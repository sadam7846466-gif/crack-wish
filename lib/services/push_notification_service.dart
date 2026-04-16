import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

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

  Future<void> initialize() async {
    try {
      // SADECE Arka plan ve Ön plan dinleyicilerini başlat (İzin isteme penceresini tetiklemez)
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Uygulama açıkken bildirim geldi: ${message.notification?.title}');
        // İstersek yukarıdan SnackBar ile gösterebiliriz vs.
      });

    } catch (e) {
      debugPrint("Firebase Push Notification dinleyicileri başlatılamadı: $e");
    }
  }

  /// Doğru zamanda kullanıcıdan izin istemek ve Token almak için kullanılır (Örn: Rutin belirlendiğinde)
  Future<bool> requestPermissionAndGetToken() async {
    try {
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
        
        final fcmToken = await _fcm.getToken();
        debugPrint('Kazanılan FCM Token: $fcmToken');
        // TODO: İleride Supabase'e bu token'i kaydedeceğiz.
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("İzin alma hatası: $e");
      return false;
    }
  }
}
