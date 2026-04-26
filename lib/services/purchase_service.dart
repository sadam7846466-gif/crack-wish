import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'analytics_service.dart';

/// Apple/Google'ın kendi satın alma sistemi — üçüncü parti yok.
class PurchaseService {
  static final PurchaseService _instance = PurchaseService._();
  factory PurchaseService() => _instance;
  PurchaseService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // ── Ürün ID'leri (App Store Connect + Google Play Console'da aynı ID'lerle oluştur) ──
  static const String eliteWeeklyId = 'elite_weekly';
  static const String eliteMonthlyId = 'elite_monthly';
  static const String eliteYearlyId = 'elite_yearly';

  // Premium Kurabiye ID'leri
  static const String cookieGoldenArabesqueId = 'cookie_golden_arabesque';
  static const String cookieMidnightMosaicId = 'cookie_midnight_mosaic';
  static const String cookiePearlLaceId = 'cookie_pearl_lace';
  static const String cookieSpringWreathId = 'cookie_spring_wreath';
  static const String cookieImperialDragonId = 'cookie_imperial_dragon';
  static const String cookieNebulaDustId = 'cookie_nebula_dust';

  static const Set<String> _allProductIds = {
    eliteWeeklyId,
    eliteMonthlyId,
    eliteYearlyId,
    cookieGoldenArabesqueId,
    cookieMidnightMosaicId,
    cookiePearlLaceId,
    cookieSpringWreathId,
    cookieImperialDragonId,
    cookieNebulaDustId,
  };

  // Yüklenen ürün detayları
  Map<String, ProductDetails> _products = {};
  bool _isAvailable = false;

  // Callback'ler
  Function(String productId)? onPurchaseSuccess;
  Function(String error)? onPurchaseError;

  /// Satın alma sistemini başlat
  Future<void> initialize() async {
    if (kIsWeb) return;

    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) {
      debugPrint('Satın alma servisi kullanılamıyor.');
      return;
    }

    // Satın alma akışını dinle
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) => debugPrint('Satın alma stream hatası: $error'),
    );

    // Ürünleri yükle
    await _loadProducts();

    // Tamamlanmamış satın almaları kontrol et
    debugPrint('PurchaseService Başlatıldı! ${_products.length} ürün yüklendi.');
  }

  /// Mağazadan ürün bilgilerini çek
  Future<void> _loadProducts() async {
    try {
      final response = await _iap.queryProductDetails(_allProductIds);
      if (response.error != null) {
        debugPrint('Ürün sorgulama hatası: ${response.error}');
      }
      _products = {
        for (final product in response.productDetails)
          product.id: product,
      };
      debugPrint('Yüklenen ürünler: ${_products.keys.toList()}');
    } catch (e) {
      debugPrint('Ürün yükleme hatası: $e');
    }
  }

  /// Satın alma sonuçlarını işle
  void _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // Satın alma başarılı — doğrula ve kilidi aç
          await _verifyAndDeliver(purchase);
          break;
        case PurchaseStatus.error:
          debugPrint('Satın alma hatası: ${purchase.error}');
          onPurchaseError?.call(purchase.error?.message ?? 'Bilinmeyen hata');
          break;
        case PurchaseStatus.pending:
          debugPrint('Satın alma beklemede: ${purchase.productID}');
          break;
        case PurchaseStatus.canceled:
          debugPrint('Satın alma iptal edildi: ${purchase.productID}');
          break;
      }

      // Her durumda işlemi tamamla (Apple/Google'a "tamam aldım" de)
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  /// Satın almayı doğrula ve ürünü kullanıcıya ver
  Future<void> _verifyAndDeliver(PurchaseDetails purchase) async {
    final prefs = await SharedPreferences.getInstance();
    final productId = purchase.productID;

    if (_isEliteProduct(productId)) {
      // Elite abonelik — premium durumunu aç (iki key de set edilmeli!)
      await prefs.setBool('is_elite', true);
      await prefs.setBool('is_premium_test_mode', true); // Tüm ekranlar bu key'i kontrol ediyor
      debugPrint('✅ Elite aktif edildi!');
      AnalyticsService().logElitePurchased(plan: productId);
    } else if (_isCookieProduct(productId)) {
      // Kurabiye — satın alınan kurabiyeyi kaydet
      final ownedCookies = prefs.getStringList('owned_cookies') ?? [];
      if (!ownedCookies.contains(productId)) {
        ownedCookies.add(productId);
        await prefs.setStringList('owned_cookies', ownedCookies);
      }
      debugPrint('✅ Kurabiye satın alındı: $productId');
      AnalyticsService().logCookiePurchased(cookieId: productId, price: 'store');
    }

    onPurchaseSuccess?.call(productId);
  }

  bool _isEliteProduct(String id) =>
      id == eliteWeeklyId || id == eliteMonthlyId || id == eliteYearlyId;

  bool _isCookieProduct(String id) => id.startsWith('cookie_');

  /// Belirli bir ürünü satın al
  Future<bool> purchase(String productId) async {
    if (!_isAvailable) {
      debugPrint('Mağaza kullanılamıyor.');
      return false;
    }

    final product = _products[productId];
    if (product == null) {
      debugPrint('Ürün bulunamadı: $productId');
      // [BETA/TEST MODU KODU] - Gerçek mağaza ID'leri bağlanana kadar UI testleri için onay simülasyonu:
      debugPrint('BETA/TEST MODU: Sanal Satın Alma Başarılı Kabul Ediliyor...');
      await Future.delayed(const Duration(seconds: 1)); // Gerçekçi ağ bekleme süresi
      _verifyAndDeliver(PurchaseDetails(
        productID: productId,
        purchaseID: 'test_purchase_id',
        status: PurchaseStatus.purchased,
        transactionDate: DateTime.now().millisecondsSinceEpoch.toString(),
        verificationData: PurchaseVerificationData(localVerificationData: 'test', serverVerificationData: 'test', source: 'test'),
      ));
      return true;
    }

    try {
      final purchaseParam = PurchaseParam(productDetails: product);

      if (_isEliteProduct(productId)) {
        // Abonelik
        await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        // Kurabiye (tek seferlik)
        await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      }
      return true;
    } catch (e) {
      debugPrint('Satın alma başlatma hatası: $e');
      return false;
    }
  }

  /// Kullanıcı Elite mi?
  Future<bool> isUserElite() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_elite') ?? false;
  }

  /// Kullanıcı bu kurabiyeye sahip mi?
  Future<bool> ownsCookie(String cookieProductId) async {
    final prefs = await SharedPreferences.getInstance();
    final owned = prefs.getStringList('owned_cookies') ?? [];
    return owned.contains(cookieProductId);
  }

  /// Eski satın almaları geri yükle (Apple zorunlu kılıyor)
  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  /// Belirli bir ürünün fiyat bilgisini al
  String? getPrice(String productId) {
    return _products[productId]?.price;
  }

  void dispose() {
    _subscription?.cancel();
  }
}
