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
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
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
                      const Color(0xFFE8DCC8).withOpacity(0.03 + pulse * 0.015),
                      const Color(0xFFE8DCC8).withOpacity(0.06 + pulse * 0.02),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.6, 0.8, 1.0],
                  ),
                ),
              ))),
              // Katman 2: Dekoratif halka — ince cream daire
              Positioned.fill(child: Center(child: Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE8DCC8).withOpacity(0.10 + pulse * 0.04),
                    width: 0.5,
                  ),
                ),
              ))),
              // Katman 3: İç halka — kesikli cream
              Positioned.fill(child: Center(child: CustomPaint(
                size: const Size(210, 210),
                painter: _AuraRingPainter(
                  color: const Color(0xFFE8DCC8).withOpacity(0.10 + pulse * 0.06),
                  dashCount: 36,
                  radius: 105,
                ),
              ))),
              // Katman 4: Koyu iç radyal glow — derinlik
              Positioned.fill(child: Center(child: Container(
                width: 180 + pulse * 6,
                height: 180 + pulse * 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF0A0505).withOpacity(0.35 + pulse * 0.05),
                      const Color(0xFF0A0505).withOpacity(0.18),
                      Colors.transparent,
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
                      color: const Color(0xFFE8DCC8).withOpacity(0.20 + pulse * 0.15),
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
      const SizedBox(height: 10),
      // Yıllar — tıklanabilir
      Center(child: GestureDetector(
        onTap: _showYearPicker,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _gold.withOpacity(0.12)),
            color: _gold.withOpacity(0.04),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(a['years'] as String, textAlign: TextAlign.center,
              style: TextStyle(color: _gold.withOpacity(0.5), fontSize: 11)),
            const SizedBox(width: 6),
            Icon(Icons.edit_outlined, size: 11, color: _gold.withOpacity(0.3)),
          ]),
        ),
      )),

      const SizedBox(height: 24),

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
            // Güçlü & Gelişim — iki sütun karşılaşma
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Sol — Güçlü yönler
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(Icons.shield_outlined, size: 12, color: const Color(0xFFCBB270).withOpacity(0.6)),
                  const SizedBox(width: 5),
                  Text('Güçlü Yönler', style: TextStyle(
                    color: const Color(0xFFCBB270).withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1,
                  )),
                ]),
                const SizedBox(height: 8),
                ...strengths.take(4).toList().asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(children: [
                    Container(
                      width: 16, height: 16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: const Color(0xFFCBB270).withOpacity(0.08),
                      ),
                      child: Center(child: Text('${e.key + 1}', style: TextStyle(
                        color: const Color(0xFFCBB270).withOpacity(0.5), fontSize: 8, fontWeight: FontWeight.w700,
                      ))),
                    ),
                    const SizedBox(width: 6),
                    Expanded(child: Text(e.value, style: TextStyle(
                      color: Colors.white.withOpacity(0.65), fontSize: 11, fontWeight: FontWeight.w500,
                    ))),
                  ]),
                )),
              ])),
              // Orta — ayırıcı çizgi
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  width: 0.5, height: 85,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.white.withOpacity(0.08), Colors.transparent],
                    ),
                  ),
                ),
              ),
              // Sağ — Gelişim alanları
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(Icons.trending_up_rounded, size: 12, color: const Color(0xFFB85C5C).withOpacity(0.6)),
                  const SizedBox(width: 5),
                  Text('Gelişim Alanı', style: TextStyle(
                    color: const Color(0xFFB85C5C).withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1,
                  )),
                ]),
                const SizedBox(height: 8),
                ...weaknesses.take(3).toList().asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(children: [
                    Container(
                      width: 16, height: 16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: const Color(0xFFB85C5C).withOpacity(0.08),
                      ),
                      child: Center(child: Text('${e.key + 1}', style: TextStyle(
                        color: const Color(0xFFB85C5C).withOpacity(0.5), fontSize: 8, fontWeight: FontWeight.w700,
                      ))),
                    ),
                    const SizedBox(width: 6),
                    Expanded(child: Text(e.value, style: TextStyle(
                      color: Colors.white.withOpacity(0.65), fontSize: 11, fontWeight: FontWeight.w500,
                    ))),
                  ]),
                )),
              ])),
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
          const Text('Kariyer Haritası', style: TextStyle(color: Color(0xFFE8DCC8), fontSize: 18, fontWeight: FontWeight.w700)),
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
      // ── Birleşik Hero + Enerji Paneli ──
      _glass(child: Column(children: [
        // ── Dekoratif üst çizgi ──
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 32, height: 0.5, decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.transparent, _goldL.withOpacity(0.2)]),
          )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('ATEŞ ATI YILI', style: TextStyle(
              color: _goldL.withOpacity(0.25), fontSize: 9,
              fontWeight: FontWeight.w700, letterSpacing: 2.5,
            )),
          ),
          Container(width: 32, height: 0.5, decoration: BoxDecoration(
            gradient: LinearGradient(colors: [_goldL.withOpacity(0.2), Colors.transparent]),
          )),
        ]),
        const SizedBox(height: 16),
        // ── At ikonu ──
        Container(
          width: 110, height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [const Color(0xFFE53935).withOpacity(0.2), const Color(0xFFE53935).withOpacity(0.06), Colors.transparent],
              stops: const [0.0, 0.45, 1.0],
              radius: 0.85,
            ),
          ),
          child: Center(child: _animalIcon(6, 90)),
        ),
        const SizedBox(height: 12),
        // ── 2026 · AT YILI — element renkli ──
        Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(width: 24, height: 0.5, decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.transparent, const Color(0xFFE53935).withOpacity(0.2)]),
          )),
          const SizedBox(width: 10),
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFFE53935)],
            ).createShader(b),
            child: const Text('2026', style: TextStyle(
              color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900,
              height: 1, letterSpacing: 2,
            )),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(width: 4, height: 4, decoration: BoxDecoration(
              shape: BoxShape.circle, color: const Color(0xFFE53935).withOpacity(0.35),
            )),
          ),
          Text('AT YILI', style: TextStyle(
            color: _goldL.withOpacity(0.45), fontSize: 14,
            fontWeight: FontWeight.w700, letterSpacing: 3,
          )),
          const SizedBox(width: 10),
          Container(width: 24, height: 0.5, decoration: BoxDecoration(
            gradient: LinearGradient(colors: [const Color(0xFFE53935).withOpacity(0.2), Colors.transparent]),
          )),
        ]),
        const SizedBox(height: 16),
        // ── İnce ayırıcı ──
        Container(height: 0.5, margin: const EdgeInsets.symmetric(horizontal: 20), decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.transparent, _goldL.withOpacity(0.12), Colors.transparent,
          ]),
        )),
        const SizedBox(height: 14),
        // ── Açıklama ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('Ateş Atı yılı; enerji, özgürlük ve hareketlilik temalı bir dönem. Cesur adımlar atanları ödüllendirir.',
            textAlign: TextAlign.center, style: _bodyStyle()),
        ),
        const SizedBox(height: 20),
        // ── Yılın Özü — 3 Nitelik Şeridi ──
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [
                const Color(0xFFE53935).withOpacity(0.06),
                Colors.white.withOpacity(0.03),
                const Color(0xFFE53935).withOpacity(0.04),
              ],
            ),
            border: Border.all(color: const Color(0xFFE53935).withOpacity(0.1), width: 0.6),
          ),
          child: Row(children: [
            // ── Ruhun Alevi — Element ──
            Expanded(child: Column(children: [
              SizedBox(
                width: 32, height: 32,
                child: CustomPaint(painter: _YearFlameIconPainter()),
              ),
              const SizedBox(height: 8),
              Text('Ateş', style: TextStyle(color: _goldL, fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text('Ruhun Alevi', style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 8, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
            ])),
            // ── Dekoratif bağlayıcı ──
            Container(
              width: 20, height: 0.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [const Color(0xFFE53935).withOpacity(0.15), _goldL.withOpacity(0.15)]),
              ),
            ),
            // ── Kozmik Denge — Kutupluluk ──
            Expanded(child: Column(children: [
              SizedBox(
                width: 32, height: 32,
                child: CustomPaint(painter: _YearYinYangIconPainter()),
              ),
              const SizedBox(height: 8),
              Text('Yang', style: TextStyle(color: _goldL, fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text('Kozmik Denge', style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 8, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
            ])),
            // ── Dekoratif bağlayıcı ──
            Container(
              width: 20, height: 0.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [_goldL.withOpacity(0.15), const Color(0xFFFFD54F).withOpacity(0.15)]),
              ),
            ),
            // ── Akış Enerjisi — Tema ──
            Expanded(child: Column(children: [
              SizedBox(
                width: 32, height: 32,
                child: CustomPaint(painter: _YearBoltIconPainter()),
              ),
              const SizedBox(height: 8),
              Text('Hareket', style: TextStyle(color: _goldL, fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text('Akış Enerjisi', style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 8, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
            ])),
          ]),
        ),
      ])),
      const SizedBox(height: 20),
      // ── Etkileşim — Premium Karşılaşma Kartı ──
      Builder(builder: (context) {
        // Element renkleri
        final myElColor = Color(ChineseZodiacData.elements[_userElement]!['color'] as int);
        const yearElColor = Color(0xFFE53935); // Ateş
        return _glass(child: Column(children: [
          // ── Üst etiket ──
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 28, height: 0.5, decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.transparent, myElColor.withOpacity(0.25)]),
            )),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text('YILLIK ETKİLEŞİM', style: TextStyle(
                color: _goldL.withOpacity(0.3), fontSize: 9,
                fontWeight: FontWeight.w700, letterSpacing: 2,
              )),
            ),
            Container(width: 28, height: 0.5, decoration: BoxDecoration(
              gradient: LinearGradient(colors: [yearElColor.withOpacity(0.25), Colors.transparent]),
            )),
          ]),
          const SizedBox(height: 18),
          // ── İki hayvan karşı karşıya ──
          SizedBox(
            height: 100,
            child: Stack(alignment: Alignment.center, children: [
              // ── Kozmik köprü ──
              Positioned.fill(child: CustomPaint(
                painter: _CosmicBridgePainter(
                  leftColor: myElColor.withOpacity(0.25),
                  rightColor: yearElColor.withOpacity(0.25),
                ),
              )),
              // ── Hayvan ikonları ──
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                // Sol — kullanıcının burcu (element renkli)
                Column(children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [myElColor.withOpacity(0.2), myElColor.withOpacity(0.05), Colors.transparent],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      border: Border.all(color: myElColor.withOpacity(0.2), width: 0.7),
                      boxShadow: [BoxShadow(color: myElColor.withOpacity(0.15), blurRadius: 16, spreadRadius: 2)],
                    ),
                    child: Center(child: _animalIcon(_animalIdx, 54)),
                  ),
                  const SizedBox(height: 6),
                  Text(_animal['name'] as String, style: TextStyle(
                    color: myElColor.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w600,
                  )),
                ]),
                // Orta — bağ sembolü
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [Colors.white.withOpacity(0.06), Colors.transparent],
                        ),
                        border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
                      ),
                      child: Center(child: SizedBox(
                        width: 18, height: 18,
                        child: CustomPaint(painter: _InteractionStarPainter(color: _goldL.withOpacity(0.45))),
                      )),
                    ),
                    const SizedBox(height: 8),
                    Text('2026', style: TextStyle(
                      color: yearElColor.withOpacity(0.45), fontSize: 10,
                      fontWeight: FontWeight.w800, letterSpacing: 1,
                    )),
                  ]),
                ),
                // Sağ — At yılı (ateş element renkli)
                Column(children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [yearElColor.withOpacity(0.2), yearElColor.withOpacity(0.05), Colors.transparent],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      border: Border.all(color: yearElColor.withOpacity(0.2), width: 0.7),
                      boxShadow: [BoxShadow(color: yearElColor.withOpacity(0.15), blurRadius: 16, spreadRadius: 2)],
                    ),
                    child: Center(child: _animalIcon(6, 54)),
                  ),
                  const SizedBox(height: 6),
                  Text('At', style: TextStyle(
                    color: yearElColor.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w600,
                  )),
                ]),
              ]),
            ]),
          ),
          const SizedBox(height: 14),
          // ── Dekoratif ayırıcı ──
          Container(height: 0.5, margin: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.transparent, myElColor.withOpacity(0.15), yearElColor.withOpacity(0.15), Colors.transparent,
            ]),
          )),
          const SizedBox(height: 14),
          // ── Etkileşim metni — sol çizgili alıntı tarzı ──
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 2, height: 50,
              margin: const EdgeInsets.only(top: 2, right: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1),
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [myElColor.withOpacity(0.5), yearElColor.withOpacity(0.2)],
                ),
              ),
            ),
            Expanded(child: Text(interaction,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6), fontSize: 13,
                height: 1.7, fontStyle: FontStyle.italic,
              ),
            )),
          ]),
        ]));
      }),
      const SizedBox(height: 20),
      // Yıl tavsiyeleri — kişiselleştirilmiş
      _glass(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Row(children: [
            SizedBox(width: 22, height: 22, child: CustomPaint(painter: _CompassIconPainter(color: _goldL.withOpacity(0.7)))),
            const SizedBox(width: 10),
            const Text('Mevsimlik Pusula', style: TextStyle(color: Color(0xFFE8DCC8), fontSize: 18, fontWeight: FontWeight.w700)),
          ]),
        ),
        const SizedBox(height: 12),
        ...ChineseZodiacData.yearSeasonalAdvice[_animalIdx].map((s) =>
          _adviceRow(s[0], s[1], s[2]),
        ),
      ])),
      const SizedBox(height: 24),
      // ── 2026 Zamanlama Rehberi ──
      Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Row(children: [
          SizedBox(width: 22, height: 22, child: CustomPaint(painter: _HourglassIconPainter(color: _goldL.withOpacity(0.7)))),
          const SizedBox(width: 10),
          const Text('2026 Zamanlama Rehberi', style: TextStyle(color: Color(0xFFE8DCC8), fontSize: 18, fontWeight: FontWeight.w700)),
        ]),
      ),
      const SizedBox(height: 12),
      ..._buildTimingCards(),
    ]);
  }

  List<Widget> _buildTimingCards() {
    final guideItems = ChineseZodiacData.yearTimingGuide[_animalIdx];
    final colors = [const Color(0xFFE53935), const Color(0xFFFF9800), const Color(0xFFFFEB3B), const Color(0xFF4CAF50), const Color(0xFF2E7D32)];
    final labels = ['Uygun Değil', 'Dikkatli Ol', 'Nötr', 'Uygun', 'Çok Uygun'];
    return guideItems.map((item) {
      final emoji = item[0] as String;
      final label = item[1] as String;
      final score = item[2] as int;
      final sc = colors[score - 1];
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: sc.withOpacity(0.06), borderRadius: BorderRadius.circular(16),
          border: Border.all(color: sc.withOpacity(0.2)),
        ),
        child: Row(children: [
          SizedBox(
            width: 28, height: 28,
            child: Center(child: SizedBox(
              width: 22, height: 22,
              child: CustomPaint(painter: _TimingIconPainter(emoji: emoji, color: sc)),
            )),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
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
  // 2) ELEMENT & YIN-YANG — FENG SHUİ MERKEZİ
  // ══════════════════════════════════════════
  Widget _elementSection() {
    final elData = ChineseZodiacData.elements[_userElement]!;
    final elColor = Color(elData['color'] as int);
    final fsProfile = ChineseZodiacData.fengShuiElementProfile[_userElement]!;
    final yyProfile = ChineseZodiacData.fengShuiYinYang[_userYinYang]!;
    final animalFs = ChineseZodiacData.animalFengShui[_animalIdx];
    final weeklyTask = ChineseZodiacData.weeklyFengShuiTask(_userElement, _userYinYang);
    final isYin = _userYinYang == 'Yin';
    final yyColor = isYin ? const Color(0xFFCFD8DC) : const Color(0xFFFFF5D1);

    // Günlük uyum skoru hesapla (deterministic)
    final today = DateTime.now();
    final seed = today.year * 1000 + today.month * 100 + today.day + _animalIdx * 7;
    final baseScore = 62 + (seed % 27); // 62-88 arası
    final elBonus = _userElement == 'Ateş' || _userElement == 'Ağaç' ? 5 : 0;
    final yyBonus = isYin ? 3 : 4;
    final harmonyScore = (baseScore + elBonus + yyBonus).clamp(0, 100);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      // ── MOD 1: KİŞİSEL ENERJİ + MEKAN EŞLEŞMESİ ──
      ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [
                  elColor.withOpacity(0.10),
                  yyColor.withOpacity(0.06),
                  Colors.transparent,
                ],
              ),
              border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.7),
            ),
            child: Column(children: [

              // ── HERO: İKİ ÖZGÜn İKON — Element & Yin-Yang ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
                child: SizedBox(
                  height: 120,
                  child: Stack(children: [

                    // ── Gradient köprü çizgisi (tam ortada dikey merkez) ──
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: CustomPaint(
                          size: const Size(120, 20),
                          painter: _EnergyBridgePainter(
                            elColor: elColor, yyColor: yyColor,
                          ),
                        ),
                      ),
                    ),

                    // ── Yin-Yang sembolü — tam merkez ──
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF120E1C),
                          boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.06), blurRadius: 8)],
                        ),
                        child: CustomPaint(painter: _YinYangMiniPainter(
                          yinColor: const Color(0xFF1a1a2e),
                          yangColor: const Color(0xFFE8E0D0),
                        )),
                      ),
                    ),

                    // ── SOL: Element İkonu ──
                    Positioned(left: 0, top: 0, bottom: 0,
                      child: SizedBox(width: 130, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        // Glow zemin (yuvarlak soft parlama)
                        Stack(alignment: Alignment.center, children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: elColor.withOpacity(0.35), blurRadius: 22)],
                            ),
                          ),
                          SizedBox(width: 72, height: 72,
                            child: CustomPaint(painter: _ElementIconPainter(element: _userElement, color: elColor)),
                          ),
                        ]),
                        const SizedBox(height: 10),
                        Text(_userElement, style: TextStyle(
                          color: elColor, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.3,
                        )),
                        const SizedBox(height: 1),
                        Text('Elementi', style: TextStyle(
                          color: Colors.white.withOpacity(0.3), fontSize: 9.5, letterSpacing: 1.2,
                        )),
                      ])),
                    ),

                    // ── SAĞ: Yin/Yang İkonu ──
                    Positioned(right: 0, top: 0, bottom: 0,
                      child: SizedBox(width: 130, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        // Glow zemin
                        Stack(alignment: Alignment.center, children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.15), blurRadius: 22)],
                            ),
                          ),
                          SizedBox(width: 72, height: 72,
                            child: CustomPaint(painter: _YinYangIconPainter(isYin: isYin)),
                          ),
                        ]),
                        const SizedBox(height: 10),
                        Text(_userYinYang, style: const TextStyle(
                          color: Color(0xFFCDCDD8), fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.3,
                        )),
                        const SizedBox(height: 1),
                        Text('Enerjisi', style: TextStyle(
                          color: Colors.white.withOpacity(0.3), fontSize: 9.5, letterSpacing: 1.2,
                        )),
                      ])),
                    ),

                  ]),
                ),
              ),

              const SizedBox(height: 24),

              // ── 3 ENERJİ KARTI (Baskın / Destekler / Yorar) ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _energyCard('dominant', 'Baskın', fsProfile['dominant'] as String),
                      const SizedBox(width: 8),
                      _energyCard('support', 'Destekler', fsProfile['supportEnergy'] as String),
                      const SizedBox(width: 8),
                      _energyCard('drain', 'Yorar', fsProfile['drainEnergy'] as String),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── İDEAL ALAN GÖRSEL ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(width: 3, height: 14, decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(2),
                    )),
                    const SizedBox(width: 8),
                    Text('İdeal Mekan', style: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5,
                    )),
                  ]),
                  const SizedBox(height: 10),
                  Container(
                    height: 110,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Stack(children: [
                      // Oda çizimi
                      Center(child: SizedBox(
                        width: 160, height: 90,
                        child: CustomPaint(painter: _RoomSketchPainter(color: Colors.white.withOpacity(0.5))),
                      )),
                      // Alan açıklaması
                      Positioned(bottom: 8, left: 12, right: 12,
                        child: Text(fsProfile['idealSpace'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 10.5),
                        ),
                      ),
                    ]),
                  ),
                ]),
              ),

              const SizedBox(height: 18),

              // ── RENK PALETİ ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(width: 3, height: 14, decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(2),
                    )),
                    const SizedBox(width: 8),
                    Text('Renk Paleti', style: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5,
                    )),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: (fsProfile['colors'] as List<String>).map((c) {
                    final colorVal = _colorFromNameEx(c, Colors.white);
                    return Expanded(child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Column(children: [
                        Container(
                          height: 32, width: double.infinity,
                          decoration: BoxDecoration(
                            color: colorVal,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(c, textAlign: TextAlign.center, style: TextStyle(
                          color: Colors.white.withOpacity(0.35), fontSize: 8.5,
                        )),
                      ]),
                    ));
                  }).toList()),
                ]),
              ),

              const SizedBox(height: 20),

              // ── 1 DAKİKALIK AKSİYON (CTA bottom bar) ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.white.withOpacity(0.0), Colors.white.withOpacity(0.04)],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24),
                  ),
                  border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1), width: 0.7)),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Center(child: Icon(Icons.bolt_rounded, size: 16, color: Colors.white.withOpacity(0.8))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('1 Dakikalık Aksiyon', style: TextStyle(
                      color: Colors.white.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5,
                    )),
                    const SizedBox(height: 4),
                    Text(fsProfile['miniAction'] as String, style: TextStyle(
                      color: Colors.white.withOpacity(0.8), fontSize: 13, height: 1.5,
                    )),
                  ])),
                ]),
              ),
            ]),
          ),
        ),
      ),

      const SizedBox(height: 16),


      // ── MOD 2: GÜNLÜK UYUM SKORU ──
      _glass(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('BUGÜNÜN ENERJİ UYUMU', style: TextStyle(
          color: _goldL.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2,
        )),
        const SizedBox(height: 16),
        Row(children: [
          // Skor yüzük
          SizedBox(width: 80, height: 80, child: Stack(alignment: Alignment.center, children: [
            CircularProgressIndicator(
              value: harmonyScore / 100,
              strokeWidth: 5,
              backgroundColor: Colors.white.withOpacity(0.06),
              valueColor: AlwaysStoppedAnimation(Color.lerp(const Color(0xFF4CAF50), _gold, harmonyScore / 100)!),
              strokeCap: StrokeCap.round,
            ),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text('$harmonyScore', style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800,
              )),
              Text('/100', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 9)),
            ]),
          ])),
          const SizedBox(width: 20),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _scoreRow('🟢', 'Kişisel enerji', harmonyScore > 75 ? 'Yüksek' : harmonyScore > 55 ? 'Orta' : 'Düşük'),
            const SizedBox(height: 6),
            _scoreRow('🔵', 'Element akışı', _userElement == 'Ateş' ? 'Aktif' : _userElement == 'Su' ? 'Derin' : 'Dengeli'),
            const SizedBox(height: 6),
            _scoreRow(isYin ? '🌙' : '☀️', 'Yin-Yang dengesi', isYin ? 'İçe dönük' : 'Dışa açık'),
            const SizedBox(height: 6),
            _scoreRow('🏠', 'Mekan uyumu', fsProfile['idealSpace'] as String),
          ])),
        ]),
        const SizedBox(height: 14),
        Container(height: 0.5, color: Colors.white.withOpacity(0.08)),
        const SizedBox(height: 12),
        // Feng shui önerisi
        Row(children: [
          Text('🧭', style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(child: Text(
            'Feng Shui önerisi: ${fsProfile['baguaFocus']}',
            style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12, height: 1.5),
          )),
        ]),
      ])),

      const SizedBox(height: 16),

      // ── MOD 3: YIN-YANG MEKAN REÇETESİ ──
      _glass(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(isYin ? '🌙' : '☀️', style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${_userYinYang} Enerjisi & Mekan', style: TextStyle(
              color: yyColor, fontSize: 15, fontWeight: FontWeight.w800,
            )),
            Text(yyProfile['state'] as String, style: TextStyle(
              color: Colors.white.withOpacity(0.4), fontSize: 11,
            )),
          ]),
        ]),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.15)),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('⚠️', style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 8),
            Expanded(child: Text(yyProfile['risk'] as String, style: TextStyle(
              color: Colors.white.withOpacity(0.7), fontSize: 12, height: 1.4,
            ))),
          ]),
        ),
        const SizedBox(height: 10),
        _fsBadge('🏠', 'Mekan ihtiyacın', yyProfile['spaceNeed'] as String, yyColor),
        const SizedBox(height: 8),
        _fsBadge('✨', 'Dengelemek için', yyProfile['activate'] as String, const Color(0xFF80CBC4)),
        const SizedBox(height: 8),
        _fsBadge('💡', 'Işık tavsiyen', yyProfile['lightTip'] as String, const Color(0xFFFFD54F)),
        const SizedBox(height: 8),
        _fsBadge('🔇', 'Ses tavsiyen', yyProfile['soundTip'] as String, const Color(0xFFCE93D8)),
        const SizedBox(height: 8),
        _fsBadge('🗑️', 'Bu hafta çıkar', yyProfile['declutter'] as String, const Color(0xFFEF9A9A)),
        const SizedBox(height: 8),
        _fsBadge('🎨', 'Sana yakışan renkler', yyProfile['color'] as String, yyColor),
      ])),

      const SizedBox(height: 16),

      // ── MOD 4: HEDEF BAZLI BAGUA SEÇİCİ ──
      _BaguaGoalSelector(
        goals: ChineseZodiacData.baguaGoals,
        elColor: elColor,
        goldL: _goldL,
        gold: _gold,
      ),

      const SizedBox(height: 16),

      // ── MOD 5: BURÇ BAZLI MEKAN GÜCÜ ──
      _glass(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(animalFs['animalEmoji'] as String, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${_animal['name']} — Mekan Profili', style: TextStyle(
              color: _goldL.withOpacity(0.85), fontSize: 15, fontWeight: FontWeight.w800,
            )),
            Text('Güç Köşen: ${animalFs['powerCorner']}', style: TextStyle(
              color: elColor.withOpacity(0.6), fontSize: 11,
            )),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: elColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: elColor.withOpacity(0.2)),
            ),
            child: Text(animalFs['powerColor'] as String, style: TextStyle(
              color: elColor, fontSize: 9, fontWeight: FontWeight.w700,
            )),
          ),
        ]),
        const SizedBox(height: 14),
        Container(height: 0.5, color: Colors.white.withOpacity(0.08)),
        const SizedBox(height: 12),
        _fsBadge('✨', 'Senin mekan enerjin', animalFs['spaceVibe'] as String, _goldL.withOpacity(0.8)),
        const SizedBox(height: 8),
        _fsBadge('💼', 'Çalışma alanın', animalFs['workSpace'] as String, const Color(0xFF80CBC4)),
        const SizedBox(height: 8),
        _fsBadge('💕', 'İlişki köşen', animalFs['loveSpace'] as String, const Color(0xFFCE93D8)),
        const SizedBox(height: 8),
        _fsBadge('🌀', 'Kaçın', animalFs['avoidEnergy'] as String, const Color(0xFFEF9A9A)),
        const SizedBox(height: 14),
        // Haftalık görev
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [elColor.withOpacity(0.1), yyColor.withOpacity(0.06)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _gold.withOpacity(0.15)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('BUGÜNÜN FENG SHUİ GÖREVİ', style: TextStyle(
              color: _goldL.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.5,
            )),
            const SizedBox(height: 8),
            Text(weeklyTask['task']!, style: TextStyle(
              color: Colors.white.withOpacity(0.85), fontSize: 13.5, height: 1.5,
            )),
          ]),
        ),
      ])),
    ]);
  }

  // Küçük enerji kartı (3'lü grid için) — sade beyaz tema, özgün ikon
  Widget _energyCard(String iconType, String label, String desc) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Özgün ikon (beyaz)
          SizedBox(
            width: 28, height: 28,
            child: CustomPaint(painter: _EnergyCardIconPainter(iconType: iconType, color: Colors.white.withOpacity(0.85))),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(
            color: Colors.white.withOpacity(0.9), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8,
          )),
          const SizedBox(height: 8),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9.5, height: 1.5),
          ),
        ],
      ),
    ),
  );


  // Renk adı → Color dönüştürücü (genişletilmiş)
  Color _colorFromNameEx(String name, Color fallback) {
    final map = {
      'Yeşil': const Color(0xFF4CAF50), 'Açık mavi': const Color(0xFF81D4FA),
      'Turkuaz': const Color(0xFF00BCD4), 'Bej': const Color(0xFFF5F0E8),
      'Kırmızı': const Color(0xFFE53935), 'Turuncu': const Color(0xFFFF9800),
      'Mor': const Color(0xFF9C27B0), 'Pembe': const Color(0xFFE91E63),
      'Altın': const Color(0xFFD4A017), 'Kahve': const Color(0xFF795548),
      'Sarı': const Color(0xFFFFEB3B), 'Bal rengi': const Color(0xFFFFB300),
      'Açık kiremit': const Color(0xFFBF7154), 'Krem': const Color(0xFFF5F0DC),
      'Beyaz': const Color(0xFFF8F8F8), 'Gri': const Color(0xFF90A4AE),
      'Gümüş': const Color(0xFFB0BEC5), 'Açık altın': const Color(0xFFE8D5A3),
      'Siyah': const Color(0xFF263238), 'Lacivert': const Color(0xFF1A237E),
      'Koyu mor': const Color(0xFF4A148C), 'Antrasit': const Color(0xFF37474F),
      'Koyu mavi': const Color(0xFF0D47A1),
    };
    return map[name] ?? fallback.withOpacity(0.6);
  }

  Widget _fsBadge(String emoji, String label, String value, Color accent) => Padding(

    padding: const EdgeInsets.only(bottom: 2),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(emoji, style: const TextStyle(fontSize: 13)),
      const SizedBox(width: 8),
      Expanded(child: RichText(text: TextSpan(children: [
        TextSpan(text: '$label  ', style: TextStyle(
          color: accent.withOpacity(0.75), fontSize: 11.5, fontWeight: FontWeight.w700,
        )),
        TextSpan(text: value, style: TextStyle(
          color: Colors.white.withOpacity(0.7), fontSize: 12, height: 1.5,
        )),
      ]))),
    ]),
  );

  Widget _scoreRow(String emoji, String label, String value) => Row(children: [
    Text(emoji, style: const TextStyle(fontSize: 11)),
    const SizedBox(width: 6),
    Text('$label: ', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
    Expanded(child: Text(value, style: TextStyle(
      color: Colors.white.withOpacity(0.75), fontSize: 11, fontWeight: FontWeight.w600,
    ), overflow: TextOverflow.ellipsis)),
  ]);





  // ══════════════════════════════════════════
  // 4) EVLİLİK UYUMU
  // ══════════════════════════════════════════
  Widget _compatibilitySection() {
    final a = _animal;
    final best = (a['bestMatch'] as List<int>);
    final good = (a['goodMatch'] as List<int>);
    final bad = (a['conflict'] as List<int>);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 12),
      // Aşk & İlişki — 💌 Aşk Mektubu
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0.08),
              Colors.white.withOpacity(0.03),
              const Color(0xFF2A1515).withOpacity(0.15),
            ],
          ),
          border: Border.all(color: const Color(0xFF8B6914).withOpacity(0.2), width: 0.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 12)),
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
              const Text('Aşk & İlişki', style: TextStyle(
                color: Color(0xFFE8DCC8), fontSize: 22, fontWeight: FontWeight.w300,
                letterSpacing: 3.0,
              )),
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
      ),
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
              const Text('Burç Uyum Haritası', style: TextStyle(
                color: Color(0xFFE8DCC8), fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 1,
              )),
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
              // ── İYİ UYUM — panel stili ──
              if (good.length > 1) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFD4A017).withOpacity(0.03),
                    border: Border.all(color: const Color(0xFFD4A017).withOpacity(0.1), width: 0.5),
                  ),
                  child: Column(children: [
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
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFFD4A017).withOpacity(0.03),
                          border: Border.all(color: const Color(0xFFD4A017).withOpacity(0.08), width: 0.5),
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
                  ]),
                ),
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
      // ── Detaylı Uyum Tablosu — Premium Tasarım ──
      ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.10),
                  Colors.white.withOpacity(0.04),
                  _crimson.withOpacity(0.03),
                ],
              ),
              border: Border.all(color: Colors.white.withOpacity(0.12), width: 0.6),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 12)),
              ],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Başlık
              Row(children: [
                SizedBox(width: 22, height: 22, child: CustomPaint(painter: _CompatChartIconPainter(color: _gold))),
                const SizedBox(width: 10),
                const Text('Detaylı Uyum Tablosu', style: TextStyle(
                  color: Color(0xFFE8DCC8), fontSize: 18, fontWeight: FontWeight.w700,
                )),
              ]),
              const SizedBox(height: 6),
              Text('Merak ettiğin burca dokun ✨', style: TextStyle(
                color: _gold.withOpacity(0.4), fontSize: 11, fontStyle: FontStyle.italic,
              )),
              const SizedBox(height: 16),
              // Hayvan seçim gridi — 2 satır 6 sütun
              ...List.generate(2, (row) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: List.generate(6, (col) {
                  final i = row * 6 + col;
                  Color borderC;
                  if (i == _animalIdx) borderC = _gold;
                  else if (best.contains(i)) borderC = const Color(0xFFC4A0AD);
                  else if (good.contains(i)) borderC = const Color(0xFFB8AD8E);
                  else if (bad.contains(i)) borderC = const Color(0xFF7B6B8A);
                  else borderC = const Color(0xFF8E99A4);
                  final selected = _selectedCompat == i;
                  final isMe = i == _animalIdx;
                  return Expanded(child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCompat = selected ? -1 : i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: selected ? borderC.withOpacity(0.12) : (isMe ? _gold.withOpacity(0.04) : Colors.transparent),
                          border: Border.all(
                            color: selected ? borderC.withOpacity(0.6) : (isMe ? _gold.withOpacity(0.18) : borderC.withOpacity(0.12)),
                            width: selected ? 1.5 : (isMe ? 0.8 : 0.5),
                          ),
                          boxShadow: selected ? [
                            BoxShadow(color: borderC.withOpacity(0.2), blurRadius: 12, spreadRadius: -2),
                          ] : null,
                        ),
                        child: _animalIcon(i, 36, opacity: selected ? 1.0 : (isMe ? 0.7 : 0.55)),
                      ),
                    ),
                  ));
                })),
              )),
              // Renk gösterge çubuğu
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 2),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _legendDot(_gold, 'Ben'),
                  const SizedBox(width: 10),
                  _legendDot(const Color(0xFFC4A0AD), 'Mükemmel'),
                  const SizedBox(width: 12),
                  _legendDot(const Color(0xFFB8AD8E), 'İyi'),
                  const SizedBox(width: 12),
                  _legendDot(const Color(0xFF6B9B9B), 'Nötr'),
                  const SizedBox(width: 12),
                  _legendDot(const Color(0xFF7B6B8A), 'Zorlayıcı'),
                ]),
              ),
              // ── Detay paneli — seçiliyse göster ──
              if (_selectedCompat >= 0) ...[
                const SizedBox(height: 16),
                // Dekoratif ayırıcı
                Container(height: 0.5, decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.transparent, _gold.withOpacity(0.2), Colors.transparent,
                  ]),
                )),
                const SizedBox(height: 16),
                Builder(builder: (ctx) {
                  final si = _selectedCompat;
                  final me = _animal;
                  final other = ChineseZodiacData.animals[si];
                  final myEl = me['fixedElement'] as String;
                  final otherEl = other['fixedElement'] as String;
                  final myTraits = (me['traits'] as List<String>);
                  final otherTraits = (other['traits'] as List<String>);
                  int baseScore; Color c; String label; String desc; String advice;
                  if (si == _animalIdx) {
                    baseScore = 100; c = Colors.white; label = 'Kendinle Uyum';
                    desc = 'Kendini tanımak en büyük güçtür. Aynı enerjinin iki yansıması — güçlü yanlarını da zayıf yanlarını da biliyorsun.';
                    advice = 'Kendine karşı dürüst ve şefkatli ol. En derin bağ, kendinle kurduğun bağdır. Güçlü yanlarını kutla, zayıf yanlarını kucakla.';
                  } else if (best.contains(si)) {
                    baseScore = 95; c = const Color(0xFFC4A0AD); label = 'Mükemmel Uyum';
                    desc = 'Bu burçla aranızda derin bir bağ var. Birbirini tamamlayan enerjiler güçlü bir çekim yaratır.';
                    advice = 'Bu eşsiz bağı korumak için birbirinize zaman ayırın. Enerjileriniz doğal olarak örtüşüyor — bunu kutlayın ve birlikte büyüyün.';
                  } else if (good.contains(si)) {
                    baseScore = 78; c = const Color(0xFFB8AD8E); label = 'İyi Uyum';
                    desc = 'Doğal bir uyum ve anlayış mevcut. Birlikte geçirilen zaman keyifli ve verimli olur.';
                    advice = 'İlişkinizi derinleştirmek için ortak hobiler keşfedin. Doğal uyumunuz güçlü — küçük jestlerle büyük anlar yaratabilirsiniz.';
                  } else if (bad.contains(si)) {
                    baseScore = 35; c = const Color(0xFF7B6B8A); label = 'Zorlayıcı';
                    desc = 'Bu ilişki sabır ve anlayış gerektirir. Farklılıklar büyümeyi de sağlar.';
                    advice = 'Sabır anahtarınız olsun. Farklılıklarınızı tehdit değil, zenginlik olarak görün. En güçlü bağlar zorlukları aşarak kurulur.';
                  } else {
                    baseScore = 58; c = const Color(0xFF6B9B9B); label = 'Nötr';
                    desc = 'Standart bir ilişki. Büyük çatışma yok ama özel bir çekim de hissedilmez.';
                    advice = 'Bu ilişkiye bilinçli emek verin. Ortak noktalar keşfettikçe bağınız güçlenebilir. Önyargısız yaklaşın.';
                  }
                  // Kategori puanları — base'den türetilmiş
                  final seed = (_animalIdx * 13 + si * 7) % 20;
                  final loveScore = (baseScore + (seed % 10) - 3).clamp(15, 100);
                  final friendScore = (baseScore + ((seed + 5) % 12) - 4).clamp(15, 100);
                  final workScore = (baseScore + ((seed + 3) % 8) - 2).clamp(15, 100);
                  final commScore = (baseScore + ((seed + 7) % 14) - 6).clamp(15, 100);
                  final avgScore = ((loveScore + friendScore + workScore + commScore) / 4).round();

                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // ── Hero: İki burç karşı karşıya ──
                    Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                      // Sol — kullanıcının burcu
                      Column(children: [
                        Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [_crimson.withOpacity(0.15), Colors.transparent],
                            ),
                            border: Border.all(color: _gold.withOpacity(0.15), width: 0.5),
                          ),
                          child: Center(child: _animalIcon(_animalIdx, 52)),
                        ),
                        const SizedBox(height: 6),
                        Text(me['name'] as String, style: TextStyle(
                          color: Colors.white.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w600,
                        )),
                      ]),
                      // Orta — Skor dairesi
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(children: [
                          Stack(alignment: Alignment.center, children: [
                            SizedBox(width: 64, height: 64, child: CircularProgressIndicator(
                              value: avgScore / 100,
                              strokeWidth: 3.5,
                              backgroundColor: Colors.white.withOpacity(0.06),
                              valueColor: AlwaysStoppedAnimation(c),
                              strokeCap: StrokeCap.round,
                            )),
                            Column(mainAxisSize: MainAxisSize.min, children: [
                              Text('$avgScore', style: TextStyle(
                                color: c, fontSize: 22, fontWeight: FontWeight.w800, height: 1,
                              )),
                              Text('puan', style: TextStyle(
                                color: c.withOpacity(0.5), fontSize: 8, fontWeight: FontWeight.w600,
                              )),
                            ]),
                          ]),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: c.withOpacity(0.12),
                              border: Border.all(color: c.withOpacity(0.25), width: 0.5),
                            ),
                            child: Text(label, style: TextStyle(
                              color: c, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.3,
                            )),
                          ),
                        ]),
                      ),
                      // Sağ — seçilen burç
                      Column(children: [
                        Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [c.withOpacity(0.15), Colors.transparent],
                            ),
                            border: Border.all(color: c.withOpacity(0.2), width: 0.5),
                          ),
                          child: Center(child: _animalIcon(si, 52)),
                        ),
                        const SizedBox(height: 6),
                        Text(other['name'] as String, style: TextStyle(
                          color: Colors.white.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w600,
                        )),
                      ]),
                    ])),
                    const SizedBox(height: 20),
                    // ── Açıklama ──
                    Center(child: Text(desc, textAlign: TextAlign.center, style: TextStyle(
                      color: Colors.white.withOpacity(0.45), fontSize: 12, height: 1.6,
                      fontStyle: FontStyle.italic,
                    ))),
                    const SizedBox(height: 20),
                    // Dekoratif ayırıcı
                    Container(height: 0.5, decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.transparent, c.withOpacity(0.15), Colors.transparent,
                      ]),
                    )),
                    const SizedBox(height: 18),
                    // ── Kategoriler — 4'lü uyum detayı ──
                    Text('Uyum Detayları', style: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5,
                    )),
                    const SizedBox(height: 14),
                    _compatCategory('Aşk & Romantizm', loveScore, c, _CompatCatType.love),
                    const SizedBox(height: 12),
                    _compatCategory('Dostluk & Sadakat', friendScore, c, _CompatCatType.friend),
                    const SizedBox(height: 12),
                    _compatCategory('İş & Kariyer', workScore, c, _CompatCatType.work),
                    const SizedBox(height: 12),
                    _compatCategory('İletişim & Anlayış', commScore, c, _CompatCatType.comm),
                    const SizedBox(height: 20),
                    // Dekoratif ayırıcı
                    Container(height: 0.5, decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.transparent, c.withOpacity(0.15), Colors.transparent,
                      ]),
                    )),
                    const SizedBox(height: 18),
                    // ── Element Karşılaştırması ──
                    Text('Element Etkileşimi', style: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5,
                    )),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white.withOpacity(0.03),
                        border: Border.all(color: Colors.white.withOpacity(0.06), width: 0.5),
                      ),
                      child: Row(children: [
                        // Sol element
                        Expanded(child: Column(children: [
                          Text(
                            ChineseZodiacData.elements[myEl]!['emoji'] as String,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(height: 4),
                          Text(myEl, style: TextStyle(
                            color: Color(ChineseZodiacData.elements[myEl]!['color'] as int).withOpacity(0.8),
                            fontSize: 13, fontWeight: FontWeight.w700,
                          )),
                          Text(me['name'] as String, style: TextStyle(
                            color: Colors.white.withOpacity(0.3), fontSize: 10,
                          )),
                        ])),
                        // Ortadaki ok / bağ
                        Column(children: [
                          SizedBox(
                            width: 40, height: 20,
                            child: CustomPaint(painter: _ElementBondPainter(
                              leftColor: Color(ChineseZodiacData.elements[myEl]!['color'] as int),
                              rightColor: Color(ChineseZodiacData.elements[otherEl]!['color'] as int),
                            )),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _elementRelationLabel(myEl, otherEl),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.45), fontSize: 9,
                              fontWeight: FontWeight.w700, letterSpacing: 0.3,
                            ),
                          ),
                        ]),
                        // Sağ element
                        Expanded(child: Column(children: [
                          Text(
                            ChineseZodiacData.elements[otherEl]!['emoji'] as String,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(height: 4),
                          Text(otherEl, style: TextStyle(
                            color: Color(ChineseZodiacData.elements[otherEl]!['color'] as int).withOpacity(0.8),
                            fontSize: 13, fontWeight: FontWeight.w700,
                          )),
                          Text(other['name'] as String, style: TextStyle(
                            color: Colors.white.withOpacity(0.3), fontSize: 10,
                          )),
                        ])),
                      ]),
                    ),
                    // Açıklayıcı cümle
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _elementRelationDesc(myEl, otherEl),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.35), fontSize: 11,
                          height: 1.5, fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Dekoratif ayırıcı
                    Container(height: 0.5, decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.transparent, c.withOpacity(0.15), Colors.transparent,
                      ]),
                    )),
                    const SizedBox(height: 18),
                    // ── Karakter Karşılaştırması — Trait Tag'ler ──
                    Text('Karakter Karşılaştırması', style: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5,
                    )),
                    const SizedBox(height: 12),
                    // VS karşılaşma düzeni
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      // Sol — kullanıcının özellikleri
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text(me['name'] as String, style: TextStyle(
                          color: Colors.white.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.w700,
                        )),
                        const SizedBox(height: 8),
                        ...myTraits.take(4).map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white.withOpacity(0.04),
                              border: Border.all(color: Colors.white.withOpacity(0.08), width: 0.5),
                            ),
                            child: Text(t, style: TextStyle(
                              color: Colors.white.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.w600,
                            )),
                          ),
                        )),
                      ])),
                      // Orta — VS çizgisi
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(children: [
                          const SizedBox(height: 2),
                          Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.04),
                              border: Border.all(color: Colors.white.withOpacity(0.08), width: 0.5),
                            ),
                            child: Center(child: Text('VS', style: TextStyle(
                              color: Colors.white.withOpacity(0.25), fontSize: 8,
                              fontWeight: FontWeight.w800, letterSpacing: 0.5,
                            ))),
                          ),
                          Container(
                            width: 0.5, height: 80,
                            margin: const EdgeInsets.only(top: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                colors: [Colors.white.withOpacity(0.08), Colors.transparent],
                              ),
                            ),
                          ),
                        ]),
                      ),
                      // Sağ — karşı tarafın özellikleri
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(other['name'] as String, style: TextStyle(
                          color: c.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.w700,
                        )),
                        const SizedBox(height: 8),
                        ...otherTraits.take(4).map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: c.withOpacity(0.05),
                              border: Border.all(color: c.withOpacity(0.12), width: 0.5),
                            ),
                            child: Text(t, style: TextStyle(
                              color: c.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.w600,
                            )),
                          ),
                        )),
                      ])),
                    ]),
                    const SizedBox(height: 20),
                    // Dekoratif ayırıcı
                    Container(height: 0.5, decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.transparent, c.withOpacity(0.15), Colors.transparent,
                      ]),
                    )),
                    const SizedBox(height: 16),
                    // ── Tavsiye Bölümü ──
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      // Sol dekoratif çizgi
                      Container(
                        width: 2, height: 50,
                        margin: const EdgeInsets.only(top: 2, right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: [c.withOpacity(0.5), c.withOpacity(0.05)],
                          ),
                        ),
                      ),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('İlişki Tavsiyesi', style: TextStyle(
                          color: c.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5,
                        )),
                        const SizedBox(height: 6),
                        Text(advice, style: TextStyle(
                          color: Colors.white.withOpacity(0.5), fontSize: 12, height: 1.6,
                          fontStyle: FontStyle.italic,
                        )),
                      ])),
                    ]),
                  ]);
                }),
              ],
            ]),
          ),
        ),
      ),
    ]);
  }

  Widget _dailySection() {
    final now = DateTime.now();
    final fortune = ChineseZodiacData.getDayFortune(_animalIdx, now);
    final c = fortune['color'] as Color;
    final mood = fortune['mood'] as Map<String, String>;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 12),

      // ── 1) Kozmik Fısıltı — Mistik mesaj ──
      _glass(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        // ── Tarih (en soluk ton) ──
        Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 24, height: 0.5, decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.transparent, _goldL.withOpacity(0.2)]),
          )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '${now.day} ${const ['Ocak','Şubat','Mart','Nisan','Mayıs','Haziran','Temmuz','Ağustos','Eylül','Ekim','Kasım','Aralık'][now.month - 1]} ${now.year}',
              style: TextStyle(
                color: _goldL.withOpacity(0.3),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.5,
              ),
            ),
          ),
          Container(width: 24, height: 0.5, decoration: BoxDecoration(
            gradient: LinearGradient(colors: [_goldL.withOpacity(0.2), Colors.transparent]),
          )),
        ]),
        const SizedBox(height: 8),
        // ── Yıldız (orta ton — Günlük tab ikonu ile aynı şekil) ──
        SizedBox(
          width: 22, height: 22,
          child: CustomPaint(painter: _DailyQuoteStarPainter()),
        ),
        const SizedBox(height: 10),
        // ── Günlük söz (en parlak ton) ──
        Text(fortune['whisper'] as String, textAlign: TextAlign.center,
          style: TextStyle(color: _goldL.withOpacity(0.8), fontSize: 15, fontStyle: FontStyle.italic, height: 1.5)),
      ]))),

      const SizedBox(height: 16),

      // ── 2) Günlük Şans Puanı (Ana kart) ──
      _glass(child: Column(children: [
        SizedBox(width: 60, height: 60, child: CustomPaint(painter: _FortuneIconPainter(level: fortune['level'] as String, color: c))),
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

      const SizedBox(height: 16),

      // ── 3) Ruh Hali Tahmini ──
      _glass(child: Row(children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [c.withOpacity(0.3), c.withOpacity(0.05)]),
          ),
          child: CustomPaint(painter: _MoodIconPainter(mood: mood['mood']!, color: c)),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Bugünkü Ruh Halin', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Text(mood['mood']!, style: TextStyle(color: _goldL, fontSize: 18, fontWeight: FontWeight.w700)),
          Text(mood['desc']!, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
        ])),
      ])),

      const SizedBox(height: 16),

      // ── 4) Enerji Ritmi — Dalga Grafiği ──
      _glass(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.bolt, color: _goldL.withOpacity(0.7), size: 18),
          const SizedBox(width: 6),
          Text('Enerji Ritmin', style: TextStyle(color: _goldL, fontSize: 15, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          width: double.infinity,
          child: CustomPaint(
            painter: _EnergyWavePainter(
              morning: fortune['morningEnergy'] as double,
              afternoon: fortune['afternoonEnergy'] as double,
              evening: fortune['eveningEnergy'] as double,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _energyLabel('Sabah', fortune['morningEnergy'] as double, const Color(0xFFFFB74D)),
          _energyLabel('Öğle', fortune['afternoonEnergy'] as double, const Color(0xFFFF8A65)),
          _energyLabel('Akşam', fortune['eveningEnergy'] as double, const Color(0xFF9575CD)),
        ]),
      ])),

      const SizedBox(height: 16),

      // ── 5) Yap / Yapma ──
      // ── 5) Yap / Yapma — İki Kart ──
      IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(child: _glass(child: Column(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4CAF50).withOpacity(0.15),
              border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
            ),
            child: const Icon(Icons.check, color: Color(0xFF4CAF50), size: 20),
          ),
          const SizedBox(height: 8),
          Text('YAP', style: TextStyle(color: const Color(0xFF4CAF50).withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(fortune['doAdvice'] as String, textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, height: 1.3)),
        ]))),
        const SizedBox(width: 12),
        Expanded(child: _glass(child: Column(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _crimson.withOpacity(0.15),
              border: Border.all(color: _crimson.withOpacity(0.3)),
            ),
            child: Icon(Icons.close, color: _crimson.withOpacity(0.8), size: 20),
          ),
          const SizedBox(height: 8),
          Text('YAPMA', style: TextStyle(color: _crimson.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(fortune['dontAdvice'] as String, textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, height: 1.3)),
        ]))),
      ])),

      const SizedBox(height: 16),

      // ── 6) Şanslı Saat · Sayılar · Renkler — Üçlü Elegant Kart ──
      ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.14),
                  Colors.white.withOpacity(0.06),
                  Colors.white.withOpacity(0.04),
                ],
              ),
              border: Border.all(color: Colors.white.withOpacity(0.18), width: 0.7),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 30, offset: const Offset(0, 12)),
              ],
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // ── Başlık ──
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(width: 28, height: 0.5, decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.transparent, _gold.withOpacity(0.3)]),
                  )),
                  const SizedBox(width: 10),
                  Text('✦', style: TextStyle(color: _goldL.withOpacity(0.3), fontSize: 8)),
                  const SizedBox(width: 8),
                  Text('Şans Rehberin', style: TextStyle(
                    color: _goldL.withOpacity(0.45), fontSize: 10,
                    fontWeight: FontWeight.w700, letterSpacing: 1.5,
                  )),
                  const SizedBox(width: 8),
                  Text('✦', style: TextStyle(color: _goldL.withOpacity(0.3), fontSize: 8)),
                  const SizedBox(width: 10),
                  Container(width: 28, height: 0.5, decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [_gold.withOpacity(0.3), Colors.transparent]),
                  )),
                ]),
              ),
              // ── 3 sütunlu içerik ──
              IntrinsicHeight(child: Row(children: [
              // ── Şanslı Saat ──
              Expanded(child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 10, 8, 16),
                child: Builder(builder: (context) {
                  final hourStr = fortune['luckyHour'] as String;
                  final hour = int.tryParse(hourStr.split(':').first) ?? 12;
                  final IconData timeIcon;
                  if (hour >= 6 && hour < 12) {
                    timeIcon = Icons.wb_sunny_outlined;
                  } else if (hour >= 12 && hour < 17) {
                    timeIcon = Icons.wb_sunny_rounded;
                  } else if (hour >= 17 && hour < 20) {
                    timeIcon = Icons.wb_twilight_rounded;
                  } else {
                    timeIcon = Icons.nightlight_round_outlined;
                  }
                  return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Text('Saat', style: TextStyle(
                      color: _goldL.withOpacity(0.4), fontSize: 9,
                      fontWeight: FontWeight.w700, letterSpacing: 1.5,
                    )),
                    const SizedBox(height: 8),
                    Text(hourStr, style: TextStyle(
                      color: _goldL, fontSize: 26,
                      fontWeight: FontWeight.w800, letterSpacing: 0.5,
                    )),
                    const SizedBox(height: 6),
                    Icon(timeIcon, color: _goldL.withOpacity(0.35), size: 18),
                  ]);
                }),
              )),
              // Dikey ayırıcı
              Container(width: 0.7, decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, _gold.withOpacity(0.15), _gold.withOpacity(0.15), Colors.transparent],
                  stops: const [0.1, 0.3, 0.7, 0.9],
                ),
              )),
              // ── Şanslı Sayılar ──
              Expanded(child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 10, 8, 16),
                child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Text('Sayılar', style: TextStyle(
                    color: _goldL.withOpacity(0.4), fontSize: 9,
                    fontWeight: FontWeight.w700, letterSpacing: 1.5,
                  )),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: (_animal['luckyNumbers'] as List<int>).map((n) =>
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: _gold.withOpacity(0.25), width: 0.8),
                        ),
                        child: Center(child: Text('$n', style: TextStyle(
                          color: _goldL, fontSize: 13, fontWeight: FontWeight.w700,
                        ))),
                      ),
                    ).toList(),
                  ),
                ]),
              )),
              // Dikey ayırıcı
              Container(width: 0.7, decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, _gold.withOpacity(0.15), _gold.withOpacity(0.15), Colors.transparent],
                  stops: const [0.1, 0.3, 0.7, 0.9],
                ),
              )),
              // ── Şanslı Renkler ──
              Expanded(child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 16),
                child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Text('Renkler', style: TextStyle(
                    color: _goldL.withOpacity(0.4), fontSize: 9,
                    fontWeight: FontWeight.w700, letterSpacing: 1.5,
                  )),
                  const SizedBox(height: 10),
                  ...(_animal['luckyColors'] as List<String>).map((c) {
                    final clr = _colorFromName(c);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Container(
                        width: double.infinity, height: 26,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          color: clr.withOpacity(0.3),
                          border: Border.all(color: clr.withOpacity(0.5), width: 1),
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                          Container(width: 6, height: 6, decoration: BoxDecoration(
                            shape: BoxShape.circle, color: clr,
                          )),
                          const SizedBox(width: 6),
                          Text(c, style: TextStyle(
                            color: Colors.white.withOpacity(0.85), fontSize: 10,
                            fontWeight: FontWeight.w600, letterSpacing: 0.3,
                          )),
                        ]),
                      ),
                    );
                  }),
                ]),
              )),
            ])),
            ]),
          ),
        ),
      ),

      const SizedBox(height: 16),

      // ── 7) Günün Meydan Okuması — Kompakt Görev Kartı ──
      _glass(child: Row(children: [
        // Sol — at ikonu
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [_gold.withOpacity(0.12), _crimson.withOpacity(0.08)]),
            border: Border.all(color: _gold.withOpacity(0.18), width: 0.6),
          ),
          child: Center(
            child: SizedBox(
              width: 26, height: 32,
              child: CustomPaint(painter: _ChallengeIconPainter(gold: _gold, goldL: _goldL)),
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Sağ — etiket + metin
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Senin için bir meydan okumamız var!', style: TextStyle(
            color: _goldL.withOpacity(0.5), fontSize: 10,
            fontWeight: FontWeight.w600, letterSpacing: 0.3,
          )),
          const SizedBox(height: 4),
          Text(fortune['challenge'] as String, style: TextStyle(
            color: Colors.white.withOpacity(0.85), fontSize: 13,
            fontWeight: FontWeight.w500, fontStyle: FontStyle.italic, height: 1.4,
          )),
        ])),
      ])),
    ]);
  }

  Widget _energyLabel(String label, double value, Color c) {
    return Column(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: c)),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
      Text('${(value * 100).toInt()}%', style: TextStyle(color: c, fontSize: 13, fontWeight: FontWeight.w700)),
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

  Color _colorFromName(String name) {
    const map = <String, Color>{
      'Kırmızı': Color(0xFFE53935), 'Mavi': Color(0xFF42A5F5),
      'Yeşil': Color(0xFF66BB6A), 'Sarı': Color(0xFFFDD835),
      'Altın': Color(0xFFD4A017), 'Turuncu': Color(0xFFFF9800),
      'Mor': Color(0xFF9C27B0), 'Beyaz': Color(0xFFEEEEEE),
      'Siyah': Color(0xFF616161), 'Gümüş': Color(0xFFBDBDBD),
      'Gri': Color(0xFF78909C),
      'Pembe': Color(0xFFEC407A), 'Lacivert': Color(0xFF1A237E),
      'Bordo': Color(0xFF880E4F), 'Kahverengi': Color(0xFF795548),
      'Turkuaz': Color(0xFF26C6DA), 'Bej': Color(0xFFD7CCC8),
      'Haki': Color(0xFF9E9D24), 'Eflatun': Color(0xFFAB47BC),
    };
    return map[name] ?? _goldL;
  }

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

  // Uyum tablosu — Gösterge noktası
  Widget _legendDot(Color c, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 6, height: 6, decoration: BoxDecoration(
      shape: BoxShape.circle, color: c.withOpacity(0.6),
    )),
    const SizedBox(width: 4),
    Text(label, style: TextStyle(
      color: Colors.white.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.w500,
    )),
  ]);

  // Uyum tablosu — Kategori satırı
  Widget _compatCategory(String label, int score, Color c, _CompatCatType type) {
    IconData icon;
    switch (type) {
      case _CompatCatType.love: icon = Icons.favorite_rounded; break;
      case _CompatCatType.friend: icon = Icons.people_rounded; break;
      case _CompatCatType.work: icon = Icons.work_rounded; break;
      case _CompatCatType.comm: icon = Icons.chat_bubble_rounded; break;
    }
    return Row(children: [
      Icon(icon, color: c.withOpacity(0.5), size: 14),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(label, style: TextStyle(
            color: Colors.white.withOpacity(0.55), fontSize: 11, fontWeight: FontWeight.w600,
          )),
          const Spacer(),
          Text('$score%', style: TextStyle(
            color: c.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w700,
          )),
        ]),
        const SizedBox(height: 5),
        ClipRRect(borderRadius: BorderRadius.circular(2), child: Stack(children: [
          Container(height: 3.5, decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(2),
          )),
          FractionallySizedBox(widthFactor: score / 100, child: Container(
            height: 3.5, decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(colors: [c.withOpacity(0.3), c.withOpacity(0.8)]),
              boxShadow: [BoxShadow(color: c.withOpacity(0.2), blurRadius: 4)],
            ),
          )),
        ])),
      ])),
    ]);
  }

  // Element ilişki — kısa etiket
  String _elementRelationLabel(String a, String b) {
    if (a == b) return 'Kardeş Ruh';
    final elData = ChineseZodiacData.elements[a]!;
    if (elData['generates'] == b) return 'Besleyici Bağ';
    if (elData['controls'] == b) return 'Yönlendirici Güç';
    if (elData['weakenedBy'] == b) return 'Dengeleyici Güç';
    final bData = ChineseZodiacData.elements[b]!;
    if (bData['generates'] == a) return 'Besleyici Bağ';
    if (bData['controls'] == a) return 'Yönlendirici Güç';
    return 'Bağımsız Akış';
  }

  // Element ilişki — açıklayıcı cümle
  String _elementRelationDesc(String a, String b) {
    if (a == b) return 'İkiniz de aynı enerjiden besleniyor. Birbirinizi sözlere gerek kalmadan anlıyorsunuz — bu nadir bir bağdır.';
    final elData = ChineseZodiacData.elements[a]!;
    if (elData['generates'] == b) return 'Senin varlığın onu güçlendiriyor, yanında olduğunda daha iyi hissediyor. Doğal bir destek kaynağısın.';
    if (elData['controls'] == b) return 'Senin bakış açın ona yön veriyor. Farkında olmadan onu etkiliyorsun — bu hem güç hem de sorumluluk.';
    if (elData['weakenedBy'] == b) return 'Bu ilişkide bazen kendini yorgun hissedebilirsin. Dengeyi korumak biraz çaba istiyor ama karşılığı var.';
    final bData = ChineseZodiacData.elements[b]!;
    if (bData['generates'] == a) return 'Onun varlığı seni güçlendiriyor, yanında olduğunda daha enerjik hissediyorsun. Doğal bir destek kaynağın.';
    if (bData['controls'] == a) return 'Onun fikirleri ve duruşu seni yönlendiriyor. Bu etki seni büyütür — eğer açık olabilirsen.';
    return 'İkiniz farklı dünyalardan geliyor. Birbirinizi keşfetmek zaman alır ama sürprizlerle dolu olabilir.';
  }

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
    Text(title, style: const TextStyle(color: Color(0xFFE8DCC8), fontSize: 18, fontWeight: FontWeight.w700)),
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

  Widget _adviceRow(String emoji, String season, String advice) {
    // Mevsime göre ikon ve renk
    final Map<String, Color> seasonColors = {
      'İlkbahar': const Color(0xFF66BB6A),
      'Yaz': const Color(0xFFFFB74D),
      'Sonbahar': const Color(0xFFE57C3A),
      'Kış': const Color(0xFF64B5F6),
    };
    final color = seasonColors[season] ?? _goldL;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 32, height: 32,
          child: Center(
            child: SizedBox(
              width: 24, height: 24,
              child: CustomPaint(painter: _SeasonIconPainter(season: season, color: color)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 1),
          Text(season, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(advice, style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 13, height: 1.5)),
        ])),
      ]),
    );
  }

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

    // Crisis Red arka plan (Yang tarafı — tüm ekran)
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.3),
        radius: 1.4,
        colors: [
          const Color(0xFFBC211F).withOpacity(0.28),
          const Color(0xFFA81C1A).withOpacity(0.18),
          const Color(0xFF901510).withOpacity(0.08),
        ],
        stops: const [0, 0.4, 1],
      ).createShader(Rect.fromLTWH(0, 0, w, h)));

    // ── Yin tarafı: S-eğrisi aşağıya kaydırılmış ──
    final yinPath = Path()
      ..moveTo(w, 0)
      ..lineTo(w * 0.55, 0)
      ..cubicTo(
        w * 1.1, h * 0.18,
        w * 1.05, h * 0.42,
        w * 0.5, h * 0.58,
      )
      ..cubicTo(
        w * -0.05, h * 0.72,
        w * -0.1, h * 0.92,
        w * 0.5, h,
      )
      ..lineTo(w, h)
      ..close();

    // Yin dolgusu — derin siyah
    canvas.drawPath(yinPath, Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.4, -0.2),
        radius: 1.3,
        colors: [
          const Color(0xFF06060A).withOpacity(0.97),
          const Color(0xFF06060A).withOpacity(0.90),
          const Color(0xFF06060A).withOpacity(0.78),
        ],
        stops: const [0, 0.5, 1],
      ).createShader(Rect.fromLTWH(0, 0, w, h)));

    // ── S-eğrisi kenarı boyunca yumuşak glow ──
    final glowPath = Path()
      ..moveTo(w * 0.55, 0)
      ..cubicTo(
        w * 1.1, h * 0.18,
        w * 1.05, h * 0.42,
        w * 0.5, h * 0.58,
      )
      ..cubicTo(
        w * -0.05, h * 0.72,
        w * -0.1, h * 0.92,
        w * 0.5, h,
      );
    // Geniş blur glow
    canvas.drawPath(glowPath, Paint()
      ..color = const Color(0xFFBC211F).withOpacity(0.10)
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

  void _showElementInfo(BuildContext ctx, String element, Color color) {
    final Map<String, Map<String, String>> ed = {
      'Ateş': {
        'emoji': '🔥',
        'title': 'Ateş Elementi',
        'desc': 'Ateş; tutku, dönüşüm ve liderliği simgeler. Bu enerjiyi taşıyanlar çevrelerine ışık ve coşku saçar — karizmatik, hırslı, ilham vericidir.',
        'traits': 'Cesur · Karizmatik · Tutkulu · Enerjik',
        'body': 'Kalp & İnce bağırsak — Çin tıbbına göre Ateş enerjisi kalbi besler; sağlıklı bir Ateş dengesi neşe, bağlantı ve güçlü dolaşım getirir.',
        'season': 'Yaz — güneşin en güçlü olduğu, hareketin ve sosyal enerjinin zirveye çıktığı dönem.',
        'dir': 'Güney',
      },
      'Su': {
        'emoji': '💧',
        'title': 'Su Elementi',
        'desc': 'Su; derinlik, sezgi ve uyum gücünü simgeler. Su insanları gizemli ve içe dönüktür; ancak aktığı her yere hayat verir.',
        'traits': 'Derin · Sezgisel · Empatik · Gizemli',
        'body': 'Böbrekler & Mesane — Çin tıbbına göre böbrekler yaşam enerjisinin (Jing) deposudur; Su dengesi dinçlik, kararlılık ve cinsel enerji sağlar.',
        'season': 'Kış — içe çekilme ve dinlenme zamanı; enerjiyi depo etmek için en uygun mevsim.',
        'dir': 'Kuzey',
      },
      'Toprak': {
        'emoji': '🌍',
        'title': 'Toprak Elementi',
        'desc': 'Toprak; merkeziyet, besleyicilik ve istikrarı simgeler. Toprak insanları çevrelerindeki herkese güven ve denge hissi yaşatır.',
        'traits': 'Sabırlı · Güvenilir · Besleyici · Pratik',
        'body': 'Mide & Dalak/Pankreas — Sindirim ve besin dönüşümünün merkezi. Dengeli Toprak enerjisi sağlıklı beslenme alışkanlıkları ve zihinsel netlik getirir.',
        'season': 'Mevsim geçişleri (her mevsim sonu) — değişim dönemlerinde özellikle güçlenir.',
        'dir': 'Merkez',
      },
      'Metal': {
        'emoji': '⚙️',
        'title': 'Metal Elementi',
        'desc': 'Metal; berraklık, disiplin ve mükemmeliyetçiliği simgeler. Metal insanları değerlere ve kurallara bağlıdır; kaliteyi her şeyin önünde tutar.',
        'traits': 'Disiplinli · Analitik · Güçlü · Titiz',
        'body': 'Akciğerler & Kalın bağırsak — Nefes ve arınmanın organları. Metal dengesi temiz bir zihin, güçlü bağışıklık ve sınırları koruma becerisi sağlar.',
        'season': 'Sonbahar — bırakma, özümseme ve özün geriye kalmasına bırakma dönemi.',
        'dir': 'Batı',
      },
      'Ağaç': {
        'emoji': '🌿',
        'title': 'Ağaç Elementi',
        'desc': 'Ağaç; büyüme, vizyon ve esnekliği simgeler. Ağaç insanları hayatta durmadan büyümek, kök salmak ve yeni şeyler inşa etmek için yaratılmıştır. Bir ağaç gibi hem esnerler hem de dik dururlar.',
        'traits': 'Yaratıcı · Vizyoner · İyimser · Esnek',
        'body': 'Karaciğer & Safra kesesi — Planlama ve karar vermenin enerjik merkezi. Dengeli Ağaç enerjisi öfkeyi salıverir, yaratıcılığı serbest bırakır ve net hedefler koymayı kolaylaştırır.',
        'season': 'İlkbahar — tohumların filizlendiği, yeni başlangıçların ve büyümenin mevsimi.',
        'dir': 'Doğu',
      },
    };
    final d = ed[element] ?? ed['Toprak']!;
    showDialog(
      context: ctx,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (dCtx) => GestureDetector(
        onTap: () => Navigator.of(dCtx).pop(),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: GestureDetector(
            onTap: () => Navigator.of(dCtx).pop(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.22), width: 0.8),
                      boxShadow: [BoxShadow(color: color.withOpacity(0.12), blurRadius: 30, spreadRadius: -4)],
                    ),
                    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text(d['emoji']!, style: const TextStyle(fontSize: 26)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(d['title']!, style: TextStyle(color: color, fontSize: 19, fontWeight: FontWeight.w800))),
                      ]),
                      const SizedBox(height: 12),
                      Container(height: 0.5, color: Colors.white.withOpacity(0.15)),
                      const SizedBox(height: 12),
                      Text(d['desc']!, style: TextStyle(color: Colors.white.withOpacity(0.82), fontSize: 13.5, height: 1.6)),
                      const SizedBox(height: 14),
                      _infoRow('✨', 'Kişilik', d['traits']!, color),
                      const SizedBox(height: 8),
                      _infoRow('🌸', 'En güçlü mevsim', d['season']!, color),
                      const SizedBox(height: 8),
                      _infoRow('🫀', 'Beden bağlantısı', d['body']!, color),
                      const SizedBox(height: 8),
                      _infoRow('🧭', 'Yön', d['dir']!, color),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showYinYangInfo(BuildContext ctx, String yy, Color color) {
    final isYin = yy == 'Yin';
    showDialog(
      context: ctx,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (dCtx) => GestureDetector(
        onTap: () => Navigator.of(dCtx).pop(),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: GestureDetector(
            onTap: () => Navigator.of(dCtx).pop(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.22), width: 0.8),
                      boxShadow: [BoxShadow(color: color.withOpacity(0.12), blurRadius: 30, spreadRadius: -4)],
                    ),
                    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text(isYin ? '🌙' : '☀️', style: const TextStyle(fontSize: 26)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(isYin ? 'Yin Enerjisi' : 'Yang Enerjisi', style: TextStyle(color: color, fontSize: 19, fontWeight: FontWeight.w800))),
                      ]),
                      const SizedBox(height: 12),
                      Container(height: 0.5, color: Colors.white.withOpacity(0.15)),
                      const SizedBox(height: 12),
                      Text(
                        isYin
                          ? 'Yin; alıcı, sessiz ve içe dönük enerjidir. Ay ve geceyle özdeşleşir. Yin taşıyan insanlar derin hisler, güçlü sezgi ve yaratıcı bir iç dünyaya sahiptir.'
                          : 'Yang; aktif, yayıcı ve dışa açılan enerjidir. Güneş ve gündüzle özdeşleşir. Yang taşıyan insanlar hareketi, liderliği ve toplumu besler.',
                        style: TextStyle(color: Colors.white.withOpacity(0.82), fontSize: 13.5, height: 1.6),
                      ),
                      const SizedBox(height: 14),
                      _infoRow('✨', 'Temel nitelikler', isYin ? 'Sezgisel · Derin · Sakin · Yaratıcı' : 'Girişken · Lider · Cesur · Enerjik', color),
                      const SizedBox(height: 8),
                      _infoRow('🕐', 'En güçlü zaman', isYin
                        ? 'Gece saatleri — zihin sessizleştiğinde Yin enerjisi zirveye çıkar; derin düşünce, sanatsal üretim ve içgörü için ideal zaman.'
                        : 'Gündüz saatleri — güneşin en parlak olduğu anlarda Yang enerjisi doruğa ulaşır; önemli kararlar, sosyal adımlar ve eylem bu zamana ait.', color),
                      const SizedBox(height: 8),
                      _infoRow('💡', 'Doğal güç', isYin
                        ? 'Dinleme, empati, strateji ve içsel keşif. Yin insanlar söylenmeyeni duyar.'
                        : 'Harekete geçme, ikna etme, liderlik ve kolektif enerji yaratma.', color),
                      const SizedBox(height: 8),
                      _infoRow('⚖️', 'Dengeyi bulmak', isYin
                        ? 'Yin enerji çok baskın olduğunda içe kapanma ve atalet riski doğar. Düzenli hareket (yürüyüş, dans), paylaşım ve küçük cesur adımlar dengeyi geri getirir.'
                        : 'Yang enerji çok baskın olduğunda tükenmişlik ve sabırsızlık riski doğar. Sessiz anlar, meditasyon ve dinleme pratiği dengeyi geri getirir.', color),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String emoji, String label, String value, Color accent) => Padding(
    padding: const EdgeInsets.only(bottom: 2),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(emoji, style: const TextStyle(fontSize: 13)),
      const SizedBox(width: 6),
      Expanded(child: RichText(text: TextSpan(children: [
        TextSpan(text: '$label  ', style: TextStyle(color: accent.withOpacity(0.75), fontSize: 12, fontWeight: FontWeight.w700)),
        TextSpan(text: value, style: TextStyle(color: Colors.white.withOpacity(0.72), fontSize: 12, height: 1.5)),
      ]))),
    ]),
  );



  @override
  Widget build(BuildContext context) {

    final count = widget.quotes.length;
    final isMotto = _idx == 0;
    final elData = ChineseZodiacData.elements[widget.element]!;
    final elColor = Color(elData['color'] as int);
    final yyColor = widget.yinYang == 'Yin' ? const Color(0xFFCFD8DC) : const Color(0xFFFFF5D1);

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
        child: Container(
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
            // ─ SABIT KISIM: Etiketler + Dalgalı çizgi ─
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  GestureDetector(
                    onTap: () => _showElementInfo(context, widget.element, elColor),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(widget.element.toUpperCase(), style: TextStyle(
                        color: elColor.withOpacity(0.75),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.5,
                      )),
                      const SizedBox(width: 4),
                      Icon(Icons.info_outline_rounded, size: 10, color: elColor.withOpacity(0.4)),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(width: 0.5, height: 12, color: Colors.white.withOpacity(0.12)),
                  ),
                  GestureDetector(
                    onTap: () => _showYinYangInfo(context, widget.yinYang, yyColor),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(widget.yinYang.toUpperCase(), style: TextStyle(
                        color: yyColor.withOpacity(0.7),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.5,
                      )),
                      const SizedBox(width: 4),
                      Icon(Icons.info_outline_rounded, size: 10, color: yyColor.withOpacity(0.4)),
                    ]),
                  ),
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
                    ]),        // outer Row children end
                  ),           // 3rd GestureDetector end
                ]),            // Padding's Row children end
              ),               // Padding end
            // ─ Dekoratif çizgi ─
            _ornamentalLine(),


                // ─ Dönen alıntı — sadece bu alan kaydırılabilir ─
                GestureDetector(
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
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
                    child: Column(children: [
                SizedBox(
                  height: 110,
                  child: Center(
                    child: AnimatedSwitcher(
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
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          height: 1.6,
                          letterSpacing: 0.2,
                        ),
                      ),
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
                    ]),          // Column children end (inside GestureDetector > Padding)
                  ),             // Padding end
              ),              // GestureDetector end
            ]),               // outer Column children end
          ),                  // Container end
        ),                    // BackdropFilter end
      );                      // ClipRRect end  
  }
}// ═══════════════════════════════════════════════════════
// BAGUA HEDEF SEÇİCİ — StatefulWidget
// ═══════════════════════════════════════════════════════
class _BaguaGoalSelector extends StatefulWidget {
  final Map<String, Map<String, String>> goals;
  final Color elColor;
  final Color goldL;
  final Color gold;
  const _BaguaGoalSelector({required this.goals, required this.elColor, required this.goldL, required this.gold});

  @override
  State<_BaguaGoalSelector> createState() => _BaguaGoalSelectorState();
}

class _BaguaGoalSelectorState extends State<_BaguaGoalSelector> {
  String _selectedGoal = 'Para';

  @override
  Widget build(BuildContext context) {
    final goal = widget.goals[_selectedGoal]!;
    final goalColor = _goalColor(_selectedGoal);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.12), width: 0.5),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Başlık
            Text('HEDEF BAZLI ALAN AKTİVASYONU', style: TextStyle(
              color: widget.goldL.withOpacity(0.35), fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2,
            )),
            const SizedBox(height: 4),
            Text('Bagua Haritası', style: TextStyle(
              color: widget.goldL.withOpacity(0.85), fontSize: 16, fontWeight: FontWeight.w800,
            )),
            const SizedBox(height: 14),
            // Hedef butonları
            Wrap(spacing: 8, runSpacing: 8, children: widget.goals.keys.map((key) {
              final isSelected = key == _selectedGoal;
              final g = widget.goals[key]!;
              return GestureDetector(
                onTap: () => setState(() => _selectedGoal = key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? _goalColor(key).withOpacity(0.18) : Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? _goalColor(key).withOpacity(0.5) : Colors.white.withOpacity(0.08),
                      width: isSelected ? 1 : 0.5,
                    ),
                  ),
                  child: Text('${g['emoji']} $key', style: TextStyle(
                    color: isSelected ? _goalColor(key) : Colors.white.withOpacity(0.5),
                    fontSize: 12, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  )),
                ),
              );
            }).toList()),
            const SizedBox(height: 18),
            // Seçili hedef detayı
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutCubic,
              child: _goalDetail(goal, goalColor),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _goalDetail(Map<String, String> goal, Color color) => Container(
    key: ValueKey(_selectedGoal),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Bagua alanı
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(children: [
          Text('🧭 ', style: const TextStyle(fontSize: 13)),
          Expanded(child: Text(goal['bagua']!, style: TextStyle(
            color: color, fontSize: 12, fontWeight: FontWeight.w700,
          ))),
        ]),
      ),
      const SizedBox(height: 12),
      _bRow('✅', 'Ekle', goal['activate']!, color),
      const SizedBox(height: 8),
      _bRow('❌', 'Çıkar', goal['remove']!, const Color(0xFFEF9A9A)),
      const SizedBox(height: 8),
      _bRow('💎', 'Renk paleti', goal['color']!, const Color(0xFFFFD54F)),
      const SizedBox(height: 12),
      // Pro tip
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.08), Colors.transparent],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('💡', style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(child: Text(goal['tip']!, style: TextStyle(
            color: Colors.white.withOpacity(0.75), fontSize: 12.5, height: 1.5,
          ))),
        ]),
      ),
    ]),
  );

  Widget _bRow(String emoji, String label, String value, Color accent) => Row(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(emoji, style: const TextStyle(fontSize: 13)),
      const SizedBox(width: 8),
      Expanded(child: RichText(text: TextSpan(children: [
        TextSpan(text: '$label  ', style: TextStyle(
          color: accent.withOpacity(0.8), fontSize: 11.5, fontWeight: FontWeight.w700,
        )),
        TextSpan(text: value, style: TextStyle(
          color: Colors.white.withOpacity(0.7), fontSize: 12, height: 1.4,
        )),
      ]))),
    ],
  );

  Color _goalColor(String goal) {
    switch (goal) {
      case 'Para': return const Color(0xFF4CAF50);
      case 'Aşk': return const Color(0xFFE91E63);
      case 'Kariyer': return const Color(0xFF2196F3);
      case 'Huzur': return const Color(0xFFFF9800);
      case 'Sağlık': return const Color(0xFF00BCD4);
      default: return Colors.white;
    }
  }
}

// ─────────────────────────────────────────────────────
// ENERGY BRIDGE PAINTER — İkonları Bağlayan Enerji Akışı
// ─────────────────────────────────────────────────────
// ── Enerji Kartı Özel İkon Painter (Bagua Trigram çizgisel) ──────
class _EnergyCardIconPainter extends CustomPainter {
  final String iconType;
  final Color color;
  const _EnergyCardIconPainter({required this.iconType, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Bagua trigram çizgi yardımcısı
    // solid=true → tam çizgi; solid=false → iki kırık çizgi (ortası boş)
    void trigramLine(double y, bool solid) {
      if (solid) {
        // TAM ÇİZGİ — Yang
        canvas.drawLine(Offset(w * 0.12, y), Offset(w * 0.88, y), p);
      } else {
        // KIRIIK ÇİZGİ — Yin (iki parça, ortası boş)
        canvas.drawLine(Offset(w * 0.12, y), Offset(w * 0.42, y), p);
        canvas.drawLine(Offset(w * 0.58, y), Offset(w * 0.88, y), p);
      }
    }

    // Trigram çizgi aralıkları: üst/orta/alt
    final y1 = h * 0.22; // Üst çizgi
    final y2 = h * 0.50; // Orta çizgi
    final y3 = h * 0.78; // Alt çizgi

    switch (iconType) {
      case 'dominant':
        // ☰ Qian — GÖK (üç tam çizgi = maksimum Yang, baskın güç)
        trigramLine(y1, true);
        trigramLine(y2, true);
        trigramLine(y3, true);
        break;

      case 'support':
        // ☴ Xun — RÜZGAR (alt kırık, üst iki tam = destekleyici, nüfuz eden)
        trigramLine(y1, true);
        trigramLine(y2, true);
        trigramLine(y3, false);
        break;

      case 'drain':
        // ☷ Kun — TOPRAK (üç kırık çizgi = alıcı, absorbe eden, tüketen)
        trigramLine(y1, false);
        trigramLine(y2, false);
        trigramLine(y3, false);
        break;
    }
  }

  @override bool shouldRepaint(_EnergyCardIconPainter o) => o.iconType != iconType || o.color != color;
}

class _EnergyBridgePainter extends CustomPainter {
  final Color elColor;
  final Color yyColor;
  _EnergyBridgePainter({required this.elColor, required this.yyColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    
    // Dalgalı zarif enerji çizgisi
    final path = Path();
    path.moveTo(0, h * 0.5);
    path.cubicTo(w * 0.25, h * 0.1, w * 0.25, h * 0.9, w * 0.5, h * 0.5);
    path.cubicTo(w * 0.75, h * 0.1, w * 0.75, h * 0.9, w, h * 0.5);

    // Gradient boya (Tüm elementler için tek tip, nötr gümüş/beyaz enerji)
    final gradient = LinearGradient(
      colors: [
        Colors.white.withOpacity(0.0),
        Colors.white.withOpacity(0.25),
        Colors.white.withOpacity(0.35),
        Colors.white.withOpacity(0.25),
        Colors.white.withOpacity(0.0),
      ],
      stops: const [0.0, 0.15, 0.5, 0.85, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final p = Paint()
      ..shader = gradient
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, p);

    // Minik ışıltı noktaları
    final dotPaint = Paint()..color = Colors.white.withOpacity(0.6);
    canvas.drawCircle(Offset(w * 0.25, h * 0.5), 1.0, dotPaint);
    canvas.drawCircle(Offset(w * 0.75, h * 0.5), 1.0, dotPaint);
  }

  @override
  bool payment(_EnergyBridgePainter old) => false;
  
  @override
  bool shouldRepaint(_EnergyBridgePainter old) => old.elColor != elColor || old.yyColor != yyColor;
}

// ─────────────────────────────────────────────────────
// YIN-YANG MINI PAINTER — Bağ sembolü
// ─────────────────────────────────────────────────────
class _YinYangMiniPainter extends CustomPainter {
  final Color yinColor;
  final Color yangColor;
  _YinYangMiniPainter({required this.yinColor, required this.yangColor});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 * 0.82;
    final yangPaint = Paint()..color = yangColor..style = PaintingStyle.fill;
    final yinPaint  = Paint()..color = yinColor ..style = PaintingStyle.fill;
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), -3.14159, 3.14159, true, yangPaint);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), 0, 3.14159, true, yinPaint);
    canvas.drawCircle(Offset(cx, cy - r / 2), r / 4, yangPaint);
    canvas.drawCircle(Offset(cx, cy + r / 2), r / 4, yinPaint);
    canvas.drawCircle(Offset(cx, cy), r,
      Paint()..color = Colors.white.withOpacity(0.15)..style = PaintingStyle.stroke..strokeWidth = 0.8);
  }

  @override
  bool shouldRepaint(_YinYangMiniPainter old) => old.yinColor != yinColor || old.yangColor != yangColor;
}

// ─────────────────────────────────────────────────────
// ELEMENT ICON PAINTER — Her element için özgün çizim
// ─────────────────────────────────────────────────────
class _ElementIconPainter extends CustomPainter {
  final String element;
  final Color color;
  _ElementIconPainter({required this.element, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (element) {
      case 'Toprak':
        // Modern katmanlı dağ (huzurlu zen formu)
        final path = Path();
        path.moveTo(w * 0.2, h * 0.75); // Geniş taban
        path.lineTo(w * 0.46, h * 0.28); // Daha dik ve asil tepe
        path.lineTo(w * 0.54, h * 0.28);
        path.lineTo(w * 0.8, h * 0.75);
        path.close();
        canvas.drawPath(path, p..strokeWidth = 2.4);
        // Zemin geniş ana çizgisi
        canvas.drawLine(Offset(w * 0.1, h * 0.85), Offset(w * 0.9, h * 0.85), p..strokeWidth = 3.2);
        // İç hacim, katman hatları (daha dengeli)
        canvas.drawLine(Offset(w * 0.38, h * 0.42), Offset(w * 0.62, h * 0.42), p..strokeWidth = 2.0);
        canvas.drawLine(Offset(w * 0.28, h * 0.6), Offset(w * 0.72, h * 0.6), p..strokeWidth = 2.0);
        break;

      case 'Ateş':
        // 🔥 emoji TextPainter ile render — garanti gerçek alev efekti
        final fireSpan = TextSpan(
          text: '🔥',
          style: TextStyle(fontSize: w * 0.78, height: 1.0),
        );
        final fireTp = TextPainter(
          text: fireSpan,
          textDirection: TextDirection.ltr,
        );
        fireTp.layout();
        fireTp.paint(
          canvas,
          Offset(
            (w - fireTp.width) / 2,
            (h - fireTp.height) / 2 - h * 0.04,
          ),
        );
        break;

      case 'Ağaç':
        // Modern & Zarif "Slim Leaf" Zen Tree
        final treeC = color;
        final trunkP = p..strokeWidth = 3.2..color = treeC;
        
        // 1. Organic Winding Trunk (Zarif Kıvrımlı Gövde)
        final trunk = Path();
        trunk.moveTo(w * 0.5, h * 0.9);
        trunk.cubicTo(w * 0.48, h * 0.78, w * 0.56, h * 0.7, w * 0.52, h * 0.55);
        canvas.drawPath(trunk, trunkP);

        // 2. Fine Branches (İnce Dallar)
        final bR = Path(); // Uzun sağ dal
        bR.moveTo(w * 0.53, h * 0.6);
        bR.quadraticBezierTo(w * 0.8, h * 0.52, w * 0.86, h * 0.35);
        canvas.drawPath(bR, p..strokeWidth = 1.8);

        final bLS = Path(); // Kısa sol alt dal
        bLS.moveTo(w * 0.5, h * 0.68);
        bLS.quadraticBezierTo(w * 0.28, h * 0.62, w * 0.22, h * 0.55);
        canvas.drawPath(bLS, p..strokeWidth = 1.4);

        final bLL = Path(); // Orta boy sol üst dal
        bLL.moveTo(w * 0.51, h * 0.55);
        bLL.quadraticBezierTo(w * 0.32, h * 0.48, w * 0.28, h * 0.38);
        canvas.drawPath(bLL, p..strokeWidth = 1.6);
        
        // 3. Ultra-Slim Leaf Silhouettes (Daha ince ve zarif yaprak formları)
        void drawSlimLeaf(double cx, double cy, double rx, double ry, double rot) {
          canvas.save();
          canvas.translate(cx, cy);
          canvas.rotate(rot);
          // rx/ry oranı daha ince bir yaprak için artırıldı
          canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2), Paint()..color = treeC..style = PaintingStyle.fill);
          canvas.restore();
        }

        drawSlimLeaf(w * 0.86, h * 0.35, 9, 3.5, 0.45); // Sağ üst ince yaprak
        drawSlimLeaf(w * 0.28, h * 0.38, 7, 2.5, -0.65); // Sol üst ince yaprak
        drawSlimLeaf(w * 0.22, h * 0.55, 6, 2.0, -0.3); // Sol alt ince yaprak
        drawSlimLeaf(w * 0.52, h * 0.42, 4, 7.5, 0.1); // Tepe dikey ince yaprak
        
        // Zemin çizgisi (Dengeli)
        canvas.drawLine(Offset(w * 0.38, h * 0.9), Offset(w * 0.62, h * 0.9), p..strokeWidth = 1.0);
        break;

      case 'Metal':
        // Keskin geometrik kristal altıgen
        final hex = Path();
        hex.moveTo(w * 0.5, h * 0.15); // Tepe noktası merkeze alındı
        hex.lineTo(w * 0.82, h * 0.32); // Sağ kanatlar dışa açıldı (boyut %70)
        hex.lineTo(w * 0.82, h * 0.68);
        hex.lineTo(w * 0.5, h * 0.85);
        hex.lineTo(w * 0.18, h * 0.68);
        hex.lineTo(w * 0.18, h * 0.32);
        hex.close();
        canvas.drawPath(hex, p..strokeWidth = 2.4);
        // İç strüktürel zarlar uzatıldı
        canvas.drawLine(Offset(w * 0.18, h * 0.32), Offset(w * 0.82, h * 0.68), p..strokeWidth = 1.6..color = color.withOpacity(0.6));
        canvas.drawLine(Offset(w * 0.82, h * 0.32), Offset(w * 0.18, h * 0.68), p..strokeWidth = 1.6);
        canvas.drawLine(Offset(w * 0.5, h * 0.15), Offset(w * 0.5, h * 0.85), p..strokeWidth = 1.6);
        break;

      case 'Su':
        // Çoğul dinamik su damlaları, boyutları büyüterek dolduruldu
        void drawDrop(double cx, double cy, double r, Paint paint) {
          final dropPath = Path();
          dropPath.moveTo(cx, cy - r * 1.5);
          dropPath.quadraticBezierTo(cx + r, cy, cx + r, cy + r * 0.5);
          dropPath.arcToPoint(Offset(cx - r, cy + r * 0.5), radius: Radius.circular(r), clockwise: true);
          dropPath.quadraticBezierTo(cx - r, cy, cx, cy - r * 1.5);
          canvas.drawPath(dropPath, paint);
        }
        // Merkez iri damla
        drawDrop(w * 0.5, h * 0.45, w * 0.22, p..strokeWidth = 2.4);
        // Sol küçük damla
        drawDrop(w * 0.22, h * 0.7, w * 0.08, p..strokeWidth = 1.8..color = color.withOpacity(0.8));
        // Sağ küçük damla
        drawDrop(w * 0.78, h * 0.55, w * 0.1, p..strokeWidth = 1.8..color = color.withOpacity(0.9));
        break;
    }
  }

  @override
  bool shouldRepaint(_ElementIconPainter old) => old.element != element || old.color != color;
}

// ─────────────────────────────────────────────────────
// YIN-YANG ICON PAINTER — Özgün çizimli ikon
// ─────────────────────────────────────────────────────
class _YinYangIconPainter extends CustomPainter {
  final bool isYin;
  _YinYangIconPainter({required this.isYin});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final silver = const Color(0xFFCDCDD8);
    final blackBg = const Color(0xFF1E1E24);
    final brightWhite = const Color(0xFFFAFAFA);
    
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    if (isYin) {
      // Saf, zarif siyah renkli ve kayık hilal ay formu
      canvas.save();
      canvas.translate(w * 0.5, h * 0.5);
      canvas.rotate(-0.35); // Biraz daha sola kayık
      
      final path = Path();
      path.moveTo(w * 0.12, -h * 0.32);
      path.cubicTo(-w * 0.38, -h * 0.28, -w * 0.38, h * 0.28, w * 0.12, h * 0.32); // dış yay
      path.cubicTo(-w * 0.12, h * 0.18, -w * 0.12, -h * 0.18, w * 0.12, -h * 0.32); // iç yay (kesici)
      
      canvas.drawPath(path, Paint()..color = blackBg..style = PaintingStyle.fill); // siyah dolgu
      canvas.drawPath(path, p..strokeWidth = 1.8..color = Colors.white.withOpacity(0.6)); // beyaz çerçeve
      
      canvas.restore();

      // Etrafında iki küçük ışıltı yıldızı
      void drawStar(double cx, double cy, double sz) {
        canvas.drawLine(Offset(cx - sz, cy), Offset(cx + sz, cy), p..strokeWidth = 1.5..color = silver);
        canvas.drawLine(Offset(cx, cy - sz), Offset(cx, cy + sz), p..color = silver);
      }
      drawStar(w * 0.75, h * 0.35, 4);
      drawStar(w * 0.85, h * 0.55, 2.5);

    } else {
      // Uyumlu, orantılı günes ışınları ve parlak beyaz merkez
      canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.16, Paint()..color = brightWhite..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.16, p..strokeWidth = 1.8..color = Colors.white.withOpacity(0.6));
      
      final rayCount = 8;
      for (int i = 0; i < rayCount; i++) {
        final angle = (i * math.pi * 2 / rayCount) - 1.5708;
        final inner = w * 0.22; // daireden hemen sonra basla
        final outer = i % 2 == 0 ? w * 0.36 : w * 0.30;
        final cx = w * 0.5;
        final cy = h * 0.5;
        canvas.drawLine(
          Offset(cx + inner * math.cos(angle), cy + inner * math.sin(angle)),
          Offset(cx + outer * math.cos(angle), cy + outer * math.sin(angle)),
          p..strokeWidth = 2.0..color = brightWhite.withOpacity(i % 2 == 0 ? 1.0 : 0.6),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_YinYangIconPainter old) => old.isYin != isYin;
}

// ─────────────────────────────────────────────────────
// ROOM SKETCH PAINTER — İdeal mekan çizimi
// ─────────────────────────────────────────────────────
class _RoomSketchPainter extends CustomPainter {


  final Color color;
  _RoomSketchPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // Zemin çizgisi
    canvas.drawLine(Offset(0, h * 0.75), Offset(w, h * 0.75), p);
    // Sol duvar
    canvas.drawLine(Offset(w * 0.08, 0), Offset(w * 0.08, h * 0.75), p);

    // Perspektif zemin çizgileri (merkeze yakınsayan)
    final linePaint = Paint()..color = color.withOpacity(0.12)..strokeWidth = 0.7;
    for (double xi = 0.2; xi < 1.0; xi += 0.2) {
      canvas.drawLine(Offset(w * xi, h * 0.75), Offset(w * 0.5, h * 0.5), linePaint);
    }

    // Sandalye / koltuk silüeti
    final chairPaint = Paint()..color = color.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 1.5..strokeCap = StrokeCap.round;
    // Oturma yeri
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.35, h * 0.5, w * 0.25, h * 0.14), const Radius.circular(4)), chairPaint);
    // Sırtlık
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.35, h * 0.3, w * 0.25, h * 0.2), const Radius.circular(4)), chairPaint);
    // Bacaklar
    canvas.drawLine(Offset(w * 0.38, h * 0.64), Offset(w * 0.38, h * 0.74), chairPaint);
    canvas.drawLine(Offset(w * 0.57, h * 0.64), Offset(w * 0.57, h * 0.74), chairPaint);

    // Saksı / bitki
    final plantPaint = Paint()..color = color.withOpacity(0.45)..style = PaintingStyle.stroke..strokeWidth = 1.3..strokeCap = StrokeCap.round;
    // Saksı gövdesi
    canvas.drawArc(Rect.fromLTWH(w * 0.12, h * 0.55, w * 0.14, h * 0.18), 0, 3.14, false, plantPaint);
    canvas.drawLine(Offset(w * 0.12, h * 0.64), Offset(w * 0.26, h * 0.64), plantPaint);
    // Gövde
    canvas.drawLine(Offset(w * 0.19, h * 0.55), Offset(w * 0.19, h * 0.38), plantPaint);
    // Yapraklar
    final path = Path();
    path.moveTo(w * 0.19, h * 0.38);
    path.quadraticBezierTo(w * 0.07, h * 0.28, w * 0.10, h * 0.20);
    canvas.drawPath(path, plantPaint);
    final path2 = Path();
    path2.moveTo(w * 0.19, h * 0.44);
    path2.quadraticBezierTo(w * 0.30, h * 0.34, w * 0.28, h * 0.25);
    canvas.drawPath(path2, plantPaint);

    // Sağ üst — lamba / ışık noktası
    final lampPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(w * 0.82, h * 0.22), 5, lampPaint);
    canvas.drawCircle(Offset(w * 0.82, h * 0.22), 2.5, Paint()..color = color.withOpacity(0.9));
  }

  @override
  bool shouldRepaint(_RoomSketchPainter old) => old.color != color;
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

class _ChallengeIconPainter extends CustomPainter {
  final Color gold;
  final Color goldL;
  _ChallengeIconPainter({required this.gold, required this.goldL});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final s = size.width;
    final h = size.height;

    final fill = Paint()
      ..color = goldL.withOpacity(0.55)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = goldL.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    // ── 1) Tepe topu ──
    canvas.drawCircle(Offset(cx, h * 0.05), s * 0.05, fill);
    canvas.drawCircle(Offset(cx, h * 0.05), s * 0.05, stroke);

    // Bağlantı çubuğu (top → taç)
    final stick = Path()
      ..moveTo(cx - s * 0.025, h * 0.09)
      ..lineTo(cx + s * 0.025, h * 0.09)
      ..lineTo(cx + s * 0.02, h * 0.14)
      ..lineTo(cx - s * 0.02, h * 0.14)
      ..close();
    canvas.drawPath(stick, fill);

    // ── 2) Taç — açık halka + 3 eğik prong ──
    final crownY = h * 0.22;
    // Taç halkası (oval band)
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, crownY), width: s * 0.34, height: h * 0.06),
      fill,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, crownY), width: s * 0.34, height: h * 0.06),
      stroke,
    );

    // 3 prong — dışa eğilerek yukarı çıkan (pembe queen referansı)
    final prongStroke = Paint()
      ..color = goldL.withOpacity(0.65)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final ballFill = Paint()..color = goldL.withOpacity(0.6);

    // Sol prong
    canvas.drawLine(Offset(cx - s * 0.13, crownY - h * 0.02), Offset(cx - s * 0.16, h * 0.11), prongStroke);
    canvas.drawCircle(Offset(cx - s * 0.16, h * 0.10), s * 0.022, ballFill);
    // Orta prong (tepe topuna bağlı)
    canvas.drawLine(Offset(cx, crownY - h * 0.03), Offset(cx, h * 0.14), prongStroke);
    // Sağ prong
    canvas.drawLine(Offset(cx + s * 0.13, crownY - h * 0.02), Offset(cx + s * 0.16, h * 0.11), prongStroke);
    canvas.drawCircle(Offset(cx + s * 0.16, h * 0.10), s * 0.022, ballFill);

    // ── 3) Boyun ──
    final neckTop = crownY + h * 0.03;
    final neckBot = h * 0.34;
    final neck = Path()
      ..moveTo(cx - s * 0.06, neckTop)
      ..lineTo(cx + s * 0.06, neckTop)
      ..lineTo(cx + s * 0.07, neckBot)
      ..lineTo(cx - s * 0.07, neckBot)
      ..close();
    canvas.drawPath(neck, fill);
    canvas.drawPath(neck, stroke);

    // ── 4) Yaka — şişkin oval halka ──
    final collarY = h * 0.37;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, collarY), width: s * 0.36, height: h * 0.06),
      fill,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, collarY), width: s * 0.36, height: h * 0.06),
      stroke,
    );

    // ── 5) Gövde — düz koni ──
    final bodyTop = collarY + h * 0.03;
    final bodyBot = h * 0.78;
    final body = Path()
      ..moveTo(cx - s * 0.12, bodyTop)
      ..lineTo(cx + s * 0.12, bodyTop)
      ..lineTo(cx + s * 0.26, bodyBot)
      ..lineTo(cx - s * 0.26, bodyBot)
      ..close();
    canvas.drawPath(body, fill);
    canvas.drawPath(body, stroke);

    // ── 6) Taban — çift oval halka ──
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, bodyBot + h * 0.02), width: s * 0.56, height: h * 0.06),
      fill,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, bodyBot + h * 0.02), width: s * 0.56, height: h * 0.06),
      stroke,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.88), width: s * 0.60, height: h * 0.06),
      fill,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.88), width: s * 0.60, height: h * 0.06),
      stroke,
    );
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

// Uyum tablosu kategorileri
enum _CompatCatType { love, friend, work, comm }

// Detaylı Uyum Tablosu — Özel grafik ikonu
class _CompatChartIconPainter extends CustomPainter {
  final Color color;
  _CompatChartIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final pf = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;
    // Çubuk grafik — 3 bar
    final barW = w * 0.18;
    // Bar 1 (sol, kısa)
    final b1 = RRect.fromLTRBR(w * 0.1, h * 0.55, w * 0.1 + barW, h * 0.85, const Radius.circular(2));
    canvas.drawRRect(b1, pf);
    canvas.drawRRect(b1, p);
    // Bar 2 (orta, uzun)
    final b2 = RRect.fromLTRBR(w * 0.38, h * 0.2, w * 0.38 + barW, h * 0.85, const Radius.circular(2));
    canvas.drawRRect(b2, pf);
    canvas.drawRRect(b2, p);
    // Bar 3 (sağ, orta)
    final b3 = RRect.fromLTRBR(w * 0.66, h * 0.4, w * 0.66 + barW, h * 0.85, const Radius.circular(2));
    canvas.drawRRect(b3, pf);
    canvas.drawRRect(b3, p);
    // Alt çizgi
    canvas.drawLine(Offset(w * 0.05, h * 0.88), Offset(w * 0.95, h * 0.88), p..strokeWidth = 1.0);
    // Trend çizgisi
    final trend = Path()
      ..moveTo(w * 0.15, h * 0.52)
      ..quadraticBezierTo(w * 0.4, h * 0.12, w * 0.75, h * 0.35);
    canvas.drawPath(trend, Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round);
    // Trend noktaları
    canvas.drawCircle(Offset(w * 0.15, h * 0.52), 2, Paint()..color = color.withOpacity(0.6));
    canvas.drawCircle(Offset(w * 0.75, h * 0.35), 2, Paint()..color = color.withOpacity(0.6));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Element bağı çizgisi painter
class _ElementBondPainter extends CustomPainter {
  final Color leftColor;
  final Color rightColor;
  _ElementBondPainter({required this.leftColor, required this.rightColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cy = h / 2;
    // Gradient çizgi
    final p = Paint()
      ..shader = LinearGradient(
        colors: [leftColor.withOpacity(0.6), rightColor.withOpacity(0.6)],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    // Dalgalı bağ çizgisi
    final path = Path()
      ..moveTo(0, cy)
      ..cubicTo(w * 0.3, cy - 6, w * 0.7, cy + 6, w, cy);
    canvas.drawPath(path, p);
    // Uç noktalar
    canvas.drawCircle(Offset(2, cy), 2.5, Paint()..color = leftColor.withOpacity(0.5));
    canvas.drawCircle(Offset(w - 2, cy), 2.5, Paint()..color = rightColor.withOpacity(0.5));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Günlük Söz Yıldızı (Günlük tab ikonu ile aynı şekil ve renk) ──
class _DailyQuoteStarPainter extends CustomPainter {
  // Günlük tab ikonu ile aynı _goldL rengi
  static const _starColor = Color(0xFFFFE8A1);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final p = Paint()
      ..color = _starColor.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

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
        p..strokeWidth = 1.2,
      );
    }
    p.strokeWidth = 1.8;
    // Merkez daire
    canvas.drawCircle(Offset(cx, cy), r * 0.15, p..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Günlük Şans İkonu ──
class _FortuneIconPainter extends CustomPainter {
  final String level;
  final Color color;
  _FortuneIconPainter({required this.level, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.4;

    switch (level) {
      case 'Çok Şanslı':
        _drawStarBurst(canvas, cx, cy, r);
        break;
      case 'Şanslı':
        _drawRisingSun(canvas, cx, cy, r);
        break;
      case 'Normal':
        _drawBalance(canvas, cx, cy, r);
        break;
      case 'Dikkatli Ol':
        _drawMysticEye(canvas, cx, cy, r);
        break;
      case 'Riskli':
        _drawStorm(canvas, cx, cy, r);
        break;
    }
  }

  void _drawStarBurst(Canvas canvas, double cx, double cy, double r) {
    canvas.drawCircle(Offset(cx, cy), r * 1.1, Paint()
      ..color = color.withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) - math.pi / 2;
      final outerR = i % 2 == 0 ? r : r * 0.45;
      final x = cx + outerR * math.cos(angle);
      final y = cy + outerR * math.sin(angle);
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, Paint()
      ..shader = RadialGradient(colors: [color, color.withOpacity(0.4)])
        .createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)));
    canvas.drawPath(path, Paint()..color = color.withOpacity(0.6)..style = PaintingStyle.stroke..strokeWidth = 1);
    canvas.drawCircle(Offset(cx, cy), r * 0.15, Paint()..color = color);
  }

  void _drawRisingSun(Canvas canvas, double cx, double cy, double r) {
    canvas.drawCircle(Offset(cx, cy + r * 0.1), r * 0.6, Paint()
      ..color = color.withOpacity(0.1)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
    canvas.drawLine(Offset(cx - r, cy + r * 0.2), Offset(cx + r, cy + r * 0.2), Paint()
      ..color = color.withOpacity(0.3)..strokeWidth = 1);
    final sunRect = Rect.fromCircle(center: Offset(cx, cy + r * 0.2), radius: r * 0.55);
    canvas.drawArc(sunRect, math.pi, math.pi, true, Paint()
      ..shader = RadialGradient(colors: [color, color.withOpacity(0.3)]).createShader(sunRect));
    for (int i = 0; i < 7; i++) {
      final angle = math.pi + (i * math.pi / 6) - math.pi / 12;
      canvas.drawLine(
        Offset(cx + r * 0.65 * math.cos(angle), cy + r * 0.2 + r * 0.65 * math.sin(angle)),
        Offset(cx + r * 0.95 * math.cos(angle), cy + r * 0.2 + r * 0.95 * math.sin(angle)),
        Paint()..color = color.withOpacity(0.5)..strokeWidth = 1.5..strokeCap = StrokeCap.round);
    }
  }

  void _drawBalance(Canvas canvas, double cx, double cy, double r) {
    final paint = Paint()..color = color.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 1.5;
    canvas.drawLine(Offset(cx, cy - r * 0.5), Offset(cx, cy + r * 0.5), paint);
    canvas.drawLine(Offset(cx - r * 0.7, cy - r * 0.5), Offset(cx + r * 0.7, cy - r * 0.5), paint);
    final basePath = Path()
      ..moveTo(cx - r * 0.18, cy + r * 0.5)
      ..lineTo(cx + r * 0.18, cy + r * 0.5)
      ..lineTo(cx, cy + r * 0.3)
      ..close();
    canvas.drawPath(basePath, Paint()..color = color.withOpacity(0.15));
    canvas.drawPath(basePath, paint);
    final leftArc = Rect.fromCircle(center: Offset(cx - r * 0.7, cy - r * 0.35), radius: r * 0.2);
    canvas.drawArc(leftArc, 0, math.pi, false, paint);
    canvas.drawCircle(Offset(cx - r * 0.7, cy - r * 0.5), 2.5, Paint()..color = color.withOpacity(0.6));
    final rightArc = Rect.fromCircle(center: Offset(cx + r * 0.7, cy - r * 0.35), radius: r * 0.2);
    canvas.drawArc(rightArc, 0, math.pi, false, paint);
    canvas.drawCircle(Offset(cx + r * 0.7, cy - r * 0.5), 2.5, Paint()..color = color.withOpacity(0.6));
  }

  void _drawMysticEye(Canvas canvas, double cx, double cy, double r) {
    canvas.drawCircle(Offset(cx, cy), r * 0.5, Paint()
      ..color = color.withOpacity(0.08)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    final eyePath = Path()
      ..moveTo(cx - r, cy)
      ..quadraticBezierTo(cx, cy - r * 0.65, cx + r, cy)
      ..quadraticBezierTo(cx, cy + r * 0.65, cx - r, cy)
      ..close();
    canvas.drawPath(eyePath, Paint()..color = color.withOpacity(0.1));
    canvas.drawPath(eyePath, Paint()..color = color.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 1.5);
    canvas.drawCircle(Offset(cx, cy), r * 0.28, Paint()
      ..shader = RadialGradient(colors: [color, color.withOpacity(0.2)])
        .createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.28)));
    canvas.drawCircle(Offset(cx, cy), r * 0.12, Paint()..color = const Color(0xFF0A0A0F));
    canvas.drawCircle(Offset(cx - r * 0.06, cy - r * 0.08), r * 0.05, Paint()..color = Colors.white.withOpacity(0.7));
  }

  void _drawStorm(Canvas canvas, double cx, double cy, double r) {
    final cloudPath = Path();
    cloudPath.addOval(Rect.fromCenter(center: Offset(cx - r * 0.2, cy - r * 0.35), width: r * 0.7, height: r * 0.45));
    cloudPath.addOval(Rect.fromCenter(center: Offset(cx + r * 0.2, cy - r * 0.3), width: r * 0.8, height: r * 0.5));
    cloudPath.addOval(Rect.fromCenter(center: Offset(cx, cy - r * 0.45), width: r * 0.6, height: r * 0.4));
    canvas.drawPath(cloudPath, Paint()..color = color.withOpacity(0.2));
    final bolt = Path()
      ..moveTo(cx + r * 0.05, cy - r * 0.1)
      ..lineTo(cx - r * 0.12, cy + r * 0.15)
      ..lineTo(cx + r * 0.02, cy + r * 0.12)
      ..lineTo(cx - r * 0.08, cy + r * 0.5)
      ..lineTo(cx + r * 0.12, cy + r * 0.08)
      ..lineTo(cx - r * 0.02, cy + r * 0.1)
      ..close();
    canvas.drawPath(bolt, Paint()..color = color.withOpacity(0.8));
    canvas.drawPath(bolt, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1);
    for (int i = 0; i < 3; i++) {
      final dx = cx - r * 0.35 + i * r * 0.35;
      final dy = cy + r * 0.3 + i * r * 0.12;
      canvas.drawLine(Offset(dx, dy), Offset(dx - r * 0.05, dy + r * 0.12), Paint()
        ..color = color.withOpacity(0.3)..strokeWidth = 1..strokeCap = StrokeCap.round);
    }
  }

  @override
  bool shouldRepaint(covariant _FortuneIconPainter old) => old.level != level || old.color != color;
}

// ── Ruh Hali İkonu ──
class _MoodIconPainter extends CustomPainter {
  final String mood;
  final Color color;
  _MoodIconPainter({required this.mood, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.32;
    final p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1.8..strokeCap = StrokeCap.round;

    switch (mood) {
      case 'Enerjik': _drawFlame(canvas, cx, cy, r, p); break;
      case 'Huzurlu': _drawMoon(canvas, cx, cy, r, p); break;
      case 'Yaratıcı': _drawBulb(canvas, cx, cy, r, p); break;
      case 'Sosyal': _drawPeople(canvas, cx, cy, r, p); break;
      case 'Düşünceli': _drawThought(canvas, cx, cy, r, p); break;
      case 'Maceracı': _drawMountain(canvas, cx, cy, r, p); break;
      case 'Romantik': _drawHearts(canvas, cx, cy, r, p); break;
      case 'Kararlı': _drawDiamond(canvas, cx, cy, r, p); break;
      case 'Neşeli': _drawSun(canvas, cx, cy, r, p); break;
      case 'Odaklı': _drawTarget(canvas, cx, cy, r, p); break;
      case 'Şefkatli': _drawHands(canvas, cx, cy, r, p); break;
      case 'Güçlü': _drawShield(canvas, cx, cy, r, p); break;
    }
  }

  // ⚡ Enerjik — Zigzag şimşek
  void _drawFlame(Canvas canvas, double cx, double cy, double r, Paint p) {
    // Glow
    canvas.drawCircle(Offset(cx, cy), r * 0.5, Paint()
      ..color = color.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    final bolt = Path()
      ..moveTo(cx - r * 0.15, cy - r * 1.0)
      ..lineTo(cx + r * 0.35, cy - r * 1.0)
      ..lineTo(cx + r * 0.05, cy - r * 0.15)
      ..lineTo(cx + r * 0.4, cy - r * 0.15)
      ..lineTo(cx - r * 0.1, cy + r * 1.0)
      ..lineTo(cx + r * 0.1, cy + r * 0.1)
      ..lineTo(cx - r * 0.3, cy + r * 0.1)
      ..close();
    canvas.drawPath(bolt, Paint()..color = color.withOpacity(0.6));
    canvas.drawPath(bolt, p);
  }

  // 🌙 Huzurlu — Hilal ay + yıldızlar
  void _drawMoon(Canvas canvas, double cx, double cy, double r, Paint p) {
    final moon = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx - r * 0.1, cy), radius: r * 0.7));
    final cut = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx + r * 0.3, cy - r * 0.15), radius: r * 0.55));
    final crescent = Path.combine(PathOperation.difference, moon, cut);
    canvas.drawPath(crescent, Paint()..color = color.withOpacity(0.3));
    canvas.drawPath(crescent, p);
    void star(double sx, double sy, double sr) {
      canvas.drawCircle(Offset(sx, sy), sr, Paint()..color = color.withOpacity(0.7));
    }
    star(cx + r * 0.55, cy - r * 0.5, r * 0.08);
    star(cx + r * 0.75, cy + r * 0.1, r * 0.06);
    star(cx + r * 0.35, cy + r * 0.5, r * 0.05);
  }

  // ✨ Yaratıcı — Kayan yıldız + parıltı izi
  void _drawBulb(Canvas canvas, double cx, double cy, double r, Paint p) {
    // Ana yıldız glow
    canvas.drawCircle(Offset(cx + r * 0.3, cy - r * 0.4), r * 0.25, Paint()
      ..color = color.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));

    // 4 kollu yıldız
    final star = Path();
    final sX = cx + r * 0.3, sY = cy - r * 0.4, sR = r * 0.35;
    star.moveTo(sX, sY - sR);
    star.quadraticBezierTo(sX + sR * 0.12, sY - sR * 0.12, sX + sR, sY);
    star.quadraticBezierTo(sX + sR * 0.12, sY + sR * 0.12, sX, sY + sR);
    star.quadraticBezierTo(sX - sR * 0.12, sY + sR * 0.12, sX - sR, sY);
    star.quadraticBezierTo(sX - sR * 0.12, sY - sR * 0.12, sX, sY - sR);
    canvas.drawPath(star, Paint()..color = color.withOpacity(0.7));

    // Kayan kuyruk — eğri çizgi
    final tail = Path()
      ..moveTo(cx + r * 0.15, cy - r * 0.25)
      ..cubicTo(cx - r * 0.2, cy + r * 0.1, cx - r * 0.4, cy + r * 0.3, cx - r * 0.7, cy + r * 0.7);
    canvas.drawPath(tail, Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round);

    // İz parıltıları
    canvas.drawCircle(Offset(cx - r * 0.15, cy + r * 0.05), r * 0.05, Paint()..color = color.withOpacity(0.4));
    canvas.drawCircle(Offset(cx - r * 0.35, cy + r * 0.3), r * 0.04, Paint()..color = color.withOpacity(0.3));
    canvas.drawCircle(Offset(cx - r * 0.55, cy + r * 0.55), r * 0.03, Paint()..color = color.withOpacity(0.2));
  }

  // 👥 Sosyal — İki kişi silüeti
  void _drawPeople(Canvas canvas, double cx, double cy, double r, Paint p) {
    canvas.drawCircle(Offset(cx - r * 0.35, cy - r * 0.4), r * 0.25, p);
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx - r * 0.35, cy + r * 0.35), width: r * 0.8, height: r * 0.9),
      math.pi, math.pi, false, p);
    canvas.drawCircle(Offset(cx + r * 0.35, cy - r * 0.4), r * 0.25, p);
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx + r * 0.35, cy + r * 0.35), width: r * 0.8, height: r * 0.9),
      math.pi, math.pi, false, p);
    canvas.drawCircle(Offset(cx, cy + r * 0.1), r * 0.2, Paint()
      ..color = color.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
  }

  // 💭 Düşünceli — Düşünce balonu
  void _drawThought(Canvas canvas, double cx, double cy, double r, Paint p) {
    final bubble = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy - r * 0.15), width: r * 1.6, height: r * 1.2),
      Radius.circular(r * 0.5),
    );
    canvas.drawRRect(bubble, Paint()..color = color.withOpacity(0.1));
    canvas.drawRRect(bubble, p);
    canvas.drawCircle(Offset(cx - r * 0.4, cy + r * 0.55), r * 0.12, Paint()..color = color.withOpacity(0.3));
    canvas.drawCircle(Offset(cx - r * 0.6, cy + r * 0.75), r * 0.07, Paint()..color = color.withOpacity(0.2));
    canvas.drawCircle(Offset(cx - r * 0.3, cy - r * 0.15), r * 0.08, Paint()..color = color.withOpacity(0.5));
    canvas.drawCircle(Offset(cx, cy - r * 0.15), r * 0.08, Paint()..color = color.withOpacity(0.5));
    canvas.drawCircle(Offset(cx + r * 0.3, cy - r * 0.15), r * 0.08, Paint()..color = color.withOpacity(0.5));
  }

  // ⛰ Maceracı — Geliştirilmiş dağ + bayrak
  void _drawMountain(Canvas canvas, double cx, double cy, double r, Paint p) {
    // Uzak dağ silüeti
    final farMt = Path()
      ..moveTo(cx + r * 0.1, cy + r * 0.7)
      ..lineTo(cx + r * 0.45, cy - r * 0.3)
      ..lineTo(cx + r * 0.55, cy - r * 0.15)
      ..lineTo(cx + r * 0.7, cy - r * 0.4)
      ..lineTo(cx + r * 1.0, cy + r * 0.7)
      ..close();
    canvas.drawPath(farMt, Paint()..color = color.withOpacity(0.08));
    canvas.drawPath(farMt, Paint()..color = color.withOpacity(0.15)..style = PaintingStyle.stroke..strokeWidth = 0.8);

    // Ana dağ — sırt hattı ile
    final mt = Path()
      ..moveTo(cx - r * 0.9, cy + r * 0.7)
      ..lineTo(cx - r * 0.2, cy - r * 0.6)
      ..lineTo(cx - r * 0.05, cy - r * 0.45)
      ..lineTo(cx + r * 0.05, cy - r * 0.65)
      ..lineTo(cx + r * 0.6, cy + r * 0.7)
      ..close();
    canvas.drawPath(mt, Paint()..color = color.withOpacity(0.2));
    canvas.drawPath(mt, p);

    // Kar örtüsü
    final snow = Path()
      ..moveTo(cx - r * 0.2, cy - r * 0.6)
      ..lineTo(cx - r * 0.05, cy - r * 0.45)
      ..lineTo(cx + r * 0.05, cy - r * 0.65)
      ..lineTo(cx + r * 0.15, cy - r * 0.4)
      ..lineTo(cx - r * 0.05, cy - r * 0.35)
      ..lineTo(cx - r * 0.3, cy - r * 0.4)
      ..close();
    canvas.drawPath(snow, Paint()..color = Colors.white.withOpacity(0.35));

    // Bayrak direği + bayrak
    final peakX = cx + r * 0.05, peakY = cy - r * 0.65;
    canvas.drawLine(Offset(peakX, peakY), Offset(peakX, peakY - r * 0.4),
      Paint()..color = color..strokeWidth = 1.5..strokeCap = StrokeCap.round);
    final flag = Path()
      ..moveTo(peakX, peakY - r * 0.4)
      ..lineTo(peakX + r * 0.3, peakY - r * 0.3)
      ..lineTo(peakX, peakY - r * 0.2);
    canvas.drawPath(flag, Paint()..color = color.withOpacity(0.7));

    // Taban çizgisi
    canvas.drawLine(Offset(cx - r * 0.9, cy + r * 0.7), Offset(cx + r * 1.0, cy + r * 0.7),
      Paint()..color = color.withOpacity(0.15)..strokeWidth = 0.5);
  }

  // 💕 Romantik — İç içe kalpler
  void _drawHearts(Canvas canvas, double cx, double cy, double r, Paint p) {
    void drawHeart(double hx, double hy, double hr, double opacity) {
      final h = Path()
        ..moveTo(hx, hy + hr * 0.5)
        ..cubicTo(hx - hr * 0.9, hy - hr * 0.05, hx - hr * 0.5, hy - hr * 0.75, hx, hy - hr * 0.25)
        ..cubicTo(hx + hr * 0.5, hy - hr * 0.75, hx + hr * 0.9, hy - hr * 0.05, hx, hy + hr * 0.5);
      canvas.drawPath(h, Paint()..color = color.withOpacity(opacity * 0.3));
      canvas.drawPath(h, Paint()..color = color.withOpacity(opacity)..style = PaintingStyle.stroke..strokeWidth = 1.5..strokeCap = StrokeCap.round);
    }
    // Büyük kalp
    drawHeart(cx - r * 0.1, cy + r * 0.1, r * 0.85, 0.5);
    // Küçük kalp (biraz sağda ve yukarıda)
    drawHeart(cx + r * 0.3, cy - r * 0.25, r * 0.5, 0.8);
    // Parıltı
    canvas.drawCircle(Offset(cx + r * 0.6, cy - r * 0.5), r * 0.06, Paint()..color = color.withOpacity(0.5));
    canvas.drawCircle(Offset(cx - r * 0.5, cy - r * 0.6), r * 0.04, Paint()..color = color.withOpacity(0.4));
  }

  // 🏹 Kararlı — Yukarı ok (engeli aşma)
  void _drawDiamond(Canvas canvas, double cx, double cy, double r, Paint p) {
    // Engel çizgisi
    canvas.drawLine(Offset(cx - r * 0.6, cy + r * 0.1), Offset(cx + r * 0.6, cy + r * 0.1),
      Paint()..color = color.withOpacity(0.2)..strokeWidth = 1.5);
    // Kırılma efekti
    canvas.drawLine(Offset(cx - r * 0.15, cy + r * 0.1), Offset(cx - r * 0.25, cy + r * 0.25),
      Paint()..color = color.withOpacity(0.15)..strokeWidth = 1);
    canvas.drawLine(Offset(cx + r * 0.15, cy + r * 0.1), Offset(cx + r * 0.25, cy + r * 0.25),
      Paint()..color = color.withOpacity(0.15)..strokeWidth = 1);

    // Ok gövdesi
    canvas.drawLine(Offset(cx, cy + r * 0.9), Offset(cx, cy - r * 0.5),
      Paint()..color = color.withOpacity(0.6)..strokeWidth = 2.2..strokeCap = StrokeCap.round);
    // Ok ucu
    final arrow = Path()
      ..moveTo(cx, cy - r * 0.95)
      ..lineTo(cx - r * 0.25, cy - r * 0.45)
      ..lineTo(cx, cy - r * 0.55)
      ..lineTo(cx + r * 0.25, cy - r * 0.45)
      ..close();
    canvas.drawPath(arrow, Paint()..color = color.withOpacity(0.7));
    canvas.drawPath(arrow, p);

    // Glow yukarıda
    canvas.drawCircle(Offset(cx, cy - r * 0.7), r * 0.2, Paint()
      ..color = color.withOpacity(0.1)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
  }

  // ☀️ Neşeli — Güneş
  void _drawSun(Canvas canvas, double cx, double cy, double r, Paint p) {
    canvas.drawCircle(Offset(cx, cy), r * 0.5, Paint()
      ..color = color.withOpacity(0.1)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    canvas.drawCircle(Offset(cx, cy), r * 0.4, Paint()..color = color.withOpacity(0.25));
    canvas.drawCircle(Offset(cx, cy), r * 0.4, p);
    // 8 ışın
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      canvas.drawLine(
        Offset(cx + r * 0.55 * math.cos(angle), cy + r * 0.55 * math.sin(angle)),
        Offset(cx + r * 0.85 * math.cos(angle), cy + r * 0.85 * math.sin(angle)),
        Paint()..color = color.withOpacity(0.5)..strokeWidth = i % 2 == 0 ? 2.0 : 1.2..strokeCap = StrokeCap.round);
    }
    // Gülümseme
    canvas.drawArc(Rect.fromCenter(center: Offset(cx, cy + r * 0.05), width: r * 0.35, height: r * 0.2),
      0, math.pi, false, Paint()..color = color.withOpacity(0.4)..style = PaintingStyle.stroke..strokeWidth = 1.2);
  }

  // 🎯 Odaklı — Hedef tahtası
  void _drawTarget(Canvas canvas, double cx, double cy, double r, Paint p) {
    canvas.drawCircle(Offset(cx, cy), r * 0.85, p);
    canvas.drawCircle(Offset(cx, cy), r * 0.55, Paint()..color = color.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 1.2);
    canvas.drawCircle(Offset(cx, cy), r * 0.25, Paint()..color = color.withOpacity(0.4));
    canvas.drawCircle(Offset(cx, cy), r * 0.1, Paint()..color = color.withOpacity(0.8));
    // Nişangah çizgileri
    canvas.drawLine(Offset(cx, cy - r * 0.85), Offset(cx, cy - r * 0.55),
      Paint()..color = color.withOpacity(0.3)..strokeWidth = 1);
    canvas.drawLine(Offset(cx, cy + r * 0.85), Offset(cx, cy + r * 0.55),
      Paint()..color = color.withOpacity(0.3)..strokeWidth = 1);
    canvas.drawLine(Offset(cx - r * 0.85, cy), Offset(cx - r * 0.55, cy),
      Paint()..color = color.withOpacity(0.3)..strokeWidth = 1);
    canvas.drawLine(Offset(cx + r * 0.85, cy), Offset(cx + r * 0.55, cy),
      Paint()..color = color.withOpacity(0.3)..strokeWidth = 1);
  }

  // 🤲 Şefkatli — Açık eller
  void _drawHands(Canvas canvas, double cx, double cy, double r, Paint p) {
    // Merkez glow — sıcaklık
    canvas.drawCircle(Offset(cx, cy), r * 0.3, Paint()
      ..color = color.withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    // 5 yaprak — açılan çiçek
    for (int i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + i * (2 * math.pi / 5);
      final px = cx + r * 0.5 * math.cos(angle);
      final py = cy + r * 0.5 * math.sin(angle);
      final petal = Path()
        ..moveTo(cx, cy)
        ..quadraticBezierTo(
          cx + r * 0.35 * math.cos(angle - 0.4),
          cy + r * 0.35 * math.sin(angle - 0.4),
          px, py)
        ..quadraticBezierTo(
          cx + r * 0.35 * math.cos(angle + 0.4),
          cy + r * 0.35 * math.sin(angle + 0.4),
          cx, cy);
      canvas.drawPath(petal, Paint()..color = color.withOpacity(0.12 + i * 0.03));
      canvas.drawPath(petal, Paint()
        ..color = color.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2);
    }

    // Merkez nokta
    canvas.drawCircle(Offset(cx, cy), r * 0.12, Paint()..color = color.withOpacity(0.6));
    canvas.drawCircle(Offset(cx, cy), r * 0.06, Paint()..color = Colors.white.withOpacity(0.5));

    // Dış halka — yayılan enerji
    canvas.drawCircle(Offset(cx, cy), r * 0.8, Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8);
  }

  // 👑 Güçlü — Taç
  void _drawShield(Canvas canvas, double cx, double cy, double r, Paint p) {
    // Glow
    canvas.drawCircle(Offset(cx, cy - r * 0.1), r * 0.4, Paint()
      ..color = color.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));

    // Taç gövdesi
    final crown = Path()
      ..moveTo(cx - r * 0.7, cy + r * 0.4)
      ..lineTo(cx - r * 0.7, cy - r * 0.15)
      ..lineTo(cx - r * 0.35, cy + r * 0.1)
      ..lineTo(cx, cy - r * 0.7)
      ..lineTo(cx + r * 0.35, cy + r * 0.1)
      ..lineTo(cx + r * 0.7, cy - r * 0.15)
      ..lineTo(cx + r * 0.7, cy + r * 0.4)
      ..close();
    canvas.drawPath(crown, Paint()..color = color.withOpacity(0.2));
    canvas.drawPath(crown, p);

    // Taban bandı
    final band = RRect.fromRectAndRadius(
      Rect.fromLTRB(cx - r * 0.7, cy + r * 0.3, cx + r * 0.7, cy + r * 0.55),
      Radius.circular(r * 0.05),
    );
    canvas.drawRRect(band, Paint()..color = color.withOpacity(0.15));
    canvas.drawRRect(band, p);

    // Mücevherler (tepe noktaları)
    canvas.drawCircle(Offset(cx, cy - r * 0.55), r * 0.08, Paint()..color = color.withOpacity(0.7));
    canvas.drawCircle(Offset(cx - r * 0.6, cy - r * 0.05), r * 0.06, Paint()..color = color.withOpacity(0.5));
    canvas.drawCircle(Offset(cx + r * 0.6, cy - r * 0.05), r * 0.06, Paint()..color = color.withOpacity(0.5));

    // Bant mücevheri
    canvas.drawCircle(Offset(cx, cy + r * 0.42), r * 0.06, Paint()..color = color.withOpacity(0.5));
  }

  @override
  bool shouldRepaint(covariant _MoodIconPainter old) => old.mood != mood || old.color != color;
}

// ── Enerji Yolu Painter — Takımyıldız bağlantı çizgileri ──
// ── Yıl Alev İkonu (Element) ──
// ── Kozmik Köprü — İki hayvan arası ark ──
class _CosmicBridgePainter extends CustomPainter {
  final Color leftColor;
  final Color rightColor;
  _CosmicBridgePainter({required this.leftColor, required this.rightColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final cy = size.height * 0.42;
    final mx = w / 2; // merkez

    // Sol dal — kullanıcı tarafından merkeze
    final pLeft = Paint()
      ..shader = LinearGradient(
        colors: [leftColor, leftColor.withOpacity(0.05)],
      ).createShader(Rect.fromLTWH(0, 0, mx, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    final leftArc = Path()
      ..moveTo(w * 0.2, cy + 4)
      ..cubicTo(w * 0.3, cy - 14, w * 0.4, cy - 6, mx, cy);
    canvas.drawPath(leftArc, pLeft);
    // Alt dal
    final leftArc2 = Path()
      ..moveTo(w * 0.2, cy + 8)
      ..cubicTo(w * 0.3, cy + 20, w * 0.4, cy + 10, mx, cy);
    canvas.drawPath(leftArc2, pLeft..strokeWidth = 0.6);

    // Sağ dal — merkez'den At tarafına
    final pRight = Paint()
      ..shader = LinearGradient(
        colors: [rightColor.withOpacity(0.05), rightColor],
      ).createShader(Rect.fromLTWH(mx, 0, mx, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    final rightArc = Path()
      ..moveTo(mx, cy)
      ..cubicTo(w * 0.6, cy - 6, w * 0.7, cy - 14, w * 0.8, cy + 4);
    canvas.drawPath(rightArc, pRight);
    // Alt dal
    final rightArc2 = Path()
      ..moveTo(mx, cy)
      ..cubicTo(w * 0.6, cy + 10, w * 0.7, cy + 20, w * 0.8, cy + 8);
    canvas.drawPath(rightArc2, pRight..strokeWidth = 0.6);

    // Merkez birleşme noktası
    final mergeP = Paint()
      ..color = Color.lerp(leftColor, rightColor, 0.5)!.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(mx, cy), 2.5, mergeP);
    canvas.drawCircle(Offset(mx, cy), 5, mergeP..color = mergeP.color.withOpacity(0.1));

    // Dekoratif yıldız noktaları
    final dotP = Paint()..style = PaintingStyle.fill;
    final dots = [0.28, 0.36, 0.64, 0.72];
    for (int i = 0; i < dots.length; i++) {
      final t = dots[i];
      final x = w * t;
      final yOff = math.sin((t - 0.2) * math.pi * 1.6) * 10;
      final y = cy - yOff;
      dotP.color = Color.lerp(leftColor, rightColor, t)!.withOpacity(0.35);
      canvas.drawCircle(Offset(x, y), 1.0, dotP);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Etkileşim Yıldız İkonu ──
class _InteractionStarPainter extends CustomPainter {
  final Color color;
  _InteractionStarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    // 4 ana ışın
    for (int i = 0; i < 4; i++) {
      final angle = (math.pi / 2 * i) - math.pi / 2;
      canvas.drawLine(
        Offset(cx + r * 0.2 * math.cos(angle), cy + r * 0.2 * math.sin(angle)),
        Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)),
        p,
      );
    }
    // 4 çapraz kısa ışın
    for (int i = 0; i < 4; i++) {
      final angle = (math.pi / 2 * i) - math.pi / 4;
      canvas.drawLine(
        Offset(cx + r * 0.2 * math.cos(angle), cy + r * 0.2 * math.sin(angle)),
        Offset(cx + r * 0.55 * math.cos(angle), cy + r * 0.55 * math.sin(angle)),
        p..strokeWidth = 0.8,
      );
    }
    // Merkez
    canvas.drawCircle(Offset(cx, cy), r * 0.12, Paint()..color = color..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Mevsim İkonları ──
// ── Pusula İkonu (Mevsimlik Pusula başlığı) ──
// ── Zamanlama Rehberi İkonları ──
class _TimingIconPainter extends CustomPainter {
  final String emoji;
  final Color color;
  _TimingIconPainter({required this.emoji, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height, cx = w/2, cy = h/2;
    final p = Paint()..color=color.withOpacity(0.75)..style=PaintingStyle.stroke..strokeWidth=1.2..strokeCap=StrokeCap.round..strokeJoin=StrokeJoin.round;
    final f = Paint()..color=color.withOpacity(0.4)..style=PaintingStyle.fill;
    switch(emoji){
      case '💰': _coin(canvas,w,h,p,f); break;
      case '📊': _barChart(canvas,w,h,p); break;
      case '📈': _trending(canvas,w,h,p,f); break;
      case '🏦': _bank(canvas,w,h,p); break;
      case '💎': _diamond(canvas,w,h,p,f); break;
      case '💼': _briefcase(canvas,w,h,p); break;
      case '🤝': _handshake(canvas,w,h,p,f); break;
      case '🏠': _house(canvas,w,h,cx,p); break;
      case '🏗️': _crane(canvas,w,h,p); break;
      case '🏡': _cottage(canvas,w,h,cx,p,f); break;
      case '🛋️': _couch(canvas,w,h,p); break;
      case '🎓': _gradCap(canvas,w,h,cx,p,f); break;
      case '📚': _books(canvas,w,h,p); break;
      case '🔬': _microscope(canvas,w,h,p,f); break;
      case '🧪': _flask(canvas,w,h,p,f); break;
      case '🧳': _luggage(canvas,w,h,p); break;
      case '✈️': _plane(canvas,w,h,p); break;
      case '🗺️': _mapScroll(canvas,w,h,p); break;
      case '🌍': _globe(canvas,w,h,cx,cy,p); break;
      case '🏕️': _tent(canvas,w,h,cx,p); break;
      case '💕': case '💞': _hearts(canvas,w,h,p); break;
      case '💐': _bouquet(canvas,w,h,cx,p,f); break;
      case '💑': _couple(canvas,w,h,cx,p,f); break;
      case '💝': _giftHeart(canvas,w,h,cx,cy,p,f); break;
      case '💒': _chapel(canvas,w,h,cx,p,f); break;
      case '🎨': _palette(canvas,w,h,p,f); break;
      case '🎵': _musicNote(canvas,w,h,p,f); break;
      case '✍️': _quill(canvas,w,h,p); break;
      case '🎭': _masks(canvas,w,h,p); break;
      case '🖼️': _frame(canvas,w,h,p,f); break;
      case '🧘': _meditate(canvas,w,h,cx,cy,p); break;
      case '🏥': _medical(canvas,w,h,cx,cy,p); break;
      case '🌿': _herb(canvas,w,h,p); break;
      case '🕊️': _dove(canvas,w,h,p); break;
      case '🎉': _party(canvas,w,h,cx,p,f); break;
      case '🥂': _toast(canvas,w,h,cx,p); break;
      case '🎪': _circus(canvas,w,h,cx,p); break;
      case '👑': _crown(canvas,w,h,p,f); break;
      case '🏰': _castle(canvas,w,h,p); break;
      case '🚀': _rocket(canvas,w,h,p,f); break;
      case '🎖️': _medal(canvas,w,h,cx,p,f); break;
      case '👨‍👩‍👧': case '👪': _family(canvas,w,h,cx,p); break;
      case '👶': _baby(canvas,w,h,cx,cy,p); break;
      case '💡': _bulb(canvas,w,h,cx,p,f); break;
      case '🖥️': _monitor(canvas,w,h,p); break;
      case '🌐': _network(canvas,w,h,cx,cy,p,f); break;
      case '📱': _phone(canvas,w,h,cx,p); break;
      case '🏆': _trophy(canvas,w,h,cx,p); break;
      case '🏃': _runner(canvas,w,h,p); break;
      case '💪': _muscle(canvas,w,h,p); break;
      case '🎲': _dice(canvas,w,h,p,f); break;
      case '♟️': _chess(canvas,w,h,cx,p,f); break;
      case '🔄': _cycle(canvas,w,h,cx,cy,p); break;
      case '⏰': _clock(canvas,w,h,cx,cy,p); break;
      case '📋': _clipboard(canvas,w,h,p); break;
      case '🔍': _search(canvas,w,h,p); break;
      case '🤲': _hands(canvas,w,h,cx,p); break;
      case '⚖️': _scale(canvas,w,h,cx,p); break;
      case '🎗️': _ribbon(canvas,w,h,cx,p); break;
      case '🍽️': _plate(canvas,w,h,cx,cy,p); break;
      case '👔': _tie(canvas,w,h,cx,p); break;
      case '🌾': _wheat(canvas,w,h,p); break;
      case '🔮': _crystal(canvas,w,h,cx,cy,p,f); break;
      case '🔨': _hammer(canvas,w,h,p,f); break;
      case '📦': _movingBox(canvas,w,h,p); break;
      case '🛡️': _shieldHome(canvas,w,h,cx,p,f); break;
      case '💵': _savings(canvas,w,h,cx,p,f); break;
      case '💍': _weddingRing(canvas,w,h,cx,cy,p,f); break;
      default: canvas.drawCircle(Offset(cx,cy),w*0.3,p); canvas.drawCircle(Offset(cx,cy),2,f);
    }
  }
  void _coin(Canvas c,double w,double h,Paint p,Paint f){c.drawOval(Rect.fromLTWH(w*.15,h*.56,w*.52,h*.18),p);c.drawOval(Rect.fromLTWH(w*.18,h*.44,w*.52,h*.18),p);c.drawOval(Rect.fromLTWH(w*.21,h*.32,w*.52,h*.18),p);c.drawLine(Offset(w*.47,h*.35),Offset(w*.47,h*.46),p..strokeWidth=0.8);c.drawLine(Offset(w*.4,h*.38),Offset(w*.54,h*.38),p..strokeWidth=0.6);c.drawLine(Offset(w*.4,h*.43),Offset(w*.54,h*.43),p);c.drawCircle(Offset(w*.82,h*.14),1.2,f);c.drawLine(Offset(w*.82,h*.07),Offset(w*.82,h*.21),p..strokeWidth=0.4);c.drawLine(Offset(w*.75,h*.14),Offset(w*.89,h*.14),p);}
  void _barChart(Canvas c,double w,double h,Paint p){c.drawLine(Offset(w*.08,h*.92),Offset(w*.08,h*.08),p..strokeWidth=0.7);c.drawLine(Offset(w*.08,h*.92),Offset(w*.95,h*.92),p);c.drawRRect(RRect.fromLTRBR(w*.18,h*.7,w*.32,h*.9,const Radius.circular(1)),p..strokeWidth=1.0);c.drawRRect(RRect.fromLTRBR(w*.36,h*.52,w*.5,h*.9,const Radius.circular(1)),p);c.drawRRect(RRect.fromLTRBR(w*.54,h*.38,w*.68,h*.9,const Radius.circular(1)),p);c.drawRRect(RRect.fromLTRBR(w*.72,h*.18,w*.86,h*.9,const Radius.circular(1)),p);final arrow=Path()..moveTo(w*.2,h*.6)..lineTo(w*.79,h*.12);c.drawPath(arrow,Paint()..color=color.withOpacity(0.3)..style=PaintingStyle.stroke..strokeWidth=0.6..strokeCap=StrokeCap.round);c.drawCircle(Offset(w*.79,h*.12),2,Paint()..color=color.withOpacity(0.5)..style=PaintingStyle.fill);}
  void _trending(Canvas c,double w,double h,Paint p,Paint f){c.drawRect(Rect.fromLTWH(w*.3,h*.12,w*.62,h*.65),p..strokeWidth=0.8);c.drawLine(Offset(w*.35,h*.72),Offset(w*.35,h*.2),p..strokeWidth=0.5);c.drawLine(Offset(w*.35,h*.72),Offset(w*.88,h*.72),p);final graph=Path()..moveTo(w*.38,h*.62)..lineTo(w*.5,h*.48)..lineTo(w*.6,h*.55)..lineTo(w*.75,h*.28)..lineTo(w*.85,h*.22);c.drawPath(graph,p..strokeWidth=1.0);c.drawCircle(Offset(w*.85,h*.22),1.5,f);c.drawLine(Offset(w*.78,h*.2),Offset(w*.88,h*.2),p..strokeWidth=0.6);c.drawLine(Offset(w*.88,h*.2),Offset(w*.88,h*.3),p);c.drawCircle(Offset(w*.15,h*.35),w*.07,p);c.drawLine(Offset(w*.15,h*.42),Offset(w*.15,h*.68),p..strokeWidth=0.9);c.drawLine(Offset(w*.15,h*.68),Offset(w*.08,h*.88),p);c.drawLine(Offset(w*.15,h*.68),Offset(w*.22,h*.88),p);c.drawLine(Offset(w*.15,h*.5),Offset(w*.28,h*.45),p..strokeWidth=0.7);c.drawLine(Offset(w*.15,h*.5),Offset(w*.08,h*.55),p);}
  void _bank(Canvas c,double w,double h,Paint p){final cx=w/2;final root=Path()..moveTo(cx,h*.1)..lineTo(w*.9,h*.35)..lineTo(w*.1,h*.35)..close();c.drawPath(root,p..strokeWidth=1.2);final innerR=Path()..moveTo(cx,h*.18)..lineTo(w*.78,h*.3)..lineTo(w*.22,h*.3)..close();c.drawPath(innerR,p..strokeWidth=0.6);for(int i=0;i<4;i++){final x=w*.18+i*w*.2;c.drawRect(Rect.fromLTWH(x,h*.35,w*.08,h*.45),p..strokeWidth=1.0);}c.drawLine(Offset(w*.05,h*.8),Offset(w*.95,h*.8),p..strokeWidth=1.2);c.drawLine(Offset(w*.05,h*.8),Offset(w*.05,h*.85),p);c.drawLine(Offset(w*.95,h*.8),Offset(w*.95,h*.85),p);c.drawLine(Offset(w*.02,h*.85),Offset(w*.98,h*.85),p..strokeWidth=1.5);}
  void _diamond(Canvas c,double w,double h,Paint p,Paint f){final d=Path()..moveTo(w*.5,h*.02)..lineTo(w*.9,h*.35)..lineTo(w*.5,h*.95)..lineTo(w*.1,h*.35)..close();c.drawPath(d,p);c.drawLine(Offset(w*.1,h*.35),Offset(w*.9,h*.35),p..strokeWidth=0.7);c.drawLine(Offset(w*.3,h*.35),Offset(w*.5,h*.02),p);c.drawLine(Offset(w*.7,h*.35),Offset(w*.5,h*.02),p);c.drawCircle(Offset(w*.5,h*.35),1.5,f);}
  void _briefcase(Canvas c,double w,double h,Paint p){final ext=RRect.fromLTRBR(w*.15,h*.15,w*.85,h*.85,const Radius.circular(5));c.drawRRect(ext,p..strokeWidth=1.5);final intD=RRect.fromLTRBR(w*.25,h*.25,w*.75,h*.75,const Radius.circular(3));c.drawRRect(intD,p..strokeWidth=1.0);c.drawCircle(Offset(w*.5,h*.5),w*.15,p..strokeWidth=1.2);for(int i=0;i<6;i++){final a=(math.pi/3*i);c.drawLine(Offset(w*.5+w*.15*math.cos(a),h*.5+w*.15*math.sin(a)),Offset(w*.5+w*.2*math.cos(a),h*.5+w*.2*math.sin(a)),p..strokeWidth=1.0);}c.drawCircle(Offset(w*.5,h*.5),w*.05,Paint()..color=color.withOpacity(0.5)..style=PaintingStyle.fill);c.drawLine(Offset(w*.6,h*.75),Offset(w*.65,h*.75),p..strokeWidth=1.5);c.drawCircle(Offset(w*.85,h*.35),2,p);c.drawCircle(Offset(w*.85,h*.65),2,p);}
  void _handshake(Canvas c,double w,double h,Paint p,Paint f){final gr1=w*.22;final cx1=w*.35;final cy1=h*.42;c.drawCircle(Offset(cx1,cy1),gr1,p..strokeWidth=1.2);c.drawCircle(Offset(cx1,cy1),gr1*.4,p..strokeWidth=0.8);for(int i=0;i<8;i++){final a=(math.pi/4*i);c.drawLine(Offset(cx1+(gr1-w*.05)*math.cos(a),cy1+(gr1-w*.05)*math.sin(a)),Offset(cx1+(gr1+w*.05)*math.cos(a),cy1+(gr1+w*.05)*math.sin(a)),p..strokeWidth=1.5);}final gr2=w*.22;final cx2=w*.65;final cy2=h*.65;c.drawCircle(Offset(cx2,cy2),gr2,p..strokeWidth=1.2);c.drawCircle(Offset(cx2,cy2),gr2*.4,p..strokeWidth=0.8);for(int i=0;i<8;i++){final a=(math.pi/4*i)+math.pi/8;c.drawLine(Offset(cx2+(gr2-w*.05)*math.cos(a),cy2+(gr2-w*.05)*math.sin(a)),Offset(cx2+(gr2+w*.05)*math.cos(a),cy2+(gr2+w*.05)*math.sin(a)),p..strokeWidth=1.5);}c.drawCircle(Offset(cx1,cy1),3,f);c.drawCircle(Offset(cx2,cy2),3,f);}
  void _house(Canvas c,double w,double h,double cx,Paint p){final house=Path()..moveTo(cx,h*.1)..lineTo(w*.88,h*.42)..lineTo(w*.88,h*.9)..lineTo(w*.12,h*.9)..lineTo(w*.12,h*.42)..close();c.drawPath(house,p);c.drawRect(Rect.fromLTWH(w*.38,h*.58,w*.24,h*.32),p..strokeWidth=0.8);}
  void _crane(Canvas c,double w,double h,Paint p){c.drawRRect(RRect.fromLTRBR(w*.1,h*.72,w*.9,h*.92,const Radius.circular(2)),p);c.drawRRect(RRect.fromLTRBR(w*.18,h*.5,w*.82,h*.72,const Radius.circular(2)),p);c.drawRRect(RRect.fromLTRBR(w*.26,h*.28,w*.74,h*.5,const Radius.circular(2)),p);c.drawLine(Offset(w*.5,h*.22),Offset(w*.5,h*.05),p..strokeWidth=0.8);final ar=Path()..moveTo(w*.42,h*.15)..lineTo(w*.5,h*.03)..lineTo(w*.58,h*.15);c.drawPath(ar,p..strokeWidth=0.9);c.drawLine(Offset(w*.1,h*.92),Offset(w*.9,h*.92),p..strokeWidth=0.5);}
  void _cottage(Canvas c,double w,double h,double cx,Paint p,Paint f){final house=Path()..moveTo(cx,h*.15)..lineTo(w*.85,h*.4)..lineTo(w*.85,h*.85)..lineTo(w*.15,h*.85)..lineTo(w*.15,h*.4)..close();c.drawPath(house,p);c.drawRect(Rect.fromLTWH(w*.4,h*.55,w*.2,h*.3),p..strokeWidth=0.7);c.drawCircle(Offset(w*.25,h*.7),3,f);c.drawCircle(Offset(w*.75,h*.72),2.5,f);}
  void _couch(Canvas c,double w,double h,Paint p){final s=Path()..moveTo(w*.1,h*.4)..lineTo(w*.1,h*.75)..lineTo(w*.9,h*.75)..lineTo(w*.9,h*.4);c.drawPath(s,p);c.drawLine(Offset(w*.1,h*.55),Offset(w*.9,h*.55),p..strokeWidth=0.7);c.drawLine(Offset(w*.15,h*.75),Offset(w*.15,h*.9),p..strokeWidth=1.0);c.drawLine(Offset(w*.85,h*.75),Offset(w*.85,h*.9),p);final back=Path()..moveTo(w*.1,h*.4)..cubicTo(w*.1,h*.2,w*.9,h*.2,w*.9,h*.4);c.drawPath(back,p..strokeWidth=1.2);}
  void _gradCap(Canvas c,double w,double h,double cx,Paint p,Paint f){final cap=Path()..moveTo(cx,h*.15)..lineTo(w*.95,h*.4)..lineTo(cx,h*.55)..lineTo(w*.05,h*.4)..close();c.drawPath(cap,p);c.drawLine(Offset(cx,h*.55),Offset(cx,h*.8),p..strokeWidth=0.8);c.drawLine(Offset(w*.3,h*.55),Offset(w*.3,h*.75),p..strokeWidth=0.6);c.drawLine(Offset(w*.7,h*.55),Offset(w*.7,h*.75),p);c.drawCircle(Offset(cx,h*.15),1.5,f);}
  void _books(Canvas c,double w,double h,Paint p){final bl=Path()..moveTo(w*.5,h*.42)..cubicTo(w*.35,h*.35,w*.15,h*.38,w*.08,h*.32)..lineTo(w*.08,h*.88)..cubicTo(w*.15,h*.82,w*.35,h*.8,w*.5,h*.88);c.drawPath(bl,p);final br=Path()..moveTo(w*.5,h*.42)..cubicTo(w*.65,h*.35,w*.85,h*.38,w*.92,h*.32)..lineTo(w*.92,h*.88)..cubicTo(w*.85,h*.82,w*.65,h*.8,w*.5,h*.88);c.drawPath(br,p);c.drawLine(Offset(w*.5,h*.42),Offset(w*.5,h*.88),p..strokeWidth=0.6);for(int i=0;i<3;i++){final a=(-0.5+i*0.5);c.drawLine(Offset(w*(0.5+0.12*math.cos(a-1.2)),h*(0.3+0.12*math.sin(a-1.2))),Offset(w*(0.5+0.2*math.cos(a-1.2)),h*(0.3+0.2*math.sin(a-1.2))),p..strokeWidth=0.5);}c.drawCircle(Offset(w*.5,h*.28),1.5,Paint()..color=color.withOpacity(0.4)..style=PaintingStyle.fill);}
  void _microscope(Canvas c,double w,double h,Paint p,Paint f){c.drawCircle(Offset(w*.4,h*.75),w*.12,p);c.drawLine(Offset(w*.4,h*.63),Offset(w*.4,h*.3),p..strokeWidth=1.3);c.drawLine(Offset(w*.4,h*.3),Offset(w*.65,h*.12),p..strokeWidth=1.0);c.drawCircle(Offset(w*.65,h*.12),w*.1,p);c.drawLine(Offset(w*.2,h*.9),Offset(w*.7,h*.9),p..strokeWidth=1.2);c.drawCircle(Offset(w*.4,h*.5),1.5,f);}
  void _flask(Canvas c,double w,double h,Paint p,Paint f){c.drawLine(Offset(w*.35,h*.08),Offset(w*.65,h*.08),p);c.drawLine(Offset(w*.4,h*.08),Offset(w*.4,h*.35),p);c.drawLine(Offset(w*.6,h*.08),Offset(w*.6,h*.35),p);final b=Path()..moveTo(w*.4,h*.35)..lineTo(w*.15,h*.8)..cubicTo(w*.15,h*.95,w*.85,h*.95,w*.85,h*.8)..lineTo(w*.6,h*.35);c.drawPath(b,p);c.drawCircle(Offset(w*.4,h*.7),2,f);c.drawCircle(Offset(w*.55,h*.75),1.5,f);}
  void _luggage(Canvas c,double w,double h,Paint p){c.drawRRect(RRect.fromLTRBR(w*.15,h*.25,w*.85,h*.85,const Radius.circular(4)),p);c.drawLine(Offset(w*.35,h*.25),Offset(w*.35,h*.12),p..strokeWidth=0.9);c.drawLine(Offset(w*.35,h*.12),Offset(w*.65,h*.12),p);c.drawLine(Offset(w*.65,h*.12),Offset(w*.65,h*.25),p);c.drawLine(Offset(w*.15,h*.5),Offset(w*.85,h*.5),p..strokeWidth=0.6);}
  void _plane(Canvas c,double w,double h,Paint p){final body=Path()..moveTo(w*.5,h*.05)..cubicTo(w*.55,h*.2,w*.55,h*.7,w*.5,h*.95);c.drawPath(body,p);final lw=Path()..moveTo(w*.5,h*.4)..lineTo(w*.05,h*.55)..lineTo(w*.5,h*.5);c.drawPath(lw,p..strokeWidth=1.0);final rw=Path()..moveTo(w*.5,h*.4)..lineTo(w*.95,h*.55)..lineTo(w*.5,h*.5);c.drawPath(rw,p);c.drawLine(Offset(w*.5,h*.85),Offset(w*.35,h*.95),p..strokeWidth=0.7);c.drawLine(Offset(w*.5,h*.85),Offset(w*.65,h*.95),p);}
  void _mapScroll(Canvas c,double w,double h,Paint p){final cx=w/2;final cy=h/2;final r=w*.36;c.drawCircle(Offset(cx,cy),r,p);c.drawOval(Rect.fromLTWH(cx-r*.35,cy-r,r*.7,r*2),p..strokeWidth=0.6);c.drawLine(Offset(cx-r*.9,cy),Offset(cx+r*.9,cy),p..strokeWidth=0.5);final trail=Path()..moveTo(w*.2,h*.35)..cubicTo(w*.35,h*.25,w*.55,h*.55,w*.75,h*.3);c.drawPath(trail,Paint()..color=color.withOpacity(0.35)..style=PaintingStyle.stroke..strokeWidth=0.8..strokeCap=StrokeCap.round);final plane=Path()..moveTo(w*.75,h*.28)..lineTo(w*.82,h*.22)..lineTo(w*.78,h*.32)..close();c.drawPath(plane,Paint()..color=color.withOpacity(0.5)..style=PaintingStyle.fill);}
  void _globe(Canvas c,double w,double h,double cx,double cy,Paint p){final r=w*.38;c.drawCircle(Offset(cx,cy),r,p);c.drawOval(Rect.fromLTWH(cx-r*.4,cy-r,r*.8,r*2),p..strokeWidth=0.7);c.drawLine(Offset(cx-r,cy),Offset(cx+r,cy),p);c.drawLine(Offset(cx-r*.85,cy-r*.4),Offset(cx+r*.85,cy-r*.4),p..strokeWidth=0.5);c.drawLine(Offset(cx-r*.85,cy+r*.4),Offset(cx+r*.85,cy+r*.4),p);}
  void _tent(Canvas c,double w,double h,double cx,Paint p){c.drawCircle(Offset(w*.12,h*.55),w*.05,p);c.drawLine(Offset(w*.12,h*.6),Offset(w*.12,h*.78),p..strokeWidth=0.8);c.drawLine(Offset(w*.12,h*.78),Offset(w*.06,h*.92),p);c.drawLine(Offset(w*.12,h*.78),Offset(w*.18,h*.92),p);c.drawLine(Offset(w*.12,h*.65),Offset(w*.05,h*.72),p..strokeWidth=0.6);c.drawLine(Offset(w*.12,h*.65),Offset(w*.08,h*.58),p);c.drawRect(Rect.fromLTWH(w*.08,h*.62,w*.08,h*.1),p..strokeWidth=0.5);final t1=Path()..moveTo(w*.32,h*.42)..lineTo(w*.32,h*.92)..moveTo(w*.32,h*.55)..lineTo(w*.25,h*.62)..moveTo(w*.32,h*.55)..lineTo(w*.39,h*.62)..moveTo(w*.32,h*.65)..lineTo(w*.26,h*.72)..moveTo(w*.32,h*.65)..lineTo(w*.38,h*.72)..moveTo(w*.32,h*.75)..lineTo(w*.27,h*.82)..moveTo(w*.32,h*.75)..lineTo(w*.37,h*.82);c.drawPath(t1,p..strokeWidth=0.6);final t2=Path()..moveTo(w*.42,h*.35)..lineTo(w*.42,h*.92)..moveTo(w*.42,h*.45)..lineTo(w*.36,h*.52)..moveTo(w*.42,h*.45)..lineTo(w*.48,h*.52)..moveTo(w*.42,h*.58)..lineTo(w*.36,h*.65)..moveTo(w*.42,h*.58)..lineTo(w*.48,h*.65)..moveTo(w*.42,h*.7)..lineTo(w*.37,h*.77)..moveTo(w*.42,h*.7)..lineTo(w*.47,h*.77);c.drawPath(t2,p);final mt=Path()..moveTo(w*.5,h*.92)..lineTo(w*.68,h*.35)..lineTo(w*.78,h*.52)..lineTo(w*.92,h*.25)..lineTo(w*.98,h*.92);c.drawPath(mt,p..strokeWidth=0.9);c.drawCircle(Offset(w*.85,h*.15),w*.08,p..strokeWidth=0.7);for(int i=0;i<5;i++){final a=(-math.pi*0.8)+i*(math.pi*0.4);c.drawLine(Offset(w*.85+w*.1*math.cos(a),h*.15+w*.1*math.sin(a)),Offset(w*.85+w*.14*math.cos(a),h*.15+w*.14*math.sin(a)),p..strokeWidth=0.5);}c.drawLine(Offset(w*.02,h*.92),Offset(w*.98,h*.92),p..strokeWidth=0.7);}
  void _hearts(Canvas c,double w,double h,Paint p){_drawH(c,w*.35,h*.45,w*.25,p);_drawH(c,w*.65,h*.4,w*.2,p..strokeWidth=1.0);}
  void _drawH(Canvas c,double cx,double cy,double s,Paint p){final path=Path()..moveTo(cx,cy+s*.5)..cubicTo(cx-s*1.1,cy-s*.2,cx-s*.3,cy-s*.9,cx,cy-s*.3)..cubicTo(cx+s*.3,cy-s*.9,cx+s*1.1,cy-s*.2,cx,cy+s*.5);c.drawPath(path,p);}
  void _bouquet(Canvas c,double w,double h,double cx,Paint p,Paint f){c.drawLine(Offset(cx,h*.5),Offset(cx-w*.1,h*.95),p);c.drawLine(Offset(cx,h*.5),Offset(cx+w*.1,h*.95),p);for(int i=0;i<5;i++){final a=(2*math.pi*i/5)-math.pi/2;c.drawCircle(Offset(cx+w*.18*math.cos(a),h*.3+w*.18*math.sin(a)),w*.12,p..strokeWidth=0.9);}c.drawCircle(Offset(cx,h*.3),2,f);}
  void _couple(Canvas c,double w,double h,double cx,Paint p,Paint f){final lHead=Path()..moveTo(w*.35,h*.25)..cubicTo(w*.45,h*.25,w*.45,h*.45,w*.35,h*.45)..cubicTo(w*.25,h*.45,w*.25,h*.25,w*.35,h*.25);c.drawPath(lHead,p..strokeWidth=1.1);final lBody=Path()..moveTo(w*.35,h*.45)..cubicTo(w*.1,h*.55,w*.15,h*.85,w*.15,h*.9)..lineTo(w*.5,h*.9)..lineTo(w*.45,h*.6);c.drawPath(lBody,p..strokeWidth=1.1);final rHead=Path()..moveTo(w*.55,h*.35)..cubicTo(w*.65,h*.35,w*.75,h*.45,w*.65,h*.55)..cubicTo(w*.55,h*.55,w*.45,h*.45,w*.55,h*.35);c.drawPath(rHead,p..strokeWidth=1.1);final rBody=Path()..moveTo(w*.6,h*.55)..cubicTo(w*.85,h*.6,w*.85,h*.85,w*.85,h*.9)..lineTo(w*.5,h*.9)..lineTo(w*.5,h*.6);c.drawPath(rBody,p..strokeWidth=1.1);final lArm=Path()..moveTo(w*.25,h*.65)..cubicTo(w*.5,h*.7,w*.7,h*.75,w*.8,h*.65);c.drawPath(lArm,p..strokeWidth=1.2);final rArm=Path()..moveTo(w*.8,h*.75)..cubicTo(w*.5,h*.8,w*.3,h*.85,w*.2,h*.75);c.drawPath(rArm,p..strokeWidth=1.2);}
  void _giftHeart(Canvas c,double w,double h,double cx,double cy,Paint p,Paint f){final hand=Path()..moveTo(w*.2,h*.9)..cubicTo(w*.3,h*.8,w*.4,h*.75,w*.6,h*.75)..cubicTo(w*.7,h*.75,w*.8,h*.8,w*.85,h*.7)..cubicTo(w*.82,h*.65,w*.75,h*.6,w*.65,h*.65)..cubicTo(w*.5,h*.7,w*.4,h*.7,w*.3,h*.8);c.drawPath(hand,p..strokeWidth=1.2);final ht=Path()..moveTo(cx,h*.35)..cubicTo(cx-w*.2,h*.2,cx-w*.3,h*.3,cx-w*.2,h*.5)..lineTo(cx,h*.65)..lineTo(cx+w*.2,h*.5)..cubicTo(cx+w*.3,h*.3,cx+w*.2,h*.2,cx,h*.35);c.drawPath(ht,p..strokeWidth=1.2);c.drawPath(ht,Paint()..color=color.withOpacity(0.12)..style=PaintingStyle.fill);c.drawLine(Offset(cx,h*.4),Offset(cx,h*.52),p..strokeWidth=0.8);c.drawLine(Offset(cx-w*.06,h*.46),Offset(cx+w*.06,h*.46),p);}
  void _chapel(Canvas c,double w,double h,double cx,Paint p,Paint f){c.drawCircle(Offset(cx-w*.1,h*.55),w*.26,p..strokeWidth=1.4);c.drawCircle(Offset(cx+w*.1,h*.55),w*.26,p);c.drawCircle(Offset(cx-w*.1,h*.55),w*.18,p..strokeWidth=0.6);c.drawCircle(Offset(cx+w*.1,h*.55),w*.18,p);final ht=Path()..moveTo(cx,h*.12)..cubicTo(cx-w*.14,h*.06,cx-w*.22,h*.14,cx-w*.16,h*.24)..lineTo(cx,h*.35)..lineTo(cx+w*.16,h*.24)..cubicTo(cx+w*.22,h*.14,cx+w*.14,h*.06,cx,h*.12);c.drawPath(ht,Paint()..color=color.withOpacity(0.35)..style=PaintingStyle.fill);c.drawPath(ht,p..strokeWidth=0.9);c.drawCircle(Offset(cx,h*.1),1.2,f);}
  void _palette(Canvas c,double w,double h,Paint p,Paint f){c.drawOval(Rect.fromLTWH(w*.08,h*.15,w*.75,h*.7),p);c.drawLine(Offset(w*.7,h*.1),Offset(w*.92,h*.88),p..strokeWidth=1.3);c.drawCircle(Offset(w*.35,h*.42),2,f);c.drawCircle(Offset(w*.5,h*.55),1.8,f);c.drawCircle(Offset(w*.3,h*.62),1.5,f);}
  void _musicNote(Canvas c,double w,double h,Paint p,Paint f){c.drawCircle(Offset(w*.3,h*.75),w*.12,f);c.drawLine(Offset(w*.42,h*.75),Offset(w*.42,h*.15),p..strokeWidth=1.2);c.drawCircle(Offset(w*.65,h*.65),w*.1,f);c.drawLine(Offset(w*.75,h*.65),Offset(w*.75,h*.2),p);c.drawLine(Offset(w*.42,h*.15),Offset(w*.75,h*.2),p..strokeWidth=1.0);}
  void _quill(Canvas c,double w,double h,Paint p){final pen=Path()..moveTo(w*.35,h*.85)..lineTo(w*.45,h*.58)..lineTo(w*.78,h*.05)..cubicTo(w*.84,h*.02,w*.9,h*.08,w*.84,h*.15)..lineTo(w*.52,h*.62)..close();c.drawPath(pen,p);c.drawLine(Offset(w*.45,h*.58),Offset(w*.84,h*.15),p..strokeWidth=0.5);final ink=Path()..moveTo(w*.35,h*.85)..cubicTo(w*.28,h*.82,w*.2,h*.78,w*.15,h*.82)..cubicTo(w*.1,h*.86,w*.08,h*.92,w*.12,h*.95)..cubicTo(w*.16,h*.98,w*.22,h*.95,w*.2,h*.9)..cubicTo(w*.18,h*.86,w*.15,h*.88,w*.14,h*.92);c.drawPath(ink,p..strokeWidth=0.9);c.drawCircle(Offset(w*.12,h*.93),1.8,Paint()..color=color.withOpacity(0.25)..style=PaintingStyle.fill);c.drawCircle(Offset(w*.08,h*.88),1,Paint()..color=color.withOpacity(0.15)..style=PaintingStyle.fill);c.drawCircle(Offset(w*.18,h*.96),0.8,Paint()..color=color.withOpacity(0.2)..style=PaintingStyle.fill);}
  void _masks(Canvas c,double w,double h,Paint p){final hm=Path()..moveTo(w*.05,h*.25)..cubicTo(w*.05,h*.08,w*.55,h*.08,w*.55,h*.25)..lineTo(w*.55,h*.52)..cubicTo(w*.55,h*.68,w*.05,h*.68,w*.05,h*.52)..close();c.drawPath(hm,p);c.drawCircle(Offset(w*.18,h*.35),w*.06,p);c.drawCircle(Offset(w*.42,h*.35),w*.06,p);final sm=Path()..moveTo(w*.2,h*.5)..cubicTo(w*.25,h*.58,w*.35,h*.58,w*.4,h*.5);c.drawPath(sm,p..strokeWidth=0.8);final sd=Path()..moveTo(w*.45,h*.35)..cubicTo(w*.45,h*.18,w*.95,h*.18,w*.95,h*.35)..lineTo(w*.95,h*.62)..cubicTo(w*.95,h*.78,w*.45,h*.78,w*.45,h*.62)..close();c.drawPath(sd,p..strokeWidth=1.2);c.drawCircle(Offset(w*.58,h*.45),w*.06,p);c.drawCircle(Offset(w*.82,h*.45),w*.06,p);final fr=Path()..moveTo(w*.6,h*.6)..cubicTo(w*.65,h*.55,w*.77,h*.55,w*.8,h*.6);c.drawPath(fr,p..strokeWidth=0.8);}
  void _frame(Canvas c,double w,double h,Paint p,Paint f){c.drawRect(Rect.fromLTWH(w*.1,h*.1,w*.8,h*.8),p);c.drawRect(Rect.fromLTWH(w*.2,h*.2,w*.6,h*.6),p..strokeWidth=0.6);final mt=Path()..moveTo(w*.3,h*.55)..lineTo(w*.45,h*.35)..lineTo(w*.55,h*.45)..lineTo(w*.7,h*.3);c.drawPath(mt,p..strokeWidth=0.9);c.drawCircle(Offset(w*.35,h*.35),2,f);}
  void _meditate(Canvas c,double w,double h,double cx,double cy,Paint p){final ht=Path()..moveTo(cx,h*.25)..cubicTo(cx-w*.3,h*.1,cx-w*.4,h*.4,cx-w*.2,h*.6)..lineTo(cx,h*.85)..lineTo(cx+w*.2,h*.6)..cubicTo(cx+w*.4,h*.4,cx+w*.3,h*.1,cx,h*.25);c.drawPath(ht,p..strokeWidth=1.3);c.drawPath(ht,Paint()..color=color.withOpacity(0.15)..style=PaintingStyle.fill);c.save();c.translate(cx,h*.5);c.rotate(-math.pi/4);c.drawRRect(RRect.fromLTRBR(-w*.25,-h*.08,w*.25,h*.08,const Radius.circular(3)),p..strokeWidth=1.0);c.drawRect(Rect.fromLTRB(-w*.08,-h*.08,w*.08,h*.08),p);c.drawCircle(Offset(-w*.12,0),w*.015,p);c.drawCircle(Offset(w*.12,0),w*.015,p);c.restore();}
  void _medical(Canvas c,double w,double h,double cx,double cy,Paint p){final ekg=Path()..moveTo(w*.05,h*.52)..lineTo(w*.2,h*.52)..lineTo(w*.28,h*.52)..lineTo(w*.33,h*.2)..lineTo(w*.38,h*.78)..lineTo(w*.43,h*.35)..lineTo(w*.48,h*.6)..lineTo(w*.52,h*.48)..lineTo(w*.58,h*.52)..lineTo(w*.95,h*.52);c.drawPath(ekg,p..strokeWidth=1.2);c.drawLine(Offset(w*.05,h*.52),Offset(w*.95,h*.52),Paint()..color=color.withOpacity(0.1)..strokeWidth=0.4);final ht=Path()..moveTo(cx,h*.72)..cubicTo(cx-w*.1,h*.65,cx-w*.18,h*.72,cx-w*.12,h*.82)..lineTo(cx,h*.92)..lineTo(cx+w*.12,h*.82)..cubicTo(cx+w*.18,h*.72,cx+w*.1,h*.65,cx,h*.72);c.drawPath(ht,Paint()..color=color.withOpacity(0.25)..style=PaintingStyle.fill);c.drawPath(ht,p..strokeWidth=0.7);}
  void _herb(Canvas c,double w,double h,Paint p){c.drawLine(Offset(w*.5,h*.95),Offset(w*.5,h*.4),p);final l1=Path()..moveTo(w*.5,h*.6)..cubicTo(w*.2,h*.5,w*.15,h*.3,w*.25,h*.2);c.drawPath(l1,p);final r1=Path()..moveTo(w*.5,h*.45)..cubicTo(w*.75,h*.35,w*.8,h*.2,w*.7,h*.1);c.drawPath(r1,p);c.drawLine(Offset(w*.5,h*.55),Offset(w*.32,h*.35),p..strokeWidth=0.5);c.drawLine(Offset(w*.5,h*.42),Offset(w*.68,h*.22),p);}
  void _dove(Canvas c,double w,double h,Paint p){final cx=w/2;for(int i=0;i<3;i++){c.drawCircle(Offset(cx,h*.75),w*(0.12+i*0.12),Paint()..color=color.withOpacity(0.12-i*0.03)..style=PaintingStyle.stroke..strokeWidth=0.6);}c.drawOval(Rect.fromLTWH(cx-w*.12,h*.32,w*.24,h*.18),Paint()..color=color.withOpacity(0.2)..style=PaintingStyle.fill);c.drawOval(Rect.fromLTWH(cx-w*.12,h*.32,w*.24,h*.18),p..strokeWidth=0.8);c.drawOval(Rect.fromLTWH(cx-w*.08,h*.15,w*.16,h*.12),Paint()..color=color.withOpacity(0.15)..style=PaintingStyle.fill);c.drawOval(Rect.fromLTWH(cx-w*.08,h*.15,w*.16,h*.12),p..strokeWidth=0.7);c.drawOval(Rect.fromLTWH(cx-w*.05,h*.02,w*.1,h*.08),Paint()..color=color.withOpacity(0.12)..style=PaintingStyle.fill);c.drawOval(Rect.fromLTWH(cx-w*.05,h*.02,w*.1,h*.08),p..strokeWidth=0.6);c.drawCircle(Offset(cx,h*.75),1.5,Paint()..color=color.withOpacity(0.4)..style=PaintingStyle.fill);}
  void _party(Canvas c,double w,double h,double cx,Paint p,Paint f){c.drawCircle(Offset(w*.22,h*.35),w*.08,p);c.drawLine(Offset(w*.22,h*.44),Offset(w*.22,h*.65),p);c.drawLine(Offset(w*.22,h*.65),Offset(w*.15,h*.85),p);c.drawLine(Offset(w*.22,h*.65),Offset(w*.3,h*.85),p);final la=Path()..moveTo(w*.22,h*.5)..cubicTo(w*.3,h*.48,w*.38,h*.44,w*.42,h*.38);c.drawPath(la,p..strokeWidth=0.9);c.drawCircle(Offset(w*.78,h*.35),w*.08,p);c.drawLine(Offset(w*.78,h*.44),Offset(w*.78,h*.65),p);c.drawLine(Offset(w*.78,h*.65),Offset(w*.7,h*.85),p);c.drawLine(Offset(w*.78,h*.65),Offset(w*.85,h*.85),p);final ra=Path()..moveTo(w*.78,h*.5)..cubicTo(w*.7,h*.48,w*.62,h*.44,w*.58,h*.38);c.drawPath(ra,p);final lPz=Path()..moveTo(w*.38,h*.25)..lineTo(w*.52,h*.25)..lineTo(w*.52,h*.32)..cubicTo(w*.55,h*.34,w*.55,h*.38,w*.52,h*.4)..lineTo(w*.52,h*.48)..lineTo(w*.38,h*.48)..lineTo(w*.38,h*.4)..cubicTo(w*.35,h*.38,w*.35,h*.34,w*.38,h*.32)..close();c.drawPath(lPz,p..strokeWidth=0.8);final rPz=Path()..moveTo(w*.52,h*.28)..lineTo(w*.66,h*.28)..lineTo(w*.66,h*.35)..cubicTo(w*.69,h*.37,w*.69,h*.41,w*.66,h*.43)..lineTo(w*.66,h*.5)..lineTo(w*.52,h*.5)..lineTo(w*.52,h*.43)..cubicTo(w*.49,h*.41,w*.49,h*.37,w*.52,h*.35)..close();c.drawPath(rPz,p);c.drawCircle(Offset(cx,h*.15),1.2,f);c.drawCircle(Offset(w*.15,h*.18),0.8,f);}
  void _toast(Canvas c,double w,double h,double cx,Paint p){final hat=Path()..moveTo(w*.5,h*.15)..lineTo(w*.25,h*.85)..lineTo(w*.75,h*.85)..close();c.drawPath(hat,p..strokeWidth=1.2);c.drawPath(hat,Paint()..color=color.withOpacity(0.1)..style=PaintingStyle.fill);c.drawCircle(Offset(w*.5,h*.1),w*.08,p..strokeWidth=0.8);c.drawCircle(Offset(w*.5,h*.1),w*.06,Paint()..color=color.withOpacity(0.3)..style=PaintingStyle.fill);c.drawLine(Offset(w*.32,h*.65),Offset(w*.68,h*.65),p..strokeWidth=0.8);c.drawLine(Offset(w*.39,h*.45),Offset(w*.61,h*.45),p);c.drawCircle(Offset(w*.18,h*.5),2,Paint()..color=color.withOpacity(0.5)..style=PaintingStyle.fill);c.drawCircle(Offset(w*.12,h*.3),1.5,Paint()..color=color.withOpacity(0.4)..style=PaintingStyle.fill);c.drawCircle(Offset(w*.82,h*.4),2.5,Paint()..color=color.withOpacity(0.4)..style=PaintingStyle.fill);c.drawCircle(Offset(w*.88,h*.25),1.5,Paint()..color=color.withOpacity(0.4)..style=PaintingStyle.fill);final s1=Path()..moveTo(w*.15,h*.65)..cubicTo(w*.05,h*.65,w*.05,h*.55,w*.15,h*.55);c.drawPath(s1,p..strokeWidth=0.7);final s2=Path()..moveTo(w*.85,h*.65)..cubicTo(w*.95,h*.65,w*.95,h*.55,w*.85,h*.55);c.drawPath(s2,p);}
  void _circus(Canvas c,double w,double h,double cx,Paint p){final cy=h*.48;final r=w*.35;c.drawCircle(Offset(cx,cy),r,p..strokeWidth=1.1);c.drawCircle(Offset(cx,cy),r*.15,p..strokeWidth=0.7);for(int i=0;i<8;i++){final a=(math.pi/4*i);c.drawLine(Offset(cx+r*.15*math.cos(a),cy+r*.15*math.sin(a)),Offset(cx+r*math.cos(a),cy+r*math.sin(a)),p..strokeWidth=0.5);}for(int i=0;i<8;i++){final a=(math.pi/4*i);c.drawCircle(Offset(cx+r*.75*math.cos(a),cy+r*.75*math.sin(a)),w*.05,p..strokeWidth=0.7);}c.drawLine(Offset(cx-r*.1,h*.88),Offset(cx+r*.1,h*.88),p..strokeWidth=1.2);c.drawLine(Offset(cx,cy+r),Offset(cx,h*.88),p..strokeWidth=1.0);}
  void _crown(Canvas c,double w,double h,Paint p,Paint f){final cr=Path()..moveTo(w*.1,h*.75)..lineTo(w*.1,h*.3)..lineTo(w*.3,h*.5)..lineTo(w*.5,h*.15)..lineTo(w*.7,h*.5)..lineTo(w*.9,h*.3)..lineTo(w*.9,h*.75)..close();c.drawPath(cr,p);c.drawCircle(Offset(w*.5,h*.13),2,f);}
  void _castle(Canvas c,double w,double h,Paint p){c.drawLine(Offset(w*.1,h*.9),Offset(w*.1,h*.4),p);c.drawLine(Offset(w*.9,h*.9),Offset(w*.9,h*.4),p);c.drawLine(Offset(w*.1,h*.4),Offset(w*.35,h*.4),p..strokeWidth=0.8);c.drawLine(Offset(w*.65,h*.4),Offset(w*.9,h*.4),p);c.drawLine(Offset(w*.35,h*.4),Offset(w*.35,h*.15),p);c.drawLine(Offset(w*.65,h*.4),Offset(w*.65,h*.15),p);c.drawLine(Offset(w*.35,h*.15),Offset(w*.65,h*.15),p);c.drawLine(Offset(w*.1,h*.9),Offset(w*.9,h*.9),p..strokeWidth=1.0);c.drawRect(Rect.fromLTWH(w*.42,h*.5,w*.16,h*.4),p..strokeWidth=0.7);}
  void _rocket(Canvas c,double w,double h,Paint p,Paint f){final r=Path()..moveTo(w*.5,h*.05)..cubicTo(w*.65,h*.2,w*.65,h*.55,w*.6,h*.7)..lineTo(w*.4,h*.7)..cubicTo(w*.35,h*.55,w*.35,h*.2,w*.5,h*.05);c.drawPath(r,p);c.drawLine(Offset(w*.4,h*.6),Offset(w*.25,h*.85),p..strokeWidth=0.9);c.drawLine(Offset(w*.6,h*.6),Offset(w*.75,h*.85),p);c.drawCircle(Offset(w*.5,h*.4),w*.06,p);}
  void _medal(Canvas c,double w,double h,double cx,Paint p,Paint f){final mt=Path()..moveTo(w*.1,h*.85)..lineTo(w*.45,h*.25)..lineTo(w*.55,h*.45)..lineTo(w*.75,h*.15)..lineTo(w*.9,h*.85)..close();c.drawPath(mt,p..strokeWidth=1.1);c.drawPath(mt,Paint()..color=color.withOpacity(0.08)..style=PaintingStyle.fill);c.drawLine(Offset(w*.1,h*.85),Offset(w*.9,h*.85),p..strokeWidth=1.5);c.drawLine(Offset(w*.75,h*.15),Offset(w*.75,h*.05),p..strokeWidth=1.2);final fl=Path()..moveTo(w*.75,h*.05)..lineTo(w*.9,h*.1)..lineTo(w*.75,h*.15);c.drawPath(fl,p..strokeWidth=0.8);c.drawPath(fl,Paint()..color=color.withOpacity(0.35)..style=PaintingStyle.fill);}
  void _family(Canvas c,double w,double h,double cx,Paint p){c.drawCircle(Offset(w*.25,h*.2),w*.09,p);c.drawLine(Offset(w*.25,h*.3),Offset(w*.25,h*.65),p);c.drawCircle(Offset(w*.75,h*.2),w*.09,p);c.drawLine(Offset(w*.75,h*.3),Offset(w*.75,h*.65),p);c.drawCircle(Offset(cx,h*.42),w*.07,p);c.drawLine(Offset(cx,h*.5),Offset(cx,h*.72),p);c.drawLine(Offset(w*.25,h*.42),Offset(cx,h*.42),p..strokeWidth=0.6);c.drawLine(Offset(w*.75,h*.42),Offset(cx,h*.42),p);}
  void _baby(Canvas c,double w,double h,double cx,double cy,Paint p){c.drawCircle(Offset(cx,h*.25),w*.15,p);final crib=Path()..moveTo(w*.15,h*.5)..cubicTo(w*.15,h*.85,w*.85,h*.85,w*.85,h*.5);c.drawPath(crib,p);c.drawLine(Offset(w*.15,h*.5),Offset(w*.85,h*.5),p..strokeWidth=0.7);c.drawLine(Offset(w*.2,h*.85),Offset(w*.2,h*.95),p..strokeWidth=0.8);c.drawLine(Offset(w*.8,h*.85),Offset(w*.8,h*.95),p);}
  void _bulb(Canvas c,double w,double h,double cx,Paint p,Paint f){final rk=Path()..moveTo(cx,h*.1)..cubicTo(w*.7,h*.25,w*.7,h*.6,w*.65,h*.75)..lineTo(w*.35,h*.75)..cubicTo(w*.3,h*.6,w*.3,h*.25,cx,h*.1);c.drawPath(rk,p..strokeWidth=1.2);c.drawCircle(Offset(cx,h*.4),w*.08,p..strokeWidth=0.8);c.drawLine(Offset(w*.38,h*.65),Offset(w*.2,h*.8),p..strokeWidth=1.0);c.drawLine(Offset(w*.62,h*.65),Offset(w*.8,h*.8),p);final fl=Path()..moveTo(w*.45,h*.75)..lineTo(cx,h*.95)..lineTo(w*.55,h*.75);c.drawPath(fl,p..strokeWidth=0.7);c.drawPath(fl,Paint()..color=color.withOpacity(0.4)..style=PaintingStyle.fill);}
  void _monitor(Canvas c,double w,double h,Paint p){c.drawRRect(RRect.fromLTRBR(w*.08,h*.1,w*.92,h*.68,const Radius.circular(3)),p);c.drawLine(Offset(w*.5,h*.68),Offset(w*.5,h*.82),p..strokeWidth=1.0);c.drawLine(Offset(w*.3,h*.82),Offset(w*.7,h*.82),p);c.drawLine(Offset(w*.25,h*.88),Offset(w*.75,h*.88),p..strokeWidth=1.2);c.drawCircle(Offset(w*.5,h*.45),w*.08,p..strokeWidth=0.7);}
  void _network(Canvas c,double w,double h,double cx,double cy,Paint p,Paint f){c.drawCircle(Offset(cx,cy),w*.12,p);for(int i=0;i<6;i++){final a=(math.pi/3*i);final ex=cx+w*.38*math.cos(a);final ey=cy+h*.38*math.sin(a);c.drawLine(Offset(cx+w*.12*math.cos(a),cy+h*.12*math.sin(a)),Offset(ex,ey),p..strokeWidth=0.6);c.drawCircle(Offset(ex,ey),w*.06,p..strokeWidth=0.9);}c.drawCircle(Offset(cx,cy),2,f);}
  void _phone(Canvas c,double w,double h,double cx,Paint p){c.drawRRect(RRect.fromLTRBR(w*.25,h*.05,w*.75,h*.95,const Radius.circular(4)),p);c.drawLine(Offset(w*.25,h*.15),Offset(w*.75,h*.15),p..strokeWidth=0.5);c.drawLine(Offset(w*.25,h*.82),Offset(w*.75,h*.82),p);c.drawCircle(Offset(cx,h*.88),w*.04,p..strokeWidth=0.7);}
  void _trophy(Canvas c,double w,double h,double cx,Paint p){final cup=Path()..moveTo(w*.2,h*.12)..lineTo(w*.8,h*.12)..cubicTo(w*.8,h*.5,w*.65,h*.65,cx,h*.68)..cubicTo(w*.35,h*.65,w*.2,h*.5,w*.2,h*.12);c.drawPath(cup,p);c.drawLine(Offset(cx,h*.68),Offset(cx,h*.82),p..strokeWidth=1.0);c.drawLine(Offset(w*.3,h*.82),Offset(w*.7,h*.82),p);c.drawLine(Offset(w*.25,h*.88),Offset(w*.75,h*.88),p..strokeWidth=1.2);final lh=Path()..moveTo(w*.2,h*.25)..cubicTo(w*.05,h*.25,w*.05,h*.5,w*.2,h*.5);c.drawPath(lh,p..strokeWidth=0.8);final rh=Path()..moveTo(w*.8,h*.25)..cubicTo(w*.95,h*.25,w*.95,h*.5,w*.8,h*.5);c.drawPath(rh,p);}
  void _runner(Canvas c,double w,double h,Paint p){c.drawCircle(Offset(w*.55,h*.12),w*.09,p);c.drawLine(Offset(w*.55,h*.22),Offset(w*.5,h*.5),p);c.drawLine(Offset(w*.5,h*.5),Offset(w*.3,h*.8),p);c.drawLine(Offset(w*.5,h*.5),Offset(w*.75,h*.75),p);c.drawLine(Offset(w*.5,h*.32),Offset(w*.25,h*.42),p..strokeWidth=0.9);c.drawLine(Offset(w*.5,h*.32),Offset(w*.8,h*.3),p);}
  void _muscle(Canvas c,double w,double h,Paint p){c.drawRRect(RRect.fromLTRBR(w*.15,h*.25,w*.85,h*.7,const Radius.circular(4)),p..strokeWidth=1.3);final base=Path()..moveTo(w*.12,h*.7)..lineTo(w*.88,h*.7)..lineTo(w*.95,h*.85)..lineTo(w*.05,h*.85)..close();c.drawPath(base,p..strokeWidth=1.2);c.drawRect(Rect.fromLTWH(w*.4,h*.75,w*.2,h*.06),p..strokeWidth=0.8);c.drawLine(Offset(w*.25,h*.35),Offset(w*.6,h*.35),p..strokeWidth=0.7);c.drawLine(Offset(w*.25,h*.45),Offset(w*.75,h*.45),p);c.drawLine(Offset(w*.25,h*.55),Offset(w*.5,h*.55),p);c.drawCircle(Offset(w*.5,h*.5),w*.08,Paint()..color=color.withOpacity(0.15)..style=PaintingStyle.fill);}
  void _dice(Canvas c,double w,double h,Paint p,Paint f){c.drawRRect(RRect.fromLTRBR(w*.12,h*.12,w*.88,h*.88,const Radius.circular(4)),p);c.drawCircle(Offset(w*.3,h*.3),2,f);c.drawCircle(Offset(w*.7,h*.3),2,f);c.drawCircle(Offset(w*.5,h*.5),2,f);c.drawCircle(Offset(w*.3,h*.7),2,f);c.drawCircle(Offset(w*.7,h*.7),2,f);}
  void _chess(Canvas c,double w,double h,double cx,Paint p,Paint f){c.drawLine(Offset(cx,h*.05),Offset(cx,h*.2),p..strokeWidth=1.2);c.drawLine(Offset(w*.4,h*.12),Offset(w*.6,h*.12),p);final crown=Path()..moveTo(w*.35,h*.2)..cubicTo(w*.65,h*.15,w*.65,h*.15,w*.65,h*.2)..lineTo(w*.7,h*.3)..lineTo(w*.3,h*.3)..close();c.drawPath(crown,p..strokeWidth=1.2);final body=Path()..moveTo(w*.35,h*.3)..cubicTo(w*.4,h*.5,w*.3,h*.7,w*.25,h*.8)..lineTo(w*.75,h*.8)..cubicTo(w*.7,h*.7,w*.6,h*.5,w*.65,h*.3)..close();c.drawPath(body,p..strokeWidth=1.2);c.drawRRect(RRect.fromLTRBR(w*.2,h*.8,w*.8,h*.95,const Radius.circular(2)),p..strokeWidth=1.5);c.drawLine(Offset(w*.35,h*.4),Offset(w*.65,h*.4),p..strokeWidth=0.6);c.drawCircle(Offset(cx,h*.55),w*.05,f);}
  void _cycle(Canvas c,double w,double h,double cx,double cy,Paint p){final r=w*.32;c.drawCircle(Offset(cx,cy),r,p..strokeWidth=1.0);for(int i=0;i<3;i++){final a=(2*math.pi*i/3)-math.pi/2;final ex=cx+r*math.cos(a);final ey=cy+r*math.sin(a);final aa=a+.4;c.drawLine(Offset(ex,ey),Offset(ex+w*.08*math.cos(aa),ey+w*.08*math.sin(aa)),p..strokeWidth=0.9);c.drawLine(Offset(ex,ey),Offset(ex+w*.08*math.cos(aa+math.pi/2),ey+w*.08*math.sin(aa+math.pi/2)),p);}}
  void _clock(Canvas c,double w,double h,double cx,double cy,Paint p){c.drawCircle(Offset(cx,cy),w*.4,p);c.drawLine(Offset(cx,cy),Offset(cx,cy-h*.25),p..strokeWidth=1.3);c.drawLine(Offset(cx,cy),Offset(cx+w*.18,cy+h*.05),p..strokeWidth=1.0);c.drawCircle(Offset(cx,cy),1.5,Paint()..color=color.withOpacity(.5)..style=PaintingStyle.fill);for(int i=0;i<12;i++){final a=(math.pi/6*i);c.drawCircle(Offset(cx+w*.35*math.cos(a),cy+w*.35*math.sin(a)),0.8,p..strokeWidth=0.5);}}
  void _clipboard(Canvas c,double w,double h,Paint p){c.drawRRect(RRect.fromLTRBR(w*.15,h*.15,w*.85,h*.92,const Radius.circular(3)),p);c.drawLine(Offset(w*.35,h*.08),Offset(w*.65,h*.08),p..strokeWidth=1.0);c.drawLine(Offset(w*.35,h*.08),Offset(w*.35,h*.2),p..strokeWidth=0.6);c.drawLine(Offset(w*.65,h*.08),Offset(w*.65,h*.2),p);for(int i=0;i<4;i++){final y=h*(.32+i*.15);c.drawLine(Offset(w*.25,y),Offset(w*.75,y),p..strokeWidth=0.5);}}
  void _search(Canvas c,double w,double h,Paint p){c.drawCircle(Offset(w*.4,h*.38),w*.28,p..strokeWidth=1.2);c.drawLine(Offset(w*.6,h*.58),Offset(w*.88,h*.88),p..strokeWidth=1.5);c.drawCircle(Offset(w*.4,h*.38),1.5,Paint()..color=color.withOpacity(.3)..style=PaintingStyle.fill);}
  void _hands(Canvas c,double w,double h,double cx,Paint p){c.drawCircle(Offset(cx,h*.45),w*.28,p..strokeWidth=1.2);c.drawLine(Offset(w*.22,h*.45),Offset(w*.78,h*.45),p..strokeWidth=0.6);c.drawLine(Offset(cx,h*.17),Offset(cx,h*.73),p);final lHand=Path()..moveTo(w*.2,h*.9)..cubicTo(w*.25,h*.7,w*.35,h*.75,cx,h*.75);c.drawPath(lHand,p..strokeWidth=1.1);final rHand=Path()..moveTo(w*.8,h*.9)..cubicTo(w*.75,h*.7,w*.65,h*.75,cx,h*.75);c.drawPath(rHand,p);c.drawCircle(Offset(cx,h*.45),w*.28,Paint()..color=color.withOpacity(0.08)..style=PaintingStyle.fill);}
  void _scale(Canvas c,double w,double h,double cx,Paint p){c.drawLine(Offset(cx,h*.1),Offset(cx,h*.85),p..strokeWidth=1.2);c.drawLine(Offset(w*.1,h*.3),Offset(w*.9,h*.3),p..strokeWidth=1.0);c.drawLine(Offset(w*.1,h*.3),Offset(w*.08,h*.55),p..strokeWidth=0.7);c.drawLine(Offset(w*.1,h*.3),Offset(w*.28,h*.55),p);final lb=Path()..moveTo(w*.05,h*.58)..cubicTo(w*.05,h*.5,w*.3,h*.5,w*.3,h*.58);c.drawPath(lb,p);c.drawLine(Offset(w*.9,h*.3),Offset(w*.72,h*.55),p);c.drawLine(Offset(w*.9,h*.3),Offset(w*.92,h*.55),p);final rb=Path()..moveTo(w*.7,h*.58)..cubicTo(w*.7,h*.5,w*.95,h*.5,w*.95,h*.58);c.drawPath(rb,p);c.drawLine(Offset(w*.3,h*.85),Offset(w*.7,h*.85),p..strokeWidth=1.0);}
  void _ribbon(Canvas c,double w,double h,double cx,Paint p){c.drawCircle(Offset(w*.35,h*.15),w*.09,p);c.drawLine(Offset(w*.35,h*.25),Offset(w*.35,h*.5),p..strokeWidth=1.0);c.drawLine(Offset(w*.35,h*.5),Offset(w*.22,h*.82),p);c.drawLine(Offset(w*.35,h*.5),Offset(w*.48,h*.82),p);final arm=Path()..moveTo(w*.35,h*.35)..cubicTo(w*.45,h*.32,w*.55,h*.28,w*.65,h*.22);c.drawPath(arm,p..strokeWidth=0.9);c.drawLine(Offset(w*.6,h*.18),Offset(w*.68,h*.28),p..strokeWidth=1.1);c.drawLine(Offset(w*.68,h*.28),Offset(w*.72,h*.32),p..strokeWidth=0.7);c.drawLine(Offset(w*.7,h*.62),Offset(w*.7,h*.82),p..strokeWidth=0.8);c.drawCircle(Offset(w*.7,h*.62),1.5,Paint()..color=color.withOpacity(0.3)..style=PaintingStyle.fill);c.drawRect(Rect.fromLTWH(w*.62,h*.82,w*.16,h*.08),p..strokeWidth=0.6);}
  void _plate(Canvas c,double w,double h,double cx,double cy,Paint p){c.drawCircle(Offset(cx,cy),w*.3,p);c.drawCircle(Offset(cx,cy),w*.18,p..strokeWidth=0.6);c.drawLine(Offset(w*.08,h*.15),Offset(w*.08,h*.85),p..strokeWidth=1.0);c.drawLine(Offset(w*.04,h*.15),Offset(w*.04,h*.32),p..strokeWidth=0.6);c.drawLine(Offset(w*.12,h*.15),Offset(w*.12,h*.32),p);final kn=Path()..moveTo(w*.92,h*.15)..cubicTo(w*.98,h*.3,w*.96,h*.5,w*.92,h*.55)..lineTo(w*.92,h*.85);c.drawPath(kn,p..strokeWidth=1.0);}
  void _tie(Canvas c,double w,double h,double cx,Paint p){c.drawLine(Offset(w*.2,h*.05),Offset(cx,h*.25),p..strokeWidth=1.1);c.drawLine(Offset(w*.8,h*.05),Offset(cx,h*.25),p);final t=Path()..moveTo(cx-w*.12,h*.2)..lineTo(cx+w*.12,h*.2)..lineTo(cx+w*.08,h*.55)..lineTo(cx,h*.9)..lineTo(cx-w*.08,h*.55)..close();c.drawPath(t,p);}
  void _wheat(Canvas c,double w,double h,Paint p){c.drawLine(Offset(w*.5,h*.95),Offset(w*.5,h*.2),p);for(int i=0;i<4;i++){final y=h*(.3+i*.15);c.drawLine(Offset(w*.5,y),Offset(w*.25,y-h*.08),p..strokeWidth=0.8);c.drawLine(Offset(w*.5,y),Offset(w*.75,y-h*.08),p);}c.drawCircle(Offset(w*.5,h*.15),2,Paint()..color=color.withOpacity(.4)..style=PaintingStyle.fill);}
  void _crystal(Canvas c,double w,double h,double cx,double cy,Paint p,Paint f){c.drawCircle(Offset(cx,cy),w*.35,p);c.drawCircle(Offset(cx,cy),w*.2,Paint()..color=color.withOpacity(0.1)..maskFilter=const MaskFilter.blur(BlurStyle.normal,5));for(int i=0;i<5;i++){final a=(2*math.pi*i/5)-math.pi/2;final ir=w*0.08;final or2=w*0.18;c.drawLine(Offset(cx+ir*math.cos(a),cy+ir*math.sin(a)),Offset(cx+or2*math.cos(a),cy+or2*math.sin(a)),p..strokeWidth=0.6);}c.drawCircle(Offset(cx,cy),w*.04,Paint()..color=color.withOpacity(0.6)..style=PaintingStyle.fill);c.drawCircle(Offset(cx+w*.15,cy-h*.12),1,Paint()..color=color.withOpacity(0.35)..style=PaintingStyle.fill);c.drawCircle(Offset(cx-w*.12,cy+h*.08),0.8,Paint()..color=color.withOpacity(0.25)..style=PaintingStyle.fill);c.drawCircle(Offset(cx+w*.08,cy+h*.15),0.7,Paint()..color=color.withOpacity(0.2)..style=PaintingStyle.fill);}
  void _hammer(Canvas c,double w,double h,Paint p,Paint f){final houseR=Path()..moveTo(w*.5,h*.08)..lineTo(w*.82,h*.35)..lineTo(w*.82,h*.65)..lineTo(w*.18,h*.65)..lineTo(w*.18,h*.35)..close();c.drawPath(houseR,p..strokeWidth=0.7);c.drawRect(Rect.fromLTWH(w*.4,h*.45,w*.2,h*.2),p..strokeWidth=0.5);c.drawLine(Offset(w*.08,h*.7),Offset(w*.92,h*.7),p..strokeWidth=1.2);final roller=Path()..moveTo(w*.65,h*.72)..lineTo(w*.65,h*.82)..lineTo(w*.75,h*.82)..lineTo(w*.75,h*.72);c.drawPath(roller,p..strokeWidth=1.0);c.drawLine(Offset(w*.7,h*.82),Offset(w*.7,h*.95),p..strokeWidth=1.3);c.drawCircle(Offset(w*.28,h*.38),w*.05,Paint()..color=color.withOpacity(0.2)..style=PaintingStyle.fill);c.drawCircle(Offset(w*.62,h*.3),w*.04,Paint()..color=color.withOpacity(0.15)..style=PaintingStyle.fill);}

  void _movingBox(Canvas c,double w,double h,Paint p){final truck=Path()..moveTo(w*.05,h*.35)..lineTo(w*.65,h*.35)..lineTo(w*.65,h*.45)..lineTo(w*.88,h*.45)..cubicTo(w*.95,h*.45,w*.95,h*.55,w*.92,h*.6)..lineTo(w*.92,h*.72)..lineTo(w*.05,h*.72)..close();c.drawPath(truck,p);c.drawLine(Offset(w*.65,h*.35),Offset(w*.65,h*.72),p..strokeWidth=0.6);c.drawCircle(Offset(w*.22,h*.72),w*.09,p..strokeWidth=1.0);c.drawCircle(Offset(w*.22,h*.72),w*.04,Paint()..color=color.withOpacity(0.3)..style=PaintingStyle.fill);c.drawCircle(Offset(w*.8,h*.72),w*.09,p);c.drawCircle(Offset(w*.8,h*.72),w*.04,Paint()..color=color.withOpacity(0.3)..style=PaintingStyle.fill);c.drawRect(Rect.fromLTWH(w*.72,h*.52,w*.12,h*.1),p..strokeWidth=0.5);c.drawLine(Offset(w*.12,h*.42),Offset(w*.12,h*.58),p..strokeWidth=0.4);c.drawLine(Offset(w*.32,h*.42),Offset(w*.32,h*.58),p);c.drawLine(Offset(w*.5,h*.42),Offset(w*.5,h*.58),p);}
  void _shieldHome(Canvas c,double w,double h,double cx,Paint p,Paint f){final sh=Path()..moveTo(cx,h*.05)..lineTo(w*.85,h*.2)..cubicTo(w*.85,h*.55,w*.7,h*.8,cx,h*.95)..cubicTo(w*.3,h*.8,w*.15,h*.55,w*.15,h*.2)..close();c.drawPath(sh,p);c.drawPath(sh,Paint()..color=color.withOpacity(0.06)..style=PaintingStyle.fill);final rf=Path()..moveTo(cx,h*.3)..lineTo(w*.68,h*.48)..lineTo(w*.68,h*.7)..lineTo(w*.32,h*.7)..lineTo(w*.32,h*.48)..close();c.drawPath(rf,p..strokeWidth=0.8);c.drawRect(Rect.fromLTWH(w*.44,h*.55,w*.12,h*.15),p..strokeWidth=0.6);}
  void _savings(Canvas c,double w,double h,double cx,Paint p,Paint f){c.drawLine(Offset(cx,h*.92),Offset(cx,h*.28),p..strokeWidth=1.3);final lLeaf1=Path()..moveTo(cx,h*.65)..cubicTo(w*.25,h*.58,w*.2,h*.48,w*.28,h*.42)..cubicTo(w*.32,h*.48,w*.35,h*.55,cx,h*.65);c.drawPath(lLeaf1,p..strokeWidth=0.8);final rLeaf1=Path()..moveTo(cx,h*.55)..cubicTo(w*.75,h*.48,w*.8,h*.38,w*.72,h*.32)..cubicTo(w*.68,h*.38,w*.65,h*.45,cx,h*.55);c.drawPath(rLeaf1,p);final lLeaf2=Path()..moveTo(cx,h*.45)..cubicTo(w*.3,h*.38,w*.28,h*.3,w*.34,h*.25)..cubicTo(w*.38,h*.3,w*.38,h*.35,cx,h*.45);c.drawPath(lLeaf2,p);c.drawCircle(Offset(cx,h*.2),w*.14,p..strokeWidth=1.0);c.drawLine(Offset(cx,h*.14),Offset(cx,h*.26),p..strokeWidth=0.6);c.drawLine(Offset(cx-w*.04,h*.17),Offset(cx+w*.04,h*.17),p);c.drawLine(Offset(cx-w*.04,h*.23),Offset(cx+w*.04,h*.23),p);c.drawLine(Offset(w*.35,h*.92),Offset(w*.65,h*.92),p..strokeWidth=0.7);}
  void _weddingRing(Canvas c,double w,double h,double cx,double cy,Paint p,Paint f){final gHead=Path()..moveTo(w*.35,h*.2)..cubicTo(w*.45,h*.2,w*.45,h*.4,w*.35,h*.4)..cubicTo(w*.25,h*.4,w*.25,h*.2,w*.35,h*.2);c.drawPath(gHead,p..strokeWidth=1.2);final gBody=Path()..moveTo(w*.35,h*.4)..lineTo(w*.15,h*.9)..lineTo(w*.5,h*.9)..lineTo(w*.4,h*.4);c.drawPath(gBody,p..strokeWidth=1.2);final bow=Path()..moveTo(w*.35,h*.43)..lineTo(w*.3,h*.47)..lineTo(w*.3,h*.39)..lineTo(w*.4,h*.47)..lineTo(w*.4,h*.39)..close();c.drawPath(bow,Paint()..color=color..style=PaintingStyle.fill);final bHead=Path()..moveTo(w*.65,h*.2)..cubicTo(w*.75,h*.2,w*.75,h*.38,w*.65,h*.38)..cubicTo(w*.55,h*.38,w*.55,h*.2,w*.65,h*.2);c.drawPath(bHead,p..strokeWidth=1.0);final bBody=Path()..moveTo(w*.65,h*.38)..lineTo(w*.5,h*.9)..lineTo(w*.85,h*.9)..lineTo(w*.7,h*.38);c.drawPath(bBody,p..strokeWidth=1.0);final veil=Path()..moveTo(w*.65,h*.2)..cubicTo(w*.9,h*.2,w*.9,h*.7,w*.85,h*.9);c.drawPath(veil,p..strokeWidth=0.8);c.drawCircle(Offset(cx,h*.6),2,f);c.drawCircle(Offset(cx-w*.05,h*.56),2,f);c.drawCircle(Offset(cx+w*.05,h*.56),2,f);}
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HourglassIconPainter extends CustomPainter {
  final Color color;
  _HourglassIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawLine(Offset(w * 0.15, h * 0.1), Offset(w * 0.85, h * 0.1), p);
    canvas.drawLine(Offset(w * 0.15, h * 0.9), Offset(w * 0.85, h * 0.9), p);

    final bulb = Path()
      ..moveTo(w * 0.25, h * 0.1)
      ..cubicTo(w * 0.25, h * 0.35, cx - w * 0.1, h * 0.45, cx, h * 0.5)
      ..cubicTo(cx + w * 0.1, h * 0.45, w * 0.75, h * 0.35, w * 0.75, h * 0.1)
      ..moveTo(cx, h * 0.5)
      ..cubicTo(cx - w * 0.1, h * 0.55, w * 0.25, h * 0.65, w * 0.25, h * 0.9)
      ..moveTo(cx, h * 0.5)
      ..cubicTo(cx + w * 0.1, h * 0.55, w * 0.75, h * 0.65, w * 0.75, h * 0.9);
    canvas.drawPath(bulb, p);

    canvas.drawLine(Offset(cx, h * 0.5), Offset(cx, h * 0.75), p..strokeWidth = 0.8);
    canvas.drawCircle(Offset(cx, h * 0.82), 1.5, Paint()..color = color..style = PaintingStyle.fill);

    final sand = Path()
      ..moveTo(w * 0.35, h * 0.9)
      ..lineTo(cx, h * 0.75)
      ..lineTo(w * 0.65, h * 0.9)
      ..close();
    canvas.drawPath(sand, Paint()..color = color.withOpacity(0.3)..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class _CompassIconPainter extends CustomPainter {
  final Color color;
  _CompassIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.42;
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    // Dış daire
    canvas.drawCircle(Offset(cx, cy), r, p);

    // 4 ana yön çizgisi
    for (int i = 0; i < 4; i++) {
      final angle = (math.pi / 2 * i) - math.pi / 2;
      final isNorth = i == 0;
      final inner = r * 0.25;
      final outer = r * (isNorth ? 1.0 : 0.85);
      canvas.drawLine(
        Offset(cx + inner * math.cos(angle), cy + inner * math.sin(angle)),
        Offset(cx + outer * math.cos(angle), cy + outer * math.sin(angle)),
        p..strokeWidth = (isNorth ? 1.4 : 1.0),
      );
    }

    // 4 çapraz — kısa akslar
    for (int i = 0; i < 4; i++) {
      final angle = (math.pi / 2 * i) - math.pi / 4;
      canvas.drawLine(
        Offset(cx + r * 0.3 * math.cos(angle), cy + r * 0.3 * math.sin(angle)),
        Offset(cx + r * 0.6 * math.cos(angle), cy + r * 0.6 * math.sin(angle)),
        p..strokeWidth = 0.6,
      );
    }

    // Kuzey ok ucu
    final nTip = Path()
      ..moveTo(cx, cy - r * 0.85)
      ..lineTo(cx - r * 0.12, cy - r * 0.6)
      ..lineTo(cx + r * 0.12, cy - r * 0.6)
      ..close();
    canvas.drawPath(nTip, Paint()..color = color.withOpacity(0.5)..style = PaintingStyle.fill);

    // Merkez
    canvas.drawCircle(Offset(cx, cy), r * 0.1,
      Paint()..color = color..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SeasonIconPainter extends CustomPainter {
  final String season;
  final Color color;
  _SeasonIconPainter({required this.season, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (season) {
      case 'İlkbahar':
        _drawSpring(canvas, w, h, p);
        break;
      case 'Yaz':
        _drawSummer(canvas, w, h, p);
        break;
      case 'Sonbahar':
        _drawAutumn(canvas, w, h, p);
        break;
      case 'Kış':
        _drawWinter(canvas, w, h, p);
        break;
    }
  }

  // İlkbahar — filiz + açılan yaprak
  void _drawSpring(Canvas canvas, double w, double h, Paint p) {
    // Gövde
    final stem = Path()
      ..moveTo(w * 0.5, h * 0.95)
      ..cubicTo(w * 0.5, h * 0.7, w * 0.48, h * 0.5, w * 0.5, h * 0.35);
    canvas.drawPath(stem, p);
    // Sol yaprak — açılıyor
    final leftLeaf = Path()
      ..moveTo(w * 0.5, h * 0.5)
      ..cubicTo(w * 0.2, h * 0.35, w * 0.15, h * 0.15, w * 0.3, h * 0.1)
      ..cubicTo(w * 0.4, h * 0.08, w * 0.48, h * 0.25, w * 0.5, h * 0.35);
    canvas.drawPath(leftLeaf, p);
    // Sağ kıvrık tomurcuk
    final rightBud = Path()
      ..moveTo(w * 0.5, h * 0.42)
      ..cubicTo(w * 0.65, h * 0.3, w * 0.72, h * 0.2, w * 0.65, h * 0.15)
      ..cubicTo(w * 0.6, h * 0.12, w * 0.55, h * 0.2, w * 0.5, h * 0.35);
    canvas.drawPath(rightBud, p..strokeWidth = 1.0);
    // Sol yaprak damarı
    canvas.drawLine(Offset(w * 0.5, h * 0.45), Offset(w * 0.35, h * 0.25), p..strokeWidth = 0.6);
    // Tomurcuk noktası
    canvas.drawCircle(Offset(w * 0.5, h * 0.35), 1.5,
      Paint()..color = color.withOpacity(0.5)..style = PaintingStyle.fill);
  }

  // Yaz — ışıltılı güneş
  void _drawSummer(Canvas canvas, double w, double h, Paint p) {
    final cx = w / 2;
    final cy = h / 2;
    final r = w * 0.2;
    // Merkez daire
    canvas.drawCircle(Offset(cx, cy), r, p..strokeWidth = 1.3);
    // Işınlar — 8 yön, uzun-kısa değişen
    for (int i = 0; i < 8; i++) {
      final angle = (math.pi / 4 * i) - math.pi / 2;
      final isLong = i % 2 == 0;
      final innerR = r + w * 0.06;
      final outerR = r + (isLong ? w * 0.22 : w * 0.14);
      canvas.drawLine(
        Offset(cx + innerR * math.cos(angle), cy + innerR * math.sin(angle)),
        Offset(cx + outerR * math.cos(angle), cy + outerR * math.sin(angle)),
        p..strokeWidth = (isLong ? 1.3 : 0.9),
      );
    }
    // İç glow noktası
    canvas.drawCircle(Offset(cx, cy), r * 0.35,
      Paint()..color = color.withOpacity(0.25)..style = PaintingStyle.fill);
  }

  // Sonbahar — süzülen yaprak
  void _drawAutumn(Canvas canvas, double w, double h, Paint p) {
    p.strokeWidth = 1.2;
    // Ana yaprak şekli
    final leaf = Path()
      ..moveTo(w * 0.5, h * 0.08)
      ..cubicTo(w * 0.75, h * 0.2, w * 0.85, h * 0.5, w * 0.65, h * 0.75)
      ..cubicTo(w * 0.55, h * 0.85, w * 0.5, h * 0.92, w * 0.5, h * 0.92)
      ..cubicTo(w * 0.5, h * 0.92, w * 0.45, h * 0.85, w * 0.35, h * 0.75)
      ..cubicTo(w * 0.15, h * 0.5, w * 0.25, h * 0.2, w * 0.5, h * 0.08);
    canvas.drawPath(leaf, p);
    // Orta damar
    canvas.drawLine(Offset(w * 0.5, h * 0.12), Offset(w * 0.5, h * 0.88), p..strokeWidth = 0.8);
    // Sol damarlar
    canvas.drawLine(Offset(w * 0.5, h * 0.35), Offset(w * 0.32, h * 0.25), p..strokeWidth = 0.6);
    canvas.drawLine(Offset(w * 0.5, h * 0.55), Offset(w * 0.28, h * 0.5), p);
    // Sağ damarlar
    canvas.drawLine(Offset(w * 0.5, h * 0.35), Offset(w * 0.68, h * 0.28), p);
    canvas.drawLine(Offset(w * 0.5, h * 0.55), Offset(w * 0.7, h * 0.48), p);
    // Rüzgar izi — küçük eğri
    final wind = Path()
      ..moveTo(w * 0.7, h * 0.8)
      ..cubicTo(w * 0.8, h * 0.75, w * 0.85, h * 0.85, w * 0.78, h * 0.9);
    canvas.drawPath(wind, p..strokeWidth = 0.7);
  }

  // Kış — kristal kar tanesi
  void _drawWinter(Canvas canvas, double w, double h, Paint p) {
    final cx = w / 2;
    final cy = h / 2;
    final r = w * 0.38;
    p.strokeWidth = 1.1;

    // 6 ana dal
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3 * i) - math.pi / 2;
      final ex = cx + r * math.cos(angle);
      final ey = cy + r * math.sin(angle);
      canvas.drawLine(Offset(cx, cy), Offset(ex, ey), p);
      // Her daldan 2 mini yan dal
      for (int j = 1; j <= 2; j++) {
        final frac = j * 0.35;
        final bx = cx + r * frac * math.cos(angle);
        final by = cy + r * frac * math.sin(angle);
        final branchLen = r * 0.22;
        final a1 = angle + math.pi / 4;
        final a2 = angle - math.pi / 4;
        canvas.drawLine(Offset(bx, by),
          Offset(bx + branchLen * math.cos(a1), by + branchLen * math.sin(a1)),
          p..strokeWidth = 0.7);
        canvas.drawLine(Offset(bx, by),
          Offset(bx + branchLen * math.cos(a2), by + branchLen * math.sin(a2)),
          p);
      }
    }
    // Merkez noktası
    canvas.drawCircle(Offset(cx, cy), 1.5,
      Paint()..color = color.withOpacity(0.5)..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _YearFlameIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [const Color(0xFFFF6B6B).withOpacity(0.9), const Color(0xFFE53935).withOpacity(0.7)],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Organic flame shape
    final flame = Path()
      ..moveTo(w * 0.5, h * 0.05)
      ..cubicTo(w * 0.65, h * 0.2, w * 0.85, h * 0.35, w * 0.8, h * 0.55)
      ..cubicTo(w * 0.78, h * 0.7, w * 0.7, h * 0.82, w * 0.6, h * 0.9)
      ..cubicTo(w * 0.55, h * 0.95, w * 0.45, h * 0.95, w * 0.4, h * 0.9)
      ..cubicTo(w * 0.3, h * 0.82, w * 0.22, h * 0.7, w * 0.2, h * 0.55)
      ..cubicTo(w * 0.15, h * 0.35, w * 0.35, h * 0.2, w * 0.5, h * 0.05);
    canvas.drawPath(flame, p);

    // Inner flame core
    final inner = Path()
      ..moveTo(w * 0.5, h * 0.35)
      ..cubicTo(w * 0.58, h * 0.45, w * 0.62, h * 0.55, w * 0.58, h * 0.7)
      ..cubicTo(w * 0.55, h * 0.78, w * 0.45, h * 0.78, w * 0.42, h * 0.7)
      ..cubicTo(w * 0.38, h * 0.55, w * 0.42, h * 0.45, w * 0.5, h * 0.35);
    canvas.drawPath(inner, p..strokeWidth = 1.0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Yıl Yin-Yang İkonu (Kutupluluk) ──
class _YearYinYangIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.42;
    final p = Paint()
      ..color = const Color(0xFFFFE8A1).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    // Outer circle
    canvas.drawCircle(Offset(cx, cy), r, p);

    // S-curve divider
    final sCurve = Path()
      ..moveTo(cx, cy - r)
      ..cubicTo(cx + r * 0.6, cy - r * 0.3, cx - r * 0.6, cy + r * 0.3, cx, cy + r);
    canvas.drawPath(sCurve, p..strokeWidth = 1.2);

    // Yang dot (top, filled)
    canvas.drawCircle(Offset(cx, cy - r * 0.45), r * 0.12,
      Paint()..color = const Color(0xFFFFE8A1).withOpacity(0.7)..style = PaintingStyle.fill);

    // Yin dot (bottom, ring)
    canvas.drawCircle(Offset(cx, cy + r * 0.45), r * 0.12, p..strokeWidth = 1.0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Yıl Şimşek İkonu (Tema/Hareket) ──
class _YearBoltIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [const Color(0xFFFFD54F).withOpacity(0.9), const Color(0xFFFFA726).withOpacity(0.6)],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Bolt shape
    final bolt = Path()
      ..moveTo(w * 0.55, h * 0.05)
      ..lineTo(w * 0.3, h * 0.45)
      ..lineTo(w * 0.5, h * 0.45)
      ..lineTo(w * 0.42, h * 0.95)
      ..lineTo(w * 0.7, h * 0.5)
      ..lineTo(w * 0.5, h * 0.5)
      ..close();
    canvas.drawPath(bolt, p);

    // Glow spark dots
    final dotP = Paint()..color = const Color(0xFFFFD54F).withOpacity(0.3)..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.25, h * 0.25), 1.5, dotP);
    canvas.drawCircle(Offset(w * 0.75, h * 0.7), 1.2, dotP);
    canvas.drawCircle(Offset(w * 0.8, h * 0.3), 1.0, dotP);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EnergyPathPainter extends CustomPainter {
  final Color gold;
  _EnergyPathPainter({required this.gold});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final cy = size.height * 0.38; // düğüm noktaları hizası

    // Sol → Orta bağlantı
    final p1 = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFFFF6B35).withOpacity(0.25), Colors.white.withOpacity(0.2)],
      ).createShader(Rect.fromLTWH(w / 6, cy - 5, w / 3, 10))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;

    final path1 = Path()
      ..moveTo(w / 6, cy)
      ..cubicTo(w * 0.28, cy - 8, w * 0.38, cy + 8, w / 2, cy);
    canvas.drawPath(path1, p1);

    // Orta → Sağ bağlantı
    final p2 = Paint()
      ..shader = LinearGradient(
        colors: [Colors.white.withOpacity(0.2), const Color(0xFFFFD54F).withOpacity(0.25)],
      ).createShader(Rect.fromLTWH(w / 2, cy - 5, w / 3, 10))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;

    final path2 = Path()
      ..moveTo(w / 2, cy)
      ..cubicTo(w * 0.62, cy + 8, w * 0.72, cy - 8, w * 5 / 6, cy);
    canvas.drawPath(path2, p2);

    // Dekoratif mini noktalar yol üzerinde
    final dotPaint = Paint()..color = gold.withOpacity(0.1);
    for (double t = 0.3; t <= 0.7; t += 0.2) {
      canvas.drawCircle(Offset(w * t, cy + math.sin(t * 10) * 3), 1.2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Enerji Dalga Grafiği ──
class _EnergyWavePainter extends CustomPainter {
  final double morning;
  final double afternoon;
  final double evening;
  _EnergyWavePainter({required this.morning, required this.afternoon, required this.evening});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final leftPad = 28.0;
    final chartW = w - leftPad;
    final topPad = 4.0;
    final bottomPad = 18.0;
    final chartH = h - topPad - bottomPad;
    final baseline = topPad + chartH;

    final colors = [const Color(0xFFFFB74D), const Color(0xFFFF8A65), const Color(0xFF9575CD)];
    final labelColor = Colors.white.withOpacity(0.25);

    // ── Y ekseni grid çizgileri + etiketler ──
    for (int pct = 25; pct <= 100; pct += 25) {
      final y = baseline - (pct / 100) * chartH;
      for (double x = leftPad; x < w; x += 5) {
        canvas.drawLine(Offset(x, y), Offset(x + 2.5, y),
          Paint()..color = Colors.white.withOpacity(0.05)..strokeWidth = 0.5);
      }
      final tp = TextPainter(
        text: TextSpan(text: '$pct', style: TextStyle(color: labelColor, fontSize: 8)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPad - tp.width - 4, y - tp.height / 2));
    }

    // ── Taban çizgisi ──
    canvas.drawLine(Offset(leftPad, baseline), Offset(w, baseline),
      Paint()..color = Colors.white.withOpacity(0.08)..strokeWidth = 0.5);

    // ── X ekseni zaman etiketleri ──
    final times = ['06:00', '10:00', '14:00', '18:00', '22:00'];
    for (int i = 0; i < times.length; i++) {
      final x = leftPad + i * chartW / (times.length - 1);
      final tp = TextPainter(
        text: TextSpan(text: times[i], style: TextStyle(color: labelColor, fontSize: 8)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, baseline + 4));
      canvas.drawLine(Offset(x, baseline), Offset(x, baseline + 3),
        Paint()..color = Colors.white.withOpacity(0.1)..strokeWidth = 0.5);
    }

    // ── Kontrol noktaları ──
    final points = <Offset>[
      Offset(leftPad, baseline - 0.15 * chartH),
      Offset(leftPad + chartW * 0.2, baseline - morning * chartH),
      Offset(leftPad + chartW * 0.5, baseline - afternoon * chartH),
      Offset(leftPad + chartW * 0.8, baseline - evening * chartH),
      Offset(w, baseline - 0.1 * chartH),
    ];

    // Catmull-Rom smooth eğri
    final wavePath = Path()..moveTo(points[0].dx, points[0].dy);
    final fillPath = Path()..moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i < points.length - 2 ? points[i + 2] : points[i + 1];
      final cp1x = p1.dx + (p2.dx - p0.dx) / 6;
      final cp1y = p1.dy + (p2.dy - p0.dy) / 6;
      final cp2x = p2.dx - (p3.dx - p1.dx) / 6;
      final cp2y = p2.dy - (p3.dy - p1.dy) / 6;
      wavePath.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
      fillPath.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }

    fillPath.lineTo(w, baseline);
    fillPath.lineTo(leftPad, baseline);
    fillPath.close();

    // ── Gradient dolgu ──
    canvas.drawPath(fillPath, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [const Color(0xFFFF8A65).withOpacity(0.18), const Color(0xFFFF8A65).withOpacity(0.02)],
      ).createShader(Rect.fromLTWH(leftPad, topPad, chartW, chartH)));

    // ── Dalga çizgisi ──
    canvas.drawPath(wavePath, Paint()
      ..style = PaintingStyle.stroke..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round
      ..shader = LinearGradient(colors: colors).createShader(Rect.fromLTWH(leftPad, 0, chartW, h)));

    // ── Glow ──
    canvas.drawPath(wavePath, Paint()
      ..style = PaintingStyle.stroke..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..shader = LinearGradient(colors: colors.map((c) => c.withOpacity(0.15)).toList())
        .createShader(Rect.fromLTWH(leftPad, 0, chartW, h)));

    // ── Tepe noktaları ──
    final peakPts = [points[1], points[2], points[3]];
    final peakVals = [morning, afternoon, evening];
    for (int i = 0; i < 3; i++) {
      final pt = peakPts[i];
      final clr = colors[i];
      // Dikey kesikli
      for (double y = pt.dy; y < baseline; y += 4) {
        canvas.drawLine(Offset(pt.dx, y), Offset(pt.dx, y + 2),
          Paint()..color = clr.withOpacity(0.12)..strokeWidth = 0.5);
      }
      canvas.drawCircle(pt, 7, Paint()..color = clr.withOpacity(0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
      canvas.drawCircle(pt, 4, Paint()..color = clr);
      canvas.drawCircle(pt, 2, Paint()..color = Colors.white.withOpacity(0.8));
      // Değer etiketi
      final tp = TextPainter(
        text: TextSpan(text: '${(peakVals[i] * 100).toInt()}%',
          style: TextStyle(color: clr, fontSize: 9, fontWeight: FontWeight.w700)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(pt.dx - tp.width / 2, pt.dy - tp.height - 6));
    }
  }

  @override
  bool shouldRepaint(covariant _EnergyWavePainter old) =>
    old.morning != morning || old.afternoon != afternoon || old.evening != evening;
}
