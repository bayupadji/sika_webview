import 'package:flutter/foundation.dart';
import 'package:sika/features/webview/domain/usecases/load_webview_url.dart';

enum WebViewLoadState { initial, loading, loaded, error }

/// Provider untuk state WebView.
///
/// Responsibility: manage URL state dan loading status.
/// Business logic didelegasikan ke [LoadWebViewUrl] usecase.
class WebViewProvider with ChangeNotifier {
  final LoadWebViewUrl _loadWebViewUrl;

  WebViewProvider(this._loadWebViewUrl);

  WebViewLoadState _state = WebViewLoadState.initial;
  String _url = '';
  String _errorMessage = 'Tidak dapat memuat URL web.';
  bool _isWebViewReady = false;

  WebViewLoadState get state => _state;
  String get url => _url;
  String get errorMessage => _errorMessage;
  bool get isWebViewReady => _isWebViewReady;

  Future<String?> initializeUrl() async {
    _state = WebViewLoadState.loading;
    notifyListeners();

    try {
      _url = await _loadWebViewUrl();
      _state = WebViewLoadState.loaded;
      notifyListeners();
      return _url;
    } catch (e) {
      _state = WebViewLoadState.error;
      _errorMessage = e.toString();
      if (kDebugMode) {
        debugPrint('[WebViewProvider] URL load error: $e');
      }
      notifyListeners();
      return null;
    }
  }

  void setWebViewReady(bool ready) {
    _isWebViewReady = ready;
    notifyListeners();
  }
}
