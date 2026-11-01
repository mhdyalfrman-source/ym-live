import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/utils/app_bottom_sheet.dart';
import 'package:tom_chat/core/widgets/buttons.dart';
import 'package:tom_chat/features/rooms/components/custom_text_field.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';

class ChangePassword extends StatelessWidget {
  final RoomController controller;
  const ChangePassword({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    String? password;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.h),
        CustomTextField(
          onChanged: (v) {
            password = v;
          },
          hintText: context.l10n.enterRoomPassword,
          labelStyle: Theme.of(context).textTheme.titleLarge,
          textStyle: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: Colors.black,
          ),
          hintStyle: TextStyle(fontSize: 16),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
          borderColor: Theme.of(context).cardColor,
        ),
        SizedBox(height: 20.h),
        Row(
          children: [
            Expanded(
              child: GeneralButton3(
                title: context.l10n.save,
                onPressed: () {
                  Get.back(result: (password ?? "").isEmpty ? null : password);
                },
              ),
            ),
            // if(controller.room.value.password == 1)...[
            SizedBox(width: 5.w),
            Expanded(
              child: GeneralButton3(
                color: AppColors.red,
                fontColor: Colors.white,
                title: context.l10n.delete,
                onPressed: () {
                  Get.back(result: "delete");
                },
              ),
            ),
            // ]
          ],
        ),
      ],
    );
  }

  static Future show(BuildContext context) async {
    final controller = Get.find<RoomController>();
    return await AppBottomSheet.show(
      context: context,
      backgroundColor: Colors.white,
      title: context.l10n.password,
      padding: const EdgeInsets.all(24),
      child: ChangePassword(controller: controller),
    );
  }
}
