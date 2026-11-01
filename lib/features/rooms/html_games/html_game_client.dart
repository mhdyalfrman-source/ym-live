import 'dart:convert';
import 'package:tom_chat/features/rooms/models/game_model.dart';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/statics_values.dart';

class HtmlGameException implements Exception {
  const HtmlGameException(this.code);
  final String code;
  String get message => switch (code) {
    'app_auth_invalid' => 'Please sign in again before opening a game.',
    'game_auth_invalid' => 'Please sign in again before opening a game.',
    'game_unavailable' => 'This game is currently unavailable.',
    'untrusted_game_url' => 'The game address is not trusted.',
    _ => 'Unable to load the game. Check your connection and try again.',
  };
}

class HtmlGameLaunch {
  HtmlGameLaunch(
    GameModel game,
    this.webToken,
    this.api, {
    bool allowHttp = false,
  }) : gid = game.gid,
       entry = Uri.parse(game.url) {
    if (gid <= 0 ||
        !trusted(entry, api, allowHttp: allowHttp) ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(webToken)) {
      throw const HtmlGameException('untrusted_game_url');
    }
  }
  final int gid;
  String webToken;
  final Uri entry;
  final Uri api;

  // The shared SDK is served with its backend. No path prefix or URL rewriting.
  static bool trusted(Uri url, Uri api, {bool allowHttp = false}) =>
      (url.scheme == 'https' || (allowHttp && url.scheme == 'http')) &&
      url.hasAuthority &&
      url.origin == api.origin &&
      url.userInfo.isEmpty;
}

class HtmlGameClient {
  HtmlGameClient({
    http.Client? client,
    Uri? base,
    String Function()? token,
    String Function()? webToken,
  }) : _client = client ?? http.Client(),
       base = base ?? Uri.parse(CallServerAPI.com),
       _token = token ?? (() => StaticValue.userData.userToken ?? ''),
       _webToken = webToken ?? (() => StaticValue.userData.webToken ?? '');

  final http.Client _client;
  final Uri base;
  final String Function() _token;
  final String Function() _webToken;

  Future<Map<String, dynamic>> request(
    String action,
    Map<String, String> data,
  ) async {
    try {
      if (!HtmlGameLaunch.trusted(base, base, allowHttp: kDebugMode)) {
        throw const HtmlGameException('untrusted_game_url');
      }
      final appRequest = action == 'app-balance';
      final token = appRequest ? _token() : _webToken();
      if (token.isEmpty) {
        throw HtmlGameException(
          appRequest ? 'app_auth_invalid' : 'game_auth_invalid',
        );
      }
      // The generic app helper swallows auth errors, so keep a typed error here.
      // Redirects are disabled to keep the app token on its configured origin.
      final request =
          http.Request(
              'POST',
              base
                  .resolve('html_games.php')
                  .replace(queryParameters: {'action': action}),
            )
            ..followRedirects = false
            ..headers.addAll({
              if (appRequest) 'API-KEY': CallServerAPI.apiKey,
              if (appRequest) 'Auth-Token': token,
              if (!appRequest) 'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            })
            ..body = jsonEncode(data);
      final response = await http.Response.fromStream(
        await _client.send(request).timeout(const Duration(seconds: 20)),
      ).timeout(const Duration(seconds: 20));
      if (response.statusCode >= 300 && response.statusCode < 400) {
        throw const HtmlGameException('untrusted_game_url');
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200 || body['code'] != 200) {
        throw HtmlGameException(
          (body['err'] as List?)?.firstOrNull?.toString() ??
              'game_network_error',
        );
      }
      return Map<String, dynamic>.from(body['data'] as Map);
    } on HtmlGameException {
      rethrow;
    } catch (_) {
      throw const HtmlGameException('game_network_error');
    }
  }

  Future<HtmlGameLaunch> launch(GameModel game) async {
    final token = _webToken();
    if (token.isEmpty) throw const HtmlGameException('game_auth_invalid');
    return HtmlGameLaunch(
      game,
      token,
      base.resolve('html_games.php'),
      allowHttp: kDebugMode,
    );
  }

  Future<void> refreshBalance() async {
    final account = _token();
    final data = await request('app-balance', {});
    final coins = int.tryParse(data['coins'].toString());
    if (coins == null || coins < 0) {
      throw const HtmlGameException('game_network_error');
    }
    if (_token() == account) StaticValue.coins.value = coins;
  }

  void dispose() => _client.close();
}

// The bridge cannot submit amounts, users, URLs or arbitrary commands.
String? parseHtmlGameMessage(String message, String nonce) {
  if (message.length > 256) return null;
  try {
    final value = jsonDecode(message);
    if (value is! Map ||
        value.length != 3 ||
        value['version'] != 1 ||
        value['nonce'] != nonce ||
        !const {
          'ready',
          'wallet_changed',
          'auth_error',
          'close',
          'load_error',
        }.contains(value['type'])) {
      return null;
    }
    return value['type'] as String;
  } catch (_) {
    return null;
  }
}
