import 'package:flutter/material.dart';
import 'package:sika/features/connectivity/presentation/screens/no_internet_screen.dart';
import 'package:sika/features/security/presentation/screens/blocking_screen.dart';
import 'package:sika/features/sdk_validation/presentation/screens/unsupported_device_screen.dart';
import 'package:sika/features/splash/presentation/splashscreen.dart';
import 'package:sika/features/webview/presentation/screens/pwa_webview.dart';
import 'package:sika/shared/widgets/error_screen.dart';

/// Definisi named routes aplikasi SIKA.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String noInternet = '/no-internet';
  static const String blocked = '/blocked';
  static const String webview = '/webview';
  static const String error = '/error';
  static const String unsupported = '/unsupported';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        noInternet: (_) => const NoInternetScreen(),
        blocked: (_) => const BlockingScreen(),
        webview: (_) => const PwaWebView(),
        unsupported: (_) => const UnsupportedDeviceScreen(),
        error: (ctx) {
          final args = ModalRoute.of(ctx)?.settings.arguments
              as Map<String, dynamic>?;
          return ErrorScreen(
            code: args?['code'] ?? 0,
            url: args?['url'] ?? '',
            description: args?['description'] ?? 'Unknown error',
            onRetry: args?['onRetry'],
          );
        },
      };
}
