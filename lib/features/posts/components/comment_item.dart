import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timeago_flutter/timeago_flutter.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/posts/components/comment_actions_bottom_sheet.dart';
import 'package:tom_chat/features/posts/controllers/post_controller.dart';
import 'package:tom_chat/features/posts/models/comment_model.dart';
import 'package:tom_chat/features/profile/components/user_name_widget.dart';
import 'package:tom_chat/statics_values.dart';

class CommentItem extends StatefulWidget {
  final CommentModel comment;
  final PostController controller;
  final int index;
  final int postIndex;

  const CommentItem({
    super.key,
    required this.comment,
    required this.controller,
    required this.index,
    required this.postIndex,
  });

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        CommentActionsBottomSheet.show(
          context,
          controller: widget.controller,
          isPostOwner:
              widget.controller.posts[widget.postIndex].uid ==
              StaticValue.userData.userId,
          comment: widget.comment,
          index: widget.index,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileAvatar(
              openProfileType: OpenProfileType.full,
              user: widget.comment.user,
              radius: 20.r,
            ),
            const SizedBox(width: 12),

            // Text block
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: UserNameWidget(
                          user: widget.comment.user,
                          style: Theme.of(context).textTheme.labelLarge!
                              .copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Timeago(
                        date: widget.comment.createdAt.toLocalDateTime(),
                        builder: (context, text) {
                          return Text(
                            "• $text",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    widget.comment.text,
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge!.copyWith(color: Colors.black),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                InkWell(
                  onTap: () {
                    widget.comment.isLike = !widget.comment.isLike;
                    // if(widget.comment.isLike){
                    //   widget.comment.likeCount++;
                    // }else{
                    //   widget.comment.likeCount--;
                    // }
                    widget.controller.likeComment(
                      widget.index,
                      widget.comment.isLike,
                    );
                    setState(() {});
                  },
                  child: Row(
                    children: [
                      Icon(
                        widget.comment.isLike
                            ? Icons.favorite
                            : Icons.favorite_border_rounded,
                        color: widget.comment.isLike
                            ? AppColors.red
                            : Colors.black,
                      ),
                      SizedBox(width: 4.r),
                      Text(
                        widget.comment.likeCount.toString(),
                        style: Theme.of(context).textTheme.labelMedium!
                            .copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(width: 5.w),
          ],
        ),
      ),
    );
  }
}
