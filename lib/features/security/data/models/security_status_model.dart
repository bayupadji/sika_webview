import 'package:sika/features/security/domain/entities/security_status.dart';

/// Model Data layer turunan dari [SecurityStatus] entity.
/// Bertanggung jawab untuk parsing dan serialisasi data dari datasource.
class SecurityStatusModel extends SecurityStatus {
  const SecurityStatusModel({
    required super.isVpnActive,
    required super.isMockLocationEnabled,
    required super.isDeveloperModeEnabled,
  });

  factory SecurityStatusModel.fromChecks({
    required bool isVpnActive,
    required bool isMockLocationEnabled,
    required bool isDeveloperModeEnabled,
  }) {
    return SecurityStatusModel(
      isVpnActive: isVpnActive,
      isMockLocationEnabled: isMockLocationEnabled,
      isDeveloperModeEnabled: isDeveloperModeEnabled,
    );
  }
}
