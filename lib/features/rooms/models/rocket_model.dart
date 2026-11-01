import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/features/rooms/models/gift_model.dart';
import 'package:tom_chat/features/store/models/store_item_model.dart';
import 'package:tom_chat/features/vip/models/vip_model.dart';

class RocketLevel {
  int lvl;
  int points;
  int nextPoints;
  int nextLevel;
  String icon;
  String global;
  String anim;
  String iconAnim;
  String name;
  List<RockeRewardItemModel> rewardItems;
  RocketLevel({
    required this.lvl,
    required this.points,
    required this.nextPoints,
    required this.nextLevel,
    required this.icon,
    required this.global,
    required this.anim,
    required this.iconAnim,
    required this.name,
    required this.rewardItems,
  });

  factory RocketLevel.fromMap(Map<String, dynamic> map) {
    return RocketLevel(
      lvl: MyMath.toInt(map['level']),
      points: MyMath.toInt(map['points']),
      nextPoints: MyMath.toInt(map['nextPoints']),
      nextLevel: MyMath.toInt(map['nextLevel']),
      icon: map['icon'] ?? "",
      global: map['global'] ?? "",
      anim: map['anim'] ?? "",
      iconAnim: map['icon_anim'] ?? "",
      name: map['name'] ?? "",
      rewardItems:
          (map['rewards'] as List<dynamic>?)
              ?.map((item) => RockeRewardItemModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class RockeRewardItemModel {
  final int id;
  final int lid;
  final int lvl;
  final int lng;
  final RewardType rewardType;
  final int giftCount;
  final GiftModel gift;
  final StoreItemModel? equipments;
  final VipModel? vip;
  final String name;
  final int coins;
  final StoreItemModel entryGift;
  final StoreItemModel frame;
  final bool enableToCollect;

  RockeRewardItemModel({
    required this.id,
    required this.lid,
    required this.lvl,
    required this.lng,
    required this.rewardType,
    required this.giftCount,
    required this.gift,
    required this.name,
    required this.coins,
    required this.entryGift,
    required this.frame,
    required this.enableToCollect,
    this.equipments,
    this.vip,
  });

  factory RockeRewardItemModel.fromJson(Map<String, dynamic> json) {
    if (json['equipment']?['icon'] != null) {
      json['equipment']['img'] = json['equipment']['icon'];
    }
    if (json['gift']?['img'] != null) {
      json['gift']['icon'] = json['gift']['img'];
    }
    return RockeRewardItemModel(
      id: MyMath.toInt(json['id']),
      lid: MyMath.toInt(json['lid']),
      lvl: MyMath.toInt(json['lvl']),
      lng: MyMath.toInt(json["lng"]),
      rewardType: RewardType.values[((json['gift_type'] as int?) ?? 1) - 1],
      giftCount: json['gift_count'] ?? 0,
      gift: GiftModel.fromJson(json['gift'] ?? {}),
      equipments: json['equipment'] != null
          ? StoreItemModel.fromMap(json['equipment'])
          : null,
      vip: json['vip'] != null ? VipModel.fromMap(json['vip']) : null,
      name: json['name'] ?? '',
      coins: MyMath.toInt(json['coins']),
      entryGift: StoreItemModel.fromMap(json['entry'] ?? {}),
      frame: StoreItemModel.fromMap(json['frame'] ?? {}),
      enableToCollect: json['isReward'] ?? false,
    );
  }
}

enum RewardType {
  coin(1),
  gift(2),
  equipment(3),
  vip(4);

  const RewardType(this.value);
  final int value;
}
