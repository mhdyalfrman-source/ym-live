import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:tom_chat/features/agency/models/agency_model.dart';

import 'package:tom_chat/features/charge/controllers/payment_controller.dart';
import 'package:tom_chat/features/rooms/models/gift_model.dart';
import 'package:tom_chat/features/rooms/models/room_model.dart';
import 'package:tom_chat/models/banner_model.dart';
import 'package:tom_chat/features/chat/models/room_chat_model.dart';
import 'package:tom_chat/models/policy_model.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'package:tom_chat/statics_values.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

mixin HomeControllerVariables {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  RxInt selectedPage = 0.obs;

  late PaymentController inAppController;

  Rx<UserModel> user = StaticValue.userData.obs;
  Rx<AgencyModel?> agency = Rx<AgencyModel?>(null);
  Rx<AgencyModel?> agencyRequest = Rx<AgencyModel?>(null);

  RxInt lastNotificationReserved = 0.obs;
  RxInt lastNotification = 0.obs;
  RxString activeLanguageCode = "".obs;
  RxBool isLight = true.obs;

  RxList<Rx<PolicyModel>> policies = <Rx<PolicyModel>>[].obs;
  RxList<BannerModel> banners = <BannerModel>[].obs;
  RxList<RoomModel> popularLives = <RoomModel>[].obs;
  RxList<RoomModel> followingLives = <RoomModel>[].obs;
  RxList<RoomModel> lastLives = <RoomModel>[].obs;

  RxBool isFetchingLives = false.obs;
  bool hasMoreLives = true;
  bool hasMoreFollowerLives = true;

  Rx<RoomModel?> room = Rx<RoomModel?>(null);
  Rx<RoomModel?> keepRoom = Rx<RoomModel?>(null);

  RxInt adsPageIndex = 0.obs;
  PageController adsController = PageController();

  ScrollController scrollControllerForMyExam = ScrollController();
  ScrollController scrollControllerForCurrentJoinedExam = ScrollController();
  ScrollController scrollControllerForLastJoinedExam = ScrollController();

  bool showHomeSteps = true;
  bool showReelsSteps = true;
  bool showExamsSteps = true;

  // Add Update User Group
  TextEditingController groupName = TextEditingController();
  TextEditingController groupDescription = TextEditingController();

  RxInt selectedStudentService = 0.obs;
  RxInt selectedTeacherService = 0.obs;

  RxInt mainSelectedScreen = 1.obs;
  RxInt selectedTab = 0.obs;

  int livePage = 0;
  int followerLivePage = 0;

  bool chatPageIsOpended = false;

  // CHAT
  RxList<RoomChatModel> roomChats = <RoomChatModel>[].obs;
  RxList<types.Message> messages = <types.Message>[].obs;
  RxInt selectedRoom = (-1).obs;
  int chatsPage = 1;
  bool hasMoewChats = true;

  final RxList<GiftModel> receivedWaitingGiftsAnimation = <GiftModel>[].obs;
  final Rx<GiftModel?> receivedGiftAnimation = Rx<GiftModel?>(null);

  RxBool showAppGifts = false.obs;

  void resetAll() {
    user.value = StaticValue.userData;

    lastNotificationReserved.value = 0;
    lastNotification.value = 0;
    activeLanguageCode.value = "";

    policies.clear();
    banners.clear();
    popularLives.clear();
    followingLives.clear();

    room.value = null;
    keepRoom.value = null;

    adsPageIndex.value = 0;

    showHomeSteps = true;
    showReelsSteps = true;
    showExamsSteps = true;

    // Groups
    groupName.clear();
    groupDescription.clear();

    selectedStudentService.value = 0;
    selectedTeacherService.value = 0;

    mainSelectedScreen.value = 1;
    selectedTab.value = 0;

    livePage = 0;

    chatPageIsOpended = false;

    // Chat
    roomChats.clear();
    messages.clear();
    selectedRoom.value = -1;
    chatsPage = 1;

    receivedWaitingGiftsAnimation.clear();
    receivedGiftAnimation.value = null;

    showAppGifts.value = false;
  }
}
