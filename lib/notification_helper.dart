import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // 初始化通知（仅需调用一次）
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidInit);
    await _plugin.initialize(initSettings);
  }

  static Future<void> scheduleTimerFinishedNotification({
    required int id,
    required String title,
    required String body,
    required int secondsFromNow,
  }) async {
    final localPath = await copyAssetToFile('assets/images/1.jpeg', '1.jpeg');

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      TZDateTime.now(local).add(Duration(seconds: secondsFromNow)),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'timer_channel',
          '倒计时',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
          styleInformation: BigPictureStyleInformation(
            FilePathAndroidBitmap(localPath),
            contentTitle: title,
            summaryText: body,
          ),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
          attachments: [DarwinNotificationAttachment(localPath)],
        ),
      ),
      androidAllowWhileIdle: false,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  static Future<String> copyAssetToFile(
      String assetPath, String filename) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filename');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file.path;
  }
}
