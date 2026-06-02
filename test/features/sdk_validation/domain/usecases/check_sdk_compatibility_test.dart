import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sika/features/sdk_validation/domain/entities/sdk_status.dart';
import 'package:sika/features/sdk_validation/domain/repositories/sdk_repository.dart';
import 'package:sika/features/sdk_validation/domain/usecases/check_sdk_compatibility.dart';

class MockSdkRepository extends Mock implements SdkRepository {}

void main() {
  late CheckSdkCompatibility usecase;
  late MockSdkRepository mockRepository;

  setUp(() {
    mockRepository = MockSdkRepository();
    usecase = CheckSdkCompatibility(mockRepository);
  });

  test('should return SdkStatus from the repository', () async {
    // arrange
    const tSdkStatus = SdkStatus(sdkInt: 30, isWebViewAvailable: true);
    when(() => mockRepository.getSdkStatus()).thenAnswer((_) async => tSdkStatus);
    
    // act
    final result = await usecase();
    
    // assert
    expect(result, equals(tSdkStatus));
    verify(() => mockRepository.getSdkStatus());
    verifyNoMoreInteractions(mockRepository);
  });
}
