import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';
import '../constants/colors.dart';
import '../models/fortune.dart';
import '../services/storage_service.dart';
import '../services/ad_service.dart';
import 'share_modal.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../services/purchase_service.dart';
import '../services/sound_service.dart';
import '../models/cookie_card.dart';

class CookieSection extends StatefulWidget {
  final VoidCallback? onCookieTapped;
  final String? selectedCookieEmoji;
  final bool hideLabels;

  const CookieSection({
    super.key,
    this.onCookieTapped,
    this.selectedCookieEmoji,
    this.hideLabels = false,
  });

  @override
  State<CookieSection> createState() => _CookieSectionState();
}

class _CookieSectionState extends State<CookieSection>
    with TickerProviderStateMixin {
  static const double _cookieSize = 200;
  bool _isPressed = false;
  bool _showFortune = false;
  Fortune? _currentFortune;
  
  // Ticker yerine AnimationController.unbounded kullanıyoruz - En temiz çözüm
  late AnimationController _animationController; 

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _shakeController;
  late AnimationController _crackController;
  late AnimationController _sparkleController;
  bool _isCracking = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // ── Günlük kurabiye hakkı ──
  int _cracksToday = _cachedCracksToday;
  bool _dailyLimitReached = _cachedDailyLimitReached;
  bool _isPremiumUser = false;
  bool _showAdOverlay = false;
  bool _showLimitOverlay = false;

  // Statik cache: widget rebuild olsa bile flickerlamasın
  static int _cachedCracksToday = 0;
  static bool _cachedDailyLimitReached = false;
  static bool _cacheLoaded = false;
  static bool _debugResetDone = false;

  // Share özelliği
  final ScreenshotController _shareScreenshotController = ScreenshotController();
  bool _isSharing = false;
  bool _showShareButton = false;
  bool _isShareButtonPressed = false; // Tıklama/Bounce efekti için

  Future<void> _shareFortune() async {
    if (_currentFortune == null) return;
    
    // Cookie ismini dili baz alarak bulalım
    final String cookieEmoji = widget.selectedCookieEmoji ?? 'spring_wreath';
    final String lang = Localizations.localeOf(context).languageCode;
    
    const tr = {
      'spring_wreath': 'Bahar Çelengi', 'lucky_clover': 'Şanslı Yonca',
      'royal_hearts': 'Kraliyet Kalpleri', 'evil_eye': 'Nazar',
      'pizza_party': 'Pizza Partisi', 'sakura_bloom': 'Sakura',
      'blue_porcelain': 'Mavi Porselen', 'pink_blossom': 'Pembe Çiçek',
      'fortune_cat': 'Şans Kedisi', 'wildflower': 'Kır Çiçeği',
      'cupid_ribbon': 'Aşk Kurdelesi', 'panda_bamboo': 'Panda',
      'ramadan_cute': 'Ramazan', 'enchanted_forest': 'Büyülü Orman',
      'golden_arabesque': 'Altın Arabesk', 'midnight_mosaic': 'Gece Mozaiği',
      'pearl_lace': 'İnci Dantel', 'golden_sakura': 'Altın Sakura',
      'dragon_phoenix': 'Ejderha & Anka', 'gold_beasts': 'Altın Canavarlar',
    };
    const en = {
      'spring_wreath': 'Spring Wreath', 'lucky_clover': 'Lucky Clover',
      'royal_hearts': 'Royal Hearts', 'evil_eye': 'Evil Eye',
      'pizza_party': 'Pizza Party', 'sakura_bloom': 'Sakura Bloom',
      'blue_porcelain': 'Blue Porcelain', 'pink_blossom': 'Pink Blossom',
      'fortune_cat': 'Fortune Cat', 'wildflower': 'Wildflower',
      'cupid_ribbon': 'Cupid Ribbon', 'panda_bamboo': 'Panda Bamboo',
      'ramadan_cute': 'Ramadan', 'enchanted_forest': 'Enchanted Forest',
      'golden_arabesque': 'Golden Arabesque', 'midnight_mosaic': 'Midnight Mosaic',
      'pearl_lace': 'Pearl Lace', 'golden_sakura': 'Golden Sakura',
      'dragon_phoenix': 'Dragon Phoenix', 'gold_beasts': 'Gold Beasts',
    };
    
    final cookieName = (lang == 'tr' ? tr : en)[cookieEmoji] ?? cookieEmoji;

    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.88), // Biraz daha derinlik
      barrierDismissible: false,
      barrierLabel: 'ShareOptions',
      transitionDuration: const Duration(milliseconds: 450), // Daha sakin ve yumuşak süre
      pageBuilder: (context, animation, secondaryAnimation) {
        return ShareModal(
          fortune: _currentFortune!,
          cookieEmoji: cookieEmoji,
          lang: lang,
          cookieName: cookieName,
          imagePath: _cookieImageMap[cookieEmoji],
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // Yumuşacık bir kavis (Curve) oluştur: Açılırken easeOutCubic (yavaşlayarak oturur), Kapanırken easeInCubic
        final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
        
        return FadeTransition(
          opacity: curve, // Parlayarak beliriş
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(curve), // Aşağıdan süzülüş
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.94, end: 1.0).animate(curve), // Kibarca büyüme
              child: child,
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleShareTap() async {
    if (_isSharing) return; // Çifte tıklamayı veya işlem varken tekrar tetiklemeyi önle
    
    // Çok hızlı tıklansa bile (tek tıkta) efekti sonuna kadar göstermeye zorla:
    if (mounted) setState(() => _isShareButtonPressed = true);
    await Future.delayed(const Duration(milliseconds: 100)); // Küçülme süresi
    
    if (mounted) setState(() => _isShareButtonPressed = false);
    await Future.delayed(const Duration(milliseconds: 80)); // Geri büyüme hissi başlangıcı

    // Modal ekranına şimdi geç
    _shareFortune();
  }

  // Dışardan (ör. CookieSelector tap) çağrılınca mesajı kapat
  void hideFortune() {
    if (!_showFortune) return;
    setState(() {
      _showFortune = false;
      _currentFortune = null;
      _isPressed = false;
    });
  }

  @override
  void initState() {
    super.initState();
    // Önce cache’ten yükle (flicker olmasın), sonra async doğrula
    if (_cacheLoaded) {
      _cracksToday = _cachedCracksToday;
      _dailyLimitReached = _cachedDailyLimitReached;
    }
    _loadDailyCookieCredits();
    
    // Reklamı arka planda önden yükleyelim:
    AdService().loadRewardedAd();

    // Bounded Animation: 0’dan 2*pi’ye sürekli döngü
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
      upperBound: 2 * math.pi,
    );
    _animationController.repeat();

    // Glow animasyonu (2s, easeInOut, ileri-geri)
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
      value: 0.5,
    );
    _glowAnimation = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    );

    // Shake animasyonu
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Crack animasyonu
    _crackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    // Sparkle animasyonu
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void didUpdateWidget(covariant CookieSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Kurabiye seçimi değiştiğinde state’i koru (cache’ten oku)
    if (oldWidget.selectedCookieEmoji != widget.selectedCookieEmoji) {
      _cracksToday = _cachedCracksToday;
      _dailyLimitReached = _cachedDailyLimitReached;
    }
  }

  @override
  void dispose() {
    _animationController.dispose(); // Unbounded controller dispose ediliyor
    _glowController.dispose();
    _shakeController.dispose();
    _crackController.dispose();
    _sparkleController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }



  // Cookie görseli veya emoji göster
  Widget _buildCookieDisplay(String emoji) {
    final imageMap = _cookieImageMap;
    final imagePath = imageMap[emoji];
    final isPaid = _paidCookieIds.contains(emoji);

    Widget cookieWidget;

    if (imagePath != null) {
      cookieWidget = Image.asset(
        imagePath,
        width: _cookieSize,
        height: _cookieSize,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Text(
            emoji,
            style: TextStyle(
              fontSize: 92,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: const Color(0xFFF7941D).withOpacity(0.5),
                  blurRadius: 15,
                  offset: Offset.zero,
                ),
              ],
            ),
          );
        },
      );
    } else {
      cookieWidget = Text(
        emoji,
        style: TextStyle(
          fontSize: 92,
          color: Colors.white,
          shadows: [
            Shadow(
              color: const Color(0xFFF7941D).withOpacity(0.5),
              blurRadius: 15,
              offset: Offset.zero,
            ),
          ],
        ),
      );
    }

    if (!isPaid) return cookieWidget;

    // Ücretli kurabiye: bulanık + kilit ikonu
    return Stack(
      alignment: Alignment.center,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
          child: cookieWidget,
        ),
        // Kilit overlay
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.3),
            border: Border.all(
              color: const Color(0xFFFFD700).withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.2),
                blurRadius: 12,
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.lock_rounded, color: Color(0xFFFFD700), size: 22),
          ),
        ),
      ],
    );
  }

  String? _getCookieImagePath(String emoji) {
    return _cookieImageMap[emoji];
  }

  static const Map<String, String> _cookieImageMap = {
    'spring_wreath': 'assets/images/cookies/spring_wreath.webp',
    'lucky_clover': 'assets/images/cookies/lucky_clover.webp',
    'royal_hearts': 'assets/images/cookies/royal_hearts.webp',
    'evil_eye': 'assets/images/cookies/evil_eye.webp',
    'pizza_party': 'assets/images/cookies/pizza_party.webp',
    'sakura_bloom': 'assets/images/cookies/sakura_bloom.webp',
    'blue_porcelain': 'assets/images/cookies/blue_porcelain.webp',
    'pink_blossom': 'assets/images/cookies/pink_blossom.webp',
    'fortune_cat': 'assets/images/cookies/fortune_cat.webp',
    'wildflower': 'assets/images/cookies/wildflower.webp',
    'cupid_ribbon': 'assets/images/cookies/cupid_ribbon.webp',
    'panda_bamboo': 'assets/images/cookies/panda_bamboo.webp',
    'ramadan_cute': 'assets/images/cookies/ramadan_cute.webp',
    'enchanted_forest': 'assets/images/cookies/enchanted_forest.webp',
    'golden_arabesque': 'assets/images/cookies/golden_arabesque.webp',
    'midnight_mosaic': 'assets/images/cookies/midnight_mosaic.webp',
    'pearl_lace': 'assets/images/cookies/pearl_lace.webp',
    'golden_sakura': 'assets/images/cookies/golden_sakura.webp',
    'dragon_phoenix': 'assets/images/cookies/dragon_phoenix.webp',
    'gold_beasts': 'assets/images/cookies/gold_beasts.webp',
  };

  static const Set<String> _paidCookieIds = {
    'golden_arabesque',
    'midnight_mosaic',
    'pearl_lace',
    'golden_sakura',
    'dragon_phoenix',
    'gold_beasts',
  };

  Future<void> _loadDailyCookieCredits() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremiumUser = prefs.getBool('is_premium_test_mode') ?? false;

    // Debug: Hot restart'ta hakları sıfırla (SADECE 1 KEZ per session)
    // Production'da bu blok çalışmaz
    assert(() {
      if (!_debugResetDone) {
        _debugResetDone = true;
        prefs.setInt('cookie_cracks_today', 0);
        _cachedCracksToday = 0;
        _cachedDailyLimitReached = false;
        _cacheLoaded = false;
      }
      return true;
    }());

    final cracks = await StorageService.getCookieCracksToday();
    // Statik cache güncelle (tüm instance’lar için)
    _cachedCracksToday = cracks;
    _cachedDailyLimitReached = cracks >= StorageService.kMaxDailyCookieCracks;
    _cacheLoaded = true;
    if (mounted) {
      setState(() {
        _cracksToday = cracks;
        _dailyLimitReached = _cachedDailyLimitReached;
      });
    }
  }

  void _onCookieTap() async {
    if (_showFortune) return;

    // Ücretli kurabiye kontrolü
    final cookieId = widget.selectedCookieEmoji ?? 'spring_wreath';
    if (_paidCookieIds.contains(cookieId)) {
      final collection = await StorageService.getCookieCollection();
      final cookieCard = collection.firstWhere(
        (c) => c.id == cookieId,
        orElse: () => CookieCard(id: cookieId, emoji: '', name: '', rarity: ''),
      );

      if (cookieCard.countObtained > 0) {
        // Zaten sahip, kırmaya geç
        _performCrack();
      } else {
        // Sahip değil, satın alma dialogunu aç
        await _showPremiumDialog();
      }
      return;
    }

    // ── Günlük limit kontrolü (Herkes için 3/gün) ──
    final cracksUsed = await StorageService.getCookieCracksToday();

    // Premium test modunu gerçek zamanlı oku (Profilde kapatılmış olabilir)
    final prefs = await SharedPreferences.getInstance();
    _isPremiumUser = prefs.getBool('is_premium_test_mode') ?? false;

    // Limit doldu (hem ücretsiz hem premium için)
    if (cracksUsed >= StorageService.kMaxDailyCookieCracks) {
      HapticFeedback.heavyImpact();
      setState(() => _showLimitOverlay = true);
      return;
    }

    // Ücretsiz kullanıcı: 2. ve 3. hak için reklam gerekli
    if (!_isPremiumUser && cracksUsed >= 1) {
      setState(() => _showAdOverlay = true);
      return;
    }
    // Premium kullanıcı: reklam yok, doğrudan devam

    _performCrack();
  }

  // ── Reklam overlay'dan "izle" a tıklandı ──
  void _onAdAccepted() {
    setState(() => _showAdOverlay = false);
    
    AdService().showRewardedAd(
      () {
        // Kullanıcı reklamı başarıyla izledi ve ödülü hak etti:
        _performCrack();
      },
      () {
        // Kullanıcı reklamı kapattı veya hata oluştu
        // Bilgi verilebilir veya sessiz kalınabilir
      }
    );
  }

  // ── Reklam overlay'dan "vazgeç" a tıklandı ──
  void _onAdDeclined() {
    setState(() => _showAdOverlay = false);
  }

  // ── Limit overlay'dan "tamam" a tıklandı ──
  void _onLimitDismissed() {
    setState(() => _showLimitOverlay = false);
  }

  // ── Gerçek kurabiye kırma işlemi ──
  void _performCrack() async {
    final cookieId = widget.selectedCookieEmoji ?? 'spring_wreath';

    setState(() => _isPressed = true);

    final fortune = Fortune.getRandomFortuneInstant(
      languageCode: Localizations.localeOf(context).languageCode,
    );

    SoundService().playCookieBreak();

    setState(() => _isCracking = true);
    _crackController.forward(from: 0);

    await StorageService.recordCookieCrack();
    StorageService.incrementCookieCount();
    StorageService.consumeCookieCard(cookieId, isPaid: _paidCookieIds.contains(cookieId));

    final newCracks = await StorageService.getCookieCracksToday();
    final limitReached = newCracks >= StorageService.kMaxDailyCookieCracks;
    // Cache güncelle
    _cachedCracksToday = newCracks;
    _cachedDailyLimitReached = limitReached;

    setState(() {
      _currentFortune = fortune;
      _isPressed = false;
      _showFortune = true;
      _showShareButton = false;
      _cracksToday = newCracks;
      _dailyLimitReached = limitReached;
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted && _showFortune) {
        setState(() => _showShareButton = true);
      }
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() => _isCracking = false);
      }
    });
  }

  // ── Reklam overlay içeriği (buzlu cam / glassmorphism) ──
  Widget _buildAdOverlayContent() {
    return GestureDetector(
      onTap: _onAdAccepted,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // Normal beyaz cam efekti (Daha görünür ve belirgin)
          color: Colors.white.withOpacity(0.35), 
          border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5), 
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // Yüksek blur (gerçekçi cam)
            child: Center(
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white.withOpacity(0.95), // Saf parlak beyaz
                size: 42,
                shadows: [
                  // Sadece çok soft, zarif bir beyaz parlama
                  Shadow(color: Colors.white.withOpacity(0.4), blurRadius: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Limit overlay içeriği (buzlu cam / glassmorphism) ──
  Widget _buildLimitOverlayContent() {
    return const _CircularLimitOverlay();
  }
  Future<void> _showPremiumDialog() async {
    final cookieId = widget.selectedCookieEmoji ?? 'spring_wreath';
    final imagePath = _cookieImageMap[cookieId];
    final result = await Navigator.of(context).push<bool>(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, _, __) => _PremiumCookieOverlay(
          cookieId: cookieId,
          imagePath: imagePath,
        ),
      ),
    );

    if (result == true) {
      // Satın alındı, envantere ekle
      await StorageService.incrementCookieCard(cookieId);
      
      // Bildirim göster
      if (mounted) {
        final isTr = Localizations.localeOf(context).languageCode == 'tr';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isTr ? 'Kurabiye başarıyla "My Cookie" koleksiyonuna eklendi!' : 'Cookie successfully added to your "My Cookie" collection!',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFC084FC).withOpacity(0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // HTML'deki gibi: cookie-img width: 190px, height: 190px - tam ortada
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: 28,
          ), // Daha kompakt dikey alan
          alignment: Alignment.center, // Tam ortalama için
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // Yatay ortalama
            mainAxisSize: MainAxisSize.min, // Minimum alan kapla
            children: [
              // Sabit yükseklikte Stack: Fortune paper çıkınca layout yüksekliği değişmesin
              SizedBox(
                height: 260,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none, // Paper'ın kesilmemesi için
                  children: [
                    // 1. KAĞIT — kurabiyenin ARKASINDA (kırılınca arasından çıkar)
                    if (_showFortune && _currentFortune != null)
                      OverflowBox(
                        maxHeight: MediaQuery.of(context).size.height * 0.9,
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.55,
                          ),
                          child: _FortunePaper(
                            fortune: _currentFortune!,
                            cookieEmoji:
                                widget.selectedCookieEmoji ?? 'spring_wreath',
                            onAnimationComplete: () {},
                            screenshotController: _shareScreenshotController,
                          ),
                        ),
                      ),

                    // 2. KURABİYE — kağıdın ÜSTÜNDE
                    // Reklam beklenirken renkleri koruyup sadece hafif kararır. Hak bitince renksiz (greyscale) olur.
                    AnimatedOpacity(
                      opacity: _showLimitOverlay ? 0.35 : (_showAdOverlay ? 0.55 : (_dailyLimitReached ? 0.4 : 1.0)),
                      duration: const Duration(milliseconds: 500),
                      child: ColorFiltered(
                        colorFilter: (_dailyLimitReached || _showLimitOverlay)
                            ? const ColorFilter.matrix(<double>[
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0, 0, 0, 1, 0,
                              ])
                            : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                        child: IgnorePointer(
                      ignoring:
                          _showFortune || _showAdOverlay || _showLimitOverlay, // Overlay açıkken kurabiyeye alttan tıklanamaz
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          _glowAnimation,
                          _shakeController,
                          _crackController,
                        ]),
                        builder: (context, child) {
                          const shakeOffset = 0.0;
                          
                          // Glow pulsation
                          final glowT = _glowAnimation.value;
                          final glowOpacity = 0.28 + (0.20 * glowT); 
                          final glowBlur = 14.0 + (10.0 * glowT); 

                          return Transform.translate(
                            offset: Offset(shakeOffset, 0),
                            child: AnimatedBuilder(
                              animation: _animationController, // Unbounded controller
                              builder: (context, child) {
                                // "value" sürekli artıyor (saniyede 1.0 artacak şekilde ayarlandı)
                                // Sinüs/Kosinüs kullanarak sonsuz döngü elde ediyoruz.
                                final double t = _animationController.value; 

                                // 1. Dikey Hareket: Sinüs (-12px ... +12px) - BELİRGİN YUKARI AŞAĞI
                                final verticalOffset = 12.0 * math.sin(t); 

                                // 2. Yatay Salınım: Kosinüs (-3px ... +3px) - HAFİF YAN SALINIM
                                // Faz farkı (pi/2) doğal olarak var -> Elips hareket
                                final horizontalOffset = 3.0 * math.cos(t); 

                                // 3. Hafif Dönme (Tilt): Sinüs (Faz farkı ekleyelim)
                                final rotationTilt = 0.02 * math.sin(t + 1.0); 

                                return Transform(
                                  transform: Matrix4.identity()
                                    ..translate(
                                      horizontalOffset,
                                      _isPressed ? 0.0 : verticalOffset,
                                    )
                                    ..rotateZ(_isPressed ? 0.0 : rotationTilt),
                                  alignment: Alignment.center,
                                  child: child,
                                );
                              },
                              child: GestureDetector(
                                onTapDown: (_) {
                                  if (!_showFortune) {
                                    setState(() => _isPressed = true);
                                    SoundService().playCookieTap();
                                  }
                                },
                                onTapUp: (_) {
                                  if (!_showFortune) {
                                    _onCookieTap();
                                  }
                                },
                                onTapCancel: () {
                                  if (!_showFortune) {
                                    setState(() => _isPressed = false);
                                  }
                                },
                                child: AnimatedScale(
                                  scale: _isPressed ? 1.1 : 1.0,
                                  duration: const Duration(milliseconds: 150),
                                  child: Container(
                                    width: _cookieSize,
                                    height: _cookieSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.transparent,
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        if (!_isCracking && !_showFortune)
                                          RepaintBoundary(
                                            child: _CookieGlow(
                                              imagePath: _getCookieImagePath(
                                                widget.selectedCookieEmoji ?? 'spring_wreath',
                                              ),
                                              emoji:
                                                  widget.selectedCookieEmoji ??
                                                  'spring_wreath',
                                              size: _cookieSize,
                                              opacity: glowOpacity.clamp(0.0, 1.0),
                                              blurSigma: glowBlur,
                                            ),
                                          ),
                                        Center(
                                          child: (_isCracking || _showFortune)
                                              ? _CrackingCookie(
                                              size: _cookieSize,
                                                  progress: _crackController.value,
                                                  builder: (emoji) =>
                                                      _buildCookieDisplay(emoji),
                                                  emoji:
                                                      widget
                                                          .selectedCookieEmoji ??
                                                      'spring_wreath',
                                                )
                                              : _buildCookieDisplay(
                                                  widget.selectedCookieEmoji ??
                                                      'spring_wreath',
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),  // IgnorePointer
                    ),  // ColorFiltered
                    ),  // AnimatedOpacity
                    // 3. Dışına tıklayınca kapatan alan (en üstte)
                    if (_showFortune && _currentFortune != null)
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            setState(() {
                              _showFortune = false;
                              _currentFortune = null;
                            });
                          },
                        ),
                      ),
                    // ── 4. REKLAM OVERLAY — kurabiyenin tam üstünde, herhangi yere tıkla kapat ──
                    if (_showAdOverlay)
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _onAdDeclined,
                          child: Center(
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutBack,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
                                );
                              },
                              child: _buildAdOverlayContent(),
                            ),
                          ),
                        ),
                      ),
                    // ── 5. LİMİT OVERLAY — kurabiyenin tam üstünde, herhangi yere tıkla kapat ──
                    if (_showLimitOverlay)
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _onLimitDismissed,
                          child: Center(
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutBack,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
                                );
                              },
                              child: _buildLimitOverlayContent(),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (!widget.hideLabels) ...[
              const SizedBox(height: 10),
              Text(
                _dailyLimitReached
                    ? (Localizations.localeOf(context).languageCode == 'tr' ? 'Gün Tamamlandı' : 'Day Completed')
                    : l10n.dailyCookieTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _dailyLimitReached ? AppColors.textWhite.withOpacity(0.5) : AppColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              if (_dailyLimitReached)
                Text(
                  Localizations.localeOf(context).languageCode == 'tr' 
                      ? 'Yarın yeni şanslarla tekrar buluşalım.' 
                      : 'See you tomorrow with new cookies.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textWhite.withOpacity(0.4),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                )
              else if (!_isPremiumUser)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(StorageService.kMaxDailyCookieCracks, (i) {
                    final isUsed = i < _cracksToday;
                    final isNextFree = !isUsed && i == 0;
                    final needsAd = !isUsed && i > 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        width: isUsed ? 8 : 10,
                        height: isUsed ? 8 : 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isUsed
                              ? Colors.white.withOpacity(0.15)
                              : isNextFree || _cracksToday == 0
                                  ? const Color(0xFFF7941D)
                                  : const Color(0xFFF7941D).withOpacity(0.5),
                          border: !isUsed && needsAd && _cracksToday > 0
                              ? Border.all(color: const Color(0xFFF7941D).withOpacity(0.4), width: 1)
                              : null,
                          boxShadow: !isUsed
                              ? [BoxShadow(color: const Color(0xFFF7941D).withOpacity(0.3), blurRadius: 6)]
                              : null,
                        ),
                      ),
                    );
                  }),
                )
              else
                Text(
                  l10n.dailyCookieSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textWhite.withOpacity(0.6),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_showFortune)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                setState(() {
                  _showFortune = false;
                  _currentFortune = null;
                  _showShareButton = false;
                });
              },
            ),
          ),
        // Paylaş butonu — en üst katmanda, dismiss'in üstünde
        if (_showFortune && _currentFortune != null)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                offset: _showShareButton ? Offset.zero : const Offset(0, 1.5),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  opacity: _showShareButton ? 1.0 : 0.0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: _showShareButton ? (_) => mounted ? setState(() => _isShareButtonPressed = true) : null : null,
                    onTapUp: _showShareButton ? (_) => mounted ? setState(() => _isShareButtonPressed = false) : null : null,
                    onTapCancel: () => mounted ? setState(() => _isShareButtonPressed = false) : null,
                    onTap: _showShareButton ? _handleShareTap : null,
                    child: AnimatedScale(
                      scale: _isShareButtonPressed ? 0.88 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOutQuart,
                      child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.12),
                                border: Border.all(color: Colors.white.withOpacity(0.3), width: 0.5),
                              ),
                              child: Center(
                                child: _isSharing
                                    ? const SizedBox(
                                        height: 14, width: 14,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1.5),
                                      )
                                    : Icon(PhosphorIcons.paperPlaneTilt(PhosphorIconsStyle.fill), color: Colors.white, size: 17),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CrackingCookie extends StatelessWidget {
  final double size;
  final double progress; // 0 -> 1
  final String emoji;
  final Widget Function(String emoji) builder;

  const _CrackingCookie({
    required this.size,
    required this.progress,
    required this.builder,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    // HTML Referansı (crackLeftAnim / crackRightAnim):
    // 100% { transform: translateX(-40px) rotate(-20deg) translateY(30px); opacity: 0; }
    
    // Sol parça: Sola açıl, aşağı düş, sola dön ve kaybol
    final leftOffset = Offset(
      -75 * progress, // Daha fazla sola (40 -> 75)
      30 * progress, 
    );
    final leftRotation = -25 * (math.pi / 180) * progress; // -25 derece (daha fazla dönüş)

    // Sağ parça: Sağa açıl, aşağı düş, sağa dön ve kaybol
    final rightOffset = Offset(
      75 * progress, // Daha fazla sağa (40 -> 75)
      30 * progress, 
    );
    final rightRotation = 25 * (math.pi / 180) * progress; // 25 derece (daha fazla dönüş)

    // Opaklık: Sonlara doğru sıfıra düşsün
    final opacity = (1.0 - (progress * 1.5)).clamp(0.0, 1.0);

    return Opacity(
      opacity: opacity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [

      
          _CookieHalf(
            size: size,
            emoji: emoji,
            builder: builder,
            alignment: Alignment.centerLeft,
            offset: leftOffset,
            rotation: leftRotation,
          ),
          _CookieHalf(
            size: size,
            emoji: emoji,
            builder: builder,
            alignment: Alignment.centerRight,
            offset: rightOffset,
            rotation: rightRotation,
          ),
        ],
      ),
    );
  }

  Widget _buildCrumb({
    required double angle, 
    required double distance, 
    required double size,
    required Color color,
  }) {
    final rad = angle; 
    final dist = distance * progress;
    final dx = dist * math.sin(rad);
    final dy = dist * -math.cos(rad) + (40 * progress * progress); // Daha fazla yerçekimi
    
    return Positioned(
      child: Transform.translate(
        offset: Offset(dx, dy),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _CookieGlow extends StatelessWidget {
  final String? imagePath;
  final String emoji;
  final double size;
  final double opacity;
  final double blurSigma;

  const _CookieGlow({
    required this.imagePath,
    required this.emoji,
    required this.size,
    this.opacity = 0.6,
    this.blurSigma = 12,
  });

  @override
  Widget build(BuildContext context) {
    // Emoji veya görsel olmayan kurabiyeler için de hafif bir genel glow ver
    if (imagePath == null) {
      return IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: 1.12,
            child: Center(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: blurSigma,
                  sigmaY: blurSigma,
                ),
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFFFB464),
                    BlendMode.srcATop,
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 92, fontFamilyFallback: ['Apple Color Emoji'])),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Görselden türetilmiş blur + renk maskesi: cookie silüetine uyumlu glow
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: 1.12,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Color(0xFFFFB464),
                BlendMode.srcATop,
              ),
              child: Image.asset(
                imagePath!,
                width: size,
                height: size,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CookieHalf extends StatelessWidget {
  final double size;
  final String emoji;
  final Widget Function(String emoji) builder;
  final Alignment alignment;
  final Offset offset;
  final double rotation;

  const _CookieHalf({
    required this.size,
    required this.emoji,
    required this.builder,
    required this.alignment,
    required this.offset,
    required this.rotation,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if this is the left half based on alignment
    final isLeft = alignment == Alignment.centerLeft;

    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: offset,
        child: Transform.rotate(
          angle: rotation,
          child: ClipPath(
            clipper: _CookieCrackClipper(isLeft: isLeft),
            child: SizedBox(
              width: size,
              height: size,
              child: Center(child: builder(emoji)),
            ),
          ),
        ),
      ),
    );
  }
}

class _CookieCrackClipper extends CustomClipper<Path> {
  final bool isLeft;

  _CookieCrackClipper({required this.isLeft});

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    // Çapraz kırık: üstte sağdan başlayıp alta doğru sola gidiyor
    // Her noktada çapraz eksen + zikzak sapması var
    // Çapraz kayma: üstte +12px sağ, altta -12px sol
    double diagAt(double t) => cx + 12 - (24 * t); // t: 0..1 arası yüzde

    if (isLeft) {
      path.moveTo(0, 0);
      path.lineTo(diagAt(0) + 3, 0); // Üst: sağdan başla

      // Zikzaklı çapraz kırık hattı
      path.lineTo(diagAt(0.12) - 5, h * 0.12);
      path.lineTo(diagAt(0.25) + 7, h * 0.25);
      path.lineTo(diagAt(0.38) - 4, h * 0.38);
      path.lineTo(diagAt(0.50) + 6, h * 0.50);
      path.lineTo(diagAt(0.62) - 6, h * 0.62);
      path.lineTo(diagAt(0.75) + 5, h * 0.75);
      path.lineTo(diagAt(0.88) - 3, h * 0.88);
      path.lineTo(diagAt(1.0) - 2, h); // Alt: soldan bitir

      path.lineTo(0, h);
      path.lineTo(0, 0);
      path.close();
    } else {
      path.moveTo(w, 0);
      path.lineTo(diagAt(0) + 3, 0);

      // Sol ile aynı hattı izlemeli (boşluksuz kapanması için)
      path.lineTo(diagAt(0.12) - 5, h * 0.12);
      path.lineTo(diagAt(0.25) + 7, h * 0.25);
      path.lineTo(diagAt(0.38) - 4, h * 0.38);
      path.lineTo(diagAt(0.50) + 6, h * 0.50);
      path.lineTo(diagAt(0.62) - 6, h * 0.62);
      path.lineTo(diagAt(0.75) + 5, h * 0.75);
      path.lineTo(diagAt(0.88) - 3, h * 0.88);
      path.lineTo(diagAt(1.0) - 2, h);

      path.lineTo(w, h);
      path.lineTo(w, 0);
      path.close();
    }

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _FortunePaper extends StatefulWidget {
  final Fortune fortune;
  final String cookieEmoji; // Seçili cookie emojisi
  final VoidCallback onAnimationComplete;
  final ScreenshotController? screenshotController;

  const _FortunePaper({
    required this.fortune,
    required this.cookieEmoji,
    required this.onAnimationComplete,
    this.screenshotController,
  });

  @override
  State<_FortunePaper> createState() => _FortunePaperState();
}

class _FortunePaperState extends State<_FortunePaper>
    with TickerProviderStateMixin {
  late AnimationController _anim;
  late AnimationController _wave;
  final AudioPlayer _audioPlayer = AudioPlayer();

  static const Map<String, String> _cookieImageMap = {
    'spring_wreath': 'assets/images/cookies/spring_wreath.webp',
    'lucky_clover': 'assets/images/cookies/lucky_clover.webp',
    'royal_hearts': 'assets/images/cookies/royal_hearts.webp',
    'evil_eye': 'assets/images/cookies/evil_eye.webp',
    'pizza_party': 'assets/images/cookies/pizza_party.webp',
    'sakura_bloom': 'assets/images/cookies/sakura_bloom.webp',
    'blue_porcelain': 'assets/images/cookies/blue_porcelain.webp',
    'pink_blossom': 'assets/images/cookies/pink_blossom.webp',
    'fortune_cat': 'assets/images/cookies/fortune_cat.webp',
    'wildflower': 'assets/images/cookies/wildflower.webp',
    'cupid_ribbon': 'assets/images/cookies/cupid_ribbon.webp',
    'panda_bamboo': 'assets/images/cookies/panda_bamboo.webp',
    'ramadan_cute': 'assets/images/cookies/ramadan_cute.webp',
    'enchanted_forest': 'assets/images/cookies/enchanted_forest.webp',
    'golden_arabesque': 'assets/images/cookies/golden_arabesque.webp',
    'midnight_mosaic': 'assets/images/cookies/midnight_mosaic.webp',
    'pearl_lace': 'assets/images/cookies/pearl_lace.webp',
    'golden_sakura': 'assets/images/cookies/golden_sakura.webp',
    'dragon_phoenix': 'assets/images/cookies/dragon_phoenix.webp',
    'gold_beasts': 'assets/images/cookies/gold_beasts.webp',
  };

  static String _cookieNameForPaper(String id, String lang) {
    const tr = {
      'spring_wreath': 'Bahar Çelengi', 'lucky_clover': 'Şanslı Yonca',
      'royal_hearts': 'Kraliyet Kalpleri', 'evil_eye': 'Nazar',
      'pizza_party': 'Pizza Partisi', 'sakura_bloom': 'Sakura',
      'blue_porcelain': 'Mavi Porselen', 'pink_blossom': 'Pembe Çiçek',
      'fortune_cat': 'Şans Kedisi', 'wildflower': 'Kır Çiçeği',
      'cupid_ribbon': 'Aşk Kurdelesi', 'panda_bamboo': 'Panda',
      'ramadan_cute': 'Ramazan', 'enchanted_forest': 'Büyülü Orman',
      'golden_arabesque': 'Altın Arabesk', 'midnight_mosaic': 'Gece Mozaiği',
      'pearl_lace': 'İnci Dantel', 'golden_sakura': 'Altın Sakura',
      'dragon_phoenix': 'Ejderha & Anka', 'gold_beasts': 'Altın Canavarlar',
    };
    const en = {
      'spring_wreath': 'Spring Wreath', 'lucky_clover': 'Lucky Clover',
      'royal_hearts': 'Royal Hearts', 'evil_eye': 'Evil Eye',
      'pizza_party': 'Pizza Party', 'sakura_bloom': 'Sakura Bloom',
      'blue_porcelain': 'Blue Porcelain', 'pink_blossom': 'Pink Blossom',
      'fortune_cat': 'Fortune Cat', 'wildflower': 'Wildflower',
      'cupid_ribbon': 'Cupid Ribbon', 'panda_bamboo': 'Panda Bamboo',
      'ramadan_cute': 'Ramadan', 'enchanted_forest': 'Enchanted Forest',
      'golden_arabesque': 'Golden Arabesque', 'midnight_mosaic': 'Midnight Mosaic',
      'pearl_lace': 'Pearl Lace', 'golden_sakura': 'Golden Sakura',
      'dragon_phoenix': 'Dragon Phoenix', 'gold_beasts': 'Gold Beasts',
    };
    return (lang == 'tr' ? tr : en)[id] ?? id;
  }

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _wave = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _anim.forward().then((_) {
      if (mounted) {
        widget.onAnimationComplete();
        _wave.repeat();
      }
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    _wave.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: Listenable.merge([_anim, _wave]),
      builder: (context, _) {
        final t = _anim.value;
        if (t == 0) return const SizedBox();

        // Yumuşak fazlar — birbirine yumuşakça akar
        final riseT = Curves.easeOutQuart.transform((t / 0.35).clamp(0.0, 1.0));
        final unfoldT = Curves.easeInOutQuart.transform(((t - 0.2) / 0.55).clamp(0.0, 1.0));
        final contentT = Curves.easeOut.transform(((t - 0.75) / 0.25).clamp(0.0, 1.0));

        // Boyut: küçük parça → tam boyut (yumuşak geçiş)
        final paperWidth = 24.0 + (unfoldT * (screenWidth * 0.85 - 24.0));
        final paperHeight = 16.0 + (unfoldT * 160.0);
        // Scale: 0.15 → 1.0 (çok küçükten başlar)
        final scale = 0.15 + (riseT * 0.85);
        // Y pozisyonu: yumuşak yükseliş
        final yOffset = 35.0 * (1.0 - riseT);
        // Çok hafif sallanma
        final wobble = math.sin(t * math.pi * 1.5) * 1.5 * (1.0 - unfoldT);
        // Opacity: yumuşak belirir
        final opacity = Curves.easeOut.transform((t / 0.15).clamp(0.0, 1.0));

        // Dalgalanma
        final waveT = _wave.value;
        final waveX = math.sin(waveT * math.pi * 2) * 1.5;
        final waveY = math.cos(waveT * math.pi * 2) * 0.8;
        final waveRotate = math.sin(waveT * math.pi * 2) * 0.005;

        return Transform.translate(
          offset: Offset(wobble + waveX, yOffset + waveY),
          child: Transform.scale(
            scale: scale,
            child: Transform.rotate(
              angle: waveRotate,
              child: Opacity(
                opacity: opacity,
                child: Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Screenshot(
                        controller: widget.screenshotController ?? ScreenshotController(),
                        child: SizedBox(
                          width: paperWidth,
                          height: paperHeight,
                          child: Stack(
                            children: [
                              // Gölge (kağıdın arkası)
                              Positioned.fill(
                                child: Container(
                                  margin: const EdgeInsets.only(top: 2, left: 1),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2 * opacity),
                                        blurRadius: 18,
                                        offset: const Offset(0, 6),
                                        spreadRadius: -2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Kağıt — yırtık kenarlarla
                              Positioned.fill(
                                child: ClipPath(
                                  clipper: _TornPaperClipper(),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    color: const Color(0xFFF2E8D5),
                                    child: Stack(
                                      children: [
                                        // Hafif buruşukluk
                                        Positioned(
                                          right: 22, top: 14,
                                          child: Transform.rotate(
                                            angle: 0.3,
                                            child: Container(width: 14, height: 0.3, color: Colors.black.withOpacity(0.04)),
                                          ),
                                        ),
                                        Positioned(
                                          left: 28, bottom: 22,
                                          child: Transform.rotate(
                                            angle: -0.15,
                                            child: Container(width: 16, height: 0.3, color: Colors.black.withOpacity(0.03)),
                                          ),
                                        ),
                                        // İçerik
                                        Positioned.fill(
                                          child: Opacity(
                                            opacity: contentT,
                                            child: SingleChildScrollView(
                                              physics: const NeverScrollableScrollPhysics(),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // Kurabiye görseli
                                                  Builder(
                                                    builder: (context) {
                                                      final imagePath = _cookieImageMap[widget.cookieEmoji];
                                                      if (imagePath != null) {
                                                        return Image.asset(
                                                          imagePath,
                                                          width: 28,
                                                          height: 28,
                                                          fit: BoxFit.contain,
                                                          errorBuilder: (_, __, ___) =>
                                                              Icon(Icons.auto_awesome, color: const Color(0xFFB8963E).withOpacity(0.6), size: 13),
                                                        );
                                                      }
                                                      return Icon(Icons.auto_awesome, color: const Color(0xFFB8963E).withOpacity(0.6), size: 13);
                                                    },
                                                  ),
                                                  const SizedBox(height: 2),
                                                  // Kurabiye adı (lokalize)
                                                  Text(
                                                    _cookieNameForPaper(widget.cookieEmoji, Localizations.localeOf(context).languageCode),
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      color: Color(0xFF5A3D28),
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w600,
                                                      letterSpacing: 0.3,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Container(
                                                    width: 20, height: 0.5,
                                                    color: const Color(0xFFCBB98A).withOpacity(0.5),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    widget.fortune.meaning,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      color: Color(0xFF1E140C), // Adeta bir mürekkep gibi kapkara/koyu sepia
                                                      fontSize: 12.0, // Font bir tık büyütüldü
                                                      fontWeight: FontWeight.w600, // Orta incelikten yarı kalına (çok daha net)
                                                      height: 1.35, // Satır arası biraz ferahlatıldı
                                                      letterSpacing: 0.2, // Kelimeler arası esneklik verildi
                                                    ),
                                                  ),
                                                  const SizedBox(height: 24),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withOpacity(0.3), // Daha temiz bir zemin
                                                      border: Border.all(color: const Color(0xFFCBB98A).withOpacity(0.5), width: 0.5), // Keskin sınır
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                        _LuckyItem(label: l10n.luckyNumber, value: '${widget.fortune.luckyNumber}', icon: Icons.confirmation_number_rounded, compact: true),
                                                        Container(width: 0.8, height: 10, color: const Color(0xFFB8963E).withOpacity(0.3)), // Daha belirgin ayrım 
                                                        _LuckyItem(label: l10n.luckyColor, value: widget.fortune.luckyColor, icon: Icons.palette_rounded, compact: true),
                                                        Container(width: 0.8, height: 10, color: const Color(0xFFB8963E).withOpacity(0.3)),
                                                        _LuckyItem(label: l10n.luckLabel, value: '${widget.fortune.luckPercent}%', icon: Icons.auto_graph_rounded, compact: true),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LuckyItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final bool compact;

  const _LuckyItem({
    required this.label,
    required this.value,
    this.icon,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    // Compact mod için daha zarif, minik ama "okunabilir" boyut ayarları
    final double iconSize = compact ? 11 : 20;
    final double labelSize = compact ? 5.5 : 8;
    final double valueSize = compact ? 9 : 11;
    final double spacing = compact ? 1.5 : 4;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: iconSize,
              color: const Color(0xFF9E7B4F), // Daha koyu, daha okunabilir tok altın/bronz
            ),
            SizedBox(height: spacing),
          ],
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF7A6B63), // Uçuk mor yerine kağıda zıt, tok bir vizon/kahve
              fontSize: labelSize,
              fontWeight: FontWeight.w700, // Çok küçük olduğu için weight artırıldı (okunabilirlik)
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: compact ? 1 : 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF2B1636), // Silik mor yerine kapkaranlık, mürekkep moru/siyah (Çok net)
              fontSize: valueSize,
              fontWeight: FontWeight.w800, // Okunması için ekstra kalın
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// Dashed line painter (HTML'deki dashed border için)
class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashSpace;

  _DashedLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashLength, size.height / 2),
        paint,
      );
      startX += dashLength + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Yırtık kağıt kenar efekti
class _TornPaperClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    // Üst kenar
    path.moveTo(0, 0);
    for (double x = 0; x <= w; x += 1) {
      final y = math.sin(x * 0.12) * 0.4 + math.sin(x * 0.35) * 0.2;
      path.lineTo(x, y + 0.6);
    }

    // Sağ kenar
    for (double y = 0; y <= h; y += 1) {
      final x = w - 0.6 + math.sin(y * 0.15) * 0.4 + math.sin(y * 0.4) * 0.2;
      path.lineTo(x, y);
    }

    // Alt kenar
    for (double x = w; x >= 0; x -= 1) {
      final y = h - 0.6 + math.sin(x * 0.14) * 0.5 + math.sin(x * 0.38) * 0.2;
      path.lineTo(x, y);
    }

    // Sol kenar
    for (double y = h; y >= 0; y -= 1) {
      final x = 0.6 + math.sin(y * 0.16) * 0.4 + math.sin(y * 0.42) * 0.2;
      path.lineTo(x, y);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ── Premium Kurabiye Buzlu Cam Paneli ──
class _PremiumCookieOverlay extends StatefulWidget {
  final String cookieId;
  final String? imagePath;

  const _PremiumCookieOverlay({
    required this.cookieId,
    this.imagePath,
  });

  @override
  State<_PremiumCookieOverlay> createState() => _PremiumCookieOverlayState();
}

class _PremiumCookieOverlayState extends State<_PremiumCookieOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _slideAnim;
  late final Animation<double> _scaleAnim;

  // Kurabiye bilgileri
  static const Map<String, Map<String, String>> _cookieInfo = {
    'golden_arabesque': {
      'tr': 'Altın Arabesk',
      'en': 'Golden Arabesque',
      'rarity': 'rare',
    },
    'midnight_mosaic': {
      'tr': 'Gece Mozaiği',
      'en': 'Midnight Mosaic',
      'rarity': 'rare',
    },
    'pearl_lace': {
      'tr': 'İnci Dantel',
      'en': 'Pearl Lace',
      'rarity': 'rare',
    },
    'golden_sakura': {
      'tr': 'Altın Sakura',
      'en': 'Golden Sakura',
      'rarity': 'legendary',
    },
    'dragon_phoenix': {
      'tr': 'Ejderha & Anka',
      'en': 'Dragon & Phoenix',
      'rarity': 'legendary',
    },
    'gold_beasts': {
      'tr': 'Altın Canavarlar',
      'en': 'Gold Beasts',
      'rarity': 'legendary',
    },
  };

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<double>(begin: 80, end: 0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool _closing = false;
  bool _isPurchasing = false;

  void _close() {
    if (_closing) return;
    _closing = true;
    _ctrl.reverse().then((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  Future<void> _handlePurchase() async {
    if (_isPurchasing) return;
    HapticFeedback.mediumImpact();
    setState(() => _isPurchasing = true);

    try {
      // Kurabiye ID'sine göre ürün ID'sini belirle
      final productId = 'cookie_${widget.cookieId}';
      final success = await PurchaseService().purchase(productId);

      if (success) {
        if (mounted) Navigator.pop(context, true);
      } else if (mounted) {
        HapticFeedback.heavyImpact();
        final isTr = Localizations.localeOf(context).languageCode == 'tr';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isTr ? 'Şu anda satın alma yapılamıyor.' : 'Purchase unavailable right now.',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent.withOpacity(0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      debugPrint('Kurabiye satın alma hatası: $e');
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return SizedBox.expand(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Listener(
                    onPointerMove: (_) => _close(),
                    behavior: HitTestBehavior.translucent,
                    child: GestureDetector(
                      onTap: _close,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        color: Colors.black.withOpacity(0.45 * _fadeAnim.value),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: Transform.translate(
                          offset: Offset(0, _slideAnim.value - 90),
                          child: Transform.scale(
                            scale: _scaleAnim.value,
                            child: GestureDetector(
                              onTap: () {},
                              onVerticalDragStart: (_) => _close(),
                              onHorizontalDragStart: (_) => _close(),
                              child: _buildGlassPanel(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGlassPanel() {
    final isTr = Localizations.localeOf(context).languageCode == 'tr';
    final info = _cookieInfo[widget.cookieId] ?? _cookieInfo['golden_arabesque']!;
    final cookieName = isTr ? info['tr']! : info['en']!;
    final isLegendary = info['rarity'] == 'legendary';
    final rarityLabel = isLegendary
        ? (isTr ? 'Efsanevi' : 'Legendary')
        : (isTr ? 'Nadir' : 'Rare');
    final rarityColor = isLegendary
        ? const Color(0xFFE8A0FF) // Mor-lila
        : const Color(0xFF7DD4FF); // Açık mavi

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 42),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18), // 40 → 18 (performans)
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withOpacity(0.35),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Kurabiye görseli + nadirlik badge ──
                SizedBox(
                  width: 76,
                  height: 76,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                    // Kurabiye görseli — hafif bulanık
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.12),
                            Colors.white.withOpacity(0.04),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.20),
                          width: 0.6,
                        ),
                      ),
                      child: Center(
                        child: widget.imagePath != null
                            ? ImageFiltered(
                                imageFilter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                                child: Image.asset(
                                  widget.imagePath!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.contain,
                                ),
                              )
                            : const Text('🥠', style: TextStyle(fontSize: 36, fontFamilyFallback: ['Apple Color Emoji'])),
                      ),
                    ),
                    // Nadirlik badge — sağ üstte
                    Positioned(
                      top: -4,
                      right: -24,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: rarityColor.withOpacity(0.20),
                          border: Border.all(
                            color: rarityColor.withOpacity(0.40),
                            width: 0.6,
                          ),
                        ),
                        child: Text(
                          rarityLabel,
                          style: TextStyle(
                            color: rarityColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                ),
                const SizedBox(height: 12),
                // ── Kurabiye adı ──
                Text(
                  cookieName,
                  style: const TextStyle(
                    color: Color(0xFFF5EDE4),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isTr ? 'Premium Koleksiyon' : 'Premium Collection',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                // ── Fiyat + Satın Al Butonu ──
                _PurchaseButton(
                  isPurchasing: _isPurchasing,
                  label: isTr ? 'Satın Al (₺29.99)' : 'Purchase (\$0.99)',
                  onTap: _handlePurchase,
                ),
                const SizedBox(height: 8),
                // ── Kapat ipucu ──
                Text(
                  isTr ? 'Kapatmak için dışına dokun' : 'Tap outside to close',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.25),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white.withOpacity(0.08),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 0.5,
            ),
          ),
          child: Center(
            child: Icon(icon, size: 16, color: iconColor),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
   }
}

// ── Satın Al Butonu (Tıklama Efekti + Haptic + Loading) ──
class _PurchaseButton extends StatefulWidget {
  final bool isPurchasing;
  final String label;
  final VoidCallback onTap;

  const _PurchaseButton({
    required this.isPurchasing,
    required this.label,
    required this.onTap,
  });

  @override
  State<_PurchaseButton> createState() => _PurchaseButtonState();
}

class _PurchaseButtonState extends State<_PurchaseButton> with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails _) {
    setState(() => _scale = 0.94);
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _scale = 1.0);
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFF4EE6C5).withOpacity(0.15),
            border: Border.all(
              color: const Color(0xFF4EE6C5).withOpacity(0.40),
              width: 0.6,
            ),
          ),
          child: Center(
            child: widget.isPurchasing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF4EE6C5),
                    ),
                  )
                : Text(
                    widget.label,
                    style: const TextStyle(
                      color: Color(0xFF4EE6C5),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _CircularLimitOverlay extends StatefulWidget {
  const _CircularLimitOverlay();

  @override
  State<_CircularLimitOverlay> createState() => _CircularLimitOverlayState();
}

class _CircularLimitOverlayState extends State<_CircularLimitOverlay> {
  late Timer _timer;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _updateProgress();
    // 5 saniyede bir güncellese bile progress pürüzsüz artar
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _updateProgress();
    });
  }

  void _updateProgress() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final nextMidnight = startOfDay.add(const Duration(days: 1));
    
    final totalSeconds = nextMidnight.difference(startOfDay).inSeconds;
    final elapsedSeconds = now.difference(startOfDay).inSeconds;
    
    if (mounted) {
      setState(() {
        _progress = elapsedSeconds / totalSeconds;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1E1E2C).withOpacity(0.65),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Center(
                child: Icon(
                  Icons.nights_stay_rounded,
                  color: Colors.white.withOpacity(0.9),
                  size: 34, // Gece ikonu
                ),
              ),
            ),
          ),
          CircularProgressIndicator(
            value: _progress,
            strokeWidth: 1.5,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }
}
