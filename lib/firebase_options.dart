// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBCB13k63VjRtU7O1DDjVJpaRZO6sf5LhI',
    appId: '1:163873675525:web:fd5048e4af6011b7937f6c',
    messagingSenderId: '163873675525',
    projectId: 'purelux-2bdcd',
    authDomain: 'purelux-2bdcd.firebaseapp.com',
    storageBucket: 'purelux-2bdcd.firebasestorage.app',
    measurementId: 'G-7QQ178C1VG',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDV1Z0eODmNAfXE_h0Z6c6UH9Q7V-MMH4Y',
    appId: '1:163873675525:android:9f9ec59a56364687937f6c',
    messagingSenderId: '163873675525',
    projectId: 'purelux-2bdcd',
    storageBucket: 'purelux-2bdcd.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA-jUzOKQJ4b2P9OUaaTFbY6FIVkiTyk8E',
    appId: '1:163873675525:ios:5b55ebf2e960cdfc937f6c',
    messagingSenderId: '163873675525',
    projectId: 'purelux-2bdcd',
    storageBucket: 'purelux-2bdcd.firebasestorage.app',
    iosBundleId: 'com.example.purelux',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA-jUzOKQJ4b2P9OUaaTFbY6FIVkiTyk8E',
    appId: '1:163873675525:ios:5b55ebf2e960cdfc937f6c',
    messagingSenderId: '163873675525',
    projectId: 'purelux-2bdcd',
    storageBucket: 'purelux-2bdcd.firebasestorage.app',
    iosBundleId: 'com.example.purelux',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBCB13k63VjRtU7O1DDjVJpaRZO6sf5LhI',
    appId: '1:163873675525:web:8973ad557ca81e5f937f6c',
    messagingSenderId: '163873675525',
    projectId: 'purelux-2bdcd',
    authDomain: 'purelux-2bdcd.firebaseapp.com',
    storageBucket: 'purelux-2bdcd.firebasestorage.app',
    measurementId: 'G-4KBDSVLXZL',
  );
}
