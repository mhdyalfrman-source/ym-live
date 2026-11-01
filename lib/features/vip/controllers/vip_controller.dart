import 'package:get/get.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/core/utils/snakbar_dialog.dart';
import 'package:tom_chat/features/vip/models/vip_model.dart';
import 'package:tom_chat/statics_values.dart';

class VipController extends GetxController {
  RxList<VipModel> vipList = <VipModel>[].obs;
  RxInt currentIndex = (-1).obs;

  Future<void> fetchAllVip() async {
    var res = await CallServerAPI.post("shop/vipList", {});
    if (res.isNotEmpty && res["list"] != null) {
      vipList.addAll(VipModel.fromList(res["list"]));
      vipList.refresh();
      currentIndex.value = 0;
    }
  }

  Future<void> buyItem(VipModel item, [int? touid]) async {
    Map res = await CallServerAPI.post("shop/vipBuying", {
      "num": item.num,
      "touid": touid ?? StaticValue.userData.userId,
    });
    if (res.isNotEmpty) {
      if (touid == null) {
        item.expireAt = 100;
      }
      vipList.refresh();
      done();
    }
  }

  Future<void> activeItem(VipModel item, int active) async {
    Map res = await CallServerAPI.post("shop/vipChangeActive", {
      "num": item.num,
      "active": active,
    });
    if (res.isNotEmpty) {
      item.active = active;
      vipList.refresh();
      done();
    }
  }
}
