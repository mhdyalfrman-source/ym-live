import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/core/utils/app_bottom_sheet.dart';
import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/core/widgets/dropdown_button.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/badges/components/medals_widget.dart';
import 'package:tom_chat/features/profile/components/user_name_widget.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'package:tom_chat/statics_values.dart';

class OnlineListBottomSheet extends StatefulWidget {
  final RoomController controller;
  const OnlineListBottomSheet({super.key, required this.controller});

  @override
  State<OnlineListBottomSheet> createState() => _OnlineListBottomSheetState();

  static Future<void> show(
    BuildContext context,
    RoomController controller,
  ) async {
    await AppBottomSheet.show(
      context: context,
      child: OnlineListBottomSheet(controller: controller),
      hideHeader: true,
      borderRadius: 0,
      padding: EdgeInsets.zero,
    );
  }
}

class _OnlineListBottomSheetState extends State<OnlineListBottomSheet> {
  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    widget.controller.onLinePage = 1;
    widget.controller.hasMoreOnlineUsers.value = true;
    widget.controller.onlineUsers.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.getOnlineUsers();
    });

    scrollController.addListener(() async {
      if (scrollController.position.maxScrollExtent <=
              scrollController.offset &&
          scrollController.offset > 0) {
        await widget.controller.getOnlineUsers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10).r,
          topRight: Radius.circular(10).r,
        ),
      ),
      child: Container(
        height: Get.height * 0.6,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xCCFF6501), const Color(0x4F737373)],
            stops: [0.0, 0.3],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10).r,
            topRight: Radius.circular(10).r,
          ),
        ),
        padding: EdgeInsets.all(10).r,
        child: Column(
          children: [
            SizedBox(height: 5.h),
            Center(
              child: Text(
                context.l10n.onlineList,
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: Obx(() {
                return ListView.separated(
                  separatorBuilder: (_, __) {
                    return SizedBox(height: 8.h);
                  },
                  itemCount: widget.controller.onlineUsers.length,
                  itemBuilder: (contetx, index) {
                    return userItem(
                      widget.controller.onlineUsers[index],
                      index,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget userItem(UserModel user, int index) {
    return Row(
      children: [
        ProfileAvatar(
          user: user,
          radius: 22.r,
          onTap: () {
            widget.controller.openSmallProfile(user);
          },
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              UserNameWidget(
                user: user,
                style: Theme.of(context).textTheme.displaySmall!.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              MedalsWidget(
                medals: user.medals ?? [],
                vip: user.vip,
                width: double.infinity,
                size: 20.r,
              ),
            ],
          ),
        ),
        Text(
          MyMath.numberToShort(user.points),
          style: Theme.of(context).textTheme.labelMedium!.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        // if(user.role == RoleEnum.owner)
        // GeneralButton3(
        //   color: AppColors.primaryDark,
        //   onPressed: null,
        //   title: context.l10n.hsot
        // )else
        Padding(
          padding: EdgeInsetsDirectional.only(end: 30.w),
          child: UserRoomSettings(
            onChange: (r) {
              if (r == RoleEnum.banned) {
                widget.controller.onlineUsers.removeAt(index);
                widget.controller.onlineUsers.refresh();
              }
            },
            user: user,
            roomId: widget.controller.room.value.id,
            controller: widget.controller,
          ),
        ),
      ],
    );
  }
}

class UserRoomSettings extends StatefulWidget {
  const UserRoomSettings({
    super.key,
    required this.user,
    required this.roomId,
    required this.controller,
    this.onChange,
    this.icon,
  });

  final UserModel user;
  final int roomId;
  final Widget? icon;
  final RoomController controller;
  final Function(RoleEnum)? onChange;

  @override
  State<UserRoomSettings> createState() => _UserRoomSettingsState();
}

class _UserRoomSettingsState extends State<UserRoomSettings> {
  @override
  Widget build(BuildContext context) {
    bool isSuperAdmin =
        StaticValue.userData.pos.value > UserPosition.superAdmin.value;
    if ((widget.user.userId == StaticValue.userData.userId ||
            (widget.controller.userRole.value == RoleEnum.admin &&
                [RoleEnum.admin, RoleEnum.owner].contains(widget.user.role)) ||
            ![
              RoleEnum.admin,
              RoleEnum.owner,
            ].contains(widget.controller.userRole.value)) &&
        !isSuperAdmin) {
      return SizedBox();
    }
    return PopupMenuWidget<int>(
      iconColor: widget.icon == null ? Colors.black : null,
      withText: false,
      onChanged: (v) async {
        await CallServerAPI.post("live/userAction", {
          "rid": widget.roomId,
          "rule": v,
          "touid": widget.user.userId,
        });
        widget.user.role = RoleEnum.values.firstWhere((n) => n.value == v);
        widget.onChange?.call(widget.user.role!);
        setState(() {});
      },
      icon: widget.icon,
      items: [
        if (widget.user.role == RoleEnum.admin) ...[
          DropdownButtonModel(
            dropName: context.l10n.removeAdmin,
            dropValue: RoleEnum.user.value,
          ),
        ] else if ([
          RoleEnum.guest,
          RoleEnum.user,
        ].contains(widget.user.role)) ...[
          if (widget.user.pos.value <= UserPosition.superAdmin.value)
            DropdownButtonModel(
              dropName: context.l10n.setAdmin,
              dropValue: RoleEnum.admin.value,
            ),
          if (!widget.user.vipUntiBan)
            DropdownButtonModel(
              dropName: context.l10n.kickUser,
              dropValue: RoleEnum.banned.value,
            ),
        ] else if (widget.user.role == RoleEnum.banned) ...[
          DropdownButtonModel(
            dropName: context.l10n.unblock,
            dropValue: RoleEnum.user.value,
          ),
        ],
      ],
    );
  }
}
