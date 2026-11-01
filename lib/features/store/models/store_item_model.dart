import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/models/helpers/image_model.dart';

class StoreItemModel {
  int id;
  ImageModel img;
  ImageModel animation;
  String name;
  StoreType type;
  StoreTypeState typeState;
  int? state;
  int? days;
  int? active;
  PriceModel? price;
  int? expiredAt;

  StoreItemModel({
    required this.id,
    required this.img,
    required this.animation,
    required this.name,
    required this.type,
    required this.typeState,
    this.state,
    required this.days,
    required this.price,
    this.active,
    this.expiredAt,
  });

  factory StoreItemModel.fromMap(Map<String, dynamic> json) {
    return StoreItemModel(
      id: MyMath.toInt(json['id']),
      img: ImageModel.fromMap(json['img']),
      animation: ImageModel.fromMap(json['animation']),
      name: json['name'] ?? "",
      type: StoreType.values.firstWhere(
        (v) => v.value == json['type'],
        orElse: () => StoreType.avatar,
      ),
      typeState: StoreTypeState.values.firstWhere(
        (v) => v.value == json['type_state'],
        orElse: () => StoreTypeState.normal,
      ),
      state: MyMath.toInt(json['state']),
      days: json['days'] ?? 0,
      price: json['price'] != null ? PriceModel.fromMap(json['price']) : null,
      active: json['active'] ?? 0,
      expiredAt: MyMath.toInt(json['expire_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'img': img.toMap(),
      'animation': animation.toMap(),
      'name': name,
      'type': type,
      'state': state,
      'days': days,
      'price': price?.toMap(),
      'active': active,
    };
  }

  static List<StoreItemModel> fromList(List<dynamic> list) {
    return list.map((e) => StoreItemModel.fromMap(e)).toList();
  }
}

class PriceModel {
  final int lng;
  final int type;

  PriceModel({required this.lng, required this.type});

  factory PriceModel.fromMap(json) {
    if (json is num) {
      return PriceModel(lng: json.toInt(), type: 0);
    }
    return PriceModel(lng: json['lng'] ?? 0, type: json['type'] ?? 0);
  }

  Map<String, dynamic> toMap() {
    return {'lng': lng, 'type': type};
  }
}

enum StoreType {
  frame(0, 0),
  bubble(1, 1),
  entry(2, 2),
  crown(3, 10),
  avatar(4, 10),
  nameBG(5, 10),
  nameEntry(6, 10),
  chatBG(7, 10),
  profileFrame(8, 3),
  special(9, 4),
  vip(99, 7);

  final int value;
  final int tabIndex;
  const StoreType(this.value, this.tabIndex);
}

enum StoreTypeState {
  normal(0),
  cpFriend(1),
  cpLove(2),
  deleteCp(3),
  deleteFriend(4);

  final int value;
  const StoreTypeState(this.value);
}
