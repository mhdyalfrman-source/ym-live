import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/utils/app_bottom_sheet.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';

class MicModeBottomSheet extends StatelessWidget {
  final RoomController controller;
  const MicModeBottomSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black87.withValues(alpha: 0.8),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10).r,
          topRight: Radius.circular(10).r,
        ),
      ),
      child: Container(
        height: Get.height * 0.5,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10).r,
            topRight: Radius.circular(10).r,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5.h),
              Padding(
                padding: EdgeInsets.all(10).r,
                child: Text(
                  "Mic Mode",
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Wrap(
                runSpacing: 10.h,
                children: [
                  ...controller.seatStyles.keys.map(
                    (k) => InkWell(
                      onTap: () async {
                        await controller.changeSeatsMode(k);
                      },
                      child: settingItem(context, k),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget settingItem(BuildContext context, int mode) {
    return Container(
      padding: EdgeInsets.all(10).r,
      margin: EdgeInsets.all(5).r,
      width: (Get.width / 2) - 10.r,
      decoration: controller.room.value.seats.length == mode
          ? BoxDecoration(
              border: Border.all(color: AppColors.primaryDark),
              borderRadius: BorderRadius.circular(10).r,
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            spacing: 3.h,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: controller.seatStyles[mode]!.map((s) {
              return Row(
                spacing: 3.w,
                mainAxisAlignment: MainAxisAlignment.center,
                children: s.map((ss) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade900,
                    ),
                    width: 25.r,
                    height: 25.r,
                    child: Icon(Icons.event_seat, size: 8.r),
                  );
                }).toList(),
              );
            }).toList(),
          ),
          SizedBox(height: 5.h),
          Text(
            context.l10n.micModeNum(mode),
            style: Theme.of(
              context,
            ).textTheme.labelMedium!.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  static Future<void> show(
    BuildContext context,
    RoomController controller,
  ) async {
    await AppBottomSheet.show(
      context: context,
      child: MicModeBottomSheet(controller: controller),
      hideHeader: true,
      borderRadius: 0,
      padding: EdgeInsets.zero,
    );
  }
}
