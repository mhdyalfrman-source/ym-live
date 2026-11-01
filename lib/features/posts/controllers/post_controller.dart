import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/core/utils/snakbar_dialog.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/features/posts/models/comment_model.dart';
import 'package:tom_chat/features/posts/models/post_model.dart';
import 'package:tom_chat/features/rooms/controllers/room_seat_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/features/chat/models/room_chat_model.dart';
import 'package:tom_chat/statics_values.dart';

class PostController extends GetxController {
  RxList<PostModel> posts = <PostModel>[].obs;
  int postPage = 1;
  RxBool hasMorePosts = true.obs;

  RxList<CommentModel> comments = <CommentModel>[].obs;
  int commentPage = 1;
  RxBool hasMoreComments = true.obs;
  RxString commentInput = "".obs;
  TextEditingController commentTextController = TextEditingController();

  late ScrollController commentScrollController;

  RxBool isLoading = false.obs;
  RxString imagePath = "".obs;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  Future<void> fetchAllPosts() async {
    if (!hasMorePosts.value) return;
    var res = await CallServerAPI.post("post", {
      "p": postPage,
      "limit": limitCount,
    }, withMessage: postPage == 1);

    if (res.isNotEmpty && res["list"] != null) {
      List<PostModel> postsList = PostModel.fromList(res["list"]);
      posts.addAll(postsList);
      posts.refresh();
      hasMorePosts.value = postsList.length == limitCount;
      postPage++;
    }
  }

  Future<void> fetchAllComments(int postIndex) async {
    if (!hasMoreComments.value) return;
    var res = await CallServerAPI.post("post/getComments", {
      "p": commentPage,
      "limit": limitCount,
      "id": posts[postIndex].id,
    }, withMessage: commentPage == 1);

    if (res.isNotEmpty && res["list"] != null) {
      List<CommentModel> commentsList = CommentModel.fromList(res["list"]);
      comments.addAll(commentsList);
      comments.refresh();
      hasMoreComments.value = commentsList.length == limitCount;
      commentPage++;
    }
  }

  Future<void> likePost(int index, bool newState) async {
    unawaited(
      CallServerAPI.post("post/like", {
        "id": posts[index].id,
      }, withMessage: false),
    );
    posts[index].isLike = newState;
    if (newState) {
      posts[index].likeCount++;
    } else {
      posts[index].likeCount--;
    }
  }

  Future<void> likeComment(int index, bool newState) async {
    unawaited(
      CallServerAPI.post("post/commentLike", {
        "id": comments[index].id,
      }, withMessage: false),
    );
    comments[index].isLike = newState;
    if (newState) {
      comments[index].likeCount++;
    } else {
      comments[index].likeCount--;
    }
  }

  Future<void> deleteComment(int index) async {
    unawaited(
      CallServerAPI.post("post/deleteComment", {
        "id": comments[index].id,
      }, withMessage: true),
    );
    comments.removeAt(index);
    comments.refresh();
  }

  Future<void> sendComment(int postIndex) async {
    var res = await CallServerAPI.post("post/comment", {
      "post_id": posts[postIndex].id,
      "comment": commentTextController.text,
    });
    if (res.isNotEmpty && res["comment"] != null) {
      comments.insert(
        0,
        CommentModel(
          id: res["comment"]["id"],
          uid: 0,
          touid: 0,
          postId: posts[postIndex].id,
          likeCount: 0,
          text: commentTextController.text,
          state: 0,
          createdAt: MyDateTime.now(),
          user: StaticValue.userData,
          isLike: false,
        ),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        posts[postIndex].commentCount++;
        posts.refresh();
        comments.refresh();
        commentScrollController.animateTo(
          0,
          duration: Duration(milliseconds: 300),
          curve: Curves.bounceIn,
        );
        commentTextController.text = "";
        commentInput.value = "";
      });
    }
  }

  void setImage(String path) {
    imagePath.value = path;
  }

  Future<void> createPost() async {
    if (imagePath.value.isEmpty) {
      snakbarDialog(
        title: Get.context!.l10n.plsChooseImage,
        durationSecound: 5,
      );
      return;
    }
    if (titleController.text.isEmpty) {
      snakbarDialog(
        title: Get.context!.l10n.titleIsRequird,
        durationSecound: 5,
      );
      return;
    }

    isLoading.value = true;

    String image = await uplaudImage(
      File(imagePath.value),
      ImageUploadType.videos,
    );
    var res = await CallServerAPI.post("post/add", {
      "title": titleController.text,
      "description": descriptionController.text,
      "url": image,
      "type": 1,
    });
    if (res.isNotEmpty && res["post"] != null) {
      res["post"]["user"] = StaticValue.userData.toMap();
      posts.insert(0, PostModel.fromMap(res["post"]));
      posts.refresh();
    }
    isLoading.value = false;

    Get.back();
    done(message: Get.context!.l10n.thePostCreatedSuccessfuly);
    imagePath.value = "";
    titleController.text = "";
    descriptionController.text = "";
  }
}
