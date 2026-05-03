import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'analytics_service.dart';
import 'storage_service.dart';
import '../models/cookie_card.dart';

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
  static const String cookieGoldenSakuraId = 'cookie_golden_sakura';
  static const String cookieDragonPhoenixId = 'cookie_dragon_phoenix';
  static const String cookieGoldBeastsId = 'cookie_gold_beasts';

  static const Set<String> _allProductIds = {
    eliteWeeklyId,
    eliteMonthlyId,
    eliteYearlyId,
    cookieGoldenArabesqueId,
    cookieMidnightMosaicId,
    cookiePearlLaceId,
    cookieGoldenSakuraId,
    cookieDragonPhoenixId,
    cookieGoldBeastsId,
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
      debugPrint('✅ Elite aktif edildi!');
      AnalyticsService().logElitePurchased(plan: productId);
    } else if (_isCookieProduct(productId)) {
      // Kurabiye — satın alınan kurabiyeyi envantere ekle
      // Satın alınan ürün ID'si örn: "cookie_golden_arabesque". Ön ekini temizle:
      final String cookieId = productId.replaceFirst('cookie_', '');
      await StorageService.incrementCookieCard(cookieId);
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
      return false;
    }

    try {
      final purchaseParam = PurchaseParam(productDetails: product);

      if (_isEliteProduct(purchaseParam.productDetails.id)) {
        await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        // Kurabiye (tüketilebilir/hediye edilebilir, stoklu ürün)
        await _iap.buyConsumable(purchaseParam: purchaseParam, autoConsume: true);
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
    final cookieId = cookieProductId.replaceFirst('cookie_', '');
    final collection = await StorageService.getCookieCollection();
    final card = collection.firstWhere((c) => c.id == cookieId, orElse: () => CookieCard(id: cookieId, emoji: '', name: '', rarity: ''));
    return card.countObtained > 0;
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
