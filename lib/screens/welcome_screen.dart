import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors.dart';
import 'root_shell.dart';
import '../services/storage_service.dart';

/// Premium giriş/kayıt ekranı — Apple, Google, E-posta ve Misafir seçenekleri.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _buttonsFade;
  late final Animation<Offset> _buttonsSlide;
  late final Animation<double> _guestFade;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // Logo: 0→30%
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.30, curve: Curves.easeOut)),
    );
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic)),
    );

    // Başlık: 15→45%
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.15, 0.45, curve: Curves.easeOut)),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.15, 0.50, curve: Curves.easeOutCubic)),
    );

    // Butonlar: 35→70%
    _buttonsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.35, 0.70, curve: Curves.easeOut)),
    );
    _buttonsSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.35, 0.75, curve: Curves.easeOutCubic)),
    );

    // Misafir linki: 55→85%
    _guestFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.55, 0.85, curve: Curves.easeOut)),
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _continueAsGuest() {
    HapticFeedback.lightImpact();
    StorageService.setHasSeenWelcome(true);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const RootShell(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _onAppleSignIn() {
    HapticFeedback.mediumImpact();
    // TODO: Apple Sign In entegrasyonu
    _continueAsGuest(); // Şimdilik misafir olarak devam
  }

  void _onGoogleSignIn() {
    HapticFeedback.mediumImpact();
    // TODO: Google Sign In entegrasyonu
    _continueAsGuest(); // Şimdilik misafir olarak devam
  }

  void _onEmailSignIn() {
    HapticFeedback.mediumImpact();
    // TODO: E-posta giriş ekranı
    _continueAsGuest(); // Şimdilik misafir olarak devam
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1A1F),
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // 1. AppTheme bgGradient (Koyu lacivert tonlar)
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF0A1A1F),
                      Color(0xFF0D2129),
                      Color(0xFF0F1F2A),
                      Color(0xFF1A1A2E),
                      Color(0xFF1E1E3A),
                      Color(0xFF252550),
                    ],
                    stops: [0.0, 0.25, 0.4, 0.6, 0.75, 1.0],
                  ),
                ),
              ),
              // 2. MottledPainter sıcak şarap overlay
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.3, -0.4),
                    radius: 1.2,
                    colors: [
                      const Color(0xFF8B3A3A).withOpacity(0.35),
                      const Color(0xFF6E2828).withOpacity(0.20),
                      const Color(0xFF1A3A5C).withOpacity(0.10),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.35, 0.6, 1.0],
                  ),
                ),
              ),
              // 3. İçerik
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(32, 0, 32, bottomPad > 0 ? 8 : 24),
                  child: Column(
                    children: [
                    const Spacer(flex: 2),

                    // ── Logo ──
                    Transform.scale(
                      scale: _logoScale.value,
                      child: Opacity(
                        opacity: _logoFade.value.clamp(0.0, 1.0),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF6B35).withOpacity(0.2),
                                blurRadius: 40,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset(
                              'assets/icons/appicon.png',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Başlık + Alt yazı ──
                    SlideTransition(
                      position: _titleSlide,
                      child: Opacity(
                        opacity: _titleFade.value.clamp(0.0, 1.0),
                        child: Column(
                          children: [
                            const Text(
                              'VLucky',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 3,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Şansını keşfet, geleceğini gör',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 3),

                    // ── Giriş Butonları ──
                    SlideTransition(
                      position: _buttonsSlide,
                      child: Opacity(
                        opacity: _buttonsFade.value.clamp(0.0, 1.0),
                        child: Column(
                          children: [
                            // Apple ile Giriş
                            _AuthButton(
                              onTap: _onAppleSignIn,
                              icon: Icons.apple,
                              label: 'Apple ile devam et',
                              bgColor: Colors.white,
                              textColor: Colors.black,
                            ),
                            const SizedBox(height: 12),

                            // Google ile Giriş
                            _AuthButton(
                              onTap: _onGoogleSignIn,
                              icon: Icons.g_mobiledata_rounded,
                              iconSize: 26,
                              label: 'Google ile devam et',
                              bgColor: Colors.white.withOpacity(0.1),
                              textColor: Colors.white,
                              borderColor: Colors.white.withOpacity(0.2),
                            ),
                            const SizedBox(height: 12),

                            // E-posta ile Giriş
                            _AuthButton(
                              onTap: _onEmailSignIn,
                              icon: Icons.mail_outline_rounded,
                              label: 'E-posta ile devam et',
                              bgColor: Colors.white.withOpacity(0.1),
                              textColor: Colors.white,
                              borderColor: Colors.white.withOpacity(0.2),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Misafir ──
                    Opacity(
                      opacity: _guestFade.value.clamp(0.0, 1.0),
                      child: GestureDetector(
                        onTap: _continueAsGuest,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'Misafir olarak devam et',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Gizlilik notu ──
                    Opacity(
                      opacity: _guestFade.value.clamp(0.0, 1.0),
                      child: Text(
                        'Devam ederek Gizlilik Politikası ve\nKullanım Koşullarını kabul etmiş olursunuz.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.2),
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const Spacer(flex: 1),
                  ],
                ),
              ),
            ),
            ],
          );
        },
      ),
    );
  }
}

// ── Auth Butonu ──
class _AuthButton extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  final double iconSize;
  final String label;
  final Color bgColor;
  final Color textColor;
  final Color? borderColor;

  const _AuthButton({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.textColor,
    this.borderColor,
    this.iconSize = 22,
  });

  @override
  State<_AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<_AuthButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: widget.bgColor,
            borderRadius: BorderRadius.circular(14),
            border: widget.borderColor != null
                ? Border.all(color: widget.borderColor!, width: 0.8)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: widget.textColor, size: widget.iconSize),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
