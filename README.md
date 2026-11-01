# Tom Chat

Tom Chat is a Flutter live voice chat and social room application. It includes multi-seat audio rooms, real-time chat, profiles, followers, gifts, non-redeemable wallet balances, recharge packages, VIP and level systems, Firebase notifications, Agora RTC integration, and in-app purchase support.

## Requirements

- Flutter SDK 3.35 or newer with Dart 3.9 support.
- Android Studio or Xcode for release builds.
- Firebase project for Google Sign-In and push notifications.
- Agora project for voice rooms.
- PHP API, Node.js Socket.IO server, MySQL, Redis, and HTTPS backend configured from the included CodeCanyon package.

## Setup

1. Configure the backend first using `CodeCanyon_Package/Main_File/documentation/index.html`.
2. Add your Firebase Android and iOS client files.
3. Update API, socket, Agora, and product settings to match your production backend.
4. Confirm the Android package name and iOS bundle identifier both use `com_yoursoft.yaumi`, or replace both with your own unique identifier.
5. Configure release signing before building marketplace or store releases.
6. Run `flutter pub get`, test the login, room, wallet, and purchase flows, then build the release app.

## Build

```bash
flutter pub get
flutter build appbundle --release
```
