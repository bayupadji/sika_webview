import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sika/features/connectivity/domain/repositories/connectivity_repository.dart';
import 'package:sika/features/connectivity/domain/usecases/check_internet_connection.dart';

class MockConnectivityRepository extends Mock implements ConnectivityRepository {}

void main() {
  late CheckInternetConnection usecase;
  late MockConnectivityRepository mockRepository;

  setUp(() {
    mockRepository = MockConnectivityRepository();
    usecase = CheckInternetConnection(mockRepository);
  });

  test('should return true when internet is available', () async {
    // arrange
    when(() => mockRepository.isInternetAvailable()).thenAnswer((_) async => true);
    
    // act
    final result = await usecase();
    
    // assert
    expect(result, isTrue);
    verify(() => mockRepository.isInternetAvailable());
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return false when internet is unavailable', () async {
    // arrange
    when(() => mockRepository.isInternetAvailable()).thenAnswer((_) async => false);
    
    // act
    final result = await usecase();
    
    // assert
    expect(result, isFalse);
    verify(() => mockRepository.isInternetAvailable());
    verifyNoMoreInteractions(mockRepository);
  });
}
