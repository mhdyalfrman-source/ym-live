// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/features/profile/components/user_name_widget.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/features/chat/models/chat_model.dart';
import 'package:tom_chat/features/chat/models/room_chat_model.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'package:tom_chat/statics_values.dart';

class SwipeableNotification extends StatefulWidget {
  final ChatModel message;
  final VoidCallback? onDismissed;

  const SwipeableNotification({
    super.key,
    required this.message,
    this.onDismissed,
  });

  @override
  State<SwipeableNotification> createState() => SwipeableNotificationState();
}

class SwipeableNotificationState extends State<SwipeableNotification> {
  double dragDistance = 0;
  bool _isDismissed = false;
  bool _isReplying = false;
  final TextEditingController _replyController = TextEditingController();
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    _startAutoCloseTimer();
  }

  void _startAutoCloseTimer() {
    _autoCloseTimer = Timer(Duration(seconds: 7), () {
      if (!_isReplying && mounted) {
        _dismissNotification();
      }
    });
  }

  void _cancelAutoCloseTimer() {
    _autoCloseTimer?.cancel();
    _autoCloseTimer = null;
  }

  void _dismissNotification() {
    if (mounted) {
      setState(() => _isDismissed = true);
      Future.delayed(const Duration(milliseconds: 300), () {
        if (Get.isDialogOpen == true) {
          Get.back();
          widget.onDismissed?.call();
        }
      });
    }
  }

  Future<void> _sendReply(String messageText) async {
    if (messageText.trim().isEmpty) return;

    HomeController controller = Get.find();

    int index = controller.roomChats.indexWhere(
      (m) => m.id == widget.message.chatId,
    );

    if (index >= 0) {
      controller.selectedRoom.value = index;
      ChatModel chat = ChatModel(
        id: controller.messages.length + 1000,
        chatText: messageText,
        chatType: ChatType.TEXT,
        user: StaticValue.userData,
        chatState: ChatState.sent,
        createdAt: MyDateTime.now(),
      );
      await controller.addMessageToUserList(
        chat,
        controller.roomChats[index].user?.userId ?? 0,
      );
      controller.roomChats[index].unreadMessage = 0;
    } else {
      controller.roomChats.insert(
        0,
        RoomChatModel(
          chats: [widget.message],
          id: widget.message.chatId,
          lastMessage: widget.message,
          lastMessageDate: widget.message.createdAt,
          unreadMessage: 1,
          user: widget.message.user,
        ),
      );
      controller.selectedRoom.value = 0;
    }

    controller.sendMessage(
      userId: widget.message.user?.userId ?? 0,
      chatId: widget.message.chatId ?? 0,
      message: messageText,
    );
    _dismissNotification();
  }

  @override
  void dispose() {
    _cancelAutoCloseTimer();
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? lastMessage = widget.message.chatText;
    try {
      if (widget.message.chatText != null &&
          widget.message.chatText!.startsWith('{"')) {
        lastMessage = widget.message.targetState == StateEnum.active
            ? context.l10n.acceptCp
            : widget.message.targetState == StateEnum.reject
            ? context.l10n.rejectCp
            : context.l10n.iWantMakeCpWithU;
      } else if ((widget.message.imageUrl ?? "") != "") {
        lastMessage = context.l10n.image;
      }
    } catch (_) {}
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(child: GestureDetector(onTap: Get.back)),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            top: MediaQuery.of(context).padding.top + 10.h + dragDistance,
            left: 12.w,
            right: 12.w,
            child: TweenAnimationBuilder(
              duration: const Duration(milliseconds: 300),
              tween: Tween<double>(begin: -100, end: 0),
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(0, _isDismissed ? -200 : value),
                  child: Opacity(
                    opacity: _isDismissed
                        ? 0
                        : (1 - (dragDistance.abs() / 100)).clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: Material(
                color: Colors.transparent,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Swipe indicator
                      Container(
                        width: double.infinity,
                        height: 20.h,
                        alignment: Alignment.center,
                        child: Container(
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // Main content row
                      Row(
                        children: [
                          // Avatar with tap to open chat
                          ProfileAvatar(
                            user: widget.message.user!,
                            radius: 20.r,
                          ),
                          SizedBox(width: 10.w),

                          // Message content - tap to open chat
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                UserNameWidget(
                                  user: widget.message.user,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                SizedBox(height: 3.h),
                                Text(
                                  lastMessage ?? "",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Reply/Cancel button - separate gesture
                          GestureDetector(
                            onTap: () {
                              if (_isReplying) {
                                // Cancel pressed - dismiss notification
                                _dismissNotification();
                              } else {
                                // Reply pressed - show input
                                setState(() {
                                  _isReplying = true;
                                  _cancelAutoCloseTimer();
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                              child: Text(
                                _isReplying
                                    ? context.l10n.cancel
                                    : context.l10n.reply,
                                style: TextStyle(
                                  color: AppColors.primaryDark,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Reply input field
                      if (_isReplying) ...[
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _replyController,
                                autofocus: true,
                                style: Theme.of(context).textTheme.labelLarge!
                                    .copyWith(color: Colors.black),
                                decoration: InputDecoration(
                                  hintText: context.l10n.enterYourMessage,
                                  filled: true,
                                  hintStyle: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .copyWith(color: Colors.black),
                                  fillColor: Colors.grey.shade100,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 10.h,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            GestureDetector(
                              onTap: () {
                                _sendReply(_replyController.text);
                                _replyController.clear();
                                setState(() => _isReplying = false);
                              },
                              child: CircleAvatar(
                                backgroundColor: AppColors.primaryDark,
                                radius: 20.w,
                                child: Icon(Icons.send_outlined),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
