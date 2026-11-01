import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/widgets/buttons.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/features/vip/controllers/vip_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/helpers/image_model.dart';

showConfirmDialog(context, VipController controller) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: EdgeInsets.all(10).r,
        backgroundColor: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(15).r,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.orderConfirmation,
                style: Theme.of(
                  context,
                ).textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5.h),
              Container(
                width: 110.r,
                height: 110.r,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AppImage(
                  image: ImageModel(
                    network:
                        controller.vipList[controller.currentIndex.value].icon,
                  ),
                ),
              ),
              SizedBox(height: 15.h),
              Row(
                children: [
                  Expanded(
                    child: GeneralButton(
                      margin: 5,
                      onPressed: () {
                        Get.back();
                        controller.buyItem(
                          controller.vipList[controller.currentIndex.value],
                        );
                      },
                      colorIndex: 1,
                      title: context.l10n.purchase,
                    ),
                  ),
                  Expanded(
                    child: GeneralButton(
                      margin: 5,
                      onPressed: Get.back,
                      colorIndex: 1,
                      title: context.l10n.close,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
