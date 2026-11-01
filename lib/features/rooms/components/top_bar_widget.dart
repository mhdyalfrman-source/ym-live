import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/profile/components/user_id_widget.dart';
import 'package:tom_chat/features/profile/components/user_name_widget.dart';
import 'package:tom_chat/features/rooms/bottom_sheets/online_list_bottom_sheet.dart';
import 'package:tom_chat/features/rooms/bottom_sheets/room_info_bottom_sheet%20.dart';
import 'package:tom_chat/features/rooms/bottom_sheets/tops_bottom_sheet.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'package:tom_chat/statics_values.dart';

class RoomTopBar extends StatelessWidget {
  final Function() onClose;
  final RoomController controller;

  const RoomTopBar({
    super.key,
    required this.controller,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Obx(() {
                  return GestureDetector(
                    onTap: () {
                      RoomInfoBottomSheet.show(context, controller);
                    },
                    child: Row(
                      children: [
                        if (controller.room.value.owner != null) ...[
                          ProfileAvatar(
                            user: controller.room.value.owner?.copyWith(
                              avatar: controller.room.value.owner?.avatar
                                  ?.copyWith(
                                    network:
                                        controller.room.value.icon?.network,
                                  ),
                            ),
                            width: 40.r,
                            height: 40.r,
                            borderRadius: BorderRadius.circular(5).r,
                          ),
                          SizedBox(width: 7.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LayoutBuilder(
                                  builder: (context, constant) {
                                    return Row(
                                      children: [
                                        Flexible(
                                          child: AutoScrollText(
                                            width: constant.maxWidth / 2,
                                            text: controller.room.value.title,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        if (controller.room.value.password == 1)
                                          Icon(Icons.lock_outline, size: 15.r),
                                      ],
                                    );
                                  },
                                ),
                                UserIdWidget(
                                  user: controller.room.value.owner,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                // MedalsWidget(
                                //   vip: controller.room.value.owner?.vip,
                                //   width: Get.width / 2,
                                //   size: 18.r,
                                //   medals: controller.room.value.owner?.medals ??[]
                                // )
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ),
              Row(
                children: [
                  Obx(() {
                    if ([
                          PersonRelation.follow,
                        ].contains(controller.room.value.owner?.relation) &&
                        controller.room.value.owner?.userId !=
                            StaticValue.userData.userId) {
                      return _iconButton(
                        Icons.favorite,
                        controller.roomColorIsRed.value
                            ? () {}
                            : () async {
                                var response =
                                    await CallServerAPI.post('user/attention', {
                                      'touid':
                                          controller.room.value.owner?.userId,
                                      'type': 1,
                                    });
                                if (response.isNotEmpty) {
                                  controller.roomColorIsRed.value = true;
                                  Future.delayed(Duration(seconds: 2), () {
                                    controller.room.update((val) {
                                      val?.owner?.relation =
                                          PersonRelation.following;
                                    });
                                  });
                                }
                              },
                        controller.roomColorIsRed.value
                            ? AppColors.red
                            : Colors.white,
                      );
                    }
                    return SizedBox();
                  }),
                  const SizedBox(width: 8),
                  _iconButton(Icons.power_settings_new, onClose),
                ],
              ),
              // center badges (simplified)
              // right avatar
            ],
          ),
        ),
        SizedBox(height: 5.h),
        SizedBox(
          height: 30.h,
          child: Stack(
            children: [
              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    TopsBottomSheet.show(context, controller);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(15).r,
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: EdgeInsets.all(5).r,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(15).r,
                          ),
                        ),
                        child: Obx(() {
                          return Row(
                            children: [
                              Image.asset(
                                "assets/images/cup.png",
                                height: 20.r,
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                MyMath.numberToShort(
                                  controller.roomCoins.value,
                                ),
                                style: Theme.of(context).textTheme.labelMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                              ),
                              SizedBox(width: 10.w),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 1,
                child: GestureDetector(
                  onTap: () {
                    OnlineListBottomSheet.show(context, controller);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(15).r,
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: EdgeInsets.all(5).r,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.horizontal(
                            right: Radius.circular(15).r,
                          ),
                        ),
                        child: Obx(() {
                          return Row(
                            children: [
                              SizedBox(width: 10.w),
                              Text(
                                controller.roomUsersCount.value.toString(),
                                style: Theme.of(context).textTheme.labelMedium!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 5.w),
                              Icon(HugeIcons.strokeRoundedUser03, size: 20.r),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }

  Widget _iconButton(
    IconData icon,
    VoidCallback onTap, [
    Color color = Colors.white,
  ]) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white12),
      child: Icon(icon, color: color),
    ),
  );
}
