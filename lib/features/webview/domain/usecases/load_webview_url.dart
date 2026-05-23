import 'package:sika/features/webview/domain/repositories/webview_repository.dart';

/// UseCase: dapatkan URL yang akan dimuat di WebView.
class LoadWebViewUrl {
  final WebViewRepository _repository;
  const LoadWebViewUrl(this._repository);
  Future<String> call() => _repository.getWebViewUrl();
}
