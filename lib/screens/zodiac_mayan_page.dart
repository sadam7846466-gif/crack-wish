import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../widgets/glass_back_button.dart';
import '../widgets/swipe_back_wrapper.dart';
import '../services/storage_service.dart';
import '../data/mayan_zodiac_data.dart';
import '../services/analytics_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ZodiacMayanPage extends StatefulWidget {
  const ZodiacMayanPage({super.key});
  @override
  State<ZodiacMayanPage> createState() => _ZodiacMayanPageState();
}

class _ZodiacMayanPageState extends State<ZodiacMayanPage>
    with TickerProviderStateMixin {
  late AnimationController _ctrl;
  late AnimationController _auraCtrl;
  
  DateTime _birthDate = DateTime(1999, 12, 20);
  bool _isDailyEnergyExpanded = false;
  bool _hasOpenedDaily = false;
  int _selectedRuhPanel = 0;
  int _selectedTrecenaDay = 0; // Trecena grafiğinde seçilen gün (0 ile 12 arası)

  // Tek Renk Teması — Antik Altın/Bronz & Obsidyen
  static const Color _goldBright = Color(0xFFB58E58); // Parlak Antik Altın

  static const Color _bg = Color(0xFF080706);         // Zifiri siyah, hafif sıcak toprak
  static const Color _obsidian = Color(0xFF14120F);   // Koyu obsidyen taş
  static const Color _obsidianLight = Color(0xFF1A1815); // Hafif açık gölge
  static const Color _jade = Color(0xFF967345);       // Antik mat altın (eski yeşil yerine)
  static const Color _amber = Color(0xFF6B4E2B);      // Koyu bronz gölge/oksit


  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))..forward();
    _auraCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000))
      ..repeat(reverse: true);
    _loadUser();
    _checkDailyRead();
  }

  Future<void> _checkDailyRead() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    if (mounted) {
      setState(() {
        _hasOpenedDaily = prefs.getBool('mayan_daily_read_$today') ?? false;
      });
    }
  }

  Future<void> _loadUser() async {
    final d = await StorageService.getBirthDate();
    if (d != null && mounted) {
      setState(() {
        _birthDate = d;
      });
      AnalyticsService().logZodiacViewed(sign: 'mayan_${MayanZodiacData.nahuales[_userIdx]['name']}');
    }
  }

  @override
  void dispose() {
    _auraCtrl.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  int get _userIdx => MayanZodiacData.nahualIndex(_birthDate);
  Map<String, dynamic> get _userNahual => MayanZodiacData.nahuales[_userIdx];
  int get _userTone => MayanZodiacData.galacticTone(_birthDate);
  Map<String, String> get _userToneData => MayanZodiacData.galacticTones[_userTone - 1];

  int _getSeed(DateTime date) => date.year * 1000 + date.month * 100 + date.day;

  int _deterministicRandom(int seed, int salt, int min, int max) {
    int hash = (seed + salt) * 2654435761 % 4294967296;
    return min + (hash % (max - min + 1));
  }

  Widget _buildNahualIcon(int index, double size, Color color) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _NahualGlyphPainter(index: index, color: color),
      ),
    );
  }

  Widget _buildAncientCard({Key? key, required Widget child, Color? borderColor, EdgeInsetsGeometry padding = const EdgeInsets.all(20)}) {
    return Container(
      key: key,
      padding: padding,
      decoration: ShapeDecoration(
        color: _obsidian,
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: borderColor ?? Colors.white.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.8),
            offset: const Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    return SwipeBackWrapper(
      child: TickerMode(
        enabled: isCurrent,
        child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
          children: [
            // Zemin: Dev Tzolk'in Takvim Çarkı
            Positioned.fill(
              child: _MayanWheelBackground(jade: _jade, gold: _goldBright, bg: _bg),
            ),
            
            // Ana İçerik - SafeArea ve Header'dan bağımsız tam ekran scroll
            Positioned.fill(
              child: _buildContent(context),
            ),

            // Header kısmı üste sabitlendi, böylece içerik scroll edilirken
            // sert bir şekilde kesilmek yerine header'ın arkasından şeffafça ekran dışına kayacak
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: _buildHeader(),
              ),
            ),
          ],
        ), // Stack
      ), // Scaffold
      ), // TickerMode
    ); // SwipeBackWrapper
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          GlassBackButton(),
          Spacer(),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    // Eski sistemdeki SafeArea ve Header yüksekliği dinamik olarak padding'e aktarıldı
    final topPadding = MediaQuery.of(context).padding.top + 65.0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20, topPadding, 20, MediaQuery.of(context).padding.bottom + 16),
      child: Column(
        children: [
          _buildRuhYoluSection(),
          const SizedBox(height: 56), // Paneller arası nefes alma boşluğu artırıldı
          _buildDailyEnergySection(),
          const SizedBox(height: 56),
          _buildCyclesSection(),
          const SizedBox(height: 56),
          _buildDNASection(),
          const SizedBox(height: 64),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // FEATURE 2: RUH YOLU (LIFE PURPOSE)
  // ══════════════════════════════════════════
  Widget _buildRuhYoluSection() {
    final n = _userNahual;
    return Column(
      children: [
        // İKONU EN YUKARI ALDIK VE DOĞUM TARİHİNİ HEADER'A TAŞIDIK
        SizedBox(
          height: 190,
          child: AnimatedBuilder(
            animation: _auraCtrl,
            builder: (ctx, _) {
              final val = _auraCtrl.value;
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Geometrik hale efektleri
                  Transform.rotate(
                    angle: val * math.pi * 0.5,
                    child: Container(
                      width: 140 + val * 10,
                      height: 140 + val * 10,
                      decoration: ShapeDecoration(
                        shape: BeveledRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                          side: BorderSide(color: _jade.withValues(alpha: 0.1 + val * 0.15), width: 2),
                        ),
                      ),
                    ),
                  ),
                  Transform.rotate(
                    angle: -val * math.pi * 0.5 + math.pi/4,
                    child: Container(
                      width: 120 + val * 8,
                      height: 120 + val * 8,
                      decoration: ShapeDecoration(
                        shape: BeveledRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: _goldBright.withValues(alpha: 0.05 + val * 0.1), width: 1),
                        ),
                      ),
                    ),
                  ),
                  _buildNahualIcon(_userIdx, 100, _jade),
                ],
              );
            },
          ),
        ),
        
        // BAŞLIKLARI DÜZENLE VE TİPOGRAFİYİ GÜZELLEŞTİR
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center, // Baseline kaldırıldı, optik tam ortalama eklendi
          children: [
            Text(
              n['name'].toUpperCase(),
              style: GoogleFonts.cinzel(
                color: Colors.white, 
                fontSize: 36, // Yazıyı hafifçe büyüttük
                fontWeight: FontWeight.w600, 
                letterSpacing: 4,
                shadows: [
                  Shadow(color: Colors.black.withValues(alpha: 0.8), blurRadius: 15), // Arka plandan koparma gölgesi
                ]
              ),
            ),
            const SizedBox(width: 14),
            Container(
              margin: const EdgeInsets.only(top: 2), // Optik olarak metinle tam aynı seviyeye getirdik
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _jade.withValues(alpha: 0.15),
                border: Border.all(color: _jade.withValues(alpha: 0.4)), // Sınırları belirginleştirdik
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 12, spreadRadius: 4), // Kutuyu havaya kaldırdık
                ]
              ),
              child: Text(
                'TON $_userTone',
                style: const TextStyle(color: _jade, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: "${n['meaning'].toUpperCase()}  |  ",
                style: GoogleFonts.cinzel(
                  color: Colors.white.withValues(alpha: 0.9), // IK ile aynı renk ailesi (Burç adı ve Çevirisi)
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3.0,
                  shadows: [
                    Shadow(color: Colors.black.withValues(alpha: 0.9), blurRadius: 10),
                  ]
                ),
              ),
              TextSpan(
                text: n['words'].toUpperCase(),
                style: TextStyle(
                  color: _goldBright, // Mottosu/Simgelediği şey altın sarısı
                  fontSize: 10, 
                  fontWeight: FontWeight.w600, 
                  letterSpacing: 3.0,
                  shadows: [
                    Shadow(color: Colors.black.withValues(alpha: 0.9), blurRadius: 12),
                  ]
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20), // Doğum tarihine biraz nefes alanı
        
        // Doğum Tarihi Kabuğu (Tasarım iyileştirildi)
        GestureDetector(
          onTap: _showDatePicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), // Biraz daha geniş ve rahat
            decoration: ShapeDecoration(
              color: Colors.black.withValues(alpha: 0.6), // Transparan siyah döküm eklendi (Çizgilerin arkadan net görünmesini engeller)
              shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
              ),
              shadows: [
                BoxShadow(color: Colors.black.withValues(alpha: 1.0), blurRadius: 15, spreadRadius: 6), // Derinlik ve okunabilirlik
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit_calendar, color: Colors.white.withValues(alpha: 0.4), size: 12),
                const SizedBox(width: 8),
                Text(
                  '${_birthDate.day}.${_birthDate.month}.${_birthDate.year}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4), 
                    fontSize: 10, 
                    fontWeight: FontWeight.bold, 
                    letterSpacing: 1.5
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        
        // YENİ İNTERAKTİF RUH MÜHRÜ PANELİ (Tek Bir Bütünleşik Panel)
        Builder(
          builder: (context) {
            Color activeColor = _selectedRuhPanel == 0 ? _jade : _selectedRuhPanel == 1 ? _goldBright : _amber;
            return _buildAncientCard(
              padding: EdgeInsets.zero,
              borderColor: activeColor.withValues(alpha: 0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // SEKME (HEADER) KISMI
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      border: Border(bottom: BorderSide(color: activeColor.withValues(alpha: 0.2))),
                    ),
                    child: Row(
                      children: [
                        _buildRuhTab(0, "KADİM BİLGELİK", Icons.auto_awesome, activeColor),
                        Container(width: 1, color: activeColor.withValues(alpha: 0.1)),
                        _buildRuhTab(1, "FREKANS (${_userTone})", Icons.waves, activeColor),
                        Container(width: 1, color: activeColor.withValues(alpha: 0.1)),
                        _buildRuhTab(2, "MİSYON", Icons.local_fire_department_outlined, activeColor),
                      ],
                    ),
                  ),
                  
                  // İÇERİK KISMI
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.05),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Padding(
                      key: ValueKey(_selectedRuhPanel),
                      padding: const EdgeInsets.all(24),
                      child: _buildRuhPanelContentRaw(n),
                    ),
                  ),
                ],
              ),
            );
          }
        ),
      ],
    );
  }

  Widget _buildRuhTab(int index, String title, IconData icon, Color activeColor) {
    bool isSel = _selectedRuhPanel == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_selectedRuhPanel != index) {
            setState(() => _selectedRuhPanel = index);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isSel ? activeColor.withValues(alpha: 0.05) : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: isSel ? activeColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSel ? activeColor : Colors.white.withValues(alpha: 0.3), size: 16),
              const SizedBox(height: 4),
              Text(
                title, 
                style: TextStyle(
                  color: isSel ? activeColor : Colors.white.withValues(alpha: 0.4), 
                  fontSize: 9, 
                  fontWeight: FontWeight.w900, 
                  letterSpacing: 0.5
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRuhPanelContentRaw(Map<String, dynamic> n) {
    if (_selectedRuhPanel == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
               const Icon(Icons.auto_awesome, color: _jade, size: 16),
               const SizedBox(width: 8),
               const Expanded(
                 child: Text('KADİM BİLGELİK', style: TextStyle(color: _jade, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
               ),
            ]
          ),
          const SizedBox(height: 16),
          Text(
            n['description'] as String,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, height: 1.6),
          ),
        ],
      );
    } else if (_selectedRuhPanel == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
               const Icon(Icons.waves, color: _goldBright, size: 16),
               const SizedBox(width: 8),
               Expanded(
                 child: Text('GALAKTİK TON ($_userTone)', style: const TextStyle(color: _goldBright, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
               ),
            ]
          ),
          const SizedBox(height: 16),
          Text(
            _userToneData['desc']!,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, height: 1.6),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
               const Icon(Icons.local_fire_department_outlined, color: _amber, size: 16),
               const SizedBox(width: 8),
               const Expanded(
                 child: Text('HAYATTAKİ ROLÜN', style: TextStyle(color: _amber, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
               ),
            ]
          ),
          const SizedBox(height: 16),
          Text(
            n['role'] as String,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14, height: 1.6, fontStyle: FontStyle.italic),
          ),
        ],
      );
    }
  }

  Widget _buildStoneLabel(String title, String content, IconData icon, {Color? baseColor, Color? borderColor}) {
    Color bColor = baseColor ?? Colors.white.withValues(alpha: 0.7);
    return _buildAncientCard(
      padding: const EdgeInsets.all(16),
      borderColor: borderColor ?? bColor.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: bColor, size: 14),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: TextStyle(color: bColor, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, height: 1.5, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // FEATURE 1 & 6: GÜNLÜK ENERJİ (KUTSAL TZOLK'İN VE GÜNLÜK HİZALANMA)
  // ══════════════════════════════════════════

  // EVRENSEL UYUM MATEMATİĞİ (TÜM GRAFİKLERİ VE KARTLARI EŞİTLER)
  Map<String, int> _calculateDailyScores(DateTime targetDate) {
    int daysSinceEpoch = targetDate.difference(DateTime(1970)).inDays;
    
    // Güç (Genel Kozmik Enerji % - Kişiden bağımsızdır)
    double wave13 = math.sin((daysSinceEpoch % 13) / 13.0 * 2 * math.pi);
    double wave20 = math.cos((daysSinceEpoch % 20) / 20.0 * 2 * math.pi);
    int genEnergy = (((wave13 * 0.5 + wave20 * 0.5) + 1.0) / 2.0 * 80 + 15).clamp(10, 99).toInt();

    // Uyum (Kişisel Rezonans %) 
    int userTone = _userTone;
    int userIdx = _userIdx;
    int seedCode = _birthDate.year * 10000 + _birthDate.month * 100 + _birthDate.day;

    double p13 = math.sin(((daysSinceEpoch + userTone * 3) % 13) / 13.0 * 2 * math.pi); 
    double p20 = math.cos(((daysSinceEpoch + userIdx * 7) % 20) / 20.0 * 2 * math.pi); 
    double pSeed = math.sin(((daysSinceEpoch * 5 + seedCode) % 31) / 31.0 * 2 * math.pi); 
    
    double comb = (p13 * 0.45) + (p20 * 0.35) + (pSeed * 0.20);
    int alignScore = (((comb * -1 + 1.0) / 2.0) * 100).clamp(0, 100).toInt();

    return { 
      'genEnergy': genEnergy, 
      'alignScore': alignScore,
    };
  }

  Widget _buildDailyEnergySection() {
    final now = DateTime.now();
    final todayIdx = MayanZodiacData.nahualIndex(now);
    final todayNahual = MayanZodiacData.nahuales[todayIdx];
    final todayTone = MayanZodiacData.galacticTone(now);
    final todayToneData = MayanZodiacData.galacticTones[todayTone - 1];
    
    final scores = _calculateDailyScores(now);
    int genEnergy = scores['genEnergy']!;
    int alignScore = scores['alignScore']!;

    String toneTitleRaw = todayToneData['title']!.toLowerCase();
    String toneTitleClean = toneTitleRaw.replaceAll(RegExp(r'\s*\(\d+\.\s*ton\)', caseSensitive: false), '').trim();

    String goodFor = _generateGoodFor(todayNahual, alignScore);
    String badFor = _generateBadFor(todayNahual, alignScore);
    String compatibilityText = _generateShortCompatibility(_userNahual, todayNahual, alignScore, genEnergy);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'GÜNÜN KUTSAL TZOLK\'İN ENERJİSİ',
              style: TextStyle(color: _goldBright, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2),
            ),
            const SizedBox(width: 8),
            if (!_hasOpenedDaily)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF22D3EE).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF22D3EE).withOpacity(0.3), width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 4, height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22D3EE),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: const Color(0xFF22D3EE).withOpacity(0.6), blurRadius: 4, spreadRadius: 1)],
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('YENİ', style: TextStyle(color: Color(0xFF22D3EE), fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        _buildAncientCard(
          borderColor: _goldBright.withValues(alpha: 0.3),
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mini Takvim (Tzolk'in Döngüsü)
              _buildTzolkinCalendarStrip(now),
              
              // Üst Kısım - Ana Enerji
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  setState(() {
                    _isDailyEnergyExpanded = !_isDailyEnergyExpanded;
                  });
                  if (_isDailyEnergyExpanded && !_hasOpenedDaily) {
                    final prefs = await SharedPreferences.getInstance();
                    final today = DateTime.now().toIso8601String().split('T')[0];
                    await prefs.setBool('mayan_daily_read_$today', true);
                    await StorageService.setZodiacDoneToday();
                    if (mounted) {
                      setState(() {
                        _hasOpenedDaily = true;
                      });
                    }
                  }
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      decoration: BoxDecoration(
                        color: _goldBright.withValues(alpha: 0.05),
                        border: Border(bottom: BorderSide(color: _goldBright.withValues(alpha: _isDailyEnergyExpanded ? 0.15 : 0.0))),
                      ),
                      child: Row(
                        children: [
                          _buildNahualIcon(todayIdx, 50, _goldBright),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${todayNahual['name'].toUpperCase()} • ${todayNahual['meaning'].toUpperCase()} (TON $todayTone)', style: GoogleFonts.cinzel(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                                const SizedBox(height: 4),
                                Text(
                                  '${todayNahual['words'].toUpperCase()} • ${todayToneData['title']!.split('(').first.trim().toUpperCase()}', 
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 1.0, height: 1.3),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Padding(
                            padding: const EdgeInsets.only(top: 16), // Sadece güç göstergesi kaldı, ok çıkarıldı
                            child: _buildGeomScore(
                              genEnergy, 
                              "GÜÇ", 
                              size: 40, 
                              color: Colors.white.withValues(alpha: 0.95)
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Aşağı doğru açma/kapatma oku tam merkeze alındı
                    Positioned(
                      bottom: 4, 
                      child: AnimatedRotation(
                        turns: _isDailyEnergyExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        child: Icon(Icons.keyboard_arrow_down_rounded, color: _goldBright.withValues(alpha: 0.6), size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Alt Kısım - Yeni Tasarım: Kısa Özet ve Yüksek Görsellik
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity, height: 0),
                secondChild: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // KİŞİSEL REZONANS KUTUSU (Okunabilir Format)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _obsidianLight.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.22), width: 1.0), // Beyazlık bir tık daha belirgin
                          boxShadow: [
                            BoxShadow(color: Colors.white.withValues(alpha: 0.08), blurRadius: 20, spreadRadius: 1), // Işık efekti bir tık artırıldı
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('KİŞİSEL REZONANS', style: TextStyle(color: _goldBright.withValues(alpha: 0.9), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _goldBright.withValues(alpha: 0.15), 
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text('%$alignScore UYUMLU', style: const TextStyle(color: _goldBright, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSummaryRow(Icons.brightness_5, "GÜNÜN ODAĞI", "${todayNahual['name'].toUpperCase()} - ${todayNahual['words']}"),
                            const SizedBox(height: 10),
                            _buildSummaryRow(Icons.fingerprint, "SANA ETKİSİ", compatibilityText),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18), // Biraz yukarı taşındı (Üst boşluk azaltıldı)
                      
                      // YENİ TASARIM: PURE MINIMAL (Saf Tipografi, Sıfır Çizgi)
                      Padding(
                        padding: EdgeInsets.zero, 
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _buildToneVisual(todayTone, color: _goldBright, dotSize: 3.5, barHeight: 2.5, barWidth: 18),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '${todayTone}. TON  •  ',
                                          style: GoogleFonts.cinzel(
                                            color: _goldBright.withValues(alpha: 0.9), 
                                            fontSize: 12, 
                                            fontWeight: FontWeight.bold, 
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        TextSpan(
                                          text: toneTitleClean.toUpperCase(),
                                          style: GoogleFonts.cinzel(
                                            color: Colors.white, 
                                            fontSize: 13, 
                                            fontWeight: FontWeight.bold, 
                                            letterSpacing: 2.0,
                                            shadows: [
                                              Shadow(
                                                color: Colors.white.withValues(alpha: 0.8), // Işıltı (Glow) efekti
                                                blurRadius: 10,
                                              )
                                            ]
                                          ),
                                        ),
                                      ]
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4), // Kendi içindeki başlık ve açıklama arası iyice yakınlaştırıldı
                            Text(
                              todayToneData['desc']!,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8), 
                                fontSize: 13, 
                                height: 1.6, 
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36), // Alttaki interaktif Işık/Gölge kürelerinden uzaklaştırıldı
                      
                      // YEPYENİ İNTERAKTİF IŞIK VE GÖLGE KÜRELERİ (Tıklanabilir Pop-up)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _InteractiveDualEnergyButton(
                            title: 'GÜNÜN IŞIĞI',
                            description: "Günün Işığı, frekansını yükselten ve seni en parlak versiyonuna taşıyan aydınlık yönündür.\n\nBugünün odaklanman gereken\ndestekleyici etkileri:\n\n$goodFor",
                            icon: Icons.wb_sunny_rounded,
                            primaryColor: const Color(0xFFFFEA99), // Daha açık ve göz alıcı parlak kış güneşi/altın tonu
                            isLight: true,
                          ),
                          const SizedBox(width: 32), // İki küre arası daraltıldı
                          _InteractiveDualEnergyButton(
                            title: 'GÜNÜN GÖLGESİ',
                            description: "Evrensel dualite gereği Günün Gölgesi, bilincini esir almak isteyen düşük titreşimli ve gölgeli yönündür.\n\nBugün dikkat etmen ve\nsakınman gereken tuzaklar:\n\n$badFor",
                            icon: Icons.nights_stay_rounded,
                            primaryColor: const Color(0xFF90A4AE), // Moonlight Silver (Ayışığı Gümüş)
                            isLight: false,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                crossFadeState: _isDailyEnergyExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 400),
                firstCurve: Curves.easeOutCubic,
                secondCurve: Curves.easeOutCubic,
                sizeCurve: Curves.easeOutCubic,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2), // Optik dikey hizalama (cap height ile)
          child: Icon(icon, color: _goldBright.withValues(alpha: 0.8), size: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(text: "$title: ", style: TextStyle(color: _goldBright.withValues(alpha: 0.8), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                TextSpan(text: value, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, height: 1.4, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToneVisual(int tone, {Color? color, double dotSize = 8, double barHeight = 6, double barWidth = 32}) {
    int bars = tone ~/ 5;
    int dots = tone % 5;
    Color c = color ?? _jade;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (dots > 0)
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(dots, (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              width: dotSize, height: dotSize,
              decoration: BoxDecoration(
                color: c, 
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: c.withValues(alpha: 0.5), blurRadius: 4, spreadRadius: 0)
                ]
              ),
            )),
          ),
        if (dots > 0 && bars > 0) const SizedBox(height: 6),
        if (bars > 0)
          for (int i = 0; i < bars; i++)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 3),
              width: barWidth, height: barHeight,
              decoration: BoxDecoration(
                color: c, 
                borderRadius: BorderRadius.circular(barHeight / 2),
                boxShadow: [
                  BoxShadow(color: c.withValues(alpha: 0.5), blurRadius: 4, spreadRadius: 0)
                ]
              ),
            ),
      ],
    );
  }

  Widget _buildGeomScore(int val, String label, {double size = 50, Color? color}) {
    Color ringColor = color ?? _goldBright;
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: val / 100,
                color: ringColor,
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                strokeWidth: size * 0.12,
              ),
            ),
            Text(
              '$val',
              style: TextStyle(color: Colors.white, fontSize: size * 0.32, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildTzolkinCalendarStrip(DateTime centerDate) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(bottom: BorderSide(color: _goldBright.withValues(alpha: 0.15))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(5, (index) {
          int offset = index - 2;
          DateTime d = DateTime(centerDate.year, centerDate.month, centerDate.day + offset);
          int nIdx = MayanZodiacData.nahualIndex(d);
          int tone = MayanZodiacData.galacticTone(d);
          
          bool isToday = offset == 0;
          Color itemColor = isToday ? _goldBright : Colors.white.withValues(alpha: 0.3);
          
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isToday ? _goldBright.withValues(alpha: 0.08) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isToday ? Border.all(color: _goldBright.withValues(alpha: 0.3)) : null,
              ),
              child: Column(
                children: [
                   Text(
                    isToday ? "BUGÜN" : "${d.day}/${d.month}",
                    style: TextStyle(
                      color: itemColor,
                      fontSize: 8,
                      fontWeight: isToday ? FontWeight.w900 : FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildNahualIcon(nIdx, isToday ? 28 : 20, itemColor),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.waves, size: 8, color: itemColor),
                      const SizedBox(width: 4),
                      Text(
                        'TON $tone',
                        style: TextStyle(
                          color: itemColor,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ══════════════════════════════════════════
  // FEATURE 3 & 4: DÖNGÜLER (Kader & Dalgalanma)
  // ══════════════════════════════════════════
  Widget _buildCyclesSection() {
    int age = DateTime.now().year - _birthDate.year;
    if (DateTime.now().month < _birthDate.month || (DateTime.now().month == _birthDate.month && DateTime.now().day < _birthDate.day)) {
      age--;
    }
    
    final todayTone = MayanZodiacData.galacticTone(DateTime.now());
    int userTone = MayanZodiacData.galacticTone(_birthDate);

    int activePhase = age < 20 ? 0 : (age < 35 ? 1 : (age < 50 ? 2 : 3));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('KADER DÖNGÜSÜ', style: TextStyle(color: _jade, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2)),
            Icon(Icons.insights, color: _jade.withValues(alpha: 0.5), size: 18),
          ],
        ),
        const SizedBox(height: 6), // Başlık ile panel iyice yakınlaştırıldı
        
        // YAŞAM EĞRİSİ ÇİZELGESİ (Bütünlük için kart içine alındı)
        _buildLifeCurveTimeline(activePhase),
        
        const SizedBox(height: 36),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(
              child: Text('13 GÜNLÜK TRECENA SEYRİ', style: TextStyle(color: _jade, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5), overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                const Icon(Icons.touch_app, color: _jade, size: 12),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _jade.withValues(alpha: 0.15), 
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('KAYDIR', style: TextStyle(color: _jade, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Builder(
          builder: (ctx) {
            List<int> trecenaPoints = [];
            DateTime baseDate = DateTime.now();
            for (int i = 0; i < 13; i++) {
              trecenaPoints.add(_calculateDailyScores(baseDate.add(Duration(days: i)))['alignScore']!);
            }

            return _buildAncientCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 8),
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        RenderBox box = ctx.findRenderObject() as RenderBox;
                        double w = box.size.width;
                        int dayIndex = ((details.localPosition.dx / w) * 12).round().clamp(0, 12);
                        if (dayIndex != _selectedTrecenaDay) {
                          setState(() {
                            _selectedTrecenaDay = dayIndex;
                          });
                        }
                      },
                      onTapDown: (details) {
                        RenderBox box = ctx.findRenderObject() as RenderBox;
                        double w = box.size.width;
                        int dayIndex = ((details.localPosition.dx / w) * 12).round().clamp(0, 12);
                        setState(() {
                          _selectedTrecenaDay = dayIndex;
                        });
                      },
                      child: SizedBox(
                        height: 180,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: _WaveGraphPainter(
                            color: _goldBright,
                            accent: const Color(0xFFFF6D00),
                            userIdx: _userIdx,
                            trecenaAlignScores: trecenaPoints,
                            selectedIndex: _selectedTrecenaDay,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Divider(color: _jade.withValues(alpha: 0.1), height: 1),
                  _buildTrecenaDayDetail(),
                ],
              ),
            );
          }
        ),
      ],
    );
  }

  Widget _buildTrecenaDayDetail() {
    int dayIndex = _selectedTrecenaDay;
    String dayTitle = dayIndex == 0 ? "BUGÜN:" : (dayIndex == 1 ? "YARIN:" : "${dayIndex + 1}. GÜN:");
    
    // KİŞİSELLEŞTİRİLMİŞ (PERSONALIZED) HESAPLAMA
    // Artık evrensel değil, kullanıcının o gün ne yaşayacağına dair öngörü veriyoruz.
    DateTime selectedTargetDate = DateTime.now().add(Duration(days: dayIndex));
    int syncScore = _calculateDailyScores(selectedTargetDate)['alignScore']!;
    
    Map<String, dynamic> userNahual = MayanZodiacData.nahuales[_userIdx];
    String signName = userNahual['name'].toString().split(' ').first; 
    String mainTrait = userNahual['words'].toString().split(',').first.split('&').first.trim().toUpperCase(); 
    
    String actionTitle = "";
    String actionDesc = "";
    int vIdx = 0;

    if (syncScore >= 80) {
      if (syncScore >= 94) {
        vIdx = 2; // Yaratım frekansı (En yüksek)
      } else if (syncScore >= 87) {
        vIdx = 1; // Kozmik Çekim (Orta)
      } else {
        vIdx = 0; // Uyanış (Zirve başlangıcı)
      }
      List<String> titles = ["ZİRVE: $mainTrait UYANIŞI", "ZİRVE: KOZMİK ÇEKİM", "ZİRVE: YARATIM FREKANSI"];
      List<String> descs = [
        "Kozmik hizalanman en üst seviyede. $signName ruhunun taşıdığı potansiyeli cesurca sahneye koymak, yeni atılımlar yapmak ve kilitli kapıları kırmak için harika bir gün. Rüzgar tamamen arkanda.",
        "Rezonans frekansın adeta taşıyor. Evrensel enerjiler o eşsiz $signName doğan ile tam bir ritim yakaladı. Bugün kafana koyduğun her şeyi büyük bir güçle tezahür ettirebilirsin.",
        "Mutlak zirvedesin! $signName enerjin patlamaya hazır. Parlamak için kendini engelleme; atacağın ufak bir adım bile devasa yankılar uyandıracak büyük bir momentum barındırıyor."
      ];
      actionTitle = titles[vIdx];
      actionDesc = descs[vIdx];
    } else if (syncScore >= 55) {
      if (syncScore >= 72) {
        vIdx = 2; // Ritmik Uyum (Zirveye en yakın)
      } else if (syncScore >= 64) {
        vIdx = 1; // Denge ve İlerleme (Orta)
      } else {
        vIdx = 0; // Akış ve Güven (Pozitif başlangıcı)
      }
      List<String> titles = ["POZİTİF: AKIŞ VE GÜVEN", "POZİTİF: DENGE VE İLERLEME", "POZİTİF: RİTMİK UYUM"];
      List<String> descs = [
        "Ritim seninle oldukça uyumlu. Çaba harcamadan pürüzsüz ilerleyecek işlerine odaklan. İçindeki $signName sezgilerine güvenerek, dengeni koruyan eylemler ve iletişimler kurabilirsin.",
        "Tatlı ve destekleyici bir rüzgar esiyor. $signName doğan bu evrensel melodiyle rahatça dans edebilir. Askıda kalan konuları kolayca halledip güvenle yol alabilirsin.",
        "Kozmik akış bugün çok berrak. Senin o tanıdık $signName enerjinle barışık, işbirlikçi ve taptaze bir frekans hakim. Fırsatları değerlendirmek, uyumlanmak için harika bir gün."
      ];
      actionTitle = titles[vIdx];
      actionDesc = descs[vIdx];
    } else if (syncScore >= 35) {
      if (syncScore >= 49) {
        vIdx = 0; // Gözlem ve Hazırlık (Pozitife en yakın, 0. index)
      } else if (syncScore >= 42) {
        vIdx = 1; // Sabır ve Değerlendirme (Orta Nötr, 1. index)
      } else {
        vIdx = 2; // İçsel Toparlanma (Dibe eğilimli Nötr, 2. index)
      }
      List<String> titles = ["NÖTR: GÖZLEM VE HAZIRLIK", "NÖTR: SABIR VE DEĞERLENDİRME", "NÖTR: İÇSEL TOPARLANMA"];
      List<String> descs = [
        "Evrensel dalga yavaşlıyor. Büyük veya riskli adımlar atmaktan ziyade, mevcut durumunu koruman, geçmiş projelerini gözden geçirmen ve sabırla beklemen gereken hazırlık aşaması.",
        "Frekanslar tamamen nötr bölgede seyrediyor. $signName sezgilerini dinlemeye devam et ancak dışarıdaki olayları gereksiz zorlamaktan kaçın. Sadece etrafındaki işaretleri not etme zamanı.",
        "Ne çok hızlı, ne çok yavaş... Bugün eylemden çok mutlak bir dinleme günüdür. Kendi merkezinde sağlam kal ve $signName bilgeliğiyle doğanın dönüşümlerini izle."
      ];
      actionTitle = titles[vIdx];
      actionDesc = descs[vIdx];
    } else {
      if (syncScore >= 24) {
        vIdx = 0; // İçsel Yenilenme (Nötre en yakın, 0. index)
      } else if (syncScore >= 12) {
        vIdx = 1; // Kozmik Dinlenme (Orta Dip, 1. index)
      } else {
        vIdx = 2; // Gölge ve Şifa (En dip, 2. index)
      }
      List<String> titles = ["DİP: İÇSEL YENİLENME", "DİP: KOZMİK DİNLENME", "DİP: GÖLGE VE ŞİFA"];
      List<String> descs = [
        "Enerjin tamamen içe çekiliyor. Çevrendeki evrensel frekanslar bugün $signName doğanla doğrudan çatışabilir. Olayları zorlayıp akıntıya kürek çekmek yerine, inzivaya çekilip ruhsal olarak şarj ol.",
        "Üzerinde yoğun ve uyumsuz bir kozmik basınç var. Bugün dış hedeflerden vazgeçip, iç bahçendeki eski travmaları temizlemek ve gölgelerinle yüzleşmek için adeta altın bir fırsat.",
        "Sürtünme katsayısı oldukça yüksek. $signName ruhunu tamamen koruma altına almalısın; her davete icabet etmeyip, tartışmalardan veya sert başlangıçlardan izole bir sığınak kur."
      ];
      actionTitle = titles[vIdx];
      actionDesc = descs[vIdx];
    }

    // The dynamic biorhythm generation from vIdx mapping provides the perfect, supportive companion description 
    // for Day 0 without breaking the frequency/trecena theme.

    // Splitting the actionTitle ("DİP: FREKANS MOLASI") into premium dual typography
    List<String> titleParts = actionTitle.split(':');
    String titleMain = titleParts[0].trim();
    String titleSub = titleParts.length > 1 ? titleParts[1].trim() : "";

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                     Container(
                       padding: const EdgeInsets.all(6),
                       decoration: BoxDecoration(color: _jade.withValues(alpha: 0.1), shape: BoxShape.circle),
                       child: Icon(Icons.auto_graph_rounded, color: _goldBright, size: 14),
                     ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dayTitle,
                            style: TextStyle(color: _jade.withValues(alpha: 0.8), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                          ),
                          const SizedBox(height: 2),
                          if (titleSub.isNotEmpty)
                            RichText(
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: titleMain,
                                    style: GoogleFonts.cinzel(color: _goldBright, fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: " : ",
                                    style: TextStyle(color: _goldBright.withValues(alpha: 0.5), fontSize: 11),
                                  ),
                                  TextSpan(
                                    text: titleSub,
                                    style: GoogleFonts.cinzel(color: _amber.withValues(alpha: 0.8), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                                  ),
                                ]
                              )
                            )
                          else
                            Text(
                              titleMain,
                              style: GoogleFonts.cinzel(color: _goldBright, fontSize: 14, fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                 decoration: BoxDecoration(
                   color: syncScore > 50 ? _goldBright.withValues(alpha: 0.15) : _amber.withValues(alpha: 0.2),
                   borderRadius: BorderRadius.circular(4),
                 ),
                 child: Text('%$syncScore UYUM', style: TextStyle(color: syncScore > 50 ? _goldBright : _amber, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text(
            actionDesc,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, height: 1.6, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildLifeCurveTimeline(int activePhase) {
    // KULLANICIYA ÖZEL KİŞİSELLEŞTİRME EKLENTİSİ
    Map<String, dynamic> userNahual = MayanZodiacData.nahuales[_userIdx];
    String signName = userNahual['name'].toString().split(' ').first; // Örn: "Timsah"
    
    // Virgülle ayrılmış anahtar kelimeleri al ve temizle
    List<String> keywords = userNahual['words'].toString().split(',').map((e) => e.trim().toLowerCase()).toList();
    if (keywords.isEmpty) keywords = ['enerji', 'güç', 'bilgelik'];
    while (keywords.length < 3) { keywords.add(keywords.first); }

    String word1 = keywords[0]; // Örn: başlangıç
    String word2 = keywords[1]; // Örn: gizem
    String word3 = keywords[2]; // Örn: beslemek
    
    // Anlam metninin ilk kısmını al
    String meaning = userNahual['meaning'].toString().toLowerCase().split(',').first; // Örn: "kolektif bilinç"

    List<Map<String, String>> phases = [
      {
        'age': '0-20', 'short': 'KÖK SALMA', 
        'full': '${signName.toUpperCase()} UYANIŞI', 
        'desc': 'İçindeki eşsiz "$word1" potansiyelinin sessizce filizlendiği yıllar. $signName ruhuyla henüz toprağı tanıdığın, köklerini yaşamın derinliklerine korkusuzca salmaya başladığın mucizevi bir başlangıç.'
      },
      {
        'age': '20-35', 'short': 'YÖN BULMA', 
        'full': '${signName.toUpperCase()} ARAYIŞI', 
        'desc': 'Hayatın kozmik labirentinde kendi pusulanı yarattığın zamanlar... Artık sadece rüzgarı izlemiyor, "$word2" gücünü kuşanarak kaderin dizginlerini kendi ellerine alıyorsun.'
      },
      {
        'age': '35-50', 'short': 'HAKİMİYET', 
        'full': '${signName.toUpperCase()} HAKİMİYETİ', 
        'desc': 'Tüm deneyimlerin artık sarsılmaz bir kale duvarına dönüşüyor. Bu kadim çağında, $meaning hislerinle adeta kendi tahtına oturuyor ve yaşamın en kudretli, en dengeli halini yaşıyorsun.'
      },
      {
        'age': '50+', 'short': 'ÜSTATLIK', 
        'full': '${signName.toUpperCase()} BİLGELİĞİ', 
        'desc': 'Fırtınalar dindi ve nihai menzil aydınlandı. Bugüne dek taşıdığın $signName asaleti ve "$word3" vizyonun, yuvayı aydınlatan ve ardından gelenlere umut olan ruhani bir fener.'
      },
    ];

    List<IconData> phaseIcons = [Icons.spa_rounded, Icons.explore_rounded, Icons.local_fire_department_rounded, Icons.auto_awesome];

    return _buildAncientCard(
      padding: const EdgeInsets.only(top: 24, bottom: 20, left: 8, right: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Evreye Özgü, Mantıklı ve Anlamlı Arka Plan Animasyonu (Kök salma, pusula, güneş, yıldızlar)
          _buildBackgroundPhaseAnimation(activePhase),
          
          Column(
            children: [
              // 1. Eğrilerden oluşan Yaşam Çizgisi Alanı
              SizedBox(
                height: 96, // Aşağıdaki yazıya yakınlaşması için grafik yüksekliği kırpıldı
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Kıvrımlı yol
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _LifeCurvePainter(
                          activePhase: activePhase,
                          activeColor: _goldBright,
                          pastColor: _jade,
                          futureColor: Colors.white.withValues(alpha: 0.1),
                        )
                      ),
                    ),
                    // Düğümler
                    Align(alignment: const Alignment(-0.75, 0.4), child: _buildCurveNode(0, phases[0]['age']!, phases[0]['short']!, activePhase == 0, activePhase > 0, true)),
                    Align(alignment: const Alignment(-0.25, -0.6), child: _buildCurveNode(1, phases[1]['age']!, phases[1]['short']!, activePhase == 1, activePhase > 1, false)),
                    Align(alignment: const Alignment(0.25, 0.2), child: _buildCurveNode(2, phases[2]['age']!, phases[2]['short']!, activePhase == 2, activePhase > 2, true)),
                    Align(alignment: const Alignment(0.75, -0.2), child: _buildCurveNode(3, phases[3]['age']!, phases[3]['short']!, activePhase == 3, activePhase > 3, false)),
                  ],
                ),
              ),
              
              const SizedBox(height: 12), // Kapatılan mesafe ("Şu an buradasın" grafiğe epey yaklaştı)
              
              // 2. Şimdiki Evre Detayı
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                child: Column(
                  key: ValueKey(activePhase),
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _goldBright.withValues(alpha: 0.1),
                        border: Border.all(color: _goldBright.withValues(alpha: 0.3)), 
                        borderRadius: BorderRadius.circular(4)
                      ),
                      child: const Text('ŞU AN BURADASIN', style: TextStyle(color: _goldBright, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      phases[activePhase]['full']!.toUpperCase(),
                      style: GoogleFonts.cinzel(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        phases[activePhase]['desc']!,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 11, height: 1.5, fontStyle: FontStyle.italic, fontWeight: FontWeight.w400),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ]
                )
              )
            ],
          )
        ],
      )
    );
  }

  Widget _buildBackgroundPhaseAnimation(int activePhase) {
    return Positioned(
      right: -25,
      bottom: -15,
      child: AnimatedBuilder(
        animation: _auraCtrl,
        builder: (context, _) {
          double val = _auraCtrl.value; // 0.0 -> 1.0 döngü

          if (activePhase == 0) {
            // 0-20 KÖK SALMA: Özel Çizim Gerçek Bir Organik Fidan Büyümesi
            return SizedBox(
              width: 170,
              height: 170,
              child: CustomPaint(
                painter: _SaplingGrowthPainter(
                  animationValue: val,
                  isReversing: _auraCtrl.status == AnimationStatus.reverse || _auraCtrl.status == AnimationStatus.dismissed,
                  primaryColor: _goldBright.withValues(alpha: 0.16),
                ),
              ),
            );
          } 
          else if (activePhase == 1) {
            // 20-35 YÖN BULMA: Yavaş ve Beşik Gibi Sallanan Dolu Pusula
            // Animator zaten 0.0 -> 1.0 -> 0.0 gidip geliyor, onu -1 ile 1 arasına haritalıyoruz
            double swing = (val - 0.5) * 2.0;
            
            return Transform.rotate(
              angle: swing * (math.pi / 4),
              child: Icon(Icons.explore, size: 160, color: _goldBright.withValues(alpha: 0.14)),
            );
          } 
          else if (activePhase == 2) {
            // 35-50 HAKİMİYET: Özel Tasarım Hareketli Denge Terazisi (Custom Painted)
            // Terazinin kollarının bir aşağı bir yukarı hareket etmesi için özel çizim (Her parça bağımsız hareket eder)
            return SizedBox(
              width: 170,
              height: 170,
              child: CustomPaint(
                painter: _AncientBalanceScalePainter(
                  animationValue: val,
                  primaryColor: _goldBright.withValues(alpha: 0.12),
                ),
              ),
            );
          } 
          else {
            // 50+ ÜSTATLIK: Tek tip, Zarif Yanıp Sönen Yıldızlar
            double star1 = (math.sin(val * math.pi * 4) + 1.0) / 2.0;
            double star2 = (math.sin(val * math.pi * 6 + 2.0) + 1.0) / 2.0;
            
            return SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 20, right: 30,
                    child: Opacity(
                      opacity: 0.15 + (star1 * 0.85),
                      child: Icon(Icons.auto_awesome, size: 80, color: _goldBright.withValues(alpha: 0.16)),
                    )
                  ),
                  Positioned(
                    bottom: 30, right: 90,
                    child: Opacity(
                      opacity: 0.1 + (star2 * 0.9),
                      child: Icon(Icons.auto_awesome, size: 50, color: _goldBright.withValues(alpha: 0.13)),
                    )
                  ),
                ]
              )
            );
          }
        }
      ),
    );
  }

  Widget _buildCurveNode(int i, String age, String short, bool isActive, bool isPast, bool textAbove) {
    Color c = isActive ? _goldBright : (isPast ? _jade : Colors.white.withValues(alpha: 0.2));
    
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
         // Noktanın kendisi
         AnimatedBuilder(
           animation: _auraCtrl,
           builder: (context, _) {
             double pulse = isActive ? (math.sin(_auraCtrl.value * math.pi * 2) + 1.0) / 2.0 : 0.0;
             return Container(
               width: isActive ? 12 : 8,
               height: isActive ? 12 : 8,
               decoration: BoxDecoration(
                 color: isActive ? _bg : (isPast ? _jade : _bg),
                 shape: BoxShape.circle,
                 border: isActive ? Border.all(color: _goldBright, width: 3) : Border.all(color: c, width: 1.5),
                 boxShadow: isActive ? [BoxShadow(color: _goldBright.withValues(alpha: 0.6 + 0.4 * pulse), blurRadius: 10 + 5 * pulse)] : null,
               ),
             );
           }
         ),
         
         // Zıplayan Çizgiyle Çakışmaması İçin Üstte veya Altta Yer Alan Metin
         Positioned(
           top: textAbove ? null : 18,
           bottom: textAbove ? 18 : null,
           child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               if (textAbove && isPast)
                 Padding(
                   padding: const EdgeInsets.only(bottom: 4),
                   child: Row(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       Icon(Icons.check_circle_rounded, color: _jade.withValues(alpha: 0.6), size: 10),
                       const SizedBox(width: 4),
                       Text('TAMAMLANDI', style: TextStyle(color: _jade.withValues(alpha: 0.6), fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                     ],
                   ),
                 ),
               Text(age, style: TextStyle(color: isActive ? _goldBright : (isPast ? Colors.white.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.4)), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
               const SizedBox(height: 2),
               Text(short, style: TextStyle(color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.4), fontSize: 8, fontWeight: FontWeight.w600, letterSpacing: 1.0)),
               if (!textAbove && isPast)
                 Padding(
                   padding: const EdgeInsets.only(top: 4),
                   child: Row(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       Icon(Icons.check_circle_rounded, color: _jade.withValues(alpha: 0.6), size: 10),
                       const SizedBox(width: 4),
                       Text('TAMAMLANDI', style: TextStyle(color: _jade.withValues(alpha: 0.6), fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                     ],
                   ),
                 ),
             ],
           )
         )
      ],
    );
  }

  // ══════════════════════════════════════════
  // FEATURE 5: MAYA ENERJİ DNA'SI
  // ══════════════════════════════════════════
  Widget _buildDNASection() {
    int cIdx = _userIdx; // Merkez Öz
    int tIdx = (cIdx + 13) % 20; // Rehber
    int rIdx = (cIdx + 11) % 20; // Destek
    int lIdx = (cIdx + 9) % 20; // Gölge
    int bIdx = (cIdx + 10) % 20; // Kök/Geçmiş
    
    // Güvenliği garantiye al (modulo eksi dönerse diye)
    tIdx = tIdx < 0 ? tIdx + 20 : tIdx;
    rIdx = rIdx < 0 ? rIdx + 20 : rIdx;
    lIdx = lIdx < 0 ? lIdx + 20 : lIdx;
    bIdx = bIdx < 0 ? bIdx + 20 : bIdx;

    String cName = MayanZodiacData.nahuales[cIdx]['name'].toString().split(' ').first;
    String gKeyword = MayanZodiacData.nahuales[tIdx]['words'].toString().split(',').first.split('&').first.trim().toLowerCase();
    String lKeyword = MayanZodiacData.nahuales[lIdx]['words'].toString().split(',').first.split('&').first.trim().toLowerCase();
    String rPower = MayanZodiacData.nahuales[rIdx]['power'].toString().toLowerCase();
    String bKeyword = MayanZodiacData.nahuales[bIdx]['words'].toString().split(',').first.split('&').first.trim().toLowerCase();
    
    String interpretation = "Ruhunun temelinde büyük bir $cName potansiyeli yatar. Geçmişten getirdiğin $bKeyword doğası seni daima ayakta tutarken, yolunu bulman gerektiğinde $gKeyword frekansı sana bir pusula gibi yön gösterir. Hayattaki asıl mücadelen içsel $lKeyword engellerini aşmaktır. Bu yolda sana bahşedilmiş en büyük doğal yeteneğin ise doğuştan gelen $rPower kudretindir. Bu eşsiz 5 yönlü denge, senin gerçek kozmik haritandır.";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('KOZMİK YAŞAM AĞACI', style: TextStyle(color: _goldBright, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const SizedBox(height: 2),
        Text('Ruhunu şekillendiren 5 kadim yön.', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontStyle: FontStyle.italic)),
        const SizedBox(height: 8),
        
        _buildAncientCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Haç Bağlantı Çizgileri - Animasyonlu ve Belirgin
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _auraCtrl,
                      builder: (context, child) {
                        return CustomPaint(
                           painter: _CrossConnectionPainter(
                             color: _goldBright,
                             animationValue: _auraCtrl.value,
                           )
                        );
                      }
                    )
                  ),
                  
                  // Evrensel Düğümler
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Üst Düğüm (Rehber) - Öncü, duru ve aydınlık bir gümüş/beyaz
                      _buildDnaNode(tIdx, "REHBER", Colors.white.withValues(alpha: 0.9), 40),
                      const SizedBox(height: 24),
                      
                      // Orta Satır (Gölge - Merkez - Destek)
                      Row(
                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                         crossAxisAlignment: CrossAxisAlignment.end,
                         children: [
                            // Gölge - Derin, karanlık ve puslu bir kül grisi
                            _buildDnaNode(lIdx, "GÖLGE", const Color(0xFF9E9E9E), 40),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              // Merkez - Kusursuz parlayan Antik Altın
                              child: _buildDnaNode(cIdx, "MERKEZ", _goldBright, 52, isCenter: true),
                            ),
                            // Destek - Çok yumuşak, soluk bir mat bronz/fildişi rengi
                            _buildDnaNode(rIdx, "DESTEK", const Color(0xFFD4C4A8), 40),
                         ]
                      ),
                      
                      const SizedBox(height: 24),
                      // Alt Düğüm (Geçmiş / Kök) - Kökleri ve toprağı hissettiren derin, kadim bir toprak tonu (Warm Taupe)
                      _buildDnaNode(bIdx, "KÖKLER", const Color(0xFFA1887F), 40),
                    ]
                  )
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Kart içi zarafet ayırıcı çizgi
              Container(
                height: 1,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      _goldBright.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Açıklayıcı Anlam Yorumu (Panelle Çok Karakteristik Bir Yorum Alanı)
              Text(
                interpretation,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11, height: 1.6, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDnaNode(int nIdx, String role, Color color, double size, {bool isCenter = false}) {
     var nahual = MayanZodiacData.nahuales[nIdx];
     String keyword = nahual['words'].toString().split(',').first.split('&').first.trim().toLowerCase();
     return SizedBox(
       width: 80,
       child: Column(
         mainAxisSize: MainAxisSize.min,
         children: [
            Text(role.toUpperCase(), style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: isCenter ? 9 : 8, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            const SizedBox(height: 8),
            _buildNahualIcon(nIdx, size, color),
            const SizedBox(height: 8),
            Text(nahual['name'].toString().toUpperCase(), style: TextStyle(color: color.withValues(alpha: 0.95), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
            const SizedBox(height: 2),
            Text(keyword.toUpperCase(), style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 7, fontWeight: FontWeight.w700, letterSpacing: 1.0), textAlign: TextAlign.center),
         ]
       ),
     );
  }

  // ══════════════════════════════════════════
  // YENİ SEÇENEK: TÜM BURÇLARI KEŞFET (EXPLORE)
  // ══════════════════════════════════════════

  void _showNahualDetails(Map<String, dynamic> n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          decoration: ShapeDecoration(
            color: _obsidian,
            shape: const BeveledRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              side: BorderSide(color: _jade, width: 2),
            ),
          ),
          child: Column(
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildNahualIcon(MayanZodiacData.nahuales.indexOf(n), 80, _jade),
                      const SizedBox(height: 16),
                      Text(n['name'].toUpperCase(), style: GoogleFonts.cinzel(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: 4)),
                      Text(n['meaning'].toUpperCase(), style: TextStyle(color: _jade, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 3)),
                      const SizedBox(height: 32),
                      _buildStoneLabel('ANA TEMA', n['words'], Icons.auto_awesome),
                      const SizedBox(height: 16),
                      _buildStoneLabel('HAYATTAKİ ROL', n['role'], Icons.star_rounded, borderColor: _goldBright.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      _buildStoneLabel('GÜÇLÜ YÖN', n['strength'], Icons.arrow_upward_rounded, baseColor: _jade),
                      const SizedBox(height: 16),
                      _buildStoneLabel('ZAYIF YÖN', n['weakness'], Icons.arrow_downward_rounded, baseColor: _amber),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════
  // DATE PICKER
  // ══════════════════════════════════════════
  void _showDatePicker() {
    int selY = _birthDate.year;
    int selM = _birthDate.month;
    int selD = _birthDate.day;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        height: 320,
        decoration: const BoxDecoration(
          color: _obsidian,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('DOĞUM TARİHİ', style: TextStyle(color: _jade, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  GestureDetector(
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      final newDate = DateTime(selY, selM, selD);
                      setState(() => _birthDate = newDate);
                      await StorageService.setBirthDate(newDate); // Kalıcı olarak kaydet
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: _jade.withValues(alpha: 0.2), border: Border.all(color: _jade)),
                      child: const Text('TAMAM', style: TextStyle(color: _jade, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoTheme(
                data: const CupertinoThemeData(brightness: Brightness.dark),
                child: CupertinoDatePicker(
                  initialDateTime: _birthDate,
                  minimumDate: DateTime(1940),
                  maximumDate: DateTime.now(),
                  mode: CupertinoDatePickerMode.date,
                  onDateTimeChanged: (d) {
                    selY = d.year;
                    selM = d.month;
                    selD = d.day;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════
  // DİNAMİK YORUM ÜRETİCİLERİ
  // ══════════════════════════════════════════
  
  String _generateShortCompatibility(Map<String, dynamic> userNahual, Map<String, dynamic> todayNahual, int alignScore, int genEnergy) {
    // Rastgeleliği gün ve burç ismine bağlayarak kararlı ama her güne/burca özgü farklılık yaratıyoruz.
    final rnd = math.Random(DateTime.now().year * 1000 + DateTime.now().month * 100 + DateTime.now().day + userNahual['name'].hashCode);
    
    final tTheme = todayNahual['words'].toString().split('&').first.trim().toLowerCase();
    final uTrait = (userNahual['traits'] as List).first.toString().toLowerCase();

    List<String> relationships = [
      "Senin o $uTrait doğan, günün $tTheme enerjisiyle doğrudan temasa geçiyor.",
      "Bugün evrenin $tTheme akışı, senin içindeki o eşsiz $uTrait potansiyeli aniden tetikliyor.",
      "Günün $tTheme teması, ruhundaki o çok tanıdık $uTrait enerjin ile derin bir diyalog kuruyor."
    ];
    String relation = relationships[rnd.nextInt(relationships.length)];
    
    // Güç ve Uyum Mantığını Harmanlayarak Kullanıcıya Alt Metinden Öğretme
    List<String> highPowerHighSync = [
      "Bugün evrensel dalga boyu çok yüksek (%$genEnergy GÜÇ) ve sen bu dev dalgayla tam aynı yönde sörf yapıyorsun! Açılan kapılardan korkusuzca geç.",
      "Kozmik ivme bugün adeta zirvede (%$genEnergy GÜÇ) ve tamamen senin arkandan itiyor. Hızlanmak ve risk almak için harika bir fırsat.",
      "Bu güçlü rüzgar (%$genEnergy GÜÇ) senin yelkenlerini tam doğru açıdan dolduruyor. Atılım yapmak için tereddüt etme."
    ];

    List<String> highPowerLowSync = [
      "Evrensel akım bugün oldukça şiddetli (%$genEnergy GÜÇ) ama ne yazık ki sana ters esiyor. İnatlaşıp akıntıya kürek çekersen sadece yorulursun, izlemede kal.",
      "Çevrende çok yoğun ve kırılgan bir enerji dalgası var (%$genEnergy GÜÇ). Bu fırtına sana uymuyor, geri çekilip kendi iç enerjini koru.",
      "Yüksek ve kaotik bir basınç altındayız (%$genEnergy GÜÇ). Ancak bu akış seninle rezonansta değil, olayları zorlamak yerine akışa teslim ol."
    ];

    List<String> lowPowerHighSync = [
      "Kozmik rüzgarlar oldukça sakin (%$genEnergy GÜÇ) ama yelkenlerini tam arkadan dolduruyor. Acele etmeden, huzurun ve eşzamanlılığın tadını çıkar.",
      "Bugün doğada demlenmiş, yumuşak bir ritim var (%$genEnergy GÜÇ) ve sen bu ritimle tam bir dans içindesin. Küçük sürprizleri kucakla.",
      "Sakin ama çok derin bir akıştayız (%$genEnergy GÜÇ). Evrenin sana fısıldadığı sinyalleri yakalamak için zihnini boşalt."
    ];

    List<String> lowPowerLowSync = [
      "Durgun ancak senin doğanla sürtüşmeyi seven, ufak dirençli bir gündeyiz (%$genEnergy GÜÇ). Dış olayları zorlamak yerine, iç dünyana yönelme zamanı.",
      "Kozmik enerji zayıf mırıldanıyor (%$genEnergy GÜÇ) ve üstelik farklı bir dilde. Adım atmaktansa, olanı biteni gözlemleyip eski kararlarını gözden geçir.",
      "Pasif bir enerjinin içindeyiz (%$genEnergy GÜÇ) fakat yine de frekanslar uyuşmuyor. Yavaşla ve yeni bir projeye hiç kalkışmadan dinlen."
    ];

    String mechanic = "";
    if (genEnergy >= 80 && alignScore >= 60) mechanic = highPowerHighSync[rnd.nextInt(highPowerHighSync.length)];
    else if (genEnergy >= 80 && alignScore < 60) mechanic = highPowerLowSync[rnd.nextInt(highPowerLowSync.length)];
    else if (genEnergy < 80 && alignScore >= 60) mechanic = lowPowerHighSync[rnd.nextInt(lowPowerHighSync.length)];
    else mechanic = lowPowerLowSync[rnd.nextInt(lowPowerLowSync.length)];

    return "$relation $mechanic";
  }

  String _generateGoodFor(Map<String, dynamic> todayNahual, int alignScore) {
    final rnd = math.Random(DateTime.now().year * 1000 + DateTime.now().month * 100 + DateTime.now().day + todayNahual['name'].hashCode);
    final words = todayNahual['words'].toString().toLowerCase().split(' & ');
    final w1 = words.first.trim();
    final w2 = words.length > 1 ? words.last.trim() : words.first.trim();
    
    List<String> highGood = [
      "${w1.isNotEmpty ? w1[0].toUpperCase() + w1.substring(1) : ''} niyetlerini somut bir şekilde eyleme dökmek, yaratım projelerini uçurmak",
      "Tüm odağını $w1 alanına kaydırmak, gizli potansiyelini korkusuzca zirveye çıkarmak",
      "Derinlerdeki $w1 arzularını beslemek ve yeni açılan yollara kucak açmak"
    ];
    
    List<String> lowGood = [
      "İç dünyanda $w2 arayışına sessizce girmek, pasif kalarak oluşan desenleri izlemek",
      "Eski yüklerden arınıp tamamen $w2 alanına yönelerek şifa depolamak",
      "Zihni yavaşlatıp $w2 konularında demlenmek ve spiritüel bir dinlenme yaşamak"
    ];
    
    return alignScore >= 60 ? highGood[rnd.nextInt(highGood.length)] : lowGood[rnd.nextInt(lowGood.length)];
  }

  String _generateBadFor(Map<String, dynamic> todayNahual, int alignScore) {
    final rnd = math.Random(DateTime.now().year * 1000 + DateTime.now().month * 100 + DateTime.now().day + todayNahual['name'].hashCode + 1);
    final w1 = todayNahual['words'].toString().toLowerCase().split(' & ').first.trim();
    
    List<String> highBad = [
      "Yok yere şüpheye düşüp $w1 fırsatlarını kaçırmak veya eski travmalara tutunmak",
      "Eylemsiz kalmaya direnmek ve oluşan o devasa $w1 ivmesini tembellikle harcamak",
      "Sabit fikirlilik yüzünden önüne serilen $w1 akışını tamamen bloke etmek"
    ];
    
    List<String> lowBad = [
      "Hiç hazır olmadığın projelere gereksiz yere atılmak, şartları çok zorlamak",
      "Dürtüsel adımlar atıp mantıksız risklere girmek ve yalan $w1 illüzyonlarına inanmak",
      "Akıntıya karşı inatla kürek çekmek ve evrenin 'artık yavaşla' uyarısına isyan etmek"
    ];
    
    return alignScore >= 60 ? highBad[rnd.nextInt(highBad.length)] : lowBad[rnd.nextInt(lowBad.length)];
  }
}

// ══════════════════════════════════════════
// CUSTOM PAINTER: KİŞİSEL BİORİTİM (ENERJİ) GRAFİĞİ
// ══════════════════════════════════════════
class _WaveGraphPainter extends CustomPainter {
  final Color color;
  final Color accent;
  final int userIdx;
  final List<int> trecenaAlignScores;
  final int selectedIndex;
  
  _WaveGraphPainter({
    required this.color, 
    required this.accent, 
    required this.userIdx, 
    required this.trecenaAlignScores,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    
    // Tzolkin Antik Arka Plan Filigranı (Kutsal Geometri / Mystic Watermark)
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.45, Paint()..color = color.withValues(alpha: 0.02)..style = PaintingStyle.stroke..strokeWidth = 20);
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.30, Paint()..color = const Color(0xFF14120F).withValues(alpha: 0.5)..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.30, Paint()..color = color.withValues(alpha: 0.03)..style = PaintingStyle.stroke..strokeWidth = 4);
    
    // Keskin ızgara hatları
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    final targetPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Yatay Referans Çizgileri (Top, Center, Bottom)
    for(int i=1; i<=3; i++) {
      double lineY = h * i / 4;
      canvas.drawLine(Offset(0, lineY), Offset(w, lineY), i == 2 ? targetPaint : gridPaint);
    }
    
    // Dikey Gün Izgarası ve Alt Gün Zarfı (X-Axis)
    for(int i=0; i<13; i++) {
       double lineX = w * i / 12;
       
       if (i == selectedIndex) {
         canvas.drawLine(Offset(lineX, 0), Offset(lineX, h), Paint()..color = color.withValues(alpha: 0.8)..strokeWidth = 1.0);
         canvas.drawLine(Offset(lineX, 0), Offset(lineX, h), Paint()..color = color.withValues(alpha: 0.4)..strokeWidth = 6..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
       } else {
         canvas.drawLine(Offset(lineX, 0), Offset(lineX, h), gridPaint);
       }
       
       // X Ekseninde Günleri Göster
       if (i % 2 == 0 || i == selectedIndex) {
         String dayText = i == 0 ? "BGN" : "+$i";
         final tpBottom = TextPainter(
           text: TextSpan(text: dayText, style: TextStyle(color: Colors.white.withValues(alpha: i == selectedIndex ? 0.7 : 0.2), fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: 1)),
           textDirection: TextDirection.ltr,
         );
         tpBottom.layout();
         tpBottom.paint(canvas, Offset(lineX - tpBottom.width/2, h - 14));
       }
    }

    List<Offset> points = [];
    final fillPath = Path();
    final linePath = Path();

    for(int i = 0; i < 13; i++) {
      // EXACT MATHEMATICAL UNIFICATION:
      // Trecena align score -> 0 to 100.
      double normalizedY = (100 - trecenaAlignScores[i]) / 100.0; 
      
      // Y ekseni: h*0.85 (0% dip) ile h*0.15 (100% tepe)
      double y = h * 0.15 + (normalizedY * h * 0.7);
      
      double x = (i / 12) * w;
      points.add(Offset(x, y));
    }

    // Eğri ve Alt Dolgusu 
    linePath.moveTo(points[0].dx, points[0].dy);
    fillPath.moveTo(points[0].dx, h);
    fillPath.lineTo(points[0].dx, points[0].dy);

    for(int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i+1];
      double ctrlX = (p0.dx + p1.dx) / 2;
      linePath.cubicTo(ctrlX, p0.dy, ctrlX, p1.dy, p1.dx, p1.dy);
      fillPath.cubicTo(ctrlX, p0.dy, ctrlX, p1.dy, p1.dx, p1.dy);
    }
    
    fillPath.lineTo(points.last.dx, h);
    fillPath.close();

    // Dinamik Gradient (Grafikteki renk geçişini okunaklı ve mistik yaptık)
    canvas.drawPath(
      fillPath, 
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [accent.withValues(alpha: 0.45), color.withValues(alpha: 0.1), color.withValues(alpha: 0.0)],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromLTRB(0, 0, w, h))
    );

    // Ana Çizgi Hattı İçin Renk Geçişi (Gradient Stroke)
    final lineGradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [color, accent, color],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTRB(0, 0, w, h))
      ..strokeWidth = 3.0 // Biraz daha kalın
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, lineGradientPaint);

    // Y ekseni etiketleri
    if (points.isNotEmpty) {
      _drawLabelRight(canvas, w, h * 0.15, "MAKS", color.withValues(alpha: 0.7));
      _drawLabelRight(canvas, w, h * 0.85, "MİN", color.withValues(alpha: 0.7));
    }
    
    // Grafik üstündeki statik gün noktalarını belirginleştir ki "kaydırılabilir" hissi yaratsın
    for (int i = 0; i < points.length; i++) {
      if (i != selectedIndex) {
        canvas.drawCircle(points[i], 3, Paint()..color = color.withValues(alpha: 0.15));
        canvas.drawCircle(points[i], 1.5, Paint()..color = const Color(0xFF14120F));
      }
    }

    // Seçilen Günü Dinamik Gösterme (Interactive Highlighter)
    if (points.isNotEmpty && selectedIndex >= 0 && selectedIndex < points.length) {
      final p = points[selectedIndex];
      
      // Dikine Klavuz Çizgisi
      canvas.drawLine(Offset(p.dx, 0), Offset(p.dx, h), Paint()..color = color.withValues(alpha: 0.2)..strokeWidth = 1.5..strokeCap=StrokeCap.round);
      
      // Işıl Işıl İşaret (Marker)
      canvas.drawCircle(p, 8, Paint()..color = color.withValues(alpha: 0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
      canvas.drawCircle(p, 4, Paint()..color = color);
      canvas.drawCircle(p, 2, Paint()..color = const Color(0xFF14120F)); // obsidyen rengi
      
      // Puan Doğrudan Diziden Geliyor! (Matematiksel Uyuşmazlığı Bitirdik)
      int score = trecenaAlignScores[selectedIndex];
      
      String label = selectedIndex == 0 ? "BUGÜN" : "${selectedIndex + 1}. GÜN";
      _drawPoint(canvas, p, "$label\n%$score UYUM", color, w);
    }
  }

  void _drawLabelRight(Canvas canvas, double maxW, double y, String text, Color c) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: c, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(maxW - tp.width - 4, y - tp.height/2));
  }

  void _drawPoint(Canvas canvas, Offset offset, String text, Color c, double w) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, height: 1.3)),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.layout();
    
    // Etiketi her zaman üste çekelim ki grafik tarafından yutulmasın, grafik zaten y=0.15'e kadar çıkıyor.
    // Eğer grafik çok tepedeyse etiket alta kayabilir.
    double dyOffset = offset.dy < 40 ? 12 : -tp.height - 8;
    
    double drawX = offset.dx - tp.width/2;
    if (drawX < 10) drawX = 10;
    if (drawX + tp.width > w - 10) drawX = w - tp.width - 10;

    // Etiket Arka Plan Lekesi Okunabilirliği Artırır
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(drawX - 4, offset.dy + dyOffset - 2, tp.width + 8, tp.height + 4), const Radius.circular(4)), 
      Paint()..color = const Color(0xFF14120F).withValues(alpha: 0.8) // Obsidyen arka plan lekesi
    );
    
    tp.paint(canvas, Offset(drawX, offset.dy + dyOffset));
  }

  @override
  bool shouldRepaint(covariant _WaveGraphPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex || oldDelegate.userIdx != userIdx;
  }
}

// ══════════════════════════════════════════
// CUSTOM PAINTER: NAHUAL GLYPHS (Historical Cartouche Style)
// ══════════════════════════════════════════
class _NahualGlyphPainter extends CustomPainter {
  final int index;
  final Color color;
  
  _NahualGlyphPainter({required this.index, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    
    final paint = Paint()
      ..color = color
      ..strokeWidth = w * 0.05
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 1. Orijinal Maya Çerçevesi (Cartouche)
    final rect = Rect.fromLTRB(w*0.1, h*0.1, w*0.9, h*0.9);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(w*0.25));
    canvas.drawRRect(rrect, paint);
    
    // Alt Kısımdaki 3 Maya "Düğümü" (Cartouche ayakları)
    if (index != 19) {
       canvas.drawCircle(Offset(w*0.3, h*0.95), w*0.04, fillPaint);
       canvas.drawCircle(Offset(w*0.5, h*0.98), w*0.05, fillPaint);
       canvas.drawCircle(Offset(w*0.7, h*0.95), w*0.04, fillPaint);
    }

    final path = Path();
    
    // 2. Orijinal İkonografik İç Çizimler
    switch (index) {
      case 0: // Imix (Nilüfer/Göğüs)
        canvas.drawArc(Rect.fromLTRB(w*0.2, h*0.2, w*0.8, h*0.8), 0, math.pi, true, paint);
        canvas.drawLine(Offset(w*0.2, h*0.5), Offset(w*0.8, h*0.5), paint);
        canvas.drawCircle(Offset(w*0.35, h*0.35), w*0.06, fillPaint);
        canvas.drawCircle(Offset(w*0.65, h*0.35), w*0.06, fillPaint);
        canvas.drawLine(Offset(w*0.3, h*0.5), Offset(w*0.3, h*0.8), paint);
        canvas.drawLine(Offset(w*0.5, h*0.5), Offset(w*0.5, h*0.8), paint);
        canvas.drawLine(Offset(w*0.7, h*0.5), Offset(w*0.7, h*0.8), paint);
        break;
      case 1: // Ik (Rüzgar) - Klasik T
        path.moveTo(w*0.3, h*0.3);
        path.lineTo(w*0.7, h*0.3);
        path.lineTo(w*0.7, h*0.5);
        path.lineTo(w*0.6, h*0.5);
        path.lineTo(w*0.6, h*0.7);
        path.lineTo(w*0.4, h*0.7);
        path.lineTo(w*0.4, h*0.5);
        path.lineTo(w*0.3, h*0.5);
        path.close();
        canvas.drawPath(path, paint);
        break;
      case 2: // Akbal (Gece)
        canvas.drawLine(Offset(w*0.2, h*0.4), Offset(w*0.8, h*0.4), paint);
        canvas.drawCircle(Offset(w*0.35, h*0.25), w*0.05, fillPaint);
        canvas.drawCircle(Offset(w*0.65, h*0.25), w*0.05, fillPaint);
        path.moveTo(w*0.3, h*0.6);
        path.quadraticBezierTo(w*0.5, h*0.8, w*0.7, h*0.6);
        canvas.drawPath(path, paint);
        break;
      case 3: // Kan (Tohum)
        canvas.drawRect(Rect.fromLTRB(w*0.35, h*0.35, w*0.65, h*0.65), paint);
        canvas.drawLine(Offset(w*0.35, h*0.35), Offset(w*0.65, h*0.65), paint);
        canvas.drawLine(Offset(w*0.65, h*0.35), Offset(w*0.35, h*0.65), paint);
        canvas.drawCircle(Offset(w*0.5, h*0.2), w*0.04, fillPaint);
        break;
      case 4: // Chicchan (Yılan Yüzeyi)
        canvas.drawLine(Offset(w*0.25, h*0.25), Offset(w*0.75, h*0.75), paint);
        canvas.drawLine(Offset(w*0.25, h*0.75), Offset(w*0.75, h*0.25), paint);
        canvas.drawCircle(Offset(w*0.3, h*0.5), w*0.04, fillPaint);
        canvas.drawCircle(Offset(w*0.7, h*0.5), w*0.04, fillPaint);
        canvas.drawCircle(Offset(w*0.5, h*0.3), w*0.04, fillPaint);
        canvas.drawCircle(Offset(w*0.5, h*0.7), w*0.04, fillPaint);
        break;
      case 5: // Cimi (Ölüm/Kafatası)
        canvas.drawCircle(Offset(w*0.35, h*0.4), w*0.1, fillPaint); 
        canvas.drawLine(Offset(w*0.4, h*0.7), Offset(w*0.8, h*0.7), paint); 
        canvas.drawLine(Offset(w*0.5, h*0.6), Offset(w*0.5, h*0.8), paint);
        canvas.drawLine(Offset(w*0.6, h*0.6), Offset(w*0.6, h*0.8), paint);
        canvas.drawLine(Offset(w*0.7, h*0.6), Offset(w*0.7, h*0.8), paint);
        break;
      case 6: // Manik (Geyik Eli)
        canvas.drawLine(Offset(w*0.2, h*0.5), Offset(w*0.8, h*0.5), paint); 
        canvas.drawArc(Rect.fromLTRB(w*0.3, h*0.2, w*0.7, h*0.5), math.pi, math.pi, false, paint); 
        canvas.drawLine(Offset(w*0.3, h*0.5), Offset(w*0.3, h*0.35), paint); 
        break;
      case 7: // Lamat (Yıldız)
        canvas.drawCircle(Offset(w*0.5, h*0.5), w*0.3, paint);
        canvas.drawLine(Offset(w*0.2, h*0.5), Offset(w*0.8, h*0.5), paint);
        canvas.drawLine(Offset(w*0.5, h*0.2), Offset(w*0.5, h*0.8), paint);
        canvas.drawCircle(Offset(w*0.35, h*0.35), w*0.04, fillPaint);
        canvas.drawCircle(Offset(w*0.65, h*0.35), w*0.04, fillPaint);
        canvas.drawCircle(Offset(w*0.35, h*0.65), w*0.04, fillPaint);
        canvas.drawCircle(Offset(w*0.65, h*0.65), w*0.04, fillPaint);
        break;
      case 8: // Muluc (Su Çekirdeği)
        canvas.drawCircle(Offset(w*0.5, h*0.5), w*0.15, fillPaint);
        path.moveTo(w*0.5, h*0.15);
        path.arcToPoint(Offset(w*0.15, h*0.5), radius: Radius.circular(w*0.35), clockwise: false);
        path.arcToPoint(Offset(w*0.5, h*0.85), radius: Radius.circular(w*0.35), clockwise: false);
        canvas.drawPath(path, paint);
        break;
      case 9: // Oc (Köpek Kafası)
        path.moveTo(w*0.5, h*0.2); 
        path.lineTo(w*0.3, h*0.5);
        path.lineTo(w*0.4, h*0.6);
        path.lineTo(w*0.3, h*0.8); 
        path.lineTo(w*0.5, h*0.9);
        path.lineTo(w*0.7, h*0.7);
        path.lineTo(w*0.8, h*0.4);
        path.close();
        canvas.drawPath(path, paint);
        canvas.drawCircle(Offset(w*0.6, h*0.5), w*0.06, fillPaint); 
        break;
      case 10: // Chuen (Maymun)
        path.moveTo(w*0.5, h*0.2);
        path.quadraticBezierTo(w*0.2, h*0.5, w*0.5, h*0.8);
        canvas.drawPath(path, paint);
        canvas.drawCircle(Offset(w*0.6, h*0.35), w*0.08, fillPaint); 
        canvas.drawArc(Rect.fromLTRB(w*0.3, h*0.5, w*0.7, h*0.9), 0, math.pi, false, paint); 
        break;
      case 11: // Eb (Yol)
        canvas.drawLine(Offset(w*0.3, h*0.3), Offset(w*0.3, h*0.7), paint);
        canvas.drawLine(Offset(w*0.5, h*0.3), Offset(w*0.5, h*0.7), paint);
        canvas.drawLine(Offset(w*0.7, h*0.3), Offset(w*0.7, h*0.7), paint);
        for(int i=0; i<3; i++) {
           double dy = h*0.35 + i*h*0.15;
           canvas.drawLine(Offset(w*0.3, dy), Offset(w*0.7, dy), paint);
        }
        break;
      case 12: // Ben (Sazlık)
        canvas.drawLine(Offset(w*0.35, h*0.2), Offset(w*0.35, h*0.8), paint);
        canvas.drawLine(Offset(w*0.65, h*0.2), Offset(w*0.65, h*0.8), paint);
        canvas.drawRect(Rect.fromLTRB(w*0.2, h*0.2, w*0.5, h*0.3), paint);
        canvas.drawRect(Rect.fromLTRB(w*0.5, h*0.7, w*0.8, h*0.8), paint);
        break;
      case 13: // Ix (Jaguar Noktaları)
        canvas.drawCircle(Offset(w*0.5, h*0.35), w*0.06, fillPaint);
        canvas.drawCircle(Offset(w*0.35, h*0.6), w*0.06, fillPaint);
        canvas.drawCircle(Offset(w*0.65, h*0.6), w*0.06, fillPaint);
        path.moveTo(w*0.5, h*0.5);
        path.lineTo(w*0.5, h*0.8);
        canvas.drawPath(path, paint);
        break;
      case 14: // Men (Kartal Gagası)
        path.moveTo(w*0.7, h*0.3); 
        path.lineTo(w*0.3, h*0.3); 
        path.lineTo(w*0.5, h*0.6); 
        path.lineTo(w*0.7, h*0.8);
        canvas.drawPath(path, paint);
        canvas.drawCircle(Offset(w*0.6, h*0.4), w*0.05, fillPaint);
        break;
      case 15: // Cib (Baykuş/Salyangoz Spiral)
        path.moveTo(w*0.5, h*0.5);
        for(double t=0; t<=math.pi*2.5; t+=0.1){
           double r = w*0.05 + w*0.035*t;
           path.lineTo(w*0.5 + r*math.cos(t), h*0.5 - r*math.sin(t)); 
        }
        canvas.drawPath(path, paint);
        break;
      case 16: // Caban (Deprem Kancası)
        path.moveTo(w*0.3, h*0.2);
        path.arcToPoint(Offset(w*0.7, h*0.4), radius: Radius.circular(w*0.2));
        path.arcToPoint(Offset(w*0.5, h*0.6), radius: Radius.circular(w*0.2), clockwise: false);
        path.lineTo(w*0.5, h*0.8);
        canvas.drawPath(path, paint);
        canvas.drawCircle(Offset(w*0.3, h*0.8), w*0.04, fillPaint);
        canvas.drawCircle(Offset(w*0.7, h*0.8), w*0.04, fillPaint);
        break;
      case 17: // Etznab (Çakmaktaşı parıltı)
        path.moveTo(w*0.3, h*0.2);
        path.lineTo(w*0.5, h*0.5);
        path.lineTo(w*0.3, h*0.8);
        canvas.drawPath(path, paint);
        final path2 = Path();
        path2.moveTo(w*0.7, h*0.2);
        path2.lineTo(w*0.5, h*0.5);
        path2.lineTo(w*0.7, h*0.8);
        canvas.drawPath(path2, paint);
        break;
      case 18: // Cauac (Fırtına)
        canvas.drawArc(Rect.fromLTRB(w*0.2, h*0.2, w*0.5, h*0.5), math.pi, math.pi, false, paint);
        canvas.drawArc(Rect.fromLTRB(w*0.5, h*0.2, w*0.8, h*0.5), math.pi, math.pi, false, paint);
        canvas.drawLine(Offset(w*0.2, h*0.4), Offset(w*0.8, h*0.4), paint);
        canvas.drawCircle(Offset(w*0.35, h*0.65), w*0.04, fillPaint);
        canvas.drawCircle(Offset(w*0.65, h*0.65), w*0.04, fillPaint);
        break;
      case 19: // Ajaw (Güneş Yüzü)
        canvas.drawCircle(Offset(w*0.35, h*0.4), w*0.06, fillPaint);
        canvas.drawCircle(Offset(w*0.65, h*0.4), w*0.06, fillPaint);
        path.moveTo(w*0.35, h*0.65);
        path.quadraticBezierTo(w*0.5, h*0.5, w*0.65, h*0.65); 
        canvas.drawPath(path, paint);
        canvas.drawCircle(Offset(w*0.5, h*0.75), w*0.04, fillPaint); 
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MayanWheelBackground extends StatelessWidget {
  final Color jade;
  final Color gold;
  final Color bg;

  const _MayanWheelBackground({required this.jade, required this.gold, required this.bg});

  @override
  Widget build(BuildContext context) {
    // İkonun ekrandaki tam merkezini hesapla:
    // SafeArea Top + Header Yüksekliği (yaklaşık 64) + ScrollView Top Padding (5) + İkon Kutusunun Yarısı (190/2 = 95)
    final double safeTop = MediaQuery.of(context).padding.top;
    final double cyOffset = safeTop + 64 + 5 + 95;

    return Stack(
      children: [
        // Ana Zemin
        Container(color: bg),
        
        // Takvim Çarkı (CustomPaint)
        Positioned.fill(
          child: CustomPaint(
            painter: _TzolkinWheelPainter(jade: jade, gold: gold, cyOffset: cyOffset),
          ),
        ),

        // Yazıların okunabilirliğini artırmak için çok keskin bir kararma (Fade) filtresi
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  bg.withValues(alpha: 0.0), // Çark net görünsün
                  bg.withValues(alpha: 0.4), // Daha yumuşak geçiş
                  bg, // En alt zifiri karanlık
                ],
                stops: const [0.3, 0.7, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TzolkinWheelPainter extends CustomPainter {
  final Color jade;
  final Color gold;
  final double cyOffset;

  _TzolkinWheelPainter({required this.jade, required this.gold, required this.cyOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    // Çarkın merkezini tam ikona hizaladık
    final center = Offset(cx, cyOffset);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5; // Çok daha belirgin ve kalın

    // Dış Halka 1 (Dış Takvim Dişlileri - 360 Haab)
    canvas.drawCircle(center, 320, linePaint..color = gold.withValues(alpha: 0.20));
    canvas.drawCircle(center, 305, linePaint..color = jade.withValues(alpha: 0.10));

    final int outerGearCount = 72;
    for (int i = 0; i < outerGearCount; i++) {
        final angle = (i * 2 * math.pi) / outerGearCount;
        final inner1 = Offset(cx + math.cos(angle) * 305, cyOffset + math.sin(angle) * 305);
        final outer1 = Offset(cx + math.cos(angle) * 320, cyOffset + math.sin(angle) * 320);
        canvas.drawLine(inner1, outer1, linePaint..color = gold.withValues(alpha: 0.20));
    }

    // Orta Halka (Tzolk'in - 260 Gün)
    canvas.drawCircle(center, 210, linePaint..color = jade.withValues(alpha: 0.25));
    final int middleGearCount = 20; // 20 Maya Sembolünü temsilen
    for (int i = 0; i < middleGearCount; i++) {
        final angle = (i * 2 * math.pi) / middleGearCount;
        final inner1 = Offset(cx + math.cos(angle) * 195, cyOffset + math.sin(angle) * 195);
        final outer1 = Offset(cx + math.cos(angle) * 210, cyOffset + math.sin(angle) * 210);
        
        // 13 Ton'u temsilen dekoratif noktalar
        canvas.drawCircle(
          Offset(cx + math.cos(angle) * 182, cyOffset + math.sin(angle) * 182), 
          3, // Daha büyük noktalar
          linePaint..style = PaintingStyle.fill..color = jade.withValues(alpha: 0.30)
        );
        
        linePaint.style = PaintingStyle.stroke;
        canvas.drawLine(inner1, outer1, linePaint..color = jade.withValues(alpha: 0.35));
    }
    
    // Merkez Çekirdek (Çemberi genişlettik ki ikonu kesmesin, onu sarsın)
    canvas.drawCircle(center, 135, linePaint..color = gold.withValues(alpha: 0.15));
    for (int i = 0; i < 12; i++) {
        final angle = (i * 2 * math.pi) / 12;
        final inner1 = Offset(cx + math.cos(angle) * 135, cyOffset + math.sin(angle) * 135);
        final outer1 = Offset(cx + math.cos(angle) * 145, cyOffset + math.sin(angle) * 145);
        canvas.drawLine(inner1, outer1, linePaint..color = gold.withValues(alpha: 0.25));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MayanNavIconPainter extends CustomPainter {
  final int index;
  final Color color;

  _MayanNavIconPainter({required this.index, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final w = size.width;
    final h = size.height;

    switch (index) {
      case 0: // Kozmik Öz (Merkez elmas / Maya Gözü)
        final path = Path()
          ..moveTo(cx, 0)
          ..lineTo(w, cy)
          ..lineTo(cx, h)
          ..lineTo(0, cy)
          ..close();
        canvas.drawPath(path, paint);
        canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy), width: 4, height: 4), paint..style = PaintingStyle.fill);
        break;
      case 1: // Bugün (Kadim Güneş / Işık basamakları)
        canvas.drawCircle(Offset(cx, cy), 4, paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;
        canvas.drawLine(Offset(cx, 0), Offset(cx, cy - 6), paint);
        canvas.drawLine(Offset(cx, h), Offset(cx, cy + 6), paint);
        canvas.drawLine(Offset(0, cy), Offset(cx - 6, cy), paint);
        canvas.drawLine(Offset(w, cy), Offset(cx + 6, cy), paint);
        break;
      case 2: // Döngüler (Tzolk'in iç içe halkaları)
        canvas.drawCircle(Offset(cx, cy), 10, paint);
        canvas.drawCircle(Offset(cx, cy), 4, paint);
        canvas.drawLine(Offset(cx, 0), Offset(cx, 2), paint);
        canvas.drawLine(Offset(cx, h), Offset(cx, h - 2), paint);
        canvas.drawLine(Offset(0, cy), Offset(2, cy), paint);
        canvas.drawLine(Offset(w, cy), Offset(w - 2, cy), paint);
        break;
      case 3: // DNA (Geometrik zikzak kökler)
        final path = Path();
        path.moveTo(w * 0.2, 0);
        path.lineTo(w * 0.8, h * 0.33);
        path.lineTo(w * 0.2, h * 0.66);
        path.lineTo(w * 0.8, h);
        
        final path2 = Path();
        path2.moveTo(w * 0.8, 0);
        path2.lineTo(w * 0.2, h * 0.33);
        path2.lineTo(w * 0.8, h * 0.66);
        path2.lineTo(w * 0.2, h);
        
        canvas.drawPath(path, paint);
        canvas.drawPath(path2, paint);
        break;
      case 4: // Keşfet (Harita / Yön Okları)
        paint.style = PaintingStyle.stroke;
        canvas.drawRect(Rect.fromLTRB(2, 2, w-2, h-2), paint);
        canvas.drawLine(Offset(w * 0.3, 2), Offset(w * 0.3, h - 2), paint);
        canvas.drawLine(Offset(w * 0.7, 2), Offset(w * 0.7, h - 2), paint);
        canvas.drawRect(Rect.fromCenter(center: Offset(w*0.3, h*0.4), width: 3, height: 3), paint..style=PaintingStyle.fill);
        canvas.drawRect(Rect.fromCenter(center: Offset(w*0.7, h*0.7), width: 3, height: 3), paint..style=PaintingStyle.fill);
        canvas.drawLine(Offset(w*0.3, h*0.4), Offset(w*0.7, h*0.7), paint..style=PaintingStyle.stroke);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// YEPYENİ İNTERAKTİF IŞIK VE GÖLGE BUTONLARI (Pop-up Widget)
class _InteractiveDualEnergyButton extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final bool isLight;

  const _InteractiveDualEnergyButton({
    required this.title,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.isLight,
  });

  void _showEnergyDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "EnergyPopup",
      barrierColor: Colors.black.withValues(alpha: 0.85), // Karanlık transparan odak
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF141210).withValues(alpha: 0.95), // Obsidian Glass
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: primaryColor.withValues(alpha: 0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(color: primaryColor.withValues(alpha: 0.15), blurRadius: 40, spreadRadius: 0),
                  BoxShadow(color: Colors.black.withValues(alpha: 0.8), blurRadius: 20, spreadRadius: 10),
                ]
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor.withValues(alpha: 0.1),
                      border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                      boxShadow: [
                        BoxShadow(color: primaryColor.withValues(alpha: 0.2), blurRadius: 20)
                      ]
                    ),
                    child: Icon(icon, color: primaryColor, size: 48),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: GoogleFonts.cinzel(color: primaryColor, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(width: 40, height: 1, color: primaryColor.withValues(alpha: 0.5)),
                  const SizedBox(height: 20),
                  Text(
                    description,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14, height: 1.6, fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                      child: const Text('KAPAT', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: 0.9 + 0.1 * anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showEnergyDialog(context),
      child: Column(
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isLight ? primaryColor.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.4),
              border: Border.all(color: primaryColor.withValues(alpha: 0.3), width: 1.5),
              boxShadow: [
                BoxShadow(color: isLight ? primaryColor.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.6), blurRadius: 15, spreadRadius: 2),
                if (!isLight) BoxShadow(color: primaryColor.withValues(alpha: 0.15), blurRadius: 8), // Gölgeye ekstra ay ışığı pırıltısı
              ]
            ),
            child: Icon(icon, color: primaryColor, size: 30),
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: primaryColor.withValues(alpha: 0.9), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        ],
      ),
    );
  }
}

class _LifeCurvePainter extends CustomPainter {
  final int activePhase;
  final Color activeColor;
  final Color pastColor;
  final Color futureColor;

  _LifeCurvePainter({required this.activePhase, required this.activeColor, required this.pastColor, required this.futureColor});

  @override
  void paint(Canvas canvas, Size size) {
    List<Offset> points = [
      Offset(size.width * 0.125, size.height * 0.7), // 0-20 (Aşağıda - Kök salma)
      Offset(size.width * 0.375, size.height * 0.2), // 20-35 (Yukarıda - Mücadele zirvesi)
      Offset(size.width * 0.625, size.height * 0.6), // 35-50 (Denge - Hakimiyet)
      Offset(size.width * 0.875, size.height * 0.4), // 50+ (Yukarıda - Ruhani rehberlik)
    ];

    Path path = Path();
    path.moveTo(0, size.height * 0.7); 
    
    // Noktalar arası muazzam pürüzsüz Bezier eğrileri
    path.cubicTo(size.width * 0.05, size.height * 0.7, size.width * 0.05, points[0].dy, points[0].dx, points[0].dy);
    
    path.cubicTo(
       points[0].dx + size.width * 0.1, points[0].dy,
       points[1].dx - size.width * 0.1, points[1].dy,
       points[1].dx, points[1].dy
    );
    path.cubicTo(
       points[1].dx + size.width * 0.1, points[1].dy,
       points[2].dx - size.width * 0.1, points[2].dy,
       points[2].dx, points[2].dy
    );
    path.cubicTo(
       points[2].dx + size.width * 0.1, points[2].dy,
       points[3].dx - size.width * 0.1, points[3].dy,
       points[3].dx, points[3].dy
    );
    
    path.cubicTo(size.width * 0.95, points[3].dy, size.width * 0.95, size.height * 0.4, size.width, size.height * 0.4);

    // Büyülü Degrade (Gradient) Tanımı - Gelecekte ulaşılan sıcak noktaları hissettirir
    Rect rect = Rect.fromLTRB(0, 0, size.width, size.height);
    Shader gradientShader = LinearGradient(
      colors: [
        pastColor,                // Kök Salmanın rengi (bilgelik, yeşilimsi mistik)
        activeColor,              // Ortalar parlak altın
        const Color(0xFFFF6D00),  // İleri yaşlar sıcak ateş, derin keşif
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(rect);

    // 1. Zemin Yolu (Gelecek - Karartılmış ince çizgi)
    Paint basePaint = Paint()
      ..color = futureColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, basePaint);

    // 2. Aktif Yolu Çiz (Sadece bulunduğumuz evreye kadar olan kısım parlar)
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, points[activePhase].dx, size.height));
    
    Paint activePaint = Paint()
      ..shader = gradientShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawPath(path, activePaint);
    
    // Işık Halesi
    Paint glowPaint = Paint()
      ..shader = gradientShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawPath(path, glowPaint);
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _AncientBalanceScalePainter extends CustomPainter {
  final double animationValue;
  final Color primaryColor;

  _AncientBalanceScalePainter({required this.animationValue, required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double beamLength = size.width * 0.75;
    
    // Animasyon zaten geriye sararak baştan başlıyor (0.0 -> 1.0 -> 0.0). 
    // Bu yüzden direkt -1.0 ile 1.0 arasına eşleştirip takılmaları/sıçramaları tamamen onarıyoruz.
    final double tilt = (animationValue - 0.5) * 2.0 * (math.pi / 24); 
    
    // 1. Direk Tabanı (Mayan Basamaklı Piramit Formu)
    canvas.drawRect(Rect.fromCenter(center: Offset(centerX, centerY + 56), width: 66, height: 6), paint..style = PaintingStyle.fill);
    canvas.drawRect(Rect.fromCenter(center: Offset(centerX, centerY + 50), width: 48, height: 6), paint);
    canvas.drawRect(Rect.fromCenter(center: Offset(centerX, centerY + 44), width: 30, height: 6), paint);

    // 2. Ana Direk
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3.5;
    canvas.drawLine(Offset(centerX, centerY - 40), Offset(centerX, centerY + 41), paint); // Kalın Taşıyıcı
    // İnce oyma detay (Ortadaki çizgi)
    canvas.drawLine(Offset(centerX, centerY - 25), Offset(centerX, centerY + 30), paint..strokeWidth = 1.0);

    // 3. Hareketli Kol (Beam)
    paint.strokeWidth = 3.0;
    canvas.save();
    canvas.translate(centerX, centerY - 45); // Pivot noktasından döndür
    canvas.rotate(tilt);
    
    // Ana U-Kirişi
    canvas.drawLine(Offset(-beamLength / 2, 0), Offset(beamLength / 2, 0), paint);
    
    // Alt dekoratif kuş kanadı kavis formu (Süsleme)
    Path beamWing = Path();
    beamWing.moveTo(-beamLength / 2 + 12, 0);
    beamWing.quadraticBezierTo(0, 16, beamLength / 2 - 12, 0);
    canvas.drawPath(beamWing, paint..strokeWidth = 1.5);

    // Kefe bağlantı halkaları
    canvas.drawCircle(Offset(-beamLength / 2, 0), 4, paint..style = PaintingStyle.stroke..strokeWidth = 2);
    canvas.drawCircle(Offset(beamLength / 2, 0), 4, paint);

    // Merkez Pivot Gözü (Güneş arması)
    canvas.drawCircle(const Offset(0, 0), 8, paint..strokeWidth = 2);
    canvas.drawCircle(const Offset(0, 0), 3, paint..style = PaintingStyle.fill);
    canvas.restore();

    // 4. Kefeler
    // Matematiksel zıt sapma (Sol ve Sağ uçların mutlak koordinatları)
    final double end1X = centerX - math.cos(tilt) * (beamLength / 2);
    final double end1Y = (centerY - 45) - math.sin(tilt) * (beamLength / 2); // Sol kefe Y (Yukarı/Aşağı)
    
    final double end2X = centerX + math.cos(tilt) * (beamLength / 2);
    final double end2Y = (centerY - 45) + math.sin(tilt) * (beamLength / 2); // Sağ kefe Y (Ters yönde)

    _drawPlate(canvas, Offset(end1X, end1Y), paint, true);
    _drawPlate(canvas, Offset(end2X, end2Y), paint, false);
  }

  void _drawPlate(Canvas canvas, Offset hookPoint, Paint paint, bool isLeft) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.2;
    
    // Asma ipleri (V yapısı)
    Path cord = Path();
    cord.moveTo(hookPoint.dx, hookPoint.dy + 4);
    cord.lineTo(hookPoint.dx - 24, hookPoint.dy + 42); // Sola açılır
    cord.moveTo(hookPoint.dx, hookPoint.dy + 4);
    cord.lineTo(hookPoint.dx + 24, hookPoint.dy + 42); // Sağa açılır
    canvas.drawPath(cord, paint);
    
    // Derin Kase (Bowl)
    paint.strokeWidth = 2.5;
    Path plate = Path();
    plate.moveTo(hookPoint.dx - 28, hookPoint.dy + 42);
    plate.quadraticBezierTo(hookPoint.dx, hookPoint.dy + 65, hookPoint.dx + 28, hookPoint.dy + 42);
    canvas.drawPath(plate, paint);

    // Kasenin içindeki mistik ağırlık (Aura / Kozmik Yük)
    Paint glowPaint = Paint()
      ..color = primaryColor.withValues(alpha: primaryColor.a * 0.8)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5); // Güçlü parıltı
      
    // İçteki cevher
    canvas.drawCircle(Offset(hookPoint.dx, hookPoint.dy + 48), isLeft ? 6 : 8, glowPaint);
    canvas.drawCircle(Offset(hookPoint.dx, hookPoint.dy + 48), 2, paint..style = PaintingStyle.fill); // Katı merkez
  }

  @override
  bool shouldRepaint(covariant _AncientBalanceScalePainter oldDelegate) => true;
}

class _SaplingGrowthPainter extends CustomPainter {
  final double animationValue;
  final bool isReversing;
  final Color primaryColor;

  _SaplingGrowthPainter({required this.animationValue, required this.isReversing, required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Küçülürken 'hemen kaybolma' hissini silmek için matematiksel bir "Asimetrik Zaman Eğrisi" ekliyoruz:
    // Büyürken lineer (doğal hızda) çıkar, ancak Geri çekilirken (Shrinking) tepede olabildiğince 
    // uzun süre (Hang time) asılı kalmasını sağlayan easeOutCubic uyguluyoruz.
    double curvedVal = isReversing 
        ? Curves.easeOutQuart.transform(animationValue) // Geri çekilirken tepe noktasında inanılmaz asılı kalır
        : animationValue; // Büyürken doğal ve pürüzsüz hızında çıkar

    // Başlangıç boyu %20, tepe noktası %100 olacak şekilde çarpan:
    double growth = 0.2 + (0.8 * curvedVal); 

    final Paint stemPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final Paint leafPaint = Paint()
      ..color = primaryColor.withValues(alpha: primaryColor.a * 0.7)
      ..style = PaintingStyle.fill;

    // Koordinat düzlemini altın merkeze (Toprak Hizasını Temsilen) taşı
    canvas.save();
    canvas.translate(size.width / 2, size.height);

    // 1. Ana Gövde Dizinimi (S-Kıvrımlı Büyüme)
    double endY = -110 * growth; // "boyunu bir tık azalt" talebi üzerine 140'tan 110'a kırpıldı
    Path stem = Path();
    stem.moveTo(0, 0);
    // Zarif bir şekilde S çizerek (Cubic Curve) boy atar
    stem.cubicTo(
      15 * growth, endY * 0.3,   // Gövdenin sağa yatışı
      -25 * growth, endY * 0.7,  // Gövdenin sola kıvrılışı
      10 * growth, endY          // En tepe filiz noktası
    );
    canvas.drawPath(stem, stemPaint);

    // 2. Filizlenen Yapraklar (Boy Uzadıkça Sırayla Çıkarlar)
    // Gövdenin büyüklüğüne göre kendi eşik (threshold) değerleri vardır.

    // En Erken Çıkan Sağ Alt Yaprak
    _drawLeaf(canvas, 8 * growth, endY * 0.35, 45 * growth, endY * 0.20, stemPaint, leafPaint, growth, 0.4);
    
    // Ortadan Sıyırılan Sol Yaprak
    _drawLeaf(canvas, -13 * growth, endY * 0.70, -55 * growth, endY * 0.55, stemPaint, leafPaint, growth, 0.6);
    
    // Taç Filiz Yaprağı (Zirvede en son beliren)
    _drawLeaf(canvas, 10 * growth, endY, -20 * growth, endY - 40 * growth, stemPaint, leafPaint, growth, 0.8);

    canvas.restore();
  }

  void _drawLeaf(Canvas canvas, double rootX, double rootY, double tipX, double tipY, Paint stemPaint, Paint leafPaint, double globalGrowth, double threshold) {
    if (globalGrowth < threshold) return; // Henüz boyu ulaşmadıysa filizlenme!
    
    // Yaprağın sırf kendisine ait büyüme skalası (0.0 -> 1.0)
    double leafGrowth = (globalGrowth - threshold) / (1.0 - threshold);
    
    double curTipX = rootX + (tipX - rootX) * leafGrowth;
    double curTipY = rootY + (tipY - rootY) * leafGrowth;
    
    // Yaprağın dibindeki bağlantı çeltiği
    canvas.drawLine(
      Offset(rootX, rootY), 
      Offset(rootX + (curTipX - rootX)*0.2, rootY + (curTipY - rootY)*0.2), 
      stemPaint..strokeWidth = 2
    );

    // Organik kıvrımlı ince sivri maya yaprağı
    Path leaf = Path();
    leaf.moveTo(rootX, rootY);
    
    // Bombeyi veren kontrol noktaları
    double ctrl1X = rootX + (curTipX - rootX) * 0.2;
    double ctrl1Y = curTipY;
    
    double ctrl2X = curTipX;
    double ctrl2Y = rootY + (curTipY - rootY) * 0.2;

    leaf.quadraticBezierTo(ctrl1X, ctrl1Y, curTipX, curTipY); // Dış kavis
    leaf.quadraticBezierTo(ctrl2X, ctrl2Y, rootX, rootY);     // İç kavis dönüş
    
    canvas.drawPath(leaf, leafPaint);
  }

  @override
  bool shouldRepaint(covariant _SaplingGrowthPainter oldDelegate) => true;
}

// ══════════════════════════════════════════
// CROSS CONNECTION PAINTER (Kadim Haç Çizgileri)
// ══════════════════════════════════════════
class _CrossConnectionPainter extends CustomPainter {
  final Color color;
  final double animationValue;

  _CrossConnectionPainter({required this.color, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // Animasyon sürekli merkezden uçlara akması için zaman bazlı lineer bir progress oluşturuyoruz
    // Süzülme hızını 1.5 saniyeden 3.0 saniyeye çıkararak çok daha yavaş, ağırbaşlı bir hale getirdik
    double progress = (DateTime.now().millisecondsSinceEpoch % 3000) / 3000.0;

    // 1. Ana Kılavuz Çizgiler (Soluk Zemin)
    Paint basePaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // 2. Işık Süzmesi - Dev Parıltı Halesi
    Paint beamGlow = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..strokeWidth = 6.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8) // Aşırı parlak bir aura
      ..style = PaintingStyle.stroke;
      
    // 3. Işık Süzmesi - Katı İç Işık Çekirdeği
    Paint beamCore = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    double cx = size.width / 2;
    double cy = size.height / 2;
    
    // Işın Çizici Yardımcı (Merkezden -> YAN UÇLARA)
    // Sadece yatay çizgiler için o eski keskin stil korunuyor "yanlara kesinlikle dokunma"
    void drawHorizontalBeam(Offset pStart, Offset pEnd) {
      canvas.drawLine(pStart, pEnd, basePaint);
      double length = (pEnd - pStart).distance;
      if (length <= 0) return;

      double head = 1.0 - (1.0 - progress) * (1.0 - progress);
      double tail = progress * progress * progress;
      if (head > 0 && tail < 1) {
         Offset pTail = Offset.lerp(pStart, pEnd, tail)!;
         Offset pHead = Offset.lerp(pStart, pEnd, head)!;
         canvas.drawLine(pTail, pHead, beamGlow);
         canvas.drawLine(pTail, pHead, beamCore);
      }
    }

    // ALT VE ÜST İÇİN SİLİNİKLEŞEN (FADING) IŞIN ÇİZİCİ
    // Baş ve son noktalara (merkez yazısı ve kenar yazıları) yaklaştıkça görünmez olup sanki "yazının altından akıyormuş" hissi yaratır.
    void drawVerticalBeam(Offset pStart, Offset pEnd) {
      final rect = Rect.fromPoints(pStart, pEnd);
      // Uçlara yaklaştıkça %40 oranında (hem merkezde hem de dış kenarlarda) tamamen silinikleşir
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, color.withValues(alpha: 0.1), color.withValues(alpha: 0.1), Colors.transparent],
        stops: const [0.0, 0.40, 0.60, 1.0],
      ).createShader(rect);

      final glowGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, color.withValues(alpha: 0.9), color.withValues(alpha: 0.9), Colors.transparent],
        stops: const [0.0, 0.40, 0.60, 1.0],
      ).createShader(rect);

      final coreGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, Colors.white.withValues(alpha: 0.8), Colors.white.withValues(alpha: 0.8), Colors.transparent],
        stops: const [0.0, 0.40, 0.60, 1.0],
      ).createShader(rect);

      Paint vBase = Paint()..strokeWidth = 1.0..style = PaintingStyle.stroke..shader = gradient;
      Paint vGlow = Paint()..strokeWidth = 6.0..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)..style = PaintingStyle.stroke..shader = glowGradient;
      Paint vCore = Paint()..strokeWidth = 2.0..style = PaintingStyle.stroke..shader = coreGradient;

      canvas.drawLine(pStart, pEnd, vBase);
      double length = (pEnd - pStart).distance;
      if (length <= 0) return;

      double head = 1.0 - (1.0 - progress) * (1.0 - progress);
      double tail = progress * progress * progress;
      if (head > 0 && tail < 1) {
         Offset pTail = Offset.lerp(pStart, pEnd, tail)!;
         Offset pHead = Offset.lerp(pStart, pEnd, head)!;
         canvas.drawLine(pTail, pHead, vGlow);
         canvas.drawLine(pTail, pHead, vCore);
      }
    }

    // Uç Koordinatları düğümlere çarpmayacak şekilde ayarlıyoruz
    double centerY = cy - 20;

    // Yatay Bağlantılar (Yanlara daha fazla gitmesi için 70'ten 48'e kadar uzatıldı) - Kesinlikle dokunulmadı
    drawHorizontalBeam(Offset(cx - 35, centerY), Offset(48, centerY));
    drawHorizontalBeam(Offset(cx + 35, centerY), Offset(size.width - 48, centerY));
    
    // Dikey Bağlantılar (Gereksiz uzunluğu kısalttık, ikonlara ulaşmadan sadece yazının gölgesinde erimesini sağladık)
    drawVerticalBeam(Offset(cx, centerY - 25), Offset(cx, 75)); // Yukarı (Rehber)
    drawVerticalBeam(Offset(cx, centerY + 25), Offset(cx, size.height - 80)); // Aşağı (Kökler)
  }

  @override
  bool shouldRepaint(covariant _CrossConnectionPainter oldDelegate) => true; // Sürekli akış için daima yenile
}
