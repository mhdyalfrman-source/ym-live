import 'package:tom_chat/features/chat/models/chat_model.dart';
import 'package:tom_chat/models/user/user_model.dart';

class RoomChatModel {
  int? id;
  int? ownerUid;
  String? title;
  int? type; // group? private?
  int? state;
  int? targetId;
  String? img;
  bool? autoDelete;
  bool? isPinned;

  List<ChatModel>? chats;

  UserModel? user; // fromUser
  ChatModel? lastMessage;
  MyDateTime? lastMessageDate;

  int unreadMessage;

  bool? isOpened;
  int? page;
  bool? hasMoreData;

  RoomChatModel({
    this.id,
    this.ownerUid,
    this.title,
    this.type,
    this.state,
    this.targetId,
    this.img,
    this.autoDelete,
    this.isPinned,
    this.chats,
    this.user,
    this.lastMessage,
    this.lastMessageDate,
    this.unreadMessage = 0,
    this.isOpened = false,
    this.page = 1,
    this.hasMoreData = true,
  });

  factory RoomChatModel.fromMap(Map<String, dynamic> map) {
    final ChatModel? msg = map["last_message"] != null
        ? ChatModel.fromMap(map["last_message"])
        : null;

    return RoomChatModel(
      id: map["id"],
      ownerUid: map["owner_uid"],
      title: map["title"],
      type: map["type"],
      state: map["state"],
      targetId: map["target_id"],
      img: map["img"],
      autoDelete: map["auto_delete"] == 1,
      isPinned: map["pin"] == 1,

      lastMessage: msg,

      lastMessageDate: msg?.createdAt,

      user: map["fromUser"] != null ? UserModel.fromMap(map["fromUser"]) : null,

      unreadMessage: map["unread_count"] ?? 0,

      chats: [],
      isOpened: false,
      hasMoreData: true,
      page: 1,
    );
  }

  static List<RoomChatModel> fromList(List<dynamic> list) {
    return list.map((e) => RoomChatModel.fromMap(e)).toList();
  }

  String? get displayTitle {
    return title ?? user?.name;
  }
}

class MyDateTime {
  final DateTime _utcDateTime;

  MyDateTime(DateTime dateTime) : _utcDateTime = dateTime.toUtc();

  /// الآن يأخذ أي string بـ UTC ويخزّنه
  factory MyDateTime.parse(String value) {
    return MyDateTime(DateTime.parse(value).toUtc());
  }

  /// الآن يأخذ milliseconds من UTC
  factory MyDateTime.fromMillisecondsSinceEpoch(int ms) {
    return MyDateTime(DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true));
  }

  /// تاريخ الآن بنسخة UTC
  factory MyDateTime.now() {
    return MyDateTime(DateTime.now().toUtc());
  }

  /// ترجمة إلى DateTime الأصلي (UTC)
  DateTime toUtcDateTime() => _utcDateTime;

  /// إرجاع التاريخ بالتوقيت المحلي
  DateTime toLocalDateTime() => _utcDateTime.toLocal();

  /// طباعة بشكل Local
  @override
  String toString() {
    return _utcDateTime.toLocal().toString();
  }

  /// تسهيل المقارنات
  int compareTo(MyDateTime other) => _utcDateTime.compareTo(other._utcDateTime);

  /// Timestamp UTC
  int get millisecondsSinceEpoch =>
      _utcDateTime.toLocal().millisecondsSinceEpoch;

  /// تنسيق مخصص مثل "2025-11-23 12:55"
  String format([String pattern = "yyyy-MM-dd HH:mm"]) {
    final dt = _utcDateTime.toLocal();
    return "${dt.year}-${_two(dt.month)}-${_two(dt.day)} "
        "${_two(dt.hour)}:${_two(dt.minute)}";
  }

  String _two(int n) => n < 10 ? "0$n" : "$n";
}
