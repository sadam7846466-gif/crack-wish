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

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 1000), // Daha hızlı (1400ms -> 1000ms)
          pageBuilder: (_, __, ___) => isLoggedIn ? const RootShell() : const OnboardingPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // easeInQuart: easeInExpo'ya göre çok daha yumuşak ve pürüzsüz hızlanır
            final scaleAnimation = Tween<double>(begin: 1.0, end: 30.0).animate(
              CurvedAnimation(
                parent: animation, 
                curve: const Interval(0.1, 1.0, curve: Curves.easeInQuart),
              ),
            );

            // Büyüdükçe eriyerek kaybolur (arkasından uygulama çıkar)
            final fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
              CurvedAnimation(
                parent: animation, 
                curve: const Interval(0.45, 0.95, curve: Curves.easeOut),
              ),
            );

            // Native ile pürüzsüz eşleşme
            final pixelRatio = MediaQuery.of(context).devicePixelRatio;
            final logicalSize = 168.0 / pixelRatio; 

            return Stack(
              fit: StackFit.expand,
              children: [
                child,
                IgnorePointer(
                  ignoring: animation.value > 0.5,
                  child: Opacity(
                    opacity: fadeOutAnimation.value,
                    child: Container(
                      color: const Color(0xFFB46471),
                      child: Center(
                        child: Transform.scale(
                          scale: scaleAnimation.value,
                          child: Image.asset(
                            'assets/icons/splash_cookie.png',
                            width: logicalSize,
                            height: logicalSize,
                            fit: BoxFit.contain,
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
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final logicalSize = 168.0 / pixelRatio; 

    return Scaffold(
      backgroundColor: const Color(0xFFB46471),
      body: Center(
        child: Image.asset(
          'assets/icons/splash_cookie.png',
          width: logicalSize, 
          height: logicalSize,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
