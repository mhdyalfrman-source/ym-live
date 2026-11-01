import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tom_chat/features/rooms/game_pix/controllers/game_pix_controller.dart';
import 'package:tom_chat/features/rooms/game_pix/models/game_pix_models.dart';

Map<String, dynamic> config() => {
  'gamePixConfig': [
    {'key': '', 'label': 'All'},
    {'key': 'puzzle', 'label': 'Puzzle'},
  ],
  'blocked_game_ids': ['blocked'],
};

Map<String, dynamic> game(String id, {String? url}) => {
  'id': id,
  'url': url ?? 'https://play.gamepix.com/$id?sid=publisher',
};

http.Response feed(List<Map<String, dynamic>> games, {String? next}) =>
    http.Response(jsonEncode({'items': games, 'next_url': next}), 200);

const nextPage = 'https://feeds.gamepix.com/v2/json/?page=2';

void main() {
  test('first-page failure can retry after categories have loaded', () async {
    var calls = 0;
    final controller = GamePixController(
      loadConfig: () async => config(),
      client: MockClient(
        (_) async => ++calls == 1
            ? http.Response('unavailable', 503)
            : feed([game('ok')]),
      ),
    );
    addTearDown(controller.onClose);
    await controller.loadInitial(fallbackAllLabel: 'All');
    expect(controller.errorMessage.value, isNotEmpty);
    await controller.retry(fallbackAllLabel: 'All');
    expect(controller.games.single.id, 'ok');
    expect(controller.errorMessage.value, isEmpty);
  });

  test('failed config does not fetch an unblocked public feed', () async {
    var configCalls = 0;
    var feedCalls = 0;
    final controller = GamePixController(
      loadConfig: () async => ++configCalls == 1 ? {} : config(),
      client: MockClient((_) async {
        feedCalls++;
        return feed([game('ok')]);
      }),
    );
    addTearDown(controller.onClose);
    await controller.loadInitial(fallbackAllLabel: 'All');
    expect(feedCalls, 0);
    expect(controller.errorMessage.value, isNotEmpty);
    await controller.retry(fallbackAllLabel: 'All');
    expect(feedCalls, 1);
  });

  for (final operation in ['pagination', 'refresh']) {
    test(
      'category switch resets $operation and discards its stale result',
      () async {
        final delayed = Completer<http.Response>();
        var calls = 0;
        final controller = GamePixController(
          loadConfig: () async => config(),
          client: MockClient((_) async {
            calls++;
            if (calls == 2) return delayed.future;
            return feed([game('game$calls')], next: nextPage);
          }),
        );
        addTearDown(controller.onClose);
        await controller.loadInitial(fallbackAllLabel: 'All');
        final pending = operation == 'pagination'
            ? controller.loadMore()
            : controller.refreshGames();
        await controller.selectCategory(controller.categories.last);
        delayed.complete(feed([game('stale')]));
        await pending;
        expect(controller.isPageLoading.value, isFalse);
        expect(controller.isRefreshing.value, isFalse);
        expect(controller.games.map((g) => g.id), ['game3']);
        await controller.loadMore();
        expect(controller.games.map((g) => g.id), ['game3', 'game4']);
      },
    );
  }

  test('duplicate initial loads share one pending configuration', () async {
    final pending = Completer<Map<String, dynamic>>();
    var calls = 0;
    final controller = GamePixController(
      loadConfig: () {
        calls++;
        return pending.future;
      },
      client: MockClient((_) async => feed([])),
    );
    addTearDown(controller.onClose);
    final first = controller.loadInitial(fallbackAllLabel: 'All');
    await controller.loadInitial(fallbackAllLabel: 'All');
    expect(calls, 1);
    pending.complete(config());
    await first;
  });

  test(
    'disposing before configuration returns prevents feed and state writes',
    () async {
      final pending = Completer<Map<String, dynamic>>();
      var calls = 0;
      final controller = GamePixController(
        loadConfig: () => pending.future,
        client: MockClient((_) async {
          calls++;
          return feed([]);
        }),
      );
      final load = controller.loadInitial(fallbackAllLabel: 'All');
      controller.onClose();
      pending.complete(config());
      await load;
      expect(calls, 0);
      expect(controller.categories, isEmpty);
    },
  );

  test('disposing before feed returns prevents stale games', () async {
    final pending = Completer<http.Response>();
    final started = Completer<void>();
    final controller = GamePixController(
      loadConfig: () async => config(),
      client: MockClient((_) {
        started.complete();
        return pending.future;
      }),
    );
    final load = controller.loadInitial(fallbackAllLabel: 'All');
    await started.future;
    controller.onClose();
    pending.complete(feed([game('late')]));
    await load;
    expect(controller.games, isEmpty);
  });

  test(
    'feed keeps provider order, deduplicates and filters blocked/unsafe games',
    () async {
      final controller = GamePixController(
        loadConfig: () async => config(),
        client: MockClient(
          (_) async => feed([
            game('b'),
            game('blocked'),
            game('a'),
            game('b'),
            game('bad', url: 'https://gamepix.com.evil.test/play'),
            game('http', url: 'http://play.gamepix.com/play'),
            game(''),
          ]),
        ),
      );
      addTearDown(controller.onClose);
      await controller.loadInitial(fallbackAllLabel: 'All');
      expect(controller.games.map((g) => g.id), ['b', 'a']);
    },
  );

  test(
    'empty filtered page remains pageable; repeating next URL terminates',
    () async {
      var calls = 0;
      final controller = GamePixController(
        loadConfig: () async => config(),
        client: MockClient(
          (_) async => ++calls == 1
              ? feed([game('blocked')], next: nextPage)
              : feed([game('ok')], next: nextPage),
        ),
      );
      addTearDown(controller.onClose);
      await controller.loadInitial(fallbackAllLabel: 'All');
      expect(controller.games, isEmpty);
      expect(controller.hasMore.value, isTrue);
      await controller.loadMore();
      expect(controller.games.single.id, 'ok');
      expect(controller.hasMore.value, isFalse);
    },
  );

  test('pagination rejects non-feed destinations', () async {
    final controller = GamePixController(
      loadConfig: () async => config(),
      client: MockClient(
        (_) async => feed([], next: 'https://play.gamepix.com/play'),
      ),
    );
    addTearDown(controller.onClose);
    await controller.loadInitial(fallbackAllLabel: 'All');
    expect(controller.hasMore.value, isFalse);
  });

  test('launch preserves game/attribution and passes selected language', () {
    final model = GamePixGameModel.fromJson({
      ...game(
        '42',
        url: 'https://play.gamepix.com/game?sid=publisher&mode=a&mode=b#board',
      ),
      'banner_image': 'not-a-url',
      'image': 'https://img.gamepix.com/icon.png',
    });
    final uri = model.launchUri('ar')!;
    expect(uri.queryParameters['lang'], 'ar');
    expect(uri.queryParameters['sid'], 'publisher');
    expect(uri.queryParametersAll['mode'], ['a', 'b']);
    expect(uri.fragment, 'board');
    expect(model.cardImage, 'https://img.gamepix.com/icon.png');
    expect(model.displayTitle, '42');
  });

  test(
    'launch rejects credentials, non-HTTPS, foreign origins and custom ports',
    () {
      for (final url in [
        'javascript:alert(1)',
        'http://gamepix.com/game',
        'https://gamepix.com.evil.test/game',
        'https://user:pass@gamepix.com/game',
        'https://gamepix.com:8443/game',
        'https://evil.test/game',
        '',
      ]) {
        expect(GamePixController.isAllowedGameUri(Uri.tryParse(url)), isFalse);
        expect(
          GamePixGameModel.fromJson(game('42', url: url)).launchUri('en'),
          isNull,
        );
      }
    },
  );
}
