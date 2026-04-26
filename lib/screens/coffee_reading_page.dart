import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'coffee_detailed_reading_page.dart';
import '../services/storage_service.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/cosmic_engine_service.dart';
import 'coffee_page.dart';

class CoffeeReadingPage extends StatefulWidget {
  final File insideAngle;
  final File leftAngle;
  final File rightAngle;
  final File plateAngle;

  const CoffeeReadingPage({
    super.key,
    required this.insideAngle,
    required this.leftAngle,
    required this.rightAngle,
    required this.plateAngle,
  });

  @override
  State<CoffeeReadingPage> createState() => _CoffeeReadingPageState();
}

class _CoffeeReadingPageState extends State<CoffeeReadingPage> with TickerProviderStateMixin {
  bool _isLoading = true;
  int _loadingTextIndex = 0;
  Timer? _loadingTimer;
  int _soulStones = 0;
  int? _expandedPhotoIndex;
  bool _isSymbolsExpanded = false;
  
  int _smokeStep = 0;
  Timer? _smokeTimer;
  
  late AnimationController _pulseController;
  late AnimationController _rotationController;

  // Sonuç ekranı giriş animasyonu
  late AnimationController _resultEntranceController;

  final List<String> _loadingTexts = [
    "Fincanın derinliklerine iniliyor...",
    "Telvelerdeki semboller evrensel enerjiyle eşleşiyor...",
    "Ruh rehberleri dinleniyor...",
    "Kader çizgilerin haritalanıyor...",
    "Sırlar açığa çıkıyor..."
  ];

  @override
  void initState() {
    super.initState();
    _loadSoulStones();

    // Aura animasyonları
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _resultEntranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Bekleme yazılarının değişimi
    _loadingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _isLoading) {
        setState(() {
          if (_loadingTextIndex < _loadingTexts.length - 1) {
            _loadingTextIndex++;
          }
        });
      }
    });

    // Duman animasyonu için sayaç
    _smokeTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (mounted && _isLoading) {
        setState(() {
          _smokeStep = (_smokeStep + 1) % 4;
        });
      }
    });

    // Sahte API bekleme süresi (UI testleri için 10 saniye)
    _simulateApiCall();
  }

  Future<void> _loadSoulStones() async {
    final stones = await StorageService.getSoulStones();
    if (mounted) setState(() => _soulStones = stones);
  }

  void _simulateApiCall() async {
    // Gelecekte burası gerçek Supabase/Edge Function API çağrısı olacak.
    
    // Kullanıcı sayfadan çıksa bile falı hazır olduğunda bildirim gitsin
    CosmicEngineService().scheduleInstantLocalNotification(
      title: "Kahve Falın Hazır! ☕️",
      body: "Fincanındaki sırlar çözüldü. Yorumunu okumak için tıkla.",
      secondsDelay: 14,
    );

    await Future.delayed(const Duration(seconds: 14));
    
    // Arka planda falı kaydet (Sayfadan çıkmış olsa bile kaydedilir)
    final dummyReading = {
      "summary": "Bir süredir beklediğin bir haber yakında geliyor.\nÖnünde açılan bir yol, seni ferahlatacak.\nKüçük bir kısmet, eline beklenmedik bir şekilde geçebilir.\nNetleşen bir konu sayesinde iç huzurun artıyor.",
      "symbols": ["Kuş - Haber/Müjde", "Açık Yol - Ferahlık", "Kalp - Sevgi"],
    };
    
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    dummyReading['time'] = DateTime.now().toIso8601String();
    await prefs.setString('coffee_last_reading_date', today);
    await prefs.setString('coffee_last_reading', jsonEncode(dummyReading));
    
    if (mounted) {
      HapticFeedback.heavyImpact();
      setState(() {
        _isLoading = false;
      });
      _resultEntranceController.forward();
    }
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    _smokeTimer?.cancel();
    _pulseController.dispose();
    _rotationController.dispose();
    _resultEntranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0A09), // Çok derin siyah/kahve
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 1200),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: _isLoading ? _buildLoadingScreen() : _buildResultScreen(),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return SafeArea(
      key: const ValueKey('loading'),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            const Spacer(flex: 3),
            // Mistik Kahve ve Duman Animasyonu (Ritüel Fincanı)
            SizedBox(
              width: 140,
              height: 140,
              child: Transform.scale(
                scale: 1.35, // Biraz küçülttük
                child: Center(
                  child: SizedBox(
                    width: 80,
                    height: 100, // Dumanlar için yüksekliği artırdık
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        // Minimalist Çizgi Duman Animasyonu (Kullanıcının Çizimi)
                        ...List.generate(3, (index) {
                          return AnimatedBuilder(
                            animation: _rotationController,
                            builder: (context, child) {
                              // Hızı yavaşlatıldı (*4 yerine daha sakin bir ritim)
                              final progress = ((_rotationController.value * 3.5) + (index * 0.33)) % 1.0;
                              
                              // Hareketi yumuşatmak için yavaşlayarak çıkan bir eğri kullanıyoruz
                              final easeProgress = Curves.easeOut.transform(progress);
                              
                              // Aşağıdan yukarıya çok daha yumuşak ve kavisli bir yükseliş
                              final dy = -45 * easeProgress;
                              
                              // Ortada en belirgin, başta ve sonda tamamen silik (yumuşak geçiş)
                              final opacity = math.sin(progress * math.pi) * 0.7; // Biraz daha şeffaf ve elit
                              
                              // X ekseninde yan yana dizilim (24, 34, 44)
                              final leftPos = 24.0 + (index * 10.0);
                              
                              return Positioned(
                                top: 15 + dy, // Fincanın üstünden süzülerek çıkıyor
                                left: leftPos,
                                child: Opacity(
                                  opacity: opacity,
                                  child: CustomPaint(
                                    size: const Size(12, 28), // Kullanıcının çizdiği zarif "S" boyutu
                                    painter: SmokeWispPainter(color: const Color(0xFFD4A373)),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                        // Kupa Gövdesi
                        Positioned(
                          top: 40,
                          left: 16,
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
                        
                        // Tabak
                        Positioned(
                          top: 84.0, // Fincanın altına oturtuldu
                          left: 4,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 72, 
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD4A373),
                                  borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(8),
                                    top: Radius.circular(2),
                                  ),
                                ),
                              ),
                              Container(
                                width: 44,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD4A373),
                                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(6)),
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
            
            const Spacer(flex: 2),
            
            // ─── Bilgilendirme Alanı ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  _buildLoadingInfoRow(
                    Icons.notifications_active_outlined,
                    'Falın hazır olunca bildirim alacaksın',
                  ),
                  const SizedBox(height: 18),
                  _buildLoadingInfoRow(
                    Icons.coffee_rounded,
                    Text.rich(
                      TextSpan(
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 16,
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(text: 'Sonucu ana sayfadaki  '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Icon(Icons.coffee_rounded, size: 18, color: Colors.white.withOpacity(0.65)),
                          ),
                          const TextSpan(text: '  butonundan görebilirsin'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildLoadingInfoRow(
                    Icons.explore_outlined,
                    'Burada bekle ya da uygulamayı keşfet',
                  ),
                ],
              ),
            ),
            
            const Spacer(flex: 1),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.white.withOpacity(0.06),
                    border: Border.all(
                      color: const Color(0xFFD4A373).withOpacity(0.25),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Ana Sayfaya Dön',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFD4A373).withOpacity(0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingInfoRow(IconData icon, dynamic content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFD4A373).withOpacity(0.10),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFFD4A373).withOpacity(0.8)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: content is String
              ? Text(
                  content,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 16,
                    height: 1.4,
                  ),
                )
              : content,
        ),
      ],
    );
  }

  Widget _buildAnimatedResultChild(double start, Widget child) {
    final fadeAnim = CurvedAnimation(
      parent: _resultEntranceController,
      curve: Interval(start, math.min(1.0, start + 0.4), curve: Curves.easeOutCubic),
    );
    final slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _resultEntranceController,
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

  Widget _buildResultScreen() {
    return Stack(
      key: const ValueKey('result'),
      children: [
        // 1. Kaydırılabilir İçerik (Tam Ekran)
        Positioned.fill(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 90, // App Bar için boşluk
              bottom: MediaQuery.of(context).padding.bottom + 80, // Alt sınırda rahatlık
              left: 24,
              right: 24,
            ),
            child: Column(
              children: [
                // Title Section
                // 1. Fincanın Bölümleri (Premium Liste)
                _buildAnimatedResultChild(
                  0.0,
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF140F0C),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFD4A373).withOpacity(0.3), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPremiumHeader(Icons.coffee_rounded, 'Fincanın Bölümleri'),
                        const SizedBox(height: 20),
                        _ExpandablePhotoItem(
                          file: widget.insideAngle,
                          title: 'Fincan İçi',
                          shortDesc: 'İç dünyan, düşüncelerin, duygusal halin.',
                          detailedDesc: 'İç dünyanı yansıtır. Telvelerin durumu kafandaki karışıklığın yakında dağılacağını söylüyor.',
                          icon: Icons.local_cafe_rounded,
                          isExpanded: _expandedPhotoIndex == 0,
                          onTap: () {
                            setState(() {
                              _expandedPhotoIndex = _expandedPhotoIndex == 0 ? null : 0;
                            });
                          },
                        ),
                        _ExpandablePhotoItem(
                          file: widget.leftAngle,
                          title: 'Kenar',
                          shortDesc: 'Yakın gelecek, haber, mesaj, görüşme.',
                          detailedDesc: 'Dış dünyayla bağlantındır. Dışa açılan izler sevindirici bir haber ya da görüşmeye işaret ediyor.',
                          icon: Icons.blur_circular_rounded,
                          isExpanded: _expandedPhotoIndex == 1,
                          onTap: () {
                            setState(() {
                              _expandedPhotoIndex = _expandedPhotoIndex == 1 ? null : 1;
                            });
                          },
                        ),
                        _ExpandablePhotoItem(
                          file: widget.rightAngle,
                          title: 'Dip',
                          shortDesc: 'Geçmişten kalan konu, yük, kapanmamış mesele.',
                          detailedDesc: 'Geçmişi ve köklerini simgeler. Dipte biriken tortular, arkada bırakman gereken eski bir konuyu gösteriyor.',
                          icon: Icons.fingerprint_rounded,
                          isExpanded: _expandedPhotoIndex == 2,
                          onTap: () {
                            setState(() {
                              _expandedPhotoIndex = _expandedPhotoIndex == 2 ? null : 2;
                            });
                          },
                        ),
                        _ExpandablePhotoItem(
                          file: widget.plateAngle,
                          title: 'Tabak',
                          shortDesc: 'Dilek, sonuç, kısmet, son enerji.',
                          detailedDesc: 'Genel enerji ve niyetindir. Tabağın temizliği, dileğinin umduğundan daha hızlı gerçekleşeceğini fısıldıyor.',
                          icon: Icons.radio_button_unchecked_rounded,
                          isExpanded: _expandedPhotoIndex == 3,
                          onTap: () {
                            setState(() {
                              _expandedPhotoIndex = _expandedPhotoIndex == 3 ? null : 3;
                            });
                          },
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Telvelerin Anlattığı Hikaye (Ana Kart)
                _buildAnimatedResultChild(
                  0.1,
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF140F0C),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFD4A373).withOpacity(0.3), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFD4A373).withOpacity(0.15),
                                  border: Border.all(color: const Color(0xFFD4A373).withOpacity(0.4)),
                                ),
                                child: const Icon(Icons.remove_red_eye_rounded, color: Color(0xFFD4A373), size: 18),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Telvelerin Anlattığı Hikaye',
                                style: GoogleFonts.playfairDisplay(
                                  color: const Color(0xFFE8D5C4),
                                  fontSize: 19,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Fincanında ilk dikkat çeken şey, uzun süredir içinde taşıdığın ama tam olarak kimseye açmadığın bir düşünce. Dışarıdan sakin görünsen de, iç dünyanda bir konuyu tekrar tekrar tartıyorsun. Kenara doğru açılan izler, bu bekleyişin çok uzun sürmeyeceğini söylüyor. Yakın zamanda bir mesaj, konuşma ya da küçük bir gelişme seni rahatlatabilir.',
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 14,
                              height: 1.6,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Falında Görülen Semboller (Premium Grid)
                _buildAnimatedResultChild(
                  0.2,
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _isSymbolsExpanded = !_isSymbolsExpanded;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _isSymbolsExpanded ? const Color(0xFF1C1714) : const Color(0xFF140F0C),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isSymbolsExpanded 
                              ? const Color(0xFFD4A373).withOpacity(0.4) 
                              : const Color(0xFFD4A373).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: _buildPremiumHeader(Icons.auto_awesome, 'Falında Görülen Semboller')),
                              AnimatedRotation(
                                turns: _isSymbolsExpanded ? 0.25 : 0,
                                duration: const Duration(milliseconds: 300),
                                child: Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.3), size: 20),
                              ),
                            ],
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            alignment: Alignment.topCenter,
                            child: _isSymbolsExpanded
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: [
                                        _buildPremiumSymbolChip(Icons.edit_road_rounded, 'Yol', 'Yeni başlangıç'),
                                        _buildPremiumSymbolChip(Icons.flutter_dash_rounded, 'Kuş', 'Haber'),
                                        _buildPremiumSymbolChip(Icons.favorite_rounded, 'Kalp', 'Duygusal konuşma'),
                                        _buildPremiumSymbolChip(Icons.vpn_key_rounded, 'Anahtar', 'Çözüm'),
                                        _buildPremiumSymbolChip(Icons.radio_button_unchecked_rounded, 'Halka', 'Bütünlük'),
                                        _buildPremiumSymbolChip(Icons.access_time_rounded, 'Saat', 'Zaman'),
                                      ],
                                    ),
                                  )
                                : const SizedBox(width: double.infinity, height: 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Aşk Yorumu
                _buildAnimatedResultChild(
                  0.3,
                  _buildSectionCard('Aşk & İlişkiler', 'Duygusal tarafta konuşulmamış bir şey var. Açık bir konuşma olursa rahatlama görünüyor. Bekarsan yeni bir tanışma ya da geçmişten gelen bir iletişim olabilir.'),
                ),
                const SizedBox(height: 16),

                // 5. İş & Para Yorumu
                _buildAnimatedResultChild(
                  0.4,
                  _buildSectionCard('İş & Para', 'İş veya para tarafında küçük ama moral veren bir gelişme görünüyor. Büyük bir sıçrama değil; daha çok haber, teklif, ödeme ya da yeni bir fırsat gibi.'),
                ),
                const SizedBox(height: 16),

                // 6. Aile & Çevre
                _buildAnimatedResultChild(
                  0.5,
                  _buildSectionCard('Aile & Yakın Çevre', 'Yakın çevrenden biriyle yapılacak bir konuşma bazı şeyleri netleştirebilir. Küçük bir yanlış anlaşılma düzelebilir.'),
                ),
                const SizedBox(height: 16),

                // 7. Yakın Gelecek
                _buildAnimatedResultChild(
                  0.6,
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF140F0C),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFD4A373).withOpacity(0.3), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPremiumHeader(Icons.timeline_rounded, 'Yakın Gelecek'),
                        const SizedBox(height: 20),
                        _buildTimelineItem('Çok Yakında', 'Küçük bir haber veya işaret kapıda.'),
                        _buildTimelineItem('3 Vakte Kadar', 'Bir görüşme, mesaj veya netleşme anı.'),
                        _buildTimelineItem('Zamanı Geldiğinde', 'Yeni bir başlangıç ya da karar süreci.', isLast: true),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 8. Dilek Mesajı
                _buildAnimatedResultChild(
                  0.7,
                  _buildSectionCard('Dilek Mesajı', 'Dileğin hemen değil ama adım adım oluyor gibi. Önce küçük bir işaret, sonra daha net bir gelişme görünüyor. Sabırla ilerlersen sonuç daha olumlu olabilir.', icon: Icons.auto_awesome_rounded),
                ),
                const SizedBox(height: 16),

                // 9. Falının Sana Tavsiyesi
                _buildAnimatedResultChild(
                  0.8,
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF140F0C),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFD4A373).withOpacity(0.5), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.stars_rounded, color: Color(0xFFD4A373), size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Falının Sana Tavsiyesi',
                              style: GoogleFonts.outfit(color: const Color(0xFFD4A373), fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Acele karar verme. Önce gelen işaretleri gör, sonra adım at. Şu an en doğru şey sabırlı ama açık olmak.',
                          style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 14, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 10. Alt Butonlar
                _buildAnimatedResultChild(
                  0.9,
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: const Color(0xFFD4A373).withOpacity(0.3)),
                            color: Colors.transparent,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.ios_share_rounded, color: Color(0xFFD4A373), size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Falımı Paylaş',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFFD4A373),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4A373),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.local_cafe_rounded, color: Color(0xFF161311), size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Yeni Fal Bak',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF161311),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                  const SizedBox(height: 40),
              ],
            ),
          ),
        ),

        // 2. Yüzen ve Gradient Geçişli App Bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 24,
              left: 24,
              right: 24,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0C0A09),
                  const Color(0xFF0C0A09).withOpacity(0.95),
                  const Color(0xFF0C0A09).withOpacity(0.8),
                  const Color(0xFF0C0A09).withOpacity(0.0),
                ],
                stops: const [0.3, 0.6, 0.8, 1.0],
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).popUntil((route) => route.isFirst);
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
                Expanded(
                  child: Center(
                    child: Text(
                      'KAHVE FALI',
                      style: GoogleFonts.playfairDisplay(
                        color: const Color(0xFFE8D5C4),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 3.0,
                      ),
                    ),
                  ),
                ),
                // Sağ tarafı dengelemek için kahve ikonu
                const Icon(Icons.local_cafe_rounded, color: Color(0xFFD4A373), size: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- PREMIUM HELPER WIDGETS ---

  Widget _buildPremiumHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFD4A373), size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.outfit(
            color: const Color(0xFFE8D5C4),
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFD4A373).withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        const Icon(Icons.flare_rounded, color: Color(0xFFD4A373), size: 14),
      ],
    );
  }

  Widget _buildSectionCard(String title, String content, {bool highlightTitle = false, IconData? icon}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF140F0C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4A373).withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            _buildPremiumHeader(icon, title),
            const SizedBox(height: 16),
          ] else ...[
            Text(
              title,
              style: GoogleFonts.outfit(
                color: const Color(0xFFE8D5C4),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            content,
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildPremiumSymbolChip(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: const Color(0xFFD4A373).withOpacity(0.2)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFD4A373).withOpacity(0.15),
            const Color(0xFFD4A373).withOpacity(0.02),
          ],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFD4A373), size: 16),
          const SizedBox(width: 8),
          Text(
            '$title — $subtitle',
            style: GoogleFonts.outfit(
              color: const Color(0xFFE8D5C4), 
              fontSize: 13, 
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String time, String desc, {bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFD4A373),
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: const Color(0xFFD4A373).withOpacity(0.3),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(time, style: GoogleFonts.outfit(color: const Color(0xFFE8D5C4), fontSize: 15, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(desc, style: GoogleFonts.inter(color: Colors.white.withOpacity(0.7), fontSize: 13, height: 1.4)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandablePhotoItem extends StatelessWidget {
  final File file;
  final String title;
  final String shortDesc;
  final String detailedDesc;
  final IconData icon;
  final bool isLast;
  final bool isExpanded;
  final VoidCallback onTap;

  const _ExpandablePhotoItem({
    Key? key,
    required this.file,
    required this.title,
    required this.shortDesc,
    required this.detailedDesc,
    required this.icon,
    required this.isExpanded,
    required this.onTap,
    this.isLast = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isExpanded ? const Color(0xFF1C1714) : const Color(0xFF1A1512),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isExpanded 
                ? const Color(0xFFD4A373).withOpacity(0.4) 
                : const Color(0xFFD4A373).withOpacity(0.15),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFD4A373).withOpacity(0.5), width: 1.5),
                    image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFD4A373).withOpacity(0.2)),
                  ),
                  child: Icon(icon, color: const Color(0xFFD4A373).withOpacity(0.7), size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.outfit(color: const Color(0xFFE8D5C4), fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(shortDesc, style: GoogleFonts.inter(color: Colors.white.withOpacity(0.6), fontSize: 12, height: 1.3)),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.3), size: 20),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: isExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 4, left: 4, right: 4),
                      child: Text(
                        detailedDesc,
                        style: GoogleFonts.inter(
                          color: const Color(0xFFD4A373).withOpacity(0.9),
                          fontSize: 13,
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : const SizedBox(width: double.infinity, height: 0),
            ),
          ],
        ),
      ),
    );
  }
}

// Fincanın üzerinden çıkan minimalist "S" şeklinde çizgi duman
class SmokeWispPainter extends CustomPainter {
  final Color color;
  SmokeWispPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width / 2, size.height); // Alt orta
    // Zarif ve pürüzsüz bir 'S' harfi (Küpük Bezier)
    path.cubicTo(
      0, size.height * 0.75, // Sola çek
      size.width, size.height * 0.25, // Sağa çek
      size.width / 2, 0, // Üst orta
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


