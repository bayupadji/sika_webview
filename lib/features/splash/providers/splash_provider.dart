import 'package:flutter/foundation.dart';
import 'package:sika/features/connectivity/presentation/providers/connectivity_provider.dart';
import 'package:sika/features/sdk_validation/presentation/providers/sdk_provider.dart';
import 'package:sika/features/security/presentation/providers/security_provider.dart';

enum SplashState { loading, sdkUnsupported, connectivityFailed, securityBlocked, ready }

/// Provider untuk state splash screen.

class SplashProvider with ChangeNotifier {
  SplashState _state = SplashState.loading;
  SplashState get state => _state;
  bool get isLoading => _state == SplashState.loading;

  Future<void> initialize({
    required SdkProvider sdkProvider,
    required ConnectivityProvider connectivityProvider,
    required SecurityProvider securityProvider,
  }) async {
    _state = SplashState.loading;
    notifyListeners();

    // ── Step 1: Minimum branding time (1.5 detik) ────────────────────────
    await Future.delayed(const Duration(milliseconds: 1500));

    // ── Step 2: SDK Validation ───────────────────────────────────────────
    final isSdkCompatible = await sdkProvider.validateSdk();
    
    if (!isSdkCompatible) {
      if (kDebugMode) {
        debugPrint('[SplashProvider] SDK not supported. Showing UnsupportedDeviceScreen.');
      }
      _state = SplashState.sdkUnsupported;
      notifyListeners();
      return;
    }

    // ── Step 3: Internet Validation ──────────────────────────────────────
    final hasInternet = await connectivityProvider.checkConnectivity();

    if (!hasInternet) {
      if (kDebugMode) {
        debugPrint('[SplashProvider] No internet. Showing NoInternetScreen.');
      }
      _state = SplashState.connectivityFailed;
      notifyListeners();
      return;
    }

    // ── Step 3: Security Validation ──────────────────────────────────────
    final isSecure = await securityProvider.runAllChecks();

    if (!isSecure) {
      if (kDebugMode) {
        debugPrint('[SplashProvider] Security violation. Showing BlockingScreen.');
      }
      _state = SplashState.securityBlocked;
      notifyListeners();
      return;
    }

    // ── Step 4: All clear → load WebView ─────────────────────────────────
    if (kDebugMode) {
      debugPrint('[SplashProvider] All checks passed. Navigating to WebView.');
    }
    _state = SplashState.ready;
    notifyListeners();
  }
}
