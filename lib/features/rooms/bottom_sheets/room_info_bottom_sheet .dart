import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/utils/app_bottom_sheet.dart';
import 'package:tom_chat/core/widgets/buttons.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/badges/components/medals_widget.dart';
import 'package:tom_chat/features/profile/components/user_id_widget.dart';
import 'package:tom_chat/features/profile/components/user_name_widget.dart';
import 'package:tom_chat/features/rooms/bottom_sheets/online_list_bottom_sheet.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/features/settings/components/level_item.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';

class RoomInfoBottomSheet extends StatefulWidget {
  final RoomController controller;
  const RoomInfoBottomSheet({super.key, required this.controller});

  @override
  State<RoomInfoBottomSheet> createState() => _RoomInfoBottomSheetState();

  static Future<void> show(
    BuildContext context,
    RoomController controller,
  ) async {
    await AppBottomSheet.show(
      context: context,
      child: RoomInfoBottomSheet(controller: controller),
      hideHeader: true,
      borderRadius: 0,
      padding: EdgeInsets.zero,
    );
  }
}

class _RoomInfoBottomSheetState extends State<RoomInfoBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController tab;

  @override
  void initState() {
    super.initState();
    tab = TabController(length: 2, vsync: this);
    widget.controller.onLinePage = 1;
    widget.controller.hasMoreOnlineUsers.value = true;
    widget.controller.onlineUsers.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height * 0.6,
      child: CardWidget(
        radius: 15.r,
        colorIndex: 1,
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            children: [
              /// ------------------- Tabs -------------------
              TabBar(
                controller: tab,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                dividerColor: Colors.transparent,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelStyle: Theme.of(
                  context,
                ).textTheme.labelMedium!.copyWith(fontWeight: FontWeight.bold),
                tabs: [
                  Tab(text: context.l10n.info),
                  Tab(text: context.l10n.admins),
                ],
              ),

              SizedBox(height: 15.h),

              /// ------------------- Tabs Content -------------------
              Expanded(
                child: TabBarView(
                  controller: tab,
                  children: [
                    _buildInfoPage(context),
                    UserTypeList(
                      controller: widget.controller,
                      type: RoleEnum.admin,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoPage(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// owner info
          Row(
            children: [
              SizedBox(width: 12.w),
              ProfileAvatar(
                onTap: () {
                  widget.controller.openSmallProfile(
                    widget.controller.room.value.owner!,
                  );
                },
                user: widget.controller.room.value.owner?.copyWith(
                  avatar: widget.controller.room.value.owner?.avatar?.copyWith(
                    network: widget.controller.room.value.icon?.network,
                  ),
                ),
                width: 70.r,
                height: 70.r,
                borderRadius: BorderRadius.circular(5).r,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, c) {
                        return AutoScrollText(
                          width: c.maxWidth,
                          text: widget.controller.room.value.title,
                          style: Theme.of(context).textTheme.displayMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                    SizedBox(height: 3.h),
                    UserIdWidget(
                      user: widget.controller.room.value.owner,
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    // MedalsWidget(
                    //   vip: widget.controller.room.value.owner?.vip,
                    //   width: Get.width / 2,
                    //   size: 18.r,
                    //   medals: widget.controller.room.value.owner?.medals ??[]
                    // )
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          /// Stats
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
          //   children: [
          //     _infoItem("متابعة", widget.controller.followers.toString()),
          //     _infoItem("عدد الهدايا", widget.controller.giftsCount.toString()),
          //     _infoItem("النشاط اليومي", widget.controller.dailyActivity.toString()),
          //   ],
          // ),
          SizedBox(height: 10.h),

          // Text(
          //   "وكالتي",
          //   style: TextStyle(
          //     color: Colors.white,
          //     fontSize: 16.sp,
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),

          // SizedBox(height: 12.h),

          // Container(
          //   padding: EdgeInsets.all(12.r),
          //   decoration: BoxDecoration(
          //     color: Colors.black.withOpacity(0.2),
          //     borderRadius: BorderRadius.circular(15.r),
          //   ),
          //   child: Row(
          //     children: [
          //       CircleAvatar(
          //         radius: 22.r,
          //         backgroundImage:
          //             NetworkImage(widget.controller.agencyImage),
          //       ),
          //       SizedBox(width: 10.w),
          //       Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Text(
          //             widget.controller.agencyName,
          //             style: TextStyle(
          //               color: Colors.white,
          //               fontSize: 15.sp,
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //           Text(
          //             "${widget.controller.agencyMembers}/1000 أعضاء",
          //             style: TextStyle(color: Colors.grey),
          //           ),
          //         ],
          //       )
          //     ],
          //   ),
          // ),

          // SizedBox(height: 25.h),

          // /// Medal
          // Text(
          //   "ميدالية الغرفة",
          //   style: TextStyle(
          //     color: Colors.white,
          //     fontSize: 16.sp,
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),

          // SizedBox(height: 8.h),

          // Center(
          //   child: Image.asset(
          //     "assets/images/room_medal.png",
          //     height: 70.h,
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _infoItem(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          title,
          style: TextStyle(color: Colors.grey, fontSize: 13.sp),
        ),
      ],
    );
  }
}

class UserTypeList extends StatefulWidget {
  final RoleEnum type;
  final RoomController controller;
  const UserTypeList({super.key, required this.controller, required this.type});

  @override
  State<UserTypeList> createState() => _UserTypeListState();
}

class _UserTypeListState extends State<UserTypeList> {
  int p = 1;
  bool hasMore = true;
  List<UserModel> users = [];

  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();

    scrollController.addListener(() async {
      if (scrollController.position.maxScrollExtent <=
              scrollController.offset &&
          scrollController.offset > 0) {
        if (!hasMore) return;
        List<UserModel> u = await widget.controller.getUsersByRole(
          page: p + 1,
          role: widget.type.value,
        );
        if (u.isNotEmpty) {
          users.addAll(u);
          p++;
          hasMore = true;
          setState(() {});
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      users = await widget.controller.getUsersByRole(
        page: p,
        role: widget.type.value,
      );
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (_, __) {
        return SizedBox(height: 8.h);
      },
      itemCount: users.length,
      itemBuilder: (contetx, index) {
        return userItem(users[index], index);
      },
    );
  }

  Widget userItem(UserModel user, int index) {
    return Row(
      children: [
        ProfileAvatar(
          onTap: () {
            widget.controller.openSmallProfile(user);
          },
          user: user,
          radius: 22.r,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              UserNameWidget(
                user: user,
                style: Theme.of(
                  context,
                ).textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
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
        if (user.role == RoleEnum.owner)
          GeneralButton3(
            color: AppColors.primaryDark,
            onPressed: null,
            title: context.l10n.host,
          )
        else
          Padding(
            padding: EdgeInsetsDirectional.only(end: 30.w),
            child: UserRoomSettings(
              onChange: (r) {
                if (r == RoleEnum.user && widget.type == RoleEnum.banned) {
                  setState(() {
                    users.removeAt(index);
                  });
                }
              },
              controller: widget.controller,
              user: user,
              roomId: widget.controller.room.value.id,
              icon: Icon(Icons.more_vert, color: Colors.white),
            ),
          ),
      ],
    );
  }
}
