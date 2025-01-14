// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sika/providers/location_provider.dart';
import 'package:sika/views/error_page.dart';

class PwaWebView extends StatefulWidget {
  const PwaWebView({super.key});

  @override
  State<PwaWebView> createState() => _PwaWebViewState();
}

class _PwaWebViewState extends State<PwaWebView> {
  final GlobalKey webViewKey = GlobalKey();
  late InAppWebViewController webViewController;
  // String currentUrl = 'https://192.168.0.20:4443';
  String currentUrl = 'https://rski-karyawan.netlify.app';

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.camera,
      Permission.storage,
    ].request();

    // Cek apakah izin diberikan
    if (statuses.values.any((status) => status.isDenied)) {
      if (kDebugMode) {
        print("Some permissions were denied.");
      }
    }

    // Memanggil fungsi di provider untuk memeriksa dan mengambil lokasi
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    await locationProvider.checkAndFetchLocation(context);

    // Setelah lokasi berhasil didapatkan, kirim data ke WebView jika mock location tidak terdeteksi
    if (!locationProvider.isMockLocationDetected && locationProvider.locationData != null) {
      final latitude = locationProvider.locationData?.latitude ?? 0.0;
      final longitude = locationProvider.locationData?.longitude ?? 0.0;

      if (kDebugMode) {
        print('Location: $latitude, $longitude');
      }

      // Kirim lokasi ke WebView menggunakan JavaScript
      await webViewController.evaluateJavascript(
        source: """window.updateLocation($latitude, $longitude);""",
      );
    }
  }

  Future<bool> _handleBackPress() async {
    if (await webViewController.canGoBack()) {
      webViewController.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackPress,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: InAppWebView(
            key: webViewKey,
            initialUrlRequest: URLRequest(url: WebUri.uri(Uri.parse(currentUrl))),
            initialSettings: InAppWebViewSettings(
              underPageBackgroundColor: Colors.white,
              javaScriptEnabled: true,
              mediaPlaybackRequiresUserGesture: false,
              allowFileAccessFromFileURLs: true,
              allowUniversalAccessFromFileURLs: true,
              allowFileAccess: true,
              allowsBackForwardNavigationGestures: true,
              geolocationEnabled: true,
              disableDefaultErrorPage: true,
              networkAvailable: true,
              alwaysBounceVertical: false,
              isInspectable: false,
              verticalScrollBarEnabled: false
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onPermissionRequest: (controller, request) async {
              return PermissionResponse(
                resources: request.resources,
                action: PermissionResponseAction.GRANT,
              );
            },
            onGeolocationPermissionsShowPrompt: (controller, origin) async {
              return GeolocationPermissionShowPromptResponse(
                origin: origin,
                allow: true,
                retain: true,
              );
            },
            onConsoleMessage: (controller, consoleMessage) {
              if (kDebugMode) {
                print(consoleMessage.message);
              }
            },
            onReceivedServerTrustAuthRequest: (controller, challenge) async {
              return ServerTrustAuthResponse(
                action: ServerTrustAuthResponseAction.PROCEED,
              );
            },
            onLoadError: (controller, url, code, message) {
              debugPrint('Error $code: $message');
              _navigateToErrorPage(code, url.toString(), message);
            },
            onLoadHttpError: (controller, url, statusCode, description) {
              debugPrint('HTTP Error: $description (Status Code: $statusCode)');
              _navigateToErrorPage(statusCode, url.toString(), description);
            },
          ),
        ),
      ),
    );
  }

  void _navigateToErrorPage(int code, String url, String description) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ErrorPage(
          title: "Error $code",
          descriptions: "Failed to Load $url: $description",
          image: "assets/warning.png",
          onPressed: () {
            Navigator.pop(context);
            webViewController.loadUrl(
              urlRequest: URLRequest(url: WebUri.uri(Uri.parse(currentUrl))),
            );
          },
          btnLabel: "Coba Lagi",
        ),
      ),
    );
  }
}
