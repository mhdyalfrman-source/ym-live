import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/features/badges/badge_wear_bottom_sheet.dart';
import 'package:tom_chat/features/badges/controllers/badge_controller.dart';
import 'package:tom_chat/features/badges/models/medal_model.dart';
import 'package:tom_chat/models/helpers/image_model.dart';

class MedalsGrid extends StatelessWidget {
  final RxList<MedalModel> medals;
  final int totalCount;
  final BadgeController controller;

  const MedalsGrid({
    super.key,
    required this.medals,
    required this.controller,
    this.totalCount = 12,
  });

  List<MedalModel?> _mergeMedals(List<MedalModel> list) {
    final used = list.where((m) => m.isUsed).toList();
    final result = <MedalModel?>[];

    result.addAll(used);

    final emptyCount = totalCount - used.length;
    for (int i = 0; i < emptyCount; i++) {
      result.add(null);
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = _mergeMedals(medals);

      return GridView.builder(
        itemCount: items.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, i) {
          final medal = items[i];

          return GestureDetector(
            onTap: () {
              BadgeWearBottomSheet.show(context, controller);
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.6),
                      width: 1,
                    ),
                  ),
                ),

                // عنصر حقيقي
                if (medal != null)
                  AppImage(
                    image: ImageModel(network: medal.icon),
                    width: 25.r,
                  )
                else
                  const Icon(Icons.add, color: Colors.amber, size: 18),

                Positioned(
                  bottom: 3,
                  right: 3,
                  child: Text(
                    "${i + 1}",
                    style: TextStyle(
                      color: Colors.amber.withOpacity(0.8),
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}
