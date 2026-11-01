import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/features/recharge_agency/models/recharge_agency_model.dart';
import 'package:tom_chat/features/chat/models/room_chat_model.dart';
import 'package:tom_chat/models/user/user_model.dart';

class WithdrawOrderModel {
  int id;
  int uid;
  double money;
  int votes;
  StateEnum status;
  int type;
  String accountBank;
  String account;
  int agencyId;
  String name;
  MyDateTime createdAt;
  RechargeAgencyModel? agency;
  WithdrawOrderModel({
    required this.id,
    required this.uid,
    required this.money,
    required this.votes,
    required this.status,
    required this.type,
    required this.accountBank,
    required this.account,
    required this.agencyId,
    required this.name,
    required this.createdAt,
    this.agency,
  });

  factory WithdrawOrderModel.fromMap(Map<String, dynamic> map) {
    return WithdrawOrderModel(
      id: MyMath.toInt(map['id']),
      uid: MyMath.toInt(map['uid']),
      money: MyMath.toDouble(map['money']),
      votes: MyMath.toInt(map['votes']),
      status: StateEnum.values.firstWhere(
        (v) => v.value == map['status'],
        orElse: () => StateEnum.pending,
      ),
      type: MyMath.toInt(map['type']),
      accountBank: map['account_bank'] ?? "",
      account: map['account'] ?? "",
      agencyId: MyMath.toInt(map['recharge_agency_id']),
      name: map['name'] ?? "",
      createdAt: map['created_at'] != null
          ? MyDateTime.parse(map['created_at'])
          : MyDateTime.now(),
      agency: map['recharge_agency'] != null
          ? RechargeAgencyModel.fromMap(map['recharge_agency'])
          : null,
    );
  }

  static List<WithdrawOrderModel> fromList(List<dynamic> list) {
    return list.map((e) => WithdrawOrderModel.fromMap(e)).toList();
  }
}
