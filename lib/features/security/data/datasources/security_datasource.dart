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
  // Menggunakan kombinasi Android Native (via MethodChannel) +
  // detect_fake_location plugin untuk double validation.

  Future<bool> isMockLocationEnabled() async {
    try {
      // Layer 1: Native Android API via MethodChannel
      final nativeResult = await _channel.invokeMethod<bool>('isMockLocationEnabled');
      final nativeMock = nativeResult ?? false;

      // Layer 2: detect_fake_location plugin
      bool pluginMock = false;
      try {
        pluginMock = await DetectFakeLocation().detectFakeLocation();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[SecurityDatasource] detect_fake_location error: $e');
        }
      }

      final isMock = nativeMock || pluginMock;
      if (kDebugMode) {
        debugPrint(
          '[SecurityDatasource] Mock location: native=$nativeMock, plugin=$pluginMock, final=$isMock',
        );
      }
      return isMock;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('[SecurityDatasource] Mock location check error: ${e.message}');
      }
      // Fallback ke plugin saja jika native gagal
      try {
        return await DetectFakeLocation().detectFakeLocation();
      } catch (_) {
        return false;
      }
    }
  }
}
