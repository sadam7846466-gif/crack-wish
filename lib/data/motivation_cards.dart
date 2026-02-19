import 'dart:math';

/// Motivasyon Kart Tipleri
enum CardType {
  quote,       // 💬 Alıntı
  science,     // 🧠 Bilim
  joke,        // 😂 Espri
  challenge,   // 🎯 Meydan Okuma
  perspective, // 💡 Perspektif
  story,       // 🌍 Hikaye
}

/// Tek bir motivasyon kartı
class MotivationCard {
  final String id;
  final CardType type;
  final String text;
  final String? author;
  final String emoji;
  final int colorValue; // gradient renk (hex)

  const MotivationCard({
    required this.id,
    required this.type,
    required this.text,
    this.author,
    required this.emoji,
    required this.colorValue,
  });
}

/// Kart havuzu ve seçim motoru
class MotivationCardDeck {
  static final _random = Random();

  /// Günlük kart seçimi — daha önce görülmemiş kartlardan rastgele seç
  static List<MotivationCard> getDailyCards(int count, List<String> seenIds) {
    final available = allCards
        .where((c) => !seenIds.contains(c.id))
        .toList();
    
    // Tüm kartlar görüldüyse sıfırla
    final pool = available.isEmpty ? List<MotivationCard>.from(allCards) : available;
    pool.shuffle(_random);
    
    return pool.take(count).toList();
  }

  /// Tip emoji'si
  static String typeEmoji(CardType type) {
    switch (type) {
      case CardType.quote: return '💬';
      case CardType.science: return '🧠';
      case CardType.joke: return '😂';
      case CardType.challenge: return '🎯';
      case CardType.perspective: return '💡';
      case CardType.story: return '🌍';
    }
  }

  /// Tip etiketi
  static String typeLabel(CardType type) {
    switch (type) {
      case CardType.quote: return 'Alıntı';
      case CardType.science: return 'Bilim';
      case CardType.joke: return 'Espri';
      case CardType.challenge: return 'Meydan Okuma';
      case CardType.perspective: return 'Perspektif';
      case CardType.story: return 'Hikaye';
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // KART HAVUZU — 60+ Kart
  // ═══════════════════════════════════════════════════════════════

  static const List<MotivationCard> allCards = [
    // ─── 💬 ALINTILAR ───────────────────────────────
    MotivationCard(
      id: 'q1', type: CardType.quote, emoji: '💬',
      colorValue: 0xFF6C63FF,
      text: 'Başarısızlık, başarıya giden yolun parçasıdır.',
      author: 'Albert Einstein',
    ),
    MotivationCard(
      id: 'q2', type: CardType.quote, emoji: '💬',
      colorValue: 0xFF9C6BFF,
      text: 'Tek sınırlarımız, kendimize koyduklarımızdır.',
      author: 'Napoleon Hill',
    ),
    MotivationCard(
      id: 'q3', type: CardType.quote, emoji: '💬',
      colorValue: 0xFF6C63FF,
      text: 'Hayatta en büyük zafer, hiç düşmemek değil, her düştüğünde ayağa kalkmaktır.',
      author: 'Nelson Mandela',
    ),
    MotivationCard(
      id: 'q4', type: CardType.quote, emoji: '💬',
      colorValue: 0xFF9C6BFF,
      text: 'Gelecek, hayallerine inananların olacaktır.',
      author: 'Eleanor Roosevelt',
    ),
    MotivationCard(
      id: 'q5', type: CardType.quote, emoji: '💬',
      colorValue: 0xFF6C63FF,
      text: 'Yapılacak en iyi şey, doğru olanı yapmaktır. İkincisi yanlış olanı yapmaktır. En kötüsü ise hiçbir şey yapmamaktır.',
      author: 'Theodore Roosevelt',
    ),
    MotivationCard(
      id: 'q6', type: CardType.quote, emoji: '💬',
      colorValue: 0xFF9C6BFF,
      text: 'Her gün bir mucize olabilir, eğer doğru gözlerle bakarsan.',
      author: 'Atasözü',
    ),
    MotivationCard(
      id: 'q7', type: CardType.quote, emoji: '💬',
      colorValue: 0xFF6C63FF,
      text: 'Dünle beraber gitti cancağızım. Ne kadar söz varsa düne ait. Şimdi yeni şeyler söylemek lazım.',
      author: 'Mevlana',
    ),
    MotivationCard(
      id: 'q8', type: CardType.quote, emoji: '💬',
      colorValue: 0xFF9C6BFF,
      text: 'Bin mil yolculuk tek adımla başlar.',
      author: 'Lao Tzu',
    ),
    MotivationCard(
      id: 'q9', type: CardType.quote, emoji: '💬',
      colorValue: 0xFF6C63FF,
      text: 'Kendine inan. Her şey seninle başlar.',
      author: 'Anonim',
    ),
    MotivationCard(
      id: 'q10', type: CardType.quote, emoji: '💬',
      colorValue: 0xFF9C6BFF,
      text: 'Fırtına geçer, güneş kalır.',
      author: 'Atasözü',
    ),

    // ─── 🧠 BİLİM ──────────────────────────────────
    MotivationCard(
      id: 's1', type: CardType.science, emoji: '🧠',
      colorValue: 0xFF40C9FF,
      text: 'Gülümsemek beyni kandırır ve mutlu eder. Buna "Facial Feedback Hipotezi" denir.',
      author: 'Nörobilim',
    ),
    MotivationCard(
      id: 's2', type: CardType.science, emoji: '🧠',
      colorValue: 0xFF2196F3,
      text: '5 dakika doğada yürümek, stres hormonunu %16 düşürür.',
      author: 'Stanford Araştırması',
    ),
    MotivationCard(
      id: 's3', type: CardType.science, emoji: '🧠',
      colorValue: 0xFF40C9FF,
      text: 'Minnettarlık günlüğü tutanlar, %25 daha mutlu hisseder.',
      author: 'Pozitif Psikoloji',
    ),
    MotivationCard(
      id: 's4', type: CardType.science, emoji: '🧠',
      colorValue: 0xFF2196F3,
      text: 'Birini sarmalamak 20 sn sürdüğünde oksitosin hormonu salgılanır — güven ve bağ hissi oluşur.',
      author: 'Nörobilim',
    ),
    MotivationCard(
      id: 's5', type: CardType.science, emoji: '🧠',
      colorValue: 0xFF40C9FF,
      text: 'Beyin yeni bir alışkanlığı 66 günde otomatik hale getirir.',
      author: 'University College London',
    ),
    MotivationCard(
      id: 's6', type: CardType.science, emoji: '🧠',
      colorValue: 0xFF2196F3,
      text: 'Müzik dinlemek dopamin salgılatır — yemek yemek kadar zevk verir.',
      author: 'McGill Üniversitesi',
    ),
    MotivationCard(
      id: 's7', type: CardType.science, emoji: '🧠',
      colorValue: 0xFF40C9FF,
      text: '2 dakika boyunca güçlü bir poz almak (Superman pozu) özgüveni artırır.',
      author: 'Harvard Araştırması',
    ),
    MotivationCard(
      id: 's8', type: CardType.science, emoji: '🧠',
      colorValue: 0xFF2196F3,
      text: 'İyilik yapmak, beyinde ödül merkezini aktive eder. Buna "Helper\'s High" denir.',
      author: 'Davranış Bilimi',
    ),
    MotivationCard(
      id: 's9', type: CardType.science, emoji: '🧠',
      colorValue: 0xFF40C9FF,
      text: 'Derin nefes almak vagus sinirini uyarır ve kalp atışını yavaşlatır — anında sakinlik.',
      author: 'Nörobilim',
    ),
    MotivationCard(
      id: 's10', type: CardType.science, emoji: '🧠',
      colorValue: 0xFF2196F3,
      text: 'Sabah güneş ışığına 10 dk maruz kalmak uyku kalitenizi %65 artırır.',
      author: 'Sirkadyen Ritim Araştırması',
    ),

    // ─── 😂 ESPRİLER ────────────────────────────────
    MotivationCard(
      id: 'j1', type: CardType.joke, emoji: '😂',
      colorValue: 0xFFFF9F43,
      text: 'Bugün erken kalktım... diye rüya gördüm.',
    ),
    MotivationCard(
      id: 'j2', type: CardType.joke, emoji: '😂',
      colorValue: 0xFFFFB347,
      text: 'Hayat kısa diyorlar. Ama sabah 6\'da kalk bir de, o zaman ne kadar uzun olduğunu anlarsın.',
    ),
    MotivationCard(
      id: 'j3', type: CardType.joke, emoji: '😂',
      colorValue: 0xFFFF9F43,
      text: 'Pozitif düşünmeye başladım. Artık hiçbir şey yapmasam bile iyi hissediyorum.',
    ),
    MotivationCard(
      id: 'j4', type: CardType.joke, emoji: '😂',
      colorValue: 0xFFFFB347,
      text: '"Her şey güzel olacak" diyen adam sonra ne oldu? Bilmiyoruz, hâlâ bekliyor.',
    ),
    MotivationCard(
      id: 'j5', type: CardType.joke, emoji: '😂',
      colorValue: 0xFFFF9F43,
      text: 'Spor salonuna yazıldım. Şu ana kadar 3 kilo verdim. Paraya diyorum.',
    ),
    MotivationCard(
      id: 'j6', type: CardType.joke, emoji: '😂',
      colorValue: 0xFFFFB347,
      text: 'Motivasyon videosu izledim 2 saat. Sonra yattım. Yarın başlıyorum.',
    ),
    MotivationCard(
      id: 'j7', type: CardType.joke, emoji: '😂',
      colorValue: 0xFFFF9F43,
      text: 'Yapay zekaya "Beni motive et" dedim. "Git bir şey yap" dedi. Haklıymış.',
    ),
    MotivationCard(
      id: 'j8', type: CardType.joke, emoji: '😂',
      colorValue: 0xFFFFB347,
      text: 'Bugün çok üretken olacağım dedim. Sonra bu cümleyi söylemek de bir üretkenlik sayılır dedim.',
    ),
    MotivationCard(
      id: 'j9', type: CardType.joke, emoji: '😂',
      colorValue: 0xFFFF9F43,
      text: 'Kedim benden daha motive. En azından her gün aynı saatte kalkıyor.',
    ),
    MotivationCard(
      id: 'j10', type: CardType.joke, emoji: '😂',
      colorValue: 0xFFFFB347,
      text: 'Hayat bir maraton diyorlar. Ben daha koşu ayakkabımı bulamadım.',
    ),

    // ─── 🎯 MEYDAN OKUMALAR ─────────────────────────
    MotivationCard(
      id: 'c1', type: CardType.challenge, emoji: '🎯',
      colorValue: 0xFF5ED39C,
      text: 'Bugün tanımadığın birine "günaydın" de.',
    ),
    MotivationCard(
      id: 'c2', type: CardType.challenge, emoji: '🎯',
      colorValue: 0xFF4CAF50,
      text: 'Sevdiğin birine "seni düşünüyorum" mesajı at.',
    ),
    MotivationCard(
      id: 'c3', type: CardType.challenge, emoji: '🎯',
      colorValue: 0xFF5ED39C,
      text: '5 dakika boyunca telefonunu bırak ve pencereden dışarı bak.',
    ),
    MotivationCard(
      id: 'c4', type: CardType.challenge, emoji: '🎯',
      colorValue: 0xFF4CAF50,
      text: 'Bugün bir şeye "hayır" de. Sınırlarını koru.',
    ),
    MotivationCard(
      id: 'c5', type: CardType.challenge, emoji: '🎯',
      colorValue: 0xFF5ED39C,
      text: 'Bugün birini güldür. Nasıl hissettirdiğini akşam düşün.',
    ),
    MotivationCard(
      id: 'c6', type: CardType.challenge, emoji: '🎯',
      colorValue: 0xFF4CAF50,
      text: 'Hiç denemediğin bir içecek dene bugün.',
    ),
    MotivationCard(
      id: 'c7', type: CardType.challenge, emoji: '🎯',
      colorValue: 0xFF5ED39C,
      text: '10 dakika sessizce otur. Hiçbir şey yapma.',
    ),
    MotivationCard(
      id: 'c8', type: CardType.challenge, emoji: '🎯',
      colorValue: 0xFF4CAF50,
      text: 'Bugün en az 3 kişiye teşekkür et.',
    ),
    MotivationCard(
      id: 'c9', type: CardType.challenge, emoji: '🎯',
      colorValue: 0xFF5ED39C,
      text: 'Aynaya bak ve kendine "İyi gidiyorsun" de.',
    ),
    MotivationCard(
      id: 'c10', type: CardType.challenge, emoji: '🎯',
      colorValue: 0xFF4CAF50,
      text: 'Bugün yeni bir şarkı keşfet ve baştan sona dinle.',
    ),

    // ─── 💡 PERSPEKTİF ──────────────────────────────
    MotivationCard(
      id: 'p1', type: CardType.perspective, emoji: '💡',
      colorValue: 0xFFFFD700,
      text: '1 yıl sonra bugünü hatırla. O gün için önemli olan ne olacak?',
    ),
    MotivationCard(
      id: 'p2', type: CardType.perspective, emoji: '💡',
      colorValue: 0xFFFFC107,
      text: 'Geçen yıl çözemeyeceğini düşündüğün bir sorun vardı. Şimdi nerede o sorun?',
    ),
    MotivationCard(
      id: 'p3', type: CardType.perspective, emoji: '💡',
      colorValue: 0xFFFFD700,
      text: 'Bugün endişelendiğin şeylerin %85\'i hiç gerçekleşmeyecek.',
    ),
    MotivationCard(
      id: 'p4', type: CardType.perspective, emoji: '💡',
      colorValue: 0xFFFFC107,
      text: '5 yaşındaki sen bugünkü seni görse ne derdi?',
    ),
    MotivationCard(
      id: 'p5', type: CardType.perspective, emoji: '💡',
      colorValue: 0xFFFFD700,
      text: 'Şu an sahip olduğun şeyler, bir zamanlar dua ettiğin şeylerdi.',
    ),
    MotivationCard(
      id: 'p6', type: CardType.perspective, emoji: '💡',
      colorValue: 0xFFFFC107,
      text: 'Mükemmel zaman diye bir şey yok. En iyi zaman şu an.',
    ),
    MotivationCard(
      id: 'p7', type: CardType.perspective, emoji: '💡',
      colorValue: 0xFFFFD700,
      text: 'Hata yapmaktan korkma. Hata, öğrenmenin ta kendisidir.',
    ),
    MotivationCard(
      id: 'p8', type: CardType.perspective, emoji: '💡',
      colorValue: 0xFFFFC107,
      text: 'Seni tanımayan biri, başarılarını duysa ne düşünürdü?',
    ),
    MotivationCard(
      id: 'p9', type: CardType.perspective, emoji: '💡',
      colorValue: 0xFFFFD700,
      text: 'Dünya 8 milyar insandan oluşuyor. Senin gibi sadece 1 tane var.',
    ),
    MotivationCard(
      id: 'p10', type: CardType.perspective, emoji: '💡',
      colorValue: 0xFFFFC107,
      text: 'Karanlık ne kadar derin olursa olsun, bir kibrit çakmak yeter.',
    ),

    // ─── 🌍 HİKAYELER ──────────────────────────────
    MotivationCard(
      id: 'st1', type: CardType.story, emoji: '🌍',
      colorValue: 0xFFFF6B6B,
      text: 'Edison ampulü bulmadan önce 10.000 kez başarısız oldu. "Başarısız olmadım, işe yaramayan 10.000 yol buldum" dedi.',
      author: 'Thomas Edison',
    ),
    MotivationCard(
      id: 'st2', type: CardType.story, emoji: '🌍',
      colorValue: 0xFFE53935,
      text: 'J.K. Rowling, Harry Potter\'ı yazarken 12 yayınevi tarafından reddedildi. Bugün dünyanın en çok satan yazarlarından biri.',
      author: 'J.K. Rowling',
    ),
    MotivationCard(
      id: 'st3', type: CardType.story, emoji: '🌍',
      colorValue: 0xFFFF6B6B,
      text: 'Walt Disney ilk iş başvurusunda "yaratıcılığı yok" diye reddedildi. Sonra dünyanın en büyük eğlence imparatorluğunu kurdu.',
      author: 'Walt Disney',
    ),
    MotivationCard(
      id: 'st4', type: CardType.story, emoji: '🌍',
      colorValue: 0xFFE53935,
      text: 'Oprah Winfrey çocukluğunda aşırı yoksulluk yaşadı. Bugün dünyanın en etkili kadınlarından biri.',
      author: 'Oprah Winfrey',
    ),
    MotivationCard(
      id: 'st5', type: CardType.story, emoji: '🌍',
      colorValue: 0xFFFF6B6B,
      text: 'Beethoven sağır olduktan sonra en ünlü eserlerini besteledi. 9. Senfoni\'yi hiç duymadan yazdı.',
      author: 'Beethoven',
    ),
    MotivationCard(
      id: 'st6', type: CardType.story, emoji: '🌍',
      colorValue: 0xFFE53935,
      text: 'Steve Jobs Apple\'dan kovuldu. Yıllar sonra geri döndü ve iPhone\'u yarattı.',
      author: 'Steve Jobs',
    ),
    MotivationCard(
      id: 'st7', type: CardType.story, emoji: '🌍',
      colorValue: 0xFFFF6B6B,
      text: 'Michael Jordan lisede basketbol takımına alınmadı. "Bu beni motive etti" dedi ve tarihin en iyisi oldu.',
      author: 'Michael Jordan',
    ),
    MotivationCard(
      id: 'st8', type: CardType.story, emoji: '🌍',
      colorValue: 0xFFE53935,
      text: 'Einstein 4 yaşına kadar konuşamadı, 7 yaşına kadar okuyamadı. Öğretmenleri "bu çocuktan bir şey olmaz" dedi.',
      author: 'Albert Einstein',
    ),
    MotivationCard(
      id: 'st9', type: CardType.story, emoji: '🌍',
      colorValue: 0xFFFF6B6B,
      text: 'Bir Japon atasözü: "Yedi kez düş, sekiz kez kalk." Nanakorobi yaoki — hayatın özeti.',
      author: 'Japon Atasözü',
    ),
    MotivationCard(
      id: 'st10', type: CardType.story, emoji: '🌍',
      colorValue: 0xFFE53935,
      text: 'Bir köylü, her gün bir taş taşıyarak dağın tepesine bir ev inşa etti. "Nasıl yaptın?" dediler. "Her gün bir taş" dedi.',
      author: 'Halk Hikayesi',
    ),
  ];
}
