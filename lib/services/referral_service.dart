import 'package:flutter/foundation.dart';
import 'package:app_links/app_links.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'storage_service.dart';

class ReferralService {
  static final ReferralService _instance = ReferralService._internal();
  factory ReferralService() => _instance;
  ReferralService._internal();

  late AppLinks _appLinks;
  bool _isInit = false;

  void initialize() {
    if (_isInit) return;
    _isInit = true;
    _appLinks = AppLinks();

    // Uygulama tamamen kapalıyken tıklanan linki yakala
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _processLink(uri);
    });

    // Uygulama açıkken veya arka plandayken tıklanan linki yakala
    _appLinks.uriLinkStream.listen((uri) {
      _processLink(uri);
    });
  }

  void _processLink(Uri uri) async {
    // Beklenen format: https://crackwish.com/invite/@sadam
    // Veya custom scheme: crackwish://invite/@sadam
    if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'invite') {
      if (uri.pathSegments.length > 1) {
        final referrerHandle = uri.pathSegments[1];
        debugPrint("Davet Kodu Yakalandı: $referrerHandle");
        
        final prefs = await SharedPreferences.getInstance();
        // Davet kodunu cihaza kaydet. (Onboarding bitince process edilecek)
        await prefs.setString('pending_referral_code', referrerHandle);
      }
    }
  }

  /// Kullanıcı hesabını oluşturduğunda bu fonksiyon çağırılır.
  static Future<void> processPendingReferrals(String newUserId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final referralCode = prefs.getString('pending_referral_code');

      if (referralCode == null || referralCode.isEmpty) return;

      // 1. Kendi davet kodun mu? (Hack koruması)
      final myHandle = await StorageService.getUserHandle();
      if (myHandle == referralCode) {
        await prefs.remove('pending_referral_code');
        return;
      }

      // 2. Supabase'deki cosmic_referrals tablosuna kaydet!
      await Supabase.instance.client.from('cosmic_referrals').insert({
        'inviter_handle': referralCode,
        'invitee_id': newUserId,
      });

      // 3. Davet ile geldiği için anında ödül ver! (+50 Aura, +2 Ruh Taşı)
      await StorageService.updateSoulStones(2);
      await StorageService.addBonusAura(50);
      
      // Ana sayfada "Arkadaşından sana bir hediye!" kutlamasını göstermek için bayrak
      await prefs.setBool('needs_referral_receiver_dialog', true);
      await prefs.setString('referral_inviter_name', referralCode);
      
      debugPrint("Davet ödülleri hesaba yüklendi!");

      // 4. Eklendiği için artık Pending kodunu sil
      await prefs.remove('pending_referral_code');

    } catch (e) {
      debugPrint("Davet kodu işleme hatası: $e");
    }
  }

  /// App her açıldığında kontrol eder, eğer başkası senin kodunla girmişse ödülünü kasana atar
  static Future<void> checkInviterRewards() async {
    try {
      final myHandle = await StorageService.getUserHandle();
      if (myHandle == null || myHandle.isEmpty) return;

      final response = await Supabase.instance.client
          .from('cosmic_referrals')
          .select()
          .eq('inviter_handle', myHandle)
          .eq('is_claimed', false);

      if (response == null || (response as List).isEmpty) return;

      int rewardedStones = 0;
      int referralCount = 0;
      List<String> newNames = [];

      for (var row in response) {
        rewardedStones += 2;
        referralCount++;

        // Davet edilen kişinin adını profilinden çek
        final inviteeId = row['invitee_id'];
        if (inviteeId != null) {
          final profileRes = await Supabase.instance.client
              .from('profiles')
              .select('full_name')
              .eq('id', inviteeId)
              .maybeSingle();
          if (profileRes != null && profileRes['full_name'] != null) {
            final name = profileRes['full_name'].toString().split(' ').first; // Sadece ilk adını al
            if (name.isNotEmpty) {
              newNames.add(name);
            }
          }
        }

        // Satırı alındı olarak işaretle
        await Supabase.instance.client
            .from('cosmic_referrals')
            .update({'is_claimed': true})
            .eq('id', row['id']);
      }

      if (rewardedStones > 0) {
        await StorageService.updateSoulStones(rewardedStones);
        await StorageService.addBonusAura(25 * referralCount); // Her davet için +25 Aura
        await StorageService.incrementStat('total_referrals_count', referralCount); // Achievement için
        
        // Ana sayfada "Arkadaşın davetini kabul etti" kutlamasını göstermek için
        final prefs = await SharedPreferences.getInstance();
        final currentCount = prefs.getInt('needs_inviter_reward_dialog_count') ?? 0;
        await prefs.setInt('needs_inviter_reward_dialog_count', currentCount + referralCount);
        
        // Yeni katılanların isimlerini de listeye ekle
        if (newNames.isNotEmpty) {
          final currentNames = prefs.getStringList('needs_inviter_reward_dialog_names') ?? [];
          currentNames.addAll(newNames);
          await prefs.setStringList('needs_inviter_reward_dialog_names', currentNames);
        }
        
        debugPrint("Davet ettiğin $referralCount kişi: +$rewardedStones Ruh Taşı, +${25 * referralCount} Aura!");
      }
    } catch (e) {
      debugPrint("Davet ödülleri kontrol hatası: $e");
    }
  }
}
