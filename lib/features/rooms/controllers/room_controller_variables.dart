import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tom_chat/controllers/event_emitter.dart';
import 'package:tom_chat/features/rooms/controllers/room_comments_controller.dart';
import 'package:tom_chat/features/rooms/models/emoji_model.dart';
import 'package:tom_chat/features/rooms/models/game_config_model.dart';
import 'package:tom_chat/features/rooms/models/game_model.dart';
import 'package:tom_chat/features/rooms/models/red_box.dart';
import 'package:tom_chat/features/rooms/models/rocket_model.dart';
import 'package:tom_chat/features/rooms/models/room_background.dart';
import 'package:tom_chat/features/rooms/models/room_model.dart';
import 'package:tom_chat/features/rooms/models/seat_model.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'package:tom_chat/statics_values.dart';

mixin RoomControllerVariables on GetxController {
  final box = GetStorage();

  // UI states
  RxBool showGiftPanel = false.obs;
  RxBool isSoundOn = true.obs;
  RxBool isLoading = false.obs;

  // حالات التبديل الثلاثة (قابلة للمراقبة)
  RxBool isMemberCanTakeMic = true.obs;
  RxBool isMemberCanSendMessage = true.obs;
  RxBool isRoomPasswordEnabled = false.obs;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  RxString imagePath = ''.obs;

  RxInt roomUsersCount = 0.obs;
  RxInt roomCoins = 0.obs;
  Rx<RoomModel> room = RoomModel().obs;

  RxBool isInitialized = false.obs;
  RxBool hasNewGustRequests = false.obs;
  RxBool isRoomConnected = false.obs;
  RxBool currentUserInGust = false.obs;
  RxBool currentUserIsHost = false.obs;

  RxBool showMiniPlayer = false.obs;
  RxBool showFullMiniPlayer = true.obs;

  RxBool roomColorIsRed = false.obs;

  EventHandler? onReconnectHandler;
  RxInt isMicOn = 0.obs;

  RxBool playing = false.obs;

  // Comments
  final RxList<LiveCommentModel> comments = <LiveCommentModel>[].obs;
  ScrollController scrollController = ScrollController();
  GlobalKey<AnimatedListState>? animatedListKey;
  TextEditingController commentTextController = TextEditingController();

  RxList<SeatModel> userRequests = <SeatModel>[].obs;

  RxList<UserModel> onlineUsers = <UserModel>[].obs;
  int onLinePage = 1;
  RxBool hasMoreOnlineUsers = true.obs;

  Rx<RoleEnum> userRole = RoleEnum.user.obs;

  final RxList<UserModel> enteryWaitingAnimation = <UserModel>[].obs;
  final Rx<UserModel?> enteryAnimation = Rx<UserModel?>(null);

  final RxList<RoomBackgroundModel> roomBackgrounds =
      <RoomBackgroundModel>[].obs;
  int backgroundsPage = 1;
  RxBool hasMoreBackgrounds = true.obs;

  RxBool showSvgaEntries = true.obs;
  RxBool showSvgaGifts = true.obs;

  RxList<RedBoxModel> redBoxes = <RedBoxModel>[].obs;
  RxList<RedBoxModel> redBoxQueue = <RedBoxModel>[].obs;
  AccurateTimer? boxTimer;
  bool isBoxCoinBottomSheetOpen = false;

  resetVariablesToDefault() {
    roomUsersCount.value = 0;
    roomCoins.value = 0;
    isInitialized.value = false;
    hasNewGustRequests.value = false;
    isRoomConnected.value = false;
    currentUserInGust.value = false;
    showMiniPlayer.value = false;
    showFullMiniPlayer.value = true;
    playing.value = false;
    roomColorIsRed.value = false;
    isMicOn.value = 0;
    room.value = RoomModel();
    userRequests.clear();

    comments.clear();
    commentTextController.text = "";

    redBoxes.clear();
    redBoxQueue.clear();
  }

  List<SeatModel> get seats =>
      room.value.seats.where((s) => s.user != null).toList();
  List<UserModel> get seatsUsers => room.value.seats
      .where((s) => s.user != null)
      .map((s) => s.user!)
      .toList();
  bool get userInGust => room.value.seats.any(
    (s) => s.user?.userId == StaticValue.userData.userId,
  );
  int get userGustIndex => room.value.seats.indexWhere(
    (s) => s.user?.userId == StaticValue.userData.userId,
  );

  String? password;

  List<EmojiModel> emojies = [];
  Rx<RocketLevel?> rocket = Rx<RocketLevel?>(null);

  final RxList<GameModel> games = <GameModel>[].obs;
  final Rx<GameConfigModel> gameConfig = GameConfigModel().obs;
  final RxBool gameIsLoading = false.obs;
  final Rx<GameModel?> selectedGame = Rx<GameModel?>(null);
  Map<int, List<List<Map>>> seatStyles = {
    5: [
      [
        {"num": 0, "size": 1},
      ],
      [
        {"num": 1, "size": 0.25},
        {"num": 2, "size": 0.25},
        {"num": 3, "size": 0.25},
        {"num": 4, "size": 0.25},
      ],
    ],
    10: [
      [
        {"num": 0, "size": 0.5},
        {"num": 1, "size": 0.5},
      ],
      [
        {"num": 2, "size": 0.25},
        {"num": 3, "size": 0.25},
        {"num": 4, "size": 0.25},
        {"num": 5, "size": 0.25},
      ],
      [
        {"num": 6, "size": 0.25},
        {"num": 7, "size": 0.25},
        {"num": 8, "size": 0.25},
        {"num": 9, "size": 0.25},
      ],
    ],
    15: [
      [
        {"num": 0, "size": 0.2},
        {"num": 1, "size": 0.2},
        {"num": 2, "size": 0.2},
        {"num": 3, "size": 0.2},
        {"num": 4, "size": 0.2},
      ],
      [
        {"num": 5, "size": 0.2},
        {"num": 6, "size": 0.2},
        {"num": 7, "size": 0.2},
        {"num": 8, "size": 0.2},
        {"num": 9, "size": 0.2},
      ],
      [
        {"num": 10, "size": 0.2},
        {"num": 11, "size": 0.2},
        {"num": 12, "size": 0.2},
        {"num": 13, "size": 0.2},
        {"num": 14, "size": 0.2},
      ],
    ],
    20: [
      [
        {"num": 0, "size": 0.2},
        {"num": 1, "size": 0.2},
        {"num": 2, "size": 0.2},
        {"num": 3, "size": 0.2},
        {"num": 4, "size": 0.2},
      ],
      [
        {"num": 5, "size": 0.2},
        {"num": 6, "size": 0.2},
        {"num": 7, "size": 0.2},
        {"num": 8, "size": 0.2},
        {"num": 9, "size": 0.2},
      ],
      [
        {"num": 10, "size": 0.2},
        {"num": 11, "size": 0.2},
        {"num": 12, "size": 0.2},
        {"num": 13, "size": 0.2},
        {"num": 14, "size": 0.2},
      ],
      [
        {"num": 15, "size": 0.2},
        {"num": 16, "size": 0.2},
        {"num": 17, "size": 0.2},
        {"num": 18, "size": 0.2},
        {"num": 19, "size": 0.2},
      ],
    ],
  };
}

class AccurateTimer {
  final Duration interval;
  final void Function(Duration elapsed) onTick;

  late DateTime _startTime;
  Timer? _timer;

  AccurateTimer(this.interval, this.onTick);

  void start() {
    _startTime = DateTime.now();
    _timer = Timer.periodic(interval, (_) {
      final elapsed = DateTime.now().difference(_startTime);
      onTick(elapsed);
    });
  }

  void cancel() {
    _timer?.cancel();
  }
}
