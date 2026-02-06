import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:ui';
import '../models/cookie_card.dart';

class StorageService {
  static const String _keyCookieCount = 'cookie_count';
  static const String _keyTotalCookies = 'total_cookies';
  static const String _keyTotalDreams = 'total_dreams';
  static const String _keyTotalTarots = 'total_tarots';
  static const String _keyLongestStreak = 'longest_streak';
  static const String _keyUserName = 'user_name';
  static const String _keyZodiacSign = 'zodiac_sign';
  static const String _keyCurrentMood = 'current_mood';
  static const String _keyStreakDays = 'streak_days';
  static const String _keyLastCookieDate = 'last_cookie_date';
  static const String _keyMood = 'mood';
  static const String _keyDreams = 'dreams';
  static const String _keyDreamList = 'dream_list'; // json list (yeni yöntem)
  static const String _keyTarotDone = 'tarot_done';
  static const String _keyDreamDone = 'dream_done';
  static const String _keyZodiacDone = 'zodiac_done';
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

  static Future<String?> getZodiacSign() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyZodiacSign);
  }

  static Future<void> setZodiacSign(String sign) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyZodiacSign, sign);
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
    dreams.insert(0, dream); // en yeni en üstte
    await prefs.setString(_keyDreamList, jsonEncode(dreams));
    await incrementTotalDreams();
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
    // 19 mevcut emoji için temel kartlar; rarity sabit.
    const rareIds = ['🎃', '🔮', '🐉', '💎', '🔥', '🌺'];
    const legendaryIds = ['👁️', '🎪', '🦄'];

    String rarityFor(String id) {
      if (legendaryIds.contains(id)) return 'legendary';
      if (rareIds.contains(id)) return 'rare';
      return 'common';
    }

    final names = {
      '🏯': 'Klasik Kurabiye',
      '🎃': 'Cadı Kurabiyesi',
      '🥠': 'Sade Kurabiye',
      '🍪': 'Çikolata Kurabiyesi',
      '⭐': 'Yıldız Kurabiye',
      '🔮': 'Mistik Kurabiye',
      '🐉': 'Ejder Kurabiyesi',
      '🦋': 'Kelebek Kurabiyesi',
      '🎭': 'Tiyatro Kurabiyesi',
      '🍀': 'Şans Kurabiyesi',
      '💎': 'Elmas Kurabiyesi',
      '🔥': 'Ateş Kurabiyesi',
      '⚡': 'Yıldırım Kurabiyesi',
      '🌈': 'Gökkuşağı Kurabiyesi',
      '👁️': 'Göz Kurabiyesi',
      '🎪': 'Sirk Kurabiyesi',
      '🦄': 'Tekboynuz Kurabiyesi',
      '🐱': 'Kedi Kurabiyesi',
      '🌺': 'Çiçek Kurabiyesi',
    };

    return names.entries
        .map(
          (e) => CookieCard(
            id: e.key,
            emoji: e.key,
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
      // Merge base with stored to ensure new cards are present
      final Map<String, CookieCard> map = {for (final c in base) c.id: c};
      for (final c in stored) {
        map[c.id] = c;
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
}
