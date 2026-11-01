import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/features/rooms/red_box/controllers/red_box_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'option_card.dart';
import '../bottom_sheets/custom_treasure_box_bottomsheet.dart';

class TreasureBoxContent extends StatelessWidget {
  final int rid;
  final RedBoxController controller;
  const TreasureBoxContent({
    required this.controller,
    super.key,
    required this.rid,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n; // convenience variable

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 16.h),
        Text(
          l10n.treasureBoxEngageMessage,
          textAlign: TextAlign.start,
          style: TextStyle(color: Colors.black, fontSize: 13.sp),
        ),
        SizedBox(height: 20.h),

        // Options
        Obx(
          () => Column(
            children: [
              OptionCard(
                title: l10n.quantityOption(40),
                subtitle: l10n.collectCoinsOption(40),
                coins: controller.quantityToCoins[40]!,
                isSelected: controller.selectedQuantity.value == 40,
                onTap: () {
                  controller.selectQuantity(40);
                },
              ),
              OptionCard(
                title: l10n.quantityOption(120),
                subtitle: l10n.collectCoinsOption(120),
                coins: controller.quantityToCoins[120]!,
                isSelected: controller.selectedQuantity.value == 120,
                onTap: () {
                  controller.selectQuantity(120);
                },
              ),
              OptionCard(
                title: l10n.quantityOption(200),
                subtitle: l10n.collectCoinsOption(200),
                coins: controller.quantityToCoins[200]!,
                isSelected: controller.selectedQuantity.value == 200,
                onTap: () {
                  controller.selectQuantity(200);
                },
              ),
            ],
          ),
        ),

        InkWell(
          onTap: () {
            Get.bottomSheet(
              CustomTreasureBoxBottomSheet(controller: controller, rid: rid),
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
            );
          },
          child: Text(l10n.otherOptions, style: TextStyle(fontSize: 13.sp)),
        ),

        SizedBox(height: 10.h),

        Text(
          l10n.treasureBoxAgreementText,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[500], fontSize: 11.sp),
        ),
        SizedBox(height: 20.h),

        // Send button with loading state
        Obx(
          () => SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  controller.isLoading.value ||
                      controller.selectedQuantity.value > 250
                  ? null
                  : () {
                      controller.sendLiveBox(
                        type: RedBoxType.local,
                        useCustom: false,
                        rid: rid,
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    controller.isLoading.value ||
                        controller.selectedQuantity.value > 250
                    ? Colors.grey
                    : AppColors.primaryDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              child: controller.isLoading.value
                  ? SizedBox(
                      height: 20.h,
                      width: 20.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      l10n.sendButton,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
