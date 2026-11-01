import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/core/utils/snakbar_dialog.dart';
import 'package:tom_chat/features/recharge_agency/controllers/recharge_agency_controller.dart';
import 'package:tom_chat/features/wallet/models/cash_data_model.dart';
import 'package:tom_chat/features/wallet/models/my_account_model.dart';
import 'package:tom_chat/features/wallet/models/payment_model.dart';
import 'package:tom_chat/features/wallet/models/withdraw_order_model.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/statics_values.dart';

class WalletController extends GetxController {
  Rx<CashDataModel?> cashData = Rx<CashDataModel?>(null);

  TextEditingController userId = TextEditingController();
  TextEditingController coins = TextEditingController();
  TextEditingController amount = TextEditingController();
  RxDouble coinsToUsd = 0.0.obs;

  TextEditingController accountName = TextEditingController();
  TextEditingController accountNumber = TextEditingController();
  Rx<int?> accountTypeId = Rx<int?>(null);

  RxList<MyAccountModel> accounts = <MyAccountModel>[].obs;

  TextEditingController diamond = TextEditingController();
  RxInt diamondToCoins = 0.obs;

  RxList<WithdrawOrderModel> orders = <WithdrawOrderModel>[].obs;
  int orderPage = 1;
  RxBool hasMoreOrders = true.obs;

  RxList<PaymentModel> payments = <PaymentModel>[].obs;
  int paymentPage = 1;
  RxBool hasMorePayments = true.obs;

  Rx<int?> selectedAccount = Rx<int?>(null);
  TextEditingController withdrawAmount = TextEditingController();
  TextEditingController agecny = TextEditingController();
  Rx<int?> selectedAgency = Rx<int?>(null);

  RxInt pageIndex = 0.obs;

  Future<void> fetchMyData() async {
    final response = await CallServerAPI.post("cash", {});
    if (response.isNotEmpty) {
      cashData.value = CashDataModel.fromJson(response);
    }
  }

  int convertUsdToCoins({required double totalUsd, required double cashRate}) {
    if (totalUsd <= 0 || cashRate <= 0) return 0;
    return (totalUsd * cashRate).round();
  }

  double convertCoinsToUsd({required int coins, required double cashRate}) {
    if (coins <= 0 || cashRate <= 0) return 0.0;
    return coins / cashRate;
  }

  Future<void> sendMoney() async {
    if (MyMath.toDouble(coins.text) >
        (convertUsdToCoins(
          totalUsd: cashData.value!.total ?? 0,
          cashRate: cashData.value!.exchangeRate,
        ))) {
      snakbarDialog(
        title: Get.context!.l10n.notEnoughMoney,
        durationSecound: 5,
      );
      return;
    }
    final response = await CallServerAPI.post("cash/sendCoins", {
      "touid": userId.text,
      "coins": coins.text,
    });
    if (response.isNotEmpty && response["dollar"] != null) {
      cashData.update((val) {
        val?.total = MyMath.toDouble(response["dollar"]);
      });
      userId.text = "";
      coins.text = "";
      coinsToUsd.value = 0;
      done();
    } else if (response["msg"] == "no_user") {
      userId.text = "";
      snakbarDialog(
        title: Get.context!.l10n.thisUserNotExis,
        durationSecound: 3,
      );
    }
  }

  Future<void> withdrawMoney() async {
    if (MyMath.toDouble(withdrawAmount.text) > (cashData.value!.total ?? 0)) {
      snakbarDialog(
        title: Get.context!.l10n.notEnoughMoney,
        durationSecound: 5,
      );
      return;
    }
    if (selectedAccount.value == null) {
      snakbarDialog(
        title: Get.context!.l10n.plsChooseAccount,
        durationSecound: 5,
      );
      return;
    }
    DateTime now = DateTime.now();
    if (cashData.value!.cashStart > now.day ||
        cashData.value!.cashEnd < now.day) {
      snakbarDialog(
        title: Get.context!.l10n.youCanSendOrdersBetween(
          cashData.value!.cashEnd,
          cashData.value!.cashStart,
        ),
        durationSecound: 5,
      );
      return;
    }
    final agencyNumber = agecny.text.trim();
    final agencyId = int.tryParse(agencyNumber);
    if (agencyNumber.isNotEmpty && (agencyId == null || agencyId <= 0)) {
      snakbarDialog(
        title: Get.context!.l10n.agencyInvalidNumber,
        durationSecound: 4,
      );
      return;
    }
    final response = await CallServerAPI.post(
      "cash/add_request",
      {
        "accountId": selectedAccount.value,
        "money": withdrawAmount.text,
        if (agencyId != null) "recharge_agency_id": agencyId,
      },
      withSnakbar: true,
      errorText: (error) => rechargeAgencyError(Get.context!, error),
    );
    if (response['created'] == true) {
      selectedAgency.value = null;
      cashData.update((val) {
        val?.total = MyMath.toDouble(response["total"]);
      });
      withdrawAmount.text = "";
      agecny.text = "";
      done();
    }
  }

  Future<void> exchangeDiamond(String coins) async {
    if (MyMath.toDouble(diamond.text) > StaticValue.diamond.value) {
      snakbarDialog(
        title: Get.context!.l10n.notEnoughMoney,
        durationSecound: 5,
      );
      return;
    }
    var res = await CallServerAPI.post("cash/exchangeDiamond", {
      "diamond": coins,
      "to": "coins",
    });
    if (res.isNotEmpty) {
      diamond.text = "";
      diamondToCoins.value = 0;
      done();
    }
  }

  Future<void> fetchAccounts() async {
    final response = await CallServerAPI.post(
      "cash/my_cash_accounts",
      {},
      withSnakbar: false,
    );
    if (response.isNotEmpty && response["list"] != null) {
      accounts.addAll(MyAccountModel.fromList(response["list"]));
      selectedAccount.value = accounts.firstOrNull?.id;
      accounts.refresh();
    }
  }

  Future<void> fetchOrders() async {
    if (!hasMoreOrders.value) return;
    final response = await CallServerAPI.post("cash/cash_request_list", {
      "p": orderPage,
      "limit": 20,
    }, withSnakbar: false);
    if (response.isNotEmpty && response["list"] != null) {
      List list = response["list"];
      orderPage++;
      hasMoreOrders.value = list.length >= 20;
      orders.addAll(WithdrawOrderModel.fromList(list));
      orders.refresh();
    } else {
      hasMoreOrders.value = false;
    }
  }

  Future<void> fetchPayments() async {
    if (!hasMorePayments.value) return;
    final response = await CallServerAPI.post("payment/userLog", {
      "p": paymentPage,
      "limit": 20,
    }, withSnakbar: false);
    if (response.isNotEmpty && response["list"] != null) {
      List list = response["list"];
      paymentPage++;
      hasMorePayments.value = list.length >= 20;
      payments.addAll(PaymentModel.fromList(list));
      payments.refresh();
    } else {
      hasMorePayments.value = false;
    }
  }

  Future<void> saveAccount() async {
    if (accountTypeId.value == null) {
      return;
    }
    final response = await CallServerAPI.post("cash/add_cash_account", {
      "type": accountTypeId.value,
      "name": accountName.text,
      "account": accountNumber.text,
    });
    if (response.isNotEmpty) {
      accounts.add(MyAccountModel.fromMap(response["account"]));
      accounts.refresh();
      accountName.text = "";
      accountNumber.text = "";
      accountTypeId.value = null;
      Get.back();
      done();
    }
  }

  Future<void> deleteAccout(MyAccountModel a) async {
    final response = await CallServerAPI.post("cash/delete_cash_account", {
      "id": a.id,
    });
    if (response.isNotEmpty) {
      accounts.removeWhere((account) => account.id == a.id);
      accounts.refresh();
      selectedAccount.value = null;
      done();
    }
  }
}
