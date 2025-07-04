import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();
    const InitializationSettings initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);
    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  static Future<void> showTimerFinishedNotification(
      {required int id, required String title, required String body}) async {
    await init();
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'timer_channel',
      '倒计时提醒',
      channelDescription: '倒计时结束提醒',
      importance: Importance.max,
      priority: Priority.high,
      playSound: false,
    );
    const DarwinNotificationDetails iosDetails =
        DarwinNotificationDetails(presentSound: false);
    const NotificationDetails details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _plugin.show(id, title, body, details);
  }
}
