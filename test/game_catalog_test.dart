import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/features/rooms/models/game_model.dart';
import 'package:tom_chat/features/rooms/html_games/html_game_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/features/rooms/bottom_sheets/games_bottom_sheet.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/features/rooms/html_games/html_game_overlay.dart';
import 'package:tom_chat/l10n/app_localizations.dart';
import 'package:tom_chat/statics_values.dart';

class CatalogRoom extends RoomController {
  @override
  Future<void> fetchGames(int type) async {
    games.assignAll(
      GameModel.listFromResponse({
        'games': [
          {
            'gid': 421,
            'name': 'Catalog supplied title',
            'icon': '',
            'url': '${CallServerAPI.com}custom/dice.html?mode=room#board',
          },
        ],
      }),
    );
  }
}

void main() {
  testWidgets(
    'API-fed menu displays supplied title and selects the half-screen launcher',
    (tester) async {
      Get.testMode = true;
      final room = CatalogRoom();
      StaticValue.coins.value = 123;
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, __) => GetMaterialApp(
            locale: const Locale('en'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => GamesBottomSheet(controller: room),
                  ),
                  child: const Text('Catalog'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Catalog'));
      await tester.pumpAndSettle();
      expect(find.text('Catalog supplied title'), findsOneWidget);
      expect(find.text('Dice'), findsNothing);
      await tester.tap(find.text('Catalog supplied title'));
      await tester.pumpAndSettle();
      expect(find.byType(HtmlGameOverlay), findsOneWidget);
      expect(find.text('Please sign in again to play.'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('game-transparent-area')));
      await tester.pumpAndSettle();
      expect(find.text('Do you want to leave the game?'), findsOneWidget);
      await tester.tap(find.text('Leave'));
      await tester.pumpAndSettle();
      expect(find.byType(HtmlGameOverlay), findsNothing);
      expect(StaticValue.coins.value, 123);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      Get.reset();
    },
  );
  test(
    'catalog uses API records and accepts both existing response shapes',
    () {
      final rows = [
        {
          'id': 421,
          'name': 'Database game name',
          'icon': '${CallServerAPI.com}html-games/dice/emblem.svg',
          'url': '${CallServerAPI.com}custom/dice.html?mode=room#board',
        },
      ];
      for (final key in ['games', 'list']) {
        final games = GameModel.listFromResponse({key: rows});
        expect(games.length, 1);
        expect(games.single.gid, 421);
        expect(games.single.name, 'Database game name');
        expect(
          games.single.url,
          '${CallServerAPI.com}custom/dice.html?mode=room#board',
        );
        expect(
          games.single.icon,
          '${CallServerAPI.com}html-games/dice/emblem.svg',
        );
      }
      expect(GameModel.listFromResponse({'games': []}), isEmpty);
      expect(GameModel.listFromResponse({}), isEmpty);
    },
  );
  test(
    'provider games keep their identifiers/URLs and are not inferred from a name',
    () {
      final game = GameModel.fromJson({
        'gid': 77,
        'name': 'Dice',
        'url': 'https://provider.test/play',
        'icon': 'https://provider.test/icon.png',
      });
      expect(game.gid, 77);
      expect(game.url, 'https://provider.test/play');
    },
  );
  test(
    'selected catalog identifier drives authenticated launch without a separate list',
    () async {
      final base = Uri.parse(CallServerAPI.com);
      final game = GameModel.fromJson({
        'gid': 9001,
        'name': 'Server title',
        'url': '${CallServerAPI.com}custom/dice.html?mode=room#board',
      });
      final client = HtmlGameClient(
        base: base,
        webToken: () => 'a' * 64,
        client: MockClient(
          (_) async => throw StateError('No registry request'),
        ),
      );
      final launch = await client.launch(game);
      expect(launch.gid, 9001);
      expect(launch.entry.toString(), game.url);
      expect(launch.webToken, 'a' * 64);
      client.dispose();
    },
  );
}
