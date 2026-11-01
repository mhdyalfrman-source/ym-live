import 'package:get/get.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/models/user/user_model.dart';

class RelationController extends GetxController {
  RxList<UserModel> relations = <UserModel>[].obs;
  RxInt relationPage = 1.obs;
  RxBool hasMoreNotification = true.obs;

  Future<void> fetchAllNotification(int id, RelationType type) async {
    if (!hasMoreNotification.value) return;
    var res = await CallServerAPI.post(
      type == RelationType.visitor
          ? "user/getProfileVisit"
          : "user/getUsersAttention",
      {"p": relationPage, "limit": limitCount, "touid": id, "state": type.name},
      withMessage: relationPage.value == 1,
    );

    if (res.isNotEmpty && res["list"] != null) {
      List<UserModel> relationList = UserModel.fromList(res["list"]);
      relations.addAll(relationList);
      relations.refresh();
      hasMoreNotification.value = relationList.length == limitCount;
    }
    relationPage.value++;
  }
}

enum RelationType { follower, following, visitor }
