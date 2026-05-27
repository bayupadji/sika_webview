import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sika/core/constants/app_constants.dart';
import 'package:sika/features/connectivity/presentation/providers/connectivity_provider.dart';
import 'package:sika/features/sdk_validation/presentation/providers/sdk_provider.dart';
import 'package:sika/features/security/presentation/providers/security_provider.dart';
import 'package:sika/features/splash/providers/splash_provider.dart';

/// Splash screen yang mengatur initialization flow aplikasi.

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward();

    // Mulai initialization setelah frame pertama
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startInitialization();
    });
  }

  Future<void> _startInitialization() async {
    if (!mounted) return;

    final splashProvider = context.read<SplashProvider>();
    final sdkProvider = context.read<SdkProvider>();
    final connectivityProvider = context.read<ConnectivityProvider>();
    final securityProvider = context.read<SecurityProvider>();

    await splashProvider.initialize(
      sdkProvider: sdkProvider,
      connectivityProvider: connectivityProvider,
      securityProvider: securityProvider,
    );

    if (!mounted) return;

    // Navigasi berdasarkan hasil initialization
    _handleNavigationAfterInit(splashProvider.state);
  }

  void _handleNavigationAfterInit(SplashState state) {
    switch (state) {
      case SplashState.sdkUnsupported:
        Navigator.pushReplacementNamed(context, '/unsupported');
        break;
      case SplashState.connectivityFailed:
        Navigator.pushReplacementNamed(context, '/no-internet');
        break;
      case SplashState.securityBlocked:
        Navigator.pushReplacementNamed(context, '/blocked');
        break;
      case SplashState.ready:
        Navigator.pushReplacementNamed(context, '/webview');
        break;
      case SplashState.loading:
        // Masih loading, tidak navigasi
        break;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<SplashProvider>(
        builder: (context, splash, _) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo dengan fade + scale animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Image.asset(
                      AppConstants.logoAsset,
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Loading indicator
                if (splash.isLoading)
                  const CircularProgressIndicator(
                    color: Color(AppConstants.primaryColor),
                    strokeWidth: 2.5,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
