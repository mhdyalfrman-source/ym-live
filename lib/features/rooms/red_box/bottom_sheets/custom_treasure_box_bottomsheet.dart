import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/utils/snakbar_dialog.dart';
import 'package:tom_chat/features/rooms/red_box/controllers/red_box_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';

class CustomTreasureBoxBottomSheet extends StatelessWidget {
  final int rid;
  final RedBoxController controller;

  const CustomTreasureBoxBottomSheet({
    super.key,
    required this.controller,
    required this.rid,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final totalCoinsController = TextEditingController();
    final quantityController = TextEditingController();
    final minutesController = TextEditingController();

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                  const Spacer(),
                  Text(
                    l10n.customTreasureBoxTitle,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.help_outline),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                l10n.customTreasureBoxSubtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 13.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 25.h),

              // Total coins field
              _buildInputField(
                controller: totalCoinsController,
                title: l10n.totalCoinsHint,
                suffix: l10n.coinsLabel,
              ),
              SizedBox(height: 16.h),

              // Quantity field
              _buildInputField(
                controller: quantityController,
                title: l10n.quantityHint,
                suffix: l10n.peopleLabel,
              ),
              SizedBox(height: 16.h),

              // Countdown field
              _buildInputField(
                controller: minutesController,
                title: l10n.countdownHint,
                suffix: l10n.minutesLabel,
              ),
              SizedBox(height: 90.h),

              // Info text
              Text(
                l10n.treasureBoxInfo,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500], fontSize: 11.sp),
              ),
              SizedBox(height: 20.h),

              // Send button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Validate inputs
                    final totalCoins =
                        int.tryParse(totalCoinsController.text) ?? 0;
                    final quantity = int.tryParse(quantityController.text) ?? 0;
                    final minutes = int.tryParse(minutesController.text) ?? 0;

                    if (totalCoins < 2000 || totalCoins > 1000000) {
                      snakbarDialog(
                        title: l10n.errorTotalCoinsRange,
                        durationSecound: 5,
                      );
                      return;
                    }

                    if (quantity < 1 || quantity > 500) {
                      snakbarDialog(
                        title: l10n.errorQuantityRange,
                        durationSecound: 5,
                      );
                      return;
                    }

                    if (minutes < 1 || minutes > 5) {
                      snakbarDialog(
                        title: l10n.errorCountdownRange,
                        durationSecound: 5,
                      );
                      return;
                    }

                    controller.setCustomValues(totalCoins, quantity, minutes);
                    controller.sendLiveBox(
                      type: RedBoxType.local,
                      useCustom: true,
                      rid: rid,
                    );
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffFF2C55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  child: Text(
                    l10n.sendButton,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String title,
    required String suffix,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Expanded text field with label
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: title,
                    hintStyle: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(fontSize: 15.sp, color: Colors.black),
                ),
              ),

              // Suffix text
              Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Text(
                  suffix,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // Divider line under field
          Divider(color: Colors.grey[300], thickness: 1, height: 1),
        ],
      ),
    );
  }
}
