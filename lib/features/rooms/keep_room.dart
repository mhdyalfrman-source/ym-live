import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/utils/swip_page.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/features/rooms/room_screen.dart';

class RoomDraggableWidget extends StatefulWidget {
  const RoomDraggableWidget({super.key});

  @override
  State<RoomDraggableWidget> createState() => _RoomDraggableWidgetState();
}

class _RoomDraggableWidgetState extends State<RoomDraggableWidget>
    with SingleTickerProviderStateMixin {
  HomeController controller = Get.put(HomeController());
  Offset position = const Offset(100, 300);
  bool isDragging = false;

  late AnimationController _pressController;
  late Animation<double> _scale;

  final double bubbleWidth = 80;
  final double bubbleHeight = 80;

  @override
  void initState() {
    super.initState();

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 0.1,
    );

    _scale = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _pressController, curve: Curves.ease));
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.keepRoom.value == null) return const SizedBox.shrink();

      return Stack(
        children: [
          /// ------------------------------
          ///   الفقاعة
          /// ------------------------------
          Positioned(
            left: position.dx,
            top: position.dy,
            child: GestureDetector(
              onTap: () {
                swipToPage(
                  context,
                  RoomScreen(creatorId: 0, roomId: 0, withSetup: false),
                );
                controller.keepRoom.value = null;
              },

              onPanStart: (_) {
                setState(() => isDragging = true);
                _pressController.forward();
              },

              onPanUpdate: (details) {
                Offset newPos = Offset(
                  details.globalPosition.dx - bubbleWidth / 2,
                  details.globalPosition.dy - bubbleHeight / 2,
                );

                setState(() {
                  position = newPos;
                });
              },

              onPanEnd: (_) {
                setState(() {
                  isDragging = false;
                });
                _pressController.reverse();
              },

              child: AnimatedBuilder(
                animation: _scale,
                builder: (context, child) {
                  return Transform.scale(scale: _scale.value, child: child);
                },
                child: _buildBubble(),
              ),
            ),
          ),

          Positioned(
            left: position.dx + bubbleWidth,
            top: position.dy - bubbleWidth / 4,
            child: GestureDetector(
              onTap: () {
                Get.find<RoomController>().leaveRoom(
                  withClearRoom: true,
                  withOutCheck: true,
                  withEndCall: true,
                );
                controller.keepRoom.value = null;
                position = Offset(100, 300);
              },
              child: Align(
                alignment: Alignment.bottomLeft,
                child: CardWidget(
                  colorIndex: 1,
                  radius: 0,
                  shape: BoxShape.circle,
                  child: Icon(Icons.close, size: 30, color: Colors.white70),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildBubble() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 50),
      duration: const Duration(seconds: 500),
      curve: Curves.linear,
      onEnd: () {},
      builder: (context, value, child) {
        return Transform.rotate(angle: value * 2 * 3.1415926535, child: child);
      },
      child: Material(
        borderRadius: BorderRadius.circular(10).r,
        color: Colors.transparent,
        child: CardWidget(
          shape: BoxShape.circle,
          radius: 10,
          colorIndex: 1,
          child: Container(
            width: bubbleWidth,
            height: bubbleHeight,
            decoration: BoxDecoration(
              boxShadow: [
                if (isDragging)
                  BoxShadow(
                    color: AppColors.primaryDark.withOpacity(0.4),
                    blurRadius: 18,
                    spreadRadius: 4,
                  ),
              ],
              shape: BoxShape.circle,
            ),
            child: ProfileAvatar(
              user: controller.keepRoom.value!.owner!,
              radius: 30.r,
            ),
          ),
        ),
      ),
    );
  }
}
