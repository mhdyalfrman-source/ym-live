import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get_storage/get_storage.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/features/chat/controllers/message_controller.dart';

import 'package:tom_chat/features/home/controllers/listeners.dart';
import 'package:tom_chat/features/home/controllers/storage_Service.dart';
import 'package:tom_chat/features/home/controllers/variable.dart';
import 'package:tom_chat/features/rooms/models/room_model.dart';
import 'package:tom_chat/models/banner_model.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'package:tom_chat/statics_values.dart';

const limitCount = 20;

class HomeController extends GetxService
    with HomeListeners, HomeControllerVariables, MessageController {
  onTap(int index) {
    selectedPage.value = index;
  }

  @override
  void onInit() async {
    super.onInit();
    GetStorage().writeIfNull("last_not", 0);
    lastNotificationReserved.value = GetStorage().read("last_not");
    isLight.value = GetStorage().read("darkMode");
    scaffoldKey = GlobalKey<ScaffoldState>();
    // GetStorage().remove("show_home_steps");
    // GetStorage().remove("show_reels_steps");
    // GetStorage().remove("show_exams_steps");
    // GetStorage().remove("show_exam_steps");

    showHomeSteps = GetStorage().read("show_home_steps") ?? true;
    showReelsSteps = GetStorage().read("show_reels_steps") ?? true;
    showExamsSteps = GetStorage().read("show_exams_steps") ?? true;
  }

  @override
  onClose() {
    super.onClose();
    stopUserListener();
  }

  fetchAll() async {
    Future.wait([
      // fetchAllChats(),
      fetchAllBanners(),
      fetchAllLives(),
      fetchAllFollowerLives(),
      getRoomById(),
      fetchAgoraConfig(),
    ]);
    startUserListener();
  }

  Future<void> fetchAllBanners() async {
    Map bannersRespons = await CallServerAPI.post("helper/getBanners", {});
    if (bannersRespons.isNotEmpty && bannersRespons["list"] != null) {
      banners.addAll(BannerModel.fromList(bannersRespons["list"]));
      banners.refresh();
    }
  }

  Future<void> fetchAllLives() async {
    if (livePage == 0) {
      popularLives.clear();
      hasMoreLives = true;
    }
    if (!hasMoreLives) return;
    hasMoreLives = false;
    livePage++;
    Map res = await CallServerAPI.post("room", {
      "p": livePage,
      "limit": limitCount,
    });
    if (res.isNotEmpty) {
      if (res["list"] is List && (res["list"] as List).isNotEmpty) {
        hasMoreLives = true;
        popularLives.addAll(RoomModel.fromList(res["list"]));
        popularLives.refresh();
      }
    }
    if (livePage == 1) {
      lastLives = RoomStorageService().getRooms().obs;
    }
  }

  Future<void> fetchAllFollowerLives() async {
    if (followerLivePage == 0) {
      followingLives.clear();
      hasMoreFollowerLives = true;
    }
    if (!hasMoreFollowerLives) return;
    hasMoreFollowerLives = false;
    followerLivePage++;
    Map res = await CallServerAPI.post("room", {
      "p": followerLivePage,
      "limit": limitCount,
      "followOnly": 1,
    }, withMessage: false);
    if (res["list"] is List && (res["list"] as List).isNotEmpty) {
      hasMoreFollowerLives = true;
      followingLives.addAll(RoomModel.fromList(res["list"]));
      followingLives.refresh();
    }
  }

  Future<List<RoomModel>> fetchAllLivesForSearch(String text, int p) async {
    List<RoomModel> result = [];
    Map res = await CallServerAPI.post("room", {
      "p": p,
      "limit": limitCount,
      "search": text,
    }, withMessage: false);
    if (res.isNotEmpty) {
      if (res["list"] is List && (res["list"] as List).isNotEmpty) {
        result.addAll(RoomModel.fromList(res["list"]));
      }
    }
    return result;
  }

  Future<List<UserModel>> fetchAllUsersForSearch(String text, int p) async {
    List<UserModel> result = [];
    Map res = await CallServerAPI.post("user/search", {
      "p": p,
      "limit": limitCount,
      "search": text,
    }, withMessage: false);
    if (res.isNotEmpty) {
      if (res["list"] is List && (res["list"] as List).isNotEmpty) {
        result.addAll(UserModel.fromList(res["list"]));
      }
    }
    return result;
  }

  Future<void> getRoomById() async {
    if ((StaticValue.userData.room) != null) {
      room.value = StaticValue.userData.room;
    }
  }

  Future<void> fetchAgoraConfig() async {
    try {
      final response = await CallServerAPI.post(
        'helper/config',
        {},
        withMessage: false,
      );

      if (response.isNotEmpty && response["agora"] != null) {
        final configAppId = response["agora"]?.toString().trim();
        StaticValue.agoraAppId = configAppId!;
      }
    } catch (_) {}
  }
}
