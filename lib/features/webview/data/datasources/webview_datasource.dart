import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sika/core/constants/app_constants.dart';
import 'package:sika/core/utils/env_config.dart';

/// Datasource untuk WebView — MethodChannel download hanya di sini.
///
/// Sesuai antigravity.md: MethodChannel tidak boleh dipanggil dari UI.
class WebViewDatasource {
  static const _channel = MethodChannel(AppConstants.downloadChannel);

  /// Mendapatkan URL yang akan dimuat di WebView dari konfigurasi .env.
  Future<String> getWebViewUrl() async {
    final url = EnvConfig.prodUrl;
    if (url.isEmpty) {
      throw Exception('PROD_URL is missing or invalid in .env file');
    }
    return url;
  }

  /// Download file menggunakan Android MediaStore via MethodChannel.
  Future<void> downloadFile({
    required String url,
    required String fileName,
  }) async {
    try {
      await _channel.invokeMethod('saveFileToDownloads', {
        'url': url,
        'fileName': fileName,
      });
      if (kDebugMode) {
        debugPrint('[WebViewDatasource] Download started: $fileName');
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('[WebViewDatasource] Download failed: ${e.message}');
      }
      rethrow;
    }
  }
}
