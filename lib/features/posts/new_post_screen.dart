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
import 'package:tom_chat/features/posts/controllers/post_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';

class NewPostScreen extends StatelessWidget {
  final PostController controller;
  const NewPostScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return PageTemplete(
      resizeToAvoidBottomInset: true,
      title: context.l10n.createPost,
      child: Padding(
        padding: const EdgeInsets.all(10).r,
        child: Column(
          children: [
            Expanded(
              child: Align(
                alignment: AlignmentGeometry.topCenter,
                child: SingleChildScrollView(
                  child: CardWidget(
                    radius: 10.r,
                    colorIndex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(10).r,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _PostImageSection(controller: controller),
                          SizedBox(height: 20.h),
                          _PostTitleSection(controller: controller),
                          SizedBox(height: 15.h),
                          _PostDescriptionSection(controller: controller),
                          SizedBox(height: 15.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _CreatePostButton(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _PostImageSection extends StatelessWidget {
  final PostController controller;
  const _PostImageSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ChooseImage(
        aboveTitle: context.l10n.postImage,
        color: const Color(0x26FFFFFF),
        file: File(controller.imagePath.value),
        onChanged: (path) => controller.setImage(path),
        onCancel: () => controller.setImage(""),
        height: 150.h,
      ),
    );
  }
}

class _PostTitleSection extends StatelessWidget {
  final PostController controller;
  const _PostTitleSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => InputField(
        keyboardType: TextInputType.text,
        isRequired: true,
        aboveLabel: context.l10n.postTitle,
        controller: controller.titleController,
        hint: context.l10n.postTitle,
        enabled: !controller.isLoading.value,
      ),
    );
  }
}

class _PostDescriptionSection extends StatelessWidget {
  final PostController controller;
  const _PostDescriptionSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => InputField(
        keyboardType: TextInputType.text,
        isRequired: false,
        aboveLabel: context.l10n.postDesc,
        controller: controller.descriptionController,
        hint: context.l10n.postDesc,
        maxLines: 4,
        enabled: !controller.isLoading.value,
      ),
    );
  }
}

class _CreatePostButton extends StatelessWidget {
  final PostController controller;
  const _CreatePostButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        child: GeneralButton(
          color: AppColors.primaryDark,
          title: controller.isLoading.value
              ? context.l10n.creating
              : context.l10n.createPost,
          onPressed: () async {
            await controller.createPost();
          },
        ),
      ),
    );
  }
}
