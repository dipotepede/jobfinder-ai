import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions have not been configured for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD_vAX_1n4y4t2kAcimO4drj7IY6wjrklo',
    appId: '1:168276976762:web:a8a750625292539ef107c3',
    messagingSenderId: '168276976762',
    projectId: 'jobfinder-dipotepede',
    authDomain: 'jobfinder-dipotepede.firebaseapp.com',
    storageBucket: 'jobfinder-dipotepede.firebasestorage.app',
    measurementId: 'G-3EL4J2DH20',
  );
}