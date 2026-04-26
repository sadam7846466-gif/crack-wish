import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CloudSyncService {
  static final CloudSyncService _instance = CloudSyncService._internal();
  factory CloudSyncService() => _instance;
  CloudSyncService._internal();

  final _supabase = Supabase.instance.client;

  // Buluta yedeklenmeyecek Cihaza Özel Anahtarlar (Sadece bu telefonda kalması gerekenler)
  final List<String> _ignoredKeys = [
    'install_id',
    'install_date',
    'app_locale', // Kullanıcı yeni telefonunu İngilizce kullanmak isteyebilir
  ];

  /// 1. TELEFONDAN -> BULUTA (Backup)
  /// Bu fonksiyon çağrıldığında o anki tüm Rüyalar, Ruh Taşları, Ayarlar Supabase Kasasına yüklenir.
  Future<void> pushToCloud() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return; // Oturum açılmamışsa yedekleme yapılamaz.

    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      Map<String, dynamic> cloudData = {};

      for (String key in allKeys) {
        if (_ignoredKeys.contains(key)) continue;
        
        // Veri tipine göre çekirdekten okuma
        var value = prefs.get(key);
        if (value != null) {
          cloudData[key] = value;
        }
      }

      // Supabase'e UPSERT (Eğer daha önce kasa yoksa yaratır, varsa günceller)
      await _supabase.from('user_cloud_saves').upsert({
        'id': user.id,
        'cloud_data': cloudData,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });

      debugPrint("☁️ [CloudSync] Tüm veriler Supabase Kasasına BAŞARIYLA YEDEKLENDİ!");
    } catch (e) {
      debugPrint("☁️ [CloudSync Error] Buluta yedekleme başarısız: \$e");
    }
  }

  /// 2. BULUTTAN -> TELEFONA (Restore)
  /// Yeni telefona geçildiğinde veya hesap kurtarıldığında buluttaki veriyi telefona gömer.
  Future<void> pullFromCloud() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await _supabase
          .from('user_cloud_saves')
          .select('cloud_data')
          .eq('id', user.id)
          .maybeSingle();

      // Kasada kayıt yoksa, temiz bir kurulum demektir.
      if (response == null || response['cloud_data'] == null) {
        debugPrint("☁️ [CloudSync] Bulutta kayıt bulunamadı (Yeni hesap).");
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> cloudData = response['cloud_data'] as Map<String, dynamic>;

      for (var entry in cloudData.entries) {
        String key = entry.key;
        dynamic value = entry.value;

        // Veri tiplerini tanıyarak doğrudan SharedPreferences'a yaz
        if (value is String) {
          await prefs.setString(key, value);
        } else if (value is int) {
          await prefs.setInt(key, value);
        } else if (value is double) {
          await prefs.setDouble(key, value);
        } else if (value is bool) {
          await prefs.setBool(key, value);
        } else if (value is List) {
          // JSON listeleri genellikle List<dynamic> döner, List<String> yapmamız lazım.
          List<String> stringList = value.map((e) => e.toString()).toList();
          await prefs.setStringList(key, stringList);
        }
      }

      debugPrint("☁️ [CloudSync] Eski günlerin Rüyaları ve Ruh Taşları BAŞARIYLA GERİ YÜKLENDİ!");
    } catch (e) {
      debugPrint("☁️ [CloudSync Error] Buluttan veri çekme başarısız: \$e");
    }
  }
}
