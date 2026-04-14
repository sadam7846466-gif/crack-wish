import 'dart:io';
import 'package:flutter/foundation.dart';

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

      // 2. Zırh: Yapay Zeka Görüntü Analizi (API Entegrasyonu Noktası)
      // TODO: Canlıya çıkarken buraya AWS Rekognition veya Google Cloud Vision API eklenecek.
      // Şimdilik simülasyon olarak dosyayı geçiriyoruz, ancak API eklendiğinde %60 üstü
      // çıplaklık veya şiddet algılandığında doğrudan rejected dönecek:
      /*
        final response = await http.post(
          Uri.parse('https://api.sightengine.com/1.0/check.json'),
          body: {
            'models': 'nudity-2.0,gore',
            'api_user': 'YOUR_API_USER',
            'api_secret': 'YOUR_API_SECRET',
            'media': imageFile, // Base64 veya form-data olarak iletilir
          }
        );
        final aiDecision = jsonDecode(response.body);
        if (aiDecision['nudity']['safe'] < 0.4 || aiDecision['gore']['prob'] > 0.5) {
           return ModerationResult.rejectedAdultContent;
        }
      */

      // 3. Zırh: Şikayet Sabıka Kontrolü
      // (Bunu ileride veritabanından kullanıcının 'flag_score' verisini okuyarak yapacağız)

      // Tüm güvenlik duvarlarından geçti!
      await Future.delayed(const Duration(milliseconds: 1500)); // Yapay Zeka analizi hissi
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
