import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/core/utils/swip_page.dart';
import 'package:tom_chat/features/profile/profile_screen.dart';
import 'package:tom_chat/features/rooms/room_screen.dart';

class AppShareHelper {
  AppShareType type;
  Map<ShareKeyType, String> parameters;
  AppShareHelper({required this.type, required this.parameters});

  factory AppShareHelper.fromShareUrl(Uri uri) {
    final pathSegments = uri.pathSegments;
    final typeName = pathSegments.last;
    AppShareType? type = AppShareType.values.firstWhereOrNull(
      (e) => e.name == typeName,
    );
    if (type == null)
      return AppShareHelper(parameters: {}, type: AppShareType.profile);

    Map<ShareKeyType, String> parameters = {};

    uri.queryParameters.forEach((key, value) {
      ShareKeyType? paramKey = ShareKeyType.values.firstWhereOrNull(
        (e) => e.name == key,
      );
      if (paramKey != null) {
        parameters[paramKey] = value;
      }
    });

    return AppShareHelper(type: type, parameters: parameters);
  }

  factory AppShareHelper.fromNotificationData(Map data) {
    AppShareType? type = AppShareType.values.firstWhereOrNull(
      (e) => e.name == data['action'],
    );
    if (type == null)
      return AppShareHelper(parameters: {}, type: AppShareType.profile);
    Map<ShareKeyType, String> parameters = {};

    data.forEach((key, value) {
      ShareKeyType? paramKey = ShareKeyType.values.firstWhereOrNull(
        (e) => e.name == key,
      );
      if (paramKey != null) {
        parameters[paramKey] = value.toString();
      }
    });

    return AppShareHelper(type: type, parameters: parameters);
  }

  String get getShareUrl {
    return "https://tomchat.live/share/${type.name}${mapToQueryString()}";
  }

  String mapToQueryString() {
    List<String> queryList = [];

    parameters.forEach((key, value) {
      queryList.add('${key.name}=${Uri.encodeComponent(value)}');
    });

    return queryList.isNotEmpty ? '?${queryList.join('&')}' : '';
  }

  bool _navGuard = false;

  Future<void> handelRoutes() async {
    if (_navGuard || parameters.isEmpty) return;
    try {
      _navGuard = true;
      if (type == AppShareType.rooms &&
          parameters[ShareKeyType.rid] != "" &&
          parameters[ShareKeyType.uid] != "") {
        swipToPage(
          Get.context!,
          RoomScreen(
            creatorId: MyMath.toInt(parameters[ShareKeyType.uid]),
            roomId: MyMath.toInt(parameters[ShareKeyType.rid]),
          ),
        );
      } else if (type == AppShareType.profile &&
          parameters[ShareKeyType.uid] != "") {
        swipToPage(
          Get.context!,
          ProfileScreen(id: MyMath.toInt(parameters[ShareKeyType.uid])),
        );
      }
    } finally {
      _navGuard = false;
    }
  }
}

enum AppShareType { profile, rooms, posts }

enum ShareKeyType { uid, vid, rid }
