import 'package:flutter/services.dart';

class PrivacyGuard {
  static const _channel = MethodChannel('spendly/privacy');

  static Future<void> setWindowSecure(bool secure) async {
    try {
      await _channel.invokeMethod('setWindowSecure', {'secure': secure});
    } catch (_) {
    }
  }
}
