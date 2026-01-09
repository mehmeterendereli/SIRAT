import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:injectable/injectable.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:shared_preferences/shared_preferences.dart';

/// Ezan Sesi Seçenekleri (PRT-006)
enum AzanSound {
  mecca,      // Mekke ezanı
  istanbul,   // İstanbul makamı
  medina,     // Medine usulü
  ney,        // Ney sesi
  silent,     // Sessiz (sadece titreşim)
}

/// Erteleme Süresi Seçenekleri (PRT-004)
enum SnoozeOption {
  min5(5),
  min10(10),
  min15(15),
  min30(30);

  const SnoozeOption(this.minutes);
  final int minutes;
}

/// Professional Notification System (Bölüm 3.1)
/// Handles Azan alerts, Pre-alarms, Snooze, and custom sounds.
/// PRT-004: Akıllı erteleme ("10 dk sonra hatırlat")
/// PRT-005: Pre-alarm (Temkin vakti, iftara 15dk kala)
/// PRT-006: Ezan ses kütüphanesi

@lazySingleton
class NotificationService {
  final fln.FlutterLocalNotificationsPlugin _notifications = fln.FlutterLocalNotificationsPlugin();
  
  // Notification Channel IDs
  static const String _azanChannelId = 'sirat_azan_channel';
  static const String _preAlarmChannelId = 'sirat_prealarm_channel';
  static const String _iftarChannelId = 'sirat_iftar_channel';
  static const String _snoozeChannelId = 'sirat_snooze_channel';
  
  // Notification ID Offsets
  static const int _preAlarmOffset = 1000;
  static const int _snoozeOffset = 2000;
  static const int _iftarOffset = 3000;
  static const int _sahurOffset = 4000;

  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    
    const androidSettings = fln.AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = fln.DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    await _notifications.initialize(
      const fln.InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _handleNotificationAction,
    );
    
    // Create notification channels for Android 8.0+
    await _createNotificationChannels();
  }

  Future<void> _createNotificationChannels() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        fln.AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      // Main Azan Channel
      await androidPlugin.createNotificationChannel(
        const fln.AndroidNotificationChannel(
          _azanChannelId,
          'Ezan Vakti Bildirimleri',
          description: 'Namaz vakti geldiğinde bildirim alın',
          importance: fln.Importance.max,
          playSound: true,
          enableVibration: true,
        ),
      );
      
      // Pre-Alarm Channel
      await androidPlugin.createNotificationChannel(
        const fln.AndroidNotificationChannel(
          _preAlarmChannelId,
          'Vakit Hatırlatıcısı',
          description: 'Namaz vaktine kaç dakika kaldığını hatırlatır',
          importance: fln.Importance.high,
        ),
      );
      
      // Iftar Channel
      await androidPlugin.createNotificationChannel(
        const fln.AndroidNotificationChannel(
          _iftarChannelId,
          'İftar & Sahur Bildirimleri',
          description: 'Ramazan ayında iftar ve sahur hatırlatmaları',
          importance: fln.Importance.max,
        ),
      );
    }
  }

  /// Handle notification action buttons
  void _handleNotificationAction(fln.NotificationResponse response) async {
    final payload = response.payload;
    final actionId = response.actionId;
    
    if (payload == null) return;
    
    // Parse payload for snooze action
    if (actionId == 'snooze_10min' || actionId == 'snooze') {
      final parts = payload.split('|');
      if (parts.length >= 3) {
        final originalId = int.tryParse(parts[0]) ?? 0;
        final title = parts[1];
        final body = parts[2];
        
        await scheduleSnooze(
          originalId: originalId,
          title: title,
          body: body,
          snoozeMinutes: 10,
        );
      }
    }
  }

  /// Get sound file name based on AzanSound enum
  String _getSoundFileName(AzanSound sound) {
    switch (sound) {
      case AzanSound.mecca:
        return 'azan_mecca';
      case AzanSound.istanbul:
        return 'azan_istanbul';
      case AzanSound.medina:
        return 'azan_medina';
      case AzanSound.ney:
        return 'ney';
      case AzanSound.silent:
        return ''; // No sound
    }
  }

  /// Get user's preferred azan sound
  Future<AzanSound> getPreferredSound() async {
    final prefs = await SharedPreferences.getInstance();
    final soundIndex = prefs.getInt('azan_sound') ?? 1; // Default: Istanbul
    return AzanSound.values[soundIndex.clamp(0, AzanSound.values.length - 1)];
  }

  /// Save user's preferred azan sound
  Future<void> setPreferredSound(AzanSound sound) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('azan_sound', sound.index);
  }

  /// Get user's preferred pre-alarm minutes
  Future<int> getPreAlarmMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('pre_alarm_minutes') ?? 15; // Default: 15 minutes
  }

  /// Save user's preferred pre-alarm minutes
  Future<void> setPreAlarmMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('pre_alarm_minutes', minutes);
  }

  /// Schedule Azan Notification with action buttons (PRT-004)
  Future<void> scheduleAzanNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    AzanSound? sound,
  }) async {
    // Don't schedule for past times
    if (scheduledDate.isBefore(DateTime.now())) return;
    
    final scheduledTzDate = tz.TZDateTime.from(scheduledDate, tz.local);
    final preferredSound = sound ?? await getPreferredSound();
    final soundFileName = _getSoundFileName(preferredSound);

    // Prepare Android notification with action buttons
    final androidDetails = fln.AndroidNotificationDetails(
      _azanChannelId,
      'Ezan Vakti Bildirimleri',
      channelDescription: 'Namaz vakti geldiğinde bildirim alın',
      importance: fln.Importance.max,
      priority: fln.Priority.high,
      sound: soundFileName.isNotEmpty 
          ? fln.RawResourceAndroidNotificationSound(soundFileName)
          : null,
      playSound: soundFileName.isNotEmpty,
      enableVibration: true,
      actions: <fln.AndroidNotificationAction>[
        const fln.AndroidNotificationAction(
          'snooze_10min',
          '10 dk Ertele',
          showsUserInterface: false,
        ),
        const fln.AndroidNotificationAction(
          'dismiss',
          'Kapat',
          cancelNotification: true,
        ),
      ],
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledTzDate,
      fln.NotificationDetails(
        android: androidDetails,
        iOS: fln.DarwinNotificationDetails(
          sound: soundFileName.isNotEmpty ? '$soundFileName.aiff' : null,
        ),
      ),
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
      payload: '$id|$title|$body',
    );
  }

  /// Schedule Snooze Notification (PRT-004)
  Future<void> scheduleSnooze({
    required int originalId,
    required String title,
    required String body,
    int snoozeMinutes = 10,
  }) async {
    final snoozeTime = DateTime.now().add(Duration(minutes: snoozeMinutes));
    final scheduledTzDate = tz.TZDateTime.from(snoozeTime, tz.local);

    await _notifications.zonedSchedule(
      originalId + _snoozeOffset,
      title,
      'Ertelendi: $body',
      scheduledTzDate,
      fln.NotificationDetails(
        android: fln.AndroidNotificationDetails(
          _snoozeChannelId,
          'Ertelenen Bildirimler',
          channelDescription: 'Ertelenen namaz vakti bildirimleri',
          importance: fln.Importance.max,
          priority: fln.Priority.high,
        ),
        iOS: const fln.DarwinNotificationDetails(),
      ),
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Schedule Pre-Alarm (Temkin) - PRT-005
  Future<void> schedulePreAlarm({
    required int id,
    required String prayerName,
    required DateTime azanTime,
    int? minutesBefore,
  }) async {
    final minutes = minutesBefore ?? await getPreAlarmMinutes();
    final preAlarmTime = azanTime.subtract(Duration(minutes: minutes));
    
    if (preAlarmTime.isBefore(DateTime.now())) return;
    
    final scheduledTzDate = tz.TZDateTime.from(preAlarmTime, tz.local);

    await _notifications.zonedSchedule(
      id + _preAlarmOffset,
      '$prayerName Vakti Yaklaşıyor',
      '$minutes dakika sonra $prayerName vakti girecek.',
      scheduledTzDate,
      fln.NotificationDetails(
        android: fln.AndroidNotificationDetails(
          _preAlarmChannelId,
          'Vakit Hatırlatıcısı',
          channelDescription: 'Namaz vaktine kaç dakika kaldığını hatırlatır',
          importance: fln.Importance.high,
          priority: fln.Priority.high,
        ),
        iOS: const fln.DarwinNotificationDetails(),
      ),
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Schedule Iftar Alert - PRT-005
  Future<void> scheduleIftarAlert({
    required DateTime iftarTime,
    int minutesBefore = 15,
  }) async {
    final alertTime = iftarTime.subtract(Duration(minutes: minutesBefore));
    
    if (alertTime.isBefore(DateTime.now())) return;
    
    final scheduledTzDate = tz.TZDateTime.from(alertTime, tz.local);

    await _notifications.zonedSchedule(
      DateTime.now().day + _iftarOffset, // Unique per day
      'İftar Yaklaşıyor',
      '$minutesBefore dakika sonra iftar vakti!',
      scheduledTzDate,
      fln.NotificationDetails(
        android: fln.AndroidNotificationDetails(
          _iftarChannelId,
          'İftar & Sahur Bildirimleri',
          channelDescription: 'Ramazan ayında iftar ve sahur hatırlatmaları',
          importance: fln.Importance.max,
          priority: fln.Priority.high,
        ),
        iOS: const fln.DarwinNotificationDetails(),
      ),
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Schedule Sahur Alert - PRT-005
  Future<void> scheduleSahurAlert({
    required DateTime sahurEndTime,
    int minutesBefore = 30,
  }) async {
    final alertTime = sahurEndTime.subtract(Duration(minutes: minutesBefore));
    
    if (alertTime.isBefore(DateTime.now())) return;
    
    final scheduledTzDate = tz.TZDateTime.from(alertTime, tz.local);

    await _notifications.zonedSchedule(
      DateTime.now().day + _sahurOffset,
      'Sahur Vakti Bitiyor',
      '$minutesBefore dakika sonra imsak vakti!',
      scheduledTzDate,
      fln.NotificationDetails(
        android: fln.AndroidNotificationDetails(
          _iftarChannelId,
          'İftar & Sahur Bildirimleri',
          channelDescription: 'Ramazan ayında iftar ve sahur hatırlatmaları',
          importance: fln.Importance.max,
          priority: fln.Priority.high,
        ),
        iOS: const fln.DarwinNotificationDetails(),
      ),
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Schedule all prayer notifications for a day
  Future<void> scheduleDailyPrayerNotifications({
    required DateTime fajr,
    required DateTime sunrise,
    required DateTime dhuhr,
    required DateTime asr,
    required DateTime maghrib,
    required DateTime isha,
    bool includePreAlarms = true,
  }) async {
    final prayers = {
      'İmsak': fajr,
      'Güneş': sunrise,
      'Öğle': dhuhr,
      'İkindi': asr,
      'Akşam': maghrib,
      'Yatsı': isha,
    };

    int baseId = 100;
    for (final entry in prayers.entries) {
      await scheduleAzanNotification(
        id: baseId,
        title: '${entry.key} Vakti',
        body: '${entry.key} namazı vakti girdi.',
        scheduledDate: entry.value,
      );
      
      if (includePreAlarms) {
        await schedulePreAlarm(
          id: baseId,
          prayerName: entry.key,
          azanTime: entry.value,
        );
      }
      
      baseId += 1;
    }
  }

  /// Cancel a specific notification
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Get pending notifications (for debugging)
  Future<List<fln.PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}

