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
        throw UnsupportedError(
          'DefaultFirebaseOptions has not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions has not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDeyjfjkhaPuO9yypSSjFPJ4WQtUWZjyz4',
    appId: '1:177104812289:android:e668ecd67d6c0250b54300',
    messagingSenderId: '177104812289',
    projectId: 'destiny-decoder-6b571',
    storageBucket: 'destiny-decoder-6b571.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',  // Add when you configure iOS
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: '177104812289',
    projectId: 'destiny-decoder-6b571',
    storageBucket: 'destiny-decoder-6b571.firebasestorage.app',
    iosBundleId: 'com.example.destinyDecoderApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: '177104812289',
    projectId: 'destiny-decoder-6b571',
    storageBucket: 'destiny-decoder-6b571.firebasestorage.app',
    iosBundleId: 'com.example.destinyDecoderApp',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: '177104812289',
    projectId: 'destiny-decoder-6b571',
    storageBucket: 'destiny-decoder-6b571.firebasestorage.app',
  );
}
