import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/core/utils/snakbar_dialog.dart';
import 'package:tom_chat/features/agency/models/agency_model.dart';
import 'package:tom_chat/features/agency/models/agency_user_model.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/features/rooms/controllers/room_seat_controller.dart';
import 'package:tom_chat/features/rooms/models/room_model.dart';
import 'package:tom_chat/models/helpers/image_model.dart';
import 'package:tom_chat/models/user/user_model.dart';

class AgencyController extends GetxController {
  RxList<AgencyModel> searchedAgencies = <AgencyModel>[].obs;
  Rx<AgencyModel?> agency = Rx<AgencyModel?>(null);
  Rx<AgencyUserModel?> currentAgencyUser = Rx<AgencyUserModel?>(null);

  RxDouble todayEarning = 0.0.obs;
  RxDouble weekEarning = 0.0.obs;
  RxDouble totalEarning = 0.0.obs;

  int agencyUsersPage = 1;
  RxBool hasMoreAgencyUsers = true.obs;
  RxList<UserModel> agencyUsers = <UserModel>[].obs;

  int agencyRequestsPage = 1;
  RxBool hasMoreAgencyRequests = true.obs;
  RxList<UserModel> agencyRequests = <UserModel>[].obs;

  int agencyQuitPage = 1;
  RxBool hasMoreAgencyQuit = true.obs;
  RxList<UserModel> agencyQuit = <UserModel>[].obs;

  int agencyRoomsPage = 1;
  RxBool hasMoreAgencyRooms = true.obs;
  RxList<RoomModel> agencyRooms = <RoomModel>[].obs;

  RxBool loading = true.obs;
  Rx<File> image = File("").obs;
  TextEditingController agencyNameController = TextEditingController();
  TextEditingController noteCotroller = TextEditingController();
  RxBool updateLoading = false.obs;

  Future<void> getAgencyUsers() async {
    var res = await CallServerAPI.post("guild/usersList", {
      "id": agency.value?.id,
      "p": agencyUsersPage,
      "limit": limitCount,
    });

    if (res.isNotEmpty && res["list"] != null) {
      List list = res["list"];
      List<UserModel> users = [];
      for (var i = 0; i < list.length; i++) {
        users.add(
          UserModel.fromMap(list[i]["user"]).copyWith(
            role: RoleEnum.values.firstWhere(
              (v) => v.value == list[i]["rule"],
              orElse: () => RoleEnum.guest,
            ),
          ),
        );
      }
      agencyUsers.addAll(users);
      agencyUsers.refresh();
      agencyUsersPage++;
      hasMoreAgencyUsers.value = users.length == limitCount;
    }
  }

  Future<void> getAgencyRequest() async {
    var res = await CallServerAPI.post("guild/requestUsersList", {
      "id": agency.value?.id,
      "p": agencyRequestsPage,
      "limit": limitCount,
    });

    if (res.isNotEmpty && res["list"] != null) {
      List list = res["list"];
      List<UserModel> users = [];
      for (var i = 0; i < list.length; i++) {
        users.add(UserModel.fromMap(list[i]["user"]));
      }
      agencyRequests.addAll(users);
      agencyRequests.refresh();
      agencyRequestsPage++;
      hasMoreAgencyRequests.value = users.length == limitCount;
    }
  }

  Future<void> getMyAgency(int id, int uid) async {
    var res = await CallServerAPI.post("guild", {"id": id, "uid": uid});

    if (res.isNotEmpty && res["guild"] != null) {
      agency.value = AgencyModel.fromMap(res["guild"]);
      if (res["userGuild"] != null) {
        currentAgencyUser.value = AgencyUserModel.fromMap(res["userGuild"]);
      }
      todayEarning.value = MyMath.toDouble(res["today_earning"]);
      weekEarning.value = MyMath.toDouble(res["week_earning"]);
      totalEarning.value = MyMath.toDouble(res["total_earning"]);
    }
    if (agency.value == null ||
        agency.value?.user?.role == RoleEnum.kick ||
        agency.value?.user?.state == StateEnum.deleted.value) {
      Get.back();
    }
  }

  Future<void> getMyAgencyRooms(int id) async {
    if (!hasMoreAgencyRooms.value) return;
    Map res = await CallServerAPI.post("guild/rooms", {
      "p": agencyRoomsPage,
      "limit": limitCount,
      "id": id,
    }, withMessage: false);
    if (res.isNotEmpty) {
      if (res["list"] is List && (res["list"] as List).isNotEmpty) {
        List<RoomModel> rooms = RoomModel.fromList(res["list"]);
        agencyRooms.addAll(rooms);
        agencyRooms.refresh();
        agencyRoomsPage++;
        hasMoreAgencyRooms.value = rooms.length == limitCount;
      }
    }
  }

  Future<List<AgencyModel>> fetchAllAgenciesForSearch(
    String text,
    int p,
  ) async {
    List<AgencyModel> result = [];
    Map res = await CallServerAPI.post("guild/search", {
      "p": p,
      "limit": limitCount,
      "name": text,
    }, withMessage: false);
    if (res.isNotEmpty) {
      if (res["list"] is List && (res["list"] as List).isNotEmpty) {
        result.addAll(AgencyModel.fromList(res["list"]));
      }
    }
    return result;
  }

  Future<void> joinToAgency(AgencyModel agecny) async {
    Map res = await CallServerAPI.post("guild/addRequest", {
      "guild_id": agecny.id,
    }, withMessage: true);
    if (res.isNotEmpty) {
      Get.find<HomeController>().agencyRequest.value = agecny;
      Get.back();
      done();
    }
  }

  Future<bool> acceptRequest(int userId, int newState) async {
    Map res = await CallServerAPI.post("guild/requestState", {
      "touid": userId,
      "state": newState,
    }, withMessage: true);
    if (res.isNotEmpty) {
      done();
      return true;
    }
    return false;
  }

  // Future<bool> kickUser(int userId)async{
  //   Map res = await CallServerAPI.post("guild/requestState", {
  //     "touid":userId,
  //     "state":0
  //   },withMessage: true);
  //   if(res.isNotEmpty){
  //     return true;
  //   }
  //   return false;
  // }

  Future<void> onEditAgency() async {
    updateLoading.value = true;

    try {
      String imageUrl = "";
      if (image.value.path != "") {
        imageUrl = await uplaudImage(image.value, ImageUploadType.profile);
      }
      var res = await CallServerAPI.post(
        "guild/update",
        {
          "name": agencyNameController.text,
          if (imageUrl != "") "icon": imageUrl,
          "notice": noteCotroller.text,
        },
        // fileFieldName: "avatar",file: image.value.path.isEmpty ? null : image.value,
        messageTime: 120,
      );
      updateLoading.value = false;
      if (res.isNotEmpty) {
        agency.update((val) {
          val?.name = agencyNameController.text;
          val?.icon = ImageModel(network: imageUrl);
          val?.notice = noteCotroller.text;
        });
        Get.back();
        done();
      }
    } catch (_) {
      updateLoading.value = false;
    }
  }
}
