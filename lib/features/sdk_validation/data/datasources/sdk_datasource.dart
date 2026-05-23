import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sika/core/constants/app_constants.dart';
import 'package:sika/core/errors/failures.dart';

/// Datasource untuk mendapatkan informasi SDK Android dari Native API.
class SdkDatasource {
  static const _channel = MethodChannel(AppConstants.securityChannel);

  Future<Map<String, dynamic>> getAndroidSdkInfo() async {
    try {
      final result = await _channel.invokeMethod('getAndroidSdkInfo');
      if (result is Map) {
        return Map<String, dynamic>.from(result);
      }
      return {'sdkInt': 0, 'isWebViewAvailable': false};
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('[SdkDatasource] Error getting SDK info: ${e.message}');
      }
      throw PlatformFailure('SDK check failed: ${e.message}');
    }
  }
}
