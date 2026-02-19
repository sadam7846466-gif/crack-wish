import 'dart:math';

/// Çark görev kategorileri
enum WheelCategory {
  connection,   // 🫶 Bağlantı
  smile,        // 😊 Gülümseme
  movement,     // 🚶 Hareket
  music,        // 🎵 Müzik
  gratitude,    // 🙏 Minnettarlık
  fun,          // 🤪 Eğlence
}

/// Tek bir çark görevi
class WheelTask {
  final String id;
  final WheelCategory category;
  final String text;
  final String emoji;
  final int colorValue;

  const WheelTask({
    required this.id,
    required this.category,
    required this.text,
    required this.emoji,
    required this.colorValue,
  });
}

/// Çark görev havuzu
class WheelTasks {
  static final _random = Random();

  /// Bugün kullanılmamış rastgele görev seç
  static WheelTask getRandomTask(List<String> usedToday) {
    final available = allTasks
        .where((t) => !usedToday.contains(t.id))
        .toList();
    
    final pool = available.isEmpty ? List<WheelTask>.from(allTasks) : available;
    return pool[_random.nextInt(pool.length)];
  }

  /// Kategori emoji
  static String categoryEmoji(WheelCategory cat) {
    switch (cat) {
      case WheelCategory.connection: return '🫶';
      case WheelCategory.smile: return '😊';
      case WheelCategory.movement: return '🚶';
      case WheelCategory.music: return '🎵';
      case WheelCategory.gratitude: return '🙏';
      case WheelCategory.fun: return '🤪';
    }
  }

  /// Kategori etiketi
  static String categoryLabel(WheelCategory cat) {
    switch (cat) {
      case WheelCategory.connection: return 'Bağlantı';
      case WheelCategory.smile: return 'Gülümseme';
      case WheelCategory.movement: return 'Hareket';
      case WheelCategory.music: return 'Müzik';
      case WheelCategory.gratitude: return 'Minnettarlık';
      case WheelCategory.fun: return 'Eğlence';
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // GÖREV HAVUZU — 36 Görev (6 kategori × 6 görev)
  // ═══════════════════════════════════════════════════════════════

  static const List<WheelTask> allTasks = [
    // 🫶 Bağlantı
    WheelTask(id: 'w_c1', category: WheelCategory.connection, emoji: '🫶', colorValue: 0xFFFF6B9D,
      text: 'Sevdiğin birine "seni düşünüyorum" mesajı at'),
    WheelTask(id: 'w_c2', category: WheelCategory.connection, emoji: '🫶', colorValue: 0xFFFF6B9D,
      text: 'Uzun süredir konuşmadığın birine merhaba de'),
    WheelTask(id: 'w_c3', category: WheelCategory.connection, emoji: '🫶', colorValue: 0xFFFF6B9D,
      text: 'Ailenden birine bugün ne kadar önemli olduğunu söyle'),
    WheelTask(id: 'w_c4', category: WheelCategory.connection, emoji: '🫶', colorValue: 0xFFFF6B9D,
      text: 'Yanındaki birine iltifat et'),
    WheelTask(id: 'w_c5', category: WheelCategory.connection, emoji: '🫶', colorValue: 0xFFFF6B9D,
      text: 'Bir arkadaşına komik bir video gönder'),
    WheelTask(id: 'w_c6', category: WheelCategory.connection, emoji: '🫶', colorValue: 0xFFFF6B9D,
      text: 'Birine bugün teşekkür et, nedenini açıkla'),

    // 😊 Gülümseme
    WheelTask(id: 'w_s1', category: WheelCategory.smile, emoji: '😊', colorValue: 0xFFFFB347,
      text: 'Aynaya bak, kendine gülümse, 10 saniye tut'),
    WheelTask(id: 'w_s2', category: WheelCategory.smile, emoji: '😊', colorValue: 0xFFFFB347,
      text: 'En son ne zaman kahkaha attığını hatırla ve tekrar gülümse'),
    WheelTask(id: 'w_s3', category: WheelCategory.smile, emoji: '😊', colorValue: 0xFFFFB347,
      text: 'Komik bir anını düşün ve sesli güle'),
    WheelTask(id: 'w_s4', category: WheelCategory.smile, emoji: '😊', colorValue: 0xFFFFB347,
      text: 'Telefonundaki en komik fotoğrafı bul ve bak'),
    WheelTask(id: 'w_s5', category: WheelCategory.smile, emoji: '😊', colorValue: 0xFFFFB347,
      text: 'Gördüğün ilk kişiye gülümse'),
    WheelTask(id: 'w_s6', category: WheelCategory.smile, emoji: '😊', colorValue: 0xFFFFB347,
      text: 'Bugün yaşadığın en komik anı düşün'),

    // 🚶 Hareket
    WheelTask(id: 'w_m1', category: WheelCategory.movement, emoji: '🚶', colorValue: 0xFF5ED39C,
      text: 'Ayağa kalk, 30 saniye streç yap'),
    WheelTask(id: 'w_m2', category: WheelCategory.movement, emoji: '🚶', colorValue: 0xFF5ED39C,
      text: '1 dakika boyunca odanı yürü'),
    WheelTask(id: 'w_m3', category: WheelCategory.movement, emoji: '🚶', colorValue: 0xFF5ED39C,
      text: '10 kez zıpla ve "yapabilirim!" de'),
    WheelTask(id: 'w_m4', category: WheelCategory.movement, emoji: '🚶', colorValue: 0xFF5ED39C,
      text: 'Kollarını yukarı kaldır ve 20 saniye Superman pozu yap'),
    WheelTask(id: 'w_m5', category: WheelCategory.movement, emoji: '🚶', colorValue: 0xFF5ED39C,
      text: 'Omuzlarını 5 kez ileri, 5 kez geri döndür'),
    WheelTask(id: 'w_m6', category: WheelCategory.movement, emoji: '🚶', colorValue: 0xFF5ED39C,
      text: 'Derin bir nefes al, kollarını iki yana aç, 10 saniye tut'),

    // 🎵 Müzik
    WheelTask(id: 'w_mu1', category: WheelCategory.music, emoji: '🎵', colorValue: 0xFF9C6BFF,
      text: 'En sevdiğin şarkıyı aç, 1 dakika dinle'),
    WheelTask(id: 'w_mu2', category: WheelCategory.music, emoji: '🎵', colorValue: 0xFF9C6BFF,
      text: 'Rastgele bir şarkı aç, ilk 30 saniyesini dinle'),
    WheelTask(id: 'w_mu3', category: WheelCategory.music, emoji: '🎵', colorValue: 0xFF9C6BFF,
      text: 'Şarkı söyle! Yüksek sesle, kimse dinlemiyor gibi'),
    WheelTask(id: 'w_mu4', category: WheelCategory.music, emoji: '🎵', colorValue: 0xFF9C6BFF,
      text: 'Bugün keşfetmediğin bir türde şarkı dinle'),
    WheelTask(id: 'w_mu5', category: WheelCategory.music, emoji: '🎵', colorValue: 0xFF9C6BFF,
      text: 'Gözlerini kapa ve 30 saniye etrafındaki sesleri dinle'),
    WheelTask(id: 'w_mu6', category: WheelCategory.music, emoji: '🎵', colorValue: 0xFF9C6BFF,
      text: 'Parmağınla masaya bir ritim çal, 15 saniye'),

    // 🙏 Minnettarlık
    WheelTask(id: 'w_g1', category: WheelCategory.gratitude, emoji: '🙏', colorValue: 0xFF40C9FF,
      text: 'Bugün sahip olduğun 1 şeyi düşün ve "teşekkürler" de'),
    WheelTask(id: 'w_g2', category: WheelCategory.gratitude, emoji: '🙏', colorValue: 0xFF40C9FF,
      text: 'Seni mutlu eden 3 küçük şeyi say'),
    WheelTask(id: 'w_g3', category: WheelCategory.gratitude, emoji: '🙏', colorValue: 0xFF40C9FF,
      text: 'Bugün yediğin en güzel şeyi düşün ve tadını hatırla'),
    WheelTask(id: 'w_g4', category: WheelCategory.gratitude, emoji: '🙏', colorValue: 0xFF40C9FF,
      text: 'Hayatındaki en güzel anı 10 saniye düşün'),
    WheelTask(id: 'w_g5', category: WheelCategory.gratitude, emoji: '🙏', colorValue: 0xFF40C9FF,
      text: 'Sağlığın için minnettarlık duy. Derin bir nefes al.'),
    WheelTask(id: 'w_g6', category: WheelCategory.gratitude, emoji: '🙏', colorValue: 0xFF40C9FF,
      text: 'Bugün güneşin doğduğu için minnettarlık duy'),

    // 🤪 Eğlence
    WheelTask(id: 'w_f1', category: WheelCategory.fun, emoji: '🤪', colorValue: 0xFFFF5722,
      text: '3 kez zıpla ve "Yapabilirim!" diye bağır'),
    WheelTask(id: 'w_f2', category: WheelCategory.fun, emoji: '🤪', colorValue: 0xFFFF5722,
      text: 'En komik yüz ifadeni yap ve 5 saniye tut'),
    WheelTask(id: 'w_f3', category: WheelCategory.fun, emoji: '🤪', colorValue: 0xFFFF5722,
      text: 'Hayvan taklidi yap — hangi hayvan olurdun?'),
    WheelTask(id: 'w_f4', category: WheelCategory.fun, emoji: '🤪', colorValue: 0xFFFF5722,
      text: 'Gözlerini kapa ve 10 saniye boyunca hayal et ki uçuyorsun'),
    WheelTask(id: 'w_f5', category: WheelCategory.fun, emoji: '🤪', colorValue: 0xFFFF5722,
      text: 'Bir süper kahraman pozu yap ve 5 saniye tut'),
    WheelTask(id: 'w_f6', category: WheelCategory.fun, emoji: '🤪', colorValue: 0xFFFF5722,
      text: 'Robot gibi yürü, 10 adım at'),
  ];
}
