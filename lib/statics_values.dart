import 'dart:async';
import 'package:get/get.dart';
import 'package:tom_chat/features/agency/models/agency_model.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'package:get_storage/get_storage.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

String seprator = ".|.";
int answerScore = 1;

class StaticValue {
  // static String serverPath= 'http://10.0.2.2:801/tom_chat/';
  static String serverPath = 'http://10.0.2.2:801/exam/';
  static String socketPath = 'ws://10.0.2.2:6001';
  static Map? appConfigs;
  static UserModel userData = visitUser;
  static AgencyModel? agency;
  static AgencyModel? agencyRequest;
  // static IOWebSocketChannel? channel;
  static bool stillConnect = false;
  static StreamController streamController =
      StreamController<String>.broadcast();
  static int? pageId;
  static String regexPatern = r"^(\+967|0)?7\d{9}$";
  static bool fromNote = false;
  static PurchaseDetails? purchaseDetails;

  static String agoraAppId = "";
  static RxInt coins = 0.obs;
  static RxInt diamond = 0.obs;
  static RxBool hasNewMessage = false.obs;

  static String language = "ar";
  static serverConfig(Map map) {
    serverPath = map["server_path"];
    socketPath = map["socket_path"];
    GetStorage().write("server_config", map);
  }

  static String? webToken;
}

UserModel visitUser = UserModel(
  userId: 0,
  name: "Ahmed Alasmet",
  pos: UserPosition.user,
  type: 0,
  points: 0,
);
