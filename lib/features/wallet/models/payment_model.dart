import 'package:flutter/material.dart';
import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/features/chat/models/room_chat_model.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';

class PaymentModel {
  int id;
  double money;
  double coins;
  StateEnum status;
  PaymentType type;
  MyDateTime date;
  PaymentModel({
    required this.id,
    required this.money,
    required this.coins,
    required this.status,
    required this.type,
    required this.date,
  });

  static List<PaymentModel> fromList(List<dynamic> list) {
    return list.map((e) => PaymentModel.fromMap(e)).toList();
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: MyMath.toInt(map['id']),
      money: MyMath.toDouble(map['money']),
      coins: MyMath.toDouble(map['coins']),
      status: StateEnum.values.firstWhere(
        (v) => v.value == map['status'],
        orElse: () => StateEnum.pending,
      ),
      type: PaymentType.values.firstWhere(
        (v) => v.name == map['type'],
        orElse: () => PaymentType.google,
      ),
      date: MyDateTime.parse(map['date']),
    );
  }
}

enum PaymentType { google, stripe, oxapay, paypal, admin }

extension PaymentTypeX on PaymentType {
  String getLabel(BuildContext context) {
    final l10n = context.l10n;

    switch (this) {
      case PaymentType.google:
        return l10n.google;
      case PaymentType.stripe:
        return "stripe";
      case PaymentType.oxapay:
        return "oxapay";
      case PaymentType.paypal:
        return "paypal";
      case PaymentType.admin:
        return l10n.admin;
    }
  }
}
