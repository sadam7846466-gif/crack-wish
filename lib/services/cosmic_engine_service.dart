import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:health/health.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class CosmicEngineService {
  static final CosmicEngineService _instance = CosmicEngineService._internal();
  factory CosmicEngineService() => _instance;
  CosmicEngineService._internal();

  // Bildirim ve Sağlık Motorları
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final Health _health = Health();

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

  /// Kullanıcının HealthKit'ine bağlanarak uyku verilerini analiz eder
  /// Eğer uyanma saatini tespit ederse, ona özel sabah ritüeli hatırlatıcısı atar
  Future<void> syncSleepAndSchedulePrediction() async {
    if (kIsWeb) return;

    try {
      // 1. Sağlık İzinlerini İste (Uyku Verisi)
      final types = [HealthDataType.SLEEP_IN_BED, HealthDataType.SLEEP_ASLEEP];
      
      bool requested = await _health.requestAuthorization(types);
      if (!requested) {
        debugPrint("Sağlık izni reddedildi. Standart bildirim rutini uygulanacak.");
        _scheduleStandardReminder();
        return;
      }

      // 2. Son 3 günlük uyku verisini çek
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 3));
      
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(startTime: yesterday, endTime: now, types: types);
      
      if (healthData.isEmpty) {
        // Veri yoksa standart saatte (Örn 09:00) at
        _scheduleStandardReminder();
        return;
      }

      // 3. Kullanıcının Ortalama Uyanma Saatini Analiz Et (Yapay Zeka Mantığı)
      // En son uyanış (veya genelde kalktığı) saati hesapla
      healthData.sort((a, b) => b.dateTo.compareTo(a.dateTo));
      final lastWakeup = healthData.first.dateTo;
      
      debugPrint("🛌 Son uyanma saati tespit edildi: \$lastWakeup");

      // 4. Yarın tam o saatte bildirim at! (Akıllı zamanlama)
      await _scheduleSmartNotification(
        id: 101,
        title: "Kozmik Zihnin Uyandı 🌙",
        body: "Dün gece gördüğün sembolleri unutmadan analiz etmeye ne dersin?",
        targetTime: tz.TZDateTime.from(lastWakeup.add(const Duration(days: 1)), tz.local),
      );

    } catch (e) {
      debugPrint("Cosmic Engine Sağlık Verisi Hatası: \$e");
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
