import 'dart:io';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/core/image/image_gallery.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/utils/chat_bubble.dart';
import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/core/utils/open_camera_gallery.dart';
import 'package:tom_chat/core/utils/swip_page.dart';
import 'package:tom_chat/core/utils/wait_message.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/core/widgets/buttons.dart';
import 'package:tom_chat/features/chat/models/reaction_model.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart' hide ChatState;
import 'package:get/get.dart' hide Trans;
import 'package:intl/intl.dart' hide TextDirection;
import 'package:tom_chat/features/profile/profile_screen.dart';
import 'package:tom_chat/features/rooms/controllers/room_seat_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/features/chat/models/chat_model.dart';
import 'package:tom_chat/features/chat/models/room_chat_model.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'package:tom_chat/statics_values.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:bubble/bubble.dart';

class ChatLayout extends StatefulWidget {
  const ChatLayout({
    super.key,
    required this.chats,
    required this.userReceiver,
    required this.addMessage,
    // required this.chatId,
  });

  final List<ChatModel> chats;
  final UserModel userReceiver;
  // final int chatId;
  final Function(ChatModel c, int reciverId) addMessage;

  @override
  State<ChatLayout> createState() => _ChatLayoutState();
}

class _ChatLayoutState extends State<ChatLayout> {
  late HomeController controller;
  int index = -1;
  Rx<types.Message?> replyMessage = Rx<types.Message?>(null);

  @override
  void initState() {
    controller = Get.find();
    index = controller.selectedRoom.value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.onSelectChat();
      controller.roomChats[controller.selectedRoom.value].isOpened = true;
      controller.roomChats[controller.selectedRoom.value].unreadMessage = 0;
    });
    CallServerAPI.post("chat/openOnlineChat", {
      "id": controller.roomChats[controller.selectedRoom.value].id,
      "touid": controller.roomChats[controller.selectedRoom.value].user?.userId,
    }, withMessage: false);
    // controller.updateChatsState(widget.chats);
    super.initState();
  }

  @override
  void dispose() {
    for (var r in controller.roomChats) {
      r.isOpened = false;
    }
    CallServerAPI.post("chat/closeOnlineChat", {
      "id": controller.roomChats[index].id,
      "touid": controller.roomChats[index].user?.userId,
    }, withMessage: false);
    // controller.chatIsOpen.value = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      types.User user = types.User(
        id: StaticValue.userData.userId.toString(),
        firstName: StaticValue.userData.name,
        imageUrl: StaticValue.userData.avatar?.network ?? "",
      );
      return Chat(
        onEndReached: () async {
          List<ChatModel> older = await controller.fetchAllRoomChats1();

          controller.roomChats[controller.selectedRoom.value].chats!.addAll(
            older,
          );

          List<types.Message> m = controller.changeChatsModelToMessage(older);

          controller.messages.addAll(m);
          controller.messages.refresh();
        },
        onAvatarTap: (u) {
          swipToPage(context, ProfileScreen(id: MyMath.toInt(u.id)));
        },
        dateHeaderThreshold: 999999999999999999,
        disableImageGallery: true,
        imageMessageBuilder: (m, {required messageWidth}) {
          return GestureDetector(
            onTap: () {
              openDialog(
                context,
                ImagePreview(images: [m.uri], initialIndex: 0),
                true,
              );
            },
            child: Container(
              padding: EdgeInsets.only(top: 12, left: 14, right: 14, bottom: 5),
              constraints: BoxConstraints(maxWidth: messageWidth.toDouble()),
              child: CachedImage(
                m.uri,
                type: ImageType.chat,
                width: (messageWidth / 2).toDouble(),
              ),
            ),
          );
        },
        textMessageBuilder: (m, {required messageWidth, required showName}) {
          if (m.metadata?["type"] == "card") {
            return Container(
              padding: EdgeInsets.only(top: 12, left: 14, right: 14, bottom: 5),
              constraints: BoxConstraints(maxWidth: messageWidth.toDouble()),
              child: Column(
                children: [
                  Text(
                    m.metadata?["targetState"] == StateEnum.active
                        ? context.l10n.acceptCp
                        : m.metadata?["targetState"] == StateEnum.reject
                        ? context.l10n.rejectCp
                        : context.l10n.iWantMakeCpWithU,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: user.id != m.author.id
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  if (user.id != m.author.id && m.metadata?["show"])
                    Row(
                      children: [
                        Expanded(
                          child: GeneralButton3(
                            margin: 3,
                            onPressed: () async {
                              m.metadata?["show"] = false;
                              setState(() {});
                              int index =
                                  controller
                                      .roomChats[controller.selectedRoom.value]
                                      .chats
                                      ?.indexWhere(
                                        (c) => c.id.toString() == m.id,
                                      ) ??
                                  -1;
                              if (index > -1) {
                                ChatModel chat = ChatModel().copyWith(
                                  chat: controller
                                      .roomChats[controller.selectedRoom.value]
                                      .chats![index],
                                );
                                chat.id = controller.messages.length + 1000;
                                chat.user = StaticValue.userData;
                                chat.chatState = ChatState.waiting;
                                chat.createdAt = MyDateTime.now();
                                chat.id = chat.id ?? 0 + 1000;
                                chat.targetState = StateEnum.active;
                                await widget.addMessage(
                                  chat,
                                  widget.userReceiver.userId,
                                );
                                await controller.changeCpState(
                                  m.id,
                                  m.text,
                                  1,
                                  chat,
                                );
                              }
                            },
                            title: context.l10n.accept,
                          ),
                        ),
                        Expanded(
                          child: GeneralButton3(
                            margin: 3,
                            onPressed: () async {
                              m.metadata?["show"] = false;
                              setState(() {});
                              int index =
                                  controller
                                      .roomChats[controller.selectedRoom.value]
                                      .chats
                                      ?.indexWhere(
                                        (c) => c.id.toString() == m.id,
                                      ) ??
                                  -1;
                              if (index > -1) {
                                ChatModel chat = ChatModel().copyWith(
                                  chat: controller
                                      .roomChats[controller.selectedRoom.value]
                                      .chats![index],
                                );
                                chat.id = controller.messages.length + 1000;
                                chat.user = StaticValue.userData;
                                chat.chatState = ChatState.waiting;
                                chat.createdAt = MyDateTime.now();
                                chat.targetState = StateEnum.reject;
                                await widget.addMessage(
                                  chat,
                                  widget.userReceiver.userId,
                                );
                                await controller.changeCpState(
                                  m.id,
                                  m.text,
                                  0,
                                  chat,
                                );
                              }
                            },
                            title: context.l10n.reject,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          }
          return Container(
            padding: EdgeInsets.only(top: 12, left: 14, right: 14, bottom: 5),
            constraints: BoxConstraints(maxWidth: messageWidth.toDouble()),
            child: Column(
              crossAxisAlignment: user.id == m.author.id
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                // if(showName)
                // UserName(author: m.author),
                buildReply(m),
                Builder(
                  builder: (context) {
                    return Text(
                      m.text,
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color:
                            user.id != m.author.id ||
                                (m.metadata?["bubble"] ?? "") != ""
                            ? Colors.black
                            : Colors.white,
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
        l10n: ChatL10nAr(),
        onMessageLongPress: (context, types.Message m) {
          List<String> reactions = ["👍", "❤️", "😂", "😮", "😢"];
          opendDialogWithName(
            context: context,
            builder: (context) {
              return Dialog(
                insetPadding: EdgeInsets.symmetric(horizontal: Get.width / 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: reactions.map((emoji) {
                        return GestureDetector(
                          onTap: () async {
                            Get.back();
                            await Future.delayed(Duration(milliseconds: 100));
                            int? index =
                                (m.metadata?["reactions"]
                                        as List<ReactionModel>?)
                                    ?.indexWhere(
                                      (r) =>
                                          r.uid == StaticValue.userData.userId,
                                    );
                            if ((index ?? -1) == -1) {
                              await controller.reaction(
                                m.id,
                                ReactionModel(
                                  emoji: emoji,
                                  uid: StaticValue.userData.userId,
                                ),
                                0,
                              );
                            } else if ((m.metadata?["reactions"]
                                        as List<ReactionModel>)[index!]
                                    .emoji !=
                                emoji) {
                              // await controller.reaction(m.id,ReactionModel(emoji: (m.metadata?["reactions"] as List<ReactionModel>)[index].emoji, uid: StaticValue.userData.userId),1);
                              await controller.reaction(
                                m.id,
                                ReactionModel(
                                  emoji: emoji,
                                  uid: StaticValue.userData.userId,
                                ),
                                0,
                              );
                            } else {
                              await controller.reaction(
                                m.id,
                                ReactionModel(
                                  emoji:
                                      (m.metadata?["reactions"]
                                              as List<ReactionModel>)[index]
                                          .emoji,
                                  uid: StaticValue.userData.userId,
                                ),
                                1,
                              );
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5).r,
                              color:
                                  ((m.metadata?["reactions"]
                                              as List<ReactionModel>?) ??
                                          [])
                                      .any(
                                        (r) =>
                                            r.emoji == emoji &&
                                            r.uid ==
                                                StaticValue.userData.userId,
                                      )
                                  ? AppColors.primaryDark
                                  : null,
                            ),
                            padding: const EdgeInsets.all(2),
                            child: Text(emoji, style: TextStyle(fontSize: 24)),
                          ),
                        );
                      }).toList(),
                    ),
                    if (m.author.id == StaticValue.userData.userId.toString())
                      ListTile(
                        onTap: () async {
                          Get.back();
                          await Future.delayed(Duration(milliseconds: 100));
                          await controller.deleteMessage(m.id);
                        },
                        title: Text(
                          context.l10n.delete,
                          style: Theme.of(context).textTheme.labelMedium!
                              .copyWith(color: Colors.black),
                        ),
                      ),
                  ],
                ),
              );
            },
            name: "MESSAGE",
          );
        },
        bubbleBuilder:
            (Widget child, {required message, required nextMessageInGroup}) {
              return buildBubble(
                user: user,
                message: message,
                child: child,
                context: context,
                nextMessageInGroup: nextMessageInGroup,
              );
            },
        customBottomWidget: Obx(() {
          return Column(
            children: [
              if (replyMessage.value != null)
                Container(
                  padding: EdgeInsets.all(8),
                  color: neutral0,
                  child: Row(
                    children: [
                      Icon(HugeIcons.strokeRoundedLinkForward),
                      SizedBox(width: 5.w),
                      Expanded(
                        child: Text(
                          getMessageText(replyMessage.value!),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          replyMessage.value = null;
                        },
                      ),
                    ],
                  ),
                ),
              Input(
                onSendPressed: onSendPressed,
                onAttachmentPressed: onAttachmentPressed,
                options: InputOptions(
                  usesSafeArea: false,
                  // textEditingController: controller.chatController,
                  autocorrect: true,
                ),
              ),
            ],
          );
        }),
        onAttachmentPressed: onAttachmentPressed,
        customDateHeaderText: (v) => DateFormat("yyyy-MM-dd").format(v),
        dateFormat: DateFormat("yyyy-MM-dd "),
        theme: DefaultChatTheme(
          inputBorderRadius: BorderRadius.zero,
          attachmentButtonIcon: Icon(Icons.image_outlined),
          backgroundColor: Colors.transparent,
          primaryColor: Theme.of(context).primaryColor,
          bubbleMargin: EdgeInsets.only(bottom: 1.5),
          statusIconPadding: EdgeInsets.only(bottom: 20, left: 4, right: 4),
        ),
        showUserAvatars: true,
        showUserNames: true,
        dateHeaderBuilder: (d) => Align(
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            margin: EdgeInsets.only(bottom: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade400,
            ),
            child: Text(
              d.text,
              textDirection: TextDirection.ltr,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ),
        user: user,
        onSendPressed: onSendPressed,
        messages: controller.messages.map((e) => e).toList(),
      );
    });
  }

  Text buildChatText({
    String? text,
    required BuildContext context,
    required types.User user,
    required types.TextMessage m,
  }) => Text(
    text ?? "NULL",
    style: Theme.of(context).textTheme.displayMedium!.copyWith(
      color: user.id != m.author.id ? Colors.black : Colors.white,
    ),
  );

  Widget buildBubble({
    required types.User user,
    required types.Message message,
    Widget? child,
    required BuildContext context,
    required bool nextMessageInGroup,
  }) {
    if ((message.metadata?["bubble"] ?? "") != "" &&
        message.metadata?["type"] != "card") {
      return ChatBubblePro(
        width: Get.width,
        textColor: Colors.black,
        bubbleUrl: message.metadata?["bubble"],
        text: "",
        child: Column(
          crossAxisAlignment: user.id != message.author.id
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            if (child != null) child.marginZero,

            buildReactions(message),
            Container(
              padding: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
              child: Text(
                DateFormat("h:mm a").format(
                  DateTime.fromMillisecondsSinceEpoch(message.createdAt!),
                ),
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                  // color: user.id != message.author.id ? Colors.black : Colors.white
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Bubble(
      padding: BubbleEdges.all(0),
      shadowColor: message.type == types.MessageType.image
          ? Colors.transparent
          : null,
      color: message.type == types.MessageType.image
          ? Colors.transparent
          : user.id != message.author.id
          ? const Color(0xfff5f5f7)
          : Theme.of(context).primaryColor,
      margin: nextMessageInGroup
          ? const BubbleEdges.symmetric(horizontal: 10, vertical: 0)
          : null,
      radius: Radius.circular(10),
      stick: false,
      nip: nextMessageInGroup
          ? BubbleNip.no
          : user.id != message.author.id
          ? BubbleNip.leftBottom
          : BubbleNip.rightBottom,
      child: Column(
        crossAxisAlignment: user.id != message.author.id
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          if (child != null) child.marginZero,

          buildReactions(message),
          Container(
            padding: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
            child: Text(
              DateFormat(
                "h:mm a",
              ).format(DateTime.fromMillisecondsSinceEpoch(message.createdAt!)),
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                fontWeight: FontWeight.normal,
                color:
                    user.id != message.author.id ||
                        message.type == types.MessageType.image
                    ? Colors.black
                    : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildReactions(types.Message message) {
    final reactions = message.metadata?["reactions"] as List<ReactionModel>?;

    if (reactions == null || reactions.isEmpty) return SizedBox();

    return Wrap(
      spacing: 4,
      children: reactions.map((e) {
        return GestureDetector(
          onTap: () async {
            if (e.uid == StaticValue.userData.userId) {
              await controller.reaction(
                message.id,
                ReactionModel(emoji: e.emoji, uid: StaticValue.userData.userId),
                1,
              );
            } else if (!reactions.any(
              (r) => r.emoji == e.emoji && r.uid == StaticValue.userData.userId,
            )) {
              await controller.reaction(
                message.id,
                ReactionModel(emoji: e.emoji, uid: StaticValue.userData.userId),
                0,
              );
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: e.uid == StaticValue.userData.userId
                  ? AppColors.primaryDark
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(e.emoji),
          ),
        );
      }).toList(),
    );
  }

  Widget buildReply(types.Message message) {
    final reply = message.metadata?["reply"] as ChatModel?;

    if (reply == null) return const SizedBox();

    final isMe = reply.user?.userId == StaticValue.userData.userId;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isMe ? Colors.white.withOpacity(0.15) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            /// الخط الجانبي
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: isMe ? Colors.white : Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMe ? context.l10n.you : (reply.user?.name ?? "User"),
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isMe
                            ? Colors.white
                            : Theme.of(context).primaryColor,
                      ),
                    ),

                    const SizedBox(height: 2),

                    /// نص الرسالة
                    Text(
                      reply.chatText?.isNotEmpty == true
                          ? reply.chatText!
                          : "📷 صورة",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: isMe ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getMessageText(types.Message m) {
    if (m.metadata?["type"] == "card") {
      return m.metadata?["targetState"] == StateEnum.active
          ? context.l10n.acceptCp
          : m.metadata?["targetState"] == StateEnum.reject
          ? context.l10n.rejectCp
          : context.l10n.iWantMakeCpWithU;
    }
    if (replyMessage.value?.type == types.MessageType.text) {
      return (replyMessage.value! as types.TextMessage).text;
    }
    return context.l10n.image;
  }

  void onAttachmentPressed() async {
    final path = await openGallery();
    if (path == "") return;
    ChatModel chat = ChatModel(
      id: controller.messages.length + 1000,
      chatType: ChatType.IMAGE,
      user: StaticValue.userData,
      chatState: ChatState.waiting,
      createdAt: MyDateTime.now(),
    );

    waitMessage();
    chat.imageUrl = await uplaudImage(File(path), ImageUploadType.file);
    Get.back();
    if (replyMessage.value != null) {
      chat.replyMessage = controller
          .roomChats[controller.selectedRoom.value]
          .chats
          ?.firstWhere((c) => c.id.toString() == replyMessage.value!.id);
    }
    await widget.addMessage(chat, widget.userReceiver.userId);
    await controller.sendMessage(
      chatId: chat.id!,
      userId: widget.userReceiver.userId,
      img: chat.imageUrl,
      replyid: replyMessage.value?.id,
    );
    replyMessage.value = null;
  }

  void onSendPressed(v) async {
    await sendMessage(v.text, ChatType.TEXT);
  }

  sendMessage(String v, ChatType chatType) async {
    ChatModel chat = ChatModel(
      id: controller.messages.length + 1000,
      chatText: v,
      chatType: chatType,
      user: StaticValue.userData,
      chatState: ChatState.waiting,
      createdAt: MyDateTime.now(),
    );
    if (replyMessage.value != null) {
      chat.replyMessage = controller
          .roomChats[controller.selectedRoom.value]
          .chats
          ?.firstWhere((c) => c.id.toString() == replyMessage.value!.id);
    }
    await widget.addMessage(chat, widget.userReceiver.userId);
    await controller.sendMessage(
      chatId: chat.id!,
      userId: widget.userReceiver.userId,
      message: v,
      replyid: replyMessage.value?.id,
    );
    replyMessage.value = null;
  }
}
