// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
// import 'package:tom_chat/l10n/l10n.dart';
// import 'package:tom_chat/statics_values.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:webview_flutter_android/webview_flutter_android.dart';

// class GameScreen extends StatefulWidget {
//   final int roomId;
//   final String url;
//   final int gameType;

//   const GameScreen({
//     super.key,
//     required this.url,
//     required this.roomId,
//     required this.gameType,
//   });

//   @override
//   State<GameScreen> createState() => _GameScreenState();
// }

// class _GameScreenState extends State<GameScreen> {
//   WebViewController? controller;
//   EventChannel? _eventChannelPlugin;
//   bool isLoading = true;
//   bool _hasValidUrl = false;
//   late RoomController roomController;

//   @override
//   void initState() {
//     super.initState();
//     _initializeWebView();
//     roomController = Get.find();
//   }

//   void _initializeWebView() {

//     if (widget.url.isEmpty ||
//         widget.url == 'null' ||
//         !widget.url.startsWith('http')) {
//       setState(() {
//         isLoading = false;
//         _hasValidUrl = false;
//       });
//       return;
//     }

//     _hasValidUrl = true;
//     controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setBackgroundColor(Colors.transparent)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageStarted: (url) {
//             if (mounted) {
//               setState(() => isLoading = true);
//             }
//           },
//           onPageFinished: (url) async {
//             if (mounted) {
//               setState(() => isLoading = false);
//             }
//           },
//           onWebResourceError: (error) {
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse(widget.url));

//     if (Platform.isAndroid) {
//       _setupAndroid();
//     } else if (Platform.isIOS) {
//       _setupIOS();
//     }
//   }

//   void _setupAndroid() {
//     if (controller == null) return;

//     AndroidWebViewController.enableDebugging(true);
//     (controller!.platform as AndroidWebViewController)
//         .setMediaPlaybackRequiresUserGesture(false);
//     _eventChannelPlugin = const EventChannel('baishunChannel');
//     _eventChannelPlugin!.receiveBroadcastStream().listen(_handleNativeEvent);
//   }

//   void _setupIOS() {
//     if (controller == null) return;

//     controller!.addJavaScriptChannel(
//       'getConfig',
//       onMessageReceived: (message) {
//         _handleGetConfig(message.message);
//       },
//     );

//     controller!.addJavaScriptChannel(
//       'sendGameAction',
//       onMessageReceived: (message) {
//         handleGameAction(json.decode(message.message));
//       },
//     );

//     controller!.addJavaScriptChannel(
//       'destroy',
//       onMessageReceived: (message) {
//         _handleDestroy();
//       },
//     );

//     controller!.addJavaScriptChannel(
//       'gameRecharge',
//       onMessageReceived: (message) {
//         _handleGameRecharge();
//       },
//     );

//     controller!.addJavaScriptChannel(
//       'gameLoaded',
//       onMessageReceived: (message) {
//         _handleGameLoaded();
//       },
//     );
//   }

//   void _handleNativeEvent(dynamic event) {
//     try {
//       final obj = json.decode(event);
//       final jsFunName = obj['jsCallback'] as String;

//       if (jsFunName.contains('getConfig')) {
//         _handleGetConfig(event);
//       } else if (jsFunName.contains('destroy')) {
//         _handleDestroy();
//       } else if (jsFunName.contains('gameRecharge')) {
//         _handleGameRecharge();
//       } else if (jsFunName.contains('gameLoaded')) {
//         _handleGameLoaded();
//       } else if (jsFunName.contains('sendGameAction')) {
//         handleGameAction(obj);
//       }
//     } catch (e) {}
//   }

//   void _handleGetConfig(String event) async {
//     if (controller == null) return;

//     try {
//       final obj = json.decode(event);
//       final jsFunName = obj['jsCallback'];
//       final config = roomController.gameConfig.value;

//       final configData = {
//         "appChannel": config.appChannel,
//         "appId": config.appId,
//         "userId": config.userId,
//         "gameMode": widget.gameType == 2 ? 3 : config.gameMode,
//         "language": config.language,
//         "gsp": widget.gameType == 2 ? 101 : config.gsp,
//         "roomId": config.roomId,
//         "code": config.code,
//         "gameRoomId": "${config.roomId}",
//         "role": roomController.currentUserIsHost.value ? 2 : 0,
//         "gameConfig": {
//           "sceneMode": config.gameConfig!.sceneMode,
//           "currencyIcon": config.gameConfig!.currencyIcon,
//         }
//       };

//       final jsCall = '$jsFunName(${jsonEncode(configData)})';
//       await controller!.runJavaScript(jsCall);
//     } catch (e) {
//     }
//   }

//   void _handleDestroy() async {
//     try {
//       if (controller != null) {
//         await controller!.loadRequest(Uri.parse('about:blank'));
//         await controller!.clearCache();
//       }
//       roomController.unselectGame();
//       if (mounted) {
//         Navigator.of(context).pop();
//       }
//     } catch (e) {
//     }
//   }

//   void _handleGameRecharge() {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('فتح صفحة الشحن...'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//     }
//   }

//   void _handleGameLoaded() {
//     if (mounted) {
//       setState(() => isLoading = false);
//     }
//   }

//   void handleGameAction(Map<String, dynamic> data) {
//     // if(data["params"]?["userId"] != null){
//     //   int id = MyMath.toInt(data["params"]?["userId"]);
//     //   bool userInGust = seats.any((s)=>s.user?.id == id);
//     //   if(!userInGust){
//     //     if(id == widget.controller.room.value.currentUserInfo?.id){
//     //       updateUserRoleInGame(widget.controller.room.value.currentUserInfo?.id??0, 1);
//     //     }
//     //     return;
//     //   }

//     // }
//     final int type = data['type'];
//     final params = data['params'];

//     // if(data["params"]?["seats"] != null && data["params"]?["seats"] is List){
//     //   bool newState = (data["params"]?["seats"] as List).any((s)=>s["userId"].toString() == StaticValues.userData.userId.currentUserInfo?.id.toString());
//     //   if(widget.controller.forceStopScrolling.value != newState){
//     //     widget.controller.forceStopScrolling.value = newState;
//     //   }
//     // }

//     switch (type) {
//       case 15:
//         _onSeatChange(params);
//         break;

//       case 17:
//         _onKickRequest(params);
//         break;

//       case 14:
//         break;
//     }
//   }

//   void _onSeatChange(Map params) {
//     _sendGameActionUpdate({
//       "type": 4,
//       "params": params,
//     });
//   }

//   void _onKickRequest(Map params) {
//     _sendGameActionUpdate({
//       "type": 6,
//       "params": {
//         "optResult": 0,
//         "optUserId": StaticValue.userData.userId,
//         "userId": params['userId'],
//         "reason": "success"
//       }
//     });
//   }

//   void _sendGameActionUpdate(Map payload) {
//     final js = "gameActionUpdate(${jsonEncode(payload)})";
//     controller?.runJavaScript(js);
//   }

//   @override
//   Widget build(BuildContext context) {
//     // ❌ إذا الـ URL مش صحيح
//     if (!_hasValidUrl) {
//       return Container(
//         color: Colors.transparent,
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.error_outline, color: Colors.red, size: 64),
//               SizedBox(height: 20),
//               Text(
//                 'Invalid Game URL',
//                 style: TextStyle(color: Colors.white, fontSize: 18),
//               ),
//               SizedBox(height: 10),
//               Text(
//                 'URL: ${widget.url}',
//                 style: TextStyle(color: Colors.white70, fontSize: 12),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return PopScope(
//       canPop: false,
//       onPopInvoked: (didPop) {
//         if (!didPop) {
//           _handleDestroy();
//         }
//       },
//       child: SafeArea(
//         child: Container(
//           color: Colors.transparent,
//           child: Stack(
//             children: [
//               Positioned.fill(
//                 child: WebViewWidget(controller: controller!),
//               ),
//               if (isLoading)
//                 Container(
//                   color: Colors.transparent,
//                   child: Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         CircularProgressIndicator(color: Colors.white),
//                         SizedBox(height: 20),
//                         Text(
//                           context.l10n.loading,
//                           style: TextStyle(color: Colors.white, fontSize: 16),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     if (controller != null) {
//       controller!.clearCache();
//       controller!.loadRequest(Uri.parse('about:blank'));
//     }
//     roomController.unselectGame();
//     super.dispose();
//   }
// }
