import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import '../models/cookie_card.dart';
import '../models/owl_letter.dart';

class StorageService {
  static const String _keyCookieCount = 'cookie_count';
  static const String _keyTotalCookies = 'total_cookies';
  static const String _keyTotalDreams = 'total_dreams';
  static const String _keyTotalTarots = 'total_tarots';
  static const String _keyLongestStreak = 'longest_streak';
  static const String _keyUserName = 'user_name';
  static const String _keyZodiacSign = 'zodiac_sign';
  static const String _keyBirthDate = 'birth_date';
  static const String _keyCurrentMood = 'current_mood';
  static const String _keyStreakDays = 'streak_days';
  static const String _keySoulStones = 'soul_stones'; // Ruh Taşı (Premium Kredi)
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
  static const String _keyLocale = 'app_locale';
  static const String _keySelectedCookie = 'selected_cookie';
  static const String _keyInstallId = 'install_id';
  static const String _keyCompletedCosmicTasks = 'completed_cosmic_tasks';
  static const String _keySpentAura = 'spent_aura'; // Ruh Taşı çeviriminde harcanan Aura

  // ── PREMIUM EKONOMİ (Ruh Taşı / Soul Stones) ──
  static Future<int> getSoulStones() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_keySoulStones)) {
      // Yeni kullanıcılara hoşgeldin hediyesi olarak 3 Ruh Taşı ver
      await prefs.setInt(_keySoulStones, 3);
      return 3;
    }
    return prefs.getInt(_keySoulStones) ?? 0;
  }

  static Future<void> updateSoulStones(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getSoulStones();
    final newValue = (current + amount).clamp(0, 9999);
    await prefs.setInt(_keySoulStones, newValue);
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
  }

  static Future<int> getTotalTarots() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTotalTarots) ?? 0;
  }

  static Future<void> incrementTotalTarots() async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getTotalTarots();
    await prefs.setInt(_keyTotalTarots, current + 1);
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

  static Future<void> setTarotDoneToday() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTarotDoneDate, _todayKey());
    await prefs.setBool(_keyTarotDone, true);
  }

  static Future<void> setDreamDoneToday() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDreamDoneDate, _todayKey());
    await prefs.setBool(_keyDreamDone, true);
  }

  static Future<void> setZodiacDoneToday() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyZodiacDoneDate, _todayKey());
    await prefs.setBool(_keyZodiacDone, true);
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
      'longestStreak': prefs.getInt(_keyLongestStreak) ?? 0,
      'soulStones': prefs.getInt(_keySoulStones) ?? 3, // Eğer boşsa default hediye miktarını alıyoruz gibi düşün ama getSoulStones handle ediyor, buraya direkt yansıtalım.
      'userName': prefs.getString(_keyUserName),
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
      await prefs.setInt(_keyStreakDays, currentStreak + 1);
    } else if (lastDate == null || lastDate != today) {
      // Yeni seri başlıyor
      await prefs.setInt(_keyStreakDays, 1);
    }

    await prefs.setString(_keyLastCookieDate, today);
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
    await prefs.setString(_keyDreamList, jsonEncode(dreams));
    await incrementTotalDreams();
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
    // 20 görsel kurabiye: 14 ücretsiz (common) + 6 ücretli (rare/legendary)
    const paidIds = [
      'golden_arabesque',
      'midnight_mosaic',
      'pearl_lace',
      'golden_sakura',
      'dragon_phoenix',
      'gold_beasts',
    ];
    const legendaryIds = ['dragon_phoenix', 'gold_beasts'];

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
      'pizza_party': 'Pizza Partisi',
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
    if (jsonStr == null) return base;
    try {
      final List decoded = jsonDecode(jsonStr) as List;
      final stored = decoded
          .map((e) => CookieCard.fromJson(e as Map<String, dynamic>))
          .toList();
      // Bilinen kurabiye ID'leri — eski emoji ID'leri filtrele
      final validIds = base.map((c) => c.id).toSet();
      final Map<String, CookieCard> map = {for (final c in base) c.id: c};
      for (final c in stored) {
        if (validIds.contains(c.id)) {
          map[c.id] = c;
        }
      }
      return map.values.toList();
    } catch (_) {
      return base;
    }
  }

  static Future<void> _saveCookieCollection(List<CookieCard> cards) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyCookieCollection,
      jsonEncode(cards.map((c) => c.toJson()).toList()),
    );
  }

  static Future<void> incrementCookieCard(String id) async {
    final cards = await getCookieCollection();
    final updated = cards.map((c) {
      if (c.id != id) return c;
      final newCount = c.countObtained + 1;
      return c.copyWith(
        countObtained: newCount,
        firstObtainedDate: c.firstObtainedDate ?? DateTime.now(),
      );
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
      'dailyReminders': prefs.getBool('${_keyNotifPrefix}dailyReminders') ?? false,
    };
  }

  /// Tek bir bildirim ayarını kaydet
  static Future<void> setNotificationSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_keyNotifPrefix}$key', value);
  }
}
