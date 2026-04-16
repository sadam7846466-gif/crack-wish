import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._();
  factory RevenueCatService() => _instance;
  RevenueCatService._();

  // TOD0: İleride RevenueCat panelinden alacağımız gerçek API Key'ler buraya girecek.
  final String _appleApiKey = 'goog_XXXXXXXXXXXXXXXXXXXXXX'; // Apple API Key
  final String _googleApiKey = 'goog_XXXXXXXXXXXXXXXXXXXXXX'; // Google API Key
  
  bool _isConfigured = false;

  Future<void> initialize() async {
    if (kIsWeb) return; // Web'de RevenueCat çalışmaz.
    
    try {
      await Purchases.setLogLevel(LogLevel.debug);

      late PurchasesConfiguration configuration;
      if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(_googleApiKey);
      } else if (Platform.isIOS) {
        configuration = PurchasesConfiguration(_appleApiKey);
      }
      await Purchases.configure(configuration);
      _isConfigured = true;
      debugPrint("RevenueCat Başarıyla Başlatıldı!");
    } catch (e) {
      debugPrint("RevenueCat Başlatma Hatası: $e");
    }
  }

  /// Kullanıcının Premium olup olmadığını kontrol eder
  Future<bool> isUserPremium() async {
    if (!_isConfigured) return false;
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      // 'elite_access' ileride RevenueCat panelinde oluşturacağın Entitlement (Abonelik Hakları) ID'si.
      if (customerInfo.entitlements.all["elite_access"]?.isActive == true) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Premium Sorgulama Hatası: $e");
      return false;
    }
  }

  /// Satın Alma Ekranını Tetikler
  Future<bool> purchasePackage(Package package) async {
    try {
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      if (customerInfo.entitlements.all["elite_access"]?.isActive == true) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Satın Alma İptali veya Hatası: $e");
      return false;
    }
  }

  /// Abonelikleri Geri Yükle (Restore) - iPhone standart kurallarından biridir.
  Future<bool> restorePurchases() async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      if (customerInfo.entitlements.all["elite_access"]?.isActive == true) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Geri Yükleme Hatası: $e");
      return false;
    }
  }
}
