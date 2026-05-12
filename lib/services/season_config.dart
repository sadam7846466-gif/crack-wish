import 'package:flutter/material.dart';
import 'dart:math' as math;

class SeasonConfig {
  static const String currentSeason = 'may'; 

  static final List<Map<String, dynamic>> _allFreeCookies = [
    {'id': 'astral_projection', 'key': 'cookieAstralProjection', 'imagePath': 'assets/images/cookies/free/may/astral_projection.webp', 'isPaid': false, 'color': const Color(0xFF9FA8DA)},
    {'id': 'celestial_dream', 'key': 'cookieCelestialDream', 'imagePath': 'assets/images/cookies/free/may/celestial_dream.webp', 'isPaid': false, 'color': const Color(0xFFB39DDB)},
    {'id': 'cosmic_dust', 'key': 'cookieCosmicDust', 'imagePath': 'assets/images/cookies/free/may/spring_wreath.webp', 'isPaid': false, 'color': const Color(0xFFBCAAA4)},
    {'id': 'enchanted_forest', 'key': 'cookieEnchantedForest', 'imagePath': 'assets/images/cookies/free/may/enchanted_forest.webp', 'isPaid': false, 'color': const Color(0xFF81C784)},
    {'id': 'evil_eye', 'key': 'cookieEvilEye', 'imagePath': 'assets/images/cookies/free/may/evil_eye.webp', 'isPaid': false, 'color': const Color(0xFF2196F3)},
    {'id': 'fortune_cat', 'key': 'cookieFortuneCat', 'imagePath': 'assets/images/cookies/free/may/fortune_cat.webp', 'isPaid': false, 'color': const Color(0xFFFFB74D)},
    {'id': 'lucky_clover', 'key': 'cookieLuckyClover', 'imagePath': 'assets/images/cookies/free/may/lucky_clover.webp', 'isPaid': false, 'color': const Color(0xFF4CAF50)},
    {'id': 'lunar_glow', 'key': 'cookieLunarGlow', 'imagePath': 'assets/images/cookies/free/may/lunar_glow.webp', 'isPaid': false, 'color': const Color(0xFFFFF59D)},
    {'id': 'mystic_aura', 'key': 'cookieMysticAura', 'imagePath': 'assets/images/cookies/free/may/mystic_aura.webp', 'isPaid': false, 'color': const Color(0xFFCE93D8)},
    {'id': 'nebula_breeze', 'key': 'cookieNebulaBreeze', 'imagePath': 'assets/images/cookies/free/may/nebula_breeze.webp', 'isPaid': false, 'color': const Color(0xFF80CBC4)},
    {'id': 'silver_lotus', 'key': 'cookieSilverLotus', 'imagePath': 'assets/images/cookies/free/may/astral_projection.webp', 'isPaid': false, 'color': const Color(0xFFB0BEC5)},
    {'id': 'quantum_leap', 'key': 'cookieQuantumLeap', 'imagePath': 'assets/images/cookies/free/may/quantum_leap.webp', 'isPaid': false, 'color': const Color(0xFF80DEEA)},
    {'id': 'ramadan_cute', 'key': 'cookieRamadanCute', 'imagePath': 'assets/images/cookies/free/may/ramadan_cute.webp', 'isPaid': false, 'color': const Color(0xFF4DB6AC)},
    {'id': 'royal_hearts', 'key': 'cookieRoyalHearts', 'imagePath': 'assets/images/cookies/free/may/royal_hearts.webp', 'isPaid': false, 'color': const Color(0xFFE91E63)},
    {'id': 'sakura_bloom', 'key': 'cookieSakuraBloom', 'imagePath': 'assets/images/cookies/free/may/sakura_bloom.webp', 'isPaid': false, 'color': const Color(0xFFF48FB1)},
    {'id': 'solar_flare', 'key': 'cookieSolarFlare', 'imagePath': 'assets/images/cookies/free/may/solar_flare.webp', 'isPaid': false, 'color': const Color(0xFFFFAB91)},
    {'id': 'spring_wreath', 'key': 'cookieSpringWreath', 'imagePath': 'assets/images/cookies/free/may/spring_wreath.webp', 'isPaid': false, 'color': const Color(0xFF8BC34A)},
    {'id': 'starlight_whisper', 'key': 'cookieStarlightWhisper', 'imagePath': 'assets/images/cookies/free/may/starlight_whisper.webp', 'isPaid': false, 'color': const Color(0xFF81D4FA)},
  ];

  static final List<Map<String, dynamic>> _allPaidCookies = [
    {'id': 'blue_porcelain', 'key': 'cookieBluePorcelain', 'imagePath': 'assets/images/cookies/paid/may/blue_porcelain.webp', 'isPaid': true, 'color': const Color(0xFF42A5F5)},
    {'id': 'cupid_ribbon', 'key': 'cookieCupidRibbon', 'imagePath': 'assets/images/cookies/paid/may/cupid_ribbon.webp', 'isPaid': true, 'color': const Color(0xFFF06292)},
    {'id': 'diamond_crust', 'key': 'cookieDiamondCrust', 'imagePath': 'assets/images/cookies/paid/may/diamond_crust.webp', 'isPaid': true, 'color': const Color(0xFFE0F7FA)},
    {'id': 'dragon_phoenix', 'key': 'cookieDragonPhoenix', 'imagePath': 'assets/images/cookies/paid/may/dragon_phoenix.webp', 'isPaid': true, 'color': const Color(0xFFFF5722)},
    {'id': 'emerald_essence', 'key': 'cookieEmeraldEssence', 'imagePath': 'assets/images/cookies/paid/may/emerald_essence.webp', 'isPaid': true, 'color': const Color(0xFF2E7D32)},
    {'id': 'gold_beasts', 'key': 'cookieGoldBeasts', 'imagePath': 'assets/images/cookies/paid/may/gold_beasts.webp', 'isPaid': true, 'color': const Color(0xFFFFAB00)},
    {'id': 'golden_arabesque', 'key': 'cookieGoldenArabesque', 'imagePath': 'assets/images/cookies/paid/may/golden_arabesque.webp', 'isPaid': true, 'color': const Color(0xFFFFD700)},
    {'id': 'golden_majesty', 'key': 'cookieGoldenMajesty', 'imagePath': 'assets/images/cookies/paid/may/golden_majesty.webp', 'isPaid': true, 'color': const Color(0xFFFFB300)},
    {'id': 'golden_sakura', 'key': 'cookieGoldenSakura', 'imagePath': 'assets/images/cookies/paid/may/golden_sakura.webp', 'isPaid': true, 'color': const Color(0xFFF8BBD0)},
    {'id': 'midnight_mosaic', 'key': 'cookieMidnightMosaic', 'imagePath': 'assets/images/cookies/paid/may/midnight_mosaic.webp', 'isPaid': true, 'color': const Color(0xFF5C6BC0)},
    {'id': 'obsidian_grace', 'key': 'cookieObsidianGrace', 'imagePath': 'assets/images/cookies/paid/may/obsidian_grace.webp', 'isPaid': true, 'color': const Color(0xFF37474F)},
    {'id': 'panda_bamboo', 'key': 'cookiePandaBamboo', 'imagePath': 'assets/images/cookies/paid/may/panda_bamboo.webp', 'isPaid': true, 'color': const Color(0xFF81C784)},
    {'id': 'pearl_lace', 'key': 'cookiePearlLace', 'imagePath': 'assets/images/cookies/paid/may/pearl_lace.webp', 'isPaid': true, 'color': const Color(0xFFE0E0E0)},
    {'id': 'pink_blossom', 'key': 'cookiePinkBlossom', 'imagePath': 'assets/images/cookies/paid/may/pink_blossom.webp', 'isPaid': true, 'color': const Color(0xFFEC407A)},
    {'id': 'platinum_veil', 'key': 'cookiePlatinumVeil', 'imagePath': 'assets/images/cookies/paid/may/platinum_veil.webp', 'isPaid': true, 'color': const Color(0xFFCFD8DC)},
    {'id': 'royal_sapphire', 'key': 'cookieRoyalSapphire', 'imagePath': 'assets/images/cookies/paid/may/royal_sapphire.webp', 'isPaid': true, 'color': const Color(0xFF1565C0)},
    {'id': 'ruby_heart', 'key': 'cookieRubyHeart', 'imagePath': 'assets/images/cookies/paid/may/ruby_heart.webp', 'isPaid': true, 'color': const Color(0xFFC62828)},
    {'id': 'wildflower', 'key': 'cookieWildflower', 'imagePath': 'assets/images/cookies/paid/may/wildflower.webp', 'isPaid': true, 'color': const Color(0xFFCDDC39)},
  ];

  /// Garanti Rotasyon: 18 ücretsiz kurabiye, her hafta 6 tane.
  /// 3 haftada 18'in hepsi sırayla vitrine çıkar, hiçbiri atlanmaz.
  static List<Map<String, dynamic>> getWeeklyFreeCookies() {
    final now = DateTime.now();
    final weekNumber = now.difference(DateTime(now.year, 1, 1)).inDays ~/ 7;
    final cycleNumber = weekNumber ~/ 3; // Her 3 haftada yeni döngü
    final cyclePosition = weekNumber % 3; // Döngü içi pozisyon (0, 1, 2)

    final copyList = List<Map<String, dynamic>>.from(_allFreeCookies);
    copyList.shuffle(_FastRandom(cycleNumber)); // Döngü başında karıştır

    // 18 / 6 = tam 3 hafta, örtüşme yok
    final start = cyclePosition * 6;
    return copyList.sublist(start, start + 6);
  }

  /// Garanti Rotasyon: 18 ücretli kurabiye, her hafta 8 tane.
  /// 3 haftada 18'in hepsi en az 1 kez vitrine çıkar.
  static List<Map<String, dynamic>> getWeeklyPaidCookies() {
    final now = DateTime.now();
    final weekNumber = now.difference(DateTime(now.year, 1, 1)).inDays ~/ 7;
    final cycleNumber = weekNumber ~/ 3;
    final cyclePosition = weekNumber % 3;

    final copyList = List<Map<String, dynamic>>.from(_allPaidCookies);
    copyList.shuffle(_FastRandom(cycleNumber + 100));

    // 18 kurabiye, 8'er gösterim, adım 6 ile kaydırma
    // Hafta 0: [0-7], Hafta 1: [6-13], Hafta 2: [12-17,0-1]
    // 3 haftada 18'in hepsi en az 1 kez görünür
    final offset = cyclePosition * 6;
    final result = <Map<String, dynamic>>[];
    for (int i = 0; i < 8; i++) {
      result.add(copyList[(offset + i) % 18]);
    }
    return result;
  }

  static List<Map<String, dynamic>> getAllCookies() {
    return [..._allFreeCookies, ..._allPaidCookies];
  }
}

class _FastRandom implements math.Random {
  int _seed;
  _FastRandom(this._seed);
  @override bool nextBool() => nextInt(2) == 0;
  @override double nextDouble() => nextInt(1000000) / 1000000.0;
  @override int nextInt(int max) {
    _seed = (_seed * 1103515245 + 12345) & 0x7fffffff;
    return _seed % max;
  }
}
