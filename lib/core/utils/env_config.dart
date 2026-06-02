import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Utility untuk membaca URL dari file .env.
class EnvConfig {
  EnvConfig._(); // Non-instantiable

  /// URL produksi dari .env.
  static String get prodUrl => dotenv.env['PROD_URL'] ?? '';

  /// URL development dari .env.
  static String get devUrl => dotenv.env['DEV_URL'] ?? '';
}
