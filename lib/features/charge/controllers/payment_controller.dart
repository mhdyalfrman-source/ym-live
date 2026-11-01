import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/core/utils/snakbar_dialog.dart';
import 'package:tom_chat/features/wallet/models/cash_data_model.dart';
import 'package:tom_chat/statics_values.dart';

class CoinPlan {
  final int id;
  final String name;
  final int coin;
  final double money;
  final int type;
  final String nameEn;
  final String? androidCode;
  final String? iosCode;

  CoinPlan({
    required this.id,
    required this.name,
    required this.coin,
    required this.money,
    required this.type,
    required this.nameEn,
    this.androidCode,
    this.iosCode,
  });

  factory CoinPlan.fromJson(Map<String, dynamic> json) {
    return CoinPlan(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      coin: json['coin'] ?? 0,
      money: MyMath.toDouble(json['money']),
      type: json['type'] ?? 0,
      nameEn: json['name_en'] ?? '',
      androidCode: json['product_id'],
      iosCode: json['ios_product_id'],
    );
  }
}

class ExchangePlan {
  final int id;
  final int coins;
  final double money;
  final int state;

  ExchangePlan({
    required this.id,
    required this.coins,
    required this.money,
    required this.state,
  });

  factory ExchangePlan.fromJson(Map<String, dynamic> json) {
    return ExchangePlan(
      id: json['id'] ?? 0,
      coins: json['coins'] ?? 0,
      money: json['money'] ?? 0,
      state: json['state'] ?? 0,
    );
  }
}

class PaymentController extends GetxController {
  final isLoading = false.obs;
  final isStoreLoading = false.obs;
  final isExchangeLoading = false.obs;
  final coinPlans = <CoinPlan>[].obs;
  RxList<ExchangePlan> exchangePlans = <ExchangePlan>[].obs;
  final selectedPlanIndex = 0.obs;
  final selectedexchangePlanIndex = (-1).obs;
  // Rx<CashDataModel?> profileData = Rx<CashDataModel?>(null);
  RxBool rechargeOpen = false.obs;

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  Rx<CashDataModel?> profileData = Rx<CashDataModel?>(null);

  RxDouble selectedCoin = 0.0.obs;
  RxDouble selectedDiamond = 0.0.obs;

  /// Initialize and load available products
  Future<void> initialize() async {
    _listenToPurchaseUpdates();
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      // throw Exception("In-app purchases are not available on this device.");
    }
  }

  /// Purchase a product
  Future<(bool, String)> purchaseProduct() async {
    isStoreLoading.value = true;
    try {
      final ProductDetailsResponse response = await _inAppPurchase
          .queryProductDetails({
            if (Platform.isAndroid)
              coinPlans[selectedPlanIndex.value].androidCode!,
            if (Platform.isIOS) coinPlans[selectedPlanIndex.value].iosCode!,
          });
      if (response.notFoundIDs.isNotEmpty) {
        snakbarDialog(title: "error", durationSecound: 10);
        return (false, "purchase_id_not_found");
      }

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: response.productDetails.first,
      );

      bool purchaseResult = await _inAppPurchase.buyConsumable(
        purchaseParam: purchaseParam,
      );

      if (purchaseResult) {
        return (true, "purchase_success");
      } else {
        return (false, "purchase_failed");
      }
    } on PlatformException catch (error) {
      if (error.code == 'storekit_duplicate_product_object') {
        // Notify the user about the pending transaction
        return (false, "purchase_pending_transaction");
      } else {
        // Handle other errors
        return (false, "purchase_general_error");
      }
    } finally {
      isStoreLoading.value = false;
    }
  }

  /// Restore previous purchases
  Future<void> restorePurchases() async {
    await _inAppPurchase.restorePurchases(
      /*applicationUserName: "ap.screenshot.pro"*/
    );
  }

  /// Listen to purchase updates
  void _listenToPurchaseUpdates() {
    _purchaseSubscription = _inAppPurchase.purchaseStream.listen((
      List<PurchaseDetails> purchaseDetailsList,
    ) async {
      for (PurchaseDetails purchaseDetails in purchaseDetailsList) {
        if (purchaseDetails.status == PurchaseStatus.restored) {
          //
        }
        if (purchaseDetails.status == PurchaseStatus.purchased) {
          await _processPurchase(purchaseDetails);
        } else if (purchaseDetails.status == PurchaseStatus.canceled) {
          //
          _handlePurchaseCancellation(purchaseDetails);
        } else if (purchaseDetails.status == PurchaseStatus.error) {
          _handleError(purchaseDetails.error);
        }
      }
    }, onError: (error) {});
  }

  /// Process and verify purchase
  Future<void> _processPurchase(PurchaseDetails purchaseDetails) async {
    try {
      final verified = await _savePurchase(purchaseDetails);
      if (verified && purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _savePurchase(PurchaseDetails purchaseDetails) async {
    Map<String, dynamic> data = {
      "token": purchaseDetails.verificationData.serverVerificationData,
      "product_id": purchaseDetails.productID,
      "type": Platform.isAndroid ? "google" : "ios",
    };
    GetStorage().write("pay", json.encode(data));
    var response = await CallServerAPI.post("payment/pay", data);
    if (response.isNotEmpty) {
      StaticValue.coins.value = response["coins"];
      GetStorage().remove("pay");
      return true;
    }
    return false;
  }

  /// Handle purchase cancellation
  Future<void> _handlePurchaseCancellation(
    PurchaseDetails purchaseDetails,
  ) async {
    isLoading.value = false;
  }

  /// Handle purchase errors
  void _handleError(IAPError? error) {
    isLoading.value = false;
  }

  Future<void> fetchCoinPlans() async {
    try {
      isLoading.value = true;
      update();

      final response = await CallServerAPI.post(
        'payment',
        {},
        withMessage: false,
      );

      final plansData = response['plans'] ?? response['data']?['plans'];
      final rechargeValue =
          response['recharge_open'] ?? response['data']?['recharge_open'];

      if (plansData != null && plansData is List) {
        final List<CoinPlan> plans = plansData
            .map((plan) => CoinPlan.fromJson(plan))
            .toList();

        coinPlans.assignAll(
          plans
              .where(
                (p) =>
                    (p.androidCode != null && Platform.isAndroid) ||
                    (p.iosCode != null && Platform.isIOS),
              )
              .toList(),
        );

        rechargeOpen.value =
            rechargeValue.toString() == '1' || rechargeValue == true;
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void selectPlan(int index) {
    selectedPlanIndex.value = index;
    update(); // Force update if needed, though Obx should handle it
  }

  CoinPlan? get selectedPlan {
    if (coinPlans.isNotEmpty && selectedPlanIndex.value < coinPlans.length) {
      return coinPlans[selectedPlanIndex.value];
    }
    return null;
  }

  void refreshPlans() {
    fetchCoinPlans();
  }

  /// Dispose resources
  @override
  void onClose() {
    _purchaseSubscription?.cancel();
  }
}
