import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'dart:math' as math;
import '../widgets/glass_back_button.dart';
import '../services/storage_service.dart';
import 'chinese_zodiac_data.dart';

class ZodiacChinesePage extends StatefulWidget {
  const ZodiacChinesePage({super.key});
  @override
  State<ZodiacChinesePage> createState() => _ZodiacChinesePageState();
}

class _ZodiacChinesePageState extends State<ZodiacChinesePage>
    with TickerProviderStateMixin {
  late AnimationController _ctrl;
  late AnimationController _auraCtrl;
  int _animalIdx = 6;
  int _activeSection = 0;
  DateTime _birthDate = DateTime(1999, 12, 20);
  String _userElement = 'Su';
  String _userYinYang = 'Yin';
  int _selectedCompat = -1;

  // Asya tarzı renk paleti
  static const Color _crimson = Color(0xFFB91C1C);
  static const Color _gold = Color(0xFFD4A030);
  static const Color _goldL = Color(0xFFFFE8A1);
  static const Color _bg = Color(0xFF0A0A0F);
  static const Color _cardBg = Color(0xFF14141A);

  static const List<Map<String, dynamic>> _sections = [
    {'icon': '🐾', 'label': 'Ruhun'},
    {'icon': '💞', 'label': 'Kader'},
    {'icon': '⭐', 'label': 'Günlük'},
    {'icon': '🐴', 'label': '2026'},
    {'icon': '🌊', 'label': 'Elementler'},
  ];

  // 12 hayvan dosya isimleri (sırayla)
  static const List<String> _animalFiles = [
    'rat', 'ox', 'tiger', 'rabbit', 'dragon', 'snake',
    'horse', 'goat', 'monkey', 'rooster', 'dog', 'pig',
  ];

  // Sade hayvan figürü (siyah arka plan screen blend ile şeffaf)
  Widget _animalIcon(int index, double size, {double opacity = 1.0}) {
    return Opacity(
      opacity: opacity,
      child: Image.asset(
        'assets/zodiac_animals/${_animalFiles[index]}.png',
        width: size, height: size,
        filterQuality: FilterQuality.high,
        fit: BoxFit.contain,
      ),
    );
  }

  // Picker için kutulu versiyon
  Widget _animalSeal(int index, double size, {bool selected = false}) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: selected ? _crimson.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? _gold.withOpacity(0.35) : Colors.white.withOpacity(0.04),
          width: selected ? 1.0 : 0.5,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(size * 0.12),
        child: _animalIcon(index, size * 0.76, opacity: selected ? 1.0 : 0.4),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward();
    _auraCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))..repeat(reverse: true);
    _loadUser();
  }

  Future<void> _loadUser() async {
    final d = await StorageService.getBirthDate();
    if (d != null && mounted) {
      setState(() {
        _birthDate = d;
        _animalIdx = ChineseZodiacData.animalIndexFromYear(d.year);
        _userElement = ChineseZodiacData.elementFromYear(d.year);
        _userYinYang = ChineseZodiacData.yinYangFromYear(d.year);
      });
    }
  }

  @override
  void dispose() { _auraCtrl.dispose(); _ctrl.dispose(); super.dispose(); }

  Map<String, dynamic> get _animal => ChineseZodiacData.animals[_animalIdx];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(children: [
        // Arka plan: Dev Yin-Yang atmosferi
        Positioned.fill(child: CustomPaint(
          painter: _YinYangBgPainter(crimson: _crimson, gold: _gold),
        )),
        SafeArea(bottom: false, child: Column(children: [
          _buildSectionTabs(),
          Expanded(child: _buildContent()),
        ])),
      ]),
    );
  }

  // ── SECTION TABS — Ayrı Liquid Glass Kartları ──
  Widget _buildSectionTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 2),
      child: Row(children: [
        // Geri butonu — bağımsız cam daire
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.16),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.22), width: 0.6),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 3)),
                  ],
                ),
                child: const Icon(Icons.chevron_left_rounded, color: Colors.white70, size: 20),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Sekmeler — her biri ayrı cam kartı
        ...List.generate(_sections.length, (i) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5),
            child: _tabItem(i),
          ),
        )),
      ]),
    );
  }

  Widget _tabItem(int i) {
    final sel = i == _activeSection;
    final iconColor = sel ? _goldL : Colors.white.withOpacity(0.45);
    final iconSize = sel ? 20.0 : 16.0;
    return GestureDetector(
      onTap: () => setState(() => _activeSection = i),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              gradient: sel
                ? const LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Color(0xFF301010), Color(0xFF1A0808)],
                  )
                : LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.12),
                      Colors.white.withOpacity(0.04),
                    ],
                  ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: sel ? _gold.withOpacity(0.4) : Colors.white.withOpacity(0.18),
                width: 0.6,
              ),
              boxShadow: [
                if (sel) ...[
                  BoxShadow(color: _crimson.withOpacity(0.2), blurRadius: 12, spreadRadius: -3),
                  BoxShadow(color: _gold.withOpacity(0.06), blurRadius: 8),
                ] else
                  BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // İkon
              Stack(alignment: Alignment.center, children: [
                if (sel) Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [_gold.withOpacity(0.14), Colors.transparent],
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: iconSize, height: iconSize,
                  child: CustomPaint(painter: _TabIconPainter(index: i, color: iconColor)),
                ),
              ]),
              const SizedBox(height: 3),
              Text(_sections[i]['label'] as String, style: TextStyle(
                color: sel ? _goldL : Colors.white.withOpacity(0.45),
                fontSize: sel ? 8.5 : 8.0,
                fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                letterSpacing: sel ? 0.5 : 0,
              )),
              // Aktif gösterge noktası
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(top: 2),
                width: sel ? 3.5 : 0, height: sel ? 3.5 : 0,
                decoration: BoxDecoration(
                  color: _goldL,
                  shape: BoxShape.circle,
                  boxShadow: sel ? [
                    BoxShadow(color: _gold.withOpacity(0.5), blurRadius: 5),
                  ] : null,
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // ── CONTENT ROUTER ──
  Widget _buildContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: SingleChildScrollView(
        key: ValueKey(_activeSection),
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        child: _sectionWidget(),
      ),
    );
  }

  Widget _sectionWidget() {
    switch (_activeSection) {
      case 0: return _profileSection();
      case 1: return _compatibilitySection();
      case 2: return _dailySection();
      case 3: return _yearSection();
      case 4: return _elementSection();
      default: return _profileSection();
    }
  }

  // ══════════════════════════════════════════
  // YIL SEÇİCİ
  void _showYearPicker() {
    int selectedYear = _birthDate.year;
    final years = List.generate(103, (i) => 1924 + i); // 1924-2026
    final initialIdx = years.indexOf(selectedYear).clamp(0, years.length - 1);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            height: 320,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.12),
                  Colors.white.withOpacity(0.06),
                  Colors.black.withOpacity(0.2),
                ],
              ),
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.15), width: 0.5)),
            ),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Doğum Yılı', style: TextStyle(color: _goldL, fontSize: 18, fontWeight: FontWeight.w700)),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _birthDate = DateTime(selectedYear, _birthDate.month, _birthDate.day);
                        _animalIdx = ChineseZodiacData.animalIndexFromYear(selectedYear);
                        _userElement = ChineseZodiacData.elementFromYear(selectedYear);
                        _userYinYang = ChineseZodiacData.yinYangFromYear(selectedYear);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [_crimson, Color(0xFFDC2626)]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Tamam', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ]),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(initialItem: initialIdx),
                  itemExtent: 44,
                  diameterRatio: 1.5,
                  selectionOverlay: Container(
                    decoration: BoxDecoration(
                      border: Border.symmetric(horizontal: BorderSide(color: _gold.withOpacity(0.15))),
                    ),
                  ),
                  onSelectedItemChanged: (i) => selectedYear = years[i],
                  children: years.map((y) => Center(
                    child: Text('$y', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 20)),
                  )).toList(),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════
  // HAYVAN SEÇİCİ
  // ══════════════════════════════════════════
  void _showAnimalPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        decoration: const BoxDecoration(
          color: Color(0xFF12121A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Tutma çubuğu
          Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(2))),
          Text('Burcunu Seç', style: TextStyle(color: _goldL, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          const SizedBox(height: 16),
          // 12 hayvan grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 0.85,
            ),
            itemCount: 12,
            itemBuilder: (_, i) {
              final sel = i == _animalIdx;
              final a = ChineseZodiacData.animals[i];
              return GestureDetector(
                onTap: () {
                  setState(() => _animalIdx = i);
                  Navigator.of(context).pop();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: sel ? _crimson.withOpacity(0.15) : Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: sel ? _gold.withOpacity(0.5) : Colors.white.withOpacity(0.06),
                      width: sel ? 1.2 : 0.5,
                    ),
                    boxShadow: sel ? [BoxShadow(color: _crimson.withOpacity(0.15), blurRadius: 12)] : null,
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _animalSeal(i, 42, selected: sel),
                    const SizedBox(height: 5),
                    Text(a['name'] as String, style: TextStyle(
                      color: sel ? _goldL : Colors.white.withOpacity(0.4),
                      fontSize: 9, fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                    )),
                  ]),
                ),
              );
            },
          ),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════
  // 0) PROFİL
  // ══════════════════════════════════════════
  Widget _profileSection() {
    final a = _animal;
    final traits = a['traits'] as List<String>;
    final strengths = a['strengths'] as List<String>;
    final weaknesses = a['weaknesses'] as List<String>;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Hero — Çarpıcı mistik aura ile hayvan figürü
      Center(child: AnimatedBuilder(
        animation: _auraCtrl,
        builder: (context, _) {
          final pulse = _auraCtrl.value;
          return SizedBox(
            width: 280, height: 280,
            child: Stack(alignment: Alignment.center, children: [
              // Katman 1: En dış halka — soluk geniş glow
              Positioned.fill(child: Center(child: Container(
                width: 260 + pulse * 12,
                height: 260 + pulse * 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.transparent,
                      _crimson.withOpacity(0.02 + pulse * 0.015),
                      _crimson.withOpacity(0.05 + pulse * 0.02),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.6, 0.8, 1.0],
                  ),
                ),
              ))),
              // Katman 2: Dekoratif halka — ince altın daire
              Positioned.fill(child: Center(child: Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _gold.withOpacity(0.06 + pulse * 0.04),
                    width: 0.5,
                  ),
                ),
              ))),
              // Katman 3: İç halka — kesikli altın
              Positioned.fill(child: Center(child: CustomPaint(
                size: const Size(210, 210),
                painter: _AuraRingPainter(
                  color: _gold.withOpacity(0.08 + pulse * 0.06),
                  dashCount: 36,
                  radius: 105,
                ),
              ))),
              // Katman 4: Kırmızı iç radyal glow
              Positioned.fill(child: Center(child: Container(
                width: 180 + pulse * 6,
                height: 180 + pulse * 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _crimson.withOpacity(0.12 + pulse * 0.05),
                      _crimson.withOpacity(0.04),
                      _gold.withOpacity(0.02),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.35, 0.6, 1.0],
                  ),
                ),
              ))),
              // Katman 5: 4 köşe dekoratif ışık noktaları
              ...List.generate(4, (i) {
                final angle = (i * math.pi / 2) - math.pi / 4;
                final dist = 100.0 + pulse * 4;
                return Positioned(
                  left: 140 + dist * math.cos(angle) - 3,
                  top: 140 + dist * math.sin(angle) - 3,
                  child: Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _gold.withOpacity(0.15 + pulse * 0.15),
                      boxShadow: [
                        BoxShadow(
                          color: _gold.withOpacity(0.1 + pulse * 0.1),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                );
              }),
              // Katman 6: 8 ince radyal çizgi — yıldız patlaması
              Positioned.fill(child: Center(child: CustomPaint(
                size: const Size(240, 240),
                painter: _StarBurstPainter(
                  color: _gold.withOpacity(0.04 + pulse * 0.03),
                  rayCount: 8,
                  innerRadius: 90,
                  outerRadius: 118,
                ),
              ))),
              // Hayvan figürü — ana ikon
              _animalIcon(_animalIdx, 200),
              // Alt dekoratif yarım ay
              Positioned(
                bottom: 18,
                child: Container(
                  width: 60, height: 2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1),
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        _gold.withOpacity(0.25 + pulse * 0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ]),
          );
        },
      )),
      const SizedBox(height: 2),
      // Yıllar
      Center(child: Text(a['years'] as String, textAlign: TextAlign.center,
        style: TextStyle(color: _gold.withOpacity(0.5), fontSize: 11))),

      const SizedBox(height: 40),

      // ── Birleşik Profil Kartı — Tag'ler + Dönen Alıntılar ──
      Builder(builder: (_) {
        // Motto + kişilik cümlelerini birleştir
        final motto = _getAnimalMotto(_animalIdx);
        final personalitySentences = (a['personality'] as String)
            .split('. ')
            .where((s) => s.trim().isNotEmpty)
            .map((s) => s.endsWith('.') ? s : '$s.')
            .toList();
        final allQuotes = [motto, ...personalitySentences];
        return _UnifiedProfileCard(
          quotes: allQuotes,
          crimson: _crimson,
          gold: _gold,
          goldL: _goldL,
          element: _userElement,
          yinYang: _userYinYang,
          year: _birthDate.year,
          onYearTap: _showYearPicker,
        );
      }),

      const SizedBox(height: 40),

      // ── Karakter Profili — yeni tasarım ──
      Builder(builder: (_) {
        final stats = _getRpgStats(_animalIdx);
        // En yüksek stat'ı bul
        final sorted = stats.entries.toList()..sort((a, b) => (b.value['val'] as int).compareTo(a.value['val'] as int));
        final hero = sorted.first;
        final others = sorted.sublist(1);
        // Klasik altın tonu — daha az turuncu, champagne
        const _accent = Color(0xFFCBB270); // Yumuşak champagne-altın
        const _accentL = Color(0xFFE8D9B0); // Açık champagne
        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.20), width: 0.6),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 12)),
            ],
          ),
          child: Column(children: [
            // Süper güç başlığı
            Text('Süper Gücün', style: TextStyle(
              color: _accent.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 2,
            )),
            const SizedBox(height: 16),
            // Büyük circular stat — arkasında radyal ışık
            Stack(alignment: Alignment.center, children: [
              // Radyal glow
              Container(
                width: 160, height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _crimson.withOpacity(0.12),
                      _accent.withOpacity(0.06),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              SizedBox(width: 120, height: 120, child: Stack(alignment: Alignment.center, children: [
              SizedBox(width: 120, height: 120, child: CircularProgressIndicator(
                value: (hero.value['val'] as int) / 100,
                strokeWidth: 5,
                backgroundColor: Colors.white.withOpacity(0.05),
                valueColor: AlwaysStoppedAnimation(Color.lerp(_crimson, _accent, (hero.value['val'] as int) / 100)!),
                strokeCap: StrokeCap.round,
              )),
              Column(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(width: 30, height: 30, child: CustomPaint(
                  painter: _StatIconPainter(statKey: hero.key, color: _accentL),
                )),
                const SizedBox(height: 4),
                Text('${hero.value['val']}%', style: const TextStyle(
                  color: _accentL, fontSize: 22, fontWeight: FontWeight.w800,
                )),
              ]),  // Column children end
              ])),  // inner Stack + SizedBox end
            ]),  // outer Stack end
            const SizedBox(height: 8),
            Text(hero.key, style: TextStyle(
              color: Colors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.w700,
            )),
            const SizedBox(height: 20),
            // Diğer 4 stat — mini circles
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: others.map((e) {
              final val = e.value['val'] as int;
              return Column(children: [
                SizedBox(width: 44, height: 44, child: Stack(alignment: Alignment.center, children: [
                  SizedBox(width: 44, height: 44, child: CircularProgressIndicator(
                    value: val / 100,
                    strokeWidth: 3,
                    backgroundColor: Colors.white.withOpacity(0.05),
                    valueColor: AlwaysStoppedAnimation(Color.lerp(_crimson, _accent, val / 100)!),
                    strokeCap: StrokeCap.round,
                  )),
                  SizedBox(width: 16, height: 16, child: CustomPaint(
                    painter: _StatIconPainter(statKey: e.key, color: _accentL.withOpacity(0.8)),
                  )),
                ])),
                const SizedBox(height: 6),
                Text('${val}%', style: const TextStyle(color: _accentL, fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(e.key, style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 9)),
              ]);
            }).toList()),
            // Ayırıcı
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Container(height: 0.5, decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.transparent, _accent.withOpacity(0.12), Colors.transparent]),
              )),
            ),
            // Güçlü & Gelişim — kompakt tag'ler
            Wrap(spacing: 6, runSpacing: 6, children: [
              ...strengths.take(4).map((s) => _traitTag(s, const Color(0xFFCBB270))),
              ...weaknesses.take(3).map((w) => _traitTag(w, const Color(0xFFB85C5C))),
            ]),
            ]),
          ),
          ),
        );
      }),
      const SizedBox(height: 20),
      // Kariyer — Kader Yolu Tasarımı
      _glass(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          SizedBox(width: 22, height: 22, child: CustomPaint(painter: _CareerIconPainter(color: _gold))),
          const SizedBox(width: 8),
          const Text('Kariyer Haritası', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 14),
        // Tavsiye — editöryal alıntı stili
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Sol dekoratif çizgi
          Container(
            width: 2, height: 40,
            margin: const EdgeInsets.only(top: 2, right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1),
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [_gold.withOpacity(0.6), _gold.withOpacity(0.08)],
              ),
            ),
          ),
          // Metin
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              a['careerAdvice'] as String,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
                height: 1.6,
                fontStyle: FontStyle.italic,
                letterSpacing: 0.2,
              ),
            ),
          ])),
        ]),
        const SizedBox(height: 20),
        // Takımyıldız Haritası
        Builder(builder: (_) {
          final careers = a['careers'] as List<String>;
          const careerDesc = <String, String>{
            'Finans Uzmanı': 'Stratejik zekanız finansta parlar',
            'Girişimci': 'Yaratıcı vizyonunuz sizi öne çıkarır',
            'Muhasebeci': 'Detaycı yapınız mükemmellik getirir',
            'Avukat': 'Adaletçi ruhunuz hakkı savunur',
            'Yazar': 'İç dünyanızı kelimelere dökme yeteneği',
            'Mühendis': 'Analitik zihniniz çözümler üretir',
            'Çiftçi': 'Doğayla uyumunuz bereket getirir',
            'Bankacı': 'Güvenilir yapınız değer kazanır',
            'Mimar': 'Hayal gücünüz yapılara hayat verir',
            'Cerrah': 'Kararlılığınız hayat kurtarır',
            'Asker': 'Cesaretiniz sınır tanımaz',
            'Komutan': 'Doğal liderliğiniz yolları açar',
            'CEO': 'Vizyoner bakışınız zirveye taşır',
            'Sporcu': 'Enerjiniz sizi öne çıkarır',
            'Gazeteci': 'Cesaretle gerçeği bulursunuz',
            'Sanatçı': 'Ruhunuzun derinliği eserlere yansır',
            'Diplomat': 'İnce zekânız köprüler kurar',
            'Psikolog': 'Empati gücünüz ruhlara dokunur',
            'Tasarımcı': 'Estetik bakışınız fark yaratır',
            'Müzisyen': 'Duygularınız melodilerde hayat bulur',
            'Politikacı': 'Karizmanız kitleleri etkiler',
            'Yatırımcı': 'Önseziniz fırsatları yakalar',
            'Lider': 'İlham vererek yönlendirirsiniz',
            'Bilim İnsanı': 'Meraklı zihniniz keşifler yapar',
            'Filozof': 'Derin düşünceleriniz anlam arar',
            'Dedektif': 'Keskin gözleminiz gizemi çözer',
            'Danışman': 'Bilgeliğiniz yol gösterir',
            'Pilot': 'Özgür ruhunuz göklerde huzur bulur',
            'Satıcı': 'İkna gücünüz eşsizdir',
            'Komedyen': 'Neşeniz hayata renk katar',
            'Rehber': 'Enerjiniz keşfe çıkarır',
            'Ressam': 'Duyarlılığınız tuvale yansır',
            'Terapi Uzmanı': 'Şefkatiniz iyileşme getirir',
            'Aşçı': 'Yaratıcılığınız lezzetlerde gizli',
            'Yazılımcı': 'Zekânız dijitalde iz bırakır',
            'Stand-up Komedyen': 'Zekice espriniz güldürür',
            'Mucit': 'Fikirleriniz dünyayı değiştirir',
            'Pazarlamacı': 'Stratejik kreativite gücünüz',
            'Askeri Komutan': 'Disiplin ve cesaretiniz birleşir',
            'Kalite Kontrolcü': 'Mükemmeliyetiniz standart belirler',
            'Polis': 'Adalet duygunuz toplumu korur',
            'Doktor': 'Şefkat ve bilginiz hayat kurtarır',
            'Öğretmen': 'Bilgeliğiniz nesillere ışık tutar',
            'Sosyal Hizmet Uzmanı': 'Empati gücünüz merhem olur',
            'Hayırsever': 'Cömert kalbiniz güzelleştirir',
            'Hemşire': 'Şefkatiniz umut olur',
            'Veteriner': 'Doğa sevginiz şifa verir',
            'Otelci': 'Misafirperverliğiniz büyüler',
          };
          const accent = Color(0xFFCBB270);
          return Column(children: [
            for (int i = 0; i < careers.length; i++) ...[
              IntrinsicHeight(child: Row(children: [
                // Sol içerik (çift index'te göster)
                Expanded(child: i.isEven
                  ? _careerNode(careers[i], careerDesc[careers[i]] ?? '', accent, CrossAxisAlignment.end)
                  : const SizedBox(),
                ),
                // Orta çizgi + düğüm
                SizedBox(width: 32, child: Column(children: [
                  if (i > 0) Container(width: 1, height: 8, color: accent.withOpacity(0.12)),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withOpacity(0.3),
                      border: Border.all(color: accent.withOpacity(0.6), width: 1),
                      boxShadow: [BoxShadow(color: accent.withOpacity(0.2), blurRadius: 8)],
                    ),
                  ),
                  if (i < careers.length - 1) Expanded(child: Container(width: 1, color: accent.withOpacity(0.08))),
                ])),
                // Sağ içerik (tek index'te göster)
                Expanded(child: i.isOdd
                  ? _careerNode(careers[i], careerDesc[careers[i]] ?? '', accent, CrossAxisAlignment.start)
                  : const SizedBox(),
                ),
              ])),
            ],
          ]);
        }),
      ])),
    ]);
  }

  // ══════════════════════════════════════════
  // 1) 2026 - AT YILI
  // ══════════════════════════════════════════
  Widget _yearSection() {
    final yearAnimal = ChineseZodiacData.animals[6]; // At
    final interaction = ChineseZodiacData.yearInteractions[_animalIdx];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Yıl hero
      _glass(child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('🐴', style: const TextStyle(fontSize: 50)),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(colors: [_crimson, Color(0xFFFF6B6B)]).createShader(b),
              child: const Text('2026', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
            ),
            Text('AT YILI', style: TextStyle(color: _goldL.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 2)),
          ]),
        ]),
        const SizedBox(height: 16),
        Text('Ateş Atı yılı; enerji, özgürlük ve hareketlilik temalı bir dönem. Cesur adımlar atanları ödüllendirir.',
          textAlign: TextAlign.center, style: _bodyStyle()),
      ])),
      const SizedBox(height: 20),
      // Yılın özellikleri
      _secHead('🏮', 'Yılın Enerjisi'),
      const SizedBox(height: 10),
      Row(children: [
        _infoChip('🔥', 'Element', 'Ateş'),
        const SizedBox(width: 10),
        _infoChip('☯️', 'Kutupluluk', 'Yang'),
        const SizedBox(width: 10),
        _infoChip('⚡', 'Tema', 'Hareket'),
      ]),
      const SizedBox(height: 20),
      // Etkileşim
      _glass(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(_animal['emoji'] as String, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          const Text('×', style: TextStyle(color: Colors.white38, fontSize: 20)),
          const SizedBox(width: 8),
          const Text('🐴', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(child: Text('${_animal['name']} & At Yılı Etkileşimi',
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
        ]),
        const SizedBox(height: 14),
        Text(interaction, style: _bodyStyle()),
      ])),
      const SizedBox(height: 20),
      // Yıl tavsiyeleri
      _glass(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _secHead('💡', '2026 Tavsiyeleri'),
        const SizedBox(height: 12),
        _adviceRow('🌱', 'İlkbahar', 'Yeni başlangıçlar için ideal. Tohumları ekin.'),
        _adviceRow('☀️', 'Yaz', 'En verimli dönem. Projelere hız verin.'),
        _adviceRow('🍂', 'Sonbahar', 'Hasat zamanı. Başarılarınızı değerlendirin.'),
        _adviceRow('❄️', 'Kış', 'Dinlenme ve planlama dönemi. İç dünyanıza dönün.'),
      ])),
      const SizedBox(height: 24),
      // ── 2026 Zamanlama Rehberi ──
      _secHead('⏰', '2026 Zamanlama Rehberi'),
      const SizedBox(height: 12),
      ..._buildTimingCards(),
    ]);
  }

  List<Widget> _buildTimingCards() {
    final timing = _animal['timingAdvice'] as Map<String, int>;
    final items = [
      {'key': 'isKurma', 'emoji': '🏢', 'label': 'İş Kurma'},
      {'key': 'yatirim', 'emoji': '📈', 'label': 'Yatırım'},
      {'key': 'evlenme', 'emoji': '💒', 'label': 'Evlenme'},
      {'key': 'cocuk', 'emoji': '👶', 'label': 'Çocuk'},
      {'key': 'seyahat', 'emoji': '✈️', 'label': 'Seyahat'},
      {'key': 'tasima', 'emoji': '🏠', 'label': 'Taşınma'},
    ];
    final colors = [const Color(0xFFE53935), const Color(0xFFFF9800), const Color(0xFFFFEB3B), const Color(0xFF4CAF50), const Color(0xFF2E7D32)];
    final labels = ['Uygun Değil', 'Dikkatli Ol', 'Nötr', 'Uygun', 'Çok Uygun'];
    return items.map((item) {
      final score = timing[item['key']] ?? 3;
      final sc = colors[score - 1];
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: sc.withOpacity(0.06), borderRadius: BorderRadius.circular(16),
          border: Border.all(color: sc.withOpacity(0.2)),
        ),
        child: Row(children: [
          Text(item['emoji'] as String, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item['label'] as String, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Row(children: List.generate(5, (i) => Container(
              width: 20, height: 5, margin: const EdgeInsets.only(right: 3),
              decoration: BoxDecoration(
                color: i < score ? sc : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(3),
              ),
            ))),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: sc.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Text(labels[score - 1], style: TextStyle(color: sc, fontSize: 9, fontWeight: FontWeight.w700)),
          ),
        ]),
      );
    }).toList();
  }

  // ══════════════════════════════════════════
  // 2) ELEMENT & YIN-YANG
  // ══════════════════════════════════════════
  Widget _elementSection() {
    final elData = ChineseZodiacData.elements[_userElement]!;
    final elColor = Color(elData['color'] as int);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Element hero
      _glass(child: Column(children: [
        Text(elData['emoji'] as String, style: const TextStyle(fontSize: 60)),
        const SizedBox(height: 8),
        ShaderMask(
          shaderCallback: (b) => LinearGradient(colors: [elColor, elColor.withOpacity(0.6)]).createShader(b),
          child: Text(_userElement, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 12),
        Text(elData['desc'] as String, textAlign: TextAlign.center, style: _bodyStyle()),
      ])),
      const SizedBox(height: 20),
      // Element özellikleri
      Row(children: [
        _infoChip('🌸', 'Mevsim', elData['season'] as String),
        const SizedBox(width: 10),
        _infoChip('🧭', 'Yön', elData['direction'] as String),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        _infoChip('🫀', 'Organ', elData['organ'] as String),
        const SizedBox(width: 10),
        _infoChip('💭', 'Duygu', elData['emotion'] as String),
      ]),
      const SizedBox(height: 20),
      // Element döngüsü
      _secHead('🔄', 'Beş Element Döngüsü'),
      const SizedBox(height: 12),
      _glass(child: Column(children: [
        _elementCycleRow('Üretir →', elData['generates'] as String, const Color(0xFF4CAF50)),
        _elementCycleRow('Kontrol →', elData['controls'] as String, const Color(0xFFFF9800)),
        _elementCycleRow('Zayıflatılır ←', elData['weakenedBy'] as String, const Color(0xFFE53935)),
      ])),
      const SizedBox(height: 20),
      // Yin Yang
      _secHead('☯️', 'Yin-Yang Dengesi'),
      const SizedBox(height: 12),
      _glass(child: Row(children: [
        Expanded(child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _userYinYang == 'Yin' ? Colors.white.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: _userYinYang == 'Yin' ? Border.all(color: Colors.white.withOpacity(0.2)) : null,
          ),
          child: Column(children: [
            const Text('☽', style: TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text('Yin', style: TextStyle(color: Colors.white.withOpacity(_userYinYang == 'Yin' ? 1 : 0.4), fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Alıcı · Sezgisel\nİçe dönük · Sakin', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
          ]),
        )),
        const SizedBox(width: 12),
        Expanded(child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _userYinYang == 'Yang' ? _gold.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: _userYinYang == 'Yang' ? Border.all(color: _gold.withOpacity(0.3)) : null,
          ),
          child: Column(children: [
            const Text('☀', style: TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text('Yang', style: TextStyle(color: _userYinYang == 'Yang' ? _goldL : Colors.white.withOpacity(0.4), fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Verici · Aktif\nDışa dönük · Ateşli', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
          ]),
        )),
      ])),
      const SizedBox(height: 20),
      // 5 element haritası
      _secHead('🌊', 'Tüm Elementler'),
      const SizedBox(height: 12),
      ...ChineseZodiacData.elements.entries.map((e) {
        final c = Color(e.value['color'] as int);
        final isUser = e.key == _userElement;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isUser ? c.withOpacity(0.12) : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isUser ? c.withOpacity(0.4) : Colors.white.withOpacity(0.06)),
          ),
          child: Row(children: [
            Text(e.value['emoji'] as String, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(e.key, style: TextStyle(color: isUser ? c : Colors.white.withOpacity(0.8), fontSize: 15, fontWeight: FontWeight.w700)),
                if (isUser) ...[const SizedBox(width: 8), Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: c.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: Text('Senin Elementin', style: TextStyle(color: c, fontSize: 9, fontWeight: FontWeight.w700)),
                )],
              ]),
              Text('${e.value['season']} · ${e.value['direction']}', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
            ])),
          ]),
        );
      }),
      const SizedBox(height: 24),
      // ── Feng Shui (Element bölümüne entegre) ──
      _secHead('🏡', 'Feng Shui Rehberi'),
      const SizedBox(height: 12),
      _fengShuiCard('🎨', 'Renk Paleti', (_animal['fengShui'] as Map<String, String>)['renk']!),
      _fengShuiCard('🧭', 'Şanslı Yön', (_animal['fengShui'] as Map<String, String>)['yön']!),
      _fengShuiCard('🪵', 'Malzeme', (_animal['fengShui'] as Map<String, String>)['malzeme']!),
      const SizedBox(height: 12),
      _glass(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _secHead('✨', 'Tasarım Tavsiyeleri'),
        const SizedBox(height: 12),
        Text((_animal['fengShui'] as Map<String, String>)['tavsiye']!, style: _bodyStyle()),
      ])),
    ]);
  }



  // ══════════════════════════════════════════
  // 4) EVLİLİK UYUMU
  // ══════════════════════════════════════════
  Widget _compatibilitySection() {
    final a = _animal;
    final best = (a['bestMatch'] as List<int>);
    final good = (a['goodMatch'] as List<int>);
    final bad = (a['conflict'] as List<int>);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Aşk & İlişki — 💌 Aşk Mektubu
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2A1A10).withOpacity(0.9),
              const Color(0xFF1E1210).withOpacity(0.95),
              const Color(0xFF2A1515).withOpacity(0.9),
            ],
          ),
          border: Border.all(color: const Color(0xFF8B6914).withOpacity(0.2), width: 0.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 12)),
          ],
        ),
        child: Stack(children: [
          ...[
            [4.0, 4.0, null, null], [null, 4.0, 4.0, null],
            [4.0, null, null, 4.0], [null, null, 4.0, 4.0],
          ].map((pos) => Positioned(
            left: pos[0] != null ? pos[0]! + 8 : null,
            top: pos[1] != null ? pos[1]! + 8 : null,
            right: pos[2] != null ? pos[2]! + 8 : null,
            bottom: pos[3] != null ? pos[3]! + 8 : null,
            child: SizedBox(
              width: 16, height: 16,
              child: CustomPaint(painter: _CornerPainter(
                color: const Color(0xFF8B6914).withOpacity(0.25),
                topLeft: pos[0] != null && pos[1] != null,
                topRight: pos[2] != null && pos[1] != null,
                bottomLeft: pos[0] != null && pos[3] != null,
                bottomRight: pos[2] != null && pos[3] != null,
              )),
            ),
          )),
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 28, 26, 24),
            child: Column(children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    center: Alignment(-0.2, -0.2),
                    colors: [Color(0xFFC62828), Color(0xFF8B0000), Color(0xFF4A0000)],
                    stops: [0.0, 0.5, 1.0],
                  ),
                  border: Border.all(color: const Color(0xFFD4A017).withOpacity(0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF8B0000).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4)),
                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(2, 2)),
                  ],
                ),
                child: const Icon(Icons.favorite_rounded, color: Color(0xFFD4A017), size: 24),
              ),
              const SizedBox(height: 14),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFD4A017), Color(0xFFF5D78E), Color(0xFFD4A017)],
                ).createShader(bounds),
                child: const Text('Aşk & İlişki', style: TextStyle(
                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.w300,
                  letterSpacing: 3.0,
                )),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: Container(height: 0.5, decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.transparent, const Color(0xFFD4A017).withOpacity(0.3),
                  ]),
                ))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('✦', style: TextStyle(
                    color: const Color(0xFFD4A017).withOpacity(0.35), fontSize: 8,
                  )),
                ),
                Expanded(child: Container(height: 0.5, decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    const Color(0xFFD4A017).withOpacity(0.3), Colors.transparent,
                  ]),
                ))),
              ]),
              const SizedBox(height: 18),
              Text(a['love'] as String, textAlign: TextAlign.center, style: TextStyle(
                color: Colors.white.withOpacity(0.72),
                fontSize: 14.5, fontStyle: FontStyle.italic,
                height: 1.75, letterSpacing: 0.2,
              )),
              const SizedBox(height: 18),
              Container(height: 0.5, color: const Color(0xFFD4A017).withOpacity(0.12)),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Sevgiyle mühürlendi', style: TextStyle(
                  color: const Color(0xFFD4A017).withOpacity(0.3),
                  fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 2.0, fontStyle: FontStyle.italic,
                )),
                const SizedBox(width: 6),
                Icon(Icons.favorite, size: 9, color: const Color(0xFFC62828).withOpacity(0.5)),
              ]),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 20),
      // ── Burç Uyum — Podium Sıralama ──
      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: const Color(0xFFD4A017).withOpacity(0.12), width: 0.5),
            ),
            child: Column(children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFD4A017), Color(0xFFF5D78E), Color(0xFFD4A017)],
                ).createShader(bounds),
                child: const Text('Burç Uyum Haritası', style: TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 1,
                )),
              ),
              const SizedBox(height: 4),
              Text('${a['name']} burcunun en uyumlu burçları', style: TextStyle(
                color: Colors.white.withOpacity(0.4), fontSize: 12, fontStyle: FontStyle.italic,
              )),
              const SizedBox(height: 22),
              // ── TOP 3 PODIUM — açıklamalı + özel ikon ──
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                // 2. sıra
                if (best.length > 1) Expanded(child: _podiumFull(
                  best[1], '🥈', const Color(0xFFC0C0C0), 45, 'Kalp kalbe bağ',
                )),
                if (best.length <= 1) const Expanded(child: SizedBox()),
                const SizedBox(width: 6),
                // 1. sıra
                Expanded(child: _podiumFull(
                  best[0], '🥇', const Color(0xFFD4A017), 65, 'Ruh eşiniz',
                )),
                const SizedBox(width: 6),
                // 3. sıra
                if (good.isNotEmpty) Expanded(child: _podiumFull(
                  good[0], '🥉', const Color(0xFFCD7F32), 30, 'Güçlü çekim',
                )),
                if (good.isEmpty) const Expanded(child: SizedBox()),
              ]),
              const SizedBox(height: 18),
              // Ayırıcı
              Container(height: 0.5, decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.transparent, const Color(0xFFD4A017).withOpacity(0.15), Colors.transparent,
                ]),
              )),
              // ── İYİ UYUM — kart stili ──
              if (good.length > 1) ...[
                const SizedBox(height: 14),
                Row(children: [
                  Icon(Icons.lightbulb_outline_rounded, color: const Color(0xFFD4A017).withOpacity(0.5), size: 14),
                  const SizedBox(width: 6),
                  Text('Aklınızda Bulunsun', style: TextStyle(color: const Color(0xFFD4A017).withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text('Alternatif bir seçenek', style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 9, fontStyle: FontStyle.italic)),
                ]),
                const SizedBox(height: 10),
                ...good.sublist(1).map((i) {
                  final gAnimal = ChineseZodiacData.animals[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFD4A017).withOpacity(0.03),
                      border: Border.all(color: const Color(0xFFD4A017).withOpacity(0.1), width: 0.5),
                    ),
                    child: Row(children: [
                      _animalIcon(i, 42),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(gAnimal['name'] as String, style: TextStyle(
                          color: Colors.white.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w700,
                        )),
                        const SizedBox(height: 2),
                        Text('Yolunuza çıkarsa fırsatı kaçırmayın', style: TextStyle(
                          color: Colors.white.withOpacity(0.3), fontSize: 10, fontStyle: FontStyle.italic,
                        )),
                      ])),
                    ]),
                  );
                }),
              ],
              // ── ZORLAYICI — ✗ çarpı işaretli ──
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFFF3D00).withOpacity(0.04),
                  border: Border.all(color: const Color(0xFFFF3D00).withOpacity(0.12), width: 0.5),
                ),
                child: Column(children: [
                  Row(children: [
                    Icon(Icons.warning_amber_rounded, color: const Color(0xFFFF3D00).withOpacity(0.5), size: 14),
                    const SizedBox(width: 6),
                    Text('Dikkat — Zorlayıcı', style: TextStyle(
                      color: const Color(0xFFFF3D00).withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w700,
                    )),
                    const Spacer(),
                    Text('Ekstra sabır gerekir', style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 9, fontStyle: FontStyle.italic)),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: bad.map((i) => Expanded(child: Column(children: [
                    _animalIcon(i, 42, opacity: 0.4),
                    const SizedBox(height: 4),
                    Text(ChineseZodiacData.animals[i]['name'] as String, style: TextStyle(
                      color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w600,
                    )),
                  ]))).toList()),
                ]),
              ),
            ]),
          ),
        ),
      ),
      const SizedBox(height: 20),
      // ── Detaylı Uyum Tablosu — Seçimli ──
      _secHead('📊', 'Detaylı Uyum Tablosu'),
      const SizedBox(height: 6),
      Text('Merak ettiğin burca dokun ✨', style: TextStyle(
        color: Colors.white.withOpacity(0.3), fontSize: 11, fontStyle: FontStyle.italic,
      )),
      const SizedBox(height: 14),
      // Hayvan seçim gridi — 2 satır 6 sütun
      ...List.generate(2, (row) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: List.generate(6, (col) {
          final i = row * 6 + col;
          if (i == _animalIdx) {
            return Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Opacity(opacity: 0.15, child: _animalIcon(i, 36)),
            ));
          }
          Color borderC;
          if (best.contains(i)) borderC = const Color(0xFFE91E63);
          else if (good.contains(i)) borderC = const Color(0xFFD4A017);
          else if (bad.contains(i)) borderC = const Color(0xFFFF3D00);
          else borderC = const Color(0xFF78909C);
          final selected = _selectedCompat == i;
          return Expanded(child: GestureDetector(
            onTap: () => setState(() => _selectedCompat = selected ? -1 : i),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: selected ? borderC.withOpacity(0.1) : Colors.transparent,
                border: Border.all(
                  color: selected ? borderC.withOpacity(0.5) : borderC.withOpacity(0.12),
                  width: selected ? 1.5 : 0.5,
                ),
              ),
              child: _animalIcon(i, 36),
            ),
          ));
        })),
      )),
      // Detay paneli — seçiliyse göster
      if (_selectedCompat >= 0 && _selectedCompat != _animalIdx) ...[
        const SizedBox(height: 6),
        Builder(builder: (ctx) {
          final si = _selectedCompat;
          final other = ChineseZodiacData.animals[si];
          int score; Color c; String label; String desc;
          if (best.contains(si)) {
            score = 95; c = const Color(0xFFE91E63); label = 'Mükemmel Uyum';
            desc = 'Bu burçla aranızda derin bir bağ var. Birbirini tamamlayan enerjiler güçlü bir çekim yaratır.';
          } else if (good.contains(si)) {
            score = 75; c = const Color(0xFFD4A017); label = 'İyi Uyum';
            desc = 'Doğal bir uyum ve anlayış mevcut. Birlikte geçirilen zaman keyifli ve verimli olur.';
          } else if (bad.contains(si)) {
            score = 35; c = const Color(0xFFFF3D00); label = 'Zorlayıcı';
            desc = 'Bu ilişki sabır ve anlayış gerektirir. Farklılıklar sürtüşmeye yol açabilir ama büyümeyi de sağlar.';
          } else {
            score = 60; c = const Color(0xFF78909C); label = 'Nötr';
            desc = 'Standart bir ilişki. Büyük çatışma yok ama özel bir çekim de hissedilmez.';
          }
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: c.withOpacity(0.04),
              border: Border.all(color: c.withOpacity(0.15)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                _animalIcon(si, 50),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(other['name'] as String, style: TextStyle(
                    color: Colors.white.withOpacity(0.9), fontSize: 16, fontWeight: FontWeight.w700,
                  )),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: c.withOpacity(0.12),
                    ),
                    child: Text(label, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ])),
                // Skor
                Column(children: [
                  Text('$score', style: TextStyle(color: c, fontSize: 28, fontWeight: FontWeight.w800, height: 1)),
                  Text('puan', style: TextStyle(color: c.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.w600)),
                ]),
              ]),
              const SizedBox(height: 12),
              // Progress bar
              ClipRRect(borderRadius: BorderRadius.circular(3), child: Stack(children: [
                Container(height: 4, decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(3),
                )),
                FractionallySizedBox(widthFactor: score / 100, child: Container(
                  height: 4, decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: LinearGradient(colors: [c.withOpacity(0.4), c]),
                    boxShadow: [BoxShadow(color: c.withOpacity(0.3), blurRadius: 6)],
                  ),
                )),
              ])),
              const SizedBox(height: 12),
              Text(desc, style: TextStyle(
                color: Colors.white.withOpacity(0.45), fontSize: 12, height: 1.5,
              )),
            ]),
          );
        }),
      ],
    ]);
  }

  Widget _dailySection() {
    final now = DateTime.now();
    final fortune = ChineseZodiacData.getDayFortune(_animalIdx, now);
    final c = fortune['color'] as Color;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Günlük şans
      _glass(child: Column(children: [
        Text(fortune['emoji'] as String, style: const TextStyle(fontSize: 50)),
        const SizedBox(height: 8),
        ShaderMask(
          shaderCallback: (b) => LinearGradient(colors: [c, c.withOpacity(0.6)]).createShader(b),
          child: Text(fortune['level'] as String, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 12),
        SizedBox(width: 200, child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(value: (fortune['score'] as int) / 100, backgroundColor: Colors.white.withOpacity(0.1), color: c, minHeight: 8),
        )),
        const SizedBox(height: 6),
        Text('Şans Puanı: ${fortune['score']}%', style: TextStyle(color: c, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Text(fortune['advice'] as String, textAlign: TextAlign.center, style: _bodyStyle()),
      ])),
      const SizedBox(height: 20),
      Row(children: [
        Expanded(child: _glass(child: Column(children: [
          const Text('🕐', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text('Şanslı Saat', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
          Text(fortune['luckyHour'] as String, style: TextStyle(color: _goldL, fontSize: 16, fontWeight: FontWeight.w700)),
        ]))),
        const SizedBox(width: 12),
        Expanded(child: _glass(child: Column(children: [
          const Text('🎯', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text('Şanslı Aktivite', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
          Text(fortune['luckyActivity'] as String, style: TextStyle(color: _goldL, fontSize: 14, fontWeight: FontWeight.w700)),
        ]))),
      ]),
      const SizedBox(height: 20),
      _secHead('🔢', 'Şanslı Sayılar'),
      const SizedBox(height: 10),
      Wrap(spacing: 10, children: (_animal['luckyNumbers'] as List<int>).map((n) =>
        Container(width: 44, height: 44, decoration: BoxDecoration(color: _gold.withOpacity(0.12), shape: BoxShape.circle, border: Border.all(color: _gold.withOpacity(0.3))),
          child: Center(child: Text('$n', style: TextStyle(color: _goldL, fontSize: 18, fontWeight: FontWeight.w800))))).toList()),
      const SizedBox(height: 16),
      _secHead('🎨', 'Şanslı Renkler'),
      const SizedBox(height: 10),
      Wrap(spacing: 10, runSpacing: 10, children: (_animal['luckyColors'] as List<String>).map((c) => _chip(c)).toList()),
    ]);
  }





  // ══════════════════════════════════════════
  // YARDIMCI WİDGET'LAR
  // ══════════════════════════════════════════
  // Zigzag kariyer düğümü
  Widget _careerNode(String name, String desc, Color accent, CrossAxisAlignment align) {
    return Padding(
      padding: EdgeInsets.only(
        left: align == CrossAxisAlignment.start ? 8 : 0,
        right: align == CrossAxisAlignment.end ? 8 : 0,
        bottom: 4,
      ),
      child: Column(
        crossAxisAlignment: align,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(name, style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          )),
          const SizedBox(height: 3),
          Text(desc, style: TextStyle(
            color: accent.withOpacity(0.4),
            fontSize: 10.5,
            height: 1.3,
          ), textAlign: align == CrossAxisAlignment.end ? TextAlign.end : TextAlign.start),
        ],
      ),
    );
  }

  Widget _matchStat(String label, double value, Color color) => Expanded(
    child: Column(children: [
      Text(label, style: TextStyle(
        color: color.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.5,
      )),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value: value, backgroundColor: Colors.white.withOpacity(0.06),
          color: color.withOpacity(0.6), minHeight: 3,
        ),
      ),
      const SizedBox(height: 4),
      Text('${(value * 100).toInt()}%', style: TextStyle(
        color: color.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.w700,
      )),
    ]),
  );

  Widget _glass({required Widget child}) => ClipRRect(
    borderRadius: BorderRadius.circular(22),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0.18),
              Colors.white.withOpacity(0.10),
              Colors.white.withOpacity(0.06),
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.22), width: 0.7),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 30, offset: const Offset(0, 12)),
          ],
        ),
        child: child,
      ),
    ),
  );

  // Birleşik kart için stat item
  Widget _statItem(String emoji, String value, String label) => Expanded(
    child: Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 18)),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(color: _goldL, fontSize: 15, fontWeight: FontWeight.w700)),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.w500)),
    ]),
  );

  Widget _statDivider() => Container(
    width: 0.5, height: 40,
    color: _gold.withOpacity(0.12),
  );

  Widget _profileTag(Color dotColor, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: dotColor.withOpacity(0.08),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: dotColor.withOpacity(0.15)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 6, height: 6, decoration: BoxDecoration(
        shape: BoxShape.circle, color: dotColor.withOpacity(0.7),
      )),
      const SizedBox(width: 8),
      Text(text, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w600)),
    ]),
  );

  Widget _traitTag(String text, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: c.withOpacity(0.12),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: c.withOpacity(0.22)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 5, height: 5, decoration: BoxDecoration(shape: BoxShape.circle, color: c.withOpacity(0.85))),
      const SizedBox(width: 7),
      Text(text, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11.5, fontWeight: FontWeight.w500)),
    ]),
  );

  // Motto
  String _getAnimalMotto(int idx) => const [
    'Gecenin en karanlık anında bile yolunu bulan, dünyayı sessizce yeniden şekillendiren ruhtur. Küçük adımlar, büyük imparatorluklar kurar.',
    'Toprağın derinliklerine kök salan ağaç, fırtınalara meydan okur. Senin gücün sabırda — zamanın kendisi senin müttefikindir.',
    'Ormanın kalbinde uyuyan bir volkan gibisin. Kükrediğinde dağlar titrer, ama asıl gücün — kontrollü sessizliğindedir.',
    'Ay ışığında açan çiçekler gibi, senin güzelliğin sessizlikte gizli. Dünyanın kaosunda huzuru yaratan nadir ruhlardansın.',
    'Gökyüzü senin tahtın, yıldızlar senin tacın. Sıradan olanla yetinmeyen ruhun, kaderi dönüştürme gücü taşır.',
    'Bin yıllık bilgeliği taşıyan ruhun, zamanın ötesinden fısıldar. Her kıvrımında bir sır, her bakışında bir kehanet saklıdır.',
    'Ufkun ötesinde bir özgürlük çağrısı duyarsın — rüzgâr senin şarkını söyler, yollar senin için açılır.',
    'Evrenin güzelliğini görebilen nadir bir göze sahipsin. Ellerinin dokunduğu her şey sanata, ruhunun değdiği her an şiire dönüşür.',
    'Kaostan düzen, karmaşadan çözüm yaratırsın. Zekân bir kılıç, esprin bir zırh — hayatı büyük bir oyuna dönüştüren ustasın.',
    'Şafak sökmeden önce uyanır, karanlıkta ışığı ilk sen görürsün. Cesaretin ve doğruluğun, yeni çağların habercisidir.',
    'Kalbinde taşıdığın sadakat ateşi, sönmeyen bir meşaledir. Sevdiklerinin kalkanı, kaybolmuşların pusolası — ruhun saf altındır.',
    'Cömertliğin sınır tanımaz, kalbin bir okyanus kadar geniştir. Varlığınla dünyayı ısıtan, dokunduğun her ruha şifa veren bir ışıksın.',
  ][idx];

  // RPG stat'ları
  Map<String, Map<String, dynamic>> _getRpgStats(int idx) {
    const stats = [
      {'z': 92, 'g': 55, 's': 60, 'e': 78, 'i': 75}, // Sıçan
      {'z': 68, 'g': 90, 's': 72, 'e': 65, 'i': 58}, // Öküz
      {'z': 75, 'g': 95, 's': 50, 'e': 90, 'i': 65}, // Kaplan
      {'z': 78, 'g': 45, 's': 92, 'e': 55, 'i': 88}, // Tavşan
      {'z': 85, 'g': 92, 's': 55, 'e': 95, 'i': 70}, // Ejderha
      {'z': 90, 'g': 60, 's': 48, 'e': 58, 'i': 95}, // Yılan
      {'z': 70, 'g': 82, 's': 65, 'e': 95, 'i': 60}, // At
      {'z': 72, 'g': 48, 's': 90, 'e': 55, 'i': 85}, // Keçi
      {'z': 95, 'g': 65, 's': 58, 'e': 85, 'i': 72}, // Maymun
      {'z': 80, 'g': 72, 's': 55, 'e': 78, 'i': 68}, // Horoz
      {'z': 70, 'g': 75, 's': 92, 'e': 72, 'i': 80}, // Köpek
      {'z': 65, 'g': 55, 's': 95, 'e': 68, 'i': 75}, // Domuz
    ];
    final s = stats[idx];
    return {
      'Zekâ': {'val': s['z']},
      'Güç': {'val': s['g']},
      'Şefkat': {'val': s['s']},
      'Enerji': {'val': s['e']},
      'Sezgi': {'val': s['i']},
    };
  }

  // Şans öğeleri
  Widget _luckyItem(String emoji, String value) => Expanded(
    child: Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 16)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(color: _goldL, fontSize: 12, fontWeight: FontWeight.w600)),
    ]),
  );

  Widget _luckyDot() => Container(
    width: 3, height: 3,
    decoration: BoxDecoration(shape: BoxShape.circle, color: _gold.withOpacity(0.2)),
  );

  Widget _infoChip(String emoji, String label, String value) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(18),
      border: Border.all(color: _gold.withOpacity(0.1)),
    ),
    child: Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 20)),
      const SizedBox(height: 6),
      Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
      const SizedBox(height: 2),
      Text(value, textAlign: TextAlign.center, style: TextStyle(color: _goldL, fontSize: 12, fontWeight: FontWeight.w700)),
    ]),
  ));

  Widget _chip(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      color: _crimson.withOpacity(0.1), borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _gold.withOpacity(0.2)),
    ),
    child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
  );

  Widget _nameChip(String name, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    decoration: BoxDecoration(
      color: c.withOpacity(0.08), borderRadius: BorderRadius.circular(20),
      border: Border.all(color: c.withOpacity(0.25)),
    ),
    child: Text(name, style: TextStyle(color: c, fontSize: 15, fontWeight: FontWeight.w700)),
  );

  Widget _secHead(String emoji, String title) => Row(children: [
    Text(emoji, style: const TextStyle(fontSize: 18)),
    const SizedBox(width: 8),
    Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
  ]);

  Widget _miniHead(String emoji, String title) => Row(children: [
    Text(emoji, style: const TextStyle(fontSize: 14)),
    const SizedBox(width: 6),
    Text(title, style: TextStyle(color: _goldL, fontSize: 14, fontWeight: FontWeight.w700)),
  ]);

  Widget _bulletItem(String text, Color c) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 6, height: 6, margin: const EdgeInsets.only(top: 6, right: 8), decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
      Expanded(child: Text(text, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, height: 1.4))),
    ]),
  );

  Widget _adviceRow(String emoji, String season, String advice) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(emoji, style: const TextStyle(fontSize: 20)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(season, style: TextStyle(color: _goldL, fontSize: 14, fontWeight: FontWeight.w700)),
        Text(advice, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
      ])),
    ]),
  );

  Widget _elementCycleRow(String relation, String target, Color c) {
    final tData = ChineseZodiacData.elements[target]!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Text(ChineseZodiacData.elements[_userElement]!['emoji'] as String, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(relation, style: TextStyle(color: c, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Text(tData['emoji'] as String, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 6),
        Text(target, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
      ]),
    );
  }

  Widget _compatCardCreative(String title, String pct, List<int> indices, Color c, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.03),
        border: Border.all(color: c.withOpacity(0.15), width: 0.5),
      ),
      child: Row(children: [
        // Sol aksent şerit
        Container(
          width: 4,
          height: 90,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [c.withOpacity(0.8), c.withOpacity(0.2)],
            ),
          ),
        ),
        Expanded(child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Başlık satırı
            Row(children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, color: c.withOpacity(0.12),
                  boxShadow: [BoxShadow(color: c.withOpacity(0.15), blurRadius: 10)],
                ),
                child: Icon(icon, color: c.withOpacity(0.8), size: 14),
              ),
              const SizedBox(width: 10),
              Text(title, style: TextStyle(color: c, fontSize: 15, fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8), color: c.withOpacity(0.12),
                ),
                child: Text(pct, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ]),
            const SizedBox(height: 12),
            // Hayvan avatarları
            Row(children: indices.map((i) {
              final animal = ChineseZodiacData.animals[i];
              return Expanded(child: Column(children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      c.withOpacity(0.1), Colors.transparent,
                    ]),
                    border: Border.all(color: c.withOpacity(0.2), width: 1),
                  ),
                  child: Center(child: Text(animal['emoji'] as String, style: const TextStyle(fontSize: 24))),
                ),
                const SizedBox(height: 5),
                Text(animal['name'] as String, style: TextStyle(
                  color: Colors.white.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w600,
                )),
              ]));
            }).toList()),
          ]),
        )),
      ]),
    );
  }

  Widget _chainTier(String label, List<int> indices, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: c.withOpacity(0.04),
        border: Border.all(color: c.withOpacity(0.12), width: 0.5),
      ),
      child: Column(children: [
        Text(label, style: TextStyle(
          color: c, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1,
        )),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(
          indices.length * 2 - 1, (idx) {
            if (idx.isOdd) {
              // Yatay bağlantı çizgisi
              return Container(width: 16, height: 1, color: c.withOpacity(0.15));
            }
            final i = indices[idx ~/ 2];
            final animal = ChineseZodiacData.animals[i];
            return Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.withOpacity(0.08),
                  border: Border.all(color: c.withOpacity(0.3), width: 1),
                  boxShadow: [BoxShadow(color: c.withOpacity(0.1), blurRadius: 8)],
                ),
                child: Center(child: Text(animal['emoji'] as String, style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(height: 4),
              Text(animal['name'] as String, style: TextStyle(
                color: Colors.white.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.w600,
              )),
            ]);
          },
        )),
      ]),
    );
  }

  Widget _miniScoreLabel(String text, Color c) => Row(children: [
    Container(width: 5, height: 5, decoration: BoxDecoration(
      shape: BoxShape.circle, color: c,
      boxShadow: [BoxShadow(color: c.withOpacity(0.4), blurRadius: 4)],
    )),
    const SizedBox(width: 6),
    Text(text, style: TextStyle(color: c.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w700)),
  ]);

  Widget _crystalOrb(Map<String, dynamic> animal, Color c, int score) {
    return Column(children: [
      Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.4),
            colors: [
              c.withOpacity(0.15),
              c.withOpacity(0.06),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          border: Border.all(color: c.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(color: c.withOpacity(0.1), blurRadius: 14, spreadRadius: 2),
            BoxShadow(color: c.withOpacity(0.06), blurRadius: 6),
          ],
        ),
        child: Stack(children: [
          // Işık yansıması
          Positioned(top: 6, left: 10, child: Container(
            width: 14, height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: LinearGradient(colors: [
                Colors.white.withOpacity(0.12), Colors.transparent,
              ]),
            ),
          )),
          Center(child: Text(animal['emoji'] as String, style: const TextStyle(fontSize: 24))),
        ]),
      ),
      const SizedBox(height: 5),
      Text(animal['name'] as String, style: TextStyle(
        color: Colors.white.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.w600,
      )),
      Text('%$score', style: TextStyle(
        color: c.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.w800,
      )),
    ]);
  }

  Widget _barRow(Map<String, dynamic> animal, int score, Color c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Text(animal['emoji'] as String, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        SizedBox(
          width: 48,
          child: Text(animal['name'] as String, style: TextStyle(
            color: Colors.white.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w600,
          )),
        ),
        const SizedBox(width: 8),
        Expanded(child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Stack(children: [
            Container(height: 4, decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(2),
            )),
            FractionallySizedBox(widthFactor: score / 100, child: Container(
              height: 4, decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(colors: [c.withOpacity(0.3), c]),
                boxShadow: [BoxShadow(color: c.withOpacity(0.3), blurRadius: 4)],
              ),
            )),
          ]),
        )),
        const SizedBox(width: 8),
        Text('$score', style: TextStyle(
          color: c.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w700,
        )),
      ]),
    );
  }

  Widget _medalBadge(Map<String, dynamic> animal, Color c, String pct) {
    return Column(children: [
      Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: c.withOpacity(0.06),
          border: Border.all(color: c.withOpacity(0.35), width: 2),
          boxShadow: [
            BoxShadow(color: c.withOpacity(0.12), blurRadius: 10, spreadRadius: 1),
          ],
        ),
        child: Center(
          child: Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: c.withOpacity(0.15), width: 0.5),
            ),
            child: Center(child: Text(animal['emoji'] as String, style: const TextStyle(fontSize: 22))),
          ),
        ),
      ),
      const SizedBox(height: 5),
      Text(animal['name'] as String, style: TextStyle(
        color: Colors.white.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.w600,
      )),
      Container(
        margin: const EdgeInsets.only(top: 3),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: c.withOpacity(0.1),
        ),
        child: Text(pct, style: TextStyle(
          color: c.withOpacity(0.7), fontSize: 8, fontWeight: FontWeight.w800,
        )),
      ),
    ]);
  }

  Widget _miniScoreCard(Map<String, dynamic> animal, int score, Color c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: c.withOpacity(0.05),
          border: Border.all(color: c.withOpacity(0.12), width: 0.5),
        ),
        child: Column(children: [
          SizedBox(
            width: 44, height: 44,
            child: Stack(children: [
              CustomPaint(
                size: const Size(44, 44),
                painter: _MiniRingPainter(score / 100, c),
              ),
              Center(child: Text(animal['emoji'] as String, style: const TextStyle(fontSize: 20))),
            ]),
          ),
          const SizedBox(height: 5),
          Text(animal['name'] as String, style: TextStyle(
            color: Colors.white.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.w600,
          )),
          Text('%$score', style: TextStyle(
            color: c.withOpacity(0.6), fontSize: 9, fontWeight: FontWeight.w800,
          )),
        ]),
      ),
    );
  }

  Widget _podiumFull(int animalIdx, String medal, Color c, double pillarH, String desc) {
    final animal = ChineseZodiacData.animals[animalIdx];
    return Column(mainAxisSize: MainAxisSize.min, children: [
      _animalIcon(animalIdx, 42),
      const SizedBox(height: 3),
      Text(animal['name'] as String, style: TextStyle(
        color: Colors.white.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.w600,
      )),
      Text(medal, style: const TextStyle(fontSize: 12)),
      Text(desc, style: TextStyle(
        color: c.withOpacity(0.5), fontSize: 8, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic,
      )),
      const SizedBox(height: 4),
      Container(
        width: double.infinity, height: pillarH,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [c.withOpacity(0.3), c.withOpacity(0.05)],
          ),
          border: Border(
            top: BorderSide(color: c.withOpacity(0.5), width: 1),
            left: BorderSide(color: c.withOpacity(0.12), width: 0.5),
            right: BorderSide(color: c.withOpacity(0.12), width: 0.5),
          ),
        ),
      ),
    ]);
  }

  Widget _podiumItem(Map<String, dynamic> animal, String medal, Color c, double pillarH) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(animal['emoji'] as String, style: const TextStyle(fontSize: 26)),
      const SizedBox(height: 2),
      Text(animal['name'] as String, style: TextStyle(
        color: Colors.white.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.w600,
      )),
      Text(medal, style: const TextStyle(fontSize: 12)),
      const SizedBox(height: 4),
      Container(
        width: double.infinity, height: pillarH,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [c.withOpacity(0.3), c.withOpacity(0.05)],
          ),
          border: Border(
            top: BorderSide(color: c.withOpacity(0.5), width: 1),
            left: BorderSide(color: c.withOpacity(0.12), width: 0.5),
            right: BorderSide(color: c.withOpacity(0.12), width: 0.5),
          ),
        ),
      ),
    ]);
  }

  Widget _podiumPlace(Map<String, dynamic> animal, int place, Color c, double height) {
    final medals = ['🥇', '🥈', '🥉'];
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      // Emoji
      Text(animal['emoji'] as String, style: const TextStyle(fontSize: 30)),
      const SizedBox(height: 4),
      Text(animal['name'] as String, style: TextStyle(
        color: Colors.white.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.w600,
      )),
      const SizedBox(height: 2),
      Text(medals[place - 1], style: const TextStyle(fontSize: 14)),
      const SizedBox(height: 6),
      // Sütun
      Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [c.withOpacity(0.25), c.withOpacity(0.06)],
          ),
          border: Border(
            top: BorderSide(color: c.withOpacity(0.4), width: 1),
            left: BorderSide(color: c.withOpacity(0.15), width: 0.5),
            right: BorderSide(color: c.withOpacity(0.15), width: 0.5),
          ),
          boxShadow: place == 1 ? [
            BoxShadow(color: c.withOpacity(0.15), blurRadius: 16),
          ] : null,
        ),
        child: Center(child: Text(
          '$place', style: TextStyle(
            color: c.withOpacity(0.3), fontSize: 32, fontWeight: FontWeight.w900,
          ),
        )),
      ),
    ]);
  }

  Widget _rankRow(int startRank, List<int> indices, Color c, String label) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: c.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
      const SizedBox(height: 8),
      Row(children: List.generate(indices.length, (idx) {
        final animal = ChineseZodiacData.animals[indices[idx]];
        return Expanded(child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 18, height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle, color: c.withOpacity(0.1),
              border: Border.all(color: c.withOpacity(0.25), width: 0.5),
            ),
            child: Center(child: Text('${startRank + idx}', style: TextStyle(
              color: c.withOpacity(0.5), fontSize: 8, fontWeight: FontWeight.w800,
            ))),
          ),
          const SizedBox(width: 4),
          Text(animal['emoji'] as String, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 3),
          Flexible(child: Text(animal['name'] as String, style: TextStyle(
            color: Colors.white.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.w500,
          ), overflow: TextOverflow.ellipsis)),
        ]));
      })),
    ]);
  }

  Widget _compatGroup(String title, List<int> indices, Color c) {
    return _glass(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(color: c, fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 10),
      Row(children: indices.map((i) {
        final a = ChineseZodiacData.animals[i];
        return Expanded(child: Column(children: [
          Text(a['emoji'] as String, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 4),
          Text(a['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        ]));
      }).toList()),
    ]));
  }

  Widget _tinderSection(String title, List<int> indices, Color c, int score) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Başlık
      Row(children: [
        Container(width: 3, height: 14, decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: c.withOpacity(0.6),
        )),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(color: c, fontSize: 14, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 10),
      // Kartlar — yatay kaydırılabilir
      SizedBox(
        height: 120,
        child: Row(children: List.generate(indices.length, (idx) {
          final i = indices[idx];
          final animal = ChineseZodiacData.animals[i];
          final rotation = (idx - (indices.length - 1) / 2) * 0.03;
          return Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Transform.rotate(
              angle: rotation,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white.withOpacity(0.04),
                  border: Border.all(color: c.withOpacity(0.2), width: 0.5),
                  boxShadow: [
                    BoxShadow(color: c.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(children: [
                  // Üst gradient şerit
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      gradient: LinearGradient(colors: [c.withOpacity(0.6), c.withOpacity(0.2)]),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Emoji
                  Text(animal['emoji'] as String, style: const TextStyle(fontSize: 32)),
                  const SizedBox(height: 6),
                  // İsim
                  Text(animal['name'] as String, style: TextStyle(
                    color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w600,
                  )),
                  const SizedBox(height: 4),
                  // Yüzde
                  Text('%$score', style: TextStyle(
                    color: c.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.w800,
                  )),
                ]),
              ),
            ),
          ));
        })),
      ),
    ]);
  }

  Widget _legendDot(String label, Color c) => Row(children: [
    Container(width: 6, height: 6, decoration: BoxDecoration(
      shape: BoxShape.circle, color: c,
      boxShadow: [BoxShadow(color: c.withOpacity(0.4), blurRadius: 4)],
    )),
    const SizedBox(width: 4),
    Text(label, style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 9, fontWeight: FontWeight.w600)),
  ]);

  Widget _fengShuiCard(String emoji, String label, String value) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _cardBg, borderRadius: BorderRadius.circular(18),
      border: Border.all(color: _gold.withOpacity(0.12)),
    ),
    child: Row(children: [
      Text(emoji, style: const TextStyle(fontSize: 24)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
        Text(value, style: TextStyle(color: _goldL, fontSize: 15, fontWeight: FontWeight.w600)),
      ])),
    ]),
  );



  TextStyle _bodyStyle() => TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 14, height: 1.65);
}

// ── Dev Yin-Yang Arka Plan — Cesur Kırmızı-Siyah ──
class _YinYangBgPainter extends CustomPainter {
  final Color crimson;
  final Color gold;
  _YinYangBgPainter({required this.crimson, required this.gold});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Derin siyah temel (Yin tarafı)
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFF06060A));

    // ── Yang tarafı: S-eğrisi ile bölünen kırmızı yarı ──
    // Klasik Yin-Yang: sağ üst kırmızı, S kıvrımıyla sol alta geçiyor
    final yangPath = Path()
      ..moveTo(w, 0)              // Sağ üst köşe
      ..lineTo(w * 0.5, 0)        // Üst ortaya gel
      // S-eğrisi: üstten ortaya sağa kıvrılarak
      ..cubicTo(
        w * 1.1, h * 0.12,       // Sağa doğru şişen kontrol noktası
        w * 1.05, h * 0.35,      // Sağda kalmaya devam
        w * 0.5, h * 0.5,        // Tam ortaya
      )
      // S-eğrisi: ortadan alta sola kıvrılarak
      ..cubicTo(
        w * -0.05, h * 0.65,     // Sola doğru şişen kontrol noktası
        w * -0.1, h * 0.88,      // Solda kalmaya devam
        w * 0.5, h,              // Alt ortaya
      )
      ..lineTo(w, h)             // Sağ alt köşe
      ..close();                 // Kapanış

    // Yang dolgusu — zengin kırmızı gradient (merkezi parlak, kenarlara doğru koyu)
    canvas.drawPath(yangPath, Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.4, -0.2),
        radius: 1.3,
        colors: [
          const Color(0xFFEF4444).withOpacity(0.22),
          const Color(0xFFDC2626).withOpacity(0.14),
          const Color(0xFFB91C1C).withOpacity(0.06),
        ],
        stops: const [0, 0.4, 1],
      ).createShader(Rect.fromLTWH(0, 0, w, h)));

    // İkinci katman — daha yoğun çekirdek (sağ üstte)
    canvas.drawPath(yangPath, Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.6, -0.5),
        radius: 0.8,
        colors: [
          const Color(0xFFEF4444).withOpacity(0.12),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h)));

    // ── S-eğrisi kenarı boyunca yumuşak kırmızı glow ──
    final glowPath = Path()
      ..moveTo(w * 0.5, 0)
      ..cubicTo(
        w * 1.1, h * 0.12,
        w * 1.05, h * 0.35,
        w * 0.5, h * 0.5,
      )
      ..cubicTo(
        w * -0.05, h * 0.65,
        w * -0.1, h * 0.88,
        w * 0.5, h,
      );
    // Geniş blur glow
    canvas.drawPath(glowPath, Paint()
      ..color = const Color(0xFFDC2626).withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 60
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30));
  }

  @override
  bool shouldRepaint(covariant _YinYangBgPainter old) => false;
}

// ── Özgün Sekme İkonları ──
class _TabIconPainter extends CustomPainter {
  final int index;
  final Color color;
  _TabIconPainter({required this.index, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.44;

    switch (index) {
      case 0: _drawSoul(canvas, cx, cy, r, p); break;
      case 1: _drawHeart(canvas, cx, cy, r, p); break;
      case 2: _drawStar(canvas, cx, cy, r, p); break;
      case 3: _drawHorse(canvas, cx, cy, r, p); break;
      case 4: _drawElements(canvas, cx, cy, r, p); break;
    }
  }

  // 0: Ruhun — Yin-Yang
  void _drawSoul(Canvas canvas, double cx, double cy, double r, Paint p) {
    canvas.drawCircle(Offset(cx, cy), r, p);
    final s = Path()
      ..moveTo(cx, cy - r)
      ..arcTo(Rect.fromCircle(center: Offset(cx, cy - r / 2), radius: r / 2), -math.pi / 2, math.pi, false)
      ..arcTo(Rect.fromCircle(center: Offset(cx, cy + r / 2), radius: r / 2), -math.pi / 2, -math.pi, false);
    canvas.drawPath(s, p);
    canvas.drawCircle(Offset(cx, cy - r / 2), r * 0.12, p..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(cx, cy + r / 2), r * 0.12, p);
    p.style = PaintingStyle.stroke;
  }

  // 1: 2026 — At profili (belirgin yele + baş)
  void _drawHorse(Canvas canvas, double cx, double cy, double r, Paint p) {
    p.strokeWidth = 1.6;
    final path = Path()
      // Boyun altı
      ..moveTo(cx - r * 0.6, cy + r * 0.9)
      // Boyun yukarı eğimli
      ..cubicTo(cx - r * 0.55, cy + r * 0.2, cx - r * 0.45, cy - r * 0.2, cx - r * 0.3, cy - r * 0.5)
      // Kulak sol
      ..lineTo(cx - r * 0.15, cy - r * 0.95)
      // Kulak tepesi
      ..lineTo(cx + r * 0.0, cy - r * 0.65)
      // Alın → burun önü
      ..cubicTo(cx + r * 0.25, cy - r * 0.6, cx + r * 0.5, cy - r * 0.35, cx + r * 0.55, cy - r * 0.05)
      // Burun ucu
      ..cubicTo(cx + r * 0.55, cy + r * 0.15, cx + r * 0.45, cy + r * 0.3, cx + r * 0.3, cy + r * 0.35)
      // Çene altı
      ..cubicTo(cx + r * 0.15, cy + r * 0.4, cx, cy + r * 0.35, cx - r * 0.15, cy + r * 0.5);
    canvas.drawPath(path, p);
    // Yele (3 dalgalı çizgi)
    for (int j = 0; j < 3; j++) {
      final yOff = j * r * 0.22;
      final mane = Path()
        ..moveTo(cx - r * 0.35 + j * r * 0.02, cy - r * 0.45 + yOff)
        ..cubicTo(
          cx - r * 0.55, cy - r * 0.3 + yOff,
          cx - r * 0.7, cy - r * 0.15 + yOff,
          cx - r * 0.6, cy - r * 0.05 + yOff,
        );
      canvas.drawPath(mane, p..strokeWidth = 1.0);
    }
    // Göz
    p.strokeWidth = 1.5;
    canvas.drawCircle(Offset(cx + r * 0.15, cy - r * 0.25), r * 0.07, p..style = PaintingStyle.fill);
    p.style = PaintingStyle.stroke;
  }

  // 2: Elementler — Dönen 5 element döngüsü (daire + 5 nokta + bağlantı okları)
  void _drawElements(Canvas canvas, double cx, double cy, double r, Paint p) {
    // Dış daire
    canvas.drawCircle(Offset(cx, cy), r, p);
    // 5 element noktası + kısa çizgiler
    for (int i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + (2 * math.pi * i / 5);
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      // Nokta
      canvas.drawCircle(Offset(x, y), r * 0.12, p..style = PaintingStyle.fill);
      // İç çizgi (merkezden dışarı)
      final ix = cx + r * 0.4 * math.cos(angle);
      final iy = cy + r * 0.4 * math.sin(angle);
      canvas.drawLine(Offset(ix, iy), Offset(x, y), p..style = PaintingStyle.stroke);
    }
    // Merkez nokta
    canvas.drawCircle(Offset(cx, cy), r * 0.1, p..style = PaintingStyle.fill);
    p.style = PaintingStyle.stroke;
  }

  // 3: Kader — Klasik kalp şekli
  void _drawHeart(Canvas canvas, double cx, double cy, double r, Paint p) {
    p.strokeWidth = 1.6;
    final hr = r * 1.05;
    final top = cy - hr * 0.35;
    final path = Path()
      ..moveTo(cx, cy + hr * 0.75)  // Alt uç
      // Sol lob
      ..cubicTo(
        cx - hr * 0.8, cy + hr * 0.2,
        cx - hr * 1.0, top - hr * 0.3,
        cx - hr * 0.5, top - hr * 0.35,
      )
      // Sol tepeden merkeze
      ..cubicTo(
        cx - hr * 0.15, top - hr * 0.38,
        cx, top - hr * 0.1,
        cx, top + hr * 0.05,
      )
      // Merkez tepeden sağ tepe
      ..cubicTo(
        cx, top - hr * 0.1,
        cx + hr * 0.15, top - hr * 0.38,
        cx + hr * 0.5, top - hr * 0.35,
      )
      // Sağ lob
      ..cubicTo(
        cx + hr * 1.0, top - hr * 0.3,
        cx + hr * 0.8, cy + hr * 0.2,
        cx, cy + hr * 0.75,
      );
    canvas.drawPath(path, p);
    p.strokeWidth = 1.5;
  }

  // 4: Günlük — Parlayan yıldız
  void _drawStar(Canvas canvas, double cx, double cy, double r, Paint p) {
    // 4 ana ışın
    for (int i = 0; i < 4; i++) {
      final angle = (math.pi / 2 * i) - math.pi / 2;
      canvas.drawLine(
        Offset(cx + r * 0.15 * math.cos(angle), cy + r * 0.15 * math.sin(angle)),
        Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)),
        p,
      );
    }
    // 4 çapraz kısa ışın
    for (int i = 0; i < 4; i++) {
      final angle = (math.pi / 2 * i) - math.pi / 4;
      canvas.drawLine(
        Offset(cx + r * 0.15 * math.cos(angle), cy + r * 0.15 * math.sin(angle)),
        Offset(cx + r * 0.55 * math.cos(angle), cy + r * 0.55 * math.sin(angle)),
        p..strokeWidth = 1.0,
      );
    }
    p.strokeWidth = 1.5;
    // Merkez daire
    canvas.drawCircle(Offset(cx, cy), r * 0.15, p..style = PaintingStyle.fill);
    p.style = PaintingStyle.stroke;
  }

  @override
  bool shouldRepaint(covariant _TabIconPainter old) => old.color != color || old.index != index;
}

// ── Özgün Stat İkonları (CustomPaint) ──
// Takımyıldız çizgileri çizen painter
// Kariyer İkonu — yükselen basamaklar + yıldız
class _CareerIconPainter extends CustomPainter {
  final Color color;
  _CareerIconPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Yükselen basamaklar (sol alttan sağ üste)
    final steps = Path()
      ..moveTo(w * 0.08, h * 0.88)
      ..lineTo(w * 0.08, h * 0.62)
      ..lineTo(w * 0.36, h * 0.62)
      ..lineTo(w * 0.36, h * 0.38)
      ..lineTo(w * 0.64, h * 0.38)
      ..lineTo(w * 0.64, h * 0.15)
      ..lineTo(w * 0.85, h * 0.15);
    canvas.drawPath(steps, paint);

    // Alt çizgi (zemin)
    canvas.drawLine(
      Offset(w * 0.08, h * 0.88),
      Offset(w * 0.85, h * 0.88),
      paint..color = color.withOpacity(0.2),
    );

    // Tepe yıldızı
    final starPaint = Paint()
      ..color = color.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    final sx = w * 0.82;
    final sy = h * 0.08;
    final sr = w * 0.07;
    final star = Path();
    for (int i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + i * 2 * math.pi / 5;
      final innerAngle = angle + math.pi / 5;
      if (i == 0) {
        star.moveTo(sx + sr * math.cos(angle), sy + sr * math.sin(angle));
      } else {
        star.lineTo(sx + sr * math.cos(angle), sy + sr * math.sin(angle));
      }
      star.lineTo(sx + sr * 0.4 * math.cos(innerAngle), sy + sr * 0.4 * math.sin(innerAngle));
    }
    star.close();
    canvas.drawPath(star, starPaint);
  }
  @override
  bool shouldRepaint(covariant _CareerIconPainter old) => old.color != color;
}

class _ConstellationPainter extends CustomPainter {
  final List<Offset> centers;
  final List<List<int>> connections;
  final List<Color> colors;
  _ConstellationPainter({required this.centers, required this.connections, required this.colors});
  @override
  void paint(Canvas canvas, Size size) {
    for (final conn in connections) {
      if (conn[0] >= centers.length || conn[1] >= centers.length) continue;
      final from = centers[conn[0]];
      final to = centers[conn[1]];
      final c1 = colors[conn[0] % colors.length];
      final c2 = colors[conn[1] % colors.length];
      // Glow çizgisi
      final glowPaint = Paint()
        ..shader = LinearGradient(colors: [c1.withOpacity(0.08), c2.withOpacity(0.08)])
            .createShader(Rect.fromPoints(from, to))
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawLine(from, to, glowPaint);
      // Ana çizgi
      final linePaint = Paint()
        ..shader = LinearGradient(colors: [c1.withOpacity(0.25), c2.withOpacity(0.25)])
            .createShader(Rect.fromPoints(from, to))
        ..strokeWidth = 1
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(from, to, linePaint);
    }
  }
  @override
  bool shouldRepaint(covariant _ConstellationPainter old) =>
      old.centers != centers || old.connections != connections;
}

class _StatIconPainter extends CustomPainter {
  final String statKey;
  final Color color;
  _StatIconPainter({required this.statKey, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.42;

    switch (statKey) {
      case 'Sezgi': _drawEye(canvas, cx, cy, r, p); break;
      case 'Zekâ': _drawBrain(canvas, cx, cy, r, p); break;
      case 'Şefkat': _drawLotus(canvas, cx, cy, r, p); break;
      case 'Enerji': _drawFlame(canvas, cx, cy, r, p); break;
      case 'Güç': _drawFist(canvas, cx, cy, r, p); break;
    }
  }

  // Sezgi — Mistik göz (üçüncü göz)
  void _drawEye(Canvas canvas, double cx, double cy, double r, Paint p) {
    // Göz şekli — badem
    final path = Path()
      ..moveTo(cx - r, cy)
      ..quadraticBezierTo(cx, cy - r * 0.7, cx + r, cy)
      ..quadraticBezierTo(cx, cy + r * 0.7, cx - r, cy);
    canvas.drawPath(path, p);
    // İris
    canvas.drawCircle(Offset(cx, cy), r * 0.3, p..style = PaintingStyle.fill);
    p.style = PaintingStyle.stroke;
    // Üst kirpikler — üç ışın
    for (int i = -1; i <= 1; i++) {
      final angle = -math.pi / 2 + i * 0.4;
      final lx = cx + r * 0.45 * math.cos(angle);
      final ly = cy + r * 0.45 * math.sin(angle);
      final ex = cx + r * 0.85 * math.cos(angle);
      final ey = cy + r * 0.85 * math.sin(angle);
      canvas.drawLine(Offset(lx, ly), Offset(ex, ey), p..strokeWidth = p.strokeWidth * 0.7);
    }
    p.strokeWidth = p.strokeWidth / 0.7;
  }

  // Zekâ — Beyin (stilize iki lob)
  void _drawBrain(Canvas canvas, double cx, double cy, double r, Paint p) {
    // Sol lob
    final left = Path()
      ..moveTo(cx, cy + r * 0.8)
      ..cubicTo(cx - r * 0.3, cy + r * 0.6, cx - r * 1.0, cy + r * 0.3, cx - r * 0.85, cy - r * 0.1)
      ..cubicTo(cx - r * 0.7, cy - r * 0.6, cx - r * 0.3, cy - r * 0.95, cx, cy - r * 0.7);
    canvas.drawPath(left, p);
    // Sağ lob
    final right = Path()
      ..moveTo(cx, cy + r * 0.8)
      ..cubicTo(cx + r * 0.3, cy + r * 0.6, cx + r * 1.0, cy + r * 0.3, cx + r * 0.85, cy - r * 0.1)
      ..cubicTo(cx + r * 0.7, cy - r * 0.6, cx + r * 0.3, cy - r * 0.95, cx, cy - r * 0.7);
    canvas.drawPath(right, p);
    // Merkez çizgi
    canvas.drawLine(Offset(cx, cy - r * 0.7), Offset(cx, cy + r * 0.8), p..strokeWidth = p.strokeWidth * 0.6);
    // Sol kıvrımlar
    final sw = p.strokeWidth;
    final fold1 = Path()
      ..moveTo(cx - r * 0.2, cy - r * 0.3)
      ..quadraticBezierTo(cx - r * 0.7, cy - r * 0.2, cx - r * 0.55, cy + r * 0.15);
    canvas.drawPath(fold1, p);
    // Sağ kıvrımlar
    final fold2 = Path()
      ..moveTo(cx + r * 0.2, cy - r * 0.3)
      ..quadraticBezierTo(cx + r * 0.7, cy - r * 0.2, cx + r * 0.55, cy + r * 0.15);
    canvas.drawPath(fold2, p);
    p.strokeWidth = sw / 0.6;
  }

  // Şefkat — Lotus çiçeği
  void _drawLotus(Canvas canvas, double cx, double cy, double r, Paint p) {
    // 5 taç yaprak — simetrik çiçek
    for (int i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + (2 * math.pi * i / 5);
      final petalPath = Path();
      petalPath.moveTo(cx, cy);
      // Yaprak ucu
      final tipX = cx + r * 0.9 * math.cos(angle);
      final tipY = cy + r * 0.9 * math.sin(angle);
      // Kontrol noktaları (genişlik)
      final perpAngle = angle + math.pi / 2;
      final c1x = cx + r * 0.45 * math.cos(angle) + r * 0.25 * math.cos(perpAngle);
      final c1y = cy + r * 0.45 * math.sin(angle) + r * 0.25 * math.sin(perpAngle);
      final c2x = cx + r * 0.45 * math.cos(angle) - r * 0.25 * math.cos(perpAngle);
      final c2y = cy + r * 0.45 * math.sin(angle) - r * 0.25 * math.sin(perpAngle);
      petalPath.quadraticBezierTo(c1x, c1y, tipX, tipY);
      petalPath.quadraticBezierTo(c2x, c2y, cx, cy);
      canvas.drawPath(petalPath, p);
    }
    // Merkez nokta
    canvas.drawCircle(Offset(cx, cy), r * 0.1, p..style = PaintingStyle.fill);
    p.style = PaintingStyle.stroke;
  }

  // Enerji — Alev (şimşek yerine daha özgün)
  void _drawFlame(Canvas canvas, double cx, double cy, double r, Paint p) {
    // Ana alev gövdesi
    final flame = Path()
      ..moveTo(cx, cy + r * 0.9)  // Alt
      ..cubicTo(cx - r * 0.5, cy + r * 0.3, cx - r * 0.6, cy - r * 0.1, cx - r * 0.2, cy - r * 0.5)
      ..cubicTo(cx - r * 0.05, cy - r * 0.7, cx, cy - r * 0.95, cx, cy - r * 0.95)
      ..cubicTo(cx, cy - r * 0.95, cx + r * 0.05, cy - r * 0.7, cx + r * 0.2, cy - r * 0.5)
      ..cubicTo(cx + r * 0.6, cy - r * 0.1, cx + r * 0.5, cy + r * 0.3, cx, cy + r * 0.9);
    canvas.drawPath(flame, p);
    // İç alev
    final inner = Path()
      ..moveTo(cx, cy + r * 0.5)
      ..cubicTo(cx - r * 0.15, cy + r * 0.1, cx - r * 0.2, cy - r * 0.15, cx, cy - r * 0.4)
      ..cubicTo(cx + r * 0.2, cy - r * 0.15, cx + r * 0.15, cy + r * 0.1, cx, cy + r * 0.5);
    canvas.drawPath(inner, p..strokeWidth = p.strokeWidth * 0.7);
    p.strokeWidth = p.strokeWidth / 0.7;
  }

  // Güç — Yumruk / kılıç kalkanı
  void _drawFist(Canvas canvas, double cx, double cy, double r, Paint p) {
    // Kalkan şekli
    final shield = Path()
      ..moveTo(cx, cy - r * 0.9)
      ..lineTo(cx + r * 0.8, cy - r * 0.5)
      ..cubicTo(cx + r * 0.8, cy + r * 0.2, cx + r * 0.4, cy + r * 0.7, cx, cy + r * 0.9)
      ..cubicTo(cx - r * 0.4, cy + r * 0.7, cx - r * 0.8, cy + r * 0.2, cx - r * 0.8, cy - r * 0.5)
      ..close();
    canvas.drawPath(shield, p);
    // İçindeki kılıç
    canvas.drawLine(
      Offset(cx, cy - r * 0.5),
      Offset(cx, cy + r * 0.45),
      p..strokeWidth = p.strokeWidth * 1.2,
    );
    // Kılıç kabzası
    canvas.drawLine(
      Offset(cx - r * 0.25, cy + r * 0.05),
      Offset(cx + r * 0.25, cy + r * 0.05),
      p,
    );
    p.strokeWidth = p.strokeWidth / 1.2;
  }

  @override
  bool shouldRepaint(covariant _StatIconPainter old) => old.statKey != statKey || old.color != color;
}

// ── Aura Kesikli Halka Painter ──
class _AuraRingPainter extends CustomPainter {
  final Color color;
  final int dashCount;
  final double radius;
  _AuraRingPainter({required this.color, required this.dashCount, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final dashAngle = (2 * math.pi) / dashCount;
    final gapRatio = 0.4; // Boşluk oranı
    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle;
      final sweepAngle = dashAngle * (1 - gapRatio);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AuraRingPainter old) => old.color != color;
}

// ── Yıldız Patlaması Radyal Çizgi Painter ──
class _StarBurstPainter extends CustomPainter {
  final Color color;
  final int rayCount;
  final double innerRadius;
  final double outerRadius;
  _StarBurstPainter({
    required this.color,
    required this.rayCount,
    required this.innerRadius,
    required this.outerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < rayCount; i++) {
      final angle = (2 * math.pi * i / rayCount) - math.pi / 2;
      final inner = Offset(
        cx + innerRadius * math.cos(angle),
        cy + innerRadius * math.sin(angle),
      );
      final outer = Offset(
        cx + outerRadius * math.cos(angle),
        cy + outerRadius * math.sin(angle),
      );
      canvas.drawLine(inner, outer, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarBurstPainter old) => old.color != color;
}

// ── Köşe Dekoratif Çizgi Painter ──
class _CornerAccentPainter extends CustomPainter {
  final Color color;
  final int corner; // 0=sol üst, 1=sağ üst, 2=sağ alt, 3=sol alt
  _CornerAccentPainter({required this.color, required this.corner});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final len = w * 0.65;

    final path = Path();
    switch (corner) {
      case 0: // Sol üst
        path.moveTo(0, len);
        path.lineTo(0, 0);
        path.lineTo(len, 0);
        break;
      case 1: // Sağ üst
        path.moveTo(w - len, 0);
        path.lineTo(w, 0);
        path.lineTo(w, len);
        break;
      case 2: // Sağ alt
        path.moveTo(w, h - len);
        path.lineTo(w, h);
        path.lineTo(w - len, h);
        break;
      case 3: // Sol alt
        path.moveTo(len, h);
        path.lineTo(0, h);
        path.lineTo(0, h - len);
        break;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerAccentPainter old) => old.color != color || old.corner != corner;
}

// ── Birleşik Profil Kartı — Tag'ler + Dönen Alıntılar ──
class _UnifiedProfileCard extends StatefulWidget {
  final List<String> quotes; // [0]=motto, [1..n]=personality
  final Color crimson;
  final Color gold;
  final Color goldL;
  final String element;
  final String yinYang;
  final int year;
  final VoidCallback onYearTap;
  const _UnifiedProfileCard({
    required this.quotes,
    required this.crimson,
    required this.gold,
    required this.goldL,
    required this.element,
    required this.yinYang,
    required this.year,
    required this.onYearTap,
  });
  @override
  State<_UnifiedProfileCard> createState() => _UnifiedProfileCardState();
}

class _UnifiedProfileCardState extends State<_UnifiedProfileCard>
    with SingleTickerProviderStateMixin {
  int _idx = 0;
  bool _slideForward = true;
  late AnimationController _timerCtrl;

  @override
  void initState() {
    super.initState();
    _timerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..addStatusListener((s) {
      if (s == AnimationStatus.completed) _advance();
    });
    _timerCtrl.forward();
  }

  void _advance() {
    if (!mounted) return;
    setState(() {
      _slideForward = true;
      _idx = (_idx + 1) % widget.quotes.length;
    });
    _timerCtrl.forward(from: 0);
  }

  void _goBack() {
    if (!mounted) return;
    setState(() {
      _slideForward = false;
      _idx = (_idx - 1 + widget.quotes.length) % widget.quotes.length;
    });
    _timerCtrl.forward(from: 0);
  }

  @override
  void dispose() {
    _timerCtrl.dispose();
    super.dispose();
  }

  Widget _ornamentalLine() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 30),
    child: SizedBox(
      height: 10,
      width: double.infinity,
      child: CustomPaint(
        painter: _WavePainter(color: widget.gold.withOpacity(0.25)),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final count = widget.quotes.length;
    final isMotto = _idx == 0;
    final elData = ChineseZodiacData.elements[widget.element]!;
    final elColor = Color(elData['color'] as int);
    final yyColor = widget.yinYang == 'Yin' ? const Color(0xFF7C3AED) : const Color(0xFFD97706);

    return GestureDetector(
      onTapUp: (details) {
        final w = context.size?.width ?? 300;
        if (details.localPosition.dx > w / 2) {
          _advance();
        } else {
          _goBack();
        }
      },
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! < -100) _advance();
        if (details.primaryVelocity! > 100) _goBack();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.14),
                  Colors.white.withOpacity(0.06),
                  Colors.white.withOpacity(0.03),
                ],
              ),
              border: Border.all(color: Colors.white.withOpacity(0.18), width: 0.6),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 35, offset: const Offset(0, 14)),
                BoxShadow(color: widget.crimson.withOpacity(0.03), blurRadius: 50, spreadRadius: -8),
              ],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                // ─ Etiketler — editorial style ─
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(widget.element.toUpperCase(), style: TextStyle(
                    color: elColor.withOpacity(0.75),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.5,
                  )),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(width: 0.5, height: 12, color: Colors.white.withOpacity(0.12)),
                  ),
                  Text(widget.yinYang.toUpperCase(), style: TextStyle(
                    color: yyColor.withOpacity(0.7),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.5,
                  )),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(width: 0.5, height: 12, color: Colors.white.withOpacity(0.12)),
                  ),
                  GestureDetector(
                    onTap: widget.onYearTap,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('${widget.year}', style: TextStyle(
                        color: widget.gold.withOpacity(0.7),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.5,
                      )),
                      const SizedBox(width: 5),
                      Icon(Icons.edit_rounded, size: 10, color: widget.gold.withOpacity(0.35)),
                    ]),
                  ),
                ]),

                // ─ Dekoratif çizgi ─
                _ornamentalLine(),

                // ─ Dönen alıntı ─
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(_slideForward ? 0.06 : -0.06, 0),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  ),
                  child: Text(
                    widget.quotes[_idx],
                    key: ValueKey(_idx),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      height: 1.65,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ─ İlerleme çubuğu ─
                AnimatedBuilder(
                  animation: _timerCtrl,
                  builder: (_, __) => Container(
                    height: 1.5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1),
                      color: Colors.white.withOpacity(0.05),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _timerCtrl.value,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1),
                          gradient: LinearGradient(
                            colors: [widget.crimson.withOpacity(0.45), widget.gold.withOpacity(0.55)],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // ─ Dot göstergeler ─
                Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(count, (i) {
                  final active = i == _idx;
                  return Container(
                    width: active ? 6 : 3.5,
                    height: active ? 6 : 3.5,
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active
                          ? widget.gold.withOpacity(0.7)
                          : Colors.white.withOpacity(0.12),
                      boxShadow: active
                          ? [BoxShadow(color: widget.gold.withOpacity(0.25), blurRadius: 4)]
                          : null,
                    ),
                  );
                })),
              ]),
          ),
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final Color color;
  _WavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final w = size.width;
    final cy = size.height / 2;
    const amp = 3.5;
    const segments = 60;

    path.moveTo(0, cy);
    for (int i = 0; i <= segments; i++) {
      final x = (i / segments) * w;
      final y = cy + amp * math.sin((i / segments) * math.pi * 6);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Kenarlarda solma efekti — segment bazlı opacity
    for (int i = 0; i < segments; i++) {
      final x1 = (i / segments) * w;
      final x2 = ((i + 1) / segments) * w;
      final y1 = cy + amp * math.sin((i / segments) * math.pi * 6);
      final y2 = cy + amp * math.sin(((i + 1) / segments) * math.pi * 6);
      final t = (i / segments);
      final fade = t < 0.15 ? t / 0.15 : (t > 0.85 ? (1 - t) / 0.15 : 1.0);
      canvas.drawLine(
        Offset(x1, y1), Offset(x2, y2),
        Paint()
          ..color = color.withOpacity(fade * (color.opacity))
          ..strokeWidth = 0.8
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CrescentPainter extends CustomPainter {
  final Color color;
  _CrescentPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.45;

    // Dış daire
    final outer = Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    // İç daire — sağa kaydırılmış
    final inner = Path()..addOval(Rect.fromCircle(center: Offset(cx + r * 0.55, cy), radius: r * 0.85));
    // Hilal = dış - iç
    final crescent = Path.combine(PathOperation.difference, outer, inner);

    canvas.drawPath(crescent, Paint()
      ..color = color
      ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final bool topLeft, topRight, bottomLeft, bottomRight;
  _CornerPainter({required this.color, this.topLeft = false, this.topRight = false, this.bottomLeft = false, this.bottomRight = false});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 0.8..strokeCap = StrokeCap.round;
    final w = size.width; final h = size.height;
    if (topLeft) {
      canvas.drawLine(Offset.zero, Offset(w, 0), p);
      canvas.drawLine(Offset.zero, Offset(0, h), p);
    }
    if (topRight) {
      canvas.drawLine(Offset(w, 0), Offset.zero, p);
      canvas.drawLine(Offset(w, 0), Offset(w, h), p);
    }
    if (bottomLeft) {
      canvas.drawLine(Offset(0, h), Offset(w, h), p);
      canvas.drawLine(Offset(0, h), Offset.zero, p);
    }
    if (bottomRight) {
      canvas.drawLine(Offset(w, h), Offset(0, h), p);
      canvas.drawLine(Offset(w, h), Offset(w, 0), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeartbeatPainter extends CustomPainter {
  final Color color;
  _HeartbeatPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final cy = size.height * 0.5;
    final p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1.2..strokeCap = StrokeCap.round;

    final path = Path();
    // EKG pattern: düz — P dalgası — QRS spike — düz
    // Normalize: 0-1 arası
    final points = <List<double>>[
      [0.0, 0], [0.08, 0], [0.10, -3], [0.12, 0], // P dalgası
      [0.16, 0], [0.18, 5], [0.20, -18], [0.22, 12], [0.24, -3], [0.26, 0], // QRS
      [0.30, 0], [0.32, 3], [0.35, 0], // T dalgası
      [0.50, 0], // düz
      [0.58, 0], [0.60, -3], [0.62, 0], // P dalgası 2
      [0.66, 0], [0.68, 5], [0.70, -18], [0.72, 12], [0.74, -3], [0.76, 0], // QRS 2
      [0.80, 0], [0.82, 3], [0.85, 0], // T dalgası 2
      [1.0, 0], // düz
    ];

    for (int i = 0; i < points.length; i++) {
      final x = points[i][0] * w;
      final y = cy + points[i][1];
      if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
    }

    canvas.drawPath(path, p);

    // İkinci hafif çizgi — biraz yukarıda
    final p2 = Paint()..color = color.withOpacity(color.opacity * 0.3)..style = PaintingStyle.stroke..strokeWidth = 0.5;
    final path2 = Path();
    for (int i = 0; i < points.length; i++) {
      final x = points[i][0] * w;
      final y = cy - 30 + points[i][1] * 0.4;
      if (i == 0) { path2.moveTo(x, y); } else { path2.lineTo(x, y); }
    }
    canvas.drawPath(path2, p2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RosePetalPainter extends CustomPainter {
  final Color color;
  _RosePetalPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final petals = <List<double>>[
      [0.12, 0.15, 14, 0.4, 0.06],
      [0.85, 0.10, 10, 1.2, 0.05],
      [0.75, 0.80, 16, 2.1, 0.07],
      [0.20, 0.70, 12, 3.5, 0.05],
      [0.55, 0.30, 8, 0.8, 0.04],
      [0.90, 0.55, 11, 4.2, 0.06],
      [0.08, 0.45, 9, 2.8, 0.04],
      [0.65, 0.90, 13, 1.6, 0.05],
      [0.40, 0.12, 7, 5.0, 0.03],
    ];
    for (final petal in petals) {
      final cx = petal[0] * size.width;
      final cy = petal[1] * size.height;
      final s = petal[2];
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(petal[3]);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: s, height: s * 0.55),
        Paint()..color = color.withOpacity(petal[4])..style = PaintingStyle.fill,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: s * 1.1, height: s * 0.6),
        Paint()..color = color.withOpacity(petal[4] * 0.5)..style = PaintingStyle.stroke..strokeWidth = 0.3,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MatchRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color bgColor;
  _MatchRingPainter({required this.progress, required this.color, required this.bgColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 4;
    // Arka plan halka
    canvas.drawCircle(center, r, Paint()..color = bgColor..style = PaintingStyle.stroke..strokeWidth = 3);
    // İlerleme yayı
    final rect = Rect.fromCircle(center: center, radius: r);
    canvas.drawArc(
      rect, -math.pi / 2, 2 * math.pi * progress, false,
      Paint()
        ..color = color.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    // Glow yayı
    canvas.drawArc(
      rect, -math.pi / 2, 2 * math.pi * progress, false,
      Paint()
        ..color = color.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EnvelopeFlapPainter extends CustomPainter {
  final Color flapColor;
  final Color lineColor;
  _EnvelopeFlapPainter({required this.flapColor, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Zarf kapağı — üçgen (açılmış halde, yukarı doğru V)
    final flapPath = Path()
      ..moveTo(0, h)           // sol alt
      ..lineTo(w / 2, 0)       // üst orta (sivri uç)
      ..lineTo(w, h)           // sağ alt
      ..close();

    // Kapak dolgusu
    canvas.drawPath(flapPath, Paint()..color = flapColor..style = PaintingStyle.fill);

    // Kapak kenar çizgileri
    final linePaint = Paint()..color = lineColor..style = PaintingStyle.stroke..strokeWidth = 0.5;
    canvas.drawLine(Offset(0, h), Offset(w / 2, 0), linePaint);
    canvas.drawLine(Offset(w / 2, 0), Offset(w, h), linePaint);

    // Alt kenarda ince yatay çizgi
    canvas.drawLine(Offset(0, h - 0.5), Offset(w, h - 0.5), Paint()..color = lineColor..strokeWidth = 0.3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EnvelopeFoldPainter extends CustomPainter {
  final Color lineColor;
  _EnvelopeFoldPainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = Paint()..color = lineColor..style = PaintingStyle.stroke..strokeWidth = 0.5;

    // Sol alt köşeden üst ortaya
    canvas.drawLine(Offset(0, h), Offset(w / 2, 0), p);
    // Sağ alt köşeden üst ortaya
    canvas.drawLine(Offset(w, h), Offset(w / 2, 0), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CompatWheelPainter extends CustomPainter {
  final int centerIdx;
  final List<int> best, good, bad;
  final double radius;
  final Offset center;
  _CompatWheelPainter({required this.centerIdx, required this.best, required this.good, required this.bad, required this.radius, required this.center});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < 12; i++) {
      if (i == centerIdx) continue;
      final angle = (i * 30 - 90) * math.pi / 180;
      final end = Offset(center.dx + radius * math.cos(angle), center.dy + radius * math.sin(angle));

      Color col;
      double width;
      double opacity;
      if (best.contains(i)) { col = const Color(0xFFE91E63); width = 1.5; opacity = 0.5; }
      else if (good.contains(i)) { col = const Color(0xFF4CAF50); width = 1.0; opacity = 0.35; }
      else if (bad.contains(i)) { col = const Color(0xFFFF9800); width = 0.8; opacity = 0.3; }
      else { col = const Color(0xFF78909C); width = 0.4; opacity = 0.12; }

      // Glow çizgi
      if (best.contains(i) || good.contains(i)) {
        canvas.drawLine(center, end, Paint()..color = col.withOpacity(opacity * 0.3)..strokeWidth = width + 4..strokeCap = StrokeCap.round..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
      }
      // Ana çizgi
      canvas.drawLine(center, end, Paint()..color = col.withOpacity(opacity)..strokeWidth = width..strokeCap = StrokeCap.round);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MiniRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  _MiniRingPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    // Arka plan halkası
    canvas.drawCircle(center, radius, Paint()
      ..color = color.withOpacity(0.08)..style = PaintingStyle.stroke..strokeWidth = 2.5);
    // İlerleme arkı
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, 2 * math.pi * progress, false,
      Paint()..color = color.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round,
    );
    // Glow
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, 2 * math.pi * progress, false,
      Paint()..color = color.withOpacity(0.15)..style = PaintingStyle.stroke..strokeWidth = 5..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AnimalIconPainter extends CustomPainter {
  final int animalIndex;
  final Color color;
  _AnimalIconPainter(this.animalIndex, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1.5..strokeCap = StrokeCap.round;
    final pf = Paint()..color = color.withOpacity(0.15)..style = PaintingStyle.fill;

    switch (animalIndex) {
      case 0: // Sıçan
        canvas.drawCircle(Offset(cx, cy + 2), 8, pf);
        canvas.drawCircle(Offset(cx, cy + 2), 8, p);
        canvas.drawOval(Rect.fromLTWH(cx - 10, cy - 10, 8, 10), p);
        canvas.drawOval(Rect.fromLTWH(cx + 2, cy - 10, 8, 10), p);
        final qt = Path()..moveTo(cx + 8, cy + 6)..cubicTo(cx + 18, cy + 2, cx + 14, cy - 8, cx + 20, cy - 6);
        canvas.drawPath(qt, p);
        canvas.drawCircle(Offset(cx - 3, cy), 1, Paint()..color = color);
        canvas.drawCircle(Offset(cx + 3, cy), 1, Paint()..color = color);
        break;
      case 1: // Öküz
        canvas.drawOval(Rect.fromLTWH(cx - 10, cy - 4, 20, 16), pf);
        canvas.drawOval(Rect.fromLTWH(cx - 10, cy - 4, 20, 16), p);
        final lh = Path()..moveTo(cx - 8, cy - 4)..quadraticBezierTo(cx - 14, cy - 16, cx - 4, cy - 12);
        final rh = Path()..moveTo(cx + 8, cy - 4)..quadraticBezierTo(cx + 14, cy - 16, cx + 4, cy - 12);
        canvas.drawPath(lh, p);
        canvas.drawPath(rh, p);
        canvas.drawCircle(Offset(cx, cy + 4), 2, p);
        break;
      case 2: // Kaplan
        canvas.drawCircle(Offset(cx, cy), 12, pf);
        canvas.drawCircle(Offset(cx, cy), 12, p);
        for (var i = -1; i <= 1; i++) {
          canvas.drawLine(Offset(cx + i * 5 - 1, cy - 8), Offset(cx + i * 5 + 1, cy - 2), p);
        }
        canvas.drawLine(Offset(cx - 10, cy - 6), Offset(cx - 12, cy - 14), p);
        canvas.drawLine(Offset(cx + 10, cy - 6), Offset(cx + 12, cy - 14), p);
        break;
      case 3: // Tavşan
        canvas.drawCircle(Offset(cx, cy + 4), 8, pf);
        canvas.drawCircle(Offset(cx, cy + 4), 8, p);
        canvas.drawOval(Rect.fromLTWH(cx - 7, cy - 18, 5, 16), p);
        canvas.drawOval(Rect.fromLTWH(cx + 2, cy - 18, 5, 16), p);
        break;
      case 4: // Ejderha
        canvas.drawCircle(Offset(cx - 2, cy - 2), 8, pf);
        canvas.drawCircle(Offset(cx - 2, cy - 2), 8, p);
        for (var i = -2; i <= 2; i++) {
          canvas.drawLine(Offset(cx - 2 + i * 4, cy - 10), Offset(cx - 2 + i * 3, cy - 16 + i.abs() * 2), p);
        }
        final sb = Path()..moveTo(cx + 6, cy + 2)..cubicTo(cx + 14, cy + 6, cx + 8, cy + 14, cx + 16, cy + 12);
        canvas.drawPath(sb, p);
        break;
      case 5: // Yılan
        final snake = Path()..moveTo(cx - 14, cy + 4)..cubicTo(cx - 6, cy - 10, cx + 6, cy + 10, cx + 14, cy - 4);
        canvas.drawPath(snake, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round);
        canvas.drawCircle(Offset(cx + 12, cy - 5), 1.5, Paint()..color = color);
        canvas.drawLine(Offset(cx + 14, cy - 4), Offset(cx + 18, cy - 6), p);
        canvas.drawLine(Offset(cx + 14, cy - 4), Offset(cx + 18, cy - 2), p);
        break;
      case 6: // At
        canvas.drawOval(Rect.fromLTWH(cx - 6, cy - 6, 12, 16), pf);
        canvas.drawOval(Rect.fromLTWH(cx - 6, cy - 6, 12, 16), p);
        for (var i = 0; i < 3; i++) {
          final mp = Path()..moveTo(cx - 6, cy - 4 + i * 4)..quadraticBezierTo(cx - 14, cy - 8 + i * 4, cx - 10, cy - 12 + i * 4);
          canvas.drawPath(mp, p);
        }
        canvas.drawLine(Offset(cx - 2, cy - 6), Offset(cx - 4, cy - 14), p);
        canvas.drawLine(Offset(cx + 2, cy - 6), Offset(cx + 4, cy - 14), p);
        break;
      case 7: // Keçi
        canvas.drawCircle(Offset(cx, cy + 2), 8, pf);
        canvas.drawCircle(Offset(cx, cy + 2), 8, p);
        final lg = Path()..moveTo(cx - 6, cy - 6)..quadraticBezierTo(cx - 16, cy - 14, cx - 8, cy - 16);
        final rg = Path()..moveTo(cx + 6, cy - 6)..quadraticBezierTo(cx + 16, cy - 14, cx + 8, cy - 16);
        canvas.drawPath(lg, p);
        canvas.drawPath(rg, p);
        canvas.drawLine(Offset(cx, cy + 10), Offset(cx, cy + 16), p);
        break;
      case 8: // Maymun
        canvas.drawCircle(Offset(cx, cy), 9, pf);
        canvas.drawCircle(Offset(cx, cy), 9, p);
        canvas.drawCircle(Offset(cx - 12, cy - 4), 5, p);
        canvas.drawCircle(Offset(cx + 12, cy - 4), 5, p);
        canvas.drawCircle(Offset(cx - 3, cy - 2), 1, Paint()..color = color);
        canvas.drawCircle(Offset(cx + 3, cy - 2), 1, Paint()..color = color);
        final smile = Path()..moveTo(cx - 3, cy + 3)..quadraticBezierTo(cx, cy + 6, cx + 3, cy + 3);
        canvas.drawPath(smile, p);
        break;
      case 9: // Horoz
        canvas.drawCircle(Offset(cx, cy), 8, pf);
        canvas.drawCircle(Offset(cx, cy), 8, p);
        final comb = Path()..moveTo(cx - 2, cy - 8)..lineTo(cx, cy - 14)..lineTo(cx + 2, cy - 8);
        canvas.drawPath(comb, p);
        canvas.drawLine(Offset(cx + 8, cy), Offset(cx + 14, cy + 2), p);
        canvas.drawLine(Offset(cx + 14, cy + 2), Offset(cx + 8, cy + 2), p);
        for (var i = 0; i < 3; i++) {
          final tf = Path()..moveTo(cx - 8, cy + 2)..quadraticBezierTo(cx - 16, cy - 4 + i * 6, cx - 12, cy - 8 + i * 6);
          canvas.drawPath(tf, p);
        }
        break;
      case 10: // Köpek
        canvas.drawCircle(Offset(cx, cy), 9, pf);
        canvas.drawCircle(Offset(cx, cy), 9, p);
        final le = Path()..moveTo(cx - 8, cy - 2)..quadraticBezierTo(cx - 16, cy, cx - 14, cy + 10);
        final re = Path()..moveTo(cx + 8, cy - 2)..quadraticBezierTo(cx + 16, cy, cx + 14, cy + 10);
        canvas.drawPath(le, p);
        canvas.drawPath(re, p);
        canvas.drawCircle(Offset(cx, cy + 2), 2, Paint()..color = color);
        break;
      case 11: // Domuz
        canvas.drawCircle(Offset(cx, cy + 2), 10, pf);
        canvas.drawCircle(Offset(cx, cy + 2), 10, p);
        canvas.drawOval(Rect.fromLTWH(cx - 4, cy, 8, 6), p);
        canvas.drawCircle(Offset(cx - 2, cy + 3), 0.8, Paint()..color = color);
        canvas.drawCircle(Offset(cx + 2, cy + 3), 0.8, Paint()..color = color);
        canvas.drawOval(Rect.fromLTWH(cx - 12, cy - 10, 8, 8), p);
        canvas.drawOval(Rect.fromLTWH(cx + 4, cy - 10, 8, 8), p);
        final tl = Path()..moveTo(cx + 10, cy + 4)..cubicTo(cx + 16, cy + 2, cx + 18, cy - 4, cx + 14, cy - 6);
        canvas.drawPath(tl, p);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
