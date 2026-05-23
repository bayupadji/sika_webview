import 'package:sika/features/connectivity/domain/repositories/connectivity_repository.dart';

/// UseCase: cek apakah internet tersedia dan reachable.
///
/// Dipanggil oleh [ConnectivityProvider].
/// Flow: Provider → UseCase → Repository → Datasource.
class CheckInternetConnection {
  final ConnectivityRepository _repository;

  const CheckInternetConnection(this._repository);

  Future<bool> call() => _repository.isInternetAvailable();
}
