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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDx9C_YiKUDIHNNc4akLgaQ7xi9CebAcWM',
    appId: '1:374192322509:web:7cb0daf0b6d03516ec7684',
    messagingSenderId: '374192322509',
    projectId: 'postify-52231',
    authDomain: 'postify-52231.firebaseapp.com',
    storageBucket: 'postify-52231.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDx9C_YiKUDIHNNc4akLgaQ7xi9CebAcWM',
    appId: '1:374192322509:android:7cb0daf0b6d03516ec7684',
    messagingSenderId: '374192322509',
    projectId: 'postify-52231',
    authDomain: 'postify-52231.firebaseapp.com',
    storageBucket: 'postify-52231.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDx9C_YiKUDIHNNc4akLgaQ7xi9CebAcWM',
    appId: '1:374192322509:ios:7cb0daf0b6d03516ec7684',
    messagingSenderId: '374192322509',
    projectId: 'postify-52231',
    authDomain: 'postify-52231.firebaseapp.com',
    storageBucket: 'postify-52231.firebasestorage.app',
    iosBundleId: 'com.example.postify',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDx9C_YiKUDIHNNc4akLgaQ7xi9CebAcWM',
    appId: '1:374192322509:ios:7cb0daf0b6d03516ec7684',
    messagingSenderId: '374192322509',
    projectId: 'postify-52231',
    authDomain: 'postify-52231.firebaseapp.com',
    storageBucket: 'postify-52231.firebasestorage.app',
    iosBundleId: 'com.example.postify',
  );
}