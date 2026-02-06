import 'package:flutter/material.dart';

class AppColors {
  // Ana Renkler
  static const Color primaryOrange = Color(0xFFFF8A3D);
  static const Color primaryOrangeDark = Color(0xFFFF6B35);
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color primaryTeal = Color(0xFF25F4EE);
  static const Color primaryPink = Color(0xFFEC4899);

  // Koyu v25 HTML arka plan tonları
  static const Color bgDark1 = Color(0xFF0A1A1F);
  static const Color bgDark2 = Color(0xFF0D2129);
  static const Color bgDark3 = Color(0xFF0F1F2A);
  static const Color bgDark4 = Color(0xFF1A1A2E);
  static const Color bgDark5 = Color(0xFF1E1E3A);
  static const Color bgDark6 = Color(0xFF252550);

  // Kart Renkleri (v25 cam yüzeyler)
  static const Color cardBackground = Color(0x1AFFFFFF); // ~10% beyaz cam
  static const Color cardBackgroundAlt = Color(0x26FFFFFF); // ~15% beyaz cam

  // Metin Renkleri (v25/dark uyumlu)
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textWhite70 = Color(0xB3FFFFFF);
  static const Color textWhite50 = Color(0x80FFFFFF);
  static const Color textWhite30 = Color(0x4DFFFFFF);
  static const Color textGrey = Color(0xFFB0B7C3); // v25 label tonu

  // Doğal yeşil vurgu
  static const Color bambooGreen = Color(0xFF6D8A5E);

  // Seçili Cookie Rengi
  static const Color selectedCookieGlow = Color(0xFFFF8A3D);

  // v25 HTML Gradient
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0A1A1F),
      Color(0xFF0D2129),
      Color(0xFF0F1F2A),
      Color(0xFF1A1A2E),
      Color(0xFF1E1E3A),
      Color(0xFF252550),
    ],
    stops: [0.0, 0.25, 0.4, 0.6, 0.75, 1.0],
  );

  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryOrange, primaryOrangeDark],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryPurple, primaryTeal],
  );
}
