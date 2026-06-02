import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sika/features/security/domain/repositories/security_repository.dart';
import 'package:sika/features/security/domain/usecases/check_vpn.dart';

class MockSecurityRepository extends Mock implements SecurityRepository {}

void main() {
  late CheckVpn usecase;
  late MockSecurityRepository mockRepository;

  setUp(() {
    mockRepository = MockSecurityRepository();
    usecase = CheckVpn(mockRepository);
  });

  test('should return true when vpn is active', () async {
    // arrange
    when(() => mockRepository.isVpnActive()).thenAnswer((_) async => true);
    // act
    final result = await usecase();
    // assert
    expect(result, equals(true));
    verify(() => mockRepository.isVpnActive());
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return false when vpn is inactive', () async {
    // arrange
    when(() => mockRepository.isVpnActive()).thenAnswer((_) async => false);
    // act
    final result = await usecase();
    // assert
    expect(result, equals(false));
    verify(() => mockRepository.isVpnActive());
    verifyNoMoreInteractions(mockRepository);
  });
}
