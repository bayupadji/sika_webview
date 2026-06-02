import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sika/features/security/domain/repositories/security_repository.dart';
import 'package:sika/features/security/domain/usecases/check_mock_location.dart';

class MockSecurityRepository extends Mock implements SecurityRepository {}

void main() {
  late CheckMockLocation usecase;
  late MockSecurityRepository mockRepository;

  setUp(() {
    mockRepository = MockSecurityRepository();
    usecase = CheckMockLocation(mockRepository);
  });

  test('should return true when mock location is enabled', () async {
    // arrange
    when(() => mockRepository.isMockLocationEnabled()).thenAnswer((_) async => true);
    // act
    final result = await usecase();
    // assert
    expect(result, equals(true));
    verify(() => mockRepository.isMockLocationEnabled());
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return false when mock location is not enabled', () async {
    // arrange
    when(() => mockRepository.isMockLocationEnabled()).thenAnswer((_) async => false);
    // act
    final result = await usecase();
    // assert
    expect(result, equals(false));
    verify(() => mockRepository.isMockLocationEnabled());
    verifyNoMoreInteractions(mockRepository);
  });
}
