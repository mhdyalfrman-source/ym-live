import 'dart:async';
import 'package:tom_chat/features/rooms/models/game_model.dart';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tom_chat/features/rooms/html_games/html_game_client.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/features/rooms/html_games/html_game_overlay.dart';

/// A transparent route keeps the existing room and its audio connection mounted.
Future<void> openHtmlGame(GameModel game) async {
  final client = HtmlGameClient();
  try {
    await showGeneralDialog<void>(
      context: Get.context!,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, animation, secondaryAnimation) =>
          _HtmlGameScreen(game: game, client: client),
    );
  } finally {
    try {
      await client.refreshBalance();
    } on HtmlGameException {
      final context = Get.context;
      if (context != null && context.mounted) {
        Get.snackbar(context.l10n.diceTitle, context.l10n.diceNetwork);
      }
    } finally {
      client.dispose();
    }
  }
}

class _HtmlGameScreen extends StatefulWidget {
  const _HtmlGameScreen({required this.game, required this.client});
  final GameModel game;
  final HtmlGameClient client;
  @override
  State<_HtmlGameScreen> createState() => _HtmlGameScreenState();
}

class _HtmlGameScreenState extends State<_HtmlGameScreen> {
  final _overlay = GlobalKey<HtmlGameOverlayState>();
  WebViewController? _web;
  Timer? _timeout;
  String? _error;
  String _nonce = '';
  bool _loading = true,
      _injected = false,
      _refreshing = false,
      _closing = false;
  bool _refreshPending = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  void _fail(String message) {
    if (!mounted || _closing) return;
    _timeout?.cancel();
    setState(() {
      _error = message;
      _loading = false;
    });
  }

  Future<void> _load() async {
    final generation = ++_generation;
    _timeout?.cancel();
    setState(() {
      _loading = true;
      _error = null;
      _injected = false;
      _web = null;
    });
    try {
      final launch = await widget.client.launch(widget.game);
      if (!mounted || generation != _generation || _closing) {
        return;
      }
      _nonce = List.generate(
        16,
        (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
      ).join();
      final controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.addJavaScriptChannel(
        'TomChatGameBridge',
        onMessageReceived: (message) {
          if (generation == _generation) {
            unawaited(_message(message.message, controller, launch));
          }
        },
      );
      await controller.setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) =>
              request.isMainFrame &&
                  Uri.tryParse(request.url) == launch.entry &&
                  generation == _generation
              ? NavigationDecision.navigate
              : NavigationDecision.prevent,
          onPageStarted: (_) {
            if (_injected && generation == _generation) {
              _fail('network');
            }
          },
          onPageFinished: (url) async {
            if (!mounted ||
                generation != _generation ||
                _injected ||
                _error != null ||
                Uri.tryParse(url) != launch.entry ||
                await controller.currentUrl() != launch.entry.toString()) {
              return;
            }
            if (!mounted || generation != _generation || _closing) return;
            _injected = true;
            final payload = jsonEncode({
              'gid': launch.gid,
              'api_url': launch.api.toString(),
              'web_token': launch.webToken,
              'bridge_nonce': _nonce,
              'locale': Localizations.localeOf(context).toLanguageTag(),
            });
            launch.webToken = '';
            try {
              await controller.runJavaScript(
                'window.TomChatGames.initialize($payload).catch(function(){})',
              );
            } catch (_) {
              _fail('network');
            }
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == true && generation == _generation) {
              _fail('network');
            }
          },
        ),
      );
      if (!mounted || generation != _generation || _closing) return;
      setState(() => _web = controller);
      _timeout = Timer(const Duration(seconds: 30), () => _fail('network'));
      await controller.loadRequest(
        launch.entry,
      ); // No app token, web token or API key in URL/headers.
    } on HtmlGameException catch (error) {
      if (!mounted || _closing) return;
      _fail(error.code.contains('auth') ? 'auth' : 'network');
    } catch (_) {
      if (!mounted || _closing) return;
      _fail('network');
    }
  }

  Future<void> _refreshBalance() async {
    if (_closing) return;
    if (_refreshing) {
      _refreshPending = true;
      return;
    }
    _refreshing = true;
    try {
      do {
        _refreshPending = false;
        await widget.client.refreshBalance();
      } while (_refreshPending && !_closing && mounted);
    } on HtmlGameException catch (error) {
      if (!mounted || _closing) return;
      _fail(error.code.contains('auth') ? 'auth' : 'network');
    } finally {
      _refreshing = false;
    }
  }

  Future<void> _message(
    String raw,
    WebViewController controller,
    HtmlGameLaunch launch,
  ) async {
    final type = parseHtmlGameMessage(raw, _nonce);
    if (type == null ||
        !mounted ||
        _closing ||
        _web != controller ||
        await controller.currentUrl() != launch.entry.toString()) {
      return;
    }
    if (!mounted || _closing || _web != controller) return;
    switch (type) {
      case 'ready':
        _timeout?.cancel();
        setState(() {
          _loading = false;
        });
      case 'wallet_changed':
        await _refreshBalance();
      case 'auth_error':
        _fail('auth');
      case 'load_error':
        _fail('network');
      case 'close':
        _overlay.currentState?.requestClose();
    }
  }

  Future<void> _close() async {
    if (_closing) return;
    _closing = true;
    _generation++;
    _timeout?.cancel();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _generation++;
    _timeout?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => HtmlGameOverlay(
    key: _overlay,
    onLeave: () => unawaited(_close()),
    child: Stack(
      fit: StackFit.expand,
      children: [
        if (_error != null)
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _error == 'auth'
                          ? context.l10n.diceAuth
                          : context.l10n.diceNetwork,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _load,
                      child: Text(context.l10n.diceRetry),
                    ),
                  ],
                ),
              ),
            ),
          )
        else ...[
          if (_web != null) WebViewWidget(controller: _web!),
          if (_loading)
            const ColoredBox(
              color: Color(0xff102b30),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
        if (_loading || _error != null)
          PositionedDirectional(
            top: 4,
            end: 4,
            child: IconButton(
              tooltip: context.l10n.diceClose,
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => _overlay.currentState?.requestClose(),
            ),
          ),
      ],
    ),
  );
}
