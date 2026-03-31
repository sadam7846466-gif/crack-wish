import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../widgets/glass_back_button.dart';
import '../services/storage_service.dart';
import '../data/mayan_zodiac_data.dart';
import 'package:flutter/cupertino.dart';

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
  int _selectedRuhPanel = 0;

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
  }

  Future<void> _loadUser() async {
    final d = await StorageService.getBirthDate();
    if (d != null && mounted) {
      setState(() {
        _birthDate = d;
      });
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
    return Scaffold(
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
      ),
    );
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
      padding: EdgeInsets.fromLTRB(20, topPadding, 20, 40),
      child: Column(
        children: [
          _buildRuhYoluSection(),
          const SizedBox(height: 32),
          _buildDailyEnergySection(),
          const SizedBox(height: 32),
          _buildCyclesSection(),
          const SizedBox(height: 32),
          _buildDNASection(),
          const SizedBox(height: 40),
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
        Text(
          n['words'].toUpperCase(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7), // Biraz daha belirgin yaptık
            fontSize: 11, 
            fontWeight: FontWeight.w600, 
            letterSpacing: 4.0,
            shadows: [
              Shadow(color: Colors.black.withValues(alpha: 0.9), blurRadius: 12), // Çizgiler altına girmesin diye sert gölge
            ]
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 18), // Boşluğu artırdık
        
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
        
        // YENİ İNTERAKTİF RUH MÜHRÜ PANELİ
        Container(
          height: 64,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _obsidianLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _goldBright.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              _buildRuhTab(0, "KADİM BİLGELİK", Icons.auto_awesome),
              _buildRuhTab(1, "FREKANS (${_userTone})", Icons.waves),
              _buildRuhTab(2, "MİSYON", Icons.local_fire_department_outlined),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // İÇERİK ANİMASYONU
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
          child: _buildRuhPanelContent(n),
        ),
      ],
    );
  }

  Widget _buildRuhTab(int index, String title, IconData icon) {
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
            color: isSel ? _goldBright.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSel ? _goldBright.withValues(alpha: 0.3) : Colors.transparent),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSel ? _goldBright : Colors.white.withValues(alpha: 0.3), size: 16),
              const SizedBox(height: 4),
              Text(
                title, 
                style: TextStyle(
                  color: isSel ? _goldBright : Colors.white.withValues(alpha: 0.4), 
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

  Widget _buildRuhPanelContent(Map<String, dynamic> n) {
    if (_selectedRuhPanel == 0) {
      return _buildAncientCard(
        key: const ValueKey(0),
        padding: const EdgeInsets.all(24),
        borderColor: _jade.withValues(alpha: 0.3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                 const Icon(Icons.auto_awesome, color: _jade, size: 16),
                 const SizedBox(width: 8),
                 Expanded(
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
        ),
      );
    } else if (_selectedRuhPanel == 1) {
      return _buildAncientCard(
        key: const ValueKey(1),
        padding: const EdgeInsets.all(24),
        borderColor: _goldBright.withValues(alpha: 0.3),
        child: Column(
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
        ),
      );
    } else {
      return _buildAncientCard(
        key: const ValueKey(2),
        padding: const EdgeInsets.all(24),
        borderColor: _amber.withValues(alpha: 0.3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                 const Icon(Icons.local_fire_department_outlined, color: _amber, size: 16),
                 const SizedBox(width: 8),
                 Expanded(
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
        ),
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
  Widget _buildDailyEnergySection() {
    final now = DateTime.now();
    final todayIdx = MayanZodiacData.nahualIndex(now);
    final todayNahual = MayanZodiacData.nahuales[todayIdx];
    final todayTone = MayanZodiacData.galacticTone(now);
    final todayToneData = MayanZodiacData.galacticTones[todayTone - 1];
    
    int seed = _getSeed(now) + _userIdx;
    int genEnergy = _deterministicRandom(seed, 1, 60, 98);
    int alignScore = _deterministicRandom(seed, 4, 30, 95);

    String toneTitleRaw = todayToneData['title']!.toLowerCase();
    String toneTitleClean = toneTitleRaw.replaceAll(RegExp(r'\s*\(\d+\.\s*ton\)', caseSensitive: false), '').trim();

    String goodFor = _generateGoodFor(todayNahual, alignScore);
    String badFor = _generateBadFor(todayNahual, alignScore);
    String compatibilityText = _generateShortCompatibility(_userNahual, todayNahual, alignScore, genEnergy);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GÜNÜN KUTSAL TZOLK\'İN ENERJİSİ',
          style: TextStyle(color: _goldBright, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        const SizedBox(height: 12),
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
                onTap: () {
                  setState(() {
                    _isDailyEnergyExpanded = !_isDailyEnergyExpanded;
                  });
                },
                child: Container(
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
                            Text('${todayNahual['name'].toUpperCase()} (TON $todayTone)', style: GoogleFonts.cinzel(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
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
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topCenter,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 16), // Altındaki "GÜÇ" metninin yüksekliğini dengeleyip merkez şeridine oturmasını sağlar
                            child: _buildGeomScore(
                              genEnergy, 
                              "GÜÇ", 
                              size: 40, 
                              color: Colors.white.withValues(alpha: 0.95)
                            ),
                          ),
                          Positioned(
                            bottom: -18, // Oku yatay hiza denkleminden tamamen çıkardık, kapsayıcının padding boşluğunda süzülecek
                            child: AnimatedRotation(
                              turns: _isDailyEnergyExpanded ? 0.5 : 0.0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              child: Icon(Icons.keyboard_arrow_down_rounded, color: _goldBright.withValues(alpha: 0.6), size: 20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('KADER DÖNGÜSÜ HARİTASI', style: TextStyle(color: _jade, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 2)),
        const SizedBox(height: 16),
        _buildAncientCard(
          child: Column(
            children: [
              _buildLithicTimelineStep("0-20 YAŞ", "Öğrenme ve Kök Salma", age >= 0 && age < 20, isLine: true),
              _buildLithicTimelineStep("20-35 YAŞ", "Yön Bulma ve Mücadele", age >= 20 && age < 35, isLine: true),
              _buildLithicTimelineStep("35-50 YAŞ", "Güçlenme ve Hakimiyet", age >= 35 && age < 50, isLine: true),
              _buildLithicTimelineStep("50+ YAŞ  ", "Rehberlik ve Üstatlık", age >= 50, isLine: false),
            ],
          ),
        ),
        
        const SizedBox(height: 36),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('KİŞİSEL ENERJİ UYUMU', style: TextStyle(color: _jade, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _jade.withValues(alpha: 0.15), 
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('14 GÜNLÜK FORECAST', style: TextStyle(color: _jade, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildAncientCard(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
          child: SizedBox(
            height: 180,
            width: double.infinity,
            child: CustomPaint(
              painter: _WaveGraphPainter(
                color: _jade,
                accent: _goldBright,
                userIdx: _userIdx, // Her burca benzersiz dalga sağlamak için
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLithicTimelineStep(String ageRange, String desc, bool active, {bool isLine = true}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: active ? _jade : _obsidianLight,
                  border: Border.all(color: active ? _jade : Colors.white.withValues(alpha: 0.3)),
                ),
              ),
            ),
            if (isLine)
              Container(
                width: 2,
                height: 48,
                color: active ? _jade.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.1),
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ageRange,
                style: TextStyle(
                  color: active ? _jade : Colors.white.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                desc,
                style: TextStyle(
                  color: active ? Colors.white : Colors.white.withValues(alpha: 0.4),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (active)
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: _jade.withValues(alpha: 0.15), border: Border.all(color: _jade.withValues(alpha: 0.4))),
                  child: const Text("ŞU AN BURADASIN", style: TextStyle(color: _jade, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════
  // FEATURE 5: MAYA ENERJİ DNA'SI
  // ══════════════════════════════════════════
  Widget _buildDNASection() {
    int seed = _birthDate.year * 1000 + _birthDate.month * 100 + _birthDate.day;
    
    List<int> dnaIndices = [_userIdx];
    while(dnaIndices.length < 4) {
      int rn = _deterministicRandom(seed, dnaIndices.length, 0, 19);
      if(!dnaIndices.contains(rn)) dnaIndices.add(rn);
    }
    
    int p1 = _deterministicRandom(seed, 10, 35, 45);
    int p2 = _deterministicRandom(seed, 11, 20, 30);
    int p3 = _deterministicRandom(seed, 12, 15, 20);
    int p4 = 100 - (p1 + p2 + p3);
    
    List<Map<String,dynamic>> dnaList = [
      {'n': MayanZodiacData.nahuales[dnaIndices[0]], 'p': p1, 'c': _goldBright},
      {'n': MayanZodiacData.nahuales[dnaIndices[1]], 'p': p2, 'c': _jade},
      {'n': MayanZodiacData.nahuales[dnaIndices[2]], 'p': p3, 'c': _goldBright.withValues(alpha: 0.7)},
      {'n': MayanZodiacData.nahuales[dnaIndices[3]], 'p': p4, 'c': _amber},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('MAYA ENERJİ DNA\'SI', style: TextStyle(color: _jade, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 2)),
        const SizedBox(height: 8),
        Text('Ruhunun antik kodlaması', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
        const SizedBox(height: 24),
        
        ...dnaList.map((dna) {
          final n = dna['n'];
          final p = dna['p'] as int;
          final c = dna['c'] as Color;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildAncientCard(
              padding: const EdgeInsets.all(16),
              borderColor: c.withValues(alpha: 0.1),
              child: Row(
                children: [
                  _buildNahualIcon(MayanZodiacData.nahuales.indexOf(n), 40, c),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(n['name'].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1)),
                            Text('%$p', style: TextStyle(color: c, fontSize: 16, fontWeight: FontWeight.w900)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(n['words'], style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Container(
                          height: 4,
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05)),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: p / 100,
                            child: Container(decoration: BoxDecoration(color: c)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
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
      builder: (_) => Container(
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
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _birthDate = DateTime(selY, selM, selD));
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
      "Sabit fikirlilik yüzünden önene serilen $w1 akışını tamamen bloke etmek"
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
  
  _WaveGraphPainter({required this.color, required this.accent, required this.userIdx});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    
    // Keskin ızgara hatları
    final gridPaint = Paint()..color = Colors.white.withValues(alpha: 0.05)..strokeWidth = 1;
    final targetPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Yatay Referans Çizgileri (Top, Center, Bottom)
    for(int i=1; i<=3; i++) {
      double lineY = h * i / 4;
      // Ortadaki eksen çizgisini biraz daha belirgin yapıyoruz
      canvas.drawLine(Offset(0, lineY), Offset(w, lineY), i == 2 ? targetPaint : gridPaint);
    }
    
    // Dikey Gün Izgarası (Her gün için ince, 7. gün için belirgin)
    for(int i=1; i<14; i++) {
       double lineX = w * i / 13;
       canvas.drawLine(Offset(lineX, 0), Offset(lineX, h), i == 7 ? targetPaint : gridPaint);
    }

    // Gerçek Zamanlı Kişisel Uyum (Biorhythm) Hesaplaması
    List<Offset> points = [];
    int maxToneIndex = 0;
    int minToneIndex = 0;
    double maxVal = -999;
    double minVal = 999;
    
    final fillPath = Path();
    final linePath = Path();
    
    int daysSinceEpoch = DateTime.now().difference(DateTime(1970)).inDays;

    for(int i = 0; i <= 13; i++) {
      int dayAbs = daysSinceEpoch + i;
      
      // Mayaların Döngüsel Frekans Matematiği 
      // Her Nahual'in evrenle olan rezonans dalgası farklıdır (userIdx faz olarak katılır)
      double wave13 = math.sin(((dayAbs + userIdx * 7) % 13) / 13.0 * 2 * math.pi); // 13 Günlük Galaktik Ton Dalgası
      double wave20 = math.cos(((dayAbs + userIdx * 11) % 20) / 20.0 * 2 * math.pi); // 20 Günlük Güneş Mührü Dalgası
      double waveMicro = math.sin(((dayAbs * 2 + userIdx) % 9) / 9.0 * 2 * math.pi); // 9 Lord of the Night Dalgası
      
      // Toplam Uyum Puanı (Biorhythm) -1.0 ile 1.0 aralığına normalize
      double combined = (wave13 * 0.5) + (wave20 * 0.4) + (waveMicro * 0.1); 
      
      if (combined > maxVal) { maxVal = combined; maxToneIndex = i; }
      if (combined < minVal) { minVal = combined; minToneIndex = i; }
      
      // Y ekseni: h*0.85 (dip) ile h*0.15 (tepe) arasına yerleştiriyoruz
      double normalizedY = (combined * -1 + 1.0) / 2.0; // -1 en üstte (küçük y), 1 en altta (büyük y)
      double y = h * 0.15 + (normalizedY * h * 0.7);
      
      double x = (i / 13) * w;
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

    // Dinamik Gradient (Grafikteki renk geçişini çok daha okunaklı ve keskin yaptık)
    canvas.drawPath(
      fillPath, 
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.65), color.withValues(alpha: 0.0)],
        ).createShader(Rect.fromLTRB(0, 0, w, h))
    );

    // Ana Çizgi Hattı (Daha premium bir kalınlık)
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);

    // Grafik Detayları ve Keskin İşaretçiler
    
    // Y ekseni etiketleri (Basitçe referans vermek için noktalama)
    if (points.isNotEmpty) {
      _drawLabelRight(canvas, w, h * 0.15, "MAKS", color.withValues(alpha: 0.8));
      _drawLabelRight(canvas, w, h * 0.85, "MİN", color.withValues(alpha: 0.8));
    }
    
    // Kritik Nokta İşaretlemeleri
    _drawPoint(canvas, points[0], "BUGÜN\n%${((maxVal - points[0].dy/h) * 100).abs().toInt().clamp(10, 99)} UYUM", Colors.white, w);
    
    if (maxToneIndex > 0) {
      _drawPoint(canvas, points[maxToneIndex], "${maxToneIndex}. GÜN\nZİRVE (!)", accent, w);
    }
    
    if (minToneIndex > 0 && minToneIndex != maxToneIndex) {
      _drawPoint(canvas, points[minToneIndex], "${minToneIndex}. GÜN\nDİNLEN", const Color(0xFFFF6D00), w);
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
    canvas.drawRect(Rect.fromCenter(center: offset, width: 8, height: 8), Paint()..color = Colors.black);
    canvas.drawRect(Rect.fromCenter(center: offset, width: 6, height: 6), Paint()..color = c);

    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, height: 1.3)),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.layout();
    
    double dyOffset = offset.dy < 60 ? 12 : -tp.height - 8;
    // Grafiğin kenarlarından metnin dışarı taşmasını engellemek için min/max x ayarı
    double drawX = offset.dx - tp.width/2;
    if (drawX < 10) drawX = 10;
    if (drawX + tp.width > w - 10) drawX = w - tp.width - 10;
    
    tp.paint(canvas, Offset(drawX, offset.dy + dyOffset));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
