import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/utils/app_bottom_sheet.dart';
import 'package:tom_chat/features/rooms/bottom_sheets/room_info_bottom_sheet%20.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';

class BlockListBottomSheet extends StatelessWidget {
  final RoomController controller;
  const BlockListBottomSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10).r,
          topRight: Radius.circular(10).r,
        ),
      ),
      child: Container(
        height: Get.height * 0.6,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xCCFF6501), const Color(0x4F737373)],
            stops: [0.0, 0.3],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10).r,
            topRight: Radius.circular(10).r,
          ),
        ),
        padding: EdgeInsets.all(10).r,
        child: Column(
          children: [
            SizedBox(height: 5.h),
            Center(
              child: Text(
                context.l10n.blockList,
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: UserTypeList(
                controller: controller,
                type: RoleEnum.banned,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> show(
    BuildContext context,
    RoomController controller,
  ) async {
    await AppBottomSheet.show(
      context: context,
      child: BlockListBottomSheet(controller: controller),
      hideHeader: true,
      borderRadius: 0,
      padding: EdgeInsets.zero,
    );
  }
}
