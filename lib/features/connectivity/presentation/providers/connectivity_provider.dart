import 'package:flutter/foundation.dart';
import 'package:sika/core/errors/failures.dart';
import 'package:sika/features/connectivity/domain/usecases/check_internet_connection.dart';

enum ConnectivityState { initial, checking, connected, disconnected }

/// Provider untuk state konektivitas internet.
///
/// Responsibility: hanya manage state, expose ke UI.
/// Business logic delegated ke [CheckInternetConnection] usecase.
class ConnectivityProvider with ChangeNotifier {
  final CheckInternetConnection _checkInternetConnection;

  ConnectivityProvider(this._checkInternetConnection);

  ConnectivityState _state = ConnectivityState.initial;
  String _errorMessage = '';

  ConnectivityState get state => _state;
  String get errorMessage => _errorMessage;
  bool get isConnected => _state == ConnectivityState.connected;
  bool get isChecking => _state == ConnectivityState.checking;

  Future<bool> checkConnectivity() async {
    _state = ConnectivityState.checking;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _checkInternetConnection();
      _state = result ? ConnectivityState.connected : ConnectivityState.disconnected;
      notifyListeners();
      return result;
    } on NoInternetFailure catch (e) {
      _state = ConnectivityState.disconnected;
      _errorMessage = e.message;
      if (kDebugMode) debugPrint('[ConnectivityProvider] NoInternetFailure: ${e.message}');
      notifyListeners();
      return false;
    } on Failure catch (e) {
      _state = ConnectivityState.disconnected;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _state = ConnectivityState.disconnected;
      _errorMessage = 'Tidak ada koneksi internet. Periksa jaringan Anda dan coba lagi.';
      notifyListeners();
      return false;
    }
  }
}
