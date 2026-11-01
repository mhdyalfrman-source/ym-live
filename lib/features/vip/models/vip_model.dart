import 'package:flutter/material.dart';
import 'package:tom_chat/core/utils/my_math.dart';

class VipModel {
  int id;
  int state;
  int num;
  String icon;
  String profileFrame;
  String? bg;
  String entryEffect;
  String nameEntryEffect;
  String frame;
  String? bubble;
  int price;
  int renewalPrice;
  int days;
  int? expireAt;
  int? active;
  Color? color;
  List<VipPrivilege> privileges;

  VipModel({
    required this.id,
    required this.state,
    required this.num,
    required this.icon,
    required this.profileFrame,
    required this.bg,
    required this.entryEffect,
    required this.nameEntryEffect,
    required this.frame,
    required this.price,
    required this.renewalPrice,
    required this.days,
    required this.privileges,
    this.color,
    this.bubble,
    this.active,
    this.expireAt,
  });

  factory VipModel.fromMap(Map<String, dynamic> json) {
    return VipModel(
      id: MyMath.toInt(json["id"]),
      state: MyMath.toInt(json["state"]),
      num: MyMath.toInt(json["num"]),
      icon: json["icon"] ?? "",
      profileFrame: json["profile_frame"] ?? "",
      bg: json["bg"] ?? "",
      entryEffect: json["entry_effect"] ?? "",
      nameEntryEffect: json["name_entry_effect"] ?? "",
      bubble: json["bubble"] ?? "",
      frame: json["frame"] ?? "",
      price: MyMath.toInt(json["price"]),
      renewalPrice: MyMath.toInt(json["renewal_price"]),
      days: MyMath.toInt(json["days"]),
      color: getColorFromList(json["color"]),
      expireAt: MyMath.toInt(json["expire_at"]),
      active: MyMath.toInt(json["active"]),
      privileges: json["privileges"] is List
          ? (json["privileges"] as List)
                .map((e) => VipPrivilege.fromJson(e))
                .toList()
          : [],
    );
  }
  static List<VipModel> fromList(List<dynamic> list) {
    return list.map((e) => VipModel.fromMap(e)).toList();
  }
}

Color? getColorFromList(String? data) {
  if (data == null || data.isEmpty) return null;

  final parts = data.split(",");

  if (parts.length < 3) return null;

  int _toInt(String v) => int.tryParse(v.trim())?.clamp(0, 255) ?? 0;

  final r = _toInt(parts[0]);
  final g = _toInt(parts[1]);
  final b = _toInt(parts[2]);

  return Color.fromARGB(255, r, g, b);
}

class VipPrivilege {
  final int id;
  final String? shopItem;
  final String icon;
  final int state;
  final PrivilegeType type;
  final String name;

  VipPrivilege({
    required this.id,
    required this.shopItem,
    required this.icon,
    required this.state,
    required this.type,
    required this.name,
  });

  factory VipPrivilege.fromJson(Map<String, dynamic> json) {
    return VipPrivilege(
      id: json["id"],
      shopItem: json["shop_item"],
      icon: json["icon"] ?? "",
      state: json["state"] ?? 0,
      type: PrivilegeType.values.firstWhere(
        (p) => p.index == MyMath.toInt(json["type"], defaultVal: 1) - 1,
      ),
      name: json["name"],
    );
  }
}

// enum PrivilegeType {
//   vipBudg,
//   enterRoomEffect,
//   untiBan,
//   moreSets,
//   costomSets,
//   gameRoom,
//   specialEntry,
//   specialFrame,
//   moreEmoje,
//   hideFromTop,
//   hideInRoom,
//   hideInLive,
//   hideLevel,
//   moreOptionInRooms,
//   costomBackground,
//   openRoom,
//   openLive,
//   vipSupport,
//   exclusiveGift,
//   sendSticker,
// }

enum PrivilegeType {
  boardcast, // 1
  businessCard, // 2
  entry, // 3
  emoji, // 4
  entryEffect, // 5
  exclusiveCustomerService, // 6
  followNum, // 7
  frame, // 8
  gift, // 9
  highlight, // 10
  itemSharing, // 11
  voiceWave, // 12
  acceleratedUpgrade, // 13
  antiBlack, // 14
  antiKick, // 15
  sendImage, // 16
}
