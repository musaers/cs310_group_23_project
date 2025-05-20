import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: "AIzaSyAzt76uf3ayEA6KJnIta0C8z2LWnWBTh0U",
    appId: "1:604550870067:web:317a66f24d903fb7181f46",
    messagingSenderId: "604550870067",
    projectId: "su-gym",
    authDomain: "su-gym.firebaseapp.com",
    storageBucket: "su-gym.firebasestorage.app",
    measurementId: "G-JNLHGMHT1X",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAzt76uf3ayEA6KJnIta0C8z2LWnWBTh0U',
    appId: 'x',
    messagingSenderId: 'x',
    projectId: 'su-gym',
    storageBucket: 'su-gym.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey:
        'AIzaSyBoMDk7Hrbxsn3opbqOU-0pjEBI2vyJ9so', // Your API key is already filled
    appId:
        '1:604550870067:ios:b2d1a91853f46f5b181f46', // This is already correct
    messagingSenderId: '604550870067', // Replace 'x' with this value
    projectId: 'su-gym', // This is already correct
    storageBucket: 'su-gym.appspot.com', // This is already correct
    iosClientId:
        '604550870067-ios-b2d1a91853f46f5b181f46', // Replace 'x' with this value
    iosBundleId: 'com.example.suGym', // This is already correct
  );
}
