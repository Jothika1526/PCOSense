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
    apiKey: 'AIzaSyBklx0zmy2t5h-NKIF2VHVIKqba9ISdPJU',
    appId: '1:442128213942:web:724d081b255e0d079e4317',
    messagingSenderId: '442128213942',
    projectId: 'pcos-app-firebase',
    authDomain: 'pcos-app-firebase.firebaseapp.com',
    storageBucket: 'pcos-app-firebase.firebasestorage.app',
    measurementId: 'G-LLGSMJP0GS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDGJpxuTim8Fzjso0-NLa_BkHSN8wB74J8',
    appId: '1:442128213942:android:514c644905e548739e4317',
    messagingSenderId: '442128213942',
    projectId: 'pcos-app-firebase',
    storageBucket: 'pcos-app-firebase.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB-BLM7aTl0S0RQu1I3QwI9EXbgbO8f1U8',
    appId: '1:442128213942:ios:26944252cb674a7a9e4317',
    messagingSenderId: '442128213942',
    projectId: 'pcos-app-firebase',
    storageBucket: 'pcos-app-firebase.firebasestorage.app',
    iosBundleId: 'com.example.pcosApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB-BLM7aTl0S0RQu1I3QwI9EXbgbO8f1U8',
    appId: '1:442128213942:ios:26944252cb674a7a9e4317',
    messagingSenderId: '442128213942',
    projectId: 'pcos-app-firebase',
    storageBucket: 'pcos-app-firebase.firebasestorage.app',
    iosBundleId: 'com.example.pcosApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBklx0zmy2t5h-NKIF2VHVIKqba9ISdPJU',
    appId: '1:442128213942:web:02e14251d9e225569e4317',
    messagingSenderId: '442128213942',
    projectId: 'pcos-app-firebase',
    authDomain: 'pcos-app-firebase.firebaseapp.com',
    storageBucket: 'pcos-app-firebase.firebasestorage.app',
    measurementId: 'G-5YQJS31GLC',
  );
}
