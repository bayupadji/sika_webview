import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sika/features/sdk_validation/domain/entities/sdk_status.dart';
import 'package:sika/features/sdk_validation/domain/usecases/check_sdk_compatibility.dart';
import 'package:sika/features/sdk_validation/presentation/providers/sdk_provider.dart';

class MockCheckSdkCompatibility extends Mock implements CheckSdkCompatibility {}

void main() {
  late SdkProvider provider;
  late MockCheckSdkCompatibility mockCheckSdkCompatibility;

  setUp(() {
    mockCheckSdkCompatibility = MockCheckSdkCompatibility();
    provider = SdkProvider(mockCheckSdkCompatibility);
  });

  test('initial state should be SdkValidationState.initial', () {
    expect(provider.state, equals(SdkValidationState.initial));
    expect(provider.errorMessage, isEmpty);
  });

  test('should set state to compatible when SDK is >= 24 and WebView is available', () async {
    // arrange
    const tSdkStatus = SdkStatus(sdkInt: 24, isWebViewAvailable: true);
    when(() => mockCheckSdkCompatibility()).thenAnswer((_) async => tSdkStatus);

    // act
    final result = await provider.validateSdk();

    // assert
    expect(result, isTrue);
    expect(provider.state, equals(SdkValidationState.compatible));
    expect(provider.errorMessage, isEmpty);
  });

  test('should set state to unsupported when SDK is < 24', () async {
    // arrange
    const tSdkStatus = SdkStatus(sdkInt: 23, isWebViewAvailable: true);
    when(() => mockCheckSdkCompatibility()).thenAnswer((_) async => tSdkStatus);

    // act
    final result = await provider.validateSdk();

    // assert
    expect(result, isFalse);
    expect(provider.state, equals(SdkValidationState.unsupported));
    expect(provider.errorMessage, contains('Versi Android Anda tidak didukung'));
  });

  test('should set state to unsupported when WebView is not available', () async {
    // arrange
    const tSdkStatus = SdkStatus(sdkInt: 30, isWebViewAvailable: false);
    when(() => mockCheckSdkCompatibility()).thenAnswer((_) async => tSdkStatus);

    // act
    final result = await provider.validateSdk();

    // assert
    expect(result, isFalse);
    expect(provider.state, equals(SdkValidationState.unsupported));
    expect(provider.errorMessage, contains('WebView tidak ditemukan'));
  });

  test('should set state to unsupported when Exception is thrown', () async {
    // arrange
    when(() => mockCheckSdkCompatibility()).thenThrow(Exception('Test error'));

    // act
    final result = await provider.validateSdk();

    // assert
    expect(result, isFalse);
    expect(provider.state, equals(SdkValidationState.unsupported));
    expect(provider.errorMessage, equals('Gagal melakukan validasi SDK.'));
  });
}
