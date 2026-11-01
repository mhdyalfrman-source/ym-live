import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:tom_chat/features/chat/chat_screen.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/features/rooms/models/seat_model.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/features/chat/models/room_chat_model.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'package:tom_chat/statics_values.dart';

seatUserAction(
  BuildContext context,
  RoomController controller,
  SeatModel seat,
) {
  return [
    UserOption(
      onTap: () async {
        Get.back();
        controller.selectedCommentUsers.clear();
        if (seat.seatNumber == -1 && seat.user != null) {
          controller.selectedCommentUsers.add(seat.user!);
        }
        await controller.onOpenGift(seat.user);
      },
      icon: Icons.card_giftcard,
      label: context.l10n.sendGift,
      child: Image.asset(
        "assets/images/send_gift.png",
        width: 30.r,
        height: 30.r,
      ),
    ),
    if (seat.user?.userId != StaticValue.userData.userId)
      UserOption(
        onTap: () {
          Get.back();
          HomeController controller = Get.find();

          int index = controller.roomChats.indexWhere(
            (m) => m.user?.userId == seat.user!.userId,
          );

          if (index >= 0) {
            controller.selectedRoom.value = index;
          } else {
            controller.roomChats.insert(
              0,
              RoomChatModel(
                chats: [],
                id: seat.user!.userId,
                lastMessage: null,
                lastMessageDate: null,
                unreadMessage: 0,
                user: seat.user,
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
        label: context.l10n.message,
        child: Image.asset(
          "assets/images/message.png",
          width: 30.r,
          height: 30.r,
        ),
      ),
    if ((controller.currentUserIsHost.value ||
            (controller.userRole.value == RoleEnum.admin &&
                (controller.room.value.owner?.userId != seat.user?.userId)) ||
            StaticValue.userData.pos.value > UserPosition.superAdmin.value) &&
        (seat.user?.pos.value ?? 0) <= UserPosition.superAdmin.value) ...[
      if (seat.seatNumber != -1) ...[
        UserOption(
          onTap: () {
            Get.back();
            controller.takeSeat(seat.seatNumber, 0);
          },
          icon: HugeIcons.strokeRoundedLogout01,
          label: context.l10n.down,
          child: Image.asset(
            "assets/images/down.png",
            width: 30.r,
            height: 30.r,
            color: Colors.black,
          ),
        ),
        UserOption(
          onTap: () {
            Get.back();
            controller.muteSeat(
              seat.seatNumber,
              seat.micState == StatePosition.locked ? 1 : 2,
            );
          },
          icon: seat.micState != StatePosition.locked
              ? HugeIcons.strokeRoundedMic01
              : HugeIcons.strokeRoundedMicOff01,
          label: seat.micState != StatePosition.locked
              ? context.l10n.mute
              : context.l10n.unmute,
        ),
      ] else ...[
        if (controller.room.value.seats.any((s) => s.user == null) &&
            seat.user?.userId != StaticValue.userData.userId)
          UserOption(
            onTap: () {
              Get.back();
              controller.grantSeat(seat.user!, 1);
            },
            icon: Icons.event_seat,
            label: context.l10n.invite,
          ),
      ],
    ] else if (seat.user?.userId == StaticValue.userData.userId) ...[
      UserOption(
        onTap: () {
          Get.back();
          controller.takeSeat(seat.seatNumber, 0);
        },
        icon: HugeIcons.strokeRoundedLogout01,
        label: context.l10n.down,
        child: Image.asset(
          "assets/images/down.png",
          width: 30.r,
          height: 30.r,
          color: Colors.black,
        ),
      ),
      UserOption(
        onTap: () {
          Get.back();
          controller.muteSeat(
            seat.seatNumber,
            seat.micState == StatePosition.open ? 1 : 0,
          );
        },
        icon: seat.micState == StatePosition.open
            ? HugeIcons.strokeRoundedMic01
            : HugeIcons.strokeRoundedMicOff01,
        label: seat.micState == StatePosition.open
            ? context.l10n.mute
            : context.l10n.unmute,
      ),
    ],
  ];
}

class UserOption extends StatelessWidget {
  final IconData icon;
  final Widget? child;
  final String label;
  final Function() onTap;
  const UserOption({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          if (child == null) SizedBox(height: 3.r),
          child ?? Icon(icon, color: Colors.black87, size: 22.r),
          if (child == null) SizedBox(height: 5.r),
          Text(
            label,
            style: const TextStyle(color: Colors.black87, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
