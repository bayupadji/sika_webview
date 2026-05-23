import 'package:sika/features/security/data/datasources/security_datasource.dart';
import 'package:sika/features/security/data/models/security_status_model.dart';
import 'package:sika/features/security/domain/entities/security_status.dart';
import 'package:sika/features/security/domain/repositories/security_repository.dart';

/// Implementasi [SecurityRepository] menggunakan [SecurityDatasource].
class SecurityRepositoryImpl implements SecurityRepository {
  final SecurityDatasource _datasource;

  const SecurityRepositoryImpl(this._datasource);

  @override
  Future<bool> isVpnActive() => _datasource.isVpnActive();

  @override
  Future<bool> isMockLocationEnabled() => _datasource.isMockLocationEnabled();

  @override
  Future<bool> isDeveloperModeEnabled() => _datasource.isDeveloperModeEnabled();

  @override
  Future<SecurityStatus> getAllSecurityStatus() async {
    // Jalankan semua pengecekan secara paralel untuk efisiensi
    final results = await Future.wait([
      _datasource.isVpnActive(),
      _datasource.isMockLocationEnabled(),
      _datasource.isDeveloperModeEnabled(),
    ]);

    return SecurityStatusModel.fromChecks(
      isVpnActive: results[0],
      isMockLocationEnabled: results[1],
      isDeveloperModeEnabled: results[2],
    );
  }
}
