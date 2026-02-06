import '../models/dream_analysis.dart';
import '../models/dream_input.dart';
import '../models/emotion.dart';
import '../models/clarification_answer.dart';
import 'gpt_enrichment_service.dart';

/// Rüya analiz ve yorum servisi
/// Bilimsel, REM uykusu temelli, deterministik yaklaşım
class DreamAnalysisService {
  final GptEnrichmentService _gptService = GptEnrichmentService();

  // ─────────────────────────────────────────────────────────────────────────
  // TÜRKÇE KELİME LİSTELERİ
  // ─────────────────────────────────────────────────────────────────────────

  /// Fiil kökleri ve yaygın çekimler
  static const _verbPatterns = [
    // Hareket
    'git', 'gel', 'koş', 'kaç', 'yürü', 'uç', 'atla', 'düş', 'in', 'çık',
    'bin', 'tırman', 'yüz', 'sür', 'takip', 'kovala', 'izle', 'dolaş',
    'gez',
    // Eylem
    'gör', 'bak', 'dinle', 'duy', 'konuş', 'söyle', 'ağla', 'gül', 'bağır',
    'sus', 'bekle', 'dur', 'otur', 'yat', 'uyan', 'kalk', 'tut', 'bırak',
    'aç', 'kapa', 'vur', 'it', 'çek', 'at', 'al', 'ver', 'ye', 'iç',
    'saklan', 'ara', 'bul', 'kaybol', 'kaybet', 'öl', 'doğ', 'uyu',
    // Geçmiş zaman ekleri içeren yaygın formlar
    'gördüm', 'gördü', 'gittim', 'gitti', 'geldi', 'geldim', 'koştum', 'koştu',
    'kaçtım', 'kaçtı', 'düştüm', 'düştü', 'uçtum', 'uçtu', 'yürüdüm', 'yürüdü',
    'kovaladı', 'kovaladım', 'takip etti', 'izledi', 'izledim',
    'dolaştım', 'dolaştı', 'dolaşıyordum', 'dolaşıyordu', 'gezdim', 'gezdi',
    'geziyordum', 'geziyordu',
    'baktım', 'baktı', 'konuştum', 'konuştu', 'ağladım', 'ağladı',
    'vardı', 'vardım', 'oldu', 'oldum', 'çıktım', 'çıktı', 'girdi', 'girdim',
    'bindim', 'bindi', 'atladım', 'atladı', 'yüzdüm', 'yüzdü',
  ];

  /// İsimler: mekan, hayvan, insan, nesne
  static const _nounPatterns = [
    // Mekanlar
    'ev', 'oda', 'sokak', 'cadde', 'yol', 'araba', 'otobüs', 'tren', 'uçak',
    'okul', 'hastane', 'park', 'orman', 'deniz', 'göl', 'dağ', 'tepe',
    'apartman', 'bina', 'köprü', 'merdiven', 'asansör', 'kapı', 'pencere',
    'bahçe', 'tarla', 'plaj', 'havuz', 'nehir', 'gökyüzü', 'bulut',
    // Hayvanlar
    'köpek', 'kedi', 'kuş', 'yılan', 'fare', 'at', 'aslan', 'kaplan', 'ayı',
    'kurt', 'tilki', 'tavşan', 'balık', 'böcek', 'örümcek', 'arı', 'kelebek',
    'köpk', 'kpek', 'kopek', // yazım hataları
    // İnsanlar
    'insan', 'adam', 'kadın', 'çocuk', 'bebek', 'anne', 'baba', 'kardeş',
    'arkadaş', 'sevgili', 'eş', 'koca', 'karı', 'dede', 'nine', 'amca',
    'dayı', 'teyze', 'hala', 'öğretmen', 'doktor', 'polis', 'asker',
    'biri', 'birisi', 'kimse', 'herkes', 'tanıdık', 'yabancı',
    // Nesneler
    'su', 'ateş', 'para', 'altın', 'anahtar', 'telefon', 'silah', 'bıçak',
    'kan', 'yemek', 'ekmek', 'meyve', 'çiçek', 'ağaç', 'taş', 'toprak',
  ];

  /// Rüya bağlamı kelimeleri
  static const _dreamContextPatterns = [
    'rüya',
    'rüyam',
    'rüyamda',
    'rüyada',
    'uyku',
    'uykum',
    'uykumda',
    'gece',
    'gördüm',
    'hayal',
    'kabus',
  ];

  /// Türkçe fiil ekleri (geçmiş, şimdiki, gelecek, rivayet)
  static final _verbSuffixPattern = RegExp(
    r'(dım?|dim?|dum?|düm?|tım?|tim?|tum?|tüm?|'
    r'dı|di|du|dü|tı|ti|tu|tü|'
    r'yor|iyor|uyor|üyor|yordu|yordum|yordun|yorduk|yordunuz|yorlardı|'
    r'mış|miş|muş|müş|'
    r'acak|ecek|cak|cek|'
    r'malı|meli|meliyim|malıyım)$',
  );

  // ─────────────────────────────────────────────────────────────────────────
  // ANALİZ FONKSİYONLARI
  // ─────────────────────────────────────────────────────────────────────────

  /// Minimum sahne kontrolü: sahne + eylem
  bool hasAnalyzableScene(String text) {
    final cleaned = text.toLowerCase().trim();

    // Minimum 10 karakter (daha esnek)
    if (cleaned.length < 10) return false;

    final words = cleaned.split(RegExp(r'\s+'));

    // En az 2 kelime olmalı
    if (words.length < 2) return false;

    // Rüya bağlamı varsa daha esnek ol
    final hasDreamContext = _dreamContextPatterns.any(
      (p) => cleaned.contains(p),
    );

    // Fiil kontrolü
    final hasVerb = _hasVerb(cleaned, words);

    // İsim kontrolü
    final hasNoun = _hasNoun(cleaned);

    // Rüya bağlamı + fiil varsa kabul et
    if (hasDreamContext && hasVerb) return true;

    // Hem fiil hem isim varsa kabul et
    if (hasVerb && hasNoun) return true;

    // Fiil varsa kısa/eksik cümleleri de kabul et
    if (hasVerb && words.length >= 2) return true;

    return false;
  }

  bool _hasVerb(String text, List<String> words) {
    // Doğrudan fiil kalıbı kontrolü
    if (_verbPatterns.any((v) => text.contains(v))) return true;

    // Fiil eki kontrolü (her kelimede)
    for (final word in words) {
      if (word.length >= 4 && _verbSuffixPattern.hasMatch(word)) {
        return true;
      }
    }

    return false;
  }

  bool _hasNoun(String text) {
    return _nounPatterns.any((n) => text.contains(n));
  }

  /// Geriye dönük kullanım için
  bool isAnalyzable(String text) => hasAnalyzableScene(text);

  /// Rüya metnini bilişsel sinyaller için analiz eder
  DreamAnalysis analyzeDream(String text) {
    final lower = text.toLowerCase();
    final sentences = text
        .split(RegExp(r'[.!?]+'))
        .where((s) => s.trim().isNotEmpty)
        .length;

    return DreamAnalysis(
      hasThreat: _hasThreatSignal(lower),
      hasPastReference: _hasPastSignal(lower),
      hasMovement: _hasMovementSignal(lower),
      isSingleScene: sentences <= 2,
    );
  }

  bool _hasThreatSignal(String text) {
    const patterns = [
      'kaza',
      'ölüm',
      'öldü',
      'öldüm',
      'korku',
      'kork',
      'tehdit',
      'tehlike',
      'kaç',
      'kovala',
      'saldır',
      'vur',
      'bıçak',
      'silah',
      'kan',
      'yaralandım',
      'düşman',
      'canavar',
      'kurt',
      'yılan',
      'boğ',
      'nefes alamadım',
      'takip',
      'izledi',
      'peşimde',
      'yakaladı',
      'tuttu',
      'kabus',
    ];
    return patterns.any((p) => text.contains(p));
  }

  bool _hasPastSignal(String text) {
    const patterns = [
      'eski',
      'önceden',
      'çocukluk',
      'çocukken',
      'küçükken',
      'geçmiş',
      'yıllar önce',
      'eskiden',
      'o zaman',
      'zamanında',
      'annem',
      'babam',
      'büyükannem',
      'dedem',
      'nine',
      'eski ev',
      'eski okul',
    ];
    return patterns.any((p) => text.contains(p));
  }

  bool _hasMovementSignal(String text) {
    const patterns = [
      'koş',
      'git',
      'gel',
      'kaç',
      'düş',
      'uç',
      'yürü',
      'atla',
      'tırman',
      'in',
      'çık',
      'bin',
      'yüz',
      'sür',
      'takip',
      'kovala',
      'izle',
      'peşinden',
      'dolaş',
      'gez',
    ];
    return patterns.any((p) => text.contains(p));
  }

  DreamAnalysis analyzeDreamText(String text) => analyzeDream(text);

  /// Soru motoru (deterministik)
  String? decideQuestion(DreamAnalysis analysis) {
    if (analysis.hasThreat) {
      return 'Rüyada tehdit ya da korku hissi var mıydı?';
    }
    if (analysis.hasPastReference) {
      return 'Bu sahne sana geçmişten tanıdık mıydı?';
    }
    return null;
  }

  /// Bilimsel yorum üretir
  String interpret({
    required DreamInput input,
    required DreamAnalysis analysis,
    List<ClarificationAnswer> answers = const [],
  }) {
    final primaryEmotion = input.emotions.isNotEmpty
        ? input.emotions.first
        : Emotion.calm;

    final clarifiedThreat = _resolveClarification(
      'threat',
      analysis.hasThreat,
      answers,
    );
    final clarifiedPast = _resolveClarification(
      'past',
      analysis.hasPastReference,
      answers,
    );
    final clarifiedMovement = _resolveClarification(
      'movement',
      analysis.hasMovement,
      answers,
    );

    final settingDescription = clarifiedPast
        ? 'geçmişle ilişkili bellekleri yeniden değerlendirdiğini'
        : 'mevcut zihinsel durumları işlediğini';
    final movementNote = clarifiedMovement
        ? 'Hareketli akış, zihnin bir çözüm arayışını simüle ettiğini gösterir.'
        : 'Daha durağan akış, zihnin dengeyi korumaya çalıştığını gösterir.';
    final threatDescription = clarifiedThreat
        ? 'bir tehdit algısıyla ilişkili'
        : 'duygusal bir iç değerlendirme';

    return '''
🧠 Nörobilimsel Çerçeve
REM uykusunda beyin, duygusal yük taşıyan anıları hikâye formatında işler.
Bu sırada mantık merkezleri baskılanır, duygu merkezleri aktiftir.

🔍 Bilişsel Okuma
Bu rüyada görülen sahneler, beynin $settingDescription düşündürüyor.
$movementNote

👤 Kişisel Bağ
Uyandığında seçtiğin duygu (${primaryEmotion.label}),
bu rüyanın $threatDescription olduğunu gösterir.

📌 Dengeli Sonuç
Bu rüya büyük ihtimalle gelecekle değil,
son dönemde yaşanan veya bastırılan bir durumla bağlantılıdır.
''';
  }

  /// GPT yalnızca metni zenginleştirir, karar vermez.
  Future<String> enrichWithGpt({
    required String baseText,
    required DreamAnalysis analysis,
    required Emotion emotion,
  }) async {
    return _gptService.enrich(
      baseText: baseText,
      analysis: analysis,
      emotion: emotion,
    );
  }

  bool get canEnrich => _gptService.isConfigured;

  bool _resolveClarification(
    String id,
    bool baseValue,
    List<ClarificationAnswer> answers,
  ) {
    for (final answer in answers) {
      if (answer.questionId != id) continue;
      if (answer.answer == 'yes') return true;
      if (answer.answer == 'no') return false;
    }
    return baseValue;
  }
}
