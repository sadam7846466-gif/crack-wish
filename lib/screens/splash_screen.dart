import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'root_shell.dart';
import 'onboarding_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeOut;
  late final Animation<double> _scale;
  late final Animation<double> _gradientFadeIn;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Gradient arka plan: Yavaşça belir (native solid renk → gradient geçişi gizler)
    _gradientFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.35, curve: Curves.easeOut)),
    );

    // Fade out: Sadece son %30'da kaybol (başlangıçta tam görünür — native ile eşleşir)
    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.70, 1.0, curve: Curves.easeIn)),
    );
    
    // Scale: Kurabiye 1.0'dan başlasın (native ile aynı), hafifçe büyüsün
    _scale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.70, curve: Curves.easeOutCubic)),
    );

    _ctrl.forward();
    _ctrl.addStatusListener((status) async {
      if (status == AnimationStatus.completed && !_navigating) {
        _navigating = true;
        
        // Kullanıcının aktif Supabase oturumu (Google/Apple ile giriş) var mı?
        final session = Supabase.instance.client.auth.currentSession;
        final isLoggedIn = session != null;

        if (!mounted) return;
        
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => isLoggedIn ? const RootShell() : const OnboardingPage(),
            transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Native launch screen ile aynı renk — geçiş görünmez olur
      backgroundColor: const Color(0xFFB46471),
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Gradient arka plan — yavaşça belirerek native solid renkten yumuşak geçiş
              Opacity(
                opacity: _gradientFadeIn.value.clamp(0.0, 1.0),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFD18471),
                        Color(0xFFC36E6E),
                        Color(0xFFA85A74),
                        Color(0xFF776288),
                      ],
                      stops: [0.0, 0.35, 0.65, 1.0],
                    ),
                  ),
                ),
              ),
              // Kurabiye ikonu — baştan görünür (native ile eşleşir), fade out ile kaybolur
              Opacity(
                opacity: _fadeOut.value.clamp(0.0, 1.0),
                child: Center(
                  child: Transform.scale(
                    scale: _scale.value,
                    child: Image.asset(
                      'assets/icons/splash_cookie.png',
                      width: 75,
                      height: 75,
                      fit: BoxFit.contain,
                    ),
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
