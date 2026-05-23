import 'package:sika/features/security/domain/repositories/security_repository.dart';

/// UseCase: cek apakah VPN aktif di perangkat.
class CheckVpn {
  final SecurityRepository _repository;
  const CheckVpn(this._repository);
  Future<bool> call() => _repository.isVpnActive();
}
