import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';
import '../constants/colors.dart';
import '../models/fortune.dart';
import '../services/storage_service.dart';

class CookieSection extends StatefulWidget {
  final VoidCallback? onCookieTapped;
  final String? selectedCookieEmoji;
  final bool hideLabels; // Sadece kurabiye göster, yazıları gizle

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
  int _paperVersion = 0;
  int _tapFlowId = 0;
  late AnimationController _animationController;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _shakeController;
  late AnimationController _crackController;
  late AnimationController _sparkleController;
  bool _isCracking = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Dışardan çağrılınca fortune/animasyon durumunu temizle
  void hideFortune() {
    _tapFlowId++; // Devam eden tap/animasyon akışlarını iptal et
    setState(() {
      _showFortune = false;
      _currentFortune = null;
      _isPressed = false;
      _isCracking = false;
      _crackController.stop();
      _crackController.reset();
      _shakeController.stop();
      _shakeController.reset();
    });
  }

  @override
  void initState() {
    super.initState();
    // Floating animasyonu - gerçek zamanlı sin dalgası
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6280), // ~2π saniye
    )..repeat(); // sadece tick için

    // Glow animasyonu (2s, easeInOut, ileri-geri)
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
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
      duration: const Duration(milliseconds: 900),
    );

    // Sparkle animasyonu
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _glowController.dispose();
    _shakeController.dispose();
    _crackController.dispose();
    _sparkleController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // Ses efektlerini çal
  Future<void> _playSound(String soundFile) async {
    // Şimdilik tüm sesler kapalı
    return;
  }

  // Cookie görseli veya emoji göster
  Widget _buildCookieDisplay(String emoji) {
    // Görsel olan cookie'ler için asset kullan
    final imageMap = _cookieImageMap;
    // Eğer görsel varsa göster, yoksa emoji göster
    final imagePath = imageMap[emoji];
    if (imagePath != null) {
      return Image.asset(
        imagePath,
        width: _cookieSize,
        height: _cookieSize,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Görsel yoksa emoji göster
          return Text(
            emoji,
            style: TextStyle(
              fontSize: 92,
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
    }

    // Emoji göster
    return Text(
      emoji,
      style: TextStyle(
        fontSize: 92, // HTML: cookie-emoji font-size: 85px
        // HTML: filter: drop-shadow(0 0 15px rgba(247,148,29,0.5))
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

  String? _getCookieImagePath(String emoji) {
    return _cookieImageMap[emoji];
  }

  static const Map<String, String> _cookieImageMap = {
    '🏯': 'assets/images/cookie_torii.png',
    '🎃': 'assets/images/cookie_halloween.png',
    'ramazan': 'assets/images/cookie_ramazan.png',
    'noel': 'assets/images/cookie_noel.png',
    'anne': 'assets/images/cookie_anne.png',
  };

  void _onCookieTap() async {
    // Fortune açıksa veya kırılma devam ediyorsa tekrar tetiklenmesin
    if (_showFortune) {
      hideFortune();
      return;
    }
    if (_isCracking) {
      return;
    }

    final flowId = ++_tapFlowId;

    // 1️⃣ BASMA HİSSİ - parmak basıyormuş gibi
    setState(() {
      _isPressed = true;
    });
    if (!_shakeController.isAnimating) {
      _shakeController.repeat();
    }
    _playSound('cookie_tap.mp3');

    // 120ms basılı kal
    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted || flowId != _tapFlowId) return;

    // 2️⃣ KIRILMA BAŞLAT
    if (!mounted) return;
    _shakeController.stop();
    _shakeController.reset();
    setState(() => _isCracking = true);

    // Çatlak sesi (biraz gecikmeli)
    Future.delayed(const Duration(milliseconds: 80), () {
      _playSound('cookie_crack.mp3');
    });

    // Parlama sesi
    Future.delayed(const Duration(milliseconds: 300), () {
      _playSound('cookie_sparkle.mp3');
    });

    // Cookie sayısını ve koleksiyon kartını artır
    await StorageService.incrementCookieCount();
    await StorageService.incrementCookieCard(
      widget.selectedCookieEmoji ?? '🏯',
    );

    // Basılı hissi bırak (kırılma başladıktan sonra)
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() => _isPressed = false);
      }
    });

    // Kırılma animasyonu tamamlanınca normal hale dön
    await _crackController.forward(from: 0);
    if (!mounted || flowId != _tapFlowId) return;

    final languageCode = Localizations.localeOf(context).languageCode;
    final fortune = await Fortune.getRandomFortune(languageCode: languageCode);
    if (!mounted || flowId != _tapFlowId) return;

    setState(() {
      _isCracking = false;
      _showFortune = true;
      _currentFortune = fortune;
      _paperVersion++;
    });
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
                    // ÖNEMLİ: Stack'te sıralama - ÖNCE cookie (arkada), SONRA fortune paper (üstte)
                    // Işık halkası (HTML'deki glow efekti) - cookie ile birlikte
                    if (_isPressed)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 800),
                        width: 230,
                        height: 230,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(
                                0xFFF7941D,
                              ).withOpacity(0.4), // HTML: rgba(247,148,29,0.4)
                              const Color(0xFFF7941D).withOpacity(0.2),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.4, 0.7],
                          ),
                        ),
                      ),
                    // Crack animasyonu (HTML'deki gibi) - cookie ile birlikte
                    if (_isCracking)
                      AnimatedBuilder(
                        animation: _crackController,
                        builder: (context, child) {
                          return Stack(
                            children: [
                              // Sol crack çizgisi
                              Positioned(
                                left: 50,
                                top: 50,
                                child: Transform.rotate(
                                  angle: -0.3 * _crackController.value,
                                  child: Opacity(
                                    opacity: _crackController.value,
                                    child: Container(
                                      width: 60,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.8),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Sağ crack çizgisi
                              Positioned(
                                right: 50,
                                top: 50,
                                child: Transform.rotate(
                                  angle: 0.3 * _crackController.value,
                                  child: Opacity(
                                    opacity: _crackController.value,
                                    child: Container(
                                      width: 60,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.8),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    // Kurabiye butonu (HTML: cookie-img 190x190px, cookie-emoji font-size: 85px)
                    // Paper açıkken kurabiye görünmemeli; kağıt kapanınca geri gelmeli
                    AnimatedOpacity(
                      opacity: _showFortune ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      child: IgnorePointer(
                        ignoring: _showFortune,
                        child: AnimatedBuilder(
                          animation: Listenable.merge([
                            _animationController,
                            _glowAnimation,
                            _shakeController,
                          ]),
                          builder: (context, child) {
                            // Shake animasyonu - HTML'deki gibi
                            final shakeOffsetX = (_isPressed && !_isCracking)
                                ? math.sin(
                                        _shakeController.value * math.pi * 6,
                                      ) *
                                      0.8
                                : 0.0;
                            final speed = 2.0; // daha hızlı
                            final time =
                                DateTime.now().millisecondsSinceEpoch / 1000.0;
                            final floatOffset =
                                math.sin(time * 1.0 * speed) * 8;
                            final floatRotate =
                                math.sin(time * 0.7 * speed) * 0.03;
                            // Glow pulsation (sadece silüet maskesine uygulanıyor)
                            final glowT = _glowAnimation.value;
                            final glowOpacity =
                                0.28 +
                                (0.20 * glowT); // 0.28 → 0.48 (daha soluk)
                            final glowBlur =
                                14.0 +
                                (10.0 * glowT); // 14 → 24 (biraz daha geniş)

                            final disableFloat = _isPressed || _isCracking;
                            return Transform.translate(
                              offset: Offset(
                                shakeOffsetX,
                                disableFloat ? 0 : -floatOffset,
                              ),
                              child: Transform.rotate(
                                angle: disableFloat ? 0 : floatRotate,
                                child: GestureDetector(
                                  onTapDown: (_) {
                                    if (!_showFortune) {
                                      setState(() => _isPressed = true);
                                      if (!_shakeController.isAnimating) {
                                        _shakeController.repeat();
                                      }
                                    }
                                  },
                                  onTapUp: (_) {
                                    if (!_showFortune) {
                                      _onCookieTap();
                                    }
                                  },
                                  onTapCancel: () {
                                    if (!_showFortune) {
                                      _shakeController.stop();
                                      _shakeController.reset();
                                      setState(() => _isPressed = false);
                                    }
                                  },
                                  child: AnimatedScale(
                                    scale: _isPressed ? 1.1 : 1.0,
                                    duration: const Duration(milliseconds: 150),
                                    child: Container(
                                      width: _cookieSize,
                                      height: _cookieSize,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.transparent,
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          if (!_isCracking)
                                            _CookieGlow(
                                              imagePath: _getCookieImagePath(
                                                widget.selectedCookieEmoji ??
                                                    '🏯',
                                              ),
                                              emoji:
                                                  widget.selectedCookieEmoji ??
                                                  '🏯',
                                              size: _cookieSize,
                                              opacity: glowOpacity.clamp(
                                                0.0,
                                                1.0,
                                              ),
                                              blurSigma: glowBlur,
                                            ),
                                          Center(
                                            child: _isCracking
                                                ? _CrackingCookie(
                                                    size: _cookieSize,
                                                    progress:
                                                        _crackController.value,
                                                    builder: (emoji) =>
                                                        _buildCookieDisplay(
                                                          emoji,
                                                        ),
                                                    emoji:
                                                        widget
                                                            .selectedCookieEmoji ??
                                                        '🏯',
                                                  )
                                                : _buildCookieDisplay(
                                                    widget.selectedCookieEmoji ??
                                                        '🏯',
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
                      ),
                    ),
                    if (_showFortune && _currentFortune != null)
                      _FortunePaperCard(
                        key: ValueKey(_paperVersion),
                        fortune: _currentFortune!,
                      ),
                  ],
                ),
              ),
              if (!widget.hideLabels) ...[
                const SizedBox(height: 10), // Daha da az dikey boşluk
                // Text'ler her zaman görünür (paper çıkınca da arkada kalır)
                // HTML: cookie-label font-size: 18px, font-weight: 700 - tam ortada
                Text(
                  l10n.dailyCookieTitle,
                  textAlign: TextAlign.center, // Tam ortalama
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 18, // HTML: 18px
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6), // HTML: margin-top: 6px
                // HTML: cookie-sub font-size: 13px, color: rgba(255,255,255,0.6) - tam ortada
                Text(
                  l10n.dailyCookieSubtitle,
                  textAlign: TextAlign.center, // Tam ortalama
                  style: TextStyle(
                    color: AppColors.textWhite.withOpacity(
                      0.6,
                    ), // HTML: rgba(255,255,255,0.6)
                    fontSize: 13, // HTML: 13px
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FortunePaperCard extends StatefulWidget {
  final Fortune fortune;

  const _FortunePaperCard({super.key, required this.fortune});

  @override
  State<_FortunePaperCard> createState() => _FortunePaperCardState();
}

class _FortunePaperCardState extends State<_FortunePaperCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildSilkPaper(
    BuildContext context,
    double paperWidth,
    double openPhase,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: paperWidth.clamp(50.0, 300.0),
      height: 230,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/cookies/paper.png',
                  fit: BoxFit.cover,
                ),
              ),
              Opacity(
                opacity: openPhase.clamp(0.0, 1.0),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.fortune.meaning,
                        textAlign: TextAlign.center,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF473828),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.todayFortune,
                        style: TextStyle(
                          color: const Color(0xFF6F5F4B).withOpacity(0.92),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Divider(
                        color: const Color(0xFF9D8867).withOpacity(0.35),
                        thickness: 1,
                        height: 1,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _PaperStatItem(
                            label: l10n.luckyNumber,
                            value: '${widget.fortune.luckyNumber}',
                          ),
                          _PaperStatItem(
                            label: l10n.luckyColor,
                            value: widget.fortune.luckyColor,
                          ),
                          _PaperStatItem(
                            label: l10n.luckLabel,
                            value: '${widget.fortune.luckPercent}%',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          double t = _controller.value;
          if (t == 0) return const SizedBox.shrink();

          // 0.0 - 0.4: Kurabiye önünde hızlı hortum (swirl)
          // 0.4 - 1.0: İpeksi, merkezden iki yana açılış
          double swirlPhase = (t / 0.4).clamp(0.0, 1.0);
          double openPhase = t < 0.4
              ? 0.0
              : Curves.easeOutQuart.transform(
                  ((t - 0.4) / 0.6).clamp(0.0, 1.0),
                );

          // Hortum: kurabiye çevresinde seri dönüş
          double angle = t * 20;
          double radius = (1 - swirlPhase) * 50;
          double xPos = math.cos(angle) * radius;
          double yPos = -swirlPhase * 30;

          // Kağıt genişliği: 50px rulo -> 280px tam kağıt
          double paperWidth = 50 + (openPhase * 230);

          return Transform.translate(
            offset: Offset(xPos, yPos),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(math.cos(t * 12) * 0.4 * (1 - openPhase))
                ..rotateZ(angle * 0.15 * (1 - openPhase)),
              child: Transform.scale(
                scale: 0.5 + (swirlPhase * 0.6),
                child: Opacity(
                  opacity: (t * 12).clamp(0.0, 1.0),
                  child: _buildSilkPaper(context, paperWidth, openPhase),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PaperStatItem extends StatelessWidget {
  final String label;
  final String value;

  const _PaperStatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF7B6A53).withOpacity(0.9),
              fontSize: 8,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF4A3A28),
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
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
    // === HTML KIRILMA ANIMASYONU (v25) ===
    // Tek faz: 0 → 1 arası, easeOut
    final crackPhase = Curves.easeOut.transform(progress.clamp(0.0, 1.0));
    final openPhase = crackPhase; // kağıt ve partiküller için aynı faz
    final crackEase = crackPhase;
    final openEase = crackPhase;
    final pressScale = 1.0;

    // === PARÇALARIN HAREKETİ (daha az uçma) ===
    final leftRotation = -0.26 * openEase; // ~15deg
    final leftOffsetX = -30 * openEase;
    final leftOffsetY = 24 * openEase;
    final fadePhase = ((progress - 0.60) / 0.40).clamp(0.0, 1.0);
    final fade = 1.0 - Curves.easeOut.transform(fadePhase);
    final leftOpacity = fade;

    final rightRotation = 0.26 * openEase; // ~15deg
    final rightOffsetX = 30 * openEase;
    final rightOffsetY = 24 * openEase;
    final rightOpacity = fade;

    // === KIRINTILAR ===
    final crumbs = List.generate(6, (i) {
      final delay = 0.35 + (i * 0.04);
      final crumbP = ((progress - delay) / 0.40).clamp(0.0, 1.0);
      final fallEase = Curves.easeIn.transform(crumbP);
      return _CrumbData(
        offset: Offset(
          (i.isEven ? -1 : 1) * (5 + i * 3.0) * crumbP,
          15 * fallEase + (i * 5.0 * fallEase),
        ),
        size: 2.0 + (i % 3) * 1.5,
        opacity: crumbP > 0.7 ? (1.0 - (crumbP - 0.7) / 0.3) : (crumbP * 0.8),
        rotation: i * 0.6 + progress * 3,
      );
    });

    final centerX = size / 2;
    final centerY = size / 2;

    return SizedBox(
      width: size,
      height: size + 40,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // === ALTIN IŞIK (kırılma noktasından) ===
          if (crackPhase > 0)
            Positioned(
              left: centerX - 30,
              top: centerY - 30,
              child: Transform.scale(
                scale: 0.2 + (openEase * 0.8),
                child: Opacity(
                  opacity: (crackEase * 0.8 - openEase * 0.3).clamp(0.0, 0.7),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.8),
                          const Color(0xFFFFD700).withOpacity(0.5),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.3, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // === KIRINTILAR (aşağı düşer) ===
          ...crumbs.map(
            (crumb) => Positioned(
              left: centerX + crumb.offset.dx - crumb.size / 2,
              top: centerY + crumb.offset.dy,
              child: Opacity(
                opacity: crumb.opacity.clamp(0.0, 1.0),
                child: Transform.rotate(
                  angle: crumb.rotation,
                  child: Container(
                    width: crumb.size,
                    height: crumb.size,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A574),
                      borderRadius: BorderRadius.circular(0.5),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // === ÇATLAK ÇİZGİSİ (ortadan) ===
          if (crackPhase > 0 && openPhase < 0.5)
            Positioned(
              left: centerX - 1,
              top: centerY - (size * 0.35 * crackEase),
              child: Opacity(
                opacity: (crackEase - openEase).clamp(0.0, 0.8),
                child: Container(
                  width: 2,
                  height: size * 0.7 * crackEase,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        const Color(0xFFFFD700).withOpacity(0.6),
                        const Color(0xFFFFD700).withOpacity(0.8),
                        const Color(0xFFFFD700).withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.4),
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // === SOL YARIM - hafif yamuk kesim ===
          Align(
            alignment: Alignment.center,
            child: Opacity(
              opacity: leftOpacity,
              child: Transform.translate(
                offset: Offset(-size * 0.25 + leftOffsetX, leftOffsetY),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..scale(openPhase > 0 ? 1.0 : pressScale)
                    ..rotateZ(leftRotation),
                  child: ClipPath(
                    clipper: _SubtleCrackClipper(isLeftHalf: true),
                    child: SizedBox(
                      width: size,
                      height: size,
                      child: builder(emoji),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // === SAĞ YARIM - hafif yamuk kesim ===
          Align(
            alignment: Alignment.center,
            child: Opacity(
              opacity: rightOpacity,
              child: Transform.translate(
                offset: Offset(size * 0.25 + rightOffsetX, rightOffsetY),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..scale(openPhase > 0 ? 1.0 : pressScale)
                    ..rotateZ(rightRotation),
                  child: ClipPath(
                    clipper: _SubtleCrackClipper(isLeftHalf: false),
                    child: SizedBox(
                      width: size,
                      height: size,
                      child: builder(emoji),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // === MINI PARLAMA PARÇACIKLARI ===
          if (crackPhase > 0.3)
            ...List.generate(4, (i) {
              final sparkP = ((progress - 0.25 - i * 0.06) / 0.30).clamp(
                0.0,
                1.0,
              );
              final angle = (i * 90.0 + 45) * math.pi / 180;
              final dist = 8 + (18 * sparkP);
              final opacity = sparkP > 0.6
                  ? (1.0 - (sparkP - 0.6) / 0.4)
                  : sparkP;

              return Positioned(
                left: centerX + math.cos(angle) * dist - 2,
                top: centerY + math.sin(angle) * dist - 2,
                child: Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: i.isEven ? const Color(0xFFFFD700) : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.6),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

// Kırıntı verisi
class _CrumbData {
  final Offset offset;
  final double size;
  final double opacity;
  final double rotation;

  const _CrumbData({
    required this.offset,
    required this.size,
    required this.opacity,
    required this.rotation,
  });
}

// Hafif yamuk/kirik kesim (cok hafif)
class _SubtleCrackClipper extends CustomClipper<Path> {
  final bool isLeftHalf;

  _SubtleCrackClipper({required this.isLeftHalf});

  @override
  Path getClip(Size size) {
    final path = Path();
    final centerX = size.width / 2;
    final points = <Offset>[
      Offset(centerX + 3.0, 0),
      Offset(centerX - 2.0, size.height * 0.20),
      Offset(centerX + 3.8, size.height * 0.40),
      Offset(centerX - 2.3, size.height * 0.60),
      Offset(centerX + 3.0, size.height * 0.80),
      Offset(centerX, size.height),
    ];

    if (isLeftHalf) {
      path.moveTo(0, 0);
      path.lineTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        final prev = points[i - 1];
        final curr = points[i];
        final midY = (prev.dy + curr.dy) / 2;
        path.quadraticBezierTo(prev.dx, midY, curr.dx, curr.dy);
      }
      path.lineTo(0, size.height);
      path.close();
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        final prev = points[i - 1];
        final curr = points[i];
        final midY = (prev.dy + curr.dy) / 2;
        path.quadraticBezierTo(prev.dx, midY, curr.dx, curr.dy);
      }
      path.lineTo(size.width, size.height);
      path.close();
    }

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// Hafif yamuk/kirik kesim (cok hafif)

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
                  child: Text(emoji, style: const TextStyle(fontSize: 92)),
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
