import 'package:sika/features/connectivity/data/datasources/connectivity_datasource.dart';
import 'package:sika/features/connectivity/domain/repositories/connectivity_repository.dart';

/// Implementasi [ConnectivityRepository] menggunakan [ConnectivityDatasource].
class ConnectivityRepositoryImpl implements ConnectivityRepository {
  final ConnectivityDatasource _datasource;

  const ConnectivityRepositoryImpl(this._datasource);

  @override
  Future<bool> isInternetAvailable() => _datasource.isInternetAvailable();
}
