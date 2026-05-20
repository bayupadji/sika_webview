import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sika/providers/location_provider.dart';
import 'package:sika/utils/env_config.dart';
import 'package:sika/views/error_page.dart';

class PwaWebView extends StatefulWidget {
  const PwaWebView({super.key});

  @override
  State<PwaWebView> createState() => _PwaWebViewState();
}

class _PwaWebViewState extends State<PwaWebView> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  String? currentUrl;

  // Flag: apakah halaman web sudah selesai load & siap menerima JS
  bool _isWebViewReady = false;

  // Simpan koordinat terakhir agar bisa dikirim saat WebView siap
  double? _pendingLat;
  double? _pendingLng;

  @override
  void initState() {
    super.initState();
    _checkEnv();
    _setupLocationAndPermissions();
  }

  void _checkEnv() {
    currentUrl = EnvConfig.prodUrl;

    if (currentUrl == null || currentUrl!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToErrorPage(
          500,
          "Environment Config",
          "CURRENT_URL is missing or invalid in .env file",
        );
      });
    }
  }

  Future<void> _setupLocationAndPermissions() async {
    // 1. Minta izin
    await _requestPermissions();

    // 2. Ambil lokasi pertama kali & cek mock
    // Guard: pastikan widget masih terpasang setelah await _requestPermissions
    if (!mounted) return;
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );
    await locationProvider.checkAndFetchLocation(context);

    // Jika mock location terdeteksi, hentikan di sini
    if (locationProvider.isMockLocationDetected) return;

    // Guard: pastikan widget masih terpasang setelah await checkAndFetchLocation
    if (!mounted) return;

    // 3. Pantau perubahan state — jika mock terdeteksi di tengah sesi,
    //    tampilkan error page secara otomatis
    locationProvider.addListener(() {
      if (locationProvider.isMockLocationDetected && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ErrorPage(
              title: "GPS Palsu Terdeteksi",
              descriptions:
                  "Nonaktifkan Mock Location di pengaturan perangkat Anda.",
              image: "assets/warning.png",
              onPressed: () => _retryAfterMockDetected(),
              btnLabel: "Coba Lagi",
            ),
          ),
        );
      }
    });

    // 4. Simpan koordinat awal sebagai pending (dikirim saat WebView ready)
    if (locationProvider.locationData != null) {
      _pendingLat = locationProvider.locationData?.latitude ?? 0.0;
      _pendingLng = locationProvider.locationData?.longitude ?? 0.0;

      if (kDebugMode) {
        print('Initial location ready: $_pendingLat, $_pendingLng');
      }

      // Jika WebView sudah siap duluan, langsung kirim
      if (_isWebViewReady) {
        await _updateGeolocationInWebView(_pendingLat!, _pendingLng!);
      }
    }

    // 5. Set callback real-time dan mulai streaming
    locationProvider.onLocationUpdate = (double lat, double lng) {
      _pendingLat = lat;
      _pendingLng = lng;

      // Hanya kirim jika WebView sudah siap
      if (_isWebViewReady) {
        _updateGeolocationInWebView(lat, lng);
      }
    };
    await locationProvider.startLocationStream();
  }

  Future<void> _requestPermissions() async {
    final statuses = await [
      Permission.location,
      Permission.camera,
      Permission.storage,
    ].request();

    if (statuses.values.any((status) => status.isDenied)) {
      if (kDebugMode) {
        print("Some permissions were denied.");
      }
    }
  }

  /// Untuk update real-time setelah override sudah ada — lebih ringan dari inject ulang penuh
  Future<void> _updateGeolocationInWebView(double lat, double lng) async {
    if (webViewController == null || !_isWebViewReady) return;

    try {
      await webViewController!.evaluateJavascript(
        source:
            "if (window.__flutterUpdateGeolocation) { window.__flutterUpdateGeolocation($lat, $lng); }",
      );
    } catch (e) {
      if (kDebugMode) {
        print('[Flutter] Geolocation update error: $e');
      }
    }
  }

  Future<void> _handleBackPress(bool didPop, dynamic result) async {
    if (didPop) return;
    if (webViewController != null && await webViewController!.canGoBack()) {
      webViewController!.goBack();
    } else {
      if (mounted) Navigator.of(context).pop(result);
    }
  }

  @override
  void dispose() {
    // Hentikan streaming lokasi saat widget di-dispose
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );
    locationProvider.stopLocationStream();
    super.dispose();
  }

  // downloadFile using mediaStore
  static const platform = MethodChannel('com.example.download');

  Future<void> downloadFileWithMediaStore(String url, String filename) async {
  try {
    await platform.invokeMethod('saveFileToDownloads', {
      'url': url,
      'fileName': filename,
    });
  } on PlatformException catch (e) {
    debugPrint("Download failed: ${e.message}");
  }
}

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _handleBackPress,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: InAppWebView(
            key: webViewKey,
            initialUrlRequest: URLRequest(url: WebUri.uri(
              Uri.parse(currentUrl!)
            )),
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
              verticalScrollBarEnabled: false,
              clearCache: false,
              clearSessionCache: false,
              thirdPartyCookiesEnabled: false
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;
              if (kDebugMode) {
                print('[Flutter] WebViewController created.');
              }
            },
            onLoadStop: (controller, url) async {
              // Halaman sudah selesai load — tandai siap
              _isWebViewReady = true;

              if (kDebugMode) {
                print('[Flutter] Page loaded: $url');
              }

              // Kirim koordinat ke queue override yang sudah terpasang
              if (_pendingLat != null && _pendingLng != null) {
                await _updateGeolocationInWebView(_pendingLat!, _pendingLng!);
              }
            },
            onLoadStart: (controller, url) {
              // Reset flag saat navigasi ke halaman baru
              _isWebViewReady = false;
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
                print('[WebView Console] ${consoleMessage.message}');
              }
            },
            onReceivedServerTrustAuthRequest: (controller, challenge) async {
              return ServerTrustAuthResponse(
                action: ServerTrustAuthResponseAction.PROCEED,
              );
            },
            onReceivedError: (controller, request, error) {
              // Abaikan error sub-resource (gambar, font, API, dll)
              if (!(request.isForMainFrame ?? false)) return;
              final url = request.url.toString();
              final code = error.type.toNativeValue() ?? -1;
              final message = error.description;
              debugPrint('Error $code: $message');
              _navigateToErrorPage(code, url, message);
            },
            onReceivedHttpError: (controller, request, errorResponse) {
              // Abaikan error sub-resource (gambar, font, API, dll)
              if (!(request.isForMainFrame ?? false)) return;
              final url = request.url.toString();
              final statusCode = errorResponse.statusCode ?? 0;
              final description = errorResponse.reasonPhrase ?? 'Unknown HTTP Error';
              debugPrint('HTTP Error: $description (Status Code: $statusCode)');
              _navigateToErrorPage(statusCode, url, description);
            },
            onDownloadStartRequest: (controller, request) async {
              final filename = request.suggestedFilename ?? 'file-download';
              final url = request.url.toString();

              final status = await Permission.storage.request();
              if (status.isGranted) {
                await downloadFileWithMediaStore(url, filename);
              } else {
                debugPrint("Storage permission denied.");
              }
            },
          ),
        ),
      ),
    );
  }

  /// Re-check mock location saat user menekan "Coba Lagi" dari error mock.
  /// Hanya kembali ke WebView jika mock sudah tidak terdeteksi.
  Future<void> _retryAfterMockDetected() async {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );

    // Cek ulang status lokasi
    await locationProvider.checkAndFetchLocation(context);

    if (!mounted) return;

    if (locationProvider.isMockLocationDetected) {
      // Mock masih aktif — tampilkan snackbar peringatan, tetap di error page
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mock Location masih aktif. Nonaktifkan terlebih dahulu.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Mock sudah dinonaktifkan — kembali ke WebView dan reload
      Navigator.pop(context);
      webViewController?.reload();
    }
  }

  void _navigateToErrorPage(int code, String url, String description) {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ErrorPage(
          title: "Error $code",
          descriptions: "Failed to Load $url: $description",
          image: "assets/warning.png",
          onPressed: () async {
            Navigator.pop(context);
            await Future.delayed(const Duration(milliseconds: 300));
            webViewController?.reload();
          },
          btnLabel: "Coba Lagi",
        ),
      ),
    );
  }
}
