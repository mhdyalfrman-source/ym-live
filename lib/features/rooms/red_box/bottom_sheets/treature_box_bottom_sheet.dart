import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/features/rooms/red_box/widgets/portal_content.dart';
import 'package:tom_chat/features/rooms/red_box/widgets/treasure_box_content.dart';
import 'package:tom_chat/l10n/l10n.dart';
import '../controllers/red_box_controller.dart';

class TreasureBoxBottomSheet extends StatefulWidget {
  final int rid;
  const TreasureBoxBottomSheet({super.key, required this.rid});

  @override
  State<TreasureBoxBottomSheet> createState() => _TreasureBoxBottomSheetState();

  static void show(BuildContext context, int rid) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => TreasureBoxBottomSheet(rid: rid),
    );
  }
}

class _TreasureBoxBottomSheetState extends State<TreasureBoxBottomSheet> {
  final controller = Get.put(RedBoxController());
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xfff1d5d0),
              Colors.white,
              Colors.white,
              Colors.white,
            ],
            begin: AlignmentGeometry.topRight,
            end: AlignmentGeometry.bottomLeft,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row(
            //   children: [
            //     buildTab(context.l10n.treasureBoxTab),
            //     SizedBox(width: 20.w),
            //     buildTab(context.l10n.portalTab),
            //   ],
            // ),
            // const Divider(),
            if (controller.selectedTab.value == context.l10n.portalTab)
              PortalContent(controller: controller, rid: widget.rid)
            else
              TreasureBoxContent(controller: controller, rid: widget.rid),
          ],
        ),
      );
    });
  }

  Widget buildTab(String title) {
    final isSelected = controller.selectedTab.value == title;
    return GestureDetector(
      onTap: () => controller.selectTab(title),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              color: isSelected ? Colors.black : Colors.grey,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            height: 2,
            width: 80.w,
            color: isSelected ? Colors.black : Colors.transparent,
          ),
        ],
      ),
    );
  }
}
