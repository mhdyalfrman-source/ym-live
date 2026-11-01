import 'package:get/get.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller_variables.dart';
import 'package:tom_chat/features/rooms/models/rocket_model.dart';
import 'package:tom_chat/models/user/user_model.dart';

class RankingController extends GetxController {
  RxList<UserModel> rockets = <UserModel>[].obs;
  RxList<RocketLevel> rocketsLevels = <RocketLevel>[].obs;
  Rx<RocketLevel?> rocketLevel = Rx<RocketLevel?>(null);
  RxInt secounds = 0.obs;
  RxBool isLoading = true.obs;
  bool hasMoreData = true;

  AccurateTimer? goalTimer;

  RxInt selectedRocket = 1.obs;
  RxBool showRocket = true.obs;

  @override
  onClose() {
    goalTimer?.cancel();
  }

  void startGoalTimer(int s) {
    secounds.value = s;
    goalTimer?.cancel();
    goalTimer = AccurateTimer(const Duration(seconds: 1), (elapsed) {
      secounds.value--;
      if (secounds.value <= 0) {
        goalTimer?.cancel();
      }
    });
    goalTimer?.start();
  }

  Future<void> fetchRocketRanking(int rid) async {
    var response = await CallServerAPI.post('rocket/ranking', {'rid': rid});
    if (response.isNotEmpty) {
      final list = response['list'];
      startGoalTimer(response["sec"] ?? 0);
      if (list.isNotEmpty) {
        list.forEach((e) {
          UserModel u = UserModel.fromMap(e);
          u.coins = MyMath.toInt(e["total_points"]);
          rockets.add(u);
        });
        rockets.refresh();
        isLoading.value = false;
      }
    }
  }

  Future<void> fetchRocketsLevels(int rid) async {
    var response = await CallServerAPI.post('rocket', {'rid': rid});
    if (response.isNotEmpty) {
      final list = response['levels'];
      if (list.isNotEmpty) {
        list.forEach((e) {
          rocketsLevels.add(RocketLevel.fromMap(e));
        });
        rocketLevel.value = RocketLevel.fromMap(response["myLevel"]);
        Get.find<RoomController>().rocket.value = rocketLevel.value;
        selectedRocket.value = rocketLevel.value!.nextLevel;
        rocketsLevels.refresh();
        isLoading.value = false;
      }
    }
  }
}
