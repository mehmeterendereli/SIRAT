import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// Professional Notification System (Bölüm 3.1)
/// Handles Azan alerts, Pre-alarms, and custom sounds.

@lazySingleton
class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    await _notifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
  }

  /// Schedule Azan Notification
  Future<void> scheduleAzanNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? soundFileName,
  }) async {
    final scheduledTzDate = tz.TZDateTime.from(scheduledDate, tz.local);
    
    // Fallback sound if none provided
    final sound = soundFileName ?? 'azan_standard';

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledTzDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'sirat_azan_channel',
          'SIRAT Azan Notifications',
          channelDescription: 'Ezan vakti bildirimleri',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound(sound),
        ),
        iOS: DarwinNotificationDetails(
          sound: '$sound.aiff',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Schedule Pre-Alarm (Temkin)
  Future<void> schedulePreAlarm({
    required int id,
    required String title,
    required int minutesBefore,
    required DateTime azanTime,
  }) async {
    final preAlarmTime = azanTime.subtract(Duration(minutes: minutesBefore));
    if (preAlarmTime.isBefore(DateTime.now())) return;

    await scheduleAzanNotification(
      id: id + 1000, // Offset for pre-alarms
      title: title,
      body: '$minutesBefore dakika sonra ezan okunacak.',
      scheduledDate: preAlarmTime,
    );
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
