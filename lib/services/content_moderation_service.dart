import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

enum ModerationResult {
  approved,
  rejectedAdultContent,
  rejectedViolence,
  rejectedTooLarge,
  rejectedInvalidFormat
}

class ContentModerationService {
  static final ContentModerationService _instance = ContentModerationService._internal();
  factory ContentModerationService() => _instance;
  ContentModerationService._internal();

  /// Fotoğrafın uygunluğunu analiz eden 3 aşamalı Yapay Zeka Güvenlik Sınavı
  Future<ModerationResult> analyzeImage(File imageFile) async {
    try {
      // 1. Zırh: Fiziksel Kontrol (Dosya boyutu ve Tipi)
      final sizeInBytes = await imageFile.length();
      final sizeInMb = sizeInBytes / (1024 * 1024);
      if (sizeInMb > 5.0) {
        return ModerationResult.rejectedTooLarge; // 5MB sınırı
      }

      // 2. Zırh: Yapay Zeka Görüntü Analizi (SightEngine)
      try {
        final request = http.MultipartRequest('POST', Uri.parse('https://api.sightengine.com/1.0/check.json'));
        request.fields['models'] = 'nudity-2.0,gore,weapon';
        request.fields['api_user'] = '1943156292';
        request.fields['api_secret'] = 'vK6gWacrF8stpPkx5J4m3ojvpHZvJJ48';
        request.files.add(await http.MultipartFile.fromPath('media', imageFile.path));

        final response = await request.send();
        final responseData = await response.stream.bytesToString();
        final aiDecision = jsonDecode(responseData);

        if (aiDecision['status'] == 'success') {
          // Çıplaklık ve +18 kontrolü (safe skoru düşükse tehlikelidir)
          if (aiDecision['nudity'] != null && (aiDecision['nudity']['safe'] ?? 1.0) < 0.45) {
             return ModerationResult.rejectedAdultContent;
          }
          // Kan ve Şiddet kontrolü
          if (aiDecision['gore'] != null && (aiDecision['gore']['prob'] ?? 0.0) > 0.5) {
             return ModerationResult.rejectedViolence;
          }
          // Silah kontrolü
          if (aiDecision['weapon'] != null && (aiDecision['weapon'] ?? 0.0) > 0.5) {
             return ModerationResult.rejectedViolence;
          }
        } else {
          // LİMİT BİTİNCE VEYA SİSTEM ÇÖKÜNCE ÇALIŞAN GİZLİ KALKAN (Fail-Safe):
          // Hata varsa kullanıcıyı kapıda bekletme, sessizce onay ver ve içeri al! (Para ödemekten kurtaran yapı)
          debugPrint('SightEngine Fail-Safe Devrede (Limit/Hata): \${aiDecision["error"]["message"]}');
          return ModerationResult.approved;
        }
      } catch (aiError) {
        // İnternet kopuksa veya yapay zeka sunucusu kapalıysa geçişe izin ver
        debugPrint('Yapay Zeka Ağ Hatası (Fail-Safe Devrede): \$aiError');
        return ModerationResult.approved;
      }

      // Tüm güvenlik duvarlarından başarıyla geçti!
      return ModerationResult.approved;

    } catch (e) {
      debugPrint('AI Moderasyon Hatası: \$e');
      // Şüpheli bir hata varsa güvenlik (fail-safe) gereği reddedilir.
      return ModerationResult.rejectedInvalidFormat;
    }
  }

  /// Uyarıcı Mesaj Döner
  String getErrorMessage(ModerationResult result) {
    switch (result) {
      case ModerationResult.rejectedAdultContent:
        return 'Bu görselin enerjisi Kozmik evrenimizle uyumlu değil (Uygunsuz İçerik).';
      case ModerationResult.rejectedViolence:
        return 'Lütfen zihni yormayan, auranı yansıtan daha sakin bir avatar seç (Rahatsız Edici İçerik).';
      case ModerationResult.rejectedTooLarge:
        return 'Görselin kozmik ağı yoracak kadar büyük. Lütfen 5MB altı bir fotoğraf seç.';
      case ModerationResult.rejectedInvalidFormat:
        return 'Fotoğrafın sihirli parşömenimiz tarafından okunamadı, format bozuk.';
      default:
        return 'Bilinmeyen bir kozmik dalgalanma oluştu.';
    }
  }
}
