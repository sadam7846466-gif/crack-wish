import 'dart:math';

/// Moral mini-an tipleri
enum MoralType {
  joke,      // 😂 Espri
  quiz,      // 🧠 Quiz
  choice,    // 🤔 Hangisini seçerdin?
  fact,      // 💡 İlginç bilgi
  miniGame,  // 🎮 Mini oyun
  task,      // 🎯 Görev
  story,     // 🥹 Hikaye
  prompt,    // ✍️ Yaratıcı soru
}

/// Tek bir moral içeriği
class MoralItem {
  final String id;
  final MoralType type;
  final String text;
  final String? author;
  final String emoji;
  final int colorValue;
  // Quiz için
  final List<String>? options;
  final int? correctIndex;
  // Choice için
  final String? optionA;
  final String? optionB;
  final int? percentA; // sahte istatistik
  // MiniGame için
  final String? gameType; // 'reflex', 'memory', 'count'

  const MoralItem({
    required this.id,
    required this.type,
    required this.text,
    required this.emoji,
    required this.colorValue,
    this.author,
    this.options,
    this.correctIndex,
    this.optionA,
    this.optionB,
    this.percentA,
    this.gameType,
  });
}

/// Seans motoru
class MoralSession {
  static final _random = Random();

  /// 10 rastgele mini an seç (görülmemişlerden)
  static List<MoralItem> generate(List<String> seenIds) {
    // Her tipten en az 1 tane olsun, geri kalanı rastgele
    final Map<MoralType, List<MoralItem>> byType = {};
    for (final type in MoralType.values) {
      byType[type] = allItems
          .where((i) => i.type == type && !seenIds.contains(i.id))
          .toList();
    }

    final selected = <MoralItem>[];

    // Her tipten 1 tane garanti (varsa)
    for (final type in MoralType.values) {
      final pool = byType[type]!;
      if (pool.isNotEmpty) {
        pool.shuffle(_random);
        selected.add(pool.removeAt(0));
      }
    }

    // Kalan slotları rastgele doldur (toplam 10)
    final remaining = byType.values.expand((l) => l).toList();
    remaining.shuffle(_random);
    while (selected.length < 10 && remaining.isNotEmpty) {
      selected.add(remaining.removeAt(0));
    }

    // Eğer yeterli yoksa seenIds'i yoksay
    if (selected.length < 10) {
      final fallback = List<MoralItem>.from(allItems);
      fallback.shuffle(_random);
      for (final item in fallback) {
        if (selected.length >= 10) break;
        if (!selected.any((s) => s.id == item.id)) {
          selected.add(item);
        }
      }
    }

    selected.shuffle(_random);
    return selected.take(10).toList();
  }

  // ═══════════════════════════════════════════════════════════════
  // İÇERİK HAVUZU
  // ═══════════════════════════════════════════════════════════════

  static const List<MoralItem> allItems = [
    // ─── 😂 ESPRİLER ────────────────────────────────
    MoralItem(id: 'j1', type: MoralType.joke, emoji: '😂', colorValue: 0xFFFF9F43,
      text: 'Bugün erken kalktım... diye rüya gördüm.'),
    MoralItem(id: 'j2', type: MoralType.joke, emoji: '😂', colorValue: 0xFFFFB347,
      text: 'Pozitif düşünmeye başladım. Artık hiçbir şey yapmasam bile iyi hissediyorum.'),
    MoralItem(id: 'j3', type: MoralType.joke, emoji: '😂', colorValue: 0xFFFF9F43,
      text: 'Spor salonuna yazıldım. Şu ana kadar 3 kilo verdim. Paraya diyorum.'),
    MoralItem(id: 'j4', type: MoralType.joke, emoji: '😂', colorValue: 0xFFFFB347,
      text: 'Motivasyon videosu izledim 2 saat. Sonra yattım. Yarın başlıyorum.'),
    MoralItem(id: 'j5', type: MoralType.joke, emoji: '😂', colorValue: 0xFFFF9F43,
      text: 'Yapay zekaya "Beni motive et" dedim. "Git bir şey yap" dedi. Haklıymış.'),
    MoralItem(id: 'j6', type: MoralType.joke, emoji: '😂', colorValue: 0xFFFFB347,
      text: 'Kedim benden daha motive. En azından her gün aynı saatte kalkıyor.'),
    MoralItem(id: 'j7', type: MoralType.joke, emoji: '😂', colorValue: 0xFFFF9F43,
      text: '"Her şey güzel olacak" diyen adam sonra ne oldu? Bilmiyoruz, hâlâ bekliyor.'),
    MoralItem(id: 'j8', type: MoralType.joke, emoji: '😂', colorValue: 0xFFFFB347,
      text: 'Hayat bir maraton diyorlar. Ben daha koşu ayakkabımı bulamadım.'),
    MoralItem(id: 'j9', type: MoralType.joke, emoji: '😂', colorValue: 0xFFFF9F43,
      text: 'Bugün çok üretken olacağım dedim. Sonra bu cümleyi söylemek de bir üretkenlik sayılır dedim.'),
    MoralItem(id: 'j10', type: MoralType.joke, emoji: '😂', colorValue: 0xFFFFB347,
      text: 'Hayat kısa diyorlar. Ama sabah 6\'da kalk bir de, o zaman ne kadar uzun olduğunu anlarsın.'),

    // ─── 🧠 QUİZ ────────────────────────────────────
    MoralItem(id: 'q1', type: MoralType.quiz, emoji: '🧠', colorValue: 0xFF6C63FF,
      text: 'Dünyada en çok konuşulan dil hangisidir?',
      options: ['İngilizce', 'Mandarin Çince', 'İspanyolca'], correctIndex: 1),
    MoralItem(id: 'q2', type: MoralType.quiz, emoji: '🧠', colorValue: 0xFF9C6BFF,
      text: 'Bir insanın vücudundaki kemik sayısı kaçtır?',
      options: ['186', '206', '226'], correctIndex: 1),
    MoralItem(id: 'q3', type: MoralType.quiz, emoji: '🧠', colorValue: 0xFF6C63FF,
      text: 'Hangi gezegen en hızlı döner?',
      options: ['Mars', 'Jüpiter', 'Venüs'], correctIndex: 1),
    MoralItem(id: 'q4', type: MoralType.quiz, emoji: '🧠', colorValue: 0xFF9C6BFF,
      text: 'Bal bozulur mu?',
      options: ['Evet, 1 yılda', 'Evet, 10 yılda', 'Hayır, asla bozulmaz'], correctIndex: 2),
    MoralItem(id: 'q5', type: MoralType.quiz, emoji: '🧠', colorValue: 0xFF6C63FF,
      text: 'Hangi hayvan en uzun süre uyumadan kalabilir?',
      options: ['Zürafalar', 'Karıncalar', 'Yunus balıkları'], correctIndex: 0),
    MoralItem(id: 'q6', type: MoralType.quiz, emoji: '🧠', colorValue: 0xFF9C6BFF,
      text: 'Dünyanın en küçük ülkesi hangisidir?',
      options: ['Monako', 'Vatikan', 'San Marino'], correctIndex: 1),
    MoralItem(id: 'q7', type: MoralType.quiz, emoji: '🧠', colorValue: 0xFF6C63FF,
      text: 'İnsan beyni günde kaç düşünce üretir?',
      options: ['6.000', '60.000', '600.000'], correctIndex: 1),
    MoralItem(id: 'q8', type: MoralType.quiz, emoji: '🧠', colorValue: 0xFF9C6BFF,
      text: 'Hangi renk en çok dikkat çeker?',
      options: ['Kırmızı', 'Sarı', 'Mavi'], correctIndex: 1),

    // ─── 🤔 HANGİSİNİ SEÇERDİN? ────────────────────
    MoralItem(id: 'ch1', type: MoralType.choice, emoji: '🤔', colorValue: 0xFF26C6DA,
      text: 'Hangisini seçerdin?', optionA: 'Uçabilmek ✈️', optionB: 'Görünmez olmak 👻', percentA: 68),
    MoralItem(id: 'ch2', type: MoralType.choice, emoji: '🤔', colorValue: 0xFF29B6F6,
      text: 'Hangisini seçerdin?', optionA: 'Geçmişe gitmek ⏪', optionB: 'Geleceği görmek ⏩', percentA: 45),
    MoralItem(id: 'ch3', type: MoralType.choice, emoji: '🤔', colorValue: 0xFF26C6DA,
      text: 'Hangisini seçerdin?', optionA: 'Her dili bilmek 🗣️', optionB: 'Her enstrümanı çalmak 🎸', percentA: 72),
    MoralItem(id: 'ch4', type: MoralType.choice, emoji: '🤔', colorValue: 0xFF29B6F6,
      text: 'Hangisini seçerdin?', optionA: 'Sonsuz para 💰', optionB: 'Sonsuz zaman ⏳', percentA: 38),
    MoralItem(id: 'ch5', type: MoralType.choice, emoji: '🤔', colorValue: 0xFF26C6DA,
      text: 'Hangisini seçerdin?', optionA: 'Hayvanlarla konuşmak 🐶', optionB: 'Zihin okumak 🧠', percentA: 55),
    MoralItem(id: 'ch6', type: MoralType.choice, emoji: '🤔', colorValue: 0xFF29B6F6,
      text: 'Hangisini seçerdin?', optionA: 'Hep yaz olsun ☀️', optionB: 'Hep kış olsun ❄️', percentA: 61),

    // ─── 💡 İLGİNÇ BİLGİ ────────────────────────────
    MoralItem(id: 'f1', type: MoralType.fact, emoji: '💡', colorValue: 0xFF40C9FF,
      text: 'Denizatı dünyadaki tek erkeğin doğum yaptığı canlıdır. 🐴'),
    MoralItem(id: 'f2', type: MoralType.fact, emoji: '💡', colorValue: 0xFF2196F3,
      text: 'Penguenler evlenme teklifi yapar — en güzel çakıl taşını bulup dişisine sunar. 🐧'),
    MoralItem(id: 'f3', type: MoralType.fact, emoji: '💡', colorValue: 0xFF40C9FF,
      text: 'Bir insan ömrü boyunca ortalama 2 yıl sadece sıra bekleyerek geçirir. ⏰'),
    MoralItem(id: 'f4', type: MoralType.fact, emoji: '💡', colorValue: 0xFF2196F3,
      text: 'Gülmek bağışıklık sistemini güçlendirir ve ağrı eşiğini yükseltir. 😄'),
    MoralItem(id: 'f5', type: MoralType.fact, emoji: '💡', colorValue: 0xFF40C9FF,
      text: 'Ahtapotun 3 kalbi ve mavi kanı vardır. 🐙'),
    MoralItem(id: 'f6', type: MoralType.fact, emoji: '💡', colorValue: 0xFF2196F3,
      text: 'Bal asla bozulmaz. 3000 yıllık Mısır mezarlarında bulunan bal hâlâ yenilebilir durumda. 🍯'),
    MoralItem(id: 'f7', type: MoralType.fact, emoji: '💡', colorValue: 0xFF40C9FF,
      text: 'Ay her yıl Dünya\'dan 3.8 cm uzaklaşıyor. 🌙'),
    MoralItem(id: 'f8', type: MoralType.fact, emoji: '💡', colorValue: 0xFF2196F3,
      text: 'Kediler günde yaklaşık 16 saat uyur — hayatlarının %70\'ini uykuda geçirirler. 😺'),

    // ─── 🎯 GÖREV ───────────────────────────────────
    MoralItem(id: 't1', type: MoralType.task, emoji: '🎯', colorValue: 0xFF5ED39C,
      text: 'Aynaya bak, kendine gülümse ve 10 saniye tut 😊'),
    MoralItem(id: 't2', type: MoralType.task, emoji: '🎯', colorValue: 0xFF4CAF50,
      text: 'Sevdiğin birine "seni düşünüyorum" mesajı at 💌'),
    MoralItem(id: 't3', type: MoralType.task, emoji: '🎯', colorValue: 0xFF5ED39C,
      text: '3 kez zıpla ve "Yapabilirim!" de 🦘'),
    MoralItem(id: 't4', type: MoralType.task, emoji: '🎯', colorValue: 0xFF4CAF50,
      text: 'Kollarını iki yana aç, Superman pozu yap, 20 saniye tut 🦸'),
    MoralItem(id: 't5', type: MoralType.task, emoji: '🎯', colorValue: 0xFF5ED39C,
      text: 'En sevdiğin şarkıyı aç, 30 saniye dinle 🎵'),
    MoralItem(id: 't6', type: MoralType.task, emoji: '🎯', colorValue: 0xFF4CAF50,
      text: 'Gördüğün ilk kişiye gülümse 😁'),

    // ─── 🥹 HİKAYE ──────────────────────────────────
    MoralItem(id: 'st1', type: MoralType.story, emoji: '🥹', colorValue: 0xFFFF6B6B,
      text: 'Bir çocuk her gün yaşlı komşusuna el sallardı. Yaşlı adam vefat ettiğinde ailesine not bırakmıştı: "O çocuğun selamı beni hayatta tuttu."'),
    MoralItem(id: 'st2', type: MoralType.story, emoji: '🥹', colorValue: 0xFFE53935,
      text: 'Edison ampulü bulmadan önce 10.000 kez başarısız oldu. "Başarısız olmadım, işe yaramayan 10.000 yol buldum" dedi.',
      author: 'Thomas Edison'),
    MoralItem(id: 'st3', type: MoralType.story, emoji: '🥹', colorValue: 0xFFFF6B6B,
      text: 'Bir köylü her gün bir taş taşıyarak dağın tepesine ev inşa etti. "Nasıl yaptın?" dediler. "Her gün bir taş" dedi.'),
    MoralItem(id: 'st4', type: MoralType.story, emoji: '🥹', colorValue: 0xFFE53935,
      text: 'Michael Jordan lisede basketbol takımına alınmadı. "Bu beni motive etti" dedi ve tarihin en iyisi oldu.',
      author: 'Michael Jordan'),
    MoralItem(id: 'st5', type: MoralType.story, emoji: '🥹', colorValue: 0xFFFF6B6B,
      text: 'J.K. Rowling Harry Potter\'ı yazarken 12 yayınevi reddetti. Bugün dünyanın en çok satan yazarlarından biri.',
      author: 'J.K. Rowling'),
    MoralItem(id: 'st6', type: MoralType.story, emoji: '🥹', colorValue: 0xFFE53935,
      text: 'Beethoven sağır olduktan sonra en ünlü eserlerini besteledi. 9. Senfoni\'yi hiç duymadan yazdı.',
      author: 'Beethoven'),

    // ─── ✍️ YARATICI SORU ────────────────────────────
    MoralItem(id: 'p1', type: MoralType.prompt, emoji: '✍️', colorValue: 0xFFFFD700,
      text: 'Bugünü 3 emoji ile anlat'),
    MoralItem(id: 'p2', type: MoralType.prompt, emoji: '✍️', colorValue: 0xFFFFC107,
      text: 'Süper gücün olsa ne olurdu?'),
    MoralItem(id: 'p3', type: MoralType.prompt, emoji: '✍️', colorValue: 0xFFFFD700,
      text: 'Hayatındaki en güzel anı 1 cümleyle anlat'),
    MoralItem(id: 'p4', type: MoralType.prompt, emoji: '✍️', colorValue: 0xFFFFC107,
      text: 'Bugün teşekkür edeceğin 1 şey ne?'),
    MoralItem(id: 'p5', type: MoralType.prompt, emoji: '✍️', colorValue: 0xFFFFD700,
      text: '10 yıl sonraki sen bu mesajı okusa ne derdi?'),
    MoralItem(id: 'p6', type: MoralType.prompt, emoji: '✍️', colorValue: 0xFFFFC107,
      text: 'Bir hayvan olsan hangisi olurdun ve neden?'),

    // ─── 🎮 MİNİ OYUN ───────────────────────────────
    MoralItem(id: 'g1', type: MoralType.miniGame, emoji: '🎮', colorValue: 0xFFFF5722,
      text: 'Refleks Testi', gameType: 'reflex'),
    MoralItem(id: 'g2', type: MoralType.miniGame, emoji: '🎮', colorValue: 0xFFE91E63,
      text: 'Renk Eşleştirme', gameType: 'color'),
    MoralItem(id: 'g3', type: MoralType.miniGame, emoji: '🎮', colorValue: 0xFF9C27B0,
      text: 'Sayı Hafızası', gameType: 'memory'),
  ];
}
