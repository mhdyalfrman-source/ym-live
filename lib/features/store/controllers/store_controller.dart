import 'package:get/get.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/core/utils/snakbar_dialog.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/features/store/models/store_item_model.dart';
import 'package:tom_chat/statics_values.dart';

class StoreController extends GetxController {
  RxBool itemShimmer = true.obs;
  RxList<StoreItemModel> items = <StoreItemModel>[].obs;
  RxList<StoreItemModel> backPackItems = <StoreItemModel>[].obs;

  List pages = [1, 1, 1, 1, 1];
  List haMore = [true, true, true, true, true];

  List backpackPages = [1, 1, 1, 1, 1];
  List haMoreBackpack = [true, true, true, true, true];

  RxInt selectedBackpackItem = (-1).obs;
  RxInt selectedItem = (-1).obs;
  RxInt selectedTab = (0).obs;
  RxInt selectedBackpackTab = (0).obs;

  refershBackPack() {
    selectedBackpackItem.value = -1;
    backpackPages = [1, 1, 1, 1, 1];
    haMoreBackpack = [true, true, true, true, true];
    backPackItems.clear();
  }

  Future<void> fetchAllBackPackItems(int type) async {
    if (!haMoreBackpack[type]) return;
    Map res = await CallServerAPI.post(
      "shop/backpack",
      {
        "type": StoreType.values.firstWhere((v) => v.tabIndex == type).value,
        "p": backpackPages[type],
        "limit": limitCount,
      },
      withSnakbar: false,
      withMessage: true,
    );
    if (res.isNotEmpty && res["list"] != null) {
      backPackItems.addAll(
        (res["list"] as List).map((i) => StoreItemModel.fromMap(i)),
      );
      backPackItems.refresh();
      backpackPages[type]++;
      haMoreBackpack[type] = (res["list"] as List).length == limitCount;
    }
    itemShimmer.value = false;
  }

  Future<void> fetchAllItems(int type) async {
    if (!haMore[type]) return;
    Map res = await CallServerAPI.post(
      "shop",
      {
        "type": StoreType.values.firstWhere((v) => v.tabIndex == type).value,
        "limit": limitCount,
        "p": pages[type],
      },
      withSnakbar: false,
      withMessage: true,
    );
    if (res.isNotEmpty && res["list"] != null) {
      items.addAll((res["list"] as List).map((i) => StoreItemModel.fromMap(i)));
      items.refresh();
      pages[type]++;
      haMore[type] = (res["list"] as List).length == limitCount;
    }
    itemShimmer.value = false;
  }

  Future<void> buyItem(StoreItemModel item, [int? touid]) async {
    Map res = await CallServerAPI.post("shop/buying", {
      "id": item.id,
      "touid": touid ?? StaticValue.userData.userId,
    });
    if (res.isNotEmpty) {
      done();
    }
  }

  Future<bool> buyCPItem(
    StoreItemModel item,
    int touid,
    bool fromBackpack,
  ) async {
    Map res = await CallServerAPI.post("cp/useCard", {
      "id": item.id,
      "touid": touid,
      "is_backpack": fromBackpack ? 1 : 0,
    });
    if (res.isNotEmpty) {
      done();
      return true;
    }
    return false;
  }

  Future<void> sendItem(StoreItemModel item, [int? touid]) async {
    Map res = await CallServerAPI.post("shop/sendFromBackpack", {
      "id": item.id,
      "touid": touid ?? StaticValue.userData.userId,
    });
    if (res.isNotEmpty) {
      done();
      refershBackPack();
      fetchAllBackPackItems(selectedBackpackTab.value);
    }
  }

  Future<void> activeItem(StoreItemModel item, bool activeState) async {
    Map res = await CallServerAPI.post("shop/activeItem", {
      "id": item.id,
      "active": activeState ? 1 : 0,
    });
    if (res.isNotEmpty) {
      for (var i = 0; i < backPackItems.length; i++) {
        if (backPackItems[i].type == item.type) {
          if (backPackItems[i].id == item.id) {
            backPackItems[i].active = backPackItems[i].active == 1 ? 0 : 1;
          } else if (backPackItems[i].active == 1) {
            backPackItems[i].active = 0;
          }
        }
      }
      backPackItems.refresh();
    }
  }
}
