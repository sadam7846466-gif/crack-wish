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
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  int _animalIdx = 6;
  int _activeSection = 0;
  DateTime _birthDate = DateTime(1999, 12, 20);
  String _userElement = 'Su';
  String _userYinYang = 'Yin';

  // Asya tarzı renk paleti
  static const Color _crimson = Color(0xFFB91C1C);
  static const Color _gold = Color(0xFFD4A030);
  static const Color _goldL = Color(0xFFFFE8A1);
  static const Color _bg = Color(0xFF0A0A0F);
  static const Color _cardBg = Color(0xFF14141A);

  static const List<Map<String, dynamic>> _sections = [
    {'icon': '🐾', 'label': 'Ruhun'},
    {'icon': '🐴', 'label': '2026'},
    {'icon': '🌊', 'label': 'Elementler'},
    {'icon': '💞', 'label': 'Kader'},
    {'icon': '⭐', 'label': 'Günlük'},
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
  void dispose() { _ctrl.dispose(); super.dispose(); }

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
      case 1: return _yearSection();
      case 2: return _elementSection();
      case 3: return _compatibilitySection();
      case 4: return _dailySection();
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
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => SizedBox(
        height: 320,
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
      // Hero — büyük hayvan figürü
      Center(child: Stack(alignment: Alignment.center, children: [
        Container(
          width: 180, height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [_crimson.withOpacity(0.07), _gold.withOpacity(0.02), Colors.transparent],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        _animalIcon(_animalIdx, 210),
      ])),
      const SizedBox(height: 6),
      // Yıllar — tıklanabilir
      GestureDetector(
        onTap: () => _showAnimalPicker(),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Flexible(child: Text(a['years'] as String, textAlign: TextAlign.center,
            style: TextStyle(color: _gold.withOpacity(0.5), fontSize: 11))),
          const SizedBox(width: 6),
          Icon(Icons.swap_horiz_rounded, color: _gold.withOpacity(0.4), size: 16),
        ]),
      ),

      const SizedBox(height: 24),

      // ── Birleşik Profil Kartı — Light Frosted Glass ──
      ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.13),
                  Colors.white.withOpacity(0.07),
                  Colors.white.withOpacity(0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.18), width: 0.6),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 30, offset: const Offset(0, 12)),
              ],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Üst: pill tag'ler
              Wrap(spacing: 8, runSpacing: 8, children: [
                _profileTag(Color(ChineseZodiacData.elements[_userElement]!['color'] as int), _userElement),
                _profileTag(_userYinYang == 'Yin' ? const Color(0xFF7C3AED) : const Color(0xFFD97706), _userYinYang),
                GestureDetector(
                  onTap: () => _showYearPicker(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _gold.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _gold.withOpacity(0.15)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 6, height: 6, decoration: BoxDecoration(
                        shape: BoxShape.circle, color: _gold.withOpacity(0.7),
                      )),
                      const SizedBox(width: 8),
                      Text('${_birthDate.year}', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 6),
                      Icon(Icons.edit_rounded, size: 12, color: _gold.withOpacity(0.5)),
                    ]),
                  ),
                ),
              ]),
              // Gradient ayırıcı
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Container(height: 0.5, decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.transparent, _gold.withOpacity(0.15), Colors.transparent]),
                )),
              ),
              // Motto — sol accent çizgi ile
              IntrinsicHeight(child: Row(children: [
                Container(width: 2, decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [_gold.withOpacity(0.5), _crimson.withOpacity(0.2)],
                  ),
                )),
                const SizedBox(width: 14),
                Expanded(child: Text(
                  _getAnimalMotto(_animalIdx),
                  style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13.5, fontStyle: FontStyle.italic, height: 1.6, letterSpacing: 0.1),
                )),
              ])),
              // Ayırıcı
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Container(height: 0.5, decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.transparent, _gold.withOpacity(0.15), Colors.transparent]),
                )),
              ),
              // Kişilik — editoryal akış tasarımı
              Builder(builder: (_) {
                final sentences = (a['personality'] as String)
                    .split('. ')
                    .where((s) => s.trim().isNotEmpty)
                    .map((s) => s.endsWith('.') ? s : '$s.')
                    .toList();
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // İlk cümle — büyük gradient hero alıntı
                  if (sentences.isNotEmpty) ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [_goldL, _gold, _goldL.withOpacity(0.7)],
                    ).createShader(bounds),
                    child: Text(
                      sentences.first,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.6,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  // Kalan cümleler — zarif akış
                  for (int i = 1; i < sentences.length; i++) ...[
                    // İnce dekoratif çizgi
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(children: [
                        Container(
                          width: i.isEven ? 40 : 60,
                          height: 0.5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              i.isEven ? _gold.withOpacity(0.4) : _crimson.withOpacity(0.4),
                              Colors.transparent,
                            ]),
                          ),
                        ),
                      ]),
                    ),
                    // Cümle metni
                    Padding(
                      padding: EdgeInsets.only(left: i.isEven ? 0 : 12),
                      child: Text(
                        sentences[i],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          height: 1.7,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  ],
                ]);
              }),
            ]),
          ),
        ),
      ),

      const SizedBox(height: 16),

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
      // Aşk & İlişki
      _glass(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _secHead('❤️', 'Aşk & İlişki'),
        const SizedBox(height: 12),
        Text(a['love'] as String, style: _bodyStyle()),
      ])),
      const SizedBox(height: 20),
      _secHead('💍', 'Burç Uyum Haritası'),
      const SizedBox(height: 4),
      Text('${a['name']} burcunun diğer burçlarla uyumu', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
      const SizedBox(height: 16),
      _compatGroup('💖 Mükemmel Uyum', best, const Color(0xFFE91E63)),
      const SizedBox(height: 12),
      _compatGroup('💛 İyi Uyum', good, const Color(0xFF4CAF50)),
      const SizedBox(height: 12),
      _compatGroup('⚡ Zorlayıcı', bad, const Color(0xFFFF9800)),
      const SizedBox(height: 20),
      // Tüm burçlarla uyum tablosu
      _secHead('📊', 'Detaylı Uyum Tablosu'),
      const SizedBox(height: 12),
      ...List.generate(12, (i) {
        if (i == _animalIdx) return const SizedBox.shrink();
        final other = ChineseZodiacData.animals[i];
        int score;
        Color c;
        String label;
        if (best.contains(i)) { score = 95; c = const Color(0xFFE91E63); label = 'Mükemmel'; }
        else if (good.contains(i)) { score = 75; c = const Color(0xFF4CAF50); label = 'İyi'; }
        else if (bad.contains(i)) { score = 35; c = const Color(0xFFFF9800); label = 'Zorlayıcı'; }
        else { score = 60; c = const Color(0xFF78909C); label = 'Normal'; }
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.withOpacity(0.2)),
          ),
          child: Row(children: [
            Text(other['emoji'] as String, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(other['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
                value: score / 100, backgroundColor: Colors.white.withOpacity(0.08), color: c, minHeight: 4,
              )),
            ])),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: Text(label, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ]),
        );
      }),
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
      case 1: _drawHorse(canvas, cx, cy, r, p); break;
      case 2: _drawElements(canvas, cx, cy, r, p); break;
      case 3: _drawHeart(canvas, cx, cy, r, p); break;
      case 4: _drawStar(canvas, cx, cy, r, p); break;
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
