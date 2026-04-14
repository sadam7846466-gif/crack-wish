import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class ProfileSyncService {
  static final ProfileSyncService _instance = ProfileSyncService._internal();
  factory ProfileSyncService() => _instance;
  ProfileSyncService._internal();

  final _supabase = Supabase.instance.client;

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
      final fileName = '\$userId/profile_\${DateTime.now().millisecondsSinceEpoch}\$fileExtension';

      // Eski resmi (eğer varsa) üstüne yazmamak veya sildiğimizden emin olmak için yol:
      // (Supabase Storage upsert: true kullanılarak üzerine yazdırılır)
      await _supabase.storage.from('avatars').upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // Başarılı yükleme sonrası public URL'i alırız
      final publicUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);
      debugPrint('Avatar Yüklendi! Public URL: \$publicUrl');
      
      return publicUrl;
    } catch (e) {
      debugPrint('Supabase Upload Avatar Hatası: \$e');
      return null;
    }
  }

  /// Profil Verilerini Supabase 'profiles' tablosuna eşitler (Sync)
  /// Bu sayede, Baykuş Postası gönderdiğimizde diğerleri bizi bu güncel isim/foto ile görür.
  Future<bool> syncProfileData({
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
        'updated_at': DateTime.now().toUtc().toIso8601String(),
        'full_name': userName,
        'handle': userHandle,
        'avatar_url': avatarUrl,
        if (zodiacSign != null) 'zodiac_sign': zodiacSign,
      };

      // 'profiles' tablosuna upsert işlemi (varsa günceller, yoksa yaratır)
      await _supabase.from('profiles').upsert(updateData);
      
      debugPrint('Profil Senkronizasyonu Başarılı!');
      return true;
    } catch (e) {
      debugPrint('Supabase Profile Sync Hatası: \$e');
      return false;
    }
  }
}
