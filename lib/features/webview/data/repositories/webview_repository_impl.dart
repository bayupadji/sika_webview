import 'package:sika/features/webview/data/datasources/webview_datasource.dart';
import 'package:sika/features/webview/domain/repositories/webview_repository.dart';

/// Implementasi [WebViewRepository].
class WebViewRepositoryImpl implements WebViewRepository {
  final WebViewDatasource _datasource;

  const WebViewRepositoryImpl(this._datasource);

  @override
  Future<String> getWebViewUrl() => _datasource.getWebViewUrl();

  @override
  Future<void> downloadFile({
    required String url,
    required String fileName,
  }) =>
      _datasource.downloadFile(url: url, fileName: fileName);
}
