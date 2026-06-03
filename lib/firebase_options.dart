import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAzcWhRnnIB_cLB5gnJjs2o7t2gPq2zFW0',
    appId: '1:740161840744:web:e45497870a77f2bf12fddd',
    messagingSenderId: '740161840744',
    projectId: 'fittrack-pro-99812',
    authDomain: 'fittrack-pro-99812.firebaseapp.com',
    storageBucket: 'fittrack-pro-99812.firebasestorage.app',
  );
}
