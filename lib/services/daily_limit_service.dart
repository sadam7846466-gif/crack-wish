import 'package:shared_preferences/shared_preferences.dart';

enum FeatureType {
  cookie,
  tarot,
  dream,
  zodiac,
  mood,
  letter
}

class DailyLimitService {
  static const int MAX_LIMIT = 3; // 1 Free + 2 Ads

  static String _getTodayKey() {
    return DateTime.now().toIso8601String().split('T')[0];
  }

  static String _getPrefKey(FeatureType feature) {
    return 'usage_${feature.name}_${_getTodayKey()}';
  }

  /// Belirtilen özelliğin bugün kaç defa kullanıldığını döndürür (0, 1, 2, 3)
  static Future<int> getUsageCount(FeatureType feature) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_getPrefKey(feature)) ?? 0;
  }

  /// Kullanım hakkını 1 artırır.
  static Future<void> incrementUsage(FeatureType feature) async {
    final prefs = await SharedPreferences.getInstance();
    int current = await getUsageCount(feature);
    await prefs.setInt(_getPrefKey(feature), current + 1);
  }

  /// Kullanıcının özelliği ÜCRETSİZ kullanma hakkı var mı? (Günde 1 kez)
  static Future<bool> hasFreeUsage(FeatureType feature) async {
    int current = await getUsageCount(feature);
    return current < 1; // 0 ise hakkı var
  }

  /// Kullanıcının özelliği REKLAM İZLEYEREK kullanma hakkı var mı?
  static Future<bool> hasAdUsage(FeatureType feature) async {
    int current = await getUsageCount(feature);
    return current >= 1 && current < MAX_LIMIT; // 1 veya 2 kere kullandıysa
  }

  /// Kullanıcının bu özellik için günlük limiti tamamen doldu mu?
  static Future<bool> isLimitExhausted(FeatureType feature) async {
    int current = await getUsageCount(feature);
    return current >= MAX_LIMIT; // 3 veya daha fazlaysa
  }
}
