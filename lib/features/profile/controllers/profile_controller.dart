import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tom_chat/controllers/general_controller.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/core/utils/open_camera_gallery.dart';
import 'package:tom_chat/core/utils/snakbar_dialog.dart';
import 'package:tom_chat/core/utils/wait_message.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/features/posts/models/post_model.dart';
import 'package:tom_chat/features/rooms/controllers/room_seat_controller.dart';
import 'package:tom_chat/features/store/models/store_item_model.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/helpers/image_model.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'package:tom_chat/statics_values.dart';

class ProfileController extends GetxController {
  RxBool loading = true.obs;
  Rx<UserModel?> user = Rx<UserModel?>(null);
  int userId;

  RxList<PostModel> posts = <PostModel>[].obs;
  int postPage = 1;
  RxBool hasMorePosts = true.obs;

  RxBool showPassword = false.obs;
  RxBool showPassword2 = false.obs;
  TextEditingController userPassword = TextEditingController();
  TextEditingController userPassword2 = TextEditingController();

  // int? birthDay;
  // int? birthMonth;
  // int? birthYear;
  RxString selectedCountry = "".obs;
  Rx<File> image = File("").obs;
  TextEditingController userName1Controller = TextEditingController();
  TextEditingController contentCotroller = TextEditingController();
  RxBool updateLoading = false.obs;

  Rx<StoreItemModel?> activeEntry = Rx<StoreItemModel?>(null);

  ProfileController(this.userId);

  Future<void> fetAllForUser([bool withMessage = true]) async {
    await getUser(withMessage);
    await fetchAllPosts();
  }

  Future<void> getUser([bool withMessage = true]) async {
    var res = await CallServerAPI.post("user", {
      "touid": userId,
    }, withMessage: withMessage);
    if (res.isNotEmpty && res["profile"] != null) {
      user.value = UserModel.fromMap(res["profile"]);
      StaticValue.coins.value = user.value?.coins ?? StaticValue.coins.value; 
      StaticValue.diamond.value = user.value?.diamond ?? StaticValue.diamond.value; 
      activeEntry.value = user.value?.entryList?.firstWhereOrNull(
        (e) => e.active == 1,
      );
    }
    loading.value = false;
  }

  Future<void> fetchAllPosts() async {
    if (!hasMorePosts.value) return;
    var res = await CallServerAPI.post("post", {
      "p": postPage,
      "limit": limitCount,
      "touid": userId,
    }, withMessage: false);

    if (res.isNotEmpty && res["list"] != null) {
      List<PostModel> postsList = PostModel.fromList(res["list"]);
      posts.addAll(postsList);
      posts.refresh();
      hasMorePosts.value = postsList.length == limitCount;
      postPage++;
    }
  }

  Future<void> onEditAccount() async {
    // final String birthday = '${birthDay.toString().padLeft(2, '0')}-'
    //     '${birthMonth.toString().padLeft(2, '0')}-'
    //     '$birthYear';

    updateLoading.value = true;

    try {
      String imageUrl = "";
      if (image.value.path != "") {
        waitMessage(300);
        imageUrl = await uplaudImage(image.value, ImageUploadType.profile);
      }
      var res = await CallServerAPI.post(
        "auth/update",
        {
          "name": userName1Controller.text,
          if(imageUrl != "")
          "avatar": imageUrl,
          "country": selectedCountry.value,
          "comment": contentCotroller.text,
        },
        // fileFieldName: "avatar",file: image.value.path.isEmpty ? null : image.value,
        messageTime: 120,
      );
      updateLoading.value = false;
      if(Get.find<GeneralController>().currentDialog == "WAIT"){
        Get.back();
      }
      if (res.isNotEmpty) {
        user.update((val) {
          val?.name = userName1Controller.text;
          val?.country = selectedCountry.value;
          val?.comment = contentCotroller.text;
          val?.avatar = ImageModel(network: imageUrl);
        });
        image.value = File("");
        Get.back();
        done();
      }
    } catch (_) {
      updateLoading.value = false;
    }
  }

  Future<void> savePassword() async {
    if (userPassword.text != userPassword2.text) {
      snakbarDialog(
        title: Get.context!.l10n.unSamePassword,
        durationSecound: 5,
      );
      return;
    }

    updateLoading.value = true;

    try {
      var res = await CallServerAPI.post(
        "auth/update",
        {"password": userPassword.text},
        messageTime: 120,
        withSnakbar: true,
      );
      updateLoading.value = false;
      if (res.isNotEmpty) {
        Get.back();
        done();
      }
    } catch (_) {
      updateLoading.value = false;
    }
  }

  Future<void> updateBG() async {
    String file = await openGallery();
    if (file == "") return;
    waitMessage(300);
    try {
      String imageUrl = await uplaudImage(File(file), ImageUploadType.profile);
      if(Get.find<GeneralController>().currentDialog == "WAIT"){
        Get.back();
      }
      var res = await CallServerAPI.post(
        "auth/update",
        {
          "bg": imageUrl,
        },
        messageTime: 120,
      );
      if (res.isNotEmpty) {
        user.update((val) {
          val?.bg = ImageModel(network: imageUrl);
        });
        done();
      }
    } catch (_) {}
  }
}
