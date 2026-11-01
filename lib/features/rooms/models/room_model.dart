import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/features/rooms/models/red_box.dart';
import 'package:tom_chat/features/rooms/models/rocket_model.dart';
import 'package:tom_chat/features/rooms/models/seat_model.dart';
import 'package:tom_chat/models/helpers/image_model.dart';
import 'package:tom_chat/models/user/user_model.dart';

class RoomModel {
  int id;
  int uid;
  String title;
  int type;
  int state;
  ImageModel? bg;
  ImageModel? icon;
  String? createdAt;
  String? userSwToken;
  String? agoraChannel;
  int? agoraUid;
  int? banned;
  UserModel? owner;
  int? start;
  int? ts;
  String? country;
  int usersCount;
  int coinNumber;
  int points;
  List<SeatModel> seats;
  LevelModel? roomLevel;
  RoleEnum myRule;
  List<RedBoxModel> redBoxes;
  int password;
  int carizma;
  RocketLevel? rocket;

  RoomModel({
    this.id = 0,
    this.uid = 0,
    this.title = "",
    this.type = 0,
    this.state = 0,
    this.bg,
    this.icon,
    this.createdAt,
    this.banned,
    this.owner,
    this.start,
    this.ts,
    this.roomLevel,
    this.userSwToken,
    this.agoraChannel,
    this.agoraUid,
    this.country,
    this.redBoxes = const [],
    this.myRule = RoleEnum.user,
    this.usersCount = 0,
    this.points = 0,
    this.coinNumber = 0,
    this.password = 0,
    this.carizma = 0,
    this.seats = const [],
    this.rocket,
  });

  factory RoomModel.fromMap(Map<String, dynamic> json) {
    // if (json['seats'] != null && json['seats'] is Map) {
    //   json['seats'] = (json['seats'] as Map).values.toList();
    // }
    return RoomModel(
      id: MyMath.toInt(json['id']),
      uid: MyMath.toInt(json['uid']),
      title: json['title'] ?? "",
      type: MyMath.toInt(json['type']),
      state: MyMath.toInt(json['state']),
      bg: ImageModel.fromMap(json['bg']),
      icon: ImageModel.fromMap(json['icon']),
      createdAt: json['created_at'],
      banned: json['banned'],
      owner: json['owner'] != null && json['owner'] is Map
          ? UserModel.fromMap(json['owner'])
          : null,
      roomLevel: json['level_info'] != null
          ? LevelModel.fromMap(json['level_info'])
          : null,
      start: MyMath.toInt(json['start']),
      ts: MyMath.toInt(json['ts']),
      country: json['owner'] != null && json['owner'] is Map
          ? (json['owner']?['country'] ?? "YE")
          : json['country']??"YE",
      usersCount: MyMath.toInt(json['usersCount']),
      coinNumber: MyMath.toInt(json['coin_number']),
      password: MyMath.toInt(json['isPassword']),
      points: MyMath.toInt(json['total_points']),
      carizma: MyMath.toInt(json['carizma']),
      seats: (json['seats'] is List)
          ? List<SeatModel>.from(
              (json['seats'] as List).map((e) => SeatModel.fromJson(e)),
            )
          : [],
      rocket: (json['rocket_level'] is Map)
          ? RocketLevel.fromMap(json['rocket_level'])
          : null,
      userSwToken: json['user_sw_token']?.toString() ?? '',
      agoraChannel: json['agora_channel']?.toString() ?? '',
      agoraUid: json['agora_uid'] != null
          ? MyMath.toInt(json['agora_uid'])
          : null,
      myRule: RoleEnum.values.firstWhere(
        (v) => v.value == MyMath.toInt(json['my_rule']),
        orElse: () => RoleEnum.user,
      ),
      redBoxes: json['red_box'] != null
          ? List<RedBoxModel>.from(
              json['red_box'].map((e) => RedBoxModel.fromJson(e)),
            )
          : [],
    );
  }
  List<SeatModel> get getSeats =>
      seats.where((s) => s.user != null).toList().skip(1).toList();

  static List<RoomModel> fromList(List<dynamic> list) {
    return list.map((e) => RoomModel.fromMap(e)).toList();
  }
}
