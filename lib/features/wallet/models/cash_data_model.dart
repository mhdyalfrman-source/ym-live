import 'package:tom_chat/core/utils/my_math.dart';

class CashDataModel {
  double? total;
  double votes;
  int coins;
  int diamond;
  double cashMin;
  double cashRate;
  double exchangeRate;
  double diamondRate;
  int cashStart;
  int cashMaxTimes;
  int youCashCount;
  int cashEnd;
  int gameExchangeRate;
  Map<String, dynamic>? chargeAgency;

  List<CachTypeModel>? paymentTypes;

  CashDataModel({
    required this.total,
    required this.votes,
    required this.coins,
    required this.diamond,
    required this.cashMin,
    required this.cashRate,
    required this.diamondRate,
    required this.exchangeRate,
    // required this.cashTake,
    required this.cashStart,
    required this.cashMaxTimes,
    required this.youCashCount,
    required this.cashEnd,
    this.chargeAgency,
    this.paymentTypes,
    this.gameExchangeRate = 0,
  });

  factory CashDataModel.fromJson(Map<String, dynamic> json) {
    return CashDataModel(
      total: MyMath.toDouble(json['total']),
      votes: MyMath.toDouble(json['votes']),
      coins: MyMath.toInt(json['coins']),
      diamond: MyMath.toInt(json['diamond']),
      cashMin: MyMath.toDouble(json['cash_min']),
      cashRate: MyMath.toDouble(json['cash_rate']),
      exchangeRate: MyMath.toDouble(json['exchange_rate']),
      diamondRate: MyMath.toDouble(json['diamond_rate']),
      cashStart: MyMath.toInt(json['cash_start']),
      cashMaxTimes: MyMath.toInt(json['cash_max_times']),
      youCashCount: MyMath.toInt(json['you_cash_count']),
      cashEnd: MyMath.toInt(json['cash_end']),
      chargeAgency: json['chargeAgency'] != null
          ? Map<String, dynamic>.from(json['chargeAgency'])
          : null,
      paymentTypes: json['types'] != null
          ? CachTypeModel.fromList((json['types'] as Map).values.toList())
          : null,
      gameExchangeRate: MyMath.toInt(json['game_exchange_rate']),
    );
  }
}

class CachTypeModel {
  int id;
  String name;
  String icon;
  CachTypeModel({required this.id, required this.name, required this.icon});

  factory CachTypeModel.fromMap(Map<String, dynamic> map) {
    return CachTypeModel(
      id: MyMath.toInt(map['id']),
      name: map['name'] ?? "",
      icon: map['icon'] ?? "",
    );
  }

  static List<CachTypeModel> fromList(List<dynamic> list) {
    return list.map((e) => CachTypeModel.fromMap(e)).toList();
  }
}

class PaymentTypeModel {
  int id;
  String name;
  PaymentTypeModel({required this.id, required this.name});

  factory PaymentTypeModel.fromMap(Map<String, dynamic> map) {
    return PaymentTypeModel(
      id: MyMath.toInt(map['id']),
      name: map['name'] ?? "",
    );
  }
}
