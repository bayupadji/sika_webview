
import 'dart:async';

import 'package:detect_fake_location/detect_fake_location.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:sika/views/error_page.dart';

class LocationProvider with ChangeNotifier {
  loc.Location location = loc.Location();
  bool _isMockLocationDetected = false;
  loc.LocationData? _locationData;
  StreamSubscription<loc.LocationData>? _locationSubscription;

  // Callback yang akan dipanggil setiap kali lokasi berubah
  // Digunakan oleh PwaWebView untuk mengirim update ke WebView
  Function(double lat, double lng)? onLocationUpdate;

  bool get isMockLocationDetected => _isMockLocationDetected;
  loc.LocationData? get locationData => _locationData;

  Future<void> checkAndFetchLocation(BuildContext context) async {
    try {
      // Periksa apakah mock location diaktifkan
      final bool isMock = await DetectFakeLocation().detectFakeLocation();
      _isMockLocationDetected = isMock;

      if (isMock) {
        if (kDebugMode) {
          print('Mock location detected. Location access denied.');
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ErrorPage(
              title: "GPS Palsu Terdeteksi",
              descriptions:
                  "Nonaktifkan Mock Location di pengaturan perangkat Anda.",
              image: "assets/warning.png",
              onPressed: () {
                Navigator.pop(context);
              },
              btnLabel: "Kembali",
            ),
          ),
        );
        return; // Berhenti jika mock location terdeteksi
      }

      // Ambil data lokasi pertama kali
      _locationData = await location.getLocation();
      if (kDebugMode) {
        print(
          'Initial Location: ${_locationData?.latitude}, ${_locationData?.longitude}',
        );
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching location: $e');
      }
    }
  }

  /// Mulai streaming lokasi real-time.
  /// Setiap update lokasi akan memanggil [onLocationUpdate] jika sudah di-set.
  Future<void> startLocationStream() async {
    // Pastikan tidak ada stream yang berjalan sebelumnya
    await _locationSubscription?.cancel();

    try {
      // Konfigurasi location untuk update yang lebih responsif
      await location.changeSettings(
        accuracy: loc.LocationAccuracy.high,
        interval: 3000, // update setiap 3 detik
        distanceFilter: 5, // hanya update jika bergerak > 5 meter
      );

      _locationSubscription = location.onLocationChanged.listen(
        (loc.LocationData newLocation) async {
          // Cek flag isMock dari native Android (tersedia di Android 6+)
          final bool nativeMock = newLocation.isMock ?? false;

          // Cek ulang via detect_fake_location setiap update
          bool pluginMock = false;
          try {
            pluginMock = await DetectFakeLocation().detectFakeLocation();
          } catch (_) {}

          if (nativeMock || pluginMock) {
            _isMockLocationDetected = true;
            if (kDebugMode) {
              print('[LocationProvider] Mock location detected on stream update!');
            }
            // Hentikan stream dan beri tahu listener
            await stopLocationStream();
            notifyListeners();
            return;
          }

          _locationData = newLocation;
          notifyListeners();

          final lat = newLocation.latitude ?? 0.0;
          final lng = newLocation.longitude ?? 0.0;

          if (kDebugMode) {
            print('Location Update: $lat, $lng');
          }

          // Kirim update ke WebView jika callback sudah di-set
          onLocationUpdate?.call(lat, lng);
        },
        onError: (error) {
          if (kDebugMode) {
            print('Location stream error: $error');
          }
        },
      );

      if (kDebugMode) {
        print('Location streaming started.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error starting location stream: $e');
      }
    }
  }

  /// Hentikan streaming lokasi dan bersihkan subscription.
  Future<void> stopLocationStream() async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;
    onLocationUpdate = null;

    if (kDebugMode) {
      print('Location streaming stopped.');
    }
  }

  @override
  void dispose() {
    stopLocationStream();
    super.dispose();
  }
}
