import 'package:tom_chat/models/user/user_model.dart';

class AgencyUserModel {
  int? id;
  int? uid;
  int? gid;
  RoleEnum? role;
  StateEnum? state;
  AgencyUserModel({this.id, this.uid, this.gid, this.role, this.state});

  AgencyUserModel copyWith({
    int? id,
    int? uid,
    int? gid,
    RoleEnum? role,
    StateEnum? state,
  }) {
    return AgencyUserModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      gid: gid ?? this.gid,
      role: role ?? this.role,
      state: state ?? this.state,
    );
  }

  factory AgencyUserModel.fromMap(Map<String, dynamic> map) {
    return AgencyUserModel(
      id: map['id'] != null ? map['id'] as int : null,
      uid: map['uid'] != null ? map['uid'] as int : null,
      gid: map['gid'] != null ? map['gid'] as int : null,
      role: RoleEnum.values.firstWhere(
        (v) => v.value == map['role'],
        orElse: () => RoleEnum.user,
      ),
      state: StateEnum.values.firstWhere(
        (v) => v.value == map['state'],
        orElse: () => StateEnum.active,
      ),
    );
  }
}
