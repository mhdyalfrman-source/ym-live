import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/l10n/l10n.dart';

class ExitDialog extends StatelessWidget {
  const ExitDialog({super.key});

  static Future show(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return ExitDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        spacing: 15.h,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          item(
            context,
            context.l10n.exit,
            HugeIcons.strokeRoundedLogout03,
            () => Get.back(result: "EXIT"),
          ),
          item(
            context,
            context.l10n.keep,
            HugeIcons.strokeRoundedArrowShrink02,
            () => Get.back(result: "KEEP"),
          ),
          item(
            context,
            context.l10n.share,
            HugeIcons.strokeRoundedShare05,
            () => Get.back(result: "SHARE"),
          ),
        ],
      ),
    );
  }

  Widget item(
    BuildContext context,
    String text,
    IconData icon,
    Function() onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70.r,
            height: 70.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: colors[4],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Icon(icon, size: 35.r, color: Colors.white),
          ),
          SizedBox(height: 5.h),
          Text(
            text,
            style: Theme.of(context).textTheme.displaySmall!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
