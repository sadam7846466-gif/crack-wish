import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../services/storage_service.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/cosmic_engine_service.dart';
import '../services/push_notification_service.dart';
import 'coffee_page.dart';

class CoffeeReadingPage extends StatefulWidget {
  static bool isApiRunning = false; // Add static flag
  static bool isViewingReading = false;
  final File? insideAngle;
  final File? leftAngle;
  final File? rightAngle;
  final File? plateAngle;
  final Map<String, dynamic>? initialData;
  final void Function(bool success, String? error)? onBackgroundResult;

  const CoffeeReadingPage({
    super.key,
    this.insideAngle,
    this.leftAngle,
    this.rightAngle,
    this.plateAngle,
    this.initialData,
    this.onBackgroundResult,
  });

  @override
  State<CoffeeReadingPage> createState() => _CoffeeReadingPageState();
}

class _CoffeeReadingPageState extends State<CoffeeReadingPage>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  bool _hasError = false;
  bool _isValidationError = false;
  String _errorMessage = '';
  int _loadingTextIndex = 0;
  Timer? _loadingTimer;
  int _soulStones = 0;
  int? _expandedPhotoIndex;
  bool _isSymbolsExpanded = false;

  int _smokeStep = 0;
  Timer? _smokeTimer;

  // Dinamik API sonuçları
  Map<String, dynamic>? _readingData;

  late AnimationController _pulseController;
  late AnimationController _rotationController;

  // Sonuç ekranı giriş animasyonu
  late AnimationController _resultEntranceController;

  final List<String> _loadingTexts = [
    "Fincanın derinliklerine iniliyor...",
    "Telvelerdeki semboller evrensel enerjiyle eşleşiyor...",
    "Ruh rehberleri dinleniyor...",
    "Kader çizgilerin haritalanıyor...",
    "Sırlar açığa çıkıyor...",
  ];

  @override
  void initState() {
    super.initState();
    CoffeeReadingPage.isViewingReading = true;
    _loadSoulStones();

    // Aura animasyonları
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _resultEntranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Bekleme yazılarının değişimi
    _loadingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _isLoading) {
        setState(() {
          if (_loadingTextIndex < _loadingTexts.length - 1) {
            _loadingTextIndex++;
          }
        });
      }
    });

    // Duman animasyonu için sayaç
    _smokeTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (mounted && _isLoading) {
        setState(() {
          _smokeStep = (_smokeStep + 1) % 4;
        });
      }
    });

    // Gerçek API çağrısı veya hazır veriyi yükleme
    if (widget.initialData != null) {
      _isLoading = false;
      _readingData = widget.initialData;
      // UI build edildikten sonra animasyonu başlat
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _resultEntranceController.forward();
      });
    } else {
      _callCoffeeApi();
    }
  }

  Future<void> _loadSoulStones() async {
    final stones = await StorageService.getSoulStones();
    if (mounted) setState(() => _soulStones = stones);
  }

  /// AI'ın image_map'ine göre doğru fotoğrafı döndür.
  /// AI her bölüm için hangi fotoğrafı (1-4) kullandığını bildirir.
  /// Fallback: image_map yoksa sabit slot sırasına güvenir.
  File? _getImageForSection(String sectionKey) {
    final allImages = [
      widget.insideAngle,
      widget.leftAngle,
      widget.rightAngle,
      widget.plateAngle,
    ];

    // AI'dan gelen image_map varsa, onu kullan
    final imageMap = _readingData?['image_map'];
    if (imageMap != null && imageMap[sectionKey] != null) {
      final idx = (imageMap[sectionKey] as int) - 1; // 1-indexed → 0-indexed
      if (idx >= 0 && idx < allImages.length) {
        return allImages[idx];
      }
    }

    // Fallback: sabit slot sırası
    switch (sectionKey) {
      case 'cup_inside':
        return widget.insideAngle;
      case 'cup_side':
        return widget.leftAngle;
      case 'cup_bottom':
        return widget.rightAngle;
      case 'saucer':
        return widget.plateAngle;
      default:
        return widget.insideAngle;
    }
  }

  /// Fotoğrafları base64'e çevir
  Future<String> _imageToBase64(File? file) async {
    if (file == null) return '';
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  /// Gerçek Supabase Edge Function çağrısı (2 aşamalı)
  Future<void> _callCoffeeApi() async {
    // ÖNEMLİ: Eğer sayfa arka plana atılırsa (dispose olursa) widget'a erişim hata fırlatır!
    // Bu yüzden arka planda kullanılacak tüm widget referanslarını yerel değişkene alıyoruz.
    final insidePath = widget.insideAngle?.path ?? '';
    final leftPath = widget.leftAngle?.path ?? '';
    final rightPath = widget.rightAngle?.path ?? '';
    final platePath = widget.plateAngle?.path ?? '';
    final backgroundCallback = widget.onBackgroundResult;

    CoffeeReadingPage.isApiRunning = true;

    try {
      // Fotoğrafları base64'e çevir
      final images = await Future.wait([
        _imageToBase64(widget.insideAngle),
        _imageToBase64(widget.leftAngle),
        _imageToBase64(widget.rightAngle),
        _imageToBase64(widget.plateAngle),
      ]);

      final supabase = Supabase.instance.client;

      // Doğrulama ana sayfada (CoffeePage) yapıldığı için direkt yoruma geçiyoruz.
      // ═══ AŞAMA 2: Fal Yorumu ═══
      final user = supabase.auth.currentUser;
      
      String? recordId;
      try {
        final insertResponse = await supabase.from('coffee_readings').insert({
          'user_id': user?.id,
          'locale': 'tr',
          'status': 'pending'
        }).select('id').maybeSingle();
        recordId = insertResponse?['id'];
      } catch (dbErr) {
        debugPrint('DB Insert failed for coffee (ignoring): $dbErr');
      }

      // record_id'yi HEMEN kaydet — kullanıcı app'i kapatırsa recovery bulabilsin
      final prefs = await SharedPreferences.getInstance();
      if (recordId != null) {
        await prefs.setString('coffee_last_record_id', recordId);
      }

      // Server Edge Function will automatically send an FCM push notification 
      // when the analysis is actually completed. We DO NOT use local timers
      // anymore to prevent false positive notifications if the request fails.

      // Profil verilerini al (AI kişiselleştirmesi için)
      final gender = await StorageService.getGender();
      final zodiac = await StorageService.getZodiacSign();
      final relationship = await StorageService.getRelationshipStatus();
      final lifeFocus = await StorageService.getLifeFocus(); // Niyet (Kalbinin Pusulası)

      final interpretResponse = await supabase.functions.invoke(
        'interpret-coffee',
        body: {
          'mode': 'interpret', 
          'images': images, 
          'locale': 'tr', 
          'userId': user?.id,
          'record_id': recordId,
          'gender': gender ?? '',
          'zodiac': zodiac ?? '',
          'relationship': relationship ?? '',
          'intent': lifeFocus ?? '', // AI promptuna niyet olarak eklenecek
        },
      );

      final initialData = interpretResponse.data as Map<String, dynamic>;
      Map<String, dynamic> reading;

      if (initialData['status'] == 'processing') {
        // AI yorumlamayı arka planda sürdürüyor. DB'den poll edeceğiz.
        
        Map<String, dynamic>? finalResult;
        // 45 saniye boyunca db yokla (15 kere 3 saniye aralıklarla)
        for (int i = 0; i < 15; i++) {
          if (!mounted) {
            // Kullanıcı sayfadan çıktıysa arka planda bildirim atacak zaten
            break;
          }
          await Future.delayed(const Duration(seconds: 3));
          
          if (recordId != null) {
            final row = await supabase.from('coffee_readings').select().eq('id', recordId).maybeSingle();
            if (row != null) {
              if (row['status'] == 'completed') {
                finalResult = row['result'] as Map<String, dynamic>;
                break;
              } else if (row['status'] == 'failed') {
                throw Exception('AI falı yorumlarken bir hata ile karşılaştı.');
              }
            }
          }
        }
        
        if (!mounted) {
           CoffeeReadingPage.isApiRunning = false;
           return;
        }

        if (finalResult == null) {
          // Timeout, but it might still finish in background
          CoffeeReadingPage.isApiRunning = false;
          backgroundCallback?.call(true, null);
          return;
        }
        reading = finalResult;
        await prefs.remove('coffee_last_record_id');
      } else {
        // Fallback: anında yanıt geldiyse
        reading = initialData;
      }

      // Sonucu kaydet (Sayfadan çıkmış olsa bile kaydedilir)
      final today = DateTime.now().toIso8601String().split('T')[0];
      reading['time'] = DateTime.now().toIso8601String();
      await prefs.setString('coffee_last_reading_date', today);
      await prefs.setString('coffee_last_reading', jsonEncode(reading));
      await prefs.setBool('coffee_last_reading_viewed', false);
      await prefs.setBool('coffee_last_reading_notified', false);

      // Fal başarıyla tamamlandı — iade bayrağını kaldır
      await prefs.setBool('pending_fortune_paid', false);

      // Save image paths to restore the UI later
      // Fotoğrafları kalıcı dizine kopyala (iOS tmp/ klasörü silebilir)
      final appDir = await getApplicationDocumentsDirectory();
      final coffeeDir = Directory('${appDir.path}/coffee_photos');
      if (!coffeeDir.existsSync()) coffeeDir.createSync(recursive: true);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final savedPaths = <String>[];
      final tempPaths = [insidePath, leftPath, rightPath, platePath];
      final labels = ['inside', 'left', 'right', 'plate'];

      for (int i = 0; i < tempPaths.length; i++) {
        final src = tempPaths[i];
        if (src.isNotEmpty && File(src).existsSync()) {
          final ext = p.extension(src).isNotEmpty ? p.extension(src) : '.jpg';
          final dest = '${coffeeDir.path}/${labels[i]}_$timestamp$ext';
          await File(src).copy(dest);
          savedPaths.add(dest);
        } else {
          savedPaths.add(src);
        }
      }

      await prefs.setStringList('coffee_last_images', savedPaths);

      await StorageService.incrementTotalCoffee();

      // Akıllı bildirimleri güncelle (kurabiye kırılmış mı, tarot bakılmış mı vb.)
      PushNotificationService().refreshSmartNotifications();

      backgroundCallback?.call(true, null);

      if (!mounted) {
        CoffeeReadingPage.isApiRunning = false;
        return;
      }

      // Kullanıcı hâlâ sayfada — sonucu görecek
      // (Local notification scheduling was removed, FCM will still send if server finishes,
      // ama push notification backend tarafında handle edildiğinden sorun yok)

      // KULLANICI SONUCU EKRANDA GÖRDÜ, BİLDİRİMİ İPTAL ET:
      await prefs.setBool('coffee_last_reading_viewed', true);
      await prefs.setBool('coffee_last_reading_notified', true);

      HapticFeedback.heavyImpact();
      setState(() {
        _readingData = reading;
        _isLoading = false;
        _hasError = false;
      });
      CoffeeReadingPage.isApiRunning = false;
      _resultEntranceController.forward();
    } catch (e) {
      debugPrint('Kahve falı API hatası: $e');

      // İşlem başarısız olduysa (Örn: İnternet koptu, AI cevap vermedi) peşin aldığımız taşı İADE EDİYORUZ!
      await StorageService.updateSoulStones(1);
      // İade yapıldı — bekleyen ödeme bayrağını temizle
      final errorPrefs = await SharedPreferences.getInstance();
      await errorPrefs.setBool('pending_fortune_paid', false);

      // Arka planda hata aldıysa Ana sayfaya bildir
      backgroundCallback?.call(
        false,
        e.toString().replaceAll('Exception: ', ''),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _isValidationError = false;
          _errorMessage = 'Bir sorun oluştu. Lütfen tekrar dene.';
        });
      }
      CoffeeReadingPage.isApiRunning = false;
    }
  }

  @override
  void dispose() {
    CoffeeReadingPage.isViewingReading = false;
    _loadingTimer?.cancel();
    _smokeTimer?.cancel();
    _pulseController.dispose();
    _rotationController.dispose();
    _resultEntranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    return TickerMode(
      enabled: isCurrent,
      child: Scaffold(
      backgroundColor: const Color(0xFF0C0A09),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 1200),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: _isLoading
            ? _buildLoadingScreen()
            : (_hasError ? _buildErrorScreen() : _buildResultScreen()),
      ),
      ), // Scaffold
    ); // TickerMode
  }

  Widget _buildLoadingScreen() {
    return SafeArea(
      key: const ValueKey('loading'),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            const Spacer(flex: 3),
            // Mistik Kahve ve Duman Animasyonu (Ritüel Fincanı)
            SizedBox(
              width: 140,
              height: 140,
              child: Transform.scale(
                scale: 1.35, // Biraz küçülttük
                child: Center(
                  child: SizedBox(
                    width: 80,
                    height: 100, // Dumanlar için yüksekliği artırdık
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        // Minimalist Çizgi Duman Animasyonu (Kullanıcının Çizimi)
                        ...List.generate(3, (index) {
                          return AnimatedBuilder(
                            animation: _rotationController,
                            builder: (context, child) {
                              // Hızı yavaşlatıldı (*4 yerine daha sakin bir ritim)
                              final progress =
                                  ((_rotationController.value * 3.5) +
                                      (index * 0.33)) %
                                  1.0;

                              // Hareketi yumuşatmak için yavaşlayarak çıkan bir eğri kullanıyoruz
                              final easeProgress = Curves.easeOut.transform(
                                progress,
                              );

                              // Aşağıdan yukarıya çok daha yumuşak ve kavisli bir yükseliş
                              final dy = -45 * easeProgress;

                              // Ortada en belirgin, başta ve sonda tamamen silik (yumuşak geçiş)
                              final opacity =
                                  math.sin(progress * math.pi) *
                                  0.7; // Biraz daha şeffaf ve elit

                              // X ekseninde yan yana dizilim (24, 34, 44)
                              final leftPos = 24.0 + (index * 10.0);

                              return Positioned(
                                top:
                                    15 +
                                    dy, // Fincanın üstünden süzülerek çıkıyor
                                left: leftPos,
                                child: Opacity(
                                  opacity: opacity,
                                  child: CustomPaint(
                                    size: const Size(
                                      12,
                                      28,
                                    ), // Kullanıcının çizdiği zarif "S" boyutu
                                    painter: SmokeWispPainter(
                                      color: const Color(0xFFD4A373),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                        // Kupa Gövdesi
                        Positioned(
                          top: 40,
                          left: 16,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD4A373),
                                  borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(20),
                                  ),
                                ),
                              ),
                              // Kulp
                              Container(
                                width: 14,
                                height: 22,
                                margin: const EdgeInsets.only(top: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFD4A373),
                                    width: 3.5,
                                  ),
                                  borderRadius: const BorderRadius.horizontal(
                                    right: Radius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Tabak
                        Positioned(
                          top: 84.0, // Fincanın altına oturtuldu
                          left: 4,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 72,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD4A373),
                                  borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(8),
                                    top: Radius.circular(2),
                                  ),
                                ),
                              ),
                              Container(
                                width: 44,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD4A373),
                                  borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(flex: 2),

            // ─── Bilgilendirme Alanı ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  _buildLoadingInfoRow(
                    Icons.notifications_active_outlined,
                    'Falın hazır olunca bildirim alacaksın',
                  ),
                  const SizedBox(height: 18),
                  _buildLoadingInfoRow(
                    Icons.local_cafe_rounded,
                    Text.rich(
                      TextSpan(
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 16,
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(text: 'Sonucu ana sayfadaki  '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Icon(
                              Icons.local_cafe_rounded,
                              size: 18,
                              color: Colors.white.withOpacity(0.65),
                            ),
                          ),
                          const TextSpan(text: '  butonundan görebilirsin'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildLoadingInfoRow(
                    Icons.explore_outlined,
                    'Burada bekle ya da uygulamayı keşfet',
                  ),
                ],
              ),
            ),

            const Spacer(flex: 1),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.popUntil(context, (route) => route.isFirst); // Tamamen ana sayfaya dön
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.white.withOpacity(0.06),
                    border: Border.all(
                      color: const Color(0xFFD4A373).withOpacity(0.25),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Ana Sayfaya Dön',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFD4A373).withOpacity(0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingInfoRow(IconData icon, dynamic content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFD4A373).withOpacity(0.10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFFD4A373).withOpacity(0.8),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: content is String
              ? Text(
                  content,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 16,
                    height: 1.4,
                  ),
                )
              : content,
        ),
      ],
    );
  }

  Widget _buildAnimatedResultChild(double start, Widget child) {
    final fadeAnim = CurvedAnimation(
      parent: _resultEntranceController,
      curve: Interval(
        start,
        math.min(1.0, start + 0.4),
        curve: Curves.easeOutCubic,
      ),
    );
    final slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _resultEntranceController,
            curve: Interval(
              start,
              math.min(1.0, start + 0.5),
              curve: Curves.easeOutQuart,
            ),
          ),
        );

    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(position: slideAnim, child: child),
    );
  }

  Widget _buildResultScreen() {
    return Stack(
      key: const ValueKey('result'),
      children: [
        // 1. Kaydırılabilir İçerik (Tam Ekran)
        Positioned.fill(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: EdgeInsets.only(
              top:
                  MediaQuery.of(context).padding.top +
                  90, // App Bar için boşluk
              bottom:
                  MediaQuery.of(context).padding.bottom +
                  24, // Alt sınırda kararında boşluk
              left: 24,
              right: 24,
            ),
            child: Column(
              children: [
                // Title Section
                // 1. Fincanın Bölümleri (Premium Liste)
                _buildAnimatedResultChild(
                  0.0,
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF140F0C),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFD4A373).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPremiumHeader(
                          Icons.local_cafe_rounded,
                          'Fincanın Bölümleri',
                        ),
                        const SizedBox(height: 20),
                        _ExpandablePhotoItem(
                          file: _getImageForSection('cup_inside'),
                          title:
                              _readingData?['cup_inside']?['title'] ??
                              'Fincan İçi',
                          shortDesc:
                              _readingData?['cup_inside']?['short'] ??
                              'İç dünyan, düşüncelerin, duygusal halin.',
                          detailedDesc:
                              _readingData?['cup_inside']?['detailed'] ??
                              'Yorum yükleniyor...',
                          icon: Icons.local_cafe_rounded,
                          isExpanded: _expandedPhotoIndex == 0,
                          onTap: () {
                            setState(() {
                              _expandedPhotoIndex = _expandedPhotoIndex == 0
                                  ? null
                                  : 0;
                            });
                          },
                        ),
                        _ExpandablePhotoItem(
                          file: _getImageForSection('cup_side'),
                          title:
                              _readingData?['cup_side']?['title'] ??
                              'Fincan Kenarı',
                          shortDesc:
                              _readingData?['cup_side']?['short'] ??
                              'Yakın gelecek, haber, mesaj, görüşme.',
                          detailedDesc:
                              _readingData?['cup_side']?['detailed'] ??
                              'Yorum yükleniyor...',
                          icon: Icons.blur_circular_rounded,
                          isExpanded: _expandedPhotoIndex == 1,
                          onTap: () {
                            setState(() {
                              _expandedPhotoIndex = _expandedPhotoIndex == 1
                                  ? null
                                  : 1;
                            });
                          },
                        ),
                        _ExpandablePhotoItem(
                          file: _getImageForSection('cup_bottom'),
                          title:
                              _readingData?['cup_bottom']?['title'] ??
                              'Fincan Dibi',
                          shortDesc:
                              _readingData?['cup_bottom']?['short'] ??
                              'Geçmişten kalan konu, yük, kapanmamış mesele.',
                          detailedDesc:
                              _readingData?['cup_bottom']?['detailed'] ??
                              'Yorum yükleniyor...',
                          icon: Icons.fingerprint_rounded,
                          isExpanded: _expandedPhotoIndex == 2,
                          onTap: () {
                            setState(() {
                              _expandedPhotoIndex = _expandedPhotoIndex == 2
                                  ? null
                                  : 2;
                            });
                          },
                        ),
                        _ExpandablePhotoItem(
                          file: _getImageForSection('saucer'),
                          title: _readingData?['saucer']?['title'] ?? 'Tabak',
                          shortDesc:
                              _readingData?['saucer']?['short'] ??
                              'Dilek, sonuç, kısmet, son enerji.',
                          detailedDesc:
                              _readingData?['saucer']?['detailed'] ??
                              'Yorum yükleniyor...',
                          icon: Icons.radio_button_unchecked_rounded,
                          isExpanded: _expandedPhotoIndex == 3,
                          onTap: () {
                            setState(() {
                              _expandedPhotoIndex = _expandedPhotoIndex == 3
                                  ? null
                                  : 3;
                            });
                          },
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Telvelerin Anlattığı Hikaye (Ana Kart)
                _buildAnimatedResultChild(
                  0.1,
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF140F0C),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFD4A373).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(
                                  0xFFD4A373,
                                ).withOpacity(0.15),
                                border: Border.all(
                                  color: const Color(
                                    0xFFD4A373,
                                  ).withOpacity(0.4),
                                ),
                              ),
                              child: const Icon(
                                Icons.remove_red_eye_rounded,
                                color: Color(0xFFD4A373),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Telvelerin Anlattığı Hikaye',
                              style: GoogleFonts.playfairDisplay(
                                color: const Color(0xFFE8D5C4),
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _readingData?['story'] ?? 'Yorum yükleniyor...',
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 14,
                            height: 1.6,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Falında Görülen Semboller (Premium Grid)
                _buildAnimatedResultChild(
                  0.2,
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _isSymbolsExpanded = !_isSymbolsExpanded;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _isSymbolsExpanded
                            ? const Color(0xFF1C1714)
                            : const Color(0xFF140F0C),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isSymbolsExpanded
                              ? const Color(0xFFD4A373).withOpacity(0.4)
                              : const Color(0xFFD4A373).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildPremiumHeader(
                                  Icons.auto_awesome,
                                  'Falında Görülen Semboller',
                                ),
                              ),
                              AnimatedRotation(
                                turns: _isSymbolsExpanded ? 0.25 : 0,
                                duration: const Duration(milliseconds: 300),
                                child: Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.white.withOpacity(0.3),
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            alignment: Alignment.topCenter,
                            child: _isSymbolsExpanded
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: _buildSymbolChips(),
                                    ),
                                  )
                                : const SizedBox(
                                    width: double.infinity,
                                    height: 0,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Aşk Yorumu
                _buildAnimatedResultChild(
                  0.3,
                  _buildSectionCard(
                    'Aşk & İlişkiler',
                    _readingData?['love'] ?? 'Yorum yükleniyor...',
                  ),
                ),
                const SizedBox(height: 16),

                // 5. İş & Para Yorumu
                _buildAnimatedResultChild(
                  0.4,
                  _buildSectionCard(
                    'İş & Para',
                    _readingData?['career'] ?? 'Yorum yükleniyor...',
                  ),
                ),
                const SizedBox(height: 16),

                // 6. Aile & Çevre
                _buildAnimatedResultChild(
                  0.5,
                  _buildSectionCard(
                    'Aile & Yakın Çevre',
                    _readingData?['family'] ?? 'Yorum yükleniyor...',
                  ),
                ),
                const SizedBox(height: 16),

                // 7. Yakın Gelecek
                _buildAnimatedResultChild(
                  0.6,
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF140F0C),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFD4A373).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPremiumHeader(
                          Icons.timeline_rounded,
                          'Yakın Gelecek',
                        ),
                        const SizedBox(height: 20),
                        ..._buildTimelineItems(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 8. Dilek Mesajı
                _buildAnimatedResultChild(
                  0.7,
                  _buildSectionCard(
                    'Dilek Mesajı',
                    _readingData?['wish'] ?? 'Yorum yükleniyor...',
                    icon: Icons.auto_awesome_rounded,
                  ),
                ),
                const SizedBox(height: 16),

                // 9. Falının Sana Tavsiyesi
                _buildAnimatedResultChild(
                  0.8,
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF140F0C),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFD4A373).withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.stars_rounded,
                              color: Color(0xFFD4A373),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Falının Sana Tavsiyesi',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFD4A373),
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _readingData?['advice'] ?? 'Yorum yükleniyor...',
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 10. Alt Butonlar
                _buildAnimatedResultChild(
                  0.9,
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: const Color(0xFFD4A373).withOpacity(0.3),
                            ),
                            color: Colors.transparent,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.ios_share_rounded,
                                color: Color(0xFFD4A373),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Falımı Paylaş',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFFD4A373),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop('new');
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4A373),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.local_cafe_rounded,
                                color: Color(0xFF161311),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Yeni Fal Bak',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF161311),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. Yüzen ve Gradient Geçişli App Bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 24,
              left: 24,
              right: 24,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0C0A09),
                  const Color(0xFF0C0A09).withOpacity(0.95),
                  const Color(0xFF0C0A09).withOpacity(0.8),
                  const Color(0xFF0C0A09).withOpacity(0.0),
                ],
                stops: const [0.3, 0.6, 0.8, 1.0],
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white70,
                      size: 18,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'KAHVE FALI',
                      style: GoogleFonts.playfairDisplay(
                        color: const Color(0xFFE8D5C4),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 3.0,
                      ),
                    ),
                  ),
                ),
                // Sağ tarafı dengelemek için boşluk (Geri butonu genişliğinde)
                const SizedBox(width: 38),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- PREMIUM HELPER WIDGETS ---

  Widget _buildPremiumHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFD4A373), size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.outfit(
            color: const Color(0xFFE8D5C4),
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFD4A373).withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        const Icon(Icons.flare_rounded, color: Color(0xFFD4A373), size: 14),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HATA EKRANI
  // ═══════════════════════════════════════════════════════════════
  Widget _buildErrorScreen() {
    return Center(
      key: const ValueKey('error'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD4A373).withOpacity(0.1),
              ),
              child: const Icon(
                Icons.local_cafe_rounded,
                color: Color(0xFFD4A373),
                size: 48,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              _errorMessage,
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.7),
                fontSize: 15,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                if (_isValidationError) {
                  Navigator.of(context).pop('retake');
                } else {
                  setState(() {
                    _isLoading = true;
                    _hasError = false;
                    _loadingTextIndex = 0;
                  });
                  _callCoffeeApi();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: const Color(0xFFD4A373),
                ),
                child: Text(
                  _isValidationError ? 'Geri Dön & Yeniden Çek' : 'Tekrar Dene',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF161311),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (!_isValidationError)
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'İptal Et',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // DİNAMİK SEMBOL CHİPLERİ
  // ═══════════════════════════════════════════════════════════════
  List<Widget> _buildSymbolChips() {
    final symbols = _readingData?['symbols'] as List?;
    if (symbols == null || symbols.isEmpty) {
      return [
        _buildPremiumSymbolChip(Icons.auto_awesome, 'Sembol', 'Yükleniyor...'),
      ];
    }
    return symbols.map<Widget>((s) {
      final name = s['name']?.toString() ?? 'Sembol';
      final meaning = s['meaning']?.toString() ?? '';
      final iconName = s['icon']?.toString() ?? 'auto_awesome';
      return _buildPremiumSymbolChip(_iconFromString(iconName), name, meaning);
    }).toList();
  }

  // ═══════════════════════════════════════════════════════════════
  // DİNAMİK TİMELİNE ÖĞELERİ
  // ═══════════════════════════════════════════════════════════════
  List<Widget> _buildTimelineItems() {
    final nearFuture = _readingData?['near_future'] as List?;
    if (nearFuture == null || nearFuture.isEmpty) {
      return [
        _buildTimelineItem('Çok Yakında', 'Yorum yükleniyor...', isLast: true),
      ];
    }
    return List.generate(nearFuture.length, (i) {
      final item = nearFuture[i];
      return _buildTimelineItem(
        item['time']?.toString() ?? '',
        item['prediction']?.toString() ?? '',
        isLast: i == nearFuture.length - 1,
      );
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // İKON STRING → IconData DÖNÜŞTÜRÜCÜ
  // ═══════════════════════════════════════════════════════════════
  IconData _iconFromString(String name) {
    const iconMap = {
      'edit_road_rounded': Icons.edit_road_rounded,
      'flutter_dash_rounded': Icons.flutter_dash_rounded,
      'favorite_rounded': Icons.favorite_rounded,
      'vpn_key_rounded': Icons.vpn_key_rounded,
      'radio_button_unchecked_rounded': Icons.radio_button_unchecked_rounded,
      'access_time_rounded': Icons.access_time_rounded,
      'visibility_rounded': Icons.visibility_rounded,
      'pets_rounded': Icons.pets_rounded,
      'park_rounded': Icons.park_rounded,
      'water_drop_rounded': Icons.water_drop_rounded,
      'home_rounded': Icons.home_rounded,
      'mail_rounded': Icons.mail_rounded,
      'auto_awesome': Icons.auto_awesome,
      'local_cafe_rounded': Icons.local_cafe_rounded,
      'star_rounded': Icons.star_rounded,
      'nightlight_rounded': Icons.nightlight_rounded,
    };
    return iconMap[name] ?? Icons.auto_awesome;
  }

  Widget _buildSectionCard(
    String title,
    String content, {
    bool highlightTitle = false,
    IconData? icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF140F0C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4A373).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            _buildPremiumHeader(icon, title),
            const SizedBox(height: 16),
          ] else ...[
            Text(
              title,
              style: GoogleFonts.outfit(
                color: const Color(0xFFE8D5C4),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            content,
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSymbolChip(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: const Color(0xFFD4A373).withOpacity(0.2)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFD4A373).withOpacity(0.15),
            const Color(0xFFD4A373).withOpacity(0.02),
          ],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFD4A373), size: 16),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '$title — $subtitle',
              style: GoogleFonts.outfit(
                color: const Color(0xFFE8D5C4),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String time, String desc, {bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFD4A373),
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: const Color(0xFFD4A373).withOpacity(0.3),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFE8D5C4),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandablePhotoItem extends StatelessWidget {
  final File? file;
  final String title;
  final String shortDesc;
  final String detailedDesc;
  final IconData icon;
  final bool isLast;
  final bool isExpanded;
  final VoidCallback onTap;

  const _ExpandablePhotoItem({
    Key? key,
    required this.file,
    required this.title,
    required this.shortDesc,
    required this.detailedDesc,
    required this.icon,
    required this.isExpanded,
    required this.onTap,
    this.isLast = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isExpanded ? const Color(0xFF1C1714) : const Color(0xFF1A1512),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isExpanded
                ? const Color(0xFFD4A373).withOpacity(0.4)
                : const Color(0xFFD4A373).withOpacity(0.15),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFD4A373).withOpacity(0.5),
                      width: 1.5,
                    ),
                    color: file == null || !file!.existsSync() ? const Color(0xFFD4A373).withOpacity(0.1) : null,
                    image: file != null && file!.existsSync()
                        ? DecorationImage(
                            image: FileImage(file!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: file == null || !file!.existsSync()
                      ? Icon(
                          icon,
                          color: const Color(0xFFD4A373).withOpacity(0.5),
                          size: 24,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFD4A373).withOpacity(0.2),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFFD4A373).withOpacity(0.7),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFE8D5C4),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        shortDesc,
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withOpacity(0.3),
                    size: 20,
                  ),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: isExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(
                        top: 16,
                        bottom: 4,
                        left: 4,
                        right: 4,
                      ),
                      child: Text(
                        detailedDesc,
                        style: GoogleFonts.inter(
                          color: const Color(0xFFD4A373).withOpacity(0.9),
                          fontSize: 13,
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : const SizedBox(width: double.infinity, height: 0),
            ),
          ],
        ),
      ),
    );
  }
}

// Fincanın üzerinden çıkan minimalist "S" şeklinde çizgi duman
class SmokeWispPainter extends CustomPainter {
  final Color color;
  SmokeWispPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width / 2, size.height); // Alt orta
    // Zarif ve pürüzsüz bir 'S' harfi (Küpük Bezier)
    path.cubicTo(
      0,
      size.height * 0.75, // Sola çek
      size.width,
      size.height * 0.25, // Sağa çek
      size.width / 2,
      0, // Üst orta
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
