import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/features/chat/models/room_chat_model.dart';
import 'package:tom_chat/models/user/user_model.dart';

class CommentModel {
  int id;
  int uid;
  int touid;
  int postId;
  int likeCount;
  String text;
  int state;
  bool isLike;
  MyDateTime createdAt;
  MyDateTime? updatedAt;
  UserModel user;

  CommentModel({
    required this.id,
    required this.uid,
    required this.touid,
    required this.postId,
    required this.likeCount,
    required this.text,
    required this.state,
    required this.createdAt,
    this.updatedAt,
    required this.user,
    required this.isLike,
  });

  factory CommentModel.fromMap(Map<String, dynamic> json) {
    return CommentModel(
      id: MyMath.toInt(json["id"]),
      uid: MyMath.toInt(json["uid"]),
      touid: MyMath.toInt(json["touid"]),
      postId: MyMath.toInt(json["post_id"]),
      likeCount: MyMath.toInt(json["like_count"]),
      text: json["content"] ?? "",
      state: MyMath.toInt(json["state"]),
      isLike: json["like"] == 1,
      createdAt: json['created_at'] != null
          ? MyDateTime.parse(json['created_at'])
          : MyDateTime.now(),
      updatedAt: json['updated_at'] != null
          ? MyDateTime.parse(json['updated_at'])
          : null,
      user: json["user"] != null
          ? UserModel.fromMap(json["user"])
          : UserModel(userId: 0, name: "none"),
    );
  }

  static List<CommentModel> fromList(List<dynamic> list) {
    return list.map((e) => CommentModel.fromMap(e)).toList();
  }
}
