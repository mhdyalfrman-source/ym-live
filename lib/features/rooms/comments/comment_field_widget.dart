import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:tom_chat/features/rooms/comments/chat_input_bottom_sheet.dart';
import 'package:tom_chat/features/rooms/controllers/room_comments_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';

class CommentFieldWidget extends StatelessWidget {
  final Function(LiveCommentModel) sendMessage;
  final TextEditingController textController;
  final UserModel user;
  final double height;
  final String? replyMessage;
  final String? mentionUserName;
  final String tag;

  const CommentFieldWidget({
    super.key,
    required this.sendMessage,
    required this.textController,
    required this.user,
    this.height = 50,
    this.replyMessage,
    this.mentionUserName,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showChatInput(context),
      child: _buildCommentField(context),
    );
  }

  Widget _buildCommentField(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          const Icon(
            HugeIcons.strokeRoundedMessage01,
            color: Colors.white70,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              textController.text.isEmpty
                  ? context.l10n.enterYourMessage
                  : textController.text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showChatInput(BuildContext context) {
    final theme = Theme.of(context);
    final focusNode = FocusNode();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (context) {
        return ChatInputBottomSheet(
          textController: textController,
          focusNode: focusNode,
          theme: theme,
          sendMessage: sendMessage,
          user: user,
          replyMessage: replyMessage,
          mentionUserName: mentionUserName,
        );
      },
    );
  }

  /// Static method for backward compatibility
  static void showChatInput(
    BuildContext context, {
    required UserModel user,
    String? replyMessage,
    String? mentionUserName,
    required TextEditingController textController,
    required Function(LiveCommentModel) sendMessage,
  }) {
    final theme = Theme.of(context);
    final focusNode = FocusNode();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (context) {
        return ChatInputBottomSheet(
          textController: textController,
          focusNode: focusNode,
          theme: theme,
          sendMessage: sendMessage,
          user: user,
          replyMessage: replyMessage,
          mentionUserName: mentionUserName,
        );
      },
    );
  }
}
