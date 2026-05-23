import 'package:sika/features/sdk_validation/domain/entities/sdk_status.dart';

/// Contract repository untuk pengecekan kompatibilitas SDK.
abstract class SdkRepository {
  Future<SdkStatus> getSdkStatus();
}
