import 'package:sika/features/sdk_validation/data/datasources/sdk_datasource.dart';
import 'package:sika/features/sdk_validation/domain/entities/sdk_status.dart';
import 'package:sika/features/sdk_validation/domain/repositories/sdk_repository.dart';

/// Implementasi [SdkRepository] menggunakan [SdkDatasource].
class SdkRepositoryImpl implements SdkRepository {
  final SdkDatasource _datasource;

  const SdkRepositoryImpl(this._datasource);

  @override
  Future<SdkStatus> getSdkStatus() async {
    final info = await _datasource.getAndroidSdkInfo();
    return SdkStatus(
      sdkInt: info['sdkInt'] ?? 0,
      isWebViewAvailable: info['isWebViewAvailable'] ?? false,
    );
  }
}
