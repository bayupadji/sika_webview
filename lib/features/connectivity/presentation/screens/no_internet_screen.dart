import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sika/core/constants/app_constants.dart';
import 'package:sika/features/connectivity/presentation/providers/connectivity_provider.dart';
import 'package:sika/shared/widgets/default_button.dart';

/// Layar fullscreen yang ditampilkan saat tidak ada koneksi internet.
///
/// Rules (antigravity.md):
/// - fullscreen
/// - memiliki tombol retry
/// - tampilkan status koneksi
/// - tidak dapat bypass ke webview
class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Tidak bisa di-dismiss dengan back button
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                const Spacer(),
                Image.asset(
                  AppConstants.warningAsset,
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                const Text(
                  AppConstants.noInternetTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  AppConstants.noInternetMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(AppConstants.textSecondaryColor),
                    height: 1.5,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: DefaultButton(
                    label: 'Coba Lagi',
                    bgColor: const Color(AppConstants.primaryColor),
                    fgColor: Colors.white,
                    onPressed: () async {
                      final provider = context.read<ConnectivityProvider>();
                      await provider.checkConnectivity();
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
