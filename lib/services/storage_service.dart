import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'analytics_service.dart';
import 'push_notification_service.dart';
import 'profile_sync_service.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import '../models/cookie_card.dart';
import '../models/owl_letter.dart';

class StorageService {
  /// Güvenli getStringList — String olarak kaydedilmiş anahtarları da yönetir
  static List<String> _safeGetStringList(SharedPreferences prefs, String key) {
    try {
      return prefs.getStringList(key) ?? [];
    } catch (_) {
      // Anahtar String olarak kaydedilmişse (veri bozulması), temizle
      prefs.remove(key);
      return [];
    }
  }

  static const String _keyCookieCount = 'cookie_count';
  static const String _keyTotalCookies = 'total_cookies';
  static const String _keyTotalDreams = 'total_dreams';
  static const String _keyTotalTarots = 'total_tarots';
  static const String _keyTotalCoffee = 'total_coffee';
  static const String _keyLongestStreak = 'longest_streak';
  static const String _keyUserName = 'user_name';
  static const String _keyUserHandle = 'user_handle';
  static const String _keyZodiacSign = 'zodiac_sign';
  static const String _keyBirthDate = 'birth_date';
  static const String _keyCurrentMood = 'current_mood';
  static const String _keyStreakDays = 'streak_days';
  static const String _keySoulStones = 'soul_stones'; // Kazanılmış Ruh Taşı (kalıcı — Aura, ödüller, milestone)
  static const String _keyDailyEliteSoulStones = 'daily_elite_soul_stones'; // Günlük Elite Ruh Taşı (her gece 00:00'da 5'e sıfırlanır)
  static const String _keyDailyEliteSoulDate = 'daily_elite_soul_date'; // Son günlük Elite taş verilme tarihi
  static const String _keyLastCookieDate = 'last_cookie_date';
  static const String _keyMood = 'mood';
  static const String _keyDreams = 'dreams';
  static const String _keyDreamList = 'dream_list'; // json list (yeni yöntem)
  static const String _keyTarotDone = 'tarot_done';
  static const String _keyDreamDone = 'dream_done';
  static const String _keyZodiacDone = 'zodiac_done';
  static const String _keyTarotDoneDate = 'tarot_done_date';
  static const String _keyDreamDoneDate = 'dream_done_date';
  static const String _keyZodiacDoneDate = 'zodiac_done_date';
  static const String _keyCoffeeDoneDate = 'coffee_done_date';
  static const String _keyCoffeeDone = 'coffee_done';
  static const String _keyZodiacOverlayDx = 'zodiac_overlay_dx';
  static const String _keyZodiacOverlayDy = 'zodiac_overlay_dy';
  static const String _keyTarotOverlayDx = 'tarot_overlay_dx';
  static const String _keyTarotOverlayDy = 'tarot_overlay_dy';
  static const String _keyMotiveAstronautDx = 'motive_astronaut_dx';
  static const String _keyMotiveAstronautDy = 'motive_astronaut_dy';
  static const String _keyMotivePlanetDx = 'motive_planet_dx';
  static const String _keyMotivePlanetDy = 'motive_planet_dy';
  static const String _keyMotiveStarDx = 'motive_star_dx';
  static const String _keyMotiveStarDy = 'motive_star_dy';
  static const String _keySeenFortunes = 'seen_fortune_ids';
  static const String _keyCookieCollection = 'cookie_collection';
  static const String _keyPinnedCookies = 'pinned_cookies';
  static const String _keyLocale = 'app_locale';
  static const String _keySelectedCookie = 'selected_cookie';
  static const String _keyInstallId = 'install_id';
  static const String _keyCompletedCosmicTasks = 'completed_cosmic_tasks';
  static const String _keySpentAura = 'spent_aura'; // Ruh Taşı çeviriminde harcanan Aura
  static const String _keyAppOpenDays = 'app_open_days'; // Uygulamanın açıldığı günler (Set<String>)
  static const String _keyClaimedAuraDays = 'claimed_aura_days'; // Aura toplanan günler (Set<String>)

  // ── ONBOARDING / PROFILING KEYS ──
  static const String _keyBirthTime = 'birth_time';
  static const String _keyLifeFocus = 'life_focus';
  static const String _keyRelationship = 'relationship_status';
  static const String _keyDreamFrequency = 'dream_frequency';
  static const String _keyAuraColor = 'aura_color';
  static const String _keySleepPattern = 'sleep_pattern';
  static const String _keyMatchPreference = 'match_preference';
  static const String _keyBirthPlace = 'birth_place';
  static const String _keyPhoneNumber = 'phone_number';

  /// DEV METHOD: Sıfırla (BETA) - Günlük yenilemeyi tetiklemek için tüm tarih bazlı sınırları 'dün' olarak ayarlar
  static Future<void> resetDailies() async {
    final prefs = await SharedPreferences.getInstance();
    final yesterday = DateTime.now().subtract(const Duration(days: 1)).toIso8601String();
    
    await prefs.setString(_keyDailyEliteSoulDate, yesterday);
    await prefs.setString(_keyLastCookieDate, yesterday);
    await prefs.setString(_keyTarotDoneDate, yesterday);
    await prefs.setString(_keyDreamDoneDate, yesterday);
    await prefs.setString(_keyZodiacDoneDate, yesterday);
    await prefs.setString(_keyCoffeeDoneDate, yesterday);
    
    // Cookie, Tarot, Zodiac, Coffee vs. true kalmışsa false yapalım ki UI anında yenilensin
    await prefs.setBool(_keyTarotDone, false);
    await prefs.setBool(_keyDreamDone, false);
    await prefs.setBool(_keyZodiacDone, false);
    await prefs.setBool(_keyCoffeeDone, false);
    
    // Reset completed tasks for the day
    await prefs.remove(_keyCompletedCosmicTasks);
  }

  // ══════════════════════════════════════════════════════════════
  // PREMIUM EKONOMİ — İKİ HAVUZLU RUH TAŞI SİSTEMİ
  // ══════════════════════════════════════════════════════════════
  //
  // HAVUZ 1: Günlük Elite Ruh Taşları (daily_elite_soul_stones)
  //   - Elite kullanıcılara her gece 00:00'da TAM 5 adet verilir
  //   - Kullanılsa da kullanılmasa da her gece 5'e sıfırlanır
  //   - Ücretsiz kullanıcılar için = 0
  //
  // HAVUZ 2: Kazanılmış Ruh Taşları (soul_stones)
  //   - Aura dönüşümünden, milestone ödüllerinden, hoşgeldin hediyesinden gelen
  //   - ASLA sıfırlanmaz, kalıcıdır
  //
  // Kullanırken: Önce günlük havuzdan düşer, günlük biterse kazanılmıştan düşer
  // UI'da: Toplam (günlük + kazanılmış) gösterilir
  // ══════════════════════════════════════════════════════════════

  static final ValueNotifier<int> soulStonesNotifier = ValueNotifier<int>(0);

  /// Elite kullanıcının günlük 5 taşını yenile (gün değiştiyse)
  static Future<void> refreshDailyEliteSoulStones() async {
    final prefs = await SharedPreferences.getInstance();
    final isPremium = prefs.getBool('is_elite') ?? false;
    if (!isPremium) {
      // Ücretsiz kullanıcı: günlük taş = 0
      await prefs.setInt(_keyDailyEliteSoulStones, 0);
      return;
    }
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastDate = prefs.getString(_keyDailyEliteSoulDate) ?? '';
    if (lastDate != today) {
      // Yeni gün VEYA ilk kez Elite olmuş (lastDate boş)
      await prefs.setInt(_keyDailyEliteSoulStones, 5);
      await prefs.setString(_keyDailyEliteSoulDate, today);
    }
  }

  /// Toplam Ruh Taşı = günlük Elite + kazanılmış (UI göstergesi için)
  static Future<int> getSoulStones() async {
    final prefs = await SharedPreferences.getInstance();
    // İlk kez ise hoşgeldin hediyesi
    if (!prefs.containsKey(_keySoulStones)) {
      await prefs.setInt(_keySoulStones, 3);
    }
    // Günlük Elite taşlarını yenile (gün değiştiyse)
    await refreshDailyEliteSoulStones();
    final earned = prefs.getInt(_keySoulStones) ?? 0;
    final daily = prefs.getInt(_keyDailyEliteSoulStones) ?? 0;
    final total = earned + daily;
    soulStonesNotifier.value = total;
    return total;
  }

  /// Kazanılmış (kalıcı) taşlara ekleme yap (Aura dönüşümü, ödüller vs.)
  static Future<void> updateSoulStones(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keySoulStones) ?? 0;
    final newValue = (current + amount).clamp(0, 9999);
    await prefs.setInt(_keySoulStones, newValue);
    // Toplam = yeni kazanılmış + mevcut günlük
    final daily = prefs.getInt(_keyDailyEliteSoulStones) ?? 0;
    soulStonesNotifier.value = newValue + daily;
    
    // Değişikliği Buluta Yedekle
    await syncEconomyToCloud();
  }

  // ═══════════════════════════════════════════════════════════════
  // CLOUD ECONOMY SYNC
  // ═══════════════════════════════════════════════════════════════

  /// Mevcut Aura ve Ruh Taşı değerlerini alıp Supabase'e yedekler
  static Future<void> syncEconomyToCloud() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final aura = prefs.getInt('daily_bonus_aura') ?? 0;
      final stones = prefs.getInt(_keySoulStones) ?? 0;
      
      final totalCookies = prefs.getInt('total_cookies') ?? 0;
      final totalTarots = prefs.getInt('total_tarots') ?? 0; // Düzeltildi
      final totalDreams = prefs.getInt('total_dreams') ?? 0; // Düzeltildi
      final totalCoffee = prefs.getInt('total_coffee') ?? 0; 
      final streakDays = prefs.getInt('streak_days') ?? 0;
      
      final totalFriends = prefs.getInt('total_friends_count') ?? 0;
      final totalLetters = prefs.getInt('total_letters_sent') ?? 0;
      final totalReferrals = prefs.getInt('total_referrals_count') ?? 0;
      final cookiesData = await getCookieCollection();
      final uniqueCookies = cookiesData.where((c) => c.firstObtainedDate != null || c.countObtained > 0).length;
      final unlockedAchievements = _safeGetStringList(prefs, 'achievements_claimed');

      await ProfileSyncService().syncEconomyData(
        aura: aura, 
        soulStones: stones,
        totalCookies: totalCookies,
        totalTarots: totalTarots,
        totalDreams: totalDreams,
        totalCoffee: totalCoffee,
        streakDays: streakDays,
        totalFriends: totalFriends,
        totalLetters: totalLetters,
        totalReferrals: totalReferrals,
        uniqueCookies: uniqueCookies,
        unlockedAchievements: unlockedAchievements,
      );
    } catch (e) {
      debugPrint('🚨 syncEconomyToCloud Hatası: $e');
    }
  }

  /// Buluttan (Supabase) mevcut değerleri indirip cihaz hafızasına yazar
  static Future<void> fetchEconomyFromCloud() async {
    final data = await ProfileSyncService().fetchEconomyData();
    if (data != null) {
      final prefs = await SharedPreferences.getInstance();
      
      final cloudAura = data['aura']!;
      final cloudStones = data['stones']!;
      final localAura = prefs.getInt('daily_bonus_aura') ?? 0;
      final localStones = prefs.getInt(_keySoulStones) ?? 0;
      
      // Eğer bulut 0 ise ve cihazda puan varsa, SIFIRLAMAK YERİNE bulutu GÜNCELLE (Eski kullanıcılar için)
      if (cloudAura == 0 && cloudStones == 0 && (localAura > 0 || localStones > 0)) {
        debugPrint('☁️ Bulut boş ama cihaz dolu. Bulut güncelleniyor...');
        await syncEconomyToCloud();
        return;
      }
      
      // Cihazı bulutla eşitle
      await prefs.setInt('daily_bonus_aura', cloudAura);
      await prefs.setInt(_keySoulStones, cloudStones);
      
      // UI için notifier'ı güncelle
      final daily = prefs.getInt(_keyDailyEliteSoulStones) ?? 0;
      soulStonesNotifier.value = cloudStones + daily;
      
      debugPrint('📥 Ekonomi başarıyla buluttan indirildi: $cloudAura Aura, $cloudStones Taş');
    }
  }

  /// Ruh Taşı harca: Önce günlükten, sonra kazanılmıştan düşer
  static Future<bool> deductSoulStones(int amount) async {
    if (amount <= 0) return false;
    final prefs = await SharedPreferences.getInstance();
    // Günlük Elite taşlarını yenile (gün değiştiyse)
    await refreshDailyEliteSoulStones();
    final daily = prefs.getInt(_keyDailyEliteSoulStones) ?? 0;
    final earned = prefs.getInt(_keySoulStones) ?? 0;
    final total = daily + earned;
    if (total < amount) return false; // Yetersiz bakiye

    int remaining = amount;

    // 1) Önce günlük havuzdan düş
    if (daily > 0) {
      final deductFromDaily = remaining.clamp(0, daily);
      await prefs.setInt(_keyDailyEliteSoulStones, daily - deductFromDaily);
      remaining -= deductFromDaily;
    }

    // 2) Kalan varsa kazanılmış havuzdan düş
    if (remaining > 0) {
      await prefs.setInt(_keySoulStones, earned - remaining);
    }

    // Notifier güncelle
    final newTotal = (total - amount);
    soulStonesNotifier.value = newTotal;
    
    await syncEconomyToCloud();
    return true;
  }

  // ── AURA HARCAMA (Ruh Taşı Çevirimi) ──
  static Future<int> getSpentAura() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keySpentAura) ?? 0;
  }

  /// Aura harcayarak Ruh Taşı üret. Başarılıysa true döner.
  static Future<bool> convertAuraToSoulStone({required int currentTotalAura, int cost = 100}) async {
    final prefs = await SharedPreferences.getInstance();
    final spent = prefs.getInt(_keySpentAura) ?? 0;
    final available = currentTotalAura - spent;
    if (available < cost) return false; // Yeterli Aura yok
    await prefs.setInt(_keySpentAura, spent + cost);
    await updateSoulStones(1); // +1 Ruh Taşı
    return true;
  }

  // ── Cihaza özel benzersiz ID (ilk kurulumda oluşturulur) ──
  static Future<int> getInstallId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getInt(_keyInstallId);
    if (id == null) {
      id = Random().nextInt(999999999);
      await prefs.setInt(_keyInstallId, id);
    }
    return id;
  }

  static const String _keyInstallDate = 'install_date';

  static Future<DateTime> getInstallDate() async {
    final prefs = await SharedPreferences.getInstance();
    var dateString = prefs.getString(_keyInstallDate);
    if (dateString == null) {
      final now = DateTime.now();
      final streak = prefs.getInt(_keyLongestStreak) ?? 0;
      final currentStreak = prefs.getInt(_keyStreakDays) ?? 0;
      final maxDays = currentStreak > streak ? currentStreak : streak;
      
      // Tahmini en eski gün
      final installDate = now.subtract(Duration(days: maxDays));
      await prefs.setString(_keyInstallDate, installDate.toIso8601String());
      return installDate;
    }
    return DateTime.parse(dateString);
  }

  // ── Seçili kurabiye (kalıcı) ──
  static Future<String> getSelectedCookie() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedCookie) ?? 'spring_wreath';
  }

  static Future<void> setSelectedCookie(String cookieId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedCookie, cookieId);
  }

  static Future<Locale?> getAppLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_keyLocale);
    if (code == null || code.isEmpty) return null;
    return Locale(code);
  }

  static Future<void> setAppLocale(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_keyLocale);
      return;
    }
    await prefs.setString(_keyLocale, locale.languageCode);
  }

  // --- Aggregate user stats (persistent) ---
  static Future<int> getTotalCookies() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTotalCookies) ?? prefs.getInt(_keyCookieCount) ?? 0;
  }

  static Future<void> incrementTotalCookies() async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getTotalCookies();
    await prefs.setInt(_keyTotalCookies, current + 1);
    await incrementCookieCount(); // mevcut sayaç ve seriyle uyum için
  }

  static Future<int> getTotalDreams() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTotalDreams) ?? 0;
  }

  static Future<void> incrementTotalDreams() async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getTotalDreams();
    await prefs.setInt(_keyTotalDreams, current + 1);
    
    await setDreamDoneToday(); // Mark dream task as done for daily tip

    // YENİ SİSTEM: Bekleyen Aura havuzuna (+3) ekliyoruz
    final isPremium = prefs.getBool('is_elite') ?? false;
    await addPendingAura('ruya', 3 * (isPremium ? 3 : 1));
    // 📊 Analytics
    AnalyticsService().logDreamAnalyzed();
  }

  static Future<int> getTotalTarots() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTotalTarots) ?? 0;
  }

  static Future<void> incrementTotalTarots() async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getTotalTarots();
    await prefs.setInt(_keyTotalTarots, current + 1);
    await setTarotDoneToday(); // Mark tarot task as done for daily tip
  }

  static Future<int> getTotalCoffee() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTotalCoffee) ?? 0;
  }

  static Future<void> incrementTotalCoffee() async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getTotalCoffee();
    await prefs.setInt(_keyTotalCoffee, current + 1);
    
    await setCoffeeDoneToday(); // Mark coffee task as done for daily tip

    // YENİ SİSTEM: Bekleyen Aura havuzuna (+3) ekliyoruz
    final isPremium = prefs.getBool('is_elite') ?? false;
    await addPendingAura('kahve', 3 * (isPremium ? 3 : 1));
    // 📊 Analytics
    AnalyticsService().logCoffeeAnalyzed();
  }

  static Future<int> getLongestStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyLongestStreak) ?? 0;
  }

  static Future<void> setLongestStreak(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLongestStreak, value);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  static Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name);
  }

  static Future<String?> getUserHandle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserHandle);
  }

  static Future<void> setUserHandle(String handle) async {
    final prefs = await SharedPreferences.getInstance();
    // Başında @ yoksa ekle
    if (!handle.startsWith('@') && handle.isNotEmpty) {
      handle = '@$handle';
    }
    await prefs.setString(_keyUserHandle, handle.toLowerCase());
  }

  static Future<String?> getAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_avatar');
  }

  static Future<void> setAvatar(String avatarPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_avatar', avatarPath);
  }

  static Future<String?> getZodiacSign() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyZodiacSign);
  }

  static Future<void> setZodiacSign(String sign) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyZodiacSign, sign);
  }

  static Future<DateTime?> getBirthDate() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keyBirthDate);
    if (str == null) return null;
    return DateTime.tryParse(str);
  }

  static Future<void> setBirthDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBirthDate, date.toIso8601String());
  }

  // ── YENİ ONBOARDING PROFİL BİLGİLERİ ──

  static Future<String?> getBirthTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBirthTime);
  }
  static Future<void> setBirthTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBirthTime, time);
  }

  static Future<String?> getLifeFocus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLifeFocus);
  }
  static Future<void> setLifeFocus(String focus) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLifeFocus, focus);
  }

  static Future<String?> getRelationshipStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRelationship);
  }
  static Future<void> setRelationshipStatus(String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRelationship, status);
  }

  static Future<String?> getDreamFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDreamFrequency);
  }
  static Future<void> setDreamFrequency(String freq) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDreamFrequency, freq);
  }

  static Future<int?> getAuraColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyAuraColor);
  }
  static Future<void> setAuraColor(int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAuraColor, colorValue);
  }

  static Future<String?> getSleepPattern() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySleepPattern);
  }
  static Future<void> setSleepPattern(String pattern) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySleepPattern, pattern);
  }

  static Future<bool?> getMatchPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyMatchPreference);
  }
  static Future<void> setMatchPreference(bool isOpen) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMatchPreference, isOpen);
  }

  static Future<String?> getBirthPlace() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBirthPlace);
  }
  static Future<void> setBirthPlace(String place) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBirthPlace, place);
  }

  static Future<String?> getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPhoneNumber);
  }
  static Future<void> setPhoneNumber(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPhoneNumber, phone);
  }

  static String _todayKey() =>
      DateTime.now().toIso8601String().split('T')[0];

  static Future<bool> isTarotDoneToday() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyTarotDoneDate) == _todayKey();
  }

  static Future<bool> isDreamDoneToday() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDreamDoneDate) == _todayKey();
  }

  static Future<bool> isZodiacDoneToday() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyZodiacDoneDate) == _todayKey();
  }

  static Future<bool> isCoffeeDoneToday() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCoffeeDoneDate) == _todayKey();
  }

  static final ValueNotifier<int> dailyTasksUpdated = ValueNotifier<int>(0);

  static Future<void> setTarotDoneToday() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTarotDoneDate, _todayKey());
    await prefs.setBool(_keyTarotDone, true);
    dailyTasksUpdated.value++;
    // Akıllı bildirim: Tarot yapıldı → hatırlatma iptal
    PushNotificationService().refreshSmartNotifications();
  }

  static Future<void> setDreamDoneToday() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDreamDoneDate, _todayKey());
    await prefs.setBool(_keyDreamDone, true);
    dailyTasksUpdated.value++;
    // Akıllı bildirim: Rüya yazıldı → hatırlatma iptal
    PushNotificationService().refreshSmartNotifications();
  }

  static Future<void> setZodiacDoneToday() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyZodiacDoneDate, _todayKey());
    await prefs.setBool(_keyZodiacDone, true);
    dailyTasksUpdated.value++;
  }

  static Future<void> setCoffeeDoneToday() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCoffeeDoneDate, _todayKey());
    await prefs.setBool(_keyCoffeeDone, true);
    dailyTasksUpdated.value++;
  }

  static Future<String?> getCurrentMood() async {
    final prefs = await SharedPreferences.getInstance();
    // eski key ile uyumluluk
    return prefs.getString(_keyCurrentMood) ?? prefs.getString(_keyMood);
  }

  static Future<void> setCurrentMood(String mood) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrentMood, mood);
    // eski mood ile hizalı kalsın
    await prefs.setString(_keyMood, mood);
  }

  /// Tüm özet stateleri tek seferde oku
  static Future<Map<String, dynamic>> getUserSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'totalCookies':
          prefs.getInt(_keyTotalCookies) ?? prefs.getInt(_keyCookieCount) ?? 0,
      'totalDreams': prefs.getInt(_keyTotalDreams) ?? 0,
      'totalTarots': prefs.getInt(_keyTotalTarots) ?? 0,
      'totalCoffee': prefs.getInt(_keyTotalCoffee) ?? 0,
      'longestStreak': prefs.getInt(_keyLongestStreak) ?? 0,
      'soulStones': prefs.getInt(_keySoulStones) ?? 3, // Eğer boşsa default hediye miktarını alıyoruz gibi düşün ama getSoulStones handle ediyor, buraya direkt yansıtalım.
      'userName': prefs.getString(_keyUserName),
      'userHandle': prefs.getString(_keyUserHandle),
      'zodiacSign': prefs.getString(_keyZodiacSign),
      'currentMood':
          prefs.getString(_keyCurrentMood) ?? prefs.getString(_keyMood),
    };
  }

  static Future<int> getCookieCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCookieCount) ?? 0;
  }

  static Future<void> incrementCookieCount() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyCookieCount) ?? 0;
    await prefs.setInt(_keyCookieCount, current + 1);
    await _updateStreak();
    
    // YENİ SİSTEM: Bekleyen Aura havuzuna (+1) ekliyoruz
    final isPremium = prefs.getBool('is_elite') ?? false;
    await addPendingAura('kurabiye', 1 * (isPremium ? 3 : 1));
  }

  // ── GÜNLÜK KURABİYE HAKKI SİSTEMİ ──
  // Free: 3 hak/gün (1 ücretsiz + 2 reklam izleyerek)
  // Premium: 3 hak/gün (reklamsız)
  static const int kMaxDailyCookieCracks = 3;
  static const String _keyCookieCracksToday = 'cookie_cracks_today';
  static const String _keyCookieCracksDate = 'cookie_cracks_date';

  /// Bugün kaç kurabiye kırıldı
  static Future<int> getCookieCracksToday() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString(_keyCookieCracksDate) ?? '';
    final today = _todayKey();
    if (savedDate != today) {
      // Yeni gün: sıfırla
      await prefs.setInt(_keyCookieCracksToday, 0);
      await prefs.setString(_keyCookieCracksDate, today);
      return 0;
    }
    return prefs.getInt(_keyCookieCracksToday) ?? 0;
  }

  /// Kalan kurabiye hakkı
  static Future<int> getRemainingCookieCracks() async {
    final used = await getCookieCracksToday();
    return (kMaxDailyCookieCracks - used).clamp(0, kMaxDailyCookieCracks);
  }

  /// Kurabiye kırılabilir mi? (hak var mı)
  static Future<bool> canCrackCookie() async {
    final used = await getCookieCracksToday();
    return used < kMaxDailyCookieCracks;
  }

  /// İlk hak ücretsiz mi? (0 kırılmışsa evet)
  static Future<bool> isNextCrackFree() async {
    final used = await getCookieCracksToday();
    return used == 0;
  }

  /// Reklam gerekli mi? (2. ve 3. hak için)
  static Future<bool> doesNextCrackRequireAd() async {
    final used = await getCookieCracksToday();
    return used >= 1 && used < kMaxDailyCookieCracks;
  }

  /// Kurabiye kırıldığını kaydet
  static Future<void> recordCookieCrack() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final savedDate = prefs.getString(_keyCookieCracksDate) ?? '';
    int current;
    if (savedDate != today) {
      current = 0;
      await prefs.setString(_keyCookieCracksDate, today);
    } else {
      current = prefs.getInt(_keyCookieCracksToday) ?? 0;
    }
    await prefs.setInt(_keyCookieCracksToday, current + 1);
    // 📊 Analytics
    AnalyticsService().logCookieCracked(cookieId: 'daily', rarity: 'unknown');
    // Akıllı bildirim: Kurabiye kırıldı → hatırlatma iptal
    PushNotificationService().refreshSmartNotifications();
  }

  // ── GÜNLÜK BAYKUŞ MEKTUBU HAKKI SİSTEMİ ──
  // Free: 5 hak/gün (1 ücretsiz + 4 reklam izleyerek)
  // Premium: 5 hak/gün (reklamsız)
  static const int kMaxDailyLetters = 5;
  static const String _keyLettersSentToday = 'letters_sent_today';
  static const String _keyLettersSentDate = 'letters_sent_date';

  /// Bugün kaç mektup gönderildi
  static Future<int> getLettersSentToday() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString(_keyLettersSentDate) ?? '';
    final today = _todayKey();
    if (savedDate != today) {
      await prefs.setInt(_keyLettersSentToday, 0);
      await prefs.setString(_keyLettersSentDate, today);
      return 0;
    }
    return prefs.getInt(_keyLettersSentToday) ?? 0;
  }

  /// Mektup gönderildiğini kaydet
  static Future<void> recordLetterSent() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final savedDate = prefs.getString(_keyLettersSentDate) ?? '';
    int current;
    if (savedDate != today) {
      current = 0;
      await prefs.setString(_keyLettersSentDate, today);
    } else {
      current = prefs.getInt(_keyLettersSentToday) ?? 0;
    }
    await prefs.setInt(_keyLettersSentToday, current + 1);
  }

  static Future<int> getStreakDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyStreakDays) ?? 0;
  }

  static Future<void> _updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString(_keyLastCookieDate);
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (lastDate == today) {
      return; // Bugün zaten yapılmış
    }

    final yesterday = DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .split('T')[0];
    final currentStreak = prefs.getInt(_keyStreakDays) ?? 0;

    if (lastDate == yesterday) {
      // Seri devam ediyor
      final newStreak = currentStreak + 1;
      await prefs.setInt(_keyStreakDays, newStreak);
      AnalyticsService().logStreakDay(day: newStreak);
    } else if (lastDate == null || lastDate != today) {
      // Yeni seri başlıyor
      await prefs.setInt(_keyStreakDays, 1);
      AnalyticsService().logStreakDay(day: 1);
    }

    await prefs.setString(_keyLastCookieDate, today);
  }

  // ═══════════════════════════════════════════════════════════════
  // GÜNLÜK GİRİŞ TAKİBİ (App Open Days + Aura Claim)
  // ═══════════════════════════════════════════════════════════════

  /// Bugünü "uygulama açıldı" olarak kaydet
  static Future<void> recordAppOpenToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final days = prefs.getStringList(_keyAppOpenDays) ?? [];
    if (!days.contains(today)) {
      days.add(today);
      await prefs.setStringList(_keyAppOpenDays, days);
    }
    // Streak'i de güncelle
    await _updateStreak();
  }

  /// Uygulamanın açıldığı tüm günleri döndür
  static Future<Set<String>> getAppOpenDays() async {
    final prefs = await SharedPreferences.getInstance();
    final days = prefs.getStringList(_keyAppOpenDays) ?? [];
    return days.toSet();
  }

  /// Belirli bir gün için Aura topla (takvimden tıklama)
  /// Hafta sonu +2, hafta içi +1
  /// Başarılıysa true döner, zaten toplanmışsa false
  static Future<bool> claimDailyAura(String dateKey) async {
    final prefs = await SharedPreferences.getInstance();
    final claimed = prefs.getStringList(_keyClaimedAuraDays) ?? [];
    if (claimed.contains(dateKey)) return false; // Zaten toplandı

    // Her gün için her zaman 4 Aura
    int auraAmount = 4;

    final bonusAura = prefs.getInt('daily_bonus_aura') ?? 0;
    await prefs.setInt('daily_bonus_aura', bonusAura + auraAmount);

    // Günü claimed olarak işaretle
    claimed.add(dateKey);
    await prefs.setStringList(_keyClaimedAuraDays, claimed);
    
    await syncEconomyToCloud();
    return true;
  }

  /// Toplanan bonus aura miktarını döndür
  static Future<int> getDailyBonusAura() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('daily_bonus_aura') ?? 0;
  }

  /// Ekstra Aura vermek için genel yardımcı metod (Premium bonusları vb.)
  static Future<void> addBonusAura(int amount) async {
    if (amount <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('daily_bonus_aura') ?? 0;
    await prefs.setInt('daily_bonus_aura', current + amount);
    await syncEconomyToCloud();
  }

  // ── PENDING AURA (Bekleyen/Toplanmayı Bekleyen Aura) ──
  static Future<void> addPendingAura(String sourceKey, int amount) async {
    if (amount <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('pending_aura_$sourceKey') ?? 0;
    await prefs.setInt('pending_aura_$sourceKey', current + amount);
  }

  static Future<int> getPendingAura(String sourceKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('pending_aura_$sourceKey') ?? 0;
  }

  static Future<void> clearPendingAura(String sourceKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pending_aura_$sourceKey');
  }

  // ── AURA KAYNAK TOPLAMA (Source Claim) ──
  static const String _keyClaimedAuraSources = 'claimed_aura_sources';
  static const String _keyClaimedAuraSourcesDate = 'claimed_aura_sources_date';

  /// Bugün toplanan aura kaynaklarını döndür (günlük sıfırlanır)
  static Future<Set<String>> getClaimedAuraSources() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString(_keyClaimedAuraSourcesDate) ?? '';
    final today = _todayKey();
    if (savedDate != today) {
      // Yeni gün: kayıtları sıfırla
      await prefs.setStringList(_keyClaimedAuraSources, []);
      await prefs.setString(_keyClaimedAuraSourcesDate, today);
      return {};
    }
    final list = prefs.getStringList(_keyClaimedAuraSources) ?? [];
    return list.toSet();
  }

  /// Bir aura kaynağını toplandı olarak işaretle
  static Future<void> claimAuraSource(String sourceKey, int auraAmount) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    // Gün kontrolü
    final savedDate = prefs.getString(_keyClaimedAuraSourcesDate) ?? '';
    List<String> list;
    if (savedDate != today) {
      list = [];
      await prefs.setString(_keyClaimedAuraSourcesDate, today);
    } else {
      list = prefs.getStringList(_keyClaimedAuraSources) ?? [];
    }
    if (list.contains(sourceKey)) return; // Zaten toplandı
    list.add(sourceKey);
    await prefs.setStringList(_keyClaimedAuraSources, list);
    // Bonus aura'yı da kaydet
    await addBonusAura(auraAmount);
  }

  /// Bugün toplanan toplam kaynak bonus'unu hesapla
  static Future<int> getTodaySourceBonus() async {
    // Bu değer addBonusAura ile zaten kaydediliyor,
    // günlük kaynak toplamını ayrı takip etmek istemiyoruz
    // claimedSources set'i yeterli
    return 0; // Placeholder - asıl bonus daily_bonus_aura'da
  }

  // ═══════════════════════════════════════════════════════════════
  // HEDEF / MILESTONE SİSTEMİ
  // ═══════════════════════════════════════════════════════════════

  /// Hangi hedeflerin (gün sayılarının) ödülünün toplandığını döndürür (ör: [7, 14])
  static Future<List<int>> getClaimedMilestones() async {
    final prefs = await SharedPreferences.getInstance();
    final strings = prefs.getStringList('claimed_milestones') ?? [];
    return strings.map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toList();
  }

  /// Belirtilen hedef için ödülü topla ve 'toplandı' olarak işaretle
  static Future<bool> claimMilestone(int threshold) async {
    final prefs = await SharedPreferences.getInstance();
    final strings = prefs.getStringList('claimed_milestones') ?? [];
    if (strings.contains(threshold.toString())) return false; // Zaten toplanmış

    // Ödülü ver
    if (threshold == 7) {
      await prefs.setInt('daily_bonus_aura', (prefs.getInt('daily_bonus_aura') ?? 0) + 15);
    } else if (threshold == 14) {
      await prefs.setInt('daily_bonus_aura', (prefs.getInt('daily_bonus_aura') ?? 0) + 30);
    } else if (threshold == 30) {
      final soulstones = await getSoulStones();
      await prefs.setInt(_keySoulStones, soulstones + 1);
    } else if (threshold == 50) {
      final soulstones = await getSoulStones();
      await prefs.setInt(_keySoulStones, soulstones + 2);
    } else if (threshold == 100) {
      final soulstones = await getSoulStones();
      await prefs.setInt(_keySoulStones, soulstones + 3);
    } else if (threshold == 365) {
      final soulstones = await getSoulStones();
      await prefs.setInt(_keySoulStones, soulstones + 5);
    }

    strings.add(threshold.toString());
    await prefs.setStringList('claimed_milestones', strings);
    return true;
  }

  /// Aura toplanan günleri döndür
  static Future<Set<String>> getClaimedAuraDays() async {
    final prefs = await SharedPreferences.getInstance();
    final claimed = prefs.getStringList(_keyClaimedAuraDays) ?? [];
    return claimed.toSet();
  }

  // ═══════════════════════════════════════════════════════════════
  // BAŞARIM (ACHIEVEMENT) SİSTEMİ
  // ═══════════════════════════════════════════════════════════════

  /// Tüm başarım tanımları
  static const List<Map<String, dynamic>> achievementDefinitions = [
    {'id': 'first_cookie', 'title': 'İlk Adım', 'desc': 'İlk kurabiyeni kırdın', 'icon': '🥚', 'iconData': Icons.cookie_rounded, 'imagePath': 'assets/icons/splash_cookie.png', 'color': Color(0xFFFDE047), 'aura': 5, 'stones': 0, 'checkKey': 'total_cookies', 'threshold': 1},
    {'id': 'first_tarot', 'title': 'Falcı Çırağı', 'desc': 'İlk tarot falına baktın', 'icon': '🔮', 'iconData': Icons.auto_awesome_rounded, 'color': Color(0xFFC084FC), 'aura': 5, 'stones': 0, 'checkKey': 'total_tarots', 'threshold': 1},
    {'id': 'first_dream', 'title': 'Rüya Avcısı', 'desc': 'İlk rüya analizini yaptın', 'icon': '💭', 'iconData': Icons.nights_stay_rounded, 'color': Color(0xFF60A5FA), 'aura': 5, 'stones': 0, 'checkKey': 'total_dreams', 'threshold': 1},
    {'id': 'first_friend', 'title': 'Sosyal Kelebek', 'desc': 'İlk arkadaşını ekledin', 'icon': '💌', 'iconData': Icons.people_alt_rounded, 'color': Color(0xFFF472B6), 'aura': 10, 'stones': 0, 'checkKey': 'total_friends', 'threshold': 1},
    {'id': 'cookie_master', 'title': 'Kurabiye Ustası', 'desc': '50 kurabiye kırdın', 'icon': '🍪', 'iconData': Icons.cookie_rounded, 'imagePath': 'assets/icons/splash_cookie.png', 'color': Color(0xFFFBBF24), 'aura': 0, 'stones': 1, 'checkKey': 'total_cookies', 'threshold': 50},
    {'id': 'wise_fortune', 'title': 'Bilge Kahin', 'desc': '30 tarot falı baktın', 'icon': '🔮', 'iconData': Icons.remove_red_eye_rounded, 'color': Color(0xFFA855F7), 'aura': 0, 'stones': 1, 'checkKey': 'total_tarots', 'threshold': 30},
    {'id': 'dream_collector', 'title': 'Rüya Koleksiyoncusu', 'desc': '20 rüya analizi yaptın', 'icon': '💭', 'iconData': Icons.bedtime_rounded, 'color': Color(0xFF3B82F6), 'aura': 0, 'stones': 1, 'checkKey': 'total_dreams', 'threshold': 20},
    {'id': 'letter_addict', 'title': 'Mektup Bağımlısı', 'desc': '10 mektup gönderdin', 'icon': '🦉', 'iconData': Icons.mail_rounded, 'color': Color(0xFF34D399), 'aura': 0, 'stones': 1, 'checkKey': 'total_letters_sent', 'threshold': 10},
    {'id': 'community_leader', 'title': 'Topluluk Lideri', 'desc': '5 arkadaş davet ettin', 'icon': '👥', 'iconData': Icons.groups_rounded, 'color': Color(0xFFFB923C), 'aura': 0, 'stones': 2, 'checkKey': 'total_referrals', 'threshold': 5},
    {'id': 'cosmic_collector', 'title': 'Kozmik Koleksiyoncu', 'desc': '10 farklı kurabiye topladın', 'icon': '⭐', 'iconData': Icons.stars_rounded, 'imagePath': 'assets/icons/splash_cookie.png', 'color': Color(0xFFFFD700), 'aura': 0, 'stones': 1, 'checkKey': 'unique_cookies', 'threshold': 10},
  ];

  /// Kazanılmış başarımları döndür
  static Future<Set<String>> getClaimedAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList('claimed_achievements') ?? []).toSet();
  }

  /// Başarım kontrolü yap ve yeni kazanılan varsa döndür
  static Future<List<Map<String, dynamic>>> checkAndClaimAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final claimed = _safeGetStringList(prefs, 'claimed_achievements').toSet();
    final newlyUnlocked = <Map<String, dynamic>>[];

    // Kullanıcı verilerini topla
    final stats = <String, int>{
      'total_cookies': prefs.getInt('total_cookies') ?? 0,
      'total_tarots': prefs.getInt('total_tarots') ?? 0,
      'total_dreams': prefs.getInt('total_dreams') ?? 0,
      'total_friends': prefs.getInt('total_friends_count') ?? 0,
      'total_letters_sent': prefs.getInt('total_letters_sent') ?? 0,
      'total_referrals': prefs.getInt('total_referrals_count') ?? 0,
    };
    
    final cookiesData = await getCookieCollection();
    stats['unique_cookies'] = cookiesData.where((c) => c.firstObtainedDate != null || c.countObtained > 0).length;

    for (final achievement in achievementDefinitions) {
      final id = achievement['id'] as String;
      if (claimed.contains(id)) continue; // Zaten kazanılmış

      final checkKey = achievement['checkKey'] as String;
      final threshold = achievement['threshold'] as int;
      final currentValue = stats[checkKey] ?? 0;

      if (currentValue >= threshold) {
        // Ödülü ver
        final aura = achievement['aura'] as int;
        final stones = achievement['stones'] as int;
        if (aura > 0) {
          await addBonusAura(aura);
        }
        if (stones > 0) {
          final currentStones = await getSoulStones();
          await prefs.setInt(_keySoulStones, currentStones + stones);
        }

        // Kazanıldı olarak işaretle
        claimed.add(id);
        newlyUnlocked.add(achievement);
      }
    }

    await prefs.setStringList('claimed_achievements', claimed.toList());
    return newlyUnlocked;
  }

  /// Belirli bir istatistiğin sayacını artır (achievement tetiklemesi için)
  static Future<void> incrementStat(String key, [int amount = 1]) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + amount);
  }

  // ═══════════════════════════════════════════════════════════════
  // UNVAN SİSTEMİ (Aura'ya Göre Otomatik)
  // ═══════════════════════════════════════════════════════════════

  /// Aura puanına göre kullanıcının unvanını döndür
  static String getUserTitle(int totalAura) {
    if (totalAura >= 1001) return 'Kozmik Kahin';
    if (totalAura >= 601) return 'Usta Kahin';
    if (totalAura >= 301) return 'Bilge Kahin';
    if (totalAura >= 151) return 'Kahin';
    if (totalAura >= 51) return 'Çırak Kahin';
    return 'Acemi Kahin';
  }

  /// Yeni bir unvan kazanılıp kazanılmadığını kontrol eder ve varsa döndürür
  static Future<Map<String, dynamic>?> checkAndClaimRankUp() async {
    final prefs = await SharedPreferences.getInstance();
    final totalAura = await getDailyBonusAura();
    final currentRank = getUserTitle(totalAura);
    final lastSeenRank = prefs.getString('last_seen_rank') ?? 'Acemi Kahin';

    // Her rütbenin Aura ödülü
    const rankRewards = {
      'Acemi Kahin': 5,
      'Çırak Kahin': 10,
      'Kahin': 20,
      'Bilge Kahin': 30,
      'Usta Kahin': 50,
      'Kozmik Kahin': 100,
    };

    if (currentRank != lastSeenRank) {
      await prefs.setString('last_seen_rank', currentRank);
      if (lastSeenRank != 'Acemi Kahin' || currentRank != 'Acemi Kahin') {
        final reward = rankRewards[currentRank] ?? 0;
        if (reward > 0) {
          await addPendingAura('rank_up', reward);
        }
        return {'title': currentRank, 'auraReward': reward};
      }
    }
    return null;
  }

  /// Bir sonraki unvana kaç aura kaldığını döndür
  static Map<String, dynamic> getNextTitleInfo(int totalAura) {
    const levels = [
      {'title': 'Çırak Kahin', 'min': 51},
      {'title': 'Kahin', 'min': 151},
      {'title': 'Bilge Kahin', 'min': 301},
      {'title': 'Usta Kahin', 'min': 601},
      {'title': 'Kozmik Kahin', 'min': 1001},
    ];
    for (final level in levels) {
      final min = level['min'] as int;
      if (totalAura < min) {
        return {
          'nextTitle': level['title'],
          'remaining': min - totalAura,
          'target': min,
          'progress': totalAura / min,
        };
      }
    }
    return {'nextTitle': null, 'remaining': 0, 'target': 1001, 'progress': 1.0}; // Max seviye
  }

  static Future<String?> getMood() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyMood);
  }

  static Future<void> setMood(String mood) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMood, mood);
  }

  static Future<List<Map<String, dynamic>>> getDreams() async {
    final prefs = await SharedPreferences.getInstance();
    // Yeni format: json list
    final listJson = prefs.getString(_keyDreamList);
    if (listJson != null) {
      try {
        final List decoded = jsonDecode(listJson) as List;
        return decoded.cast<Map<String, dynamic>>();
      } catch (_) {
        // json bozulduysa aşağıdaki legacy'ye düşer
      }
    }

    // Eski format (tekil anahtarlar) geriye dönük destek
    final dreamCount = prefs.getInt('${_keyDreams}_count') ?? 0;
    final List<Map<String, dynamic>> legacy = [];

    for (int i = 0; i < dreamCount; i++) {
      final dreamText = prefs.getString('${_keyDreams}_${i}_text');
      final dreamMood = prefs.getString('${_keyDreams}_${i}_mood');
      final dreamDate = prefs.getString('${_keyDreams}_${i}_date');

      if (dreamText != null) {
        legacy.add({
          'title': null,
          'text': dreamText,
          'mood': dreamMood,
          'date': dreamDate,
          'symbols': const [],
        });
      }
    }
    return legacy;
  }

  static Future<void> saveDream(Map<String, dynamic> dream) async {
    final prefs = await SharedPreferences.getInstance();
    final dreams = await getDreams();

    if (dream.containsKey('id')) {
      final idx = dreams.indexWhere((d) => d['id'] == dream['id']);
      if (idx != -1) {
        dreams[idx] = dream;
        await prefs.setString(_keyDreamList, jsonEncode(dreams));
        return;
      }
    }

    if (!dream.containsKey('id')) {
      dream['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    }

    dreams.insert(0, dream); // en yeni en üstte

    // ── 12 AYLIK DÖNEN PENCERE ──
    // 12 aydan eski rüyaları otomatik sil (sunucu yükü sabit kalsın)
    final cutoff = DateTime.now().subtract(const Duration(days: 365));
    dreams.removeWhere((d) {
      final dateStr = d['date'] as String?;
      if (dateStr == null) return false;
      final date = DateTime.tryParse(dateStr);
      if (date == null) return false;
      return date.isBefore(cutoff);
    });

    await prefs.setString(_keyDreamList, jsonEncode(dreams));
    await incrementTotalDreams();
    AnalyticsService().logDreamSaved();
  }

  static Future<void> clearDreams() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDreamList);
    // Varsa legacy'yi de temizle:
    final count = prefs.getInt('${_keyDreams}_count') ?? 0;
    for (int i = 0; i < count; i++) {
      await prefs.remove('${_keyDreams}_${i}_text');
      await prefs.remove('${_keyDreams}_${i}_mood');
      await prefs.remove('${_keyDreams}_${i}_date');
    }
    await prefs.remove('${_keyDreams}_count');
  }

  /// Rüyaları aylara göre grupla (12 aylık dönen pencere)
  /// Dönen map: {'Mayıs 2026': [dream1, dream2], 'Nisan 2026': [dream3]}
  static Future<Map<String, List<Map<String, dynamic>>>> getDreamsByMonth() async {
    final dreams = await getDreams();
    final months = <String, List<Map<String, dynamic>>>{};
    final monthNames = ['', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 
                         'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];

    // İçinde bulunduğumuz ayı her zaman ilk sıraya ekle (boş olsa bile)
    final now = DateTime.now();
    final currentMonthKey = '${monthNames[now.month]} ${now.year}';
    months[currentMonthKey] = [];

    for (final dream in dreams) {
      final dateStr = dream['date'] as String?;
      if (dateStr == null) continue;
      final date = DateTime.tryParse(dateStr);
      if (date == null) continue;

      final key = '${monthNames[date.month]} ${date.year}';
      months.putIfAbsent(key, () => []);
      months[key]!.add(dream);
    }
    return months;
  }

  static Future<bool> isTarotDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyTarotDone) ?? false;
  }

  static Future<void> setTarotDone(bool done) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTarotDone, done);
  }

  static Future<bool> isDreamDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDreamDone) ?? false;
  }

  static Future<void> setDreamDone(bool done) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDreamDone, done);
  }

  static Future<bool> isZodiacDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyZodiacDone) ?? false;
  }

  static Future<void> setZodiacDone(bool done) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyZodiacDone, done);
  }

  static Future<Offset> getZodiacOverlayOffset() async {
    final prefs = await SharedPreferences.getInstance();
    final dx = prefs.getDouble(_keyZodiacOverlayDx) ?? 0.0;
    final dy = prefs.getDouble(_keyZodiacOverlayDy) ?? 0.0;
    return Offset(dx, dy);
  }

  static Future<void> setZodiacOverlayOffset(Offset offset) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyZodiacOverlayDx, offset.dx);
    await prefs.setDouble(_keyZodiacOverlayDy, offset.dy);
  }

  static Future<Offset> getTarotOverlayOffset() async {
    final prefs = await SharedPreferences.getInstance();
    final dx = prefs.getDouble(_keyTarotOverlayDx) ?? 0.0;
    final dy = prefs.getDouble(_keyTarotOverlayDy) ?? 0.0;
    return Offset(dx, dy);
  }

  static Future<void> setTarotOverlayOffset(Offset offset) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyTarotOverlayDx, offset.dx);
    await prefs.setDouble(_keyTarotOverlayDy, offset.dy);
  }


  static Future<Offset> getMotiveAstronautOffset() async {
    final prefs = await SharedPreferences.getInstance();
    final dx = prefs.getDouble(_keyMotiveAstronautDx) ?? 0.0;
    final dy = prefs.getDouble(_keyMotiveAstronautDy) ?? 0.0;
    return Offset(dx, dy);
  }

  static Future<void> setMotiveAstronautOffset(Offset offset) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyMotiveAstronautDx, offset.dx);
    await prefs.setDouble(_keyMotiveAstronautDy, offset.dy);
  }

  static Future<Offset> getMotivePlanetOffset() async {
    final prefs = await SharedPreferences.getInstance();
    final dx = prefs.getDouble(_keyMotivePlanetDx) ?? 0.0;
    final dy = prefs.getDouble(_keyMotivePlanetDy) ?? 0.0;
    return Offset(dx, dy);
  }

  static Future<void> setMotivePlanetOffset(Offset offset) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyMotivePlanetDx, offset.dx);
    await prefs.setDouble(_keyMotivePlanetDy, offset.dy);
  }

  static Future<Offset> getMotiveStarOffset() async {
    final prefs = await SharedPreferences.getInstance();
    final dx = prefs.getDouble(_keyMotiveStarDx) ?? 0.0;
    final dy = prefs.getDouble(_keyMotiveStarDy) ?? 0.0;
    return Offset(dx, dy);
  }

  static Future<void> setMotiveStarOffset(Offset offset) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyMotiveStarDx, offset.dx);
    await prefs.setDouble(_keyMotiveStarDy, offset.dy);
  }

  // --- Cookie Collection ---
  static List<CookieCard> _baseCookieCards() {
    const paidIds = [
      'blue_porcelain',
      'cupid_ribbon',
      'diamond_crust',
      'dragon_phoenix',
      'emerald_essence',
      'gold_beasts',
      'golden_arabesque',
      'golden_majesty',
      'golden_sakura',
      'midnight_mosaic',
      'obsidian_grace',
      'panda_bamboo',
      'pearl_lace',
      'pink_blossom',
      'platinum_veil',
      'royal_sapphire',
      'ruby_heart',
      'wildflower',
    ];
    const legendaryIds = ['dragon_phoenix', 'gold_beasts', 'diamond_crust', 'platinum_veil'];

    String rarityFor(String id) {
      if (legendaryIds.contains(id)) return 'legendary';
      if (paidIds.contains(id)) return 'rare';
      return 'common';
    }

    final names = {
      'spring_wreath': 'Bahar Çelengi',
      'lucky_clover': 'Şanslı Yonca',
      'royal_hearts': 'Kraliyet Kalpleri',
      'evil_eye': 'Nazar',
      'silver_lotus': 'Gümüş Nilüfer',
      'sakura_bloom': 'Sakura',
      'blue_porcelain': 'Mavi Porselen',
      'pink_blossom': 'Pembe Çiçek',
      'fortune_cat': 'Şans Kedisi',
      'wildflower': 'Kır Çiçeği',
      'cupid_ribbon': 'Aşk Kurdelesi',
      'panda_bamboo': 'Panda',
      'ramadan_cute': 'Ramazan',
      'enchanted_forest': 'Büyülü Orman',
      'golden_arabesque': 'Altın Arabesk',
      'midnight_mosaic': 'Gece Mozaiği',
      'pearl_lace': 'İnci Dantel',
      'golden_sakura': 'Altın Sakura',
      'dragon_phoenix': 'Ejderha & Anka',
      'gold_beasts': 'Altın Canavarlar',
      
      // YENİ ÜCRETSİZ (FREE) KURABİYELER
      'celestial_dream': 'Göksel Rüya',
      'starlight_whisper': 'Yıldız Fısıltısı',
      'mystic_aura': 'Mistik Aura',
      'lunar_glow': 'Ay Işıltısı',
      'solar_flare': 'Güneş Patlaması',
      'cosmic_dust': 'Kozmik Toz',
      'nebula_breeze': 'Nebula Esintisi',
      'astral_projection': 'Astral Seyahat',
      'quantum_leap': 'Kuantum Sıçraması',

      // YENİ ÜCRETLİ (PAID) KURABİYELER
      'royal_sapphire': 'Kraliyet Safiri',
      'diamond_crust': 'Elmas Kabuk',
      'platinum_veil': 'Platin Peçe',
      'golden_majesty': 'Altın İhtişam',
      'emerald_essence': 'Zümrüt Özü',
      'ruby_heart': 'Yakut Kalp',
      'obsidian_grace': 'Obsidyen Zarafeti',
    };

    return names.entries
        .map(
          (e) => CookieCard(
            id: e.key,
            emoji: e.key, // Artık emoji yerine ID kullanıyoruz
            name: e.value,
            rarity: rarityFor(e.key),
          ),
        )
        .toList();
  }

  static Future<List<CookieCard>> getCookieCollection() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyCookieCollection);
    final base = _baseCookieCards();
    
    Map<String, CookieCard> map = {for (final c in base) c.id: c};
    
    if (jsonStr != null) {
      try {
        final List decoded = jsonDecode(jsonStr) as List;
        final stored = decoded
            .map((e) => CookieCard.fromJson(e as Map<String, dynamic>))
            .toList();
        
        for (final c in stored) {
          map[c.id] = c;
        }
      } catch (_) {}
    }
    
    // ── VERİ KURTARMA (DATA RECOVERY) ──
    // Eğer kullanıcının koleksiyonu bir hata nedeniyle silindiyse veya boşsa
    final totalCracked = prefs.getInt(_keyTotalCookies) ?? 0;
    final uniqueCount = map.values.where((c) => c.firstObtainedDate != null || c.countObtained > 0).length;
    
    if (totalCracked > 0 && uniqueCount == 0 && map.isNotEmpty) {
      // Toplam kırılanın %30'u kadar (en az 1, en fazla 20) rastgele kurabiyeyi kurtar
      int cookiesToRestore = (totalCracked * 0.3).toInt().clamp(1, 20);
      final listValues = map.values.toList();
      listValues.shuffle();
      
      for (int i = 0; i < cookiesToRestore && i < listValues.length; i++) {
        final id = listValues[i].id;
        map[id] = map[id]!.copyWith(
          countObtained: 1,
          firstObtainedDate: DateTime.now().subtract(Duration(days: i)),
        );
      }
      
      // Kurtarılan veriyi anında kaydet
      prefs.setString(
        _keyCookieCollection,
        jsonEncode(map.values.map((c) => c.toJson()).toList()),
      );
    }

    return map.values.toList();
  }

  static Future<void> _saveCookieCollection(List<CookieCard> cards) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyCookieCollection,
      jsonEncode(cards.map((c) => c.toJson()).toList()),
    );
  }

  static Future<void> incrementCookieCard(String id, {bool isRewardOrGift = false}) async {
    final cards = await getCookieCollection();
    final updated = cards.map((c) {
      if (c.id != id) return c;
      
      int newCount = c.countObtained + 1; // Her zaman envanteri artır

      return c.copyWith(
        countObtained: newCount,
        firstObtainedDate: c.firstObtainedDate ?? DateTime.now(), // İlk kez alınıyorsa tarihi setle (Açılan kurabiyelerde görünmesi için)
      );
    }).toList();
    await _saveCookieCollection(updated);
  }

  /// Kurabiyeyi kır (kullan)
  static Future<void> consumeCookieCard(String id, {required bool isPaid}) async {
    final cards = await getCookieCollection();
    final updated = cards.map((c) {
      if (c.id != id) return c;
      
      int newCount = c.countObtained;
      if (isPaid) {
        newCount = (c.countObtained - 1).clamp(0, 999); // Ücretli kurabiye kırılınca envanterden düşer
      } else {
        newCount = c.countObtained + 1; // Ücretsiz kurabiye kırıldıkça sayısı (x1, x2) profil için artar
      }
      
      return c.copyWith(
        countObtained: newCount,
        firstObtainedDate: c.firstObtainedDate ?? DateTime.now(), // Kırıldığı için artık 'Açılan Kurabiyeler' geçmişinde görünür
      );
    }).toList();
    await _saveCookieCollection(updated);
  }

  static Future<void> decrementCookieCard(String id) async {
    final cards = await getCookieCollection();
    final updated = cards.map((c) {
      if (c.id != id) return c;
      
      int newCount = c.countObtained - 1;
      if (newCount < 0) newCount = 0; // Negatif olmasını önle
      
      return c.copyWith(countObtained: newCount);
    }).toList();
    await _saveCookieCollection(updated);
  }

  static Future<void> toggleCookieFavorite(String id, bool value) async {
    final cards = await getCookieCollection();
    final updated = cards.map((c) {
      if (c.id != id) return c;
      return c.copyWith(isFavorite: value);
    }).toList();
    await _saveCookieCollection(updated);
  }

  /// Mektupla gelen kurabiyeyi koleksiyona ekle (sayısını +1 artır)
  static Future<void> addCookieToCollection(String cookieId) async {
    await incrementCookieCard(cookieId);
  }

  /// Kurabiye koleksiyonundan 1 adet düş (mektupla gönderirken)
  static Future<void> deductCookieCard(String cookieId) async {
    final cards = await getCookieCollection();
    final updated = cards.map((c) {
      if (c.id != cookieId) return c;
      final newCount = (c.countObtained - 1).clamp(0, 999);
      return c.copyWith(countObtained: newCount);
    }).toList();
    await _saveCookieCollection(updated);
  }

  // --- Fortune seen list ---
  static Future<List<String>> getSeenFortuneIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keySeenFortunes) ?? [];
  }

  static Future<void> addSeenFortuneId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_keySeenFortunes) ?? [];
    if (current.contains(id)) return;
    current.add(id);
    await prefs.setStringList(_keySeenFortunes, current);
  }

  static Future<void> clearSeenFortunes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySeenFortunes);
  }

  // ═══════════════════════════════════════════════════════════════
  // MOTIVATION
  // ═══════════════════════════════════════════════════════════════

  static const String _keySeenMotivCards = 'seen_motiv_cards';
  static const String _keyMotivStreak = 'motiv_streak';
  static const String _keyMotivLastDate = 'motiv_last_date';
  static const String _keyMotivDoneDate = 'motiv_done_date';
  static const String _keyJournalEntries = 'journal_entries';
  static const String _keyUsedWheelTasks = 'used_wheel_tasks';
  static const String _keyUsedWheelDate = 'used_wheel_date';
  static const String _keyMotivLikedCards = 'motiv_liked_cards';

  /// Görülen motivasyon kart ID'leri
  static Future<List<String>> getSeenMotivationCardIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keySeenMotivCards) ?? [];
  }

  static Future<void> addSeenMotivationCardId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_keySeenMotivCards) ?? [];
    if (!current.contains(id)) {
      current.add(id);
      await prefs.setStringList(_keySeenMotivCards, current);
    }
  }

  static Future<void> addSeenMotivationCardIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_keySeenMotivCards) ?? [];
    for (final id in ids) {
      if (!current.contains(id)) current.add(id);
    }
    await prefs.setStringList(_keySeenMotivCards, current);
  }

  /// Beğenilen kart ID'leri
  static Future<List<String>> getLikedMotivationCardIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyMotivLikedCards) ?? [];
  }

  static Future<void> addLikedMotivationCardId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_keyMotivLikedCards) ?? [];
    if (!current.contains(id)) {
      current.add(id);
      await prefs.setStringList(_keyMotivLikedCards, current);
    }
  }

  /// Motivasyon streak
  static Future<int> getMotivationStreak() async {
    final prefs = await SharedPreferences.getInstance();
    // Streak'i kontrol et — son tarih dün veya bugün mü?
    final lastDate = prefs.getString(_keyMotivLastDate);
    final today = _todayKey();
    final yesterday = DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .split('T')[0];

    if (lastDate == today || lastDate == yesterday) {
      return prefs.getInt(_keyMotivStreak) ?? 0;
    }
    // Streak kırıldı
    return 0;
  }

  // ── GÖRÜLMÜŞ KURABİYE TAKİBİ ──
  static const String _keySeenCookieIds = 'seen_cookie_ids';

  /// Görülmüş kurabiye ID'lerini döndür
  static Future<Set<String>> getSeenCookieIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keySeenCookieIds) ?? [];
    return list.toSet();
  }

  /// Bir kurabiyeyi görüldü olarak işaretle
  static Future<void> markCookieSeen(String cookieId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keySeenCookieIds) ?? [];
    if (!list.contains(cookieId)) {
      list.add(cookieId);
      await prefs.setStringList(_keySeenCookieIds, list);
    }
  }

  /// Görülmemiş (yeni) kurabiye var mı kontrol et
  static Future<bool> hasUnseenCookies() async {
    final collection = await getCookieCollection();
    final seen = await getSeenCookieIds();
    // countObtained > 0 olan ama görülmemiş kurabiye varsa true
    for (final c in collection) {
      if (c.countObtained > 0 && !seen.contains(c.id)) return true;
    }
    return false;
  }

  static Future<int> updateMotivationStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString(_keyMotivLastDate);
    final today = _todayKey();

    if (lastDate == today) {
      return prefs.getInt(_keyMotivStreak) ?? 1;
    }

    final yesterday = DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .split('T')[0];
    
    int newStreak;
    if (lastDate == yesterday) {
      newStreak = (prefs.getInt(_keyMotivStreak) ?? 0) + 1;
    } else {
      newStreak = 1;
    }

    await prefs.setInt(_keyMotivStreak, newStreak);
    await prefs.setString(_keyMotivLastDate, today);
    return newStreak;
  }

  /// Bugün motivasyon tamamlandı mı?
  static Future<bool> isMotivationDoneToday() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyMotivDoneDate) == _todayKey();
  }

  static Future<void> setMotivationDoneToday() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMotivDoneDate, _todayKey());
  }

  /// Günlük girişleri
  static Future<void> saveJournalEntry(String text) async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = prefs.getString(_keyJournalEntries);
    List<Map<String, dynamic>> entries = [];
    if (entriesJson != null) {
      try {
        entries = (jsonDecode(entriesJson) as List)
            .cast<Map<String, dynamic>>();
      } catch (_) {}
    }
    entries.insert(0, {
      'text': text,
      'date': _todayKey(),
      'timestamp': DateTime.now().toIso8601String(),
    });
    await prefs.setString(_keyJournalEntries, jsonEncode(entries));
  }

  static Future<List<Map<String, dynamic>>> getJournalEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = prefs.getString(_keyJournalEntries);
    if (entriesJson == null) return [];
    try {
      return (jsonDecode(entriesJson) as List)
          .cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  /// Bugün kullanılan çark görevleri
  static Future<List<String>> getUsedWheelTasksToday() async {
    final prefs = await SharedPreferences.getInstance();
    final date = prefs.getString(_keyUsedWheelDate);
    if (date != _todayKey()) return []; // yeni gün, sıfır
    return prefs.getStringList(_keyUsedWheelTasks) ?? [];
  }

  static Future<void> addUsedWheelTask(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final date = prefs.getString(_keyUsedWheelDate);
    
    List<String> used;
    if (date == today) {
      used = prefs.getStringList(_keyUsedWheelTasks) ?? [];
    } else {
      used = [];
      await prefs.setString(_keyUsedWheelDate, today);
    }
    
    if (!used.contains(id)) used.add(id);
    await prefs.setStringList(_keyUsedWheelTasks, used);
  }

  // ═══════════════════════════════════════════════════════════════
  // OWL LETTERS (Baykuş Mektupları)
  // ═══════════════════════════════════════════════════════════════

  static const String _keyOwlLetters = 'owl_letters';
  static const String _keyOwlLastDelivered = 'owl_last_delivered_date';
  static const String _keyOwlDeliveredIds = 'owl_delivered_ids';

  /// Tüm mektupları getir (baykuştan gelen + kullanıcının yazdığı)
  static Future<List<OwlLetter>> getOwlLetters() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyOwlLetters);
    if (json == null) return [];
    try {
      final List decoded = jsonDecode(json) as List;
      return decoded
          .map((e) => OwlLetter.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Mektup kaydet
  static Future<void> saveOwlLetter(OwlLetter letter) async {
    final prefs = await SharedPreferences.getInstance();
    final letters = await getOwlLetters();
    letters.insert(0, letter);
    await prefs.setString(
      _keyOwlLetters,
      jsonEncode(letters.map((l) => l.toJson()).toList()),
    );
  }

  /// Mektubu okundu olarak işaretle
  static Future<void> markOwlLetterRead(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final letters = await getOwlLetters();
    final updated = letters.map((l) {
      if (l.id == id) return l.copyWith(isRead: true);
      return l;
    }).toList();
    await prefs.setString(
      _keyOwlLetters,
      jsonEncode(updated.map((l) => l.toJson()).toList()),
    );
  }

  /// Mektup sil
  static Future<void> deleteOwlLetter(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final letters = await getOwlLetters();
    letters.removeWhere((l) => l.id == id);
    await prefs.setString(
      _keyOwlLetters,
      jsonEncode(letters.map((l) => l.toJson()).toList()),
    );
  }

  /// Okunmamış mektup sayısı
  static Future<int> getUnreadOwlLetterCount() async {
    final letters = await getOwlLetters();
    final now = DateTime.now();
    return letters.where((l) {
      if (l.isRead) return false;
      // Geleceğe mektup henüz açılmamışsa sayma
      if (!l.fromOwl && l.openAt != null && l.openAt!.isAfter(now)) {
        return false;
      }
      return true;
    }).length;
  }

  /// Bugün baykuş mektup getirdi mi? Getirmediyse havuzdan birini seç ve kaydet.
  static Future<OwlLetter?> getOrDeliverDailyOwlLetter() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final lastDelivered = prefs.getString(_keyOwlLastDelivered);

    if (lastDelivered == today) return null; // bugün zaten geldi

    // Daha önce teslim edilen ID'ler
    final deliveredIds = prefs.getStringList(_keyOwlDeliveredIds) ?? [];

    // Havuzdan henüz gelmemiş bir mektup seç
    final pool = OwlLetterPool.letters;
    final available = <int>[];
    for (int i = 0; i < pool.length; i++) {
      if (!deliveredIds.contains('owl_$i')) {
        available.add(i);
      }
    }

    // Hepsi geldiyse sıfırla
    if (available.isEmpty) {
      deliveredIds.clear();
      for (int i = 0; i < pool.length; i++) {
        available.add(i);
      }
    }

    final rng = Random();
    final idx = available[rng.nextInt(available.length)];
    final entry = pool[idx];

    final letter = OwlLetter(
      id: 'owl_${today}_$idx',
      contentTr: entry['tr']!,
      contentEn: entry['en']!,
      fromOwl: true,
      createdAt: DateTime.now(),
    );

    await saveOwlLetter(letter);
    deliveredIds.add('owl_$idx');
    await prefs.setStringList(_keyOwlDeliveredIds, deliveredIds);
    await prefs.setString(_keyOwlLastDelivered, today);

    return letter;
  }

  // ═══════════════════════════════════════════════════════════════
  // ZODIAC CHALLENGES
  // ═══════════════════════════════════════════════════════════════

  static Future<List<String>> getCompletedCosmicTasks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyCompletedCosmicTasks) ?? [];
  }

  static Future<void> addCompletedCosmicTask(String task) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_keyCompletedCosmicTasks) ?? [];
    if (!current.contains(task)) {
      current.add(task);
      await prefs.setStringList(_keyCompletedCosmicTasks, current);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // WELCOME / AUTH
  // ═══════════════════════════════════════════════════════════════

  static const String _keyHasSeenWelcome = 'has_seen_welcome';

  static Future<bool> hasSeenWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasSeenWelcome) ?? false;
  }

  static Future<void> setHasSeenWelcome(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSeenWelcome, value);
  }

  // ═══════════════════════════════════════════════════════════════
  // ZODIAC TRAIT BOOSTS (Görev tamamlayınca artan değerler)
  // ═══════════════════════════════════════════════════════════════

  static const String _keyTraitBoosts = 'zodiac_trait_boosts';

  /// Trait boost'larını oku → { "Sabırsızlık": 5, "Dürüst": 3 } gibi
  static Future<Map<String, int>> getTraitBoosts() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyTraitBoosts);
    if (json == null) return {};
    try {
      final Map<String, dynamic> decoded = jsonDecode(json) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
    } catch (_) {
      return {};
    }
  }

  /// Belirli bir trait'in boost'unu artır
  static Future<void> addTraitBoost(String traitName, int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final boosts = await getTraitBoosts();
    final current = boosts[traitName] ?? 0;
    // Maksimum toplam boost: +40 puan
    boosts[traitName] = (current + amount).clamp(0, 40);
    await prefs.setString(_keyTraitBoosts, jsonEncode(boosts));
  }

  // ═══════════════════════════════════════════════════════════════
  // NOTIFICATION SETTINGS (Bildirim Ayarları)
  // ═══════════════════════════════════════════════════════════════

  static const String _keyNotifPrefix = 'notif_';

  /// Tüm bildirim ayarlarını oku
  static Future<Map<String, bool>> getNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'announcements': prefs.getBool('${_keyNotifPrefix}announcements') ?? true,
      'voices': prefs.getBool('${_keyNotifPrefix}voices') ?? false,
      'newCookieAlarm': prefs.getBool('${_keyNotifPrefix}newCookieAlarm') ?? true,
      'friendsAlarm': prefs.getBool('${_keyNotifPrefix}friendsAlarm') ?? true,
      'dailyReminders': prefs.getBool('${_keyNotifPrefix}dailyReminders') ?? true,
    };
  }

  /// Tek bir bildirim ayarını kaydet
  static Future<void> setNotificationSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_keyNotifPrefix}$key', value);
  }

  // --- DEVELOPER FAST RESET ---
  static Future<void> forceResetDailyLimits() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cookie_cracks_today');
    await prefs.remove('cookie_cracks_date');
    await prefs.remove('letters_sent_today');
    await prefs.remove('letters_sent_date');
    await prefs.remove('tarot_done_date');
    await prefs.remove('dream_done_date');
    await prefs.remove('zodiac_done_date');
    await prefs.remove('motiv_done_date');
    await prefs.remove('owl_last_delivered');
  }

  // --- CONTACTS SYNC STATE ---
  static Future<bool> hasContactsSynced() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('contacts_synced_once') ?? false;
  }

  static Future<void> setContactsSynced(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('contacts_synced_once', value);
  }

  // --- SOUND SETTINGS ---
  static Future<bool?> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('sound_enabled');
  }

  static Future<void> setSoundEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', value);
    // ---------------------------------------------------------------------------
  // ELITE ABONELİK & GÜNLÜK ÖDÜL (Adım 4)
  // ---------------------------------------------------------------------------
  
  /// Her gece 00:00'dan sonra giriş yapan Elite abonelere bedava 5 Ruh Taşı verir.
  /// Ayrıca Elite aboneliği biten kullanıcının yetkilerini temizler.
  static Future<void> checkDailyEliteReward() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 1. Kullanıcı şu an Elite mi? (Bunu Supabase'den veya IAP'den güncelleyebilirsiniz)
      final isElite = prefs.getBool('is_elite') ?? false;
      if (!isElite) return; // Elite değilse ödül yok

      // 2. Bugünün tarihini al (Sadece yıl-ay-gün olarak)
      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month}-${now.day}';

      // 3. Son ödül aldığı tarihi çek
      final lastRewardDate = prefs.getString(_keyDailyEliteSoulDate);

      // 4. Eğer bugün ödül almamışsa
      if (lastRewardDate != todayStr) {
        // Envantere 5 ruh taşı ekle
        final currentStones = await getSoulStones();
        await prefs.setInt(_keySoulStones, currentStones + 5);
        
        // Ödül tarihini bugüne güncelle
        await prefs.setString(_keyDailyEliteSoulDate, todayStr);
        
        debugPrint('👑 ELITE ÖDÜLÜ: Günlük 5 Bedava Ruh Taşı verildi!');
      }
    } catch (e) {
      debugPrint('👑 Elite ödül hatası: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // PROFİL VİTRİNİ (SHOWCASE)
  // ---------------------------------------------------------------------------
  
  static Future<List<String>> getPinnedCookies() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyPinnedCookies) ?? [];
  }

  static Future<void> setPinnedCookies(List<String> cookieIds) async {
    final prefs = await SharedPreferences.getInstance();
    // En fazla 3 tane sabitlenebilir
    final safeList = cookieIds.take(3).toList();
    await prefs.setStringList(_keyPinnedCookies, safeList);
  }

}
}
