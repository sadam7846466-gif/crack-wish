import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTheme {
  /// Emoji fallback'li TextTheme oluştur
  /// Google Fonts emoji glyph içermediği için Apple Color Emoji'yi fallback olarak ekliyoruz
  static TextTheme _withEmojiFallback(TextTheme theme) {
    const fallback = ['Apple Color Emoji', 'Segoe UI Emoji', 'Noto Color Emoji'];
    return theme.copyWith(
      displayLarge: theme.displayLarge?.copyWith(fontFamilyFallback: fallback),
      displayMedium: theme.displayMedium?.copyWith(fontFamilyFallback: fallback),
      displaySmall: theme.displaySmall?.copyWith(fontFamilyFallback: fallback),
      headlineLarge: theme.headlineLarge?.copyWith(fontFamilyFallback: fallback),
      headlineMedium: theme.headlineMedium?.copyWith(fontFamilyFallback: fallback),
      headlineSmall: theme.headlineSmall?.copyWith(fontFamilyFallback: fallback),
      titleLarge: theme.titleLarge?.copyWith(fontFamilyFallback: fallback),
      titleMedium: theme.titleMedium?.copyWith(fontFamilyFallback: fallback),
      titleSmall: theme.titleSmall?.copyWith(fontFamilyFallback: fallback),
      bodyLarge: theme.bodyLarge?.copyWith(fontFamilyFallback: fallback),
      bodyMedium: theme.bodyMedium?.copyWith(fontFamilyFallback: fallback),
      bodySmall: theme.bodySmall?.copyWith(fontFamilyFallback: fallback),
      labelLarge: theme.labelLarge?.copyWith(fontFamilyFallback: fallback),
      labelMedium: theme.labelMedium?.copyWith(fontFamilyFallback: fallback),
      labelSmall: theme.labelSmall?.copyWith(fontFamilyFallback: fallback),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryOrange,
        secondary: AppColors.primaryPurple,
        surface: AppColors.bgDark4,
      ),
      textTheme: _withEmojiFallback(
        GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme.apply(
            bodyColor: AppColors.textWhite,
            displayColor: AppColors.textWhite,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textWhite),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F5F7),
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryOrange,
        secondary: AppColors.primaryPurple,
        surface: Colors.white,
      ),
      textTheme: _withEmojiFallback(
        GoogleFonts.interTextTheme(
          ThemeData.light().textTheme.apply(
            bodyColor: const Color(0xFF1D1D1F),
            displayColor: const Color(0xFF1D1D1F),
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF1D1D1F)),
      ),
    );
  }
}
