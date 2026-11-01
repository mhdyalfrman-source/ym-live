import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:popover/popover.dart';
import 'package:tom_chat/core/utils/delete_dialog.dart';
import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/chat/chat_screen.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/features/profile/components/user_name_widget.dart';
import 'package:tom_chat/features/rooms/bottom_sheets/online_list_bottom_sheet.dart';
import 'package:tom_chat/features/rooms/bottom_sheets/small_profile_bottom_sheet.dart';
import 'package:tom_chat/features/rooms/components/seat_user_action.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/features/rooms/models/seat_model.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/features/chat/models/room_chat_model.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'package:tom_chat/statics_values.dart';

class SeatWidget extends StatefulWidget {
  final SeatModel seat;
  final RoomController controller;

  const SeatWidget({super.key, required this.seat, required this.controller});

  @override
  State<SeatWidget> createState() => _SeatWidgetState();
}

class _SeatWidgetState extends State<SeatWidget> {
  /// فتح القائمة للكرسي الفاضي
  void _showEmptySeatMenu(BuildContext context) {
    List<Widget> items = options();
    showPopover(
      context: context,
      transitionDuration: const Duration(milliseconds: 180),
      arrowHeight: 10,
      arrowWidth: 20,
      bodyBuilder: (context) => Column(children: items),
      width: 160,
      height: items.length * 60.h,
      backgroundColor: Colors.black87,
      barrierColor: Colors.transparent,
    );
  }

  List<Widget> options() {
    bool isLocked = widget.seat.seatState == StatePosition.locked;
    bool isOwner =
        widget.controller.currentUserIsHost.value ||
        widget.controller.userRole.value == RoleEnum.admin ||
        StaticValue.userData.pos.value > UserPosition.superAdmin.value;
    return [
      if (isLocked && !isOwner && widget.seat.user == null)
        ListTile(
          title: Text(
            context.l10n.askChair,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          onTap: () {
            Get.back();
            widget.controller.takeSeat(widget.seat.seatNumber);
          },
        )
      else if (widget.seat.user == null)
        ListTile(
          title: Text(
            context.l10n.takeTheMic,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          onTap: () {
            Get.back();
            widget.controller.takeSeat(widget.seat.seatNumber);
          },
        ),
      if (widget.seat.user?.userId == StaticValue.userData.userId)
        ListTile(
          title: Text(
            context.l10n.leaveTheMic,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          onTap: () {
            Get.back();
            widget.controller.takeSeat(widget.seat.seatNumber, 0);
          },
        ),

      if (isOwner &&
          widget.seat.user?.userId != StaticValue.userData.userId) ...[
        ListTile(
          title: Text(
            isLocked ? context.l10n.openTheMic : context.l10n.closeTheMic,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          onTap: () {
            Get.back();
            widget.controller.seatState(
              widget.seat.seatNumber,
              isLocked ? StatePosition.open.value : StatePosition.locked.value,
            );
          },
        ),
      ],
    ];
  }

  void _openUserDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        return Center(
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ProfileAvatar(user: widget.seat.user!, radius: 40),
                const SizedBox(height: 10),
                UserNameWidget(
                  user: widget.seat.user,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    UserOption(
                      onTap: () {
                        SmallProfileBottomSheet.show(
                          context: context,
                          user: widget.seat.user!,
                        );
                      },
                      icon: Icons.home,
                      label: "Homepage",
                    ),
                    UserOption(
                      onTap: () async {
                        Get.back();
                        await widget.controller.onOpenGift(widget.seat.user!);
                      },
                      icon: Icons.card_giftcard,
                      label: "Send gift",
                    ),
                    UserOption(
                      onTap: () {
                        Get.back();
                        HomeController controller = Get.find();

                        int index = controller.roomChats.indexWhere(
                          (m) => m.user?.userId == widget.seat.user!.userId,
                        );

                        if (index >= 0) {
                          controller.selectedRoom.value = index;
                        } else {
                          controller.roomChats.insert(
                            0,
                            RoomChatModel(
                              chats: [],
                              id: widget.seat.user!.userId,
                              lastMessage: null,
                              lastMessageDate: null,
                              unreadMessage: 0,
                              user: widget.seat.user,
                            ),
                          );
                          controller.selectedRoom.value = 0;
                        }

                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return SizedBox(
                              height: Get.height * 0.7,
                              child: ChatScreen(
                                withAllChats: false,
                                withHeader: true,
                                withNotification: false,
                              ),
                            );
                          },
                          isScrollControlled: true,
                        );
                      },
                      icon: Icons.message,
                      label: "Message",
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (widget.controller.currentUserIsHost.value) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MicButton(
                        onTap: () {
                          Get.back();
                          widget.controller.takeSeat(widget.seat.seatNumber, 0);
                        },
                        icon: HugeIcons.strokeRoundedLogout01,
                        label: "Down",
                      ),
                      MicButton(
                        onTap: () {
                          Get.back();
                          widget.controller.muteSeat(
                            widget.seat.seatNumber,
                            widget.seat.micState == StatePosition.open ? 2 : 0,
                          );
                        },
                        icon: widget.seat.micState == StatePosition.open
                            ? HugeIcons.strokeRoundedMic01
                            : HugeIcons.strokeRoundedMicOff01,
                        label: widget.seat.micState == StatePosition.open
                            ? "Mute"
                            : "Unmute",
                      ),
                      MicButton(
                        onTap: () {},
                        icon: HugeIcons.strokeRoundedMusicNote03,
                        label: "Mute Music",
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final seat = widget.seat;
    final isEmpty = seat.user == null;

    return GestureDetector(
      onTap: () {
        final int hasRequsets = widget.controller.userRequests.indexWhere(
          (u) => u.seatNumber == seat.seatNumber,
        );
        if (hasRequsets >= 0 && widget.controller.currentUserIsHost.value) {
          deleteMessage(
            title: context.l10n.seatRequest,
            content: context.l10n.seatReuestBy(
              widget.controller.userRequests[hasRequsets].user?.name ?? "",
            ),
            onDelete: () {
              Get.back();
              widget.controller.acceptRequst(seat.seatNumber, 1);
              widget.controller.userRequests.removeAt(hasRequsets);
            },
            onCancel: () {
              Get.back();
              widget.controller.acceptRequst(seat.seatNumber, 0);
              widget.controller.userRequests.removeAt(hasRequsets);
            },
            onWillPop: true,
            cancelButton: context.l10n.reject,
            deleteButton: context.l10n.accept,
          );
        } else if (isEmpty /*|| seat.user?.userId == StaticValue.userData.userId*/ ) {
          _showEmptySeatMenu(context);
        } else {
          SmallProfileBottomSheet.show(
            context: context,
            user: seat.user!,
            children: seatUserAction(context, widget.controller, seat),
            icon:
                seat.user?.userId == StaticValue.userData.userId ||
                    widget.seat.user?.userId ==
                        widget.controller.room.value.owner?.userId ||
                    (widget.seat.user?.pos.value ?? 0) >
                        UserPosition.superAdmin.value
                ? null
                : UserRoomSettings(
                    controller: widget.controller,
                    user: widget.seat.user!,
                    roomId: widget.controller.room.value.id,
                    icon: Icon(
                      HugeIcons.strokeRoundedSettings01,
                      color: Colors.black,
                    ),
                  ),
          );
          // _openUserDialog();
        }
      },
      child: Column(
        children: [
          Obx(() {
            final userId = StaticValue.userData.userId == seat.user?.userId
                ? 0
                : seat.user?.userId;
            final double rawVol =
                widget.controller.remoteUserVolumes.containsKey(userId)
                ? (widget.controller.remoteUserVolumes[userId] ?? 0).toDouble()
                : 0;

            final double maxSpread = 15;
            final double maxBlur = 30;

            final double spread = (rawVol / 100).clamp(0, 1) * maxSpread;
            final double blur = (rawVol / 100).clamp(0, 1) * maxBlur;

            final bool hasRequsets =
                widget.controller.userRequests.any(
                  (u) => u.seatNumber == seat.seatNumber,
                ) &&
                seat.user == null;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 50.r,
              height: 50.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // boxShadow: rawVol > 0
                //     ? [
                //         BoxShadow(
                //           color: Colors.white.withOpacity(0.5),
                //           blurRadius: blur,
                //           spreadRadius: spread,
                //         ),
                //       ]
                //     : [],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: rawVol > 0 ? 0.4 : 0.0,
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 250),
                      scale: 1 + (rawVol / 100) * 0.2,
                      child: Container(
                        width: 45.r + 20,
                        height: 45.r + 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (seat.user?.vip?.color ?? Colors.white)
                              .withOpacity(0.4),
                        ),
                      ),
                    ),
                  ),

                  // --- WAVE 2 (أقوى شوي) ---
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: rawVol > 50 ? 0.25 : 0.0,
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 250),
                      scale: 1 + (rawVol / 100) * 0.3,
                      child: Container(
                        width: 50.r + 35,
                        height: 50.r + 35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (seat.user?.vip?.color ?? Colors.white)
                              .withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                  if (!isEmpty) ...[
                    Container(
                      width: 50.r,
                      height: 50.r,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(
                            0.2,
                          ), // حافة خفيفة تعطي تأثير زجاج
                          width: 1,
                        ),
                      ),
                      child: ProfileAvatar(user: seat.user!, radius: 27.r),
                    ),
                  ] else
                    ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: 50.r,
                          height: 50.r,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(
                                0.2,
                              ), // حافة خفيفة تعطي تأثير زجاج
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            seat.seatState == StatePosition.locked
                                ? Icons.lock
                                : Icons.event_seat,
                            color: Colors.white24,
                          ),
                        ),
                      ),
                    ),
                  if (!isEmpty && widget.seat.micState == StatePosition.locked)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.seat.micState == StatePosition.locked
                              ? Colors.redAccent
                              : Colors.black87,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.mic_off,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  if (hasRequsets && widget.controller.currentUserIsHost.value)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.redAccent,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          "?",
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                    ),
                  if (seat.emoji != null)
                    Positioned.fill(
                      child: Transform.scale(
                        scale: 1.2,
                        child: CachedImage(seat.emoji!, type: ImageType.store),
                      ),
                    ),
                ],
              ),
            );
          }),
          const SizedBox(height: 6),
          if (seat.user?.name != null) ...[
            UserNameWidget(
              // width: Get.width * 0.2,
              user: seat.user,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (widget.controller.room.value.carizma == 1) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    MyMath.numberToShort(seat.score),
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Icon(Icons.favorite_outline, color: Colors.white, size: 14.r),
                ],
              ),
            ],
          ] else
            Text(
              '${seat.seatNumber}',
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}

class UserOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Function() onTap;
  const UserOption({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            children: [
              Icon(icon, color: Colors.white70),
              Text(
                label,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MicButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Function() onTap;
  const MicButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Icon(icon, color: Colors.white70),
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
