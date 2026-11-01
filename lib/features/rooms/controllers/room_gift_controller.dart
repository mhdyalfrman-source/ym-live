import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/core/utils/snakbar_dialog.dart';
import 'package:tom_chat/core/utils/swip_page.dart';
import 'package:tom_chat/features/charge/controllers/payment_controller.dart';
import 'package:tom_chat/features/charge/recharge_coin_screen.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller_variables.dart';
import 'package:tom_chat/features/rooms/gifts/live_room_send_gift_bottom_sheet.dart';
import 'package:tom_chat/features/rooms/models/gift_model.dart';
import 'package:tom_chat/features/rooms/models/rocket_model.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/helpers/image_model.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'package:tom_chat/statics_values.dart';

mixin RoomGiftController on GetxController, RoomControllerVariables {
  final RxList<GiftModel> gifts = <GiftModel>[].obs;
  final RxList<GiftModel> stickers = <GiftModel>[].obs;

  final RxList<GiftModel> receivedGifts = <GiftModel>[].obs;
  final RxList<GiftModel> receivedLuckyGifts = <GiftModel>[].obs;

  final RxList<UserModel> topContributors = <UserModel>[].obs;

  // selected guest users for send gift
  final RxSet<int> selectedGuestUsers = <int>{}.obs;
  final RxList<UserModel> selectedCommentUsers = <UserModel>[].obs;

  final Rx<GiftModel?> comboGift = Rx<GiftModel?>(null);
  final RxInt _subGiftIndex = (-1).obs;
  final RxString sendId = ''.obs;
  late DateTime lastSendGiftTime;
  late DateTime lastIncreasingComboTime;

  final RxBool isBottomSheetOpen = false.obs;

  Rx<GiftModel?> gift = Rx<GiftModel?>(null);

  RxList<int> comoItems = <int>[].obs;
  RxInt selctedCompo = 0.obs;

  final RxList<int> luckyWins = <int>[].obs;

  initGifts() {
    lastSendGiftTime = DateTime.now();
    lastIncreasingComboTime = DateTime.now();
    // this.giftsType = GiftsType.audioLive;
    fetchGifts();
    // fetchStickers();

    isBottomSheetOpen.listen((value) {
      if (!value) {
        sendGift(completed: true);
      }
    });
  }

  void resetGiftContreroller() {
    receivedGifts.clear();
    receivedLuckyGifts.clear();
    topContributors.clear();
    selectedGuestUsers.clear();
    selectedCommentUsers.clear();
    enteryWaitingAnimation.clear();
    enteryAnimation.value = null;
    comboGift.value = null;
  }

  void initToContributors(List<UserModel> users) {
    topContributors.assignAll(users);
  }

  void fetchGifts() async {
    var response = await CallServerAPI.post('live/giftList', {
      'rid': room.value.id,
    }, withMessage: false);
    var response2 = await CallServerAPI.post('live/giftBackpack', {
      'rid': room.value.id,
    }, withMessage: false);
    if (response.isNotEmpty) {
      List<GiftModel> giftList = [];
      final giftsMap = response['gifts'] as Map<String, dynamic>?;

      if (giftsMap != null) {
        giftsMap.forEach((key, value) {
          if (value is List) {
            for (var item in value) {
              giftList.add(GiftModel.fromJson(item));
            }
          }
        });
      }

      for (var item in (response2['gifts'] ?? [])) {
        giftList.add(GiftModel.fromJson(item)..type = GiftType.backPack);
      }

      if ((response['combo'] is List)) {
        comoItems.assignAll(List.from(response['combo']));
      }
      selctedCompo.value = comoItems.firstOrNull ?? 0;

      gifts.assignAll(giftList);
      if (gifts.isNotEmpty && gift.value == null) {
        gift.value = gifts[0];
        for (var i = 0; i < gifts.length - 1; i++) {
          if (gifts[i].coins < gift.value!.coins) {
            gift.value = gifts[i];
          }
        }
      }
      gifts.refresh();
      comoItems.refresh();
    }
  }

  Future<void> fetchStickers() async {
    if (stickers.isNotEmpty) return;
    var response = await CallServerAPI.post('gift', {'type': 'sticker'});
    if (response.isNotEmpty) {
      List<GiftModel> giftList = [];
      for (var item in response['gifts']) {
        giftList.add(GiftModel.fromJson(item));
      }

      stickers.assignAll(giftList);
      StaticValue.coins.value = MyMath.toInt(response['coins']);
    }
  }

  bool enableSendGift() {
    // selectedGuestUsers.removeWhere(
    //     (element) => ! room.value.seats.any((user) => user.user?.userId == element));

    if (selectedGuestUsers.isEmpty) {
      snakbarDialog(
        title: Get.context!.l10n.noGuestUsersTitle,
        durationSecound: 5,
      );
      return false;
    }
    // check money
    if (comboGift.value?.coins != null &&
        comboGift.value!.coins *
                comboGift.value!.count *
                selectedGuestUsers.length >
            StaticValue.coins.value) {
      recharge();
      return false;
    }
    return true;
  }

  Future<void> sendGift({bool completed = false, GiftModel? gift}) async {
    // var gift = comboGift.value?.copyWith();
    comboGift.value = comboGift.value?.copyWith(count: 0);
    if (completed) {
      comboGift.value = null;
    }

    if (gift == null || gift.count < 1) return;
    if (!enableSendGift()) return;
    if (gift.type == GiftType.backPack && gift.count < selctedCompo.value) {
      snakbarDialog(
        title: Get.context!.l10n.notEnoughGiftCount,
        durationSecound: 5,
      );
      return;
    }
    lastSendGiftTime = DateTime.now();
    var response = await CallServerAPI.post('live/sendGift', {
      // 'type': "giftsType.name",
      'toUsers': selectedGuestUsers.join(','),
      'gift': gift.id.toString(),
      // 'giftCount': gift.count.toString(),
      // 'giftCount': selctedCompo.value,
      'is_backpack': gift.type == GiftType.backPack ? 1 : 0,
      'count': selctedCompo.value,
      'rid': room.value.id,
      "endCombo": 1,
    });
    if (response.isNotEmpty) {
      StaticValue.coins.value = MyMath.toInt(response['coins']);
      if (gift.type == GiftType.backPack) {
        for (var i = 0; i < gifts.length; i++) {
          if (gifts[i].id == gift.id && gifts[i].type == GiftType.backPack) {
            gifts[i].lng -= selctedCompo.value;
            gifts.refresh();
            break;
          }
        }
      }
      int backCoins = MyMath.toInt(response["coinsBack"]);
      if (backCoins != 0) {
        luckyWins.add(backCoins);
        luckyWins.refresh();
      }
      // currentGifterLevel.value = LevelsModel.fromMap(response['gifter_level']);
    }
  }

  void handleGift(GiftModel gift, int count) {
    if ((gift.giftAnimation?.network ?? "") != "") {
      addAnimation(
        UserModel(userId: 0, name: "", entry: gift.giftAnimation),
        true,
      );
    }

    int existingGiftIndex = receivedGifts.indexWhere(
      (element) => element.sendId == gift.sendId,
    );
    if (existingGiftIndex != -1) {
      receivedGifts[existingGiftIndex] = receivedGifts[existingGiftIndex]
          .copyWith(count: receivedGifts[existingGiftIndex].count + count);
    } else {
      receivedGifts.add(gift.copyWith(count: count));
    }
  }

  void removeNormalGiftByUserId(String sendId) {
    receivedGifts.removeWhere((gift) => gift.sendId == sendId);
  }

  void removeLuckyGift() {
    receivedLuckyGifts.removeAt(0);
  }

  void setComboGift(GiftModel gift) {
    if (!enableSendGift()) return;
    if (gift.coins > StaticValue.coins.value) {
      recharge();
      return;
    }
    sendGiftWithDelay();
    lastSendGiftTime = DateTime.now();
    lastIncreasingComboTime = DateTime.now();
    sendId.value =
        "${gift.id}_${StaticValue.userData.userId}_${DateTime.now().millisecondsSinceEpoch}";
    comboGift.value = gift;
  }

  void removeComboGift() {
    if (comboGift.value != null) {
      sendGift();
    }
    comboGift.value = null;
    subGiftIndex.value = (-1);
  }

  Future<void> increaseComboCount() async {
    if (!enableSendGift()) return;
    lastIncreasingComboTime = DateTime.now();
    comboGift.value = comboGift.value?.copyWith(
      count: comboGift.value!.count + 1,
    );
    if (DateTime.now().difference(lastSendGiftTime).inSeconds > 2) {
      await sendGift();
    }
    sendGiftWithDelay();
  }

  Future<void> sendGiftWithDelay() async {
    await Future.delayed(Duration(seconds: 2), () async {
      if (DateTime.now().difference(lastIncreasingComboTime).inSeconds >= 2) {
        await sendGift(completed: true);
      }
    });
  }

  Future<void> recharge() async {
    Get.put(PaymentController());
    swipToPage(Get.context!, RechargeCoinScreen());
  }

  void addSelectedGuestUser(int userId) {
    selectedGuestUsers.add(userId);
  }

  void removeSelectedGuestUser(int userId) {
    selectedGuestUsers.remove(userId);
  }

  void clearSelectedGuestUsers() {
    selectedGuestUsers.clear();
  }

  void selectAllGuestUsers(List<UserModel> guestUsers) {
    selectedGuestUsers.assignAll(guestUsers.map((e) => e.userId));
  }

  RxInt get subGiftIndex {
    if (_subGiftIndex.value == -1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _subGiftIndex.value = 0;
      });
    }
    return _subGiftIndex;
  }

  Future<void> onOpenGift(UserModel? selectedGust) async {
    // if(selectedGust?.userId == StaticValue.userData.userId)return;
    if (selectedGust != null) {
      selectedGuestUsers.clear();
      selectedGuestUsers.add(selectedGust.userId);
    }
    await LiveRoomSendGiftBottomSheet.show(
      Get.context!,
      Get.find<RoomController>(),
      (gift) {},
      // seats.length <= 1 ? null :
      room.value,
      selectedGust,
      StaticValue.userData,
    );
  }

  Future<void> removeCurrentEnteryAnimation() async {
    enteryAnimation.value = null;
    await Future.delayed(const Duration(milliseconds: 500));
    if (enteryWaitingAnimation.isEmpty) {
      enteryAnimation.value = null;
      return;
    }
    enteryAnimation.value = enteryWaitingAnimation.removeAt(0);
  }

  void addRocketAnimation(RocketLevel rocket, UserModel? to) {
    addAnimation(
      UserModel(
        userId: 0,
        name: "",
        entry: ImageModel(network: rocket.anim.replaceAll(".cdn", "")),
      ),
      null,
    );
  }

  void addAnimation(UserModel? entery, bool? isGifts) {
    if (!showSvgaGifts.value && isGifts == true) return;
    if (!showSvgaEntries.value && isGifts == false) return;
    if ((((entery?.vip?.entryEffect ?? entery?.entry?.network))?.endsWith(
              '.svga',
            ) ??
            false) ||
        (((entery?.vip?.entryEffect ?? entery?.entry?.network))?.endsWith(
              '.mp4',
            ) ??
            false)) {
      enteryWaitingAnimation.add(entery!);
      if (enteryAnimation.value == null) {
        enteryAnimation.value = enteryWaitingAnimation.removeAt(0);
      }
    }
  }
}
