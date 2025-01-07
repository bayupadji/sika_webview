import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart' as ph; // Alias 'permission_handler'
import 'package:location/location.dart' as loc; // Alias 'location'

class PermissionProvider with ChangeNotifier {
  bool _isLocationGranted = false;
  bool _isCameraGranted = false;
  bool _isStorageGranted = false;

  bool get isLocationGranted => _isLocationGranted;
  bool get isCameraGranted => _isCameraGranted;
  bool get isStorageGranted => _isStorageGranted;

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
        print('Storage permission permanently denied. Redirecting to settings.');
      }
      await ph.openAppSettings(); // Membuka pengaturan aplikasi
    }

    notifyListeners();
  }

  Future<void> getLocation() async {
    if (_isLocationGranted) {
      loc.Location location = loc.Location();
      loc.LocationData locationData = await location.getLocation();
      if (kDebugMode) {
        print('Location: ${locationData.latitude}, ${locationData.longitude}');
      }
    } else {
      if (kDebugMode) {
        print('Location permission is not granted.');
      }
    }
  }

  Future<void> getCamera() async {
    if (_isCameraGranted) {
      // Mendapatkan kamera pertama
      final cameras = await availableCameras();
      final firstCamera = cameras.first;
      if (kDebugMode) {
        print('Camera available: ${firstCamera.name}');
      }
    } else {
      if (kDebugMode) {
        print('Camera permission is not granted.');
      }
    }
  }
}
