import 'package:flutter/material.dart';

/// Her güncellemede sadece bu dosyayı değiştireceksin!
class SeasonConfig {
  static const String currentSeason = 'may'; // Haziran gelince 'june' yap

  static final List<Map<String, dynamic>> freeCookies = [
    {'id': 'free_1', 'name': 'Bahar Çiçeği', 'color': const Color(0xFFF48FB1)},
    {'id': 'free_2', 'name': 'Sabah Çiyi', 'color': const Color(0xFF81D4FA)},
    {'id': 'free_3', 'name': 'Papatya', 'color': const Color(0xFFFFF59D)},
    {'id': 'free_4', 'name': 'Şans Yoncası', 'color': const Color(0xFF8BC34A)},
    {'id': 'free_5', 'name': 'Güneşli Meltem', 'color': const Color(0xFFFFCC80)},
    {'id': 'free_6', 'name': 'Tatlı Kiraz', 'color': const Color(0xFFEF9A9A)},
  ];

  static final List<Map<String, dynamic>> paidCookies = [
    {'id': 'paid_1', 'name': 'Altın Boğa', 'color': const Color(0xFFFFD700)},
    {'id': 'paid_2', 'name': 'Sedef İnci', 'color': const Color(0xFFF8BBD0)},
    {'id': 'paid_3', 'name': 'Kraliyet Zümrüdü', 'color': const Color(0xFF2E7D32)},
    {'id': 'paid_4', 'name': 'Gece Orkidesi', 'color': const Color(0xFF311B92)},
    {'id': 'paid_5', 'name': 'Elmas Kelebek', 'color': const Color(0xFFB3E5FC)},
    {'id': 'paid_6', 'name': 'Gül Danteli', 'color': const Color(0xFFE91E63)},
    {'id': 'paid_7', 'name': 'İkizler Prizması', 'color': const Color(0xFF9575CD)},
    {'id': 'paid_8', 'name': 'Göksel Bahar', 'color': const Color(0xFF1A237E)},
  ];
}
