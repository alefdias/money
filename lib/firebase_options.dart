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
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCLGTzD3BaEAi7ZRXb7u7nchIY24Vm1e8s',
    appId: '1:134959488780:android:b23059820c6d48dbb03329',
    messagingSenderId: '134959488780',
    projectId: 'money-28b22',
    storageBucket: 'money-28b22.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCLGTzD3BaEAi7ZRXb7u7nchIY24Vm1e8s',
    appId: '1:134959488780:android:b23059820c6d48dbb03329',
    messagingSenderId: '134959488780',
    projectId: 'money-28b22',
    storageBucket: 'money-28b22.firebasestorage.app',
  );
}
