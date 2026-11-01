import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/utils/gallery_bottom_sheet.dart';
import 'package:tom_chat/features/rooms/components/custom_text_field.dart';
import 'package:tom_chat/features/rooms/controllers/room_comments_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';

class ChatInputBottomSheet extends StatefulWidget {
  final TextEditingController textController;
  final FocusNode focusNode;
  final ThemeData theme;
  final Function(LiveCommentModel) sendMessage;
  final UserModel user;
  final String? replyMessage;
  final String? mentionUserName;

  const ChatInputBottomSheet({
    super.key,
    required this.textController,
    required this.focusNode,
    required this.theme,
    required this.sendMessage,
    required this.user,
    this.replyMessage,
    this.mentionUserName,
  });

  @override
  State<ChatInputBottomSheet> createState() => _ChatInputBottomSheetState();
}

class _ChatInputBottomSheetState extends State<ChatInputBottomSheet> {
  @override
  void initState() {
    super.initState();
    _autoFocusTextField();
    _initializeMentionText();
  }

  void _autoFocusTextField() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.focusNode.requestFocus();
    });
  }

  void _initializeMentionText() {
    if (widget.mentionUserName != null) {
      widget.textController.text =
          '@${widget.mentionUserName}: ${widget.textController.text}';
    }
  }

  void _sendMessage() {
    final message = widget.textController.text.trim();
    if (message.isNotEmpty) {
      widget.sendMessage(
        LiveCommentModel(message: message, type: MessageType.text),
      );
      widget.textController.clear();
      Navigator.pop(context);
    }
  }

  void _sendImage() async {
    bool messageSent = false;
    await Get.bottomSheet(
      GalleryBottomSheet(
        onMediaSelected: (File file, bool isVideo) {
          widget.sendMessage(
            LiveCommentModel(
              type: MessageType.image,
              user: widget.user,
              message: "",
              image: file,
            ),
          );
          messageSent = true;
          Get.back();
          Get.back();
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );

    if (!messageSent) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF090909),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 6),
            _buildInputRow(),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow() {
    return Row(
      children: [
        Expanded(child: _buildTextFieldSection()),
        if (widget.user.vipSendImage)
          IconButton(
            onPressed: _sendImage,
            icon: Icon(Icons.image_outlined, color: Colors.white70),
          ),
        IconButton(
          onPressed: () {
            _sendMessage();
          },
          icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
        ),
      ],
    );
  }

  Widget _buildTextFieldSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomTextField(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        focusNode: widget.focusNode,
        keyboardType: TextInputType.multiline,
        borderColor: Colors.transparent,
        fillColor: Colors.transparent,
        textStyle: widget.theme.textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 3,
        maxLength: 100,
        controller: widget.textController,
        hintText: context.l10n.enterComment,
        textInputAction: TextInputAction.send,
        onSubmitted: (_) => _sendMessage(),
      ),
    );
  }
}
