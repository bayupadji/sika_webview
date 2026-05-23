
import 'package:sika/features/sdk_validation/data/datasources/sdk_datasource.dart';
import 'package:sika/features/sdk_validation/data/repositories/sdk_repository_impl.dart';
import 'package:sika/features/sdk_validation/domain/usecases/check_sdk_compatibility.dart';
import 'package:sika/features/sdk_validation/presentation/providers/sdk_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:sika/features/connectivity/data/datasources/connectivity_datasource.dart';
import 'package:sika/features/connectivity/data/repositories/connectivity_repository_impl.dart';
import 'package:sika/features/connectivity/domain/usecases/check_internet_connection.dart';
import 'package:sika/features/connectivity/presentation/providers/connectivity_provider.dart';
import 'package:sika/features/security/data/datasources/security_datasource.dart';
import 'package:sika/features/security/data/repositories/security_repository_impl.dart';
import 'package:sika/features/security/domain/usecases/check_developer_mode.dart';
import 'package:sika/features/security/domain/usecases/check_mock_location.dart';
import 'package:sika/features/security/domain/usecases/check_vpn.dart';
import 'package:sika/features/security/presentation/providers/security_provider.dart';
import 'package:sika/features/splash/providers/splash_provider.dart';
import 'package:sika/features/webview/data/datasources/webview_datasource.dart';
import 'package:sika/features/webview/data/repositories/webview_repository_impl.dart';
import 'package:sika/features/webview/domain/usecases/load_webview_url.dart';
import 'package:sika/features/webview/presentation/providers/webview_provider.dart';

/// Dependency injection untuk semua provider.
///
/// Wiring: Datasource → Repository → UseCase → Provider
/// Sesuai dependency direction: Presentation → Domain ← Data
class AppBindings {
  AppBindings._();

  static List<SingleChildWidget> get providers => [
        // ─── SDK Validation ────────────────────────────────────────────────
        ChangeNotifierProvider<SdkProvider>(
          create: (_) => SdkProvider(
            CheckSdkCompatibility(
              SdkRepositoryImpl(
                SdkDatasource(),
              ),
            ),
          ),
        ),

        // ─── Connectivity ──────────────────────────────────────────────────
        ChangeNotifierProvider<ConnectivityProvider>(
          create: (_) => ConnectivityProvider(
            CheckInternetConnection(
              ConnectivityRepositoryImpl(
                ConnectivityDatasource(),
              ),
            ),
          ),
        ),

        // ─── Security ──────────────────────────────────────────────────────
        ChangeNotifierProvider<SecurityProvider>(
          create: (_) {
            final datasource = SecurityDatasource();
            final repository = SecurityRepositoryImpl(datasource);
            return SecurityProvider(
              checkVpn: CheckVpn(repository),
              checkMockLocation: CheckMockLocation(repository),
              checkDeveloperMode: CheckDeveloperMode(repository),
            );
          },
        ),

        // ─── WebView ───────────────────────────────────────────────────────
        ChangeNotifierProvider<WebViewProvider>(
          create: (_) => WebViewProvider(
            LoadWebViewUrl(
              WebViewRepositoryImpl(
                WebViewDatasource(),
              ),
            ),
          ),
        ),

        // ─── Splash ────────────────────────────────────────────────────────
        ChangeNotifierProvider<SplashProvider>(
          create: (_) => SplashProvider(),
        ),
      ];
}
