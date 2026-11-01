import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/utils/swip_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' hide Trans;
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/features/home/search_screen.dart';
import 'package:tom_chat/features/notifications/controllers/notification_controller.dart';
import 'package:tom_chat/features/notifications/notification_screen.dart';
import 'package:tom_chat/features/rooms/new_room_screen.dart';
import 'package:tom_chat/features/rooms/room_screen.dart';
import 'package:tom_chat/features/tops/tops_screen.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/statics_values.dart';

class UserCard extends StatelessWidget {
  final HomeController controller;
  const UserCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final notificationController = Get.put(NotificationController());
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          // Expanded(
          //   child: GestureDetector(
          //     onTap: () {
          //       swipToPage(
          //         context,
          //         PageTemplete(
          //           backgroundColor: Theme.of(
          //             context,
          //           ).scaffoldBackgroundColor,
          //           title: "personalAccount".tr(),
          //           child: PersonalInformation(forAdmin: false),
          //         ),
          //       );
          //     },
          //     child: ShowcaseWidget(
          //       stepKey: controller.stepOne,
          //       title: 'personalData'.tr(),
          //       description: 'homeStepOne'.tr(),
          //       child: Row(
          //         children: [
          //           UserProfileImage(
          //             imagePath: StaticValue.userData.userImagePath ?? "",
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          Expanded(
            child: Obx(() {
              return Row(
                children: [
                  InkWell(
                    onTap: () {
                      controller.mainSelectedScreen.value = 0;
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          context.l10n.ertbat,
                          style: Theme.of(context).textTheme.displaySmall!
                              .copyWith(color: Colors.black),
                        ),
                        SizedBox(height: 5.h),
                        smallLine(controller.mainSelectedScreen.value == 0),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  InkWell(
                    onTap: () {
                      controller.mainSelectedScreen.value = 1;
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          context.l10n.chat,
                          style: Theme.of(context).textTheme.displaySmall!
                              .copyWith(color: Colors.black),
                        ),
                        SizedBox(height: 5.h),
                        smallLine(controller.mainSelectedScreen.value == 1),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),

          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (controller.room.value == null) {
                    Get.to(() => NewRoomScreen());
                  } else {
                    swipToPage(
                      context,
                      RoomScreen(
                        withSetup: controller.keepRoom.value == null,
                        creatorId: StaticValue.userData.userId,
                        roomId: controller.room.value!.id,
                      ),
                    );
                  }
                },
                icon: Image.asset(
                  "assets/images/home.png",
                  width: 30.r,
                  height: 30.r,
                ),
              ),
              //  IconButton(
              //   onPressed: () {
              //     swipToPage(context, StoreScreen());
              //   },
              //   icon: Image.asset(
              //     "assets/images/store.png",
              //     width: 30.r,
              //     height: 30.r,
              //   ),
              // ),
              IconButton(
                onPressed: () async {
                  swipToPage(context, const SearchScreen());
                },
                icon: Image.asset(
                  "assets/images/search.png",
                  width: 30.r,
                  height: 30.r,
                ),
              ),
              Obx(
                () => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: () {
                        swipToPage(
                          context,
                          NotificationScreen(
                            title: context.l10n.systemNotifications,
                          ),
                        );
                      },
                      icon: Image.asset(
                        "assets/images/notification.png",
                        width: 30.r,
                        height: 30.r,
                      ),
                    ),
                    if (notificationController.unreadCount.value > 0)
                      Positioned(
                        right: 8.r,
                        top: 8.r,
                        child: Container(
                          width: 9.r,
                          height: 9.r,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  swipToPage(context, TopsScreen());
                },
                icon: Image.asset(
                  "assets/images/kas.png",
                  width: 30.r,
                  height: 30.r,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget smallLine(show) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      width: show ? 10 : 0,
      height: 3,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(5).r,
      ),
    );
  }
}
