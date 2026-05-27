import 'package:sika/features/security/domain/entities/security_status.dart';

/// Contract repository untuk pemeriksaan keamanan perangkat.
abstract class SecurityRepository {
  Future<bool> isVpnActive();
  Future<bool> isMockLocationEnabled();
  Future<bool> isDeveloperModeEnabled();
  Future<SecurityStatus> getAllSecurityStatus();
}
