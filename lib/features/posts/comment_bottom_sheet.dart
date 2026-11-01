import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/utils/app_bottom_sheet.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/core/widgets/input_field.dart';
import 'package:tom_chat/features/posts/components/comment_item.dart';
import 'package:tom_chat/features/posts/controllers/post_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';

class CommentsBottomSheet extends StatefulWidget {
  final int postIndex;
  const CommentsBottomSheet({super.key, required this.postIndex});

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();

  static Future<void> show(BuildContext context, int postIndex) async {
    AppBottomSheet.show(
      context: context,
      child: CommentsBottomSheet(postIndex: postIndex),
      title: "Comments",
      backgroundColor: Colors.white,
    );
  }
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  late PostController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(PostController(), permanent: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.comments.clear();
      controller.commentPage = 1;
      controller.hasMoreComments.value = true;
      controller.commentInput.value = "";
      controller.fetchAllComments(widget.postIndex);
    });
    controller.commentScrollController = ScrollController();
    controller.commentScrollController.addListener(() async {
      if (controller.commentScrollController.position.maxScrollExtent <=
              controller.commentScrollController.offset &&
          controller.commentScrollController.offset > 0) {
        await controller.fetchAllComments(widget.postIndex);
      }
    });
  }

  @override
  void dispose() {
    controller.commentScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height * 0.7,
      child: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.comments.isEmpty) {
                return Center(
                  child: Text(
                    context.l10n.noCommentsYet,
                    style: Theme.of(
                      context,
                    ).textTheme.displayMedium!.copyWith(color: Colors.black),
                  ),
                );
              }

              return ListView.builder(
                controller: controller.commentScrollController,
                padding: const EdgeInsets.all(16),
                itemCount: controller.comments.length,
                itemBuilder: (context, index) {
                  final comment = controller.comments[index];
                  return CommentItem(
                    postIndex: widget.postIndex,
                    index: index,
                    comment: comment,
                    controller: controller,
                  );
                },
              );
            }),
          ),

          CardWidget(
            colorIndex: 1,
            radius: 15.r,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InputField(
                      hint: context.l10n.enterComment,
                      isRequired: true,
                      keyboardType: TextInputType.text,
                      controller: controller.commentTextController,
                      onChanged: (v) => controller.commentInput.value = v,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () async =>
                        await controller.sendComment(widget.postIndex),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primaryDark,
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
