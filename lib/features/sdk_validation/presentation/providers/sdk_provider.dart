import 'package:flutter/foundation.dart';
import 'package:sika/core/errors/failures.dart';
import 'package:sika/features/sdk_validation/domain/usecases/check_sdk_compatibility.dart';

enum SdkValidationState { initial, checking, compatible, unsupported }

/// Provider untuk state validasi SDK.
class SdkProvider with ChangeNotifier {
  final CheckSdkCompatibility _checkSdkCompatibility;

  SdkProvider(this._checkSdkCompatibility);

  SdkValidationState _state = SdkValidationState.initial;
  String _errorMessage = '';

  SdkValidationState get state => _state;
  String get errorMessage => _errorMessage;

  bool get isCompatible => _state == SdkValidationState.compatible;
  bool get isChecking => _state == SdkValidationState.checking;

  Future<bool> validateSdk() async {
    _state = SdkValidationState.checking;
    _errorMessage = '';
    notifyListeners();

    try {
      final status = await _checkSdkCompatibility();

      if (status.isCompatible) {
        _state = SdkValidationState.compatible;
      } else {
        _state = SdkValidationState.unsupported;
        if (status.sdkInt < 24) {
          _errorMessage = 'Versi Android Anda tidak didukung.\nSilakan update perangkat untuk menggunakan aplikasi SIKA.';
        } else if (!status.isWebViewAvailable) {
          _errorMessage = 'WebView tidak ditemukan atau tidak kompatibel di perangkat Anda.';
        } else {
          _errorMessage = 'Perangkat tidak didukung.';
        }
      }

      notifyListeners();
      return _state == SdkValidationState.compatible;
    } on Failure catch (e) {
      _state = SdkValidationState.unsupported;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('[SdkProvider] Unexpected error: $e');
      _state = SdkValidationState.unsupported;
      _errorMessage = 'Gagal melakukan validasi SDK.';
      notifyListeners();
      return false;
    }
  }
}
