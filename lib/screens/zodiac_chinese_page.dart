import 'package:flutter/material.dart';
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
    {'icon': '📜', 'label': 'Profil'},
    {'icon': '🐎', 'label': '2026'},
    {'icon': '☯️', 'label': 'Element'},
    {'icon': '💼', 'label': 'Kariyer'},
    {'icon': '💍', 'label': 'Uyum'},
    {'icon': '⏰', 'label': 'Zamanlama'},
    {'icon': '👶', 'label': 'İsim'},
    {'icon': '📅', 'label': 'Bugün'},
    {'icon': '🏡', 'label': 'Feng Shui'},
    {'icon': '🔄', 'label': 'Karşılaştır'},
  ];

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
        // Arka plan gradienti
        Positioned.fill(child: Container(
          decoration: BoxDecoration(gradient: RadialGradient(
            center: const Alignment(0, -0.6), radius: 1.4,
            colors: [_crimson.withOpacity(0.12), _bg, const Color(0xFF050508)],
            stops: const [0, 0.5, 1],
          )),
        )),
        // Büyük bulanık karakter
        Positioned(top: -20, right: -30, child: Opacity(
          opacity: 0.04,
          child: Text(_animal['nameCn'] as String, style: const TextStyle(fontSize: 280, fontWeight: FontWeight.w900, color: Colors.white)),
        )),
        SafeArea(bottom: false, child: Column(children: [
          _buildHeader(),
          _buildSectionTabs(),
          Expanded(child: _buildContent()),
        ])),
      ]),
    );
  }

  // ── HEADER ──
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(children: [
        const GlassBackButton(),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: _crimson.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _crimson.withOpacity(0.3)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(_animal['emoji'] as String, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text('中国占星术', style: TextStyle(color: _goldL.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
    );
  }

  // ── SECTION TABS ──
  Widget _buildSectionTabs() {
    return Container(
      height: 52,
      margin: const EdgeInsets.only(top: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _sections.length,
        itemBuilder: (_, i) {
          final sel = i == _activeSection;
          return GestureDetector(
            onTap: () => setState(() => _activeSection = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: sel ? _crimson.withOpacity(0.25) : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: sel ? _gold.withOpacity(0.5) : Colors.white.withOpacity(0.08)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(_sections[i]['icon'] as String, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(_sections[i]['label'] as String, style: TextStyle(
                  color: sel ? _goldL : Colors.white.withOpacity(0.5),
                  fontSize: 12, fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                )),
              ]),
            ),
          );
        },
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
      case 3: return _careerSection();
      case 4: return _compatibilitySection();
      case 5: return _timingSection();
      case 6: return _namingSection();
      case 7: return _dailySection();
      case 8: return _fengShuiSection();
      case 9: return _comparisonSection();
      default: return _profileSection();
    }
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
      // Hero
      Center(child: Text(a['emoji'] as String, style: const TextStyle(fontSize: 80))),
      const SizedBox(height: 12),
      Center(child: ShaderMask(
        shaderCallback: (b) => const LinearGradient(colors: [_gold, _goldL]).createShader(b),
        child: Text(a['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800)),
      )),
      Center(child: Text('${a['nameCn']}  ·  ${a['nameEn']}', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14, letterSpacing: 2))),
      const SizedBox(height: 6),
      Center(child: Text(a['years'] as String, textAlign: TextAlign.center, style: TextStyle(color: _gold.withOpacity(0.5), fontSize: 11))),
      const SizedBox(height: 24),
      // Element, YinYang, Yıl
      Row(children: [
        _infoChip(ChineseZodiacData.elements[_userElement]!['emoji'] as String, 'Element', _userElement),
        const SizedBox(width: 10),
        _infoChip('☯️', 'Yin/Yang', _userYinYang),
        const SizedBox(width: 10),
        _infoChip('📅', 'Doğum', '${_birthDate.year}'),
      ]),
      const SizedBox(height: 24),
      // Kişilik
      _glass(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _secHead('🐾', 'Kişilik Analizi'),
        const SizedBox(height: 12),
        Text(a['personality'] as String, style: _bodyStyle()),
      ])),
      const SizedBox(height: 16),
      // Özellikler
      _secHead('✦', 'Öne Çıkan Özellikler'),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: traits.map((t) => _chip(t)).toList()),
      const SizedBox(height: 20),
      // Güçlü / Zayıf
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: _glass(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _miniHead('💪', 'Güçlü Yönler'),
          const SizedBox(height: 8),
          ...strengths.map((s) => _bulletItem(s, const Color(0xFF4CAF50))),
        ]))),
        const SizedBox(width: 12),
        Expanded(child: _glass(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _miniHead('⚡', 'Zayıf Yönler'),
          const SizedBox(height: 8),
          ...weaknesses.map((w) => _bulletItem(w, const Color(0xFFFF9800))),
        ]))),
      ]),
      const SizedBox(height: 20),
      // Aşk
      _glass(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _secHead('❤️', 'Aşk & İlişki'),
        const SizedBox(height: 12),
        Text(a['love'] as String, style: _bodyStyle()),
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
            Text('AT YILI · 马年', style: TextStyle(color: _goldL.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 2)),
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
    ]);
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
    ]);
  }

  // ══════════════════════════════════════════
  // 3) KARİYER
  // ══════════════════════════════════════════
  Widget _careerSection() {
    final careers = _animal['careers'] as List<String>;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _glass(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _secHead('💼', 'Kariyer Haritanız'),
        const SizedBox(height: 14),
        Text(_animal['careerAdvice'] as String, style: _bodyStyle()),
      ])),
      const SizedBox(height: 20),
      _secHead('🎯', 'Önerilen Meslekler'),
      const SizedBox(height: 12),
      ...careers.asMap().entries.map((e) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _crimson.withOpacity(0.06 + e.key * 0.02),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _gold.withOpacity(0.1 + e.key * 0.05)),
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: _gold.withOpacity(0.15), shape: BoxShape.circle),
            child: Center(child: Text('${e.key + 1}', style: TextStyle(color: _goldL, fontSize: 16, fontWeight: FontWeight.w800))),
          ),
          const SizedBox(width: 14),
          Text(e.value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        ]),
      )),
    ]);
  }

  // ══════════════════════════════════════════
  // 4) EVLİLİK UYUMU
  // ══════════════════════════════════════════
  Widget _compatibilitySection() {
    final best = (_animal['bestMatch'] as List<int>);
    final good = (_animal['goodMatch'] as List<int>);
    final bad = (_animal['conflict'] as List<int>);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _secHead('💍', 'Burç Uyum Haritası'),
      const SizedBox(height: 4),
      Text('${_animal['name']} burcunun diğer burçlarla uyumu', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
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

  // ══════════════════════════════════════════
  // 5) ZAMANLAMA
  // ══════════════════════════════════════════
  Widget _timingSection() {
    final timing = _animal['timingAdvice'] as Map<String, int>;
    final items = [
      {'key': 'isKurma', 'emoji': '🏢', 'label': 'İş Kurma', 'desc': 'Kendi işini kurma zamanı mı?'},
      {'key': 'yatirim', 'emoji': '📈', 'label': 'Yatırım', 'desc': 'Yatırım yapma zamanı mı?'},
      {'key': 'evlenme', 'emoji': '💒', 'label': 'Evlenme', 'desc': 'Evlilik için uygun zaman mı?'},
      {'key': 'cocuk', 'emoji': '👶', 'label': 'Çocuk', 'desc': 'Aile büyütme zamanı mı?'},
      {'key': 'seyahat', 'emoji': '✈️', 'label': 'Seyahat', 'desc': 'Uzun yolculuklar için uygun mu?'},
      {'key': 'tasima', 'emoji': '🏠', 'label': 'Taşınma', 'desc': 'Ev değiştirme zamanı mı?'},
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _glass(child: Column(children: [
        const Text('⏰', style: TextStyle(fontSize: 40)),
        const SizedBox(height: 8),
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(colors: [_gold, _goldL]).createShader(b),
          child: const Text('Şimdi Ne Zamanı?', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 8),
        Text('${_animal['name']} burcu için 2026 zamanlama rehberi', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
      ])),
      const SizedBox(height: 20),
      ...items.map((item) {
        final score = timing[item['key']] ?? 3;
        final colors = [const Color(0xFFE53935), const Color(0xFFFF9800), const Color(0xFFFFEB3B), const Color(0xFF4CAF50), const Color(0xFF2E7D32)];
        final labels = ['Uygun Değil', 'Dikkatli Ol', 'Nötr', 'Uygun', 'Çok Uygun'];
        final c = colors[score - 1];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.withOpacity(0.06), borderRadius: BorderRadius.circular(18),
            border: Border.all(color: c.withOpacity(0.2)),
          ),
          child: Row(children: [
            Text(item['emoji'] as String, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item['label'] as String, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              Text(item['desc'] as String, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
              const SizedBox(height: 6),
              Row(children: List.generate(5, (i) => Container(
                width: 24, height: 6, margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: i < score ? c : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(3),
                ),
              ))),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: Text(labels[score - 1], style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
          ]),
        );
      }),
    ]);
  }

  // ══════════════════════════════════════════
  // 6) ÇOCUK İSİMLENDİRME
  // ══════════════════════════════════════════
  Widget _namingSection() {
    final names = _animal['childNames'] as Map<String, List<String>>;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _glass(child: Column(children: [
        const Text('👶', style: TextStyle(fontSize: 40)),
        const SizedBox(height: 8),
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(colors: [_gold, _goldL]).createShader(b),
          child: const Text('Element İsim Rehberi', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 8),
        Text('$_userElement elementine göre isim önerileri', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
      ])),
      const SizedBox(height: 20),
      _secHead('👦', 'Erkek İsimleri'),
      const SizedBox(height: 10),
      Wrap(spacing: 10, runSpacing: 10, children: (names['erkek'] ?? []).map((n) => _nameChip(n, const Color(0xFF42A5F5))).toList()),
      const SizedBox(height: 20),
      _secHead('👧', 'Kız İsimleri'),
      const SizedBox(height: 10),
      Wrap(spacing: 10, runSpacing: 10, children: (names['kiz'] ?? []).map((n) => _nameChip(n, const Color(0xFFEC407A))).toList()),
      const SizedBox(height: 20),
      _glass(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _secHead('💡', 'Neden Element İsmi?'),
        const SizedBox(height: 10),
        Text('Çin astrolojisinde çocuğun ismi, doğum elementine uygun seçilir. Bu, çocuğun enerjisini güçlendirir ve doğal yeteneklerini destekler. '
            '$_userElement elementine ait isimler, bu elementin özelliklerini taşır ve çocuğa koruyucu bir enerji sağlar.',
            style: _bodyStyle()),
      ])),
    ]);
  }

  // ══════════════════════════════════════════
  // 7) GÜN DEĞERİ
  // ══════════════════════════════════════════
  Widget _dailySection() {
    final now = DateTime.now();
    final fortune = ChineseZodiacData.getDayFortune(_animalIdx, now);
    final c = fortune['color'] as Color;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _glass(child: Column(children: [
        Text(fortune['emoji'] as String, style: const TextStyle(fontSize: 50)),
        const SizedBox(height: 8),
        ShaderMask(
          shaderCallback: (b) => LinearGradient(colors: [c, c.withOpacity(0.6)]).createShader(b),
          child: Text(fortune['level'] as String, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 12),
        // Puan çubuğu
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
  // 8) FENG SHUI
  // ══════════════════════════════════════════
  Widget _fengShuiSection() {
    final fs = _animal['fengShui'] as Map<String, String>;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _glass(child: Column(children: [
        const Text('🏡', style: TextStyle(fontSize: 50)),
        const SizedBox(height: 8),
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(colors: [_gold, _goldL]).createShader(b),
          child: const Text('Feng Shui Rehberi', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 8),
        Text('$_userElement elementine göre yaşam alanı tasarımı', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
      ])),
      const SizedBox(height: 20),
      _fengShuiCard('🎨', 'Renk Paleti', fs['renk']!),
      _fengShuiCard('🧭', 'Şanslı Yön', fs['yön']!),
      _fengShuiCard('🪵', 'Malzeme', fs['malzeme']!),
      const SizedBox(height: 16),
      _glass(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _secHead('✨', 'Tasarım Tavsiyeleri'),
        const SizedBox(height: 12),
        Text(fs['tavsiye']!, style: _bodyStyle()),
      ])),
      const SizedBox(height: 16),
      _glass(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _secHead('🚫', 'Kaçınılması Gerekenler'),
        const SizedBox(height: 12),
        ...(_animal['unluckyColors'] as List<String>).map((c) => _bulletItem('$c tonlarından kaçının', const Color(0xFFE53935))),
        _bulletItem('Dağınık ve karmaşık ortamlar', const Color(0xFFE53935)),
        _bulletItem('Kapı karşısında ayna kullanmayın', const Color(0xFFE53935)),
      ])),
    ]);
  }

  // ══════════════════════════════════════════
  // 9) BATI-ASYA KARŞILAŞTIRMASI
  // ══════════════════════════════════════════
  Widget _comparisonSection() {
    final md = _birthDate.month * 100 + _birthDate.day;
    final wSign = ChineseZodiacData.westernSignName(md);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _glass(child: Column(children: [
        const Text('🔄', style: TextStyle(fontSize: 40)),
        const SizedBox(height: 8),
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(colors: [_gold, _goldL]).createShader(b),
          child: const Text('İki Dünya, Bir Sen', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 8),
        Text('Batı ve Doğu astrolojisinin birleşik analizi', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
      ])),
      const SizedBox(height: 20),
      Row(children: [
        Expanded(child: _glass(child: Column(children: [
          const Text('🌍', style: TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text('Batı', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
          Text(wSign, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        ]))),
        const SizedBox(width: 12),
        Expanded(child: _glass(child: Column(children: [
          Text(_animal['emoji'] as String, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text('Doğu', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
          Text(_animal['name'] as String, style: TextStyle(color: _goldL, fontSize: 18, fontWeight: FontWeight.w700)),
        ]))),
      ]),
      const SizedBox(height: 20),
      _comparisonRow('📅 Baz', 'Doğum ayı ve günü', 'Doğum yılı'),
      _comparisonRow('🌿 Element', '4 Element (Ateş/Su/Hava/Toprak)', '5 Element (Ağaç/Ateş/Toprak/Metal/Su)'),
      _comparisonRow('🔄 Döngü', '12 aylık döngü', '12 yıllık döngü'),
      _comparisonRow('☯️ Kutup', 'Pozitif/Negatif', 'Yin/Yang'),
      _comparisonRow('🪐 Gezegen', 'Yönetici gezegen', 'Element baskınlığı'),
      const SizedBox(height: 16),
      _glass(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _secHead('🔮', 'Birleşik Yorum'),
        const SizedBox(height: 12),
        Text('$wSign burcunun analitik gücü ile ${_animal['name']} burcunun sezgisel derinliği birleştiğinde, '
            'hem Doğu hem Batı bilgeliğinden beslenen benzersiz bir karakter profili ortaya çıkar. '
            '$_userElement elementinin dengesiyle $_userYinYang enerjinizi harmanlayarak, '
            'her iki geleneğin de güçlü yanlarını taşıyan birisiniz.',
            style: _bodyStyle()),
      ])),
    ]);
  }

  // ══════════════════════════════════════════
  // YARDIMCI WİDGET'LAR
  // ══════════════════════════════════════════
  Widget _glass({required Widget child}) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: _cardBg, borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withOpacity(0.06)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
    ),
    child: child,
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

  Widget _comparisonRow(String title, String west, String east) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: _cardBg, borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.06)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(color: _goldL, fontSize: 13, fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      Row(children: [
        Expanded(child: Text(west, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12))),
        Container(width: 1, height: 30, color: Colors.white.withOpacity(0.1)),
        Expanded(child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(east, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
        )),
      ]),
    ]),
  );

  TextStyle _bodyStyle() => TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 14, height: 1.65);
}
