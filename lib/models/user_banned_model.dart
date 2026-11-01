import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/features/chat/models/room_chat_model.dart';

class UserBannedModel {
  int? uid;
  int? banType;
  String? comments;
  MyDateTime? expiredTime;
  UserBannedModel({this.uid, this.banType, this.comments, this.expiredTime});

  factory UserBannedModel.fromMap(Map<String, dynamic> map) {
    return UserBannedModel(
      uid: MyMath.toInt(map['uid']),
      banType: MyMath.toInt(map['ban_type']),
      comments: map['comments'],
      expiredTime: MyDateTime.parse(map['expired_time']),
    );
  }
}
