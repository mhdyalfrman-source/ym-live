import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/features/agency/models/agency_model.dart';
import 'package:tom_chat/features/badges/models/medal_model.dart';
import 'package:tom_chat/features/rooms/models/gift_model.dart';
import 'package:tom_chat/features/rooms/models/room_model.dart';
import 'package:tom_chat/features/store/models/store_item_model.dart';
import 'package:tom_chat/features/vip/models/vip_model.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/helpers/image_model.dart';

class UserModel {
  int userId;
  int rechargeAgencyId;
  UserPosition pos;
  String name;
  int type;
  ImageModel? avatar;
  ImageModel? theme;
  ImageModel? entry;
  ImageModel? profileFrame;
  String? comment;
  String? birthday;
  LevelsModel? levels;
  VipModel? vip;
  List<MedalModel>? medals;
  List<String>? features;
  int coins;
  int diamond;
  int points;
  String? username;
  bool? banned;
  DateTime? createdAt;
  DateTime? visitAt;
  String? deviceId;
  String? userToken;
  String? fmcToken;
  String? appPrefix;
  String? email;
  String? country;
  int? state;
  // StateEnum? state;
  RoleEnum? role;
  String? chatBubble;
  int? followersCount;
  int? followingCount;
  int? visitersCount;
  int? viewCount;
  int? isOnline;
  PersonRelation relation;
  List<StoreItemModel>? frameList;
  List<StoreItemModel>? entryList;
  List<SentGiftModel>? giftsList;
  ImageModel? bg;
  SpecialId? specialId;
  UserModel? cpLover;
  List<UserModel> cpList;
  RoomModel? room;
  DateTime? cpLoveDate;
  AgencyModel? agency;
  int? onlineRid;
  String? webToken;

  UserModel({
    required this.userId,
    this.rechargeAgencyId = 0,
    required this.name,
    this.type = 1,
    this.pos = UserPosition.user,
    this.state,
    this.role,
    this.avatar,
    this.theme,
    this.bg,
    this.chatBubble,
    this.entry,
    this.profileFrame,
    this.comment,
    this.birthday,
    this.levels,
    this.vip,
    this.medals,
    this.features,
    this.country,
    this.coins = 0,
    this.diamond = 0,
    this.points = 0,
    this.username,
    this.banned,
    this.createdAt,
    this.visitAt,
    this.deviceId,
    this.userToken,
    this.appPrefix,
    this.fmcToken,
    this.email,
    this.followersCount,
    this.followingCount,
    this.visitersCount,
    this.viewCount,
    this.entryList,
    this.frameList,
    this.giftsList,
    this.isOnline,
    this.specialId,
    this.cpLover,
    this.room,
    this.cpLoveDate,
    this.agency,
    this.relation = PersonRelation.follow,
    this.onlineRid,
    this.webToken,
    this.cpList = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['uid'] ?? map['id'] ?? 0,
      rechargeAgencyId: MyMath.toInt(map['recharge_agency_id']),
      pos: UserPosition.values.firstWhere(
        (v) => v.value == map['pos'],
        orElse: () => UserPosition.user,
      ),
      name: map['name'] ?? '',
      type: MyMath.toInt(map['type'], defaultVal: 1),
      state: MyMath.toInt(map['state'], defaultVal: 1),
      // state: StateEnum.values.firstWhereOrNull((v)=>v.value == MyMath.toInt(map['state'])),
      role: RoleEnum.values.firstWhereOrNull(
        (v) =>
            v.value ==
            MyMath.toInt(map['rule'], defaultVal: RoleEnum.user.value),
      ),
      avatar: map['avatar'] != null ? ImageModel.fromMap(map['avatar']) : null,
      theme: map['theme'] != null ? ImageModel.fromMap(map['theme']) : null,
      entry: map['entry'] != null ? ImageModel.fromMap(map['entry']) : null,
      profileFrame: map['profile_frame'] != null
          ? ImageModel.fromMap(map['profile_frame'])
          : null,
      comment: map['comment'],
      country: map['country'],
      birthday: map['birthday'],
      levels: map['levels'] != null ? LevelsModel.fromMap(map['levels']) : null,
      vip: map['vip'] != null ? VipModel.fromMap(map['vip']) : null,
      specialId: map['special_id'] != null
          ? SpecialId.fromMap(map['special_id'])
          : null,
      medals: map['medals'] != null
          ? List<MedalModel>.from(
              map['medals'].map((x) => MedalModel.fromMap(x)),
            )
          : [],
      features: map['features'] != null
          ? List<String>.from(map['features'])
          : [],
      coins: MyMath.toInt(map['coins']),
      diamond: MyMath.toInt(map['diamond']),
      points: MyMath.toInt(map['total_points']),
      username: map['username'],
      banned: map['banned'] != null ? (map['banned'] == 1) : null,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'])
          : null,
      visitAt: map['visit_at'] != null
          ? DateTime.tryParse(map['visit_at'])
          : DateTime.now(),
      deviceId: map['deviceId'],
      userToken: map['token'],
      appPrefix: map['appPrefix'],
      fmcToken: map['fmcToken'],
      email: map['email'],
      chatBubble: map['chatBubble'],
      relation: PersonRelation.values.firstWhere(
        (v) => v.name == map['button'],
        orElse: () => PersonRelation.follow,
      ),
      followersCount: MyMath.toInt(map["followers_count"]),
      followingCount: MyMath.toInt(map["following_count"]),
      visitersCount: MyMath.toInt(map["visiters_count"]),
      viewCount: MyMath.toInt(map["view_count"]),
      isOnline: MyMath.toInt(map["is_online"]),
      onlineRid: MyMath.toInt(map["online_rid"]),
      entryList: map['entry_list'] != null
          ? List<StoreItemModel>.from(
              StoreItemModel.fromList(map['entry_list']),
            )
          : [],
      frameList: map['frame_list'] != null
          ? List<StoreItemModel>.from(
              StoreItemModel.fromList(map['frame_list']),
            )
          : [],
      giftsList: map['gifts_list'] != null
          ? List<SentGiftModel>.from(SentGiftModel.fromList(map['gifts_list']))
          : [],
      bg: map['bg'] != null ? ImageModel.fromMap(map['bg']) : null,
      cpLover: map["cp_love"] != null
          ? UserModel.fromMap(map["cp_love"])
          : null,
      cpList: map["cp_list"] != null && map["cp_list"] is List
          ? UserModel.fromList(map["cp_list"])
          : [],
      agency: map["guild"] != null && map["guild"] is Map
          ? AgencyModel.fromMap(map["guild"])
          : null,
      room: map["room"] != null && map["room"] is Map
          ? RoomModel.fromMap(map["room"])
          : null,
      cpLoveDate: map["cp_love_date"] != null
          ? DateTime.tryParse(map["cp_love_date"])
          : null,
      webToken: map["web_token"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': userId,
      'recharge_agency_id': rechargeAgencyId,
      'pos': pos.value,
      'name': name,
      'type': type,
      'state': state,
      'avatar': avatar?.toMap(),
      'theme': theme?.toMap(),
      'entry': entry?.toMap(),
      'profile_frame': profileFrame?.toMap(),
      'comment': comment,
      'birthday': birthday,
      'levels': levels?.toMap(),
      'medals': medals?.map((e) => e.toMap()).toList(),
      'features': features,
      'coins': coins,
      'total_points': points,
      'username': username,
      'banned': banned,
      'created_at': createdAt?.toIso8601String(),
      'token': userToken,
      'web_token': webToken,
      'appPrefix': appPrefix,
      'fmcToken': fmcToken,
      'email': email,
      'button': relation.name,
    };
  }

  String toJson() => json.encode(toMap());

  static List<UserModel> fromList(List<dynamic> list) {
    return list.map((e) => UserModel.fromMap(e)).toList();
  }

  bool get vipUntiBan {
    return (vip?.privileges.any(
              (p) =>
                  (p.type == PrivilegeType.antiKick ||
                  p.type == PrivilegeType.antiBlack),
            ) ??
            false) ||
        pos.value > UserPosition.superAdmin.value;
  }

  bool get vipShareItem {
    return vip?.privileges.any((p) => p.type == PrivilegeType.itemSharing) ??
        false;
  }

  bool get vipCustomGift {
    return vip?.privileges.any((p) => p.type == PrivilegeType.gift) ?? false;
  }

  bool get vipCustomEmoji {
    return vip?.privileges.any((p) => p.type == PrivilegeType.emoji) ?? false;
  }

  bool get vipSendImage {
    return vip?.privileges.any((p) => p.type == PrivilegeType.emoji) ?? false;
  }

  UserModel copyWith({
    int? userId,
    UserPosition? pos,
    String? name,
    int? type,
    int? state,
    // StateEnum? state,
    RoleEnum? role,
    int? rid,
    ImageModel? avatar,
    ImageModel? theme,
    ImageModel? entry,
    ImageModel? profileFrame,
    String? comment,
    String? birthday,
    LevelsModel? levels,
    VipModel? vip,
    List<MedalModel>? medals,
    List<String>? features,
    int? coins,
    int? diamond,
    int? points,
    String? username,
    bool? banned,
    DateTime? createdAt,
    String? deviceId,
    String? userToken,
    String? fmcToken,
    String? appPrefix,
    String? email,
    String? country,
    PersonRelation? relation,
    RoomModel? room,
    AgencyModel? agency,
    String? webToken,
    dynamic chatBubble,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      pos: pos ?? this.pos,
      name: name ?? this.name,
      type: type ?? this.type,
      state: state ?? this.state,
      chatBubble: chatBubble ?? this.chatBubble,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      theme: theme ?? this.theme,
      entry: entry ?? this.entry,
      profileFrame: profileFrame ?? this.profileFrame,
      comment: comment ?? this.comment,
      birthday: birthday ?? this.birthday,
      levels: levels ?? this.levels,
      vip: vip ?? this.vip,
      medals: medals ?? this.medals,
      features: features ?? this.features,
      coins: coins ?? this.coins,
      diamond: diamond ?? this.diamond,
      points: points ?? this.points,
      username: username ?? this.username,
      banned: banned ?? this.banned,
      createdAt: createdAt ?? this.createdAt,
      deviceId: deviceId ?? this.deviceId,
      userToken: userToken ?? this.userToken,
      fmcToken: fmcToken ?? this.fmcToken,
      appPrefix: appPrefix ?? this.appPrefix,
      email: email ?? this.email,
      country: country ?? this.country,
      relation: relation ?? this.relation,
      room: room ?? this.room,
      webToken: webToken ?? this.webToken,
    );
  }
}

class LevelsModel {
  final LevelModel? consumption;
  final LevelModel gifter;
  final LevelModel charge;
  final LevelModel anchor;

  LevelsModel({
    this.consumption,
    required this.gifter,
    required this.charge,
    required this.anchor,
  });

  factory LevelsModel.fromMap(Map<String, dynamic> map) {
    return LevelsModel(
      consumption: map['consumption'] != null
          ? LevelModel.fromMap(map['consumption'])
          : null,
      gifter: LevelModel.fromMap(map['gifter']),
      charge: LevelModel.fromMap(map['charge']),
      anchor: LevelModel.fromMap(map['anchor']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'consumption': consumption?.toMap(),
      'gifter': gifter.toMap(),
      'charge': charge.toMap(),
      'anchor': anchor.toMap(),
    };
  }

  List<LevelModel?> get levels {
    return [gifter, anchor, charge];
  }
}

class LevelModel {
  final int lvl;
  final int nextLevelUp;
  final int progress;
  final int total;
  final String? icon;

  LevelModel({
    required this.lvl,
    required this.nextLevelUp,
    required this.progress,
    required this.total,
    this.icon,
  });

  factory LevelModel.fromMap(Map<String, dynamic> map) {
    return LevelModel(
      lvl: map['lvl'] ?? 0,
      nextLevelUp: MyMath.toInt(map['nextLevelUp']),
      progress: MyMath.toInt(map['progress']),
      total: MyMath.toInt(map['total']),
      icon: map["icon"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lvl': lvl,
      'nextLevelUp': nextLevelUp,
      'progress': progress,
      'total': total,
    };
  }

  static List<LevelModel> fromList(List<dynamic> list) {
    return list.map((e) => LevelModel.fromMap(e)).toList();
  }
}

enum PersonRelation {
  friends,
  following,
  followBack,
  follow,
  block,
  iBlock,
  blockBy,
}

extension PersonRelationX on PersonRelation {
  String getLabel(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case PersonRelation.friends:
        return l10n.unFollow;
      case PersonRelation.following:
        return l10n.following;
      case PersonRelation.followBack:
        return l10n.followBack;
      case PersonRelation.follow:
        return l10n.follow;
      case PersonRelation.block:
        return "block";
      case PersonRelation.iBlock:
        return "unblock";
      case PersonRelation.blockBy:
        return "blocked";
    }
  }
}

enum UserPosition {
  deleted(0),
  banned(1),
  notCompleted(2),
  user(3),
  seller(4),
  supervisor(5),
  admin(6),
  superAdmin(7),
  programmer(8),
  owner(9);

  final int value;
  const UserPosition(this.value);
}

extension StateEnumX on StateEnum {
  String getLabel(BuildContext context) {
    final l10n = context.l10n;

    switch (this) {
      case StateEnum.deleted:
        return l10n.deleted;

      case StateEnum.pending:
        return l10n.pending1;

      case StateEnum.reject:
        return l10n.rejected1;

      case StateEnum.hold:
        return l10n.onHold;

      case StateEnum.active:
        return l10n.active1;
    }
  }
}

enum StateEnum {
  deleted(0),
  pending(1),
  reject(2),
  hold(3),
  active(9);

  final int value;
  const StateEnum(this.value);
}

enum RoleEnum {
  banned(0),
  kick(1),
  silent(2),
  guest(3),
  user(5),
  admin(8),
  owner(9);

  final int value;
  const RoleEnum(this.value);
}

class SpecialId {
  int? val;
  String? img;

  SpecialId({this.val, this.img});

  factory SpecialId.fromMap(Map<String, dynamic> map) {
    return SpecialId(val: MyMath.toInt(map['val']), img: map['img']);
  }
}
