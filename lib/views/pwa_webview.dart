// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sika/constants/error_modals.dart';

class PwaWebView extends StatefulWidget {
  const PwaWebView({super.key});

  @override
  State<PwaWebView> createState() => _PwaWebViewState();
}

class _PwaWebViewState extends State<PwaWebView> {
  final GlobalKey webViewKey = GlobalKey();
  late InAppWebViewController webViewController;
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
              ErrorModal.showErrorModal(
                context,
                errorMessage: message,
                onRetry: () {
                  webViewController.loadUrl(
                    urlRequest: URLRequest(
                      url: WebUri.uri(Uri.parse(currentUrl)),
                    ),
                  );
                },
              );
            },
            onLoadHttpError: (controller, url, statusCode, description) {
              debugPrint('HTTP Error: $description (Status Code: $statusCode)');
              ErrorModal.showErrorModal(
                context,
                errorMessage: description,
                onRetry: () {
                  webViewController.loadUrl(
                    urlRequest: URLRequest(
                      url: WebUri.uri(Uri.parse(currentUrl)),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
