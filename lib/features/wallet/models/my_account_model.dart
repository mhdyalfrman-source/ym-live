import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/features/chat/models/room_chat_model.dart';

class MyAccountModel {
  int id;
  int uid;
  int type;
  String accountBank;
  String name;
  String account;
  MyDateTime createAt;
  MyAccountModel({
    required this.id,
    required this.uid,
    required this.type,
    required this.accountBank,
    required this.name,
    required this.account,
    required this.createAt,
  });

  factory MyAccountModel.fromMap(Map<String, dynamic> map) {
    return MyAccountModel(
      id: MyMath.toInt(map['id']),
      uid: MyMath.toInt(map['uid']),
      type: MyMath.toInt(map['type']),
      accountBank: map['account_bank'] ?? "",
      name: map['name'] ?? "",
      account: map['account'] ?? "",
      createAt: map['create_at'] != null
          ? MyDateTime.parse(map['create_at'])
          : MyDateTime.now(),
    );
  }

  static List<MyAccountModel> fromList(List<dynamic> list) {
    return list.map((e) => MyAccountModel.fromMap(e)).toList();
  }
}
