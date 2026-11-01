import 'package:tom_chat/core/utils/my_math.dart';

class RoomBackgroundModel {
  int? id;
  String? name;
  String? url;
  int? type;
  RoomBackgroundModel({this.id, this.name, this.url, this.type});

  RoomBackgroundModel copyWith({
    int? id,
    String? name,
    String? url,
    int? type,
  }) {
    return RoomBackgroundModel(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      type: type ?? this.type,
    );
  }

  factory RoomBackgroundModel.fromMap(Map<String, dynamic> map) {
    return RoomBackgroundModel(
      id: MyMath.toInt(map['id']),
      name: (map['name'] ?? "").toString(),
      url: (map['network'] ?? "").toString(),
      type: MyMath.toInt(map['type']),
    );
  }

  static List<RoomBackgroundModel> fromList(List<dynamic> list) {
    return list.map((e) => RoomBackgroundModel.fromMap(e)).toList();
  }
}
