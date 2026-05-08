import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io' show Platform;
import 'analytics_service.dart';

class AdService {
  static final AdService _instance = AdService._();
  factory AdService() => _instance;
  AdService._();

  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoading = false;

  // GERÇEK REKLAM KİMLİKLERİ (PRODUCTION)
  String get _rewardedAdUnitId {
    if (Platform.isAndroid) {
      // TODO: Android için henüz gerçek kimlik girilmedi, şimdilik test kimliği duruyor.
      return 'ca-app-pub-3940256099942544/5224354917'; 
    } else if (Platform.isIOS) {
      return 'ca-app-pub-5096906411582452/3877609409'; // Gerçek iOS Rewarded Ad Kimliği
    }
    throw UnsupportedError("Unsupported platform");
  }

  void loadRewardedAd() {
    if (_isRewardedAdLoading || _rewardedAd != null) {
      return;
    }
    _isRewardedAdLoading = true;

    try {
      RewardedAd.load(
        adUnitId: _rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('RewardedAd yüklendi.');
            _rewardedAd = ad;
            _isRewardedAdLoading = false;
          },
          onAdFailedToLoad: (error) {
            debugPrint('RewardedAd yüklenemedi: $error');
            _rewardedAd = null;
            _isRewardedAdLoading = false;
          },
        ),
      );
    } catch (e) {
      debugPrint('Ad load error: $e');
      _isRewardedAdLoading = false;
    }
  }

  void showRewardedAd(Function onRewardEarned, Function onAdDismissed) {
    if (_rewardedAd == null) {
      debugPrint('Reklam henüz yüklenmedi veya başarısız oldu.');
      loadRewardedAd();
      onRewardEarned(); 
      return;
    }

    bool earnedReward = false;

    try {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) => debugPrint('Reklam gösteriliyor.'),
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('Reklam kapatıldı.');
          ad.dispose();
          _rewardedAd = null;
          loadRewardedAd(); 
          if (earnedReward) {
            onRewardEarned();
          } else {
            onAdDismissed();
          }
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('Reklam gösterilemedi: $error');
          ad.dispose();
          _rewardedAd = null;
          loadRewardedAd();
          onRewardEarned(); 
        },
      );

      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          debugPrint('Kullanıcı reklamı izledi ve ödülü kazandı: ${reward.amount} ${reward.type}');
          AnalyticsService().logAdWatched(source: 'rewarded');
          earnedReward = true;
        },
      );
    } catch (e) {
      debugPrint('Reklam gösteriminde HATA (MissingPlugin?): $e');
      onRewardEarned(); // Hata olduysa affet ve ödülü ver
    }
  }
}
