import 'dart:io';

import 'package:get/get.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/features/rooms/controllers/room_agora_controller.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller_variables.dart';
import 'package:tom_chat/features/rooms/models/room_background.dart';
import 'package:tom_chat/models/user/user_model.dart';

mixin RoomSeatController on GetxController
    implements RoomControllerVariables, RoomAgoraController {
  Future<void> changeSeatsMode(int newMode) async {
    Get.back();
    CallServerAPI.post("room/changeRoomSeatsLng", {
      "id": room.value.id,
      "lng": newMode,
    });
  }

  Future<void> seatState(int seatNumber, int state) async {
    CallServerAPI.post("live/seatState", {
      "rid": room.value.id,
      "seat": seatNumber,
      "state": state,
    });
  }

  Future<void> takeSeat(int seatNumber, [int isUp = 1]) async {
    CallServerAPI.post("live/seatTake", {
      "rid": room.value.id,
      "seat": seatNumber,
      "isUp": isUp,
    });
  }

  Future<void> grantSeat(UserModel user, [int isUp = 1]) async {
    CallServerAPI.post("live/seatTake", {
      "rid": room.value.id,
      "touid": user.userId,
      "seat":
          room.value.seats
              .firstWhereOrNull((s) => s.user == null)
              ?.seatNumber ??
          0,
      "isUp": isUp,
    });
  }

  Future<void> muteSeat(int seatNumber, [int mute = 0]) async {
    CallServerAPI.post("live/seatMic", {
      "rid": room.value.id,
      "seat": seatNumber,
      "mute": mute,
    });
  }

  Future<void> getOnlineUsers() async {
    if (!hasMoreOnlineUsers.value) return;
    var res = await CallServerAPI.post("live/onlineUsers", {
      "rid": room.value.id,
      "limit": limitCount,
      "p": onLinePage,
    });
    if (res.isNotEmpty && res["list"] != null) {
      List<UserModel> userList = UserModel.fromList(res["list"]);
      onlineUsers.addAll(userList.obs);
      onlineUsers.refresh();
      onLinePage++;
      hasMoreOnlineUsers.value = userList.length == limitCount;
    }
  }

  Future<List<UserModel>> getUsersByRole({
    required int role,
    required int page,
  }) async {
    var res = await CallServerAPI.post("live/getMembersList", {
      "rid": room.value.id,
      "limit": limitCount,
      "p": page,
      "rule": role,
    });
    if (res.isNotEmpty && res["list"] != null) {
      List<UserModel> userList = UserModel.fromList(res["list"]);
      return userList;
    }
    return [];
  }

  Future<void> getRoomBackgrounds() async {
    if (!hasMoreBackgrounds.value) return;
    var res = await CallServerAPI.post("room/backgroundList", {
      "limit": limitCount,
      "p": backgroundsPage,
    });
    if (res.isNotEmpty && res["list"] != null) {
      List<RoomBackgroundModel> roomList = RoomBackgroundModel.fromList(
        res["list"],
      ).obs;
      roomBackgrounds.addAll(roomList.obs);
      roomBackgrounds.refresh();
      backgroundsPage++;
      hasMoreBackgrounds.value = roomList.length == limitCount;
    }
  }

  Future<void> acceptRequst(int seatNumber, [int accept = 1]) async {
    CallServerAPI.post("live/seatRequestAccept", {
      "rid": room.value.id,
      "seat": seatNumber,
      "accept": accept,
    });
  }

  Future<void> updateRoomName(String newName) async {
    CallServerAPI.post("room/updateRoom", {
      "rid": room.value.id,
      "title": newName,
    });
  }

  Future<void> updateRoomBg(File file) async {
    String image = await uplaudImage(file, ImageUploadType.live);
    CallServerAPI.post("room/updateRoom", {"rid": room.value.id, "bg": image});
  }

  Future<void> updateRoomBgByPath(String path) async {
    CallServerAPI.post("room/updateRoom", {"rid": room.value.id, "bg": path});
  }

  Future<void> updateRoomPassword(String password) async {
    CallServerAPI.post("room/updateRoom", {
      "rid": room.value.id,
      "password": password,
    });
    room.value.password = password == "delete" ? 0 : 1;
  }

  Future<void> updateRoomCarizma(int newState) async {
    CallServerAPI.post("room/updateRoom", {
      "rid": room.value.id,
      "carizma": newState,
    });
    room.value.carizma = newState;
  }

  Future<void> resetRoomCarizma() async {
    CallServerAPI.post("live/clearRoomGifts", {"rid": room.value.id});
  }

  Future<void> updateRoomIcon(File file) async {
    String image = await uplaudImage(file, ImageUploadType.live);
    CallServerAPI.post("room/updateRoom", {
      "rid": room.value.id,
      "icon": image,
    });
  }
}

enum ImageUploadType {
  profile,
  videoCover,
  videos,
  comment,
  live,
  verification,
  businessInfo,
  file,
  audio,
}

Future<String> uplaudImage(File file, ImageUploadType type) async {
  var res = await CallServerAPI.post("helper/globalUploadFile", {
    "lng": 1,
    "extension": file.path.split('.').last.toLowerCase(),
    "f": "ROOM_BG",
    "type": type.name,
  }, withMessage: false);
  String? imagePath;

  if (res.isNotEmpty && res['url'] != null) {
    imagePath = res['url'].toString();
    await CallServerAPI.put(imagePath, file, type: "ROOM_BG");
  }
  return (imagePath ?? "").split("?").first;
}
