import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAPlC9v-4QuyHQ_DdSYtaUtWrMLoLi0roQ',
    appId: '1:511222243354:web:your_web_app_id_here', // Thy ơi, bà điền Web App ID vào đây nha!
    messagingSenderId: '511222243354',
    projectId: 'nutrifit-c6cf2',
    authDomain: 'nutrifit-c6cf2.firebaseapp.com',
    storageBucket: 'nutrifit-c6cf2.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAPlC9v-4QuyHQ_DdSYtaUtWrMLoLi0roQ',
    appId: '1:511222243354:android:f3f65cd1ca4ccd129e71a3',
    messagingSenderId: '511222243354',
    projectId: 'nutrifit-c6cf2',
    storageBucket: 'nutrifit-c6cf2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAPlC9v-4QuyHQ_DdSYtaUtWrMLoLi0roQ',
    appId: '1:511222243354:ios:your_ios_app_id_here',
    messagingSenderId: '511222243354',
    projectId: 'nutrifit-c6cf2',
    storageBucket: 'nutrifit-c6cf2.firebasestorage.app',
    iosBundleId: 'com.example.nutrifit',
  );
}
