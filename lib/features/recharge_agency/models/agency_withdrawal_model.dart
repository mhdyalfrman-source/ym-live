import 'package:tom_chat/core/utils/my_math.dart';

class AgencyWithdrawalModel {
  final int id;
  final int uid;
  final String amount;
  final String userName;
  final String accountName;
  final String accountNumber;
  final String accountType;
  final String createdAt;

  const AgencyWithdrawalModel({
    required this.id,
    required this.uid,
    required this.amount,
    required this.userName,
    required this.accountName,
    required this.accountNumber,
    required this.accountType,
    required this.createdAt,
  });

  factory AgencyWithdrawalModel.fromMap(Map<String, dynamic> map) =>
      AgencyWithdrawalModel(
        id: MyMath.toInt(map['id']),
        uid: MyMath.toInt(map['uid']),
        amount: map['amount']?.toString() ?? '0',
        userName: map['user_name']?.toString() ?? '',
        accountName: map['account_name']?.toString() ?? '',
        accountNumber: map['account_number']?.toString() ?? '',
        accountType: map['account_type']?.toString() ?? '',
        createdAt: map['created_at']?.toString() ?? '',
      );
}
