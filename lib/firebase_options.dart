// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
    apiKey: 'AIzaSyAnmBpin-yemKGt65tSK84PyUpyvtZIk-c',
    appId: '1:232805926692:web:269de0b2e8d2ac8e3a15b1',
    messagingSenderId: '232805926692',
    projectId: 'mr-taxi-6653a',
    authDomain: 'mr-taxi-6653a.firebaseapp.com',
    storageBucket: 'mr-taxi-6653a.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAcX0nkLLWDd__6UAMx2sVNUEvUr8cJvL8',
    appId: '1:232805926692:android:6317a2ea1ca282393a15b1',
    messagingSenderId: '232805926692',
    projectId: 'mr-taxi-6653a',
    storageBucket: 'mr-taxi-6653a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBXaFRswx2RUTm7k18Fh5Vu5a1mzA9XlbI',
    appId: '1:232805926692:ios:24c3fca80bb545633a15b1',
    messagingSenderId: '232805926692',
    projectId: 'mr-taxi-6653a',
    storageBucket: 'mr-taxi-6653a.appspot.com',
    iosClientId: '232805926692-k5j2rsv983hegi9nq76aha9ir6u84n3g.apps.googleusercontent.com',
    iosBundleId: 'com.example.uberProject',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBXaFRswx2RUTm7k18Fh5Vu5a1mzA9XlbI',
    appId: '1:232805926692:ios:24c3fca80bb545633a15b1',
    messagingSenderId: '232805926692',
    projectId: 'mr-taxi-6653a',
    storageBucket: 'mr-taxi-6653a.appspot.com',
    iosClientId: '232805926692-k5j2rsv983hegi9nq76aha9ir6u84n3g.apps.googleusercontent.com',
    iosBundleId: 'com.example.uberProject',
  );
}
