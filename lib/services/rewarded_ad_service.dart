import 'dart:async';
import 'package:flutter/foundation.dart';

/// Stub interface for Rewarded Ad integration
/// Replace with actual ad SDK implementation (AdMob, Unity Ads, etc.)
abstract class RewardedAdService {
  /// Check if an ad is ready to show
  Future<bool> isAdReady();

  /// Load a new ad
  Future<void> loadAd();

  /// Show the ad and return true if user completed watching
  Future<bool> showAd();

  /// Dispose resources
  void dispose();
}

/// Stub implementation for development/testing
class StubRewardedAdService implements RewardedAdService {
  bool _isLoaded = false;
  
  @override
  Future<bool> isAdReady() async {
    // Simulate ad availability (80% success rate)
    await Future.delayed(const Duration(milliseconds: 200));
    return _isLoaded;
  }

  @override
  Future<void> loadAd() async {
    // Simulate ad loading (1-2 seconds)
    await Future.delayed(const Duration(milliseconds: 1500));
    // 90% success rate for loading
    _isLoaded = DateTime.now().millisecond % 10 != 0;
    debugPrint('[RewardedAdService] Ad loaded: $_isLoaded');
  }

  @override
  Future<bool> showAd() async {
    if (!_isLoaded) {
      debugPrint('[RewardedAdService] No ad loaded');
      return false;
    }

    // Simulate ad watching (2-3 seconds)
    debugPrint('[RewardedAdService] Showing ad...');
    await Future.delayed(const Duration(seconds: 2));
    
    // 95% completion rate
    final completed = DateTime.now().millisecond % 20 != 0;
    debugPrint('[RewardedAdService] Ad completed: $completed');
    
    _isLoaded = false; // Ad consumed
    return completed;
  }

  @override
  void dispose() {
    _isLoaded = false;
  }
}

/// Singleton accessor
class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  RewardedAdService? _service;

  RewardedAdService get service {
    _service ??= StubRewardedAdService();
    return _service!;
  }

  /// Initialize with custom service (for production)
  void initialize(RewardedAdService service) {
    _service?.dispose();
    _service = service;
  }

  void dispose() {
    _service?.dispose();
    _service = null;
  }
}
