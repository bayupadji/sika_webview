/// Kelas dasar untuk semua failure di aplikasi.
/// Digunakan di Domain layer sebagai representasi error yang tidak bergantung Flutter.
abstract class Failure {
  final String message;
  const Failure(this.message);
}

// ─── Connectivity Failures ────────────────────────────────────────────────

class NoInternetFailure extends Failure {
  const NoInternetFailure() : super('Tidak ada koneksi internet. Periksa jaringan Anda dan coba lagi.');
}

class ServerUnreachableFailure extends Failure {
  const ServerUnreachableFailure() : super('Server tidak dapat dijangkau. Coba lagi nanti.');
}

// ─── Security Failures ────────────────────────────────────────────────────

class MockLocationFailure extends Failure {
  const MockLocationFailure() : super('Akses aplikasi diblokir demi keamanan absensi.');
}

class DeveloperModeFailure extends Failure {
  const DeveloperModeFailure() : super('Nonaktifkan Developer Options untuk melanjutkan.');
}

class VpnFailure extends Failure {
  const VpnFailure() : super('Matikan VPN untuk menggunakan aplikasi.');
}

// ─── Platform Failures ────────────────────────────────────────────────────

class PlatformFailure extends Failure {
  const PlatformFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure() : super('Terjadi kesalahan tidak terduga.');
}
