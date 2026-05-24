import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sika/core/constants/app_constants.dart';
import 'package:sika/features/security/presentation/providers/security_provider.dart';
import 'package:sika/shared/widgets/default_button.dart';

/// Layar blocking fullscreen yang ditampilkan saat ada pelanggaran keamanan.
///
/// Rules (antigravity.md):
/// - fullscreen
/// - tidak bisa dismiss
/// - tampilkan alasan block
/// - memiliki tombol retry
class BlockingScreen extends StatelessWidget {
  const BlockingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SecurityProvider>(
      builder: (context, securityProvider, _) {
        final title = _getTitle(securityProvider.blockReason);
        final message = securityProvider.errorMessage;

        return PopScope(
          canPop: false, // Tidak bisa di-dismiss
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Spacer(),
                    // Icon peringatan
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(AppConstants.errorColor).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.security_rounded,
                        size: 52,
                        color: Color(AppConstants.errorColor),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(AppConstants.textSecondaryColor),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Chip info block reason
                    _buildBlockReasonChip(securityProvider.blockReason),
                    const Spacer(),
                    if (securityProvider.isChecking)
                      const CircularProgressIndicator(
                        color: Color(AppConstants.primaryColor),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: DefaultButton(
                          label: 'Coba Lagi',
                          bgColor: const Color(AppConstants.primaryColor),
                          fgColor: Colors.white,
                          onPressed: () async {
                            await context.read<SecurityProvider>().runAllChecks();
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

  String _getTitle(BlockReason reason) {
    switch (reason) {
      case BlockReason.vpn:
        return AppConstants.vpnTitle;
      case BlockReason.mockLocation:
        return AppConstants.mockLocationTitle;
      case BlockReason.developerMode:
        return AppConstants.developerModeTitle;
      case BlockReason.none:
        return 'Akses Diblokir';
    }
  }

  Widget _buildBlockReasonChip(BlockReason reason) {
    IconData icon;
    String label;

    switch (reason) {
      case BlockReason.vpn:
        icon = Icons.vpn_key_rounded;
        label = 'VPN Aktif';
        break;
      case BlockReason.mockLocation:
        icon = Icons.location_off_rounded;
        label = 'Mock Location';
        break;
      case BlockReason.developerMode:
        icon = Icons.developer_mode_rounded;
        label = 'Developer Mode';
        break;
      case BlockReason.none:
        return const SizedBox.shrink();
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: const Color(AppConstants.errorColor)),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          color: Color(AppConstants.errorColor),
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: const Color(AppConstants.errorColor).withOpacity(0.1),
      side: const BorderSide(color: Colors.transparent),
    );
  }
}
