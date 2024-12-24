import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBpRKG9jm72n7-szD5YczXvmvxkMrDZl0w',
    appId: '1:995757362115:web:efb6ce72e5d2ad0c034b76',
    messagingSenderId: '995757362115',
    projectId: 'sudoku-6ce70',
    authDomain: 'sudoku-6ce70.firebaseapp.com',
    storageBucket: 'sudoku-6ce70.firebasestorage.app',
    measurementId: 'G-LZPVZLRRWL',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBpRKG9jm72n7-szD5YczXvmvxkMrDZl0w',
    appId: '1:995757362115:web:13e4b1ac5e7bdc72034b76',
    messagingSenderId: '995757362115',
    projectId: 'sudoku-6ce70',
    authDomain: 'sudoku-6ce70.firebaseapp.com',
    storageBucket: 'sudoku-6ce70.firebasestorage.app',
    measurementId: 'G-W9KH1W0N0B',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAwBpPB7XFMcCD9Jv-eYT8JVpllovmC0lk',
    appId: '1:995757362115:android:8dfdcf2d8f2f2908034b76',
    messagingSenderId: '995757362115',
    projectId: 'sudoku-6ce70',
    storageBucket: 'sudoku-6ce70.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAj_KkSub-KjOwUB4jaiWy5lge8QwNpS1o',
    appId: '1:995757362115:ios:503ae57192e9b82b034b76',
    messagingSenderId: '995757362115',
    projectId: 'sudoku-6ce70',
    storageBucket: 'sudoku-6ce70.firebasestorage.app',
    iosBundleId: 'com.example.proect',
  );

} 