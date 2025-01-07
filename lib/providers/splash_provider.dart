// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:sika/views/pwa_webview.dart';

class SplashProvider with ChangeNotifier {
  bool _isLoading = true;

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> simulateLoading(BuildContext context) async {
    // Simulasi proses loading
    await Future.delayed(Duration(seconds: 3));
    setLoading(false);

    // Navigasi ke halaman berikutnya
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const PwaWebView()
      ),
    );
  }
}
