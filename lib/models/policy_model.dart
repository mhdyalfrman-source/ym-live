import 'dart:convert';

class PolicyModel {
  int? policyId;
  String? policyName;
  PolicyModel({this.policyId, this.policyName});

  PolicyModel copyWith({PolicyModel? policy}) {
    return PolicyModel(
      policyId: policy!.policyId ?? policyId,
      policyName: policy.policyName ?? policyName,
    );
  }

  factory PolicyModel.initialize({int? policyId, String? policyName}) {
    return PolicyModel(policyId: policyId ?? 0, policyName: policyName ?? "");
  }

  Map<String, dynamic> toMap(bool forUpdate) {
    Map<String, dynamic> map = {'POL_ID': policyId};
    return map;
  }

  factory PolicyModel.fromMap(Map<String, dynamic> map) {
    return PolicyModel(
      policyId: map['POL_ID'] != null ? map['POL_ID'] as int : null,
      policyName: map['POL_NAME'] != null ? map['POL_NAME'] as String : null,
    );
  }

  String toJson(bool forUpdate) => json.encode(toMap(forUpdate));

  factory PolicyModel.fromJson(String source) =>
      PolicyModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
