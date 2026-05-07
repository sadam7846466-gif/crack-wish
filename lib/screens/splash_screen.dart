import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'root_shell.dart';
import 'onboarding_page.dart';
import '../services/storage_service.dart';

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

    _checkSessionAndNavigate();
  }

  /// Session kurtarma sigortası:
  /// 1) Önce currentSession'ı kontrol et (hızlı yol)
  /// 2) null ise → Supabase'in initialSession event'ini bekle (max 2sn)
  /// 3) Timeout olursa → currentSession'ı son kez kontrol et
  /// Bu sayede iOS'ta session restore gecikse bile kullanıcı çıkış yapmış gibi görünmez.
  Future<void> _checkSessionAndNavigate() async {
    // Minimum splash süresi (animasyon için)
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    // Hızlı yol: Session zaten hazırsa bekletme
    var session = Supabase.instance.client.auth.currentSession;
    debugPrint("🔐 [SPLASH] İlk session kontrolü: ${session != null ? 'VAR' : 'YOK'}");
    
    // Session null ise — iOS'ta restore geç olabilir, bekle
    if (session == null) {
      try {
        await Supabase.instance.client.auth.onAuthStateChange
            .firstWhere((data) => 
                data.event == AuthChangeEvent.initialSession ||
                data.event == AuthChangeEvent.signedIn ||
                data.event == AuthChangeEvent.tokenRefreshed)
            .timeout(const Duration(seconds: 4));
      } catch (_) {
        // Timeout veya hata — sorun değil, devam et
      }
      if (!mounted) return;
      // Son kontrol
      session = Supabase.instance.client.auth.currentSession;
      debugPrint("🔐 [SPLASH] onAuthStateChange sonrası session: ${session != null ? 'VAR' : 'YOK'}");
    }

    // SON ŞANS: Session hâlâ null ise, token'ı elle yenilemeyi dene
    if (session == null) {
      try {
        final response = await Supabase.instance.client.auth.refreshSession();
        session = response.session;
        debugPrint("🔐 [SPLASH] refreshSession sonucu: ${session != null ? 'BAŞARILI' : 'BAŞARISIZ'}");
      } catch (e) {
        debugPrint("🔐 [SPLASH] refreshSession hatası (normal olabilir): $e");
      }
      if (!mounted) return;
    }

    final isLoggedIn = session != null;
    
    if (isLoggedIn) {
      // Adım 4: Elite Kullanıcılarına günlük ödül kontrolü
      try {
        await StorageService.checkDailyEliteReward();
      } catch (_) {}
    }

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
