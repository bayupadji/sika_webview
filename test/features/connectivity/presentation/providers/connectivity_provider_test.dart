import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sika/core/errors/failures.dart';
import 'package:sika/features/connectivity/domain/usecases/check_internet_connection.dart';
import 'package:sika/features/connectivity/presentation/providers/connectivity_provider.dart';

class MockCheckInternetConnection extends Mock implements CheckInternetConnection {}

void main() {
  late ConnectivityProvider provider;
  late MockCheckInternetConnection mockCheckInternetConnection;

  setUp(() {
    mockCheckInternetConnection = MockCheckInternetConnection();
    provider = ConnectivityProvider(mockCheckInternetConnection);
  });

  test('initial state should be ConnectivityState.initial', () {
    expect(provider.state, equals(ConnectivityState.initial));
    expect(provider.errorMessage, isEmpty);
  });

  test('should set state to connected when internet is available', () async {
    // arrange
    when(() => mockCheckInternetConnection()).thenAnswer((_) async => true);

    // act
    final result = await provider.checkConnectivity();

    // assert
    expect(result, isTrue);
    expect(provider.state, equals(ConnectivityState.connected));
    expect(provider.errorMessage, isEmpty);
  });

  test('should set state to disconnected when internet is not available', () async {
    // arrange
    when(() => mockCheckInternetConnection()).thenAnswer((_) async => false);

    // act
    final result = await provider.checkConnectivity();

    // assert
    expect(result, isFalse);
    expect(provider.state, equals(ConnectivityState.disconnected));
  });

  test('should handle Exception and set state to disconnected', () async {
    // arrange
    when(() => mockCheckInternetConnection()).thenThrow(Exception('No route to host'));

    // act
    final result = await provider.checkConnectivity();

    // assert
    expect(result, isFalse);
    expect(provider.state, equals(ConnectivityState.disconnected));
    expect(provider.errorMessage, contains('Tidak ada koneksi internet'));
  });
}
