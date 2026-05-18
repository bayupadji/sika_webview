import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Utility untuk mendekripsi URL yang tersimpan terenkripsi di file .env.
///
/// Enkripsi menggunakan AES-256-CBC.
/// Format nilai di .env: <iv_base64>:<ciphertext_base64>
///
/// Untuk menghasilkan nilai terenkripsi baru, jalankan:
///   dart run tools/encrypt_url.dart
class EnvConfig {
  EnvConfig._(); // Non-instantiable

  // Key AES-256 (32 byte) dipecah menjadi 4 bagian agar tidak mudah
  // ditemukan sebagai satu string di dalam binary APK/IPA.
  static const String _p1 = 'S1k4R5k1';
  static const String _p2 = 'W3bV13wK';
  static const String _p3 = '3yAp0L0g';
  static const String _p4 = 'y2024Sec';

  static enc.Key get _key => enc.Key.fromUtf8('$_p1$_p2$_p3$_p4');

  /// Dekripsi nilai dari .env.
  /// Mengembalikan string kosong jika gagal (nilai tidak valid / korup).
  static String _decrypt(String? encoded) {
    if (encoded == null || encoded.isEmpty) return '';
    try {
      final parts = encoded.split(':');
      if (parts.length != 2) return '';
      final iv = enc.IV.fromBase64(parts[0]);
      final encrypter = enc.Encrypter(enc.AES(_key, mode: enc.AESMode.cbc));
      return encrypter.decrypt64(parts[1], iv: iv);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[EnvConfig] Dekripsi gagal: $e');
      }
      return '';
    }
  }

  /// URL produksi (sudah didekripsi).
  static String get prodUrl => _decrypt(dotenv.env['PROD_URL']);

  /// URL development (sudah didekripsi).
  static String get devUrl => _decrypt(dotenv.env['DEV_URL']);
}
