import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'analytics_service.dart';

class AdService {
  static final AdService _instance = AdService._();
  factory AdService() => _instance;
  AdService._();

  // ========== ADMOB ==========
  bool _admobInitialized = false;
  RewardedAd? _admobAd;
  bool _admobAdReady = false;

  // AdMob Rewarded Ad Unit
  static const String _admobAdUnitId = 'ca-app-pub-6648535985790373/7761948246';

  // ========== UNITY ADS (YEDEK) ==========
  bool _unityInitialized = false;
  bool _unityAdReady = false;
  static const String _unityGameId = '800005416';
  static const String _unityPlacementId = 'Rewarded_Android';

  /// SDK'ları başlat
  Future<void> initialize() async {
    // 1. AdMob başlat (birincil)
    await _initAdMob();
    // 2. Unity Ads başlat (yedek)
    _initUnity();
  }

  // ========== ADMOB ==========
  Future<void> _initAdMob() async {
    try {
      await MobileAds.instance.initialize();
      _admobInitialized = true;
      debugPrint('✅ AdMob başlatıldı!');
      _loadAdMobAd();
    } catch (e) {
      debugPrint('⚠️ AdMob init error: $e');
    }
  }

  void _loadAdMobAd() {
    if (!_admobInitialized) return;

    RewardedAd.load(
      adUnitId: _admobAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('✅ AdMob Rewarded Ad yüklendi!');
          _admobAd = ad;
          _admobAdReady = true;
        },
        onAdFailedToLoad: (error) {
          debugPrint('⚠️ AdMob Ad yüklenemedi: ${error.message}');
          _admobAdReady = false;
          // 15 saniye sonra tekrar dene
          Future.delayed(const Duration(seconds: 15), () => _loadAdMobAd());
        },
      ),
    );
  }

  // ========== UNITY ADS (YEDEK) ==========
  void _initUnity() {
    try {
      UnityAds.init(
        gameId: _unityGameId,
        testMode: true,
        onComplete: () {
          debugPrint('✅ Unity Ads başlatıldı!');
          _unityInitialized = true;
          _loadUnityAd();
        },
        onFailed: (error, message) {
          debugPrint('⚠️ Unity Ads başlatılamadı: $error');
        },
      );
    } catch (e) {
      debugPrint('⚠️ Unity init error: $e');
    }
  }

  void _loadUnityAd() {
    if (!_unityInitialized) return;
    UnityAds.load(
      placementId: _unityPlacementId,
      onComplete: (id) {
        debugPrint('✅ Unity Ad yüklendi');
        _unityAdReady = true;
      },
      onFailed: (id, error, message) {
        debugPrint('⚠️ Unity Ad yüklenemedi: $error');
        _unityAdReady = false;
      },
    );
  }

  // ========== REKLAM GÖSTER ==========
  void showRewardedAd(Function onRewardEarned, Function onAdDismissed) {
    // 1. Önce AdMob dene
    if (_admobInitialized && _admobAdReady && _admobAd != null) {
      _showAdMobAd(onRewardEarned, onAdDismissed);
      return;
    }

    // 2. AdMob yoksa Unity dene
    if (_unityInitialized && _unityAdReady) {
      _showUnityAd(onRewardEarned, onAdDismissed);
      return;
    }

    // 3. Hiçbiri yoksa ödülü bedava ver
    debugPrint('⚠️ Reklam hazır değil, ödül veriliyor...');
    _loadAdMobAd();
    _loadUnityAd();
    onRewardEarned();
  }

  // ========== ADMOB GÖSTER ==========
  void _showAdMobAd(Function onRewardEarned, Function onAdDismissed) {
    final ad = _admobAd;
    if (ad == null) {
      onRewardEarned();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('🔄 AdMob reklam kapatıldı');
        ad.dispose();
        _admobAd = null;
        _admobAdReady = false;
        _loadAdMobAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('❌ AdMob gösterilemedi: ${error.message}');
        ad.dispose();
        _admobAd = null;
        _admobAdReady = false;
        _loadAdMobAd();
        // AdMob başarısız → Unity dene
        if (_unityAdReady) {
          _showUnityAd(onRewardEarned, onAdDismissed);
        } else {
          onRewardEarned();
        }
      },
    );

    ad.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('🎁 AdMob ödül kazanıldı: ${reward.amount} ${reward.type}');
        AnalyticsService().logAdWatched(source: 'admob_rewarded');
        onRewardEarned();
      },
    );
  }

  // ========== UNITY GÖSTER ==========
  void _showUnityAd(Function onRewardEarned, Function onAdDismissed) {
    try {
      UnityAds.showVideoAd(
        placementId: _unityPlacementId,
        onStart: (_) => debugPrint('📺 Unity reklam başladı'),
        onClick: (_) {},
        onSkipped: (_) {
          _unityAdReady = false;
          _loadUnityAd();
          onAdDismissed();
        },
        onComplete: (_) {
          debugPrint('🎁 Unity reklam tamamlandı!');
          AnalyticsService().logAdWatched(source: 'unity_rewarded');
          _unityAdReady = false;
          _loadUnityAd();
          onRewardEarned();
        },
        onFailed: (_, error, message) {
          debugPrint('❌ Unity gösterilemedi: $error');
          _unityAdReady = false;
          _loadUnityAd();
          onRewardEarned();
        },
      );
    } catch (e) {
      debugPrint('❌ Unity hata: $e');
      onRewardEarned();
    }
  }

  void loadRewardedAd() {
    _loadAdMobAd();
    _loadUnityAd();
  }
}
