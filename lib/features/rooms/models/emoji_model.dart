import 'package:tom_chat/core/utils/my_math.dart';

class EmojiModel {
  int id;
  String name;
  String icon;
  int type;
  int vip;
  EmojiModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    required this.vip,
  });

  factory EmojiModel.fromMap(Map<String, dynamic> map) {
    return EmojiModel(
      id: MyMath.toInt(map['id']),
      name: map['name'] ?? "",
      icon: map['icon'] ?? "",
      type: MyMath.toInt(map['type']),
      vip: MyMath.toInt(map['vip']),
    );
  }
}
