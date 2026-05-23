/// Konstanta-konstanta aplikasi SIKA.
class AppConstants {
  AppConstants._();

  // ─── Method Channel Names ───────────────────────────────────────────────
  static const String securityChannel = 'com.sika.security';
  static const String downloadChannel = 'com.sika.download';

  // ─── App Info ───────────────────────────────────────────────────────────
  static const String appName = 'SIKA';

  // ─── App Colors (hex) ───────────────────────────────────────────────────
  static const int primaryColor = 0xFF10A9A4;
  static const int errorColor = 0xFFE53935;
  static const int warningColor = 0xFFFFA000;
  static const int textSecondaryColor = 0xFF828282;

  // ─── Security Messages ──────────────────────────────────────────────────
  static const String mockLocationTitle = 'Mock Location Detected';
  static const String mockLocationMessage =
      'Akses aplikasi diblokir demi keamanan absensi.';

  static const String developerModeTitle = 'Developer Mode Aktif';
  static const String developerModeMessage =
      'Nonaktifkan Developer Options untuk melanjutkan.';

  static const String vpnTitle = 'VPN Terdeteksi';
  static const String vpnMessage =
      'Matikan VPN untuk menggunakan aplikasi.';

  // ─── Connectivity Messages ──────────────────────────────────────────────
  static const String noInternetTitle = 'Tidak Ada Koneksi Internet';
  static const String noInternetMessage =
      'Periksa jaringan Anda dan coba lagi.';

  // ─── Assets ─────────────────────────────────────────────────────────────
  static const String logoAsset = 'assets/main_logo.png';
  static const String warningAsset = 'assets/warning.png';
}
