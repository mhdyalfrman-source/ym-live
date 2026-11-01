import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/utils/app_bottom_sheet.dart';
import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/core/utils/swip_page.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/badges/components/medals_widget.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/features/home/main_screen.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/features/profile/components/levels_widget.dart';
import 'package:tom_chat/features/profile/components/user_name_widget.dart';
import 'package:tom_chat/features/profile/profile_screen.dart';
import 'package:tom_chat/features/rooms/models/room_model.dart';
import 'package:tom_chat/features/rooms/room_screen.dart';
import 'package:tom_chat/features/tops/controllers/top_screen_controller.dart';
import 'package:tom_chat/features/vip/vip_screen.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';

class TopsScreen extends StatefulWidget {
  final int typeIndex;
  const TopsScreen({super.key, this.typeIndex = 0});

  @override
  State<TopsScreen> createState() => _TopsScreenState();

  static Future<void> show(BuildContext context, int typeIndex) async {
    await AppBottomSheet.show(
      context: context,
      child: TopsScreen(typeIndex: typeIndex),
      hideHeader: true,
      borderRadius: 0,
      padding: EdgeInsets.zero,
    );
  }
}

class _TopsScreenState extends State<TopsScreen> {
  ScrollController scrollController = ScrollController();
  late TopScreenController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.put(TopScreenController());

    controller.typeIndex.value = widget.typeIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getTops(setState);
    });

    scrollController.addListener(() async {
      if (scrollController.position.maxScrollExtent <=
              scrollController.offset &&
          scrollController.offset > 0) {
        await controller.getTops(setState);
      }
    });
  }

  String getSvgaImageNum(int num) {
    if (controller.typeIndex.value == 0) {
      return "assets/svga/hel_home_wealth_rank_$num.svga";
    } else if (controller.typeIndex.value == 1) {
      return "assets/svga/hel_home_charm_rank_$num.svga";
    } else if (controller.typeIndex.value == 2) {
      return "assets/svga/hel_home_game_rank_$num.svga";
    }
    return "";
  }

  List<LevelModel?> userLevels(UserModel user) {
    if (controller.typeIndex.value == 0) {
      return [user.levels?.gifter];
    } else if (controller.typeIndex.value == 1) {
      return [user.levels?.anchor];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplete(
      withSafeArea: false,
      title: "",
      child: DefaultTabController(
        length: 3,
        child: Obx(() {
          List<UserModel> users = [];
          List<RoomModel> rooms = [];
          if (controller.typeIndex.value == 0) {
            users = controller.index == 0
                ? controller.daylyUsers
                : controller.index == 1
                ? controller.weaklyUsers
                : controller.monthlyUsers;
          } else if (controller.typeIndex.value == 1) {
            users = controller.index == 0
                ? controller.dayly2Users
                : controller.index == 1
                ? controller.weakly2Users
                : controller.monthly2Users;
          } else if (controller.typeIndex.value == 2) {
            rooms = controller.index == 0
                ? controller.dayly3Users
                : controller.index == 1
                ? controller.weakly3Users
                : controller.monthly3Users;
          }
          return Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Image.asset(
                  controller.typeIndex.value == 0
                      ? "assets/images/bg_king_ranking_gath 1.png"
                      : controller.typeIndex.value == 1
                      ? "assets/images/bg_king_ranking_level 1.png"
                      : controller.typeIndex.value == 2
                      ? "assets/images/bg_king_ranking_wealth 1.png"
                      : "assets/images/bg_cp.png",
                  fit: BoxFit.cover,
                ),
              ),
              Column(
                children: [
                  whiteAppBar(
                    context: context,
                    title: "",
                    child: SafeArea(
                      child: Center(
                        child: TabWidget2(
                          selectedIndex: controller.typeIndex.value,
                          tabs: [
                            context.l10n.rich,
                            context.l10n.gathib,
                            context.l10n.rooms,
                          ],
                          onTap: (index) async {
                            setState(() {
                              controller.typeIndex.value = index;
                            });
                            controller.updating.value = true;
                            Future.delayed(Duration(milliseconds: 200), () {
                              controller.updating.value = false;
                            });
                            await controller.getTops(setState);
                          },
                        ),
                      ),
                    ),
                  ),
                  // if(controller.typeIndex.value != 2)...[
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.w),
                      child: Opacity(
                        opacity: 0.9,
                        child: TabWidget(
                          height: 33.h,
                          tabs: [
                            context.l10n.dayly,
                            context.l10n.weekly,
                            context.l10n.monthly,
                          ],
                          onTap: (index) async {
                            controller.index = index;
                            await controller.getTops(setState);
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  // ]else...[
                  //   SizedBox(height: 60.h,),
                  // ],
                  if (controller.typeIndex.value == 2)
                    SizedBox(
                      height: 220.h,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 45.r,
                            top: 120.r,
                            child: topItem(rooms.elementAtOrNull(1), null, 2),
                          ),
                          Positioned(
                            right: 45.r,
                            top: 120.r,
                            child: topItem(rooms.elementAtOrNull(2), null, 3),
                          ),
                          Positioned(
                            left: Get.width / 4,
                            right: Get.width / 4,
                            top: 5.r,
                            child: topItem(rooms.elementAtOrNull(0), 3, 1),
                          ),
                        ],
                      ),
                    )
                  else
                    SizedBox(
                      height: 220.h,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 45.r,
                            top: 100.r,
                            child: Column(
                              children: [
                                Obx(() {
                                  if (controller.updating.value) {
                                    return SizedBox();
                                  }
                                  return ProfileAvatar(
                                    openProfileType: OpenProfileType.full,
                                    user: users.length > 1 ? users[1] : null,
                                    height: 60.r,
                                    width: 60.r,
                                    padding: EdgeInsets.all(5).r,
                                    customBorder: getSvgaImageNum(2),
                                  );
                                }),
                                if (users.length > 1) ...[
                                  SizedBox(height: 3.h),
                                  UserNameWidget(
                                    width: Get.width * 0.28,
                                    user: users[1],
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  LevelsWidget(
                                    levels: userLevels(users[1]),
                                    vip: null,
                                    size: 10.r,
                                    width: 60.r,
                                    isCenter: true,
                                  ),
                                  Text(
                                    MyMath.numberToShort(users[1].points),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(
                                          color: Color(0xffFFC800),
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Positioned(
                            right: 45.r,
                            top: 100.r,
                            child: Column(
                              children: [
                                Obx(() {
                                  if (controller.updating.value) {
                                    return SizedBox();
                                  }
                                  return ProfileAvatar(
                                    openProfileType: OpenProfileType.full,
                                    user: users.length > 2 ? users[2] : null,
                                    padding: EdgeInsets.all(5).r,
                                    height: 60.r,
                                    width: 60.r,
                                    customBorder: getSvgaImageNum(3),
                                  );
                                }),
                                if (users.length > 2) ...[
                                  SizedBox(height: 3.h),
                                  UserNameWidget(
                                    width: Get.width * 0.28,
                                    user: users[2],
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  LevelsWidget(
                                    levels: userLevels(users[2]),
                                    vip: null,
                                    size: 10.r,
                                    width: 60.r,
                                    isCenter: true,
                                  ),
                                  Text(
                                    MyMath.numberToShort(users[2].points),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(
                                          color: Color(0xffFFC800),
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Positioned(
                            left: Get.width / 4,
                            right: Get.width / 4,
                            top: 5.r,
                            child: Column(
                              children: [
                                Obx(() {
                                  if (controller.updating.value) {
                                    return SizedBox();
                                  }
                                  return ProfileAvatar(
                                    openProfileType: OpenProfileType.full,
                                    withScaleOut: 3,
                                    user: users.isNotEmpty ? users[0] : null,
                                    radius: 40.r,
                                    customBorder: getSvgaImageNum(1),
                                  );
                                }),
                                if (users.isNotEmpty) ...[
                                  UserNameWidget(
                                    width: Get.width * 0.28,
                                    user: users[0],
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  LevelsWidget(
                                    levels: userLevels(users[0]),
                                    vip: null,
                                    size: 10.r,
                                    width: 80.r,
                                    isCenter: true,
                                  ),
                                  Text(
                                    MyMath.numberToShort(users[0].points),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(
                                          color: Color(0xffFFC800),
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(10).r,
                        ),
                      ),
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                        ).copyWith(top: 5.h),
                        separatorBuilder: (_, __) {
                          return SizedBox(height: 12.h);
                        },
                        itemCount:
                            (controller.typeIndex.value != 2 ? users : rooms)
                                .skip(3)
                                .length,
                        itemBuilder: (contetx, index) {
                          final user =
                              (controller.typeIndex.value != 2 ? users : rooms)
                                  .skip(3)
                                  .toList()[index];
                          return userItem(
                            user,
                            controller.typeIndex.value != 2
                                ? userLevels(user as UserModel)
                                : [],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget topItem(RoomModel? room, double? withScaleOut, int num) {
    return GestureDetector(
      onTap: () {
        if (room != null) {
          RoomModel? keep = Get.find<HomeController>().keepRoom.value;
          swipToPage(
            context,
            RoomScreen(
              creatorId: room.uid,
              roomId: room.id,
              withSetup: keep == null,
            ),
          );
        }
      },
      child: Column(
        children: [
          Obx(() {
            if (controller.updating.value) {
              return SizedBox();
            }
            return ProfileAvatar(
              openProfileType: OpenProfileType.full,
              user: room != null
                  ? UserModel(userId: 0, name: "", avatar: room.icon)
                  : null,
              height: num == 1 ? null : 60.r,
              width: num == 1 ? null : 60.r,
              radius: num == 1 ? 40.r : null,
              padding: EdgeInsets.all(5).r,
              customBorder: getSvgaImageNum(num),
              withScaleOut: withScaleOut,
            );
          }),
          if (room != null) ...[
            if (num > 1) SizedBox(height: 3.h),
            AutoScrollText(
              width: Get.width * 0.28,
              text: room.title,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              MyMath.numberToShort(room.points),
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: Color(0xffFFC800),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget userItem(u, List<LevelModel?> levels) {
    UserModel user;
    if (u is RoomModel) {
      user = UserModel(
        userId: u.id,
        name: u.title,
        points: u.points,
        avatar: u.icon,
        medals: [],
      );
    } else {
      user = u;
    }
    return GestureDetector(
      onTap: () {
        if (u is RoomModel) {
          RoomModel? keep = Get.find<HomeController>().keepRoom.value;
          swipToPage(
            context,
            RoomScreen(creatorId: u.uid, roomId: u.id, withSetup: keep == null),
          );
        } else {
          swipToPage(context, ProfileScreen(id: user.userId, fromRoom: false));
        }
      },
      child: Row(
        children: [
          ProfileAvatar(user: user, radius: 22.r),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, c) {
                    return UserNameWidget(
                      textAlign: TextAlign.start,
                      width: c.maxWidth,
                      user: user,
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                if (u is UserModel) ...[
                  SizedBox(height: 5.h),
                  LevelsWidget(
                    levels: levels,
                    vip: null,
                    width: double.infinity,
                    size: 13.r,
                  ),
                ],
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
          SizedBox(width: 8.w),
        ],
      ),
    );
  }
}
