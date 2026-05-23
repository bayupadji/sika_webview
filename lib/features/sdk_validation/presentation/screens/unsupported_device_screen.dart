import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sika/core/constants/app_constants.dart';
import 'package:sika/features/sdk_validation/presentation/providers/sdk_provider.dart';
import 'package:sika/shared/widgets/default_button.dart';

/// Layar fullscreen yang ditampilkan saat Android SDK atau WebView tidak didukung.
///
/// Rules (antigravity.md):
/// - block akses aplikasi
/// - jangan load webview
/// - tampilkan unsupported device page
class UnsupportedDeviceScreen extends StatelessWidget {
  const UnsupportedDeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SdkProvider>(
      builder: (context, sdkProvider, _) {
        return PopScope(
          canPop: false, // Tidak bisa di-dismiss
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    const Spacer(),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(AppConstants.errorColor).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.system_update_alt_rounded,
                        size: 52,
                        color: Color(AppConstants.errorColor),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Perangkat Tidak Didukung',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      sdkProvider.errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(AppConstants.textSecondaryColor),
                        height: 1.6,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: DefaultButton(
                        label: 'Tutup Aplikasi',
                        bgColor: const Color(AppConstants.errorColor),
                        fgColor: Colors.white,
                        onPressed: () async {
                          SystemNavigator.pop();
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
      },
    );
  }
}
