import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart' as google_auth;
import '../constants/colors.dart';
import 'root_shell.dart';
import '../services/storage_service.dart';
import 'onboarding_page.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _buttonsFade;
  late final Animation<Offset> _buttonsSlide;

  bool _isGoogleLoading = false;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.40, curve: Curves.easeOut)));
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic)));

    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.25, 0.60, curve: Curves.easeOut)));
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.25, 0.65, curve: Curves.easeOutCubic)));

    _buttonsFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.50, 0.90, curve: Curves.easeOut)));
    _buttonsSlide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.50, 0.95, curve: Curves.easeOutCubic)));

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _finalizeLogin() async {
    HapticFeedback.lightImpact();
    StorageService.setHasSeenWelcome(true);
    final sign = await StorageService.getZodiacSign();
    if (!mounted) return;
    final targetScreen = (sign == null || sign.isEmpty) ? const OnboardingPage() : const RootShell();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => targetScreen,
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  void _onAppleSignIn() {
    HapticFeedback.mediumImpact();
    _finalizeLogin(); 
  }

  Future<void> _onGoogleSignIn() async {
    HapticFeedback.mediumImpact();
    if (_isGoogleLoading) return;
    setState(() => _isGoogleLoading = true);
    try {
      const webClientId = 'SENIN_SUPABASE_GOOGLE_WEB_CLIENT_ID_BURAYA_GELECEK'; 
      final googleSignIn = google_auth.GoogleSignIn(serverClientId: webClientId);
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;
      if (accessToken == null || idToken == null) throw 'Kimlik doğrulama tokenları alınamadı.';

      final AuthResponse res = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final user = res.user;
      if (user != null) {
        final String name = user.userMetadata?['full_name'] ?? 'Kahin';
        final String currentName = await StorageService.getUserName() ?? '';
        if (currentName.isEmpty) await StorageService.setUserName(name);
        StorageService.setHasSeenWelcome(true);
        if (mounted) {
          final sign = await StorageService.getZodiacSign();
          final targetScreen = (sign == null || sign.isEmpty) ? const OnboardingPage() : const RootShell();
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => targetScreen,
              transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
              transitionDuration: const Duration(milliseconds: 600),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Giriş Hatası: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bağlantı hatası: $e. Şimdilik misafir olarak devam ediliyor...', style: const TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF16151A),
          )
        );
        _finalizeLogin();
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeData>(
      valueListenable: AppThemeController.notifier,
      builder: (context, palette, _) {
        return LiquidGlassScope.stack(
          background: Container(
            decoration: BoxDecoration(gradient: palette.bgGradient),
          ),
          content: Scaffold(
            extendBody: true,
            backgroundColor: Colors.transparent,
            body: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: CustomPaint(
                          painter: _WelcomeMottledPainter(),
                        ),
                      ),
                    ),
                    SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Transform.scale(
                              scale: _logoScale.value,
                              child: Opacity(
                                opacity: _logoFade.value.clamp(0.0, 1.0),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 180,
                                      height: 180,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF8E3A42).withOpacity(0.45), // Soft Plum/Ruby
                                            blurRadius: 180,
                                            spreadRadius: 60,
                                          ),
                                          BoxShadow(
                                            color: const Color(0xFFC05C65).withOpacity(0.25), // Soft Muted Red
                                            blurRadius: 80,
                                            spreadRadius: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Image.asset(
                                      'assets/icons/splash_cookie.png',
                                      width: 180,
                                      height: 180,
                                      fit: BoxFit.contain,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 48),
                            
                            SlideTransition(
                              position: _titleSlide,
                              child: Opacity(
                                opacity: _titleFade.value.clamp(0.0, 1.0),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Crack & Wish',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 38,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 2.5,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'The magic is within you.',
                                      style: TextStyle(
                                        color: Color(0xFFE5B0B0),
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                        letterSpacing: 1.2,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SlideTransition(
                        position: _buttonsSlide,
                        child: Opacity(
                          opacity: _buttonsFade.value.clamp(0.0, 1.0),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: _onAppleSignIn,
                                child: Container(
                                  width: double.infinity,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(22),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 20,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.apple, color: Colors.black, size: 28),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Apple ile Devam Et',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              GestureDetector(
                                onTap: _onGoogleSignIn,
                                child: Container(
                                  width: double.infinity,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.08),
                                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: _isGoogleLoading
                                    ? const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(PhosphorIcons.googleLogo(PhosphorIconsStyle.fill), color: Colors.white, size: 24),
                                          const SizedBox(width: 12),
                                          const Text(
                                            'Google ile Devam Et',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                "Devam ederek Kullanım Koşulları ve Gizlilik Politikası'nı\nkabul etmiş sayılırsınız.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.35),
                                  fontSize: 11,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _MiniSocialBtn extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final VoidCallback onTap;
  
  const _MiniSocialBtn({required this.icon, required this.onTap, this.iconSize = 24});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.05),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Center(
          child: Icon(icon, color: Colors.white.withOpacity(0.8), size: iconSize),
        ),
      ),
    );
  }
}

class _WelcomeMottledPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);

    final allColors = [
      const Color(0xFFC8A890), // Orta bej
      const Color(0xFF8B3A3A),
      const Color(0xFF7A3030),
      const Color(0xFF964040),
      const Color(0xFFA04848),
      const Color(0xFF6E2828),
      const Color(0xFF883838),
      const Color(0xFF1A3A5C),
      const Color(0xFF2A4A6C),
      const Color(0xFF1E3050),
    ];

    for (int i = 0; i < 26; i++) {
      final color = allColors[rng.nextInt(allColors.length)];
      final opacity = 0.08 + rng.nextDouble() * 0.15; // Extremely soft (max 0.23)
      final radius = 120.0 + rng.nextDouble() * 200.0; // Larger to be fuzzier
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;

      final paint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(x, y),
          radius,
          [
            color.withOpacity(opacity),
            color.withOpacity(opacity * 0.60),
            color.withOpacity(opacity * 0.15),
            color.withOpacity(0),
          ],
          [0.0, 0.25, 0.65, 1.0], // Very soft fade starts early
        );
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
