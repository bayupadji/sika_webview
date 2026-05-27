import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sika/core/constants/app_constants.dart';
import 'package:sika/features/webview/data/datasources/webview_datasource.dart';
import 'package:sika/features/webview/presentation/providers/webview_provider.dart';
import 'package:sika/shared/helpers/location_helper.dart';

/// Layar WebView utama aplikasi SIKA.

class PwaWebView extends StatefulWidget {
  const PwaWebView({super.key});

  @override
  State<PwaWebView> createState() => _PwaWebViewState();
}

class _PwaWebViewState extends State<PwaWebView> {
  final GlobalKey _webViewKey = GlobalKey();
  InAppWebViewController? _webViewController;

  // ─── WebView datasource untuk download (tidak langsung invoke channel) ──
  final WebViewDatasource _webViewDatasource = WebViewDatasource();

  // ─── Location streaming helper ──────────────────────────────────────────
  late final LocationHelper _locationHelper;

  bool _isWebViewReady = false;
  double? _pendingLat;
  double? _pendingLng;

  @override
  void initState() {
    super.initState();
    _locationHelper = LocationHelper(
      onLocationUpdate: (lat, lng) {
        _pendingLat = lat;
        _pendingLng = lng;
        if (_isWebViewReady) {
          _updateGeolocationInWebView(lat, lng);
        }
      },
      onMockDetected: () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/blocked');
        }
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initialize();
    });
  }

  Future<void> _initialize() async {
    // 1. Resolve URL via provider (usecase → repository → datasource)
    if (!mounted) return;
    final webViewProvider = context.read<WebViewProvider>();
    final url = await webViewProvider.initializeUrl();

    if (url == null || url.isEmpty) {
      // URL tidak valid, tidak lanjutkan
      return;
    }

    // 2. Request runtime permissions
    await _requestPermissions();

    // 3. Inisialisasi location streaming
    if (!mounted) return;
    await _locationHelper.initialize(context);
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.location,
      Permission.camera,
      Permission.storage,
    ].request();
  }

  Future<void> _updateGeolocationInWebView(double lat, double lng) async {
    if (_webViewController == null || !_isWebViewReady) return;
    try {
      await _webViewController!.evaluateJavascript(
        source:
            'if (window.__flutterUpdateGeolocation) { window.__flutterUpdateGeolocation($lat, $lng); }',
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PwaWebView] Geolocation update error: $e');
      }
    }
  }

  Future<void> _handleBackPress(bool didPop, dynamic result) async {
    if (didPop) return;
    if (_webViewController != null && await _webViewController!.canGoBack()) {
      _webViewController!.goBack();
    } else {
      if (mounted) Navigator.of(context).pop(result);
    }
  }

  @override
  void dispose() {
    _locationHelper.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WebViewProvider>(
      builder: (context, webViewProvider, _) {
        final url = webViewProvider.url;

        if (webViewProvider.state == WebViewLoadState.loading || url.isEmpty) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                color: Color(AppConstants.primaryColor),
              ),
            ),
          );
        }

        if (webViewProvider.state == WebViewLoadState.error) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Text(
                webViewProvider.errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: _handleBackPress,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: InAppWebView(
                key: _webViewKey,
                initialUrlRequest:
                    URLRequest(url: WebUri.uri(Uri.parse(url))),
                initialSettings: InAppWebViewSettings(
                  underPageBackgroundColor: Colors.white,
                  javaScriptEnabled: true,
                  mediaPlaybackRequiresUserGesture: false,
                  allowFileAccess: false,
                  allowsBackForwardNavigationGestures: true,
                  geolocationEnabled: true,
                  disableDefaultErrorPage: true,
                  networkAvailable: true,
                  alwaysBounceVertical: false,
                  isInspectable: kDebugMode,
                  verticalScrollBarEnabled: false,
                  clearCache: false,
                  clearSessionCache: false,
                  thirdPartyCookiesEnabled: false,
                ),
                onWebViewCreated: (controller) {
                  _webViewController = controller;
                  if (kDebugMode) {
                    debugPrint('[PwaWebView] WebViewController created.');
                  }
                },
                onLoadStop: (controller, loadedUrl) async {
                  _isWebViewReady = true;
                  context.read<WebViewProvider>().setWebViewReady(true);

                  if (kDebugMode) {
                    debugPrint('[PwaWebView] Page loaded: $loadedUrl');
                  }

                  // Kirim koordinat pending jika sudah tersedia
                  if (_pendingLat != null && _pendingLng != null) {
                    await _updateGeolocationInWebView(
                        _pendingLat!, _pendingLng!);
                  }
                },
                onLoadStart: (controller, loadedUrl) {
                  _isWebViewReady = false;
                  context.read<WebViewProvider>().setWebViewReady(false);
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
                    debugPrint('[WebView Console] ${consoleMessage.message}');
                  }
                },
                onReceivedServerTrustAuthRequest: (controller, challenge) async {
                  return ServerTrustAuthResponse(
                    action: ServerTrustAuthResponseAction.PROCEED,
                  );
                },
                onReceivedError: (controller, request, error) {
                  if (!(request.isForMainFrame ?? false)) return;
                  final errorUrl = request.url.toString();
                  final code = error.type.toNativeValue() ?? -1;
                  final message = error.description;
                  debugPrint('[PwaWebView] Error $code: $message');
                  _navigateToErrorPage(code, errorUrl, message);
                },
                onReceivedHttpError: (controller, request, errorResponse) {
                  if (!(request.isForMainFrame ?? false)) return;
                  final errorUrl = request.url.toString();
                  final statusCode = errorResponse.statusCode ?? 0;
                  final description =
                      errorResponse.reasonPhrase ?? 'Unknown HTTP Error';
                  debugPrint('[PwaWebView] HTTP $statusCode: $description');
                  _navigateToErrorPage(statusCode, errorUrl, description);
                },
                onDownloadStartRequest: (controller, request) async {
                  final filename =
                      request.suggestedFilename ?? 'file-download';
                  final downloadUrl = request.url.toString();

                  final status = await Permission.storage.request();
                  if (status.isGranted) {
                    // ── Download via datasource, tidak langsung invoke channel ──
                    await _webViewDatasource.downloadFile(
                      url: downloadUrl,
                      fileName: filename,
                    );
                  } else {
                    debugPrint('[PwaWebView] Storage permission denied.');
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToErrorPage(int code, String url, String description) {
    if (!mounted) return;
    Navigator.pushNamed(
      context,
      '/error',
      arguments: {
        'code': code,
        'url': url,
        'description': description,
        'onRetry': () async {
          Navigator.pop(context);
          await Future.delayed(const Duration(milliseconds: 300));
          _webViewController?.reload();
        },
      },
    );
  }
}
