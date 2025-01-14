import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

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
        print(
            'Storage permission permanently denied. Redirecting to settings.');
      }
      await ph.openAppSettings(); // Membuka pengaturan aplikasi
    }

    notifyListeners();
  }
}
