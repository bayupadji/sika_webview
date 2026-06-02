import 'package:detect_fake_location/detect_fake_location.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sika/core/constants/app_constants.dart';
import 'package:sika/core/errors/failures.dart';

/// Datasource untuk pemeriksaan keamanan perangkat via Android Native API.
///
/// MethodChannel HANYA boleh berada di sini (antigravity.md: features/security/data/datasources/).
class SecurityDatasource {
  static const _channel = MethodChannel(AppConstants.securityChannel);

  // ─── VPN Detection ─────────────────────────────────────────────────────

  Future<bool> isVpnActive() async {
    try {
      final result = await _channel.invokeMethod<bool>('isVpnActive');
      final isActive = result ?? false;
      if (kDebugMode) {
        debugPrint('[SecurityDatasource] VPN active: $isActive');
      }
      return isActive;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('[SecurityDatasource] VPN check error: ${e.message}');
      }
      throw PlatformFailure('VPN check failed: ${e.message}');
    }
  }

  // ─── Developer Mode Detection ──────────────────────────────────────────

  Future<bool> isDeveloperModeEnabled() async {
    try {
      final result = await _channel.invokeMethod<bool>('isDeveloperModeEnabled');
      final isEnabled = result ?? false;
      if (kDebugMode) {
        debugPrint('[SecurityDatasource] Developer mode enabled: $isEnabled');
      }
      return isEnabled;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('[SecurityDatasource] Developer mode check error: ${e.message}');
      }
      throw PlatformFailure('Developer mode check failed: ${e.message}');
    }
  }

  // ─── Mock Location Detection ───────────────────────────────────────────
  // Andalkan native channel (yang sekarang sudah conservative/tidak
  // false-positive). Plugin detect_fake_location hanya fallback jika native error.
  // Deteksi real-time mock dilakukan di LocationHelper via LocationData.isMock.

  Future<bool> isMockLocationEnabled() async {
    try {
      final nativeResult = await _channel.invokeMethod<bool>('isMockLocationEnabled');
      final nativeMock = nativeResult ?? false;
      if (kDebugMode) {
        debugPrint('[SecurityDatasource] Mock location (native): $nativeMock');
      }
      return nativeMock;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('[SecurityDatasource] Mock location native error: ${e.message}');
      }
      // Fallback ke plugin jika native gagal
      try {
        final pluginResult = await DetectFakeLocation().detectFakeLocation();
        if (kDebugMode) {
          debugPrint('[SecurityDatasource] Mock location (plugin fallback): $pluginResult');
        }
        return pluginResult;
      } catch (_) {
        return false;
      }
    }
  }
}
