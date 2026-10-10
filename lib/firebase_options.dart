import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for Universtree.
///
/// Note: To connect your specific Firebase project console:
/// Replace the placeholders below with your project credentials from the
/// Firebase Console -> Project Settings -> General -> Your Apps.
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
          'you can reconfigure this by running the FlutterFire CLI.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCwmJGaz3tK17wDLciGK26kLeOXAi1cpc8',
    appId: '1:517782171043:web:588caf766c4a8efe3dbe16',
    messagingSenderId: '517782171043',
    projectId: 'universtree-3d91e',
    authDomain: 'universtree-3d91e.firebaseapp.com',
    databaseURL: 'https://universtree-3d91e-default-rtdb.firebaseio.com',
    storageBucket: 'universtree-3d91e.firebasestorage.app',
    measurementId: 'G-82S65JY81E',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBdcvzTjEAuRT8iEG1SiIPTsc-15nJVTuo',
    appId: '1:517782171043:android:8c75a168698373293dbe16',
    messagingSenderId: '517782171043',
    projectId: 'universtree-3d91e',
    databaseURL: 'https://universtree-3d91e-default-rtdb.firebaseio.com',
    storageBucket: 'universtree-3d91e.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB41tQ4knTNiT-p6u1F1o168MjcJy_Sud4',
    appId: '1:517782171043:ios:5d39bce0506c3e9c3dbe16',
    messagingSenderId: '517782171043',
    projectId: 'universtree-3d91e',
    databaseURL: 'https://universtree-3d91e-default-rtdb.firebaseio.com',
    storageBucket: 'universtree-3d91e.firebasestorage.app',
    androidClientId: '517782171043-oq5i6jkcqf69kta25vdf0ql5vdk7a46k.apps.googleusercontent.com',
    iosClientId: '517782171043-6u0itig1uurtbk8hf4hnv2ksi575kjcc.apps.googleusercontent.com',
    iosBundleId: 'com.example.universtree',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB41tQ4knTNiT-p6u1F1o168MjcJy_Sud4',
    appId: '1:517782171043:ios:5d39bce0506c3e9c3dbe16',
    messagingSenderId: '517782171043',
    projectId: 'universtree-3d91e',
    databaseURL: 'https://universtree-3d91e-default-rtdb.firebaseio.com',
    storageBucket: 'universtree-3d91e.firebasestorage.app',
    androidClientId: '517782171043-oq5i6jkcqf69kta25vdf0ql5vdk7a46k.apps.googleusercontent.com',
    iosClientId: '517782171043-6u0itig1uurtbk8hf4hnv2ksi575kjcc.apps.googleusercontent.com',
    iosBundleId: 'com.example.universtree',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCwmJGaz3tK17wDLciGK26kLeOXAi1cpc8',
    appId: '1:517782171043:web:3283c5ba663df5bd3dbe16',
    messagingSenderId: '517782171043',
    projectId: 'universtree-3d91e',
    authDomain: 'universtree-3d91e.firebaseapp.com',
    databaseURL: 'https://universtree-3d91e-default-rtdb.firebaseio.com',
    storageBucket: 'universtree-3d91e.firebasestorage.app',
    measurementId: 'G-JW7ERXCWJ1',
  );
}
