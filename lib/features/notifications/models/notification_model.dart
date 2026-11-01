import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/features/chat/models/room_chat_model.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';

class NotificationModel {
  final int id;
  final int senderId;
  final int receiverId;
  final int targetId;
  final String? targetType;
  final String title;
  final String body;
  final String? image;
  final Map<String, dynamic> data;
  final NotificationType type;
  final bool isRead;
  final MyDateTime? created;
  final UserModel? user;

  NotificationModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.targetId,
    required this.targetType,
    required this.title,
    required this.body,
    required this.image,
    required this.data,
    required this.type,
    required this.isRead,
    required this.created,
    required this.user,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> json) {
    final rawData = json['data'] ?? json['txt'];
    return NotificationModel(
      id: MyMath.toInt(json['id']),
      senderId: MyMath.toInt(json['sender_uid'] ?? json['sender_id']),
      receiverId: MyMath.toInt(
        json['receiver_uid'] ?? json['receiver_id'] ?? json['uid'],
      ),
      targetId: MyMath.toInt(
        json['target_id'] ??
            json['video_id'] ??
            json['room_id'] ??
            json['live_streaming_id'],
      ),
      targetType: json['target_type']?.toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? json['string'] ?? '').toString(),
      image: json['image']?.toString(),
      data: rawData is Map
          ? Map<String, dynamic>.from(rawData)
          : <String, dynamic>{},
      type: NotificationTypeX.fromBackend(json['type'] ?? json['type_str']),
      isRead: MyMath.toInt(json['read']) == 1,
      created: MyDateTime.parse(json['created_at']),
      user: json['user'] != null ? UserModel.fromMap(json['user']) : null,
    );
  }

  static List<NotificationModel> fromList(List<dynamic> list) {
    return list
        .whereType<Map>()
        .map((e) => NotificationModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  String displayTitle(BuildContext context) {
    if (title.isNotEmpty) return title;
    return type.localized(context, this);
  }
}

enum NotificationType {
  liveStarted('live_started', 7),
  newFollower('new_follower', 8),
  postInteraction('post_interaction', 4),
  storeItemOrVip('store_item_or_vip', 12),
  privateMessage('private_message', 13),
  system('system', 13),

  videos_like('videos_like', 1),
  videos_post('videos_post', 2),
  videos_rePost('videos_rePost', 3),
  comments_add('comments_add', 4),
  comments_like('comments_like', 5),
  comments_replay('comments_replay', 6),
  lives_start('lives_start', 7),
  profile_follow('profile_follow', 8),
  stories('stories', 9),
  posts('posts', 10),
  mentions('mentions', 11),
  gifts('gifts', 12);

  final String backendValue;
  final int value;
  const NotificationType(this.backendValue, this.value);
}

extension NotificationTypeX on NotificationType {
  static NotificationType fromBackend(dynamic value) {
    final raw = value?.toString() ?? '';
    return NotificationType.values.firstWhereOrNull(
          (type) => type.backendValue == raw || type.name == raw,
        ) ??
        NotificationType.system;
  }

  String get apiValue => backendValue;

  String localized(
    BuildContext context,
    NotificationModel? notification, [
    String defaultTitle = '',
  ]) {
    final appText = context.l10n;
    final user = notification?.user?.name.toString() ?? 'System';
    if (notification != null && notification.body.isNotEmpty) {
      return notification.body;
    }
    switch (this) {
      case NotificationType.liveStarted:
      case NotificationType.lives_start:
        return appText.notificationLiveStart(user);
      case NotificationType.newFollower:
      case NotificationType.profile_follow:
        return appText.notificationPersonFollow(user);
      case NotificationType.postInteraction:
      case NotificationType.comments_add:
      case NotificationType.comments_like:
      case NotificationType.comments_replay:
      case NotificationType.videos_like:
        return appText.notificationPost(user);
      case NotificationType.storeItemOrVip:
      case NotificationType.gifts:
        return appText.notificationGift(user);
      case NotificationType.privateMessage:
        return appText.message;
      case NotificationType.videos_post:
        return appText.notificationVideoPost(user);
      case NotificationType.videos_rePost:
        return appText.notificationVideoRepost(user);
      case NotificationType.stories:
        return appText.notificationStory(user);
      case NotificationType.posts:
        return appText.notificationPost(user);
      case NotificationType.mentions:
        return appText.notificationMention(user);
      case NotificationType.system:
        return appText.notificationSystem(
          defaultTitle.isNotEmpty ? defaultTitle : user,
        );
    }
  }
}
