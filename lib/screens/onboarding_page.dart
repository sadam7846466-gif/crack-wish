import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import 'root_shell.dart';
import 'zodiac_hub_page.dart';
import '../data/mayan_zodiac_data.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with TickerProviderStateMixin {
  late final AnimationController _stepCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  int _currentStep = 0; // 0 to 6
  int _selectedAvatarIndex = 2; // Ortadan (3. avatar) başlasın, kapak akışına uygun

  // --- Step 0 Data ---
  final TextEditingController _nameCtrl = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final TextEditingController _usernameCtrl = TextEditingController();
  final FocusNode _usernameFocus = FocusNode();
  DateTime _selectedDate = DateTime(2000, 1, 1);
  bool _hasSelectedDate = false;
  DateTime? _selectedTime;
  bool _knowsTime = false;
  String? _selectedLocation;

  // --- Step 1 Data ---
  String _lifeFocus = "Ruhsal Aydınlanma";
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
    _stepCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _stepCtrl, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _stepCtrl, curve: Curves.easeOutCubic));

    _stepCtrl.forward();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && _currentStep == 0) _nameFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _stepCtrl.dispose();
    _nameCtrl.dispose();
    _nameFocus.dispose();
    _usernameCtrl.dispose();
    _usernameFocus.dispose();
    super.dispose();
  }

  void _nextStep() {
    HapticFeedback.lightImpact();
    if (_currentStep == 1 && (_nameCtrl.text.trim().isEmpty || _usernameCtrl.text.trim().isEmpty)) return;

    if (_currentStep < 6) {
      if (_currentStep == 1) {
        _nameFocus.unfocus();
        _usernameFocus.unfocus();
      }
      _stepCtrl.reverse().then((_) {
        setState(() => _currentStep++);
        _stepCtrl.forward();
      });
    } else {
      _finishOnboarding();
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

  Future<void> _finishOnboarding() async {
    HapticFeedback.heavyImpact();
    
    // 0. Name & Zodiac & DoB & Handle
    await StorageService.setUserName(_nameCtrl.text.trim());
    await StorageService.setUserHandle(_usernameCtrl.text.trim());
    await StorageService.setZodiacSign(_calculateZodiac(_selectedDate));
    await StorageService.setBirthDate(_selectedDate);
    if (_knowsTime && _selectedTime != null) {
      await StorageService.setBirthTime(DateFormat('HH:mm').format(_selectedTime!));
    }

    // 1. Focus & Relationship
    await StorageService.setLifeFocus(_lifeFocus);
    await StorageService.setRelationshipStatus(_relationship);

    // 2. Dreams & Aura
    await StorageService.setDreamFrequency(_dreamFrequency);
    await StorageService.setAuraColor(_auraColor);

    // 3. Sleep Pattern
    await StorageService.setSleepPattern(_sleepPattern);

    // 4. Match Preference
    await StorageService.setMatchPreference(_matchPreference);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const RootShell(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
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
              Container(decoration: const BoxDecoration(color: Color(0xFF060913))),
              Positioned.fill(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: _currentStep == 0 ? 1.0 : 0.6, // Keep it slightly visible on other pages or completely change
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
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
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
            body: SafeArea(
              bottom: false,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: constraints.maxHeight),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                if (_currentStep > 0) const SizedBox(height: 12), // Tepe boşluğunu daha da kısalttık, yazılar çok yukarda olacak
                                if (_currentStep == 0) _buildWelcomeStep(),
                                if (_currentStep == 1) _buildStep0(),
                                if (_currentStep == 2) _buildStepDateWithWheels(),
                                if (_currentStep == 3) _buildStep1(),
                                if (_currentStep == 4) _buildStep2(),
                                if (_currentStep == 5) _buildStep3(),
                                if (_currentStep == 6) _buildStep4(),
                                const SizedBox(height: 24), // Sadece rahat bir nefes payı bırakıldı, bottomNavigationBar artık kendi gerçek alanını kaplayacak
                              ],
                            ),
                          ),
                        );
                      }
                    ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Kilit yazısı sayfa göstergeleri ve Butonun "ÜSTÜNE" taşındı
                      if (_currentStep > 0) ...[
                        Transform.translate(
                          offset: const Offset(0, -16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(PhosphorIcons.lockKey(PhosphorIconsStyle.fill), color: Colors.white.withOpacity(0.15), size: 14),
                              const SizedBox(width: 8),
                              Text(
                                "Yalnızca sana özel haritanı çizmek içindir.",
                                style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Roma Rakamlı Bölüm Belirteci - İçeriğin Ortasında
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(7, (index) {
                          final isActive = _currentStep == index;
                          const numerals = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII'];
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                color: isActive ? const Color(0xFFD3A29B) : Colors.white.withOpacity(0.2),
                                fontSize: isActive ? 15 : 13,
                                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                                letterSpacing: 1.0,
                                shadows: isActive ? [
                                  Shadow(color: const Color(0xFFD3A29B).withOpacity(0.6), blurRadius: 10)
                                ] : [],
                              ),
                              child: Text(numerals[index]),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 4), // Roma rakamları butonlara doğru aşağıya yaklaştıırıldı
                      _buildNextButton(
                        title: _currentStep == 6 ? "Yolculuğa Başla" : "Devam Et",
                        icon: _currentStep == 6 ? PhosphorIcons.sparkle(PhosphorIconsStyle.fill) : PhosphorIcons.arrowRight(PhosphorIconsStyle.bold),
                        onTap: _nextStep,
                        glowColor: const Color(0xFFC36E6E), // Splash Screen paletinden yumuşak kırmızımsı/gül kurusu
                      ),
                    ],
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
  Widget _buildTitle(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.cormorant(
        color: Colors.white,
        fontSize: 36, // Cormorant fontu daha zarif olduğu için font boyutu biraz artırıldı
        fontWeight: FontWeight.w300, // Lüks serif hissiyatı için çok daha ince ve asil (Light)
        height: 1.2,
        letterSpacing: 1.0, 
        shadows: [
          Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
    );
  }

  Widget _buildSubtitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 32),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withOpacity(0.85),
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
          letterSpacing: 0.2,
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
            style: TextStyle(
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

  Widget _buildOption(String label, String currentVal, Function(String) onSelect, {int index = 0}) {
    final isSelected = label == currentVal;
    final color = Color(_auraColor);
    return StaggeredFade(
      delay: Duration(milliseconds: 150 + (index * 50)), // Kademeli animasyon gecikmesi
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onSelect(label);
        },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.12) : Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? color.withOpacity(0.6) : Colors.white.withOpacity(0.08),
                  width: 1,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(color: color.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 4))
                ] : [],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? color : Colors.white.withOpacity(0.85),
                        fontSize: 15,
                        letterSpacing: 0.2,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), color: color, size: 22)
                  else
                    Icon(PhosphorIcons.circle(PhosphorIconsStyle.regular), color: Colors.white.withOpacity(0.15), size: 22),
                ],
              ),
            ),
          ),
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
                  Text(title, style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
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
  // STEPS
  // ==========================================
  Widget _buildWelcomeStep() {
    return Column(
      children: [
        _buildTitle("Kozmik Serüvene\nHoş Geldin"),
        const SizedBox(height: 8), // Alt Başlık ile başlık arası kısaldı, blok yukarı taşındı
        _buildSubtitle("Derin bir nefes al ve yıldızların rehberliğine hazır ol."),
        
        const SizedBox(height: 16), // Yukarı çekilmesi için 32'den 16'ya düşürüldü
        
        _buildFeatureItem(icon: PhosphorIcons.sparkle(PhosphorIconsStyle.fill), text: "Sana Özel Astroloji Haritası"),
        _buildFeatureItem(
          icon: PhosphorIcons.cards(PhosphorIconsStyle.fill), 
          text: "Yol Gösterici Tarot Serüveni",
          angle: math.pi / 2, // Yatay kartları gerçek dikey (vertical) tarot destesi formuna çevirir
        ),
        _buildFeatureItem(icon: PhosphorIcons.coffee(PhosphorIconsStyle.fill), text: "Telvelerde Gizlenen Kadim Kahve Falı Sırları"),
        _buildFeatureItem(icon: PhosphorIcons.moonStars(PhosphorIconsStyle.fill), text: "Bilinçaltı Rüya Analizleri"),
        _buildFeatureItem(icon: PhosphorIcons.infinity(PhosphorIconsStyle.bold), text: "Mistik Çin & Maya Uyumları"),
        
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String text, double angle = 0.0}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 40, right: 24), // Maddeler arasındaki nefes alma boşluğu artırıldı
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
          const SizedBox(width: 20),
          Expanded( // Flex kullanıyoruz ki metin ikonların düzenini asla bozmasın
            child: Text(
              text,
              textAlign: TextAlign.left, // Tüm yazılar ip gibi soldan başlar
              style: TextStyle(
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
        ],
      ),
    );
  }


  Widget _buildStep0() {
    return Transform.translate(
      offset: const Offset(0, -15), // İçeriği biraz daha aşağı oturtmak için -35'ten -15'e çekildi
      child: Column(
        children: [
          _buildTitle("Seni Tanıyalım"),
          _buildSubtitle("Ruh eşlerinin seni bulabilmesi için profilini oluştur ve kozmik kimliğini belirle."),
          
          const SizedBox(height: 16),
        
        // CoverFlow Tarzı Dinamik Avatar Seçici
        StaggeredFade(
          delay: const Duration(milliseconds: 250),
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

        const SizedBox(height: 36), // Paneli avatarlardan ayırmak için biraz aşağı kaydırdık

        _buildGlassCard(
          delay: 400,
          child: Column(
            children: [
              _buildUnifiedInputRow(
                 customIcon: Transform.scale(
                   scale: 1.4,
                   child: Image.asset('assets/images/owl.png', width: 38, height: 38),
                 ),
                 title: "PROFİL ADIN",
                 child: TextField(
                     controller: _nameCtrl,
                     focusNode: _nameFocus,
                     style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.2),
                     cursorColor: const Color(0xFFD18471), // Lüks altın/somon
                     textCapitalization: TextCapitalization.words,
                     decoration: InputDecoration(
                       border: InputBorder.none,
                       isDense: true,
                       contentPadding: EdgeInsets.zero,
                       hintText: "Örn: Yıldız Tozu \uD83C\uDF19",
                       hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 16),
                     ),
                 ),
              ),
              _buildDivider(),
              // 2. Kullanıcı Adı (Benzersiz, Aramalarda Bulunmak İçin)
              _buildUnifiedInputRow(
                 icon: PhosphorIcons.at(PhosphorIconsStyle.fill),
                 title: "KULLANICI ADI",
                 child: TextField(
                     controller: _usernameCtrl,
                     focusNode: _usernameFocus,
                     style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
                     cursorColor: const Color(0xFFD18471),
                     keyboardType: TextInputType.emailAddress, // Boşluksuz ve küçük harf klavye yapısı için ideal
                     decoration: InputDecoration(
                       border: InputBorder.none,
                       isDense: true,
                       contentPadding: EdgeInsets.zero,
                       hintText: "@kozmikyolcu",
                       hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 16),
                     ),
                 ),
              ),
            ],
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

    return Transform.translate(
      offset: const Offset(0, -25), // Başlığı ve içeriği bir tık yukarı taşımak için
      child: Column(
        children: [
        _buildTitle("Kozmik Koordinat"),
        _buildSubtitle("Astrolojik haritanın temeli için doğduğun anı seç."),
        const SizedBox(height: 20), // Kozmik çarkları biraz aşağıya doğru kaydırarak nefes aldırır
        StaggeredFade(
          delay: const Duration(milliseconds: 300),
          child: Container(
            height: 160,
            width: double.infinity,
            alignment: Alignment.center,
            color: Colors.transparent,
            child: SizedBox(
              width: 280,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SimpleConnectionPainter(),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: cTargetRotation),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeOutCubic,
                      builder: (context, angle, child) => _buildMiniWheel(cSign, ChineseWheelPainter(rotation: angle, gold: Colors.white, goldD: Colors.white.withOpacity(0.5)), 105),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: wTargetRotation),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeOutCubic,
                      builder: (context, angle, child) => _buildMiniWheel(wSign, WesternWheelPainter(rotation: angle, gold: Colors.white, goldD: Colors.white.withOpacity(0.5)), 90),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: mTargetRotation),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeOutCubic,
                      builder: (context, angle, child) => _buildMiniWheel(mSign, MayanWheelPainter(rotation: angle, gold: Colors.white, goldD: Colors.white.withOpacity(0.5), isMini: true), 90),
                    ),
                  ),
                ],
              ),
            )
          )
        ),
        const SizedBox(height: 56), // Paneli kullanıcının isteği üzerine biraz daha aşağı taşıdık
        _buildGlassCard(
          delay: 400,
          child: Column(
            children: [
              _buildUnifiedInputRow(
                 icon: PhosphorIcons.calendarStar(PhosphorIconsStyle.fill),
                 title: "DÜNYAYA GELİŞ TARİHİN",
                 child: Text(
                   _hasSelectedDate 
                      ? DateFormat('dd MMMM yyyy').format(_selectedDate) 
                      : "Doğum tarihini seç",
                   style: TextStyle(
                     color: _hasSelectedDate ? Colors.white : Colors.white.withOpacity(0.25), 
                     fontSize: _hasSelectedDate ? 15 : 12, 
                     fontWeight: FontWeight.w400
                   )
                 ),
                 onTap: () {
                   _nameFocus.unfocus();
                   _showDatePicker(context, mode: CupertinoDatePickerMode.date);
                 },
                 suffix: Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold), color: Colors.white.withOpacity(0.3), size: 16),
              ),
              _buildDivider(),
              _buildUnifiedInputRow(
                 icon: PhosphorIcons.hourglass(PhosphorIconsStyle.fill),
                 title: "DOĞUM SAATİN (Opsiyonel)",
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(_selectedTime != null ? DateFormat('HH:mm').format(_selectedTime!) : "Tam saati biliyorsan detaylı analiz için gir", style: TextStyle(color: _selectedTime != null ? Colors.white : Colors.white.withOpacity(0.25), fontSize: _selectedTime != null ? 15 : 12, fontWeight: FontWeight.w400)),
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
                     Text(_selectedLocation ?? "Şehir seçerek hesaplamayı netleştir", style: TextStyle(color: _selectedLocation != null ? Colors.white : Colors.white.withOpacity(0.25), fontSize: _selectedLocation != null ? 15 : 12, fontWeight: FontWeight.w400)),
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
            ],
          ),
        ),
      ]
    ));
  }


  Widget _buildGlassCard({required Widget child, required int delay}) {
    return StaggeredFade(
      delay: Duration(milliseconds: delay),
      child: Container(
        margin: const EdgeInsets.only(top: 24),
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
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          color: Colors.transparent,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
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
    return Column(
      children: [
        _buildTitle("Kalbinin Pusulası"),
        _buildSubtitle("Fallarının frekansı için niyetini belirle."),
        
        _buildSectionLabel("HAYAT ODAĞI"),
        _buildOption("Ruhsal Aydınlanma & Keşif", _lifeFocus, (v) => setState(() => _lifeFocus = v)),
        _buildOption("Kariyer & Kişisel Güç", _lifeFocus, (v) => setState(() => _lifeFocus = v)),
        _buildOption("Aşk & Kozmik Uyum", _lifeFocus, (v) => setState(() => _lifeFocus = v)),
        _buildOption("Şifa & İçsel Huzur", _lifeFocus, (v) => setState(() => _lifeFocus = v)),

        const SizedBox(height: 12),
        _buildSectionLabel("İLİŞKİ DURUMU"),
        _buildOption("Yalnız Gökyüzü (Bekar)", _relationship, (v) => setState(() => _relationship = v)),
        _buildOption("Karmaşık Bir Yörünge", _relationship, (v) => setState(() => _relationship = v)),
        _buildOption("Eşleşmiş Ruh (İlişkisi Var)", _relationship, (v) => setState(() => _relationship = v)),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        _buildTitle("Bilinçaltı & Auran"),
        _buildSubtitle("Bilinçaltının derinliklerini ve auranı keşfet."),

        _buildSectionLabel("RÜYA YAKLAŞIMI"),
        _buildOption("Haberci & Net Rüyalar", _dreamFrequency, (v) => setState(() => _dreamFrequency = v)),
        _buildOption("Sürprizli & Kaotik Olaylar", _dreamFrequency, (v) => setState(() => _dreamFrequency = v)),
        _buildOption("Bulutlar Kadar Sakin", _dreamFrequency, (v) => setState(() => _dreamFrequency = v)),

        const SizedBox(height: 24),
        _buildSectionLabel("AURA RENGİNİ SEÇ"),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: _auraColors.map((colorVal) {
            final isSel = _auraColor == colorVal;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _auraColor = colorVal);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(colorVal),
                  border: Border.all(color: Colors.white, width: isSel ? 3 : 0),
                  boxShadow: [
                    if (isSel) BoxShadow(color: Color(colorVal).withOpacity(0.6), blurRadius: 20, spreadRadius: 4),
                  ],
                ),
                child: isSel ? Icon(PhosphorIcons.check(PhosphorIconsStyle.bold), color: Colors.white, size: 28) : null,
              ),
            );
          }).toList(),
        )
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        _buildTitle("Kozmik Senkronizasyon"),
        _buildSubtitle("Kozmik mesajlarını hangi aralıkta almak istersin?"),

        _buildSectionLabel("UYKU & UYANIŞ DÖNGÜSÜ"),
        _buildOption("Sabah Kuşu (Erken Uyanan)", _sleepPattern, (v) => setState(() => _sleepPattern = v)),
        _buildOption("Gece İnsanı (Geç Uyuyan)", _sleepPattern, (v) => setState(() => _sleepPattern = v)),
        _buildOption("Düzensiz Bir Döngüm Var", _sleepPattern, (v) => setState(() => _sleepPattern = v)),

        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(_auraColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Color(_auraColor).withOpacity(0.3), width: 1),
          ),
          child: Row(
            children: [
              Icon(PhosphorIcons.bellRinging(PhosphorIconsStyle.fill), color: Color(_auraColor), size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  "Sana bildirim atarken bu döngüyü dikkate alacağız.",
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, height: 1.4),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      children: [
        _buildTitle("Kozmik Ağdaki Yerin"),
        _buildSubtitle("Aynı aurayı paylaştığın ruh eşinle karşılaşmaya hazır mısın?"),

        _buildSectionLabel("EŞLEŞME TERCİHİ"),
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _matchPreference = true);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _matchPreference ? Color(_auraColor).withOpacity(0.15) : Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _matchPreference ? Color(_auraColor).withOpacity(0.5) : Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Kozmik Ağ'a Açığım",
                        style: TextStyle(color: _matchPreference ? Color(_auraColor) : Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Benzer falları seçen ruhlarla etkileşime girmeme izin ver.",
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, height: 1.4),
                      ),
                    ],
                  ),
                ),
                if (_matchPreference) Icon(Icons.check_circle_rounded, color: Color(_auraColor))
              ],
            ),
          ),
        ),

        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _matchPreference = false);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: !_matchPreference ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: !_matchPreference ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Sadece Kendi Yolculuğum",
                        style: TextStyle(color: !_matchPreference ? Colors.white : Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Görünmez olmak ve eşleşmemek istiyorum.",
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, height: 1.4),
                      ),
                    ],
                  ),
                ),
                if (!_matchPreference) const Icon(Icons.check_circle_rounded, color: Colors.white)
              ],
            ),
          ),
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
              child: Container(
                height: 440, // Klavye açıkken harita arama konforu için yükseklik artırıldı
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(top: BorderSide(color: Colors.white.withOpacity(0.25), width: 1.5)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
                    child: Material(
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.15))),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 24),
                                  child: Text("Dünyadaki Doğum Konumun", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16)),
                                ),
                                CupertinoButton(
                                  child: const Text('Bitti', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 0),
                            child: TextField(
                              autofocus: false, 
                              style: const TextStyle(color: Colors.white, fontSize: 17, fontFamily: 'Montserrat'),
                              cursorColor: const Color(0xFFD18471),
                              decoration: InputDecoration(
                                hintText: "Şehir, ilçe veya ülke araştırın...",
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 16, fontFamily: 'Montserrat'),
                                prefixIcon: Icon(Icons.public, color: Colors.white.withOpacity(0.5), size: 22),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
                                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 1.5)),
                                suffixIcon: isSearching ? const CupertinoActivityIndicator() : null,
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
                          
                          Expanded( 
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                              itemCount: searchResults.length,
                              itemBuilder: (context, index) {
                                final parts = searchResults[index].split(',');
                                final city = parts[0].trim();
                                final country = parts.length > 1 ? parts[1].trim() : "";
                                
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                                  title: Row(
                                    children: [
                                      Text(city, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'Montserrat')),
                                      if (country.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(country, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14, fontFamily: 'Montserrat'), overflow: TextOverflow.ellipsis)),
                                      ]
                                    ],
                                  ),
                                  onTap: () {
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
      builder: (_) => Container(
        height: 320,
        margin: const EdgeInsets.only(top: 10), // Yuvarlatılmış köşeler için üst boşluk
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08), // Açık renk, lüks cam efekti
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.25), width: 1.5)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0), // Cam bulanıklığı arka plandaki yıldızları gösterir
            child: Column(
              children: [
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.15))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CupertinoButton(
                        child: const Text('Bitti', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoTheme(
                    data: const CupertinoThemeData(
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w400, fontFamily: 'Cormorant'),
                      ),
                    ),
                    child: CupertinoDatePicker(
                      backgroundColor: Colors.transparent,
                      mode: mode,
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
    );
  }

  Widget _buildNextButton({required String title, required IconData icon, required VoidCallback onTap, required Color glowColor}) {
    return Transform.translate(
      offset: const Offset(-36, 16), // Bloğun görsel ağırlığını merkeze oturtmak için X ekseninde biraz sola kaydırıldı
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
                         Text(
                          title.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 4.5, 
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
          size: const Size(220, 24),
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
    "https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=300", 
    "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&q=80&w=300", 
    "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=300", 
    "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=300", 
    "https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?auto=format&fit=crop&q=80&w=300", 
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
                        height: 145, // Yuvarlak form (Tam daire)
                        width: 145,  // Yükseklikle birebir aynı ebat!
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, // "burayı yuvarlak yap" emrine göre tam daire kesimi
                          color: Colors.white.withOpacity(0.04), // Cam efektati tabanı
                          border: Border.all(
                            color: isFullyFocused ? Colors.white.withOpacity(0.4) : Colors.white.withOpacity(0.1),
                            width: isFullyFocused ? 2.5 : 1.0,
                          ),
                          boxShadow: isFullyFocused ? [BoxShadow(color: Colors.white.withOpacity(0.15), blurRadius: 40)] : [],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(1000), // Tam sarmalayan yuvarlak maske
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0), // Cam panel bulanıklığı
                            child: Padding(
                              padding: EdgeInsets.zero, // Cam panele tam oturmasını sağlamak için boşluk sıfırlandı
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(1000), // İç resmin mükemmel yuvarlak kalması için
                                child: ImageFiltered(
                                  imageFilter: ui.ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(_avatars[index]),
                                        fit: BoxFit.cover,
                                        colorFilter: ColorFilter.mode(
                                          Colors.black.withOpacity(isFullyFocused ? 0.0 : 0.5), 
                                          BlendMode.darken,
                                        )
                                      )
                                    ),
                                  ),
                                ),
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

    final Offset c1 = Offset(size.width / 2, 52.5);
    final Offset c2 = Offset(45, size.height - 69);
    final Offset c3 = Offset(size.width - 45, size.height - 69);

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
