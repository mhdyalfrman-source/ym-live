import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:tom_chat/controllers/socket_manager.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/core/utils/snakbar_dialog.dart';
import 'package:tom_chat/core/utils/swip_page.dart';
import 'package:tom_chat/core/widgets/buttons.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/features/home/controllers/storage_service.dart';
import 'package:tom_chat/features/rooms/bottom_sheets/online_list_bottom_sheet.dart';
import 'package:tom_chat/features/rooms/bottom_sheets/small_profile_bottom_sheet.dart';
import 'package:tom_chat/features/rooms/components/custom_text_field.dart';
import 'package:tom_chat/features/rooms/components/seat_user_action.dart';
import 'package:tom_chat/features/rooms/controllers/room_agora_controller.dart';
import 'package:tom_chat/features/rooms/controllers/room_comments_controller.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller_variables.dart';
import 'package:tom_chat/features/rooms/controllers/room_game_controller.dart';
import 'package:tom_chat/features/rooms/controllers/room_gift_controller.dart';
import 'package:tom_chat/features/rooms/controllers/room_listeners.dart';
import 'package:tom_chat/features/rooms/controllers/room_seat_controller.dart';
import 'package:tom_chat/features/rooms/models/emoji_model.dart';
import 'package:tom_chat/features/rooms/models/gift_model.dart';
import 'package:tom_chat/features/rooms/models/red_box.dart';
import 'package:tom_chat/features/rooms/models/room_model.dart';
import 'package:tom_chat/features/rooms/models/seat_model.dart';
import 'package:tom_chat/features/rooms/music/controller/music_controller.dart';
import 'package:tom_chat/features/rooms/room_error_screen.dart';
import 'package:tom_chat/features/rooms/room_screen.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'package:tom_chat/statics_values.dart';

enum RoomPrivacy { public, private }

class RoomController extends GetxController
    with
        RoomControllerVariables,
        RoomListeners,
        RoomSeatController,
        RoomAgoraController,
        RoomGiftController,
        MusicController,
        RoomCommentsController,
        LiveGamesController {
  @override
  void onInit() {
    super.onInit();
    // initGifts();

    // load persisted playlist and current track
    showSvgaEntries.value = box.read('showSvgaEntries') ?? true;
    showSvgaGifts.value = box.read('showSvgaGifts') ?? true;
    final savedPlaylist = box.read<List>('room_playlist');
    if (savedPlaylist != null) playlist.assignAll(savedPlaylist.cast<String>());
    currentTrack.value = box.read('room_current') ?? '';
  }

  void toggleShowSvgaEntries(bool v) async {
    showSvgaEntries.value = !showSvgaEntries.value;
    box.write('showSvgaEntries', showSvgaEntries.value);
  }

  void toggleShowSvgaGifts(bool v) async {
    showSvgaGifts.value = !showSvgaGifts.value;
    box.write('showSvgaGifts', showSvgaGifts.value);
  }

  Future<bool> setup({int? creatorId, required int roomId}) async {
    password = null;
    resetVariablesToDefault();
    if (StaticValue.agoraAppId == "") {
      await Get.find<HomeController>().fetchAgoraConfig();
    }
    // await initializeAgoraConfiguration(StaticValue.agoraAppId);
    if (!(await enterRoom(creatorId, roomId, false))) {
      return false;
    }
    isInitialized.value = false;
    stopRoomListeners();
    resetGiftContreroller();
    updateRommVariables();
    startLiveListeners();
    insertWelcomeComment();
    isInitialized.value = true;
    onReconnectHandler = onReconnect;
    SocketManager.instance.off('forceReconnect', onReconnectHandler);
    SocketManager.instance.on('forceReconnect', onReconnectHandler!);
    UserModel user = Get.find<HomeController>().user.value;
    addAnimation(user, false);
    LiveCommentModel comment = LiveCommentModel(
      message: Get.context!.l10n.joinedToRoom,
      user: user,
      type: MessageType.text,
    );
    addComment(comment);
    return true;
  }

  void updateRommVariables() {
    currentUserInGust.value = userInGust;
    redBoxes.value = room.value.redBoxes;
    rocket.value = room.value.rocket;
    if (room.value.owner?.userId == StaticValue.userData.userId) {
      userRole.value = RoleEnum.owner;
    } else {
      userRole.value = room.value.myRule;
    }
    startBoxTimer();
  }

  Future<void> onReconnect(_) async {
    if (isRoomConnected.value) {
      await enterRoom(room.value.owner!.userId, room.value.id, true);
      updateRommVariables();
    }
  }

  Future<bool> enterRoom(int? creatorId, int roomId, bool reconnect) async {
    RoomModel? r;
    if (creatorId == null || creatorId == StaticValue.userData.userId) {
      var startRoomResponse = await startLive(reconnect);
      r = startRoomResponse;
      currentUserIsHost.value = true;
    } else {
      var enterRoomResponse = await enterLive(roomId);
      r = enterRoomResponse.$1;
      bool isClosed = enterRoomResponse.$2 == "banned";
      if (enterRoomResponse.$2 == "bad_password" && password == null) {
        var res = await showDialog(
          context: Get.context!,
          builder: (context) {
            return Dialog(
              child: Padding(
                padding: EdgeInsets.all(8.0).r,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.l10n.thisIsPrivateRoom,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(color: Colors.black),
                    ),
                    Text(
                      context.l10n.enterPassword,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: Colors.black),
                    ),
                    SizedBox(height: 10.h),
                    CustomTextField(
                      onChanged: (v) {
                        password = v;
                      },
                      hintText: context.l10n.enterRoomPassword,
                      labelStyle: Theme.of(context).textTheme.titleLarge,
                      textStyle: Theme.of(context).textTheme.displaySmall
                          ?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                            color: Colors.black,
                          ),
                      hintStyle: TextStyle(fontSize: 16),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      borderColor: Theme.of(context).colorScheme.onSurface,
                    ),
                    SizedBox(height: 10.h),
                    GeneralButton3(
                      title: context.l10n.next,
                      onPressed: () {
                        Get.back(result: true);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
        if (res is bool) {
          return await enterRoom(creatorId, roomId, reconnect);
        }
      }
      if (enterRoomResponse.$2 == "bad_password") {
        Get.back(closeOverlays: true);
        snakbarDialog(
          title: Get.context!.l10n.errorPasswordPlsPleaseTryAgain,
          durationSecound: 5,
        );
        return false;
      }
      if (isClosed || r == null) {
        if (isClosed) {
          Get.back(closeOverlays: true);
          snakbarDialog(
            title: Get.context!.l10n.youAreBlockedFromLive,
            durationSecound: 5,
          );
        } else {
          RoomStorageService().removeRoom(roomId);
          Get.find<HomeController>().lastLives.value = RoomStorageService()
              .getRooms();
          Get.off(() => RoomErrorScreen());
        }
        return false;
      }
      currentUserIsHost.value = false;
    }
    if (r == null) {
      return false;
    }
    room.value = r;
    roomUsersCount.value = r.usersCount;
    roomCoins.value = r.coinNumber;
    int index = userGustIndex;
    isMicOn.value = index != -1 ? room.value.seats[index].micState!.value : 1;
    // SocketManager.instance.emitToServer("joinRoom",{
    //   "rid":r.id
    // });
    // startPkTimer(room.value.pkData,true);
    try {
      await joinToCall(
        appId: StaticValue.agoraAppId,
        channelId: (r.agoraChannel?.trim().isNotEmpty ?? false)
            ? r.agoraChannel!.trim()
            : 'room_${r.id}',
        rid: r.id,
        callToken: r.userSwToken!,
        // enableMic: creatorId == StaticValue.userData.userId,
        enableMic: isMicOn.value == 0,
        uid: r.agoraUid ?? StaticValue.userData.userId,
      );
    } catch (_) {}
    return true;
  }

  Future<(RoomModel?, String?)> enterLive(
    int roomId, [
    bool reconnect = false,
  ]) async {
    try {
      final response = await CallServerAPI.post('live/enterRoom', {
        'rid': roomId,
        if (password != null) 'password': password,
        if (reconnect) 'reconnect': '1',
      });
      if (response.isNotEmpty && response['err'] == null) {
        var roomData = getRoomModelFromJson(response);
        isRoomConnected.value = true;
        return (roomData, response['state']?.toString());
      }
      return (null, response['err']?.toString());
    } catch (e) {
      return (null, null);
    }
  }

  Future<RoomModel?> startLive([bool reconnect = false]) async {
    try {
      final response = await CallServerAPI.post(
        'live/startLive',
        {},
        withMessage: false,
      );
      if (response.isNotEmpty) {
        var roomData = getRoomModelFromJson(response);
        isRoomConnected.value = true;
        return roomData;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  RoomModel getRoomModelFromJson(Map json) {
    json["room"]["usersCount"] = json["usersCount"];
    // json["room"]["coin_number"] = json["coin_number"];
    json["room"]["seats"] = json["seats"];
    json["room"]["owner"] = json["owner"];
    return RoomModel.fromMap(json["room"]);
  }

  void toggleGiftPanel() => showGiftPanel.value = !showGiftPanel.value;

  void toggleMiniPlayer() => showMiniPlayer.value = !showMiniPlayer.value;

  void toggleMicSetting(bool value) {
    isMemberCanTakeMic.value = value;
  }

  void toggleMessageSetting(bool value) {
    isMemberCanSendMessage.value = value;
  }

  void togglePasswordSetting(bool value) {
    isRoomPasswordEnabled.value = value;
  }

  Future<void> createAudioRoom() async {
    try {
      isLoading.value = true;
      String image = "";
      if (imagePath.value != "") {
        image = await uplaudImage(File(imagePath.value), ImageUploadType.live);
      }

      var res = await CallServerAPI.post("room/createRoom", {
        "title": titleController.text,
        "type": "",
        "state": "",
        "micLngs": 5,
        "icon": image,
        // "bg":image,
      });
      if (res.isNotEmpty && res["room"] != null) {
        // res = await CallServerAPI.post("live/startLive", {});
        RoomModel room = RoomModel.fromMap(res["room"]);

        swipReplacementPage(
          Get.context!,
          RoomScreen(creatorId: room.uid, roomId: room.id),
        );
      }
      isLoading.value = false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create audio room: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  Future<void> fetchEmojis() async {
    if (emojies.isNotEmpty) return;
    var response = await CallServerAPI.post('live/emojiList', {
      // "limit":100ذ
    });
    if (response.isNotEmpty) {
      List<EmojiModel> giftList = [];
      for (var item in response['list']) {
        giftList.add(EmojiModel.fromMap(item));
      }

      emojies.addAll(giftList);
    }
  }

  openSmallProfile(UserModel user) {
    int index = room.value.seats.indexWhere(
      (s) => s.user?.userId == user.userId,
    );
    SmallProfileBottomSheet.show(
      context: Get.context!,
      user: user,
      children: seatUserAction(
        Get.context!,
        this,
        index == -1
            ? SeatModel(
                seatNumber: -1,
                isHost: false,
                percentageSize: 1,
                user: user,
              )
            : room.value.seats[index],
      ),
      icon:
          user.userId == StaticValue.userData.userId ||
              user.userId == room.value.owner?.userId ||
              user.pos.value > UserPosition.superAdmin.value
          ? null
          : UserRoomSettings(
              controller: this,
              user: user,
              roomId: room.value.id,
              icon: Icon(
                HugeIcons.strokeRoundedSettings01,
                color: Colors.black,
              ),
            ),
    );
  }

  Future<void> moveOnClickOnRoom(int? roomId, int? userId) async {
    if (roomId != null && userId != null) {
      if (currentUserIsHost.value || userInGust || roomId == room.value.id)
        return;
      await leaveRoom(
        withEndCall: true,
        withOutCheck: true,
        withClearRoom: true,
      );
      await setup(roomId: roomId, creatorId: userId);
    }
  }

  Future<void> moveOnClickOnGloablGift(GiftModel gift) async {
    if (gift.isAllNotify == 1 && gift.rid != null && gift.liveuid != null) {
      if (currentUserIsHost.value || userInGust || gift.rid == room.value.id)
        return;
      await leaveRoom(
        withEndCall: true,
        withOutCheck: true,
        withClearRoom: true,
      );
      await setup(roomId: gift.rid!, creatorId: gift.liveuid);
    }
  }

  Future<void> moveOnClickOnRedBox(RedBoxModel? red) async {
    if (red != null && red.rid != 0 && red.liveuid != 0) {
      if (currentUserIsHost.value || userInGust || red.rid == room.value.id)
        return;
      await leaveRoom(
        withEndCall: true,
        withOutCheck: true,
        withClearRoom: true,
      );
      await setup(roomId: red.rid, creatorId: red.liveuid);
    }
  }
}
