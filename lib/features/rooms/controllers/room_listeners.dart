import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tom_chat/controllers/socket_manager.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/core/utils/delete_dialog.dart';
import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/features/rooms/controllers/room_agora_controller.dart';
import 'package:tom_chat/features/rooms/controllers/room_comments_controller.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller_variables.dart';
import 'package:tom_chat/features/rooms/controllers/room_gift_controller.dart';
import 'package:tom_chat/features/rooms/controllers/room_seat_controller.dart';
import 'package:tom_chat/features/rooms/live_ended_page.dart';
import 'package:tom_chat/features/rooms/models/gift_model.dart';
import 'package:tom_chat/features/rooms/models/red_box.dart';
import 'package:tom_chat/features/rooms/models/room_model.dart';
import 'package:tom_chat/features/rooms/models/seat_model.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/helpers/image_model.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'package:tom_chat/statics_values.dart';

mixin RoomListeners on GetxController
    implements
        RoomControllerVariables,
        RoomGiftController,
        RoomAgoraController,
        RoomCommentsController,
        RoomSeatController {
  Future<void> startLiveListeners() async {
    SocketManager.instance.on('roomMessage', (data) {
      UserModel user = UserModel.fromMap(data["person"]);
      if (data["msg"] == "roomJoin" && data["type"] == "notification") {
        if (user.userId != room.value.owner?.userId) {
          roomUsersCount.value++;
        }
      } else if (data["msg"] == "leaveRoom" && data["type"] == "notification") {
        if (user.userId == room.value.owner?.userId) {
          // if(room.value.owner?.userId != StaticValue.userData.userId){
          //   leaveRoom(withEndCall: true,withOutCheck: true,withClearRoom: true);
          //   Get.back(closeOverlays: true);
          //   Get.to(()=>LiveEndedPage(user: user));
          // }
        } else {
          roomUsersCount.value--;
        }
      } else if (data["type"] == "normal") {
        var comment = LiveCommentModel.fromMap(data);
        addComment(comment);
      }
    });

    SocketManager.instance.on('stopRoom', (data) {
      leaveRoom(withEndCall: true, withOutCheck: true, withClearRoom: true);
      Get.back(closeOverlays: true);
      UserModel user = UserModel.fromMap(data);
      Get.to(() => LiveEndedPage(user: user));
    });

    SocketManager.instance.on('message', (data) {
      var comment = LiveCommentModel.fromMap(data);
      addComment(comment);
    });

    SocketManager.instance.on('roomData', (data) {
      room.update((val) {
        val?.title = data["title"] ?? val.title;
        val?.state = data["state"] ?? val.state;
        val?.bg = data["bg"] != null ? ImageModel.fromMap(data["bg"]) : val.bg;
        val?.icon = data["icon"] != null
            ? ImageModel.fromMap(data["icon"])
            : val.icon;
        val?.password = data["isPassword"] != null
            ? MyMath.toInt(data["isPassword"])
            : val.password;
        val?.carizma = data["carizma"] != null
            ? MyMath.toInt(data["carizma"])
            : val.carizma;
      });
    });

    SocketManager.instance.on('roomSeats', (data) {
      bool userWasInGust = userInGust;
      room.update((val) {
        val?.seats = (data is List)
            ? List<SeatModel>.from((data).map((e) => SeatModel.fromJson(e)))
            : [];
      });
      int index = userGustIndex;
      if (index == -1 && userWasInGust) {
        switchToAudience(withPublishMic: false);
        isMicOn.value = 0;
        showMiniPlayer.value = false;
      } else if (index != -1) {
        StatePosition newState =
            room.value.seats[index].micState ?? StatePosition.closed;
        switchToBroadcaster(
          withPublishMic: newState == StatePosition.open,
          publishMixedAudioTrack: newState != StatePosition.locked,
        );
        if (showMiniPlayer.value) {
          showMiniPlayer.value = newState != StatePosition.locked;
        }
        isMicOn.value = newState.value;
      }
      if (!showMiniPlayer.value && playing.value) {
        stopMusic();
      }
    });

    SocketManager.instance.on('seatRequest', (data) async {
      if (data["type"] == "request") {
        data["pos"] = data["seat"];
        SeatModel seat = SeatModel.fromJson(data);
        userRequests.add(seat);
        userRequests.refresh();
      } else if (data["type"] == "invite" &&
          data["user"]?["uid"] == StaticValue.userData.userId) {
        deleteMessage(
          title: Get.context!.l10n.invite,
          content: Get.context!.l10n.inviteToSeat,
          deleteButton: Get.context!.l10n.accept,
          cancelButton: Get.context!.l10n.reject,
          onDelete: () {
            Get.back();
            acceptRequst(data["seat"]);
          },
          onCancel: () {
            Get.back();
            acceptRequst(data["seat"], 0);
          },
          onWillPop: false,
        );
      }
    });

    SocketManager.instance.on('leaveRoom', (data) {
      int index = room.value.seats.indexWhere(
        (s) => s.seatNumber == data['oldSeat'],
      );
      room.update((val) {
        if (index > -1) {
          val?.seats[index].user = null;
        }
        roomUsersCount.value = MyMath.toInt(data["users_count"]);
      });
      // invitedUsers.removeWhere((u)=>u.id == data['id']);
      // invitedUsers.refresh();
    });

    SocketManager.instance.on('userAction', (data) async {
      RoleEnum? role = RoleEnum.values.firstWhereOrNull(
        (v) => v.value == data["rule"],
      );
      if (role != null && data["uid"] == StaticValue.userData.userId) {
        userRole.value = role;
        if ([RoleEnum.banned, RoleEnum.kick].contains(role)) {
          await endCall();
          Get.back(closeOverlays: true);
          leaveRoom(
            withEndCall: false,
            withOutCheck: true,
            withClearRoom: true,
          );
        }
      }
    });

    SocketManager.instance.on('clearChat', (data) async {
      comments.clear();
      comments.refresh();
    });

    SocketManager.instance.on('enterRoom', (data) async {
      UserModel user = UserModel.fromMap(data);
      roomUsersCount.value = MyMath.toInt(data["users_count"]);
      if (user.userId == StaticValue.userData.userId) return;
      if ((user.vip?.entryEffect ?? "") != "" ||
          (user.entry?.network ?? "") != "") {
        addAnimation(user, false);
      }
      var comment = LiveCommentModel(
        message: Get.context!.l10n.joinedToRoom,
        user: user,
        type: MessageType.text,
      );
      addComment(comment);
    });

    SocketManager.instance.on('kicking', (data) async {
      roomUsersCount.value = MyMath.toInt(data["users_count"]);
    });

    SocketManager.instance.on('seatEmoji', (data) async {
      int index = room.value.seats.indexWhere(
        (s) => s.seatNumber == MyMath.toInt(data["seat"]),
      );
      room.update((val) {
        val?.seats[index].emoji = data["name"].toString();
      });
      Future.delayed(Duration(seconds: 5), () {
        room.update((val) {
          val?.seats[index].emoji = null;
        });
      });
    });

    SocketManager.instance.on('roomGift', svgaHandle);

    SocketManager.instance.on('giftLuckNot', luckyEvent);

    SocketManager.instance.on('redBox', (data) {
      RedBoxModel roomData = RedBoxModel.fromJson(data["box"]);
      if (roomData.rid == room.value.id) {
        redBoxes.add(roomData);
        redBoxes.refresh();
        startBoxTimer();
      }
      //else if(!currentUserIsHost.value){
      redBoxQueue.add(roomData);
      redBoxQueue.refresh();
      // }
    });

    SocketManager.instance.on('redBoxUse', (data) {
      int index = redBoxes.indexWhere((box) => box.id == data["box_id"]);
      if (index != -1) {
        redBoxes[index].coinsRemaining = data["coins"];
        redBoxes.refresh();
      }
    });

    SocketManager.instance.on('seatsScore', (data) {
      List list = data;
      room.update((val) {
        for (var i = 0; i < list.length; i++) {
          int index = room.value.seats.indexWhere(
            (s) => s.user?.userId == MyMath.toInt(list[i]["uid"]),
          );
          if (index == -1) continue;
          val?.seats[index].score = MyMath.toInt(list[i]["score"]);
        }
      });
    });

    SocketManager.instance.on('clearRoomGifts', (data) {
      if (room.value.id == MyMath.toInt(data["rid"])) {
        room.update((val) {
          for (var i = 0; i < val!.seats.length; i++) {
            val.seats[i].score = 0;
          }
        });
      }
    });
  }

  Future<void> stopRoomListeners() async {
    SocketManager.instance.off('roomMessage');
    SocketManager.instance.off('stopRoom');
    SocketManager.instance.off('roomData');
    SocketManager.instance.off('roomSeats');
    SocketManager.instance.off('kicking');
    SocketManager.instance.off('userAction');
    SocketManager.instance.off('enterRoom');
    SocketManager.instance.off('seatEmoji');
    SocketManager.instance.off('seatRequest');
    SocketManager.instance.off('leaveRoom');
    SocketManager.instance.off('clearChat');
    SocketManager.instance.off('redBox');
    SocketManager.instance.off('redBoxUse');
    SocketManager.instance.off('message');
    SocketManager.instance.off('seatsScore');
    SocketManager.instance.off('clearRoomGifts');
    SocketManager.instance.off('roomGift', svgaHandle);
    SocketManager.instance.off('giftLuckNot', luckyEvent);
    if (onReconnectHandler != null) {
      SocketManager.instance.off('forceReconnect', onReconnectHandler);
      onReconnectHandler = null;
    }
  }

  Future<bool> leaveRoom({
    bool withOutCheck = false,
    bool withClearRoom = false,
    required bool withEndCall,
  }) async {
    if (userInGust && !withOutCheck && !currentUserIsHost.value) {
      var res = await deleteMessage(
        title: Get.context!.l10n.areYouSrueYouWantToLeve,
        content: Get.context!.l10n.areYouSrueYouWantToLeveDesc,
        deleteButton: Get.context!.l10n.leave,
        cancelButton: Get.context!.l10n.cancel,
        onDelete: () {
          Get.back(result: true);
        },
        onCancel: Get.back,
        onWillPop: false,
      );
      if (res is! bool) {
        return false;
      }
    }
    isRoomConnected.value = false;

    SocketManager.instance.emitToServer("leaveRoom", {"rid": room.value.id});

    CallServerAPI.post("live/leaveRoom", {
      "rid": room.value.id,
      "uid": StaticValue.userData.userId,
    }, withMessage: !withOutCheck);
    deleteControllers(withClearRoom);
    if (withEndCall) {
      endCall();
    }
    return true;
  }

  void svgaHandle(data) {
    // صناعة UserModel للمُرسل
    if (data is List) {
      for (var i = 0; i < data.length; i++) {
        final sender = UserModel(
          userId: MyMath.toInt(data[i]["uid"]),
          pos: UserPosition.values.firstWhere(
            (v) => v.value == data[i]["uPos"],
            orElse: () => UserPosition.user,
          ),
          role: RoleEnum.values.firstWhereOrNull(
            (v) =>
                v.value ==
                MyMath.toInt(data[i]["uRule"], defaultVal: RoleEnum.user.value),
          ),
          name: data[i]["uName"] ?? "",
          avatar: data[i]["uAvatar"] != null
              ? ImageModel.fromMap(data[i]["uAvatar"])
              : null,
        );

        // صناعة UserModel للمستلم
        final receiver = UserModel(
          userId: MyMath.toInt(data[i]["touid"]),
          pos: UserPosition.values.firstWhere(
            (v) => v.value == data[i]["toPos"],
            orElse: () => UserPosition.user,
          ),
          role: RoleEnum.values.firstWhereOrNull(
            (v) =>
                v.value ==
                MyMath.toInt(
                  data[i]["toRule"],
                  defaultVal: RoleEnum.user.value,
                ),
          ),
          name: data[i]["toName"] ?? "",
          avatar: data[i]["toAvatar"] != null
              ? ImageModel.fromMap(data[i]["toAvatar"])
              : null,
        );

        // تعديل الماب ليناسب GiftModel الأصلي بدون تغيير الكلاس
        final map = {
          "send_id":
              "${data[i]["uid"]}-${data[i]["touid"]}-${DateTime.now().toString()}",
          "id": data[i]["gid"],
          "type": 0,
          "mark": 0,
          "name": data[i]["name"] ?? "",
          "coins": 0,
          "icon": data[i]["img"],
          "isAllNotify": data[i]["is_all_notify"],
          "isCp": 0,
          "count": data[i]["count"] ?? 1,
          "anim": data[i]["anim"],
          "rid": data[i]["rid"],
          "liveuid": data[i]["liveuid"],
        };
        GiftModel gift = GiftModel.fromJson(map, sender: sender, to: receiver);
        if (gift.rid != room.value.id) {
          continue;
        }
        handleGift(gift, data[i]['count']);
        if (data[i]["coin_number"] != null && data[i]["rid"] == room.value.id) {
          roomCoins.value = data[i]["coin_number"];
        }
        if (data[i]["room_level"] != null && data[i]["rid"] == room.value.id) {
          room.update((val) {
            val?.roomLevel = LevelModel.fromMap(data[i]["room_level"]);
          });
        }
        var comment = LiveCommentModel(
          metadata: {
            "name": map["name"],
            "count": map["count"],
            "icon": map["icon"]?["network"] ?? map["icon"] ?? "",
            "to": receiver.toMap(),
          },
          message: sender.name,
          user: sender,
          type: MessageType.gift,
        );
        addComment(comment);
      }
    }
    // handleIfIsTopContributor(user);
  }

  void deleteControllers([bool withClearRoom = true]) {
    stopRoomListeners();
    boxTimer?.cancel();
    if (withClearRoom) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        room.value = RoomModel();
        isInitialized.value = false;
      });
    }
  }

  void startBoxTimer() {
    if (redBoxes.isNotEmpty) {
      boxTimer?.cancel();
      boxTimer = AccurateTimer(const Duration(seconds: 1), (elapsed) {
        for (var i = 0; i < redBoxes.length; i++) {
          if (i > 0 &&
              redBoxes[i].seconds <= 0 &&
              redBoxes[0].coinsRemaining > 0) {
            continue;
          }
          redBoxes[i].seconds--;
        }
        redBoxes.refresh();
        if (redBoxes.isNotEmpty && redBoxes[0].seconds <= 0) {
          if (redBoxes.length > 1 &&
              (redBoxes[0].coinsRemaining <= 0 ||
                  redBoxes[0].seconds <= -600)) {
            redBoxes.removeAt(0);
            redBoxes.refresh();
          } else if (redBoxes.length == 1 &&
              ((redBoxes[0].coinsRemaining <= 0 &&
                      redBoxes[0].seconds <= -120) ||
                  redBoxes[0].seconds <= -600)) {
            redBoxes.removeAt(0);
            redBoxes.refresh();
          }
          // if(redBoxes.length > 1 && redBoxes[0].seconds <= -20){
          //   redBoxes.removeAt(0);
          //   redBoxes.refresh();
          // }else if(redBoxes.length == 1 && redBoxes[0].seconds <= -60){
          //   redBoxes.removeAt(0);
          //   redBoxes.refresh();
          // }
        }
        if (redBoxes.isEmpty) {
          boxTimer?.cancel();
          if (isBoxCoinBottomSheetOpen) {
            Get.back();
          }
        }
      });
      boxTimer?.start();
    }
  }

  void onUpdateBoxValue(RedBoxModel b) {
    int index = redBoxes.indexWhere((element) => element.id == b.id);
    if (index != -1) {
      redBoxes[index].coinsRemaining = b.coinsRemaining;
      redBoxes[index].reward = b.reward;
    }
  }

  void luckyEvent(data) {
    // data["percent"]
    if (MyMath.toInt(data["is_global"]) == 0) {
      receivedLuckyGifts.add(
        GiftModel.fromJson(
          data['gift'],
          sender: UserModel.fromMap(data['user']),
        ).copyWith(
          sendId: DateTime.now().toString(),
          count: data['count'],
          coins: MyMath.toInt(data["coins_back"]),
        ),
      );
      receivedLuckyGifts.refresh();
    }
  }
}
