import 'package:flutter/services.dart';

class NativeTimezoneChannel {
  static const MethodChannel _channel = MethodChannel('native_timezone');

  static Future<String> getLocalTimezone() async {
    final String timezone = await _channel.invokeMethod('getLocalTimezone');
    return timezone;
  }
}
