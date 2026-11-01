import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:tom_chat/features/rooms/models/room_model.dart';

class RoomStorageService {
  final GetStorage _storage = GetStorage();
  final String _key = 'rooms';
  final int _maxItems = 20;

  // إضافة غرفة جديدة
  void addRoom(RoomModel room) {
    List<RoomModel> currentRooms = getRooms();

    if (currentRooms.any((r) => r.id == room.id)) return;

    if (currentRooms.length >= _maxItems) {
      currentRooms.removeAt(0); // إزالة أقدم غرفة عند الوصول للحد الأقصى
    }

    currentRooms.add(room);

    // تحويل كل غرفة إلى JSON ثم تخزينها
    List<String> jsonList = currentRooms
        .map((r) => jsonEncode(_roomToMap(r)))
        .toList();
    _storage.write(_key, jsonList);
  }

  // إضافة غرفة جديدة
  void removeRoom(int roomId) {
    List<RoomModel> currentRooms = getRooms();
    currentRooms.removeWhere((r) => r.id == roomId);
    List<String> jsonList = currentRooms
        .map((r) => jsonEncode(_roomToMap(r)))
        .toList();
    _storage.write(_key, jsonList);
  }

  // جلب الغرف
  List<RoomModel> getRooms() {
    List<dynamic>? rawList = _storage.read(_key);
    if (rawList == null) return [];

    List<String> jsonList = List<String>.from(rawList);

    return jsonList.map((e) {
      Map<String, dynamic> map = jsonDecode(e);
      return RoomModel.fromMap(map);
    }).toList();
  }

  // مسح كل الغرف
  void clear() {
    _storage.remove(_key);
  }

  // تحويل RoomModel إلى Map مع التعامل مع null
  Map<String, dynamic> _roomToMap(RoomModel room) {
    return {
      'id': room.id,
      'uid': room.uid,
      'title': room.title,
      'type': room.type,
      'state': room.state,
      'bg': room.bg?.toMap(),
      'icon': room.icon?.toMap(),
      'created_at': room.createdAt,
      'banned': room.banned,
      'owner': room.owner?.toMap(),
      'level_info': room.roomLevel?.toMap(),
      'start': room.start,
      'ts': room.ts,
      'country': room.country,
      'usersCount': room.usersCount,
      'coin_number': room.coinNumber,
      'seats': room.seats.map((s) => s.toJson()).toList(),
      'user_sw_token': room.userSwToken,
      'agora_channel': room.agoraChannel,
      'agora_uid': room.agoraUid,
      'my_rule': room.myRule.value,
    };
  }
}
