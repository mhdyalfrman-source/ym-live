import 'package:awesome_gradiant_font/awesome_gradiant_font.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tom_chat/l10n/l10n.dart';

class AppLogo extends StatelessWidget {
  final double? width;
  const AppLogo({super.key, this.width});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/images/logo.png", width: width ?? 150.r),
            SizedBox(width: 5.w),
            AwesomeGradiantFont(
              context.l10n.appName,
              gradient: LinearGradient(colors: colors[1]),
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
