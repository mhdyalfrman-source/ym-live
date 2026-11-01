import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/widgets/buttons.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/l10n/l10n.dart';

class RoomErrorScreen extends StatelessWidget {
  const RoomErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplete(
      title: "",
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              HugeIcons.strokeRoundedRssError,
              color: Colors.grey,
              size: 64,
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.ops,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.thisLiveEnded,
              style: const TextStyle(color: Colors.black54, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            GeneralButton3(
              color: AppColors.primaryDark,
              onPressed: () => Get.back(result: true),
              title: context.l10n.close,
              fontColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
