import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service untuk mengelola runtime permissions.
/// Dipanggil oleh presentation layer, bukan dari provider langsung.
class PermissionService {
  /// Minta semua permission yang dibutuhkan aplikasi sebelum masuk WebView.
  Future<void> requestRequiredPermissions() async {
    final statuses = await [
      Permission.location,
      Permission.camera,
      Permission.storage,
    ].request();

    if (kDebugMode) {
      statuses.forEach((permission, status) {
        debugPrint('[PermissionService] $permission → $status');
      });
    }

    // Jika storage ditolak permanen, buka app settings
    if (statuses[Permission.storage]?.isPermanentlyDenied ?? false) {
      if (kDebugMode) {
        debugPrint('[PermissionService] Storage permanently denied. Opening settings.');
      }
      await openAppSettings();
    }
  }
}
