import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vlucky_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:vlucky_flutter/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Arka planda mesaj gelince tetiklenir.
  await Firebase.initializeApp();
  debugPrint("Arka plan mesajı: ${message.messageId}");
}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._();
  factory PushNotificationService() => _instance;
  PushNotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Local Notifications (Sabah/Akşam Rutinleri için) Başlat
      tz.initializeTimeZones();
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false, 
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const InitializationSettings initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('YEREL BİLDİRİME TIKLANDI: ${response.payload}');
        },
      );

      // 2. Firebase Cloud Messaging Başlat
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Apple için foreground bildirimi ayarları (Ön plandayken native banner ÇIKMASIN, custom UI kullanacağız)
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: false, // native banner in-app iken gizlensin
        badge: true,
        sound: true,
      );

      // Ön Planda (Uygulama Açıkken) Firebase Mesajı Gelirse
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Uygulama açıkken bildirim geldi: ${message.notification?.title}');
        
        final title = message.notification?.title ?? 'Kozmik Bildirim';
        final body = message.notification?.body ?? '';

        // Şık Custom SnackBar HER PLATFORMDA çıksın
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            duration: const Duration(seconds: 4),
            margin: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 20),
            content: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 1)
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(body, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint("Bildirim servisleri başlatılamadı: $e");
    }
  }

  /// Kullanıcıdan izin ister, FCM Token alır ve Local Routine'leri kurar
  Future<bool> requestPermissionAndGetToken() async {
    try {
      // 1. Firebase İzni İste
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('Kullanıcı izin durumu: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized || 
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        
        // 2. iOS Local Notification İzinlerini de garantile
        await _localNotifications
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true);
            
        // 3. FCM Token Al ve Kaydet
        final fcmToken = await _fcm.getToken();
        debugPrint('Kazanılan FCM Token: $fcmToken');
        
        if (fcmToken != null) {
          final user = Supabase.instance.client.auth.currentUser;
          if (user != null) {
            try {
              await Supabase.instance.client
                  .from('profiles')
                  .update({'fcm_token': fcmToken})
                  .eq('id', user.id);
              debugPrint('✅ FCM Token Supabase profiles tablosuna başarıyla kaydedildi!');
            } catch (e) {
              debugPrint('🔴 FCM Token kaydetme hatası: $e');
            }
          }
        }
        
        // 4. İzin alındıysa sabah ve akşam otomatik rutinleri kur
        await _scheduleRoutines();
        
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("İzin alma hatası: $e");
      return false;
    }
  }

  /// Sabah, Öğle, Akşam ve Uyku (Cosmic Engine) yerel bildirimlerini kurar
  Future<void> _scheduleRoutines() async {
    // KULLANICI AYARLARINI KONTROL ET (Rastgele ve sürekli bildirim atılmasını engeller)
    final settings = await StorageService.getNotificationSettings();
    final bool dailyRemindersEnabled = settings['dailyReminders'] ?? false;

    if (!dailyRemindersEnabled) {
      debugPrint('Kullanıcı günlük bildirimleri kapattığı için rutinler iptal edildi.');
      await cancelNotification(1);
      await cancelNotification(2);
      await cancelNotification(3);
      await cancelNotification(4);
      return;
    }

    // Dinamik ve kişiselleştirilmiş bildirimler için kullanıcı verilerini çek
    final prefs = await SharedPreferences.getInstance();
    final String userName = prefs.getString('user_name') ?? "Ruh";
    final String zodiac = prefs.getString('zodiac_sign') ?? "Yıldıztozu";

    _scheduleLocalNotification(
      id: 1,
      title: 'Güneş doğdu $userName! 🌞',
      body: '$zodiac burcunun bugünkü kozmik mesajı seni bekliyor. Dün geceki rüyanı analiz et ve kurabiyeni kır.',
      hour: 9,
      minute: 0,
      channelId: 'morning_routine',
      channelName: 'Sabah Kahini',
    );
    
    // Cosmic Engine (Uyku Verisi / Akıllı Hatırlatıcı)
    _scheduleLocalNotification(
      id: 2,
      title: 'Ruhun Fısıldıyor ✨',
      body: 'Evrenin sana gönderdiği mesajları yorumlamak için kozmik günlüğün seni bekliyor.',
      hour: 9,
      minute: 30,
      channelId: 'cosmic_engine',
      channelName: 'Cosmic Engine',
    );

    // Öğleden Sonra Kurabiye Hatırlatıcısı
    _scheduleLocalNotification(
      id: 3,
      title: 'Kozmik Çay Saati 🥠',
      body: 'Bugünkü $zodiac şans kurabiyeni kırmayı unutma! Gizli bir başarım seni bekliyor olabilir.',
      hour: 15,
      minute: 0,
      channelId: 'afternoon_routine',
      channelName: 'Öğle Kurabiyesi',
    );

    _scheduleLocalNotification(
      id: 4,
      title: 'Ruhsal Dinlenme Vakti ✨',
      body: 'Günün yorgunluğunu atmak için $zodiac burcuna özel Tarot açılımın hazır. Serini kaybetmemek için gün bitmeden tıkla!',
      hour: 20,
      minute: 0,
      channelId: 'evening_routine',
      channelName: 'Akşam Tarotu',
    );
  }

  Future<void> _scheduleLocalNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required String channelId,
    required String channelName,
  }) async {
    await _localNotifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _nextInstanceOfTime(hour, minute),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Belirli bir süre sonra (örneğin Kahve falı için) tetiklenecek bildirim
  Future<void> scheduleDelayedNotification({
    required int id,
    required String title,
    required String body,
    required Duration delay,
    required String channelId,
    required String channelName,
  }) async {
    if (!_isInitialized) return;
    
    final scheduledDate = tz.TZDateTime.now(tz.local).add(delay);
    
    await _localNotifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Bir bildirimi iptal eder (Örneğin fal sayfasında kaldıysa ve sonucu gördüyse)
  Future<void> cancelNotification(int id) async {
    if (!_isInitialized) return;
    await _localNotifications.cancel(id: id);
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
