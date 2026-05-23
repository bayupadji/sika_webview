import 'dart:async';

import 'package:detect_fake_location/detect_fake_location.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;

/// Helper untuk manajemen lokasi dan streaming koordinat ke WebView.
///
/// Dipindahkan ke shared/helpers agar separation of concerns terjaga.
/// LocationHelper bukan Provider — ia tidak manage state UI.
class LocationHelper {
  final Function(double lat, double lng) onLocationUpdate;
  final VoidCallback onMockDetected;

  loc.Location _location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;
  bool _isMockDetected = false;

  LocationHelper({
    required this.onLocationUpdate,
    required this.onMockDetected,
  });

  bool get isMockDetected => _isMockDetected;

  /// Inisialisasi: cek mock location → ambil lokasi awal → mulai stream.
  Future<void> initialize(BuildContext context) async {
    // Cek mock location terlebih dahulu
    final isMock = await _checkMockLocation();
    if (isMock) {
      _isMockDetected = true;
      if (context.mounted) {
        onMockDetected();
      }
      return;
    }

    // Ambil lokasi awal
    await _fetchInitialLocation();

    // Mulai streaming real-time
    await _startLocationStream();
  }

  Future<bool> _checkMockLocation() async {
    try {
      return await DetectFakeLocation().detectFakeLocation();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocationHelper] Mock check error: $e');
      }
      return false;
    }
  }

  Future<void> _fetchInitialLocation() async {
    try {
      final locationData = await _location.getLocation();
      final lat = locationData.latitude ?? 0.0;
      final lng = locationData.longitude ?? 0.0;
      if (kDebugMode) {
        debugPrint('[LocationHelper] Initial location: $lat, $lng');
      }
      onLocationUpdate(lat, lng);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocationHelper] Initial location error: $e');
      }
    }
  }

  Future<void> _startLocationStream() async {
    await _locationSubscription?.cancel();

    try {
      await _location.changeSettings(
        accuracy: loc.LocationAccuracy.high,
        interval: 3000,
        distanceFilter: 5,
      );

      _locationSubscription = _location.onLocationChanged.listen(
        (loc.LocationData data) async {
          // Cek native mock flag
          final nativeMock = data.isMock ?? false;

          // Cek ulang via plugin
          bool pluginMock = false;
          try {
            pluginMock = await DetectFakeLocation().detectFakeLocation();
          } catch (_) {}

          if (nativeMock || pluginMock) {
            _isMockDetected = true;
            if (kDebugMode) {
              debugPrint('[LocationHelper] Mock detected during stream!');
            }
            await stop();
            onMockDetected();
            return;
          }

          final lat = data.latitude ?? 0.0;
          final lng = data.longitude ?? 0.0;
          onLocationUpdate(lat, lng);
        },
        onError: (e) {
          if (kDebugMode) {
            debugPrint('[LocationHelper] Stream error: $e');
          }
        },
      );

      if (kDebugMode) {
        debugPrint('[LocationHelper] Location streaming started.');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocationHelper] Start stream error: $e');
      }
    }
  }

  Future<void> stop() async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;
    if (kDebugMode) {
      debugPrint('[LocationHelper] Location streaming stopped.');
    }
  }

  void dispose() {
    stop();
  }
}
