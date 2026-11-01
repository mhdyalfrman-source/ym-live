import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/utils/app_bottom_sheet.dart';
import 'package:tom_chat/core/widgets/buttons.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/features/rooms/models/red_box.dart';
import 'package:tom_chat/l10n/l10n.dart';

class TreatureBoxListBottomSheet extends StatefulWidget {
  final RoomController controller;
  final Function(RedBoxModel) onOpenBox;
  const TreatureBoxListBottomSheet({
    super.key,
    required this.controller,
    required this.onOpenBox,
  });

  @override
  State<TreatureBoxListBottomSheet> createState() =>
      _GifterRankingBottomSheetState();

  static void show(
    BuildContext context,
    RoomController controller,
    Function(RedBoxModel) onOpenBox,
  ) {
    AppBottomSheet.show(
      context: context,
      child: TreatureBoxListBottomSheet(
        controller: controller,
        onOpenBox: onOpenBox,
      ),
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      borderRadius: 5,
      hideHeader: true,
      title: context.l10n.treasureBox,
      isDismissible: true,
      isScrollControlled: true,
      isScrollable: true,
    );
  }
}

class _GifterRankingBottomSheetState extends State<TreatureBoxListBottomSheet> {
  String formatSeconds(int totalSeconds) {
    if (totalSeconds <= 0) return "00:00";

    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Container(
        height: Get.height * 0.45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF6DA), Colors.white],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // handle
              Center(
                child: Container(
                  width: 46.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
              ),
              SizedBox(height: 10.h),

              SizedBox(height: 14.h),

              Expanded(
                child: Obx(() {
                  return ListView.separated(
                    padding: EdgeInsets.only(bottom: 10.h),
                    separatorBuilder: (_, __) => SizedBox(height: 10.h),
                    itemCount: widget.controller.redBoxes.length,
                    itemBuilder: (context, index) {
                      final box = widget.controller.redBoxes[index];
                      final close = box.seconds > 0;
                      final person = box.user;

                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: const Color(0xffFF2C55).withOpacity(0.85),
                              width: 1.1,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 10.h,
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/image_treasure_3.png',
                                fit: BoxFit.contain,
                                width: 50,
                                height: 50,
                              ),

                              SizedBox(width: 10.w),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.l10n.treasureBox,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: Colors.black,
                                          ),
                                    ),
                                    SizedBox(height: 6.h),
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8.w,
                                            vertical: 4.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(
                                              0.08,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              30.r,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.withOpacity(
                                                0.18,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Image.asset(
                                                "assets/images/coin.png",
                                                height: 16.sp,
                                              ),
                                              SizedBox(width: 6.w),
                                              Text(
                                                box.coins.toString(),
                                                style: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Colors.black,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(width: 8.w),

                              if ((box.reward ?? 0) > 0)
                                SizedBox(
                                  height: 34.h,
                                  child: GeneralButton3(
                                    color: AppColors.primaryDark,
                                    fontColor: Colors.white,
                                    title: context.l10n.opened,
                                    onPressed: null,
                                  ),
                                )
                              else
                                SizedBox(
                                  width: 92.w,
                                  height: 34.h,
                                  child: GeneralButton3(
                                    color: AppColors.primaryDark,
                                    fontColor: Colors.white,
                                    padding: EdgeInsets.zero,
                                    title: close
                                        ? formatSeconds(box.seconds.toInt())
                                        : context.l10n.open,
                                    onPressed: /*close ? null :*/ () {
                                      widget.onOpenBox(box);
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
