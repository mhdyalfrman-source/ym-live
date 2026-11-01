import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/features/posts/components/post_item.dart';
import 'package:tom_chat/features/posts/controllers/post_controller.dart';
import 'package:tom_chat/features/posts/new_post_screen.dart';
import 'package:tom_chat/l10n/l10n.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  late PostController controller;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = Get.put(PostController(), permanent: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.posts.clear();
      controller.postPage = 1;
      controller.hasMorePosts.value = true;
      if (controller.postPage == 1) {
        controller.fetchAllPosts();
      }
    });
    scrollController.addListener(() async {
      if (scrollController.position.maxScrollExtent <=
              scrollController.offset &&
          scrollController.offset > 0) {
        await controller.fetchAllPosts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplete(
      title: context.l10n.posts,
      withIcon: false,
      floatingActionButton: InkWell(
        onTap: () {
          Get.to(() => NewPostScreen(controller: controller));
        },
        child: SizedBox(
          width: 110.w,
          height: 40.h,
          child: CardWidget(
            radius: 15,
            colorIndex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.l10n.createPost,
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 3.w),
                Icon(Icons.add),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      child: Obx(() {
        if (controller.posts.isEmpty) {
          return Center(
            child: Text(
              context.l10n.noPostsFound,
              style: Theme.of(
                context,
              ).textTheme.displayMedium!.copyWith(color: Colors.black),
            ),
          );
        }

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(12),
          itemCount: controller.posts.length,
          itemBuilder: (context, index) {
            final post = controller.posts[index];
            return PostItem(post: post, index: index, controller: controller);
          },
        );
      }),
    );
  }
}
