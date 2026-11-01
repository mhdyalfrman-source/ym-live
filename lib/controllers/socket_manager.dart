import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:tom_chat/controllers/event_emitter.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/statics_values.dart';

class SocketManager extends MyEventEmitter {
  SocketManager._internal();
  static final SocketManager instance = SocketManager._internal();
  Timer? _reconnectTimer;
  bool _isManuallyDisconnected = false;
  io.Socket? _socket;

  final Map<String, String> _reconnectData = {};

  void addReconnectData(Map<String, String> data) {
    _reconnectData.addAll(data);
  }

  void removeReconnectData(List<String> keys) {
    for (var key in keys) {
      _reconnectData.remove(key);
    }
  }

  void _waitAndReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 58), () {
      if (_socket?.disconnected == true && !_isManuallyDisconnected) {
        _isManuallyDisconnected = true;
      }
    });
  }

  String socketId = "";

  void init(String ip, int port) {
    try {
      if ((_socket != null) || StaticValue.userData.userId == 0) {
        return;
      }

      _socket = io.io('http://$ip:$port', {
        'transports': ['websocket'],
        'autoConnect': false,
        'timeout': 60000,
      });

      _socket?.onConnect((_) async {
        Map<String, String> data = {
          "token": StaticValue.userData.userToken ?? "",
          "prefix": StaticValue.userData.appPrefix ?? '',
          "apiKey": CallServerAPI.apiKey,
          ..._reconnectData,
        };
        if (socketId != "" && socketId != (_socket?.id ?? "")) {
          await CallServerAPI.post(
            'auth/tokenLogin',
            {},
            secounds: 100,
            withMessage: false,
          );
          emit("forceReconnect");
        } else {
          emit("forceReconnect");
        }
        _socket?.emit('conn', data);
        socketId = _socket?.id ?? "";
      });

      _socket?.connect();

      _socket?.onReconnect((_) {
        _reconnectTimer?.cancel();
        if (!_isManuallyDisconnected) {
          return;
        }
        _isManuallyDisconnected = false;
        emit("reconnect");
      });

      _socket?.onDisconnect((_) {
        _waitAndReconnect();
        emit("disconnect");
      });
      _socket?.onAny((event, data) {
        if (kDebugMode) {
          print("📣 Socket Event: $event");
          print("📣 Socket Data: $data");
        }
        dynamic newData;
        try {
          if (data.runtimeType == String) {
            try {
              newData = jsonDecode(data);
            } catch (e) {
              newData = data;
            }
          } else {
            newData = data;
          }

          if (event == 'globalAnimation') {
            List.from(newData).map((json) {}).toList();
          } else if (event == 'userInfo') {
            
          } else if (newData != null) {
            emit(event, newData);
          }
        } catch (e) {
          if (kDebugMode) {
            print(
                "📣 jsonDecode json error: $e & type of data ${newData.runtimeType}");
          }
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print("⚠️ Socket error: $e");
      }
    }
  }

  void disconnect({bool manual = true}) {
    try {
      _reconnectTimer?.cancel(); // ⛔️ أوقف أي محاولة إعادة اتصال
      _reconnectTimer = null;

      _isManuallyDisconnected = manual;

      _socket?.offAny();
      _socket?.clearListeners();
      _socket?.disconnect();
      _socket?.close();
      _socket = null;

      super.clearListeners();
    } catch (e) {}
  }

  void emitToServer(String eventName, dynamic data) {
    _socket?.emit(eventName, data);
  }
}
