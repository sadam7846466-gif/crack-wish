import 'package:flutter/material.dart';

enum AppThemeKey { v25html }

class AppThemeData {
  final LinearGradient bgGradient;
  final Color cardBackground;
  final Color cardBackgroundAlt;

  const AppThemeData({
    required this.bgGradient,
    required this.cardBackground,
    required this.cardBackgroundAlt,
  });
}

class AppThemeController {
  static final ValueNotifier<AppThemeData> _notifier =
      ValueNotifier<AppThemeData>(_v25Html);

  static AppThemeData get current => _notifier.value;
  static ValueNotifier<AppThemeData> get notifier => _notifier;

  static void setTheme(AppThemeKey key) {
    _notifier.value = _v25Html;
  }
  // Buzlu bej + kırmızı benekli (mottled) tema
  static const AppThemeData _v25Html = AppThemeData(
    bgGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFEDD5CC), // Açık kırmızımsı bej
        Color(0xFFD9A898), // Sıcak kırmızı-bej
        Color(0xFFCC8878), // Terra cotta
        Color(0xFFBF7060), // Kırmızı
        Color(0xFFD49888), // Gül kırmızısı
        Color(0xFFC47868), // Sıcak kırmızı
        Color(0xFFD8A090), // Kırmızımsı bej
        Color(0xFFBB6858), // Derin kırmızı
      ],
      stops: [0.0, 0.14, 0.28, 0.42, 0.56, 0.70, 0.85, 1.0],
    ),
    cardBackground: Color(0x1AFFFFFF), // ~10% beyaz cam
    cardBackgroundAlt: Color(0x26FFFFFF), // ~15% beyaz cam
  );
}
