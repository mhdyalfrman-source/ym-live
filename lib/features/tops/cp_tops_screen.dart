import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/utils/app_bottom_sheet.dart';
import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/home/main_screen.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/features/profile/components/user_name_widget.dart';
import 'package:tom_chat/features/tops/controllers/top_screen_controller.dart';
import 'package:tom_chat/features/tops/models/cp_model.dart';
import 'package:tom_chat/features/vip/vip_screen.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';

class CPTopsScreen extends StatefulWidget {
  final int typeIndex;
  const CPTopsScreen({super.key, this.typeIndex = 0});

  @override
  State<CPTopsScreen> createState() => _CPTopsScreenState();

  static Future<void> show(BuildContext context, int typeIndex) async {
    await AppBottomSheet.show(
      context: context,
      child: CPTopsScreen(typeIndex: typeIndex),
      hideHeader: true,
      borderRadius: 0,
      padding: EdgeInsets.zero,
    );
  }
}

class _CPTopsScreenState extends State<CPTopsScreen> {
  ScrollController scrollController = ScrollController();
  late TopScreenController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.put(TopScreenController());

    controller.typeIndex.value = widget.typeIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getCPTops(setState);
    });

    scrollController.addListener(() async {
      if (scrollController.position.maxScrollExtent <=
              scrollController.offset &&
          scrollController.offset > 0) {
        await controller.getCPTops(setState);
      }
    });
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
          List<CpModel> users = [];
          if (controller.typeIndex.value == 0) {
            users = controller.index == 0
                ? controller.daylyCpRanks
                : controller.index == 1
                ? controller.weeklyCpRanks
                : controller.monthlyCpRanks;
          }
          return Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Image.asset(
                  controller.typeIndex.value == 0
                      ? "assets/images/bg_cp.png"
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
                          tabs: [context.l10n.cp],
                          onTap: (index) async {
                            setState(() {
                              controller.typeIndex.value = index;
                            });
                            controller.updating.value = true;
                            Future.delayed(Duration(milliseconds: 200), () {
                              controller.updating.value = false;
                            });
                            await controller.getCPTops(setState);
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
                            await controller.getCPTops(setState);
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    height: 220.h,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0.r,
                          right: Get.width / 2,
                          top: 120.r,
                          child: Column(
                            children: [
                              Obx(() {
                                if (controller.updating.value) {
                                  return SizedBox();
                                }
                                return cpTopWidget(
                                  users.length > 1 ? users[1] : null,
                                  2,
                                  30.r,
                                );
                              }),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 0,
                          left: Get.width / 2,
                          top: 120.r,
                          child: Column(
                            children: [
                              Obx(() {
                                if (controller.updating.value) {
                                  return SizedBox();
                                }
                                return cpTopWidget(
                                  users.length > 2 ? users[2] : null,
                                  3,
                                  30.r,
                                );
                              }),
                            ],
                          ),
                        ),
                        Positioned(
                          left: Get.width / 5,
                          right: Get.width / 5,
                          top: 5.r,
                          child: Column(
                            children: [
                              Obx(() {
                                if (controller.updating.value) {
                                  return SizedBox();
                                }
                                return cpTopWidget(
                                  users.isNotEmpty ? users[0] : null,
                                  1,
                                  35.r,
                                );
                              }),
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
                          return SizedBox(height: 5.h);
                        },
                        itemCount: users.skip(3).length,
                        itemBuilder: (contetx, index) {
                          final user = users.skip(3).toList()[index];
                          return userItem(user);
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

  Widget cpTopWidget(CpModel? cp, int rank, double radius) {
    return SizedBox(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: [
              ProfileAvatar(
                openProfileType: OpenProfileType.full,
                user: cp?.user,
                radius: radius,
                assetCustomBorder: "assets/images/cp_top$rank.png",
                withScaleOut: 1,
                // customBorder: getSvgaImageNum(1),
              ),
              UserNameWidget(
                width: Get.width * 0.2,
                user: cp?.user,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Image.asset("assets/images/cp_heart.png", width: 50.w),
              if (cp != null)
                Text(
                  MyMath.numberToShort(cp.coins),
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: Color(0xffFFC800),
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          Column(
            children: [
              ProfileAvatar(
                openProfileType: OpenProfileType.full,
                user: cp?.toUser,
                radius: radius,
                assetCustomBorder: "assets/images/cp_top$rank.png",
                withScaleOut: 1,
              ),
              UserNameWidget(
                width: Get.width * 0.2,
                user: cp?.toUser,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget userItem(CpModel cp) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/cp_small_bg.png"),
        ),
      ),
      width: double.infinity,
      height: 100.r,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ProfileAvatar(radius: 30.r, user: cp.user),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/cp_heart.png", height: 30.r),
              Text(
                MyMath.numberToShort(cp.coins),
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: Color(0xffFFC800),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ProfileAvatar(
            radius: 30.r,
            user: cp.toUser,
            openProfileType: OpenProfileType.full,
          ),
        ],
      ),
    );
  }
}
