import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/models/helpers/image_model.dart';
import 'package:tom_chat/models/user/user_model.dart';

class AgencyModel {
  int id;
  int uid;
  String? name;
  ImageModel? icon;
  String? notice;
  String? description;
  double? percentage;
  StateEnum? state;
  String? updatedAt;
  String? createAt;
  ImageModel? badge;
  UserModel? user;
  RoleEnum? rule;

  AgencyModel({
    required this.id,
    required this.uid,
    this.name,
    this.icon,
    this.notice,
    this.description,
    this.state,
    this.percentage,
    this.updatedAt,
    this.createAt,
    this.badge,
    this.user,
    this.rule,
  });

  factory AgencyModel.fromMap(Map<String, dynamic> json) {
    return AgencyModel(
      id: MyMath.toInt(json["id"]),
      uid: MyMath.toInt(json["uid"]),
      percentage: MyMath.toDouble(json["percentage"]),
      name: json["name"],
      icon: json["icon"] != null ? ImageModel.fromMap(json["icon"]) : null,
      notice: json["notice"],
      description: json["description"],
      state: StateEnum.values.firstWhere(
        (v) => v.value == json["state"],
        orElse: () => StateEnum.active,
      ),
      rule: RoleEnum.values.firstWhere(
        (v) => v.value == json["rule"],
        orElse: () => RoleEnum.guest,
      ),
      updatedAt: json["updated_at"],
      createAt: json["create_at"],
      badge: json["badge"] != null ? ImageModel.fromMap(json["badge"]) : null,
      user: json["user"] != null ? UserModel.fromMap(json["user"]) : null,
    );
  }

  static List<AgencyModel> fromList(List<dynamic> list) {
    return list.map((e) => AgencyModel.fromMap(e)).toList();
  }
}
