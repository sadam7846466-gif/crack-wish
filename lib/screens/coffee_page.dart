import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../widgets/feature_header_actions.dart';
import '../services/storage_service.dart';
import 'coffee_reading_page.dart';
import 'premium_paywall_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../widgets/fade_page_route.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CoffeePage extends StatefulWidget {
  const CoffeePage({super.key});

  @override
  State<CoffeePage> createState() => _CoffeePageState();
}

class _CoffeePageState extends State<CoffeePage> with TickerProviderStateMixin {
  late PageController _pageCtrl;
  int _currentStep = 0;
  
  // Validation state
  bool _isValidating = false;
  bool _isValidated = false;
  List<int> _invalidSlots = [];
  
  // Arka plandaki fincan animasyonu için
  late AnimationController _floatCtrl;

  // Economy State (Gerçek StorageService ile bağlı)
  bool _isPremium = false;
  int _soulStones = 0;
  final int _fortuneCost = 1; // 1 Fal Maliyeti: 1 Ruh Taşı

  // Görselleri tutacağımız değişkenler
  final ImagePicker _picker = ImagePicker();
  File? _leftAngle;
  File? _rightAngle;
  File? _insideAngle;
  File? _plateAngle;

  // Son kahve falı kaydı (sadece 1 tane, yenisi eskiyi siler)
  Map<String, dynamic>? _lastReading;

  // Giriş animasyonu için
  late AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(initialPage: 0);
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _entranceController.forward();
    _loadSoulStones();
    _loadPremiumStatus();
    _loadTodaysReadings();
  }

  Future<void> _loadSoulStones() async {
    final stones = await StorageService.getSoulStones();
    if (mounted) setState(() => _soulStones = stones);
  }

  Future<void> _loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final premium = prefs.getBool('is_premium_test_mode') ?? false;
    if (mounted) setState(() => _isPremium = premium);
  }

  void dispose() {
    _pageCtrl.dispose();
    _floatCtrl.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _nextStep() {
    // Premium kilidi kaldırıldı, herkes fotoğraf çekimine geçebilir

    if (_currentStep < 6) {
      HapticFeedback.mediumImpact();
      setState(() => _currentStep++);
      _pageCtrl.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 900), // Çok daha yavaş ve sakin
        curve: Curves.easeInOutQuart, // Başlarken ve biterken çok yumuşak bir ivme
      );
    }
  }

  Future<String> _imageToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> _validateImages() async {
    setState(() {
      _isValidating = true;
      _isValidated = false;
      _invalidSlots.clear();
    });

    try {
      final images = await Future.wait([
        _imageToBase64(_insideAngle!),
        _imageToBase64(_leftAngle!),
        _imageToBase64(_rightAngle!),
        _imageToBase64(_plateAngle!),
      ]);

      final validateResponse = await Supabase.instance.client.functions.invoke(
        'interpret-coffee',
        body: {
          'mode': 'validate',
          'images': images,
          'locale': 'tr',
        },
      );

      if (validateResponse.data != null && validateResponse.data['results'] != null) {
        final results = validateResponse.data['results'] as List;
        final invalidSlots = <int>[];
        for (int i = 0; i < results.length; i++) {
          if (results[i]['valid'] != true) {
            invalidSlots.add(i);
          }
        }
        
        if (mounted) {
          setState(() {
            _isValidating = false;
            _isValidated = invalidSlots.isEmpty;
            _invalidSlots = invalidSlots;
          });
        }
      } else {
        // Fail-safe
        if (mounted) setState(() { _isValidating = false; _isValidated = true; });
      }
    } catch (e) {
      debugPrint('Doğrulama hatası: $e');
      if (mounted) setState(() { _isValidating = false; _isValidated = true; });
    }
  }

  // Ruh Taşı ile Satın Alma / Başlatma (Sadece doğrulama başarılıysa çağrılır)
  Future<void> _startAnalysisWithSoulStones() async {
    if (_soulStones < _fortuneCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yetersiz Ruh Taşı! ✨')),
      );
      return;
    }

    if (_leftAngle == null || _rightAngle == null || _insideAngle == null || _plateAngle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm fotoğrafları çekin!')),
      );
      return;
    }

    HapticFeedback.heavyImpact();
    
    // Gerçek Ruh Taşı düşür (StorageService üzerinden)
    final success = await StorageService.deductSoulStones(_fortuneCost);
    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yetersiz Ruh Taşı! ✨')),
        );
      }
      return;
    }
    
    // Bakiyeyi güncelle
    await _loadSoulStones();

    // Fotoğraflar hazır, CoffeeReadingPage'e git
    if (mounted) {
      final result = await Navigator.push(
        context,
        FadePageRoute(
          page: CoffeeReadingPage(
            insideAngle: _insideAngle!,
            leftAngle: _leftAngle!,
            rightAngle: _rightAngle!,
            plateAngle: _plateAngle!,
          ),
        ),
      );

      if (result == 'retake' && mounted) {
        setState(() {
          _currentStep = 1; // Başlangıca dön, hatalı fotoğrafı tekrar çekebilsin
        });
      }
    }
  }

  // Premium Paywall (Popup)
  void _showPremiumPaywall() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: const Color(0xFFD4A373).withOpacity(0.3)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.workspace_premium_rounded, color: Color(0xFFD4A373), size: 64),
              const SizedBox(height: 16),
              Text(
                'Sadece Premium Özeldir',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Kahve Falı özelliği uygulamanın elit üyelerine aittir. Premium\'a geç ve Ruh Taşlarınla geleceğin sırlarını arala.',
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () {
                  setState(() => _isPremium = true);
                  Navigator.pop(context);
                  _nextStep();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4A373),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: Text(
                      'Premium Ol (Simülasyon)',
                      style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold),
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

  // GERÇEK FOTOĞRAF SEÇİCİ
  Future<void> _pickImage(int stepIndex, {bool isPlate = false}) async {
    HapticFeedback.lightImpact();
    
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Fotoğraf Kaynağı',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.pop(ctx);
                        final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                        if (picked != null) _saveAndNext(File(picked.path), stepIndex, isPlate: isPlate);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.camera_alt_rounded, color: Color(0xFFD4A373), size: 32),
                            const SizedBox(height: 12),
                            Text('Kamera', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.pop(ctx);
                        final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                        if (picked != null) _saveAndNext(File(picked.path), stepIndex, isPlate: isPlate);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.photo_library_rounded, color: Color(0xFFD4A373), size: 32),
                            const SizedBox(height: 12),
                            Text('Galeri', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _saveAndNext(File file, int stepIndex, {bool isPlate = false}) {
    setState(() {
      if (stepIndex == 1) _insideAngle = file;
      if (stepIndex == 2) _leftAngle = file;
      if (stepIndex == 3) _rightAngle = file;
    if (stepIndex == _currentStep) {
      if (!isPlate) {
        _nextStep();
      } else {
        HapticFeedback.heavyImpact(); // Flaş patladığı an güçlü bir titreşim verelim
      }
    } else {
      // Sadece görseli güncelledi, sayfada kalmaya devam et
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161311), // Biraz daha açık, sıcak ve zengin espresso tonu
      body: Stack(
        children: [
          // Background Mists (Daha yumuşak ve geniş)
          Positioned(
            top: -150,
            left: -100,
            child: _buildBlurryBlob(color: const Color(0xFF5E3A20).withOpacity(0.25), size: 500),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: _buildBlurryBlob(color: const Color(0xFFD4A373).withOpacity(0.15), size: 400),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Stack(
                    children: [
                      // Arka planda tam boyuta yayılan Sayfalar (Hiçbir zaman aşağı/yukarı kaymaz)
                      Positioned.fill(
                        child: PageView(
                          controller: _pageCtrl,
                          physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildIntroScreen(),
                      _buildUploadStep(
                        stepIndex: 1,
                        title: 'Fincan İçi',
                        desc: 'Kamerayı fincanın tam üstüne getirin ve içindeki telveleri odaklayarak çekin.',
                        icon: Icons.keyboard_arrow_down_rounded,
                      ),
                      _buildUploadStep(
                        stepIndex: 2,
                        title: 'Sol Profil',
                        desc: 'Fincanı kulbundan tutup sadece sol yüzünün fotoğrafını net bir şekilde çekin.',
                        icon: Icons.screen_rotation_rounded,
                      ),
                      _buildUploadStep(
                        stepIndex: 3,
                        title: 'Sağ Profil',
                        desc: 'Şimdi fincanın sağ arka yüzünü, ışığın vurduğu açıdan çekin.',
                        icon: Icons.screen_rotation_alt_rounded,
                      ),
                      _buildUploadStep(
                        stepIndex: 4,
                        title: 'Tabağın Sırrı',
                        desc: 'Son olarak tabağın geniş yüzeyini, içindeki telveler net görünecek şekilde çekin.',
                        icon: Icons.blur_circular_rounded,
                        buttonText: 'Tabak Fotoğrafı Çek',
                      ),
                      _buildFinalReadyScreen(),
                      _buildAnalyzingScreen(),
                    ],
                  ),
                ),
                
                // Üstte Yüzen İlerleme Çubuğu ve Yuvalar (Sayfanın Spacer(flex:3) boşluğuna denk gelir, düzeni asla kaydırmaz)
                if (_currentStep > 0 && _currentStep < 6)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Column(
                      key: ValueKey(_currentStep > 0),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildProgressBar(),
                        _buildImageSlots(),
                      ],
                    ),
                  ),
              ],
            ),
          ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < 4; i++) ...[
            Expanded(
              child: TweenAnimationBuilder<double>(
                key: const ValueKey('progress_bar'), // Yalnızca ilk ekrana girişte (montajda) oynar
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 1400 + (i * 250)), // Süreyi uzattık ki gecikme payı olsun
                curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic), // Animasyonun ilk %60'ında (sayfa geçerken) bekle, sonra gel!
                builder: (context, val, child) {
                  return Opacity(
                    opacity: val,
                    child: Transform.translate(
                      offset: Offset(0, 15 * (1 - val)), // Aşağıdan yukarı doğru hafifçe kayarak gelir
                      child: child,
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  height: 4,
                  decoration: BoxDecoration(
                    color: (i + 1) < _currentStep 
                        ? const Color(0xFFD4A373) 
                        : (i + 1) == _currentStep 
                            ? const Color(0xFFD4A373).withOpacity(0.7) 
                            : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            if (i < 3) const SizedBox(width: 8),
          ]
        ],
      ),
    );
  }

  Widget _buildImageSlots() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (int i = 0; i < 4; i++) ...[
            Expanded(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: GestureDetector(
                  onTap: () {
                    int stepNum = i + 1;
                    File? imageFile;
                    if (stepNum == 1) imageFile = _insideAngle;
                    if (stepNum == 2) imageFile = _leftAngle;
                    if (stepNum == 3) imageFile = _rightAngle;
                    if (stepNum == 4) imageFile = _plateAngle;
                    
                    // Sadece mevcut adımda henüz 'Sonraki Adım'a tıklanmadıysa değiştirebilir. 
                    // Geçmiş adımlara dönmek KİLİTLİDİR.
                    if (imageFile != null && (stepNum == _currentStep || (_currentStep == 5 && _invalidSlots.contains(i)))) {
                      HapticFeedback.lightImpact();
                      _pickImage(stepNum, isPlate: stepNum == 4);
                    }
                  },
                  child: TweenAnimationBuilder<double>(
                    key: const ValueKey('image_slots'), // Sadece ekrana ilk girişte animasyon oynar
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 1100 + (i * 150)), // Süreyi uzattık (bekleme payı)
                    curve: const Interval(0.45, 1.0, curve: Curves.easeOutCubic), // Sayfa geçişi bitene kadar (ilk ~500ms) tamamen görünmez!
                    builder: (context, val, child) {
                      return Opacity(
                        opacity: val,
                        child: Transform.translate(
                          offset: Offset(0, 10 * (1 - val)),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _currentStep > (i + 1) 
                            ? Colors.white.withOpacity(0.08)
                            : Colors.white.withOpacity(0.02),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _invalidSlots.contains(i)
                              ? Colors.redAccent.withOpacity(0.8)
                              : _currentStep == (i + 1) 
                                  ? const Color(0xFFD4A373).withOpacity(0.6)
                                  : _currentStep > (i + 1)
                                      ? const Color(0xFFD4A373).withOpacity(0.2)
                                      : Colors.white.withOpacity(0.05),
                          width: _invalidSlots.contains(i) ? 2.5 : (_currentStep == (i + 1) ? 1.5 : 1.0),
                        ),
                        image: () {
                          File? img;
                          if (i == 0) img = _insideAngle;
                          if (i == 1) img = _leftAngle;
                          if (i == 2) img = _rightAngle;
                          if (i == 3) img = _plateAngle;
                          return img != null
                              ? DecorationImage(
                                  image: FileImage(img),
                                  fit: BoxFit.cover,
                                )
                              : null;
                        }(),
                      ),
                      child: Builder(
                        builder: (context) {
                          File? img;
                          if (i == 0) img = _insideAngle;
                          if (i == 1) img = _leftAngle;
                          if (i == 2) img = _rightAngle;
                          if (i == 3) img = _plateAngle;
                          
                          if (img != null) {
                            if (_invalidSlots.contains(i)) {
                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.6),
                                ),
                                child: const Center(
                                  child: Icon(Icons.refresh_rounded, color: Colors.white, size: 24),
                                ),
                              );
                            }
                            return const SizedBox.shrink(); // Resim geçerliyse ikon yok
                          }
                          
                          return Center(
                            child: Icon(
                              _currentStep > (i + 1) ? Icons.check_circle_outline_rounded : Icons.photo_camera_rounded,
                              color: _currentStep == (i + 1) 
                                  ? const Color(0xFFD4A373).withOpacity(0.8) 
                                  : _currentStep > (i + 1) 
                                      ? const Color(0xFFD4A373).withOpacity(0.5)
                                      : Colors.white.withOpacity(0.15),
                              size: 20,
                            ),
                          );
                        }
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (i < 3) const SizedBox(width: 6),
          ]
        ],
      ),
    );
  }

  Widget _buildBlurryBlob({required Color color, required double size}) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Tam ortada başlık
          Center(
            child: Text(
              'KAHVE FALI',
              style: GoogleFonts.inter(
                color: const Color(0xFFE8D5C4),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 3.0,
              ),
            ),
          ),
          // Butonlar üstte
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Sol: Geri Butonu
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (_currentStep > 0 && _currentStep < 5) {
                    setState(() => _currentStep--);
                    _pageCtrl.animateToPage(
                      _currentStep,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.fastOutSlowIn,
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 18),
                ),
              ),
              // Sağ: Fallarım + Ruh Taşı
              Row(
                children: [
                  // Son Falım Butonu
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showLastReadingPanel();
                    },
                    child: ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.10),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _lastReading != null
                                  ? const Color(0xFFD4A373).withOpacity(0.4)
                                  : Colors.white.withOpacity(0.12),
                              width: 0.6,
                            ),
                          ),
                          child: Icon(
                            Icons.coffee_rounded,
                            size: 16,
                            color: _lastReading != null
                                ? const Color(0xFFD4A373).withOpacity(0.9)
                                : Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Ruh Taşı
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showSoulStoneInfoPanel();
                    },
                    child: ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.10),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF22D3EE).withOpacity(0.3),
                              width: 0.6,
                            ),
                          ),
                          child: FutureBuilder<int>(
                            future: StorageService.getSoulStones(),
                            builder: (ctx, snap) {
                              final stones = snap.data ?? _soulStones;
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.diamond_outlined,
                                    size: 11,
                                    color: stones > 0
                                        ? const Color(0xFF22D3EE).withOpacity(0.9)
                                        : Colors.white.withOpacity(0.25),
                                  ),
                                  const SizedBox(width: 1),
                                  Text(
                                    '$stones',
                                    style: TextStyle(
                                      color: stones > 0
                                          ? const Color(0xFF22D3EE).withOpacity(0.9)
                                          : Colors.white.withOpacity(0.3),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SON FAL KAYDI (yeni fal eskiyi siler, 00:00'da sıfırlanır)
  // ═══════════════════════════════════════════════════════════════
  static const String _keyCoffeeReading = 'coffee_last_reading';
  static const String _keyCoffeeReadingDate = 'coffee_last_reading_date';

  Future<void> _loadTodaysReadings() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final savedDate = prefs.getString(_keyCoffeeReadingDate) ?? '';

    if (savedDate != today) {
      // Yeni gün — sıfırla
      await prefs.remove(_keyCoffeeReading);
      await prefs.setString(_keyCoffeeReadingDate, today);
      if (mounted) setState(() => _lastReading = null);
      return;
    }

    final raw = prefs.getString(_keyCoffeeReading);
    if (raw != null) {
      try {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        if (mounted) setState(() => _lastReading = data);
      } catch (_) {
        if (mounted) setState(() => _lastReading = null);
      }
    }
  }

  /// Son fal sonucunu kaydet — eskiyi siler (CoffeeReadingPage'den çağrılacak)
  static Future<void> saveCoffeeReading(Map<String, dynamic> reading) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    reading['time'] = DateTime.now().toIso8601String();
    await prefs.setString(_keyCoffeeReadingDate, today);
    await prefs.setString(_keyCoffeeReading, jsonEncode(reading));
  }



  Widget _preparingInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFD4A373).withOpacity(0.10),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFFD4A373).withOpacity(0.8)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showLastReadingPanel() async {
    await showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible: true,
      barrierLabel: 'LastReading',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        final panelW = MediaQuery.of(context).size.width * 0.85;
        final hasReading = _lastReading != null;
        String timeStr = '';
        if (hasReading) {
          try {
            final dt = DateTime.parse(_lastReading!['time'] ?? '');
            timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
          } catch (_) {}
        }
        final summary = _lastReading?['summary'] ?? '';

        return Center(
          child: SizedBox(
            width: panelW,
            child: Material(
              type: MaterialType.transparency,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A373).withOpacity(0.06),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFD4A373).withOpacity(0.25),
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.coffee_rounded,
                          color: hasReading
                              ? const Color(0xFFD4A373)
                              : Colors.white.withOpacity(0.3),
                          size: 40,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          hasReading ? 'Son Falın' : 'Kahve Falı',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (hasReading && timeStr.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Saat $timeStr • Gece 00:00\'da silinir',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 11,
                            ),
                          ),
                        ],
                        if (hasReading && summary.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            height: 0.5,
                            color: Colors.white.withOpacity(0.08),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            summary,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                              height: 1.6,
                            ),
                            maxLines: 8,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (!hasReading) ...[
                          const SizedBox(height: 20),
                          Icon(
                            Icons.local_cafe_outlined,
                            color: Colors.white.withOpacity(0.08),
                            size: 60,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Henüz fal baktırmadın.\nBir fincan kahve demle,\ntelvelerin sana fısıldamasını bekle.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: const SizedBox.expand(),
            ),
            FadeTransition(
              opacity: anim1,
              child: ScaleTransition(
                scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
                child: child,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSoulStoneInfoPanel() async {
    final soulStones = await StorageService.getSoulStones();
    if (!mounted) return;
    await showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible: true,
      barrierLabel: 'SoulStoneInfo',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        final panelW = MediaQuery.of(context).size.width * 0.85;
        return Center(
          child: SizedBox(
            width: panelW,
            child: Material(
              type: MaterialType.transparency,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    height: _isPremium ? 320 : 360,
                    alignment: Alignment.topCenter,
                    decoration: BoxDecoration(
                      color: _isPremium
                          ? const Color(0xFF22D3EE).withOpacity(0.08)
                          : Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _isPremium
                            ? const Color(0xFF22D3EE).withOpacity(0.35)
                            : Colors.white.withOpacity(0.25),
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Icon(
                          Icons.diamond_rounded,
                          color: soulStones >= 1
                              ? const Color(0xFF22D3EE)
                              : Colors.white.withOpacity(0.3),
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Ruh Taşların',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF22D3EE).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF22D3EE).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.diamond_outlined, size: 14, color: Color(0xFF22D3EE)),
                              const SizedBox(width: 6),
                              Text(
                                soulStones > 0 ? '$soulStones Ruh Taşın var' : 'Ruh Taşın bitti',
                                style: const TextStyle(
                                  color: Color(0xFF22D3EE),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _premiumInfoRow(Icons.auto_awesome, 'Kahve falı yorumlaması için gerekli', true),
                        const SizedBox(height: 10),
                        _premiumInfoRow(Icons.diamond_outlined, 'Her yorum 1 Ruh Taşı harcar', soulStones >= 1),
                        const SizedBox(height: 10),
                        _premiumInfoRow(
                          Icons.workspace_premium,
                          _isPremium
                              ? 'Elite ayrıcalığı: Her gece 5 Ruh Taşı yenilenir'
                              : 'Elite ile her gece 5 Ruh Taşı kazan',
                          _isPremium,
                        ),
                        if (!_isPremium) ...[
                          const Spacer(),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF22D3EE).withOpacity(0.15),
                              elevation: 0,
                              minimumSize: const Size(double.infinity, 44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: const Color(0xFF22D3EE).withOpacity(0.4)),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumPaywallPage()));
                            },
                            child: const Text(
                              'Elite Abone Ol',
                              style: TextStyle(color: Color(0xFF22D3EE), fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: const SizedBox.expand(),
            ),
            FadeTransition(
              opacity: anim1,
              child: ScaleTransition(
                scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
                child: child,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _premiumInfoRow(IconData icon, String text, bool isActive) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? const Color(0xFF22D3EE).withOpacity(0.12)
                : Colors.white.withOpacity(0.05),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isActive
                ? const Color(0xFF22D3EE).withOpacity(0.8)
                : Colors.white.withOpacity(0.3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isActive
                  ? Colors.white.withOpacity(0.75)
                  : Colors.white.withOpacity(0.4),
              fontSize: 13,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedChild(double start, Widget child) {
    final fadeAnim = CurvedAnimation(
      parent: _entranceController,
      curve: Interval(start, math.min(1.0, start + 0.4), curve: Curves.easeOutCubic),
    );
    final slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Interval(start, math.min(1.0, start + 0.5), curve: Curves.easeOutQuart),
    ));

    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: slideAnim,
        child: child,
      ),
    );
  }

  // ADIM 1-4: Kamera Ekranları ve Ritüel
  Widget _buildIntroScreen() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3), // Üstteki itme gücünü artırdık ki blok komple aşağı insin
                    
                    // Özel Fal Ritüeli Animasyonu
                    _buildAnimatedChild(
                      0.0,
                      const _CoffeeRitualAnimation(),
                    ),
                    const SizedBox(height: 16), // Fincan aşağıdaki yazılara biraz daha yaklaştı
                    
                    _buildAnimatedChild(
                      0.15,
                      Text(
                        'RİTÜEL',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFD4A373),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 4.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildAnimatedChild(
                      0.3,
                      Text(
                        'Fincanın Sırları',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAnimatedChild(
                      0.45,
                      Text(
                        'Telveler sadece onlara doğru bakanlara konuşur. Gerçek bir okuma için ritüeli takip et.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                          height: 1.6,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24), // Üstteki açıklama ile liste arasındaki boşluğu daralttık
                    
                    // Ritüel Adımları - Minimalist
                    _buildAnimatedChild(
                      0.55,
                      _buildRitualRow(Icons.self_improvement_rounded, 'Niyetini Belirle', 'Yudumlarken zihninden bir soru veya dilek geçir.'),
                    ),
                    _buildAnimatedChild(0.6, _buildDivider()),
                    _buildAnimatedChild(
                      0.65,
                      _buildRitualRow(Icons.coffee_rounded, 'Aynı Yerden İç', 'Şekillerin bozulmaması için hep aynı taraftan yudumla.'),
                    ),
                    _buildAnimatedChild(0.7, _buildDivider()),
                    _buildAnimatedChild(
                      0.75,
                      _buildRitualRow(Icons.flip_camera_android_rounded, 'Ters Çevir', 'Fincanı kapat, soğumasını bekle ve yavaşça aç.'),
                    ),
                    
                    const SizedBox(height: 24), // Dar ekranlarda butonun metne yapışmasını/bindirmesini engeller
                    const Spacer(),
                    
                    // Fotoğraf Çekimine Geçiş Butonu
                    _buildAnimatedChild(
                      0.85,
                      TapScaleButton(
                        onTap: _nextStep,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: const Color(0xFFD4A373).withOpacity(0.1), // Hafif ve şık bir arka plan
                            border: Border.all(
                              color: const Color(0xFFD4A373).withOpacity(0.5), // Etrafında zarif bir çizgi
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Telvelerin Fısıltısını Dinle',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFD4A373),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), // 20'den 12'ye düşürerek satırları sıkıştırdık
      child: Container(
        height: 1,
        width: double.infinity,
        color: Colors.white.withOpacity(0.05),
      ),
    );
  }

  Widget _buildRitualRow(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFD4A373).withOpacity(0.8), size: 22),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4), // 6'dan 4'e düşürdük
              Text(
                desc,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadStep({
    required int stepIndex,
    required String title,
    required String desc,
    required IconData icon,
    String buttonText = 'Bu Açıyı Çek',
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32), // 24'ten 32'ye çıkardık, ilk sayfayla tamamen aynı oldu
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2), // İlk sayfaya göre biraz daha yukarı çektik (Spacer(flex:2))
                    
                    _CameraAngleInstruction(stepIndex: stepIndex),
                    const SizedBox(height: 48), // Eski boşluğa geri döndük ki animasyon yukarı kaymasın
                    
                    // Sadece yazıları aşağı kaydırıyoruz (Layout'u etkilemeden)
                    Transform.translate(
                      offset: const Offset(0, 30),
                      child: Column(
                        children: [
                          Text(
                            'Adım $stepIndex: $title',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            desc,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 15,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    const Spacer(), // İlk sayfadaki gibi butonu aşağı iten Spacer
                    
                    // Ana Aksiyon Butonu
                    Builder(
                      builder: (context) {
                        bool hasImage = false;
                        if (stepIndex == 1) hasImage = _insideAngle != null;
                        if (stepIndex == 2) hasImage = _leftAngle != null;
                        if (stepIndex == 3) hasImage = _rightAngle != null;
                        if (stepIndex == 4) hasImage = _plateAngle != null;
                        
                        return TapScaleButton(
                          onTap: () {
                            if (hasImage) {
                              // Tüm adımlarda "Sonraki Adım" ile ilerle
                              // Adım 4'te _nextStep() çağrılırsa _buildFinalReadyScreen()'e gider
                              // Oradan Ruh Taşı düşürülüp CoffeeReadingPage'e geçilir
                              _nextStep();
                            } else {
                              _pickImage(stepIndex, isPlate: stepIndex == 4);
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: hasImage ? const Color(0xFFD4A373) : Colors.transparent,
                              border: Border.all(
                                color: hasImage ? Colors.transparent : const Color(0xFFD4A373).withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  hasImage 
                                      ? Icons.arrow_forward_rounded
                                      : Icons.camera_alt_rounded, 
                                  color: hasImage ? const Color(0xFF161311) : const Color(0xFFD4A373), 
                                  size: 18
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  hasImage 
                                      ? 'Sonraki Adım'
                                      : buttonText,
                                  style: GoogleFonts.inter(
                                    color: hasImage ? const Color(0xFF161311) : const Color(0xFFD4A373),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    ),
                    const SizedBox(height: 32), // Butonun sayfa altına yapışmasını engeller
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ADIM 5: Tüm Fotoğraflar Tamam (Tabağı da çektik) ve RUH TAŞI ile Analiz Başlatma (YORUMLAMA SAYFASI)
  Widget _buildFinalReadyScreen() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF7A3FE2).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFB084F4), size: 64),
          ),
          const SizedBox(height: 48),
          Text(
            'Ritüel Tamamlandı',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Tüm fotoğrafların hazır. Fincanındaki sırlar ve tabağındaki gizemler yorumlanmayı bekliyor. Hazırsan Ruh Taşları ile geleceği arala.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 15,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          
          // SADECE RUH TAŞI BUTONU VEYA TARAMA BUTONU
          Builder(
            builder: (context) {
              if (_isValidating) {
                return Column(
                  children: [
                    const CircularProgressIndicator(color: Color(0xFFB084F4)),
                    const SizedBox(height: 16),
                    Text(
                      'Görseller Kontrol Ediliyor...',
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              }

              if (_invalidSlots.isNotEmpty) {
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Geçersiz görseller var, kırmızı ile işaretlendi.',
                            style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        // Otomatik olarak ilk hatalı olanı aç
                        final firstInvalid = _invalidSlots.first;
                        _pickImage(firstInvalid + 1, isPlate: firstInvalid == 3);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.white.withOpacity(0.05),
                          border: Border.all(color: Colors.white.withOpacity(0.15)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Hatalı Olanları Yeniden Çek',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }

              if (_isValidated) {
                return GestureDetector(
                  onTap: _startAnalysisWithSoulStones,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6D28D9).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Falı Yorumla - $_fortuneCost Ruh Taşı',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Henüz doğrulanmadıysa "Sırları Arala" butonu göster
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _validateImages();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: const Color(0xFFD4A373).withOpacity(0.15),
                    border: Border.all(color: const Color(0xFFD4A373).withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_rounded, color: Color(0xFFD4A373), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Sırları Arala',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFD4A373),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          ),
        ],
      ),
    );
  }

  // ADIM 5: Yorumlama
  Widget _buildAnalyzingScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: Color(0xFFD4A373)),
        const SizedBox(height: 32),
        Text(
          'Telveler Okunuyor...',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Geleceğin kapıları aralanıyor, bekle.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

// RİTÜEL ANİMASYONU (Sessiz Lüks)
class _CoffeeRitualAnimation extends StatefulWidget {
  const _CoffeeRitualAnimation();

  @override
  State<_CoffeeRitualAnimation> createState() => _CoffeeRitualAnimationState();
}

class _CoffeeRitualAnimationState extends State<_CoffeeRitualAnimation> with SingleTickerProviderStateMixin {
  int _step = 0; 
  // 0: İçiliyor (Tabak altta, Buhar var)
  // 1: Tabak Kapanıyor (Buhar yok, Tabak üste çıkıyor) ve Telveler için Sallanıyor
  // 2: Ters Çevriliyor (Grup 180 derece dönüyor)
  // 3: Bekleniyor (Mistik parlamalar çıkıyor)
  
  Timer? _timer;
  late AnimationController _swirlController;

  @override
  void initState() {
    super.initState();

    _swirlController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500), // Biraz hızlandırdık
    );

    // Giriş animasyonunun bitmesini bekleyip öyle başlatıyoruz (2000ms)
    _scheduleNextStep(2000);
  }

  void _scheduleNextStep(int delayMs) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: delayMs), () {
      if (!mounted) return;
      
      setState(() {
        _step = (_step + 1) % 4;
        
        if (_step == 1) {
          // Tabak kapandıktan sonra sallanma
          Future.delayed(const Duration(milliseconds: 1200), () {
            if (mounted && _step == 1) {
              _swirlController.forward(from: 0.0);
            }
          });
        }
      });

      // Her adım için özel bekleme süreleri (Daha dinamik ve akıcı)
      int nextDelay = 4000;
      if (_step == 0) {
        nextDelay = 800; // İlk sayfa tekrarlandığında anında kapat
      } else if (_step == 1) {
        nextDelay = 4000; // Kapanma ve sallanma süresi
      } else if (_step == 2) {
        nextDelay = 2000; // Ters dönme süresi
      } else if (_step == 3) {
        nextDelay = 4000; // Soğuma bekleme süresi
      }
      
      _scheduleNextStep(nextDelay);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _swirlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double plateY;
    double groupRotation;
    double plateRotation;
    
    if (_step == 0) {
      plateY = 44.0; // Fincanın altında
      groupRotation = 0.0;
      plateRotation = 0.0; // Tabak normal
    } else if (_step == 1) {
      plateY = -6.0; // Fincanın üstünde (Kapatıldı)
      groupRotation = 0.0;
      plateRotation = 0.5; // Kapanırken havada 180 derece takla atıp kapanıyor!
    } else if (_step == 2 || _step == 3) {
      plateY = -6.0; 
      groupRotation = 0.5; // Bütün sistem ters çevrildi (180 derece)
      plateRotation = 0.5; // Tabak grup içinde zaten tersti
    } else {
      plateY = 44.0;
      groupRotation = 0.0;
      plateRotation = 0.0;
    }

    return Container(
      width: 140,
      height: 140,
      child: Center(
        child: AnimatedBuilder(
          animation: _swirlController,
          builder: (context, child) {
            // Çalkalama (Swirl) Matematiği
            // _swirlController 0'dan 1'e giderken sadece 2 tam tur atar (Çok daha yavaş)
            double angle = _swirlController.value * 2 * 2 * math.pi;
            
            // Titremenin çok sert başlamayıp yavaşça bitmesi için yumuşatıcı çarpan (sinüs çanı)
            double intensity = math.sin(_swirlController.value * math.pi);
            
            // Yatay dairesel hareket (Çok yassı, yataya yakın gerçekçi bir yörünge)
            double dx = 40.0 * math.cos(angle) * intensity;
            double dy = 2.0 * math.sin(angle) * intensity; // Yukarı aşağı hareketi çok kıstık

            return Transform.translate(
              offset: Offset(dx, dy),
              child: child,
            );
          },
          child: AnimatedRotation(
            turns: groupRotation,
            duration: const Duration(milliseconds: 1500), // Çok daha yavaş dönüş
            curve: Curves.easeInOutQuart, // Pürüzsüz başlama ve bitiş
            child: Transform.scale(
              scale: 1.35, // Tüm animasyonu %35 büyütüyoruz
              child: SizedBox(
              width: 80, // Genişliği artırdık ki kulpu da rahatça sığdırsın
              height: 60,
              child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Buhar Efekti (Adım 0)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOut,
                  top: _step == 0 ? -15 : -5,
                  left: 28, // Gövde merkezine (40) hizalandı
                  child: AnimatedOpacity(
                    opacity: _step == 0 ? 0.6 : 0.0,
                    duration: const Duration(milliseconds: 800),
                    child: const Icon(Icons.waves_rounded, color: Color(0xFFD4A373), size: 24),
                  ),
                ),
                
                // Kupa Gövdesi
                Positioned(
                  top: 0,
                  left: 16, // Kupanın gövdesi tam olarak 80 birimlik kutunun ortasına (40) gelecek şekilde ayarlandı
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD4A373),
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                        ),
                      ),
                      // Kulp
                      Container(
                        width: 14,
                        height: 22,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFD4A373), width: 3.5),
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Tabak (Daha geniş, kıvrımlı, taban çıkıntılı ve gövdeye ortalı)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 1200), // Tabak süzülerek yavaşça kapanacak
                  curve: Curves.easeInOutCubic,
                  top: plateY,
                  left: 4, // Tabağın tam ortası kupa gövdesinin ortasına (40) hizalandı
                  child: AnimatedRotation(
                    turns: plateRotation,
                    duration: const Duration(milliseconds: 1200), // Yukarı çıkarken aynı anda dönecek
                    curve: Curves.easeInOutCubic,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tabağın ana geniş gövdesi
                        Container(
                          width: 72, 
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD4A373),
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(8), // Alt kısımlar daha yuvarlak
                              top: Radius.circular(2),    // Üst kısım daha düz
                            ),
                          ),
                        ),
                        // Tabağın altındaki gerçekçi o ufak oturtma çıkıntısı
                        Container(
                          width: 36, 
                          height: 2.5,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD4A373),
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(3), // Çok hafif yumuşaklık
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Soğuma Efekti (Adım 3) - Fincanın soğuduğunu belirtmek için
                Positioned(
                  top: 42, // Kupa ters döndüğünde görsel olarak en üst burası olur (Tabanın üstü)
                  left: 24,
                  child: AnimatedOpacity(
                    opacity: _step == 3 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 1000),
                    child: const Icon(Icons.ac_unit_rounded, color: Color(0xFFD4A373), size: 14),
                  ),
                ),
                Positioned(
                  top: 54, 
                  left: 40,
                  child: AnimatedOpacity(
                    opacity: _step == 3 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 1200),
                    child: const Icon(Icons.ac_unit_rounded, color: Color(0xFFE8D5C4), size: 18),
                  ),
                ),
                Positioned(
                  top: 46, 
                  left: 54,
                  child: AnimatedOpacity(
                    opacity: _step == 3 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 1400),
                    child: const Icon(Icons.ac_unit_rounded, color: Color(0xFFD4A373), size: 12),
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
}

class _CameraAngleInstruction extends StatefulWidget {
  final int stepIndex; // 1: Sol, 2: Sağ, 3: İç
  const _CameraAngleInstruction({super.key, required this.stepIndex});

  @override
  State<_CameraAngleInstruction> createState() => _CameraAngleInstructionState();
}

class _CameraAngleInstructionState extends State<_CameraAngleInstruction> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 5000))..repeat(); // Çok daha yavaş
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
      builder: (context, child) {
        final val = _ctrl.value;

        return SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Builder(
                builder: (context) {
                    // Mükemmel Widget Tabanlı 3D Eğilme Animasyonu (Tüm adımlarda çalışır)
                    double tilt = 0.0;
                    if (val < 0.3) {
                      tilt = Curves.easeInOutSine.transform(val / 0.3); // 0 -> 1 (Yavaşça eğilir)
                    } else if (val < 0.7) {
                      tilt = 1.0; // İçten görünüm sabit bekler
                    } else {
                      tilt = 1.0 - Curves.easeInOutSine.transform((val - 0.7) / 0.3); // Geri döner
                    }

                    if (widget.stepIndex == 4) {
                      // YENİ ANİMASYON: Tabak yukarı kalkar, büyür ve içi görünür (Kupa aşağıda kalır)
                      return Transform.scale(
                        scale: 1.35,
                        child: SizedBox(
                          width: 80.0,
                          height: 80.0,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              // Kupa Gövdesi (Aşağıda kalıyor, tabağın altına iniyor ve tamamen ayrılıyor)
                              Positioned(
                                top: tilt * 70.0, // 0'dan 70'e inerek tabaktan tamamen ayrılıp aşağı düşer
                                left: 16.0,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 48.0,
                                      height: 40.0,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFD4A373),
                                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.0)),
                                      ),
                                    ),
                                    // Kulp
                                    Container(
                                      width: 14.0,
                                      height: 22.0,
                                      margin: const EdgeInsets.only(top: 4.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: const Color(0xFFD4A373), width: 3.5),
                                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(12.0)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Tabak (Yukarı kalkıyor ve açılıyor)
                              Positioned(
                                top: 36.0 - (tilt * 42.0), // 36'dan -6'ya çıkar (Kupadan tamamen kopar ve kameraya yaklaşır)
                                left: 4.0,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Tabağın ana gövdesi (Düz çizgiden daireye dönüşür)
                                    Container(
                                      width: 72.0, 
                                      height: 6.0 + (tilt * 66.0), // 6'dan 72'ye büyür (Tam daire olur)
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD4A373),
                                        borderRadius: BorderRadius.vertical(
                                          bottom: Radius.circular(8.0 + (tilt * 28.0)), // 8 -> 36
                                          top: Radius.circular(2.0 + (tilt * 34.0)),    // 2 -> 36
                                        ),
                                      ),
                                      // Tabağın içi (Telveler)
                                      child: Center(
                                        child: Opacity(
                                          opacity: tilt, // Sadece yukarı kalkarken belirginleşir
                                          child: Container(
                                            width: 62.0, // 72 tabağın içinde 62 siyah alan
                                            height: tilt * 62.0, // 0'dan 62'ye açılır (Elips illüzyonu)
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF161311),
                                              borderRadius: BorderRadius.circular(31.0),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.blur_on_rounded, // Tabağa akan telveler
                                                size: 32.0 * tilt,
                                                color: const Color(0xFFD4A373).withOpacity(0.6),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Tabağın altındaki çıkıntı (Tepeden bakılınca yok olur)
                                    if (tilt < 1.0)
                                      Container(
                                        width: 36.0, 
                                        height: math.max(0.0, 2.5 * (1.0 - tilt)), // 2.5'ten 0'a küçülür
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFD4A373).withOpacity(1.0 - tilt),
                                          borderRadius: const BorderRadius.vertical(
                                            bottom: Radius.circular(3.0),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              
                              // Telefon ve Fotoğraf Çekim Animasyonu (Adım 4 İçin)
                              if (val > 0.3 && val < 0.7) // Sadece tabak tam ortadayken çalışır
                                Builder(
                                  builder: (context) {
                                    // 0.3 ile 0.7 arasını kendi içinde 0.0 - 1.0 bir zaman dilimine dönüştürüyoruz
                                    double p = (val - 0.3) / 0.4;
                                    
                                    double phoneOpacity = 0.0;
                                    double phoneY = 0.0;
                                    double flashOpacity = 0.0;

                                    if (p < 0.2) {
                                      // Giriş: Telefon aşağıdan süzülerek gelir
                                      phoneOpacity = p / 0.2;
                                      phoneY = 30 * (1.0 - phoneOpacity);
                                    } else if (p < 0.8) {
                                      // Sabit duruş ve Fotoğraf Çekimi
                                      phoneOpacity = 1.0;
                                      phoneY = 0.0;
                                      // Flaş patlaması (Tam ortada, p: 0.4 ile 0.6 arası)
                                      if (p > 0.4 && p < 0.6) {
                                        double flashP = (p - 0.4) / 0.2; // 0.0 -> 1.0
                                        flashOpacity = flashP < 0.5 ? (flashP / 0.5) : (1.0 - ((flashP - 0.5) / 0.5));
                                      }
                                    } else {
                                      // Çıkış: Telefon yukarı doğru kayıp gözden kaybolur
                                      phoneOpacity = 1.0 - ((p - 0.8) / 0.2);
                                      phoneY = -30 * (1.0 - phoneOpacity);
                                    }

                                    return OverflowBox(
                                      maxWidth: double.infinity,
                                      maxHeight: double.infinity,
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        alignment: Alignment.center,
                                        children: [
                                          // Flaş Işığı (Soft, lüks bir parlama)
                                          if (flashOpacity > 0)
                                            Transform.translate(
                                              offset: Offset(0, phoneY),
                                              child: Container(
                                                width: 220,
                                                height: 220,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  gradient: RadialGradient(
                                                    colors: [
                                                      Colors.white.withOpacity(flashOpacity * 0.25),
                                                      Colors.white.withOpacity(0.0),
                                                    ],
                                                    stops: const [0.0, 1.0],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          // Telefon Cihazı
                                          Transform.translate(
                                            offset: Offset(0, phoneY),
                                            child: Transform.scale(
                                              scale: 0.75 + (1.0 - phoneOpacity) * 0.1, // Biraz daha küçülttük
                                              child: Opacity(
                                                opacity: phoneOpacity,
                                                child: Stack(
                                                  clipBehavior: Clip.none,
                                                  alignment: Alignment.center,
                                                  children: [
                                                    // Sol Ses Açma Tuşu
                                                    Positioned(
                                                      left: -2,
                                                      top: 36,
                                                      child: Container(width: 2.5, height: 12, decoration: BoxDecoration(color: const Color(0xFFE8D5C4).withOpacity(0.7), borderRadius: const BorderRadius.horizontal(left: Radius.circular(2)))),
                                                    ),
                                                    // Sol Ses Kısma Tuşu
                                                    Positioned(
                                                      left: -2,
                                                      top: 52,
                                                      child: Container(width: 2.5, height: 12, decoration: BoxDecoration(color: const Color(0xFFE8D5C4).withOpacity(0.7), borderRadius: const BorderRadius.horizontal(left: Radius.circular(2)))),
                                                    ),
                                                    // Sağ Güç Tuşu
                                                    Positioned(
                                                      right: -2,
                                                      top: 44,
                                                      child: Container(width: 2.5, height: 16, decoration: BoxDecoration(color: const Color(0xFFE8D5C4).withOpacity(0.7), borderRadius: const BorderRadius.horizontal(right: Radius.circular(2)))),
                                                    ),
                                                    // Telefon Gövdesi (Ekran Yüzü)
                                                    Container(
                                                      width: 76,
                                                      height: 160,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(color: const Color(0xFFE8D5C4).withOpacity(0.5), width: 2.5),
                                                        borderRadius: BorderRadius.circular(18),
                                                        color: Colors.white.withOpacity(0.02),
                                                      ),
                                                      child: Stack(
                                                        alignment: Alignment.center,
                                                        children: [
                                                          // Odak Karesi (Vizör)
                                                          Icon(Icons.crop_free_rounded, color: const Color(0xFFD4A373).withOpacity(0.8), size: 36),
                                                          // Dynamic Island
                                                          Positioned(
                                                            top: 6,
                                                            child: Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Container(width: 22, height: 7, decoration: BoxDecoration(color: Colors.black.withOpacity(0.85), borderRadius: BorderRadius.circular(4))),
                                                                const SizedBox(width: 2.5),
                                                                Container(width: 7, height: 7, decoration: BoxDecoration(color: Colors.black.withOpacity(0.85), shape: BoxShape.circle)),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Tilt calculation is now at the top.

                    return Transform.scale(
                      scale: 1.35, // İlk ekrandaki boyutla birebir aynı olması için büyüttük
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                        children: [
                          // Kupa Gövdesi ve Kulp (Adım 1, 2, 3)
                          Positioned(
                            top: 24.0 - (tilt * 4.0), // Eğildikçe tam ortaya yerleşmek için yukarı kayar
                            left: 16.0, 
                            child: Transform.rotate(
                                  angle: widget.stepIndex == 2 ? -0.25 : (widget.stepIndex == 3 ? 0.25 : 0.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Fincan Gövdesi
                                      Container(
                                        width: 48.0,
                                        height: 40.0 + (tilt * 8.0), // 40'tan 48'e (Tam Daire Olur)
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFD4A373),
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(20.0 + (tilt * 4.0)), // 20 -> 24
                                            bottomRight: Radius.circular(20.0 + (tilt * 4.0)),
                                            topLeft: Radius.circular(tilt * 24.0), // 0 -> 24
                                            topRight: Radius.circular(tilt * 24.0),
                                          ),
                                        ),
                                        // Fincanın ağzı (İçi)
                                        alignment: Alignment(0.0, -1.0 + tilt), // Üst kenardan merkeze kayar
                                        child: Container(
                                          width: 44.0, // Ağız genişliği hep aynı
                                          height: tilt * 44.0, // Yükseklik 0'dan 44'e açılarak elips illüzyonu yaratır
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF161311),
                                            borderRadius: BorderRadius.circular(22.0),
                                          ),
                                          child: Center(
                                            child: Opacity(
                                              opacity: tilt,
                                              child: Icon(
                                                Icons.blur_on_rounded, // Telveler
                                                size: 24.0 * tilt,
                                                color: const Color(0xFFD4A373).withOpacity(0.6),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Kulp (Gerçekçi Fizik: Tepeden bakıldığında ince ve kısa bir çıkıntı)
                                      Container(
                                        width: 14.0 - (tilt * 4.0), // Biraz kısalır (14 -> 10)
                                        height: 22.0 - (tilt * 16.0), // Çok daha ince hale gelir (22 -> 6)
                                        // Gövde 48 olacak. 6 boyundaki kulpu ortalamak için (48-6)/2 = 21.
                                        // 4'ten 21'e: 4 + (tilt * 17)
                                        margin: EdgeInsets.only(top: 4.0 + (tilt * 17.0)), 
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFD4A373).withOpacity(tilt), // İçi dolar
                                          border: Border.all(color: const Color(0xFFD4A373), width: 3.5 - (tilt * 2.5)), // Hata vermemesi için kenarlık da incelir
                                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(12.0)), // Ucu her zaman tam yuvarlak kalsın
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          ), // Positioned'ı kapatıyoruz
                          // Telefon ve Fotoğraf Çekim Animasyonu
                          if (val > 0.3 && val < 0.7) // Sadece fincan tam tepedeyken çalışır
                            Builder(
                              builder: (context) {
                                // 0.3 ile 0.7 arasını kendi içinde 0.0 - 1.0 bir zaman dilimine dönüştürüyoruz
                                double p = (val - 0.3) / 0.4;
                                
                                double phoneOpacity = 0.0;
                                double phoneY = 0.0;
                                double flashOpacity = 0.0;

                                if (p < 0.2) {
                                  // Giriş: Telefon aşağıdan süzülerek gelir
                                  phoneOpacity = p / 0.2;
                                  phoneY = 30 * (1.0 - phoneOpacity);
                                } else if (p < 0.8) {
                                  // Sabit duruş ve Fotoğraf Çekimi
                                  phoneOpacity = 1.0;
                                  phoneY = 0.0;
                                  // Flaş patlaması (Tam ortada, p: 0.4 ile 0.6 arası)
                                  if (p > 0.4 && p < 0.6) {
                                    double flashP = (p - 0.4) / 0.2; // 0.0 -> 1.0
                                    flashOpacity = flashP < 0.5 ? (flashP / 0.5) : (1.0 - ((flashP - 0.5) / 0.5));
                                  }
                                } else {
                                  // Çıkış: Telefon yukarı doğru kayıp gözden kaybolur
                                  phoneOpacity = 1.0 - ((p - 0.8) / 0.2);
                                  phoneY = -30 * (1.0 - phoneOpacity);
                                }
                                
                                // Sol ve Sağ Profil İçin Telefonun Yeri/Açısı Değişir!
                                double phoneOffsetX = 0.0;
                                double phoneRotation = 0.0;
                                if (widget.stepIndex == 2) { // Sol Profil
                                  phoneOffsetX = -25.0; // Sola kaydır
                                  phoneRotation = -0.2; // Sola hafif eğ (radyan)
                                } else if (widget.stepIndex == 3) { // Sağ Profil
                                  phoneOffsetX = 25.0; // Sağa kaydır
                                  phoneRotation = 0.2; // Sağa hafif eğ
                                }

                                return OverflowBox(
                                  maxWidth: double.infinity,
                                  maxHeight: double.infinity,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    alignment: Alignment.center,
                                    children: [
                                    // Flaş Işığı (Soft, lüks bir parlama)
                                    if (flashOpacity > 0)
                                      Transform.translate(
                                        offset: Offset(phoneOffsetX, phoneY),
                                        child: Container(
                                          width: 220,
                                          height: 220,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              colors: [
                                                Colors.white.withOpacity(flashOpacity * 0.25),
                                                Colors.white.withOpacity(0.0),
                                              ],
                                              stops: const [0.0, 1.0],
                                            ),
                                          ),
                                        ),
                                      ),
                                    // Telefon Cihazı
                                    Transform.translate(
                                      offset: Offset(phoneOffsetX, phoneY),
                                      child: Transform.rotate(
                                        angle: phoneRotation,
                                        child: Transform.scale(
                                          scale: 0.75 + (1.0 - phoneOpacity) * 0.1, // Biraz daha küçülttük (0.85 -> 0.75)
                                          child: Opacity(
                                            opacity: phoneOpacity,
                                            child: Stack(
                                              clipBehavior: Clip.none,
                                              alignment: Alignment.center,
                                              children: [
                                                // Sol Ses Açma Tuşu
                                                Positioned(
                                                  left: -2,
                                                  top: 36,
                                                  child: Container(width: 2.5, height: 12, decoration: BoxDecoration(color: const Color(0xFFE8D5C4).withOpacity(0.7), borderRadius: const BorderRadius.horizontal(left: Radius.circular(2)))),
                                                ),
                                                // Sol Ses Kısma Tuşu
                                                Positioned(
                                                  left: -2,
                                                  top: 52,
                                                  child: Container(width: 2.5, height: 12, decoration: BoxDecoration(color: const Color(0xFFE8D5C4).withOpacity(0.7), borderRadius: const BorderRadius.horizontal(left: Radius.circular(2)))),
                                                ),
                                                // Sağ Güç Tuşu
                                                Positioned(
                                                  right: -2,
                                                  top: 44,
                                                  child: Container(width: 2.5, height: 16, decoration: BoxDecoration(color: const Color(0xFFE8D5C4).withOpacity(0.7), borderRadius: const BorderRadius.horizontal(right: Radius.circular(2)))),
                                                ),

                                                // Telefon Gövdesi (Ekran Yüzü)
                                                Container(
                                                  width: 76,
                                                  height: 160, // Tam olarak 6.3 inç (1:2.1 civarı) gerçekçi oran!
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: const Color(0xFFE8D5C4).withOpacity(0.5), width: 2.5), // Metalik kasa kenarı
                                                    borderRadius: BorderRadius.circular(18),
                                                    // İçi şeffaf kalıyor ki kahve görünsün
                                                    color: Colors.white.withOpacity(0.02),
                                                  ),
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      // Odak Karesi (Vizör)
                                                      Icon(Icons.crop_free_rounded, color: const Color(0xFFD4A373).withOpacity(0.8), size: 36),
                                                      // Dynamic Island (Kullanıcının Çizdiği: Hap + Nokta Çentik)
                                                      Positioned(
                                                        top: 6,
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            // Hap şeklindeki çentik
                                                            Container(
                                                              width: 22,
                                                              height: 7,
                                                              decoration: BoxDecoration(
                                                                color: Colors.black.withOpacity(0.85),
                                                                borderRadius: BorderRadius.circular(4),
                                                              ),
                                                            ),
                                                            const SizedBox(width: 2.5),
                                                            // Yuvarlak sensör / ön kamera noktası
                                                            Container(
                                                              width: 7,
                                                              height: 7,
                                                              decoration: BoxDecoration(
                                                                color: Colors.black.withOpacity(0.85),
                                                                shape: BoxShape.circle,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            ),
                        ],
                      ),
                    ));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class CupFlipPainter extends CustomPainter {
  final double tilt;

  CupFlipPainter({required this.tilt});

  @override
  void paint(Canvas canvas, Size size) {
    double cx = size.width / 2;
    double cy = size.height / 2;

    final paint = Paint()
      ..color = const Color(0xFFD4A373).withOpacity(0.3 + (tilt * 0.1))
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFFD4A373).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    double cupWidth = 44.0;
    double cupHeight = 36.0;
    
    double currentCupWidth = cupWidth + (tilt * (56 - cupWidth));
    
    // 1. BUHAR (Steam) - Yavaşça kaybolur
    if (tilt < 0.3) {
      double steamOpacity = 1.0 - (tilt / 0.3);
      final steamPaint = Paint()
        ..color = const Color(0xFFD4A373).withOpacity(0.4 * steamOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;
      
      for (int i = -1; i <= 1; i++) {
        Path steamPath = Path();
        double sx = cx + (i * 8);
        double sy = cy - cupHeight/2 - 10;
        steamPath.moveTo(sx, sy);
        steamPath.quadraticBezierTo(sx - 4, sy - 4, sx, sy - 8);
        steamPath.quadraticBezierTo(sx + 4, sy - 12, sx, sy - 16);
        canvas.drawPath(steamPath, steamPaint);
      }
    }

    // 2. TABAK (Saucer) - Aşağı kayarak kaybolur
    if (tilt < 0.5) {
      double plateOpacity = 1.0 - (tilt / 0.5);
      final platePaint = Paint()
        ..color = const Color(0xFFD4A373).withOpacity(0.3 * plateOpacity)
        ..style = PaintingStyle.fill;
      
      double plateY = cy + cupHeight/2 + 6 + (tilt * 10);
      Rect plateRect = Rect.fromCenter(center: Offset(cx, plateY), width: 56, height: 4);
      canvas.drawRRect(RRect.fromRectAndRadius(plateRect, const Radius.circular(2)), platePaint);
    }

    // 3. KULP (Handle) - İçe doğru kaybolur
    if (tilt < 0.8) {
      double handleOpacity = 1.0 - (tilt / 0.8);
      final handlePaint = Paint()
        ..color = const Color(0xFFD4A373).withOpacity(0.4 * handleOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;
      
      double handleX = cx + currentCupWidth/2;
      double handleY = cy - 2;
      Rect handleRect = Rect.fromLTWH(handleX, handleY, 14, 20);
      canvas.drawArc(handleRect, -math.pi/2, math.pi, false, handlePaint);
    }

    // 4. FİNCAN GÖVDESİ VE AĞZI
    double bodyTopY = cy - cupHeight/2 + (tilt * cupHeight/2);
    double bodyBottomY = cy + cupHeight/2 - (tilt * cupHeight/2);
    
    double topOvalHeight = 4 + (tilt * 52);
    Rect topOval = Rect.fromCenter(center: Offset(cx, bodyTopY), width: currentCupWidth, height: topOvalHeight);
    
    Path bodyPath = Path();
    double bottomRadius = 18 + (tilt * 10);
    
    bodyPath.moveTo(cx - currentCupWidth/2, bodyTopY);
    bodyPath.lineTo(cx - currentCupWidth/2, bodyBottomY - bottomRadius);
    bodyPath.quadraticBezierTo(cx - currentCupWidth/2, bodyBottomY, cx - currentCupWidth/2 + bottomRadius, bodyBottomY);
    bodyPath.lineTo(cx + currentCupWidth/2 - bottomRadius, bodyBottomY);
    bodyPath.quadraticBezierTo(cx + currentCupWidth/2, bodyBottomY, cx + currentCupWidth/2, bodyBottomY - bottomRadius);
    bodyPath.lineTo(cx + currentCupWidth/2, bodyTopY);
    
    canvas.drawPath(bodyPath, paint);
    canvas.drawPath(bodyPath, borderPaint);
    
    // Fincan İçi
    final insidePaint = Paint()
      ..color = const Color(0xFF161311)
      ..style = PaintingStyle.fill;
    
    canvas.drawOval(topOval, insidePaint);
    canvas.drawOval(topOval, borderPaint);
    
    // 5. TELVELER
    if (tilt > 0.3) {
      double groundsOpacity = (tilt - 0.3) / 0.7;
      
      final blurPaint = Paint()
        ..color = const Color(0xFFD4A373).withOpacity(0.15 * groundsOpacity)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        
      canvas.drawCircle(Offset(cx, bodyTopY), currentCupWidth * 0.35, blurPaint);
      
      final dotPaint = Paint()
        ..color = const Color(0xFFD4A373).withOpacity(0.5 * groundsOpacity)
        ..style = PaintingStyle.fill;
        
      canvas.drawCircle(Offset(cx, bodyTopY), 2 + (tilt * 4), dotPaint);
      canvas.drawCircle(Offset(cx - 8, bodyTopY + 5), 1.5 + (tilt * 3), dotPaint);
      canvas.drawCircle(Offset(cx + 10, bodyTopY - 4), 1.5 + (tilt * 3), dotPaint);
      canvas.drawCircle(Offset(cx - 6, bodyTopY - 10), 1 + (tilt * 2), dotPaint);
      canvas.drawCircle(Offset(cx + 8, bodyTopY + 10), 2 + (tilt * 2), dotPaint);
    }
  }

  @override
  bool shouldRepaint(CupFlipPainter oldDelegate) => oldDelegate.tilt != tilt;
}
