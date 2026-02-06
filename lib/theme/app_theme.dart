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
  // v25 HTML teması (teal -> gece mavisi)
  static const AppThemeData _v25Html = AppThemeData(
    bgGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF0A1A1F), // 0%
        Color(0xFF0D2129), // 25%
        Color(0xFF0F1F2A), // 40%
        Color(0xFF1A1A2E), // 60%
        Color(0xFF1E1E3A), // 75%
        Color(0xFF252550), // 100%
      ],
      stops: [0.0, 0.25, 0.4, 0.6, 0.75, 1.0],
    ),
    cardBackground: Color(0x1AFFFFFF), // ~10% beyaz cam
    cardBackgroundAlt: Color(0x26FFFFFF), // ~15% beyaz cam
  );
}
