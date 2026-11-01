import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller_variables.dart';
import 'package:tom_chat/models/user/user_model.dart';

mixin RoomCommentsController on GetxController
    implements RoomControllerVariables {
  Future<void> sendComment(LiveCommentModel message) async {
    CallServerAPI.post(
      'live/sendMessage',
      {
        if (message.image == null) 'msg': message.message,
        'rid': room.value.id,
        // 'pro': message.pro.toString(),
        // 'mentionTo': message.replyTo,
        // 'replyMessage': message.replyMessage,
        // 'metaData':message.message
      },
      file: message.image,
      fileFieldName: message.image == null ? 'file' : "image",
    );
    // SocketManager.instance.emitToServer("sendMessage", {
    //   "rid":room.value.id,
    //   "txt":message
    // });
  }

  void insertWelcomeComment() {
    if (comments.any((c) => c.message == 'Welcome to live')) return;
    comments.insert(
      0,
      LiveCommentModel(message: "Welcome to live", type: MessageType.system),
    );
  }

  void setAnimatedListKey(GlobalKey<AnimatedListState> key) {
    animatedListKey = key;
  }

  Future<void> addComment(LiveCommentModel comment) async {
    comments.add(comment);
    animatedListKey?.currentState?.insertItem(
      comments.length - 1,
      duration: const Duration(milliseconds: 600),
    );

    // Trigger animated list insertion
    if (animatedListKey?.currentState != null) {
      if (comments.length > 15) {
        Future.delayed(const Duration(milliseconds: 600), () {
          comments.removeAt(0); // Remove from beginning instead of end
          animatedListKey?.currentState?.removeItem(
            0,
            (context, animation) => const SizedBox.shrink(),
            duration: const Duration(milliseconds: 300),
          );
        });
      }
    }

    // Smooth auto-scroll to show the latest comment
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (!scrollController.hasClients || comments.isEmpty) return;

    // Wait for the widget to be built before scrolling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent + 20,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void removeComment(String commentId) {
    // final index = comments.indexWhere((comment) => comment.id == commentId);
    // if (index != -1) {
    //   final removedComment = comments[index];
    //   comments.removeAt(index);

    //   // Trigger animated list removal
    //   if (_animatedListKey?.currentState != null) {
    //     _animatedListKey!.currentState!.removeItem(
    //       index,
    //       (context, animation) => SlideTransition(
    //         position: animation.drive(
    //           Tween<Offset>(
    //             begin: const Offset(-1.0, 0.0),
    //             end: Offset.zero,
    //           ).chain(CurveTween(curve: Curves.easeInBack)),
    //         ),
    //         child: FadeTransition(
    //           opacity: animation,
    //           child: Container(
    //             margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
    //             child: Text(
    //               '${removedComment.user?.name}: ${removedComment.message}',
    //               style: const TextStyle(color: Colors.grey),
    //             ),
    //           ),
    //         ),
    //       ),
    //       duration: const Duration(milliseconds: 300),
    //     );
    //   }
    // }
  }

  void clearComments() {
    comments.clear();
  }

  /// Manually scroll to the bottom of the comments list
  void scrollToBottom() {
    _scrollToBottom();
  }
}

class LiveCommentModel {
  String? message;
  UserModel? user;
  MessageType type;
  Map? metadata;
  File? image;
  LiveCommentModel({
    required this.message,
    required this.type,
    this.user,
    this.metadata,
    this.image,
  });

  factory LiveCommentModel.fromMap(Map<String, dynamic> map) {
    return LiveCommentModel(
      type: MessageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MessageType.text,
      ),
      message: map['text'],
      user: map["person"] != null ? UserModel.fromMap(map['person']) : null,
    );
  }
}

enum MessageType { text, gift, system, sticker, image, box }
