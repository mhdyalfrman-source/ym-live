import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/utils/choose_image.dart';
import 'package:tom_chat/core/widgets/buttons.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/core/widgets/input_field.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';

class NewRoomScreen extends StatefulWidget {
  const NewRoomScreen({super.key});

  @override
  State<NewRoomScreen> createState() => _NewRoomScreenState();
}

class _NewRoomScreenState extends State<NewRoomScreen> {
  RoomPrivacy roomPrivacy = RoomPrivacy.public;
  late RoomController controller;
  @override
  void initState() {
    super.initState();
    controller = Get.put(RoomController(), permanent: true);
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return PageTemplete(
      resizeToAvoidBottomInset: false,
      title: context.l10n.newRoom,
      child: Padding(
        padding: const EdgeInsets.all(10).r,
        child: Column(
          children: [
            Expanded(
              child: Align(
                alignment: AlignmentGeometry.topCenter,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: CardWidget(
                      radius: 10.r,
                      colorIndex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(10).r,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Obx(() {
                              return ChooseImage(
                                aboveTitle: context.l10n.roomIcon,
                                color: Color(0x26FFFFFF),
                                file: File(controller.imagePath.value),
                                onChanged: (v) {
                                  controller.imagePath.value = v;
                                },
                                onCancel: () {
                                  controller.imagePath.value = "";
                                },
                                height: 150.h,
                              );
                            }),
                            SizedBox(height: 20.h),
                            Obx(
                              () => InputField(
                                keyboardType: TextInputType.text,
                                isRequired: true,
                                aboveLabel: context.l10n.roomName,
                                controller: controller.titleController,
                                hint: context.l10n.roomName,
                                enabled: !controller.isLoading.value,
                              ),
                            ),
                            SizedBox(height: 15.h),
                            Obx(
                              () => InputField(
                                keyboardType: TextInputType.text,
                                isRequired: false,
                                aboveLabel: context.l10n.roomDescription,
                                controller: controller.descriptionController,
                                hint: context.l10n.roomDescription,
                                maxLines: 4,
                                enabled: !controller.isLoading.value,
                              ),
                            ),
                            SizedBox(height: 15.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: GeneralButton(
                  color: AppColors.primaryDark,
                  title: controller.isLoading.value
                      ? context.l10n.creating
                      : context.l10n.newRoom,
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await controller.createAudioRoom();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
