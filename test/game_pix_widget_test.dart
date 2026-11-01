import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/features/rooms/game_pix/controllers/game_pix_controller.dart';
import 'package:tom_chat/features/rooms/game_pix/models/game_pix_models.dart';
import 'package:tom_chat/features/rooms/game_pix/pages/game_bottom_sheet2.dart';
import 'package:tom_chat/features/rooms/game_pix/pages/game_pix_game_page.dart';
import 'package:tom_chat/features/rooms/models/room_model.dart';
import 'package:tom_chat/l10n/app_localizations.dart';
// The test replaces the native view at the plugin's public platform boundary.
// ignore: depend_on_referenced_packages
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class FakeWebPlatform extends WebViewPlatform {
  final controllers = <FakeWebController>[];
  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    final controller = FakeWebController(params);
    controllers.add(controller);
    return controller;
  }

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) => FakeNavigation(params);
  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) => FakeWebWidget(params);
}

class FakeWebWidget extends PlatformWebViewWidget {
  FakeWebWidget(super.params) : super.implementation();
  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

class FakeNavigation extends PlatformNavigationDelegate {
  FakeNavigation(super.params) : super.implementation();
  late NavigationRequestCallback navigation;
  late PageEventCallback started;
  late PageEventCallback finished;
  late WebResourceErrorCallback error;
  late HttpResponseErrorCallback httpError;
  @override
  Future<void> setOnNavigationRequest(
    NavigationRequestCallback callback,
  ) async {
    navigation = callback;
  }

  @override
  Future<void> setOnPageStarted(PageEventCallback callback) async {
    started = callback;
  }

  @override
  Future<void> setOnPageFinished(PageEventCallback callback) async {
    finished = callback;
  }

  @override
  Future<void> setOnProgress(ProgressCallback callback) async {}
  @override
  Future<void> setOnWebResourceError(WebResourceErrorCallback callback) async {
    error = callback;
  }

  @override
  Future<void> setOnHttpError(HttpResponseErrorCallback callback) async {
    httpError = callback;
  }
}

class FakeWebController extends PlatformWebViewController {
  FakeWebController(super.params) : super.implementation();
  late FakeNavigation delegate;
  Uri? loaded;
  bool history = false;
  int backs = 0;
  int reloads = 0;
  Completer<bool>? pendingBack;
  @override
  Future<void> setJavaScriptMode(JavaScriptMode mode) async {}
  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate handler,
  ) async {
    delegate = handler as FakeNavigation;
  }

  @override
  Future<void> loadRequest(LoadRequestParams params) async {
    loaded = params.uri;
    delegate.started(params.uri.toString());
    delegate.finished(params.uri.toString());
  }

  @override
  Future<bool> canGoBack() async =>
      pendingBack == null ? history : pendingBack!.future;
  @override
  Future<void> goBack() async {
    backs++;
    history = false;
  }

  @override
  Future<void> reload() async {
    reloads++;
    delegate.started(loaded.toString());
    delegate.finished(loaded.toString());
  }
}

const model = GamePixGameModel(
  id: '1',
  title: 'Test game',
  url: 'https://play.gamepix.com/game?sid=publisher',
);

class TestRoom extends RoomController {
  @override
  // This fake skips app services and native audio teardown.
  // ignore: must_call_super
  void onInit() {}
  @override
  // ignore: must_call_super
  void onClose() {}
}

Future<void> mount(
  WidgetTester tester,
  Widget page, {
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) => GetMaterialApp(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                isDismissible: false,
                enableDrag: false,
                builder: (_) => page,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  late FakeWebPlatform web;
  setUp(() {
    Get.testMode = true;
    web = FakeWebPlatform();
    WebViewPlatform.instance = web;
  });
  tearDown(() {
    Get.reset();
  });

  testWidgets('system back navigates history then closes only the game', (
    tester,
  ) async {
    await mount(tester, const GamePixGamePage(game: model));
    final controller = web.controllers.single;
    expect(controller.loaded!.queryParameters['lang'], 'en');
    controller.history = true;
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(controller.backs, 1);
    expect(find.byType(GamePixGamePage), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(GamePixGamePage), findsNothing);
    expect(find.text('Open'), findsOneWidget);
  });

  testWidgets('pending back after close cannot pop the underlying room', (
    tester,
  ) async {
    await mount(tester, const GamePixGamePage(game: model));
    final controller = web.controllers.single;
    controller.pendingBack = Completer<bool>();
    await tester.binding.handlePopRoute();
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    controller.pendingBack!.complete(false);
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'failed main page can retry; subresource failures do not hide game',
    (tester) async {
      await mount(tester, const GamePixGamePage(game: model));
      final controller = web.controllers.single;
      controller.delegate.error(
        WebResourceError(
          errorCode: -2,
          description: 'offline',
          isForMainFrame: false,
        ),
      );
      await tester.pump();
      expect(find.widgetWithText(TextButton, 'Retry'), findsNothing);
      controller.delegate.error(
        WebResourceError(
          errorCode: -2,
          description: 'offline',
          isForMainFrame: true,
        ),
      );
      await tester.pump();
      await tester.tap(find.widgetWithText(TextButton, 'Retry'));
      await tester.pumpAndSettle();
      expect(controller.reloads, 1);
      expect(find.widgetWithText(TextButton, 'Retry'), findsNothing);
      expect(
        await controller.delegate.navigation(
          const NavigationRequest(url: 'https://evil.test', isMainFrame: true),
        ),
        NavigationDecision.prevent,
      );
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      controller.delegate.error(
        WebResourceError(
          errorCode: -2,
          description: 'late',
          isForMainFrame: true,
        ),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('invalid launch never creates a WebView', (tester) async {
    await mount(
      tester,
      const GamePixGamePage(
        game: GamePixGameModel(
          id: 'bad',
          title: 'Bad',
          url: 'https://evil.test',
        ),
      ),
    );
    expect(web.controllers, isEmpty);
    expect(find.widgetWithText(TextButton, 'Retry'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
  });

  testWidgets(
    'stalled navigation times out and can be closed without a live timer',
    (tester) async {
      await mount(tester, const GamePixGamePage(game: model));
      web.controllers.single.delegate.started(model.url);
      await tester.pump(const Duration(seconds: 31));
      expect(find.widgetWithText(TextButton, 'Retry'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 31));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('small RTL layout and keyboard preserve close control', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await mount(
      tester,
      const GamePixGamePage(game: model),
      locale: const Locale('ar'),
    );
    tester.view.viewInsets = const FakeViewPadding(bottom: 200);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(web.controllers.single.loaded!.queryParameters['lang'], 'ar');
    expect(tester.takeException(), isNull);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
  });

  testWidgets('landscape game restores the application orientation policy', (
    tester,
  ) async {
    final orientations = <dynamic>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'SystemChrome.setPreferredOrientations') {
          orientations.add(call.arguments);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await mount(
      tester,
      const GamePixGamePage(
        game: GamePixGameModel(
          id: '1',
          title: 'Landscape',
          url: 'https://play.gamepix.com/game',
          orientation: 'landscape',
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(orientations.first, [
      'DeviceOrientation.landscapeLeft',
      'DeviceOrientation.landscapeRight',
    ]);
    expect(orientations.last, isEmpty);
  });

  testWidgets(
    'rapid game taps launch once, reopening works, room exit removes owned routes',
    (tester) async {
      // Registration without onInit avoids Agora/socket/production API calls.
      final room = TestRoom();
      room.room.value = RoomModel(id: 42);
      room.isRoomConnected.value = true;
      Get.put<RoomController>(room);
      final controller = GamePixController(
        loadConfig: () async => {'gamePixConfig': [], 'blocked_game_ids': []},
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'items': [
                {'id': '1', 'title': 'Test game', 'url': model.url},
              ],
            }),
            200,
          ),
        ),
      );
      await mount(
        tester,
        Games2BottomSheet(liveuid: '42', controller: controller),
      );
      final tap = tester
          .widget<InkWell>(
            find
                .ancestor(
                  of: find.text('Test game'),
                  matching: find.byType(InkWell),
                )
                .first,
          )
          .onTap!;
      tap();
      tap();
      await tester.pumpAndSettle();
      expect(web.controllers.length, 1);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      tap();
      await tester.pumpAndSettle();
      expect(web.controllers.length, 2);
      room.isRoomConnected.value = false;
      await tester.pumpAndSettle();
      expect(find.byType(GamePixGamePage), findsNothing);
      expect(find.byType(Games2BottomSheet), findsNothing);
      expect(find.text('Open'), findsOneWidget);
    },
  );
}
