import 'package:get/get.dart' hide Trans;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/core/utils/snakbar_dialog.dart';
import 'package:tom_chat/features/chat/models/reaction_model.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/features/home/controllers/variable.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/features/chat/models/chat_model.dart';
import 'package:tom_chat/features/chat/models/room_chat_model.dart';
import 'package:tom_chat/models/user/user_model.dart';

mixin MessageController on GetxService implements HomeControllerVariables {
  onSelectChat() async {
    roomChats[selectedRoom.value].chats ??= [];
    List<types.Message> chats = [];
    messages.clear();
    if ((roomChats[selectedRoom.value].page ?? 1) == 1) {
      roomChats[selectedRoom.value].chats = [];
      List<ChatModel> temp = await fetchAllRoomChats1();
      roomChats[selectedRoom.value].chats!.addAll(temp);
    }
    chats = changeChatsModelToMessage(roomChats[selectedRoom.value].chats!);
    messages.addAll(chats.map((e) => e));
    roomChats[selectedRoom.value].isOpened = true;
    messages.refresh();

    await updateChatsState(roomChats[selectedRoom.value].chats!);
  }

  Future<void> fetchAllChats() async {
    if (hasMoewChats) {
      var res = await CallServerAPI.post("chat", {
        "p": chatsPage,
        "limit": limitCount,
      });
      if (res.isNotEmpty && res["list"] != null) {
        List<RoomChatModel> chats = RoomChatModel.fromList(res["list"]);
        for (var i = 0; i < chats.length; i++) {
          if (!roomChats.any((c) => c.id == chats[i].id)) {
            roomChats.add(chats[i]);
          }
        }
        hasMoewChats = res["list"].isNotEmpty;
        chatPageIsOpended = true;
        chatsPage++;
      } else {
        hasMoewChats = false;
      }
    }
  }

  Future<List<ChatModel>> fetchAllRoomChats1() async {
    roomChats[selectedRoom.value].page ??= 1;
    // int userId = roomChats[selectedRoom.value].id??0;
    int page = roomChats[selectedRoom.value].page!;
    bool hasMore = roomChats[selectedRoom.value].hasMoreData ?? true;

    if (!hasMore) return [];
    List<ChatModel> chats = [];
    var res = await CallServerAPI.post("chat/getMessages", {
      // "chat_id":userId,
      "touid": roomChats[selectedRoom.value].user?.userId,
      "p": page,
      "limit": limitCount,
    }, withMessage: page == 1);
    if (res.isNotEmpty && res["list"] is List) {
      chats.addAll(ChatModel.fromList(res["list"]));
      roomChats[selectedRoom.value].hasMoreData =
          (res["list"] as List).length == limitCount;
      roomChats[selectedRoom.value].page =
          roomChats[selectedRoom.value].page! + 1;
    }
    return chats;
  }

  updateChatsState(List<ChatModel> chats) async {
    // for (var i = 0; i < chats.length; i++) {
    //   ChatModel c = ChatModel().copyWith(chat: chats[i]);
    //   if(c.chatState!=ChatState.RECIVED && c.userSender!.userId != StaticValue.userData.userId ){
    //     c.userReceiver = c.userSender;
    //     await changeMessageState(c);
    //   }
    // }
  }

  // changeMessageState(ChatModel chat)async{
  //   chat.chatState = ChatState.RECIVED;
  //     await sendMessage(
  //       chat: chat,
  //     );
  // }

  sendMessage({
    required int userId,
    required int chatId,
    String? message,
    String? img,
    String? replyid,
  }) async {
    var res = await CallServerAPI.post("chat/sendMessage", {
      "touid": userId,
      if (message != null) "content": message,
      if (img != null) "image_url": img,
      if (replyid != null) "reply_id": replyid,
    }, withMessage: false);
    if (res.isNotEmpty && res["message"] != null) {
      ChatModel chat = ChatModel.fromMap(res["message"]);
      if (replyid != null) {
        chat.replyMessage = roomChats[selectedRoom.value].chats?.firstWhere(
          (c) => c.id.toString() == replyid,
        );
      }
      updateMessageState(chat, chatId);
    }
  }

  updateMessageState(ChatModel chat, chatId) {
    int selectRoom = selectedRoom.value;
    int index = messages.indexWhere((m) => m.id == chatId.toString());
    if (index >= 0) {
      messages[index] = messages[index].copyWith(
        id: chat.id.toString(),
        status: getStatus(chat.chatState ?? ChatState.sent),
      );
    }
    index = roomChats[selectRoom].chats!.indexWhere((m) => m.id == chatId);
    if (index >= 0) {
      roomChats[selectRoom].chats![index].id = chat.id;
      roomChats[selectRoom].chats![index].chatState = chat.chatState;
    }
  }

  List<types.Message> changeChatsModelToMessage(List<ChatModel> chats) {
    List<types.Message> list = [];
    for (var e in chats) {
      types.User sender = types.User(
        id: e.user!.userId.toString(),
        createdAt: e.createdAt?.compareTo(MyDateTime.now()),
        firstName: e.user?.name,
        imageUrl: e.user?.avatar?.network ?? "",
      );
      types.Status status = getStatus(e.chatState!);
      if ((e.imageUrl ?? "") != "") {
        list.add(
          types.ImageMessage(
            metadata: {
              "reactions": e.reactions,
              "reply": e.replyMessage,
              "type": "image",
            },
            createdAt: e.createdAt!.millisecondsSinceEpoch,
            showStatus: true,
            status: status,
            author: sender,
            id: e.id!.toString(),
            height: 100,
            name: "Image ${e.id}",
            size: 0,
            uri: e.imageUrl!,
            width: 100,
          ),
        );
        continue;
      }
      list.add(
        types.TextMessage(
          metadata: {
            "reactions": e.reactions,
            "reply": e.replyMessage,
            "type": e.card != null ? "card" : "text",
            "targetState": e.targetState,
            "show": e.targetState == StateEnum.pending,
            "bubble": e.user?.chatBubble ?? e.user?.vip?.bubble,
          },
          // metadata: {"type":"e.chatType!.name","bubble":"https://tomchat.fra1.digitaloceanspaces.com/admin/9da0214bd8152779543815f95447a9d9.png"},
          createdAt: e.createdAt!.millisecondsSinceEpoch,
          showStatus: true,
          status: status,
          author: sender,
          id: e.id!.toString(),
          text: e.chatText ?? "",
        ),
      );
    }
    return list;
  }

  Future<types.Message> changeChatModelToMessage(ChatModel chat) async {
    types.User sender = types.User(
      id: chat.user!.userId.toString(),
      createdAt: chat.createdAt!.compareTo(MyDateTime.now()),
      firstName: chat.user!.name,
      imageUrl: chat.user!.avatar?.network ?? "",
    );
    types.Status status = getStatus(chat.chatState!);
    if ((chat.imageUrl ?? "") != "") {
      return types.ImageMessage(
        metadata: {
          "reactions": chat.reactions,
          "reply": chat.replyMessage,
          "type": "image",
        },
        createdAt: chat.createdAt!.millisecondsSinceEpoch,
        showStatus: true,
        status: status,
        author: sender,
        id: chat.id!.toString(),
        height: 100,
        name: "Image ${chat.id}",
        size: 0,
        uri: chat.imageUrl!,
        width: 100,
      );
    }
    return types.TextMessage(
      metadata: {
        "reactions": chat.reactions,
        "reply": chat.replyMessage,
        "type": chat.card != null ? "card" : "text",
        "targetState": chat.targetState,
        "show": chat.targetState == StateEnum.pending,
        "bubble": chat.user?.chatBubble ?? chat.user?.vip?.bubble,
      },
      createdAt: chat.createdAt!.millisecondsSinceEpoch,
      showStatus: true,
      status: status,
      author: sender,
      id: chat.id!.toString(),
      text: chat.chatText!,
    );
  }

  types.Status getStatus(ChatState chatState) {
    return chatState == ChatState.waiting
        ? types.Status.sending
        : chatState == ChatState.sent
        ? types.Status.sent
        : types.Status.seen;
  }

  addMessageToUserList(ChatModel c, int reciverId) async {
    int index = roomChats.indexWhere((r) {
      return r.user!.userId == reciverId;
    });
    if (index == -1) return;
    roomChats[index].lastMessage = c;
    roomChats[index].lastMessageDate = c.createdAt;
    roomChats[index].chats!.insert(0, c);
    messages.insert(0, (await changeChatModelToMessage(c)));
  }

  String getSubTitleForChatRoom(List<ChatModel>? chats) {
    return (chats?.lastOrNull?.imageUrl ?? "") != ""
        ? Get.context!.l10n.image
        : chats?.lastOrNull?.chatText ?? "";
  }

  Future<bool> deleteMessage(String id) async {
    var res = await CallServerAPI.post("chat/delete", {
      "chat_id": roomChats[selectedRoom.value].id,
      "type": "all",
      "msgID": id,
    }, withMessage: false);
    if (res.isNotEmpty) {
      messages.removeWhere((m) => m.id == id);
      roomChats[selectedRoom.value].chats?.removeWhere(
        (c) => c.id.toString() == id.toString(),
      );
      done();
      return true;
    }
    return false;
  }

  Future<bool> changeCpState(
    String id,
    String text,
    int newState,
    ChatModel c,
  ) async {
    try {
      if (text.startsWith('{"')) {
        var res = await CallServerAPI.post("cp/changeCpState", {
          "touid": roomChats[selectedRoom.value].user?.userId,
          "accept": newState,
        }, withMessage: false);
        if (res.isNotEmpty) {
          int index =
              roomChats[selectedRoom.value].chats?.indexWhere(
                (c) => c.id.toString() == id,
              ) ??
              -1;
          if (index > -1) {
            roomChats[selectedRoom.value].chats?[index].targetState =
                StateEnum.deleted;
          }
          ChatModel chat = ChatModel.fromMap(res["message"]);
          chat.chatText = c.chatText;
          chat.targetState = newState == 1
              ? StateEnum.active
              : StateEnum.reject;
          chat.card = c.card;
          updateMessageState(chat, c.id);
          done();
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  Future<void> reaction(
    String messageId,
    ReactionModel emoji,
    int isDelete,
  ) async {
    var res = await CallServerAPI.post('chat/addReaction', {
      'id': messageId.toString(),
      'emoji': emoji.emoji,
      'isDelete': isDelete,
    });

    if (res.isNotEmpty && res['reactions'] != null) {
      List<ReactionModel>? reactions = ChatModel.parseReactions(
        res['reactions'],
      );
      int index = messages.indexWhere((m) => m.id == messageId);
      int? chatIndex = roomChats[selectedRoom.value].chats?.indexWhere(
        (c) => c.id.toString() == messageId.toString(),
      );
      if (isDelete == 1) {
        messages[index].metadata?["reactions"] = reactions;
        if ((chatIndex ?? -1) != -1) {
          roomChats[selectedRoom.value].chats?[chatIndex!].reactions =
              reactions;
        }
      } else {
        messages[index].metadata?["reactions"] = reactions;
        if ((chatIndex ?? -1) != -1) {
          roomChats[selectedRoom.value].chats?[chatIndex!].reactions =
              reactions;
        }
      }
      messages.refresh();
    }
  }
}
