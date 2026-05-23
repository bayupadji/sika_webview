// ignore_for_file: avoid_print

// Tool untuk menghasilkan nilai terenkripsi untuk dimasukkan ke file .env
// Jalankan dengan: dart run tools/encrypt_url.dart
//
// PENTING: Key harus SAMA persis dengan yang ada di lib/utils/env_config.dart

import 'package:encrypt/encrypt.dart' as enc;

void main() {
  // Key 32 karakter = AES-256 — harus identik dengan EnvConfig._key
  const p1 = 'S1k4R5k1';
  const p2 = 'W3bV13wK';
  const p3 = '3yAp0L0g';
  const p4 = 'y2024Sec';
  final key = enc.Key.fromUtf8('$p1$p2$p3$p4');

  // URL yang ingin dienkripsi
  final urls = {
    'PROD_URL': 'https://sikarski.cloud/',
    'DEV_URL': 'https://rski-karyawan.netlify.app',
  };

  print('# ==========================================');
  print('# Salin nilai berikut ke file .env Anda:');
  print('# ==========================================\n');

  urls.forEach((envKey, url) {
    // Gunakan IV acak yang unik untuk setiap URL
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(url, iv: iv);
    // Format: <iv_base64>:<ciphertext_base64>
    print('$envKey=${iv.base64}:${encrypted.base64}');
  });

  print('\n# ==========================================');
  print('# JANGAN commit nilai plaintext ke repository!');
  print('# ==========================================');
}
