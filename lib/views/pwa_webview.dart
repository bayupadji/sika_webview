// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart' as loc;
import 'package:sika/providers/permission_provider.dart';
import 'package:sika/views/error_page.dart';

class PwaWebView extends StatefulWidget {
  const PwaWebView({super.key});

  @override
  State<PwaWebView> createState() => _PwaWebViewState();
}

class _PwaWebViewState extends State<PwaWebView> {
  final GlobalKey webViewKey = GlobalKey();
  late InAppWebViewController webViewController;
  // String currentUrl = 'https://rski-karyawan.netlify.app';
  String currentUrl = 'https://192.168.0.20:4443';

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

    statuses.forEach((permission, status) {
      if (status.isDenied) {
        debugPrint("Izin $permission ditolak.");
      } else if (status.isGranted) {
        debugPrint("Izin $permission diberikan.");
      }
    });

    // Memastikan lokasi yang diterima bukan lokasi palsu
    await _checkMockLocationAndSend();
  }

  Future<void> _checkMockLocationAndSend() async {
    // Mengambil akses ke PermissionProvider dari Provider
    final permissionProvider =
        Provider.of<PermissionProvider>(context, listen: false);

    // Mengecek apakah lokasi palsu terdeteksi
    if (permissionProvider.isMockLocationDetected) {
      debugPrint('Fake GPS detected. Location will not be sent to WebView.');
      // Menampilkan pesan kesalahan atau notifikasi di WebView jika perlu
      await webViewController.evaluateJavascript(
        source:
            """alert('Fake GPS detected. Please disable mock location.');""",
      );
      return; // Tidak melanjutkan pengambilan lokasi
    }

    // Jika lokasi bukan fake, kirim data lokasi ke WebView
    await sendLocationToWebView();
  }

  Future<void> sendLocationToWebView() async {
    loc.Location location = loc.Location();

    try {
      loc.LocationData locationData = await location.getLocation();

      final latitude = locationData.latitude ?? 0.0;
      final longitude = locationData.longitude ?? 0.0;

      debugPrint('Location: $latitude, $longitude');

      // Kirim lokasi ke WebView menggunakan JavaScript
      await webViewController.evaluateJavascript(
        source: """window.updateLocation($latitude, $longitude);""",
      );
    } catch (e) {
      debugPrint('Error fetching location: $e');
    }
  }

  Future<bool> _handleBackPress() async {
    if (await webViewController.canGoBack()) {
      webViewController.goBack();
      return false; // Jangan keluar dari aplikasi, hanya kembali di WebView
    }
    return true; // Keluar dari aplikasi jika tidak ada halaman sebelumnya
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackPress,
      child: Scaffold(
        body: SafeArea(
          child: InAppWebView(
            key: webViewKey,
            initialUrlRequest: URLRequest(
              url: WebUri.uri(Uri.parse(currentUrl)),
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              mediaPlaybackRequiresUserGesture: false,
              allowFileAccessFromFileURLs: true,
              allowUniversalAccessFromFileURLs: true,
              allowFileAccess: true,
              isInspectable: false,
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
              debugPrint(consoleMessage.message);
            },
            onLoadError: (controller, url, code, message) {
              debugPrint('Error: $message');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ErrorPage(
                    title: "$code: Oops, terjadi kesalahan!",
                    descriptions: message,
                    image: "assets/warning.png",
                    onPressed: () {
                      Navigator.pop(context);
                      webViewController.loadUrl(
                        urlRequest: URLRequest(
                          url: WebUri.uri(
                            Uri.parse(currentUrl)
                          ),
                        )
                      );
                    },
                    btnLabel: "Coba Lagi"
                  )
                ),
              );
            },
            onLoadHttpError: (controller, url, statusCode, description) {
              debugPrint('HTTP Error: $description (Status Code: $statusCode)');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ErrorPage(
                    title: "$statusCode: Oops, terjadi kesalahan!",
                    descriptions: description,
                    image: "assets/warning.png",
                    onPressed: () {
                      Navigator.pop(context);
                      webViewController.loadUrl(
                        urlRequest: URLRequest(
                          url: WebUri.uri(
                            Uri.parse(currentUrl)
                          ),
                        )
                      );
                    },
                    btnLabel: "Coba Lagi"
                  )
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
