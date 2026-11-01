import 'dart:convert';

import 'package:timeago_flutter/timeago_flutter.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/utils/swip_page.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/chat/chat_layout.dart';
import 'package:tom_chat/features/notifications/models/notification_model.dart';
import 'package:tom_chat/features/notifications/notification_screen.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' hide Trans;
import 'package:tom_chat/features/profile/components/user_name_widget.dart';
import 'package:tom_chat/features/store/models/store_item_model.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/features/chat/models/room_chat_model.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'package:tom_chat/statics_values.dart';

class ChatScreen extends StatefulWidget {
  final bool withAllChats;
  final bool withHeader;
  final bool withNotification;
  const ChatScreen({
    super.key,
    required this.withAllChats,
    required this.withHeader,
    required this.withNotification,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  PageController subPageController = PageController();
  ScrollController scrollController = ScrollController();
  late HomeController controller;
  @override
  void initState() {
    super.initState();
    controller = Get.find();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchAllChats();
      if (!widget.withAllChats) {
        subPageController.jumpToPage(1);
      }
      StaticValue.hasNewMessage.value = false;
    });
    scrollController.addListener(() async {
      if (scrollController.position.maxScrollExtent <=
              scrollController.offset &&
          scrollController.offset > 0) {
        await controller.fetchAllChats();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.selectedRoom.value = -1;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      RoomChatModel? c;
      if (controller.selectedRoom.value >= 0) {
        c = controller.roomChats[controller.selectedRoom.value];
      }
      return PageTemplete(
        title: widget.withHeader ? (c?.title ?? context.l10n.chats) : "",
        withIcon: controller.selectedRoom.value != -1,
        onBack: () {
          if (widget.withAllChats && controller.selectedRoom.value != -1) {
            controller.roomChats[controller.selectedRoom.value].isOpened =
                false;
            subPageController.jumpToPage(0);
          } else {
            Get.back();
          }
          controller.selectedRoom.value = -1;
        },
        backgroundColor: Theme.of(context).primaryColorLight,
        child: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: subPageController,
          children: [
            items(),
            if (controller.selectedRoom.value != -1)
              ChatLayout(
                addMessage: (c, reciverId) async {
                  await controller.addMessageToUserList(c, reciverId);
                },
                chats: c!.chats!,
                userReceiver:
                    controller.roomChats[controller.selectedRoom.value].user!,
              ),
          ],
        ),
      );
    });
  }

  Widget items() {
    return Obx(() {
      return RefreshIndicator(
        onRefresh: () async {
          controller.roomChats.clear();
          controller.hasMoewChats = true;
          controller.chatsPage = 1;
          return await controller.fetchAllChats();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: scrollController,
          children: [
            // if(widget.withNotification)
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     TopNotificationItem(
            //       image: "assets/images/ic_user_chat.png",
            //       title: context.l10n.systemNotifications,
            //       onTap: (){
            //         swipToPage(context, NotificationScreen(title: context.l10n.systemNotifications,types: [NotificationType.comments_add,NotificationType.comments_like,NotificationType.lives_start,NotificationType.profile_follow,NotificationType.videos_like]));
            //       },
            //     ),
            //     TopNotificationItem(
            //       image: "assets/images/ic_user_event.png",
            //       title: context.l10n.agencyNotifications,
            //       onTap: (){
            //         swipToPage(context, NotificationScreen(title: context.l10n.agencyNotifications,types: [NotificationType.mentions]));
            //       },
            //     ),
            //     TopNotificationItem(
            //       image: "assets/images/logo.png",
            //       title: context.l10n.tomChatTeam,
            //       onTap: (){
            //         swipToPage(context, NotificationScreen(title: context.l10n.tomChatTeam,types: [NotificationType.system]));
            //       },
            //     ),
            //   ],
            // ),
            SizedBox(height: 15.h),
            ...controller.roomChats.asMap().entries.map((item) {
              String? lastMessage = item.value.lastMessage?.chatText;
              try {
                if (item.value.lastMessage?.chatText != null &&
                    item.value.lastMessage!.chatText!.startsWith('{"')) {
                  Map<String, dynamic> card = json.decode(
                    item.value.lastMessage!.chatText!,
                  );
                  StoreItemModel store = StoreItemModel.fromMap(card);
                  lastMessage =
                      item.value.lastMessage?.targetState == StateEnum.active
                      ? context.l10n.acceptCp
                      : item.value.lastMessage?.targetState == StateEnum.reject
                      ? context.l10n.rejectCp
                      : context.l10n.iWantMakeCpWithU;
                } else if ((item.value.lastMessage?.imageUrl ?? "") != "") {
                  lastMessage = context.l10n.image;
                }
              } catch (_) {}
              return Column(
                children: [
                  ListTile(
                    onTap: () async {
                      controller.selectedRoom.value = item.key;
                      controller.messages.clear();
                      subPageController.jumpToPage(1);
                    },
                    title: LayoutBuilder(
                      builder: (context, c) {
                        return AutoScrollText(
                          textAlign: TextAlign.start,
                          width: c.maxWidth,
                          text: (item.value.displayTitle ?? ""),
                          style: Theme.of(context).textTheme.labelLarge!
                              .copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                        );
                      },
                    ),
                    subtitle: (lastMessage ?? "") == ""
                        ? null
                        : RichText(
                            maxLines: 3,
                            text: TextSpan(
                              style: Theme.of(context).textTheme.labelMedium!
                                  .copyWith(color: Colors.black),
                              children: [
                                TextSpan(text: lastMessage ?? ""),
                                if (item.value.lastMessageDate != null)
                                  WidgetSpan(
                                    child: Timeago(
                                      builder: (context, time) {
                                        return Text(
                                          " • $time",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium!
                                              .copyWith(color: Colors.black),
                                        );
                                      },
                                      date: item.value.lastMessageDate!
                                          .toLocalDateTime(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                    leading: ProfileAvatar(
                      openProfileType: OpenProfileType.full,
                      user: item.value.user!,
                      radius: 22.r,
                    ),
                    trailing: item.value.unreadMessage > 0
                        ? Container(
                            padding: EdgeInsets.all(5).r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.red,
                            ),
                            child: Text(
                              item.value.unreadMessage > 99
                                  ? "99+"
                                  : item.value.unreadMessage.toString(),
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          )
                        : SizedBox(),
                  ),
                  // Divider(height: 0,color: Colors.grey.shade500,)
                ],
              );
            }),
          ],
        ),
      );
    });
  }
}

class TopNotificationItem extends StatelessWidget {
  final String image;
  final String title;
  final Function() onTap;
  const TopNotificationItem({
    super.key,
    required this.image,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Image.asset(image, height: 35.h),
          SizedBox(height: 5.h),
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
