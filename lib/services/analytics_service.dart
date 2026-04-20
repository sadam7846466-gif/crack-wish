import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Firebase Analytics — Kullanıcı davranışlarını takip eder.
/// console.firebase.google.com → Analytics panelinden görüntülenir.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._();
  factory AnalyticsService() => _instance;
  AnalyticsService._();

  FirebaseAnalytics? _analytics;

  FirebaseAnalytics? get _safeAnalytics {
    try {
      _analytics ??= FirebaseAnalytics.instance;
      return _analytics;
    } catch (e) {
      debugPrint('⚠️ Firebase Analytics henüz hazır değil: $e');
      return null;
    }
  }

  /// Navigator observer — otomatik ekran takibi (hangi sayfayı açtı?)
  FirebaseAnalyticsObserver? get observer {
    final a = _safeAnalytics;
    if (a == null) return null;
    return FirebaseAnalyticsObserver(analytics: a);
  }

  // ══════════════════════════════════════════════
  // 🍪 KURABİYE
  // ══════════════════════════════════════════════
  
  /// Kurabiye kırıldığında
  Future<void> logCookieCracked({required String cookieId, required String rarity}) async {
    await _log('cookie_cracked', {
      'cookie_id': cookieId,
      'rarity': rarity,
    });
  }

  /// Premium kurabiye satın alındığında
  Future<void> logCookiePurchased({required String cookieId, required String price}) async {
    await _log('cookie_purchased', {
      'cookie_id': cookieId,
      'price': price,
    });
  }

  // ══════════════════════════════════════════════
  // 🃏 TAROT
  // ══════════════════════════════════════════════
  
  /// Tarot falı açıldığında
  Future<void> logTarotOpened({required int cardCount}) async {
    await _log('tarot_opened', {
      'card_count': cardCount,
    });
  }

  /// Tarot paylaşıldığında
  Future<void> logTarotShared() async {
    await _log('tarot_shared', {});
  }

  // ══════════════════════════════════════════════
  // 🌙 RÜYA
  // ══════════════════════════════════════════════
  
  /// Rüya yorumlandığında
  Future<void> logDreamAnalyzed({String? emotion}) async {
    await _log('dream_analyzed', {
      if (emotion != null) 'emotion': emotion,
    });
  }

  /// Rüya kaydedildiğinde
  Future<void> logDreamSaved() async {
    await _log('dream_saved', {});
  }

  // ══════════════════════════════════════════════
  // ⭐ BURÇ
  // ══════════════════════════════════════════════
  
  /// Burç okunduğunda
  Future<void> logZodiacViewed({required String sign}) async {
    await _log('zodiac_viewed', {
      'sign': sign,
    });
  }

  // ══════════════════════════════════════════════
  // 👑 ELİTE / SATIN ALMA
  // ══════════════════════════════════════════════
  
  /// Elite satın alındığında
  Future<void> logElitePurchased({required String plan}) async {
    await _log('elite_purchased', {
      'plan': plan, // weekly, monthly, yearly
    });
  }

  /// Paywall açıldığında
  Future<void> logPaywallViewed() async {
    await _log('paywall_viewed', {});
  }

  // ══════════════════════════════════════════════
  // 📺 REKLAM
  // ══════════════════════════════════════════════
  
  /// Reklam izlendiğinde
  Future<void> logAdWatched({required String source}) async {
    await _log('ad_watched', {
      'source': source, // cookie, tarot, dream
    });
  }

  // ══════════════════════════════════════════════
  // 📬 BAYKUŞ POSTASI
  // ══════════════════════════════════════════════
  
  /// Baykuş Postası gönderildiğinde
  Future<void> logOwlLetterSent() async {
    await _log('owl_letter_sent', {});
  }

  /// Arkadaş ekleme isteği gönderildiğinde
  Future<void> logFriendRequestSent() async {
    await _log('friend_request_sent', {});
  }

  // ══════════════════════════════════════════════
  // 🔥 SERİ (STREAK)
  // ══════════════════════════════════════════════
  
  /// Günlük seri uzadığında
  Future<void> logStreakDay({required int day}) async {
    await _log('streak_day', {
      'day': day,
    });
  }

  // ══════════════════════════════════════════════
  // 👤 PROFİL
  // ══════════════════════════════════════════════
  
  /// Profil oluşturulduğunda (onboarding tamamlandığında)
  Future<void> logProfileCreated() async {
    await _log('profile_created', {});
  }

  /// Avatar değiştirildiğinde
  Future<void> logAvatarChanged() async {
    await _log('avatar_changed', {});
  }

  // ══════════════════════════════════════════════
  // 📱 GENEL
  // ══════════════════════════════════════════════
  
  /// Uygulama açıldığında (her oturumda 1 kez)
  Future<void> logAppOpened() async {
    await _log('app_opened', {});
  }

  /// Paylaşım yapıldığında
  Future<void> logContentShared({required String type}) async {
    await _log('content_shared', {
      'type': type, // cookie, tarot, dream, zodiac
    });
  }

  /// Kullanıcı özelliği ayarla (segmentasyon için)
  Future<void> setUserProperty({required String name, required String value}) async {
    try {
      await _safeAnalytics?.setUserProperty(name: name, value: value);
    } catch (e) {
      debugPrint('Analytics user property hatası: $e');
    }
  }

  // ── İç yardımcı metod ──
  Future<void> _log(String name, Map<String, Object> params) async {
    try {
      await _safeAnalytics?.logEvent(name: name, parameters: params);
      debugPrint('📊 Analytics: $name $params');
    } catch (e) {
      debugPrint('Analytics log hatası: $e');
    }
  }
}
