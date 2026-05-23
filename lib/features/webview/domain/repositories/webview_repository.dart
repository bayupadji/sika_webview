/// Contract repository untuk WebView.
abstract class WebViewRepository {
  /// Mendapatkan URL yang akan dimuat di WebView.
  Future<String> getWebViewUrl();

  /// Menyimpan file ke direktori Downloads menggunakan MediaStore.
  Future<void> downloadFile({required String url, required String fileName});
}
