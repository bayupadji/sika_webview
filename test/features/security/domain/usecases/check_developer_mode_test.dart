import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sika/features/security/domain/repositories/security_repository.dart';
import 'package:sika/features/security/domain/usecases/check_developer_mode.dart';

class MockSecurityRepository extends Mock implements SecurityRepository {}

void main() {
  late CheckDeveloperMode usecase;
  late MockSecurityRepository mockRepository;

  setUp(() {
    mockRepository = MockSecurityRepository();
    usecase = CheckDeveloperMode(mockRepository);
  });

  test('should return true when developer mode is enabled', () async {
    // arrange
    when(() => mockRepository.isDeveloperModeEnabled()).thenAnswer((_) async => true);
    // act
    final result = await usecase();
    // assert
    expect(result, equals(true));
    verify(() => mockRepository.isDeveloperModeEnabled());
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return false when developer mode is not enabled', () async {
    // arrange
    when(() => mockRepository.isDeveloperModeEnabled()).thenAnswer((_) async => false);
    // act
    final result = await usecase();
    // assert
    expect(result, equals(false));
    verify(() => mockRepository.isDeveloperModeEnabled());
    verifyNoMoreInteractions(mockRepository);
  });
}
