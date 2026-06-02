import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sika/core/errors/failures.dart';
import 'package:sika/features/security/domain/usecases/check_developer_mode.dart';
import 'package:sika/features/security/domain/usecases/check_mock_location.dart';
import 'package:sika/features/security/domain/usecases/check_vpn.dart';
import 'package:sika/features/security/presentation/providers/security_provider.dart';

class MockCheckVpn extends Mock implements CheckVpn {}
class MockCheckMockLocation extends Mock implements CheckMockLocation {}
class MockCheckDeveloperMode extends Mock implements CheckDeveloperMode {}

void main() {
  late SecurityProvider provider;
  late MockCheckVpn mockCheckVpn;
  late MockCheckMockLocation mockCheckMockLocation;
  late MockCheckDeveloperMode mockCheckDeveloperMode;

  setUp(() {
    mockCheckVpn = MockCheckVpn();
    mockCheckMockLocation = MockCheckMockLocation();
    mockCheckDeveloperMode = MockCheckDeveloperMode();

    provider = SecurityProvider(
      checkVpn: mockCheckVpn,
      checkMockLocation: mockCheckMockLocation,
      checkDeveloperMode: mockCheckDeveloperMode,
    );
  });

  test('initial state should be SecurityState.initial', () {
    expect(provider.state, equals(SecurityState.initial));
    expect(provider.blockReason, equals(BlockReason.none));
  });

  test('should set state to secure when all checks pass (return false)', () async {
    // arrange
    when(() => mockCheckVpn()).thenAnswer((_) async => false);
    when(() => mockCheckMockLocation()).thenAnswer((_) async => false);
    when(() => mockCheckDeveloperMode()).thenAnswer((_) async => false);

    // act
    final result = await provider.runAllChecks();

    // assert
    expect(result, equals(true));
    expect(provider.state, equals(SecurityState.secure));
    expect(provider.blockReason, equals(BlockReason.none));
  });

  test('should set state to blocked with vpn reason when VPN is active', () async {
    // arrange
    when(() => mockCheckVpn()).thenAnswer((_) async => true);
    when(() => mockCheckMockLocation()).thenAnswer((_) async => false);
    when(() => mockCheckDeveloperMode()).thenAnswer((_) async => false);

    // act
    final result = await provider.runAllChecks();

    // assert
    expect(result, equals(false));
    expect(provider.state, equals(SecurityState.blocked));
    expect(provider.blockReason, equals(BlockReason.vpn));
  });

  test('should set state to blocked with mockLocation reason when Mock Location is enabled', () async {
    // arrange
    when(() => mockCheckVpn()).thenAnswer((_) async => false);
    when(() => mockCheckMockLocation()).thenAnswer((_) async => true);
    when(() => mockCheckDeveloperMode()).thenAnswer((_) async => false);

    // act
    final result = await provider.runAllChecks();

    // assert
    expect(result, equals(false));
    expect(provider.state, equals(SecurityState.blocked));
    expect(provider.blockReason, equals(BlockReason.mockLocation));
  });

  test('should set state to blocked with developerMode reason when Dev Mode is enabled', () async {
    // arrange
    when(() => mockCheckVpn()).thenAnswer((_) async => false);
    when(() => mockCheckMockLocation()).thenAnswer((_) async => false);
    when(() => mockCheckDeveloperMode()).thenAnswer((_) async => true);

    // act
    final result = await provider.runAllChecks();

    // assert
    expect(result, equals(false));
    expect(provider.state, equals(SecurityState.blocked));
    expect(provider.blockReason, equals(BlockReason.developerMode));
  });

  test('should set state to blocked when an exception is thrown', () async {
    // arrange
    when(() => mockCheckVpn()).thenThrow(Exception('Test error'));
    when(() => mockCheckMockLocation()).thenAnswer((_) async => false);
    when(() => mockCheckDeveloperMode()).thenAnswer((_) async => false);

    // act
    final result = await provider.runAllChecks();

    // assert
    expect(result, equals(false));
    expect(provider.state, equals(SecurityState.blocked));
    expect(provider.errorMessage, equals('Gagal melakukan validasi keamanan.'));
  });
}
