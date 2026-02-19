import 'package:flutter/material.dart';

class AppColors {
  // Ana Renkler — sıcak glassmorphism paleti
  static const Color primaryOrange = Color(0xFFFF8A3D);
  static const Color primaryOrangeDark = Color(0xFFF46B2F);
  static const Color primaryAmber = Color(0xFFFFAB5E);
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color primaryTeal = Color(0xFF25F4EE);
  static const Color primaryPink = Color(0xFFEC4899);

  // Gün batımı kırmızısı arka plan tonları
  static const Color bgDark1 = Color(0xFF2A0A10);  // derin kırmızı gece
  static const Color bgDark2 = Color(0xFF4A1018);  // koyu crimson
  static const Color bgDark3 = Color(0xFF7A1A22);  // canlı kırmızı
  static const Color bgDark4 = Color(0xFFB02030);  // gün batımı kırmızısı
  static const Color bgDark5 = Color(0xFF6A151E);  // sıcak kiraz
  static const Color bgDark6 = Color(0xFF3D0C14);  // derin şarap

  // Kart Renkleri — glassmorphism cam yüzeyler (daha belirgin)
  static const Color cardBackground = Color(0x26FFFFFF);     // ~15% beyaz cam
  static const Color cardBackgroundAlt = Color(0x33FFFFFF);   // ~20% beyaz cam
  static const Color cardBackgroundStrong = Color(0x40FFFFFF); // ~25% beyaz cam

  // Glassmorphism border renkleri
  static const Color glassBorder = Color(0x40FFFFFF);       // ~25% beyaz
  static const Color glassBorderLight = Color(0x33FFFFFF);  // ~20% beyaz
  static const Color glassBorderSubtle = Color(0x1AFFFFFF); // ~10% beyaz

  // Metin Renkleri
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textWhite70 = Color(0xB3FFFFFF);
  static const Color textWhite50 = Color(0x80FFFFFF);
  static const Color textWhite30 = Color(0x4DFFFFFF);
  static const Color textGrey = Color(0xFFD4C4B0); // sıcak gri-krem

  // Doğal yeşil vurgu
  static const Color bambooGreen = Color(0xFF6D8A5E);

  // Seçili Cookie Rengi
  static const Color selectedCookieGlow = Color(0xFFFF8A3D);

  // Gün batımı kırmızısı Arka Plan Gradienti
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF2A0A10),  // derin kırmızı gece
      Color(0xFF5A1220),  // koyu crimson
      Color(0xFF8C1E2A),  // canlı kırmızı
      Color(0xFFB02030),  // gün batımı kırmızısı — en parlak nokta
      Color(0xFF6A151E),  // sıcak kiraz
      Color(0xFF3D0C14),  // derin şarap
    ],
    stops: [0.0, 0.2, 0.4, 0.55, 0.75, 1.0],
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

  // Glassmorphism kart iç gradienti
  static LinearGradient get glassCardGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withOpacity(0.18),
      Colors.white.withOpacity(0.08),
    ],
  );

  // Sıcak vurgu gradienti (kart hover/accent)
  static LinearGradient get warmAccentGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryOrange.withOpacity(0.25),
      primaryAmber.withOpacity(0.10),
    ],
  );
}
