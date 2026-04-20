import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'root_shell.dart';
import 'onboarding_page.dart';
import '../services/storage_service.dart';
import 'onboarding_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
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
      duration: const Duration(milliseconds: 1400),
    );

    // Fade: Çabuk belir, ortada kal, hafif erken çık
    _fade = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    
    // Scale: Yavaşça büyüyen (zoom) sinematik efekt
    _scale = Tween<double>(begin: 0.85, end: 1.05)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _ctrl.forward();
    _ctrl.addStatusListener((status) async {
      if (status == AnimationStatus.completed && !_navigating) {
        _navigating = true;
        
        // Kullanıcı önbellekte var mı bakıyoruz
        final userName = await StorageService.getUserName();
        final isNewUser = (userName == null || userName.isEmpty);

        if (!mounted) return;
        
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => isNewUser ? const OnboardingPage() : const RootShell(),
            transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 800),
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
      backgroundColor: const Color(0xFFB46471),
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return Opacity(
            opacity: _fade.value.clamp(0.0, 1.0),
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
              child: Center(
                child: ScaleTransition(
                  scale: _scale,
                  child: Image.asset(
                    'assets/icons/splash_cookie.png',
                    width: 75,
                    height: 75,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
