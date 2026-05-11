import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../services/profile_sync_service.dart';
import '../services/referral_service.dart';
import '../services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'root_shell.dart';
import 'zodiac_hub_page.dart';
import '../data/mayan_zodiac_data.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/analytics_service.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with TickerProviderStateMixin {
  late final AnimationController _stepCtrl;
  late final AnimationController _shakeCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  int _currentStep = 0; // 0 to 6
  int _selectedAvatarIndex = 2; // Ortadan (3. avatar) başlasın, kapak akışına uygun
  bool _showLoginButtons = false;
  bool _isAuthLoading = false;

  // --- Step 0 Data ---
  final TextEditingController _nameCtrl = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final TextEditingController _usernameCtrl = TextEditingController();
  final FocusNode _usernameFocus = FocusNode();
  bool _isCheckingHandle = false;
  String? _handleError;
  DateTime _selectedDate = DateTime(2000, 1, 1);
  bool _hasSelectedDate = false;
  DateTime? _selectedTime;
  bool _knowsTime = false;
  String? _selectedLocation;

  // --- Step 1 Data ---
  List<String> _lifeFocus = [];
  String _relationship = "Yalnız Gökyüzü";

  // --- Step 2 Data ---
  String _dreamFrequency = "Haberci & Net";
  int _auraColor = 0xFFC356FE; // Default Purple Aura
  final List<int> _auraColors = [
    0xFFFF3A6C, // Passion / Coral
    0xFFC356FE, // Mystic Purple
    0xFF4DB6AC, // Calm Teal
    0xFFFFC107, // Sun Yellow
    0xFF2979FF, // Deep Ocean Blue
    0xFFF48FB1, // Romantic Pink
  ];

  // --- Step 3 Data ---
  String _sleepPattern = "Gece İnsanı";

  // --- Step 4 Data ---
  bool _matchPreference = true;

  @override
  void initState() {
    super.initState();
    _stepCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _stepCtrl, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _stepCtrl, curve: Curves.easeOutCubic));

    _stepCtrl.forward();
  }

  @override
  void dispose() {
    _stepCtrl.dispose();
    _shakeCtrl.dispose();
    _nameCtrl.dispose();
    _nameFocus.dispose();
    _usernameCtrl.dispose();
    _usernameFocus.dispose();
    super.dispose();
  }

  void _nextStep() async {
    HapticFeedback.lightImpact();
    if (_currentStep == 2 && (_nameCtrl.text.trim().isEmpty || _usernameCtrl.text.trim().isEmpty)) {
      HapticFeedback.heavyImpact();
      _shakeCtrl.forward(from: 0.0);
      return;
    }
    
    // Handle benzersizlik kontrolü (Step 2'den çıkarken)
    if (_currentStep == 2) {
      setState(() {
        _isCheckingHandle = true;
        _handleError = null;
      });
      
      final handle = _usernameCtrl.text.trim();
      final isAvailable = await ProfileSyncService().isHandleAvailable(handle);
      
      if (!mounted) return;
      setState(() => _isCheckingHandle = false);
      
      if (!isAvailable) {
        HapticFeedback.heavyImpact();
        setState(() => _handleError = 'Bu kullanıcı adı zaten alınmış');
        _shakeCtrl.forward(from: 0.0);
        return;
      }
    }
    
    if (_currentStep == 3 && !_hasSelectedDate) {
      HapticFeedback.heavyImpact();
      _shakeCtrl.forward(from: 0.0);
      return;
    }

    if (_currentStep < 6) {
      if (_currentStep == 2) {
        _nameFocus.unfocus();
        _usernameFocus.unfocus();
      }
      _stepCtrl.reverse().then((_) {
        setState(() => _currentStep++);
        _stepCtrl.forward();
      });
    } else if (_currentStep == 6) {
      // Kullanıcı zaten giriş yapmışsa (Giriş Yap → onboarding yönlendirmesi) direkt kaydet
      final existingUser = Supabase.instance.client.auth.currentUser;
      if (existingUser != null) {
        // Zaten oturum açık → step 7'yi atla, direkt profil kaydet
        await _completeFinalOnboardingProfileSave();
      } else {
        // Oturum yok → step 7 (Hesap Oluştur) göster
        _stepCtrl.reverse().then((_) {
          setState(() => _currentStep = 7);
          _stepCtrl.forward();
        });
      }
    }
  }

  void _prevStep() {
    if (_currentStep == 0) return;
    HapticFeedback.lightImpact();
    _stepCtrl.reverse().then((_) {
      setState(() => _currentStep--);
      _stepCtrl.forward();
    });
  }

  String _calculateZodiac(DateTime date) {
    final int d = date.day;
    final int m = date.month;
    if ((m == 3 && d >= 21) || (m == 4 && d <= 19)) return 'aries';
    if ((m == 4 && d >= 20) || (m == 5 && d <= 20)) return 'taurus';
    if ((m == 5 && d >= 21) || (m == 6 && d <= 20)) return 'gemini';
    if ((m == 6 && d >= 21) || (m == 7 && d <= 22)) return 'cancer';
    if ((m == 7 && d >= 23) || (m == 8 && d <= 22)) return 'leo';
    if ((m == 8 && d >= 23) || (m == 9 && d <= 22)) return 'virgo';
    if ((m == 9 && d >= 23) || (m == 10 && d <= 22)) return 'libra';
    if ((m == 10 && d >= 23) || (m == 11 && d <= 21)) return 'scorpio';
    if ((m == 11 && d >= 22) || (m == 12 && d <= 21)) return 'sagittarius';
    if ((m == 12 && d >= 22) || (m == 1 && d <= 19)) return 'capricorn';
    if ((m == 1 && d >= 20) || (m == 2 && d <= 18)) return 'aquarius';
    return 'pisces';
  }

  void _showGlassError(String message) {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
      padding: EdgeInsets.zero,
      content: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFF2D55).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFF2D55).withOpacity(0.35), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF2D55).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.error_outline_rounded, color: Color(0xFFFF2D55), size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      duration: const Duration(seconds: 4),
    ));
  }

  void _transitionToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const RootShell(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  Future<void> _checkAndRouteUser() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user != null) {
      try {
        final profile = await supabase.from('profiles').select('full_name, username, zodiac_sign, handle, avatar_url').eq('id', user.id).maybeSingle();
        if (profile != null && profile['full_name'] != null) {
           // HESAP VAR: Verileri indir ve direkt ana ekrana yönlendir
           await StorageService.setUserName(profile['full_name'].toString());
           if(profile['username'] != null) {
             await StorageService.setUserHandle(profile['username'].toString());
           }
           if(profile['handle'] != null) {
             await StorageService.setUserHandle(profile['handle'].toString());
           }
           if(profile['avatar_url'] != null) {
             await StorageService.setAvatar(profile['avatar_url'].toString());
           }
           if(profile['zodiac_sign'] != null) {
             await StorageService.setZodiacSign(profile['zodiac_sign'].toString());
           }
           
           // Giriş yapıldığında Buluttaki bakiyeyi cihaz hafızasına indir!
           await StorageService.fetchEconomyFromCloud();
           
           if (!mounted) return;
           _transitionToHome();
           return;
        }
      } catch (e) {
        debugPrint('Profil kurtarma hatası: $e');
      }
      
      // Profil yok ama hesap var → Onboarding'e yönlendir (profil tamamlasın)
      // Oturumu KAPATMA! Auth hesabı zaten oluştu, sadece profil eksik.
      if (!mounted) return;
      _showGlassError('Hoş geldin! Profilini tamamlamak için birkaç adım kaldı.');
      setState(() {
        _showLoginButtons = false;
        _currentStep = 1; // Onboarding adımlarına yönlendir
      });
      _stepCtrl.forward(from: 0.0);
      return;
    }
    
    if (!mounted) return;
    _showGlassError('Giriş başarısız oldu. Lütfen tekrar deneyin.');
    setState(() {
      _showLoginButtons = false;
    });
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isAuthLoading = true);
    try {
      final response = await AuthService().signInWithGoogle();
      if (response != null && mounted) {
        await _checkAndRouteUser();
      }
    } catch (e) {
      if (kDebugMode) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Test Modu: Eski hesaba giriş simüle ediliyor...', style: TextStyle(color: Colors.white))));
        await AuthService().signInAnonymously();
        // Gerçek bir eski kullanıcı girişini simüle etmek için sahte önbellek:
        await StorageService.setUserName("Alpha Tester");
        await StorageService.setUserHandle("alpha_tester");
        await StorageService.setZodiacSign("scorpio");
        if (mounted) {
          _transitionToHome();
        }
        return;
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red.shade900,
        behavior: SnackBarBehavior.floating,
        content: Text('Google Girişi Başarısız: $e', style: const TextStyle(color: Colors.white)),
        duration: const Duration(seconds: 8),
      ));
    } finally {
      if (mounted) setState(() => _isAuthLoading = false);
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _isAuthLoading = true);
    try {
      final response = await AuthService().signInWithApple();
      if (response != null && mounted) {
        await _checkAndRouteUser();
      }
    } catch (e) {
      if (kDebugMode) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Test Modu: Eski hesaba giriş simüle ediliyor...', style: TextStyle(color: Colors.white))));
        await AuthService().signInAnonymously();
        // Gerçek bir eski kullanıcı girişini simüle etmek için sahte önbellek:
        await StorageService.setUserName("Alpha Tester");
        await StorageService.setUserHandle("alpha_tester");
        await StorageService.setZodiacSign("scorpio");
        if (mounted) {
          _transitionToHome();
        }
        return;
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red.shade900,
        behavior: SnackBarBehavior.floating,
        content: Text('Apple Girişi Başarısız: $e', style: const TextStyle(color: Colors.white)),
        duration: const Duration(seconds: 8),
      ));
    } finally {
      if (mounted) setState(() => _isAuthLoading = false);
    }
  }

  /// Zaten kayıtlı bir profili olan kullanıcıyı tespit edip engelleyen ortak kontrol.
  /// true dönerse: profil zaten var, işlem iptal edilmeli.
  /// false dönerse: yeni kullanıcı, kayıt devam edebilir.
  Future<bool> _isAlreadyRegistered(String provider) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return false;
      
      debugPrint('🔍 [$provider] Profil kontrolü yapılıyor... User ID: ${user.id}');
      final profile = await supabase.from('profiles').select('full_name').eq('id', user.id).maybeSingle();
      debugPrint('🔍 [$provider] Profil sonucu: $profile');
      
      if (profile != null && profile['full_name'] != null) {
        debugPrint('🚫 [$provider] ZATEN KAYITLI! Oturum kapatılıyor...');
        await supabase.auth.signOut();
        if (mounted) {
          _showGlassError('Bu $provider hesabı ile zaten bir kozmik profilin var! Lütfen ilk sayfadaki "Giriş Yap" seçeneğini kullan.');
        }
        return true;
      }
    } catch (e) {
      debugPrint('⚠️ [$provider] Profil kontrol hatası: $e');
    }
    return false;
  }

  Future<void> _handleFinalGoogleSignIn() async {
    setState(() => _isAuthLoading = true);
    try {
      final response = await AuthService().signInWithGoogle();
      if (response != null && mounted) {
        if (await _isAlreadyRegistered('Google')) return;
        await _completeFinalOnboardingProfileSave();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [Google] Gerçek giriş başarısız, test modunda anonim deneniyor: $e');
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Test Modu: Anonim bağlanılıyor...', style: TextStyle(color: Colors.white))));
        await AuthService().signInAnonymously();
        // Anonim modda bile zaten kayıtlı kontrolü yap
        if (await _isAlreadyRegistered('Google-Test')) return;
        await _completeFinalOnboardingProfileSave();
        return;
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red.shade900,
        behavior: SnackBarBehavior.floating,
        content: Text('Google Kaydı Başarısız: $e', style: const TextStyle(color: Colors.white)),
        duration: const Duration(seconds: 8),
      ));
    } finally {
      if (mounted) setState(() => _isAuthLoading = false);
    }
  }

  Future<void> _handleFinalAppleSignIn() async {
    setState(() => _isAuthLoading = true);
    try {
      final response = await AuthService().signInWithApple();
      if (response != null && mounted) {
        if (await _isAlreadyRegistered('Apple')) return;
        await _completeFinalOnboardingProfileSave();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [Apple] Gerçek giriş başarısız, test modunda anonim deneniyor: $e');
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Test Modu: Anonim bağlanılıyor...', style: TextStyle(color: Colors.white))));
        await AuthService().signInAnonymously();
        // Anonim modda bile zaten kayıtlı kontrolü yap
        if (await _isAlreadyRegistered('Apple-Test')) return;
        await _completeFinalOnboardingProfileSave();
        return;
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red.shade900,
        behavior: SnackBarBehavior.floating,
        content: Text('Apple Kaydı Başarısız: $e', style: const TextStyle(color: Colors.white)),
        duration: const Duration(seconds: 8),
      ));
    } finally {
      if (mounted) setState(() => _isAuthLoading = false);
    }
  }



  Future<void> _completeFinalOnboardingProfileSave() async {
    HapticFeedback.heavyImpact();
    
    // Sabit avatar havuzundan index'e göre asset path çekimi
    final List<String> avatarPool = [
      'assets/images/avatars/avatar_1.png',
      'assets/images/avatars/avatar_2.png',
      'assets/images/avatars/avatar_3.png',
      'assets/images/avatars/avatar_4.png',
      'assets/images/avatars/avatar_5.png',
      'assets/images/avatars/avatar_6.png',
      'assets/images/avatars/avatar_7.png',
      'assets/images/avatars/avatar_8.png',
      'assets/images/avatars/avatar_9.png',
      'assets/images/avatars/avatar_10.png',
      'assets/images/avatars/avatar_11.png',
      'assets/images/avatars/avatar_12.png',
    ];
    final String selectedAvatarUrl = avatarPool[_selectedAvatarIndex];
    
    debugPrint('💾 Profil kaydı başlıyor...');
    debugPrint('💾 İsim: ${_nameCtrl.text.trim()}, Handle: ${_usernameCtrl.text.trim()}, Burç: ${_calculateZodiac(_selectedDate)}');
    
    // Lokal veriler kaydediliyor
    await StorageService.setUserName(_nameCtrl.text.trim());
    await StorageService.setUserHandle(_usernameCtrl.text.trim());
    await StorageService.setAvatar(selectedAvatarUrl);
    await StorageService.setZodiacSign(_calculateZodiac(_selectedDate));
    await StorageService.setBirthDate(_selectedDate);
    if (_knowsTime && _selectedTime != null) {
      await StorageService.setBirthTime(DateFormat('HH:mm').format(_selectedTime!));
    }
    if (_selectedLocation != null) {
      await StorageService.setBirthPlace(_selectedLocation!);
    }
    await StorageService.setLifeFocus(_lifeFocus.join(", "));
    await StorageService.setRelationshipStatus(_relationship);
    await StorageService.setDreamFrequency(_dreamFrequency);
    await StorageService.setAuraColor(_auraColor);
    await StorageService.setSleepPattern(_sleepPattern);
    
    debugPrint('✅ Lokal kayıt tamamlandı!');

    // Buluta (Supabase) Senkronize Ediliyor
    dynamic syncResult = false;
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      debugPrint('☁️ Supabase senkronizasyonu başlıyor...');
      syncResult = await ProfileSyncService().syncProfileData(
        userName: _nameCtrl.text.trim(),
        userHandle: _usernameCtrl.text.trim(),
        avatarUrl: selectedAvatarUrl,
        zodiacSign: _calculateZodiac(_selectedDate),
      );
      debugPrint('☁️ Supabase senkronizasyon sonucu: ${syncResult == true ? "BAŞARILI ✅" : "BAŞARISIZ ❌ $syncResult"}');
      
      // ✅ BAŞARILI İSE: Varsa davet kodunu (referral) tetikle!
      if (syncResult == true) {
        await ReferralService.processPendingReferrals(currentUser.id);
        
        // Hoş Geldin Bonusu (İlk kez kayıt olanlara 3 Ruh Taşı)
        final prefs = await SharedPreferences.getInstance();
        if (!(prefs.getBool('welcome_bonus_claimed') ?? false)) {
          // getSoulStones zaten boş hesaplara otomatik 3 taş atar.
          // Burada tekrar ekleme (update) yapmaya gerek yok, sadece senkronize ediyoruz.
          await StorageService.getSoulStones(); 
          await StorageService.syncEconomyToCloud();
          await prefs.setBool('welcome_bonus_claimed', true);
          await prefs.setBool('needs_welcome_dialog', true); // Ana sayfada kutlama göstermek için bayrak
          debugPrint('🎁 Hoş Geldin Bonusu verildi: +3 Ruh Taşı');
        }
      }
    } else {
      debugPrint('⚠️ Supabase auth kullanıcısı null - bulut senkronizasyonu atlandı');
    }

    if (!mounted) return;
    
    // EĞER BULUT KAYDI BAŞARISIZ OLDUYSA İŞLEMİ DURDUR
    if (syncResult != true && Supabase.instance.client.auth.currentUser != null) {
       _showGlassError('Kayıt işlemi veritabanında reddedildi:\n$syncResult\nLütfen destek ile iletişime geçin.');
       // Sisteme çöp oturum kalmasın diye iptal edelim
       await Supabase.instance.client.auth.signOut();
       return;
    }

    AnalyticsService().logProfileCreated();
    _transitionToHome();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeData>(
      valueListenable: AppThemeController.notifier,
      builder: (context, palette, _) {
        return LiquidGlassScope.stack(
          background: Stack(
            fit: StackFit.expand,
            children: [
              Container(decoration: const BoxDecoration(color: Color(0xFF151726))), // Keskin siyahtan daha yumuşak gece tonuna geçildi
              Positioned.fill(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: _currentStep == 0 ? 1.0 : 0.45, // Arka planı biraz daha yumuşattık (0.6 -> 0.45)
                  child: CinematicAuroraWind(
                    child: Image.asset(
                      "assets/images/serene_welcome.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: RepaintBoundary(
                  child: Opacity(
                    opacity: 0.15, // Reduce the noisy painter opacity heavily so the artwork shines beautifully
                    child: CustomPaint(painter: _OnboardingMottledPainter()),
                  ),
                ),
              ),
            ],
          ),
          content: Scaffold(
            resizeToAvoidBottomInset: false, // KLAVYE ÇAKIŞMA ÇÖZÜMÜ: Sayfanın kendi kendine itilmesini kapatıp %100 kontrolü TweenAnimation'a veriyoruz!
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
            extendBody: true, // Alt kısımdaki kesikleri engeller, cam efekti pürüzsüz çalışır
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent, // Fixes iOS scroll dark overlay issue
              elevation: 0,
              leading: _currentStep > 0
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white54, size: 20),
                      onPressed: _prevStep,
                    )
                  : const SizedBox.shrink(),
              actions: const [], // Sağ üst köşe tamamen temizlendi, adım göstergesi en alta taşındı
            ),
            body: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                  position: _slideAnim,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          clipBehavior: Clip.none, // Avatarların sağa sola taşmasına izin verir (akıcı geçiş)
                          physics: _currentStep <= 6 ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(top: 140, bottom: 220), // Alt menü ile çakışmayı önlemek için bottom artırıldı
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: constraints.maxHeight - 120),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                if (_currentStep > 0 && _currentStep < 7) 
                                   _buildDynamicHeader(), // Sabitlenmiş Başlık
                                if (_currentStep == 0) SizedBox(height: MediaQuery.of(context).size.height * 0.62, child: _buildWelcomeStep()),
                                if (_currentStep == 1) _buildFeaturesStep(),
                                if (_currentStep == 2) _buildStep0(),
                                if (_currentStep == 3) _buildStepDateWithWheels(),
                                if (_currentStep == 4) _buildStep1(),
                                if (_currentStep == 5) _buildStep2(),
                                if (_currentStep == 6) _buildStep3(),
                                if (_currentStep == 7) SizedBox(height: MediaQuery.of(context).size.height * 0.62, child: _buildWelcomeStep(isFinal: true)),
                              ],
                            ),
                          ),
                        );
                      }
                    ),
                  ),
                ),
              ),
            bottomNavigationBar: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 28, right: 28, top: 8, bottom: 0), // Küçük telefon optimizasyonu
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Kilit yazısı sayfa göstergeleri ve Butonun "ÜSTÜNE" taşındı
                      if (_currentStep == 3) ...[
                        const SizedBox(height: 16), // Form kutusundan ayrılması için nefes boşluğu eklendi
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(PhosphorIcons.lockKey(PhosphorIconsStyle.fill), color: Colors.white.withOpacity(0.15), size: 14),
                            const SizedBox(width: 8),
                            Text(
                              "Yalnızca sana özel haritanı çizmek içindir.",
                              style: GoogleFonts.nunito(color: Colors.white.withOpacity(0.3), fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8), // Kilit simgesi ile roman rakamları arası daraltıldı
                      ],
                      // Açık liste: Tüm Roma Rakamları (pasifler soluk, aktif olan parlak)
                      if (_currentStep > 0 && _currentStep < 7)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(6, (index) {
                            final romanNums = ['I', 'II', 'III', 'IV', 'V', 'VI'];
                            final isActive = (_currentStep - 1) == index;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5.0),
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: GoogleFonts.cinzel(
                                  color: isActive ? const Color(0xFFD3A29B) : Colors.white.withOpacity(0.25),
                                  fontSize: 14, // Cinzel biraz küçük kaldığı için bir tık (+1) büyütüldü
                                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                                  letterSpacing: 1.0,
                                  shadows: isActive 
                                    ? [Shadow(color: const Color(0xFFD3A29B).withOpacity(0.6), blurRadius: 10)] 
                                    : [],
                                ),
                                child: Text(romanNums[index]),
                              ),
                            );
                          }),
                        ),
                      const SizedBox(height: 4), // Roma rakamları butonlara doğru aşağıya yaklaştıırıldı
                      if (_currentStep != 0 && _currentStep < 7) ...[
                        _buildNextButton(
                          title: _currentStep == 6 ? "Yolculuğa Başla" : "Devam Et",
                          icon: _currentStep == 6 ? PhosphorIcons.sparkle(PhosphorIconsStyle.fill) : PhosphorIcons.arrowRight(PhosphorIconsStyle.bold),
                          onTap: _nextStep,
                          glowColor: const Color(0xFFC36E6E),
                        ),
                      ] else if (_currentStep == 0) ...[
                        Stack(
                          alignment: Alignment.bottomCenter, // "Hadi Başlayalım" butonunu orijinal en alt noktasına çiviler!
                          clipBehavior: Clip.none,
                          children: [
                            // 1. Durum: Kayıt Ol Modu (Hadi Başlayalım Butonu)
                            IgnorePointer(
                              ignoring: _showLoginButtons,
                              child: AnimatedSlide(
                                offset: _showLoginButtons ? const Offset(0.0, 0.1) : Offset.zero, // Çıkarken usulca aşağı süzülme
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeOutQuint,
                                child: AnimatedOpacity(
                                  opacity: _showLoginButtons ? 0.0 : 1.0,
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeOut,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 24.0), // "Hadi Başlayalım" butonunu alt yazıdan hafifçe koparıp havaya kaldırır
                                    child: _buildNextButton(
                                      title: "Hadi Başlayalım",
                                      icon: PhosphorIcons.arrowRight(PhosphorIconsStyle.bold),
                                      onTap: _nextStep,
                                      glowColor: const Color(0xFFC36E6E),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // 2. Durum: Giriş Yap Modu (Apple ve Google Butonları)
                            IgnorePointer(
                              ignoring: !_showLoginButtons,
                              child: AnimatedSlide(
                                offset: _showLoginButtons ? Offset.zero : const Offset(0.0, 0.08), // Girerken dipten yukarı yumuşak bir yükseliş
                                duration: const Duration(milliseconds: 700),
                                curve: Curves.easeOutExpo,
                                child: AnimatedScale(
                                  scale: _showLoginButtons ? 1.0 : 0.95, // Derinlik hissiyatı için ufak bir büyüme (Scale)
                                  duration: const Duration(milliseconds: 700),
                                  curve: Curves.easeOutExpo,
                                  child: AnimatedOpacity(
                                    opacity: _showLoginButtons ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 450),
                                    curve: Curves.easeOut,
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 20.0), // 100 pixel çok geldiği için "bir tık" (30px) düşürülerek tam odak merkeze alındı
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                      if (_isAuthLoading)
                                        const SizedBox(
                                          height: 124,
                                          child: Center(
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                          ),
                                        )
                                    else ...[
                                      _buildAuthButton(
                                        icon: Icons.apple,
                                        label: "Apple ile Giriş Yap",
                                        color: Colors.white,
                                        textColor: Colors.black,
                                        onTap: _handleAppleSignIn,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildAuthButton(
                                        icon: Icons.g_mobiledata_rounded,
                                        label: "Google ile Giriş Yap",
                                        color: Colors.white.withOpacity(0.1),
                                        textColor: Colors.white,
                                        onTap: _handleGoogleSignIn,
                                      ),
                                    ],
                                  ],
                                ),
                              ), // Padding closing
                            ), // AnimatedOpacity closing
                                ), // AnimatedScale closing
                              ), // AnimatedSlide closing
                            ), // IgnorePointer closing
                          ],
                        ),
                      const SizedBox(height: 16),
                      Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _showLoginButtons = !_showLoginButtons;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            highlightColor: Colors.white.withOpacity(0.05),
                            splashColor: Colors.white.withOpacity(0.1),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text.rich(
                                  key: ValueKey(_showLoginButtons),
                                  TextSpan(
                                    text: _showLoginButtons ? "Henüz evrene katılmadın mı?  " : "Zaten evrene katıldın mı?  ",
                                    style: GoogleFonts.nunito(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 13,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: _showLoginButtons ? "Kayıt Ol" : "Giriş Yap",
                                        style: GoogleFonts.nunito(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ] else if (_currentStep == 7) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 70.0), // İlk sayfadaki butonlarla birebir aynı seviyede tutuldu
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isAuthLoading)
                                const SizedBox(
                                  height: 124,
                                  child: Center(
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  ),
                                )
                              else ...[
                                _buildAuthButton(
                                  icon: Icons.apple,
                                  label: "Apple ile Hesabını Oluştur",
                                  color: Colors.white,
                                  textColor: Colors.black,
                                  onTap: _handleFinalAppleSignIn,
                                ),
                                const SizedBox(height: 12),
                                _buildAuthButton(
                                  icon: Icons.g_mobiledata_rounded,
                                  label: "Google ile Hesabını Oluştur",
                                  color: Colors.white.withOpacity(0.1),
                                  textColor: Colors.white,
                                  onTap: _handleFinalGoogleSignIn,
                                ),
                              ],
                            ],
                          ),
                        ),
                        // 7. adımda butonlar arasına mesafe konarak tam splash düzenini yakalıyoruz
                        const SizedBox(height: 48), // BottomBar'ı aşağıdan esnetir
                      ],
                      // Yasal Bilgilendirme — Ekranın En Altı (Sadece auth butonları görünürken)
                      if (_currentStep == 0 || _currentStep == 7)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8, top: 4),
                          child: _buildLegalDisclaimer(),
                        ),
                    ], // Column children
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

  // ==========================================
  // SHARED UI COMPONENTS
  // ==========================================

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildLegalDisclaimer() {
    return Text.rich(
      TextSpan(
        text: 'By continuing, you agree to our ',
        style: GoogleFonts.nunito(
          color: Colors.white.withOpacity(0.3),
          fontSize: 11,
          height: 1.5,
        ),
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: () => _openUrl('https://crackwish.com/terms.html'),
              child: Text(
                'Terms of Use',
                style: GoogleFonts.nunito(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white.withOpacity(0.25),
                ),
              ),
            ),
          ),
          TextSpan(
            text: ' and ',
            style: GoogleFonts.nunito(
              color: Colors.white.withOpacity(0.3),
              fontSize: 11,
            ),
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: () => _openUrl('https://crackwish.com/privacy.html'),
              child: Text(
                'Privacy Policy',
                style: GoogleFonts.nunito(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white.withOpacity(0.25),
                ),
              ),
            ),
          ),
          TextSpan(
            text: '.',
            style: GoogleFonts.nunito(
              color: Colors.white.withOpacity(0.3),
              fontSize: 11,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
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

  Widget _buildDynamicHeader() {
    String title = "";
    String subtitle = "";
    
    switch (_currentStep) {
      case 1:
        title = "Seni Neler Bekliyor?";
        subtitle = "Evrenin fısıltılarına kulak verip kaderini keşfetmeye hazır mısın?";
        break;
      case 2:
        title = "Seni Tanıyalım";
        subtitle = "Ruh eşlerinin seni bulabilmesi için profilini oluştur ve kozmik kimliğini belirle.";
        break;
      case 3:
        title = "Kozmik Koordinat";
        subtitle = "Astrolojik haritanın temeli için doğduğun anı seç.";
        break;
      case 4:
        title = "Kalbinin Pusulası";
        subtitle = "Niyetini belirle, yolunu çizelim.";
        break;
      case 5:
        title = "Bilinçaltının Sesi";
        subtitle = "Rüyaların sana nasıl ulaşıyor?";
        break;
      case 6:
        title = "İçsel Pusulan";
        subtitle = "Hayatındaki kadersel dönüm noktalarında yolunu nasıl bulursun?";
        break;
      default:
        return const SizedBox.shrink();
    }

    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    // Sadece 2. adımda (İsim girme bölümü) klavye açılınca başlığı da loşlaştır
    final bool shouldDim = isKeyboardOpen && _currentStep == 2;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      opacity: shouldDim ? 0.1 : 1.0,
      child: Column(
        key: ValueKey('header_$_currentStep'), // Her adım değişiminde taze bir yapı
        children: [
          _buildTitle(title),
          _buildSubtitle(subtitle),
        ],
      ),
    );
  }

  Widget _buildTitle(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.nunito(
        color: Colors.white,
        fontSize: 32, // Zarif punto
        fontWeight: FontWeight.w600, // crack&wish logosuyla birebir aynı kalınlık (w600)
        height: 1.2,
        letterSpacing: -0.5,
        shadows: [
          Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
    );
  }

  Widget _buildSubtitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12), // Boşluk israfı engellenerek panellerin sığması sağlandı
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.nunito(
          color: Colors.white.withOpacity(0.85),
          fontSize: 16,
          fontWeight: FontWeight.w500, // Daha okunaklı ve ince alt başlık (w700 -> w500)
          height: 1.4,
          letterSpacing: 0.0,
          shadows: [
            Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 12, offset: const Offset(0, 2)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14, top: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: const Color(0xFFD18471).withOpacity(0.9), size: 18),
            const SizedBox(width: 8),
          ],
          Text(
            text.toUpperCase(),
            style: GoogleFonts.nunito(
              color: Colors.white.withOpacity(0.45),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(IconData icon, String label, String currentVal, Function(String) onSelect, {int index = 0}) {
    final isSelected = label == currentVal;
    
    return StaggeredFade(
      delay: Duration(milliseconds: 150 + (index * 50)),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onSelect(label);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.04), // Cam arka plan
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFEEDBD5) : Colors.white.withOpacity(0.10), // Pastel çerçeve
                    width: isSelected ? 2.0 : 1.0,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(color: const Color(0xFFD3A29B).withOpacity(0.2), blurRadius: 24, spreadRadius: 2) // Yumuşak parlama
                  ] : [],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.white.withOpacity(0.08),
                        shape: BoxShape.circle,
                        boxShadow: isSelected ? [
                          BoxShadow(color: Colors.white.withOpacity(0.4), blurRadius: 16)
                        ] : [],
                      ),
                      child: Icon(icon, color: isSelected ? const Color(0xFFD3A29B) : Colors.white.withOpacity(0.7), size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        label,
                        style: GoogleFonts.nunito(
                          color: isSelected ? Colors.white : Colors.white.withOpacity(0.85),
                          fontSize: 16,
                          letterSpacing: 0.1,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
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
    );
  }

  Widget _buildGridOption(IconData icon, String label, List<String> currentVals, Function(String) onSelect, {int index = 0}) {
    final isSelected = currentVals.contains(label);
    
    return StaggeredFade(
      delay: Duration(milliseconds: 150 + (index * 50)),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onSelect(label);
        },
        child: SizedBox.expand(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.04), // Seçiliyken cam efektini güçlendirecek fon
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFEEDBD5) : Colors.white.withOpacity(0.10),
                    width: isSelected ? 2.0 : 1.0,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(color: const Color(0xFFD3A29B).withOpacity(0.2), blurRadius: 24, spreadRadius: 2)
                  ] : [],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.08),
                            shape: BoxShape.circle,
                            boxShadow: isSelected ? [
                              BoxShadow(color: Colors.white.withOpacity(0.4), blurRadius: 16)
                            ] : [],
                          ),
                          child: Icon(icon, color: isSelected ? const Color(0xFFD3A29B) : Colors.white.withOpacity(0.7), size: 28),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            label,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper for inputs ---
  Widget _buildCosmicInput({required Widget child, VoidCallback? onTap, Duration? delay}) {
    return StaggeredFade(
      delay: delay ?? const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                  width: 1,
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.06),
                    Colors.transparent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              alignment: Alignment.center,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // HELPER FOR UNIFIED COSMIC CARDS
  Widget _buildUnifiedInputRow({IconData? icon, Widget? customIcon, required String title, required Widget child, VoidCallback? onTap, Widget? suffix}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minHeight: 52), // Ultra ince ve zarif görünüm için yükseklik daha da kısıldı
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6), 
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFCE4EC).withOpacity(0.25), // Çok hafif, tatlı bir toz pembe dokunuşu
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.0), // Sınırlar ince parıltılı
                boxShadow: [
                  BoxShadow(color: const Color(0xFFFCE4EC).withOpacity(0.2), blurRadius: 12),
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6),
                ],
              ),
              child: customIcon ?? Icon(icon, color: Colors.white, size: 23),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: GoogleFonts.nunito(color: Colors.white.withOpacity(0.35), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                  const SizedBox(height: 4),
                  child,
                ],
              ),
            ),
            if (suffix != null) suffix,
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 76, right: 20), // Ayraç tam olarak yazının başlangıç hizasına oturtuldu (20 padding + 40 icon + 16 gap)
      child: Divider(color: Colors.white.withOpacity(0.06), height: 1),
    );
  }

  // ==========================================
  Widget _buildWelcomeStep({bool isFinal = false}) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 60), // Kurabiyenin tavanla arasındaki boşluk artırılarak icon hafifçe aşağı indirildi
          
          // Asset Şans Kurabiyesi Görseli
          Image.asset(
            'assets/icons/splash_cookie.png',
            width: 120, // Kibar ve doygun
            height: 120,
            fit: BoxFit.contain,
            color: Colors.white, // Cihaz temasına göre bozulmayı önler
          ),
          const Spacer(flex: 2), // Esnek boşluk daraltılarak logo ve motto bloğu hafifçe yukarı (kurabiyeye doğru) çekildi
          
          // Düz yazılış, gölgelerden tamamen arındırılmış crack&wish
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.nunito(
                fontSize: 46, // İdeal logonun görsel ağırlığı için hafif yumuşatıldı
                fontWeight: FontWeight.w600, // Yarı kalın (SemiBold) - tam görseldeki o yumuşak ama belirgin dolgunluk
                letterSpacing: 0.0, // Harfler arası nefes payı açıldı
                color: Colors.white,
                // Kullanıcı isteği: Shadows tamamen silindi
              ),
              children: [
                const TextSpan(text: 'crack'),
                TextSpan(
                  text: '&', 
                  style: GoogleFonts.nunito(
                    color: const Color(0xFFD3A29B),
                    fontWeight: FontWeight.w400, // & işareti logoda bir tık ince kalarak tipografik estetiği artırıyor
                    // Kullanıcı isteği: Shadows tamamen silindi
                  ),
                ),
                const TextSpan(text: 'wish'),
              ],
            ),
          ),
          
          const SizedBox(height: 12), // Logo ile Motto arasındaki mesafe eski haline (12) döndürüldü
          
          // Kullanıcının Özel Beklenti Mottosu
          Text(
            isFinal ? "Kozmik haritanı güvenceye almak için tıkla." : "Bugün umutlarım hayallerimden daha büyük.",
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              color: Colors.white.withOpacity(0.85), // Premium puslu hissiyat
              fontSize: 16,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),

          const Spacer(flex: 4), 
        ],
      ),
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String text, double angle = 0.0}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24), // Yazılar ikonlarla beraber daha sola kaydırıldı (40'tan 24'e düşürüldü)
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
               color: const Color(0xFFFCE4EC).withOpacity(0.25), // Çok hafif, tatlı bir toz pembe dokunuşu
               shape: BoxShape.circle,
               border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.0), // Sınırlar ince parıltılı
               boxShadow: [
                 BoxShadow(color: const Color(0xFFFCE4EC).withOpacity(0.2), blurRadius: 12),
                 BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6),
               ],
            ),
            child: Transform.rotate(
              angle: angle,
              child: Icon(icon, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 12), // İkon ile metin arası mesafe daraltılarak yazılar daha da sola çekildi
          Expanded( 
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0), // Yazılar hizalanma amaçlı hafifçe aşağı kaydırıldı
              child: Text(
                text,
                textAlign: TextAlign.left,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 16, offset: const Offset(0, 4)),
                    Shadow(color: Colors.black.withOpacity(0.4), blurRadius: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesStep() {
    return Column(
        children: [
          const SizedBox(height: 64), // Yazı ve ikonlar arası boşluk biraz artırılarak aşağı alındı
          
          StaggeredFade(
            delay: const Duration(milliseconds: 50),
            child: _buildFeatureItem(icon: PhosphorIcons.sparkle(PhosphorIconsStyle.fill), text: "Sana Özel Astroloji Haritası"),
          ),
          StaggeredFade(
            delay: const Duration(milliseconds: 100),
            child: _buildFeatureItem(
              icon: PhosphorIcons.cards(PhosphorIconsStyle.fill), 
              text: "Yol Gösterici Tarot Serüveni",
              angle: math.pi / 2, // Yatay kartları gerçek dikey (vertical) tarot destesi formuna çevirir
            ),
          ),
          StaggeredFade(
            delay: const Duration(milliseconds: 150),
            child: _buildFeatureItem(icon: PhosphorIcons.coffee(PhosphorIconsStyle.fill), text: "Telvelerde Gizlenen Kadim Kahve Falı Sırları"),
          ),
          StaggeredFade(
            delay: const Duration(milliseconds: 200),
            child: _buildFeatureItem(icon: PhosphorIcons.moonStars(PhosphorIconsStyle.fill), text: "Bilinçaltı Rüya Analizleri"),
          ),
          StaggeredFade(
            delay: const Duration(milliseconds: 250),
            child: _buildFeatureItem(icon: PhosphorIcons.infinity(PhosphorIconsStyle.bold), text: "Mistik Çin & Maya Uyumları"),
          ),
        ],
      );
  }


  // ==========================================
  // PROFİL INPUTLARI (İSİM VE KULLANICI ADI)
  Widget _buildNameInputs({bool isDummy = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildUnifiedInputRow(
           customIcon: Transform.scale(
             scale: 1.4,
             child: Image.asset('assets/images/owl.png', width: 38, height: 38),
           ),
           title: "PROFİL ADIN",
           child: TextField(
               controller: isDummy ? null : _nameCtrl,
               focusNode: isDummy ? null : _nameFocus,
               style: GoogleFonts.nunito(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.2),
               cursorColor: const Color(0xFFD18471), // Lüks altın/somon
               textCapitalization: TextCapitalization.words,
               decoration: InputDecoration(
                 border: InputBorder.none,
                 isDense: true,
                 contentPadding: EdgeInsets.zero,
                 hintText: "Örn: Yıldız Tozu \uD83C\uDF19",
                 hintStyle: GoogleFonts.nunito(color: Colors.white.withOpacity(0.2), fontSize: 16),
               ),
           ),
        ),
        _buildDivider(),
        // 2. Kullanıcı Adı (Benzersiz, Aramalarda Bulunmak İçin)
        _buildUnifiedInputRow(
           icon: PhosphorIcons.at(PhosphorIconsStyle.fill),
           title: "KULLANICI ADI",
           child: TextField(
               controller: isDummy ? null : _usernameCtrl,
               focusNode: isDummy ? null : _usernameFocus,
               onChanged: isDummy ? null : (_) {
                 if (_handleError != null) setState(() => _handleError = null);
               },
               style: GoogleFonts.nunito(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
               cursorColor: const Color(0xFFD18471),
               keyboardType: TextInputType.emailAddress,
               decoration: InputDecoration(
                 border: InputBorder.none,
                 isDense: true,
                 contentPadding: EdgeInsets.zero,
                 hintText: "@kozmikyolcu",
                 hintStyle: GoogleFonts.nunito(color: Colors.white.withOpacity(0.2), fontSize: 16),
                 suffixIcon: _isCheckingHandle
                     ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white38))
                     : null,
                 suffixIconConstraints: const BoxConstraints(maxWidth: 24, maxHeight: 24),
               ),
           ),
        ),
        // Handle hata mesajı
        if (_handleError != null)
          Padding(
            padding: const EdgeInsets.only(left: 52, top: 4),
            child: Text(
              _handleError!,
              style: GoogleFonts.nunito(color: const Color(0xFFF87171), fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }

  Widget _buildStep0() {
    // Klavye kapanma tepkisini "ANINDA" almak için Focus statülerini de ekledik (Gecikme tamamen silinir)
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 40 || _nameFocus.hasFocus || _usernameFocus.hasFocus;

    return SizedBox(
      height: 390, // Altın oran
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. ZEMİN KATMani (Title, Subtitle, Avatar her zaman burada)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              opacity: isKeyboardOpen ? 0.1 : 1.0, 
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  StaggeredFade(
                    delay: const Duration(milliseconds: 100),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      child: _AvatarCoverFlow(
                        selectedIndex: _selectedAvatarIndex,
                        onSelected: (idx) {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedAvatarIndex = idx);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  // Dummy placeholder for exact alignment
                  Opacity(
                    opacity: 0.0,
                    child: IgnorePointer(
                      child: _buildGlassCard(
                        delay: 0,
                        shake: false,
                        child: _buildNameInputs(isDummy: true),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. AKTİF İNPUT PANELİ (Hardware Accelerated - %100 CPU'suz Grafik Motorunda Kayar)
          Align(
            alignment: Alignment.bottomCenter, // Fiziksel olarak daima altta durur
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0.0, 
                end: isKeyboardOpen ? -170.0 : 0.0 // Klavye açıldığında -170 piksel yukarı süzülür
              ),
              duration: const Duration(milliseconds: 300), // Süre biraz yumuşatıldı
              curve: Curves.easeOutQuart, // Quart kavis kaymak gibi süzülür
              builder: (context, translateY, child) {
                return Transform.translate(
                  offset: Offset(0, translateY),
                  child: child,
                );
              },
              child: _buildGlassCard(
                delay: 0,
                shake: true,
                child: _buildNameInputs(isDummy: false), // Gerçek text field'lar
              ),
            ),
          ),
        ],
      ),
    );
  }



  String _getWesternZodiac(DateTime d) {
    final month = d.month;
    final day = d.day;
    final signs = ['Oğlak', 'Kova', 'Balık', 'Koç', 'Boğa', 'İkizler', 'Yengeç', 'Aslan', 'Başak', 'Terazi', 'Akrep', 'Yay', 'Oğlak'];
    const cutoffs = [20, 19, 20, 20, 21, 21, 23, 23, 23, 23, 22, 22];
    return day < cutoffs[month - 1] ? signs[month - 1] : signs[month];
  }

  int _getWesternZodiacIndex(DateTime d) {
    final month = d.month;
    final day = d.day;
    final signsIdx = [9, 10, 11, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    const cutoffs = [20, 19, 20, 20, 21, 21, 23, 23, 23, 23, 22, 22];
    return day < cutoffs[month - 1] ? signsIdx[month - 1] : signsIdx[month];
  }

  String _getChineseZodiac(DateTime d) {
    final animals = ['Fare', 'Öküz', 'Kaplan', 'Tavşan', 'Ejderha', 'Yılan', 'At', 'Keçi', 'Maymun', 'Horoz', 'Köpek', 'Domuz'];
    return animals[(d.year - 4) % 12];
  }

  int _getChineseZodiacIndex(DateTime d) {
    return (d.year - 4) % 12;
  }

  String _getMayanZodiac(DateTime d) {
    // Gerçek Maya İsimleri ve Türkçe Anlamı bir arada gösterimi (örn. OC \n (KÖPEK))
    final idx = MayanZodiacData.nahualIndex(d);
    final nahual = MayanZodiacData.nahuales[idx];
    return "${nahual['name']}\n(${nahual['meaning']})".toUpperCase();
  }

  int _getMayanZodiacIndex(DateTime d) {
    // Profil sayfası ile %100 uyumlu tam isabet indeksi
    final nahualIdx = MayanZodiacData.nahualIndex(d);
    // Çark çizimi Maymun'dan (10. indeks) başladığı için +10 kaydırıyoruz
    return (nahualIdx + 10) % 20;
  }

  Widget _buildStepDateWithWheels() {
    final bool isSmallScreen = MediaQuery.of(context).size.height < 800; // Telefon ekranı ufaksa (örn iPhone SE, standart Android)
    final int wIndex = _getWesternZodiacIndex(_selectedDate);
    final int cIndex = _getChineseZodiacIndex(_selectedDate);
    final int mIndex = _getMayanZodiacIndex(_selectedDate);

    // Alt merkeze seçili burcu getirecek matematiksel formüller
    final double wTargetRotation = (165 - wIndex * 30) / 360.0;
    final double cTargetRotation = (180 - cIndex * 30) / 360.0;
    final double mTargetRotation = 2.0 - mIndex * 0.2;
    
    final String wSign = _hasSelectedDate ? _getWesternZodiac(_selectedDate).toUpperCase() : "BATI";
    final String cSign = _hasSelectedDate ? _getChineseZodiac(_selectedDate).toUpperCase() : "ASYA";
    final String mSign = _hasSelectedDate ? _getMayanZodiac(_selectedDate).toUpperCase() : "MAYA";

    return Column(
        children: [
        const SizedBox(height: 16), // Başlık menüden ayrıldıktan sonra çarkların arasına girmesini (çakışmayı) engeller
        // SizedBox boşluğu silinerek içerik bir tık yukarı çekildi
        StaggeredFade(
          delay: const Duration(milliseconds: 300),
          child: Container(
            height: isSmallScreen ? 180 : 230, // Küçük ekranda alt cam panele yer açmak için daraltıldı
            width: double.infinity,
            alignment: Alignment.topCenter,
            color: Colors.transparent,
            child: Transform.scale(
              scale: isSmallScreen ? 0.78 : 1.0, // Küçük ekranda çarklar ölçeklendi
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 330, 
                height: 230,
                child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SimpleConnectionPainter(),
                    ),
                  ),
                  Positioned(
                    top: 80, 
                    left: 95, // Ortaya hizalandı
                    width: 140,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: cTargetRotation),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeOutCubic,
                      builder: (context, angle, child) => _buildMiniWheel(cSign, ChineseWheelPainter(rotation: angle, gold: Colors.white, goldD: Colors.white.withOpacity(0.5)), 105),
                    ),
                  ),
                  Positioned(
                    left: -10, // En yüksekte
                    top: 0, // Merkez Y = 45
                    width: 140,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: wTargetRotation),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeOutCubic,
                      builder: (context, angle, child) => _buildMiniWheel(wSign, WesternWheelPainter(rotation: angle, gold: Colors.white, goldD: Colors.white.withOpacity(0.5)), 90),
                    ),
                  ),
                  Positioned(
                    left: 210, 
                    top: 40, // Asya ile orantılı
                    width: 140,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: mTargetRotation),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeOutCubic,
                      builder: (context, angle, child) => _buildMiniWheel(mSign, MayanWheelPainter(rotation: angle, gold: Colors.white, goldD: Colors.white.withOpacity(0.5), isMini: true), 96), 
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      _buildGlassCard(
        delay: 200, // Sayfa açılır açılmaz hızlıca belirmesi için gecikme azaltıldı
        shake: false, // TÜM KARTIN TİTREMESİ İPTAL EDİLDİ (Sadece doldurulmamış zorunlu alan titreyecek)
        child: Column(
            children: [
              AnimatedBuilder(
                animation: _shakeCtrl,
                builder: (context, animChild) {
                  // Eğer tarih seçilmediyse ve titreme başladıysa sarsıntı ve kırmızılık hissi
                  final isError = !_hasSelectedDate && _shakeCtrl.isAnimating;
                  final dx = isError ? math.sin(_shakeCtrl.value * math.pi * 6) * 12 * (1 - _shakeCtrl.value) : 0.0;
                  
                  return Transform.translate(
                    offset: Offset(dx, 0),
                    child: _buildUnifiedInputRow(
                       icon: PhosphorIcons.calendarStar(PhosphorIconsStyle.fill),
                       title: "DÜNYAYA GELİŞ TARİHİN", // (Burası Zorunlu) yazısı kaldırıldı, boyut değişmeyecek
                       child: Text(
                         _hasSelectedDate 
                            ? DateFormat('dd MMMM yyyy').format(_selectedDate) 
                            : "Doğum tarihini seç",
                         style: GoogleFonts.nunito(
                           color: isError 
                              ? const Color(0xFFE58888) // Hata anında kırmızı parlar
                              : (_hasSelectedDate ? Colors.white : Colors.white.withOpacity(0.25)), 
                           fontSize: _hasSelectedDate ? 15 : 12, 
                           fontWeight: FontWeight.w400
                         )
                       ),
                       onTap: () {
                         _nameFocus.unfocus();
                         _showDatePicker(context, mode: CupertinoDatePickerMode.date);
                       },
                       suffix: Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold), color: isError ? const Color(0xFFE58888) : Colors.white.withOpacity(0.3), size: 16),
                    ),
                  );
                }
              ),
              _buildDivider(),
              _buildUnifiedInputRow(
                 icon: PhosphorIcons.hourglass(PhosphorIconsStyle.fill),
                 title: "DOĞUM SAATİN (Opsiyonel)",
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(_selectedTime != null ? DateFormat('HH:mm').format(_selectedTime!) : "Tam saati biliyorsan detaylı analiz için gir", style: GoogleFonts.nunito(color: _selectedTime != null ? Colors.white : Colors.white.withOpacity(0.25), fontSize: _selectedTime != null ? 15 : 12, fontWeight: FontWeight.w400)),
                   ],
                 ),
                 onTap: () {
                   _nameFocus.unfocus();
                   _showDatePicker(context, mode: CupertinoDatePickerMode.time);
                 },
                 suffix: _selectedTime != null 
                    ? GestureDetector(
                        onTap: () => setState(() => _selectedTime = null),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)),
                          child: Icon(PhosphorIcons.x(PhosphorIconsStyle.bold), color: Colors.white.withOpacity(0.8), size: 12),
                        ),
                      )
                    : Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold), color: Colors.white.withOpacity(0.3), size: 16),
              ),
              _buildDivider(),
              _buildUnifiedInputRow(
                 icon: PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                 title: "DOĞUM YERİN (Opsiyonel)",
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(_selectedLocation ?? "Şehir seçerek hesaplamayı netleştir", style: GoogleFonts.nunito(color: _selectedLocation != null ? Colors.white : Colors.white.withOpacity(0.25), fontSize: _selectedLocation != null ? 15 : 12, fontWeight: FontWeight.w400)),
                   ],
                 ),
                 onTap: () {
                   _nameFocus.unfocus();
                   _showLocationPicker(context);
                 },
                 suffix: _selectedLocation != null 
                    ? GestureDetector(
                        onTap: () => setState(() => _selectedLocation = null),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)),
                          child: Icon(PhosphorIcons.x(PhosphorIconsStyle.bold), color: Colors.white.withOpacity(0.8), size: 12),
                        ),
                      )
                    : Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold), color: Colors.white.withOpacity(0.3), size: 16),
              ),
              const SizedBox(height: 2), // Alt sıranın cama yapışmasını engellemek için ufak boşluk
            ],
          ),
        ),
      ]
    );
  }


  Widget _buildGlassCard({required Widget child, required int delay, bool shake = true}) {
    return AnimatedBuilder(
      animation: _shakeCtrl,
      builder: (context, animChild) {
        // Hata anında sağa sola titreme efekti (Sine wave)
        final dx = shake ? math.sin(_shakeCtrl.value * math.pi * 6) * 12 * (1 - _shakeCtrl.value) : 0.0;
        return Transform.translate(
          offset: Offset(dx, 0),
          child: animChild,
        );
      },
      child: StaggeredFade(
        delay: Duration(milliseconds: delay),
        child: Container(
        margin: const EdgeInsets.only(top: 18), // Çark alanı yükseklik kazandığı için burası dengelendi
        decoration: BoxDecoration(
          color: const Color(0xFFFBE4EB).withOpacity(0.12), // Toz pembe eklendi, camsı zemin
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.18)), // Dış hatlar daha belirgin
          boxShadow: [
            BoxShadow(color: const Color(0xFFC36E6E).withOpacity(0.15), blurRadius: 40, spreadRadius: -5),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: child,
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildMiniWheel(String label, CustomPainter painter, double size) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: painter),
        ),
        const SizedBox(height: 2),
        Icon(PhosphorIcons.caretUp(PhosphorIconsStyle.fill), size: 12, color: Colors.white),
        // panelsiz tasarim
        Container(
          height: 28, // Sabit yükseklik, yazılar 2 satıra çıksa bile çarkı yukarı itmesini engeller
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          color: Colors.transparent,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return Transform.translate(
      offset: const Offset(0, -90),
      child: Column(
      children: [
        const SizedBox(height: 0),
        GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
            _buildGridOption(PhosphorIcons.eye(PhosphorIconsStyle.fill), "Ruhsal\nAydınlanma", _lifeFocus, (v) {
              setState(() {
                if (_lifeFocus.contains(v)) _lifeFocus.remove(v);
                else _lifeFocus.add(v);
              });
            }, index: 0),
            _buildGridOption(PhosphorIcons.rocketLaunch(PhosphorIconsStyle.fill), "Kariyer &\nKişisel Güç", _lifeFocus, (v) {
              setState(() {
                if (_lifeFocus.contains(v)) _lifeFocus.remove(v);
                else _lifeFocus.add(v);
              });
            }, index: 1),
            _buildGridOption(PhosphorIcons.heart(PhosphorIconsStyle.fill), "Aşk &\nKozmik Uyum", _lifeFocus, (v) {
              setState(() {
                if (_lifeFocus.contains(v)) _lifeFocus.remove(v);
                else _lifeFocus.add(v);
              });
            }, index: 2),
            _buildGridOption(PhosphorIcons.leaf(PhosphorIconsStyle.fill), "Şifa &\nİçsel Huzur", _lifeFocus, (v) {
              setState(() {
                if (_lifeFocus.contains(v)) _lifeFocus.remove(v);
                else _lifeFocus.add(v);
              });
            }, index: 3),
            _buildGridOption(PhosphorIcons.coins(PhosphorIconsStyle.fill), "Maddi Bolluk &\nBereket", _lifeFocus, (v) {
              setState(() {
                if (_lifeFocus.contains(v)) _lifeFocus.remove(v);
                else _lifeFocus.add(v);
              });
            }, index: 4),
            _buildGridOption(PhosphorIcons.planet(PhosphorIconsStyle.fill), "Evrenin\nSürprizleri", _lifeFocus, (v) {
              setState(() {
                if (_lifeFocus.contains(v)) _lifeFocus.remove(v);
                else _lifeFocus.add(v);
              });
            }, index: 5),
          ],
        ),
      ],
    ),
    );
  }

  Widget _buildOverlappingOption(String label, String currentVal, IconData icon, Function(String) onSelect) {
    final isSelected = label == currentVal;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onSelect(label);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24, left: 24, right: 16, top: 12),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Base Card
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: const EdgeInsets.only(top: 24, bottom: 24, left: 60, right: 20),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFD3A29B).withOpacity(0.12) : Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? const Color(0xFFD3A29B).withOpacity(0.5) : Colors.white.withOpacity(0.10),
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: GoogleFonts.nunito(
                        color: isSelected ? Colors.white : Colors.white.withOpacity(0.75),
                        fontSize: 16,
                        fontWeight: FontWeight.w700, // Sabit font kalınlığı (kutu büyümesini/şişmesini engeller)
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), color: const Color(0xFFD3A29B), size: 24)
                  else
                    Icon(PhosphorIcons.circle(), color: Colors.white.withOpacity(0.2), size: 24),
                ],
              ),
            ),
            
            // Breaking bounds huge icon
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              left: isSelected ? -24 : -16, 
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: isSelected ? [
                    BoxShadow(color: const Color(0xFFD3A29B).withOpacity(0.6), blurRadius: 20, offset: const Offset(4, 4))
                  ] : [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(2, 2))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? const Color(0xFFD3A29B) : Colors.black.withOpacity(0.15), // Küçücük bir koyuluk
                        border: Border.all(
                          color: isSelected ? Colors.white.withOpacity(0.8) : Colors.white.withOpacity(0.2), // Yumuşak saydam kenarlık
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: label == "Sürprizli & Kaotik Olaylar" 
                        ? SizedBox(
                            width: isSelected ? 36 : 28,
                            height: isSelected ? 36 : 28,
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                // Ana şimşek
                                Icon(PhosphorIcons.lightning(PhosphorIconsStyle.fill), color: isSelected ? Colors.white : Colors.white.withOpacity(0.8), size: isSelected ? 24 : 20),
                                // Sol hafif yatık (Dengeli Kaos)
                                Positioned(
                                  left: isSelected ? -4 : -2, 
                                  top: isSelected ? 0 : 2, 
                                  child: Transform.rotate(
                                    angle: -0.25, 
                                    child: Icon(PhosphorIcons.lightning(PhosphorIconsStyle.fill), color: isSelected ? Colors.white.withOpacity(0.7) : Colors.white.withOpacity(0.5), size: isSelected ? 16 : 14)
                                  )
                                ),
                                // Sağ hafif yatık (Dengeli Kaos)
                                Positioned(
                                  right: isSelected ? -4 : -2, 
                                  bottom: isSelected ? 0 : 2, 
                                  child: Transform.rotate(
                                    angle: 0.25, 
                                    child: Icon(PhosphorIcons.lightning(PhosphorIconsStyle.fill), color: isSelected ? Colors.white.withOpacity(0.9) : Colors.white.withOpacity(0.7), size: isSelected ? 18 : 14)
                                  )
                                ),
                              ],
                            ),
                          )
                        : Icon(
                          icon, 
                          color: isSelected ? Colors.white : Colors.white.withOpacity(0.8), 
                          size: isSelected ? 36 : 28
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        const SizedBox(height: 100), // Kutuları dikey olarak ortaya aldık

        _buildOverlappingOption(
          "Haberci & Net Rüyalar", 
          _dreamFrequency, 
          PhosphorIcons.bird(PhosphorIconsStyle.fill),
          (v) => setState(() => _dreamFrequency = v)
        ),
        _buildOverlappingOption(
          "Sürprizli & Kaotik Olaylar", 
          _dreamFrequency, 
          PhosphorIcons.lightning(PhosphorIconsStyle.fill), // Özel şimşek kümesi
          (v) => setState(() => _dreamFrequency = v)
        ),

        _buildOverlappingOption(
          "Bulutlar Kadar Sakin", 
          _dreamFrequency, 
          PhosphorIcons.cloud(PhosphorIconsStyle.fill),
          (v) => setState(() => _dreamFrequency = v)
        ),
      ],
    );
  }

  Widget _buildTimeAccordion(String title, String desc, IconData icon, String val, List<Color> gradientColors) {
    final isSelected = _sleepPattern == val;
    final isInitial = _sleepPattern.isEmpty;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _sleepPattern = val);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutQuart,
        margin: const EdgeInsets.only(bottom: 24), // Panellerin arası genişletilip sayfayı doldurması sağlandı
        height: isSelected ? 130 : (isInitial ? 90 : 72), // Paneller biraz daha dolgunlaşıp lüks bir görünüme kavuştu
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: isSelected 
               ? gradientColors 
               : [Colors.white.withOpacity(0.04), Colors.white.withOpacity(0.02)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: isSelected ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.05),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: gradientColors.last.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))
          ] : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Arka plandaki dev ikon (Seçilince watermark gibi çıkar)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutQuint,
                right: isSelected ? -20 : 20,
                top: isSelected ? -20 : 10,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: isSelected ? 0.35 : 0.03, // Seçili değilken neredeyse görünmez
                  child: Icon(icon, size: isSelected ? 180 : 64, color: Colors.white),
                ),
              ),
              
              // İçerik
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              padding: EdgeInsets.all(isSelected ? 10 : 8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                              ),
                              child: Icon(icon, color: isSelected ? Colors.white : Colors.white.withOpacity(0.5), size: isSelected ? 24 : 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                title,
                                style: GoogleFonts.nunito(
                                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                                  fontSize: isSelected ? 18 : 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), color: Colors.white, size: 24),
                          ],
                        ),
                        
                        // Açıklama Metni (Sadece seçiliyken veya hiçbir şey seçilmemişken görünür)
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: isSelected ? 0.9 : (isInitial ? 0.6 : 0.0),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              desc,
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: 13,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        const SizedBox(height: 80), // Butonları dikey ortaya yaklaştırdık

        _buildTimeAccordion(
          "Aklın Işığı", 
          "Olayları analiz eder, mantığımla tartıp somut adımlar planlarım.", 
          PhosphorIcons.sun(PhosphorIconsStyle.fill), 
          "Aklın Işığı (Mantık)", 
          [const Color(0xFFECA37F), const Color(0xFFD3A29B)]
        ),
        _buildTimeAccordion(
          "Kalbin Fısıltısı", 
          "İç sesimi dinler, mantığımdan önce her zaman hislerime güvenirim.", 
          PhosphorIcons.moon(PhosphorIconsStyle.fill), 
          "Kalbin Fısıltısı (Sezgi)", 
          [const Color(0xFF384358), const Color(0xFF161821)]
        ),
        _buildTimeAccordion(
          "Evrenin Akışı", 
          "Her şeyin bir sebebi olduğuna inanır, evrenin işaretlerini takip ederim.", 
          PhosphorIcons.spiral(PhosphorIconsStyle.fill), 
          "Evrenin Akışı (Kader)", 
          [const Color(0xFF6B4B7C), const Color(0xFF392D46)]
        ),

      ],
    );
  }

  // ==========================================
  // UTILS
  // ==========================================
  void _showLocationPicker(BuildContext context) {
    String tempLocation = "";
    bool isSearching = false;
    Timer? _debounce;
    
    // Uygulama açılışında görünen prestijli dünya başkentleri
    final List<String> defaultLocations = [
      "İstanbul, Türkiye", "New York, ABD", "Londra, Birleşik Krallık", "Paris, Fransa", "Tokyo, Japonya",
      "Ankara, Türkiye", "İzmir, Türkiye", "Zürih, İsviçre", "Berlin, Almanya", "Roma, İtalya", 
      "Dubai, BAE", "Los Angeles, ABD", "Sidney, Avustralya", "Antalya, Türkiye", "Barselona, İspanya"
    ];
    
    List<String> searchResults = List.from(defaultLocations);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, 
      builder: (ctx) {
        return StatefulBuilder( 
          builder: (BuildContext context, StateSetter setModalState) {

            Future<void> performSearch(String query) async {
               if (query.trim().length < 2) {
                  setModalState(() {
                     searchResults = List.from(defaultLocations);
                     isSearching = false;
                  });
                  return;
               }
               
               setModalState(() => isSearching = true);
               
               try {
                  final uri = Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&limit=8&accept-language=tr');
                  final res = await http.get(uri, headers: {'User-Agent': 'vlucky_cosmic_app_1.0'});
                  
                  if (res.statusCode == 200) {
                     final List data = json.decode(res.body);
                     final List<String> results = [];
                     for (var e in data) {
                        final addr = e['address'] ?? {};
                        final city = addr['city'] ?? addr['town'] ?? addr['village'] ?? addr['county'] ?? addr['state'] ?? e['name'] ?? "";
                        final country = addr['country'] ?? "";
                        if (city.isNotEmpty) {
                           final fullName = country.isNotEmpty ? "$city, $country" : city;
                           if (!results.contains(fullName)) results.add(fullName);
                        }
                     }
                     if (results.isEmpty) results.add("$query (Özel Konum)");
                     
                     setModalState(() {
                        searchResults = results;
                        isSearching = false;
                     });
                  } else {
                     setModalState(() => isSearching = false);
                  }
               } catch (e) {
                  setModalState(() => isSearching = false);
               }
            }

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.45, // Boyut %55'ten %45'e küçültüldü
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12), // Ortak renk değeri (0.10 ve eski 0.15'in ortası)
                        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.2))),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
                          const SizedBox(height: 16),
                          
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(width: 50),
                                Expanded(
                                  child: Text('Tam Konumu Ara', textAlign: TextAlign.center, style: GoogleFonts.nunito(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  child: Text('Bitti', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                                  onPressed: () {
                                    if (tempLocation.trim().isNotEmpty && searchResults.isNotEmpty) {
                                      setState(() => _selectedLocation = searchResults.first);
                                    }
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(height: 1, color: Colors.white.withOpacity(0.05)),
                          
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextField(
                              autofocus: true, 
                              style: GoogleFonts.nunito(color: Colors.white, fontSize: 14),
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                hintText: "Köy, ilçe veya şehir yaz...",
                                hintStyle: GoogleFonts.nunito(color: Colors.white.withOpacity(0.3)),
                                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                                suffixIcon: isSearching ? const Padding(padding: EdgeInsets.all(12), child: CupertinoActivityIndicator(radius: 10)) : null,
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.05),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                              onChanged: (val) {
                                tempLocation = val;
                                if (_debounce?.isActive ?? false) _debounce!.cancel();
                                _debounce = Timer(const Duration(milliseconds: 600), () {
                                   performSearch(val);
                                });
                              },
                              onSubmitted: (val) {
                                 if (val.trim().isNotEmpty && searchResults.isNotEmpty) {
                                   setState(() => _selectedLocation = searchResults.first);
                                 }
                                 Navigator.of(context).pop();
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          if (tempLocation.trim().isNotEmpty && !isSearching)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: ListTile(
                                leading: Container(
                                  width: 32, height: 32,
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                                ),
                                title: Text('"${tempLocation.trim()}"', style: GoogleFonts.nunito(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                                subtitle: Text('Serbest metin olarak ekle', style: GoogleFonts.nunito(color: Colors.white.withOpacity(0.3), fontSize: 11)),
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _selectedLocation = tempLocation.trim());
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),

                          Expanded( 
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: searchResults.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: const Icon(Icons.location_on_outlined, color: Colors.white54, size: 20),
                                  title: Text(searchResults[index], style: GoogleFonts.nunito(color: Colors.white, fontSize: 13)),
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() => _selectedLocation = searchResults[index]);
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        );
      }
    );
  }



  void _showDatePicker(BuildContext context, {required CupertinoDatePickerMode mode}) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => ClipRRect( // ClipRRect ana sarıcı yapıldı, yapı eşitlendi
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.45, // Konum paneliyle BİREBİR aynı daha küçük yükseklik
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12), // Ortak renk değeri (0.10 ve eski 0.15'in ortası)
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.2))),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2))), // Sürükleme çubuğu
                  const SizedBox(height: 16),
                  
                  // Başlık ve Buton uyumu
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 50), // Başlığı merkeze hizalamak için dummmy boşluk
                        Expanded(
                          child: Text(
                            mode == CupertinoDatePickerMode.date ? 'Doğum Tarihini Seç' : 'Doğum Saatini Seç',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Text('Bitti', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                          onPressed: () {
                            setState(() {
                              if (mode == CupertinoDatePickerMode.date) {
                                _hasSelectedDate = true;
                              } else {
                                _selectedTime ??= DateTime.now(); // Eğer çark hiç döndürülmediyse UI'da görünen şimdiki zamanı kabul et
                                _knowsTime = true;
                              }
                            });
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  Container(height: 1, color: Colors.white.withOpacity(0.05)), // Alt çizgi
                  
                  Expanded(
                    child: CupertinoTheme(
                      data: CupertinoThemeData(
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle: GoogleFonts.nunito(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w400),
                        ),
                      ),
                      child: CupertinoDatePicker(
                        backgroundColor: Colors.transparent,
                        mode: mode,
                        use24hFormat: true,
                        initialDateTime: mode == CupertinoDatePickerMode.date ? _selectedDate : (_selectedTime ?? DateTime.now()),
                        maximumYear: DateTime.now().year,
                        onDateTimeChanged: (val) {
                          setState(() {
                            if (mode == CupertinoDatePickerMode.date) {
                              _selectedDate = val;
                              _hasSelectedDate = true;
                            } else {
                              _selectedTime = val;
                              _knowsTime = true;
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton({required String title, required IconData icon, required VoidCallback onTap, required Color glowColor}) {
    return Transform.translate(
      offset: _currentStep == 0 
          ? const Offset(-30, 12) // "Hadi Başlayalım" ince ayar
          : _currentStep == 6 
              ? const Offset(-4, 12) // "Yolculuğa Başla" çok uzun olduğu için optik merkezi sağlamak adına daha sağa (0'a yakın) çekildi
              : const Offset(-56, 12), // "Devam Et" kısa olduğu için daha çok sola itilir
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        // Bloğu bütünüyle ekranın ORTASINA yaslıyoruz
        child: Align(
          alignment: Alignment.center,
          child: Transform.scale(
            scale: 0.80, 
            alignment: Alignment.center,
            child: Container(
              height: 74,
              decoration: const BoxDecoration(
                color: Colors.transparent, 
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // İç hizalamada ok ve yıldız sağa tam yaslı kalmaya devam ediyor
                crossAxisAlignment: CrossAxisAlignment.end, 
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                         // Görsel merkezleme için altın kural: Ok uzunluğunu yutan görünmez bir sol ağırlık (tüm adımlarda aktif)
                         const SizedBox(width: 26), 
                         Text(
                          title.toUpperCase(),
                          style: GoogleFonts.nunito(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: _currentStep == 0 ? 3.0 : 4.5, 
                            shadows: [
                              Shadow(color: glowColor.withOpacity(0.8), blurRadius: 15),
                            ]
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(icon, color: Colors.white.withOpacity(0.9), size: 18),
                      ]
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0), 
                    child: _AnimatedCurvedLine(glowColor: glowColor),
                  ),
                ]
              )
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingMottledPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final allColors = [
      const Color(0xFFC8A890), 
      const Color(0xFF8B3A3A),
      const Color(0xFF1A3A5C),
      const Color(0xFF2A4A6C),
      const Color(0xFF1E3050),
    ];
    for (int i = 0; i < 20; i++) {
      final color = allColors[rng.nextInt(allColors.length)];
      final opacity = 0.05 + rng.nextDouble() * 0.12; 
      final radius = 100.0 + rng.nextDouble() * 250.0; 
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final paint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(x, y),
          radius,
          [
            color.withOpacity(opacity),
            color.withOpacity(opacity * 0.60),
            color.withOpacity(0),
          ],
          [0.0, 0.4, 1.0],
        );
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==========================================
// CUSTOM STAGGERED FADE IN WIDGET
// ==========================================
class StaggeredFade extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const StaggeredFade({Key? key, required this.child, required this.delay}) : super(key: key);

  @override
  State<StaggeredFade> createState() => _StaggeredFadeState();
}

class _StaggeredFadeState extends State<StaggeredFade> {
  bool _show = false;
  
  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) setState(() => _show = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      opacity: _show ? 1.0 : 0.0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        offset: _show ? Offset.zero : const Offset(0, 0.2),
        child: widget.child,
      ),
    );
  }
}

// ==========================================
// LOOPING FLOAT ANIMATION
// ==========================================
class LoopingFloat extends StatefulWidget {
  final Widget child;
  const LoopingFloat({Key? key, required this.child}) : super(key: key);
  @override
  State<LoopingFloat> createState() => _LoopingFloatState();
}

class _LoopingFloatState extends State<LoopingFloat> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  late final Animation<Offset> _anim = Tween(begin: const Offset(0, -0.04), end: const Offset(0, 0.04))
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine));

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: _anim, child: widget.child);
  }
}

// ==========================================
// CINEMATIC AURORA WIND (Fluid Cloud Ripples)
// ==========================================
class CinematicAuroraWind extends StatefulWidget {
  final Widget child;
  const CinematicAuroraWind({Key? key, required this.child}) : super(key: key);
  @override
  State<CinematicAuroraWind> createState() => _CinematicAuroraWindState();
}

class _CinematicAuroraWindState extends State<CinematicAuroraWind> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final double v = _ctrl.value; // 0 to 1
        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.hardEdge,
          children: [
            // Layer 1: Base slow moving
            Transform.translate(
              offset: Offset(math.sin(v * math.pi * 2) * 50, math.cos(v * math.pi * 2) * 40),
              child: Transform.scale(
                scale: 1.25,
                child: widget.child,
              ),
            ),
            // Layer 2: Inverted slow moving overlay creates cloud/wind interference
            Opacity(
              opacity: 0.55, // Karışım oranı
              child: Transform.translate(
                offset: Offset(math.sin((v + 0.5) * math.pi * 2) * -70, math.cos((v + 0.25) * math.pi * 2) * -50),
                child: Transform.scale(
                  scale: 1.4,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..scale(-1.0, -1.0, 1.0),
                    child: widget.child,
                  ),
                ),
              ),
            ),
            // Layer 3: Atmospheric pulsing color tint
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFC36E6E).withOpacity(0.05 + math.sin(v * math.pi * 2).abs() * 0.1),
                    const Color(0xFF6E88C3).withOpacity(0.05 + math.cos(v * math.pi * 2).abs() * 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              ),
            ),
          ],
        );
      }
    );
  }
}

class LoopingPulse extends StatefulWidget {
  final Widget child;
  const LoopingPulse({super.key, required this.child});
  @override
  State<LoopingPulse> createState() => _LoopingPulseState();
}

class _LoopingPulseState extends State<LoopingPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
  late final Animation<double> _scale = Tween<double>(begin: 0.92, end: 1.15).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine));
  
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scale, child: widget.child);
  }
}


class _DashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    final double radius = size.width / 2;
    final center = Offset(radius, radius);
    for (int i = 0; i < 360; i += 4) {
      if (i % 8 != 0) {
        final x1 = center.dx + radius * math.cos(i * math.pi / 180);
        final y1 = center.dy + radius * math.sin(i * math.pi / 180);
        final x2 = center.dx + (radius - 4) * math.cos(i * math.pi / 180);
        final y2 = center.dy + (radius - 4) * math.sin(i * math.pi / 180);
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LoopingHourglass extends StatefulWidget {
  const LoopingHourglass({super.key});
  @override
  State<LoopingHourglass> createState() => _LoopingHourglassState();
}
class _LoopingHourglassState extends State<LoopingHourglass> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final v = _ctrl.value;
        double rotation = 0.0;
        if (v > 0.8) rotation = math.pi * ((v - 0.8) / 0.2);
        IconData icon = PhosphorIcons.hourglass(PhosphorIconsStyle.fill);
        if (v < 0.2) icon = PhosphorIcons.hourglassHigh(PhosphorIconsStyle.fill);
        else if (v < 0.5) icon = PhosphorIcons.hourglassMedium(PhosphorIconsStyle.fill);
        else if (v < 0.8) icon = PhosphorIcons.hourglassLow(PhosphorIconsStyle.fill);
        return Transform.rotate(
           angle: rotation,
           child: Container(
             decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [ BoxShadow(color: const Color(0xFFC36E6E).withOpacity(0.2), blurRadius: 40) ]),
             child: Icon(icon, color: const Color(0xFFD18471), size: 100),
           )
        );
      }
    );
  }
}

class _AnimatedCurvedLine extends StatefulWidget {
  final Color glowColor;
  const _AnimatedCurvedLine({Key? key, required this.glowColor}) : super(key: key);

  @override
  State<_AnimatedCurvedLine> createState() => _AnimatedCurvedLineState();
}

class _AnimatedCurvedLineState extends State<_AnimatedCurvedLine> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 4000))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return CustomPaint(
          size: const Size(280, 24), // Kuyruklu yıldızın dalgalı kuyrukları görsel olarak çok daha uzatıldı (220 -> 280)
          painter: _CurvedLinePainter(progress: _ctrl.value, glowColor: widget.glowColor),
        );
      },
    );
  }
}

class _CurvedLinePainter extends CustomPainter {
  final double progress;
  final Color glowColor;

  _CurvedLinePainter({required this.progress, required this.glowColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Animasyon progress'ini kavislerin nefes almasını (dalgalanmasını) sağlamak için sürekli dönen bir faz (phase) olarak kullanıyoruz
    final phase = progress * math.pi * 2; 
    
    // 3 zarif cam/neon teli
    for (int i = 0; i < 3; i++) {
      final path = Path();
      final int segments = 60;
      
      // En sol taraf tamamen şeffaf, görünmeden başlıyor
      path.moveTo(0, size.height * 0.7);
      
      for (int j = 1; j <= segments; j++) {
        final t = j / segments;
        final x = size.width * t;
        
        // Çok geniş ve sakin akan dalgalar 
        final frequency = math.pi * 2.5; 
        
        // Eğrinin orta bölgesinde kavis daha belirgin, uçlarda sıfırlanıyor ki düz durabilsin (kusursuz estetik için)
        final centerWeight = math.sin(t * math.pi); 
        final amplitude = size.height * 0.35 * centerWeight; 
        
        // Zaman ve katman fazına göre nefes alan/titreşen narin kavisler
        final timeOffset = phase + (i * 1.5);
        final waveY = math.sin(t * frequency + timeOffset) * amplitude;
        
        double currentY = size.height * 0.7 + waveY;
        
        // En sağdaki %25'lik kısımda tüm teller zarifçe tek bir hedef noktada (oka) birleşerek havaya kalkar
        if (t > 0.75) {
           final pullFactor = (t - 0.75) * 4.0; // 0'dan 1'e sert artış
           final easeInSq = math.pow(pullFactor, 2); // Kusursuz bağlayıcı ivme
           final targetY = size.height * 0.15; // Yüksekliği, metin yanındaki ok ile dengeli
           currentY = currentY * (1 - easeInSq) + targetY * easeInSq;
        }
        
        path.lineTo(x, currentY);
      }
      
      // Premium hissi vermek için noktalı çizgi yerine kusursuz yumuşak Gradient geçişi (arkada görünmez, okta parlıyor)
      final shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(size.width, 0),
        [
           Colors.transparent,
           glowColor.withOpacity(0.0),
           glowColor.withOpacity(i == 0 ? 0.6 : 0.3),
           i == 0 ? Colors.white : glowColor.withOpacity(0.8),
        ],
        [0.0, 0.4, 0.8, 1.0],
      );

      final strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = i == 0 ? 2.0 : 1.0
        ..strokeCap = StrokeCap.round
        ..shader = shader;
        
      // Dış ışıma (glow) pürüzsüz yayılır
      final glowStrokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = i == 0 ? 5.0 : 3.0
        ..strokeCap = StrokeCap.round
        ..shader = shader
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      canvas.drawPath(path, glowStrokePaint); // Işıma katmanı
      canvas.drawPath(path, strokePaint); // Çekirdek katman
    }
    
    // Tüm tellerin birleştiği hedef uctaki ana sihirli yıldız çekirdeği (göz alıcı parlaklık)
    final tipPos = Offset(size.width, size.height * 0.15);
    
    final starGlowDark = Paint()
      ..color = glowColor.withOpacity(0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(tipPos, 8, starGlowDark);
    
    final starGlowBright = Paint()
      ..color = glowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(tipPos, 4, starGlowBright);
    
    final starCore = Paint()..color = Colors.white;
    canvas.drawCircle(tipPos, 2, starCore);
  }

  @override
  bool shouldRepaint(covariant _CurvedLinePainter oldDelegate) => true;
}

class _AvatarCoverFlow extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _AvatarCoverFlow({Key? key, required this.selectedIndex, required this.onSelected}) : super(key: key);

  @override
  State<_AvatarCoverFlow> createState() => _AvatarCoverFlowState();
}

class _AvatarCoverFlowState extends State<_AvatarCoverFlow> {
  late final PageController _pageCtrl;
  
  final List<String> _avatars = [
    'assets/images/avatars/avatar_1.png',
    'assets/images/avatars/avatar_2.png',
    'assets/images/avatars/avatar_3.png',
    'assets/images/avatars/avatar_4.png',
    'assets/images/avatars/avatar_5.png',
    'assets/images/avatars/avatar_6.png',
    'assets/images/avatars/avatar_7.png',
    'assets/images/avatars/avatar_8.png',
    'assets/images/avatars/avatar_9.png',
    'assets/images/avatars/avatar_10.png',
    'assets/images/avatars/avatar_11.png',
    'assets/images/avatars/avatar_12.png',
  ];

  @override
  void initState() {
    super.initState();
    // Dokunma boyutlarını belirlemek için (Boyutlar küçüldüğü için viewport daraltıldı)
    _pageCtrl = PageController(viewportFraction: 0.40, initialPage: widget.selectedIndex);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160, // Kusursuz yuvarlaklar için genel yükseklik daraltıldı
      child: Stack(
        clipBehavior: Clip.none, // Kenarlardaki avatarların Padding dışına taşmasına izin ver
        alignment: Alignment.center,
        children: [
          // 1. Z-Index Katmanı: Ortadaki eleman DAİMA en üstte olacak şekilde Stack
          AnimatedBuilder(
            animation: _pageCtrl,
            builder: (context, child) {
              // HATA ÇÖZÜMÜ: Sayfa controller'ı daha widget ağacına bağlanmadığında (hasClients false iken) direkt seçili indeksi kullan ki kırmızı ekran vermesin!
              final double page = _pageCtrl.hasClients ? _pageCtrl.page! : widget.selectedIndex.toDouble();
              
              // Kartları merkeze uzaklıklarına göre sıralıyoruz (Merkezdekiler listeye en son eklenir ki EN ÜSTTE görünsün)
              List<int> renderOrder = List.generate(_avatars.length, (i) => i);
              renderOrder.sort((a, b) {
                final distA = (page - a).abs();
                final distB = (page - b).abs();
                return distB.compareTo(distA); 
              });

              return Stack(
                clipBehavior: Clip.none, // Pürüzsüz taşma için kritik ayar
                alignment: Alignment.center,
                children: renderOrder.map((index) {
                  final double diff = (page - index);
                  final double absDiff = diff.abs();

                  // Yanlardaki avatarları merkezin "altına" sıkıştırmak için mesafe formülü
                  final double dx = -diff * 95.0; // Kompakt yerleşim için aralıklar daraltıldı

                  // Büyüme matematiği
                  final double scale = Curves.easeOutCubic.transform((1 - (absDiff * 0.42)).clamp(0.0, 1.0));
                  final bool isFullyFocused = absDiff < 0.2;
                  
                  // Bulanıklık (Blur) formülü kullanıcının isteği üzerine büyük oranda azaltıldı (Maksimum 6.0'a çekildi)
                  final double blurAmount = (absDiff * 4.0).clamp(0.0, 6.0); 
                  
                  return Transform.translate(
                    offset: Offset(dx, 0),
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        height: 145,
                        width: 145,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: isFullyFocused ? [BoxShadow(color: Colors.white.withOpacity(0.15), blurRadius: 40)] : [],
                        ),
                        child: ClipOval(
                          child: ImageFiltered(
                            imageFilter: ui.ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
                            child: Transform.scale(
                              scale: 1.12, // Avatarın iç çemberini container'a tam oturt
                              child: Image.asset(
                                _avatars[index],
                                fit: BoxFit.cover,
                                width: 145,
                                height: 145,
                                colorBlendMode: isFullyFocused ? null : BlendMode.darken,
                                color: isFullyFocused ? null : Colors.black.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          // 2. Transparan Etkileşim Katmanı (Kullanıcının kaydırma hissiyatını yönetir)
          PageView.builder(
            controller: _pageCtrl,
            physics: const BouncingScrollPhysics(),
            itemCount: _avatars.length,
            onPageChanged: widget.onSelected,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  _pageCtrl.animateToPage(index, duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
                },
                child: Container(color: Colors.transparent), 
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SimpleConnectionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pLine = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
      
    final pDot = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    // Tek sayfa (scrollsuz) görünüm için dikey eksende kısıtlanan yeni merkezler
    // ASYA: top=85, size=105 -> Y Merkezi: 85 + 52.5 = 137.5. X Merkezi: 85 + 70 = 155.
    final Offset c1 = Offset(155, 137.5); 
    // BATI: top=0, size=90 -> Y Merkezi: 0 + 45 = 45. X Merkezi: 60.
    final Offset c2 = Offset(60, 45); 
    // MAYA: top=40, size=96 -> Y Merkezi: 40 + 48 = 88. X Merkezi: 285.
    final Offset c3 = Offset(285, 88);  

    canvas.drawLine(c2, c1, pLine);
    canvas.drawLine(c1, c3, pLine);
    
    canvas.drawCircle(c1, 3.5, pDot);
    canvas.drawCircle(c2, 3.5, pDot);
    canvas.drawCircle(c3, 3.5, pDot);
    canvas.drawCircle(c1, 1.5, Paint()..color = Colors.white);
    canvas.drawCircle(c2, 1.5, Paint()..color = Colors.white);
    canvas.drawCircle(c3, 1.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
