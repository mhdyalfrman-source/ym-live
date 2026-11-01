import 'dart:convert';
import 'package:tom_chat/features/rooms/models/game_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tom_chat/features/rooms/html_games/html_game_client.dart';
import 'package:tom_chat/statics_values.dart';

void main() {
  final base = Uri.parse('https://example.test/public/');
  test('bridge accepts only events bound to this launch', () {
    String message(Map<String, dynamic> extra) => jsonEncode({
      'version': 1,
      'nonce': 'launch',
      'type': 'wallet_changed',
      ...extra,
    });
    expect(parseHtmlGameMessage(message({}), 'launch'), 'wallet_changed');
    expect(parseHtmlGameMessage(message({'coins': 9999}), 'launch'), isNull);
    expect(parseHtmlGameMessage(message({'nonce': 'other'}), 'launch'), isNull);
    expect(parseHtmlGameMessage(message({'type': 'credit'}), 'launch'), isNull);
    expect(parseHtmlGameMessage('invalid', 'launch'), isNull);
  });
  test(
    'URL policy rejects redirects to foreign, unsafe and credential URLs',
    () {
      expect(
        HtmlGameLaunch.trusted(
          base.resolve('html-games/demo/index.html'),
          base,
        ),
        isTrue,
      );
      for (final url in [
        'https://evil.test/public/',
        'http://example.test/public/',
        'https://secret@example.test/public/',
      ]) {
        expect(HtmlGameLaunch.trusted(Uri.parse(url), base), isFalse);
      }
    },
  );
  test(
    'opening a game reuses the saved web token without an exchange',
    () async {
      final client = HtmlGameClient(
        base: base,
        token: () => 'app-token',
        webToken: () => 'a' * 64,
        client: MockClient(
          (_) async =>
              throw StateError('Launch must not request a second URL registry'),
        ),
      );
      final game = GameModel.fromJson({
        'gid': 421,
        'url': '${base}custom/play.html?a=1&a=2&tag=a%2Bb#board',
      });
      final launch = await client.launch(game);
      expect(launch.gid, 421);
      expect(launch.entry.toString(), game.url);
      expect(launch.webToken, 'a' * 64);
      expect(launch.api, base.resolve('html_games.php'));
      client.dispose();
    },
  );
  test('existing secure-storage user serialization includes web_token', () {
    final user = StaticValue.userData.copyWith(webToken: 'b' * 64);
    expect(jsonDecode(user.toJson())['web_token'], 'b' * 64);
  });
  test('wallet refresh uses authoritative response', () async {
    StaticValue.coins.value = 1;
    final client = HtmlGameClient(
      base: base,
      token: () => 'app-token',
      client: MockClient((request) async {
        expect(request.url.queryParameters['action'], 'app-balance');
        expect(request.body, '{}');
        return http.Response('{"code":200,"data":{"coins":"123456"}}', 200);
      }),
    );
    await client.refreshBalance();
    expect(StaticValue.coins.value, 123456);
    client.dispose();
  });
  test('failed refresh preserves balance and reports auth error', () async {
    StaticValue.coins.value = 42;
    final client = HtmlGameClient(
      base: base,
      token: () => 'app-token',
      client: MockClient(
        (_) async => http.Response(
          '{"code":401,"err":["app_auth_invalid"],"data":null}',
          401,
        ),
      ),
    );
    await expectLater(
      client.refreshBalance(),
      throwsA(
        isA<HtmlGameException>().having(
          (e) => e.code,
          'code',
          'app_auth_invalid',
        ),
      ),
    );
    expect(StaticValue.coins.value, 42);
    client.dispose();
  });
  test('account switching ignores an old in-flight wallet response', () async {
    StaticValue.coins.value = 42;
    var token = 'first';
    final client = HtmlGameClient(
      base: base,
      token: () => token,
      client: MockClient((_) async {
        token = 'second';
        return http.Response('{"code":200,"data":{"coins":"999"}}', 200);
      }),
    );
    await client.refreshBalance();
    expect(StaticValue.coins.value, 42);
    client.dispose();
  });
}
