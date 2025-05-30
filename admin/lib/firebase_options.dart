// File generated by FlutterFire CLI.
// This file is used to configure Firebase for your Flutter app.

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
        return android; // Use android for linux temporarily
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBkAbhRedFqlUEUYUVmm__6LRf4rt4quhs',
    appId: '1:339978807673:web:cfbec39a5405b3b4f5e7a8',
    messagingSenderId: '339978807673',
    projectId: 'loanadmin-b1f26',
    authDomain: 'loanadmin-b1f26.firebaseapp.com',
    storageBucket: 'loanadmin-b1f26.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBkAbhRedFqlUEUYUVmm__6LRf4rt4quhs',
    appId: '1:339978807673:android:cfbec39a5405b3b4f5e7a8',
    messagingSenderId: '339978807673',
    projectId: 'loanadmin-b1f26',
    storageBucket: 'loanadmin-b1f26.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBkAbhRedFqlUEUYUVmm__6LRf4rt4quhs',
    appId: '1:339978807673:ios:cfbec39a5405b3b4f5e7a8',
    messagingSenderId: '339978807673',
    projectId: 'loanadmin-b1f26',
    storageBucket: 'loanadmin-b1f26.firebasestorage.app',
    iosBundleId: 'com.loanbee.admin.loan_admin',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBkAbhRedFqlUEUYUVmm__6LRf4rt4quhs',
    appId: '1:339978807673:macos:cfbec39a5405b3b4f5e7a8',
    messagingSenderId: '339978807673',
    projectId: 'loanadmin-b1f26',
    storageBucket: 'loanadmin-b1f26.firebasestorage.app',
    iosBundleId: 'com.loanbee.admin.loan_admin',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBkAbhRedFqlUEUYUVmm__6LRf4rt4quhs',
    appId: '1:339978807673:web:cfbec39a5405b3b4f5e7a8',
    messagingSenderId: '339978807673',
    projectId: 'loanadmin-b1f26',
    authDomain: 'loanadmin-b1f26.firebaseapp.com',
    storageBucket: 'loanadmin-b1f26.firebasestorage.app',
  );
} 