import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/features/rooms/models/red_box.dart';
import 'package:tom_chat/features/rooms/red_box/bottom_sheets/treature_box_list_bottom_sheet.dart';
import 'package:tom_chat/features/rooms/red_box/bottom_sheets/treature_counter.dart';

class AnimatedTreasureBox extends StatefulWidget {
  final RoomController controller;
  final int liveId;
  const AnimatedTreasureBox({
    super.key,
    required this.controller,
    required this.liveId,
  });

  @override
  State<AnimatedTreasureBox> createState() => _AnimatedTreasureBoxState();
}

class _AnimatedTreasureBoxState extends State<AnimatedTreasureBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..forward();

    final isRTL = ['ar', 'ur'].contains(Get.locale?.languageCode);

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0),
      end: isRTL
          ? const Offset(0.1, 0) // عربي
          : const Offset(-0.2, 0), // إنجليزي
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // widget.controller.boxTime.listen((val){
    //   if(val == 0){
    //     _controller.reverse();
    //     controllerCompleted = true;
    //   }else if(controllerCompleted){
    //     _controller.forward();
    //     controllerCompleted = false;
    //   }
    // });
  }

  bool controllerCompleted = false;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(
        width: Get.width / 4,
        child: SlideTransition(
          position: _offsetAnimation,
          child: Obx(() {
            int totalSeconds =
                widget.controller.redBoxes.firstOrNull?.seconds.toInt() ?? 0;

            // if(totalSeconds <= 0)return SizedBox.shrink();
            int minutes = totalSeconds <= 0 ? 0 : totalSeconds ~/ 60;
            int seconds = totalSeconds <= 0 ? 0 : totalSeconds % 60;
            return GestureDetector(
              onTap: () => showTreasureBoxBottomSheet(context),
              child: SizedBox(
                width: 30.r,
                height: 30.r,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      margin: EdgeInsetsDirectional.only(start: 10.w),
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.topCenter,
                          heightFactor: 0.9,
                          child: AnimatedRotation(
                            turns: totalSeconds <= 0 ? 0 : 1 / 10,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                            child: Image.asset(
                              "assets/images/image_treasure.png",
                              width: 40.r,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: totalSeconds <= 0
                          ? SizedBox()
                          : Container(
                              margin: EdgeInsetsDirectional.only(start: 5.w),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Future<void> showTreasureBoxBottomSheet(BuildContext context) async {
    if (widget.controller.redBoxes.isEmpty) return;
    if (widget.controller.redBoxes.length > 1) {
      TreatureBoxListBottomSheet.show(context, widget.controller, openBox);
      return;
    }
    openBox(widget.controller.redBoxes.first);
  }

  void openBox(RedBoxModel box) async {
    widget.controller.isBoxCoinBottomSheetOpen = true;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => TreasureBoxCounterBottomSheet(
        onUpdateBoxValue: widget.controller.onUpdateBoxValue,
        box: box,
        liveId: widget.liveId,
      ),
    );
    widget.controller.isBoxCoinBottomSheetOpen = false;
  }
}
