import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:tom_chat/controllers/socket_manager.dart';
import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/features/agency/models/agency_model.dart';
import 'package:tom_chat/features/chat/controllers/message_controller.dart';
import 'package:tom_chat/features/chat/models/reaction_model.dart';
import 'package:tom_chat/features/home/components/notification_widget.dart';

import 'package:tom_chat/features/home/controllers/variable.dart';
import 'package:tom_chat/features/chat/models/chat_model.dart';
import 'package:tom_chat/features/chat/models/room_chat_model.dart';
import 'package:tom_chat/features/settings/setting_screen.dart';
import 'package:tom_chat/features/vip/models/vip_model.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'package:tom_chat/statics_values.dart';

mixin HomeListeners on GetxService
    implements
        HomeControllerVariables,
        MessageController /*,NotificationController*/ {
  startUserListener() {
    SocketManager.instance.off("privateMessage");
    SocketManager.instance.on("privateMessage", (data) async {
      if (chatPageIsOpended && data["type"] == "message") {
        StaticValue.hasNewMessage.value = true;
        ChatModel chat = ChatModel.fromMap(data["message"]);
        int index = roomChats.indexWhere(
          (r) => r.user?.userId == chat.user?.userId,
        );
        if (index >= 0) {
          roomChats[index].chats ??= [];
          roomChats[index].chats!.insert(0, chat);
          roomChats[index].lastMessage = chat;
          roomChats[index].lastMessageDate = chat.createdAt;
          if (roomChats[index].isOpened ?? false) {
            StaticValue.hasNewMessage.value = false;
            roomChats[index].unreadMessage = 0;
            messages.insert(0, await changeChatModelToMessage(chat));
            messages.refresh();
          } else {
            roomChats[index].unreadMessage++;
            roomChats.refresh();
            showCustomNotification(chat);
          }
        } else {
          roomChats.insert(
            0,
            RoomChatModel(
              chats: [chat],
              id: data["chat_id"],
              lastMessage: chat,
              lastMessageDate: chat.createdAt,
              unreadMessage: 1,
              user: chat.user,
            ),
          );
          showCustomNotification(chat);
        }
      } else if (data["type"] == "message") {
        StaticValue.hasNewMessage.value = true;
        ChatModel chat = ChatModel.fromMap(data["message"]);
        showCustomNotification(chat);
      } else if (data["type"] == "deleteMessage") {
        int mesId = MyMath.toInt(data["messageID"]);
        ChatModel chat = ChatModel.fromMap(data["last_message"]);
        int index = roomChats.indexWhere((r) => r.user?.userId == chat.uid);
        if (index >= 0) {
          roomChats[index].chats?.removeWhere((c) => c.id == mesId);
          roomChats[index].lastMessage = roomChats[index].chats?.lastOrNull;
          roomChats[index].lastMessageDate =
              roomChats[index].chats?.lastOrNull?.createdAt;
          if (roomChats[index].isOpened ?? false) {
            messages.removeWhere((m) => m.id == mesId.toString());
            messages.refresh();
          } else {
            roomChats.refresh();
          }
        }
      } else if (data["type"] == "reactions") {
        int mesId = MyMath.toInt(data["msgID"]);
        ChatModel chat = ChatModel.fromMap(data["chat"]);
        List<ReactionModel>? reactions = ChatModel.parseReactions(
          data['reactions'],
        );
        int index = roomChats.indexWhere((r) => r.id == chat.id);
        if (index >= 0 && reactions != null) {
          int? i = roomChats[index].chats?.indexWhere((c) => c.id == mesId);
          if ((i ?? -1) != -1) {
            roomChats[index].chats?[i!].reactions = reactions;
          }
          if (roomChats[index].isOpened ?? false) {
            int i = messages.indexWhere((m) => m.id == mesId.toString());
            messages[i].metadata?["reactions"] = reactions;
            messages.refresh();
          }
        }
      } else if (data["type"] == "messageState") {
        int chatId = MyMath.toInt(data["chat_id"]);
        List<int> ids = data["message_ids"] is List
            ? List<int>.from(
                (data["message_ids"] as List).map((e) => MyMath.toInt(e)),
              )
            : [];
        if (ids.isEmpty) return;
        int state = MyMath.toInt(data["state"], defaultVal: 2);
        int targetState = MyMath.toInt(data["target_state"], defaultVal: 2);
        ChatState chatState = ChatState.values.firstWhere(
          (v) => v.value == state,
          orElse: () => ChatState.received,
        );
        StateEnum targetStateEnum = StateEnum.values.firstWhere(
          (v) => v.value == targetState,
          orElse: () => StateEnum.reject,
        );
        int index = roomChats.indexWhere((r) => r.id == chatId);
        if (index >= 0) {
          for (final chat in roomChats[index].chats ?? <ChatModel>[]) {
            if (ids.contains(chat.id)) {
              chat.chatState = chatState;
              chat.targetState = targetStateEnum;
            }
          }
          if (roomChats[index].lastMessage?.id != null &&
              ids.contains(roomChats[index].lastMessage!.id)) {
            roomChats[index].lastMessage?.chatState = chatState;
            roomChats[index].lastMessage?.targetState = targetStateEnum;
          }
          if (roomChats[index].isOpened ?? false) {
            for (final id in ids) {
              int i = messages.indexWhere((m) => m.id == id.toString());
              if (i >= 0) {
                messages[i].metadata?["state"] = state;
                messages[i].metadata?["targetState"] = targetStateEnum;
                messages[i] = messages[i].copyWith(
                  status: getStatus(chatState),
                );
              }
            }
            messages.refresh();
          }
          roomChats.refresh();
        }
      }
    });

    SocketManager.instance.off("updateUserData");
    SocketManager.instance.on("updateUserData", (data) async {
      if ((data as Map).containsKey("coins") && data["coins"] != null) {
        StaticValue.userData.coins = MyMath.toInt(data["coins"]);
        StaticValue.coins.value = MyMath.toInt(data["coins"]);
      } else if (data.containsKey("diamond") && data["diamond"] != null) {
        StaticValue.userData.diamond = data["diamond"];
        StaticValue.diamond.value = data["diamond"];
      } else if (data.containsKey("vip") && data["vip"] != null) {
        StaticValue.userData.vip = VipModel.fromMap(data["vip"]);
        user.value.vip = VipModel.fromMap(data["vip"]);
      } else if (data.containsKey("guild") && data["guild"] != null) {
        agency.value = AgencyModel.fromMap(data["guild"]);
      } else if (data.containsKey("banned")) {
        await logout();
      }
    });
  }

  void stopUserListener() {
    // SocketManager.instance.off("globalAnimation");
    SocketManager.instance.off("privateMessage");
  }

  // void _addAnimation(GiftModel gift, int count) {
  //   if (gift.giftAnimation != null && (gift.giftAnimation?.network??"").endsWith('.svga') && (gift.isAllNotify == 2)) {
  //     int existingIndex = receivedWaitingGiftsAnimation
  //         .indexWhere((element) => element.sendId == gift.sendId);
  //     if (existingIndex != -1) {
  //       receivedWaitingGiftsAnimation[existingIndex] =
  //           receivedWaitingGiftsAnimation[existingIndex].copyWith(
  //               count:
  //                   receivedWaitingGiftsAnimation[existingIndex].count + count);
  //     } else {
  //       if (receivedGiftAnimation.value?.sendId == gift.sendId) {
  //         receivedWaitingGiftsAnimation.insert(0, gift.copyWith(count: count));
  //       } else {
  //         receivedWaitingGiftsAnimation.add(gift.copyWith(count: count));
  //       }
  //     }
  //     if (receivedGiftAnimation.value == null) {
  //       receivedGiftAnimation.value = receivedWaitingGiftsAnimation.removeAt(0);
  //     }
  //   }
  // }

  Future<void> removeCurrentGiftAnimation() async {
    receivedGiftAnimation.value = null;
    await Future.delayed(const Duration(milliseconds: 500));
    if (receivedWaitingGiftsAnimation.isEmpty) {
      receivedGiftAnimation.value = null;
      return;
    }
    receivedGiftAnimation.value = receivedWaitingGiftsAnimation.removeAt(0);
  }
}

void showCustomNotification(ChatModel message) {
  Get.dialog(
    SwipeableNotification(message: message),
    barrierColor: Colors.transparent,
    barrierDismissible: true,
    useSafeArea: false,
  );
}
