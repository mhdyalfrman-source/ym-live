import 'package:tom_chat/features/chat/models/reaction_model.dart';
import 'package:tom_chat/features/chat/models/room_chat_model.dart';
import 'package:tom_chat/features/store/models/store_item_model.dart';
import 'package:tom_chat/models/user/user_model.dart';

class ChatModel {
  int? id;
  int? chatId;
  int? uid;
  String? chatText;
  ChatType chatType;

  String? imageUrl;
  String? videoUrl;
  String? voiceUrl;

  bool? isForwarded;
  bool? isViewOnce;
  MyDateTime? viewedAt;

  ChatState? chatState;
  StateEnum? targetState;

  UserModel? user;
  MyDateTime? createdAt;
  MyDateTime? updatedAt;

  StoreItemModel? card;
  List<ReactionModel>? reactions;

  ChatModel? replyMessage;

  ChatModel({
    this.id,
    this.chatId,
    this.uid,
    this.chatText,
    this.imageUrl,
    this.videoUrl,
    this.voiceUrl,
    this.isForwarded,
    this.isViewOnce,
    this.viewedAt,
    this.chatState,
    this.targetState,
    this.user,
    this.createdAt,
    this.updatedAt,
    this.card,
    this.reactions,
    this.replyMessage,
    this.chatType = ChatType.TEXT,
  });

  ChatModel copyWith({ChatModel? chat}) {
    return ChatModel(
      id: chat!.id ?? id,
      chatId: chat.chatId ?? chatId,
      uid: chat.uid ?? uid,
      chatText: chat.chatText ?? chatText,
      imageUrl: chat.imageUrl ?? imageUrl,
      videoUrl: chat.videoUrl ?? videoUrl,
      voiceUrl: chat.voiceUrl ?? voiceUrl,
      isForwarded: chat.isForwarded ?? isForwarded,
      isViewOnce: chat.isViewOnce ?? isViewOnce,
      viewedAt: chat.viewedAt ?? viewedAt,
      chatState: chat.chatState ?? chatState,
      targetState: chat.targetState ?? targetState,
      user: chat.user?.copyWith(),
      createdAt: chat.createdAt ?? createdAt,
      updatedAt: chat.updatedAt ?? updatedAt,
      reactions: chat.reactions ?? reactions,
      replyMessage: chat.replyMessage ?? replyMessage,
      card: chat.card ?? card,
      chatType: chat.chatType,
    );
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map['id'],
      chatId: map['chat_id'],
      uid: map['uid'],
      chatText: map['content'],
      imageUrl: map['image_url'],
      videoUrl: map['video_url'],
      voiceUrl: map['voice_url'],
      isForwarded: map['is_forwarded'] == 1,
      isViewOnce: map['is_view_once'] == 1,
      viewedAt: map['viewed_at'] != null
          ? MyDateTime.parse(map['viewed_at'])
          : null,
      chatState: map['target_state'] != null
          ? ChatState.values.firstWhere(
              (v) => v.value == map['target_state'],
              orElse: () => ChatState.sent,
            )
          : ChatState.sent,
      reactions: map['reactions'] != null
          ? parseReactions(map['reactions'])
          : null,
      replyMessage: map['reply_to'] != null
          ? ChatModel.fromMap(map['reply_to'])
          : null,
      targetState: StateEnum.values.firstWhere(
        (v) => v.value == map['target_state'],
        orElse: () => StateEnum.pending,
      ),
      user: map["user"] != null ? UserModel.fromMap(map["user"]) : null,
      createdAt: map["created_at"] != null
          ? MyDateTime.parse(map["created_at"])
          : null,
      updatedAt: map["updated_at"] != null
          ? MyDateTime.parse(map["updated_at"])
          : null,
      card: map["card"] != null ? StoreItemModel.fromMap(map["card"]) : null,
      chatType: (map["image_url"] ?? "") != "" ? ChatType.IMAGE : ChatType.TEXT,
    );
  }

  static List<ChatModel> fromList(List<dynamic> list) {
    return list.map((e) => ChatModel.fromMap(e)).toList();
  }

  // Add this helper method to parse reactions
  static List<ReactionModel>? parseReactions(dynamic reactionsData) {
    if (reactionsData == null) return null;

    // Handle empty list case
    if (reactionsData is List && reactionsData.isEmpty) {
      return [];
    }

    // Handle list case (if API returns list format)
    if (reactionsData is List) {
      return reactionsData
          .map((x) => ReactionModel.fromJson(x as Map<String, dynamic>))
          .toList();
    }

    // Handle map case (current API format: {1: {uid: 15, emoji: ❤️}})
    if (reactionsData is Map) {
      return reactionsData.values
          .map((x) => ReactionModel.fromJson(x as Map<String, dynamic>))
          .toList();
    }

    return null;
  }
}

enum ChatState {
  waiting(0),
  sent(1),
  received(2);

  final int value;
  const ChatState(this.value);
}

enum ChatType { TEXT, IMAGE, AUDIO }
