// lib/screens/tarot_meanings.dart
// 22 Büyük Arkana kartının anlamları ve yorum motoru

import 'dart:math';

/// Kart sembolü — kartın içindeki görsel öğeler + anchor koordinatları
class CardSymbol {
  final String emoji;
  final String nameTr;
  final String nameEn;
  final List<String> meaningsTr;
  final List<String> meaningsEn;
  /// Sembolün kart üzerindeki konumu (0.0 - 1.0 oransal)
  final double anchorX;
  final double anchorY;

  const CardSymbol({
    required this.emoji,
    required this.nameTr,
    required this.nameEn,
    required this.meaningsTr,
    required this.meaningsEn,
    this.anchorX = 0.5,
    this.anchorY = 0.5,
  });

  /// Rastgele bir anlam seçer (seed ile tekrarlanabilir)
  String meaningTr([Random? rng]) => meaningsTr[(rng ?? Random()).nextInt(meaningsTr.length)];
  String meaningEn([Random? rng]) => meaningsEn[(rng ?? Random()).nextInt(meaningsEn.length)];
}

/// Pozisyona göre kaç sembol gösterileceğini belirler (3-7)
int getSymbolCountForPosition(int positionIndex, int availableSymbols) {
  if (availableSymbols <= 4) return availableSymbols;
  const positionBase = [3, 6, 4, 4, 4, 5, 6]; // Geçmiş,Şimdi,Gizli,Engel,Çevre,Tavsiye,Sonuç
  final base = positionIndex < positionBase.length ? positionBase[positionIndex] : 4;
  return base.clamp(3, availableSymbols.clamp(3, 7));
}

/// Kart sembollerine otomatik anchor pozisyonları atar (sol-sağ dağılımlı)
List<CardSymbol> _withAnchors(List<CardSymbol> symbols, List<List<double>> anchors) {
  final result = <CardSymbol>[];
  for (int i = 0; i < symbols.length; i++) {
    final a = i < anchors.length ? anchors[i] : [0.5, 0.3 + i * 0.1];
    result.add(CardSymbol(
      emoji: symbols[i].emoji,
      nameTr: symbols[i].nameTr,
      nameEn: symbols[i].nameEn,
      meaningsTr: symbols[i].meaningsTr,
      meaningsEn: symbols[i].meaningsEn,
      anchorX: a[0],
      anchorY: a[1],
    ));
  }
  return result;
}

/// 78 kart için anchor koordinatları (cardId → [[x,y], ...])
const Map<int, List<List<double>>> _cardAnchors = {
  // ── MAJOR ARCANA ── (sıra = sembol sırası ile eşleşir)
  // 0-Fool: Köpek→Dog, Uçurum→Cliff, Heybe→Wand, Güneş→Sun
  0: [[0.58,0.55],[0.55,0.60],[0.48,0.45],[0.50,0.20]],
  // 1-Magician: Sonsuzluk→Infinity, DörtElement→Table, Asa→RaisedWand
  1: [[0.50,0.25],[0.50,0.72],[0.38,0.18]],
  // 2-HighPriestess: Yıldızlar→background, Sütunlar→BlackPillar, HilalAy→Crescent, Parşömen→Scroll
  2: [[0.35,0.20],[0.28,0.50],[0.50,0.82],[0.58,0.45]],
  // 3-Empress: Taç→Crown, Buğday→Wheat, Nar→Pomegranate, Venüs→Shield
  3: [[0.50,0.26],[0.25,0.45],[0.25,0.85],[0.65,0.55]],
  // 4-Emperor: TaşTaht→StoneThrone, KoçBaşları→LeftRam, KırmızıCüppe→Emperor, Dağlar→Mountains
  4: [[0.50,0.28],[0.30,0.60],[0.50,0.55],[0.28,0.45]],
  // 5-Hierophant: ÜçlüTaç→TripleCrown, Müritler→Disciples, Asa→Staff
  5: [[0.50,0.32],[0.65,0.85],[0.38,0.32]],
  // 6-Lovers: Melek→Angel, BilgiAğacı→Left Tree, Adem/Havva→Lovers, Yılan→Snake, AltınYol→Path
  6: [[0.50,0.32],[0.25,0.55],[0.50,0.65],[0.32,0.48],[0.50,0.85]],
  // 7-Chariot: İkiSfenks→BlackSphinx, YıldızÖrtüsü→StarCanopy, Zırh→Charioteer
  7: [[0.35,0.68],[0.50,0.15],[0.50,0.35]],
  // 8-Strength: Aslan→Lion, Sonsuzluk→Infinity, Çiçekler→LeftFlowers
  8: [[0.55,0.50],[0.50,0.15],[0.35,0.76]],
  // 9-Hermit: Fener→Lantern, Asa→Staff, DağZirvesi→Peak
  9: [[0.42,0.35],[0.50,0.45],[0.50,0.65]],
  // 10-Wheel: Çark→Wheel, Sfenks→Sphinx, Yılan→Snake
  10: [[0.50,0.50],[0.50,0.18],[0.28,0.55]],
  // 11-Justice: Terazi→Scales, Kılıç→Sword, Ay→Moon
  11: [[0.62,0.60],[0.38,0.45],[0.50,0.20]],
  // 12-HangedMan: TersDuruş→HangedMan, Hale→Halo, DünyaAğacı→Tree
  12: [[0.50,0.55],[0.50,0.75],[0.25,0.50]],
  // 13-Death: BeyazAt→WhiteHorse, DoğanGüneş→RisingSun, SiyahBayrak→Banner, DizÇökenler→Figures
  13: [[0.45,0.42],[0.65,0.48],[0.60,0.22],[0.30,0.72]],
  // 14-Temperance: İkiKupa→LeftCup, MelekKanatları→Wings, Nehir→River, Güneş→Sun
  14: [[0.58,0.44],[0.30,0.50],[0.58,0.72],[0.50,0.22]],
  // 15-Devil: Şeytan→Devil, Pentagram→Pentagram, Zincir→Chain, Figürler→Figures
  15: [[0.50,0.50],[0.50,0.18],[0.50,0.85],[0.75,0.80]],
  // 16-Tower: Yıldırım→Lightning, DüşenTaç→FallingCrown, Alevler→Flames
  16: [[0.60,0.25],[0.42,0.20],[0.50,0.80]],
  // 17-Star: Yıldız→Star, Su→Water, Figür→Figure
  17: [[0.50,0.18],[0.45,0.85],[0.58,0.55]],
  // 18-Moon: Ay→Moon, İkiKule→LeftTower, Kurt→Wolf, Nehir→River
  18: [[0.50,0.20],[0.28,0.45],[0.36,0.68],[0.50,0.85]],
  // 19-Sun: ParlayanGüneş→Sun, Çocuk→Child, Ayçiçekleri→SunflowersL, BeyazAt→Horse
  19: [[0.50,0.25],[0.55,0.55],[0.25,0.42],[0.50,0.75]],
  // 20-Judgement: Boru→Trumpet, Cebrail→Gabriel, Uyananlar→Awakened, Mezarlar→Graves
  20: [[0.38,0.32],[0.50,0.18],[0.35,0.68],[0.70,0.80]],
  // 21-World: Dansçı→Dancer, Çelenk→Wreath, Melek, Kartal, Boğa, Aslan
  21: [[0.50,0.50],[0.72,0.50],[0.28,0.15],[0.72,0.15],[0.25,0.85],[0.72,0.85]],
  // ── CUPS ──
  22: [[0.50,0.55],[0.50,0.15],[0.50,0.85],[0.65,0.68],[0.32,0.15]],
  23: [[0.25,0.65],[0.75,0.65],[0.40,0.62],[0.60,0.62],[0.50,0.32],[0.50,0.50]],
  24: [[0.30,0.60],[0.50,0.58],[0.70,0.60],[0.50,0.35],[0.50,0.90],[0.50,0.18]],
  25: [[0.35,0.65],[0.28,0.35],[0.60,0.50],[0.68,0.55],[0.68,0.82]],
  26: [[0.50,0.48],[0.38,0.82],[0.50,0.92],[0.68,0.65],[0.30,0.54],[0.65,0.20]],
  27: [[0.42,0.65],[0.58,0.65],[0.25,0.75],[0.50,0.22],[0.32,0.48],[0.65,0.55]],
  28: [[0.50,0.70],[0.72,0.35],[0.30,0.60],[0.50,0.38],[0.65,0.50],[0.28,0.35],[0.50,0.15]],
  29: [[0.35,0.65],[0.65,0.72],[0.50,0.22],[0.62,0.35],[0.32,0.50],[0.55,0.65]],
  30: [[0.50,0.60],[0.30,0.45],[0.65,0.60],[0.40,0.12]],
  31: [[0.50,0.55],[0.32,0.68],[0.50,0.20],[0.50,0.28],[0.72,0.52],[0.50,0.90]],
  32: [[0.62,0.52],[0.45,0.52],[0.45,0.45],[0.50,0.18],[0.30,0.80]],
  33: [[0.50,0.45],[0.50,0.65],[0.60,0.32],[0.35,0.45],[0.50,0.85]],
  34: [[0.50,0.45],[0.60,0.42],[0.35,0.65],[0.50,0.18],[0.50,0.88]],
  35: [[0.45,0.45],[0.65,0.45],[0.38,0.65],[0.50,0.88],[0.75,0.70],[0.50,0.85]],
  // ── WANDS ──
  36: [[0.50,0.60],[0.50,0.35],[0.42,0.28],[0.70,0.82],[0.25,0.45]],
  37: [[0.60,0.50],[0.68,0.35],[0.48,0.42],[0.45,0.75],[0.35,0.55]],
  38: [[0.62,0.50],[0.72,0.35],[0.35,0.55],[0.45,0.45]],
  39: [[0.28,0.45],[0.50,0.35],[0.50,0.70],[0.68,0.60],[0.50,0.55]],
  40: [[0.50,0.68],[0.50,0.50],[0.50,0.42]],
  41: [[0.50,0.45],[0.55,0.60],[0.42,0.35],[0.45,0.25],[0.72,0.70]],
  42: [[0.50,0.50],[0.62,0.45],[0.32,0.65],[0.45,0.32]],
  43: [[0.50,0.50],[0.25,0.75],[0.50,0.85]],
  44: [[0.50,0.45],[0.62,0.50],[0.22,0.55],[0.62,0.35]],
  45: [[0.50,0.65],[0.45,0.45],[0.65,0.62],[0.65,0.72]],
  46: [[0.55,0.62],[0.45,0.35],[0.52,0.58],[0.72,0.75]],
  47: [[0.55,0.45],[0.45,0.68],[0.62,0.22],[0.62,0.50],[0.35,0.85]],
  48: [[0.50,0.45],[0.62,0.45],[0.72,0.45],[0.38,0.52],[0.48,0.80],[0.50,0.18]],
  49: [[0.50,0.45],[0.68,0.45],[0.32,0.60],[0.45,0.85],[0.50,0.20]],
  // ── SWORDS ──
  50: [[0.50,0.65],[0.50,0.45],[0.50,0.15],[0.40,0.25],[0.50,0.85]],
  51: [[0.50,0.45],[0.65,0.35],[0.50,0.18],[0.75,0.65]],
  52: [[0.50,0.50],[0.65,0.30],[0.72,0.45],[0.50,0.12],[0.30,0.16]],
  53: [[0.52,0.64],[0.65,0.30],[0.55,0.92],[0.32,0.30]],
  54: [[0.50,0.65],[0.35,0.50],[0.40,0.88],[0.72,0.68],[0.50,0.18]],
  55: [[0.40,0.60],[0.58,0.65],[0.50,0.75],[0.65,0.62],[0.50,0.20],[0.60,0.12]],
  56: [[0.65,0.65],[0.68,0.55],[0.32,0.72],[0.30,0.62],[0.45,0.68],[0.50,0.22]],
  57: [[0.50,0.60],[0.68,0.70],[0.50,0.15],[0.72,0.45]],
  58: [[0.45,0.55],[0.35,0.28],[0.48,0.85],[0.75,0.28]],
  59: [[0.50,0.78],[0.48,0.65],[0.48,0.58],[0.70,0.45]],
  60: [[0.52,0.60],[0.45,0.40],[0.50,0.20],[0.65,0.50],[0.32,0.78]],
  61: [[0.55,0.45],[0.65,0.62],[0.38,0.25],[0.62,0.25],[0.35,0.45]],
  62: [[0.50,0.50],[0.50,0.25],[0.35,0.35],[0.68,0.45],[0.75,0.35],[0.38,0.60],[0.65,0.18]],
  63: [[0.50,0.45],[0.50,0.25],[0.32,0.38],[0.68,0.65],[0.35,0.60],[0.32,0.70],[0.50,0.15]],
  // ── PENTACLES ──
  64: [[0.50,0.35],[0.50,0.22],[0.50,0.62],[0.50,0.85],[0.25,0.75]],
  65: [[0.50,0.60],[0.38,0.48],[0.65,0.40],[0.50,0.52],[0.30,0.65],[0.72,0.50]],
  66: [[0.35,0.72],[0.65,0.72],[0.50,0.18],[0.50,0.40],[0.50,0.55]],
  67: [[0.50,0.65],[0.50,0.35],[0.50,0.55],[0.40,0.88],[0.50,0.15]],
  68: [[0.45,0.65],[0.65,0.62],[0.50,0.32],[0.50,0.42],[0.25,0.85]],
  69: [[0.50,0.45],[0.40,0.50],[0.62,0.55],[0.70,0.65],[0.30,0.65]],
  70: [[0.40,0.50],[0.75,0.60],[0.60,0.48],[0.50,0.20]],
  71: [[0.45,0.55],[0.55,0.55],[0.70,0.45],[0.35,0.65]],
  72: [[0.50,0.55],[0.68,0.35],[0.28,0.65],[0.32,0.60],[0.50,0.12]],
  73: [[0.50,0.72],[0.75,0.40],[0.35,0.45],[0.50,0.56],[0.70,0.85]],
  74: [[0.50,0.55],[0.40,0.30],[0.25,0.75],[0.68,0.70],[0.50,0.20]],
  75: [[0.55,0.45],[0.50,0.60],[0.45,0.38],[0.50,0.22],[0.50,0.85]],
  76: [[0.50,0.45],[0.50,0.48],[0.40,0.78],[0.62,0.78],[0.25,0.20],[0.30,0.50]],
  77: [[0.50,0.45],[0.60,0.52],[0.32,0.40],[0.32,0.65],[0.26,0.58],[0.72,0.45],[0.50,0.20]],
};

/// Kartın içindeki sembolleri ve anlamlarını döndürür
List<CardSymbol> getCardSymbols(int cardId) {
  const majorSymbols = <int, List<CardSymbol>>{
    0: [ // The Fool
      CardSymbol(emoji: '🐕', nameTr: 'Köpek', nameEn: 'Dog', meaningsTr: ['Koruyan içgüdülerin', 'İçindeki sadık rehber', 'Seni koruyan iç ses'], meaningsEn: ['Your protective instincts']),
      CardSymbol(emoji: '🏔️', nameTr: 'Uçurum', nameEn: 'Cliff', meaningsTr: ['Bilinmeyene cesaretin', 'Atılgan ruhunun çağrısı', 'Risk alan kalbin'], meaningsEn: ['Courage to leap into unknown']),
      CardSymbol(emoji: '🎒', nameTr: 'Heybe', nameEn: 'Pouch', meaningsTr: ['Taşıdığın gizli güç', 'Taşıdığın güç yeter', 'İhtiyacın olan sende saklı'], meaningsEn: ['Everything is already within']),
      CardSymbol(emoji: '☀️', nameTr: 'Güneş', nameEn: 'Sun', meaningsTr: ['Yolunu aydınlatan ruh', 'İlahi korunma altındasın', 'Aydınlık yeni başlangıç'], meaningsEn: ['Spirit illuminating your path']),
    ],
    1: [ // The Magician
      CardSymbol(emoji: '♾️', nameTr: 'Sonsuzluk', nameEn: 'Infinity', meaningsTr: ['Sınırsız potansiyelin', 'Yaratma gücün sınırsız', 'Henüz keşfetmediğin güç'], meaningsEn: ['Unlimited potential']),
      CardSymbol(emoji: '🏺', nameTr: 'Elementler', nameEn: 'Elements', meaningsTr: ['Tüm araçlar elinde', 'Yaratmak için her şeyin var', 'Eksik sandığın şey elinde'], meaningsEn: ['All tools in your hands']),
      CardSymbol(emoji: '🪄', nameTr: 'Asa', nameEn: 'Wand', meaningsTr: ['İlahi enerji kanalın', 'Evrenle bağlantın güçlü', 'Gökten gelen güç akıyor'], meaningsEn: ['Channeling divine energy']),
    ],
    2: [ // The High Priestess
      CardSymbol(emoji: '⭐', nameTr: 'Yıldızlar', nameEn: 'Stars', meaningsTr: ['Kozmik sırların rehberi', 'Sonsuz potansiyelin', 'Evrenin yol göstericiliği'], meaningsEn: ['Guide of cosmic secrets']),
      CardSymbol(emoji: '🏛️', nameTr: 'Sütunlar', nameEn: 'Pillars', meaningsTr: ['Aydınlık-karanlık dengesi', 'İki dünya arasında duruyorsun', 'Denge noktanı bul'], meaningsEn: ['Dark and light balance']),
      CardSymbol(emoji: '🌙', nameTr: 'Ay', nameEn: 'Moon', meaningsTr: ['Doruk noktadaki sezgi gücün', 'İç sesin hiç bu kadar net olmadı', 'Hissettiğine güven'], meaningsEn: ['Your intuition peaks']),
      CardSymbol(emoji: '📜', nameTr: 'Parşömen', nameEn: 'Scroll', meaningsTr: ['Açılmamış sırlar', 'Zamanı gelen bilgi', 'Henüz görünmeyen cevaplar'], meaningsEn: ['Secrets not yet revealed']),
    ],
    3: [ // The Empress
      CardSymbol(emoji: '👑', nameTr: 'Taç', nameEn: 'Crown', meaningsTr: ['Kozmik annelik enerjin', 'Besleyen gücün uyanıyor', 'Şefkatin dünyayı değiştirir'], meaningsEn: ['Your cosmic mothering energy']),
      CardSymbol(emoji: '🌾', nameTr: 'Buğday', nameEn: 'Wheat', meaningsTr: ['Şefkatinin hasadı', 'Geri dönen sevgin', 'Geri dönen emeklerin'], meaningsEn: ['Harvest of compassion']),
      CardSymbol(emoji: '🍇', nameTr: 'Nar', nameEn: 'Pomegranate', meaningsTr: ['Yaratıcılığının meyvesi', 'Seninle olan bolluk', 'Çiçek açan üretkenliğin'], meaningsEn: ['Your creativity bears fruit']),
      CardSymbol(emoji: '🛡️', nameTr: 'Venüs Kalkanı', nameEn: 'Venus Shield', meaningsTr: ['Sevgi en güçlü kalkanın', 'Kucaklanan dişil enerjin', 'Koruyan zarafetin'], meaningsEn: ['Love is your strongest shield']),
    ],
    4: [ // The Emperor
      CardSymbol(emoji: '🪨', nameTr: 'Taht', nameEn: 'Throne', meaningsTr: ['Otoriten sağlam zeminde', 'Liderliğin doğuştan', 'Sözün güç taşıyor'], meaningsEn: ['Your authority on solid ground']),
      CardSymbol(emoji: '🐏', nameTr: 'Koç', nameEn: 'Ram', meaningsTr: ['Engelleri kıran iraden', 'Önüne çıkanı aşarsın', 'Kararlılığın dağları eritir'], meaningsEn: ['Your will that breaks barriers']),
      CardSymbol(emoji: '🔴', nameTr: 'Cüppe', nameEn: 'Robe', meaningsTr: ['Tutkuyla yönetim gücün', 'Kalpten gelen liderliğin', 'Birleşen güç ve sevgin'], meaningsEn: ['Your power of ruling with passion']),
      CardSymbol(emoji: '🏔️', nameTr: 'Dağlar', nameEn: 'Mountains', meaningsTr: ['Liderliğin yalnız zirvesi', 'Zirvede tek başına durursun', 'Güç sorumluluk getirir'], meaningsEn: ['Leadership needs solitude']),
    ],
    5: [ // The Hierophant
      CardSymbol(emoji: '⛪', nameTr: 'Taç', nameEn: 'Crown', meaningsTr: ['Bilinç köprüsü', 'Maddi-manevi bağlantın', 'İçsel bilgeliğin tacı'], meaningsEn: ['Bridge of consciousness']),
      CardSymbol(emoji: '👥', nameTr: 'Müritler', nameEn: 'Disciples', meaningsTr: ['Öğrenmeye açık kalbin', 'Bilgeliği arayan ruhun', 'Dinlenen rehberliğin'], meaningsEn: ['Your heart open to logic']),
      CardSymbol(emoji: '🪄', nameTr: 'Asa', nameEn: 'Staff', meaningsTr: ['Manevi otoriten', 'İnancının gücü', 'Kutsal bağlantın'], meaningsEn: ['Your spiritual authority']),
    ],
    6: [ // The Lovers
      CardSymbol(emoji: '👼', nameTr: 'Melek', nameEn: 'Angel', meaningsTr: ['Üst bilinç desteğin', 'Evren aşkını onaylıyor', 'Doğru yolda olduğunun işareti'], meaningsEn: ['Higher mind supports']),
      CardSymbol(emoji: '🌳', nameTr: 'Bilgi Ağacı', nameEn: 'Tree of Knowledge', meaningsTr: ['Doğru ile arzu arası', 'Kalbinle aklın yarışıyor', 'Seçim zamanı geldi'], meaningsEn: ['Between right and desire']),
      CardSymbol(emoji: '🚻', nameTr: 'Adem ve Havva', nameEn: 'Adam & Eve', meaningsTr: ['Ruh eşinle bütünleşme', 'İki zıt kutbun uyumu', 'Seçimini kalbinle yap'], meaningsEn: ['Union with soulmate']),
      CardSymbol(emoji: '🐍', nameTr: 'Yılan', nameEn: 'Snake', meaningsTr: ['Tutkularının fısıltısı', 'Seni kışkırtan dürtü', 'Dönüşüm kapıda'], meaningsEn: ['Whispers of passion']),
      CardSymbol(emoji: '🌊', nameTr: 'Nehir', nameEn: 'River', meaningsTr: ['Birlikte akacağınız hayat', 'Aşkın çağlayan gücü', 'Duyguların sonsuz akışı'], meaningsEn: ['Life flowing together']),
    ],
    7: [ // The Chariot
      CardSymbol(emoji: '🐱', nameTr: 'Sfenks', nameEn: 'Sphinx', meaningsTr: ['Zıt güçlerin kontrolü', 'Kaos içinde denge bul', 'İç çatışmanı yönet'], meaningsEn: ['Control opposing forces']),
      CardSymbol(emoji: '⭐', nameTr: 'Yıldız', nameEn: 'Stars', meaningsTr: ['Evrenin sana rehberliği', 'Sana bakan yıldızlar', 'Seni çağıran kaderin'], meaningsEn: ['Universe guides you']),
      CardSymbol(emoji: '🛡️', nameTr: 'Zırh', nameEn: 'Armor', meaningsTr: ['İradeyle korunman', 'Kararların kalkanın', 'Güçlü irade güçlü koruma'], meaningsEn: ['Shielded by willpower']),
    ],
    8: [ // Strength
      CardSymbol(emoji: '🦁', nameTr: 'Aslan', nameEn: 'Lion', meaningsTr: ['Ehlileşecek tutkuların', 'Gücün yumuşaklıkta saklı', 'Kontrol sevgiyle gelir'], meaningsEn: ['Passions to be tamed']),
      CardSymbol(emoji: '♾️', nameTr: 'Sonsuzluk', nameEn: 'Infinity', meaningsTr: ['Barışla gelen zafer', 'Savaşmadan kazanırsın', 'Sabrın en büyük silahın'], meaningsEn: ['Victory through peace']),
      CardSymbol(emoji: '🌸', nameTr: 'Çiçekler', nameEn: 'Flowers', meaningsTr: ['Sevgiden gelen güç', 'Naziklik en büyük güçtür', 'Zarafetle fethedeceksin'], meaningsEn: ['Strength in softness']),
    ],
    9: [ // The Hermit
      CardSymbol(emoji: '🏮', nameTr: 'Fener', nameEn: 'Lantern', meaningsTr: ['İçindeki gizli gerçek', 'İçindeki cevaplar', 'Sessizlikteki bilgeliğin'], meaningsEn: ['Seek truth within']),
      CardSymbol(emoji: '🪵', nameTr: 'Asa', nameEn: 'Staff', meaningsTr: ['Deneyimden gelen güç', 'Seni bilge yapan deneyimlerin', 'Her adım bir ders'], meaningsEn: ['Experience gives power']),
      CardSymbol(emoji: '⛰️', nameTr: 'Zirve', nameEn: 'Peak', meaningsTr: ['Yalnızlıktaki cevaplar', 'Kalabalıktan uzaklaş', 'Sessizlik konuşur'], meaningsEn: ['Answers in solitude']),
    ],
    10: [ // Wheel of Fortune
      CardSymbol(emoji: '☸️', nameTr: 'Çark', nameEn: 'Wheel', meaningsTr: ['Her iniş çıkışın haberi', 'Döngü hep dönüyor', 'Bugün düşüş yarın yükseliş'], meaningsEn: ['Every fall heralds a rise']),
      CardSymbol(emoji: '📖', nameTr: 'Sfenks', nameEn: 'Sphinx', meaningsTr: ['Merkezde kalma bilgeliği', 'Fırtınanın gözünde kal', 'Dengeni koru'], meaningsEn: ['Know to stay centered']),
      CardSymbol(emoji: '🐍', nameTr: 'Yılan', nameEn: 'Snake', meaningsTr: ['Değişime direnmenin bedeli', 'Akışa bırak kendini', 'Direnme dönüş'], meaningsEn: ['Resisting change pulls you down']),
    ],
    11: [ // Justice
      CardSymbol(emoji: '⚖️', nameTr: 'Terazi', nameEn: 'Scales', meaningsTr: ['Tarttılan eylemlerin', 'Hesap zamanı', 'Değerlendirilen geçmişin'], meaningsEn: ['Actions being weighed']),
      CardSymbol(emoji: '⚔️', nameTr: 'Kılıç', nameEn: 'Sword', meaningsTr: ['İki yönlü keskin gerçek', 'Doğruluk acıtabilir', 'Hakikat kaçınılmaz'], meaningsEn: ['Truth cuts both ways']),
      CardSymbol(emoji: '🌙', nameTr: 'Ay', nameEn: 'Moon', meaningsTr: ['İlahi adalet şaşmaz', 'Evrensel denge sağlanıyor', 'Sezgilerine güven'], meaningsEn: ['Divine justice prevails']),
    ],
    12: [ // The Hanged Man
      CardSymbol(emoji: '🙃', nameTr: 'Duruş', nameEn: 'Pose', meaningsTr: ['Ters bakışın açtığı kapı', 'Bakış açını değiştir', 'Farklı duruş farklı sonuç'], meaningsEn: ['Upside down reveals']),
      CardSymbol(emoji: '💫', nameTr: 'Hale', nameEn: 'Halo', meaningsTr: ['Teslimiyetle uyanış', 'Kazandıran teslimiyetin', 'Bırakılan kontrol yanılsaman'], meaningsEn: ['Awakening via surrender']),
      CardSymbol(emoji: '🌳', nameTr: 'Ağaç', nameEn: 'Tree', meaningsTr: ['Farklı yoldan büyüme', 'Alışılmadık çözümler bul', 'Kuralları yeniden yaz'], meaningsEn: ['Growth the unusual way']),
    ],
    13: [ // Death
      CardSymbol(emoji: '🐴', nameTr: 'At', nameEn: 'Horse', meaningsTr: ['Güçlü gelen dönüşüm', 'Kaçınılmaz değişimin', 'Eski sen gidiyor'], meaningsEn: ['Change comes with force']),
      CardSymbol(emoji: '🌅', nameTr: 'Güneş', nameEn: 'Sun', meaningsTr: ['Her son yeni başlangıç', 'Doğuş olan bitişin', 'Açılan yeni yolların'], meaningsEn: ['Every end a new start']),
      CardSymbol(emoji: '🏴', nameTr: 'Bayrak', nameEn: 'Banner', meaningsTr: ['Biten eski düzen', 'Bırakılan alışkanlıkların', 'Gelen yeni kuralların'], meaningsEn: ['Old order is ending']),
      CardSymbol(emoji: '👥', nameTr: 'Figürler', nameEn: 'Figures', meaningsTr: ['Dönüşümde herkesin eşitliği', 'Kaçış yok kabul et', 'Değişim herkese dokunur'], meaningsEn: ['All equal in change']),
    ],
    14: [ // Temperance
      CardSymbol(emoji: '🏺', nameTr: 'Kupalar', nameEn: 'Cups', meaningsTr: ['Zıtlıkları birleştirmen', 'Dengeyi sen kurarsın', 'Uyum senin doğan'], meaningsEn: ['Uniting opposites']),
      CardSymbol(emoji: '🪶', nameTr: 'Kanatlar', nameEn: 'Wings', meaningsTr: ['Ruh ve beden köprün', 'İçsel uyumun güçleniyor', 'Bütünlüğe doğru yoldasın'], meaningsEn: ['Body-spirit bridge']),
      CardSymbol(emoji: '🌊', nameTr: 'Nehir', nameEn: 'River', meaningsTr: ['Duyguların akışı', 'Bilinçaltı bağlantın', 'Sonsuz yaşam enerjin'], meaningsEn: ['Flow of your emotions, Subconscious link']),
      CardSymbol(emoji: '☀️', nameTr: 'Güneş', nameEn: 'Sun', meaningsTr: ['İçsel aydınlanman', 'Ruhunu ısıtan o denge', 'İlahi ışığın koruması'], meaningsEn: ['Your inner illumination']),
    ],
    15: [ // The Devil
      CardSymbol(emoji: '🐐', nameTr: 'Şeytan', nameEn: 'Devil', meaningsTr: ['Dünyevi tutkular ve ego', 'Korkularının yansıması', 'Gölge benliğinle yüzleş'], meaningsEn: ['Worldly passions and ego']),
      CardSymbol(emoji: '⭐', nameTr: 'Pentagram', nameEn: 'Pentagram', meaningsTr: ['Maddeye bağımlılık', 'Dünyevi illüzyon', 'Maddenin ruha üstünlüğü'], meaningsEn: ['Material addiction']),
      CardSymbol(emoji: '⛓️', nameTr: 'Zincir', nameEn: 'Chain', meaningsTr: ['Gevs̈ek zincirler ve özgürlük', 'Zincirlerin senaryonu sen yaz', 'Esaret bir seçimdir'], meaningsEn: ['You can escape if willing']),
      CardSymbol(emoji: '👤', nameTr: 'Figürler', nameEn: 'Figures', meaningsTr: ['Korkularla yüzleşmen', 'Gerçeğe bakan cesaretin', 'Cesaret isteyen özgürlüğün'], meaningsEn: ['Time to face your fears']),
    ],
    16: [ // The Tower
      CardSymbol(emoji: '⚡', nameTr: 'Yıldırım', nameEn: 'Lightning', meaningsTr: ['Anında açığa çıkan gerçek', 'Yıkım aslında özgürlük', 'Şok gerçeği getirir'], meaningsEn: ['Truth revealed instantly']),
      CardSymbol(emoji: '👑', nameTr: 'Taç', nameEn: 'Crown', meaningsTr: ['Egoyla inşa edilenin çöküşü', 'Sahte güvenlik çöker', 'Temelsiz olan devrilir'], meaningsEn: ['Ego-built can collapse']),
      CardSymbol(emoji: '🔥', nameTr: 'Alev', nameEn: 'Flame', meaningsTr: ['Ateşten geçen gercek', 'Yangından sağ çıkan değerli', 'Ateşten geçen altın olur'], meaningsEn: ['What remains is real']),
    ],
    17: [ // The Star
      CardSymbol(emoji: '🌟', nameTr: 'Yıldız', nameEn: 'Star', meaningsTr: ['Karanlıktan sonra umut', 'Karanlığın sonundaki şafak', 'Hep var olan ışık'], meaningsEn: ['Hope after darkness']),
      CardSymbol(emoji: '💧', nameTr: 'Su', nameEn: 'Water', meaningsTr: ['Toprağı ve ruhu besleyen şifa', 'Şifa veren enerji', 'Sana akan bereket'], meaningsEn: ['Feeds earth and spirit']),
      CardSymbol(emoji: '👤', nameTr: 'Figür', nameEn: 'Figure', meaningsTr: ['İlahi akışa teslimiyet', 'Huzur ve şifa', 'Evrensel enerjiyi topraklama'], meaningsEn: ['Surrender to divine flow']),
    ],
    18: [ // The Moon
      CardSymbol(emoji: '🌕', nameTr: 'Ay', nameEn: 'Moon', meaningsTr: ['Görünenin ötesindeki yanılsama', 'Yanılsama içindesin', 'Görünenin ötesine bak'], meaningsEn: ['Not all you see is real']),
      CardSymbol(emoji: '🏰', nameTr: 'Kuleler', nameEn: 'Towers', meaningsTr: ['Bilinen-bilinmeyen kapı', 'İki dünya arasında', 'Eşik bir karar noktası'], meaningsEn: ['Known-unknown gate']),
      CardSymbol(emoji: '🐺', nameTr: 'Kurt', nameEn: 'Wolf', meaningsTr: ['Evcil ve vahşi benin', 'İçindeki iki yüz', 'Karanlık tarafını kabul et'], meaningsEn: ['Your tame and wild self']),
      CardSymbol(emoji: '🌊', nameTr: 'Nehir', nameEn: 'River', meaningsTr: ['Bilinçaltının akışı', 'Bilinmeze doğru sürükleniş', 'Derin duygular'], meaningsEn: ['Flow of the subconscious']),
    ],
    19: [ // The Sun
      CardSymbol(emoji: '☀️', nameTr: 'Güneş', nameEn: 'Sun', meaningsTr: ['En aydınlık anın', 'Parıldama zamanın', 'Sana yönelen ışığın'], meaningsEn: ['Your brightest moment has come']),
      CardSymbol(emoji: '👶', nameTr: 'Çocuk', nameEn: 'Child', meaningsTr: ['Uyanan iç çocuǧun', 'Geri dönen saflığın', 'İzin verilen neşen'], meaningsEn: ['Inner child awakens']),
      CardSymbol(emoji: '🌻', nameTr: 'Çiçek', nameEn: 'Flower', meaningsTr: ['Işığa yönelişin', 'Doğru yöne bakışın', 'Seni çağıran güneşin'], meaningsEn: ['Your turn to light']),
      CardSymbol(emoji: '🐴', nameTr: 'At', nameEn: 'Horse', meaningsTr: ['Saf enerjiyle koşan ruh', 'Durdurulamaz gücün', 'Özgürce ilerleyişin'], meaningsEn: ['Galloping with pure energy']),
    ],
    20: [ // Judgement
      CardSymbol(emoji: '📯', nameTr: 'Sûr', nameEn: 'Horn', meaningsTr: ['Ruhun uyanış çağrısı', 'Büyük uyanış vakti', 'Kapıdaki ikinci şans'], meaningsEn: ['Your spirit wakes you']),
      CardSymbol(emoji: '👼', nameTr: 'Melek', nameEn: 'Angel', meaningsTr: ['İlahi çağrının sesi', 'Yeniden doğuş vakti', 'Tartılan eylemlerin'], meaningsEn: ['Your actions are weighed']),
      CardSymbol(emoji: '✨', nameTr: 'Uyananlar', nameEn: 'Awakened', meaningsTr: ['Doğmakta olan yeni sen', 'Başlayan ruhsal diriliş', 'Zihinsel uyanışın'], meaningsEn: ['New you is rising']),
      CardSymbol(emoji: '⚰️', nameTr: 'Mezarlar', nameEn: 'Graves', meaningsTr: ['Kırılan eski kabuk', 'Geride bırakılan geçmiş', 'Sınırlayıcı inançlardan kurtuluş'], meaningsEn: ['Break your old shell']),
    ],
    21: [ // The World
      CardSymbol(emoji: '💃', nameTr: 'Dansçı', nameEn: 'Dancer', meaningsTr: ['Tamamlanan yolculuk', 'Döngü tamamlandı', 'Başardın, gururlan'], meaningsEn: ['Journey complete, celebrate!']),
      CardSymbol(emoji: '🌿', nameTr: 'Çelenk', nameEn: 'Wreath', meaningsTr: ['Evrenin taktığı taç', 'Hak ettiğin ödül', 'Başarının sembolü'], meaningsEn: ['Crown from the universe']),
      CardSymbol(emoji: '👼', nameTr: 'Melek', nameEn: 'Angel', meaningsTr: ['Hava elementi', 'Zihinsel aydınlanma', 'Kova burcu enerjisi'], meaningsEn: ['Air element']),
      CardSymbol(emoji: '🦅', nameTr: 'Kartal', nameEn: 'Eagle', meaningsTr: ['Su elementi', 'Duygusal derinlik', 'Akrep burcu enerjisi'], meaningsEn: ['Water element']),
      CardSymbol(emoji: '🐂', nameTr: 'Boğa', nameEn: 'Bull', meaningsTr: ['Toprak elementi', 'Maddi istikrar', 'Boğa burcu enerjisi'], meaningsEn: ['Earth element']),
      CardSymbol(emoji: '🦁', nameTr: 'Aslan', nameEn: 'Lion', meaningsTr: ['Ateş elementi', 'Eylemsel güç', 'Aslan burcu enerjisi'], meaningsEn: ['Fire element']),
    ],
  };

  if (cardId < 22 && majorSymbols.containsKey(cardId)) {
    final anchors = _cardAnchors[cardId] ?? [];
    return _withAnchors(majorSymbols[cardId]!, anchors);
  }

  // ── KARTA ÖZEL MİNOR ARCANA SEMBOLLERİ ──
  const minorSpecificSymbols = <int, List<CardSymbol>>{
    22: [ // Ace of Cups
      CardSymbol(emoji: '🏆', nameTr: 'Kupa', nameEn: 'Cup', meaningsTr: ['Taşan duygusal bereketin', 'Coşkuyla dolan kalbin', 'Akan duygusal zenginliğin'], meaningsEn: ['Your overflowing emotional abundance']),
      CardSymbol(emoji: '☀️', nameTr: 'Güneş', nameEn: 'Sun', meaningsTr: ['Kalbini aydınlatan ışık', 'İçindeki sıcaklık', 'Sevgi güneşin doğuyor'], meaningsEn: ['The light illuminating your heart']),
      CardSymbol(emoji: '💧', nameTr: 'Su', nameEn: 'Water', meaningsTr: ['Duygularının serbest akışı', 'Hissettiklerini bırak aksın', 'Engelsiz duygusal akış'], meaningsEn: ['Free flow of your emotions']),
      CardSymbol(emoji: '🐟', nameTr: 'Balık', nameEn: 'Fish', meaningsTr: ['Bilinçaltından gelen mesajlar', 'Rüyaların sana konuşuyor', 'Derinlerden gelen fısıltı'], meaningsEn: ['Messages from your subconscious']),
      CardSymbol(emoji: '✨', nameTr: 'Yıldız', nameEn: 'Star', meaningsTr: ['Ruhani rehberliğin', 'Manevi pusulan aktif', 'Görünmez el seni yönlendiriyor'], meaningsEn: ['Your spiritual guidance']),
    ],
    23: [ // Two of Cups
      CardSymbol(emoji: '👩', nameTr: 'Kadın', nameEn: 'Woman', meaningsTr: ['Seni tamamlayan enerji'], meaningsEn: ['The energy that completes you']),
      CardSymbol(emoji: '👨', nameTr: 'Erkek', nameEn: 'Man', meaningsTr: ['Karşındaki aynan'], meaningsEn: ['Your mirror reflection']),
      CardSymbol(emoji: '🥂', nameTr: 'Kupalar', nameEn: 'Cups', meaningsTr: ['Karşılıklı duygu paylaşımı'], meaningsEn: ['Mutual emotional exchange']),
      CardSymbol(emoji: '🥂', nameTr: 'Kadeh', nameEn: 'Chalice', meaningsTr: ['Sana dönen sevgi'], meaningsEn: ['Love returning to you']),
      CardSymbol(emoji: '⚕️', nameTr: 'Caduceus', nameEn: 'Caduceus', meaningsTr: ['Ruhsal bağınızın gücü'], meaningsEn: ['Power of your spiritual bond']),
      CardSymbol(emoji: '💫', nameTr: 'Enerji', nameEn: 'Energy', meaningsTr: ['Aranızdaki çekim gücü'], meaningsEn: ['The attraction between you']),
    ],
    24: [ // Three of Cups
      CardSymbol(emoji: '💃', nameTr: 'Dost', nameEn: 'Friend', meaningsTr: ['Seni destekleyen bağlar'], meaningsEn: ['Bonds that support you']),
      CardSymbol(emoji: '💃', nameTr: 'Kutlama', nameEn: 'Celebration', meaningsTr: ['Paylaşılan sevinç'], meaningsEn: ['Shared joy']),
      CardSymbol(emoji: '💃', nameTr: 'Birlik', nameEn: 'Unity', meaningsTr: ['Birlikte daha güçsünüz'], meaningsEn: ['Stronger together']),
      CardSymbol(emoji: '🥂', nameTr: 'Kupalar', nameEn: 'Cups', meaningsTr: ['Kutlanacak başarıların'], meaningsEn: ['Your achievements to celebrate']),
      CardSymbol(emoji: '🍇', nameTr: 'Meyve', nameEn: 'Fruit', meaningsTr: ['Emeğinin hasadı geldi'], meaningsEn: ['Harvest of your efforts arrived']),
      CardSymbol(emoji: '✨', nameTr: 'Yıldız', nameEn: 'Star', meaningsTr: ['Evren seninle kutluyor'], meaningsEn: ['The universe celebrates with you']),
    ],
    25: [ // Four of Cups
      CardSymbol(emoji: '🧘', nameTr: 'Oturan Adam', nameEn: 'Seated Man', meaningsTr: ['Kaçırdığın fırsatların'], meaningsEn: ['Opportunities you are missing']),
      CardSymbol(emoji: '🌳', nameTr: 'Ağaç', nameEn: 'Tree', meaningsTr: ['Seni koruyan konfor alanın'], meaningsEn: ['Your protective comfort zone']),
      CardSymbol(emoji: '🏆', nameTr: 'Kupa', nameEn: 'Cup', meaningsTr: ['Görmediğin yeni bir şans'], meaningsEn: ['A new chance you do not see']),
      CardSymbol(emoji: '✨', nameTr: 'Ruh Eli', nameEn: 'Spirit Hand', meaningsTr: ['Evrenin sana uzattığı el'], meaningsEn: ['The hand the universe extends to you']),
      CardSymbol(emoji: '🏆', nameTr: 'Kupalar', nameEn: 'Cups', meaningsTr: ['Değerini bilmediğin nimetler'], meaningsEn: ['Blessings you undervalue']),
    ],
    26: [ // Five of Cups
      CardSymbol(emoji: '👤', nameTr: 'Kederli Silüet', nameEn: 'Sorrowful Silhouette', meaningsTr: ['Kaybettiklerine takılma'], meaningsEn: ['Do not dwell on your losses']),
      CardSymbol(emoji: '🍷', nameTr: 'Devrilen Kadehler', nameEn: 'Fallen Chalices', meaningsTr: ['Yaşanan hayal kırıklığı'], meaningsEn: ['The disappointment you experienced']),
      CardSymbol(emoji: '💧', nameTr: 'Su', nameEn: 'Water', meaningsTr: ['Akanı geri getiremezsin'], meaningsEn: ['You cannot bring back what flowed away']),
      CardSymbol(emoji: '🏆', nameTr: 'Kalan Kupalar', nameEn: 'Remaining Cups', meaningsTr: ['Hâlâ sahip olduğun değerler'], meaningsEn: ['Values you still possess']),
      CardSymbol(emoji: '🌉', nameTr: 'Köprü', nameEn: 'Bridge', meaningsTr: ['Yeni başlangıca geçiş yolun'], meaningsEn: ['Your path to a new beginning']),
      CardSymbol(emoji: '✨', nameTr: 'Yıldızlar', nameEn: 'Stars', meaningsTr: ['Arkada bekleyen umudun'], meaningsEn: ['Hope always stands behind you']),
    ],
    27: [ // Six of Cups
      CardSymbol(emoji: '👦', nameTr: 'Çocuk', nameEn: 'Child', meaningsTr: ['Masumiyetine dönüş zamanı', 'Çocuksu saflığın', 'Yeniden masum olabilirsin'], meaningsEn: ['Time to return to your innocence']),
      CardSymbol(emoji: '👧', nameTr: 'Çocuk', nameEn: 'Child', meaningsTr: ['Geçmişten gelen sıcaklık'], meaningsEn: ['Warmth coming from the past']),
      CardSymbol(emoji: '🌸', nameTr: 'Kupalar', nameEn: 'Cups', meaningsTr: ['Nostalji ve tatlı anıların', 'Geçmişin güzel mirası', 'Anılardan gelen güç'], meaningsEn: ['Your nostalgia and sweet memories']),
      CardSymbol(emoji: '🌕', nameTr: 'Dolunay', nameEn: 'Full Moon', meaningsTr: ['Duygusal tamlık hissin'], meaningsEn: ['Your sense of emotional wholeness']),
      CardSymbol(emoji: '🏘️', nameTr: 'Köy', nameEn: 'Village', meaningsTr: ['Köklerine duyduğun özlem'], meaningsEn: ['Your longing for your roots']),
      CardSymbol(emoji: '🛣️', nameTr: 'Patika', nameEn: 'Path', meaningsTr: ['Geçmişe açılan yolun'], meaningsEn: ['Your path opening to the past']),
    ],
    28: [ // Seven of Cups
      CardSymbol(emoji: '👤', nameTr: 'Hayalperest', nameEn: 'Dreamer', meaningsTr: ['Hayallerinin esiri olma'], meaningsEn: ['Do not be a prisoner of dreams']),
      CardSymbol(emoji: '🎭', nameTr: 'İllüzyon', nameEn: 'Illusion', meaningsTr: ['Görüntüye aldanma', 'Seçenekler karmaşası'], meaningsEn: ['Deception of appearances']),
      CardSymbol(emoji: '🐉', nameTr: 'Ejderha', nameEn: 'Dragon', meaningsTr: ['Korku dolu bir hayalin'], meaningsEn: ['A dream filled with fear']),
      CardSymbol(emoji: '🐍', nameTr: 'Yılan', nameEn: 'Snake', meaningsTr: ['Aldatıcı bir arzu'], meaningsEn: ['A deceptive desire']),
      CardSymbol(emoji: '🏰', nameTr: 'Kale', nameEn: 'Castle', meaningsTr: ['Ulaşılmaz bir hedef'], meaningsEn: ['An unreachable goal']),
      CardSymbol(emoji: '💎', nameTr: 'Mücevher', nameEn: 'Jewel', meaningsTr: ['Sahte parıltıya kapılma'], meaningsEn: ['Do not fall for false glitter']),
      CardSymbol(emoji: '☀️', nameTr: 'Güneş', nameEn: 'Sun', meaningsTr: ['Sorgulanan gerçek hedefin'], meaningsEn: ['Which is your real goal?']),
    ],
    29: [ // Eight of Cups
      CardSymbol(emoji: '🚶', nameTr: 'Yolcu', nameEn: 'Traveler', meaningsTr: ['Geride bırakma cesareti'], meaningsEn: ['The courage to let go']),
      CardSymbol(emoji: '🏆', nameTr: 'Kupalar', nameEn: 'Cups', meaningsTr: ['Artık seni doyurmayan şeyler'], meaningsEn: ['Things that no longer fulfill you']),
      CardSymbol(emoji: '🌒', nameTr: 'Tutulma', nameEn: 'Eclipse', meaningsTr: ['Bilinçaltından gelen işaret'], meaningsEn: ['A signal from your subconscious']),
      CardSymbol(emoji: '🏔️', nameTr: 'Dağ', nameEn: 'Mountain', meaningsTr: ['Önündeki yeni keşifler'], meaningsEn: ['New discoveries lie ahead']),
      CardSymbol(emoji: '🌉', nameTr: 'Köprü', nameEn: 'Bridge', meaningsTr: ['Eskiyle yeninin arasındasın'], meaningsEn: ['You are between old and new']),
      CardSymbol(emoji: '🛤️', nameTr: 'Patika', nameEn: 'Path', meaningsTr: ['Ruhunun seni çektiği yön'], meaningsEn: ['The direction your soul pulls you']),
    ],
    30: [ // Nine of Cups
      CardSymbol(emoji: '🧘', nameTr: 'Gururlu Adam', nameEn: 'Proud Man', meaningsTr: ['Gerçekleşen dileklerin'], meaningsEn: ['Your wishes are coming true']),
      CardSymbol(emoji: '🏆', nameTr: 'Kupalar', nameEn: 'Cups', meaningsTr: ['Duygusal tatmin ve bolluk'], meaningsEn: ['Emotional satisfaction and abundance']),
      CardSymbol(emoji: '⚜️', nameTr: 'Görkemli Örtü', nameEn: 'Magnificent Drape', meaningsTr: ['Sahip olduğun zenginlikler'], meaningsEn: ['Riches you possess']),
      CardSymbol(emoji: '✨', nameTr: 'Yıldızlar', nameEn: 'Stars', meaningsTr: ['Evrenin sana gülümseyişi'], meaningsEn: ['The universe smiles upon you']),
    ],
    31: [ // Ten of Cups
      CardSymbol(emoji: '👫', nameTr: 'Aile', nameEn: 'Family', meaningsTr: ['Senin en derin arzun'], meaningsEn: ['Your deepest desire']),
      CardSymbol(emoji: '🧒', nameTr: 'Çocuklar', nameEn: 'Children', meaningsTr: ['Paylaşılan mutluluk'], meaningsEn: ['Shared happiness']),
      CardSymbol(emoji: '🌈', nameTr: 'Kupalar', nameEn: 'Cups', meaningsTr: ['Duygusal zenginliğin zirvesi'], meaningsEn: ['Peak of your emotional richness']),
      CardSymbol(emoji: '🌈', nameTr: 'Gökkuşağı', nameEn: 'Rainbow', meaningsTr: ['Evrenin sana vaadi'], meaningsEn: ['The universes promise to you']),
      CardSymbol(emoji: '🏡', nameTr: 'Ev', nameEn: 'Home', meaningsTr: ['Seni bekleyen güvenli limanın'], meaningsEn: ['Your safe harbor awaits you']),
      CardSymbol(emoji: '🍇', nameTr: 'Meyve', nameEn: 'Fruit', meaningsTr: ['Emeğinin meyvesi olgunlaştı'], meaningsEn: ['The fruit of your labor ripened']),
    ],
    32: [ // Page of Cups
      CardSymbol(emoji: '👦', nameTr: 'Genç', nameEn: 'Youth', meaningsTr: ['Yeni duygusal keşiflerin'], meaningsEn: ['Your new emotional discoveries']),
      CardSymbol(emoji: '🏆', nameTr: 'Kupa', nameEn: 'Cup', meaningsTr: ['Sana sunulan sürpriz'], meaningsEn: ['A surprise offered to you']),
      CardSymbol(emoji: '🐟', nameTr: 'Balık', nameEn: 'Fish', meaningsTr: ['Gelen beklenmedik mesajın'], meaningsEn: ['An unexpected message is coming']),
      CardSymbol(emoji: '☀️', nameTr: 'Güneş', nameEn: 'Sun', meaningsTr: ['Yaratıcılığının uyanışı'], meaningsEn: ['Awakening of your creativity']),
      CardSymbol(emoji: '🌊', nameTr: 'Dalga', nameEn: 'Wave', meaningsTr: ['Duygusal heyecanlar kapıda'], meaningsEn: ['Emotional excitement at your door']),
    ],
    33: [ // Knight of Cups
      CardSymbol(emoji: '🏇', nameTr: 'Şövalye', nameEn: 'Knight', meaningsTr: ['Gelen romantik haberci'], meaningsEn: ['A romantic messenger is coming']),
      CardSymbol(emoji: '🐎', nameTr: 'At', nameEn: 'Horse', meaningsTr: ['Saf niyetle gelen bir teklif'], meaningsEn: ['An offer coming with pure intent']),
      CardSymbol(emoji: '🏆', nameTr: 'Kupa', nameEn: 'Cup', meaningsTr: ['Sana uzatılan duygusal davet'], meaningsEn: ['An emotional invitation extended to you']),
      CardSymbol(emoji: '🧥', nameTr: 'Pelerin', nameEn: 'Cloak', meaningsTr: ['Zarif ve sakin bir yaklaşım'], meaningsEn: ['An elegant and calm approach']),
      CardSymbol(emoji: '💧', nameTr: 'Su', nameEn: 'Water', meaningsTr: ['Seni yönlendiren duyguların'], meaningsEn: ['Your emotions are guiding you']),
    ],
    34: [ // Queen of Cups
      CardSymbol(emoji: '👸', nameTr: 'Kraliçe', nameEn: 'Queen', meaningsTr: ['Sezgisel bilgeliğin'], meaningsEn: ['Your intuitive wisdom']),
      CardSymbol(emoji: '🏆', nameTr: 'Kupa', nameEn: 'Cup', meaningsTr: ['İçsel zenginliğin'], meaningsEn: ['Your inner richness']),
      CardSymbol(emoji: '🪑', nameTr: 'Taht', nameEn: 'Throne', meaningsTr: ['Duygulara hâkimiyetin'], meaningsEn: ['You rule your emotions']),
      CardSymbol(emoji: '☀️', nameTr: 'Güneş', nameEn: 'Sun', meaningsTr: ['Aydınlanmış sevgi enerjin'], meaningsEn: ['Your enlightened love']),
      CardSymbol(emoji: '🌊', nameTr: 'Su', nameEn: 'Water', meaningsTr: ['Güçlü empati enerjin'], meaningsEn: ['Strong empathy power']),
    ],
    35: [ // King of Cups
      CardSymbol(emoji: '🤴', nameTr: 'Kral', nameEn: 'King', meaningsTr: ['Duygusal olgunluğun'], meaningsEn: ['Your emotional maturity']),
      CardSymbol(emoji: '🏆', nameTr: 'Kupa', nameEn: 'Cup', meaningsTr: ['İçsel zenginliğin'], meaningsEn: ['Your inner richness']),
      CardSymbol(emoji: '🪑', nameTr: 'Taht', nameEn: 'Throne', meaningsTr: ['Kaosta bile korunan denge'], meaningsEn: ['Balanced even in chaos']),
      CardSymbol(emoji: '🌊', nameTr: 'Deniz', nameEn: 'Sea', meaningsTr: ['Derin duyguların gücü'], meaningsEn: ['Power of deep emotions']),
    ],
    36: [ // Ace of Wands
      CardSymbol(emoji: '✨', nameTr: 'El', nameEn: 'Hand', meaningsTr: ['Evrenin sana verdiği güç'], meaningsEn: ['The power the universe gives you']),
      CardSymbol(emoji: '🌱', nameTr: 'Asa', nameEn: 'Wand', meaningsTr: ['Yeni tutkulu başlangıcın'], meaningsEn: ['Your new passionate beginning']),
      CardSymbol(emoji: '🍃', nameTr: 'Yaprak', nameEn: 'Leaf', meaningsTr: ['Büyüme potansiyelin'], meaningsEn: ['Your growth potential']),
      CardSymbol(emoji: '🏰', nameTr: 'Kale', nameEn: 'Castle', meaningsTr: ['Hedefinin görüntüsü'], meaningsEn: ['The vision of your goal']),
      CardSymbol(emoji: '☁️', nameTr: 'Bulut', nameEn: 'Cloud', meaningsTr: ['Netleşen hayallerin'], meaningsEn: ['Your dreams are becoming clear']),
    ],
    37: [ // Two of Wands
      CardSymbol(emoji: '👤', nameTr: 'Kâşif', nameEn: 'Explorer', meaningsTr: ['Büyük kararın eşiğindesin'], meaningsEn: ['You are on the edge of a big decision']),
      CardSymbol(emoji: '🪵', nameTr: 'Asa', nameEn: 'Wand', meaningsTr: ['Elindeki güç ve planlama'], meaningsEn: ['Power and planning in your hands']),
      CardSymbol(emoji: '🔮', nameTr: 'Küre', nameEn: 'Globe', meaningsTr: ['Geleceğe bakışın'], meaningsEn: ['Your vision of the future']),
      CardSymbol(emoji: '🏰', nameTr: 'Kale', nameEn: 'Castle', meaningsTr: ['Konfor alanından çıkma zamanı'], meaningsEn: ['Time to leave your comfort zone']),
      CardSymbol(emoji: '🌊', nameTr: 'Ufuk', nameEn: 'Horizon', meaningsTr: ['Seni bekleyen olanaklar'], meaningsEn: ['Possibilities awaiting you']),
    ],
    38: [ // Three of Wands
      CardSymbol(emoji: '🧍', nameTr: 'Lider', nameEn: 'Leader', meaningsTr: ['Planların hayat buluyor'], meaningsEn: ['Your plans are coming to life']),
      CardSymbol(emoji: '🪵', nameTr: 'Asalar', nameEn: 'Wands', meaningsTr: ['Attığın sağlam temeller'], meaningsEn: ['The solid foundations you laid']),
      CardSymbol(emoji: '⛵', nameTr: 'Gemi', nameEn: 'Ship', meaningsTr: ['Yola çıkan umutların'], meaningsEn: ['Your hopes setting sail']),
      CardSymbol(emoji: '🌅', nameTr: 'Ufuk', nameEn: 'Horizon', meaningsTr: ['Genişleyen vizyonun'], meaningsEn: ['Your expanding vision']),
    ],
    39: [ // Four of Wands
      CardSymbol(emoji: '🪵', nameTr: 'Asalar', nameEn: 'Wands', meaningsTr: ['Sağlam temeller üzerine kurulu'], meaningsEn: ['Built on solid foundations']),
      CardSymbol(emoji: '🌸', nameTr: 'Çelenk', nameEn: 'Garland', meaningsTr: ['Kutlamaya değer başarın'], meaningsEn: ['An achievement worth celebrating']),
      CardSymbol(emoji: '💃', nameTr: 'Çift', nameEn: 'Couple', meaningsTr: ['Paylaşılan mutluluk anı'], meaningsEn: ['A shared moment of happiness']),
      CardSymbol(emoji: '🏰', nameTr: 'Kale', nameEn: 'Castle', meaningsTr: ['Güvenli yuvanın simgesi'], meaningsEn: ['Symbol of your safe haven']),
      CardSymbol(emoji: '🌅', nameTr: 'Ufuk', nameEn: 'Horizon', meaningsTr: ['Altın çağın başlangıcı'], meaningsEn: ['Your golden age is beginning']),
    ],
    40: [ // Five of Wands
      CardSymbol(emoji: '🤼', nameTr: 'Rakipler', nameEn: 'Rivals', meaningsTr: ['Etrafındaki rekabet ortamı'], meaningsEn: ['The competitive environment around you']),
      CardSymbol(emoji: '🪵', nameTr: 'Asalar', nameEn: 'Wands', meaningsTr: ['Çatışan fikirler ve görüşler', 'Farklı sesleri dinle', 'Kaos içinde doğru yolu bul'], meaningsEn: ['Clashing ideas and opinions']),
      CardSymbol(emoji: '✨', nameTr: 'Kıvılcım', nameEn: 'Spark', meaningsTr: ['Sürtüşmeden doğan enerji'], meaningsEn: ['Energy born from friction']),
    ],
    41: [ // Six of Wands
      CardSymbol(emoji: '🏇', nameTr: 'Binici', nameEn: 'Rider', meaningsTr: ['Gelen zafer anın'], meaningsEn: ['Your moment of victory has come']),
      CardSymbol(emoji: '🐎', nameTr: 'At', nameEn: 'Horse', meaningsTr: ['Başarıya taşıyan gücün'], meaningsEn: ['The force carrying you to success']),
      CardSymbol(emoji: '🌿', nameTr: 'Asa', nameEn: 'Wand', meaningsTr: ['Kazandığın saygı ve itibar'], meaningsEn: ['The respect and prestige you earned']),
      CardSymbol(emoji: '👑', nameTr: 'Taç', nameEn: 'Crown', meaningsTr: ['Hak ettiğin tanınma'], meaningsEn: ['The recognition you deserve']),
      CardSymbol(emoji: '👥', nameTr: 'Kalabalık', nameEn: 'Crowd', meaningsTr: ['Seni alkışlayanlar'], meaningsEn: ['There are those who applaud you']),
    ],
    42: [ // Seven of Wands
      CardSymbol(emoji: '🛡️', nameTr: 'Savunucu', nameEn: 'Defender', meaningsTr: ['Tek başına durma cesaretin'], meaningsEn: ['Your courage to stand alone']),
      CardSymbol(emoji: '🔱', nameTr: 'Mızrak', nameEn: 'Spear', meaningsTr: ['Elindeki en güçlü silahın'], meaningsEn: ['Your most powerful weapon']),
      CardSymbol(emoji: '⚔️', nameTr: 'Saldırı', nameEn: 'Attack', meaningsTr: ['Sana yönelen dış baskılar'], meaningsEn: ['External pressures aimed at you']),
      CardSymbol(emoji: '🔥', nameTr: 'Ateş', nameEn: 'Fire', meaningsTr: ['Seni ayakta tutan irade gücün'], meaningsEn: ['The willpower keeping you standing']),
    ],
    43: [ // Eight of Wands
      CardSymbol(emoji: '🏹', nameTr: 'Alevli Oklar', nameEn: 'Flaming Arrows', meaningsTr: ['Hızla gelen haberler'], meaningsEn: ['News arriving fast']),
      CardSymbol(emoji: '⛰️', nameTr: 'Tepeler', nameEn: 'Hills', meaningsTr: ['Geride kalan engeller'], meaningsEn: ['Obstacles are falling behind']),
      CardSymbol(emoji: '🌊', nameTr: 'Nehir', nameEn: 'River', meaningsTr: ['Artan yaşam hızın'], meaningsEn: ['The pace of your life is accelerating']),
    ],
    44: [ // Nine of Wands
      CardSymbol(emoji: '🤕', nameTr: 'Savaşçı', nameEn: 'Warrior', meaningsTr: ['Yorgun ama pes etmeyen sen'], meaningsEn: ['Tired but you never give up']),
      CardSymbol(emoji: '🪵', nameTr: 'Asa', nameEn: 'Wand', meaningsTr: ['Son savunma hattın'], meaningsEn: ['This is your last line of defense']),
      CardSymbol(emoji: '🪵', nameTr: 'Asalar', nameEn: 'Wands', meaningsTr: ['Geçirdiğin tüm sınavlar'], meaningsEn: ['All the trials you have endured']),
      CardSymbol(emoji: '🔥', nameTr: 'Alev', nameEn: 'Flame', meaningsTr: ['İçindeki sönmeyen ateş'], meaningsEn: ['The unquenchable fire within you']),
    ],
    45: [ // Ten of Wands
      CardSymbol(emoji: '🚶', nameTr: 'Yüklü Adam', nameEn: 'Burdened Man', meaningsTr: ['Omuzlarındaki ağır yük'], meaningsEn: ['The heavy burden on your shoulders']),
      CardSymbol(emoji: '🪵', nameTr: 'Odun Demeti', nameEn: 'Bundle of Wood', meaningsTr: ['Ağır sorumlulukların'], meaningsEn: ['Your heavy responsibilities']),
      CardSymbol(emoji: '🏘️', nameTr: 'Kasaba', nameEn: 'Town', meaningsTr: ['Yaklaşan hedefin'], meaningsEn: ['Your approaching goal']),
      CardSymbol(emoji: '🛣️', nameTr: 'Patika', nameEn: 'Path', meaningsTr: ['Kalan son adımların'], meaningsEn: ['Your remaining few steps']),
    ],
    46: [ // Page of Wands
      CardSymbol(emoji: '👦', nameTr: 'Genç', nameEn: 'Youth', meaningsTr: ['Yeni maceranın başlangıcı'], meaningsEn: ['The beginning of a new adventure']),
      CardSymbol(emoji: '🌱', nameTr: 'Asa', nameEn: 'Wand', meaningsTr: ['İçindeki yaratıcı kıvılcım'], meaningsEn: ['The creative spark within you']),
      CardSymbol(emoji: '🦎', nameTr: 'Semender', nameEn: 'Salamander', meaningsTr: ['Ateşle dönüşüm gücün'], meaningsEn: ['Your power of transformation through fire']),
      CardSymbol(emoji: '🏔️', nameTr: 'Piramit', nameEn: 'Pyramid', meaningsTr: ['Keşfedilecek gizemler'], meaningsEn: ['Mysteries to be explored']),
    ],
    47: [ // Knight of Wands
      CardSymbol(emoji: '🏇', nameTr: 'Şövalye', nameEn: 'Knight', meaningsTr: ['Tutkuyla ileri atılışın'], meaningsEn: ['Your passionate charge forward']),
      CardSymbol(emoji: '🐎', nameTr: 'At', nameEn: 'Horse', meaningsTr: ['Dizginlenemez enerjin'], meaningsEn: ['Your untamable energy']),
      CardSymbol(emoji: '🔥', nameTr: 'Asa', nameEn: 'Wand', meaningsTr: ['Yanan tutku ve kararlılığın'], meaningsEn: ['Your burning passion and determination']),
      CardSymbol(emoji: '🧥', nameTr: 'Pelerin', nameEn: 'Cloak', meaningsTr: ['Cesurca aldığın riskler'], meaningsEn: ['The risks you bravely take']),
      CardSymbol(emoji: '🏔️', nameTr: 'Piramit', nameEn: 'Pyramid', meaningsTr: ['Uzaktaki hedeflerin'], meaningsEn: ['Your distant goals']),
    ],
    48: [ // Queen of Wands
      CardSymbol(emoji: '👸', nameTr: 'Kraliçe', nameEn: 'Queen', meaningsTr: ['İçindeki lider enerjisi'], meaningsEn: ['The leader energy within you']),
      CardSymbol(emoji: '🪵', nameTr: 'Asa', nameEn: 'Wand', meaningsTr: ['Yaratıcı gücünün simgesi'], meaningsEn: ['Symbol of your creative power']),
      CardSymbol(emoji: '🌻', nameTr: 'Ayçiçeği', nameEn: 'Sunflower', meaningsTr: ['Neşen ve pozitif enerjin'], meaningsEn: ['Your joy and positive energy']),
      CardSymbol(emoji: '🪑', nameTr: 'Taht', nameEn: 'Throne', meaningsTr: ['Cesaretle oturduğun yer'], meaningsEn: ['The place you sit with courage']),
      CardSymbol(emoji: '🐈‍⬛', nameTr: 'Kedi', nameEn: 'Cat', meaningsTr: ['Uyanan sezgisel güçlerin'], meaningsEn: ['Your intuitive powers are awakening']),
      CardSymbol(emoji: '☀️', nameTr: 'Güneş', nameEn: 'Sun', meaningsTr: ['Etrafına yaydığın ışık'], meaningsEn: ['The light you radiate around you']),
    ],
    49: [ // King of Wands
      CardSymbol(emoji: '🤴', nameTr: 'Kral', nameEn: 'King', meaningsTr: ['Parıldayan vizyoner liderliğin'], meaningsEn: ['Your visionary leadership shines']),
      CardSymbol(emoji: '🌱', nameTr: 'Asa', nameEn: 'Wand', meaningsTr: ['Büyüyen gücünün sembolü'], meaningsEn: ['Symbol of your growing power']),
      CardSymbol(emoji: '🪑', nameTr: 'Taht', nameEn: 'Throne', meaningsTr: ['Hissedilen doğal otoriten'], meaningsEn: ['Your natural authority is felt']),
      CardSymbol(emoji: '🦎', nameTr: 'Semender', nameEn: 'Salamander', meaningsTr: ['Ateşten geçip kazandığın güç'], meaningsEn: ['You grew stronger through fire']),
      CardSymbol(emoji: '☀️', nameTr: 'Güneş', nameEn: 'Sun', meaningsTr: ['İçindeki parlak ışık'], meaningsEn: ['The bright light within you']),
    ],
    50: [ // Ace of Swords
      CardSymbol(emoji: '✨', nameTr: 'El', nameEn: 'Hand', meaningsTr: ['Evrenin sana sunduğu netlik'], meaningsEn: ['The clarity the universe offers you']),
      CardSymbol(emoji: '⚔️', nameTr: 'Kılıç', nameEn: 'Sword', meaningsTr: ['Keskin zekânın gücü'], meaningsEn: ['The power of your sharp mind']),
      CardSymbol(emoji: '👑', nameTr: 'Taç', nameEn: 'Crown', meaningsTr: ['Yaklaşan zihinsel zafer'], meaningsEn: ['Mental victory is approaching']),
      CardSymbol(emoji: '🌿', nameTr: 'Defne', nameEn: 'Laurel', meaningsTr: ['Barışla gelen başarın'], meaningsEn: ['Your success coming with peace']),
      CardSymbol(emoji: '☁️', nameTr: 'Bulut', nameEn: 'Cloud', meaningsTr: ['Dağılan zihinsel sisin'], meaningsEn: ['Your mental fog is clearing']),
    ],
    51: [ // Two of Swords
      CardSymbol(emoji: '🙈', nameTr: 'Gözleri Bağlı Ruh', nameEn: 'Blindfolded Soul', meaningsTr: ['Görmezden geldiğin gerçek'], meaningsEn: ['The truth you are ignoring']),
      CardSymbol(emoji: '⚔️', nameTr: 'Kılıçlar', nameEn: 'Swords', meaningsTr: ['İçindeki ikilem'], meaningsEn: ['The dilemma within you']),
      CardSymbol(emoji: '🌙', nameTr: 'Ay', nameEn: 'Moon', meaningsTr: ['Sezgine güvenme zamanı'], meaningsEn: ['Time to trust your intuition']),
      CardSymbol(emoji: '🌊', nameTr: 'Deniz', nameEn: 'Sea', meaningsTr: ['Bastırdığın duygular'], meaningsEn: ['Emotions you have suppressed']),
    ],
    52: [ // Three of Swords
      CardSymbol(emoji: '❤️', nameTr: 'Kalp', nameEn: 'Heart', meaningsTr: ['Acı veren bir gerçek'], meaningsEn: ['A painful truth']),
      CardSymbol(emoji: '⚔️', nameTr: 'Kılıçlar', nameEn: 'Swords', meaningsTr: ['Seni yaralayan sözler'], meaningsEn: ['Words that wounded you']),
      CardSymbol(emoji: '🌧️', nameTr: 'Yağmur', nameEn: 'Rain', meaningsTr: ['Dökülmesi gereken gözyaşları'], meaningsEn: ['Tears that need to be shed']),
      CardSymbol(emoji: '🌙', nameTr: 'Ay', nameEn: 'Moon', meaningsTr: ['Geceyi aydınlatan acı bilgelik'], meaningsEn: ['Painful wisdom illuminating the night']),
      CardSymbol(emoji: '⛈️', nameTr: 'Fırtına', nameEn: 'Storm', meaningsTr: ['Geçici zorluk dönemi'], meaningsEn: ['Temporary difficult phase']),
    ],
    53: [ // Four of Swords
      CardSymbol(emoji: '🛌', nameTr: 'Dinlenen Savaşçı', nameEn: 'Resting Warrior', meaningsTr: ['Ruhunun dinlenme ihtiyacı'], meaningsEn: ['Your souls need for rest']),
      CardSymbol(emoji: '⚔️', nameTr: 'Kılıçlar', nameEn: 'Swords', meaningsTr: ['Askıya aldığın mücadeleler'], meaningsEn: ['Battles you have put on hold']),
      CardSymbol(emoji: '⚔️', nameTr: 'Kılıç', nameEn: 'Sword', meaningsTr: ['Hazır olduğunda döneceksin'], meaningsEn: ['You will return when ready']),
      CardSymbol(emoji: '🪟', nameTr: 'Vitray', nameEn: 'Stained Glass', meaningsTr: ['İç huzurunun kaynağı'], meaningsEn: ['The source of your inner peace']),
    ],
    54: [ // Five of Swords
      CardSymbol(emoji: '🏆', nameTr: 'Galip', nameEn: 'Victor', meaningsTr: ['Bedeli ödenmiş zaferin'], meaningsEn: ['You won but what did you lose?']),
      CardSymbol(emoji: '⚔️', nameTr: 'Kılıçlar', nameEn: 'Swords', meaningsTr: ['Ele geçirdiğin avantaj'], meaningsEn: ['The advantage you seized']),
      CardSymbol(emoji: '⚔️', nameTr: 'Yerdeki Kılıçlar', nameEn: 'Fallen Swords', meaningsTr: ['Bıraktığın yaralar var'], meaningsEn: ['There are wounds you left behind']),
      CardSymbol(emoji: '🚶', nameTr: 'Uzaklaşanlar', nameEn: 'The Departing Ones', meaningsTr: ['Uzaklaşan ilişkilerin'], meaningsEn: ['Your distancing relationships']),
      CardSymbol(emoji: '🌙', nameTr: 'Ay', nameEn: 'Moon', meaningsTr: ['Vicdanının sesi yükseliyor'], meaningsEn: ['The voice of your conscience rises']),
    ],
    55: [ // Six of Swords
      CardSymbol(emoji: '🛶', nameTr: 'Kayıkçı', nameEn: 'Boatman', meaningsTr: ['Seni güvenli kıyıya taşıyan', 'Rehberin seni bekliyor', 'Güvenli geçiş yolun var'], meaningsEn: ['The one carrying you to safe shores']),
      CardSymbol(emoji: '👩‍👧', nameTr: 'Anne', nameEn: 'Mother', meaningsTr: ['Korunan değerli varlıkların', 'Kaybetmeyeceğin hazineler', 'Sana ait olan kaybolmaz'], meaningsEn: ['Your precious ones being protected']),
      CardSymbol(emoji: '🚤', nameTr: 'Tekne', nameEn: 'Boat', meaningsTr: ['Geçiş döneminin aracı', 'Değişim teknen hazır', 'Bir kıyıdan diğerine'], meaningsEn: ['The vehicle of your transition']),
      CardSymbol(emoji: '⚔️', nameTr: 'Kılıçlar', nameEn: 'Swords', meaningsTr: ['Yanında taşıdığın dersler'], meaningsEn: ['Lessons you carry with you']),
      CardSymbol(emoji: '🌙', nameTr: 'Ay', nameEn: 'Moon', meaningsTr: ['Belirsizlikte rehberin var'], meaningsEn: ['You have a guide in uncertainty']),
      CardSymbol(emoji: '✨', nameTr: 'Yıldız', nameEn: 'Star', meaningsTr: ['Daha iyi günler yaklaşıyor'], meaningsEn: ['Better days are approaching']),
    ],
    56: [ // Seven of Swords
      CardSymbol(emoji: '🥷', nameTr: 'Hırsız', nameEn: 'Thief', meaningsTr: ['Gizlice yapılan hamleler'], meaningsEn: ['Moves made in secret']),
      CardSymbol(emoji: '⚔️', nameTr: 'Kılıçlar', nameEn: 'Swords', meaningsTr: ['Strateji ve kurnazlık'], meaningsEn: ['Strategy and cunning']),
      CardSymbol(emoji: '⚔️', nameTr: 'Kılıçlar', nameEn: 'Swords', meaningsTr: ['Geride bıraktıkların'], meaningsEn: ['What you left behind']),
      CardSymbol(emoji: '⛺', nameTr: 'Çadır', nameEn: 'Tent', meaningsTr: ['Sessiz ve gizli kaçış'], meaningsEn: ['Escaping without being noticed']),
      CardSymbol(emoji: '🔥', nameTr: 'Ateş', nameEn: 'Fire', meaningsTr: ['Tehlikenin yakınlığı'], meaningsEn: ['The nearness of danger']),
      CardSymbol(emoji: '🌕', nameTr: 'Ay', nameEn: 'Moon', meaningsTr: ['Kaçınılmaz ortaya çıkış'], meaningsEn: ['Everything will come to light']),
    ],
    57: [ // Eight of Swords
      CardSymbol(emoji: '⛓️', nameTr: 'Tutsak', nameEn: 'Captive', meaningsTr: ['Kendi kendine koyduğun sınırlar'], meaningsEn: ['Your self-imposed limitations']),
      CardSymbol(emoji: '⚔️', nameTr: 'Kılıçlar', nameEn: 'Swords', meaningsTr: ['Zihinsel hapishanen'], meaningsEn: ['In your mental prison']),
      CardSymbol(emoji: '🌙', nameTr: 'Ay', nameEn: 'Moon', meaningsTr: ['Görünmeyen gerçek'], meaningsEn: ['You are not seeing the truth']),
      CardSymbol(emoji: '🏰', nameTr: 'Kale', nameEn: 'Castle', meaningsTr: ['Gizli çıkış yolu'], meaningsEn: ['The way out actually exists']),
    ],
    58: [ // Nine of Swords
      CardSymbol(emoji: '😱', nameTr: 'Uykusuz Ruh', nameEn: 'Sleepless Soul', meaningsTr: ['Uykusuz bırakan kaygıların'], meaningsEn: ['Anxieties keeping you sleepless']),
      CardSymbol(emoji: '⚔️', nameTr: 'Kılıçlar', nameEn: 'Swords', meaningsTr: ['Zihindeki kâbus döngüsü'], meaningsEn: ['The nightmare cycle in your mind']),
      CardSymbol(emoji: '🛏️', nameTr: 'Yatak', nameEn: 'Bed', meaningsTr: ['Huzursuz ruhunun yansıması'], meaningsEn: ['Reflection of your restless soul']),
      CardSymbol(emoji: '🪟', nameTr: 'Pencere', nameEn: 'Window', meaningsTr: ['Yaklaşan şafak ve umut'], meaningsEn: ['Dawn approaches you must endure']),
    ],
    59: [ // Ten of Swords
      CardSymbol(emoji: '🩸', nameTr: 'Yıkılan Beden', nameEn: 'Fallen Body', meaningsTr: ['En derin düşüş noktası'], meaningsEn: ['Your deepest point of fall']),
      CardSymbol(emoji: '⚔️', nameTr: 'Kılıçlar', nameEn: 'Swords', meaningsTr: ['Daha kötüsü olmayan dip nokta'], meaningsEn: ['It cannot get worse than this']),
      CardSymbol(emoji: '🌅', nameTr: 'Güneş', nameEn: 'Sun', meaningsTr: ['Başlayan yeniden doğuş'], meaningsEn: ['Rebirth is beginning']),
      CardSymbol(emoji: '🏰', nameTr: 'Kale', nameEn: 'Castle', meaningsTr: ['Geride bırakılan eski düzen'], meaningsEn: ['The old order left behind']),
    ],
    60: [ // Page of Swords
      CardSymbol(emoji: '👦', nameTr: 'Genç', nameEn: 'Youth', meaningsTr: ['Keskin ve açık zekân'], meaningsEn: ['Your curious and sharp mind']),
      CardSymbol(emoji: '⚔️', nameTr: 'Kılıç', nameEn: 'Sword', meaningsTr: ['Yeni fikirlerinin gücü'], meaningsEn: ['The power of your new ideas']),
      CardSymbol(emoji: '☀️', nameTr: 'Güneş', nameEn: 'Sun', meaningsTr: ['Aydınlanan zihnin'], meaningsEn: ['An illuminated mind']),
      CardSymbol(emoji: '🧥', nameTr: 'Pelerin', nameEn: 'Cloak', meaningsTr: ['Gözüpek cesaretin'], meaningsEn: ['Your bold courage']),
      CardSymbol(emoji: '🐦', nameTr: 'Kuş', nameEn: 'Bird', meaningsTr: ['Özgür düşüncelerin'], meaningsEn: ['Your free thoughts']),
    ],
    61: [ // Knight of Swords
      CardSymbol(emoji: '🏇', nameTr: 'Şövalye', nameEn: 'Knight', meaningsTr: ['Hızlı ve keskin hamlelerin'], meaningsEn: ['Your fast and sharp moves']),
      CardSymbol(emoji: '🐎', nameTr: 'At', nameEn: 'Horse', meaningsTr: ['Durdurulamaz kararlılığın'], meaningsEn: ['Your unstoppable determination']),
      CardSymbol(emoji: '⚔️', nameTr: 'Kılıç', nameEn: 'Sword', meaningsTr: ['Zihinsel saldırı gücün'], meaningsEn: ['Your mental attack power']),
      CardSymbol(emoji: '⚡', nameTr: 'Şimşek', nameEn: 'Lightning', meaningsTr: ['Yaklaşan ani değişim'], meaningsEn: ['Sudden change is coming']),
      CardSymbol(emoji: '🧥', nameTr: 'Pelerin', nameEn: 'Cloak', meaningsTr: ['Geride bırakılan tereddüt'], meaningsEn: ['Hesitation left behind']),
    ],
    62: [ // Queen of Swords
      CardSymbol(emoji: '👸', nameTr: 'Kraliçe', nameEn: 'Queen', meaningsTr: ['Duygusal netliğin gücü'], meaningsEn: ['Power of your emotional clarity']),
      CardSymbol(emoji: '👑', nameTr: 'Taç', nameEn: 'Crown', meaningsTr: ['Zihinsel olgunluğun'], meaningsEn: ['Your mental maturity']),
      CardSymbol(emoji: '⚔️', nameTr: 'Kılıç', nameEn: 'Sword', meaningsTr: ['Keskin sezgi ve mantığın'], meaningsEn: ['Your sharp intuition and logic']),
      CardSymbol(emoji: '👋', nameTr: 'El', nameEn: 'Hand', meaningsTr: ['Gerçeği kabul etme cesaretin'], meaningsEn: ['Your courage to accept truth']),
      CardSymbol(emoji: '🦋', nameTr: 'Kelebek', nameEn: 'Butterfly', meaningsTr: ['Dönüşen düşüncelerin'], meaningsEn: ['Your transforming thoughts']),
      CardSymbol(emoji: '🪑', nameTr: 'Taht', nameEn: 'Throne', meaningsTr: ['Bağımsız duruşun'], meaningsEn: ['Your independent stance']),
      CardSymbol(emoji: '⚡', nameTr: 'Şimşek', nameEn: 'Lightning', meaningsTr: ['Geçmişten gelen dersler'], meaningsEn: ['Lessons from the past']),
    ],
    63: [ // King of Swords
      CardSymbol(emoji: '🤴', nameTr: 'Kral', nameEn: 'King', meaningsTr: ['Adil ve objektif karar gücün'], meaningsEn: ['Your fair and objective decision power']),
      CardSymbol(emoji: '👑', nameTr: 'Taç', nameEn: 'Crown', meaningsTr: ['Entelektüel otoriten'], meaningsEn: ['Your intellectual authority']),
      CardSymbol(emoji: '⚔️', nameTr: 'Kılıç', nameEn: 'Sword', meaningsTr: ['Mantığın keskin kenarı'], meaningsEn: ['The sharp edge of your logic']),
      CardSymbol(emoji: '⚔️', nameTr: 'Kılıç', nameEn: 'Sword', meaningsTr: ['Dengeleyici güç elinde'], meaningsEn: ['Balancing power in your hands']),
      CardSymbol(emoji: '🦅', nameTr: 'Kartal', nameEn: 'Eagle', meaningsTr: ['Yüksekten gören vizyonun'], meaningsEn: ['Your vision that sees from above']),
      CardSymbol(emoji: '🪑', nameTr: 'Taht', nameEn: 'Throne', meaningsTr: ['Tarafsız ve sağlam duruşun'], meaningsEn: ['Your impartial and firm stance']),
      CardSymbol(emoji: '✨', nameTr: 'Yıldız', nameEn: 'Star', meaningsTr: ['Evrensel adalet enerjisi'], meaningsEn: ['Universal justice energy']),
    ],
    64: [ // Ace of Pentacles
      CardSymbol(emoji: '✨', nameTr: 'El', nameEn: 'Hand', meaningsTr: ['Evrenin sana sunduğu fırsat'], meaningsEn: ['The opportunity the universe offers you']),
      CardSymbol(emoji: '🪙', nameTr: 'Sikke', nameEn: 'Coin', meaningsTr: ['Maddi bereketin filizi'], meaningsEn: ['The seed of your material abundance']),
      CardSymbol(emoji: '🌿', nameTr: 'Kemer', nameEn: 'Arch', meaningsTr: ['Bolluk bahçesinin girişi'], meaningsEn: ['The entrance to the garden of plenty']),
      CardSymbol(emoji: '🛣️', nameTr: 'Patika', nameEn: 'Path', meaningsTr: ['Refaha giden yolun'], meaningsEn: ['Your path to prosperity']),
      CardSymbol(emoji: '🌳', nameTr: 'Bahçe', nameEn: 'Garden', meaningsTr: ['Emeğinle büyüyecek toprak'], meaningsEn: ['Soil that will grow with your effort']),
    ],
    65: [ // Two of Pentacles
      CardSymbol(emoji: '🤹', nameTr: 'Jonglör', nameEn: 'Juggler', meaningsTr: ['Denge sanatında ustalaşman'], meaningsEn: ['You are mastering the art of balance']),
      CardSymbol(emoji: '🪙', nameTr: 'Sikke', nameEn: 'Coin', meaningsTr: ['İş hayatının dengesi'], meaningsEn: ['The balance of your work life']),
      CardSymbol(emoji: '🪙', nameTr: 'Sikke', nameEn: 'Coin', meaningsTr: ['Özel hayatının dengesi'], meaningsEn: ['The balance of your personal life']),
      CardSymbol(emoji: '♾️', nameTr: 'Bant', nameEn: 'Band', meaningsTr: ['Akışta kalmayı öğrenmek'], meaningsEn: ['You are learning to stay in flow']),
      CardSymbol(emoji: '🌊', nameTr: 'Dalga', nameEn: 'Wave', meaningsTr: ['İnişli çıkışlı dönemin'], meaningsEn: ['Your period of ups and downs']),
      CardSymbol(emoji: '⛵', nameTr: 'Gemi', nameEn: 'Ship', meaningsTr: ['Dışarıdan gelen değişkenler'], meaningsEn: ['External variables affecting you']),
    ],
    66: [ // Three of Pentacles
      CardSymbol(emoji: '👨‍🎨', nameTr: 'Usta', nameEn: 'Master', meaningsTr: ['Gelecek ustalık onayın'], meaningsEn: ['Recognition of your mastery is coming']),
      CardSymbol(emoji: '📜', nameTr: 'Mimarlar', nameEn: 'Architects', meaningsTr: ['Takım çalışmasının gücü'], meaningsEn: ['The power of teamwork']),
      CardSymbol(emoji: '🪙', nameTr: 'Sikkeler', nameEn: 'Coins', meaningsTr: ['İlk somut başarıların'], meaningsEn: ['Your first concrete achievements']),
      CardSymbol(emoji: '🏛️', nameTr: 'Kemer', nameEn: 'Arch', meaningsTr: ['Sağlam temellerin'], meaningsEn: ['You have solid foundations']),
      CardSymbol(emoji: '🪟', nameTr: 'Pencere', nameEn: 'Window', meaningsTr: ['Detaylara verdiğin özen'], meaningsEn: ['The care you give to details']),
    ],
    67: [ // Four of Pentacles
      CardSymbol(emoji: '😠', nameTr: 'Kontrolcü Adam', nameEn: 'Controlling Man', meaningsTr: ['Bırakamadığın kontrol'], meaningsEn: ['The control you cannot let go of']),
      CardSymbol(emoji: '🪙', nameTr: 'Başındaki Sikke', nameEn: 'Coin on Head', meaningsTr: ['Zihinsel takıntıların'], meaningsEn: ['Your mental obsessions']),
      CardSymbol(emoji: '🪙', nameTr: 'Kalbindeki Sikke', nameEn: 'Coin on Heart', meaningsTr: ['Kalbini kapadığın şeyler'], meaningsEn: ['Things you closed your heart to']),
      CardSymbol(emoji: '🪙', nameTr: 'Ayaktaki Sikkeler', nameEn: 'Coins at Feet', meaningsTr: ['Güvenlik ihtiyacın çok yüksek'], meaningsEn: ['Your need for security is very high']),
      CardSymbol(emoji: '🌞', nameTr: 'Güneş', nameEn: 'Sun', meaningsTr: ['Kaçırdığın hayat var dışarıda'], meaningsEn: ['There is life you are missing outside']),
    ],
    68: [ // Five of Pentacles
      CardSymbol(emoji: '🤕', nameTr: 'Yaralı Adam', nameEn: 'Wounded Man', meaningsTr: ['Zor dönemin ağırlığı'], meaningsEn: ['The weight of your difficult period']),
      CardSymbol(emoji: '🥶', nameTr: 'Üşüyen Kadın', nameEn: 'Freezing Woman', meaningsTr: ['Yardım istemeye cesaret et'], meaningsEn: ['Dare to ask for help']),
      CardSymbol(emoji: '🪟', nameTr: 'Vitray', nameEn: 'Stained Glass', meaningsTr: ['Görmediğin destek çok yakın'], meaningsEn: ['Unseen support is very close']),
      CardSymbol(emoji: '🪙', nameTr: 'Sikkeler', nameEn: 'Coins', meaningsTr: ['Manevi zenginliğine dön'], meaningsEn: ['Return to your spiritual richness']),
      CardSymbol(emoji: '❄️', nameTr: 'Kar', nameEn: 'Snow', meaningsTr: ['Geçici zorluk eriyecek'], meaningsEn: ['Temporary hardship will melt away']),
    ],
    69: [ // Six of Pentacles
      CardSymbol(emoji: '🤲', nameTr: 'Hayırsever', nameEn: 'Benefactor', meaningsTr: ['Verme ve alma dengen'], meaningsEn: ['Your balance of giving and receiving']),
      CardSymbol(emoji: '⚖️', nameTr: 'Terazi', nameEn: 'Scales', meaningsTr: ['Adil paylaşım enerjin'], meaningsEn: ['Your energy of fair sharing']),
      CardSymbol(emoji: '🪙', nameTr: 'Sikkeler', nameEn: 'Coins', meaningsTr: ['Sana gelen bolluk'], meaningsEn: ['Abundance coming to you']),
      CardSymbol(emoji: '🤲', nameTr: 'Yardım Alan', nameEn: 'The Receiver', meaningsTr: ['Uzatılan yardım eli'], meaningsEn: ['The helping hand extended']),
      CardSymbol(emoji: '🙏', nameTr: 'Yardım Bekleyen', nameEn: 'The Pleading One', meaningsTr: ['Sana uzanan eller'], meaningsEn: ['Hands reaching out to you']),
    ],
    70: [ // Seven of Pentacles
      CardSymbol(emoji: '🧑‍🌾', nameTr: 'Çiftçi', nameEn: 'Farmer', meaningsTr: ['Yakınlaşan sabrının meyvesi'], meaningsEn: ['The fruit of your patience is near']),
      CardSymbol(emoji: '🌳', nameTr: 'Çalı', nameEn: 'Bush', meaningsTr: ['Büyüyen yatırımların'], meaningsEn: ['Your growing investments']),
      CardSymbol(emoji: '🪙', nameTr: 'Sikkeler', nameEn: 'Coins', meaningsTr: ['Emeğinin görünen sonuçları'], meaningsEn: ['You see the results of your efforts']),
      CardSymbol(emoji: '🌞', nameTr: 'Güneş', nameEn: 'Sun', meaningsTr: ['Doğru zamanlamanın önemi'], meaningsEn: ['Right timing is very important']),
    ],
    71: [ // Eight of Pentacles
      CardSymbol(emoji: '🔨', nameTr: 'Zanaatkar', nameEn: 'Craftsman', meaningsTr: ['Ustalığa giden yolun'], meaningsEn: ['You are on the road to mastery']),
      CardSymbol(emoji: '🪙', nameTr: 'İşlenen Sikke', nameEn: 'Carved Coin', meaningsTr: ['Her detaya verdiğin emek'], meaningsEn: ['The effort you give to every detail']),
      CardSymbol(emoji: '🪙', nameTr: 'Tamamlanan Sikkeler', nameEn: 'Completed Coins', meaningsTr: ['Biriken deneyim ve beceri'], meaningsEn: ['Accumulating experience and skill']),
      CardSymbol(emoji: '🪚', nameTr: 'Tezgah', nameEn: 'Workbench', meaningsTr: ['Özveriyle çalışmanın ödülü'], meaningsEn: ['The reward of dedicated work']),
    ],
    72: [ // Nine of Pentacles
      CardSymbol(emoji: '💃', nameTr: 'Kadın', nameEn: 'Woman', meaningsTr: ['Kendi kendinle yetebilme gücün'], meaningsEn: ['Your power of self-sufficiency']),
      CardSymbol(emoji: '🦅', nameTr: 'Şahin', nameEn: 'Falcon', meaningsTr: ['Eğitilmiş sezgilerin'], meaningsEn: ['Your trained intuitions']),
      CardSymbol(emoji: '🪙', nameTr: 'Sikkeler', nameEn: 'Coins', meaningsTr: ['Maddi bağımsızlığın'], meaningsEn: ['Your financial independence']),
      CardSymbol(emoji: '🍇', nameTr: 'Bağ', nameEn: 'Vineyard', meaningsTr: ['Toplanan emeğin hasadı'], meaningsEn: ['You are reaping the harvest of your labor']),
      CardSymbol(emoji: '🪙', nameTr: 'Sikke', nameEn: 'Coin', meaningsTr: ['Ruhani zenginliğin de var'], meaningsEn: ['You also have spiritual wealth']),
    ],
    73: [ // Ten of Pentacles
      CardSymbol(emoji: '👨‍👩‍👧‍👦', nameTr: 'Aile', nameEn: 'Family', meaningsTr: ['Nesiller arası aktardığın miras'], meaningsEn: ['The legacy you pass across generations']),
      CardSymbol(emoji: '🪙', nameTr: 'Sikkeler', nameEn: 'Coins', meaningsTr: ['Kurulan kalıcı zenginlik'], meaningsEn: ['You are building lasting wealth']),
      CardSymbol(emoji: '🏛️', nameTr: 'Kemer', nameEn: 'Arch', meaningsTr: ['Köklü temellerin sağlam'], meaningsEn: ['Your deep foundations are solid']),
      CardSymbol(emoji: '🏰', nameTr: 'Konak', nameEn: 'Manor', meaningsTr: ['Kurduğun güvenli düzen'], meaningsEn: ['The secure order you built']),
      CardSymbol(emoji: '🐕', nameTr: 'Köpek', nameEn: 'Dog', meaningsTr: ['Sadakat ve aile bağların'], meaningsEn: ['Your loyalty and family bonds']),
    ],
    74: [ // Page of Pentacles
      CardSymbol(emoji: '👦', nameTr: 'Genç', nameEn: 'Youth', meaningsTr: ['Yeni öğrenme yolculuğun'], meaningsEn: ['Your new learning journey']),
      CardSymbol(emoji: '🪙', nameTr: 'Sikke', nameEn: 'Coin', meaningsTr: ['Dikkatli ve planlı adımların'], meaningsEn: ['Your careful and planned steps']),
      CardSymbol(emoji: '🌱', nameTr: 'Bereketli Vadi', nameEn: 'Fertile Valley', meaningsTr: ['Yüksek büyüme potansiyelin'], meaningsEn: ['Your growth potential is very high']),
      CardSymbol(emoji: '🛣️', nameTr: 'Patika', nameEn: 'Path', meaningsTr: ['Hedefe doğru adımların'], meaningsEn: ['You walk toward your goal step by step']),
      CardSymbol(emoji: '✨', nameTr: 'Yıldız', nameEn: 'Star', meaningsTr: ['İlhamının kaynağı'], meaningsEn: ['The source of your inspiration is here']),
    ],
    75: [ // Knight of Pentacles
      CardSymbol(emoji: '🏇', nameTr: 'Şövalye', nameEn: 'Knight', meaningsTr: ['Sabırlı ve kararlı ilerleyişin'], meaningsEn: ['Your patient and determined progress']),
      CardSymbol(emoji: '🐎', nameTr: 'At', nameEn: 'Horse', meaningsTr: ['Güvenilir ve istikrarlı güç'], meaningsEn: ['Reliable and stable power']),
      CardSymbol(emoji: '🪙', nameTr: 'Sikke', nameEn: 'Coin', meaningsTr: ['Maddi hedeflerine odağın'], meaningsEn: ['Your focus on material goals']),
      CardSymbol(emoji: '☀️', nameTr: 'Güneş', nameEn: 'Sun', meaningsTr: ['Kararlılığının meyvesi'], meaningsEn: ['The fruit of your determination']),
      CardSymbol(emoji: '🌾', nameTr: 'Tarla', nameEn: 'Field', meaningsTr: ['Emek verdiğin toprak'], meaningsEn: ['The soil you nurture with effort']),
    ],
    76: [ // Queen of Pentacles
      CardSymbol(emoji: '👸', nameTr: 'Kraliçe', nameEn: 'Queen', meaningsTr: ['Bolluk ve şefkat enerjin'], meaningsEn: ['Your energy of abundance and compassion']),
      CardSymbol(emoji: '🪙', nameTr: 'Sikke', nameEn: 'Coin', meaningsTr: ['Taşan koruyucu bereketin'], meaningsEn: ['Your protective blessings overflow']),
      CardSymbol(emoji: '🐇', nameTr: 'Tavşan', nameEn: 'Rabbit', meaningsTr: ['Doğurganlık ve bereket'], meaningsEn: ['Fertility and abundance']),
      CardSymbol(emoji: '🧺', nameTr: 'Sepet', nameEn: 'Basket', meaningsTr: ['Paylaştıkça çoğalan nimetler'], meaningsEn: ['Blessings that multiply as you share']),
      CardSymbol(emoji: '🌹', nameTr: 'Gül Bahçesi', nameEn: 'Rose Garden', meaningsTr: ['Güvenli ve güzel alanın'], meaningsEn: ['Your safe and beautiful space']),
      CardSymbol(emoji: '🏛️', nameTr: 'Sütun', nameEn: 'Pillar', meaningsTr: ['Seni taşıyan sağlam temeller'], meaningsEn: ['Your solid foundations carry you']),
    ],
    77: [ // King of Pentacles
      CardSymbol(emoji: '🤴', nameTr: 'Kral', nameEn: 'King', meaningsTr: ['Maddi dünyanın efendiliği'], meaningsEn: ['You are the master of the material world']),
      CardSymbol(emoji: '🪙', nameTr: 'Sikke', nameEn: 'Coin', meaningsTr: ['Dorukta olan finansal gücün'], meaningsEn: ['Your financial power is at its peak']),
      CardSymbol(emoji: '🪄', nameTr: 'Asa', nameEn: 'Scepter', meaningsTr: ['Hissedilen kararlı liderliğin'], meaningsEn: ['Your determined leadership is felt']),
      CardSymbol(emoji: '🪑', nameTr: 'Taht', nameEn: 'Throne', meaningsTr: ['Sarsılmaz otoriten'], meaningsEn: ['Your unshakable authority']),
      CardSymbol(emoji: '🍇', nameTr: 'Bağ', nameEn: 'Vineyard', meaningsTr: ['Biriktirdiğin zenginlik'], meaningsEn: ['The wealth you have accumulated']),
      CardSymbol(emoji: '🏰', nameTr: 'Kale', nameEn: 'Castle', meaningsTr: ['Kurduğun imparatorluk'], meaningsEn: ['The empire you built']),
      CardSymbol(emoji: '☀️', nameTr: 'Güneş', nameEn: 'Sun', meaningsTr: ['Başarının tacı sende'], meaningsEn: ['The crown of success is yours']),
    ],
  };
  if (minorSpecificSymbols.containsKey(cardId)) {
    final anchors = _cardAnchors[cardId] ?? [];
    return _withAnchors(minorSpecificSymbols[cardId]!, anchors);
  }


  // Minor Arcana — suit ve rank bazlı semboller (fallback)
  final suitIndex = ((cardId - 22) ~/ 14).clamp(0, 3);
  final rank = (cardId - 22) % 14;

  final suitSymbols = <List<CardSymbol>>[
    [ // Cups
      const CardSymbol(emoji: '🏆', nameTr: 'Kupa', nameEn: 'Cup', meaningsTr: ['Kalbinin kapasitesi'], meaningsEn: ['Your hearts capacity']),
      const CardSymbol(emoji: '💧', nameTr: 'Su', nameEn: 'Water', meaningsTr: ['Akan duyguların'], meaningsEn: ['Emotions in flow']),
      const CardSymbol(emoji: '🌊', nameTr: 'Deniz', nameEn: 'Sea', meaningsTr: ['Derinlerdeki dünyalar'], meaningsEn: ['Worlds in the depths']),
    ],
    [ // Wands
      const CardSymbol(emoji: '🪵', nameTr: 'Asa', nameEn: 'Wand', meaningsTr: ['Yaratıcı ateşin'], meaningsEn: ['Your creative fire']),
      const CardSymbol(emoji: '🔥', nameTr: 'Ateş', nameEn: 'Fire', meaningsTr: ['Sönmeyen alevin'], meaningsEn: ['Your eternal flame']),
      const CardSymbol(emoji: '🌱', nameTr: 'Filiz', nameEn: 'Sprout', meaningsTr: ['Kök salan fikirlerin'], meaningsEn: ['Ideas taking root']),
    ],
    [ // Swords
      const CardSymbol(emoji: '⚔️', nameTr: 'Kılıç', nameEn: 'Sword', meaningsTr: ['Düşüncenin gücü'], meaningsEn: ['Power of thought']),
      const CardSymbol(emoji: '☁️', nameTr: 'Bulut', nameEn: 'Cloud', meaningsTr: ['Dağılan zihinsel sis'], meaningsEn: ['Clearing mental fog']),
      const CardSymbol(emoji: '💨', nameTr: 'Rüzgâr', nameEn: 'Wind', meaningsTr: ['Savrulan eskiler'], meaningsEn: ['Old swept away']),
    ],
    [ // Pentacles
      const CardSymbol(emoji: '🪙', nameTr: 'Sikke', nameEn: 'Coin', meaningsTr: ['Somut sonuçların'], meaningsEn: ['Your tangible results']),
      const CardSymbol(emoji: '🌿', nameTr: 'Bahçe', nameEn: 'Garden', meaningsTr: ['Ektiğin tohumlar'], meaningsEn: ['Seeds you planted']),
      const CardSymbol(emoji: '⭐', nameTr: 'Yıldız', nameEn: 'Star', meaningsTr: ['Madde ve ruh köprüsü'], meaningsEn: ['Bridge of matter & spirit']),
    ],
  ];

  final rankSymbol = rank == 0
    ? const CardSymbol(emoji: '✨', nameTr: 'El', nameEn: 'Hand', meaningsTr: ['Evrenin açtığı kapı'], meaningsEn: ['Universe opens a door'])
    : rank >= 10
      ? const CardSymbol(emoji: '👤', nameTr: 'Figür', nameEn: 'Figure', meaningsTr: ['Sen ya da çevrenden biri'], meaningsEn: ['You or someone near'])
      : CardSymbol(emoji: rank.isEven ? '🔄' : '⚡', nameTr: rank.isEven ? 'Denge' : 'Aksiyon', nameEn: rank.isEven ? 'Balance' : 'Action', meaningsTr: [rank.isEven ? 'Durup değerlendirme zamanı' : 'Harekete geçme zamanı'], meaningsEn: [rank.isEven ? 'Time to pause' : 'Time for action']);

  final allSymbols = [...suitSymbols[suitIndex], rankSymbol];
  final anchors = _cardAnchors[cardId] ?? [];
  return _withAnchors(allSymbols, anchors);
}

/// Kart tonu
enum CardTone { heavy, soft, decision }

/// Hareket tipi
enum CardMovement { motion, stillness }

/// Yaşam fazı
enum CardPhase { beginning, ending, completion, awakening, neutral }

/// Akış tipi (3 kart arası)
enum FlowType { harmonious, conflicting, transformative }

class CardMeaning {
  final int id;

  // Tema
  final String themeTr;
  final String themeEn;

  // Ton / hareket / faz
  final CardTone tone;
  final CardMovement movement;
  final CardPhase phase;

  // Pozisyona göre anlamlar (Geçmiş / Şimdi / Yön)
  final String pastTr;
  final String pastEn;
  final String presentTr;
  final String presentEn;
  final String directionTr;
  final String directionEn;

  const CardMeaning({
    required this.id,
    required this.themeTr,
    required this.themeEn,
    required this.tone,
    required this.movement,
    required this.phase,
    required this.pastTr,
    required this.pastEn,
    required this.presentTr,
    required this.presentEn,
    required this.directionTr,
    required this.directionEn,
  });
}

// ============================================================
// 22 Büyük Arkana Kart Anlamları
// ============================================================
const Map<int, CardMeaning> cardMeanings = {
  0: CardMeaning(
    id: 0,
    themeTr: 'Yeni başlangıç, masumiyet, cesaret',
    themeEn: 'New beginning, innocence, courage',
    tone: CardTone.soft,
    movement: CardMovement.motion,
    phase: CardPhase.beginning,
    pastTr: 'Karttaki beyaz köpek gibi içgüdülerin seni korumuş; uçurumun kenarında olsan bile heybendeki saf niyetle o cesur adımı atmışsın.',
    pastEn: 'Like the white dog on the card, your instincts protected you; despite the cliff edge, you took that bold leap with pure intentions.',
    presentTr: 'Deli gibi uçuruma doğru yürüyen o figür sensin. Sırtındaki küçük heybeden başka bir şeye ihtiyacın yok; bilinmeyene güvenme zamanı.',
    presentEn: 'You are the figure walking toward the cliff. You need nothing but the small pouch on your back; it is time to trust the unknown.',
    directionTr: 'Ayaklarının altındaki uçuruma aldırma. Köpeğinin havlaması tehlikeyi değil, uyanışı simgeliyor. İlk adımı atmaktan korkma.',
    directionEn: 'Ignore the cliff beneath your feet. The dog barking symbolizes awakening, not danger. Do not fear taking the first step.',
  ),
  1: CardMeaning(
    id: 1,
    themeTr: 'İrade, yaratıcılık, ustalık',
    themeEn: 'Willpower, creativity, mastery',
    tone: CardTone.decision,
    movement: CardMovement.motion,
    phase: CardPhase.neutral,
    pastTr: 'Masadaki asa, kupa, kılıç ve tılsımı kullanmışsın. Başının üzerindeki sonsuzluk işareti gibi, iradeni potansiyele çevirmişsin.',
    pastEn: 'You used the wand, cup, sword, and pentacle on the table. Like the infinity sign above you, you turned will into potential.',
    presentTr: 'Büyücünün masasındaki tüm elementler önünde duruyor. Bir elin göğü (fikri), diğeri yeri (eylemi) işaret ediyor. Yeteneklerini birleştir.',
    presentEn: 'All elements on the Magicians table lay before you. With one hand to the sky and one to the earth, merge your skills.',
    directionTr: 'Masadaki araçları izlemek yerine eline al. Büyücünün sonsuz odaklanmasıyla düşündüklerini gerçeğe dönüştür.',
    directionEn: 'Pick up the tools instead of just looking at them. Transform your thoughts into reality with the Magicians infinite focus.',
  ),
  2: CardMeaning(
    id: 2,
    themeTr: 'Sezgi, gizem, içsel bilgelik',
    themeEn: 'Intuition, mystery, inner wisdom',
    tone: CardTone.soft,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'Karanlık ve aydınlık sütunlar arasında oturmuşsun. Dizindeki parşömen gibi sırlar açığa çıkaran bir evre yaşamışsın.',
    pastEn: 'You sat between the dark (B) and light (J) pillars. Like the scroll on his lap, it was a phase where secrets were revealed.',
    presentTr: 'Arkadaki narlarla süslü perde, henüz bilmediğin gizemleri saklıyor. Ayaklarının altındaki hilal gibi sezgilerine kulak ver.',
    presentEn: 'The pomegranate-adorned veil behind conceals mysteries you do not yet know. Listen to your intuition like the crescent at her feet.',
    directionTr: 'O iki siyah ve beyaz sütunun ortasından geç. Perdenin ardına bakmak için mantığı bırakıp kalbinin bilgeliğine güvenmelisin.',
    directionEn: 'Pass between the black and white pillars. To look behind the veil, leave logic and trust your hearts wisdom.',
  ),
  3: CardMeaning(
    id: 3,
    themeTr: 'Bereket, doğurganlık, şefkat',
    themeEn: 'Abundance, fertility, nurturing',
    tone: CardTone.soft,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'Başındaki on iki yıldızlı taç gibi, hayata büyük bir değer katmışsın. Çevrendeki buğday tarlaları ektiğin şefkatin sonucudur.',
    pastEn: 'Like the twelve-starred crown, you added immense value to life. The wheat fields around you are the result of the compassion you sowed.',
    presentTr: 'İmparatoriçe gibi rahat bir tahtta, ormanın ve suyun bereketi içindesin. Kendine ve etrafına sevgi ve bolluk enerjisi veriyorsun.',
    presentEn: 'Like the Empress on a comfortable throne, you are amidst the abundance of forest and water. You radiate love and abundance.',
    directionTr: 'Önündeki sararan buğdayları hasat etme zamanı. Yaratıcılığının doğurgan akışına izin ver, sevgiyle büyüt.',
    directionEn: 'It is time to harvest the golden wheat before you. Allow the fertile flow of your creativity to nurture with love.',
  ),
  4: CardMeaning(
    id: 4,
    themeTr: 'Otorite, yapı, düzen',
    themeEn: 'Authority, structure, order',
    tone: CardTone.decision,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'Koç başlı taş tahtın üzerindeki İmparator gibi, sınırları sen çizmişsin ve gri dağlar gibi sarsılmaz bir temel atmışsın.',
    pastEn: 'Like the Emperor on the ram-headed stone throne, you drew the boundaries and built an unshakable foundation like the gray mountains.',
    presentTr: 'Üzerindeki kırmızı zırh savaşmaya hazır olduğunu, elindeki küre ise kontrolün sende olduğunu gösteriyor. Düzeni sağla.',
    presentEn: 'Your red armor shows you are ready to fight, the orb in your hand shows you have control. Establish order.',
    directionTr: 'Arkadaki çıplak kayaçlar gibi mantıklı ve katı olmalısın. Kuralları sen koy ve krallığını disiplinle yönet.',
    directionEn: 'Be logical and solid like the barren rocks behind. Set the rules and rule your kingdom with discipline.',
  ),
  5: CardMeaning(
    id: 5,
    themeTr: 'Gelenek, rehberlik, inanç sistemi',
    themeEn: 'Tradition, guidance, belief system',
    tone: CardTone.decision,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'Önündeki iki rahip gibi, bir bilgenin ya da sistemin rehberliğini dinlemişsin. Çapraz duran iki anahtar sana eski kapıları açmış.',
    pastEn: 'Like the two priests before him, you listened to the guidance of a wise one or system. The crossed keys opened ancient doors.',
    presentTr: 'Aziz tahtında oturuyor ve bir eliyle hayır duası veriyor. Mevcut inançların, kuralların veya eğitimin seni şekillendiriyor.',
    presentEn: 'The Hierophant sits on his throne offering a blessing. Your current beliefs, rules, or education are shaping you.',
    directionTr: 'Ayaklarının önündeki anahtarları al. Öğrendiğin geleneklerden ders çıkar ama kendi içindeki o yüce inancı da bul.',
    directionEn: 'Take the keys at his feet. Learn from traditions but also find that supreme belief within yourself.',
  ),
  6: CardMeaning(
    id: 6,
    themeTr: 'Seçim, ilişki, uyum',
    themeEn: 'Choice, relationship, harmony',
    tone: CardTone.decision,
    movement: CardMovement.motion,
    phase: CardPhase.neutral,
    pastTr: 'Tıpkı Adem ile Havva ve arkalarındaki Bilgi Ağacı ile yılan gibi, masumiyetten çıkıp önemli bir seçim yapmak zorunda kalmışsın.',
    pastEn: 'Like Adam and Eve and the Tree of Knowledge with the snake, you stepped out of innocence and had to make an important choice.',
    presentTr: 'Yukarıdaki dev melek Rafael in kanatları altında, kalbin ve aklın omuz omuza. Bir yanda tutku, diğer yanda doğru değerler var.',
    presentEn: 'Under the wings of the giant angel Raphael, your heart and mind stand side by side. On one side is passion, the other, true values.',
    directionTr: 'Meleğin kutsadığı şekilde, sadece kendi ruhunla uyumlu olana yönel. Gözlerini kaçırma ve o gerçek seçimi yap.',
    directionEn: 'As the angel blesses, turn only to what aligns with your soul. Do not look away; make that true choice.',
  ),
  7: CardMeaning(
    id: 7,
    themeTr: 'İrade, zafer, ilerleme',
    themeEn: 'Willpower, victory, forward movement',
    tone: CardTone.decision,
    movement: CardMovement.motion,
    phase: CardPhase.neutral,
    pastTr: 'Arabayı çeken siyah ve beyaz iki sfenksi dizginlemişsin. Zıt güçleri tek bir hedefe sürerek o zorlu yolu geçmişsin.',
    pastEn: 'You harnessed the black and white sphinxes pulling the chariot. You drove opposing forces to a single goal and passed that rocky road.',
    presentTr: 'Zırhın ve yıldızlı gölgeliğin altındasın. Önündeki sfenksler farklı yönlere gitmek istese de iradenle onları kontrol ediyorsun.',
    presentEn: 'You are under the armor and starry canopy. The sphinxes want to go different ways, but your will controls them.',
    directionTr: 'Asanın gücüyle zıtlıkları dengele. Arkandaki şehri bırak, gözünü hedefe dik ve dizginleri sıkı tutarak ilerle.',
    directionEn: 'Balance contradictions with the power of your wand. Leave the city behind, set your eyes on the goal, and ride forward.',
  ),
  8: CardMeaning(
    id: 8,
    themeTr: 'İç güç, sabır, cesaret',
    themeEn: 'Inner strength, patience, courage',
    tone: CardTone.soft,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'Vahşi bir aslanın çenesini şefkatle okşayan o kadın gibi, en zorlu duygularını veya krizlerini yumuşak bir sabırla yatıştırmışsın.',
    pastEn: 'Like the woman gently caressing the fierce lions jaw, you soothed your toughest emotions or crises with soft patience.',
    presentTr: 'Başının üstünde sonsuzluk işareti parlıyor. Kaba kuvvete ihtiyacın yok; içindeki o vahşi aslan, senin şefkatine boyun eğmiş durumda.',
    presentEn: 'The infinity sign shines above your head. You need no brute force; the wild lion within has bowed to your compassion.',
    directionTr: 'Düşmanlarını veya korkularını zorlayarak değil, aslanı evcilleştiren o narin ellerinle sevgi ve cesaretle aşacaksın.',
    directionEn: 'You will overcome enemies or fears not by forcing them, but with the gentle hands and love that tamed the lion.',
  ),
  9: CardMeaning(
    id: 9,
    themeTr: 'İçe dönüş, arayış, yalnızlık',
    themeEn: 'Introspection, seeking, solitude',
    tone: CardTone.soft,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'Karlı ve soğuk dağların zirvesinde tek başına yürümüşsün. Kalabalıkları geride bırakıp kendi fenerinin ışığına sığınmışsın.',
    pastEn: 'You walked alone on the snowy, cold mountain peaks. Leaving crowds behind, you sought refuge in the light of your own lantern.',
    presentTr: 'Gri bir cüppe içinde sarsılmaz bir asaya dayanıyorsun. Elindeki yıldızlı fener, başkalarına değil, sadece senin önünü aydınlatıyor.',
    presentEn: 'In a gray cloak leaning on an unshakable staff, the starry lantern in your hand illuminates only your own path, no one elses.',
    directionTr: 'Zirvedeki yalnızlığını koru. Bilgelik dışarıdan gelmeyecek; karanlıkta asana yaslanıp fenerinin içindeki altı köşeli yıldıza bak.',
    directionEn: 'Maintain your solitude on the peak. Wisdom wont come from outside; lean on your staff in the dark and look at the star in your lantern.',
  ),
  10: CardMeaning(
    id: 10,
    themeTr: 'Kader, döngü, dönüm noktası',
    themeEn: 'Fate, cycle, turning point',
    tone: CardTone.decision,
    movement: CardMovement.motion,
    phase: CardPhase.neutral,
    pastTr: 'Çarkın üstündeki kılıçlı Sfenks hükmünü vermiş, Anubis seni yukarı taşırken Yılan aşağı çekmiş. Hayatın büyük döngüsü seni buraya getirmiş.',
    pastEn: 'The sword-wielding Sphinx passed judgment, Anubis carried you up while the Snake pulled you down. Lifes great cycle brought you here.',
    presentTr: 'Burç sembolleriyle dolu dev tekerlek durmaksızın dönüyor. İyi ya da kötü yok; şu an sadece kadersel bir değişimin tam merkezindesin.',
    presentEn: 'The giant wheel filled with zodiac symbols spins endlessly. There is no good or bad; you are directly at the center of fateful change.',
    directionTr: 'Çarkın üzerindeki yılan da, Anubis de dönmeye mecburdur. Kontrolü bırak, tekerlek dönerken merkeze odaklan ve değişimi kabul et.',
    directionEn: 'Both the snake and Anubis must turn with the wheel. Let go of control, focus on the center as it spins, and accept the change.',
  ),
  11: CardMeaning(
    id: 11,
    themeTr: 'Adalet, denge, doğruluk',
    themeEn: 'Justice, balance, truth',
    tone: CardTone.decision,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'İki sütun arasındaki mor perdenin önünde oturan o yargıç gibi, ektiklerinin sonuçlarını tartan terazide kendi geçmişinle hesaplaşmışsın.',
    pastEn: 'Like the judge sitting before the purple veil between two pillars, you reckoned with your past on the scales that weighed what you sowed.',
    presentTr: 'Bir elinde karar kılıcı yukarı kalkmış, diğer elindeki terazi kusursuz bir dengede. Gerçekler çıplak ve tüm yanılmalar kesilip atılıyor.',
    presentEn: 'One hand raises the sword of decision, the other elegantly balances the scales. Truths are bare and all illusions are cut away.',
    directionTr: 'Gözlerindeki bağı kendin çöz. İki ucu keskin kılıç adaleti sağlasın diye, terazinin ruhunu dinleyerek dürüstçe adım at.',
    directionEn: 'Untie the blindfold yourself. So the double-edged sword can bring justice, listen to the spirit of the scale and step honestly.',
  ),
  12: CardMeaning(
    id: 12,
    themeTr: 'Fedakârlık, bekleyiş, farklı bakış açısı',
    themeEn: 'Sacrifice, waiting, new perspective',
    tone: CardTone.soft,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'T harfi şeklindeki canlı bir ağaca ayağından asılmışsın ama yüzün acı değil, huzur doluymuş. Kendi isteğinle dünyayı baş aşağı görmüşsün.',
    pastEn: 'You were hung by the foot on a T-shaped living tree, yet your face showed not pain, but peace. You willingly saw the world upside down.',
    presentTr: 'Başının etrafında asılı dururken bile alev alev yanan bir hale var. Hiçbir yere gitmiyorsun ama zihnin daha önce hiç olmadığı kadar aydınlık.',
    presentEn: 'There is a blazing halo around your head even as you hang suspended. You are going nowhere, but your mind is more luminous than ever.',
    directionTr: 'Ayağındaki ipi kesmeye çalışma. Serbest kalacağın o aydınlanma anına kadar dünyayı o farklı ve asılı perspektiften izlemeye devam et.',
    directionEn: 'Do not try to cut the rope on your foot. Observe the world from this hanging perspective until the enlightenment sets you free.',
  ),
  13: CardMeaning(
    id: 13,
    themeTr: 'Dönüşüm, kapanış, yenilenme',
    themeEn: 'Transformation, ending, renewal',
    tone: CardTone.heavy,
    movement: CardMovement.motion,
    phase: CardPhase.ending,
    pastTr: 'Zırhlı bir iskelet beyaz atıyla ezip geçmiş; o eski kralın tacı düşmüş ve senin eski alışkanlıklarının hepsi yeryüzünden silinmiş.',
    pastEn: 'An armored skeleton rode its white horse over everything; the old kings crown fell and all your former habits were wiped from the earth.',
    presentTr: 'Ölüm şövalyesi karşında duruyor fakat ufukta iki kule arasından o parlak güneş doğmak üzere. Bu bir bitiş değil, ruhsal bir temizliktir.',
    presentEn: 'The Death knight stands before you, but on the horizon, a bright sun is rising between the towers. This is not an end, but a spirit purge.',
    directionTr: 'Atın önünde diz çöken çocuk gibi direnişi bırak. Yeni gün doğarken, ölü topraklarda açacak olan o mistik gülü (bayraktaki gül) kabul et.',
    directionEn: 'Drop the resistance like the child kneeling before the horse. As the new dawn nears, accept the mystic rose on the black flag.',
  ),
  14: CardMeaning(
    id: 14,
    themeTr: 'Denge, ılımlılık, sabır',
    themeEn: 'Balance, moderation, patience',
    tone: CardTone.soft,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'Kızıl kanatlı meleğin bir ayağı suda diğeri karadaymış. Sen de hayatındaki zıt güçleri — duyguları ve mantığı — ustaca dengeleyerek uyuma kavuşmuşsun.',
    pastEn: 'The red-winged angel had one foot in water, one on land. You too achieved harmony by masterfully balancing opposing forces — emotions and logic.',
    presentTr: 'Göğsünde aydınlık bir üçgen, alnında güneş mühürü olan melek senin yanında. Duygularınla mantığın mükemmel bir dengede buluşuyor.',
    presentEn: 'The angel with a luminous triangle on the chest and a sun symbol on the forehead stands beside you. Your emotions and reason meet in perfect balance.',
    directionTr: 'Acele etme, ılımlılığın gücüne güven. Zıtlıkları birleştiren melek gibi, sabırla ve huzurla ilerle. Denge kurduğunda arkadaki dağlara giden yol kendiliğinden açılacak.',
    directionEn: 'Do not rush, trust in the power of moderation. Like the angel that unites opposites, advance with patience and peace. When balance is found, the path to the mountains will open on its own.',
  ),
  15: CardMeaning(
    id: 15,
    themeTr: 'Bağımlılık, gölge, yüzleşme',
    themeEn: 'Attachment, shadow, confrontation',
    tone: CardTone.heavy,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'Tahtında oturan boynuzlu ve yarasa kanatlı Şeytanın tahtına prangalarla bağlanmışsın. Ama zincirler o kadar bolmuş ki, sadece korkudan kaçamamışsın.',
    pastEn: 'You were chained to the throne of the horned, bat-winged Devil. But the chains were so loose, you only stayed bound out of fear.',
    presentTr: 'Şeytanın tahtına bağlısın ama zincirler aslında gevşek; seni tutan o değil, kendi korkuların. Karanlığın içinde körü körüne bir bağımlılığa sıkışıp kalmış gibisin.',
    presentEn: 'The chained figures carry grapes and flames on their tails, surrendering to base desires. You seem stuck in a blind addiction in the dark.',
    directionTr: 'Boynundaki o gevşek zinciri ellerinle çıkarabilirsin! Şeytan asasını ne kadar kaldırmış olursa olsun, karanlık gölgende tutsak değilsin.',
    directionEn: 'You can lift that loose chain off your neck with your bare hands! No matter how high the Devil raises his torch, you are not a prisoner.',
  ),
  16: CardMeaning(
    id: 16,
    themeTr: 'Yıkım, kriz, ani değişim',
    themeEn: 'Destruction, crisis, sudden change',
    tone: CardTone.heavy,
    movement: CardMovement.motion,
    phase: CardPhase.ending,
    pastTr: 'Karanlık gökte çakan o şiddetli şimşek sarı tacı devirmiş ve üzerine güvendiğin o yüksek taş kule paramparça alevler içinde çökmüş.',
    pastEn: 'The fierce lightning struck the yellow crown, and the high stone tower you relied on collapsed in flames and shattered ruins.',
    presentTr: 'İki figür alev alan kuleden tepeüstü aşağı düşüyor. Sahip olduğunu sandığın her inanç, kurduğun her plan büyük bir şokla yerle bir oluyor.',
    presentEn: 'Two figures are plunging headfirst from the burning tower. Every belief you held, every plan you built is crashing down in shock.',
    directionTr: 'Kül olan kuleyi kurtarmak için çabalama; yanıp kül olmasına izin ver. O yıldırım senin felaketin değil, yanılsamanı yok eden bir gerçektir.',
    directionEn: 'Do not fight to save the turning ash; let it burn entirely. That lightning is not your doom, but the truth destroying your illusions.',
  ),
  17: CardMeaning(
    id: 17,
    themeTr: 'Umut, ilham, iyileşme',
    themeEn: 'Hope, inspiration, healing',
    tone: CardTone.soft,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'Gecenin o yoğun karanlığı dağılmış ve gökyüzü yepyeni bir umutla aydınlanmış. Ruhunu ağırlaştıran tüm yükleri, yeryüzüne dökülen o şifalı sularla akıtıp arınmışsın.',
    pastEn: 'The dense darkness of the night has dispersed, and the sky is illuminated with newfound hope. You have let all the burdens weighing on your soul flow away with the healing waters poured onto the earth, purifying yourself.',
    presentTr: 'Kozmik bir rehber gibi parlayan o ilahi yıldız, evrenin şifa enerjisini üzerine döküyor. Uzun zamandır beklediğin o derin huzur duygusu usulca hayatına sızıyor.',
    presentEn: 'That divine star, shining like a cosmic guide, pours the universes healing energy upon you. The profound sense of peace you have long awaited is quietly seeping into your life.',
    directionTr: 'Önündeki o berrak ve şifalı havuza korkusuzca yaklaş. Evrenin sana sunduğu bu derin ilhamı kucaklayarak ruhunu yepyeni bir başlangıca taşıyacaksın.',
    directionEn: 'Approach that clear and healing pool before you without fear. By embracing this deep inspiration offered by the universe, you will carry your soul to a brand new beginning.',
  ),
  18: CardMeaning(
    id: 18,
    themeTr: 'Yanılsama, korku, bilinçaltı',
    themeEn: 'Illusion, fear, subconscious',
    tone: CardTone.heavy,
    movement: CardMovement.stillness,
    phase: CardPhase.neutral,
    pastTr: 'Dolunayın ışığı altında gölgelerin dans ettiği bir dönemden geçmişsin. Neyin gerçek neyin yanılsama olduğunu ayırt edemediğin bir süreçte, sezgilerin seni sessizce yönlendirmiş.',
    pastEn: 'You passed through a time where shadows danced under the full moon. In a period where you could not distinguish real from illusion, your intuition quietly guided you.',
    presentTr: 'Dolunayın altında iki kule arasındaki yol belirsiz ve karanlık. Gördüğün her şey gerçek olmayabilir. Sezgilerine kulak ver ama korkularının seni yönlendirmesine izin verme.',
    presentEn: 'The path between the two towers under the full moon is uncertain and dark. Not everything you see may be real. Listen to your intuition but do not let your fears steer you.',
    directionTr: 'Karanlıktan korkma ama her gördüğüne de körü körüne güvenme. İçindeki korkular gerçekte sandığından çok daha küçük. Cesaretini topla, o gölgeli yolda yürümeye devam et ve iki kulenin arasından geç.',
    directionEn: 'Do not fear the darkness, but do not blindly trust everything you see. The fears within are far smaller than you imagine. Gather your courage, keep walking the shadowy path, and pass between the two towers.',
  ),
  19: CardMeaning(
    id: 19,
    themeTr: 'Başarı, canlılık, aydınlanma',
    themeEn: 'Success, vitality, enlightenment',
    tone: CardTone.soft,
    movement: CardMovement.motion,
    phase: CardPhase.neutral,
    pastTr: 'Güneş bütün karanlıkları delmiş. Çıplak, neşeli çocuk gri taş duvarın ardından beyaz atının üstünde ellerini açarak kucağına bir lütuf gibi inmiş.',
    pastEn: 'The sun pierced all darkness. Experiencing true joy, the naked playful child rode the white horse from behind the wall like a blessing.',
    presentTr: 'Ayçiçekleri yüzünü sana değil güneşe dönmüş — çünkü sen zaten güneşin kendisisin. Saklayacak bir şeyin yok, her şey apaçık ve aydınlık. En parlak dönemini yaşıyorsun.',
    presentEn: 'The yellow sunflowers behind face the magnificent Sun, not you. You are bathed in a shining light that requires hiding absolutely nothing.',
    directionTr: 'Çocuğun tuttuğu kırmızı zafer bayrağını sen devral. Gökyüzündeki neşeli Güneş gibi adımlarını aydınlat, kalbin ısınsın ve başarıya koş.',
    directionEn: 'Take the red banner of victory the child holds. Let your steps be illuminated like the joyful Sun, let your heart warm up, and run to success.',
  ),
  20: CardMeaning(
    id: 20,
    themeTr: 'Uyanış, yargı, çağrı',
    themeEn: 'Awakening, judgement, calling',
    tone: CardTone.heavy,
    movement: CardMovement.motion,
    phase: CardPhase.awakening,
    pastTr: 'Kozmik bir melek göklerden bulutlar arasında altın sûrunu üflemiş. Sen o ilahi sesi duymuş ve geçmişte sıkıştığın dar dünyadan kollarını açıp ışığa çıkmışsın.',
    pastEn: 'A cosmic angel blew its golden horn from the clouds. You heard the divine call and rose to the light with open arms from the narrow world of your past.',
    presentTr: 'Kollarını göğe doğru uzatmış o silüetler yeniden can buluyor. Kendini eleştirmeyi bıraktın; şimdi aydınlık bir ruhsal çağrıya uyanıyorsun.',
    presentEn: 'Those silhouettes reaching out to the sky are coming alive again. You have stopped judging yourself; now you awaken to a bright spiritual calling.',
    directionTr: 'Göklerden yankılanan o sûrun sesi senin nihai yükselişini müjdeliyor. Unutulmuş güzel hayallerin sonsuz bir aydınlık içinde yeniden doğacak.',
    directionEn: 'The sound of the horn echoing from the heavens heralds your ultimate rise. Your forgotten beautiful dreams will be reborn in endless light.',
  ),
  21: CardMeaning(
    id: 21,
    themeTr: 'Tamamlanma, bütünlük, zafer',
    themeEn: 'Completion, wholeness, triumph',
    tone: CardTone.soft,
    movement: CardMovement.motion,
    phase: CardPhase.completion,
    pastTr: 'Uzun bir yolculuğun sonuna gelmiş ve başladığın yere bambaşka biri olarak dönmüşsün. Hayatındaki büyük bir döngü kapanmış, ektiğin her tohum meyvesini vermiş.',
    pastEn: 'You closed the cycle with the oval wreath and the lion, ox, eagle, and angel at the corners. Like the infinite dancer, your journey became a masterpiece.',
    presentTr: 'Her şey yerli yerinde. Ruhun, aklın, kalbin ve bedenin mükemmel bir uyum içinde dans ediyor. Tamamlanmış bir bütünsün ve evren bunu kutluyor.',
    presentEn: 'Floating gracefully inside the green wreath, the naked woman holds wands of balance. The spiritual and physical are in absolute perfection.',
    directionTr: 'Bu döngü kapandı ama yeni bir kapı açılıyor. Kazandığın bilgeliği yanına al ve bir sonraki seviyeye adım at. Başardın — şimdi kutlama zamanı.',
    directionEn: 'The four cosmic elements are your witnesses. You are the departure and the destination. Wrap in that purple ribbon and celebrate your masterpiece!',
  ),
  // ============================================================
  // MINOR ARCANA — CUPS (Kupalar) — 14 kart (id: 22–35)
  // ============================================================
  22: CardMeaning(id: 22, themeTr: 'Duygusal bolluk, yeni aşk, ruhani hediye', themeEn: 'Emotional abundance, new love, spiritual gift', tone: CardTone.soft, movement: CardMovement.stillness, phase: CardPhase.beginning,
    pastTr: 'Gökyüzünden uzanan gizemli bir el sana altın bir kupa sunmuş ve o kupadan beş saf su akışı dökülmüş. Kalbine ilk kez dokunan o duygu, ruhunu sonsuza dek değiştirmiş.',
    pastEn: 'A mysterious hand from the sky offered you a golden cup with five streams of pure water flowing from it. That first emotion that touched your heart changed your soul forever.',
    presentTr: 'Kupanın içinden yükselen güvercin, ağzında kutsal bir ekmekle sana barış getiriyor. Duygusal bir bereket kapısı ardına kadar açık; nilüferler suyun üzerinde senin için çiçek açıyor.',
    presentEn: 'The dove rising from the cup brings peace with sacred bread in its mouth. A door of emotional abundance is wide open; lotus flowers bloom on the water just for you.',
    directionTr: 'Kupadan taşan o beş su akışını takip et — her biri bir duygunun nehridir. Kalbin ne söylüyorsa onu yap, çünkü evren sana duygusal bir armağan sunuyor.',
    directionEn: 'Follow the five streams overflowing from the cup — each is a river of emotion. Do what your heart says, for the universe offers you an emotional gift.',
  ),
  23: CardMeaning(id: 23, themeTr: 'Karşılıklı bağ, ortaklık, derin çekim', themeEn: 'Mutual bond, partnership, deep attraction', tone: CardTone.soft, movement: CardMovement.stillness, phase: CardPhase.neutral,
    pastTr: 'İki kişi birbirinin gözüne bakarak kupalarını buluşturmuş. Aralarında ışıldayan şifa ve denge asası Caduceus, bu bağı kutsal ilan etmiş. O karşılıklı söz hâlâ geçerliliğini koruyor.',
    pastEn: 'Two people met each others gaze and clinked their cups. The glowing Caduceus staff of healing and balance between them declared this bond sacred. That mutual promise still holds.',
    presentTr: 'Karşındaki kişiyle aranızda görünmez ama güçlü bir enerji köprüsü var. İki kupanın buluştuğu o nokta, ruhların birbirini tanıdığı andır.',
    presentEn: 'There is an invisible but powerful energy bridge between you and the person before you. The point where two cups meet is the moment souls recognize each other.',
    directionTr: 'Kupanı kaldır ve karşındakine uzat. Gerçek bağ eşit paylaşımdadır. Korkularını bırak, o köprüyü geç — karşı tarafta seni bekleyen bir ruh var.',
    directionEn: 'Raise your cup and extend it to the one before you. True bonds exist in equal sharing. Let go of fears and cross that bridge.',
  ),
  24: CardMeaning(id: 24, themeTr: 'Kutlama, dostluk, topluluk neşesi', themeEn: 'Celebration, friendship, communal joy', tone: CardTone.soft, movement: CardMovement.motion, phase: CardPhase.neutral,
    pastTr: 'Üç dost kupalarını havaya kaldırıp dans etmiş. Etraflarındaki meyveler ve çiçekler bu birlikteliğin bereketinin kanıtıymış. O kutlama senin ruhuna kazınmış.',
    pastEn: 'Three friends raised their cups to the sky and danced. The fruits and flowers around them symbolized the abundance of this unity. That celebration is etched in your soul.',
    presentTr: 'Hayatında kutlamaya değer bir an var. Üç kupanın buluştuğu o neşe halkasında sen de varsın. Sevdiklerinle paylaşılan mutluluk ikiye katlanıyor.',
    presentEn: 'There is a moment worth celebrating in your life. You are part of that circle of joy where three cups meet. Happiness shared with loved ones doubles.',
    directionTr: 'Sevinçlerini paylaş, yalnız kutlama yapma. Üç kupanın dansı gibi, topluluk seni güçlendirecek. Dostlarını topla ve hayatı kutla.',
    directionEn: 'Share your joys, do not celebrate alone. Like the dance of three cups, community will strengthen you. Gather your friends and celebrate life.',
  ),
  25: CardMeaning(id: 25, themeTr: 'İç sıkıntısı, kaçırılan fırsat, bezginlik', themeEn: 'Apathy, missed opportunity, discontent', tone: CardTone.heavy, movement: CardMovement.stillness, phase: CardPhase.neutral,
    pastTr: 'Ağacın altında kollarını kavuşturup oturmuşsun. Önündeki üç kupaya bakmışsın ama arkandan uzanan gizemli elin sunduğu dördüncü kupayı fark etmemişsin.',
    pastEn: 'You sat under the tree with arms crossed. You stared at the three cups before you, but a mysterious hand behind offered a fourth cup — and you did not notice.',
    presentTr: 'Elindeki nimetlere bıkkınlıkla bakıyorsun ama görmediğin bir fırsat tam arkanda bekliyor. Bulutlardan uzanan o el, senin için yeni bir kapı açıyor.',
    presentEn: 'You look at your blessings with boredom, yet an unseen opportunity waits right behind you. That hand reaching from the clouds opens a new door for you.',
    directionTr: 'Başını çevir ve o dördüncü kupayı gör. Sahip olduklarına şükret ama yeniye de kapını kapat. Bezginlik en tehlikeli körlüktür.',
    directionEn: 'Turn your head and see that fourth cup. Be grateful for what you have, but do not shut the door to the new. Apathy is the most dangerous blindness.',
  ),
  26: CardMeaning(id: 26, themeTr: 'Kayıp, hayal kırıklığı, umut', themeEn: 'Loss, disappointment, remaining hope', tone: CardTone.heavy, movement: CardMovement.stillness, phase: CardPhase.neutral,
    pastTr: 'Siyah pelerinli figür, devrilmiş üç kupanın önünde yas tutmuş. Dökülen kırmızı şarap gibi kaybettiğin şeyler seni derin bir üzüntüye gömmüş. Ama arkadaki iki dolu kupa hep oradaymış.',
    pastEn: 'The cloaked figure mourned before three overturned cups. What you lost buried you in deep sorrow like spilled red wine. But two full cups still stand behind.',
    presentTr: 'Üç kupan devrildi ve acı çekiyorsun. Ama arkana bak — orada hâlâ ayakta duran iki kupa var. Köprü seni eve götürmeye hazır. Kaybettiğine değil, kalanına odaklan.',
    presentEn: 'Three cups have fallen and you suffer. But look behind — two cups still stand. The bridge is ready to take you home. Focus not on what you lost, but what remains.',
    directionTr: 'Dökülen suyu geri koyamazsın ama arkadaki iki kupayı alıp köprüyü geçebilirsin. Yas tut ama orada kalma. Umut her zaman geride duranlardadır.',
    directionEn: 'You cannot put spilled water back, but you can take the two cups behind you and cross the bridge. Mourn, but do not stay there. Hope always lives in what remains.',
  ),
  27: CardMeaning(id: 27, themeTr: 'Nostalji, masumiyet, çocukluk anıları', themeEn: 'Nostalgia, innocence, childhood memories', tone: CardTone.soft, movement: CardMovement.stillness, phase: CardPhase.neutral,
    pastTr: 'Küçük bir çocuk, çiçeklerle dolu bir kupayı büyük çocuğa uzatmış. Eski evin bahçesindeki o sıcak anılar gibi, geçmişteki masumiyetin seni korumuş.',
    pastEn: 'A small child extended a cup full of flowers to the older child. Like warm memories in the garden of the old house, your past innocence protected you.',
    presentTr: 'Geçmişin güzel anıları seni çağırıyor. Altı kupanın her birindeki beyaz çiçekler, saf ve temiz bir zamanı simgeliyor. O masumiyete geri dönme vakti.',
    presentEn: 'Beautiful memories of your past are calling. The white flowers in each of the six cups symbolize a pure and clean time. Time to return to that innocence.',
    directionTr: 'Geçmişe saplanma ama ondan ilham al. O çocuğun saf gülümsemesini hatırla ve bugünü o gözlerle gör. Nostalji bir hapishane değil, bir pusula olmalı.',
    directionEn: 'Do not get stuck in the past, but draw inspiration from it. Remember that childs pure smile and see today through those eyes. Nostalgia should be a compass, not a prison.',
  ),
  28: CardMeaning(id: 28, themeTr: 'Hayal, seçenek bolluğu, yanılsama', themeEn: 'Fantasy, abundant choices, illusion', tone: CardTone.decision, movement: CardMovement.stillness, phase: CardPhase.neutral,
    pastTr: 'Yedi kupa bulutların içinden belirmiş — her biri farklı bir vaat taşırmış: servet, güzellik, zafer... Ama hepsi birer gölge miymiş yoksa gerçek mi, bunu hiç anlayamamışsın.',
    pastEn: 'Seven cups appeared within clouds — each carrying a different promise: wealth, beauty, victory... But you never knew if they were shadows or real.',
    presentTr: 'Önünde yedi farklı hayal parlıyor ama hangisi gerçek? Bulutların içindeki kupalar seni büyülüyor. Dikkat et: ejderha, yılan, kale, mücevher — hepsi aynı anda gerçek olamaz.',
    presentEn: 'Seven different dreams shimmer before you, but which is real? The cups within clouds enchant you. Beware: dragon, snake, castle, jewel — they cannot all be real at once.',
    directionTr: 'Hayallerinin esiri olma. Yedi kupadan sadece birini seç ve o birinin peşinden gerçeklikle yürü. Hepsini istemek hiçbirini alamamak demektir.',
    directionEn: 'Do not become a prisoner of your dreams. Choose only one of the seven cups and pursue it with reality. Wanting all means getting none.',
  ),
  29: CardMeaning(id: 29, themeTr: 'Arayış, geride bırakma, ruhani yolculuk', themeEn: 'Search, leaving behind, spiritual journey', tone: CardTone.decision, movement: CardMovement.motion, phase: CardPhase.ending,
    pastTr: 'Kırmızı pelerinli figür, düzenli dizilmiş sekiz kupaya sırtını dönmüş ve dağlara doğru yürümeye başlamış. Tutulma altındaki ay, bu ayrılığı kutsal kılmış.',
    pastEn: 'The red-cloaked figure turned their back on eight neatly arranged cups and began walking toward the mountains. The eclipse-moon made this departure sacred.',
    presentTr: 'Sahip olduğun şeyler artık seni doyurmuyor. Sekiz kupan yerinde duruyor ama ruhun daha fazlasını arıyor. Ay tutulması altında yeni bir yolculuğa çıkma zamanı.',
    presentEn: 'What you have no longer fulfills you. Your eight cups stand in place, but your soul seeks more. Under the lunar eclipse, it is time for a new journey.',
    directionTr: 'Geride bırakmak kayıp değil, cesaret eylemidir. O sekiz kupayı şükranla selamla ve dağlara doğru yürü. Aradığın şey bu kupalar arasında değil.',
    directionEn: 'Leaving behind is not loss, but an act of courage. Greet those eight cups with gratitude and walk toward the mountains. What you seek is not among these cups.',
  ),
  30: CardMeaning(id: 30, themeTr: 'Dilek gerçekleşmesi, tatmin, bolluk', themeEn: 'Wish fulfillment, satisfaction, abundance', tone: CardTone.soft, movement: CardMovement.stillness, phase: CardPhase.completion,
    pastTr: 'Kollarını kavuşturmuş, memnun figür, arkasında gökkuşağı gibi dizilmiş dokuz altın kupanın önünde gülümsemiş. O an, her şeyin yolunda olduğunu hissettiğin en saf anmış.',
    pastEn: 'The content figure with arms folded smiled before nine golden cups arranged like a rainbow behind him. That was the purest moment when you felt everything was right.',
    presentTr: 'Dokuz kupa arkanda altın bir kemer gibi parlıyor. Dileklerin gerçekleşiyor, tatmin duygusu seni sarıyor. Bu an şükranla dolu bir zirve.',
    presentEn: 'Nine cups gleam behind you like a golden arch. Your wishes are coming true, satisfaction embraces you. This moment is a peak full of gratitude.',
    directionTr: 'Gülümse, hak ettin. Ama dokuz kupanın verdiği rehavetle on uncu kupayı gözden kaçırma. Tatmin ol ama tok gözlü olma.',
    directionEn: 'Smile, you earned it. But do not let the comfort of nine cups make you overlook the tenth. Be satisfied, but do not become complacent.',
  ),
  31: CardMeaning(id: 31, themeTr: 'Aile mutluluğu, duygusal tamlık, huzur', themeEn: 'Family happiness, emotional completeness, peace', tone: CardTone.soft, movement: CardMovement.stillness, phase: CardPhase.completion,
    pastTr: 'Gökyüzünde parlayan gökkuşağının içindeki on kupa, aile figürlerinin üzerine sonsuz bir bereket yağdırmış. Çocuklar dans etmiş, çift kucaklaşmış. O mutluluk anı ebediymiş.',
    pastEn: 'Ten cups within a shining rainbow in the sky poured infinite blessings upon the family figures. Children danced, the couple embraced. That moment of happiness was eternal.',
    presentTr: 'Gökkuşağının altında, sevdiklerinin ortasındasın. On kupanın temsil ettiği duygusal tamlık seni sarıyor. Ev, aile, huzur — hepsi şu an ellerinin arasında.',
    presentEn: 'Under the rainbow, you stand among your loved ones. The emotional completeness of ten cups embraces you. Home, family, peace — all within your hands right now.',
    directionTr: 'Bu gökkuşağını koru. On kupanın vaadi sadece almak değil, paylaşmaktır. Mutluluğu böl, çoğaltsın. Ailene ve sevdiklerine zaman ayır.',
    directionEn: 'Protect this rainbow. The promise of ten cups is not just to receive, but to share. Divide happiness, let it multiply. Give time to family and loved ones.',
  ),
  32: CardMeaning(id: 32, themeTr: 'Duygusal mesaj, yaratıcı ilham, sürpriz', themeEn: 'Emotional message, creative inspiration, surprise', tone: CardTone.soft, movement: CardMovement.stillness, phase: CardPhase.beginning,
    pastTr: 'Genç bir haberci kupasından çıkan küçük bir balığa şaşkınlıkla bakmış. O beklenmedik mesaj, senin duygusal uyanışının ilk kıvılcımıymış.',
    pastEn: 'A young messenger gazed in wonder at the small fish emerging from the cup. That unexpected message was the first spark of your emotional awakening.',
    presentTr: 'Kupanın içinden bir balık fırlıyor — hayal bile edemeyeceğin bir mesaj geliyor. Genç enerjisi gibi taze ve meraklı ol. Yaratıcılığın seni çağırıyor.',
    presentEn: 'A fish leaps from the cup — a message you could not even imagine is arriving. Be fresh and curious like youthful energy. Your creativity calls you.',
    directionTr: 'O balığı yakala! Sana gelen sürpriz mesajı reddetme. Duygusal bir keşfe açık ol, çünkü bu kupa yepyeni bir başlangıcın habercisi.',
    directionEn: 'Catch that fish! Do not reject the surprise message coming to you. Be open to emotional discovery, for this cup heralds a brand new beginning.',
  ),
  33: CardMeaning(id: 33, themeTr: 'Romantik teklif, şövalye ruhu, zarif yaklaşım', themeEn: 'Romantic offer, chivalrous spirit, graceful approach', tone: CardTone.soft, movement: CardMovement.motion, phase: CardPhase.neutral,
    pastTr: 'Beyaz atının üzerinde sakin nehrin kıyısında ilerleyen şövalye, kupasını nazikçe uzatmış. O zarif ve samimi yaklaşım, kalbine dokunmuş.',
    pastEn: 'The knight on his white horse, advancing along the calm river bank, gracefully extended his cup. That elegant and sincere approach had touched your heart.',
    presentTr: 'Bir şövalye sana doğru geliyor — kanatları olan kupasıyla. Bu yaklaşım sert değil, nazik; acele değil, sabırlı. Duygusal bir davet kapında.',
    presentEn: 'A knight approaches you — with a winged cup. This approach is not harsh but gentle; not rushed but patient. An emotional invitation is at your door.',
    directionTr: 'Şövalyenin kupasını kabul et ya da sen ol o şövalye. Duygularını zarafetle ifade et. Atın yavaş ama kararlı adımları gibi, sabırla ilerle.',
    directionEn: 'Accept the knights cup, or become that knight yourself. Express your emotions with grace. Like the horses slow but steady steps, advance with patience.',
  ),
  34: CardMeaning(id: 34, themeTr: 'Sezgisel bilgelik, empatik güç, duygusal derinlik', themeEn: 'Intuitive wisdom, empathic power, emotional depth', tone: CardTone.soft, movement: CardMovement.stillness, phase: CardPhase.neutral,
    pastTr: 'Deniz kenarındaki tahtında oturan kraliçe, kapalı süslemeli kupasına derin derin bakmış. Onun sezgisel gücü gibi, sen de bir zamanlar iç sesini kusursuz bir berraklıkla duyabilmişsin.',
    pastEn: 'The queen sitting on her seaside throne gazed deeply into her ornate closed cup. Like her intuitive power, you too once could hear your inner voice perfectly.',
    presentTr: 'Denizin kıyısındaki tahtındasın ve elindeki kapalı kupa senin iç dünyanı temsil ediyor. Kimsenin göremediği derinlikleri sen hissediyorsun. Empatik gücün dorukta.',
    presentEn: 'You sit on your throne by the sea, and the closed cup in your hand represents your inner world. You sense depths no one else can see. Your empathic power peaks.',
    directionTr: 'Kupanı açma, onu koru. İç bilgeliğin en değerli hazinen. Dışarıdan gelen gürültüyü sustur ve denizin sesini dinle — cevaplar orada.',
    directionEn: 'Do not open your cup, protect it. Your inner wisdom is your most precious treasure. Silence the outside noise and listen to the sea — answers are there.',
  ),
  35: CardMeaning(id: 35, themeTr: 'Duygusal olgunluk, sakin liderlik, derin denge', themeEn: 'Emotional maturity, calm leadership, deep balance', tone: CardTone.soft, movement: CardMovement.stillness, phase: CardPhase.completion,
    pastTr: 'Fırtınalı denizin ortasındaki tahtında oturan kral, bir elinde kupa diğerinde asa, dalgalara aldırmadan hüküm sürmüş. Sen de en büyük fırtınalarda bile soğukkanlılığını korumuşsun.',
    pastEn: 'The king on his throne amid stormy seas ruled undisturbed, cup in one hand, scepter in the other. You too kept your composure even in the greatest storms.',
    presentTr: 'Etrafında dalgalar yükseliyor ama sen sakin ve dengedesin. Kralın kupası gibi duygularını sağlam tutuyorsun. Fırtınalı suda bile tahtından kalkmıyorsun.',
    presentEn: 'Waves rise around you but you remain calm and balanced. You hold your emotions steady like the kings cup. Even in stormy waters, you do not leave your throne.',
    directionTr: 'Duygusal olgunluk senin tacın. Dalgalar ne kadar yükselirse yükselsin, kralın sakinliğiyle hüküm sür. Kontrolü kaybetme, çünkü sen denizin efendisisin.',
    directionEn: 'Emotional maturity is your crown. No matter how high the waves rise, rule with the kings calm. Do not lose control, for you are the master of the sea.',
  ),
  // ============================================================
  // MINOR ARCANA — WANDS (Asalar) — 14 kart (id: 36–49)
  // ============================================================
  36: CardMeaning(id: 36, themeTr: 'Yaratıcı kıvılcım, yeni girişim, ilham', themeEn: 'Creative spark, new venture, inspiration', tone: CardTone.soft, movement: CardMovement.motion, phase: CardPhase.beginning,
    pastTr: 'Bulutlardan uzanan güçlü bir el sana filizlenen bir asa vermiş. O asanın ucundaki yapraklar, senin yaratıcı ateşinin ilk kıvılcımıymış. Bir şeye başlamışsın ve o ateş hâlâ yanıyor.',
    pastEn: 'A powerful hand from the clouds gave you a sprouting wand. The leaves at its tip were the first spark of your creative fire. You started something and that fire still burns.',
    presentTr: 'Elindeki filizlenen asa patlama noktasında. Yapraklar düşerken yeni tohumlar ekiliyor. Yaratıcı enerjin hiç bu kadar güçlü olmamıştı — şimdi harekete geç.',
    presentEn: 'The sprouting wand in your hand is at the bursting point. As leaves fall, new seeds are planted. Your creative energy has never been this strong — act now.',
    directionTr: 'O asayı sıkıca tut ve toprağa dik. Her yaprak bir fırsat, her filiz bir başlangıç. Düşünme zamanı bitti, yapma zamanı geldi.',
    directionEn: 'Hold that wand tight and plant it in the ground. Every leaf is an opportunity, every sprout a beginning. Time to think is over, time to do has come.',
  ),
  37: CardMeaning(id: 37, themeTr: 'Planlama, vizyon, keşif arzusu', themeEn: 'Planning, vision, desire for discovery', tone: CardTone.decision, movement: CardMovement.stillness, phase: CardPhase.neutral,
    pastTr: 'Kalenin tepesinden denize bakan figür, bir elinde dünya küresi diğerinde asa tutmuş. Büyük planlar kurduğun o dönem, bugünün temellerini atmış.',
    pastEn: 'The figure atop the castle looking out to sea held a globe in one hand and a wand in the other. That period of grand planning laid the foundations of today.',
    presentTr: 'Kalenin burcundan bakıyorsun ve tüm dünya ayaklarının altında. Bir elindeki küre geleceği, diğerindeki asa gücü temsil ediyor. Büyük kararların eşiğindesin.',
    presentEn: 'You gaze from the castle turret and the world lies at your feet. The globe represents the future, the wand represents power. You stand at the edge of great decisions.',
    directionTr: 'Küreyi sadece seyretme, onu döndür. Kalenin güvenliğinde kalmak kolay ama gerçek keşif kapıdan çıkmayı gerektirir. Planını eyleme dönüştür.',
    directionEn: 'Do not just watch the globe, spin it. Staying safe in the castle is easy, but true discovery requires stepping out. Turn your plan into action.',
  ),
  38: CardMeaning(id: 38, themeTr: 'Genişleme, ilerleme, ufkun açılması', themeEn: 'Expansion, progress, broadening horizons', tone: CardTone.soft, movement: CardMovement.motion, phase: CardPhase.neutral,
    pastTr: 'Tepenin üzerinde duran figür, elindeki asayla ufka bakmış ve gemilerin yelken açtığını görmüş. Attığın adımlar meyvesini vermeye başlamış.',
    pastEn: 'The figure standing on the hill gazed at the horizon with wand in hand and watched ships set sail. The steps you took had begun bearing fruit.',
    presentTr: 'Gemilerin ufukta yelken açıyor — senin gönderdiğin niyetler yola çıktı. Üç asanın güçlü duruşu gibi, temellerin sağlam. Genişleme zamanı.',
    presentEn: 'Ships sail on the horizon — the intentions you sent are on their way. Like the strong stance of three wands, your foundations are solid. Time to expand.',
    directionTr: 'Gemilerinin dönmesini bekle ama boş durma. Ufku izlerken yeni rotalar planla. En iyi lider hem sabırlı hem vizyonerdir.',
    directionEn: 'Wait for your ships to return, but do not stand idle. While watching the horizon, plan new routes. The best leader is both patient and visionary.',
  ),
  39: CardMeaning(id: 39, themeTr: 'Kutlama, yuva, sağlam temel', themeEn: 'Celebration, home, solid foundation', tone: CardTone.soft, movement: CardMovement.motion, phase: CardPhase.neutral,
    pastTr: 'Dört asadan yapılan takın altında bir çift el ele dans etmiş. Çiçek çelenkleri ve arkadaki kale, senin güvenli bir yuva kurduğun o mutlu dönemin sembolüymüş.',
    pastEn: 'The couple danced beneath an arch of four wands. Flower garlands and the castle behind symbolized that happy period when you built a safe home.',
    presentTr: 'Dört asa bir geçit kapısı oluşturuyor ve sen bu kapıdan geçmek üzeresin. Arkadaki kale güvenliği, çiçekler neşeyi temsil ediyor. Bir şeyi kutlama zamanı!',
    presentEn: 'Four wands form a gateway and you are about to pass through. The castle behind represents security, the flowers joy. Time to celebrate something!',
    directionTr: 'Bu kapıdan geç ve kutla. Sağlam temeller üzerine inşa ettiğin her şey kutlamayı hak ediyor. Sevinç paylaşıldıkça büyür.',
    directionEn: 'Pass through this gate and celebrate. Everything built on solid foundations deserves celebration. Joy grows when shared.',
  ),
  40: CardMeaning(id: 40, themeTr: 'Rekabet, sürtüşme, yapıcı çatışma', themeEn: 'Competition, friction, constructive conflict', tone: CardTone.heavy, movement: CardMovement.motion, phase: CardPhase.neutral,
    pastTr: 'Etrafında farklı fikirler ve güçler çarpışmış, herkes kendi doğrusunu savunmuş. Kaotik ve yorucu bir dönemmiş ama bu sürtüşme seni bilemiş ve güçlendirmiş.',
    pastEn: 'Five youths clashed their wands against each other. It looked chaotic, but this friction actually sharpened and strengthened you.',
    presentTr: 'Çevrende rekabet kızışıyor. Farklı sesler, fikirler ve istekler çatışıyor. Kaos gibi görünen bu ortam seni rahatsız etse de aslında büyütüyor.',
    presentEn: 'Competition heats up around you. Like five clashing wands, different voices, ideas and desires collide. This seeming chaos is actually growing you.',
    directionTr: 'Çatışmadan kaçma, onu yönet. Bu sürtüşme bir savaş değil, seni geliştiren bir antrenman. Rakiplerinden öğren ve kendi tarzını bul.',
    directionEn: 'Do not flee from conflict, manage it. The dance of five wands is not war, but training. Learn from competitors and find your own style.',
  ),
  41: CardMeaning(id: 41, themeTr: 'Zafer, tanınma, başarı taçlanması', themeEn: 'Victory, recognition, crowning success', tone: CardTone.soft, movement: CardMovement.motion, phase: CardPhase.completion,
    pastTr: 'Defne çelengiyle süslenmiş asanı tutan atlı, kalabalığın alkışları arasında zafer yürüyüşü yapmış. O an hak ettiğin tanınmayı aldığın muhteşem anmış.',
    pastEn: 'The rider holding a laurel-crowned wand marched in victory amid the crowds applause. That was the glorious moment you received the recognition you deserved.',
    presentTr: 'Halk seni alkışlıyor ve asandaki defne çelengi zaferini ilan ediyor. Başardın! Bu an sana ait ve herkes bunu görüyor. Omuzlarında taşınıyorsun.',
    presentEn: 'The crowd applauds and the laurel wreath on your wand declares your victory. You did it! This moment is yours and everyone sees it.',
    directionTr: 'Zaferini kabul et ve gururla yürü. Defne çelengi sana ait. Ama unutma: gerçek lider alçakgönüllülükle kazanır.',
    directionEn: 'Accept your victory and walk with pride. The laurel wreath is yours. But remember: true leaders win with humility.',
  ),
  42: CardMeaning(id: 42, themeTr: 'Savunma, direnç, toprak koruma', themeEn: 'Defense, resilience, holding ground', tone: CardTone.heavy, movement: CardMovement.motion, phase: CardPhase.neutral,
    pastTr: 'Tepenin üzerinde tek başına, alttan gelen altı asaya karşı kendi asanla savaşmışsın. Dezavantajlı konumda bile pes etmemişsin ve yerini korumuşsun.',
    pastEn: 'Alone on the hilltop, you fought six wands from below with your single wand. Even at a disadvantage, you never gave up and held your ground.',
    presentTr: 'Altı asa aşağıdan sana yöneliyor ama sen tepenin üzerindesin ve avantajlısın. Tek başına duruyorsun ama savaşmaya kararlısın. İnandığın şeyi savun.',
    presentEn: 'Six wands aim at you from below but you stand atop the hill with the advantage. You stand alone but determined to fight. Defend what you believe in.',
    directionTr: 'Geri adım atma. Tepenin üzerindeki pozisyonun avantajını kullan. Tek başına olman zayıflık değil, inanç gücünün kanıtı.',
    directionEn: 'Do not step back. Use the advantage of your hilltop position. Being alone is not weakness, it is proof of the power of belief.',
  ),
  43: CardMeaning(id: 43, themeTr: 'Hızlı gelişme, momentum, ani hareket', themeEn: 'Rapid development, momentum, swift movement', tone: CardTone.soft, movement: CardMovement.motion, phase: CardPhase.neutral,
    pastTr: 'Sekiz asa gökyüzünden ok gibi fırlamış ve yeşil vadinin üzerinden süzülmüş. Her şey o kadar hızlı gelişmiş ki, nefes bile alamadan yeni bir yere taşınmışsın.',
    pastEn: 'Eight wands shot through the sky like arrows, soaring over the green valley. Everything happened so fast you were carried to a new place before you could breathe.',
    presentTr: 'Sekiz asa havada uçuyor — haberler, fırsatlar ve değişimler hızla geliyor. Hayatın ivme kazandı. Bu dalga seni ileriye taşıyor, tut kendini.',
    presentEn: 'Eight wands fly through the air — news, opportunities and changes arrive rapidly. Your life has gained momentum. This wave carries you forward, hold on.',
    directionTr: 'Hıza ayak uydur ama kontrolü kaybetme. Sekiz asanın uçuş yönünü takip et. Hızlı hareket etmek doğru ama yönün de doğru olsun.',
    directionEn: 'Keep pace but do not lose control. Follow the flight direction of eight wands. Moving fast is right, but make sure your direction is right too.',
  ),
  44: CardMeaning(id: 44, themeTr: 'Son direnç, yorgun savaşçı, dayanıklılık', themeEn: 'Last stand, weary warrior, endurance', tone: CardTone.heavy, movement: CardMovement.stillness, phase: CardPhase.neutral,
    pastTr: 'Bandajlı başıyla asasına dayanan savaşçı, arkasındaki sekiz asanın oluşturduğu duvarın önünde nöbet tutmuş. Yorgun düşmüşsün ama asla dizlerinin üstüne çökmemişsin.',
    pastEn: 'The bandaged warrior leaned on his wand, standing guard before the wall of eight wands behind him. You grew weary but never fell to your knees.',
    presentTr: 'Yaralarına rağmen ayaktasın. Arkandaki sekiz asa senin savunma hattın. Son bir sınav daha var ama sen buna hazırsın — çünkü şimdiye kadar hepsini atlattın.',
    presentEn: 'Despite your wounds, you stand. The eight wands behind are your line of defense. One more test remains, but you are ready — you survived them all so far.',
    directionTr: 'Pes etme, son çizgiyi geçmek üzeresin. Asana dayan, yaralarını onurla taşı. Bu son engeli de aşacaksın — içindeki ateş henüz sönmedi.',
    directionEn: 'Do not give up, you are about to cross the finish line. Lean on your wand, wear your wounds with honor. You will overcome this last obstacle — the fire within has not died.',
  ),
  45: CardMeaning(id: 45, themeTr: 'Aşırı yük, sorumluluk, hedefe yakınlık', themeEn: 'Heavy burden, responsibility, nearing the goal', tone: CardTone.heavy, movement: CardMovement.motion, phase: CardPhase.neutral,
    pastTr: 'On asayı sırtında taşıyarak kasabaya doğru yürüyen figür, omuzlarının ezici ağırlığı altında eğilmiş. Çok fazla sorumluluk üstlenmişsin ama hedefe yaklaşmışsın.',
    pastEn: 'The figure carrying ten wands on his back toward the town buckled under the crushing weight. You took on too much responsibility, but you neared the goal.',
    presentTr: 'Sırtındaki on asa seni eziyor ama kasaba çok yakın. Yükün ağır, sorumluluğun çok. Ama bırakmana gerek yok — sadece birkaç adım daha. Hedefe neredeyse vardın.',
    presentEn: 'Ten wands on your back crush you, but the town is very close. Your load is heavy, your responsibilities many. But you need not drop them — just a few more steps.',
    directionTr: 'Her asayı kendin taşımak zorunda değilsin. Bazılarını paylaş, bazılarını bırak. Hedefe yükünü hafifletmiş olarak varmak, yolda çökmekten iyidir.',
    directionEn: 'You do not have to carry every wand yourself. Share some, drop others. Reaching the goal with a lighter load is better than collapsing on the road.',
  ),
  46: CardMeaning(id: 46, themeTr: 'Heyecan, keşif ruhu, genç enerji', themeEn: 'Excitement, spirit of discovery, youthful energy', tone: CardTone.soft, movement: CardMovement.motion, phase: CardPhase.beginning,
    pastTr: 'Genç haberci çöldeki asasına hayranlıkla bakmış ve yeni topraklar keşfetmeye ant içmiş. O ilk heyecan, macera ruhunun doğduğu anmış.',
    pastEn: 'The young messenger gazed at his wand in the desert with admiration and vowed to explore new lands. That first excitement was the birth of your adventurous spirit.',
    presentTr: 'Elindeki asa seni çağırıyor ve ayaklarının altındaki kum yeni keşiflere davet ediyor. Genç, heyecanlı ve cesursun. Her şey mümkün görünüyor.',
    presentEn: 'The wand in your hand calls you and the sand beneath your feet invites new discoveries. You are young, excited and brave. Everything seems possible.',
    directionTr: 'O heyecanı kaybetme. Genç keşifçinin gözleriyle dünyaya bak. Her asa yeni bir macera, her adım yeni bir hikaye. Korkusuzca ilerle.',
    directionEn: 'Do not lose that excitement. See the world through the young explorers eyes. Every wand is a new adventure, every step a new story. Advance fearlessly.',
  ),
  47: CardMeaning(id: 47, themeTr: 'Tutkulu atılım, cesur liderlik, macera', themeEn: 'Passionate charge, bold leadership, adventure', tone: CardTone.decision, movement: CardMovement.motion, phase: CardPhase.neutral,
    pastTr: 'Şövalye alevli atına binip çöller ve piramitler arasından geçmiş. Hiçbir engel onu durduramamış çünkü tutkusu her şeyden güçlüymüş. Sen de öyle yapmışsın.',
    pastEn: 'The knight rode his fiery horse through deserts and past pyramids. Nothing could stop him because his passion was stronger than everything. So did you.',
    presentTr: 'Atın şaha kalkıyor ve asanın alevler saçıyor. Durdurulamaz bir enerjiyle ilerliyorsun. Şövalyenin tutkusu gibi, senin de içinde söndürülemez bir ateş var.',
    presentEn: 'Your horse rears and your wand shoots flames. You advance with unstoppable energy. Like the knights passion, there is an unquenchable fire inside you too.',
    directionTr: 'Atını sür ama dizginleri de elden bırakma. Tutku güçlü bir yakıt ama kontrolsüz ateş her şeyi yakar. Cesur ol ama akıllıca ilerle.',
    directionEn: 'Ride your horse but do not let go of the reins. Passion is powerful fuel, but uncontrolled fire burns everything. Be brave but advance wisely.',
  ),
  48: CardMeaning(id: 48, themeTr: 'Güvenli liderlik, sıcak enerji, manyetik çekim', themeEn: 'Confident leadership, warm energy, magnetic pull', tone: CardTone.soft, movement: CardMovement.motion, phase: CardPhase.neutral,
    pastTr: 'Bir dönem hayatında öyle bir sıcaklık ve özgüven varmış ki, insanlar sana doğal olarak çekilmiş. Liderliğin zorla değil, sevgiyle gelmiş ve etrafına yaydığın pozitif enerji herkesi sarıp sarmalamış.',
    pastEn: 'The queen on her lion-adorned throne held a wand in one hand and a sunflower in the other, radiating positive energy. Everyone ran to her light as her black cat stood at her feet.',
    presentTr: 'Ayçiçeğinin güneşe dönmesi gibi insanlar da sana yöneliyor. Kraliçenin sıcak kararlılığı sende var. Asanı tut, kendini sev ve tahtından liderlik et.',
    presentEn: 'People turn to you like sunflowers to the sun. You have the queens warm determination. Hold your wand, love your cat and lead from your throne.',
    directionTr: 'Işığını saklamayı bırak. Kraliçenin ayçiçeği gibi güneşe dön ve etrafına sıcaklık yay. Liderliğin güçle değil, sevgiyle gelir.',
    directionEn: 'Stop hiding your light. Turn to the sun like the queens sunflower and spread warmth around you. Leadership comes not from force, but from love.',
  ),
  49: CardMeaning(id: 49, themeTr: 'Vizyoner güç, doğal otorite, stratejik zeka', themeEn: 'Visionary power, natural authority, strategic mind', tone: CardTone.decision, movement: CardMovement.motion, phase: CardPhase.neutral,
    pastTr: 'Tahtında oturan kral, asasını bir meşale gibi tutarak geleceği görmüş. Pelerinindeki semender figürleri ateşten dönüşümün simgesiymiş. Vizyonun gerçeğe dönüşmüş.',
    pastEn: 'The king on his throne held his wand like a torch and saw the future. The salamander figures on his robe symbolized transformation through fire. Your vision became reality.',
    presentTr: 'Kralın tahtındasın ve elindeki asa gücünü temsil ediyor. Semenderin ateşte yeniden doğuşu gibi, sen de her krizden daha güçlü çıkıyorsun. Doğal bir lidersin.',
    presentEn: 'You sit on the kings throne, the wand in your hand represents your power. Like the salamander reborn in fire, you emerge stronger from every crisis. You are a natural leader.',
    directionTr: 'Asanı yükselt ve vizyonunu ilan et. Kralın stratejik zekâsıyla hareket et. Büyük düşün, cesurca planla ve kararlılıkla yürüt.',
    directionEn: 'Raise your wand and declare your vision. Act with the kings strategic mind. Think big, plan boldly and execute with determination.',
  ),
  // ============================================================
  // MINOR ARCANA — SWORDS (Kılıçlar) — 14 kart (id: 50–63)
  // ============================================================
  50: CardMeaning(id: 50, themeTr: 'Zihinsel zafer, yeni fikir, berraklık', themeEn: 'Mental victory, new idea, clarity', tone: CardTone.decision, movement: CardMovement.motion, phase: CardPhase.beginning,
    pastTr: 'Bulutlardan uzanan el, altın taçla süslü bir kılıcı sana vermiş. Defne dalı ve palmiye yaprakları o zihinsel zaferi süslemiş. Aklına gelen o parlak fikir her şeyi değiştirmiş.',
    pastEn: 'A hand from the clouds gave you a sword crowned with gold. Laurel branch and palm leaves adorned that mental victory. That brilliant idea changed everything.',
    presentTr: 'Elindeki kılıç berraklığın sembolü — zihinsel sisin dağılıyor ve gerçek netleşiyor. Taçtaki mücevher gibi, doğru cevap tam önünde parlıyor.',
    presentEn: 'The sword in your hand symbolizes clarity — mental fog disperses and truth crystallizes. Like the jewel in the crown, the right answer shines right before you.',
    directionTr: 'Kılıcı kararlılıkla kaldır. Zihinsel gücün dorukta ve bu kılıç hem koruyor hem yol açıyor. Yeni fikirlerin cesurca peşinden git.',
    directionEn: 'Raise the sword with resolve. Your mental power peaks and this sword both protects and clears the way. Boldly pursue your new ideas.',
  ),
  51: CardMeaning(id: 51, themeTr: 'İkilem, inkâr, ertelenmiş karar', themeEn: 'Dilemma, denial, postponed decision', tone: CardTone.heavy, movement: CardMovement.stillness, phase: CardPhase.neutral,
    pastTr: 'Gözleri bağlı kadın, çapraz tuttuğu iki kılıçla denizin önünde oturmuş. Arkasındaki hilal ay sezgisini çağırmış ama sen görmezden gelmişsin.',
    pastEn: 'The blindfolded woman sat before the sea holding two crossed swords. The crescent moon behind called to her intuition, but you chose to ignore it.',
    presentTr: 'Gözlerini kapatıp iki kılıcı kucaklamışsın. Karar vermekten kaçınıyorsun ama dengeyi sonsuza dek tutamazsın. Hilal ay sana sezgini dinlemeni fısıldıyor.',
    presentEn: 'You have closed your eyes and embraced two swords. You avoid deciding, but you cannot hold the balance forever. The crescent moon whispers to trust your intuition.',
    directionTr: 'Bağı çöz ve gözlerini aç. İki kılıçtan birini yere bırak. Karar vermemek de bir karardır — ve genellikle en kötüsü.',
    directionEn: 'Remove the blindfold and open your eyes. Put one of the two swords down. Not deciding is also a decision — and usually the worst one.',
  ),
  52: CardMeaning(id: 52, themeTr: 'Kalp kırıklığı, acı gerçek, yas', themeEn: 'Heartbreak, painful truth, grief', tone: CardTone.heavy, movement: CardMovement.stillness, phase: CardPhase.neutral,
    pastTr: 'Üç kılıç kırmızı bir kalbin tam ortasından geçmiş. Yağmur bulutları gözyaşı gibi yağmış. O acı veren gerçek seni derinden yaralamış ama içinden geçmişsin.',
    pastEn: 'Three swords pierced through the center of a red heart. Rain clouds poured like tears. That painful truth wounded you deeply, but you came through.',
    presentTr: 'Kalbine saplanan acı gerçeğin kılıçları sızlıyor. Yağmur yağıyor, gökyüzü ağlıyor. Ama bu acı geçicidir — her fırtınadan sonra güneş doğar.',
    presentEn: 'The swords of painful truth embedded in your heart ache. Rain falls, the sky weeps. But this pain is temporary — the sun rises after every storm.',
    directionTr: 'Acıyı kabul et ama onunla evlenme. Kılıçları kalbinden çek — iyileşme cesaretle başlar. Yaralar kapanır, izler güçlendirir.',
    directionEn: 'Accept the pain but do not marry it. Pull the three swords from your heart — healing begins with courage. Wounds close, scars strengthen.',
  ),
  53: CardMeaning(id: 53, themeTr: 'Dinlenme, iyileşme, stratejik bekleme', themeEn: 'Rest, recovery, strategic waiting', tone: CardTone.soft, movement: CardMovement.stillness, phase: CardPhase.neutral,
    pastTr: 'Şövalye kilisede el pençe divan yatıyordu, üç kılıç duvarda asılı, dördüncüsü altında. Vitray pencereden süzülen renkli ışık onu iyileştirmiş. Durduğun o dönem seni onarmış.',
    pastEn: 'The knight lay in prayer in the church, three swords on the wall, the fourth beneath him. Colorful light through stained glass healed him. That pause restored you.',
    presentTr: 'Mücadeleyi durdur ve dinlen. Şövalye gibi kılıçlarını duvara as ve iyileşmeye izin ver. Bu bir yenilgi değil, stratejik bir geri çekilme.',
    presentEn: 'Stop the fight and rest. Hang your swords on the wall like the knight and let healing happen. This is not defeat, but a strategic retreat.',
    directionTr: 'Vitray pencerenin ışığına yüzünü dön. İyileşmek zaman ister ve bu zamanı kendin için ayırmak güçsüzlük değil, bilgeliktir.',
    directionEn: 'Turn your face to the stained glass window light. Healing takes time and setting this time aside is not weakness, but wisdom.',
  ),
  54: CardMeaning(id: 54, themeTr: 'Boş zafer, bedeli ağır kazanç, vicdan', themeEn: 'Hollow victory, costly win, conscience', tone: CardTone.heavy, movement: CardMovement.motion, phase: CardPhase.neutral,
    pastTr: 'Sırıtarak üç kılıcı toplayan figür, geride bıraktığı iki kişinin kılıçlarını da almış. Kazanmışsın ama kazanmanın bedeli ağır olmuş — arkana bakınca kimse kalmamış.',
    pastEn: 'The smirking figure collected three swords and took the two left behind by others. You won, but the cost was heavy — when you looked back, no one remained.',
    presentTr: 'Elinde üç kılıç var ve galip sen görünüyorsun. Ama arkanda bıraktığın yıkıma bak. Bu zafer gerçekten değdi mi? Vicdanın seni sorgulamaya başlıyor.',
    presentEn: 'You hold three swords and appear victorious. But look at the destruction behind you. Was this victory truly worth it? Your conscience begins to question.',
    directionTr: 'Kılıçları geri ver veya yere bırak. Kazanmanın bedeli kaybetmekten ağır olmamalı. Gerçek zafer, herkesin ayakta kaldığı zaferdir.',
    directionEn: 'Give the swords back or lay them down. The cost of winning should not outweigh losing. True victory is one where everyone stands.',
  ),
  55: CardMeaning(id: 55, themeTr: 'Geçiş, iyileşme yolculuğu, sığınak', themeEn: 'Transition, healing journey, refuge', tone: CardTone.soft, movement: CardMovement.motion, phase: CardPhase.neutral,
    pastTr: 'Kayıkçı, kadın ve çocuğu altı kılıçla birlikte sakin sulara doğru kürek çekmiş. Zor bir dönemden çıkıp güvenli kıyılara doğru yol almışsın.',
    pastEn: 'The boatman rowed the woman and child toward calmer waters alongside six swords. You left a difficult period and sailed toward safe shores.',
    presentTr: 'Fırtınalı suları geride bırakıyorsun. Teknedeki altı kılıç taşıdığın yaraları simgeliyor ama karşı kıyı daha sakin. Geçiş döneminin tam ortasındasın.',
    presentEn: 'You leave stormy waters behind. The six swords in the boat represent wounds you carry, but the opposite shore is calmer. You are in the middle of transition.',
    directionTr: 'Kürek çekmeye devam et. Karşı kıyı yakın ve orada seni bekleyen huzur var. Kılıçlarını bırakma — onlar sana ders veren savaşçının madalyaları.',
    directionEn: 'Keep rowing. The opposite shore is near and peace awaits you there. Do not drop your swords — they are the medals of the warrior who taught you lessons.',
  ),
  56: CardMeaning(id: 56, themeTr: 'Hile, strateji, gizli hamle', themeEn: 'Deception, strategy, hidden move', tone: CardTone.heavy, movement: CardMovement.motion, phase: CardPhase.neutral,
    pastTr: 'Gizlice beş kılıcı toplayan figür, askeri kamptan sessizce uzaklaşmış. İki kılıç geride kalmış. Zekice bir hamle mi yoksa aldatma mı — buna sen karar vermişsin.',
    pastEn: 'The figure secretly gathered five swords and slipped away from the camp. Two swords remained. A clever move or deception — you decided that.',
    presentTr: 'Beş kılıcı taşıyorsun ama iki tanesi geride kaldı. Her şeyi elde etmeye çalışıyorsun ama bu yolun sonu tehlikeli. Arkana bak — fark eden biri var mı?',
    presentEn: 'You carry five swords but two remain behind. You try to obtain everything, but this path leads to danger. Look back — has anyone noticed?',
    directionTr: 'Kurnazlık bir stratejidir ama dürüstlük bir kaledir. Beş kılıçla kaçmak yerine, yedi kılıcın sahibi olmak için doğru yolu seç.',
    directionEn: 'Cunning is a strategy but honesty is a fortress. Instead of fleeing with five swords, choose the right path to own all seven.',
  ),
  57: CardMeaning(id: 57, themeTr: 'Zihinsel hapishane, kendi kendini sınırlama', themeEn: 'Mental prison, self-limitation, restriction', tone: CardTone.heavy, movement: CardMovement.stillness, phase: CardPhase.neutral,
    pastTr: 'Bağlanmış ve gözleri örtülü kadın, sekiz kılıcın arasında bataklıkta mahsur kalmış. Ama bağlar aslında gevşek — sen kendi korkularınla kendini hapsetmişsin.',
    pastEn: 'The bound and blindfolded woman was trapped among eight swords in the marsh. But the bindings were loose — you imprisoned yourself with your own fears.',
    presentTr: 'Etrafındaki sekiz kılıç bir kafes oluşturuyor ama bağların gevşek. Bataklıkta sıkıştığını düşünüyorsun ama çıkış var — görmüyorsun çünkü gözlerin bağıyla.',
    presentEn: 'Eight swords around you form a cage but your bindings are loose. You think you are stuck in the marsh, but there is an exit — you cannot see it because of the blindfold.',
    directionTr: 'Bağı çöz, gözlerini aç. Kılıçlar arasından geçebileceğin bir boşluk var. Zindan senin zihninde — anahtarı da orada ara.',
    directionEn: 'Untie the binding, open your eyes. There is a gap between the swords you can pass through. The prison is in your mind — look for the key there too.',
  ),
  58: CardMeaning(id: 58, themeTr: 'Kaygı, kabus, aşırı endişe', themeEn: 'Anxiety, nightmare, excessive worry', tone: CardTone.heavy, movement: CardMovement.stillness, phase: CardPhase.neutral,
    pastTr: 'Gece yarısı yatağında doğrulup ellerini yüzüne kapatmışsın. Duvardaki dokuz kılıç karanlıkta parlamış. Zihindeki o kabus döngüsü seni uykusuz bırakmış.',
    pastEn: 'You sat up in bed at midnight, covering your face with your hands. Nine swords gleamed on the wall in darkness. That nightmare cycle in your mind kept you sleepless.',
    presentTr: 'Dokuz kılıç başının üzerinde asılı dururken, zihnin sana rahat vermiyor. Her düşünce karanlıkta parlayan bir bıçak gibi kalbine saplanıyor. Unutma ki bu dehşet verici sahneyi yaratan gerçeklik değil, içindeki korkunun gölgesidir.',
    presentEn: 'Nine swords hang above your head and your mind gives no peace. Every thought cuts like a blade. But remember that this terrifying scene is created not by reality, but by the shadow of your inner fear.',
    directionTr: 'Nefes al. Duvardaki kılıçların hiçbiri sana dokunmuyor aslında. Zihninin uydurduğu senaryolardan çık. Sabah gelecek ve her kabus bitecek.',
    directionEn: 'Breathe. None of the swords on the wall actually touch you. Step out of the scenarios your mind fabricated. Morning will come and every nightmare will end.',
  ),
  59: CardMeaning(id: 59, themeTr: 'Dip nokta, karanlık son, zoraki yenilenme', themeEn: 'Rock bottom, dark ending, forced renewal', tone: CardTone.heavy, movement: CardMovement.stillness, phase: CardPhase.ending,
    pastTr: 'Yüzüstü yatan figürün sırtına on kılıç saplanmış. Her şey bitmiş gibi görünmüş. Ama ufuktaki altın şafak, bu kapanışın bir yenilenme olduğunu fısıldamış.',
    pastEn: 'Ten swords were planted in the back of the figure lying face down. Everything seemed over. But the golden dawn on the horizon whispered this ending was renewal.',
    presentTr: 'On kılıç sırtında ve yere yığılmış gibisin. Bu en dip noktası. Ama ufka bak — altın bir güneş doğmak üzere. Bu bitiş gerçek bir sonun değil, zorunlu yenilenmenin başlangıcı.',
    presentEn: 'Ten swords in your back and you seem to have collapsed. This is rock bottom. But look at the horizon — a golden sun is about to rise. This ending is not the true end, but the start of forced renewal.',
    directionTr: 'Artık daha kötüsü yok — bu özgürleştirici bir gerçek. Kılıçları sırtından çek, doğrul ve ufuktaki şafağa yürü. Her dip nokta bir sıçrama tahtasıdır.',
    directionEn: 'It cannot get worse — this is a liberating truth. Pull the swords from your back, stand up and walk toward the dawn on the horizon. Every rock bottom is a springboard.',
  ),
  60: CardMeaning(id: 60, themeTr: 'Keskin zeka, yeni bakış, cesur söz', themeEn: 'Curious intellect, fresh perspective, bold speech', tone: CardTone.decision, movement: CardMovement.motion, phase: CardPhase.beginning,
    pastTr: 'Rüzgârlı tepede duran genç, kılıcını iki eliyle yukarı kaldırmış. Gökyüzündeki kuşlar onun özgür düşüncesinin yansımasıymış. O ilk cesur sözün her şeyi başlatmış.',
    pastEn: 'The youth on the windy hilltop raised the sword with both hands. Birds in the sky represented his free thinking. That first bold word started everything.',
    presentTr: 'Rüzgâr saçlarını savururken kılıcını cesurca havaya kaldırmışsın. Zihnin her zamankinden daha keskin, ufkun ise uçsuz bucaksız. Tıpkı o kuşlar gibi özgürce kanat çırpan taze fikirlerini artık hayata geçirme vakti.',
    presentEn: 'You raise your sword boldly as the wind blows through your hair. Your mind is sharper than ever, your horizon boundless. It is time to bring to life the fresh ideas flying free like those birds.',
    directionTr: 'Kılıcını indir ama keskinliğini asla kaybetme. Genç bir savaşçının atikliğiyle dünyaya meydan oku. Cesurca konuş, ancak bilgeliğin sesini dinlemeyi de unutma.',
    directionEn: 'Lower your sword but never lose its edge. Challenge the world with the agility of a young warrior. Speak boldly, but do not forget to listen to the voice of wisdom.',
  ),
  61: CardMeaning(id: 61, themeTr: 'Hızlı karar, kararlı hamle, ani değişim', themeEn: 'Swift decision, decisive move, sudden change', tone: CardTone.decision, movement: CardMovement.motion, phase: CardPhase.neutral,
    pastTr: 'Rüzgâr gibi atını süren şövalye, kılıcını havaya kaldırarak düşmanlarına doğru dört nala koşmuş. Bulutlar ve fırtına onu durduramamış. O ani kararın akışı değiştirmiş.',
    pastEn: 'The knight rode his horse like the wind, raising his sword and charging at full gallop. Clouds and storms could not stop him. That sudden decision changed the flow.',
    presentTr: 'Atın dört nala koşuyor ve kılıcın havada parlıyor. Fırtına yaklaşıyor ama sen durdurulamazsın. Hızlı düşün, hızlı karar ver. An bu an.',
    presentEn: 'Your horse gallops at full speed and your sword gleams in the air. A storm approaches but you cannot be stopped. Think fast, decide fast. The moment is now.',
    directionTr: 'Düşünme zamanı bitti, harekete geç. Kılıcın keskinliğiyle yolunu aç ama fırtınanın içinde soğukkanlılığını koru. Cesaret ile bilgelik yan yana yürüsün.',
    directionEn: 'Do not hesitate, take action. Be sharp and clear like the knights sword. But speed is not recklessness — know how to ride the horse.',
  ),
  62: CardMeaning(id: 62, themeTr: 'Bağımsız düşünce, duygusal netlik, sert adalet', themeEn: 'Independent thought, emotional clarity, firm justice', tone: CardTone.decision, movement: CardMovement.stillness, phase: CardPhase.neutral,
    pastTr: 'Bulutların üzerindeki tahtında oturan kraliçe, bir eliyle kılıcını kaldırmış diğeriyle uzaklara uzanmış. Kelebekler etrafında uçuşurken o acı gerçeği cesurca söylemiş.',
    pastEn: 'The queen on her throne above the clouds raised her sword with one hand and reached out with the other. As butterflies fluttered around, she spoke the painful truth bravely.',
    presentTr: 'Tahtında tek başına oturuyorsun, bulutların üzerinde. Kılıcın gerçeği kesiyor, kelebeklerin dönüşümü temsil ediyor. Zihinsel netliğin seni yalancı acılardan koruyor.',
    presentEn: 'You sit alone on your throne above the clouds. Your sword cuts truth, your butterflies represent transformation. Mental clarity protects you from false pains.',
    directionTr: 'Kılıcınla gerçeği kes ama kalbini de dinle. Kraliçenin gücü soğuklukta değil, cesurca dürüst olmaktadır. Bağımsız düşün ama yalnız kalma.',
    directionEn: 'Cut truth with your sword but also listen to your heart. The queens power lies not in coldness, but in courageous honesty. Think independently but do not isolate.',
  ),
  63: CardMeaning(id: 63, themeTr: 'Entelektüel otorite, adil yönetim, stratejik güç', themeEn: 'Intellectual authority, fair governance, strategic power', tone: CardTone.decision, movement: CardMovement.stillness, phase: CardPhase.neutral,
    pastTr: 'Mavi cüppeli kral tahtında oturarak kılıcını dimdik tutmuş. Arkasındaki bulutlar ve kelebekler zihninin hem gücünü hem zarafetini yansıtıyormuş. Adil ve keskin kararlarınla saygı kazanmışsın.',
    pastEn: 'The king in blue robes sat on his throne holding the sword upright. Clouds and butterflies behind showed both his minds power and elegance. You earned respect with fair, sharp decisions.',
    presentTr: 'Tahtındasın ve kılıcın dik duruyor — eğilmiyor, bükülmüyor. Kralın tarafsızlığı ve stratejik zekâsı sende. Mantıkla yönet, duygularla değil.',
    presentEn: 'You sit on your throne, sword standing straight — unbent, unbowed. The kings impartiality and strategic mind are in you. Govern with logic, not emotions.',
    directionTr: 'Kılıcını dik tut ve adaleti sağla. Kral gibi tarafsız ol ama merhameti de unutma. Entelektüel güç sorumluluk getirir.',
    directionEn: 'Keep your sword upright and deliver justice. Be impartial like the king, but do not forget mercy. Intellectual power brings responsibility.',
  ),
  // ============================================================
  // MINOR ARCANA — PENTACLES (Sikkeler) — 14 kart (id: 64–77)
  // ============================================================
  64: CardMeaning(id: 64, themeTr: 'Maddi fırsat, yeni başlangıç, bereket kapısı', themeEn: 'Material opportunity, new start, abundance gate', tone: CardTone.soft, movement: CardMovement.stillness, phase: CardPhase.beginning,
    pastTr: 'Bulutlardan uzanan el, altın bir sikke sunmuş. Bahçenin kapısındaki çiçekli kemerin altından o fırsatı almışsın ve maddi dünyada ilk adımını atmışsın.',
    pastEn: 'A hand from the clouds offered a golden coin. Beneath the flowered arch at the garden gate, you took that opportunity and stepped into the material world.',
    presentTr: 'Altın sikke avucunda parlıyor ve bahçenin kapısı açık. Maddi bir fırsat seni bekliyor. Bu tohumun ekilme zamanı — bereket bahçesine adım at.',
    presentEn: 'A golden coin gleams in your palm and the garden gate is open. A material opportunity awaits. Time to plant this seed — step into the garden of abundance.',
    directionTr: 'Sikkeyi cebine koyma, toprağa ek. Fırsatı değerlendir ve o bahçeyi büyüt. Bereket kapısı açık ama sonsuza dek açık kalmayacak.',
    directionEn: 'Do not pocket the coin, plant it in the soil. Seize the opportunity and grow that garden. The abundance gate is open, but it will not stay open forever.',
  ),
  65: CardMeaning(id: 65, themeTr: 'Denge cambazlığı, uyum arayışı, esneklik', themeEn: 'Juggling balance, seeking harmony, flexibility', tone: CardTone.decision, movement: CardMovement.motion, phase: CardPhase.neutral,
    pastTr: 'Genç jonglör iki sikkeyi sonsuzluk bandıyla çevirirken, arka plandaki dalgalı deniz hayatın inişli çıkışlı dönemini yansıtıyormuş. O dengeleme sanatını sen de öğrenmişsin.',
    pastEn: 'The young juggler spun two coins with an infinity band while the wavy sea behind reflected lifes ups and downs. You too learned that art of balance.',
    presentTr: 'İki sikkeyi havada döndürüyorsun — iş ve özel hayat, vermek ve almak. Dalgalar arkanda yükseliyor ama sen dengedesin. Bu cambazlığın ustası sensin.',
    presentEn: 'You spin two coins in the air — work and personal life, giving and taking. Waves rise behind, but you stay balanced. You are the master of this juggling act.',
    directionTr: 'Dengeyi sadece bir an değil, sürekli koru. Jonglörün sonsuzluk bandı gibi, akışta kal. Mükemmellik değil, uyum ara.',
    directionEn: 'Maintain balance not just for a moment, but continuously. Like the jugglers infinity band, stay in flow. Seek not perfection, but harmony.',
  ),
  66: CardMeaning(id: 66, themeTr: 'Ustalık, takım çalışması, ilk meyveler', themeEn: 'Mastery, teamwork, first fruits', tone: CardTone.soft, movement: CardMovement.stillness, phase: CardPhase.neutral,
    pastTr: 'Usta, kemerli katedralin içinde iki mimarla birlikte çalışmış. Planlar incelenirken üç sikke taş kemerden parlamış. İş birliğiyle büyük eserler yaratmışsın.',
    pastEn: 'The craftsman worked inside the arched cathedral with two architects. Plans examined as three coins shone from the stone arch. Through collaboration, you created great works.',
    presentTr: 'Bir takımın parçasısın ve herkesin uzmanlığı bütünü güçlendiriyor. Üç sikke kemerde parlıyor — emeğinin ilk somut sonuçları görünüyor. Ustalığın takdir ediliyor.',
    presentEn: 'You are part of a team and everyones expertise strengthens the whole. Three coins shine in the arch — the first concrete results of your effort appear. Your mastery is recognized.',
    directionTr: 'Tek başına yapma, takımla yap. Ustanın keseri gibi, her detaya özen göster. İlk meyveleri topla ama işi yarım bırakma.',
    directionEn: 'Do not go alone, work with the team. Like the masters chisel, attend to every detail. Gather the first fruits but do not leave the work half done.',
  ),
  67: CardMeaning(id: 67, themeTr: 'Kontrol tutkusu, güvensizlik, kapalılık', themeEn: 'Control obsession, insecurity, closedness', tone: CardTone.heavy, movement: CardMovement.stillness, phase: CardPhase.neutral,
    pastTr: 'Tahtında oturan figür, bir sikkeyi başının üstünde dengelerken diğerlerini ayaklarının altında ve kollarının arasında sıkıca tutmuş. Kaybetme korkusu seni esir almış.',
    pastEn: 'The figure on the throne balanced one coin on his head while clutching others under his feet and in his arms. Fear of losing took you captive.',
    presentTr: 'Dört sikkeyi kucaklıyorsun ama hiçbirinden keyif alamıyorsun. Kontrolü bırakamıyorsun çünkü güvensizlik seni ele geçirmiş. Arkandaki şehri görmüyorsun — hayat dışarıda akıyor.',
    presentEn: 'You cling to four coins but enjoy none. You cannot release control because insecurity has gripped you. You do not see the city behind — life flows outside.',
    directionTr: 'Bir sikkeyi bırak ve ne olduğunu gör. Kaybetme korkusu, sahip olduklarından daha pahalıya patlıyor. Elini aç, bolluk açık avuca gelir.',
    directionEn: 'Drop one coin and see what happens. Fear of losing costs more than what you own. Open your hand, abundance comes to the open palm.',
  ),
  68: CardMeaning(id: 68, themeTr: 'Zorluk, dışlanma, gizli destek', themeEn: 'Hardship, exclusion, hidden support', tone: CardTone.heavy, movement: CardMovement.motion, phase: CardPhase.neutral,
    pastTr: 'Karlı yolda yürüyen iki figür, aydınlatılmış katedralin vitray penceresinin önünden geçmiş. İçerideki sıcaklığı ve desteği görememişler. Sen de zor günlerde yardımı fark etmemişsin.',
    pastEn: 'Two figures walking the snowy road passed the cathedrals stained glass window. They could not see warmth inside. You too did not notice help during hard times.',
    presentTr: 'Soğuk ve karın ortasındasın. Beş sikke pencerenin üzerinde parlıyor ama sen onları göremiyorsun. Maddi zorluk yaşıyorsun ama fark etmediğin bir destek çok yakınında.',
    presentEn: 'You stand in cold and snow. Five coins shine above the window but you cannot see them. You face material hardship, but unnoticed support is very close.',
    directionTr: 'Başını kaldır ve vitray pencereye bak. Yardım istemek utanç değil, güçtür. Katedralin kapısı açık — içeri gir ve ısın.',
    directionEn: 'Raise your head and look at the stained glass window. Asking for help is not shame, but strength. The cathedrals door is open — go in and warm up.',
  ),
  69: CardMeaning(id: 69, themeTr: 'Cömertlik, adil paylaşım, karşılıklı yarar', themeEn: 'Generosity, fair sharing, mutual benefit', tone: CardTone.soft, movement: CardMovement.stillness, phase: CardPhase.neutral,
    pastTr: 'Terazisini tutan zengin tüccar, diz çökmüş iki figüre altın sikkeler dağıtmış. Sen de bir zamanlar ya veren ya da alan olmuşsun — ve bu denge hayatını şekillendirmiş.',
    pastEn: 'The wealthy merchant holding scales distributed gold coins to two kneeling figures. You too were once either the giver or receiver — and this balance shaped your life.',
    presentTr: 'Terazin dengede ve ellerin dolu. Altı sikke paylaşılmayı bekliyor. Cömertlik döngüsünde yerini al — veren el alan elden üstündür ama ikisi de kutsaldır.',
    presentEn: 'Your scales balance and your hands are full. Six coins await sharing. Take your place in the cycle of generosity — the giving hand is above, but both are sacred.',
    directionTr: 'Paylaş ama adil paylaş. Terazinin dengesini bozma. Cömertlik hesapsız olmalı ama sınırsız değil. Veren el alan elden üstündür, yeter ki denge korunsun.',
    directionEn: 'Share, but share fairly. Do not tip the scales. Generosity should be unconditional, but not unlimited.',
  ),
  70: CardMeaning(id: 70, themeTr: 'Sabır, yatırım, bekleme bilgeliği', themeEn: 'Patience, investment, wisdom of waiting', tone: CardTone.decision, movement: CardMovement.stillness, phase: CardPhase.neutral,
    pastTr: 'Çapa dayanmış çiftçi, asmanın üzerindeki yedi sikkeye bakmış ve hasadın zamanını beklemiş. Sen de bir zamanlar o sabırlı çiftçi gibi emeğinin meyvesini beklemişsin.',
    pastEn: 'The farmer leaning on his hoe gazed at seven coins on the vine and waited for harvest time. You too once waited like that patient farmer for the fruit of your labor.',
    presentTr: 'Yedi sikke dalda olgunlaşıyor ama henüz hasat zamanı değil. Asmanın üzerindeki meyveler sana bakıyor — sabır mı yoksa acele mi? Başarı doğru zamanda toplamaktadır.',
    presentEn: 'Seven coins ripen on the vine but harvest time has not yet come. The fruits on the vine gaze at you — patience or haste? Success lies in gathering at the right time.',
    directionTr: 'Çapanı bırakma ama acele de etme. Yatırımın büyüyor ve doğru zamanda muhteşem bir hasat olacak. Sabır en zor ama en karlı erdem.',
    directionEn: 'Do not put down the hoe, but do not rush either. Your investment grows, and at the right time the harvest will be magnificent. Patience is the hardest but most rewarding virtue.',
  ),
  71: CardMeaning(id: 71, themeTr: 'Özveri, ustalık yolu, detay odaklılık', themeEn: 'Dedication, path to mastery, attention to detail', tone: CardTone.soft, movement: CardMovement.stillness, phase: CardPhase.neutral,
    pastTr: 'Çalışma tezgahında oturan zanaatçı, her sikkeyi aynı titizlikle oymuş. Sekiz sikke duvarda asılıydı — her biri bir adımdı ustalık merdiveninde. Özveriyle çalıştın ve becerilerini bilemişsin.',
    pastEn: 'The craftsman at his workbench carved each coin with equal care. Eight coins hung on the wall — each a step on the mastery ladder. You worked with dedication and honed your skills.',
    presentTr: 'Tezgahındasın ve elindeki aletle bir sikke daha oyuyorsun. Sekiz merdiven basamağının altıncısındasın. Ustalık yolunda sabrın ve özenin meyvelerini toplamaya başlıyorsun.',
    presentEn: 'You sit at your bench carving yet another coin. You are on the sixth of eight steps. You begin to reap the fruits of patience and care on the path to mastery.',
    directionTr: 'Her detaya aynı özeni ver. Zanaatçının sekiz sikkesi gibi, tekrar tekrar yap ama her seferinde daha iyi yap. Ustalık bir an değil, bir süreçtir.',
    directionEn: 'Give equal care to every detail. Like the craftsmans eight coins, do it again and again, but better each time. Mastery is not a moment, but a process.',
  ),
  72: CardMeaning(id: 72, themeTr: 'Bağımsızlık, lüks, kendi kendine yetme', themeEn: 'Independence, luxury, self-sufficiency', tone: CardTone.soft, movement: CardMovement.stillness, phase: CardPhase.completion,
    pastTr: 'Zarif kadın, üzüm bağlarının ortasındaki bahçesinde yürürken elindeki şahini okşamış. Dokuz sikke etrafında parlamış. Kendi ellerin ile inşa ettiğin bağımsızlık sana huzur vermiş.',
    pastEn: 'The elegant woman strolled through her vineyard garden, stroking the falcon on her hand. Nine coins gleamed around her. The independence you built with your own hands gave you peace.',
    presentTr: 'Bağının ortasındasın ve her asma senin emeğinin eseri. Şahin eğitilmiş sezgini, üzümler biriktirdiğin zenginliği simgeliyor. Kimseye bağımlı değilsin ve bu güzelliğin tadını çıkar.',
    presentEn: 'You stand amidst your vineyard, every vine the fruit of your labor. The falcon represents trained intuition, the grapes your accumulated wealth. You depend on no one — enjoy this beauty.',
    directionTr: 'Bağımsızlığını kutla ama yalnızlığa dönüştürme. Şahinin gibi sezgilerini dinle ve bağının meyvelerini paylaş.',
    directionEn: 'Celebrate your independence but do not let it become isolation. Listen to your instincts like your falcon and share the fruits of your vineyard. True wealth gains meaning when shared.',
  ),
  73: CardMeaning(id: 73, themeTr: 'Kalıcı miras, nesiller arası bağ, köklü refah', themeEn: 'Lasting legacy, generational bond, rooted prosperity', tone: CardTone.soft, movement: CardMovement.stillness, phase: CardPhase.completion,
    pastTr: 'Kemerli taş kapının önünde üç nesil bir araya gelmiş. On altın sikke bu köklü ailenin sarsılmaz bağını aydınlatmış. Kurduğun miras nesilden nesile aktarılacak kadar güçlenmiş.',
    pastEn: 'Three generations stood together before the castle gate — elder, adult and child. Ten coins gleamed from every part of the arch. The legacy you built passed to generations.',
    presentTr: 'On sikke seni ve aileni sarıyor. Kale kapısının altındasın ve nesiller arası bağ güçlü. Kurduğun düzen, sadece bugün için değil, gelecek nesiller için de parlıyor.',
    presentEn: 'Ten coins surround you and your family. You stand beneath the castle gate, the generational bond strong. The order you built shines not just for today, but for future generations.',
    directionTr: 'Bugün ektiğin her tohum, torunlarının ağacı olacak. Mirasın sadece maddi değil, değerlerin de aktarılmalı. Kalıcı olanı inşa et.',
    directionEn: 'Every seed you plant today will become your grandchildrens tree. Your legacy should include not just material wealth, but values too. Build what lasts.',
  ),
  74: CardMeaning(id: 74, themeTr: 'Yeni öğrenme, pratik hayal, dikkatli adım', themeEn: 'New learning, practical dream, careful step', tone: CardTone.soft, movement: CardMovement.stillness, phase: CardPhase.beginning,
    pastTr: 'Yeşil otların üzerinde yürüyen genç, elindeki sikkeye hayalci bir gözle bakmış. Uzaktaki dağlar hedefini, ayaklarının altındaki toprak ise sabırlı adımlarının simgesiymiş.',
    pastEn: 'The youth walking on green grass gazed at the coin in his hand with dreamy eyes. Distant mountains symbolized his goal, earth beneath his feet his patient steps.',
    presentTr: 'Sikkeyi ellerinde tutuyorsun ve geleceği hayal ediyorsun. Ama bu boş bir rüya değil — ayakların yerde, gözlerin ufukta. Pratik bir hayalperestsin ve bu mükemmel bir denge.',
    presentEn: 'You hold the coin in your hands and envision the future. But this is not an empty dream — feet on the ground, eyes on the horizon. You are a practical dreamer, a perfect balance.',
    directionTr: 'Hayalini sikkeye çevir. Adım adım, sabırla ve dikkatle ilerle. Genç öğrencinin merakıyla her fırsatı değerlendir.',
    directionEn: 'Turn your dream into a coin. Step by step, patiently and carefully advance. Seize every opportunity with the young students curiosity.',
  ),
  75: CardMeaning(id: 75, themeTr: 'Sabırlı ilerleme, güvenilir güç, istikrar', themeEn: 'Patient progress, reliable strength, stability', tone: CardTone.decision, movement: CardMovement.stillness, phase: CardPhase.neutral,
    pastTr: 'Ağır adımlarla yürüyen atın üzerindeki şövalye, elindeki sikkeye dikkatle bakmış. Tarlalar ve tepeler geçtikçe, sabırlı ama kararlı adımlarla hedefe yaklaşmışsın.',
    pastEn: 'The knight on his heavy-stepping horse carefully examined the coin in his hand. As fields and hills passed, you approached your goal with patient but determined steps.',
    presentTr: 'Atın yavaş ama sağlam adımlarla ilerliyor. Elindeki sikke maddi hedefini simgeliyor. Hızlı değilsin ama güvenilirsin — ve bu sarsılmaz istikrarın seni çok daha güçlü kılıyor.',
    presentEn: 'Your horse advances with slow but solid steps. The coin in your hand symbolizes your material goal. You are not fast but reliable — and this unshakable stability makes you far stronger.',
    directionTr: 'Hızlanma, kendi ritmini koru. Şövalyenin sabırlı ama kararlı yürüyüşü gibi ilerle. Hedefine ulaşacaksın — sadece devam et.',
    directionEn: 'Do not speed up, maintain your rhythm. Advance like the knights patient but determined march. You will reach your goal — just keep going.',
  ),
  76: CardMeaning(id: 76, themeTr: 'Şefkatli bolluk, toprak anası, koruyucu bereket', themeEn: 'Compassionate abundance, earth mother, protective blessing', tone: CardTone.soft, movement: CardMovement.stillness, phase: CardPhase.neutral,
    pastTr: 'Gül bahçesinin ortasındaki tahtında oturan kraliçe, kucağındaki sikkeyi bir bebek gibi sevgiyle tutmuş. Tavşan ayaklarının dibinde oturmuş. Bereket ve şefkatin birleştiği o dönem seni beslemiş.',
    pastEn: 'The queen on her throne amid the rose garden held the coin in her lap lovingly like a baby. A rabbit sat at her feet. That period where abundance and compassion united nourished you.',
    presentTr: 'Gül bahçenin ortasındasın ve kucağındaki sikke hem maddi hem manevi bolluğu temsil ediyor. Tavşanın doğurganlığı, sütunların sağlamlığı — her şey yerinde ve bereketli.',
    presentEn: 'You sit amid your rose garden, the coin in your lap represents both material and spiritual abundance. The rabbits fertility, the pillars solidity — everything is in place and blessed.',
    directionTr: 'Kraliçenin sikkeyi koruduğu gibi nimetlerini koru ama paylaş. Bolluk paylaşıldıkça çoğalır. Toprak anası gibi besle, büyüt ve koru.',
    directionEn: 'Protect your blessings as the queen protects the coin, but share. Abundance multiplies when shared. Nurture, grow and protect like the earth mother.',
  ),
  77: CardMeaning(id: 77, themeTr: 'Maddi zirve, kalıcı başarı, miras bırakan güç', themeEn: 'Material peak, lasting success, legacy-building power', tone: CardTone.soft, movement: CardMovement.stillness, phase: CardPhase.completion,
    pastTr: 'Üzüm bağlarıyla çevrili kalesinin önündeki kralın cüppesini altın sikkeler süslemiş. Boğa başlı tahtında oturan bu hükümdar, maddi dünyayı fethetmiş. Sen de öyle.',
    pastEn: 'Gold coins adorned the robe of the king before his castle surrounded by vineyards. This ruler on his bull-headed throne had conquered the material world. So did you.',
    presentTr: 'Kralın tahtındasın — üzüm bağlarının, kalelerinin ve altın sikkelerinin arasında. Maddi zirvedesin ve herkes sana saygıyla bakıyor. Bu başarıyı kalıcı kıl.',
    presentEn: 'You sit on the kings throne — amid vineyards, castles and golden coins. You are at the material peak and everyone looks upon you with respect. Make this success lasting.',
    directionTr: 'Başarının tadını çıkar ama onu miras olarak bırakmayı da planla. Kralın sikkelerini sayma, onlarla imparatorluk kur. Bağını büyüt, mirasını koru.',
    directionEn: 'Enjoy your success but also plan to leave it as legacy. Do not count the kings coins, build an empire with them. Grow your vineyard, protect your legacy.',
  ),
};


// ============================================================
// Yorum Motoru
// ============================================================

class TarotReading {
  final String generalTheme;
  final String pastInfluence;
  final String presentEnergy;
  final String directionAdvice;
  final String closingMessage;
  final FlowType flowType;
  final String flowLabel;
  final List<String> promises;

  const TarotReading({
    required this.generalTheme,
    required this.pastInfluence,
    required this.presentEnergy,
    required this.directionAdvice,
    required this.closingMessage,
    required this.flowType,
    required this.flowLabel,
    required this.promises,
  });
}

TarotReading generateReading({
  required int card1Id,
  required int card2Id,
  required int card3Id,
  required String card1Name,
  required String card2Name,
  required String card3Name,
  required bool isTr,
}) {
  final m1 = cardMeanings[card1Id]!;
  final m2 = cardMeanings[card2Id]!;
  final m3 = cardMeanings[card3Id]!;

  // --- Akış tipi belirleme ---
  final flowType = _detectFlowType(m1, m2, m3);
  final flowLabel = _flowLabel(flowType, isTr);

  // --- Genel tema (hikaye cümlesi) ---
  final generalTheme = _buildGeneralTheme(
    m1, m2, m3, card1Name, card2Name, card3Name, flowType, isTr,
  );

  // --- Pozisyon yorumları (her seferinde farklı ek cümle) ---
  final _posRng = Random();
  
  final pastInfluence = _variedPositionText(
    isTr ? m1.pastTr : m1.pastEn, 'past', flowType, isTr, _posRng,
  );
  final presentEnergy = _variedPositionText(
    isTr ? m2.presentTr : m2.presentEn, 'present', flowType, isTr, _posRng,
  );
  final directionAdvice = _variedPositionText(
    isTr ? m3.directionTr : m3.directionEn, 'direction', flowType, isTr, _posRng,
  );

  // --- Vaatler / Anahtar kelimeler (bir kere hesapla) ---
  final promises = _buildPromises(m1, m2, m3, isTr);

  // --- Kapanış mesajı (vaatlerle aynı kelimeleri kullanır) ---
  final closingMessage = _buildClosing(promises, flowType, isTr);

  return TarotReading(
    generalTheme: generalTheme,
    pastInfluence: pastInfluence,
    presentEnergy: presentEnergy,
    directionAdvice: directionAdvice,
    closingMessage: closingMessage,
    flowType: flowType,
    flowLabel: flowLabel,
    promises: promises,
  );
}

// --- Vaatler / Anahtar Kelimeler ---
List<String> _buildPromises(CardMeaning m1, CardMeaning m2, CardMeaning m3, bool isTr) {
  final rng = Random();
  final words1 = (isTr ? m1.themeTr : m1.themeEn).split(',').map((s) => s.trim()).toList();
  final words2 = (isTr ? m2.themeTr : m2.themeEn).split(',').map((s) => s.trim()).toList();
  final words3 = (isTr ? m3.themeTr : m3.themeEn).split(',').map((s) => s.trim()).toList();

  words1.shuffle(rng);
  words2.shuffle(rng);
  words3.shuffle(rng);

  String p1 = words1.first;
  String p2 = words2.first;
  String p3 = words3.first;

  if (p2 == p1 && words2.length > 1) p2 = words2[1];
  if ((p3 == p1 || p3 == p2) && words3.length > 1) p3 = words3[1];
  if ((p3 == p1 || p3 == p2) && words3.length > 2) p3 = words3[2];

  return [p1, p2, p3];
}

// --- Akış tespiti ---
FlowType _detectFlowType(CardMeaning m1, CardMeaning m2, CardMeaning m3) {
  final tones = [m1.tone, m2.tone, m3.tone];
  final heavyCount = tones.where((t) => t == CardTone.heavy).length;
  final softCount = tones.where((t) => t == CardTone.soft).length;

  // Dönüşüm akışı: ending + soft veya awakening/completion varsa
  final phases = [m1.phase, m2.phase, m3.phase];
  final hasEnding = phases.contains(CardPhase.ending);
  final hasCompletion = phases.contains(CardPhase.completion);
  final hasAwakening = phases.contains(CardPhase.awakening);
  final hasBeginning = phases.contains(CardPhase.beginning);

  if (hasEnding && (hasCompletion || hasAwakening || softCount >= 1)) {
    return FlowType.transformative;
  }

  // Çatışma: 2+ ağır kart
  if (heavyCount >= 2) {
    return FlowType.conflicting;
  }

  // Uyumlu: 2+ yumuşak kart
  if (softCount >= 2) {
    return FlowType.harmonious;
  }

  // Dönüşüm: bitiş → başlangıç
  if (hasEnding && hasBeginning) {
    return FlowType.transformative;
  }

  // Varsayılan
  if (heavyCount >= 1 && softCount >= 1) {
    return FlowType.transformative;
  }

  return FlowType.harmonious;
}

String _flowLabel(FlowType flow, bool isTr) {
  switch (flow) {
    case FlowType.harmonious:
      return isTr ? '✨ Uyumlu Akış' : '✨ Harmonious Flow';
    case FlowType.conflicting:
      return isTr ? '⚡ Yüzleşme Akışı' : '⚡ Confrontation Flow';
    case FlowType.transformative:
      return isTr ? '🔄 Dönüşüm Akışı' : '🔄 Transformation Flow';
  }
}

// --- Genel tema cümlesi (rastgele varyasyonlu) ---
final _themeRng = Random();

String _buildGeneralTheme(
  CardMeaning m1, CardMeaning m2, CardMeaning m3,
  String n1, String n2, String n3,
  FlowType flow, bool isTr,
) {
  List<String> pool;

  switch (flow) {
    case FlowType.harmonious:
      pool = isTr ? [
        '$n1 kartının enerjisi $n2 ile uyum yakalıyor, $n3 bu dengeyi taçlandırıyor. İçindeki ışığı korkusuzca yansıt.',
        'Üç kart tek bir nefes gibi: $n1 enerjisi seni hazırlıyor, $n2 yolunu aydınlatıyor, $n3 seni hedefe taşıyor.',
        '$n1 kartı temeli attı, $n2 duvarları yükseltti, $n3 kapıyı açtı. Bu ev senin.',
        '$n1 ile $n2 birlikte dans ediyor, $n3 bu dansı kutsuyor. Hayat seninle uyumda.',
        '$n1 kartının bilgeliği $n2 ile derinleşiyor, $n3 bunu eyleme dönüştürüyor. Akış seninle.',
        '$n1 enerjisi sana güven verdi, $n2 cesaretini besledi, $n3 yolunu açtı. Şimdi yürü.',
      ] : [
        'The energy of $n1 harmonizes with $n2, and $n3 crowns this balance. Reflect your inner light fearlessly.',
        'Three cards breathe as one: $n1 prepares you, $n2 illuminates your path, $n3 carries you to your goal.',
        '$n1 laid the foundation, $n2 raised the walls, $n3 opened the door. This home is yours.',
        '$n1 and $n2 dance together, $n3 blesses this dance. Life is in harmony with you.',
        'The wisdom of $n1 deepens with $n2, and $n3 turns it into action. The flow is with you.',
        'The energy of $n1 gave you confidence, $n2 nourished your courage, $n3 cleared your path. Now walk.',
      ];
      break;
    case FlowType.conflicting:
      pool = isTr ? [
        '$n1 kartı seni sarsıyor, $n2 sınıyor ama $n3 çıkış yolunu gösteriyor.',
        '$n1 enerjisi yıkıyor, $n2 sorgulatıyor ama $n3 küllerin altındaki altını ortaya çıkarıyor.',
        '$n1 kartının fırtınası esiyor, $n2 dengeyi sınıyor, $n3 gözlerini açıyor. Dikkat et.',
        'Kartlar çatışıyor: $n1 enerjisi ateş, $n2 rüzgâr, $n3 ise o yangından doğacak yeni ormanı temsil ediyor.',
        '$n1 kartı seni sınadı, $n2 yüzleşme getirdi ama $n3 ayağa kalkman gerektiğini hatırlatıyor.',
        '$n1 enerjisi zorluyor, $n2 karşına dikiliyor ama $n3 sana diyor ki: sen bundan büyüksün.',
      ] : [
        'The $n1 card shakes you, $n2 tests you, but $n3 reveals the way forward.',
        'The energy of $n1 breaks apart, $n2 questions, but $n3 uncovers gold beneath the ashes.',
        'The storm of $n1 blows, $n2 tests your balance, $n3 opens your eyes. Pay attention.',
        'The cards clash: $n1 energy is fire, $n2 is the wind, $n3 represents the new forest born from that blaze.',
        '$n1 challenged you, $n2 brought confrontation, but $n3 reminds you to stand.',
        'The energy of $n1 pushes, $n2 stands in your way, but $n3 tells you: you are bigger than this.',
      ];
      break;
    case FlowType.transformative:
      pool = isTr ? [
        '$n1 kartı bir kapıyı kapatıyor, $n2 seni dönüştürüyor, $n3 yeni bir başlangıç sunuyor.',
        '$n1 enerjisi eskiyi geride bıraktı, $n2 seni yoğurdu, $n3 yeni halini ortaya çıkardı. Tanışma zamanı.',
        '$n1 kartı ile bir dönem sona erdi. $n2 geçiş sürecini yönetiyor. $n3 yeni hayatının ilk adımı.',
        '$n1 enerjisi eski hikâyeni kapattı, $n2 sana yeni bir kalem uzattı, $n3 boş sayfayı önüne koydu. Yaz.',
        '$n1 kartı kozanı ördü, $n2 seni olgunlaştırdı, $n3 kanatlarını açtı. Artık uç.',
        '$n1 enerjisi geceyi getirdi, $n2 karanlıkta seni korudu, $n3 şafağı başlattı. Bu senin dönüşümün.',
      ] : [
        'The $n1 card closes a door, $n2 transforms you, $n3 offers a fresh start.',
        'The energy of $n1 left the old behind, $n2 reshaped you, $n3 revealed your new self. Time to meet yourself.',
        'A chapter ended with $n1. $n2 guides the transition. $n3 is the first step of your new life.',
        'The energy of $n1 closed the old story, $n2 offered you a new pen, $n3 placed a blank page before you. Write.',
        'The $n1 card wove the cocoon, $n2 matured you within, $n3 unfurled your wings. Now fly.',
        'The energy of $n1 brought the night, $n2 sheltered you in the dark, $n3 broke the dawn. This is your metamorphosis.',
      ];
      break;
  }

  return pool[_themeRng.nextInt(pool.length)];
}

// --- Pozisyon yorumlarına rastgele ek cümle ---
String _variedPositionText(
  String base, String position, FlowType flow, bool isTr, Random rng,
) {
  List<String> suffixes;

  if (position == 'past') {
    suffixes = isTr ? [
      ' Bu iz hâlâ sende yaşıyor.',
      ' O anın enerjisi bugün bile hissediliyor.',
      ' Geçmiş bitti ama dersi bitmedi.',
      ' O deneyim seni sen yapan parçalardan biri.',
      ' Geride bıraktığını sanıyorsun ama o seni bırakmadı.',
      ' Bu hatıra bir pusula gibi yön veriyor.',
      ' Orada bir şey öğrendin; şimdi hatırla.',
      ' Geçmişin gölgeleri aydınlığa dönüşmeyi bekliyor.',
    ] : [
      ' This mark still lives within you.',
      ' The energy of that moment is still felt today.',
      ' The past ended but its lesson did not.',
      ' That experience is one of the pieces that made you who you are.',
      ' You think you left it behind, but it never left you.',
      ' This memory guides you like a compass.',
      ' You learned something there; now remember.',
      ' The shadows of the past await their turn to become light.',
    ];
  } else if (position == 'present') {
    suffixes = isTr ? [
      ' Şu an tam da olman gereken yerdesin.',
      ' Bu enerji geçici değil; onu kullan.',
      ' Şimdi karar anı, dikkat et.',
      ' Bu an sana özel bir mesaj taşıyor.',
      ' Gözlerini aç, cevap önünde duruyor.',
      ' Bu enerji bir davet; kabul et ya da reddet.',
      ' Şimdiki an tek gerçek güç kaynağın.',
      ' Zamanın durduğu bu noktada, içine bak.',
    ] : [
      ' You are exactly where you need to be right now.',
      ' This energy is not temporary; use it.',
      ' Now is the moment of decision, pay attention.',
      ' This moment carries a special message for you.',
      ' Open your eyes, the answer stands before you.',
      ' This energy is an invitation; accept or decline.',
      ' The present moment is your only true source of power.',
      ' At this point where time stands still, look within.',
    ];
  } else {
    suffixes = isTr ? [
      ' Cesur ol, yol seni bekliyor.',
      ' Bu yön tek seçenek değil ama en doğrusu.',
      ' Adımını at; gerisini evren halledecek.',
      ' Geleceğin yazılmadı, onu sen yazıyorsun.',
      ' Bu kapıdan geçersen geri dönüşü olmayabilir. Ama o iyi bir şey.',
      ' Pusula kalbinde, harita ellerinde.',
      ' İleriye bak; geçmişe değil.',
      ' Yolun sonunda seni bekleyen, bugün hayal bile edemeyeceğin bir sen.',
    ] : [
      ' Be brave, the path awaits you.',
      ' This direction is not the only option, but the truest one.',
      ' Take your step; the universe will handle the rest.',
      ' Your future is not written, you are writing it.',
      ' If you pass through this door, there may be no return. But that is a good thing.',
      ' The compass is in your heart, the map in your hands.',
      ' Look forward, not backward.',
      ' At the end of the road awaits a version of you that today you cannot even imagine.',
    ];
  }

  return '$base ${suffixes[rng.nextInt(suffixes.length)]}';
}

// --- Kapanış mesajı (Kartların Gizli Fısıltısı — rastgele varyasyonlu) ---
final _closingRng = Random();

String _buildClosing(
  List<String> promises,
  FlowType flow, bool isTr,
) {
  final k1 = promises[0];
  final k2 = promises[1];
  final k3 = promises[2];

  List<String> pool;

  switch (flow) {
    case FlowType.harmonious:
      pool = isTr ? [
        '"$k1" seni buraya getirdi.\n"$k3" seni ileriye taşıyacak.\nSadece güven.',
        '"$k1" bir kapıydı.\n"$k3" o kapının ardındaki hazine.\nSen zaten içindesin.',
        '"$k1" tohumdu.\n"$k2" topraktı.\n"$k3" açan çiçek.\nŞimdi kokla.',
        'Hayat sana "$k1" fısıldadı.\nSen "$k2" ile cevap verdin.\n"$k3" yolunu aydınlattı.\nDevam et.',
        '"$k1" sessizce hayatına girdi.\n"$k3" sessizce seni dönüştürecek.\nArada sen varsın.\nVe bu yeterli.',
        'Her şey "$k1" ile başladı.\n"$k2" yolculuğun oldu.\n"$k3" seni bekliyor.\nAma yol daha bitmedi.',
        'Hayat sana "$k1" öğretti.\n"$k2" ile büyüdün.\nŞimdi "$k3" seninle.\nKullan.',
        '"$k3" sana bakıyor.\nİçinde "$k1" var.\nYanında "$k2".\nDinle.',
      ] : [
        '"$k1" brought you here.\n"$k3" will carry you forward.\nJust trust.',
        '"$k1" was a door.\n"$k3" is the treasure behind it.\nYou are already inside.',
        '"$k1" was the seed.\n"$k2" was the soil.\n"$k3" is the bloom.\nBreathe it in.',
        'Life whispered "$k1."\nYou answered with "$k2."\n"$k3" lit the way.\nKeep going.',
        '"$k1" entered your life quietly.\n"$k3" will quietly transform you.\nIn between, there is you.\nAnd that is enough.',
        'It all began with "$k1."\n"$k2" became your journey.\n"$k3" awaits.\nBut the road goes on.',
        'Life taught you "$k1."\nYou grew with "$k2."\nNow "$k3" is with you.\nUse it.',
        '"$k3" watches over you.\n"$k1" within.\n"$k2" beside you.\nListen.',
      ];
      break;
    case FlowType.conflicting:
      pool = isTr ? [
        '"$k1" seni sarstı.\nAma "$k3" seni yeniden kuracak.\nHer yara bir kapıdır.',
        '"$k1" acıttı.\n"$k2" sordu: neden?\n"$k3" cevapladı: güçlenmek için.\nŞimdi bil.',
        'Zorluk yaşadın.\n"$k1" seni sınadı.\n"$k2" dağıttı.\nAma "$k3" diyor ki:\nKırık yerlerden ışık girer.',
        '"$k1" bir darbe gibiydi.\n"$k2" onu derinleştirdi.\n"$k3" ise uzanan bir el.\nTut.',
        'Acı "$k1" ile başladı.\n"$k2" ile derinleşti.\nAma "$k3"...\n"$k3" seni tanımlayacak olan.',
        '"$k1" karanlıktı.\n"$k2" fırtına.\nAma "$k3" şafak.\nVe şafak her zaman kazanır.',
        'Düştün.\n"$k1" zorladı.\n"$k2" sınadı.\nAma "$k3" sana el uzatıyor.\nYakala.',
        '"$k1" yakıcıydı.\n"$k2" küllere dönüştürdü.\n"$k3" anka kuşu gibi yeniden doğuş.\nSen de öylesin.',
      ] : [
        '"$k1" shook you.\nBut "$k3" will rebuild you.\nEvery wound is a door.',
        '"$k1" hurt.\n"$k2" asked: why?\n"$k3" answered: to grow stronger.\nNow you know.',
        'You faced hardship.\n"$k1" tested you.\n"$k2" scattered.\nBut "$k3" says:\nLight enters through the cracks.',
        '"$k1" was a blow.\n"$k2" deepened it.\n"$k3" is the hand reaching out.\nGrab it.',
        'Pain began with "$k1."\nDeepened with "$k2."\nBut "$k3"...\n"$k3" is what will define you.',
        '"$k1" was the darkness.\n"$k2" was the storm.\nBut "$k3" is the dawn.\nAnd dawn always wins.',
        'You fell.\n"$k1" challenged you.\n"$k2" tested you.\nBut "$k3" reaches out.\nGrab on.',
        '"$k1" was the fire.\n"$k2" became the ashes.\n"$k3" is the rebirth.\nSo are you.',
      ];
      break;
    case FlowType.transformative:
      pool = isTr ? [
        '"$k1" sona erdi.\n"$k3" doğuyor.\nSen de.',
        '"$k1" bitti.\nAma "$k3" başlıyor.\nFinaller her zaman yeni sezonların ilk sahnesidir.',
        'Eski sen "$k1" ile vedalaştı.\n"$k2" geçiş dönemiydi.\n"$k3" yeniden doğuş.\nKalk.',
        '"$k1" son sayfaydı.\n"$k2" sessizlikti.\n"$k3" yeni bir hikâyenin ilk satırı.\nYeniden doğdun.',
        '"$k1" yıkımı getirdi.\n"$k2" temizledi.\n"$k3" inşa edecek.\nMimar sensin.',
        '"$k1" tırtıldı.\n"$k2" kozaydı.\n"$k3" kelebek.\nArtık uçabilirsin.',
        '"$k1" seni aldı.\n"$k2" seni değiştirdi.\n"$k3" seni geri verdi.\nAma farklı.\nÇok farklı.',
        '"$k1" bir vedaydı.\n"$k2" yolculuk.\n"$k3" yeni bir merhaba.\nGülümse.',
      ] : [
        '"$k1" has ended.\n"$k3" is being born.\nSo are you.',
        '"$k1" ended.\nBut "$k3" begins.\nFinales are always the opening scenes of new seasons.',
        'The old you said goodbye with "$k1."\n"$k2" was the transition.\n"$k3" is resurrection.\nRise.',
        '"$k1" was the last page.\n"$k2" was silence.\n"$k3" is the first line of a new story.\nYou are reborn.',
        '"$k1" brought the fall.\n"$k2" cleared the ground.\n"$k3" will build.\nYou are the architect.',
        '"$k1" was the caterpillar.\n"$k2" was the cocoon.\n"$k3" is the butterfly.\nYou can fly now.',
        '"$k1" took you.\n"$k2" changed you.\n"$k3" gave you back.\nBut different.\nVery different.',
        '"$k1" was a goodbye.\n"$k2" the journey.\n"$k3" a new hello.\nSmile.',
      ];
      break;
  }

  return pool[_closingRng.nextInt(pool.length)];
}


// ============================================================
// Full Arcana — 7 Kart Yorum Motoru (Premium)
// ============================================================

/// 7 kartlık okumada her pozisyonun bilgisi
class FullCardReading {
  final String positionTitle;
  final String content;
  final String cardName;
  final int cardIndex;

  const FullCardReading({
    required this.positionTitle,
    required this.content,
    required this.cardName,
    required this.cardIndex,
  });
}

/// Element analizi sonucu
class ElementAnalysis {
  final Map<String, double> elements; // {'Ateş': 0.7, 'Su': 0.2, ...}
  final String dominantElement;
  final String dominantEmoji;
  final String dominantDescriptionTr;
  final String dominantDescriptionEn;

  const ElementAnalysis({
    required this.elements,
    required this.dominantElement,
    required this.dominantEmoji,
    required this.dominantDescriptionTr,
    required this.dominantDescriptionEn,
  });
}

/// Kart ilişki analizi
class CardRelation {
  final String card1Name;
  final String card2Name;
  final String relationTextTr;
  final String relationTextEn;
  final String emoji;

  const CardRelation({
    required this.card1Name,
    required this.card2Name,
    required this.relationTextTr,
    required this.relationTextEn,
    required this.emoji,
  });
}

/// Günlük ritüel önerisi
class RitualSuggestion {
  final String titleTr;
  final String titleEn;
  final String actionTr;
  final String actionEn;
  final String emoji;

  const RitualSuggestion({
    required this.titleTr,
    required this.titleEn,
    required this.actionTr,
    required this.actionEn,
    required this.emoji,
  });
}

class FullTarotReading {
  final String generalTheme;
  final List<FullCardReading> cardReadings; // 7 adet
  final String adviceParagraph;
  final String closingMessage;
  final FlowType flowType;
  final String flowLabel;
  final List<String> promises;
  // Premium özellikler
  final ElementAnalysis elementAnalysis;
  final List<CardRelation> cardRelations;
  final int cosmicScore;
  final String cosmicLabelTr;
  final String cosmicLabelEn;
  final String secretMessageTr;
  final String secretMessageEn;
  final RitualSuggestion ritualSuggestion;

  const FullTarotReading({
    required this.generalTheme,
    required this.cardReadings,
    required this.adviceParagraph,
    required this.closingMessage,
    required this.flowType,
    required this.flowLabel,
    required this.promises,
    required this.elementAnalysis,
    required this.cardRelations,
    required this.cosmicScore,
    required this.cosmicLabelTr,
    required this.cosmicLabelEn,
    required this.secretMessageTr,
    required this.secretMessageEn,
    required this.ritualSuggestion,
  });
}

/// 7 kart pozisyon başlıkları
List<String> _fullPositionsTr = [
  'Geçmiş',
  'Şimdi',
  'Gizli Etkiler',
  'Engeller',
  'Çevre',
  'Tavsiye',
  'Sonuç',
];

List<String> _fullPositionsEn = [
  'Past',
  'Present',
  'Hidden Influences',
  'Obstacles',
  'Environment',
  'Advice',
  'Outcome',
];

/// Pozisyona özgü yorum üretme (7 pozisyon)
String _fullPositionReading(CardMeaning meaning, int positionIndex, bool isTr, Random rng) {
  // Her pozisyon için base text + ek cümle
  String base;
  List<String> extras;

  switch (positionIndex) {
    case 0: // Geçmiş
      base = isTr ? meaning.pastTr : meaning.pastEn;
      extras = isTr ? [
        'Bu enerji seni bugüne taşıdı.',
        'Geçmişin gölgesi hâlâ üzerinde.',
        'O deneyim bugünkü gücünün kaynağı.',
        'Geride bıraktığını sandığın ama bırakamadığın bir iz.',
      ] : [
        'This energy carried you to today.',
        'The shadow of the past still lingers.',
        'That experience is the source of your present strength.',
        'A mark you thought you left behind, but never truly did.',
      ];
      break;
    case 1: // Şimdi
      base = isTr ? meaning.presentTr : meaning.presentEn;
      if (meaning.tone == CardTone.soft) {
        extras = isTr ? [
          'Şu an hayatın tam kalbinde, bu kartın o şifalı ve ince titreşimi yankılanıyor.',
          'Zaman tam da bu naif enerjiyi kucaklayıp derin bir nefes alma zamanı.',
          'İçinde bulunduğun an, bu kartın sükunetiyle yıkanıyor.',
        ] : [
          'Right now, at the very heart of your life, the healing and subtle vibration of this card echoes.',
          'It is time to embrace this naive energy and take a deep breath.',
          'The moment you are in is washed with the serenity of this card.',
        ];
      } else if (meaning.tone == CardTone.heavy) {
        extras = isTr ? [
          'Şu an etrafını saran bu yoğun atmosfer, aslında içinde taşıdığın gücü uyandırmak için var.',
          'Zamanın bu ağır kesitinden geçerken, asıl gücünün bu yüzleşmede gizli olduğunu hatırla.',
          'Şu an her ne kadar zorlu görünse de, bu enerji seni yeniden inşa etmek için çalışıyor.',
        ] : [
          'This dense atmosphere surrounding you right now exists to awaken the power you carry inside.',
          'While passing through this heavy segment of time, remember your true strength is hidden in this confrontation.',
          'Even though it seems challenging now, this energy is working to rebuild you.',
        ];
      } else { // decision / motion
        extras = isTr ? [
          'Tam da şu an, hayat seni bu net kararlılıkla hareket etmeye çağırıyor.',
          'Anın gücü tamamen zihninin açıklığında ve atacağın o cesur adımda gizli.',
          'Zaman durmayı değil, bu kartın gösterdiği kararlılıkla eyleme geçmeyi emrediyor.',
        ] : [
          'Right now, life calls you to act with this clear determination.',
          'The power of the moment is hidden entirely in the clarity of your mind and the bold step you will take.',
          'Time commands not to pause, but to take action with the resolve shown by this card.',
        ];
      }
      break;
    case 2: // Gizli Etkiler
      base = isTr ? meaning.directionTr : meaning.directionEn;
      extras = isTr ? [
        'Farkında olmadığın ama hayatını yönlendiren bir güç bu.',
        'Bilinçaltın sana bunu fısıldıyor, duymaya hazır ol.',
        'Görünmeyen iplerle bağlı olduğun bir enerji.',
        'Bu etki karanlıkta çalışıyor ama sonuçları aydınlıkta.',
        'Perdenin arkasındaki güç budur.',
      ] : [
        'A force you are unaware of, yet it steers your life.',
        'Your subconscious whispers this, be ready to listen.',
        'An energy you are invisibly tied to.',
        'This influence works in the dark, but results show in the light.',
        'This is the power behind the veil.',
      ];
      break;
    case 3: // Engeller
      base = isTr ? meaning.presentTr : meaning.presentEn;
      if (meaning.tone == CardTone.soft) {
        extras = isTr ? [
          'Bu kartın o yumuşak ve şifalı enerjisini hayatına alamamak, şu an önündeki en büyük engel olabilir.',
          'Şu sıralar bu kartın temsil ettiği sükunete direniyor gibisin.',
          'İçindeki bu yumuşak gücü reddetmek, senin en temel pürüzün.',
        ] : [
          'Failing to welcome this cards soft and healing energy might be your biggest obstacle.',
          'You seem to be resisting the serenity this card represents.',
          'Rejecting this inner soft power is your primary hurdle.',
        ];
      } else if (meaning.tone == CardTone.heavy) {
        extras = isTr ? [
          'Üzerindeki bu yoğun ve ağır enerji, ilerlemeni durduran görünmez bir duvara dönüşmüş.',
          'Kartın temsil ettiği bu ağır gölge, şu an aşman gereken en büyük pürüz.',
          'Bu yükü taşımakta ısrar etmen, ne yazık ki önündeki yolu kapatıyor.',
        ] : [
          'This dense and heavy energy has become an invisible wall stopping your progress.',
          'The dark shadow this card represents is the biggest hurdle you must overcome.',
          'Insisting on carrying this burden unfortunately blocks the path ahead.',
        ];
      } else { // decision
        extras = isTr ? [
          'Her şeyi mantıkla çözmeye çalışmak ya da bir karara sıkışıp kalmak, şu an önündeki asıl engel.',
          'Eyleme geçmek yerine sürekli analiz yapmak, ilerlemeni yavaşlatan gizli bir duvar olabilir.',
          'Bu kartın gerektirdiği o net kararı vermeyi ertelemek, seni bu eşikte bekleten temel pürüz.',
        ] : [
          'Trying to solve everything with logic or being stuck on a decision is your main obstacle.',
          'Continuously analyzing instead of taking action might be a hidden wall slowing your progress.',
          'Delaying the clear decision this card demands is the primary hurdle keeping you at this threshold.',
        ];
      }
      break;
    case 4: // Çevre
      base = isTr ? meaning.pastTr : meaning.pastEn;
      extras = isTr ? [
        'Çevrenden gelen bu enerji seni derinden etkiliyor.',
        'Etrafındaki insanlar bu kartın enerjisini taşıyor.',
        'Çevrenin sessiz etkisi hafife alınmamalı.',
        'Yakınlarından gelen bu titreşim, kararlarını şekillendiriyor.',
        'Dış dünyanın sana gönderdiği bir mesaj bu.',
      ] : [
        'This energy from your surroundings deeply affects you.',
        'People around you carry this cards energy.',
        'The silent influence of your environment should not be underestimated.',
        'This vibration from those close to you shapes your decisions.',
        'This is a message the outer world sends you.',
      ];
      break;
    case 5: // Tavsiye
      base = isTr ? meaning.directionTr : meaning.directionEn;
      extras = isTr ? [
        'Kartlar sana bunu yapmanı söylüyor, dinle.',
        'Bu tavsiye bir hediye, onu kabul et.',
        'Evrenin sana sunduğu yol haritası bu.',
        'Cesur ol ve bu kartın gösterdiği yöne yürü.',
        'Bu bilgelik doğrudan kaderin ağzından geliyor.',
      ] : [
        'The cards urge you to do this, listen.',
        'This advice is a gift, accept it.',
        'This is the roadmap the universe offers you.',
        'Be brave and walk in the direction this card shows.',
        'This wisdom comes straight from the mouth of destiny.',
      ];
      break;
    default: // Sonuç (6)
      base = isTr ? meaning.directionTr : meaning.directionEn;
      extras = isTr ? [
        'Yolculuğun sonu buraya çıkıyor.',
        'Kaderin nihai fısıltısı budur.',
        'Tüm kartlar bu sonuca işaret ediyor.',
        'Her şey bu noktaya doğru akıyor.',
        'Evren sana bu kapıyı açık bırakıyor.',
      ] : [
        'Your journey leads to this destination.',
        'This is the final whisper of fate.',
        'All cards point to this outcome.',
        'This outcome is not inevitable, your choices will decide.',
        'The universe leaves this door open for you.',
      ];
      break;
  }

  final extra = extras[rng.nextInt(extras.length)];
  return '$base $extra';
}

/// 7 kart genel tema cümlesi (premium, daha derin)
String _buildFullGeneralTheme(List<CardMeaning> meanings, List<String> names, FlowType flow, bool isTr) {
  final rng = Random();
  final t0 = (isTr ? meanings[0].themeTr : meanings[0].themeEn).split(',').first.trim();
  final t6 = (isTr ? meanings[6].themeTr : meanings[6].themeEn).split(',').first.trim();
  List<String> pool;

  switch (flow) {
    case FlowType.harmonious:
      pool = isTr ? [
        'Yedi kart tek bir senfonide buluşuyor. Geçmişinde ${names[0]} bir temel attı, ${names[1]} bu temeli güçlendirdi. ${names[2]} farkında olmadığın bir enerjiyi harekete geçirdi. ${names[3]} yolundaki engelleri yumuşattı, ${names[4]} çevrenden desteği gösteriyor. ${names[5]} sana net bir tavsiye veriyor ve ${names[6]} tüm bu yolculuğun huzurlu bir sonuca ulaşacağını müjdeliyor.',
        'Kartlar sana huzurun resmini çiziyor. ${names[0]} fırçayı aldı ve $t0 ile başladı. ${names[1]} bugünün renklerini ekledi, ${names[2]} görünmeyen detayları ortaya çıkardı. ${names[3]} sınavı yumuşattı, ${names[4]} çevrendeki uyumu gösterdi. ${names[5]} son fırça darbesini vurdu ve ${names[6]} tabloyu asıyor. Bu sanat eseri senin.',
        '${names[0]} ışığı yaktı, ${names[1]} alevleri besledi. ${names[2]} karanlıkta saklanan gücü açığa çıkardı. ${names[3]} yolundaki taşları döşedi, ${names[4]} seni destekleyen rüzgâr oldu. ${names[5]} rehber olarak yolunu aydınlattı ve ${names[6]} seni eve götürüyor. $t6 ile taçlanan bu yolculuk kutlu.',
      ] : [
        'Seven cards unite in a single symphony. In your past, ${names[0]} laid a foundation and ${names[1]} strengthened it. ${names[2]} set an unseen force in motion. ${names[3]} softened the obstacles, ${names[4]} reveals support from your surroundings. ${names[5]} offers clear advice, and ${names[6]} heralds a peaceful conclusion.',
        'The cards paint a picture of peace. ${names[0]} took the brush, starting with $t0. ${names[1]} added todays colors, ${names[2]} revealed hidden details. ${names[3]} eased the trial, ${names[4]} showed harmony. ${names[5]} made the final stroke and ${names[6]} hangs the masterpiece. This art is yours.',
        '${names[0]} lit the light, ${names[1]} fed the flame. ${names[2]} unveiled hidden strength. ${names[3]} paved the way, ${names[4]} became the supporting wind. ${names[5]} illuminated your path and ${names[6]} takes you home. This journey crowned with $t6 is blessed.',
      ];
      break;
    case FlowType.conflicting:
      pool = isTr ? [
        'Yedi kart arasında bir fırtına esiyor. ${names[0]} geçmişten gelen şimşeği çaktırdı, ${names[1]} şimdiki gerginliği hissettiriyor. ${names[2]} perdenin arkasındaki çatışmayı ortaya çıkardı. ${names[3]} önüne koyduğu engel zorlu ama ${names[4]} çevrenden gelen güç seni taşıyor. ${names[5]} sana savaş planını veriyor ve ${names[6]} sonunda gökkuşağını vaat ediyor.',
        'Kartlar çatışıyor ama bir düzen var. ${names[0]} savaşın kökenini gösteriyor, ${names[1]} cepheyi çiziyor. ${names[2]} gizli müttefikleri açığa çıkardı. ${names[3]} asıl engeli işaret ediyor, ${names[4]} stratejik desteği gösteriyor. ${names[5]} son hamleyi fısıldıyor ve ${names[6]} zaferi müjdeliyor.',
        '${names[0]} bir kapıyı kapattı ama ${names[1]} yenisini açıyor. ${names[2]} göremediğin düşmanı gösterdi, ${names[3]} sınavını koydu. ${names[4]} seni çevreleyen enerji ile sınıyor. Ama ${names[5]} sana silah veriyor ve ${names[6]} seni galip çıkarıyor. Her çatışma bir büyüme fırsatı.',
      ] : [
        'A storm blows between seven cards. ${names[0]} struck lightning from the past, ${names[1]} brings present tension. ${names[2]} exposed the conflict behind the curtain. The obstacle ${names[3]} placed is tough, but ${names[4]} shows surrounding strength. ${names[5]} gives you the battle plan and ${names[6]} promises the rainbow.',
        'The cards clash, but theres an order. ${names[0]} shows the root of battle, ${names[1]} draws the front line. ${names[2]} revealed hidden allies. ${names[3]} marks the real obstacle, ${names[4]} shows strategic support. ${names[5]} whispers the final move and ${names[6]} heralds victory.',
        '${names[0]} closed a door but ${names[1]} opens a new one. ${names[2]} revealed the unseen enemy, ${names[3]} set the trial. ${names[4]} surrounding energy tests you. But ${names[5]} arms you and ${names[6]} declares you victorious. Every conflict is a growth opportunity.',
      ];
      break;
    case FlowType.transformative:
      pool = isTr ? [
        'Yedi kart bir metamorfoz çiziyor. ${names[0]} eski halini gösteriyor — $t0 seninle başladı. ${names[1]} dönüşümün şimdiki anını yansıtıyor. ${names[2]} bilinçaltında başlayan değişimi açığa çıkardı. ${names[3]} kırılma noktasını işaret ediyor, ${names[4]} çevrenin bu dönüşüme tepkisini gösteriyor. ${names[5]} yeni yolun haritasını çiziyor ve ${names[6]} kanatlarını açıyor. Dönüşümün muhteşem.',
        '${names[0]} eski seni gömdü, ${names[1]} yasını tuttu. ${names[2]} toprağın altında ne olduğunu fısıldadı. ${names[3]} kırılgan anı gösteriyor, ${names[4]} çevreden gelen yeni enerjiyi taşıyor. ${names[5]} kazma verdi ve ${names[6]} hazineyi ortaya çıkarıyor. $t6 artık senin.',
        'Kartların hikâyesi bir anka kuşu: ${names[0]} yanıyor, ${names[1]} alevleri hissediyor, ${names[2]} duman arasında bir şey parlıyor. ${names[3]} kül oluyor, ${names[4]} rüzgâr esiyor, ${names[5]} ilk kıvılcımı atıyor ve ${names[6]} küllerden yeniden doğuyor. Bu sen!',
      ] : [
        'Seven cards draw a metamorphosis. ${names[0]} shows your former self — $t0 began with you. ${names[1]} reflects the present moment. ${names[2]} revealed the subconscious shift. ${names[3]} marks the breaking point, ${names[4]} shows your environments reaction. ${names[5]} maps the new path and ${names[6]} unfurls the wings. Your transformation is magnificent.',
        '${names[0]} buried the old you, ${names[1]} mourned. ${names[2]} whispered what lies beneath. ${names[3]} shows the fragile moment, ${names[4]} carries new energy. ${names[5]} gave you the shovel and ${names[6]} reveals the treasure. $t6 is now yours.',
        'The cards tell the story of a phoenix: ${names[0]} burns, ${names[1]} feels the flames, ${names[2]} — something glimmers through the smoke. ${names[3]} becomes ash, ${names[4]} the wind blows, ${names[5]} sparks the first flame and ${names[6]} rises from the ashes. That is you!',
      ];
      break;
  }

  return pool[rng.nextInt(pool.length)];
}

/// 7 kart tavsiye paragrafı oluşturma
String _buildFullAdvice(List<CardMeaning> meanings, List<String> names, FlowType flow, bool isTr) {
  final rng = Random();
  final t0 = meanings[0].themeTr.split(',').first.trim().toLowerCase();
  final t1 = meanings[1].themeTr.split(',').first.trim().toLowerCase();
  final t2 = meanings[2].themeTr.split(',').first.trim().toLowerCase();
  final t3 = meanings[3].themeTr.split(',').first.trim().toLowerCase();
  final t5 = meanings[5].themeTr.split(',').first.trim().toLowerCase();
  final t6 = meanings[6].themeTr.split(',').first.trim().toLowerCase();
  
  final t0en = meanings[0].themeEn.split(',').first.trim().toLowerCase();
  final t1en = meanings[1].themeEn.split(',').first.trim().toLowerCase();
  final t2en = meanings[2].themeEn.split(',').first.trim().toLowerCase();
  final t3en = meanings[3].themeEn.split(',').first.trim().toLowerCase();
  final t5en = meanings[5].themeEn.split(',').first.trim().toLowerCase();
  final t6en = meanings[6].themeEn.split(',').first.trim().toLowerCase();

  final poolTr = [
    'Geçmişteki o "$t0" dönemi artık kapandı. Karşına çıkan "$t3" engelini ancak içindeki o "$t5" hissine sıkı sıkı tutunarak aşabilirsin. Yolu açtığında "$t6" seni bekliyor olacak.',
    'Eski "$t0" bağları geride kaldı. Şimdiki sahip olduğun "$t1" enerjisi sana ihtiyacın olan gücü zaten veriyor. Sadece iç sesinin fısıldadığı o "$t5" çağrısına kulak ver ve "$t6" hedefine doğru yürümeye başla.',
    'Şu an önünü kapatan "$t3" zorluğunu gözünde büyütme. Aradığın cevap dışarıda değil, içindeki o derin "$t2" sessizliğinde yatıyor. Düşüncelerindeki "$t5" ışığını takip edersen karanlık dağılır.',
    'Bu açılım sana şunu fısıldıyor: Gözlerini "$t0" gölgesinden ayır, bugünü mevcut "$t1" enerjinle yaşa. Önündeki o "$t3" sisine takılma, yegane pusulan "$t5" olsun ki "$t6" baharına uyanabilesin.',
  ];

  final poolEn = [
    'That past era of "$t0en" is now over. You can only overcome the obstacle of "$t3en" ahead of you by fiercely holding on to the feeling of "$t5en". Once the path clears, "$t6en" will be waiting for you.',
    'Old ties of "$t0en" are left behind. The current "$t1en" energy you possess already grants you the strength you need. Just listen to the call of "$t5en" echoing within you, and start walking towards your target of "$t6en".',
    'Do not exaggerate the difficulty of "$t3en" blocking your way right now. The answer you seek is not out there, but deep within the silence of your "$t2en". If you follow the light of "$t5en" in your thoughts, the darkness will fade.',
    'This reading whispers to you: Take your eyes off the shadow of "$t0en", live today with your current "$t1en" energy. Do not get stuck in the fog of "$t3en" ahead—let your true compass be "$t5en" so you can awaken to the spring of "$t6en".',
  ];

  return isTr ? poolTr[rng.nextInt(poolTr.length)] : poolEn[rng.nextInt(poolEn.length)];
}

/// Full Arcana 7 kart kapanış mesajı
String _buildFullClosing(List<String> promises, FlowType flow, bool isTr) {
  final rng = Random();
  final k1 = promises[0];
  final k2 = promises[1];
  final k3 = promises.length > 2 ? promises[2] : k2;
  final k4 = promises.length > 3 ? promises[3] : k3;

  List<String> pool;

  switch (flow) {
    case FlowType.harmonious:
      pool = isTr ? [
        '"$k1" seni çağırıyor.\n"$k2" seni karşılıyor.\n"$k3" seni sarıyor.\n"$k4" seni tamamlıyor.\nEvren seninle dans ediyor.',
        'Yedi kartın fısıltısı tek bir kelimeye dönüşüyor:\n"$k1."\nVe bu kelime senin için yazıldı.',
        '"$k1" başlangıç.\n"$k2" yolculuk.\n"$k3" keşif.\n"$k4" zafer.\nBu hikâye senin.',
      ] : [
        '"$k1" calls you.\n"$k2" welcomes you.\n"$k3" embraces you.\n"$k4" completes you.\nThe universe dances with you.',
        'The whisper of seven cards becomes one word:\n"$k1."\nAnd this word was written for you.',
        '"$k1" is the beginning.\n"$k2" the journey.\n"$k3" the discovery.\n"$k4" the triumph.\nThis story is yours.',
      ];
      break;
    case FlowType.conflicting:
      pool = isTr ? [
        '"$k1" acıttı.\n"$k2" sorguladı.\n"$k3" sınadı.\nAma "$k4" diyor ki:\nHer fırtınadan sonra bir gökkuşağı var.',
        'Yedi kartın savaşı sona erdi.\n"$k1" yenilmedi.\n"$k2" güçlendi.\n"$k3" direndi.\n"$k4" kazandı.\nSen kazandın.',
        '"$k1" kırıldı.\n"$k2" döküldü.\nAma "$k3" ve "$k4" seni yeniden inşa ediyor.\nKırık yerlerden altın akar.',
      ] : [
        '"$k1" hurt.\n"$k2" questioned.\n"$k3" tested.\nBut "$k4" says:\nAfter every storm, there is a rainbow.',
        'The battle of seven cards has ended.\n"$k1" didn\'t lose.\n"$k2" grew stronger.\n"$k3" endured.\n"$k4" won.\nYou won.',
        '"$k1" broke.\n"$k2" spilled.\nBut "$k3" and "$k4" rebuild you.\nGold flows through the cracks.',
      ];
      break;
    case FlowType.transformative:
      pool = isTr ? [
        '"$k1" öldü.\n"$k2" gömüldü.\n"$k3" filizlendi.\n"$k4" çiçek açtı.\nBu senin yeniden doğuşun.',
        'Eski sen "$k1" ile vedalaştı.\n"$k2" yas tuttu.\n"$k3" yeni tohum ekti.\n"$k4" güneşi doğurdu.\nŞimdi yeni seni kutla.',
        '"$k1" son nefesti.\n"$k2" sessizlik.\n"$k3" ilk hareket.\n"$k4" yeni bir çığlık.\nYeniden doğdun.',
      ] : [
        '"$k1" died.\n"$k2" was buried.\n"$k3" sprouted.\n"$k4" bloomed.\nThis is your rebirth.',
        'The old you said goodbye to "$k1."\n"$k2" mourned.\n"$k3" planted new seeds.\n"$k4" birthed the sun.\nCelebrate the new you.',
        '"$k1" was the last breath.\n"$k2" silence.\n"$k3" first movement.\n"$k4" a new cry.\nYou are reborn.',
      ];
      break;
  }

  return pool[rng.nextInt(pool.length)];
}

// ============================================================
// Premium Analiz Fonksiyonları (Sadece Full Arcana)
// ============================================================

/// Element analizi — 7 kartın tonuna göre element dağılımı
ElementAnalysis _analyzeElements(List<CardMeaning> meanings) {
  int fire = 0, water = 0, air = 0, earth = 0;

  for (final m in meanings) {
    switch (m.tone) {
      case CardTone.soft:
        fire += 2; air += 1;
        break;
      case CardTone.heavy:
        water += 2; earth += 1;
        break;
      case CardTone.decision:
        air += 1; earth += 1;
        break;
    }
    switch (m.movement) {
      case CardMovement.motion:
        fire += 1;
        break;
      case CardMovement.stillness:
        earth += 1;
        break;
    }
    switch (m.phase) {
      case CardPhase.beginning:
      case CardPhase.awakening:
        fire += 1; air += 1;
        break;
      case CardPhase.ending:
      case CardPhase.neutral:
        water += 1; earth += 1;
        break;
      case CardPhase.completion:
        earth += 2;
        break;
    }
  }

  // Beraberlik kırıcı: her elemente küçük benzersiz jitter ekle
  // Bu sayede iki element asla aynı yüzdeye sahip olmaz
  final rng = Random(fire * 7 + water * 13 + air * 19 + earth * 31);
  final jitters = <double>[
    rng.nextDouble() * 2.0 + 0.5,  // Ateş: 0.5-2.5
    rng.nextDouble() * 2.0 + 0.5,  // Su: 0.5-2.5
    rng.nextDouble() * 2.0 + 0.5,  // Hava: 0.5-2.5
    rng.nextDouble() * 2.0 + 0.5,  // Toprak: 0.5-2.5
  ];

  final rawScores = [
    fire.toDouble() + jitters[0],
    water.toDouble() + jitters[1],
    air.toDouble() + jitters[2],
    earth.toDouble() + jitters[3],
  ];
  final total = rawScores.reduce((a, b) => a + b);

  final elements = {
    'Ateş': rawScores[0] / total,
    'Su': rawScores[1] / total,
    'Hava': rawScores[2] / total,
    'Toprak': rawScores[3] / total,
  };

  // Baskın element — en yüksek değeri bul
  String dominant = 'Ateş';
  double maxVal = 0;
  elements.forEach((k, v) { if (v > maxVal) { maxVal = v; dominant = k; } });

  final emojis = {'Ateş': '🔥', 'Su': '💧', 'Hava': '🌬️', 'Toprak': '🌿'};
  final descTr = {
    'Ateş': 'Ateş baskın — aksiyon, tutku ve cesaret enerjin yüksek! Harekete geçme zamanı.',
    'Su': 'Su baskın — duygusal derinlik ve sezgi gücün dorukta. İç sesini dinle.',
    'Hava': 'Hava baskın — zihinsel berraklık ve iletişim enerjin güçlü. Düşün ve konuş.',
    'Toprak': 'Toprak baskın — istikrar ve pratiklik enerjin yüksek. Sağlam adımlar at.',
  };
  final descEn = {
    'Ateş': 'Fire dominant — your energy for action, passion and courage is high! Time to move.',
    'Su': 'Water dominant — your emotional depth and intuition are at their peak. Listen to your inner voice.',
    'Hava': 'Air dominant — your mental clarity and communication energy is strong. Think and speak.',
    'Toprak': 'Earth dominant — your stability and practicality energy is high. Take solid steps.',
  };

  return ElementAnalysis(
    elements: elements,
    dominantElement: dominant,
    dominantEmoji: emojis[dominant]!,
    dominantDescriptionTr: descTr[dominant]!,
    dominantDescriptionEn: descEn[dominant]!,
  );
}

/// Kart ilişki analizi — En güçlü 2-3 sinerji
List<CardRelation> _analyzeCardRelations(List<CardMeaning> meanings, List<String> names, bool isTr) {
  final relations = <CardRelation>[];
  final rng = Random();

  // İlişki tipleri
  final synergies = <Map<String, dynamic>>[];
  final usedTexts = <String>{};

  for (int i = 0; i < meanings.length; i++) {
    for (int j = i + 1; j < meanings.length; j++) {
      final m1 = meanings[i];
      final m2 = meanings[j];
      int score = 0;
      String typeTr = '';
      String typeEn = '';
      String emoji = '✨';

      // Aynı ton = güçlendirici
      if (m1.tone == m2.tone) {
        score += 3;
        if (m1.tone == CardTone.soft) {
          final opts = [
            {'tr': 'ışığı öyle yoğunlaştırıyor ki, saklandığın gölgelerde bile artık güvendesin.', 'en': 'intensifies the light so much that you are safe even in the shadows you hide in.', 'e': '☀️'},
            {'tr': 'aynı frekansta titreşiyor. Ruhundaki o sönmüş umudu yeniden tutuşturmak için birleştiler.', 'en': 'vibrate at the same frequency. They united to reignite that extinguished hope in your soul.', 'e': '💫'},
            {'tr': 'birleşerek o beklediğin mucizenin kırılgan ama kesin tohumunu ekiyor.', 'en': 'combine to plant the fragile yet certain seed of the miracle you wait for.', 'e': '🌟'},
          ];
          final pick = opts[rng.nextInt(opts.length)];
          typeTr = pick['tr']!; typeEn = pick['en']!; emoji = pick['e']!;
        } else if (m1.tone == CardTone.heavy) {
          final opts = [
            {'tr': 'birleşerek karanlığın en dibine iniyor. En çok korktuğun o yüzleşme tam da burada yatıyor.', 'en': 'descend into the very bottom of the darkness together. The confrontation you fear most lies right here.', 'e': '🌑'},
            {'tr': 'kusursuz bir kriz yaratıyor. Sırf parçalanıp yeniden daha güçlü doğabilesin diye.', 'en': 'create a perfect crisis. Just so you can shatter and be reborn stronger.', 'e': '🔮'},
            {'tr': 'ağır bir karmayı sonlandırmak için buluştu. Kaçma, tam içinden geç.', 'en': 'came together to end a heavy karma. Do not run, pass right through it.', 'e': '⚗️'},
          ];
          final pick = opts[rng.nextInt(opts.length)];
          typeTr = pick['tr']!; typeEn = pick['en']!; emoji = pick['e']!;
        } else {
          final opts = [
            {'tr': 'karar anında zihnini bıçak gibi keskinleştiriyor. O adım artık ertelenemez.', 'en': 'sharpens your mind like a knife at the moment of decision. That step can no longer be delayed.', 'e': '⚖️'},
            {'tr': 'önüne kaçınılmaz bir kavşak seriyor. Seçim yapmamak da en karanlık seçimdir.', 'en': 'lays out an inevitable crossroads before you. Refusing to choose is also the darkest choice.', 'e': '🧭'},
            {'tr': 'o ertelediğin kırılma anını ayağına getiriyor. Sadece dürüst ol.', 'en': 'brings the breaking point you delayed right to your feet. Just be honest.', 'e': '🔀'},
          ];
          final pick = opts[rng.nextInt(opts.length)];
          typeTr = pick['tr']!; typeEn = pick['en']!; emoji = pick['e']!;
        }
      }

      // Zıt hareket = gerilim ama büyüme
      if (m1.movement != m2.movement) {
        score += 2;
        final opts = [
          {'tr': 'zıt yönlere çekerek içsel bir kaos yaratıyor. Bu gerilim aydınlanma ateşini yakacak.', 'en': 'creates inner chaos by pulling in opposite directions. This tension will ignite your fire of enlightenment.', 'e': '⚡'},
          {'tr': 'bir yanda eylem, diğer yanda durgunluk... Seni durduran dışarısı değil, zihninin ta kendisi.', 'en': 'action on one side, stillness on the other... It is not the outside stopping you, it is your very mind.', 'e': '🌪️'},
          {'tr': 'farklı ritimlerde çarpışıyor. Dengen tamamen bozulduğunda asıl gücünü bulacaksın.', 'en': 'clashes in different rhythms. You will find your true power when your balance is completely disrupted.', 'e': '🔄'},
          {'tr': 'aradığın o tuhaf dinginliği tam da bu kaotik çarpışmada sana hediye ediyor.', 'en': 'gifts you that strange serenity you seek right in this chaotic collision.', 'e': '🎭'},
        ];
        final pick = opts[rng.nextInt(opts.length)];
        typeTr = pick['tr']!; typeEn = pick['en']!; emoji = pick['e']!;
      }

      // Aynı faz = eş zamanlı enerji
      if (m1.phase == m2.phase) {
        score += 2;
        if (m1.phase == CardPhase.beginning || m1.phase == CardPhase.awakening) {
          final opts = [
            {'tr': 'birlikte yepyeni, ürkütücü ama çok güçlü bir sayfa açıyor. Eskiyi tamamen sil.', 'en': 'opens a brand new, scary but very powerful chapter together. Erase the old completely.', 'e': '🌅'},
            {'tr': 'hiç beklemediğin bir anda o yeni döngünün sarsılmaz temellerini atıyor.', 'en': 'lays the unshakable foundations of that new cycle precisely when you least expect it.', 'e': '🌱'},
          ];
          final pick = opts[rng.nextInt(opts.length)];
          typeTr = pick['tr']!; typeEn = pick['en']!; emoji = pick['e']!;
        } else if (m1.phase == CardPhase.completion || m1.phase == CardPhase.ending) {
          final opts = [
            {'tr': 'o döneme acımasızca ve kesin olarak nokta koyuyor. Bitti.', 'en': 'ruthlessly and definitively puts an end to that era. It is done.', 'e': '🌙'},
            {'tr': 'kapanan kapının arkasından bakmanı sana tamamen yasaklıyor. Bu final özgürlüğün için.', 'en': 'forbids you completely from looking behind the closed door. This finale is for your freedom.', 'e': '🏁'},
          ];
          final pick = opts[rng.nextInt(opts.length)];
          typeTr = pick['tr']!; typeEn = pick['en']!; emoji = pick['e']!;
        }
      }

      if (score >= 2 && typeTr.isNotEmpty && !usedTexts.contains(typeTr)) {
        usedTexts.add(typeTr);
        synergies.add({
          'i': i, 'j': j, 'score': score,
          'typeTr': typeTr, 'typeEn': typeEn, 'emoji': emoji,
        });
      }
    }
  }

  // Skora göre sırala, en iyi 3'ünü al
  synergies.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
  final top = synergies.take(3);

  for (final s in top) {
    final i = s['i'] as int;
    final j = s['j'] as int;
    relations.add(CardRelation(
      card1Name: names[i],
      card2Name: names[j],
      relationTextTr: '${names[i]} ve ${names[j]} ${s['typeTr']}',
      relationTextEn: '${names[i]} and ${names[j]} ${s['typeEn']}',
      emoji: s['emoji'] as String,
    ));
  }

  // En az 2 ilişki garanti et
  if (relations.length < 2) {
    final fallbackTr = [
      'enerjilerini o kadar görünmez bir şekilde körüklüyor ki, sonucuna sen bile inanamayacaksın.',
      'arka planda fısıldaşarak asıl ihtiyacın olan o acı reçeteyi yazıyor.',
      'zihnindeki kör düğümü yavaşça çözüyor. Buna sadece izin ver.',
    ];
    final fallbackEn = [
      'fuels their energies so invisibly that even you will not believe the outcome.',
      'whispers in the background to write the bitter prescription you truly need.',
      'slowly unties the blind knot in your mind. Just allow it to happen.',
    ];
    while (relations.length < 2) {
      final idx = rng.nextInt(fallbackTr.length);
      final idx1 = rng.nextInt(3);
      final idx2 = 4 + rng.nextInt(3);
      relations.add(CardRelation(
        card1Name: names[idx1],
        card2Name: names[idx2],
        relationTextTr: '${names[idx1]} ve ${names[idx2]} ${fallbackTr[idx]}',
        relationTextEn: '${names[idx1]} and ${names[idx2]} ${fallbackEn[idx]}',
        emoji: '✨',
      ));
    }
  }

  return relations;
}

/// Kozmik uyum skoru (0-100)
Map<String, dynamic> _calculateCosmicScore(List<CardMeaning> meanings, FlowType flow) {
  int score = 50; // base

  // FlowType bonusu
  switch (flow) {
    case FlowType.harmonious: score += 25; break;
    case FlowType.transformative: score += 15; break;
    case FlowType.conflicting: score += 5; break;
  }

  // Ton tutarlılığı
  final tones = meanings.map((m) => m.tone).toList();
  final brightCount = tones.where((t) => t == CardTone.soft).length;
  if (brightCount >= 5) score += 15;
  else if (brightCount >= 3) score += 8;

  // Hareket uyumu
  final forwardCount = meanings.where((m) => m.movement == CardMovement.motion).length;
  if (forwardCount >= 5) score += 10;
  else if (forwardCount >= 3) score += 5;

  score = score.clamp(15, 98);

  String labelTr, labelEn;
  if (score >= 85) { labelTr = 'Muhteşem Uyum'; labelEn = 'Magnificent Harmony'; }
  else if (score >= 70) { labelTr = 'Güçlü Uyum'; labelEn = 'Strong Harmony'; }
  else if (score >= 55) { labelTr = 'Dengeli Enerji'; labelEn = 'Balanced Energy'; }
  else if (score >= 40) { labelTr = 'Karışık Enerji'; labelEn = 'Mixed Energy'; }
  else { labelTr = 'Çatışmalı Enerji'; labelEn = 'Conflicting Energy'; }

  return {'score': score, 'labelTr': labelTr, 'labelEn': labelEn};
}

/// Gizli mesaj — 7 karttan çıkan sır
Map<String, String> _generateSecretMessage(List<CardMeaning> meanings, List<String> names, FlowType flow, bool isTr) {
  final rng = Random();
  final t0 = meanings[0].themeTr.split(',').first.trim().toLowerCase();
  final t1 = meanings[1].themeTr.split(',').first.trim().toLowerCase();
  final t2 = meanings[2].themeTr.split(',').first.trim().toLowerCase();
  final t3 = meanings[3].themeTr.split(',').first.trim().toLowerCase();
  final t5 = meanings[5].themeTr.split(',').first.trim().toLowerCase();
  final t6 = meanings[6].themeTr.split(',').first.trim().toLowerCase();
  
  final t0en = meanings[0].themeEn.split(',').first.trim().toLowerCase();
  final t1en = meanings[1].themeEn.split(',').first.trim().toLowerCase();
  final t2en = meanings[2].themeEn.split(',').first.trim().toLowerCase();
  final t3en = meanings[3].themeEn.split(',').first.trim().toLowerCase();
  final t5en = meanings[5].themeEn.split(',').first.trim().toLowerCase();
  final t6en = meanings[6].themeEn.split(',').first.trim().toLowerCase();

  final poolTr = [
    'Şu an içten içe bildiğin ama kendine bile itiraf edemediğin bir yalanı yaşıyorsun. İçindeki o "$t2" enerjisi sana bunu haykırıyor. O çok korktuğun "$t6", aslında cezan değil, tek kurtuluşun. Artık uyan.',
    'Evren sana bir ayna tutuyor: Geçmişte yaşadığın o "$t0" senaryosunu zihninde tekrar tekrar oynatarak şimdiki "$t1" zamanını sabote eden ta kendisisin. Engel olan bir dış güç yok. En büyük düşmanın şu an bu satırları okuyor.',
    'Zihnindeki o sessiz pazarlığı biliyoruz: İçindeki o asıl "$t2" dürtüsünü bastırmak için karşındaki "$t3" engelini sen bilerek kurguladın. Kolay olanı seçip kurbanı oynamayı bırak. Evren senden sadece sarsıcı bir dürüstlük istiyor.',
    'Önündeki o ihtişamlı "$t6" hedefine öylesine saplantılısın ki, şu an zihninin o derin "$t1" karmaşasında çürüdüğünü göremiyorsun. İçindeki mezarlığı temizlemeden yeni bir hayat inşa edemezsin.',
    'Birilerinin artık sana şu sert gerçeği söylemesi gerekiyordu: Aradığın cevap ışıkta değil, o karanlığa gömdüğün "$t2" arzusunda saklı. O sözde "$t3" mazeretinin ardına saklanmaktan vazgeçtiğin gün her şey paramparça olup yeniden doğacak.',
  ];

  final poolEn = [
    'You are currently living a lie that you know deep down but cannot even admit to yourself. That suppressed energy of "$t2en" inside you is screaming this at you. That "$t6en" you fear so much is not your punishment, it is your only salvation. Wake up now.',
    'The universe is holding a mirror to you: By replaying that "$t0en" scenario from your past over and over in your mind, YOU are the one sabotaging your present "$t1en" reality. There is no external force blocking you. Your greatest enemy is reading these lines right now.',
    'We have deciphered that silent bargain within your mind: You orchestrated your current obstacle of "$t3en" yourself just to suppress your deep urge for "$t2en". Stop choosing the easy way out and playing the victim. The universe only asks for your shattering honesty.',
    'You are so obsessed with that glorious "$t6en" goal ahead of you that you cannot see your mind rotting in the current vortex of "$t1en". You cannot build a new life without cleaning the graveyard inside you.',
    'Someone finally had to tell you this harsh truth: The answer you seek is not in the light, it is hidden in the deep "$t2en" desire you buried in the dark. The day you stop hiding behind your "$t3en" excuse, everything will shatter and be reborn.',
  ];

  final idx = rng.nextInt(poolTr.length);
  return {'tr': poolTr[idx], 'en': poolEn[idx]};
}

/// Günlük ritüel önerisi — elementlere ve kartlara göre
RitualSuggestion _generateRitualSuggestion(ElementAnalysis elements, FlowType flow) {
  final rng = Random();

  final rituals = <Map<String, String>>[];

  switch (elements.dominantElement) {
    case 'Ateş':
      rituals.addAll([
        {'titleTr': 'Cesaret Ritüeli', 'titleEn': 'Courage Ritual', 'actionTr': 'Bugün bir kırmızı mum yak ve alevine bakarak cesaretini çağır. 3 dakika boyunca korkularını aleve ver.', 'actionEn': 'Light a red candle today and summon your courage by gazing at its flame. Give your fears to the fire for 3 minutes.', 'emoji': '🕯️'},
        {'titleTr': 'Aksiyon Adımı', 'titleEn': 'Action Step', 'actionTr': 'Bugün ertelediğin bir şeyi yap. Ne kadar küçük olursa olsun, harekete geç. Ateş enerjin seni destekliyor.', 'actionEn': 'Do something you\'ve been postponing today. No matter how small, take action. Your fire energy supports you.', 'emoji': '⚡'},
      ]);
      break;
    case 'Su':
      rituals.addAll([
        {'titleTr': 'Duygu Arınması', 'titleEn': 'Emotional Cleanse', 'actionTr': 'Bugün bir bardak suya niyetini fısılda ve yavaşça iç. Her yudumda duygularını temizle.', 'actionEn': 'Whisper your intention into a glass of water today and slowly drink it. Cleanse your emotions with each sip.', 'emoji': '🌊'},
        {'titleTr': 'İç Ses Meditasyonu', 'titleEn': 'Inner Voice Meditation', 'actionTr': 'Gözlerini kapat, 5 derin nefes al. İç sesinin sana ne söylediğini dinle. Su enerjin sezgilerini güçlendiriyor.', 'actionEn': 'Close your eyes, take 5 deep breaths. Listen to what your inner voice tells you. Your water energy strengthens intuition.', 'emoji': '🧘'},
      ]);
      break;
    case 'Hava':
      rituals.addAll([
        {'titleTr': 'Düşünce Temizliği', 'titleEn': 'Thought Cleanse', 'actionTr': 'Bugün 5 dakika pencereyi aç ve temiz havayı ciğerlerine doldur. Her nefeste eski düşünceleri bırak, yenilere yer aç.', 'actionEn': 'Open a window for 5 minutes today and fill your lungs with fresh air. Release old thoughts with each breath, make room for new ones.', 'emoji': '🍃'},
        {'titleTr': 'Kelime Gücü', 'titleEn': 'Power of Words', 'actionTr': 'Bugün birine söylemek isteyip söyleyemediğin bir şeyi yaz. Göndermek zorunda değilsin, sadece yaz.', 'actionEn': 'Write something today that you wanted to say to someone but couldn\'t. You don\'t have to send it, just write.', 'emoji': '✍️'},
      ]);
      break;
    default: // Toprak
      rituals.addAll([
        {'titleTr': 'Topraklama Ritüeli', 'titleEn': 'Grounding Ritual', 'actionTr': 'Bugün çıplak ayaklarınla toprağa veya çimenliğe bas. 3 dakika boyunca ayaklarından yükselen enerjiyi hisset.', 'actionEn': 'Stand barefoot on earth or grass today. Feel the energy rising from your feet for 3 minutes.', 'emoji': '🌱'},
        {'titleTr': 'Sağlam Adım', 'titleEn': 'Solid Step', 'actionTr': 'Bugün uzun süredir planladığın pratik bir adımı at. Bir listeye yaz, organize et. Toprak enerjin seni destekliyor.', 'actionEn': 'Take a practical step you\'ve been planning for a while. Write a list, organize. Your earth energy supports you.', 'emoji': '📋'},
      ]);
      break;
  }

  final chosen = rituals[rng.nextInt(rituals.length)];
  return RitualSuggestion(
    titleTr: chosen['titleTr']!,
    titleEn: chosen['titleEn']!,
    actionTr: chosen['actionTr']!,
    actionEn: chosen['actionEn']!,
    emoji: chosen['emoji']!,
  );
}

/// Ana fonksiyon: 7 kart okuma üret
FullTarotReading generateFullReading({
  required List<int> cardIds,  // 7 kart ID
  required List<String> cardNames,  // 7 kart ismi
  required bool isTr,
}) {
  final rng = Random();
  
  // Kartların anlamlarını al (tüm 78 kart artık cardMeanings'de)
  final meanings = cardIds.map((id) => cardMeanings[id]!).toList();

  // Akış tipi (ilk 3 karttan belirlenir)
  final flowType = _detectFlowType(meanings[0], meanings[1], meanings[2]);
  final flowLabel = _flowLabel(flowType, isTr);

  // Genel tema
  final generalTheme = _buildFullGeneralTheme(meanings, cardNames, flowType, isTr);

  // 7 kart yorumu
  final positions = isTr ? _fullPositionsTr : _fullPositionsEn;
  final cardReadings = <FullCardReading>[];
  for (int i = 0; i < 7; i++) {
    cardReadings.add(FullCardReading(
      positionTitle: positions[i],
      content: _fullPositionReading(meanings[i], i, isTr, rng),
      cardName: cardNames[i],
      cardIndex: cardIds[i],
    ));
  }

  // Vaatler / Anahtar kelimeler (7 karttan)
  final allThemes = meanings.map((m) => (isTr ? m.themeTr : m.themeEn).split(',').map((s) => s.trim()).toList()).toList();
  allThemes.forEach((l) => l.shuffle(rng));
  final promises = <String>[];
  final used = <String>{};
  for (final themeList in allThemes) {
    for (final word in themeList) {
      if (!used.contains(word.toLowerCase())) {
        promises.add(word);
        used.add(word.toLowerCase());
        break;
      }
    }
    if (promises.length >= 5) break;
  }
  while (promises.length < 4) promises.add(isTr ? 'dönüşüm' : 'transformation');

  // Tavsiye paragrafı
  final adviceParagraph = _buildFullAdvice(meanings, cardNames, flowType, isTr);

  // Kapanış mesajı
  final closingMessage = _buildFullClosing(promises, flowType, isTr);

  // ── Premium analizler ──
  final elementAnalysis = _analyzeElements(meanings);
  final cardRelations = _analyzeCardRelations(meanings, cardNames, isTr);
  final cosmicData = _calculateCosmicScore(meanings, flowType);
  final secretMsg = _generateSecretMessage(meanings, cardNames, flowType, isTr);
  final ritual = _generateRitualSuggestion(elementAnalysis, flowType);

  return FullTarotReading(
    generalTheme: generalTheme,
    cardReadings: cardReadings,
    adviceParagraph: adviceParagraph,
    closingMessage: closingMessage,
    flowType: flowType,
    flowLabel: flowLabel,
    promises: promises,
    elementAnalysis: elementAnalysis,
    cardRelations: cardRelations,
    cosmicScore: cosmicData['score'] as int,
    cosmicLabelTr: cosmicData['labelTr'] as String,
    cosmicLabelEn: cosmicData['labelEn'] as String,
    secretMessageTr: secretMsg['tr']!,
    secretMessageEn: secretMsg['en']!,
    ritualSuggestion: ritual,
  );
}

