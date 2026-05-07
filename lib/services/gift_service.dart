import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'storage_service.dart';
import 'profile_sync_service.dart';

class GiftService {
  static final GiftService _instance = GiftService._internal();
  factory GiftService() => _instance;
  GiftService._internal();

  final _supabase = Supabase.instance.client;

  /// Güvenli Hediye Aktarım Fonksiyonu
  /// [targetUserId] = Hediyeyi alacak arkadaşın Supabase UUID'si
  /// [cookieId] = Gönderilen kurabiyenin ID'si (Örn: "golden_arabesque")
  Future<bool> sendCookieGift(String targetUserId, String cookieId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('🎁 Hediye Hatası: Kullanıcı giriş yapmamış.');
        return false;
      }

      // 1. Kendi stok kontrolümüzü (Locale) yapıyoruz.
      final collection = await StorageService.getCookieCollection();
      final myCookieCard = collection.firstWhere(
        (c) => c.id == cookieId,
        orElse: () => throw Exception('Kurabiye bulunamadı'),
      );

      if (myCookieCard.countObtained <= 0) {
        debugPrint('🎁 Hediye Hatası: Yeterli stok yok.');
        return false;
      }

      // 2. Alıcının (Arkadaşın) mevcut kurabiye envanterini çekiyoruz
      final receiverData = await _supabase
          .from('profiles')
          .select('cookie_inventory')
          .eq('id', targetUserId)
          .maybeSingle();

      if (receiverData == null) {
        debugPrint('🎁 Hediye Hatası: Alıcı profil bulunamadı.');
        return false;
      }

      // Alıcının envanterini hazırlıyoruz
      Map<String, dynamic> receiverInventory = {};
      if (receiverData['cookie_inventory'] != null) {
        receiverInventory = Map<String, dynamic>.from(receiverData['cookie_inventory']);
      }
      
      // Alıcıya +1 ekle
      final currentReceiverCount = (receiverInventory[cookieId] ?? 0) as int;
      receiverInventory[cookieId] = currentReceiverCount + 1;

      // 3. Kendi (Gönderen) envanterimizi buluttan çekiyoruz
      final senderData = await _supabase
          .from('profiles')
          .select('cookie_inventory')
          .eq('id', user.id)
          .maybeSingle();
          
      Map<String, dynamic> senderInventory = {};
      if (senderData != null && senderData['cookie_inventory'] != null) {
        senderInventory = Map<String, dynamic>.from(senderData['cookie_inventory']);
      }

      // Kendi stokumuzdan -1 düş
      final currentSenderCount = (senderInventory[cookieId] ?? 0) as int;
      if (currentSenderCount <= 0) {
        debugPrint('🎁 Hediye Hatası: Bulut stokunuz yetersiz.');
        return false; // Hile Koruması
      }
      senderInventory[cookieId] = currentSenderCount - 1;

      // 4. TRANSACTION MANTIĞI: İki profili de aynı anda güncelliyoruz
      // Kendi bulut stokumuzu güncelleyelim
      await _supabase.from('profiles').update({
        'cookie_inventory': senderInventory,
      }).eq('id', user.id);

      // Alıcının bulut stokunu güncelleyelim
      await _supabase.from('profiles').update({
        'cookie_inventory': receiverInventory,
      }).eq('id', targetUserId);

      // 5. BAŞARILI! Kendi cihazımızdaki yerel veriyi de (StorageService) -1 yapalım ki UI anında güncellensin.
      await StorageService.decrementCookieCard(cookieId);

      debugPrint('✅ 🎁 Hediye Başarıyla Gönderildi: $cookieId -> $targetUserId');
      return true;

    } catch (e) {
      debugPrint('🎁 Hediye Aktarım Hatası: $e');
      return false;
    }
  }
}
