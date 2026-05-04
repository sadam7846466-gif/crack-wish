import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

      // Apple için foreground bildirimi ayarları — native banner olarak göstersin
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,  // Ön plandayken de native banner çıksın
        badge: true,
        sound: true,
      );

      // Ön Planda (Uygulama Açıkken) Firebase Mesajı Gelirse
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Uygulama açıkken bildirim geldi: ${message.notification?.title}');
        
        // iOS: setForegroundNotificationPresentationOptions ile native banner otomatik çıkar
        // Android: Local notification ile göster (çünkü Android FCM ön planda otomatik göstermez)
        if (defaultTargetPlatform == TargetPlatform.android) {
          final title = message.notification?.title ?? 'Kozmik Bildirim';
          final body = message.notification?.body ?? '';
          _localNotifications.show(
            id: message.hashCode,
            title: title,
            body: body,
            notificationDetails: const NotificationDetails(
              android: AndroidNotificationDetails(
                'fcm_foreground',
                'Bildirimler',
                importance: Importance.high,
                priority: Priority.high,
              ),
            ),
          );
        }
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
        
        // 4. İzin alındıysa akıllı bildirimleri kur
        await _scheduleRoutines();
        
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("İzin alma hatası: $e");
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // AKILLI BİLDİRİM MOTORU — Kullanıcı davranışına göre karar verir
  // Mesajlar her gün rotasyonla değişir. Yapılan aktivite → bildirim iptal.
  // ═══════════════════════════════════════════════════════════════

  Future<void> _scheduleRoutines() async {
    final settings = await StorageService.getNotificationSettings();
    final bool dailyRemindersEnabled = settings['dailyReminders'] ?? false;

    if (!dailyRemindersEnabled) {
      for (int i = 1; i <= 10; i++) { await cancelNotification(i); }
      await cancelNotification(901);
      await cancelNotification(902);
      await cancelNotification(903);
      await cancelNotification(904);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final String userName = prefs.getString('user_name') ?? "Ruh";
    final String zodiac = prefs.getString('zodiac_sign') ?? "Yıldıztozu";
    final int dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;

    final bool cookieDone = (await StorageService.getCookieCracksToday()) > 0;
    final bool tarotDone = await StorageService.isTarotDoneToday();
    final bool dreamDone = await StorageService.isDreamDoneToday();
    final int streakDays = await StorageService.getStreakDays();

    // ── SABAH (09:00) — Her gün farklı mesaj ──
    final morningMessages = [
      ['Günaydın $userName! ☀️', '$zodiac burcunun bugünkü kozmik mesajı hazır.'],
      ['Yeni bir gün, yeni bir şans ✨', '$userName, evren bugün senin için ne hazırladı?'],
      ['Kozmik enerji yüksek! 🌟', '$zodiac burcu bugün güçlü. Fırsatları kaçırma!'],
      ['Bugün senin günün $userName 🔮', 'Yıldızlar $zodiac burcuna gülümsüyor.'],
      ['Evren seninle konuşmak istiyor 🌌', '$userName, bugünkü kozmik rehberliğin hazır.'],
      ['Ruhun uyanıyor $userName 💫', '$zodiac enerjisi bugün dorukta!'],
      ['Kozmik kahvaltı zamanı ☕', '$userName, günün mesajını almadan çıkma!'],
    ];
    final mo = morningMessages[dayOfYear % morningMessages.length];
    _scheduleLocalNotification(id: 1, title: mo[0], body: mo[1], hour: 9, minute: 0, channelId: 'morning_routine', channelName: 'Sabah Kahini');

    // ── ÖĞLE (13:00) — Kurabiye kırılmadıysa ──
    if (!cookieDone) {
      final cookieMessages = [
        ['Bugünkü kurabiyeni kırmadın 🥠', '$zodiac şans kurabiyende gizli bir mesaj var!'],
        ['Şans kurabiyesi seni bekliyor 🍪', 'Bugünkü $zodiac mesajını kurabiyende bul!'],
        ['Kurabiyeni kırmadan günü kapatma 🥠', 'İçindeki mesaj seni şaşırtabilir!'],
        ['Kırmadığın kurabiye, kaçırdığın şans! ✨', '$userName, şans kurabiyeni kırmayı unuttun.'],
      ];
      final co = cookieMessages[dayOfYear % cookieMessages.length];
      _scheduleLocalNotification(id: 2, title: co[0], body: co[1], hour: 13, minute: 0, channelId: 'cookie_reminder', channelName: 'Kurabiye Hatırlatıcı');
    } else {
      await cancelNotification(2);
    }

    // ── AKŞAM (18:00) — Tarot bakılmadıysa ──
    if (!tarotDone) {
      final tarotMessages = [
        ['Akşam kartın seni bekliyor 🃏', 'Bugünün enerjisini okumak için $zodiac tarot açılımını kaçırma!'],
        ['Kartlar fısıldıyor $userName 🔮', 'Bugün için sana bir mesaj var. Tarot kartını çek!'],
        ['Akşam enerjisi güçlü 🌙', '$zodiac burcuna özel kart açılımın hazır.'],
        ['Gün bitmeden kartını çek ✨', 'Evrenin sana bugün ne söylediğini merak etmiyor musun?'],
      ];
      final ta = tarotMessages[dayOfYear % tarotMessages.length];
      _scheduleLocalNotification(id: 3, title: ta[0], body: ta[1], hour: 18, minute: 0, channelId: 'tarot_reminder', channelName: 'Tarot Hatırlatıcı');
    } else {
      await cancelNotification(3);
    }

    // ── GECE (21:00) — Rüya yazmadıysa ──
    if (!dreamDone) {
      final dreamMessages = [
        ['Dün gece bir rüya gördün mü? 🌙', 'Rüya günlüğün seni bekliyor. Bilinçaltının mesajını kaçırma!'],
        ['Rüyaların bir şey anlatıyor 💭', '$userName, rüyanı yaz ve bilinçaltını keşfet!'],
        ['Uyumadan önce rüyanı yaz 🌌', 'Gece gördüklerin evrenin sana mesajı olabilir.'],
        ['Rüya defterine bir not düş 📝', '$zodiac burcunun rüya enerjisi bu gece yüksek!'],
      ];
      final dr = dreamMessages[dayOfYear % dreamMessages.length];
      _scheduleLocalNotification(id: 4, title: dr[0], body: dr[1], hour: 21, minute: 0, channelId: 'dream_reminder', channelName: 'Rüya Hatırlatıcı');
    } else {
      await cancelNotification(4);
    }

    // ── BURÇ SEZONU (10:00) — Sezon değişim günlerinde ──
    final zodiacSeason = _getZodiacSeasonToday();
    if (zodiacSeason != null) {
      final isUserSeason = zodiacSeason.toLowerCase() == zodiac.toLowerCase();
      _scheduleLocalNotification(
        id: 5,
        title: isUserSeason ? '♈ $zodiac sezonu başladı! 🎉' : '$zodiacSeason sezonu başladı! ✨',
        body: isUserSeason
            ? '$userName, bu dönem tamamen senin! Kozmik enerjin dorukta.'
            : 'Yeni kozmik dönem! $zodiac burcunu nasıl etkiler? Gel öğren.',
        hour: 10, minute: 0, channelId: 'zodiac_season', channelName: 'Burç Sezonu',
      );
    } else {
      await cancelNotification(5);
    }

    // ── DOĞUM GÜNÜ (00:01) — Yılda 1 kez ──
    final birthDateStr = prefs.getString('birth_date');
    if (birthDateStr != null) {
      final birthDate = DateTime.tryParse(birthDateStr);
      if (birthDate != null) {
        final now = DateTime.now();
        if (birthDate.month == now.month && birthDate.day == now.day) {
          _scheduleLocalNotification(
            id: 6,
            title: '🎂 Doğum günün kutlu olsun $userName!',
            body: 'Kozmik Baykuş sana özel bir doğum günü mektubu bıraktı 🦉✨',
            hour: 0, minute: 1,
            channelId: 'birthday', channelName: 'Doğum Günü',
          );
        } else {
          await cancelNotification(6);
        }
      }
    }

    // ── SERİ KUTLAMASI (12:00) — 7, 14, 30, 50, 100 gün ──
    if ({7, 14, 30, 50, 100}.contains(streakDays)) {
      _scheduleLocalNotification(
        id: 7,
        title: '🔥 $streakDays günlük seri! Muhteşem $userName!',
        body: 'Kozmik kararlılığın ödülsüz kalmaz. Seni özel bir sürpriz bekliyor!',
        hour: 12, minute: 0,
        channelId: 'streak_celebration', channelName: 'Seri Kutlaması',
      );
    } else {
      await cancelNotification(7);
    }

    // ── KOZMİK OLAYLAR (14:00) — Dolunay, Yeniay, Merkür Retrosu ──
    final cosmicEvent = _getCosmicEventToday();
    if (cosmicEvent != null) {
      _scheduleLocalNotification(
        id: 8,
        title: cosmicEvent['title']!,
        body: cosmicEvent['body']!
            .replaceAll('{zodiac}', zodiac)
            .replaceAll('{name}', userName),
        hour: 14, minute: 0,
        channelId: 'cosmic_events', channelName: 'Kozmik Olaylar',
      );
    } else {
      await cancelNotification(8);
    }

    // ── GERİ KAZANIM (RE-ENGAGEMENT) BİLDİRİMLERİ (Katman 3) ──
    await _scheduleReEngagementNotifications(userName, zodiac);
  }

  // ═══════════════════════════════════════════════════════════════
  // YARDIMCI MOTORLAR
  // ═══════════════════════════════════════════════════════════════

  /// Bugün bir burç sezonu başlıyor mu?
  String? _getZodiacSeasonToday() {
    final now = DateTime.now();
    final md = now.month * 100 + now.day;
    const seasons = {
      121: 'Kova', 219: 'Balık', 321: 'Koç', 420: 'Boğa',
      521: 'İkizler', 621: 'Yengeç', 723: 'Aslan', 823: 'Başak',
      923: 'Terazi', 1023: 'Akrep', 1122: 'Yay', 1222: 'Oğlak',
    };
    return seasons[md];
  }

  /// Bugün özel bir kozmik olay var mı? (2026 takvimi)
  Map<String, String>? _getCosmicEventToday() {
    final now = DateTime.now();
    final key = '${now.month}-${now.day}';
    const events = <String, Map<String, String>>{
      // 2026 Dolunayları
      '1-13': {'title': 'Dolunay Gecesi 🌕', 'body': '{zodiac} burcunda dolunay! Duygular yoğun, farkındalık yüksek.'},
      '2-12': {'title': 'Dolunay Enerjisi 🌕', 'body': '{name}, dolunay gecesi rüyaların çok anlamlı olabilir!'},
      '3-14': {'title': 'Dolunay Aydınlanması 🌕', 'body': 'Bu gece dolunay! {zodiac} burcunu derinlemesine etkiliyor.'},
      '4-12': {'title': 'Dolunay Gücü 🌕', 'body': '{name}, dolunay gecesi tarot kartın çok güçlü!'},
      '5-12': {'title': 'Dolunay Sihri 🌕', 'body': '{zodiac} burcunun dolunay enerjisi dorukta! Niyetini belirle.'},
      '6-11': {'title': 'Dolunay Ritüeli 🌕', 'body': 'Bu gece dolunay! {name}, kozmik enerjinle bağlan.'},
      '7-10': {'title': 'Dolunay Farkındalığı 🌕', 'body': '{zodiac} burcu dolunaydan güç alıyor!'},
      '8-8':  {'title': 'Dolunay Dönüşümü 🌕', 'body': 'Dolunay gecesi! {name}, içsel dönüşümün başlıyor.'},
      '9-7':  {'title': 'Dolunay Hasadı 🌕', 'body': '{zodiac} burcunda hasat zamanı. Emeklerinin karşılığı geliyor!'},
      '10-7': {'title': 'Dolunay Dengesi 🌕', 'body': '{name}, bu dolunay denge getiriyor.'},
      '11-5': {'title': 'Dolunay Derinliği 🌕', 'body': 'Dolunay! {zodiac} burcu için derin sezgiler.'},
      '12-4': {'title': 'Dolunay Kapanışı 🌕', 'body': 'Yılın son dolunaylarından biri! {name}, döngüyü kapat.'},
      // 2026 Yeniayları
      '1-29': {'title': 'Yeniay Başlangıcı 🌑', 'body': '{name}, yeniay yeni niyetler için mükemmel!'},
      '2-28': {'title': 'Yeniay Enerjisi 🌑', 'body': '{zodiac} burcunda yeniay. Yeni başlangıçlar seni bekliyor!'},
      '5-27': {'title': 'Yeniay Niyeti 🌑', 'body': '{name}, yeniay gecesi bir niyet belirle. Evren dinliyor.'},
      // 2026 Merkür Retroları
      '3-15': {'title': 'Merkür Retrosu Başladı ☿️', 'body': '{zodiac} dikkat! İletişimde yanlış anlaşılmalar olabilir.'},
      '4-7':  {'title': 'Merkür Retrosu Bitti ✨', 'body': 'Rahatlama zamanı {name}! İletişim yeniden akıyor.'},
      '7-18': {'title': 'Merkür Retrosu Başladı ☿️', 'body': '{zodiac} yaz retrosuna hazır mısın? Sabırlı ol.'},
      '8-11': {'title': 'Merkür Retrosu Bitti ✨', 'body': '{name}, retro bitti! Planlarını hayata geçir.'},
      '11-10': {'title': 'Merkür Retrosu Başladı ☿️', 'body': 'Son retro! {zodiac} yıl sonunu sakin geçir.'},
      '12-1': {'title': 'Merkür Retrosu Bitti ✨', 'body': '{name}, yılın son retrosu bitti. Özgürce ilerle!'},
      // Asya (Çin) Astrolojisi (2026)
      '2-17': {'title': 'Çin Yeni Yılı 🐉', 'body': 'Ateş Atı yılı başlıyor! Asya burcunun sana ne getireceğini öğren.'},
      '8-22': {'title': 'Kozmik Tanabata 🎋', 'body': 'Yıldız festivali enerjisi yüksek! {name}, dileklerini evrene gönder.'},
      '9-25': {'title': 'Güz Ortası Festivali 🥮', 'body': 'Ay enerjisi en parlak halinde. İçsel dengeyi bulma zamanı.'},
      // Maya Takvimi Olayları
      '4-4':  {'title': 'Tzolk\'in Portalı 🌀', 'body': 'Maya takviminde özel bir galaktik portal günü. Enerjin değişiyor!'},
      '7-25': {'title': 'Zaman Dışı Gün ⏳', 'body': 'Maya takviminde Zaman Dışı Gün. Geçmişi bırak, yarına hazırlan.'},
      '12-21':{'title': 'Kozmik Yenilenme ☀️', 'body': 'Güneş dönümü! Maya bilgeliğine göre ruhunu arındırma zamanı.'},
    };
    return events[key];
  }

  // ═══════════════════════════════════════════════════════════════
  // BİLDİRİM ALTYAPISI
  // ═══════════════════════════════════════════════════════════════

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
          channelId, channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// App açılmadığında tetiklenecek geri kazanım bildirimleri (Katman 3)
  /// Bu fonksiyon her app açılışında çağrılır ve gelecekteki bildirimleri öteler.
  Future<void> _scheduleReEngagementNotifications(String userName, String zodiac) async {
    final now = tz.TZDateTime.now(tz.local);

    // Eski re-engagement'leri iptal et (böylece her giriş yaptığında ötelenir)
    await cancelNotification(901);
    await cancelNotification(902);
    await cancelNotification(903);
    await cancelNotification(904);

    const details = NotificationDetails(
      android: AndroidNotificationDetails('re_engagement', 'Geri Kazanım', importance: Importance.high, priority: Priority.high),
      iOS: DarwinNotificationDetails(),
    );

    // 2 Gün Sonra
    await _localNotifications.zonedSchedule(
      id: 901,
      title: 'Kozmik Birikimin Var ✨',
      body: '$userName, $zodiac burcunun 2 günlük enerjisi birikti. Gel ve topla!',
      scheduledDate: now.add(const Duration(days: 2)),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    // 5 Gün Sonra
    await _localNotifications.zonedSchedule(
      id: 902,
      title: 'Seni Özledik $userName 🦉',
      body: 'Baykuşun sana gizli bir sürpriz mektup bıraktı. Görmek ister misin?',
      scheduledDate: now.add(const Duration(days: 5)),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    // 14 Gün Sonra
    await _localNotifications.zonedSchedule(
      id: 903,
      title: 'Önemli Bir Kozmik Dönem 🌟',
      body: '$zodiac burcunun bu hafta çok özel bir döngüsü var. Bunu kaçırmamalısın!',
      scheduledDate: now.add(const Duration(days: 14)),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    // 30 Gün Sonra (Son şans)
    await _localNotifications.zonedSchedule(
      id: 904,
      title: 'Kozmik Enerjin Zayıflıyor... 🔥',
      body: '$userName, şans serini yeniden başlatmak için son çağrı. Evren seni bekliyor!',
      scheduledDate: now.add(const Duration(days: 30)),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
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
          channelId, channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Bir bildirimi iptal eder
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

  Future<void> updateTopicSubscription(String topic, bool subscribe) async {
    try {
      if (subscribe) {
        await _fcm.subscribeToTopic(topic);
      } else {
        await _fcm.unsubscribeFromTopic(topic);
      }
      debugPrint('Topic $topic subscription: $subscribe');
    } catch (e) {
      debugPrint('Topic subscription error: $e');
    }
  }

  void updateDailyReminders(bool enable) {
    if (enable) {
      _scheduleRoutines();
    } else {
      for (int i = 1; i <= 10; i++) { cancelNotification(i); }
      cancelNotification(901);
      cancelNotification(902);
      cancelNotification(903);
      cancelNotification(904);
    }
  }

  /// Kullanıcı bir aktivite yaptığında bildirim zamanlamalarını güncelle.
  /// Böylece "kurabiye kırmadın" bildirimi, kurabiye kırıldığında iptal olur.
  Future<void> refreshSmartNotifications() async {
    if (!_isInitialized) return;
    await _scheduleRoutines();
  }
}
