import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/features/home/main_screen.dart';
import 'package:tom_chat/features/levels/controllers/level_controller.dart';
import 'package:tom_chat/features/levels/models/app_level_model.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/features/profile/components/levels_widget.dart';
import 'package:tom_chat/features/profile/components/user_name_widget.dart';
import 'package:tom_chat/features/vip/vip_screen.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/helpers/image_model.dart';
import 'package:tom_chat/models/user/user_model.dart';

class LevelScreen extends StatefulWidget {
  final int typeIndex;
  const LevelScreen({super.key, this.typeIndex = 0});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  ScrollController scrollController = ScrollController();
  late LevelController controller;
  late HomeController homeController;

  int index = 0;

  @override
  void initState() {
    super.initState();
    controller = Get.put(LevelController());
    homeController = Get.find();
    controller.typeIndex.value = widget.typeIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchAllLevels();
    });

    scrollController.addListener(() async {
      if (scrollController.position.maxScrollExtent <=
              scrollController.offset &&
          scrollController.offset > 0) {
        await controller.fetchAllLevels();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplete(
      withSafeArea: false,
      title: "",
      child: Padding(
        padding: const EdgeInsets.all(10).r,
        child: Obx(() {
          String progress = "";
          if (controller.typeIndex.value == 0) {
            progress =
                ((homeController.user.value.levels?.gifter.nextLevelUp ?? 0) -
                        (homeController.user.value.levels?.gifter.progress ??
                            0))
                    .toString();
          } else {
            progress =
                ((homeController.user.value.levels?.anchor.nextLevelUp ?? 0) -
                        (homeController.user.value.levels?.anchor.progress ??
                            0))
                    .toString();
          }
          return Column(
            children: [
              whiteAppBar(
                context: context,
                title: "",
                child: SafeArea(
                  child: Center(
                    child: TabWidget2(
                      color: AppColors.primary,
                      selectedIndex: controller.typeIndex.value,
                      tabs: [context.l10n.rich, context.l10n.gathib],
                      onTap: (index) async {
                        controller.typeIndex.value = index;
                        await controller.fetchAllLevels();
                      },
                    ),
                  ),
                ),
                color: AppColors.primary,
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          ProfileAvatar(
                            user: UserModel(
                              userId: 0,
                              name: "",
                              avatar: ImageModel(
                                network:
                                    homeController.user.value.avatar?.network,
                              ),
                            ),
                            radius: 30.r,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    UserNameWidget(
                                      user: homeController.user.value,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall!
                                          .copyWith(color: Colors.black),
                                    ),
                                    LevelsWidget(
                                      levels: [
                                        if (controller.typeIndex.value == 0)
                                          homeController
                                              .user
                                              .value
                                              .levels
                                              ?.gifter,
                                        if (controller.typeIndex.value == 1)
                                          homeController
                                              .user
                                              .value
                                              .levels
                                              ?.anchor,
                                      ],
                                      vip: null,
                                      width: 100.w,
                                      size: 13.r,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5.h),
                                Text(
                                  context.l10n.upgradeSpace(progress),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .copyWith(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20.h),
                            Text(
                              context.l10n.showLevelDesc,
                              style: Theme.of(context).textTheme.displaySmall!
                                  .copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              context.l10n.levelPoint1,
                              style: Theme.of(context).textTheme.labelMedium!
                                  .copyWith(color: Colors.black),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20.h),
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: colors[1]),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            // ===== Header =====
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    context.l10n.level,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge!
                                        .copyWith(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    context.l10n.icon,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge!
                                        .copyWith(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    context.l10n.points,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge!
                                        .copyWith(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            ...(controller.typeIndex.value == 0
                                    ? controller.gifterLevels
                                    : controller.anchorLevels)
                                .map((e) => _buildRow(e)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildRow(AppLevelModel row) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Level
          Expanded(
            child: Text(
              row.levelNum.toString(),
              style: Theme.of(context).textTheme.labelMedium,
              textAlign: TextAlign.center,
            ),
          ),

          // Icon
          Expanded(
            child: Center(
              child: AppImage(
                width: 50.r,
                image: ImageModel(network: row.icon),
              ),
            ),
          ),

          // Effects
          Expanded(
            child: Text(
              row.levelUp.toString(),
              style: Theme.of(context).textTheme.labelMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
