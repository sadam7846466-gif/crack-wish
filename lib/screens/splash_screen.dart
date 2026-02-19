import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'root_shell.dart';

/// Premium cinematic splash with fortune cookie icon,
/// radial light burst, floating stars, and a shimmer reveal.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ─── Master timeline controllers ───
  late final AnimationController _stageCtrl; // 0-1 over ~3s
  late final AnimationController _loopCtrl; // repeating glow
  late final AnimationController _starCtrl; // star twinkle loop

  // ─── Derived animations ───
  late final Animation<double> _iconScale;
  late final Animation<double> _iconOpacity;
  late final Animation<double> _burstOpacity;
  late final Animation<double> _burstScale;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _tagOpacity;
  late final Animation<double> _exitOpacity;

  bool _navigating = false;

  // Star data (seeded random for consistency)
  late final List<_StarData> _stars;

  @override
  void initState() {
    super.initState();

    // ─── Generate stars ───
    final rng = math.Random(77);
    _stars = List.generate(30, (_) => _StarData.random(rng));

    // ─── Stage controller (one-shot, 3.2 s) ───
    _stageCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    // ─── Loop controller (glow pulse, repeats) ───
    _loopCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // ─── Star twinkle ───
    _starCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    // ─── Build sub-animations from the stage curve ───

    // Icon: 0% → 40%
    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _stageCtrl,
        curve: const Interval(0.0, 0.40, curve: Curves.elasticOut),
      ),
    );
    _iconOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _stageCtrl,
        curve: const Interval(0.0, 0.20, curve: Curves.easeOut),
      ),
    );

    // Light burst: 15% → 50%
    _burstScale = Tween<double>(begin: 0.3, end: 2.5).animate(
      CurvedAnimation(
        parent: _stageCtrl,
        curve: const Interval(0.15, 0.50, curve: Curves.easeOut),
      ),
    );
    _burstOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.8)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.8, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 60,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _stageCtrl,
        curve: const Interval(0.15, 0.55),
      ),
    );

    // Title text: 35% → 60%
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _stageCtrl,
        curve: const Interval(0.35, 0.55, curve: Curves.easeOut),
      ),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _stageCtrl,
        curve: const Interval(0.35, 0.60, curve: Curves.easeOutCubic),
      ),
    );

    // Tagline: 50% → 70%
    _tagOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _stageCtrl,
        curve: const Interval(0.50, 0.70, curve: Curves.easeOut),
      ),
    );

    // Whole-screen fade-out: 85% → 100%
    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _stageCtrl,
        curve: const Interval(0.85, 1.0, curve: Curves.easeIn),
      ),
    );

    // ─── Start timeline & schedule navigation ───
    _stageCtrl.forward();
    _stageCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_navigating) {
        _navigating = true;
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, a, b) => const RootShell(),
            transitionsBuilder: (_, anim, sa, child) => child,
            transitionDuration: Duration.zero,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _stageCtrl.dispose();
    _loopCtrl.dispose();
    _starCtrl.dispose();
    super.dispose();
  }

  // ─── BUILD ───────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080510),
      body: AnimatedBuilder(
        animation: Listenable.merge([_stageCtrl, _loopCtrl, _starCtrl]),
        builder: (context, _) {
          return Opacity(
            opacity: _exitOpacity.value.clamp(0.0, 1.0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── Background gradient ──
                _buildBackground(),

                // ── Twinkling stars ──
                ..._buildStars(context),

                // ── Radial light burst ──
                _buildLightBurst(context),

                // ── Icon + text column ──
                _buildCenterContent(context),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Background ─────────────────────────────────────────
  Widget _buildBackground() {
    final glowVal = _loopCtrl.value;
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.15),
          radius: 1.2,
          colors: [
            Color.lerp(
              const Color(0xFF1A0A2E),
              const Color(0xFF2D1248),
              glowVal,
            )!,
            const Color(0xFF0F0720),
            const Color(0xFF080510),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  // ─── Stars ──────────────────────────────────────────────
  List<Widget> _buildStars(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final t = _starCtrl.value;

    return _stars.map((star) {
      // Twinkle: each star has its own phase
      final phase = (t + star.phase) % 1.0;
      final twinkle = (math.sin(phase * math.pi * 2) + 1) / 2;
      final opacity =
          (star.minAlpha + twinkle * (star.maxAlpha - star.minAlpha))
              .clamp(0.0, 1.0);

      return Positioned(
        left: star.x * size.width,
        top: star.y * size.height,
        child: Container(
          width: star.size,
          height: star.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: star.color.withValues(alpha: opacity),
            boxShadow: [
              BoxShadow(
                color: star.color.withValues(alpha: opacity * 0.5),
                blurRadius: star.size * 3,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  // ─── Radial Light Burst ─────────────────────────────────
  Widget _buildLightBurst(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final center = Offset(size.width / 2, size.height * 0.38);

    return Positioned(
      left: center.dx - 200,
      top: center.dy - 200,
      child: Transform.scale(
        scale: _burstScale.value,
        child: Opacity(
          opacity: _burstOpacity.value.clamp(0.0, 1.0),
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFF6B35).withValues(alpha: 0.4),
                  const Color(0xFFFF8A3D).withValues(alpha: 0.15),
                  const Color(0xFF8B5CF6).withValues(alpha: 0.05),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.3, 0.6, 1.0],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Center Content (Icon + Text) ───────────────────────
  Widget _buildCenterContent(BuildContext context) {
    final glowVal = _loopCtrl.value;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Spacer to push icon slightly above center
          const SizedBox(height: 0),

          // ── Fortune Cookie Icon ──
          Transform.scale(
            scale: _iconScale.value,
            child: Opacity(
              opacity: _iconOpacity.value.clamp(0.0, 1.0),
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    // Warm inner glow
                    BoxShadow(
                      color: const Color(0xFFFF6B35).withValues(
                        alpha: 0.3 + 0.2 * glowVal,
                      ),
                      blurRadius: 40 + 20 * glowVal,
                      spreadRadius: 5,
                    ),
                    // Purple outer glow
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(
                        alpha: 0.15 + 0.1 * glowVal,
                      ),
                      blurRadius: 60 + 20 * glowVal,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    'assets/icons/app_icon.png',
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 36),

          // ── App name ──
          SlideTransition(
            position: _textSlide,
            child: Opacity(
              opacity: _textOpacity.value.clamp(0.0, 1.0),
              child: _ShimmerText(
                text: 'VLucky',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 6,
                  height: 1.1,
                ),
                shimmerProgress: _stageCtrl.value,
                baseColors: const [
                  Color(0xFFFFFFFF),
                  Color(0xFFF0E6FF),
                ],
                shimmerColor: const Color(0xFFFFD700),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ── Tagline ──
          Opacity(
            opacity: _tagOpacity.value.clamp(0.0, 1.0),
            child: const Text(
              '🥠 Kırılmamış Kurabiyeler Seni Bekliyor',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0x99FFFFFF),
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Star data class ──────────────────────────────────────
class _StarData {
  final double x, y, size, phase, minAlpha, maxAlpha;
  final Color color;

  const _StarData({
    required this.x,
    required this.y,
    required this.size,
    required this.phase,
    required this.minAlpha,
    required this.maxAlpha,
    required this.color,
  });

  factory _StarData.random(math.Random rng) {
    const starColors = [
      Color(0xFFFFFFFF),
      Color(0xFFFFE4B5),
      Color(0xFFADD8E6),
      Color(0xFFDDA0DD),
      Color(0xFFFFD700),
    ];
    return _StarData(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      size: 1.0 + rng.nextDouble() * 3.0,
      phase: rng.nextDouble(),
      minAlpha: 0.05 + rng.nextDouble() * 0.2,
      maxAlpha: 0.5 + rng.nextDouble() * 0.5,
      color: starColors[rng.nextInt(starColors.length)],
    );
  }
}

// ─── Shimmer text effect ──────────────────────────────────
class _ShimmerText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final double shimmerProgress;
  final List<Color> baseColors;
  final Color shimmerColor;

  const _ShimmerText({
    required this.text,
    required this.style,
    required this.shimmerProgress,
    required this.baseColors,
    required this.shimmerColor,
  });

  @override
  Widget build(BuildContext context) {
    // Shimmer band sweeps across the text
    final shimmerStop = (shimmerProgress * 3 - 0.5).clamp(0.0, 1.0);

    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            baseColors[0],
            baseColors.length > 1 ? baseColors[1] : baseColors[0],
            shimmerColor,
            baseColors.length > 1 ? baseColors[1] : baseColors[0],
            baseColors[0],
          ],
          stops: [
            (shimmerStop - 0.15).clamp(0.0, 1.0),
            (shimmerStop - 0.05).clamp(0.0, 1.0),
            shimmerStop,
            (shimmerStop + 0.05).clamp(0.0, 1.0),
            (shimmerStop + 0.15).clamp(0.0, 1.0),
          ],
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: Text(text, style: style.copyWith(color: Colors.white)),
    );
  }
}
