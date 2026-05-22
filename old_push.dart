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
  debugPrint("Arka plan mesajı: ${message.messageId} - type: ${message.data['type']}");
  
  final type = message.data['type'];
  
  // Rüya veya kahve falı hazır bildirimi geldiğinde, flag'leri ayarla
  if (type == 'dream_reading_ready' || type == 'coffee_reading_ready') {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (type == 'dream_reading_ready') {
        // "Hazır" flag'lerini HEMEN ayarla — app açılınca anında göstersin
        await prefs.setBool('dream_last_reading_viewed', false);
        await prefs.setBool('dream_last_reading_notified', false);
        await prefs.setBool('dream_push_received', true);
        debugPrint('🌙 Arka plan: Rüya hazır flag\'leri ayarlandı');
      } else if (type == 'coffee_reading_ready') {
        await prefs.setBool('coffee_last_reading_viewed', false);
        await prefs.setBool('coffee_last_reading_notified', false);
        await prefs.setBool('coffee_push_received', true);
        debugPrint('☕ Arka plan: Kahve hazır flag\'leri ayarlandı');
      }
    } catch (e) {
      debugPrint('Arka plan handler hatası: $e');
    }
  }
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
      // Türkiye saat dilimini ayarla — yoksa UTC'de kalır ve bildirimler 3 saat geç gider!
      tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
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

      if (defaultTargetPlatform == TargetPlatform.android) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(const AndroidNotificationChannel(
              'owl_channel',
              'Baykuş Mektupları',
              description: 'Kozmik baykuş mesajları',
              importance: Importance.max,
              sound: RawResourceAndroidNotificationSound('baykuszili'),
            ));
      }

      // 2. Firebase Cloud Messaging Başlat
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Apple için foreground bildirimi ayarları — in-app toast ile yönetildiği için native banner KAPALI
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: false,  // Ön plandayken native banner çıkmasın (in-app toast yeterli)
        badge: true,
        sound: false,
      );

      // Ön Planda (Uygulama Açıkken) Firebase Mesajı Gelirse
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Uygulama açıkken bildirim geldi: ${message.notification?.title}');
        
        // iOS: setForegroundNotificationPresentationOptions ile native banner otomatik çıkar
        // Android: Local notification ile göster (çünkü Android FCM ön planda otomatik göstermez)
        if (defaultTargetPlatform == TargetPlatform.android) {
          final title = message.notification?.title ?? 'Kozmik Bildirim';
          final body = message.notification?.body ?? '';
          final soundName = message.data['type'] == 'new_letter' ? 'baykuszili' : null;

          _localNotifications.show(
            id: message.hashCode,
            title: title,
            body: body,
            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                soundName != null ? 'owl_channel' : 'fcm_foreground',
                'Bildirimler',
                importance: Importance.high,
                priority: Priority.high,
                sound: soundName != null ? RawResourceAndroidNotificationSound(soundName) : null,
              ),
            ),
          );
        }
      });

      _isInitialized = true;

      // ── OTOMATİK: İzin iste + Token al + Bildirimleri planla ──
      // App her açıldığında tüm bildirim altyapısını garanti altına al
      await requestPermissionAndGetToken();
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

  String _translateZodiac(String sign) {
    final map = {
      'aries': 'Koç', 'taurus': 'Boğa', 'gemini': 'İkizler',
      'cancer': 'Yengeç', 'leo': 'Aslan', 'virgo': 'Başak',
      'libra': 'Terazi', 'scorpio': 'Akrep', 'sagittarius': 'Yay',
      'capricorn': 'Oğlak', 'aquarius': 'Kova', 'pisces': 'Balık'
    };
    return map[sign.trim().toLowerCase()] ?? sign;
  }

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
    final String rawZodiac = prefs.getString('zodiac_sign') ?? "Yıldıztozu";
    final String zodiac = _translateZodiac(rawZodiac);
    final int dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;

    // Her kullanıcıya özel "Organik Bildirim Dakikası" (0-59 arası)
    // Böylece herkese tam saatinde gitmez, sistem saati doğal hissettirir.
    final int userHash = userName.hashCode.abs();
    final int minuteOffset = (userHash + dayOfYear * 7) % 60;

    final bool cookieDone = (await StorageService.getCookieCracksToday()) > 0;
    final bool tarotDone = await StorageService.isTarotDoneToday();
    final bool dreamDone = await StorageService.isDreamDoneToday();
    final int streakDays = await StorageService.getStreakDays();
    final int soulStones = await StorageService.getSoulStones();

    // Mesaj seçici: Herkes o gün AYNI mesajı almasın diye kullanıcının hash'i ile kaydırıyoruz.
    int getMsgIndex(int length) => (dayOfYear + userHash) % length;

    // ── SABAH (09:XX) — Günlük Karşılama (3 günde 1) ──
    if ((dayOfYear + userHash) % 3 == 0) {
      final morningMessages = [
        ['Günaydın $userName! ☀️', '$zodiac burcunun bugünkü kozmik mesajı hazır.'],
        ['Yeni bir gün, yeni bir şans ✨', '$userName, evren bugün senin için ne hazırladı?'],
        ['Kozmik enerji yüksek! 🌟', '$zodiac burcu bugün güçlü. Fırsatları kaçırma!'],
        ['Bugün senin günün $userName 🔮', 'Yıldızlar $zodiac burcuna gülümsüyor.'],
        ['Evren seninle konuşmak istiyor 🌌', '$userName, bugünkü kozmik rehberliğin hazır.'],
      ];
      final mo = morningMessages[getMsgIndex(morningMessages.length)];
      _scheduleLocalNotification(id: 1, title: mo[0], body: mo[1], hour: 9, minute: minuteOffset, channelId: 'morning_routine', channelName: 'Sabah Kahini');
    } else {
      await cancelNotification(1);
    }

    // ── KUŞLUK VAKTİ (11:XX) — Rüya Hatırlatıcı (4 günde 1) ──
    if (!dreamDone && (dayOfYear + userHash) % 4 == 0) {
      final dreamMessages = [
        ['Dün gece bir rüya gördün mü? 🌙', 'Bilinçaltının mesajını unutmadan kaydet!'],
        ['Rüyaların bir şey anlatıyor 💭', '$userName, bu sabah rüyanı yaz ve sırları keşfet!'],
        ['Evren sana ne mesaj verdi? 🌌', 'Dün gece gördüğün rüya, geleceğine dair ipuçları taşıyor.'],
      ];
      final dr = dreamMessages[getMsgIndex(dreamMessages.length)];
      _scheduleLocalNotification(id: 4, title: dr[0], body: dr[1], hour: 11, minute: minuteOffset, channelId: 'dream_reminder', channelName: 'Rüya Hatırlatıcı');
    } else {
      await cancelNotification(4);
    }

    // ── ÖĞLE (14:XX) — Kurabiye Molası (3 günde 1, boğmamak için) ──
    if (!cookieDone && (dayOfYear + userHash) % 3 == 1) {
      final cookieMessages = [
        ['Kurabiyeni unutma 🥠', '$zodiac şans kurabiyende gizli bir mesaj var!'],
        ['Şansını kır 🍪', 'Bugünkü $zodiac mesajını kurabiyende bul!'],
        ['Sana bir mesaj var 🥠', 'İçindeki sürprizi görmek için kurabiyeni kır.'],
      ];
      final co = cookieMessages[getMsgIndex(cookieMessages.length)];
      _scheduleLocalNotification(id: 2, title: co[0], body: co[1], hour: 14, minute: minuteOffset, channelId: 'cookie_reminder', channelName: 'Kurabiye Hatırlatıcı');
    } else {
      await cancelNotification(2);
    }

    // ── RUH TAŞI ZENGİNLİĞİ (16:XX) — (Çok Ruh Taşı varsa 4 günde 1 hatırlatır) ──
    if (soulStones >= 50 && (dayOfYear + userHash) % 4 == 0) {
      _scheduleLocalNotification(id: 9, title: 'Cebinde Ruh Taşları parlıyor! 💎', body: 'Biriken $soulStones Ruh Taşınla premium kurabiyeleri denemenin tam zamanı.', hour: 16, minute: minuteOffset, channelId: 'economy_reminder', channelName: 'Ekonomi Hatırlatıcı');
    } else {
      await cancelNotification(9);
    }

    // ── AKŞAM (19:XX) — Tarot (4 günde 1, rüyayla çakışmasın diye +2 kaydırmalı) ──
    if (!tarotDone && (dayOfYear + userHash) % 4 == 2) {
      final tarotMessages = [
        ['Akşam kartın hazır 🃏', 'Bugünün enerjisini okumak için $zodiac açılımını kaçırma!'],
        ['Kartlar fısıldıyor 🔮', 'Bugün için sana bir mesaj var. Tarot kartını çek!'],
        ['Akşam enerjisi güçlü 🌙', 'Günü kapatmadan evrenin sana ne söylediğine bak.'],
      ];
      final ta = tarotMessages[getMsgIndex(tarotMessages.length)];
      _scheduleLocalNotification(id: 3, title: ta[0], body: ta[1], hour: 19, minute: minuteOffset, channelId: 'tarot_reminder', channelName: 'Tarot Hatırlatıcı');
    } else {
      await cancelNotification(3);
    }

    // ── STREAK KORUMA (21:XX) — (En az 3 günlük serisi varsa ve kırmadıysa KESİN uyarır) ──
    if (streakDays >= 3 && !cookieDone) {
      _scheduleLocalNotification(id: 10, title: '🔥 Serin bozulmak üzere!', body: '$streakDays günlük serini kaybetme. Hemen girip bir kurabiye kır.', hour: 21, minute: 30, channelId: 'streak_reminder', channelName: 'Seri Hatırlatıcı');
    } else {
      await cancelNotification(10);
    }

    // ── KAHVE FALI HATIRLATICI (17:XX) — (5 günde 1) ──
    if ((dayOfYear + userHash) % 5 == 1) {
      final coffeeMessages = [
        ['Kahveler içildi mi? ☕', 'Fincanını kapat, telvelerdeki sırları senin için okuyayım.'],
        ['Gelecek telvelerde gizli ✨', '$userName, kahve keyfinden sonra falına bakmayı unutma!'],
        ['Telveler konuşmak istiyor ☕', 'Fincanında beliren semboller sana bir mesaj taşıyor olabilir.'],
      ];
      final cof = coffeeMessages[getMsgIndex(coffeeMessages.length)];
      _scheduleLocalNotification(id: 11, title: cof[0], body: cof[1], hour: 17, minute: minuteOffset, channelId: 'coffee_reminder', channelName: 'Kahve Falı Hatırlatıcı');
    } else {
      await cancelNotification(11);
    }

    // ── BURÇ SEZONU (10:00) — Sezon değişim günlerinde ──
    final rawZodiacSeason = _getZodiacSeasonToday();
    if (rawZodiacSeason != null) {
      final zodiacSeason = _translateZodiac(rawZodiacSeason);
      final isUserSeason = rawZodiacSeason.toLowerCase() == rawZodiac.toLowerCase() || zodiacSeason.toLowerCase() == zodiac.toLowerCase();
      
      _scheduleLocalNotification(
        id: 5,
        title: isUserSeason ? '♈ $zodiac sezonu başladı! 🎉' : '$zodiacSeason sezonu başladı! ✨',
        body: isUserSeason
            ? 'Güneş artık senin burcunda $userName. En şanslı dönemine girdin!'
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
            hour: 10, minute: 0,
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
