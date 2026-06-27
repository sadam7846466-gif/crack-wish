import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


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
  final String Function(BuildContext) textBuilder;
  final String emoji;
  final int colorValue;

  const WheelTask({
    required this.id,
    required this.category,
    required this.textBuilder,
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
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_c1),
    WheelTask(id: 'w_c2', category: WheelCategory.connection, emoji: '🫶', colorValue: 0xFFFF6B9D,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_c2),
    WheelTask(id: 'w_c3', category: WheelCategory.connection, emoji: '🫶', colorValue: 0xFFFF6B9D,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_c3),
    WheelTask(id: 'w_c4', category: WheelCategory.connection, emoji: '🫶', colorValue: 0xFFFF6B9D,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_c4),
    WheelTask(id: 'w_c5', category: WheelCategory.connection, emoji: '🫶', colorValue: 0xFFFF6B9D,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_c5),
    WheelTask(id: 'w_c6', category: WheelCategory.connection, emoji: '🫶', colorValue: 0xFFFF6B9D,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_c6),

    // 😊 Gülümseme
    WheelTask(id: 'w_s1', category: WheelCategory.smile, emoji: '😊', colorValue: 0xFFFFB347,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_s1),
    WheelTask(id: 'w_s2', category: WheelCategory.smile, emoji: '😊', colorValue: 0xFFFFB347,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_s2),
    WheelTask(id: 'w_s3', category: WheelCategory.smile, emoji: '😊', colorValue: 0xFFFFB347,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_s3),
    WheelTask(id: 'w_s4', category: WheelCategory.smile, emoji: '😊', colorValue: 0xFFFFB347,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_s4),
    WheelTask(id: 'w_s5', category: WheelCategory.smile, emoji: '😊', colorValue: 0xFFFFB347,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_s5),
    WheelTask(id: 'w_s6', category: WheelCategory.smile, emoji: '😊', colorValue: 0xFFFFB347,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_s6),

    // 🚶 Hareket
    WheelTask(id: 'w_m1', category: WheelCategory.movement, emoji: '🚶', colorValue: 0xFF5ED39C,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_m1),
    WheelTask(id: 'w_m2', category: WheelCategory.movement, emoji: '🚶', colorValue: 0xFF5ED39C,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_m2),
    WheelTask(id: 'w_m3', category: WheelCategory.movement, emoji: '🚶', colorValue: 0xFF5ED39C,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_m3),
    WheelTask(id: 'w_m4', category: WheelCategory.movement, emoji: '🚶', colorValue: 0xFF5ED39C,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_m4),
    WheelTask(id: 'w_m5', category: WheelCategory.movement, emoji: '🚶', colorValue: 0xFF5ED39C,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_m5),
    WheelTask(id: 'w_m6', category: WheelCategory.movement, emoji: '🚶', colorValue: 0xFF5ED39C,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_m6),

    // 🎵 Müzik
    WheelTask(id: 'w_mu1', category: WheelCategory.music, emoji: '🎵', colorValue: 0xFF9C6BFF,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_mu1),
    WheelTask(id: 'w_mu2', category: WheelCategory.music, emoji: '🎵', colorValue: 0xFF9C6BFF,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_mu2),
    WheelTask(id: 'w_mu3', category: WheelCategory.music, emoji: '🎵', colorValue: 0xFF9C6BFF,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_mu3),
    WheelTask(id: 'w_mu4', category: WheelCategory.music, emoji: '🎵', colorValue: 0xFF9C6BFF,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_mu4),
    WheelTask(id: 'w_mu5', category: WheelCategory.music, emoji: '🎵', colorValue: 0xFF9C6BFF,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_mu5),
    WheelTask(id: 'w_mu6', category: WheelCategory.music, emoji: '🎵', colorValue: 0xFF9C6BFF,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_mu6),

    // 🙏 Minnettarlık
    WheelTask(id: 'w_g1', category: WheelCategory.gratitude, emoji: '🙏', colorValue: 0xFF40C9FF,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_g1),
    WheelTask(id: 'w_g2', category: WheelCategory.gratitude, emoji: '🙏', colorValue: 0xFF40C9FF,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_g2),
    WheelTask(id: 'w_g3', category: WheelCategory.gratitude, emoji: '🙏', colorValue: 0xFF40C9FF,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_g3),
    WheelTask(id: 'w_g4', category: WheelCategory.gratitude, emoji: '🙏', colorValue: 0xFF40C9FF,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_g4),
    WheelTask(id: 'w_g5', category: WheelCategory.gratitude, emoji: '🙏', colorValue: 0xFF40C9FF,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_g5),
    WheelTask(id: 'w_g6', category: WheelCategory.gratitude, emoji: '🙏', colorValue: 0xFF40C9FF,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_g6),

    // 🤪 Eğlence
    WheelTask(id: 'w_f1', category: WheelCategory.fun, emoji: '🤪', colorValue: 0xFFFF5722,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_f1),
    WheelTask(id: 'w_f2', category: WheelCategory.fun, emoji: '🤪', colorValue: 0xFFFF5722,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_f2),
    WheelTask(id: 'w_f3', category: WheelCategory.fun, emoji: '🤪', colorValue: 0xFFFF5722,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_f3),
    WheelTask(id: 'w_f4', category: WheelCategory.fun, emoji: '🤪', colorValue: 0xFFFF5722,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_f4),
    WheelTask(id: 'w_f5', category: WheelCategory.fun, emoji: '🤪', colorValue: 0xFFFF5722,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_f5),
    WheelTask(id: 'w_f6', category: WheelCategory.fun, emoji: '🤪', colorValue: 0xFFFF5722,
      textBuilder: (context) => AppLocalizations.of(context)!.wheelTask_w_f6),
  ];
}
