import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:sika/core/errors/failures.dart';

/// Datasource untuk konektivitas internet.
/// Melakukan dua tahap validasi:
///   1. Network availability check (WiFi/Mobile Data)
///   2. Actual internet reachability check
class ConnectivityDatasource {
  final Connectivity _connectivity;
  final InternetConnectionChecker _connectionChecker;

  ConnectivityDatasource({
    Connectivity? connectivity,
    InternetConnectionChecker? connectionChecker,
  })  : _connectivity = connectivity ?? Connectivity(),
        _connectionChecker = connectionChecker ?? InternetConnectionChecker.instance;

  /// Cek network availability terlebih dahulu,
  /// lalu verifikasi actual internet access.
  Future<bool> isInternetAvailable() async {
    try {
      // Tahap 1: Cek apakah ada network (WiFi/Mobile)
      final connectivityResult = await _connectivity.checkConnectivity();
      final hasNetwork = connectivityResult.isNotEmpty &&
          !connectivityResult.every((r) => r == ConnectivityResult.none);

      if (!hasNetwork) {
        if (kDebugMode) {
          debugPrint('[ConnectivityDatasource] No network available.');
        }
        throw const NoInternetFailure();
      }

      // Tahap 2: Cek actual internet reachability
      final isReachable = await _connectionChecker.hasConnection;
      if (!isReachable) {
        if (kDebugMode) {
          debugPrint('[ConnectivityDatasource] Network available but no internet (captive portal?).');
        }
        throw const NoInternetFailure();
      }

      if (kDebugMode) {
        debugPrint('[ConnectivityDatasource] Internet available and reachable.');
      }
      return true;
    } on Failure {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ConnectivityDatasource] Unexpected error: $e');
      }
      throw const UnknownFailure();
    }
  }
}
