import 'dart:math';
import '../services/storage_service.dart';

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
    return [
      _FortuneTemplate(
        id: 'fortune_01',
        nameTr: 'Yıldız',
        nameEn: 'Star',
        emoji: '🌟',
        meaningTr:
            'Umut ve ilham senden yana. Küçük bir adım, beklediğin kapıyı aralayacak.',
        meaningEn:
            'Hope and inspiration are on your side. A small step will open the door you have been waiting for.',
        length: 'medium',
        statsTr: {
          'Aşk': 'Yükseliş',
          'Kariyer': 'Gelişim',
          'Para': 'İyileşme',
          'Sağlık': 'Mükemmel',
        },
        statsEn: {
          'Love': 'Rise',
          'Career': 'Growth',
          'Money': 'Recovery',
          'Health': 'Excellent',
        },
      ),
      _FortuneTemplate(
        id: 'fortune_02',
        nameTr: 'Ay',
        nameEn: 'Moon',
        emoji: '🌙',
        meaningTr:
            'Sezgilerin yükseliyor. Sakin kal ve iç sesi dinle; ufak bir işaret yolunu gösterecek.',
        meaningEn:
            'Your intuition is rising. Stay calm and listen to your inner voice; a small sign will show the way.',
        length: 'medium',
        statsTr: {
          'Aşk': 'Dengeli',
          'Kariyer': 'Stabil',
          'Para': 'Dikkat',
          'Sağlık': 'İyi',
        },
        statsEn: {
          'Love': 'Balanced',
          'Career': 'Stable',
          'Money': 'Caution',
          'Health': 'Good',
        },
      ),
      _FortuneTemplate(
        id: 'fortune_03',
        nameTr: 'Güneş',
        nameEn: 'Sun',
        emoji: '☀️',
        meaningTr:
            'Başarı ve mutluluk kapıda. Emeklerinin karşılığı geliyor; paylaşmak iyi gelecek.',
        meaningEn:
            'Success and happiness are near. Your efforts will pay off; sharing will feel good.',
        length: 'medium',
        statsTr: {
          'Aşk': 'Yükseliş',
          'Kariyer': 'Yükseliş',
          'Para': 'Artış',
          'Sağlık': 'Mükemmel',
        },
        statsEn: {
          'Love': 'Rise',
          'Career': 'Rise',
          'Money': 'Increase',
          'Health': 'Excellent',
        },
      ),
      _FortuneTemplate(
        id: 'fortune_04',
        nameTr: 'Kader',
        nameEn: 'Destiny',
        emoji: '💫',
        meaningTr:
            'Değişim kapıda, şans senden yana. Cesur davranırsan yeni fırsatlar açılır.',
        meaningEn:
            'Change is near and luck is on your side. Be bold and new opportunities will open.',
        length: 'medium',
        statsTr: {
          'Aşk': 'Olumlu',
          'Kariyer': 'Gelişim',
          'Para': 'İyileşme',
          'Sağlık': 'İyi',
        },
        statsEn: {
          'Love': 'Positive',
          'Career': 'Growth',
          'Money': 'Recovery',
          'Health': 'Good',
        },
      ),
      _FortuneTemplate(
        id: 'fortune_05',
        nameTr: 'Aşk',
        nameEn: 'Love',
        emoji: '❤️',
        meaningTr:
            'Aşkta önemli kararlar yaklaşıyor. Açık bir konuşma rahatlatacak.',
        meaningEn:
            'Important decisions in love are approaching. An honest conversation will bring relief.',
        length: 'short',
        statsTr: {
          'Aşk': 'Yükseliş',
          'Kariyer': 'Stabil',
          'Para': 'Dengeli',
          'Sağlık': 'İyi',
        },
        statsEn: {
          'Love': 'Rise',
          'Career': 'Stable',
          'Money': 'Balanced',
          'Health': 'Good',
        },
      ),
      _FortuneTemplate(
        id: 'fortune_06',
        nameTr: 'Kule',
        nameEn: 'Tower',
        emoji: '⚡',
        meaningTr:
            'Ani değişim ve yeni başlangıç ufukta. Beklenmedik bir haber planlarını tazeler.',
        meaningEn:
            'Sudden change and a new beginning are on the horizon. Unexpected news will refresh your plans.',
        length: 'short',
        statsTr: {
          'Aşk': 'Değişim',
          'Kariyer': 'Dönüşüm',
          'Para': 'Değişken',
          'Sağlık': 'Dikkat',
        },
        statsEn: {
          'Love': 'Change',
          'Career': 'Transformation',
          'Money': 'Volatile',
          'Health': 'Caution',
        },
      ),
      _FortuneTemplate(
        id: 'fortune_07',
        nameTr: 'Büyücü',
        nameEn: 'Magician',
        emoji: '🎭',
        meaningTr:
            'Yaratıcı gücün elinde. Fikirlerini cesurca söyle, destek bulacaksın.',
        meaningEn:
            'Creative power is in your hands. Share your ideas boldly and you will find support.',
        length: 'medium',
        statsTr: {
          'Aşk': 'Olumlu',
          'Kariyer': 'Yükseliş',
          'Para': 'Artış',
          'Sağlık': 'İyi',
        },
        statsEn: {
          'Love': 'Positive',
          'Career': 'Rise',
          'Money': 'Increase',
          'Health': 'Good',
        },
      ),
      _FortuneTemplate(
        id: 'fortune_08',
        nameTr: 'İmparatoriçe',
        nameEn: 'Empress',
        emoji: '👑',
        meaningTr:
            'Bolluk ve bereket zamanı. Küçük dokunuşlar sıcaklık getirir; şükür şansını artırır.',
        meaningEn:
            'It is a time of abundance. Small gestures bring warmth; gratitude increases your luck.',
        length: 'medium',
        statsTr: {
          'Aşk': 'Yükseliş',
          'Kariyer': 'Gelişim',
          'Para': 'Artış',
          'Sağlık': 'Mükemmel',
        },
        statsEn: {
          'Love': 'Rise',
          'Career': 'Growth',
          'Money': 'Increase',
          'Health': 'Excellent',
        },
      ),
      _FortuneTemplate(
        id: 'fortune_09',
        nameTr: 'Adalet',
        nameEn: 'Justice',
        emoji: '⚖️',
        meaningTr:
            'Denge ve doğrulukla ilerle. Mantıkla kalbi dengeleyince eski mesele çözülür.',
        meaningEn:
            'Move forward with balance and honesty. When mind and heart align, an old issue will resolve.',
        length: 'short',
        statsTr: {
          'Aşk': 'Dengeli',
          'Kariyer': 'Stabil',
          'Para': 'Dengeli',
          'Sağlık': 'İyi',
        },
        statsEn: {
          'Love': 'Balanced',
          'Career': 'Stable',
          'Money': 'Balanced',
          'Health': 'Good',
        },
      ),
      _FortuneTemplate(
        id: 'fortune_10',
        nameTr: 'Rahibe',
        nameEn: 'Priestess',
        emoji: '🔮',
        meaningTr:
            'İç bilgelik rehber. Sessiz bir an, net bir içgörü verecek.',
        meaningEn:
            'Inner wisdom is your guide. A quiet moment will bring a clear insight.',
        length: 'short',
        statsTr: {
          'Aşk': 'Dengeli',
          'Kariyer': 'Gelişim',
          'Para': 'Stabil',
          'Sağlık': 'İyi',
        },
        statsEn: {
          'Love': 'Balanced',
          'Career': 'Growth',
          'Money': 'Stable',
          'Health': 'Good',
        },
      ),
      _FortuneTemplate(
        id: 'fortune_11',
        nameTr: 'Şans',
        nameEn: 'Luck',
        emoji: '🍀',
        meaningTr:
            'Talih bugün senden yana. Küçük bir risk sürpriz kazanç getirebilir.',
        meaningEn:
            'Luck is on your side today. A small risk could bring a pleasant surprise.',
        length: 'short',
        statsTr: {
          'Aşk': 'Olumlu',
          'Kariyer': 'Yükseliş',
          'Para': 'Artış',
          'Sağlık': 'İyi',
        },
        statsEn: {
          'Love': 'Positive',
          'Career': 'Rise',
          'Money': 'Increase',
          'Health': 'Good',
        },
      ),
      _FortuneTemplate(
        id: 'fortune_12',
        nameTr: 'Dönüşüm',
        nameEn: 'Transformation',
        emoji: '🦋',
        meaningTr:
            'Güzelleşerek değişiyorsun. Eski bir alışkanlığı bırakmak enerjini tazeler.',
        meaningEn:
            'You are changing beautifully. Letting go of an old habit will refresh your energy.',
        length: 'medium',
        statsTr: {
          'Aşk': 'Gelişim',
          'Kariyer': 'Dönüşüm',
          'Para': 'İyileşme',
          'Sağlık': 'Gelişim',
        },
        statsEn: {
          'Love': 'Growth',
          'Career': 'Transformation',
          'Money': 'Recovery',
          'Health': 'Growth',
        },
      ),
    ];
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

    // Basit deterministik karıştırma
    final seed = DateTime.now().day;
    fortunes.shuffle(Random(seed));

    final unseen = fortunes.where((f) => !seenIds.contains(f.id)).toList();
    List<Fortune> pool;

    if (unseen.isEmpty) {
      await StorageService.clearSeenFortunes();
      pool = fortunes;
    } else {
      pool = unseen;
    }

    final selected = pool[Random().nextInt(pool.length)];

    final luckyNumber = Random().nextInt(99) + 1;
    final colors = languageCode == 'tr'
        ? ['Altın', 'Gümüş', 'Mavi', 'Kırmızı', 'Yeşil', 'Mor', 'Turuncu', 'Pembe']
        : ['Gold', 'Silver', 'Blue', 'Red', 'Green', 'Purple', 'Orange', 'Pink'];
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

  // Çok uzun anlamları kısalt (daha etkili, 2 satır civarı)
  static String _shortenMeaning(String text) {
    const int maxChars = 110; // daha kısa, ~2 satır
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
