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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDZ8EYZOM330WxW7e5yWut8BkpexKAqYDY",
    authDomain: "mis-lab-3-221037.firebaseapp.com",
    projectId: "mis-lab-3-221037",
    storageBucket: "mis-lab-3-221037.firebasestorage.app",
    messagingSenderId: "223270406672",
    appId: "1:223270406672:web:6fe64ce30e53083930d895",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDZ8EYZOM330WxW7e5yWut8BkpexKAqYDY",
    authDomain: "mis-lab-3-221037.firebaseapp.com",
    projectId: "mis-lab-3-221037",
    storageBucket: "mis-lab-3-221037.firebasestorage.app",
    messagingSenderId: "223270406672",
    appId: "1:223270406672:web:6fe64ce30e53083930d895",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyDZ8EYZOM330WxW7e5yWut8BkpexKAqYDY",
    authDomain: "mis-lab-3-221037.firebaseapp.com",
    projectId: "mis-lab-3-221037",
    storageBucket: "mis-lab-3-221037.firebasestorage.app",
    messagingSenderId: "223270406672",
    appId: "1:223270406672:web:6fe64ce30e53083930d895",
  );
}
