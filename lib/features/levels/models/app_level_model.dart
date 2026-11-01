import 'package:tom_chat/core/utils/my_math.dart';

class AppLevelModel {
  int id;
  int levelNum;
  int type;
  String icon;
  int levelUp;
  AppLevelModel({
    required this.id,
    required this.levelNum,
    required this.type,
    required this.icon,
    required this.levelUp,
  });

  factory AppLevelModel.fromMap(Map<String, dynamic> map) {
    return AppLevelModel(
      id: MyMath.toInt(map['id']),
      levelNum: MyMath.toInt(map['lvl']),
      type: MyMath.toInt(map['type']),
      icon: map['icon'] ?? "",
      levelUp: MyMath.toInt(map['points']),
    );
  }

  static List<AppLevelModel> fromList(List<dynamic> list) {
    return list.map((e) => AppLevelModel.fromMap(e)).toList();
  }
}
