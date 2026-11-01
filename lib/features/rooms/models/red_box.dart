import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/features/chat/models/room_chat_model.dart';
import 'package:tom_chat/models/user/user_model.dart';

class RedBoxModel {
  int id;
  int type;
  int liveuid;
  int uid;
  int coins;
  int coinsRemaining;
  int? reward;
  int people;
  int peopleClaimedCount;
  int seconds;
  String expiredAt;
  String updatedAt;
  String createdAt;
  UserModel? user;
  int rid;

  RedBoxModel({
    required this.id,
    required this.type,
    required this.liveuid,
    required this.uid,
    required this.coins,
    this.reward,
    required this.coinsRemaining,
    required this.people,
    required this.peopleClaimedCount,
    required this.expiredAt,
    required this.updatedAt,
    required this.createdAt,
    required this.seconds,
    this.user,
    required this.rid,
  });

  factory RedBoxModel.fromJson(Map<String, dynamic> json) {
    return RedBoxModel(
      id: MyMath.toInt(json['id']),
      type: MyMath.toInt(json['type']),
      liveuid: MyMath.toInt(json['liveuid']),
      uid: MyMath.toInt(json['uid']),
      coins: MyMath.toInt(json['coins']),
      coinsRemaining: MyMath.toInt(json['coins_remaining']),
      people: MyMath.toInt(json['people']),
      reward: MyMath.toInt(json['reward']),
      peopleClaimedCount: MyMath.toInt(json['people_claimed_count']),
      expiredAt: json['expired_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      createdAt: MyDateTime.parse(json['created_at']).toString(),
      seconds: MyMath.toInt(json['remaining_seconds']),
      user: json['user'] != null ? UserModel.fromMap(json['user']) : null,
      rid: MyMath.toInt(json['rid']),
    );
  }
}
