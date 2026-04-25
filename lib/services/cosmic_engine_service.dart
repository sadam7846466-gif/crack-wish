import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class CosmicEngineService {
  static final CosmicEngineService _instance = CosmicEngineService._internal();
  factory CosmicEngineService() => _instance;
  CosmicEngineService._internal();

  // Bildirim Motoru
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Arka plan kozmik motorunu başlatır
  Future<void> initialize() async {
    if (_isInitialized || kIsWeb) return;
    
    // Zaman dilimi ayarları (Bildirimleri doğru saatte atmak için)
    tz.initializeTimeZones();

    // Bildirim İzinleri (Sessizce hazırlanır)
    const DarwinInitializationSettings iosRules = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const AndroidInitializationSettings androidRules = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initSettings = InitializationSettings(
      android: androidRules,
      iOS: iosRules,
    );

    await _notificationsPlugin.initialize(settings: initSettings);
    _isInitialized = true;
    debugPrint("🔮 Cosmic Engine & Notifications Initialized");
  }

  /// Kullanıcının uyku verilerini (geçici olarak devre dışı)
  /// Şimdilik sadece standart sabah ritüeli hatırlatıcısı atar
  Future<void> syncSleepAndSchedulePrediction() async {
    if (kIsWeb) return;

    try {
      // TODO: Sağlık izinleri (HealthKit) entegrasyonu ileride eklenecek.
      // Şimdilik standart bildirim atıyoruz.
      _scheduleStandardReminder();
    } catch (e) {
      debugPrint("Cosmic Engine Bildirim Zamanlama Hatası: \$e");
      _scheduleStandardReminder();
    }
  }

  /// Standart yedek bildirim (Eğer sağlık verisi yoksa)
  Future<void> _scheduleStandardReminder() async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 9, 30); // 09:30
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _scheduleSmartNotification(
      id: 102,
      title: "Ruhun Fısıldıyor ✨",
      body: "Evrenin sana gönderdiği mesajları yorumlamak için kozmik günlüğün seni bekliiyor.",
      targetTime: scheduledDate,
    );
  }

  /// Belirlenen saate nokta atışı bildirim planlar
  Future<void> _scheduleSmartNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime targetTime,
  }) async {
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: targetTime,
      notificationDetails: platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    debugPrint("📬 Akıllı Bildirim Kuruldu: \$title -> Zaman: \$targetTime");
  }

  /// İlizyon Motorunun (Evrenin) hemen veya saniyeler sonra bildirim gönderebilmesi için genel fonksiyon.
  Future<void> scheduleInstantLocalNotification({
    required String title,
    required String body,
    int secondsDelay = 2,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    final targetTime = now.add(Duration(seconds: secondsDelay));
    
    await _scheduleSmartNotification(
      id: 999, // Özel İllüzyon ID'si
      title: title, 
      body: body, 
      targetTime: targetTime,
    );
  }
}
