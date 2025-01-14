// ignore_for_file: use_build_context_synchronously

import 'package:detect_fake_location/detect_fake_location.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:sika/views/error_page.dart';

class LocationProvider with ChangeNotifier {
  loc.Location location = loc.Location();
  bool _isMockLocationDetected = false;
  loc.LocationData? _locationData;

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

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ErrorPage(
              title: "GPS Palsu Terdeteksi",
              descriptions: "Nonaktifkan Mock Location di pengaturan perangkat Anda.",
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

      // Ambil data lokasi jika tidak ada mock location
      _locationData = await location.getLocation();
      if (kDebugMode) {
        print('Location: ${_locationData?.latitude}, ${_locationData?.longitude}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching location: $e');
      }
    } finally {
      notifyListeners(); // Beritahu perubahan status
    }
  }
}

