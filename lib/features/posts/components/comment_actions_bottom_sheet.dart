import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:tom_chat/core/utils/app_bottom_sheet.dart';
import 'package:tom_chat/features/posts/controllers/post_controller.dart';
import 'package:tom_chat/features/posts/models/comment_model.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/statics_values.dart';

class CommentActionsBottomSheet extends StatelessWidget {
  final PostController controller;
  final bool isPostOwner;
  final CommentModel comment;
  final int index;
  const CommentActionsBottomSheet({
    super.key,
    required this.controller,
    required this.comment,
    required this.isPostOwner,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LiveCommentActionItem(
          icon: HugeIcons.strokeRoundedCopy01,
          title: context.l10n.copyMessage, // 🔹 localized
          onTap: () async {
            Get.back();
            await Clipboard.setData(ClipboardData(text: comment.text));
          },
        ),
        if (isPostOwner || comment.user.userId == StaticValue.userData.userId)
          LiveCommentActionItem(
            icon: HugeIcons.strokeRoundedDelete01,
            title: context.l10n.delete,
            onTap: () {
              Get.back();
              controller.deleteComment(index);
            },
          ),
      ],
    );
  }

  static Future<void> show(
    BuildContext context, {
    required PostController controller,
    required bool isPostOwner,
    required CommentModel comment,
    required int index,
  }) async {
    AppBottomSheet.show(
      backgroundColor: Colors.white,
      context: context,
      child: CommentActionsBottomSheet(
        controller: controller,
        comment: comment,
        index: index,
        isPostOwner: isPostOwner,
      ),
    );
  }
}

class LiveCommentActionItem extends StatelessWidget {
  final IconData? icon;
  final String title;
  final VoidCallback onTap;
  const LiveCommentActionItem({
    super.key,
    required this.title,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (icon != null) Icon(icon, color: Colors.black),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
