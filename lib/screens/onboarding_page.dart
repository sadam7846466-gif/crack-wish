import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import 'root_shell.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with TickerProviderStateMixin {
  late final AnimationController _stepCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  int _currentStep = 0; // 0 to 4

  // --- Step 0 Data ---
  final TextEditingController _nameCtrl = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  DateTime _selectedDate = DateTime(2000, 1, 1);
  DateTime? _selectedTime;
  bool _knowsTime = false;

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
    _stepCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _stepCtrl, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _stepCtrl, curve: Curves.easeOutCubic));

    _stepCtrl.forward();

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted && _currentStep == 0) _nameFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _stepCtrl.dispose();
    _nameCtrl.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _nextStep() {
    HapticFeedback.lightImpact();
    if (_currentStep == 0 && _nameCtrl.text.trim().isEmpty) return;

    if (_currentStep < 4) {
      if (_currentStep == 0) _nameFocus.unfocus();
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
    
    // 0. Name & Zodiac & DoB
    await StorageService.setUserName(_nameCtrl.text.trim());
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
        transitionDuration: const Duration(milliseconds: 1500),
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
              Container(decoration: BoxDecoration(color: const Color(0xFF0A0F16))),
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(painter: _OnboardingMottledPainter()),
                ),
              ),
            ],
          ),
          content: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: _currentStep > 0
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white54, size: 20),
                      onPressed: _prevStep,
                    )
                  : const SizedBox.shrink(),
              actions: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: Text(
                      "${_currentStep + 1} / 5",
                      style: const TextStyle(color: Colors.white30, fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                          if (_currentStep == 0) _buildStep0(),
                          if (_currentStep == 1) _buildStep1(),
                          if (_currentStep == 2) _buildStep2(),
                          if (_currentStep == 3) _buildStep3(),
                          if (_currentStep == 4) _buildStep4(),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            floatingActionButton: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                  child: _buildNextButton(
                    title: _currentStep == 4 ? "Aydınlanmayı Tamamla" : "Devam Et",
                    icon: _currentStep == 4 ? PhosphorIcons.sparkle(PhosphorIconsStyle.fill) : PhosphorIcons.arrowRight(PhosphorIconsStyle.bold),
                    onTap: _nextStep,
                    glowColor: _currentStep == 4 ? Color(_auraColor) : const Color(0xFFFF8A3D),
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
      style: const TextStyle(
        color: Colors.white,
        fontSize: 27,
        fontWeight: FontWeight.w800,
        height: 1.2,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSubtitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 36),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 14,
          height: 1.5,
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
            Icon(icon, color: const Color(0xFFFF8A3D).withOpacity(0.9), size: 18),
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

  Widget _buildOption(String label, String currentVal, Function(String) onSelect) {
    final isSelected = label == currentVal;
    final color = Color(_auraColor);
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onSelect(label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.12) : Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(24),
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
                        fontSize: 16,
                        letterSpacing: 0.3,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), color: color, size: 24)
                  else
                    Icon(PhosphorIcons.circle(PhosphorIconsStyle.regular), color: Colors.white.withOpacity(0.15), size: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper for inputs ---
  Widget _buildCosmicInput({required Widget child, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(24),
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
    );
  }

  // ==========================================
  // STEPS
  // ==========================================
  Widget _buildStep0() {
    return Column(
      children: [
        _buildTitle("Evrene İlk Seslenişin"),
        _buildSubtitle("Yıldızlar seni hangi isimle tanımalı?\nEşsiz ruhunu yansıtacak bir isim ve doğuş anın..."),
        
        _buildSectionLabel("KOZMİK İSMİN", icon: PhosphorIcons.sparkle(PhosphorIconsStyle.fill)),
        _buildCosmicInput(
          child: TextField(
            controller: _nameCtrl,
            focusNode: _nameFocus,
            textAlign: TextAlign.left,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 0.5),
            cursorColor: const Color(0xFFFF8A3D),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Örn: Yıldız Tozu",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 18),
              icon: Icon(PhosphorIcons.userFocus(PhosphorIconsStyle.bold), color: Colors.white.withOpacity(0.3)),
            ),
            onSubmitted: (_) => _nextStep(),
            textCapitalization: TextCapitalization.words,
          ),
        ),
        
        const SizedBox(height: 8),
        _buildSectionLabel("DOĞUM TARİHİN", icon: PhosphorIcons.calendarStar(PhosphorIconsStyle.fill)),
        _buildCosmicInput(
          onTap: () {
            _nameFocus.unfocus();
            _showDatePicker(context, mode: CupertinoDatePickerMode.date);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(PhosphorIcons.calendar(PhosphorIconsStyle.bold), color: Colors.white.withOpacity(0.3)),
                  const SizedBox(width: 16),
                  Text(
                    DateFormat('dd MMMM yyyy').format(_selectedDate),
                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                  ),
                ],
              ),
              Icon(PhosphorIcons.caretDown(PhosphorIconsStyle.bold), color: const Color(0xFFFF8A3D).withOpacity(0.8), size: 18),
            ],
          ),
        ),

        const SizedBox(height: 8),
        _buildSectionLabel("DOĞUM SAATİN", icon: PhosphorIcons.clock(PhosphorIconsStyle.fill)),
        _buildCosmicInput(
          onTap: () {
            _nameFocus.unfocus();
            _showDatePicker(context, mode: CupertinoDatePickerMode.time);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(PhosphorIcons.hourglass(PhosphorIconsStyle.bold), color: _knowsTime ? const Color(0xFFFF8A3D).withOpacity(0.8) : Colors.white.withOpacity(0.3)),
                  const SizedBox(width: 16),
                  Text(
                    _knowsTime && _selectedTime != null ? DateFormat('HH:mm').format(_selectedTime!) : "Tam saatini bilmiyorum",
                    style: TextStyle(color: _knowsTime ? Colors.white : Colors.white.withOpacity(0.3), fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                  ),
                ],
              ),
              if (_knowsTime)
                GestureDetector(
                  onTap: () => setState(() { _knowsTime = false; _selectedTime = null; }),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)),
                    child: Icon(PhosphorIcons.x(PhosphorIconsStyle.bold), color: Colors.white.withOpacity(0.8), size: 14),
                  ),
                )
              else
                Icon(PhosphorIcons.caretDown(PhosphorIconsStyle.bold), color: Colors.white.withOpacity(0.3), size: 18),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        _buildTitle("Kalbinin Pusulası"),
        _buildSubtitle("Şu an en çok neye ihtiyaç duyuyorsun?\nTarot ve Kahve falların bu frekansa göre okunacak."),
        
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
        _buildSubtitle("Rüyaların nasıl şekilleniyor ve ruhun hangi renkte parlıyor?"),

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
        _buildSubtitle("Evrenin sana hediye edeceği mesajları, günün hangi saatinde almak ruhuna daha iyi gelir?"),

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
        _buildSubtitle("Evren tesadüfleri sever. Seninle aynı auroya sahip ve benzer yıldız dizilimini paylaşanlarla eşleşmeye açık mısın?"),

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
  void _showDatePicker(BuildContext context, {required CupertinoDatePickerMode mode}) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        color: const Color(0xFF1B2330),
        child: Column(
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    child: const Text('Bitti', style: TextStyle(color: Color(0xFFFF8A3D), fontWeight: FontWeight.bold)),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
            ),
            Expanded(
              child: CupertinoTheme(
                data: const CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(color: Colors.white, fontSize: 20),
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
    );
  }

  Widget _buildNextButton({required String title, required IconData icon, required VoidCallback onTap, required Color glowColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [glowColor, glowColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: glowColor.withOpacity(0.35),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.15),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.8),
            ),
            const SizedBox(width: 10),
            Icon(icon, color: Colors.white, size: 24),
          ],
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
