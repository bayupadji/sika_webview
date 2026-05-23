import 'package:sika/features/security/domain/repositories/security_repository.dart';

/// UseCase: cek apakah mock location diaktifkan di perangkat.
class CheckMockLocation {
  final SecurityRepository _repository;
  const CheckMockLocation(this._repository);
  Future<bool> call() => _repository.isMockLocationEnabled();
}
