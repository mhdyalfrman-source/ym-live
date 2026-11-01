import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/models/helpers/image_model.dart';

/// A cash agency is independent of the families/agencies system.
class RechargeAgencyModel {
  final int id;
  final String name;
  final ImageModel? icon;
  final String countryCode;
  final String phone;
  final int ownerUid;
  final int coinsBalance;
  final double usdBalance;

  const RechargeAgencyModel({
    required this.id,
    required this.name,
    this.icon,
    required this.countryCode,
    required this.phone,
    this.ownerUid = 0,
    this.coinsBalance = 0,
    this.usdBalance = 0,
  });

  factory RechargeAgencyModel.fromMap(Map<String, dynamic> map) =>
      RechargeAgencyModel(
        id: MyMath.toInt(map['id']),
        name: map['name']?.toString() ?? '',
        icon: ImageModel.fromMap(map['icon'] ?? map['image']),
        countryCode: map['country_code']?.toString() ?? '',
        phone: map['phone']?.toString() ?? '',
        ownerUid: MyMath.toInt(map['uid']),
        coinsBalance: MyMath.toInt(map['coins_balance']),
        usdBalance: MyMath.toDouble(map['usd_balance']),
      );

  String get description =>
      '+${countryCode.replaceFirst(RegExp(r'^\+'), '')}$phone';
  Uri? get whatsappUri {
    final number = '${countryCode.replaceFirst(RegExp(r'^\+'), '')}$phone';
    if (!RegExp(r'^[1-9][0-9]{6,14}$').hasMatch(number)) return null;
    return Uri.https('wa.me', '/$number');
  }
}
