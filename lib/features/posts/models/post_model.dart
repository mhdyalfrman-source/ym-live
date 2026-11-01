import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/features/chat/models/room_chat_model.dart';
import 'package:tom_chat/models/user/user_model.dart';

class PostModel {
  int id;
  int uid;
  String title;
  String url;
  int likeCount;
  int commentCount;
  bool isLike;
  int state;
  String description;
  MyDateTime? updatedAt;
  MyDateTime createdAt;
  UserModel user;

  PostModel({
    required this.id,
    required this.uid,
    required this.title,
    required this.isLike,
    required this.url,
    required this.likeCount,
    required this.commentCount,
    required this.state,
    required this.description,
    required this.createdAt,
    this.updatedAt,
    required this.user,
  });

  factory PostModel.fromMap(Map<String, dynamic> json) {
    return PostModel(
      id: json["id"] ?? 0,
      uid: MyMath.toInt(json["uid"]),
      title: json["title"] ?? "",
      url: json["url"] ?? "",
      likeCount: MyMath.toInt(json["like_count"]),
      commentCount: MyMath.toInt(json["comment_count"]),
      isLike: json["like"] == 1,
      state: MyMath.toInt(json["state"]),
      description: json["description"] ?? "",
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

  static List<PostModel> fromList(List<dynamic> list) {
    return list.map((e) => PostModel.fromMap(e)).toList();
  }
}
