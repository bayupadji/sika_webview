import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:sika/views/pwa_webview.dart';

class SplashProvider with ChangeNotifier {
  bool _isLoading = true;
  String? errorMsg;
  String? get errorMessage => errorMsg;

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setErrorMessage(String? message) {
    errorMsg = message;
    notifyListeners();
  }

  Future<void> simulateLoading(BuildContext context) async {
    try {
      // Simulasi proses loading
      setLoading(true);
      await Future.delayed(const Duration(seconds: 3));

      // Periksa konektivitas — checkConnectivity() mengembalikan List<ConnectivityResult>
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.isEmpty ||
          connectivityResult.every((r) => r == ConnectivityResult.none)) {
        throw Exception(
            "Tidak ada koneksi internet. Silakan periksa koneksi Anda.");
      }

      // Guard: pastikan widget masih terpasang setelah async gap
      if (!context.mounted) return;

      // Navigasi ke halaman berikutnya jika ada koneksi
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const PwaWebView(),
        ),
      );
    } catch (e) {
      setLoading(false);
      setErrorMessage(e.toString());

      // Guard: pastikan widget masih terpasang setelah async gap
      if (!context.mounted) return;

      // Tampilkan pesan error menggunakan SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
