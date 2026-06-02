import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sika/core/constants/app_constants.dart';
import 'package:sika/features/security/data/datasources/security_datasource.dart';

void main() {
  late SecurityDatasource datasource;

  const MethodChannel securityChannel = MethodChannel(AppConstants.securityChannel);
  const MethodChannel fallbackChannel = MethodChannel('detect_fake_location');
  const MethodChannel permissionChannel = MethodChannel('flutter.baseflow.com/permissions/methods');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    datasource = SecurityDatasource();
    
    // Mock default permission as granted for the plugin to work
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, (MethodCall methodCall) async {
      if (methodCall.method == 'checkPermissionStatus') {
        return 1; // PermissionStatus.granted
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(securityChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(fallbackChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, null);
  });

  group('Mock Location Detection', () {
    test('should return native result when native channel is successful (Android 11)', () async {
      // arrange
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(securityChannel, (MethodCall methodCall) async {
        if (methodCall.method == 'isMockLocationEnabled') {
          return true; // Simulate native returning true
        }
        return null;
      });

      // act
      final result = await datasource.isMockLocationEnabled();

      // assert
      expect(result, isTrue);
    });

    test('should fallback to plugin when native channel throws PlatformException (Android 12+)', () async {
      // arrange
      bool fallbackCalled = false;
      
      // Native channel melempar exception
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(securityChannel, (MethodCall methodCall) async {
        if (methodCall.method == 'isMockLocationEnabled') {
          throw PlatformException(code: 'ERROR', message: 'Native error simulated');
        }
        return null;
      });

      // Plugin channel (fallback) mengembalikan nilai
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(fallbackChannel, (MethodCall methodCall) async {
        if (methodCall.method == 'detectFakeLocation') {
          fallbackCalled = true;
          return true; // Plugin mengembalikan true
        }
        return null;
      });

      // act
      final result = await datasource.isMockLocationEnabled();

      // assert
      expect(result, isTrue);
      expect(fallbackCalled, isTrue, reason: 'Fallback plugin seharusnya dipanggil');
    });

    test('should return false if both native and fallback throw exception', () async {
      // arrange
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(securityChannel, (MethodCall methodCall) async {
        if (methodCall.method == 'isMockLocationEnabled') {
          throw PlatformException(code: 'ERROR');
        }
        return null;
      });

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(fallbackChannel, (MethodCall methodCall) async {
        if (methodCall.method == 'detectFakeLocation') {
          throw PlatformException(code: 'ERROR');
        }
        return null;
      });

      // act
      final result = await datasource.isMockLocationEnabled();

      // assert
      expect(result, isFalse);
    });
  });
}
