// Bottom bar with action buttons
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/features/chat/chat_screen.dart';
import 'package:tom_chat/features/rooms/bottom_sheets/basic_tool_bottom_sheet.dart';
import 'package:tom_chat/features/rooms/bottom_sheets/emoji_bottom_sheet.dart';
import 'package:tom_chat/features/rooms/comments/comment_field_widget.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'package:tom_chat/statics_values.dart';

class BottomActionBar extends StatelessWidget {
  final RoomController c;

  const BottomActionBar({super.key, required this.c});

  Widget circleButton(
    IconData icon,
    VoidCallback? onTap, {
    double size = 40,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: onTap == null
                  ? Colors.grey.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20.r),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.black87.withOpacity(0.5)),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        spacing: 5.w,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: circleButton(HugeIcons.strokeRoundedBubbleChat, () {
              CommentFieldWidget.showChatInput(
                context,
                sendMessage: (text) async {
                  await c.sendComment(text);
                  Get.back();
                },
                textController: c.commentTextController,
                user: StaticValue.userData,
              );
            }),
          ), // chat
          Expanded(
            child: Obx(() {
              return Stack(
                children: [
                  circleButton(HugeIcons.strokeRoundedMail01, () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                        return SizedBox(
                          height: Get.height * 0.7,
                          child: ChatScreen(
                            withAllChats: true,
                            withHeader: true,
                            withNotification: false,
                          ),
                        );
                      },
                    );
                  }),
                  if (StaticValue.hasNewMessage.value)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
          Expanded(
            child: Obx(() {
              return circleButton(
                Icons.emoji_emotions_outlined,
                !c.userInGust
                    ? null
                    : () async {
                        await c.fetchEmojis();
                        EmojiBottomSheet.show(context, c);
                      },
                color: !c.userInGust ? Colors.grey.shade600 : Colors.white,
              );
            }),
          ),
          GestureDetector(
            onTap: () async {
              c.selectedCommentUsers.clear();
              await c.onOpenGift(null);
            },
            child: SizedBox(
              width: 45.r,
              height: 45.r,
              child: Image.asset("assets/images/gift.png"),
            ),
          ),
          Expanded(
            child: Obx(() {
              return circleButton(
                c.isMicOn.value == 0
                    ? HugeIcons.strokeRoundedMic01
                    : HugeIcons.strokeRoundedMicOff01,
                !c.userInGust ||
                        (c.isMicOn.value == 2 &&
                            (!c.currentUserIsHost.value &&
                                c.userRole.value != RoleEnum.admin))
                    ? null
                    : () {
                        int index = c.userGustIndex;
                        if (c.isMicOn.value == 0) {
                          c.muteSeat(c.room.value.seats[index].seatNumber, 1);
                          c.isMicOn.value = 1;
                        } else {
                          c.muteSeat(c.room.value.seats[index].seatNumber, 0);
                          c.isMicOn.value = 0;
                        }
                        c.switchToBroadcaster(
                          withPublishMic: c.isMicOn.value == 0,
                        );
                      },
                color: !c.userInGust ? Colors.grey.shade600 : Colors.white,
              );
            }),
          ),
          Expanded(
            child: Obx(
              () => circleButton(
                c.isSoundOn.value
                    ? HugeIcons.strokeRoundedVolumeHigh
                    : HugeIcons.strokeRoundedVolumeOff,
                c.playing.value
                    ? null
                    : () {
                        c.isSoundOn.toggle();
                        if (c.isSoundOn.value) {
                          c.engine!.enableAudio();
                        } else {
                          c.engine!.disableAudio();
                        }
                      },
                color: c.playing.value ? Colors.grey.shade600 : Colors.white,
              ),
            ),
          ),
          Expanded(
            child: circleButton(HugeIcons.strokeRoundedGridView, () {
              BasicToolBottomSheet.show(context, c);
            }, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
