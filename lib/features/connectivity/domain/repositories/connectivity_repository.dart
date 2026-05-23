import 'package:sika/core/errors/failures.dart';

/// Contract repository untuk pengecekan koneksi internet.
/// Domain layer — pure Dart, tidak bergantung Flutter maupun package eksternal.
abstract class ConnectivityRepository {
  /// Mengembalikan [true] jika internet tersedia dan reachable.
  /// Melempar [NoInternetFailure] jika tidak ada koneksi.
  /// Melempar [ServerUnreachableFailure] jika server SIKA tidak dapat dijangkau.
  Future<bool> isInternetAvailable();
}
