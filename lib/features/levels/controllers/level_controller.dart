import 'package:get/get.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/features/levels/models/app_level_model.dart';

class LevelController extends GetxController {
  RxList<AppLevelModel> gifterLevels = <AppLevelModel>[].obs;
  int gifterPage = 1;
  RxBool hasMoreGifter = true.obs;

  RxList<AppLevelModel> anchorLevels = <AppLevelModel>[].obs;
  int anchorPage = 1;
  RxBool hasMoreAnchorUsers = true.obs;

  RxInt typeIndex = 0.obs;

  int pageLimit = 50;

  Future<void> fetchAllLevels() async {
    if (typeIndex.value == 0) {
      if (!hasMoreGifter.value) {
        return;
      }
    } else if (typeIndex.value == 1) {
      if (!hasMoreAnchorUsers.value) {
        return;
      }
    }
    var res = await CallServerAPI.post("helper/levels", {
      "limit": pageLimit,
      "p": typeIndex.value == 0 ? gifterPage : anchorPage,
      "type": typeIndex.value == 0 ? "gifter" : "anchor",
    });
    if (res.isNotEmpty && res["list"] != null) {
      List<AppLevelModel> userList = AppLevelModel.fromList(res["list"]);
      if (typeIndex.value == 0) {
        hasMoreGifter.value = userList.length >= pageLimit;
        gifterLevels.addAll(userList);
        gifterPage++;
      } else if (typeIndex.value == 1) {
        hasMoreAnchorUsers.value = userList.length >= pageLimit;
        anchorLevels.addAll(userList);
        anchorPage++;
      }
    }
  }
}
