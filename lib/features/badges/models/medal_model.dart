import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/models/user/user_model.dart';

class MedalModel {
  int id;
  String name;
  String icon;
  int? time;
  int target;
  int targetType;
  int targetId;
  int type;
  int sort;
  int lvl;
  int levelId;
  DateTime? createdAt;
  int progress;
  DateTime? expiresAt;
  bool isAchieved;
  bool isUsed;
  List<MedalModel> levels;

  MedalModel({
    required this.id,
    required this.name,
    required this.icon,
    this.time,
    required this.target,
    required this.targetType,
    required this.targetId,
    required this.type,
    required this.sort,
    required this.lvl,
    required this.levelId,
    this.createdAt,
    required this.progress,
    this.expiresAt,
    required this.isAchieved,
    required this.isUsed,
    this.levels = const [],
  });

  factory MedalModel.fromMap(Map<String, dynamic> map) {
    return MedalModel(
      id: MyMath.toInt(map['id']),
      name: map['name'] ?? "",
      icon: map['icon'] ?? "",
      time: MyMath.toInt(map['time']),
      target: MyMath.toInt(map['target']),
      targetType: map['target_type'],
      targetId: MyMath.toInt(map['target_id']),
      type: MyMath.toInt(map['type']),
      sort: MyMath.toInt(map['sort']),
      lvl: MyMath.toInt(map['lvl']),
      levelId: MyMath.toInt(map['level_id']),
      createdAt:
          map['created_at'] != null &&
              map['created_at'] != "0000-00-00 00:00:00"
          ? DateTime.tryParse(map['created_at'])
          : null,
      progress: MyMath.toInt(map['progress']),
      expiresAt: map['expires_at'] != null
          ? DateTime.tryParse(map['expires_at'])
          : null,
      isAchieved: map['is_achieved'] == StateEnum.active.value,
      isUsed: map['is_used'] == StateEnum.active.value,
      levels: map['levels'] != null ? MedalModel.fromList(map['levels']) : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'time': time,
      'target': target,
      'target_type': targetType,
      'target_id': targetId,
      'type': type,
      'sort': sort,
      'lvl': lvl,
      'level_id': levelId,
      'created_at': createdAt?.toIso8601String(),
      'progress': progress,
      'expires_at': expiresAt?.toIso8601String(),
      'is_achieved': isAchieved ? 1 : 0,
      'is_used': isUsed ? 1 : 0,
      'levels': levels,
    };
  }

  static List<MedalModel> fromList(List<dynamic> list) {
    return list.map((e) => MedalModel.fromMap(e)).toList();
  }
}
