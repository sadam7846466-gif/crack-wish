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

  /// Bilimsel yorum üretir — detaylı ve derin
  String interpret({
    required DreamInput input,
    required DreamAnalysis analysis,
    List<ClarificationAnswer> answers = const [],
  }) {
    final primaryEmotion = input.emotions.isNotEmpty
        ? input.emotions.first
        : Emotion.calm;
    final dreamText = input.text.toLowerCase();

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

    // Sembol tespiti
    final symbols = <String>[];
    final symbolAnalyses = <String>[];
    _detectAndDescribeSymbols(dreamText, symbols, symbolAnalyses);

    // Duygusal yoğunluk analizi
    final emotionIntensity = _analyzeEmotionIntensity(dreamText, primaryEmotion);

    // Sahne karmaşıklığı
    final sentences = input.text
        .split(RegExp(r'[.!?]+'))
        .where((s) => s.trim().isNotEmpty)
        .length;
    final complexity = sentences > 4 ? 'karmaşık' : (sentences > 2 ? 'orta düzeyde' : 'yoğunlaştırılmış');

    // Bağlam cümleleri
    final settingDesc = clarifiedPast
        ? 'Beyin, geçmişle ilişkili bellekleri yeniden değerlendiriyor ve eski anıları yeni duygusal çerçevelerle işliyor.'
        : 'Zihin, mevcut yaşantıdaki duygusal yükleri ve çözülmemiş sorunları gece boyunca işlemeye devam ediyor.';
    final movementNote = clarifiedMovement
        ? 'Rüyadaki hareketli akış, beyninizin aktif olarak bir çözüm senaryosu simüle ettiğini gösteriyor. Zihin, hareket yoluyla kontrolü yeniden kazanmaya çalışıyor.'
        : 'Daha durağan sahne yapısı, zihnin dengeyi korumaya ve duygusal düzenleme yapmaya odaklandığını düşündürüyor.';
    final threatNote = clarifiedThreat
        ? 'Amigdala kaynaklı tehdit algısı aktif — bu, rüyanızın bir "güvenlik simülasyonu" işlevi gördüğünü düşündürüyor. Beyin, olası tehlikelere karşı hazırlık yapıyor.'
        : 'Belirgin bir tehdit sinyali tespit edilmedi. Rüya daha çok duygusal işleme ve anı konsolidasyonu ile ilgili görünüyor.';

    // Bilinçaltı analizi
    final subconsciousAnalysis = _buildSubconsciousAnalysis(
      dreamText, primaryEmotion, clarifiedThreat, clarifiedPast, clarifiedMovement, symbols,
    );

    // Tavsiye
    final advice = _buildAdvice(primaryEmotion, clarifiedThreat, clarifiedPast, symbols);

    // Sembol bölümü
    final symbolSection = symbols.isNotEmpty
        ? '''
✨ Sembol Haritası
${symbolAnalyses.join('\n')}'''
        : '';

    return '''
🧠 Nörobilimsel Çerçeve
REM uykusunda beyin, duygusal yük taşıyan anıları hikâye formatında işler. Bu sırada prefrontal korteks (mantık merkezi) baskılanır, limbik sistem (duygu merkezi) aktifleşir. Rüyanızda $complexity bir sahne yapısı tespit edildi.
$settingDesc
$movementNote

🔍 Detaylı Rüya Analizi
$threatNote
$emotionIntensity
Rüyadaki sahneler, beynin gece boyunca gerçekleştirdiği duygusal düzenleme sürecinin bir yansımasıdır. Bu süreçte beyin, gündüz bastırılan veya tam olarak işlenemeyen duyguları güvenli bir ortamda yeniden deneyimler.

💭 Bilinçaltı Analizi
$subconsciousAnalysis
$symbolSection

📌 Sonuç ve Tavsiye
$advice''';
  }

  void _detectAndDescribeSymbols(String text, List<String> symbols, List<String> analyses) {
    final symbolDescriptions = {
      'su': MapEntry('Su / Deniz', 'Su sembolleri bilinçaltındaki duygusal derinliği ve bastırılmış hisleri temsil eder. Durgun su iç huzuru, dalgalı su duygusal çalkantıyı simgeler.'),
      'deniz': MapEntry('Su / Deniz', 'Deniz, bilinçaltının enginliğini ve keşfedilmemiş duyguları temsil eder. Derinliklere inmek, bastırılan anılara yüzleşmeyi simgeler.'),
      'uçmak': MapEntry('Uçmak', 'Uçma rüyaları özgürlük arzusu ve mevcut sınırlamalardan kurtulma ihtiyacını yansıtır. Kontrollü uçuş özgüvenin, kontrolsüz uçuş kaygının göstergesidir.'),
      'uçuyordum': MapEntry('Uçmak', 'Uçma deneyimi, bilinçaltının baskılardan kurtulma ve yükselme arzusunu simüle etmesidir.'),
      'düşmek': MapEntry('Düşmek', 'Düşme rüyaları kontrol kaybı korkusu ve güvensizlik hissini yansıtır. Beyin, REM uykusunda kas gevşemesini düşme hissi olarak yorumlayabilir.'),
      'düştüm': MapEntry('Düşmek', 'Düşme deneyimi, hayatınızdaki bir alandaki kontrolsüzlük hissini ve temel güvenlik ihtiyacını yansıtıyor.'),
      'ev': MapEntry('Ev / Mekan', 'Ev sembolü benliğinizi ve iç dünyanızı temsil eder. Farklı odalar, kişiliğinizin farklı yönlerine karşılık gelir. Bilinmeyen odalar, keşfedilmemiş potansiyelinizi simgeler.'),
      'oda': MapEntry('Ev / Mekan', 'Oda, zihnin belirli bir konuya veya duyguya odaklandığı alanı simgeler. Kapalı kapılar bastırılan düşünceleri temsil edebilir.'),
      'araba': MapEntry('Araba / Yolculuk', 'Araba, hayat yolculuğunuzda kontrolü ve yönü temsil eder. Süren siz iseniz kontrol sizdedir; yolcu iseniz başkalarının etkisi altındasınız demektir.'),
      'köpek': MapEntry('Köpek', 'Köpek sembolü sadakat, güven ve koruma ile ilişkilidir. Dostça bir köpek güvenilir ilişkileri, saldırgan bir köpek ihanet korkusunu yansıtır.'),
      'kedi': MapEntry('Kedi', 'Kedi, bağımsızlık, sezgi ve gizemli dişil enerjiyi temsil eder. Bilinçaltındaki bağımsızlık arzusunu ve sezgisel bilgeliği simgeler.'),
      'yılan': MapEntry('Yılan', 'Yılan, dönüşüm, gizli korkular ve bastırılmış dürtüleri temsil eden güçlü bir arketiptir. Deri değiştirme gibi, kişisel bir dönüşüm sürecine işaret edebilir.'),
      'ölüm': MapEntry('Ölüm', 'Ölüm sembolü paradoksal olarak yeniden doğuşu ve dönüşümü simgeler. Eski bir alışkanlığın, ilişkinin veya hayat döneminin sona ermesini ve yeni bir başlangıcı temsil eder.'),
      'öldüm': MapEntry('Ölüm', 'Kendi ölümünüzü görmek, eski benliğinizin bir bölümünün dönüşüm geçirdiğini ve yeni bir kişisel evreye girdiğinizi simgeler.'),
      'bebek': MapEntry('Bebek / Çocuk', 'Bebek, yeni başlangıçları, saflığı ve korunmaya muhtaç projeleri veya fikirleri temsil eder. İçinizdeki çocuğun sesi olabilir.'),
      'çocuk': MapEntry('Bebek / Çocuk', 'Çocuk figürü, masumiyeti ve nostaljik bir döneme olan özlemi simgeler. İç çocuğunuzun ihtiyaçlarına dikkat çekiyor olabilir.'),
      'anne': MapEntry('Anne', 'Anne figürü, şefkat, güvenlik ve koşulsuz sevgi arketipini temsil eder. Bilinçaltınızdaki bakım ve korunma ihtiyacını yansıtır.'),
      'baba': MapEntry('Baba', 'Baba figürü, otorite, rehberlik ve koruma arketipini temsil eder. Hayatınızdaki yönlendirme ve onay ihtiyacını simgeler.'),
      'para': MapEntry('Para / Değer', 'Para, öz değer duygusu ve hayattaki güvenlik ihtiyacını simgeler. Para bulmak gizli potansiyeli, kaybetmek güvensizlik hissini yansıtır.'),
      'altın': MapEntry('Para / Değer', 'Altın, en yüksek değeri ve ruhani zenginliği temsil eder. Bilinçaltınızdaki değer arayışını simgeler.'),
      'ateş': MapEntry('Ateş', 'Ateş, tutku, öfke, dönüşüm ve arınmayı temsil eder. Kontrollü ateş yaratıcı enerjiyi, kontrolsüz ateş bastırılan öfkeyi simgeler.'),
      'diş': MapEntry('Diş', 'Diş kaybetme rüyaları güvensizlik, imaj kaygısı ve kontrol kaybı korkusuyla ilişkilidir. Stres dönemlerinde daha sık görülür.'),
      'kaç': MapEntry('Kaçış', 'Kaçma eylemi, gerçek hayatta kaçınılan bir durumla yüzleşme ihtiyacını simgeler. Beyin, kaçış senaryosunu güvenli ortamda simüle ediyor.'),
      'kovala': MapEntry('Kovalanma', 'Kovalanma rüyaları, bastırılan korkularla yüzleşilmemesinin bir yansımasıdır. Sizi kovalayan şey, kaçındığınız bir duygu veya sorumluluk olabilir.'),
    };

    final usedNames = <String>{};
    for (final entry in symbolDescriptions.entries) {
      if (text.contains(entry.key) && !usedNames.contains(entry.value.key)) {
        usedNames.add(entry.value.key);
        symbols.add(entry.value.key);
        analyses.add('• ${entry.value.key}: ${entry.value.value}');
      }
    }
  }

  String _analyzeEmotionIntensity(String text, Emotion emotion) {
    // Duygu yoğunluğu kelimeleri
    final intensifiers = ['çok', 'aşırı', 'müthiş', 'korkunç', 'dehşet', 'inanılmaz', 'şiddetli', 'yoğun', 'derin'];
    final hasIntensifier = intensifiers.any((w) => text.contains(w));

    switch (emotion) {
      case Emotion.anxiety:
        return hasIntensifier
            ? 'Yüksek düzeyde kaygı sinyalleri tespit edildi. Beyin, belirsizlik kaynaklı stres hormonlarını (kortizol) rüya yoluyla düzenlemeye çalışıyor. Bu tür rüyalar genellikle çözülmemiş günlük endişelerin yansımasıdır.'
            : 'Orta düzeyde kaygı sinyalleri mevcut. Bilinçaltı, gündelik yaşamda tam olarak ifade edilemeyen endişeleri rüya sahneleri aracılığıyla işliyor.';
      case Emotion.fear:
        return hasIntensifier
            ? 'Güçlü korku tepkileri tespit edildi. Amigdala aktif olarak tehdit simülasyonu gerçekleştiriyor. Bu, beynin sizi olası tehlikelere hazırlamak için kullandığı evrimsel bir mekanizmadır.'
            : 'Korku kaynaklı savunma mekanizmaları aktif. Beyin, güvenli rüya ortamında korku tepkilerini deneyimleyerek gerçek hayattaki stres toleransını artırıyor.';
      case Emotion.calm:
        return 'Huzur ve iç denge sinyalleri baskın. Parasempatik sinir sistemi aktif; beyin, olumlu anıları güçlendiriyor ve duygusal dengeyi pekiştiriyor. Bu tür rüyalar iyileşme sürecinin göstergesidir.';
      case Emotion.happiness:
        return 'Pozitif duygu merkezleri aktif. Beyin, dopamin ve serotonin ilişkili anıları işliyor ve bunları uzun vadeli belleğe kaydetmeye çalışıyor. Bu, zihinsel refahın güçlü bir işaretidir.';
      case Emotion.sadness:
        return hasIntensifier
            ? 'Derin üzüntü ve kayıp sinyalleri tespit edildi. Beyin, yaslanmamış duyguları ve işlenmemiş kayıpları rüya yoluyla yeniden deneyimliyor. Bu, iyileşme sürecinin doğal ve gerekli bir parçasıdır.'
            : 'Melankoli ve nostalji sinyalleri mevcut. Bilinçaltı, geçmiş deneyimleri yeniden değerlendiriyor ve duygusal kapanış (closure) arıyor.';
      case Emotion.confusion:
        return 'Bilişsel belirsizlik ve karar verme güçlüğü sinyalleri aktif. Beyin, birden fazla senaryoyu aynı anda simüle ediyor. Bu, hayatınızda netlik gerektiren bir konunun varlığına işaret edebilir.';
      case Emotion.surprise:
        return hasIntensifier
            ? 'Yüksek düzeyde şaşkınlık ve beklenmedik durum sinyalleri tespit edildi. Beyin, uyanık hayattaki yeni ve öngörülemeyen bir duruma rüya yoluyla adapte olmaya çalışıyor.'
            : 'Hafif bir şaşkınlık hissi mevcut. Bilinçaltı, beklentiler ile gerçekleşen olaylar arasındaki uyumsuzlukları keşfediyor ve esneklik kazanmaya çalışıyor.';
    }
  }

  String _buildSubconsciousAnalysis(
    String text, Emotion emotion, bool hasThreat, bool hasPast, bool hasMovement, List<String> symbols,
  ) {
    final parts = <String>[];

    parts.add('Bilinçaltınız bu rüya aracılığıyla size önemli mesajlar gönderiyor:');

    if (hasThreat) {
      parts.add('• Beyin, bir tehdit veya stres kaynağını güvenli ortamda simüle ediyor. Bu, bastırılan korku veya kaygının yüzeye çıkmasıdır. Bilinçaltınız bu durumla yüzleşmenizi istiyor.');
    }

    if (hasPast) {
      parts.add('• Geçmişe dair anılar aktif olarak yeniden işleniyor. Bilinçaltınız, eski deneyimlerden ders çıkarmaya ve tamamlanmamış duygusal süreçleri kapatmaya çalışıyor.');
    }

    if (hasMovement) {
      parts.add('• Hareketli sahneler, bilinçaltınızın aktif olarak bir çözüm veya çıkış yolu aradığını gösteriyor. Zihin, hareketsizliğe boyun eğmeyi reddediyor.');
    }

    switch (emotion) {
      case Emotion.anxiety:
        parts.add('• Kaygı, bilinçaltınızın kontrolsüzlük hissine verdiği bir alarm sinyalidir. Rüyanız, bu kaygının kökenini size göstermeye çalışıyor.');
        break;
      case Emotion.fear:
        parts.add('• Korku tepkisi, bilinçaltınızdaki korunma mekanizmasının aktif olduğunu gösteriyor. Bu rüya, yüzleşilmesi gereken bir korkunun varlığına işaret ediyor.');
        break;
      case Emotion.calm:
        parts.add('• Huzurlu uyandığınız bu rüya, bilinçaltınızın dengede olduğunu ve duygusal iyileşme sürecinin devam ettiğini gösteriyor.');
        break;
      case Emotion.happiness:
        parts.add('• Mutluluk hissi, bilinçaltınızın pozitif anıları projekte ettiğini gösteriyor. Bu, ruhsal sağlığınızın güçlü olduğunun bir kanıtıdır.');
        break;
      case Emotion.sadness:
        parts.add('• Üzüntü, bilinçaltınızın işlenmemiş bir kayıp veya hayal kırıklığıyla uğraştığını gösteriyor. Bu duyguyu bastırmak yerine kabullenmek iyileşme sürecini hızlandırır.');
        break;
      case Emotion.confusion:
        parts.add('• Belirsizlik, bilinçaltınızın birden fazla seçenek arasında kaldığını gösteriyor. Rüyanız, netlik ihtiyacınızı yansıtıyor.');
        break;
      case Emotion.surprise:
        parts.add('• Şaşkınlık, hayatınızdaki öngörülemeyen gelişmelere karşı bilinçaltınızın verdiği doğal bir tepkidir. Rüyanız, beklenmeyene adapte olma sürecinizi yansıtıyor.');
        break;
    }

    if (symbols.isNotEmpty) {
      parts.add('• Rüyanızdaki semboller (${symbols.join(', ')}), bilinçaltınızın size gönderdiği şifreli mesajlardır. Her biri ayrı bir duygusal katmanı temsil ediyor.');
    }

    return parts.join('\n');
  }

  String _buildAdvice(Emotion emotion, bool hasThreat, bool hasPast, List<String> symbols) {
    final advice = <String>[];

    advice.add('Bu rüya, beynin gece boyunca gerçekleştirdiği duygusal düzenleme sürecinin doğal bir parçasıdır.');

    if (hasThreat) {
      advice.add('Rüyanızdaki tehdit unsurları, gerçek hayatta kaçındığınız bir konuyla yüzleşme zamanının geldiğine işaret edebilir. Korkuyu kabullenmek, onu kontrol etmenin ilk adımıdır.');
    }

    if (hasPast) {
      advice.add('Geçmişe dair imgeler, tamamlanmamış bir duygusal sürecin varlığını düşündürüyor. Bu anılarla barışmak, ileri adım atmanızı kolaylaştıracaktır.');
    }

    switch (emotion) {
      case Emotion.anxiety:
        advice.add('Tavsiye: Yatmadan önce 5 dakika derin nefes egzersizi yapın. Kaygı tetikleyicilerinizi bir günlüğe yazarak bilinçli hale getirin. Düzenli rüya kaydı tutmak, bilinçaltınızla daha iyi iletişim kurmanıza yardımcı olacaktır.');
        break;
      case Emotion.fear:
        advice.add('Tavsiye: Korku kaynağını güvenli bir ortamda (terapi, günlük yazma) ifade edin. Lucid rüya tekniklerini deneyerek rüyadaki korkularla bilinçli olarak yüzleşebilirsiniz.');
        break;
      case Emotion.calm:
        advice.add('Tavsiye: Bu huzurlu rüya deneyimini korumak için uyku düzeninizi sürdürün. Yatmadan önce pozitif niyetler belirlemek, olumlu rüya deneyimlerini artırır.');
        break;
      case Emotion.happiness:
        advice.add('Tavsiye: Bu pozitif enerjiyi gün içinde de taşımak için rüyanızdaki mutluluk anını detaylıca yazın ve zor zamanlarda tekrar okuyun.');
        break;
      case Emotion.sadness:
        advice.add('Tavsiye: Üzüntüyü bastırmak yerine hissetmeye izin verin. Rüyanızdaki duyguyu bir mektuba dökün — alıcısı olmak zorunda değil. Bu eylem bilinçaltınıza "seni duyuyorum" mesajı verir.');
        break;
      case Emotion.confusion:
        advice.add('Tavsiye: Karar vermekte zorlandığınız konuyu kağıda yazın. Rüya günlüğü tutarak bilinçaltınızın size verdiği ipuçlarını zamanla daha net görmeye başlayacaksınız.');
        break;
      case Emotion.surprise:
        advice.add('Tavsiye: Beklenmedik olaylara direnç göstermek yerine onları birer keşif fırsatı olarak görün. Hayatınızdaki yeni gelişmeleri esneklikle karşılayın.');
        break;
    }

    return advice.join('\n');
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
