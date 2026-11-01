import 'package:flutter/material.dart';
import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/helpers/image_model.dart';
import 'package:tom_chat/models/user/user_model.dart';

class GiftModel {
  String sendId;
  int id;
  int? rid;
  int? liveuid;
  GiftType type;
  int mark;
  String name;
  int coins;
  int lng;
  ImageModel giftImage;
  int isAllNotify;
  bool isCp;
  int count;
  LevelModel? roomlevel;
  ImageModel? roomImg;
  ImageModel? uAvatar;
  ImageModel? giftAnimation;
  UserModel? sender;
  UserModel? to;
  int globalNotifyLvl;

  GiftModel({
    required this.sendId,
    required this.id,
    this.type = GiftType.gift,
    this.mark = 0,
    required this.name,
    this.coins = 0,
    required this.giftImage,
    this.isAllNotify = 0,
    this.isCp = false,
    this.count = 1,
    this.lng = 0,
    this.giftAnimation,
    this.sender,
    this.to,
    this.rid,
    this.roomlevel,
    this.roomImg,
    this.uAvatar,
    this.liveuid,
    this.globalNotifyLvl = 0,
  });

  factory GiftModel.fromJson(
    Map<String, dynamic> json, {
    UserModel? sender,
    UserModel? to,
  }) {
    return GiftModel(
      sendId: json['send_id'] ?? '',
      id: MyMath.toInt(json['id']),
      rid: MyMath.toInt(json['rid']),
      liveuid: MyMath.toInt(json['liveuid']),
      type: GiftType.values.firstWhere(
        (g) => g.value == json['type'],
        orElse: () => GiftType.gift,
      ),
      mark: MyMath.toInt(json['mark']),
      globalNotifyLvl: MyMath.toInt(json['global_notify_lvl']),
      name: json['name'] ?? '',
      coins: MyMath.toInt(json['coins']),
      giftImage: ImageModel.fromMap(json['icon']),
      isAllNotify: json['isAllNotify'] ?? 0,
      isCp: json['isCp'] == 1,
      count: MyMath.toInt(json['count'], defaultVal: 1),
      lng: MyMath.toInt(json['lng']),
      roomImg: json['roomImg'] != null
          ? ImageModel.fromMap(json['roomImg'])
          : null,
      uAvatar: json['uAvatar'] != null
          ? ImageModel.fromMap(json['uAvatar'])
          : null,
      giftAnimation: json['anim'] != null
          ? ImageModel.fromMap(json['anim'])
          : null,
      roomlevel: json['room_level'] != null
          ? LevelModel.fromMap(json['room_level'])
          : null,
      sender: sender,
      to: to,
    );
  }

  GiftModel copyWith({
    String? sendId,
    int? count,
    int? vip,
    int? coins,
    int? mark,
    GiftType? type,
    bool? isCp,
    int? isAllNotify,
    ImageModel? giftImage,
    ImageModel? giftAnimation,
    int? requiredLevel,
    UserModel? sender,
    List<SubGiftModel>? subGifts,
    UserModel? to,
  }) {
    return GiftModel(
      sendId: sendId ?? this.sendId,
      id: id,
      type: type ?? this.type,
      mark: mark ?? this.mark,
      name: name,
      coins: coins ?? this.coins,
      giftImage: giftImage ?? this.giftImage,
      count: count ?? this.count,
      giftAnimation: giftAnimation ?? this.giftAnimation,
      sender: sender ?? this.sender,
      isAllNotify: isAllNotify ?? this.isAllNotify,
      isCp: isCp ?? this.isCp,
      to: to ?? this.to,
    );
  }

  static List<GiftModel> fromList(List<dynamic> list) {
    return list.map((e) => GiftModel.fromJson(e)).toList();
  }
}

class SubGiftModel {
  final String icon;
  final String name;

  SubGiftModel({required this.icon, required this.name});

  factory SubGiftModel.fromJson(Map<String, dynamic> json) {
    return SubGiftModel(icon: json['icon'] ?? '', name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'icon': icon, 'name': name};
  }
}

class SentGiftModel {
  int? giftId;
  int? counts;
  String? img;
  SentGiftModel({this.giftId, this.counts, this.img});

  factory SentGiftModel.fromMap(Map<String, dynamic> map) {
    return SentGiftModel(
      giftId: MyMath.toInt(map['gift_id']),
      counts: MyMath.toInt(map['counts']),
      img: map['img'] != null ? map['img'] as String : null,
    );
  }
  static List<SentGiftModel> fromList(List<dynamic> list) {
    return list.map((e) => SentGiftModel.fromMap(e)).toList();
  }
}

enum GiftType {
  gift(1),
  vip(6), // بحسب مستوي ال vip
  cp(2),
  country(3),
  luck(4),
  gifterLvl(5), // تتحسب بلفل الثروه او الداعمين
  special(7), // مشاهير غالبا هتكون mp4
  backPack(0);

  final int value;
  const GiftType(this.value);
}

extension TranslatGiftTypes on GiftType {
  String getLocalization(BuildContext context) {
    switch (this) {
      case GiftType.gift:
        return context.l10n.typeGift;
      case GiftType.cp:
        return context.l10n.typeCp;
      case GiftType.country:
        return context.l10n.typeCountry;
      case GiftType.luck:
        return context.l10n.typeLuck;
      case GiftType.gifterLvl:
        return context.l10n.typeGifter_level;
      case GiftType.vip:
        return context.l10n.typeVip;
      case GiftType.special:
        return context.l10n.typeSpecial;
      case GiftType.backPack:
        return "";
    }
  }
}
