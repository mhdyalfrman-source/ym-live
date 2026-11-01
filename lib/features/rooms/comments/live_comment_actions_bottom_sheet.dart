import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:tom_chat/core/utils/app_bottom_sheet.dart';
import 'package:tom_chat/features/rooms/controllers/room_comments_controller.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'comment_field_widget.dart';

class LiveCommentActionsBottomSheet extends StatelessWidget {
  final RoomController controller;
  final LiveCommentModel comment;
  final UserModel currentUser;
  final Function(UserModel) onBlock;
  final Function(UserModel) onSilence;
  final Function(UserModel) onMakeAdmin;
  final Function(UserModel) onRemoveAdmin;
  const LiveCommentActionsBottomSheet({
    super.key,
    required this.controller,
    required this.comment,
    required this.currentUser,
    required this.onBlock,
    required this.onSilence,
    required this.onMakeAdmin,
    required this.onRemoveAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // LiveCommentActionItem(
        //   icon: HugeIcons.strokeRoundedMessage02,
        //   title:
        //       "replyTo ${comment.user?.name??""}" ,
        //   onTap: () {
        //     Navigator.pop(context);
        //     CommentFieldWidget.showChatInput(
        //       context,
        //       user: comment.user!,
        //       textController: TextEditingController(),
        //       sendMessage: (message) {
        //         controller.sendComment(message);
        //       },
        //       replyMessage: comment.message,
        //       mentionUserName: comment.user?.username,
        //     );
        //   },
        // ),
        LiveCommentActionItem(
          icon: HugeIcons.strokeRoundedCopy01,
          title: context.l10n.copyMessage, // 🔹 localized
          onTap: () async {
            Navigator.pop(context);
            await Clipboard.setData(ClipboardData(text: comment.message ?? ""));
          },
        ),
        // if (currentUser.role == Role.owner &&
        //     currentUser.id != comment.user?.id)
        //   LiveCommentActionItem(
        //     icon: HugeIcons.strokeRoundedUserCheck01,
        //     title: controller.admins.containsKey(comment.user?.id) &&
        //             controller.admins[comment.user?.id] == Role.admin
        //         ? context.l10n.removeFromAdmins(comment.user?.fullName??"")
        //         : context.l10n.makeAdmin(comment.user?.fullName??""),
        //     onTap: () {
        //       Navigator.pop(context);
        //       if (controller.admins.containsKey(comment.user?.id) &&
        //           controller.admins[comment.user?.id] == Role.admin) {
        //         onRemoveAdmin(comment.user!);
        //       } else {
        //         onMakeAdmin(comment.user!);
        //       }
        //     },
        //   ),
        // if ((currentUser.role == Role.owner ||
        //         currentUser.role == Role.admin) &&
        //     currentUser.id != comment.user?.id) ...[
        //   LiveCommentActionItem(
        //     icon: HugeIcons.strokeRoundedMute,
        //     title: '${context.l10n.silence} ${comment.user?.fullName}',
        //     onTap: () {
        //       Navigator.pop(context);
        //       onSilence(comment.user!);
        //     },
        //   ),
        //   LiveCommentActionItem(
        //     icon: HugeIcons.strokeRoundedUserBlock01,
        //     title: '${context.l10n.block} ${comment.user?.fullName}',
        //     onTap: () {
        //       Navigator.pop(context);
        //       onBlock(comment.user!);
        //     },
        //   ),
        //   LiveCommentActionItem(
        //     icon: HugeIcons.strokeRoundedSchoolReportCard,
        //     title: context.l10n.report(comment.user?.fullName??""),
        //     onTap: () {
        //       Navigator.pop(context);
        //       Get.to(() => ReasonPage(
        //             endPoint: "profile/report",
        //             reportKey: "touid",
        //             id: comment.user?.id ?? 0,
        //           ));
        //     },
        //   ),
        // ],
      ],
    );
  }

  static Future<void> show(
    BuildContext context, {
    required LiveCommentModel comment,
    required UserModel currentUser,
    required Function(UserModel) onBlock,
    required Function(UserModel) onSilence,
    required Function(UserModel) onMakeAdmin,
    required RoomController controller,
    required Function(UserModel) onRemoveAdmin,
  }) async {
    // if (comment.user != null &&
    //     !controller.admins.containsKey(comment.user!.id) &&
    //     comment.user?.role == Role.admin) {
    //   controller.admins[comment.user!.id] = Role.admin;
    // }
    // if (controller.admins.containsKey(currentUser.id)) {
    //   currentUser.role = controller.admins[currentUser.id]!;
    // }
    AppBottomSheet.show(
      context: context,
      child: LiveCommentActionsBottomSheet(
        comment: comment,
        currentUser: currentUser,
        onBlock: onBlock,
        onSilence: onSilence,
        onMakeAdmin: onMakeAdmin,
        controller: controller,
        onRemoveAdmin: onRemoveAdmin,
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
            if (icon != null) Icon(icon),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
