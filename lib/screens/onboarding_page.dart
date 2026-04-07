import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/colors.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import 'root_shell.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with TickerProviderStateMixin {
  late final AnimationController _stepCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  int _currentStep = 0; // 0: Name, 1: Date of Birth
  final TextEditingController _nameCtrl = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  
  DateTime _selectedDate = DateTime(2000, 1, 1);
  DateTime? _selectedTime;
  bool _knowsTime = false;

  @override
  void initState() {
    super.initState();
    _stepCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _stepCtrl, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(CurvedAnimation(parent: _stepCtrl, curve: Curves.easeOutCubic));
    
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
    if (_currentStep == 0) {
      if (_nameCtrl.text.trim().isEmpty) return;
      _nameFocus.unfocus();
      _stepCtrl.reverse().then((_) {
        setState(() => _currentStep = 1);
        _stepCtrl.forward();
      });
    } else {
      _finishOnboarding();
    }
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
    HapticFeedback.mediumImpact();
    await StorageService.setUserName(_nameCtrl.text.trim());
    
    // Save Zodiac
    final zodiac = _calculateZodiac(_selectedDate);
    await StorageService.setZodiacSign(zodiac);
    
    // Save Birth Date
    await StorageService.setBirthDate(_selectedDate);

    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const RootShell(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 1000),
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
              Container(decoration: BoxDecoration(gradient: palette.bgGradient)),
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
            body: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: _currentStep == 0 ? _buildNameStep() : _buildBirthStep(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNameStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Kozmik İsmin",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Yıldızlar seni hangi isimle tanımalı?\nEşsiz ruhunu yansıtacak bir isim seç.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 56),
        Container(
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: TextField(
              controller: _nameCtrl,
              focusNode: _nameFocus,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
              cursorColor: const Color(0xFFFF8A3D),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Örn: Yıldız Tozu",
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.25),
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                ),
              ),
              onSubmitted: (_) => _nextStep(),
              textCapitalization: TextCapitalization.words,
            ),
          ),
        ),
        const SizedBox(height: 48),
        _buildNextButton(
          title: "Devam Et",
          icon: PhosphorIcons.arrowRight(PhosphorIconsStyle.bold),
          onTap: _nextStep,
        ),
      ],
    );
  }

  Widget _buildBirthStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Doğuş Anın",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Gökyüzü haritanı ve burcunu\nhesaplayabilmemiz için gerekli.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 48),
        
        // Date Picker Button
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _showDatePicker(context, mode: CupertinoDatePickerMode.date);
          },
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.fill), color: Colors.white70),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('dd MMMM yyyy').format(_selectedDate),
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Icon(PhosphorIcons.caretDown(PhosphorIconsStyle.bold), color: Colors.white54, size: 18),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Time Picker Button
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _showDatePicker(context, mode: CupertinoDatePickerMode.time);
          },
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: _knowsTime ? Colors.white.withOpacity(0.06) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _knowsTime ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.05),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      PhosphorIcons.clock(PhosphorIconsStyle.fill), 
                      color: _knowsTime ? Colors.white70 : Colors.white30
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _knowsTime && _selectedTime != null 
                        ? DateFormat('HH:mm').format(_selectedTime!) 
                        : "Doğum Saati (İsteğe Bağlı)",
                      style: TextStyle(
                        color: _knowsTime ? Colors.white : Colors.white54, 
                        fontSize: 16, 
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ],
                ),
                if (_knowsTime)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _knowsTime = false;
                        _selectedTime = null;
                      });
                    },
                    child: Icon(PhosphorIcons.xCircle(PhosphorIconsStyle.fill), color: Colors.white54, size: 20),
                  )
                else
                  Icon(PhosphorIcons.caretDown(PhosphorIconsStyle.bold), color: Colors.white30, size: 18),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 56),
        _buildNextButton(
          title: "Uyanışı Başlat",
          icon: PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
          onTap: _nextStep,
        ),
      ],
    );
  }

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

  Widget _buildNextButton({required String title, required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFFF8A3D),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF8A3D).withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, color: Colors.white, size: 20),
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
      const Color(0xFF7A3030),
      const Color(0xFF964040),
      const Color(0xFFA04848),
      const Color(0xFF6E2828),
      const Color(0xFF883838),
      const Color(0xFF1A3A5C),
      const Color(0xFF2A4A6C),
      const Color(0xFF1E3050),
    ];
    for (int i = 0; i < 26; i++) {
      final color = allColors[rng.nextInt(allColors.length)];
      final opacity = 0.08 + rng.nextDouble() * 0.15; 
      final radius = 120.0 + rng.nextDouble() * 200.0; 
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final paint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(x, y),
          radius,
          [
            color.withOpacity(opacity),
            color.withOpacity(opacity * 0.60),
            color.withOpacity(opacity * 0.15),
            color.withOpacity(0),
          ],
          [0.0, 0.25, 0.65, 1.0],
        );
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
