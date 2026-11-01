import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GameViewer2 extends StatefulWidget {
  const GameViewer2({
    super.key,
    required this.gameUrl,
    required this.gameId,
    required this.appId,
    required this.appKey,
    required this.token,
    this.roomNum = '1',
    this.lang = 'ar',
  });

  final String gameUrl;
  final String gameId;
  final String appId;
  final String appKey;
  final String token;
  final String roomNum;
  final String lang;

  @override
  State<GameViewer2> createState() => _GameViewer2State();
}

class _GameViewer2State extends State<GameViewer2> {
  late final WebViewController _controller;
  var _bridgeSent = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) => _injectBootstrapIfNeeded(),
        ),
      )
      ..loadRequest(Uri.parse(widget.gameUrl));
  }

  Future<void> _injectBootstrapIfNeeded() async {
    if (_bridgeSent) return;
    _bridgeSent = true;

    final payload = <String, dynamic>{
      'game_id': widget.gameId,
      'app_id': widget.appId,
      'app_key': widget.appKey,
      'token': widget.token,
      'room_num': widget.roomNum,
      'lang': widget.lang,
    };

    final jsonText = jsonEncode(payload);
    final js =
        '''
(function(){
  try {
    if (typeof bootstrapGamesFromBridge !== 'function') {
      console.error('bootstrapGamesFromBridge غير معرّف — تأكد أن المسار /games');
      return;
    }
    var ok = bootstrapGamesFromBridge($jsonText);
  } catch (e) {
    console.error(e);
  }
})();
''';

    await _controller.runJavaScript(js);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: WebViewWidget(controller: _controller),
        ),
      ),
    );
  }
}
