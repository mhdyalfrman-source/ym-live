import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class StoredUser {
  final String id;
  String? name;
  String? profilePic;
  String token;
  String deviceID;
  bool isSelected;

  StoredUser({
    required this.id,
    this.name,
    this.isSelected = false,
    this.profilePic,
    required this.token,
    required this.deviceID,
  });

  factory StoredUser.fromJson(Map<String, dynamic> json) {
    return StoredUser(
      id: json['id'] as String,
      name: json['name'] as String?,
      profilePic: json['profilePic'] as String?,
      token: json['token'] as String,
      deviceID: json['deviceID'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'profilePic': profilePic,
    'token': token,
    'deviceID': deviceID,
  };
}

class SecureUsersStore {
  static const String _usersKey = 'users';
  static const String _activeUserIdKey = 'active_user_id';

  // اجعل الكاش يبدأ بـ null حتى نقرأ من التخزين أول مرة
  static List<StoredUser>? _cache;

  final FlutterSecureStorage _storage;
  SecureUsersStore._internal(this._storage);

  factory SecureUsersStore({FlutterSecureStorage? storage}) {
    return SecureUsersStore._internal(storage ?? const FlutterSecureStorage());
  }

  Future<List<StoredUser>> getAllUsers() async {
    try {
      final value = await _storage.read(key: _usersKey);
      if (value == null || value.isEmpty) {
        _cache = <StoredUser>[];
        return _cache!;
      }

      final decoded = json.decode(value);
      if (decoded is! List) {
        _cache = <StoredUser>[];
        return _cache!;
      }

      // لا تستدعِ getActiveUser هنا لتجنب الدوران
      final activeId = await _storage.read(key: _activeUserIdKey);

      final list = decoded
          .whereType<Map>() // عناصر القائمة تكون Map<dynamic,dynamic>
          .map((e) {
            final u = StoredUser.fromJson(e.cast<String, dynamic>());
            u.isSelected = (u.id == activeId);
            return u;
          })
          .toList(growable: false);

      _cache = list;
      return list;
    } catch (e, st) {
      _cache = <StoredUser>[];
      return _cache!;
    }
  }

  Future<StoredUser> upsertUser(StoredUser user) async {
    final list = await getAllUsers();
    final index = list.indexWhere((u) => u.id == user.id);

    if (index >= 0) {
      final current = list[index];
      current.name = user.name ?? current.name;
      current.profilePic = user.profilePic ?? current.profilePic;
      current.token = user.token;
      current.deviceID = user.deviceID;
      _cache = List<StoredUser>.from(list);
    } else {
      _cache = List<StoredUser>.from(list)..add(user);
    }

    await _writeUsers(_cache!);
    return _cache!.firstWhere((u) => u.id == user.id);
  }

  Future<bool> deleteUserById(String id) async {
    final list = await getAllUsers();
    final before = list.length;

    final newList = List<StoredUser>.from(list)..removeWhere((u) => u.id == id);
    if (newList.length == before) return false;

    final activeId = await getActiveUserId();
    if (activeId == id) {
      await _storage.delete(key: _activeUserIdKey);
    }

    _cache = newList;
    await _writeUsers(newList);
    return true;
  }

  Future<void> clearAll() async {
    _cache = <StoredUser>[];
    await _storage.delete(key: _usersKey);
    await _storage.delete(key: _activeUserIdKey);
  }

  Future<bool> setActiveUser(String id) async {
    final list = await getAllUsers();
    if (list.every((u) => u.id != id)) return false;

    await _storage.write(key: _activeUserIdKey, value: id);

    _cache = list
        .map(
          (u) => StoredUser(
            id: u.id,
            name: u.name,
            profilePic: u.profilePic,
            token: u.token,
            deviceID: u.deviceID,
            isSelected: u.id == id,
          ),
        )
        .toList(growable: false);

    return true;
  }

  Future<String?> getActiveUserId() async {
    return _storage.read(key: _activeUserIdKey);
  }

  Future<StoredUser?> getActiveUser() async {
    final id = await getActiveUserId();
    if (id == null) return null;
    final list = await getAllUsers(); // استخدم أحدث نسخة
    return list.firstWhereOrNull((u) => u.id == id);
  }

  Future<void> _writeUsers(List<StoredUser> users) async {
    final jsonList = users.map((u) => u.toJson()).toList(growable: false);
    await _storage.write(key: _usersKey, value: json.encode(jsonList));
  }
}
