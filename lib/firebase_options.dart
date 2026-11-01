// File generated manually based on provided Firebase config.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web is not configured in the provided Firebase data.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'iOS not provided in the supplied Firebase configuration.',
        );
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Platform not configured in provided Firebase data.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  /// ANDROID OPTIONS (tomchat)

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBV2F0dYyKpQ2uuJLY06qvNezqFUGnYSy8',
    appId: '1:310234338475:android:d376e3fc3821d50e53d3ee',
    messagingSenderId: '310234338475',
    projectId: 'yaumi-1',
    storageBucket: 'yaumi-1.firebasestorage.app',
  );
}
