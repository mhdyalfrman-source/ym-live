import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tom_chat/features/rooms/html_games/html_game_overlay.dart';
import 'package:tom_chat/l10n/app_localizations.dart';

void main() {
  testWidgets(
    'half-screen overlay captures upper taps; cancel retains child and back confirms',
    (tester) async {
      tester.view.reset();
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      var roomTaps = 0, leaves = 0;
      final gameKey = GlobalKey();
      final overlayKey = GlobalKey<HtmlGameOverlayState>();
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Stack(
            children: [
              GestureDetector(
                onTap: () => roomTaps++,
                child: const SizedBox.expand(),
              ),
              HtmlGameOverlay(
                key: overlayKey,
                onLeave: () => leaves++,
                child: StatefulBuilder(
                  key: gameKey,
                  builder: (_, __) => const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
      );
      final state = gameKey.currentState;
      expect(
        tester
            .getRect(find.byKey(const ValueKey('game-transparent-area')))
            .height,
        422,
      );
      await tester.tapAt(const Offset(50, 100));
      await tester.pump();
      expect(roomTaps, 0);
      expect(find.text('هل تريد مغادرة اللعبة؟'), findsOneWidget);
      await tester.tap(find.text('البقاء'));
      await tester.pump();
      expect(gameKey.currentState, same(state));
      expect(leaves, 0);
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(find.text('هل تريد مغادرة اللعبة؟'), findsOneWidget);
      await tester.tap(find.text('البقاء'));
      await tester.pump();
      overlayKey.currentState!.requestClose();
      await tester.pump();
      await tester.tap(find.text('مغادرة'));
      await tester.pumpAndSettle();
      expect(leaves, 1);
      expect(roomTaps, 0);
    },
  );
}
