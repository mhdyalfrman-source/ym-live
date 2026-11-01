import 'package:get/get.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/core/utils/snakbar_dialog.dart';
import 'package:tom_chat/features/badges/models/medal_model.dart';

class BadgeController extends GetxController {
  RxList<MedalModel> medals = <MedalModel>[].obs;
  RxList<MedalModel> myMedals = <MedalModel>[].obs;
  Rx<MedalModel?> selectedMedal = Rx<MedalModel?>(null);

  Future<void> fetchAllMedals() async {
    var res = await CallServerAPI.post("user/myMedals", {});
    if (res.isNotEmpty && res["list"] != null) {
      medals.addAll(MedalModel.fromList(res["list"]));
      myMedals.addAll(
        MedalModel.fromList(res["list"]).where((m) => m.isAchieved),
      );
      medals.refresh();
    }
  }

  Future<void> wearAndTakeOff(int id, int use) async {
    int index = myMedals.indexWhere((m) => m.id == id);
    var res = await CallServerAPI.post("user/useMedals", {
      "id": id,
      "use": use,
    });
    if (res.isNotEmpty) {
      if (index >= 0) {
        myMedals[index].isUsed = use == 1;
        myMedals.refresh();
      }
      Get.back();
      done();
    }
  }
}
