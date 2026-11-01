import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timeago_flutter/timeago_flutter.dart';
import 'package:tom_chat/core/image/image_gallery.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/utils/swip_page.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/posts/comment_bottom_sheet.dart';
import 'package:tom_chat/features/posts/controllers/post_controller.dart';
import 'package:tom_chat/features/posts/models/post_model.dart';
import 'package:tom_chat/features/profile/components/user_name_widget.dart';
import 'package:tom_chat/models/helpers/image_model.dart';

class PostItem extends StatefulWidget {
  final PostController controller;
  final int index;
  final PostModel post;

  const PostItem({
    super.key,
    required this.post,
    required this.controller,
    required this.index,
  });

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --------------------------------------------- Header
          Row(
            children: [
              ProfileAvatar(
                openProfileType: OpenProfileType.full,
                user: widget.post.user,
                radius: 20.r,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserNameWidget(
                      user: widget.post.user,
                      style: Theme.of(
                        context,
                      ).textTheme.displaySmall!.copyWith(color: Colors.black),
                    ),
                    Text(
                      CountryService()
                              .findByCode(widget.post.user.country ?? "YE")
                              ?.flagEmoji ??
                          "",
                      style: Theme.of(context).textTheme.displayMedium!
                          .copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              Timeago(
                date: widget.post.createdAt.toLocalDateTime(),
                builder: (context, text) {
                  return Text(
                    "• $text",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (widget.post.title.isNotEmpty)
            Text(
              widget.post.title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),

          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GestureDetector(
              onTap: () {
                openDialog(
                  context,
                  ImagePreview(images: [widget.post.url], initialIndex: 0),
                  true,
                );
              },
              child: AppImage(
                image: ImageModel(network: widget.post.url),
                height: 260,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),

          if (widget.post.description.isNotEmpty) ...[
            const SizedBox(height: 10),

            Text(
              widget.post.description,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
            ),
          ],

          const SizedBox(height: 10),

          Row(
            children: [
              InkWell(
                onTap: () {
                  widget.post.isLike = !widget.post.isLike;
                  // if(widget.post.isLike){
                  //   widget.post.likeCount++;
                  // }else{
                  //   widget.post.likeCount--;
                  // }
                  widget.controller.likePost(widget.index, widget.post.isLike);
                  setState(() {});
                },
                child: Row(
                  children: [
                    Icon(
                      widget.post.isLike
                          ? Icons.favorite
                          : Icons.favorite_border_rounded,
                      color: widget.post.isLike ? AppColors.red : Colors.black,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.post.likeCount.toString(),
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              InkWell(
                onTap: () {
                  CommentsBottomSheet.show(context, widget.index);
                },
                child: Row(
                  children: [
                    Icon(Icons.mode_comment_outlined, color: Colors.black),
                    SizedBox(width: 4),
                    Text(
                      widget.post.commentCount.toString(),
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
