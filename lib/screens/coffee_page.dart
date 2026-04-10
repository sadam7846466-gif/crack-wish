import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CoffeePage extends StatefulWidget {
  const CoffeePage({super.key});

  @override
  State<CoffeePage> createState() => _CoffeePageState();
}

class _CoffeePageState extends State<CoffeePage> with TickerProviderStateMixin {
  late PageController _pageCtrl;
  int _currentStep = 0;
  
  // Arka plandaki fincan animasyonu için
  late AnimationController _floatCtrl;

  // Sahte Economy State (Entegrasyonda globale bağlanacak)
  bool _isPremium = false; // BAŞLANGIÇTA ÜCRETSİZ KULLANICI (PREMIUM DEĞİL)
  int _soulStones = 120;
  final int _fortuneCost = 30; // 1 Fal Maliyeti: 30 Ruh Taşı

  // Görselleri tutacağımız değişkenler
  final ImagePicker _picker = ImagePicker();
  File? _leftAngle;
  File? _rightAngle;
  File? _insideAngle;
  File? _plateAngle;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(initialPage: 0);
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    // Sadece Premiumlar girebilir kontrolü
    if (_currentStep == 0 && !_isPremium) {
      _showPremiumPaywall();
      return;
    }

    if (_currentStep < 5) {
      HapticFeedback.mediumImpact();
      setState(() => _currentStep++);
      _pageCtrl.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 600),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  // Ruh Taşı ile Satın Alma / Başlatma
  void _startAnalysisWithSoulStones() {
    if (_soulStones < _fortuneCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yetersiz Ruh Taşı! ✨')),
      );
      return;
    }

    // Seçili fotoğraf kontrolü
    if (_leftAngle == null || _rightAngle == null || _insideAngle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen fincanın 3 açısını da çekin!')),
      );
      return;
    }

    HapticFeedback.heavyImpact();
    
    // Ruh taşını düş
    setState(() {
      _soulStones -= _fortuneCost;
    });

    _nextStep();
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
      if (stepIndex == 1) _leftAngle = file;
      if (stepIndex == 2) _rightAngle = file;
      if (stepIndex == 3) _insideAngle = file;
      if (isPlate) _plateAngle = file;
    });
    
    if (!isPlate) {
      _nextStep();
    } else {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tabak Eklendi ☕')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A08), // Koyu kahve siyahı
      body: Stack(
        children: [
          // Background Mists
          Positioned(
            top: -100,
            left: -100,
            child: _buildBlurryBlob(color: const Color(0xFF4A2B15).withOpacity(0.3), size: 400),
          ),
          Positioned(
            bottom: -50,
            right: -100,
            child: _buildBlurryBlob(color: const Color(0xFFD4A373).withOpacity(0.1), size: 300),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                // İlerleme Çubuğu (Karşılama ekranında gizli)
                if (_currentStep > 0 && _currentStep < 5)
                  _buildProgressBar(),
                
                Expanded(
                  child: PageView(
                    controller: _pageCtrl,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildIntroScreen(),
                      _buildUploadStep(
                        stepIndex: 1,
                        title: 'Sol Profil',
                        desc: 'Fincanı kulbundan tutup sadece sol yüzünün fotoğrafını net bir şekilde çekin.',
                        icon: Icons.screen_rotation_rounded,
                      ),
                      _buildUploadStep(
                        stepIndex: 2,
                        title: 'Sağ Profil',
                        desc: 'Şimdi fincanın sağ arka yüzünü, ışığın vurduğu açıdan çekin.',
                        icon: Icons.screen_rotation_alt_rounded,
                      ),
                      _buildUploadStep(
                        stepIndex: 3,
                        title: 'Fincan İçi',
                        desc: 'Kamerayı fincanın tam üstüne getirin ve içindeki telveleri odaklayarak çekin.',
                        icon: Icons.keyboard_arrow_down_rounded,
                      ),
                      _buildFinalReadyScreen(), // Tabak Adımı Premium Ruh Taşı Kontrolüne dönüştü
                      _buildAnalyzingScreen(),
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
        children: List.generate(4, (index) {
          int stepNum = index + 1;
          bool isActive = stepNum == _currentStep;
          bool isPast = stepNum < _currentStep;
          
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index == 3 ? 0 : 8),
              decoration: BoxDecoration(
                color: isPast 
                    ? const Color(0xFFD4A373) 
                    : isActive 
                        ? const Color(0xFFD4A373).withOpacity(0.6) 
                        : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBlurryBlob({required Color color, required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Geri Butonu
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (_currentStep > 0 && _currentStep < 5) {
                // Geri dön
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            ),
          ),
          
          // Başlık
          Text(
            'Türk Kahvesi Falı',
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          
          // Ruh Taşı Göstergesi (Yeni ekledik!)
          if (_isPremium)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF7A3FE2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF7A3FE2).withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bubble_chart_rounded, color: Color(0xFFB084F4), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '$_soulStones',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox(width: 44),
        ],
      ),
    );
  }

  // ADIM 0: Karşılama Ekranı ve Ritüel
  Widget _buildIntroScreen() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    
                    // KULLANICI BURAYA KENDİ İSTEDİĞİ GÖRSELİ/ANİMASYONU EKLEYECEK
                    
                    Text(
                      'Fal Öncesi Ritüeli',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Türk Kahvesi falı, dibe çöken telvelerin oluşturduğu mistik şekillerle okunur. Gerçek bir okuma için ritüele uyduğundan emin ol:',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 13,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    
                    // Ritüel Adımları
                    _buildRitualRow(Icons.self_improvement_rounded, 'Niyet Et', 'Yudumlarken zihninden niyet geçir.'),
                    const SizedBox(height: 12),
                    _buildRitualRow(Icons.coffee_rounded, 'Aynı Yerden İç', 'Şekillerin bozulmaması için hep aynı taraftan iç.'),
                    const SizedBox(height: 12),
                    _buildRitualRow(Icons.flip_camera_android_rounded, 'Ters Çevir, Soğut', 'Fincanı ters kapatıp dileğini dile ve soğumasını bekle.'),
                    
                    const Spacer(),
                    
                    // Kilit veya Normal Buton
                    GestureDetector(
                      onTap: _nextStep,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            colors: _isPremium 
                              ? [const Color(0xFFD4A373), const Color(0xFF8B5A2B)]
                              : [const Color(0xFF1A1A1A), const Color(0xFF1A1A1A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: _isPremium ? Colors.transparent : const Color(0xFFD4A373).withOpacity(0.3),
                          ),
                          boxShadow: _isPremium ? [
                            BoxShadow(
                              color: const Color(0xFFD4A373).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ] : [],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isPremium ? Icons.camera_alt_rounded : Icons.lock_rounded, 
                              color: _isPremium ? Colors.white : const Color(0xFFD4A373),
                              size: 20
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _isPremium ? 'Hazırım, Fotoğrafları Çek' : 'Premium İle Kilidi Aç',
                              style: GoogleFonts.inter(
                                color: _isPremium ? Colors.white : const Color(0xFFD4A373),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildRitualRow(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFD4A373).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD4A373).withOpacity(0.2)),
          ),
          child: Icon(icon, color: const Color(0xFFD4A373), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ADIM 1,2,3: Görsel Yükleme Ekranları
  Widget _buildUploadStep({
    required int stepIndex,
    required String title,
    required String desc,
    required IconData icon,
    String buttonText = 'Bu Açıyı Çek',
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFD4A373).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFD4A373), size: 64),
          ),
          const SizedBox(height: 48),
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
          const SizedBox(height: 60),
          
          // Ana Aksiyon Butonu
          GestureDetector(
            onTap: () => _pickImage(stepIndex),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFD4A373).withOpacity(0.5)),
                color: Colors.white.withOpacity(0.05),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt_outlined, color: Color(0xFFD4A373), size: 20),
                  const SizedBox(width: 12),
                  Text(
                    buttonText,
                    style: GoogleFonts.inter(
                      color: const Color(0xFFD4A373),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ADIM 4: Tüm Fotoğraflar Tamam (Tabağı da birleştirdik) ve RUH TAŞI ile Analiz Başlatma
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
            'Adım 4: Tabak ve Sonuç',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Fotoğrafların hazır. Son olarak varsa tabağını da ekle ve Ruh Taşlarını kullanarak geleceği arala.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 15,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          
          // Tabak Fotoğrafı Çek (Gerçek seçici tetiklenir)
          GestureDetector(
            onTap: () => _pickImage(4, isPlate: true),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                color: Colors.white.withOpacity(0.02),
              ),
              child: Center(
                child: Text(
                  '+ Tabak Ekle (İsteğe Bağlı)',
                  style: GoogleFonts.inter(color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
          
          // RUH TAŞI BUTONU
          GestureDetector(
            onTap: _startAnalysisWithSoulStones, // Yeni Fonksiyon (Ruh taşı düşüyor)
            child: Container(
               width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFF7A3FE2), Color(0xFF5A2BB5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7A3FE2).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bubble_chart_rounded, color: Colors.white, size: 20),
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
