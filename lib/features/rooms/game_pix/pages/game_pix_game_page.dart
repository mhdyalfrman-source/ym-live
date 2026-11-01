import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/features/rooms/game_pix/controllers/game_pix_controller.dart';
import 'package:tom_chat/features/rooms/game_pix/models/game_pix_models.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GamePixGamePage extends StatefulWidget {
  const GamePixGamePage({super.key, required this.game});
  final GamePixGameModel game;

  @override
  State<GamePixGamePage> createState() => _GamePixGamePageState();
}

class _GamePixGamePageState extends State<GamePixGamePage> {
  WebViewController? _webViewController;
  Timer? _timeout;
  int _progress = 0;
  bool _failed = false;
  bool _closing = false;
  bool _handlingBack = false;
  bool _started = false;
  bool _configuring = false;
  bool _changedOrientation = false;
  Uri? _mainFrameUri;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      unawaited(_initialize());
    }
  }

  bool get _active => mounted && !_closing;

  Future<void> _initialize() async {
    if (_configuring || !_active) return;
    final uri = widget.game.launchUri(
      Localizations.localeOf(context).languageCode,
    );
    if (uri == null) {
      _fail();
      return;
    }
    _configuring = true;
    try {
      final orientation = widget.game.orientation?.toLowerCase().trim();
      if (!_changedOrientation &&
          (orientation == 'landscape' || orientation == 'portrait')) {
        _changedOrientation = true;
        await SystemChrome.setPreferredOrientations(
          orientation == 'landscape'
              ? [
                  DeviceOrientation.landscapeLeft,
                  DeviceOrientation.landscapeRight,
                ]
              : [DeviceOrientation.portraitUp],
        );
      }
      if (!_active) return;
      final controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (_active) setState(() => _progress = progress);
          },
          onPageStarted: (url) {
            if (_active) {
              _mainFrameUri = Uri.tryParse(url);
              _beginLoading();
            }
          },
          onPageFinished: (_) {
            if (!_active) return;
            _timeout?.cancel();
            setState(() => _progress = 100);
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == true) _fail();
          },
          onHttpError: (error) {
            // The cross-platform request has no isForMainFrame flag.
            if (error.request?.uri == _mainFrameUri && _mainFrameUri != null) {
              _fail();
            }
          },
          onNavigationRequest: (request) {
            if (!_active ||
                !GamePixController.isAllowedGameUri(
                  Uri.tryParse(request.url),
                )) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
      if (!_active) return;
      setState(() => _webViewController = controller);
      _mainFrameUri = uri;
      _beginLoading();
      await controller.loadRequest(uri);
    } catch (_) {
      _fail();
    } finally {
      _configuring = false;
    }
  }

  void _beginLoading() {
    _timeout?.cancel();
    setState(() {
      _failed = false;
      _progress = 0;
    });
    _timeout = Timer(const Duration(seconds: 30), _fail);
  }

  void _fail() {
    if (!_active) return;
    _timeout?.cancel();
    setState(() => _failed = true);
  }

  Future<void> _back() async {
    if (_handlingBack || !_active) return;
    _handlingBack = true;
    try {
      final controller = _webViewController;
      final canGoBack = controller != null && await controller.canGoBack();
      if (!mounted || !_active || ModalRoute.of(context)?.isCurrent != true) {
        return;
      }
      if (canGoBack) {
        await controller.goBack();
      } else {
        _close();
      }
    } catch (_) {
      if (_active) _close();
    } finally {
      _handlingBack = false;
    }
  }

  void _close() {
    if (!_active || ModalRoute.of(context)?.isCurrent != true) return;
    _closing = true;
    _timeout?.cancel();
    Navigator.of(context).pop();
  }

  Future<void> _reload() async {
    if (!_active || _configuring) return;
    final controller = _webViewController;
    if (controller == null) {
      await _initialize();
      return;
    }
    _beginLoading();
    try {
      await controller.reload();
    } catch (_) {
      _fail();
    }
  }

  @override
  void dispose() {
    _closing = true;
    _timeout?.cancel();
    // This app has no orientation lock outside GamePix.
    if (_changedOrientation) {
      unawaited(SystemChrome.setPreferredOrientations([]));
    }
    // WebViewWidget owns the platform view; there is no controller dispose API.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) unawaited(_back());
    },
    child: Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: CardWidget(
        radius: 10,
        colorIndex: 1,
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.8,
          child: SafeArea(
            child: Column(
              children: [
                AppBar(
                  title: Text(
                    widget.game.displayTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  leading: BackButton(onPressed: _back),
                  actions: [
                    IconButton(
                      tooltip: context.l10n.diceRetry,
                      onPressed: _reload,
                      icon: const Icon(Icons.refresh),
                    ),
                    IconButton(
                      tooltip: context.l10n.close,
                      onPressed: _close,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                if (!_failed && _progress < 100)
                  LinearProgressIndicator(
                    value: _progress == 0 ? null : _progress / 100,
                    minHeight: 2,
                    color: AppColors.primaryDark,
                  ),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_webViewController != null)
                        WebViewWidget(controller: _webViewController!),
                      if (_failed)
                        ColoredBox(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: Center(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    context.l10n.errorOcoredPleaseTryAgain,
                                    textAlign: TextAlign.center,
                                  ),
                                  TextButton(
                                    onPressed: _reload,
                                    child: Text(context.l10n.diceRetry),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
