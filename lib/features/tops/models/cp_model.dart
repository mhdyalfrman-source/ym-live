import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/models/user/user_model.dart';

class CpModel {
  UserModel user;
  UserModel toUser;
  int rank;
  int coins;
  CpModel({
    required this.user,
    required this.toUser,
    required this.rank,
    required this.coins,
  });

  factory CpModel.fromMap(Map<String, dynamic> map) {
    return CpModel(
      user: UserModel.fromMap(map['user']),
      toUser: UserModel.fromMap(map['toUser']),
      rank: MyMath.toInt(map['rank']),
      coins: MyMath.toInt(map['total_points']),
    );
  }

  static List<CpModel> fromList(List<dynamic> list) {
    return list.map((e) => CpModel.fromMap(e)).toList();
  }
}
