import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/features/rooms/comments/live_comment_item.dart';
import 'package:tom_chat/features/rooms/controllers/room_comments_controller.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/features/rooms/models/room_model.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'package:tom_chat/statics_values.dart';

class LiveCommentsList extends StatefulWidget {
  final RoomController controller;
  final bool autoScroll;
  final Function(UserModel)? onCommentTap;
  final RoomModel room;

  const LiveCommentsList({
    super.key,
    required this.controller,
    this.autoScroll = true,
    this.onCommentTap,
    required this.room,
  });

  @override
  State<LiveCommentsList> createState() => _LiveCommentsListState();
}

class _LiveCommentsListState extends State<LiveCommentsList> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => widget.controller.comments.isEmpty
          ? _buildEmptyState()
          : _buildCommentsList(),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text('', style: TextStyle(color: Colors.white54, fontSize: 14)),
    );
  }

  Widget _buildCommentsList() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.white, Colors.white],
              stops: [0.001, 0.2, 1],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: ListView.separated(
            controller: widget.controller.scrollController,
            itemCount: widget.controller.comments.length,
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            separatorBuilder: (context, index) => SizedBox(height: 10.h),
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemBuilder: (context, index) {
              if (index >= widget.controller.comments.length) {
                return const SizedBox.shrink();
              }
              final comment = widget.controller.comments[index];
              return _buildCommentItem(comment);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCommentItem(LiveCommentModel comment) {
    return LiveCommentItem(
      room: widget.room,
      controller: widget.controller,
      comment: comment,
      onTap: widget.onCommentTap,
      currentUser: StaticValue.userData,
      onBlock: (_) {},
      onSilence: (_) {},
      onMakeAdmin: (_) {},
      onRemoveAdmin: (_) {},
    );
  }
}
