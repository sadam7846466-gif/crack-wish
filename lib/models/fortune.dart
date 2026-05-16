import 'dart:math';
import '../services/storage_service.dart';
import '../data/daily_quotes.dart';

class Fortune {
  final String id;
  final String name;
  final String emoji;
  final String meaning;
  final String length; // short | medium
  final Map<String, String> stats;
  final int luckyNumber;
  final String luckyColor;
  final int luckPercent;

  Fortune({
    required this.id,
    required this.name,
    required this.emoji,
    required this.meaning,
    required this.length,
    required this.stats,
    required this.luckyNumber,
    required this.luckyColor,
    required this.luckPercent,
  });

  static List<_FortuneTemplate> _templates() {
    final List<_FortuneTemplate> list = [];
    final emojis = ['🌟', '🌙', '☀️', '💫', '❤️', '⚡', '🎭', '👑', '⚖️', '🔮', '🍀', '🦋', '✨', '🧿'];
    
    // Create templates from the 1000 item pool
    for (int i = 0; i < DailyQuotes.pool.length; i++) {
      final q = DailyQuotes.pool[i];
      final r = Random(i); // Deterministic generation for stable IDs and stats
      
      list.add(_FortuneTemplate(
        id: 'cookie_$i',
        nameTr: 'Kozmik Fısıltı',
        nameEn: 'Cosmic Whisper',
        emoji: emojis[r.nextInt(emojis.length)],
        meaningTr: q['tr']!,
        meaningEn: q['en']!,
        length: q['tr']!.length > 60 ? 'medium' : 'short',
        statsTr: {
          'Aşk': r.nextBool() ? 'Yükseliş' : 'Dengeli',
          'Kariyer': r.nextBool() ? 'Gelişim' : 'Stabil',
          'Para': r.nextBool() ? 'Artış' : 'Bekleyiş',
          'Sağlık': 'İyi',
        },
        statsEn: {
          'Love': r.nextBool() ? 'Rise' : 'Balanced',
          'Career': r.nextBool() ? 'Growth' : 'Stable',
          'Money': r.nextBool() ? 'Increase' : 'Wait',
          'Health': 'Good',
        },
      ));
    }
    return list;
  }

  static List<Fortune> _localizedFortunes(String languageCode) {
    return _templates()
        .map(
          (t) => Fortune(
            id: t.id,
            name: languageCode == 'tr' ? t.nameTr : t.nameEn,
            emoji: t.emoji,
            meaning: languageCode == 'tr' ? t.meaningTr : t.meaningEn,
            length: t.length,
            stats: languageCode == 'tr' ? t.statsTr : t.statsEn,
            luckyNumber: 0,
            luckyColor: '',
            luckPercent: 0,
          ),
        )
        .toList();
  }

  static Future<Fortune> getRandomFortune({
    required String languageCode,
  }) async {
    final fortunes = _localizedFortunes(languageCode);
    final seenIds = await StorageService.getSeenFortuneIds();

    final unseen = fortunes.where((f) => !seenIds.contains(f.id)).toList();
    List<Fortune> pool;

    if (unseen.isEmpty) {
      // Bütün mesajları görmüş (1000 tane), listeyi sıfırla
      await StorageService.clearSeenFortunes();
      pool = fortunes;
    } else {
      pool = unseen;
    }

    final selected = pool[Random().nextInt(pool.length)];

    final luckyNumber = Random().nextInt(99) + 1;
    final colors = languageCode == 'tr'
        ? ['Altın', 'Gümüş', 'Mavi', 'Kırmızı', 'Yeşil', 'Mor', 'Turuncu', 'Pembe', 'Kahverengi', 'Beyaz', 'Siyah', 'Lacivert']
        : ['Gold', 'Silver', 'Blue', 'Red', 'Green', 'Purple', 'Orange', 'Pink', 'Brown', 'White', 'Black', 'Navy'];
    final luckyColor = colors[Random().nextInt(colors.length)];
    final luckPercent = 50 + Random().nextInt(51);

    await StorageService.addSeenFortuneId(selected.id);

    return Fortune(
      id: selected.id,
      name: selected.name,
      emoji: selected.emoji,
      meaning: _shortenMeaning(selected.meaning),
      length: selected.length,
      stats: selected.stats,
      luckyNumber: luckyNumber,
      luckyColor: luckyColor,
      luckPercent: luckPercent,
    );
  }

  /// Anında fortune döndürür - storage beklemez
  static Fortune getRandomFortuneInstant({
    required String languageCode,
  }) {
    // Storage beklemiyoruz ama rastgelelik için tam listeyi kullanıyoruz.
    // İdealde bu fonksiyon Future olmalı ama Widget build esnasında senkron çalışması gerekiyorsa 
    // en azından 1000'lik havuzdan rastgele çekiyoruz. Gerçek Unseen logic'i Future olan getRandomFortune'da çalışır.
    final fortunes = _localizedFortunes(languageCode);
    
    // Basit rastgele
    final selected = fortunes[Random().nextInt(fortunes.length)];

    final luckyNumber = Random().nextInt(99) + 1;
    final colors = languageCode == 'tr'
        ? ['Altın', 'Gümüş', 'Mavi', 'Kırmızı', 'Yeşil', 'Mor', 'Turuncu', 'Pembe', 'Kahverengi', 'Beyaz', 'Siyah', 'Lacivert']
        : ['Gold', 'Silver', 'Blue', 'Red', 'Green', 'Purple', 'Orange', 'Pink', 'Brown', 'White', 'Black', 'Navy'];
    final luckyColor = colors[Random().nextInt(colors.length)];
    final luckPercent = 50 + Random().nextInt(51);

    // Storage'ı arka planda güncelle (aynı şeyin çıkma ihtimalini azaltır)
    StorageService.addSeenFortuneId(selected.id);

    return Fortune(
      id: selected.id,
      name: selected.name,
      emoji: selected.emoji,
      meaning: _shortenMeaning(selected.meaning),
      length: selected.length,
      stats: selected.stats,
      luckyNumber: luckyNumber,
      luckyColor: luckyColor,
      luckPercent: luckPercent,
    );
  }

  // Çok uzun anlamları kısalt (daha etkili, 2-3 satır civarı)
  static String _shortenMeaning(String text) {
    const int maxChars = 200; // Artık 1000 mesaj var ve daha uzun olabilirler
    if (text.length <= maxChars) return text;
    return '${text.substring(0, maxChars).trimRight()}...';
  }
}

class _FortuneTemplate {
  final String id;
  final String nameTr;
  final String nameEn;
  final String emoji;
  final String meaningTr;
  final String meaningEn;
  final String length;
  final Map<String, String> statsTr;
  final Map<String, String> statsEn;

  const _FortuneTemplate({
    required this.id,
    required this.nameTr,
    required this.nameEn,
    required this.emoji,
    required this.meaningTr,
    required this.meaningEn,
    required this.length,
    required this.statsTr,
    required this.statsEn,
  });
}
