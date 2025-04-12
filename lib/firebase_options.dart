import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Firebase is not configured for web. Please add web configuration if needed.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android; // Android configuration
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDSpx1kUC_6af-QexYAKIO9to9OeBs5k0g',
    appId: '1:358973831552:android:cbf1137918fc95079b2965',
    messagingSenderId: '358973831552',
    projectId: 'healthmate-85b15',
    storageBucket: 'healthmate-85b15.appspot.com',
  );
}
