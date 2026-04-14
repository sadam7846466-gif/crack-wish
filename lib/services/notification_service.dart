import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false, // İzinleri sonradan manuel isteyeceğiz
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('BİLDİRİME TIKLANDI: ${response.payload}');
        // TODO: Deep linking ve payload yapısı eklenebilir.
      },
    );

    _isInitialized = true;
  }

  /// Doğru zamanda kullanıcıdan bildirim gönderme izni ister (Soft Prompt)
  Future<bool> requestPermissions() async {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      // iOS özel izin kodları vs uygulanabilir
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return true;
    }
    return false;
  }

  /// Sabah Rutini Paketi: Rüya, Günlük Kurabiye ve Astroloji (Her sabah atılır)
  Future<void> scheduleMorningRoutine({required int targetHour, required int targetMinute}) async {
    await _notificationsPlugin.zonedSchedule(
      1, // Sabah id'si
      'Güneş doğdu! 🌞', // Titreşimli tazeleyici bir başlık
      'Dün geceki rüyanı analiz et, taze kurabiyeni kır ve gökyüzünün bugünkü mesajını öğren.',
      _nextInstanceOfTime(targetHour, targetMinute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'morning_routine',
          'Sabah Kahini',
          channelDescription: 'Günlük fal, kurabiye ve rüya yorulmaları',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Her gün aynı saatte tekrar et
    );
  }

  /// Akşam Rutini Paketi: Tarot Serisi (Her akşam atılır)
  Future<void> scheduleEveningRoutine({required int targetHour, required int targetMinute}) async {
    await _notificationsPlugin.zonedSchedule(
      2, // Akşam id'si
      'Ruhsal Dinlenme Vakti ✨',
      'Günün yorgunluğunu atmak için Tarot açılımın hazır. Serini kaybetmemek için gün bitmeden tıkla!',
      _nextInstanceOfTime(targetHour, targetMinute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'evening_routine',
          'Akşam Tarotu',
          channelDescription: 'Seri koruma ve Tarot bildirimleri',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Her gün aynı saatte tekrar et
    );
  }

  /// Bütün bekleyen bildirimleri iptal eder
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Belirtilen saatin bir sonraki denk gelişini bulur (saat geçtiyse yarını ayarlar)
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
