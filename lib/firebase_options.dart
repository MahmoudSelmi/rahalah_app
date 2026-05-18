import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.macOS:
        return android;
      case TargetPlatform.iOS:
        return android;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA_Ek_YIWbfwBXsOsbyVXU3QCp6fIOstRk',
    appId: '1:868335486548:android:cdf53697d79b13f3d0cfc1',
    messagingSenderId: '868335486548',
    projectId: 'rahalah-app',
    storageBucket: 'rahalah-app.firebasestorage.app',
  );
}