import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/core/utils/snakbar_dialog.dart';
import 'package:tom_chat/features/charge/recharge_coin_screen.dart';
import 'package:tom_chat/l10n/l10n.dart';

enum RedBoxType {
  local(1),
  gloabal(2);

  final int value;
  const RedBoxType(this.value);
}

class RedBoxController extends GetxController {
  var selectedTab = "".obs;
  var selectedQuantity = 40.obs;
  var selectedPortalOption = 500.obs;

  // Custom treasure box parameters
  var customTotalCoins = 0.obs;
  var customQuantity = 0.obs;
  var customMinutes = 0.obs;

  // API response
  var isLoading = false.obs;

  // Default values for predefined options
  final Map<int, int> quantityToCoins = {
    40: 2000,
    120: 6000,
    200: 10000,
    250: 6000,
    500: 10000,
  };

  @override
  onInit() {
    super.onInit();
    selectedTab.value = Get.context!.l10n.treasureBoxTab;
  }

  void selectTab(String tab) {
    selectedTab.value = tab;
  }

  void selectQuantity(int quantity) {
    selectedQuantity.value = quantity;
  }

  void selectPortalOption(int viewers) {
    selectedPortalOption.value = viewers;
  }

  void setCustomValues(int totalCoins, int quantity, int minutes) {
    customTotalCoins.value = totalCoins;
    customQuantity.value = quantity;
    customMinutes.value = minutes;
  }

  Future<void> sendLiveBox({
    required RedBoxType type,
    bool useCustom = false,
    required int rid,
  }) async {
    isLoading.value = true;
    try {
      int coins;
      int people;
      int minutes;

      if (useCustom) {
        coins = customTotalCoins.value;
        people = customQuantity.value;
        minutes = customMinutes.value;
      } else {
        coins = quantityToCoins[selectedQuantity.value] ?? 20;
        people = selectedQuantity.value;
        minutes = 1;
      }

      // Validation
      if (!_validateInputs(coins, people, minutes, useCustom)) {
        isLoading.value = false;
        return;
      }

      final response = await CallServerAPI.post("livebox/send", {
        "rid": rid,
        "coins": coins,
        "people": people,
        "minutes": minutes,
        "type": 2, //type.value ,// 2 global
      });

      if (response.isNotEmpty && response['done'] == 1) {
        isLoading.value = false;
        Get.back();
        return;
      } else {
        Get.back();
        await showModalBottomSheet(
          context: Get.context!,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => const RechargeCoinScreen(),
        );
      }
    } catch (e) {
      snakbarDialog(title: Get.context!.l10n.errorTitle, durationSecound: 5);
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateInputs(int coins, int people, int minutes, bool useCustom) {
    final l10n = Get.context!.l10n;

    if (coins <= 0 || people <= 0 || minutes <= 0) {
      snakbarDialog(title: l10n.errorInvalidValues, durationSecound: 5);
      return false;
    }

    if (coins < 2000 || coins > 1000000) {
      snakbarDialog(title: l10n.errorCoinsRange, durationSecound: 5);
      return false;
    }

    if (people < 1 || people > 2500) {
      snakbarDialog(title: l10n.errorQuantityRange, durationSecound: 5);
      return false;
    }

    if (minutes < 1 || minutes > 5) {
      snakbarDialog(title: l10n.errorCountdownRange, durationSecound: 5);
      return false;
    }

    return true;
  }
}
