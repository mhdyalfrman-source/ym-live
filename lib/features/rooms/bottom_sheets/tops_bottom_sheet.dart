import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/core/utils/app_bottom_sheet.dart';
import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/badges/components/medals_widget.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/features/home/main_screen.dart';
import 'package:tom_chat/features/profile/components/user_name_widget.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';

class TopsBottomSheet extends StatefulWidget {
  final RoomController controller;
  const TopsBottomSheet({super.key, required this.controller});

  @override
  State<TopsBottomSheet> createState() => _TopsBottomSheetState();

  static Future<void> show(
    BuildContext context,
    RoomController controller,
  ) async {
    await AppBottomSheet.show(
      context: context,
      child: TopsBottomSheet(controller: controller),
      hideHeader: true,
      borderRadius: 0,
      padding: EdgeInsets.zero,
    );
  }
}

class _TopsBottomSheetState extends State<TopsBottomSheet> {
  ScrollController scrollController = ScrollController();

  RxList<UserModel> daylyUsers = <UserModel>[].obs;
  int daylyPage = 1;
  RxBool hasMoreDaylyUsers = true.obs;

  RxList<UserModel> weaklyUsers = <UserModel>[].obs;
  int weaklyPage = 1;
  RxBool hasMoreWeaklyUsers = true.obs;

  RxList<UserModel> monthlyUsers = <UserModel>[].obs;
  int monthlyPage = 1;
  RxBool hasMoreMonthlyUsers = true.obs;

  RxList<UserModel> dayly2Users = <UserModel>[].obs;
  int dayly2Page = 1;
  RxBool hasMoreDayly2Users = true.obs;

  RxList<UserModel> weakly2Users = <UserModel>[].obs;
  int weakly2Page = 1;
  RxBool hasMoreWeakly2Users = true.obs;

  RxList<UserModel> monthly2Users = <UserModel>[].obs;
  int monthly2Page = 1;
  RxBool hasMoreMonthly2Users = true.obs;

  int index = 0;
  int typeIndex = 0;

  Future<void> getTops() async {
    if (typeIndex == 0) {
      if (index == 0) {
        if (!hasMoreDaylyUsers.value) {
          setState(() {});
          return;
        }
      } else if (index == 1) {
        if (!hasMoreWeaklyUsers.value) {
          setState(() {});
          return;
        }
      } else if (index == 2) {
        if (!hasMoreMonthlyUsers.value) {
          setState(() {});
          return;
        }
      }
    } else {
      if (index == 0) {
        if (!hasMoreDayly2Users.value) {
          setState(() {});
          return;
        }
      } else if (index == 1) {
        if (!hasMoreWeakly2Users.value) {
          setState(() {});
          return;
        }
      } else if (index == 2) {
        if (!hasMoreMonthly2Users.value) {
          setState(() {});
          return;
        }
      }
    }
    var res = await CallServerAPI.post("live/ranking", {
      "rid": widget.controller.room.value.id,
      "limit": limitCount,
      "p": typeIndex == 0
          ? (index == 0
                ? daylyPage
                : index == 1
                ? weaklyPage
                : monthlyPage)
          : (index == 0
                ? dayly2Page
                : index == 1
                ? weakly2Page
                : monthly2Page),
      "time": index == 0
          ? "daily"
          : index == 1
          ? "week"
          : "month",
      "type": typeIndex == 0 ? "gifter" : "anchor",
    });
    if (res.isNotEmpty && res["list"] != null) {
      List<UserModel> userList = UserModel.fromList(res["list"]);
      if (typeIndex == 0) {
        if (index == 0) {
          daylyUsers.addAll(userList.obs);
          daylyUsers.refresh();
          daylyPage++;
          hasMoreDaylyUsers.value = userList.length == limitCount;
        } else if (index == 1) {
          weaklyUsers.addAll(userList.obs);
          weaklyUsers.refresh();
          weaklyPage++;
          hasMoreWeaklyUsers.value = userList.length == limitCount;
        } else if (index == 2) {
          monthlyUsers.addAll(userList.obs);
          monthlyUsers.refresh();
          monthlyPage++;
          hasMoreMonthlyUsers.value = userList.length == limitCount;
        }
      } else {
        if (index == 0) {
          dayly2Users.addAll(userList.obs);
          dayly2Users.refresh();
          dayly2Page++;
          hasMoreDayly2Users.value = userList.length == limitCount;
        } else if (index == 1) {
          weakly2Users.addAll(userList.obs);
          weakly2Users.refresh();
          weakly2Page++;
          hasMoreWeakly2Users.value = userList.length == limitCount;
        } else if (index == 2) {
          monthly2Users.addAll(userList.obs);
          monthly2Users.refresh();
          monthly2Page++;
          hasMoreMonthly2Users.value = userList.length == limitCount;
        }
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getTops();
    });

    scrollController.addListener(() async {
      if (scrollController.position.maxScrollExtent <=
              scrollController.offset &&
          scrollController.offset > 0) {
        await getTops();
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
      child: DefaultTabController(
        length: 3,
        child: Container(
          height: Get.height * 0.7,
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
                child: TabWidget2(
                  selectedIndex: typeIndex,
                  tabs: [context.l10n.rich, context.l10n.gathib],
                  onTap: (index) async {
                    setState(() {
                      typeIndex = index;
                    });
                    await getTops();
                  },
                ),
              ),
              SizedBox(height: 15.h),
              Center(
                child: TabWidget(
                  tabs: [
                    context.l10n.dayly,
                    context.l10n.weekly,
                    context.l10n.monthly,
                  ],
                  onTap: (index) async {
                    this.index = index;
                    await getTops();
                  },
                ),
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: Obx(() {
                  List<UserModel> users = [];
                  if (typeIndex == 0) {
                    users = index == 0
                        ? daylyUsers
                        : index == 1
                        ? weaklyUsers
                        : monthlyUsers;
                  } else {
                    users = index == 0
                        ? dayly2Users
                        : index == 1
                        ? weakly2Users
                        : monthly2Users;
                  }
                  if (users.isEmpty) {
                    return Center(
                      child: Text(
                        context.l10n.thereAreNoDataYet,
                        style: Theme.of(
                          context,
                        ).textTheme.displaySmall!.copyWith(color: Colors.black),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      SizedBox(
                        height: 200.h,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              bottom: -120,
                              child: Image.asset("assets/images/tops.png"),
                            ),
                            if (users.length > 1)
                              Positioned(
                                left: 10.r,
                                top: 30.r,
                                child: Column(
                                  children: [
                                    ProfileAvatar(
                                      openProfileType: OpenProfileType.full,
                                      user: users[1],
                                      radius: 35.r,
                                      assetCustomBorder:
                                          "assets/images/room_top${typeIndex}2.png",
                                    ),
                                    SizedBox(height: 3.h),
                                    UserNameWidget(
                                      user: users[1],
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium!
                                          .copyWith(color: Colors.black),
                                    ),
                                    MedalsWidget(
                                      medals: users[1].medals ?? [],
                                      vip: users[1].vip,
                                      size: 18.r,
                                      width: 70.r,
                                    ),
                                    Text(
                                      MyMath.numberToShort(users[1].points),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium!
                                          .copyWith(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            if (users.length > 2)
                              Positioned(
                                right: 10.r,
                                top: 30.r,
                                child: Column(
                                  children: [
                                    ProfileAvatar(
                                      openProfileType: OpenProfileType.full,
                                      user: users[2],
                                      radius: 35.r,
                                      assetCustomBorder:
                                          "assets/images/room_top${typeIndex}3.png",
                                    ),
                                    SizedBox(height: 3.h),
                                    UserNameWidget(
                                      user: users[2],
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium!
                                          .copyWith(color: Colors.black),
                                    ),
                                    MedalsWidget(
                                      medals: users[2].medals ?? [],
                                      vip: users[2].vip,
                                      size: 18.r,
                                      width: 70.r,
                                    ),
                                    Text(
                                      MyMath.numberToShort(users[2].points),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium!
                                          .copyWith(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            if (users.isNotEmpty)
                              Positioned(
                                left: Get.width / 4,
                                right: Get.width / 4,
                                top: 0,
                                child: Column(
                                  children: [
                                    ProfileAvatar(
                                      openProfileType: OpenProfileType.full,
                                      user: users[0],
                                      radius: 40.r,
                                      padding: EdgeInsets.all(13).r,
                                      withScaleOut: 1.8,
                                      assetCustomBorder:
                                          "assets/images/room_top${typeIndex}1.png",
                                    ),
                                    UserNameWidget(
                                      user: users[0],
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium!
                                          .copyWith(color: Colors.black),
                                    ),
                                    MedalsWidget(
                                      medals: users[0].medals ?? [],
                                      vip: users[0].vip,
                                      size: 18.r,
                                      width: 80.r,
                                    ),
                                    Text(
                                      MyMath.numberToShort(users[0].points),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium!
                                          .copyWith(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                          ).copyWith(top: 5.h),
                          separatorBuilder: (_, __) {
                            return SizedBox(height: 12.h);
                          },
                          itemCount: users.skip(3).length,
                          itemBuilder: (contetx, index) {
                            return userItem(users.skip(3).toList()[index]);
                          },
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget userItem(UserModel user) {
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
        SizedBox(width: 5.w),
      ],
    );
  }
}
