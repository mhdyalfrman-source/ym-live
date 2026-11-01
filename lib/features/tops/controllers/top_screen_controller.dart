import 'package:get/get.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/features/rooms/models/room_model.dart';
import 'package:tom_chat/features/tops/models/cp_model.dart';
import 'package:tom_chat/models/user/user_model.dart';

class TopScreenController extends GetxController {
  RxList<UserModel> daylyUsers = <UserModel>[].obs;
  int daylyPage = 1;
  RxBool hasMoreDaylyUsers = true.obs;

  RxList<UserModel> weaklyUsers = <UserModel>[].obs;
  int weaklyPage = 1;
  RxBool hasMoreWeaklyUsers = true.obs;

  RxList<UserModel> monthlyUsers = <UserModel>[].obs;
  int monthlyPage = 1;
  RxBool hasMoreMonthlyUsers = true.obs;

  RxList<UserModel> dayly2Users = <UserModel>[].obs;
  int dayly2Page = 1;
  RxBool hasMoreDayly2Users = true.obs;

  RxList<UserModel> weakly2Users = <UserModel>[].obs;
  int weakly2Page = 1;
  RxBool hasMoreWeakly2Users = true.obs;

  RxList<UserModel> monthly2Users = <UserModel>[].obs;
  int monthly2Page = 1;
  RxBool hasMoreMonthly2Users = true.obs;

  RxList<RoomModel> dayly3Users = <RoomModel>[].obs;
  int dayly3Page = 1;
  RxBool hasMoreDayly3Users = true.obs;

  RxList<RoomModel> weakly3Users = <RoomModel>[].obs;
  int weakly3Page = 1;
  RxBool hasMoreWeakly3Users = true.obs;

  RxList<RoomModel> monthly3Users = <RoomModel>[].obs;
  int monthly3Page = 1;
  RxBool hasMoreMonthly3Users = true.obs;

  int index = 0;
  RxInt typeIndex = 0.obs;

  RxBool updating = false.obs;

  // CP Variables
  RxList<CpModel> daylyCpRanks = <CpModel>[].obs;
  int daylyCpPage = 1;
  RxBool hasMoreDaylyCp = true.obs;

  RxList<CpModel> weeklyCpRanks = <CpModel>[].obs;
  int weeklyCpPage = 1;
  RxBool hasMoreWeeklyCp = true.obs;

  RxList<CpModel> monthlyCpRanks = <CpModel>[].obs;
  int monthlyCpPage = 1;
  RxBool hasMoreMonthlyCp = true.obs;

  Future<void> getTops(void Function(void Function() fn) setState) async {
    int p = 1;
    if (typeIndex.value == 0) {
      if (index == 0) {
        p = daylyPage;
        setState(() {});
        if (!hasMoreDaylyUsers.value) return;
      } else if (index == 1) {
        p = weaklyPage;
        setState(() {});
        if (!hasMoreWeaklyUsers.value) return;
      } else if (index == 2) {
        p = monthlyPage;
        setState(() {});
        if (!hasMoreMonthlyUsers.value) return;
      }
    } else if (typeIndex.value == 1) {
      if (index == 0) {
        p = dayly2Page;
        setState(() {});
        if (!hasMoreDayly2Users.value) return;
      } else if (index == 1) {
        p = weakly2Page;
        setState(() {});
        if (!hasMoreWeakly2Users.value) return;
      } else if (index == 2) {
        p = monthly2Page;
        setState(() {});
        if (!hasMoreMonthly2Users.value) return;
      }
    } else if (typeIndex.value == 2) {
      if (index == 0) {
        p = dayly3Page;
        setState(() {});
        if (!hasMoreDayly3Users.value) return;
      } else if (index == 1) {
        p = weakly3Page;
        setState(() {});
        if (!hasMoreWeakly3Users.value) return;
      } else if (index == 2) {
        p = monthly3Page;
        setState(() {});
        if (!hasMoreMonthly3Users.value) return;
      }
    }
    var res = await CallServerAPI.post("live/ranking", {
      "rid": 0,
      "limit": limitCount,
      "p": p,
      "time": index == 0
          ? "daily"
          : index == 1
          ? "week"
          : "month",
      "type": typeIndex.value == 0
          ? "gifter"
          : typeIndex.value == 1
          ? "anchor"
          : "rooms",
    });
    if (res.isNotEmpty && res["list"] != null) {
      List<UserModel> userList = UserModel.fromList(res["list"]);
      if (typeIndex.value == 0) {
        if (index == 0) {
          daylyUsers.addAll(userList.obs);
          daylyUsers.refresh();
          daylyPage++;
          hasMoreDaylyUsers.value = userList.length == limitCount;
        } else if (index == 1) {
          weaklyUsers.addAll(userList.obs);
          weaklyUsers.refresh();
          weaklyPage++;
          hasMoreWeaklyUsers.value = userList.length == limitCount;
        } else if (index == 2) {
          monthlyUsers.addAll(userList.obs);
          monthlyUsers.refresh();
          monthlyPage++;
          hasMoreMonthlyUsers.value = userList.length == limitCount;
        }
      } else if (typeIndex.value == 1) {
        if (index == 0) {
          dayly2Users.addAll(userList.obs);
          dayly2Users.refresh();
          dayly2Page++;
          hasMoreDayly2Users.value = userList.length == limitCount;
        } else if (index == 1) {
          weakly2Users.addAll(userList.obs);
          weakly2Users.refresh();
          weakly2Page++;
          hasMoreWeakly2Users.value = userList.length == limitCount;
        } else if (index == 2) {
          monthly2Users.addAll(userList.obs);
          monthly2Users.refresh();
          monthly2Page++;
          hasMoreMonthly2Users.value = userList.length == limitCount;
        }
      } else if (typeIndex.value == 2) {
        List<RoomModel> userList = RoomModel.fromList(res["list"]);
        if (index == 0) {
          dayly3Users.addAll(userList.obs);
          dayly3Users.refresh();
          dayly3Page++;
          hasMoreDayly3Users.value = userList.length == limitCount;
        } else if (index == 1) {
          weakly3Users.addAll(userList.obs);
          weakly3Users.refresh();
          weakly3Page++;
          hasMoreWeakly3Users.value = userList.length == limitCount;
        } else if (index == 2) {
          monthly3Users.addAll(userList.obs);
          monthly3Users.refresh();
          monthly3Page++;
          hasMoreMonthly3Users.value = userList.length == limitCount;
        }
      }
      setState(() {});
    }
  }

  Future<void> getCPTops(void Function(void Function() fn) setState) async {
    int p = 1;
    if (typeIndex.value == 0) {
      if (index == 0) {
        p = daylyCpPage;
        setState(() {});
        if (!hasMoreDaylyCp.value) return;
      } else if (index == 1) {
        p = weeklyCpPage;
        setState(() {});
        if (!hasMoreWeeklyCp.value) return;
      } else if (index == 2) {
        p = monthlyCpPage;
        setState(() {});
        if (!hasMoreMonthlyCp.value) return;
      }
    }
    var res = await CallServerAPI.post("cp/ranking", {
      "limit": limitCount,
      "p": p,
      "time": index == 0
          ? "daily"
          : index == 1
          ? "week"
          : "month",
    });
    if (res.isNotEmpty && res["list"] != null) {
      List<CpModel> userList = CpModel.fromList(res["list"]);
      if (index == 0) {
        daylyCpRanks.addAll(userList.obs);
        daylyCpRanks.refresh();
        daylyCpPage++;
        hasMoreDaylyCp.value = userList.length == limitCount;
      } else if (index == 1) {
        weeklyCpRanks.addAll(userList.obs);
        weeklyCpRanks.refresh();
        weeklyCpPage++;
        hasMoreWeeklyCp.value = userList.length == limitCount;
      } else if (index == 2) {
        monthlyCpRanks.addAll(userList.obs);
        monthlyCpRanks.refresh();
        monthlyCpPage++;
        hasMoreMonthlyCp.value = userList.length == limitCount;
      }
    }
  }
}
