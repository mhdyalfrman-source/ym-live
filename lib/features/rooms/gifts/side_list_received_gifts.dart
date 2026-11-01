import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/features/rooms/gifts/received_gift_widget.dart';
import 'package:tom_chat/features/rooms/models/room_model.dart';

class SideListReceivedGifts extends StatelessWidget {
  final RoomModel room;
  final TextDirection directionality;
  const SideListReceivedGifts({
    super.key,
    required this.controller,
    required this.room,
    this.directionality = TextDirection.ltr,
  });

  final RoomController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Directionality(
        textDirection: directionality,
        child: SizedBox(
          height: 60.h * 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: controller.receivedGifts.take(4).map((gift) {
              return ReceivedGiftWidget(
                key: ValueKey(gift.sendId),
                onTap: () async {
                  await controller.moveOnClickOnGloablGift(gift);
                },
                room: room,
                gift: gift,
                directionality: directionality,
                onFinish: () {
                  controller.removeNormalGiftByUserId(gift.sendId);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
