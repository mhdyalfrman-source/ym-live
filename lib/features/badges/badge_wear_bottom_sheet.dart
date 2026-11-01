import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/utils/app_bottom_sheet.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/features/badges/controllers/badge_controller.dart';
import 'package:tom_chat/features/badges/models/medal_model.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/helpers/image_model.dart';

class BadgeWearBottomSheet extends StatelessWidget {
  final BadgeController controller;
  const BadgeWearBottomSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    bool enableWear = controller.myMedals.where((m) => m.isUsed).length < 12;
    return Container(
      decoration: BoxDecoration(
        color: Color(0xff3E2520),
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
                child: Row(
                  children: [
                    SizedBox(width: 10.w),
                    GestureDetector(
                      onTap: Get.back,
                      child: Text(
                        context.l10n.cancel,
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Color(0xffDCAE5B),
                        ),
                      ),
                    ),
                    const Spacer(),
                    buttonItem(context, context.l10n.save, Get.back),
                    SizedBox(width: 10.w),
                  ],
                ),
              ),
              Obx(() {
                return MasonryGridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  itemCount: controller.myMedals.length,
                  shrinkWrap: true,
                  primary: false,
                  itemBuilder: (context, index) {
                    return settingItem(
                      context,
                      controller.myMedals[index],
                      enableWear,
                    );
                  },
                );
              }),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget buttonItem(BuildContext context, String text, Function()? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xff413325),
          borderRadius: BorderRadius.circular(20).r,
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2).r,
        child: Center(
          child: Text(
            text,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              fontWeight: FontWeight.bold,
              color: Color(0xffDCAE5B).withOpacity(onTap == null ? 0.5 : 1),
            ),
          ),
        ),
      ),
    );
  }

  Widget settingItem(BuildContext context, MedalModel medal, bool enableWear) {
    return Container(
      padding: EdgeInsets.all(10).r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF3A201E),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: AppImage(
              image: ImageModel(network: medal.icon),
              width: 100.w,
            ),
          ),
          if (!medal.isUsed) ...[
            SizedBox(height: 5.h),
            buttonItem(
              context,
              context.l10n.wear,
              !enableWear
                  ? null
                  : () async {
                      await controller.wearAndTakeOff(medal.id, 1);
                    },
            ),
          ] else ...[
            SizedBox(height: 5.h),
            buttonItem(context, context.l10n.takeOff, () async {
              await controller.wearAndTakeOff(medal.id, 0);
            }),
          ],
        ],
      ),
    );
  }

  static Future<void> show(
    BuildContext context,
    BadgeController controller,
  ) async {
    await AppBottomSheet.show(
      context: context,
      child: BadgeWearBottomSheet(controller: controller),
      hideHeader: true,
      borderRadius: 0,
      padding: EdgeInsets.zero,
    );
  }
}
