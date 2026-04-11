import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'storage_service.dart';

/// Türkçe/İngilizce kart ismi → asset yolu eşleme tablosu (78 kart)
const Map<String, String> _cardNameToAsset = {
  // ── MAJOR ARCANA ──
  'Deli': 'assets/images/tarot/tarot/The_Fool.webp',
  'The Fool': 'assets/images/tarot/tarot/The_Fool.webp',
  'Büyücü': 'assets/images/tarot/tarot/The_Magician.webp',
  'The Magician': 'assets/images/tarot/tarot/The_Magician.webp',
  'Başrahibe': 'assets/images/tarot/tarot/The_High_Priestess.webp',
  'The High Priestess': 'assets/images/tarot/tarot/The_High_Priestess.webp',
  'İmparatoriçe': 'assets/images/tarot/tarot/The_Empress.webp',
  'The Empress': 'assets/images/tarot/tarot/The_Empress.webp',
  'İmparator': 'assets/images/tarot/tarot/The_Emperor.webp',
  'The Emperor': 'assets/images/tarot/tarot/The_Emperor.webp',
  'Aziz': 'assets/images/tarot/tarot/The_Hierophant.webp',
  'The Hierophant': 'assets/images/tarot/tarot/The_Hierophant.webp',
  'Aşıklar': 'assets/images/tarot/tarot/The_Lovers.webp',
  'The Lovers': 'assets/images/tarot/tarot/The_Lovers.webp',
  'Savaş Arabası': 'assets/images/tarot/tarot/The_Chariot.webp',
  'The Chariot': 'assets/images/tarot/tarot/The_Chariot.webp',
  'Güç': 'assets/images/tarot/tarot/Strength.webp',
  'Strength': 'assets/images/tarot/tarot/Strength.webp',
  'Ermiş': 'assets/images/tarot/tarot/The_Hermit.webp',
  'The Hermit': 'assets/images/tarot/tarot/The_Hermit.webp',
  'Kader Çarkı': 'assets/images/tarot/tarot/Wheel_of_Fortune.webp',
  'Wheel of Fortune': 'assets/images/tarot/tarot/Wheel_of_Fortune.webp',
  'Adalet': 'assets/images/tarot/tarot/Justice.webp',
  'Justice': 'assets/images/tarot/tarot/Justice.webp',
  'Asılan Adam': 'assets/images/tarot/tarot/The_Hanged_Man.webp',
  'The Hanged Man': 'assets/images/tarot/tarot/The_Hanged_Man.webp',
  'Ölüm': 'assets/images/tarot/tarot/Death.webp',
  'Death': 'assets/images/tarot/tarot/Death.webp',
  'Denge': 'assets/images/tarot/tarot/Temperance.webp',
  'Temperance': 'assets/images/tarot/tarot/Temperance.webp',
  'Şeytan': 'assets/images/tarot/tarot/The_Devil.webp',
  'The Devil': 'assets/images/tarot/tarot/The_Devil.webp',
  'Kule': 'assets/images/tarot/tarot/The_Tower.webp',
  'The Tower': 'assets/images/tarot/tarot/The_Tower.webp',
  'Yıldız': 'assets/images/tarot/tarot/The_Star.webp',
  'The Star': 'assets/images/tarot/tarot/The_Star.webp',
  'Ay': 'assets/images/tarot/tarot/The_Moon.webp',
  'The Moon': 'assets/images/tarot/tarot/The_Moon.webp',
  'Güneş': 'assets/images/tarot/tarot/The_Sun.webp',
  'The Sun': 'assets/images/tarot/tarot/The_Sun.webp',
  'Yargı': 'assets/images/tarot/tarot/Judgement.webp',
  'Judgement': 'assets/images/tarot/tarot/Judgement.webp',
  'Dünya': 'assets/images/tarot/tarot/The_World.webp',
  'The World': 'assets/images/tarot/tarot/The_World.webp',
  // ── CUPS ──
  'Kâselerin Ası': 'assets/images/tarot/tarot/Ace_of_Cups.webp',
  'Kâselerin İkisi': 'assets/images/tarot/tarot/Two_of_Cups.webp',
  'Kâselerin Üçü': 'assets/images/tarot/tarot/Three_of_Cups.webp',
  'Kâselerin Dörtü': 'assets/images/tarot/tarot/Four_of_Cups.webp',
  'Kâselerin Beşi': 'assets/images/tarot/tarot/Five_of_Cups.webp',
  'Kâselerin Altısı': 'assets/images/tarot/tarot/Six_of_Cups.webp',
  'Kâselerin Yedisi': 'assets/images/tarot/tarot/Seven_of_Cups.webp',
  'Kâselerin Sekizi': 'assets/images/tarot/tarot/Eight_of_Cups.webp',
  'Kâselerin Dokuzu': 'assets/images/tarot/tarot/Nine_of_Cups.webp',
  'Kâselerin Onu': 'assets/images/tarot/tarot/Ten_of_Cups.webp',
  'Kâselerin Uşağı': 'assets/images/tarot/tarot/Page_of_Cups.webp',
  'Kâselerin Şövalyesi': 'assets/images/tarot/tarot/Knight_of_Cups.webp',
  'Kâselerin Kraliçesi': 'assets/images/tarot/tarot/Queen_of_Cups.webp',
  'Kâselerin Kralı': 'assets/images/tarot/tarot/King_of_Cups.webp',
  // ── WANDS ──
  'Asaların Ası': 'assets/images/tarot/tarot/Ace_of_Wands.webp',
  'Asaların İkisi': 'assets/images/tarot/tarot/Two_of_Wands.webp',
  'Asaların Üçü': 'assets/images/tarot/tarot/Three_of_Wands.webp',
  'Asaların Dörtü': 'assets/images/tarot/tarot/Four_of_Wands.webp',
  'Asaların Beşi': 'assets/images/tarot/tarot/Five_of_Wands.webp',
  'Asaların Altısı': 'assets/images/tarot/tarot/Six_of_Wands.webp',
  'Asaların Yedisi': 'assets/images/tarot/tarot/Seven_of_Wands.webp',
  'Asaların Sekizi': 'assets/images/tarot/tarot/Eight_of_Wands.webp',
  'Asaların Dokuzu': 'assets/images/tarot/tarot/Nine_of_Wands.webp',
  'Asaların Onu': 'assets/images/tarot/tarot/Ten_of_Wands.webp',
  'Asaların Uşağı': 'assets/images/tarot/tarot/Page_of_Wands.webp',
  'Asaların Şövalyesi': 'assets/images/tarot/tarot/Knight_of_Wands.webp',
  'Asaların Kraliçesi': 'assets/images/tarot/tarot/Queen_of_Wands.webp',
  'Asaların Kralı': 'assets/images/tarot/tarot/King_of_Wands.webp',
  // ── SWORDS ──
  'Kılıçların Ası': 'assets/images/tarot/tarot/Ace_of_Swords.webp',
  'Kılıçların İkisi': 'assets/images/tarot/tarot/Two_of_Swords.webp',
  'Kılıçların Üçü': 'assets/images/tarot/tarot/Three_of_Swords.webp',
  'Kılıçların Dörtü': 'assets/images/tarot/tarot/Four_of_Swords.webp',
  'Kılıçların Beşi': 'assets/images/tarot/tarot/Five_of_Swords.webp',
  'Kılıçların Altısı': 'assets/images/tarot/tarot/Six_of_Swords.webp',
  'Kılıçların Yedisi': 'assets/images/tarot/tarot/Seven_of_Swords.webp',
  'Kılıçların Sekizi': 'assets/images/tarot/tarot/Eight_of_Swords.webp',
  'Kılıçların Dokuzu': 'assets/images/tarot/tarot/Nine_of_Swords.webp',
  'Kılıçların Onu': 'assets/images/tarot/tarot/Ten_of_Swords.webp',
  'Kılıçların Uşağı': 'assets/images/tarot/tarot/Page_of_Swords.webp',
  'Kılıçların Şövalyesi': 'assets/images/tarot/tarot/Knight_of_Swords.webp',
  'Kılıçların Kraliçesi': 'assets/images/tarot/tarot/Queen_of_Swords.webp',
  'Kılıçların Kralı': 'assets/images/tarot/tarot/King_of_Swords.webp',
  // ── PENTACLES ──
  'Sikkelerin Ası': 'assets/images/tarot/tarot/Ace_of_Pentacles.webp',
  'Sikkelerin İkisi': 'assets/images/tarot/tarot/Two_of_Pentacles.webp',
  'Sikkelerin Üçü': 'assets/images/tarot/tarot/Three_of_Pentacles.webp',
  'Sikkelerin Dörtü': 'assets/images/tarot/tarot/Four_of_Pentacles.webp',
  'Sikkelerin Beşi': 'assets/images/tarot/tarot/Five_of_Pentacles.webp',
  'Sikkelerin Altısı': 'assets/images/tarot/tarot/Six_of_Pentacles.webp',
  'Sikkelerin Yedisi': 'assets/images/tarot/tarot/Seven_of_Pentacles.webp',
  'Sikkelerin Sekizi': 'assets/images/tarot/tarot/Eight_of_Pentacles.webp',
  'Sikkelerin Dokuzu': 'assets/images/tarot/tarot/Nine_of_Pentacles.webp',
  'Sikkelerin Onu': 'assets/images/tarot/tarot/Ten_of_Pentacles.webp',
  'Sikkelerin Uşağı': 'assets/images/tarot/tarot/Page_of_Pentacles.webp',
  'Sikkelerin Şövalyesi': 'assets/images/tarot/tarot/Knight_of_Pentacles.webp',
  'Sikkelerin Kraliçesi': 'assets/images/tarot/tarot/Queen_of_Pentacles.webp',
  'Sikkelerin Kralı': 'assets/images/tarot/tarot/King_of_Pentacles.webp',
};

/// Kart isminden asset yolunu çözer (eski kayıtlar için de çalışır)
String resolveCardAsset(String cardName, String savedAsset) {
  if (savedAsset.isNotEmpty) return savedAsset;
  return _cardNameToAsset[cardName] ?? '';
}

/// Tüm 78 kartın benzersiz asset yollarını döner (grid haritası için)
List<String> getAllCardAssets() {
  return _cardNameToAsset.values.toSet().toList()..sort();
}

class TarotLog {
  final String cardName;
  final String cardAsset; // Kart görseli yolu: 'assets/images/tarot/tarot/The_Moon.webp'
  final String category;
  final String outcome;
  final DateTime date;

  TarotLog({
    required this.cardName,
    this.cardAsset = '',
    required this.category,
    required this.outcome,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'cardName': cardName,
      'cardAsset': cardAsset,
      'category': category,
      'outcome': outcome,
      'date': date.toIso8601String(),
    };
  }

  factory TarotLog.fromMap(Map<String, dynamic> map) {
    return TarotLog(
      cardName: map['cardName'] ?? '',
      cardAsset: map['cardAsset'] ?? '',
      category: map['category'] ?? '',
      outcome: map['outcome'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class SignatureResult {
  final String cardName;
  final String cardAsset; // Doğrudan asset yolu
  final String periodLabel; // "Son 3 Gün", "Son 7 Gün", "Son 1 Ay", "Tüm Zamanlar"
  
  SignatureResult({required this.cardName, required this.cardAsset, required this.periodLabel});
}

class UserStatsService {
  static const String _tarotHistoryKey = 'tarot_history_logs_v1';

  /// Yeni bir Tarot falını yerel belleğe (arşive) ekler
  static Future<void> addTarotReading(String cardName, String category, String outcome, {String cardAsset = ''}) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> currentLogsRaw = prefs.getStringList(_tarotHistoryKey) ?? [];
    
    final newLog = TarotLog(
      cardName: cardName,
      cardAsset: cardAsset,
      category: category,
      outcome: outcome,
      date: DateTime.now(),
    );

    currentLogsRaw.add(json.encode(newLog.toMap()));
    await prefs.setStringList(_tarotHistoryKey, currentLogsRaw);
    
    // Aura puanı (seviye) için global sayacı artır
    await StorageService.incrementTotalTarots();
    
    // YENİ SİSTEM: Kullanıcının toplaması için Bekleyen Aura Havuzuna (Vault) ekle
    final isPremium = prefs.getBool('is_premium_test_mode') ?? false;
    final int pts = 2 * (isPremium ? 3 : 1);
    await StorageService.addPendingAura('fal', pts);
  }

  /// Tüm Tarot geçmişini zaman sırasına göre (en yeni en üstte) döner
  static Future<List<TarotLog>> getTarotHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> currentLogsRaw = prefs.getStringList(_tarotHistoryKey) ?? [];
    
    final logs = currentLogsRaw.map((raw) => TarotLog.fromMap(json.decode(raw))).toList();
    logs.sort((a, b) => b.date.compareTo(a.date)); // En yeniden eskiye
    return logs;
  }

  /// ══════════════════════════════════════════════
  /// AKıLLI KADEMELİ İMZA KARTI SİSTEMİ
  /// ══════════════════════════════════════════════
  /// Öncelik sırası: 3 Gün → 7 Gün → 30 Gün → Tüm Zamanlar
  /// Her kademede en az 2 fal gerekir. Hiç yoksa null döner (GİZLİ).
  static Future<SignatureResult?> getSignatureCard() async {
    final logs = await getTarotHistory();
    if (logs.isEmpty) return null;

    final now = DateTime.now();
    
    // Kademe kademe kontrol et
    final periods = [
      (Duration(days: 3), 'Son 3 Gün'),
      (Duration(days: 7), 'Son 7 Gün'),
      (Duration(days: 30), 'Son 1 Ay'),
    ];

    for (final (duration, label) in periods) {
      final cutoff = now.subtract(duration);
      final filtered = logs.where((l) => l.date.isAfter(cutoff)).toList();
      
      if (filtered.length >= 2) {
        final result = _findMostFrequent(filtered);
        if (result != null) return SignatureResult(cardName: result.$1, cardAsset: result.$2, periodLabel: label);
      }
    }

    // Hiçbir dönemde yeterli veri yoksa → Tüm zamanlar (en az 2 fal)
    if (logs.length >= 2) {
      final result = _findMostFrequent(logs);
      if (result != null) return SignatureResult(cardName: result.$1, cardAsset: result.$2, periodLabel: 'Tüm Zamanlar');
    }

    // Tek bir fal bile var ama minimum 2'ye ulaşamamış → o kartı göster
    if (logs.isNotEmpty) {
      return SignatureResult(cardName: logs.first.cardName, cardAsset: logs.first.cardAsset, periodLabel: 'Son Falın');
    }

    return null; // Hiç veri yok → GİZLİ
  }

  /// Frekans analizi: Verilen log listesinden en çok tekrar eden kartı bulur
  /// Döner: (cardName, cardAsset) veya null
  static (String, String)? _findMostFrequent(List<TarotLog> logs) {
    final freq = <String, int>{};
    final assetMap = <String, String>{}; // cardName → cardAsset
    for (var log in logs) {
      freq[log.cardName] = (freq[log.cardName] ?? 0) + 1;
      if (log.cardAsset.isNotEmpty) assetMap[log.cardName] = log.cardAsset;
    }
    
    String? best;
    int maxCount = 0;
    freq.forEach((card, count) {
      if (count > maxCount) {
        maxCount = count;
        best = card;
      }
    });
    if (best == null) return null;
    return (best!, assetMap[best!] ?? '');
  }

  /// Toplam kaç kere Tarot falına bakıldığını döner (Tüm zamanlar)
  static Future<int> getTotalTarotReadings() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> currentLogsRaw = prefs.getStringList(_tarotHistoryKey) ?? [];
    return currentLogsRaw.length;
  }

  /// Son N tane fal kaydını döner (varsayılan 3)
  static Future<List<TarotLog>> getRecentReadings({int count = 3}) async {
    final logs = await getTarotHistory();
    return logs.take(count).toList();
  }

  /// Keşfedilen benzersiz kart sayısını ve listesini döner (78 üzerinden)
  static Future<Set<String>> getDiscoveredCards() async {
    final logs = await getTarotHistory();
    final discovered = <String>{};
    for (var log in logs) {
      final asset = resolveCardAsset(log.cardName, log.cardAsset);
      if (asset.isNotEmpty) discovered.add(asset);
    }
    return discovered;
  }

  /// ══════════════════════════════════════════════
  /// KOZMİK PROFİL ANALİTİĞİ
  /// ══════════════════════════════════════════════
  static Future<TarotProfile?> getTarotProfile() async {
    final logs = await getTarotHistory();
    if (logs.isEmpty) return null;

    // ── Element Analizi (Kart Suit'lerine göre) ──
    // Cups=Su, Wands=Ateş, Swords=Hava, Pentacles=Toprak, Major=Ruh
    int su = 0, ates = 0, hava = 0, toprak = 0, ruh = 0;
    
    for (var log in logs) {
      final asset = resolveCardAsset(log.cardName, log.cardAsset);
      if (asset.contains('Cups')) { su++; }
      else if (asset.contains('Wands')) { ates++; }
      else if (asset.contains('Swords')) { hava++; }
      else if (asset.contains('Pentacles')) { toprak++; }
      else { ruh++; } // Major Arcana
    }

    // Dominant element bul
    final elements = {'Su': su, 'Ateş': ates, 'Hava': hava, 'Toprak': toprak, 'Ruh': ruh};
    final sorted = elements.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final dominantElement = sorted.first.key;
    
    // ── En çok bakılan kategori ──
    final catFreq = <String, int>{};
    for (var log in logs) {
      catFreq[log.category] = (catFreq[log.category] ?? 0) + 1;
    }
    String topCategory = 'Genel';
    int topCatCount = 0;
    catFreq.forEach((cat, count) {
      if (count > topCatCount) {
        topCatCount = count;
        topCategory = cat;
      }
    });

    // ── Büyük/Küçük Arkana oranı ──  
    final majorCount = ruh;
    final majorPercent = logs.isNotEmpty ? ((majorCount / logs.length) * 100).round() : 0;

    return TarotProfile(
      totalReadings: logs.length,
      dominantElement: dominantElement,
      dominantEmoji: _elementEmoji(dominantElement),
      favoriteCategory: topCategory,
      majorArcanaPercent: majorPercent,
      elementBreakdown: elements,
    );
  }

  static String _elementEmoji(String element) {
    switch (element) {
      case 'Ateş': return '🔥';
      case 'Su': return '💧';
      case 'Hava': return '🌬️';
      case 'Toprak': return '🌿';
      case 'Ruh': return '✨';
      default: return '🔮';
    }
  }
}

class TarotProfile {
  final int totalReadings;
  final String dominantElement;
  final String dominantEmoji;
  final String favoriteCategory;
  final int majorArcanaPercent;
  final Map<String, int> elementBreakdown;

  TarotProfile({
    required this.totalReadings,
    required this.dominantElement,
    required this.dominantEmoji,
    required this.favoriteCategory,
    required this.majorArcanaPercent,
    required this.elementBreakdown,
  });
}
