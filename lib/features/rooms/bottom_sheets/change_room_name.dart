import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/widgets/buttons.dart';
import 'package:tom_chat/core/widgets/input_field.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';

changeRoomNameDialog(context, RoomController controller) {
  TextEditingController textController = TextEditingController(
    text: controller.room.value.title,
  );
  RxString value = "".obs;
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 25).r,
        backgroundColor: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(15).r,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.roomName,
                style: Theme.of(
                  context,
                ).textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5.h),
              InputField(
                isRequired: false,
                keyboardType: TextInputType.text,
                controller: textController,
                onChanged: (v) {
                  value.value = v;
                },
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: Obx(() {
                      return GeneralButton(
                        onPressed: value.trim().isEmpty
                            ? null
                            : () async {
                                Get.back();
                                controller.updateRoomName(textController.text);
                              },
                        colorIndex: 1,
                        title: context.l10n.save,
                      );
                    }),
                  ),
                  Expanded(
                    child: GeneralButton(
                      onPressed: Get.back,
                      colorIndex: 1,
                      title: context.l10n.close,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
