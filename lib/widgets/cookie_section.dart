import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';
import '../constants/colors.dart';
import '../models/fortune.dart';
import '../services/storage_service.dart';

class CookieSection extends StatefulWidget {
  final VoidCallback? onCookieTapped;
  final String? selectedCookieEmoji;

  const CookieSection({
    super.key,
    this.onCookieTapped,
    this.selectedCookieEmoji,
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
  late AnimationController _animationController;
  late Animation<double> _floatAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _shakeController;
  late AnimationController _crackController;
  late AnimationController _sparkleController;
  bool _isCracking = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

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
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _floatAnimation = Tween<double>(begin: 0, end: 14).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);

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
      duration: const Duration(milliseconds: 800),
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
    // Eğer paper zaten açıksa yeni mesaj çıkmasın
    if (_showFortune) {
      return;
    }

    // Önce basılı hali göster
    setState(() {
      _isPressed = true;
    });

    // Benzersiz falı al (async)
    final fortune = await Fortune.getRandomFortune(
      languageCode: Localizations.localeOf(context).languageCode,
    );

    setState(() {
      _currentFortune = fortune;
    });

    // Cookie'ye tıklama sesi
    _playSound('cookie_tap.mp3');

    // Crack animasyonu başlat
    setState(() => _isCracking = true);
    _crackController.forward(from: 0);

    // Kırılma sesi
    Future.delayed(const Duration(milliseconds: 200), () {
      _playSound('cookie_crack.mp3');
    });
    // Parlama sesi
    Future.delayed(const Duration(milliseconds: 400), () {
      _playSound('cookie_sparkle.mp3');
    });

    // Cookie sayısını ve koleksiyon kartını artır
    await StorageService.incrementCookieCount();
    await StorageService.incrementCookieCard(widget.selectedCookieEmoji ?? '🏯');

    // Stats'ı güncelle - ama setState çağırma! Bu tüm sayfayı rebuild eder
    // widget.onCookieTapped?.call(); // Kaldırıldı - bu tüm sayfayı rebuild ediyor ve cookie selector'ı etkiliyor
    // Arka plan hiçbir şey değişmemeli - sadece fortune paper ortaya çıkmalı

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _isPressed = false;
          _isCracking = false;
        });
      }
    });

    // Paper'ın daha hızlı çıkması için gecikmeyi azalt (HTML'deki gibi ama daha dramatik)
    Future.delayed(const Duration(milliseconds: 400), () {
      // 800ms -> 400ms (daha hızlı)
      if (mounted) {
        setState(() {
          _showFortune = true; // Paper hemen görünür ve animasyon başlar
        });
      }
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
                    // ÖNEMLİ: Cookie ÖNCE ekleniyor (ARKADA kalacak) - fortune paper SONRA eklenecek (ÜSTTE olacak)
                    // Paper çıktığında cookie ARKADA KALMALI ve tıklanmamalı (GİZLENMEMELİ!)
                    IgnorePointer(
                      ignoring:
                          _showFortune, // Paper çıktığında cookie tıklanamaz ama görünür kalır
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          _floatAnimation,
                          _glowAnimation,
                          _shakeController,
                        ]),
                        builder: (context, child) {
                          // Shake animasyonu - HTML'deki gibi
                          const shakeOffset = 0.0; // Şimdilik titreşim kapalı
                          final floatOffset = _floatAnimation.value;
                          // Glow pulsation (sadece silüet maskesine uygulanıyor)
                          final glowT = _glowAnimation.value;
                          final glowOpacity =
                              0.28 + (0.20 * glowT); // 0.28 → 0.48 (daha soluk)
                          final glowBlur =
                              14.0 +
                              (10.0 * glowT); // 14 → 24 (biraz daha geniş)

                          return Transform.translate(
                            offset: Offset(
                              shakeOffset,
                              _isPressed ? 0 : -floatOffset,
                            ),
                            child: GestureDetector(
                              onTapDown: (_) {
                                if (!_showFortune) {
                                  setState(() => _isPressed = true);
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
                                        _CookieGlow(
                                          imagePath: _getCookieImagePath(
                                            widget.selectedCookieEmoji ?? '🏯',
                                          ),
                                          emoji:
                                              widget.selectedCookieEmoji ??
                                              '🏯',
                                          size: _cookieSize,
                                          opacity: glowOpacity.clamp(0.0, 1.0),
                                          blurSigma: glowBlur,
                                        ),
                                      Center(
                                        child: (_isCracking || _showFortune)
                                            ? _CrackingCookie(
                                                size: _cookieSize,
                                                progress: _showFortune
                                                    ? 1.0
                                                    : _crackController.value,
                                                builder: (emoji) =>
                                                    _buildCookieDisplay(emoji),
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
                          );
                        },
                      ),
                    ),
                    // Fortune Paper - EN SON ekleniyor (ÜSTTE görünecek, cookie ARKADA kalacak)
                    // Paper yalnızca dışarı tıklayınca kapanmalı; mesajın kendisine tıklayınca kapanmamalı
                    if (_showFortune && _currentFortune != null) ...[
                      // Dışına tıklayınca kapatan şeffaf alan
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
                      // Mesaj kartı (tıklayınca kapanmaz) - overflow engelle
                      OverflowBox(
                        maxHeight: MediaQuery.of(context).size.height * 0.9,
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.55,
                            maxWidth: 250,
                          ),
                          child: _FortunePaper(
                            fortune: _currentFortune!,
                            cookieEmoji:
                                widget.selectedCookieEmoji ??
                                '🏯', // Seçili cookie emojisi
                            onAnimationComplete: () {
                              // Animasyon tamamlandı - otomatik kaybolma yok, sadece dış tıklama ile kaybolur
                            },
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
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
                });
              },
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
    // Halves translate dışa doğru, hafif döner
    final leftOffset = Offset(-24 * progress, 6 * progress);
    final rightOffset = Offset(24 * progress, 6 * progress);
    final leftRotation = -0.15 * progress;
    final rightRotation = 0.15 * progress;

    return Stack(
      clipBehavior: Clip.none,
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
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: offset,
        child: Transform.rotate(
          angle: rotation,
          child: ClipRect(
            child: Align(
              alignment: alignment,
              widthFactor: 0.5,
              child: SizedBox(width: size, height: size, child: builder(emoji)),
            ),
          ),
        ),
      ),
    );
  }
}

class _FortunePaper extends StatefulWidget {
  final Fortune fortune;
  final String cookieEmoji; // Seçili cookie emojisi
  final VoidCallback onAnimationComplete;

  const _FortunePaper({
    required this.fortune,
    required this.cookieEmoji,
    required this.onAnimationComplete,
  });

  @override
  State<_FortunePaper> createState() => _FortunePaperState();
}

class _FortunePaperState extends State<_FortunePaper>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _textController;
  late AnimationController _luckyController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotateAnimation; // HTML'deki rotate animasyonu
  late Animation<double> _iconOpacityAnimation; // Icon opacity animasyonu
  late Animation<double>
  _textOpacityAnimation; // Text opacity animasyonu (blur ile)
  late Animation<double> _textBlurAnimation; // Text blur animasyonu
  late Animation<double>
  _luckyOpacityAnimation; // Lucky section opacity animasyonu
  late Animation<double> _glowAnimation; // Paper glow animasyonu
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Fortune paper sesi
  Future<void> _playFortuneSound() async {
    // Şimdilik tüm sesler kapalı
    return;
  }

  @override
  void initState() {
    super.initState();

    // Ana paper animasyonu (daha hızlı ve dramatik - 0.6s)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 600,
      ), // 800ms -> 600ms (daha hızlı "şııp" efekti)
    );

    // Text reveal animasyonu (0.8s gecikme ile, 2.5s süre)
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Lucky section animasyonu (3s gecikme ile, 1.5s süre)
    _luckyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Paper glow animasyonu (sonsuz döngü) - sadece fortune paper görünürken başlatılacak
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // HTML'deki paper-fly-up animasyonu - daha dramatik: scale, translateY, rotate birlikte
    // 0%: scale(0.1) translateY(80px) rotate(-10deg)
    // 40%: scale(0.7) translateY(-30px) rotate(5deg)
    // 70%: scale(1.05) translateY(5px) rotate(-2deg)
    // 100%: scale(1) translateY(0) rotate(0)

    // Scale animasyonu (HTML'deki gibi - daha dramatik başlangıç)
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween:
            Tween<double>(
                  begin: 0.05,
                  end: 0.7,
                ) // 0% -> 40% (0.1'den 0.05'e - daha küçük başlangıç)
                .chain(
                  CurveTween(curve: const Cubic(0.34, 1.56, 0.64, 1)),
                ), // Bounce efekti için
        weight: 0.4,
      ),
      TweenSequenceItem(
        tween:
            Tween<double>(
                  begin: 0.7,
                  end: 1.08,
                ) // 40% -> 70% (1.05'ten 1.08'e - daha fazla bounce)
                .chain(CurveTween(curve: const Cubic(0.34, 1.56, 0.64, 1))),
        weight: 0.3,
      ),
      TweenSequenceItem(
        tween:
            Tween<double>(
                  begin: 1.08,
                  end: 1.0,
                ) // 70% -> 100% (daha fazla bounce)
                .chain(CurveTween(curve: Curves.elasticOut)), // Elastic efekti
        weight: 0.3,
      ),
    ]).animate(_controller);

    // Opacity animasyonu (40%'ta 1 olmalı - HTML'deki gibi)
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween:
            Tween<double>(begin: 0.0, end: 1.0) // 0% -> 40%
                .chain(CurveTween(curve: Curves.easeOut)),
        weight: 0.4,
      ),
      TweenSequenceItem(
        tween:
            Tween<double>(begin: 1.0, end: 1.0) // 40% -> 100% (1'de kal)
                .chain(CurveTween(curve: Curves.linear)),
        weight: 0.6,
      ),
    ]).animate(_controller);

    // Slide animasyonu - Cookie'nin içinden/altından çıkacak (HTML'deki gibi)
    // Cookie 190px, paper cookie'nin altından çıkacak, yani cookie'nin yarısından (95px) başlamalı
    _slideAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween:
            Tween<Offset>(
              begin: const Offset(
                0,
                0.45,
              ), // Cookie'nin içinden/altından başla (190px/2 = 95px, ~0.45)
              end: const Offset(0, -0.3), // Yukarı çık (bounce up)
            ).chain(
              CurveTween(curve: const Cubic(0.34, 1.56, 0.64, 1)),
            ), // Bounce efekti
        weight: 0.4,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0, -0.3),
          end: const Offset(0, 0.03), // Biraz aşağı (bounce down)
        ).chain(CurveTween(curve: const Cubic(0.34, 1.56, 0.64, 1))),
        weight: 0.3,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0, 0.03),
          end: const Offset(
            0,
            -0.12,
          ), // Cookie'nin hemen üstünde konumlan (cookie arkada görünür)
        ).chain(CurveTween(curve: Curves.easeOut)), // Smooth bitiş
        weight: 0.3,
      ),
    ]).animate(_controller);

    // Rotate animasyonu (HTML'deki gibi)
    _rotateAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -10 * math.pi / 180, // -10deg
          end: 5 * math.pi / 180, // 5deg
        ).chain(CurveTween(curve: const Cubic(0.34, 1.56, 0.64, 1))),
        weight: 0.4,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 5 * math.pi / 180,
          end: -2 * math.pi / 180, // -2deg
        ).chain(CurveTween(curve: const Cubic(0.34, 1.56, 0.64, 1))),
        weight: 0.3,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -2 * math.pi / 180,
          end: 0, // 0deg
        ).chain(CurveTween(curve: const Cubic(0.34, 1.56, 0.64, 1))),
        weight: 0.3,
      ),
    ]).animate(_controller);

    // Icon opacity animasyonu (paper ile birlikte)
    _iconOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    // Text reveal animasyonu (0.8s gecikme ile, blur efekti ile)
    _textOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.3), // 0% -> 30%
        weight: 0.3,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.3, end: 0.6), // 30% -> 60%
        weight: 0.3,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.6, end: 1.0), // 60% -> 100%
        weight: 0.4,
      ),
    ]).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _textBlurAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 8.0, end: 5.0), // 0% -> 30%
        weight: 0.3,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 5.0, end: 2.0), // 30% -> 60%
        weight: 0.3,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 2.0, end: 0.0), // 60% -> 100%
        weight: 0.4,
      ),
    ]).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    // Lucky section animasyonu (3s gecikme ile)
    _luckyOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _luckyController, curve: Curves.easeOut));

    // Paper glow animasyonu (sonsuz döngü)
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.4).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Animasyonları başlat - mounted kontrolü ekle (dispose hatası önlemek için)
    _controller.forward().then((_) {
      if (!mounted) return; // Widget dispose edilmişse devam etme

      // Glow animasyonunu başlat (sonsuz döngü) - sadece fortune paper görünürken
      if (mounted) {
        _glowController.repeat(reverse: true);
      }

      // Fortune paper açılma sesi
      _playFortuneSound();

      // Text animasyonunu başlat (0.8s gecikme ile)
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return; // Widget dispose edilmişse devam etme
        _textController.forward();
      });

      // Lucky section animasyonunu başlat (3s gecikme ile)
      Future.delayed(const Duration(milliseconds: 3000), () {
        if (!mounted) return; // Widget dispose edilmişse devam etme
        _luckyController.forward();
      });

      widget.onAnimationComplete();
    });
  }

  @override
  void dispose() {
    // Glow controller'ı önce durdur (repeat() çalışıyor olabilir)
    _glowController.stop();
    _glowController.dispose();
    // Diğer controller'ları dispose et
    _controller.dispose();
    _textController.dispose();
    _luckyController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedBuilder(
      animation: Listenable.merge([
        _controller,
        _textController,
        _luckyController,
        _glowController,
      ]),
      builder: (context, child) {
        // Paper glow animasyonu (HTML'deki gibi)
        final glowOpacity = 0.3 + (_glowAnimation.value * 0.1); // 0.3 -> 0.4

        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: SlideTransition(
              position: _slideAnimation,
              child: Transform.rotate(
                angle: _rotateAnimation.value,
                child: Container(
                  width: 250,
                  constraints: const BoxConstraints(maxWidth: 250),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 22,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFfffef8),
                        Color(0xFFf5f0e5),
                        Color(0xFFebe5d8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 60,
                        offset: const Offset(0, 20),
                      ),
                      BoxShadow(
                        color: const Color(
                          0xFF8B5A2B,
                        ).withOpacity(glowOpacity * 0.4),
                        blurRadius: 40,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: const Color(
                          0xFFFFD700,
                        ).withOpacity(glowOpacity * 0.3),
                        blurRadius: 40,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.7,
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Opacity(
                            opacity: _iconOpacityAnimation.value,
                            child: Text(
                              widget.cookieEmoji,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: 60,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C4DFF).withOpacity(0.18),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF7C4DFF,
                                  ).withOpacity(0.28),
                                  blurRadius: 6,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          AnimatedBuilder(
                            animation: _textController,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _textOpacityAnimation.value,
                                child: Transform.translate(
                                  offset: Offset(
                                    0,
                                    10 * (1 - _textOpacityAnimation.value),
                                  ),
                                  child: Text(
                                    widget.fortune.meaning,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xFF3d2a5e),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FontStyle.italic,
                                      height: 1.4,
                                      shadows: [
                                        Shadow(
                                          color: const Color(0xFF3d2a5e)
                                              .withOpacity(
                                                _textBlurAnimation.value / 10,
                                              ),
                                          blurRadius:
                                              _textBlurAnimation.value * 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          Opacity(
                            opacity: _luckyOpacityAnimation.value,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  child: CustomPaint(
                                    size: const Size(double.infinity, 1),
                                    painter: _DashedLinePainter(
                                      color: const Color(
                                        0xFF8B5CF6,
                                      ).withOpacity(0.25),
                                      strokeWidth: 1,
                                      dashLength: 4,
                                      dashSpace: 4,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _LuckyItem(
                                      label: l10n.luckyNumber,
                                      value: '${widget.fortune.luckyNumber}',
                                    ),
                                    _LuckyItem(
                                      label: l10n.luckyColor,
                                      value: widget.fortune.luckyColor,
                                    ),
                                    _LuckyItem(
                                      label: l10n.luckLabel,
                                      value: '${widget.fortune.luckPercent}%',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: 108,
                            height: 32,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFF7941D),
                                    Color(0xFFFF6B35),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFF7941D,
                                    ).withOpacity(0.30),
                                    blurRadius: 7,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextButton(
                                onPressed: () async {
                                  final shareText = l10n.fortuneShareText(
                                    widget.cookieEmoji,
                                    widget.fortune.name,
                                    widget.fortune.meaning,
                                    widget.fortune.luckyNumber,
                                    widget.fortune.luckyColor,
                                    widget.fortune.luckPercent,
                                  );
                                  await Share.share(shareText);
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  l10n.shareButton,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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

  const _LuckyItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    // HTML'deki gibi: lucky-label ve lucky-value
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(), // HTML: text-transform: uppercase
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF8b7aa8), // HTML: #8b7aa8
              fontSize: 8, // HTML: font-size: 8px
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF5a3db0), // HTML: #5a3db0
              fontSize: 11, // HTML: font-size: 11px
              fontWeight: FontWeight.w700,
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
