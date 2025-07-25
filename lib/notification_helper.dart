import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // 初始化通知 Android
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 初始化通知 Android
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    InitializationSettings initSettings = InitializationSettings(
        android: androidInit, iOS: initializationSettingsIOS);

    await _plugin.initialize(initSettings);
  }

  static Future<void> scheduleTimerFinishedNotification({
    required int id,
    required String title,
    required String body,
    required int secondsFromNow,
    String? uniqueAttachmentName,
  }) async {
    String? localPath;
    try {
      final filename = uniqueAttachmentName ?? '1.jpeg';
      localPath = await copyAssetToFile('assets/images/1.jpeg', filename);
      if (!File(localPath).existsSync()) {
        localPath = null;
      }
    } catch (e) {
      localPath = null;
    }

    final androidDetails = AndroidNotificationDetails(
      'timer_channel',
      '倒计时',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
      styleInformation: localPath != null
          ? BigPictureStyleInformation(
              FilePathAndroidBitmap(localPath),
              contentTitle: title,
              summaryText: body,
            )
          : null,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
      attachments:
          localPath != null ? [DarwinNotificationAttachment(localPath)] : null,
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      TZDateTime.now(local).add(Duration(seconds: secondsFromNow)),
      NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
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
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filename');
    // 检查文件是否存在且内容有效（非空且大小大于0）
    if (await file.exists()) {
      final stat = await file.stat();
      if (stat.size > 0) {
        debugPrint('File already exists:  {file.path}');
        return file.path;
      } else {
        // 文件存在但内容无效，删除重拷贝
        await file.delete();
      }
    }
    final byteData = await rootBundle.load(assetPath);
    await file.writeAsBytes(byteData.buffer.asUint8List());
    debugPrint('File copied to:  {file.path}');
    return file.path;
  }
}
