import 'dart:io' show Platform;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../screens/root_shell.dart';
import '../screens/onboarding_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;
  bool _isLoginMode = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _routeUser() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    
    // Varsayılan olarak lokal hafızaya (önbelleğe) bak
    String? userName = await StorageService.getUserName();

    if (user != null) {
      // 1. Apple/Google ile girmiş biri var. Supabase (Bulut) veri tabanına soruyoruz:
      // "Bu kişinin profili önceden var mı?"
      try {
        final profile = await supabase
            .from('profiles')
            .select('full_name, handle, avatar_url')
            .eq('id', user.id)
            .maybeSingle();

        if (profile != null && profile['full_name'] != null) {
           // ESKİ KULLANICI! Hemen bulut verilerini cihaza geri indiriyoruz:
           await StorageService.setUserName(profile['full_name'].toString());
           
           if(profile['handle'] != null) {
             await StorageService.setUserHandle(profile['handle'].toString());
           }
           
           if(profile['avatar_url'] != null) {
             await StorageService.setAvatar(profile['avatar_url'].toString());
           }
           
           // Ve artık yerel adımız dolu olduğu için onu Onboarding'e Yollamayacağız.
           userName = profile['full_name'].toString();
           debugPrint("Kullanıcı profili buluttan geri yüklendi: $userName");
        }
      } catch (e) {
        debugPrint('Profil kurtarma hatası: $e');
      }
    }

    if (!mounted) return;
    
    // Eğer isim hala yoksa (Bulutta da yokmuş), o zaman o YENİ bir kullanıcıdır.
    // Onu profil oluşturma sihirbazına (Onboarding) gönder
    if (userName == null || userName.isEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingPage()),
      );
    } else {
      // Zaten profili olduğu anlaşıldığına göre, hiç soru sormadan direkt Yıldız Odasına Gönder!
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RootShell()),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final response = await AuthService().signInWithGoogle();
      if (response != null && mounted) {
        await _routeUser();
      }
    } catch (e) {
      _showError('Google Girişi Başarısız: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final response = await AuthService().signInWithApple();
      if (response != null && mounted) {
        await _routeUser();
      }
    } catch (e) {
      _showError('Apple Girişi Başarısız: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Derin Uzay / Aura Arka Planı
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.5, -0.6),
                radius: 1.5,
                colors: [
                  Color(0xFF2E1B4E), // Koyu Mistik Mor
                  Color(0xFF0F0B1A), // Zifiri Karanlık Uzay
                ],
              ),
            ),
          ),
          
          // Hareketli Arka Plan Efektleri (Opsiyonel)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.1,
            right: -50,
            child: _buildGlowSphere(const Color(0xFFC356FE), 200, 0.4),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.2,
            left: -100,
            child: _buildGlowSphere(const Color(0xFF4DB6AC), 250, 0.2),
          ),

          // 2. Merkezi Cam Panel İçeriği
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    
                    // Logo / Başlık
                    const Center(
                      child: Text(
                        "C r a c k   W i s h",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 4.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Ruhunun rehberi ile senkronize ol.\nGeçmişini, geleceğini ve bilinçaltını hatırla.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    
                    const Spacer(),

                    // Giriş Paneli (Buzlu Cam)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 30,
                                spreadRadius: -5,
                              )
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_isLoading)
                                const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              else ...[
                                if (Platform.isIOS || Platform.isMacOS) ...[
                                  _buildAuthButton(
                                    icon: Icons.apple,
                                    label: _isLoginMode ? "Apple ile Giriş Yap" : "Apple ile Devam Et",
                                    color: Colors.white,
                                    textColor: Colors.black,
                                    onTap: _handleAppleSignIn,
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                _buildAuthButton(
                                  icon: Icons.g_mobiledata_rounded,
                                  label: _isLoginMode ? "Google ile Giriş Yap" : "Google ile Devam Et",
                                  color: Colors.white.withOpacity(0.1),
                                  textColor: Colors.white,
                                  onTap: _handleGoogleSignIn,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Mod Değiştirici (Zarif Metin)
                    GestureDetector(
                      onTap: () => setState(() => _isLoginMode = !_isLoginMode),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text.rich(
                          TextSpan(
                            text: _isLoginMode ? "Henüz evrene katılmadın mı?  " : "Zaten hesabın var mı?  ",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5), 
                              fontSize: 13,
                            ),
                            children: [
                              TextSpan(
                                text: _isLoginMode ? "Kayıt Ol" : "Giriş Yap",
                                style: const TextStyle(
                                  color: Colors.white, 
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowSphere(Color color, double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(opacity * 0.6),
            blurRadius: 80,
            spreadRadius: 40,
          ),
        ],
      ),
    );
  }

  Widget _buildAuthButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color == Colors.white ? Colors.transparent : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 28),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
