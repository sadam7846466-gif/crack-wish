import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vlucky_flutter/main.dart';
import 'package:flutter/material.dart';

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
        
        final title = message.notification?.title ?? 'Kozmik Bildirim';
        final body = message.notification?.body ?? '';

        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
                boxShadow: [
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
            duration: const Duration(seconds: 4),
            margin: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 20),
          ),
        );
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
        
        // Supabase'e Token'i Kaydet
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
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("İzin alma hatası: $e");
      return false;
    }
  }
}
