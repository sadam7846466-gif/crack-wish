import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'root_shell.dart';
import '../services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
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

    // 0→30% belir, 30→70% dur, 70→100% kaybol
    _fade = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

    _ctrl.forward();
    _ctrl.addStatusListener((status) async {
      if (status == AnimationStatus.completed && !_navigating) {
        _navigating = true;
        await StorageService.hasSeenWelcome();
        if (!mounted) return;
        
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            // DEV MODE: Her seferinde onboarding göster
            pageBuilder: (_, __, ___) => const OnboardingPage(),
            transitionsBuilder: (_, a, __, child) => child,
            transitionDuration: Duration.zero,
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
                child: Image.asset(
                  'assets/icons/splash_cookie.png',
                  width: 70,
                  height: 70,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
