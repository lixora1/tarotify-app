// Bu dosya Firebase Console'dan otomatik oluşturulur:
// Firebase Console → Proje Ayarları → Uygulamanı Ekle → Android → google-services.json indir
// Sonra: flutterfire configure komutu bu dosyayı otomatik oluşturur.

// firebase_options.dart — ÖRNEK ŞABLON
// Gerçek değerleri firebase_options.dart dosyanızdan alın.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('Bu platform desteklenmiyor.');
    }
  }

  // ⚠️ Bu değerleri Firebase Console'dan kopyalayın (google-services.json)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
  );
}
