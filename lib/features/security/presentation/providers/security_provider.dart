import 'package:flutter/foundation.dart';
import 'package:sika/core/errors/failures.dart';
import 'package:sika/features/security/domain/entities/security_status.dart';
import 'package:sika/features/security/domain/usecases/check_developer_mode.dart';
import 'package:sika/features/security/domain/usecases/check_mock_location.dart';
import 'package:sika/features/security/domain/usecases/check_vpn.dart';

enum SecurityState { initial, checking, secure, blocked }

/// Alasan kenapa akses diblokir.
enum BlockReason { none, vpn, mockLocation, developerMode }

/// Provider untuk state keamanan perangkat.
///
/// Responsibility: hanya manage state, expose ke UI.
/// Business logic didelegasikan ke usecase masing-masing.
class SecurityProvider with ChangeNotifier {
  final CheckVpn _checkVpn;
  final CheckMockLocation _checkMockLocation;
  final CheckDeveloperMode _checkDeveloperMode;

  SecurityProvider({
    required CheckVpn checkVpn,
    required CheckMockLocation checkMockLocation,
    required CheckDeveloperMode checkDeveloperMode,
  })  : _checkVpn = checkVpn,
        _checkMockLocation = checkMockLocation,
        _checkDeveloperMode = checkDeveloperMode;

  SecurityState _state = SecurityState.initial;
  BlockReason _blockReason = BlockReason.none;
  SecurityStatus _securityStatus = SecurityStatus.initial();
  String _errorMessage = '';

  SecurityState get state => _state;
  BlockReason get blockReason => _blockReason;
  SecurityStatus get securityStatus => _securityStatus;
  String get errorMessage => _errorMessage;
  bool get isSecure => _state == SecurityState.secure;
  bool get isBlocked => _state == SecurityState.blocked;
  bool get isChecking => _state == SecurityState.checking;

  /// Jalankan semua security check secara paralel.
  Future<bool> runAllChecks() async {
    _state = SecurityState.checking;
    _blockReason = BlockReason.none;
    _errorMessage = '';
    notifyListeners();

    try {
      // Jalankan semua check secara paralel
      final results = await Future.wait([
        _checkVpn(),
        _checkMockLocation(),
        _checkDeveloperMode(),
      ]);

      final isVpn = results[0];
      final isMock = results[1];
      final isDevMode = results[2];

      _securityStatus = SecurityStatus(
        isVpnActive: isVpn,
        isMockLocationEnabled: isMock,
        isDeveloperModeEnabled: isDevMode,
      );

      if (kDebugMode) {
        debugPrint('[SecurityProvider] Result: $_securityStatus');
      }

      if (isVpn) {
        _state = SecurityState.blocked;
        _blockReason = BlockReason.vpn;
        _errorMessage = 'Matikan VPN untuk menggunakan aplikasi.';
      } else if (isMock) {
        _state = SecurityState.blocked;
        _blockReason = BlockReason.mockLocation;
        _errorMessage = 'Akses aplikasi diblokir demi keamanan absensi.';
      } else if (isDevMode) {
        _state = SecurityState.blocked;
        _blockReason = BlockReason.developerMode;
        _errorMessage = 'Nonaktifkan Developer Options untuk melanjutkan.';
      } else {
        _state = SecurityState.secure;
      }

      notifyListeners();
      return _state == SecurityState.secure;
    } on Failure catch (e) {
      _state = SecurityState.blocked;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SecurityProvider] Unexpected error: $e');
      }
      _state = SecurityState.blocked;
      _errorMessage = 'Gagal melakukan validasi keamanan.';
      notifyListeners();
      return false;
    }
  }
}
