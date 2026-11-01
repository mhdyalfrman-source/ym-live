import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/features/rooms/red_box/controllers/red_box_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'portal_option_card.dart';

class PortalContent extends StatelessWidget {
  final int rid;
  final RedBoxController controller;
  const PortalContent({required this.controller, super.key, required this.rid});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        SizedBox(height: 8.h),
        _buildHeader(context),
        SizedBox(height: 20.h),

        // Options
        Obx(
          () => Column(
            children: [
              PortalOptionCard(
                viewers: "250",
                coins: 6000,
                reachingViewersCoins: 2000,
                treasureBoxCoins: 4000,
                isSelected: controller.selectedQuantity.value == 250,
                onTap: () {
                  controller.selectPortalOption(250);
                  controller.selectedQuantity.value = 250;
                },
              ),
              SizedBox(height: 12.h),
              PortalOptionCard(
                viewers: "500",
                coins: 10000,
                reachingViewersCoins: 2000,
                treasureBoxCoins: 8000,
                isSelected: controller.selectedQuantity.value == 500,
                onTap: () {
                  controller.selectPortalOption(500);
                  controller.selectedQuantity.value = 500;
                },
              ),
            ],
          ),
        ),

        SizedBox(height: 12.h),

        // InkWell(
        //   onTap: () => snakbarDialog(
        //       title: l10n.customize, description: l10n.customizePortalOptions),
        //   child: Text(
        //     l10n.customizeButton,
        //     style: TextStyle(fontSize: 13.sp),
        //   ),
        // ),
        SizedBox(height: 40.h),

        Text(
          l10n.portalAgreementText,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 11.sp,
            height: 1.4,
          ),
        ),
        SizedBox(height: 20.h),

        Obx(() {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.selectedQuantity.value < 250
                  ? null
                  : () {
                      controller.sendLiveBox(
                        type: RedBoxType.gloabal,
                        useCustom: false,
                        rid: rid,
                      );
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
          );
        }),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 219, 247, 254),
            Color(0xFFCAEFF9),
            Color(0xFFF4F7FC),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.sendPortalHeader,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          Image.asset("assets/images/image_treasure_3.png", height: 85.h),
        ],
      ),
    );
  }
}
