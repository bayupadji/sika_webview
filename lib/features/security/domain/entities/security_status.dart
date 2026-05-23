/// Entity yang merepresentasikan hasil pemeriksaan keamanan perangkat.
/// Domain layer — pure Dart.
class SecurityStatus {
  final bool isVpnActive;
  final bool isMockLocationEnabled;
  final bool isDeveloperModeEnabled;

  const SecurityStatus({
    required this.isVpnActive,
    required this.isMockLocationEnabled,
    required this.isDeveloperModeEnabled,
  });

  /// Apakah perangkat aman (semua check lolos).
  bool get isSecure =>
      !isVpnActive && !isMockLocationEnabled && !isDeveloperModeEnabled;

  /// Status default saat belum di-check.
  factory SecurityStatus.initial() => const SecurityStatus(
        isVpnActive: false,
        isMockLocationEnabled: false,
        isDeveloperModeEnabled: false,
      );

  @override
  String toString() =>
      'SecurityStatus(vpn=$isVpnActive, mock=$isMockLocationEnabled, devMode=$isDeveloperModeEnabled)';
}
