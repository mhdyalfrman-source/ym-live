import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tom_chat/main.dart';
import 'package:tom_chat/statics_values.dart';

Future<String> getToken() async {
  try {
    final firebaseMessaging = FirebaseMessaging.instance;
    String? result = "";
    await firebaseMessaging.requestPermission();
    // FirebaseMessaging.instance.deleteToken();
    // await FirebaseMessaging.instance.subscribeToTopic("allsystem");
    // await FirebaseMessaging.instance.subscribeToTopic(StaticValue.userData.userType!.name);
    // await FirebaseMessaging.instance.subscribeToTopic(StaticValue.userData.userType!.name + StaticValue.userData.institution!.institutionId!.toString());
    // if(u.userToken == null || u.userToken == ""){
    result = await FirebaseMessaging.instance.getToken();
    // }
    return result ?? "";
  } catch (e) {
    return "";
  }
}

void handleNotification(BuildContext context) {
  // swipToPage(context,UserNotificationScreen());
}

class MessagingConfig {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      sound: RawResourceAndroidNotificationSound('custom_sound'),
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  static Future<void> initFirebaseMessaging() async {
    await createNotificationChannel();

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: false,
          requestBadgePermission: false,
          requestAlertPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse payload) {
        handleNotification(navigatorKey.currentContext!);
        return;
      },
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
    } else {}

    FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
      try {
        RemoteNotification? notification = event.notification;
        // AndroidNotification? android = event.notification?.android;

        if (notification == null) {
          return;
        }

        var body = notification.body;

        await flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            body,
            NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              channelDescription:
                  'This channel is used for important notifications.',
              sound: RawResourceAndroidNotificationSound('custom_sound'),
              icon: '@mipmap/ic_launcher',
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              sound: 'custom_sound.caf',
            ),
          ),
        );

        // handleNotification(navigatorKey.currentContext!, event.data);
      } catch (err) {}
    });

    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        StaticValue.fromNote = true;
        handleNotification(navigatorKey.currentContext!);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      StaticValue.fromNote = true;
      handleNotification(navigatorKey.currentContext!);
    });
  }

  @pragma('vm:entry-point')
  static Future<void> messageHandler(RemoteMessage message) async {
    StaticValue.fromNote = true;
  }
}
