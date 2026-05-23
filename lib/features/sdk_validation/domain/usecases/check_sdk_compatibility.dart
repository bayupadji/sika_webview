import 'package:sika/features/sdk_validation/domain/entities/sdk_status.dart';
import 'package:sika/features/sdk_validation/domain/repositories/sdk_repository.dart';

/// UseCase: periksa kompatibilitas SDK Android dan ketersediaan WebView.
class CheckSdkCompatibility {
  final SdkRepository _repository;

  const CheckSdkCompatibility(this._repository);

  Future<SdkStatus> call() => _repository.getSdkStatus();
}
