import 'package:tom_chat/core/utils/my_math.dart';

class GameModel {
  final int gid;
  final String name;
  final String icon;
  final String url;
  final int type;
  Map<String, dynamic> config;

  GameModel({
    required this.gid,
    required this.name,
    required this.icon,
    required this.url,
    required this.type,
    this.config = const {},
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      gid: MyMath.toInt(json['gid'] ?? json['id']),
      name: json['name'] ?? '',
      icon: json['icon']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      type: MyMath.toInt(json['type']),
      config: json['config'] is Map ? json["config"] : {},
    );
  }

  static List<GameModel> listFromResponse(Map<String, dynamic> response) {
    final rows = response['games'] ?? response['list'];
    return rows is List
        ? rows
              .whereType<Map>()
              .map((row) => GameModel.fromJson(Map<String, dynamic>.from(row)))
              .toList()
        : [];
  }

  Map<String, dynamic> toJson() {
    return {'gid': gid, 'name': name, 'icon': icon, 'url': url};
  }
}
