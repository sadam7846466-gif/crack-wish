import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class ProfileSyncService {
  static final ProfileSyncService _instance = ProfileSyncService._internal();
  factory ProfileSyncService() => _instance;
  ProfileSyncService._internal();

  final _supabase = Supabase.instance.client;

  /// Kullanıcı adı (handle) benzersiz mi kontrol et
  /// true = kullanılabilir, false = başkası almış
  Future<bool> isHandleAvailable(String handle) async {
    try {
      final cleaned = handle.toLowerCase().trim();
      if (cleaned.isEmpty) return false;
      
      // @ işaretini ekle/düzelt
      final normalized = cleaned.startsWith('@') ? cleaned : '@$cleaned';
      
      final user = _supabase.auth.currentUser;
      
      // Supabase'den bu handle'ı kullanan birini ara
      final result = await _supabase
          .from('profiles')
          .select('id')
          .eq('handle', normalized)
          .maybeSingle();
      
      // Sonuç yoksa → handle müsait
      if (result == null) return true;
      
      // Sonuç kendi kullanıcımızsa → handle müsait (kendi handle'ını değiştirmiyor)
      if (user != null && result['id'] == user.id) return true;
      
      // Başka biri almış
      return false;
    } catch (e) {
      debugPrint('Handle kontrol hatası: $e');
      // Hata durumunda geçişe izin ver (offline durumlar için)
      return true;
    }
  }

  /// Profil fotoğrafını Supabase 'avatars' storage klasörüne güvenle yükler
  /// Başarılı olursa herkese açık URL'sini (publicUrl) döndürür.
  Future<String?> uploadAvatar(File imageFile) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('UploadAvatar Error: Kullanıcı oturum açmamış.');
        return null;
      }

      final userId = user.id;
      final fileExtension = p.extension(imageFile.path).toLowerCase();
      // Örn: avatars/df4a-1.../profile.jpg
      final fileName = '$userId/profile_${DateTime.now().millisecondsSinceEpoch}$fileExtension';

      // Eski resmi (eğer varsa) üstüne yazmamak veya sildiğimizden emin olmak için yol:
      // (Supabase Storage upsert: true kullanılarak üzerine yazdırılır)
      await _supabase.storage.from('avatars').upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // Başarılı yükleme sonrası public URL'i alırız
      final publicUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);
      debugPrint('Avatar Yüklendi! Public URL: $publicUrl');
      
      return publicUrl;
    } catch (e) {
      debugPrint('Supabase Upload Avatar Hatası: $e');
      return null;
    }
  }

  /// Profil Verilerini Supabase 'profiles' tablosuna eşitler (Sync)
  /// Bu sayede, Baykuş Postası gönderdiğimizde diğerleri bizi bu güncel isim/foto ile görür.
  Future<dynamic> syncProfileData({
    required String userName,
    required String userHandle,
    required String avatarUrl,
    String? zodiacSign,
    String? birthDate,
    // Onboarding profil bilgileri
    String? birthTime,
    String? lifeFocus,
    String? relationshipStatus,
    String? dreamFrequency,
    String? sleepPattern,
    String? gender,
    String? birthPlace,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      // ÖNEMLİ: Sadece Supabase 'profiles' tablosunda MEVCUT olan kolonlar gönderilmeli!
      // birth_time, life_focus, relationship_status, dream_frequency, sleep_pattern,
      // gender, birth_place kolonları henüz DB'de YOK — eklenince buraya dahil edilecek.
      // Bu alanlar şimdilik yalnızca cihaz hafızasında (SharedPreferences) saklanıyor.
      final updateData = {
        'id': user.id, // Primary Key olarak eşleşecek
        'full_name': userName,
        'username': userHandle, // Supabase 'not-null' zorunluluğu
        'handle': userHandle,
        'avatar_url': avatarUrl,
        if (zodiacSign != null) 'zodiac_sign': zodiacSign,
        if (birthDate != null) 'birth_date': birthDate,
      };

      // 'profiles' tablosuna upsert işlemi (varsa günceller, yoksa yaratır)
      await _supabase.from('profiles').upsert(updateData);
      
      debugPrint('Profil Senkronizasyonu Başarılı!');
      return true;
    } catch (e) {
      debugPrint('Supabase Profile Sync Hatası: $e');
      return e.toString();
    }
  }

  /// Kullanıcının hesap bakiyesini ve TÜM istatistiklerini Supabase'e canlı yedekler
  Future<void> syncEconomyData({
    required int aura, 
    required int soulStones,
    int? totalCookies,
    int? totalTarots,
    int? totalDreams,
    int? totalCoffee,
    int? streakDays,
    int? totalFriends,
    int? totalLetters,
    int? totalReferrals,
    int? uniqueCookies,
    List<String>? unlockedAchievements,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final Map<String, dynamic> updateData = {
        'aura_points': aura,
        'soul_stones': soulStones,
      };

      if (totalCookies != null) updateData['total_cookies'] = totalCookies;
      if (totalTarots != null) updateData['total_tarots'] = totalTarots;
      if (totalDreams != null) updateData['total_dreams'] = totalDreams;
      if (totalCoffee != null) updateData['total_coffee'] = totalCoffee;
      if (streakDays != null) updateData['streak_days'] = streakDays;
      
      if (totalFriends != null) updateData['total_friends'] = totalFriends;
      if (totalLetters != null) updateData['total_letters_sent'] = totalLetters;
      if (totalReferrals != null) updateData['total_referrals'] = totalReferrals;
      if (uniqueCookies != null) updateData['unique_cookies'] = uniqueCookies;
      if (unlockedAchievements != null) updateData['unlocked_achievements'] = unlockedAchievements;

      await _supabase.from('profiles').update(updateData).eq('id', user.id);
      
      debugPrint('☁️ Tüm Veriler Yedeklendi: $aura Aura, $soulStones RT');
    } catch (e) {
      debugPrint('☁️ Veri Yedeklenirken Hata: $e');
    }
  }

  /// Elite (Premium) durumunu Supabase'e senkronize eder
  /// Böylece Supabase panelinden Premium kullanıcıları görebilirsin
  Future<void> syncEliteStatus(bool isElite) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final Map<String, dynamic> updateData = {
        'is_elite': isElite,
      };

      // İlk kez Elite oluyorsa tarihi kaydet
      if (isElite) {
        updateData['elite_since'] = DateTime.now().toIso8601String();
      }

      await _supabase.from('profiles').update(updateData).eq('id', user.id);
      
      debugPrint('👑 Elite durum güncellendi: $isElite');
    } catch (e) {
      debugPrint('👑 Elite senkronizasyon hatası: $e');
    }
  }

  /// Elite durumunu Supabase'den çeker
  Future<bool> fetchEliteStatus() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final data = await _supabase
          .from('profiles')
          .select('is_elite')
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        return (data['is_elite'] ?? false) as bool;
      }
    } catch (e) {
      debugPrint('👑 Elite durumu çekilirken hata: $e');
    }
    return false;
  }

  /// Başka cihaza geçildiğinde veya silinip yüklendiğinde eski bakiyeyi buluttan çeker
  Future<Map<String, int>?> fetchEconomyData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final data = await _supabase
          .from('profiles')
          .select('aura_points, soul_stones')
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        return {
          'aura': (data['aura_points'] ?? 0) as int,
          'stones': (data['soul_stones'] ?? 0) as int,
        };
      }
    } catch (e) {
      debugPrint('☁️ Ekonomi Buluttan Çekilirken Hata: $e');
    }
    return null;
  }

  /// Satın alınan/hediye gelen Premium Kurabiye envanterini buluta senkronize eder (jsonb formatında)
  Future<void> syncCookieInventoryToCloud(Map<String, int> inventory) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('profiles').update({
        'cookie_inventory': inventory,
      }).eq('id', user.id);
      
      debugPrint('☁️ Kurabiye Envanteri Buluta Yedeklendi: $inventory');
    } catch (e) {
      debugPrint('☁️ Kurabiye Envanteri Senkronizasyon Hatası: $e');
    }
  }

  /// Buluttaki Kurabiye envanterini (jsonb) locale çekmek için
  Future<Map<String, int>?> fetchCookieInventory() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final data = await _supabase
          .from('profiles')
          .select('cookie_inventory')
          .eq('id', user.id)
          .maybeSingle();

      if (data != null && data['cookie_inventory'] != null) {
        final Map<String, dynamic> rawMap = data['cookie_inventory'];
        final Map<String, int> inventory = {};
        rawMap.forEach((key, value) {
          if (value is int) {
            inventory[key] = value;
          }
        });
        return inventory;
      }
    } catch (e) {
      debugPrint('☁️ Kurabiye Envanteri Buluttan Çekilirken Hata: $e');
    }
    return null;
  }

  /// Profil Vitrini (Showcase) Kurabiyelerini buluta senkronize eder
  Future<void> syncPinnedCookiesToCloud(List<String> cookieIds) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // Sadece ilk 3 tanesine izin ver
      final safeList = cookieIds.take(3).toList();
      await _supabase.from('profiles').update({
        'pinned_cookies': safeList,
      }).eq('id', user.id);
      
      debugPrint('☁️ Vitrin Buluta Yedeklendi: $safeList');
    } catch (e) {
      debugPrint('☁️ Vitrin Senkronizasyon Hatası: $e');
    }
  }

  /// Buluttaki vitrin kurabiyelerini locale çeker
  Future<List<String>?> fetchPinnedCookies() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final data = await _supabase
          .from('profiles')
          .select('pinned_cookies')
          .eq('id', user.id)
          .maybeSingle();

      if (data != null && data['pinned_cookies'] != null) {
        return List<String>.from(data['pinned_cookies']);
      }
    } catch (e) {
      debugPrint('☁️ Vitrin Buluttan Çekilirken Hata: $e');
    }
    return null;
  }
}
