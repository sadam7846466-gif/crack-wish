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
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final updateData = {
        'id': user.id, // Primary Key olarak eşleşecek
        'full_name': userName,
        'username': userHandle, // Supabase 'not-null' zorunluluğu
        'handle': userHandle,
        'avatar_url': avatarUrl,
        if (zodiacSign != null) 'zodiac_sign': zodiacSign,
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
}
