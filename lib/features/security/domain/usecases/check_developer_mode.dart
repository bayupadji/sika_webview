import 'package:sika/features/security/domain/repositories/security_repository.dart';

/// UseCase: cek apakah Developer Mode aktif di perangkat.
class CheckDeveloperMode {
  final SecurityRepository _repository;
  const CheckDeveloperMode(this._repository);
  Future<bool> call() => _repository.isDeveloperModeEnabled();
}
