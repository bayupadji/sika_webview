import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart'
    as ph; // Alias 'permission_handler' // Plugin detect_fake_location

class PermissionProvider with ChangeNotifier {
  bool _isLocationGranted = false;
  bool _isCameraGranted = false;
  bool _isStorageGranted = false;
  // bool _isMockLocationDetected = false;

  bool get isLocationGranted => _isLocationGranted;
  bool get isCameraGranted => _isCameraGranted;
  bool get isStorageGranted => _isStorageGranted;
  // bool get isMockLocationDetected => _isMockLocationDetected;

  Future<void> requestPermissions() async {
    // Meminta izin lokasi
    ph.PermissionStatus locationPermission =
        await ph.Permission.location.request();
    _isLocationGranted = locationPermission.isGranted;

    // Meminta izin kamera
    ph.PermissionStatus cameraPermission = await ph.Permission.camera.request();
    _isCameraGranted = cameraPermission.isGranted;

    // Meminta izin penyimpanan
    ph.PermissionStatus storagePermission =
        await ph.Permission.storage.request();
    _isStorageGranted = storagePermission.isGranted;

    // Menangani izin yang ditolak permanen
    if (storagePermission.isPermanentlyDenied) {
      if (kDebugMode) {
        print(
            'Storage permission permanently denied. Redirecting to settings.');
      }
      await ph.openAppSettings(); // Membuka pengaturan aplikasi
    }

    // Memeriksa apakah mock location diaktifkan
    // await _checkMockLocation();

    notifyListeners();
  }

  // Future<void> _checkMockLocation() async {
  //   try {
  //     final bool isMock = await DetectFakeLocation().detectFakeLocation();
  //     _isMockLocationDetected = isMock;
  //     if (kDebugMode) {
  //       print(_isMockLocationDetected
  //           ? 'Mock location detected.'
  //           : 'No mock location detected.');
  //     }

  //     // Jika mock location terdeteksi, set _isLocationGranted ke false
  //     if (_isMockLocationDetected) {
  //       _isLocationGranted = false;
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print("Error detecting mock location: $e");
  //     }
  //     _isMockLocationDetected = false;
  //     _isLocationGranted =
  //         true; // Jika tidak ada error, set _isLocationGranted ke true
  //   }
  // }



  // Future<void> getLocation() async {
  //   if (!_isLocationGranted) {
  //     if (kDebugMode) {
  //       print('Location permission is not granted or fake GPS detected.');
  //     }
  //     return; // Tidak melanjutkan pengambilan lokasi jika mock location terdeteksi atau izin tidak diberikan
  //   }

  //   loc.Location location = loc.Location();
  //   try {
  //     loc.LocationData locationData = await location.getLocation();
  //     if (kDebugMode) {
  //       print('Location: ${locationData.latitude}, ${locationData.longitude}');
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Error fetching location: $e');
  //     }
  //   }
  // }

  // Future<void> getCamera() async {
  //   if (_isCameraGranted) {
  //     // Mendapatkan kamera pertama
  //     final cameras = await availableCameras();
  //     final firstCamera = cameras.first;
  //     if (kDebugMode) {
  //       print('Camera available: ${firstCamera.name}');
  //     }
  //   } else {
  //     if (kDebugMode) {
  //       print('Camera permission is not granted.');
  //     }
  //   }
  // }
}
