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

  // Verdigris Patina — Antik Bronz & Antik Yeşil
  static const Color _goldBright = Color(0xFF9A7040); // Antik bronz (bakır pası, sıcak)

  static const Color _bg = Color(0xFF080C09);         // Zifiri siyah, hafif yeşil niyansi
  static const Color _obsidian = Color(0xFF0F1510);   // Koyu obsidyen taş
  static const Color _obsidianLight = Color(0xFF1A201B); // Hafif açık gölge
  static const Color _jade = Color(0xFF4A7A5A);       // Verdigris (yaşlanmış bakır yeşili, mat)
  static const Color _amber = Color(0xFF7A5430);      // Koyu bronz gölge


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

  // Antik taş görünümlü kart yapıcısı
  Widget _buildAncientCard({required Widget child, Color? borderColor, EdgeInsetsGeometry padding = const EdgeInsets.all(20)}) {
    return Container(
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
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildContent()),
              ],
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


  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 40),
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
        
        // Element/Yön kaldırıldı, sadece Kadim Bilgelik Kartı kaldı
        
        // Kadim Bilgelik Kartı (Kapsamlı Açıklama)
        _buildAncientCard(
          padding: const EdgeInsets.all(20),
          borderColor: _jade.withValues(alpha: 0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                   Icon(Icons.auto_awesome, color: _jade, size: 16),
                   const SizedBox(width: 8),
                   Expanded(
                     child: Text('KADİM BİLGELİK', style: TextStyle(color: _jade, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
                   ),
                ]
              ),
              const SizedBox(height: 12),
              Text(
                n['description'] as String,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14, height: 1.6),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Ton (Kişisel Frekans) Kartı
        _buildAncientCard(
          padding: const EdgeInsets.all(20),
          borderColor: _goldBright.withValues(alpha: 0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                   Icon(Icons.waves, color: _goldBright, size: 16),
                   const SizedBox(width: 8),
                   Expanded(
                     child: Text('GALAKTİK TON ($_userTone)', style: TextStyle(color: _goldBright, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
                   ),
                ]
              ),
              const SizedBox(height: 12),
              Text(
                _userToneData['desc']!,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14, height: 1.6),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Ruh Rehberi
        _buildStoneLabel('RUH REHBERİ', n['spirit'], Icons.pets, baseColor: _goldBright),
        const SizedBox(height: 16),
        
        _buildStoneLabel('HAYATTAKİ ROLÜN', n['role'], Icons.star_rounded, borderColor: _goldBright.withValues(alpha: 0.3)),
      ],
    );
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
  // FEATURE 1 & 6: GÜNLÜK ENERJİ
  // ══════════════════════════════════════════
  Widget _buildDailyEnergySection() {
    final now = DateTime.now();
    final todayIdx = MayanZodiacData.nahualIndex(now);
    final todayNahual = MayanZodiacData.nahuales[todayIdx];
    final todayTone = MayanZodiacData.galacticTone(now);
    final todayToneData = MayanZodiacData.galacticTones[todayTone - 1];
    
    int seed = _getSeed(now) + _userIdx;
    int genEnergy = _deterministicRandom(seed, 1, 60, 98);
    int relEnergy = _deterministicRandom(seed, 2, 40, 95);
    int workEnergy = _deterministicRandom(seed, 3, 50, 99);
    
    int alignScore = _deterministicRandom(seed, 4, 30, 95);
    int riskScore = 100 - alignScore + _deterministicRandom(seed, 5, -10, 10).clamp(-20, 20);
    riskScore = riskScore.clamp(5, 95);

    String advice = alignScore > 65 ? "BUGÜN ÖNE ÇIK VE PARLA" : "GERİ PLANDA KAL VE İZLE";
    String doWhat = alignScore > 65 ? "Yeni başlangıçlar, fırsat arayışı" : "İç gözlem, erteleme, dinlenme";
    String dontWhat = alignScore > 65 ? "Fırsatları kaçırmak, pasif kalmak" : "Büyük riskler, kışkırtıcı diyaloglar";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'KUTSAL TZOLK\'IN ENERJİSİ',
          style: TextStyle(color: _jade, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 2),
        ),
        const SizedBox(height: 12),
        _buildAncientCard(
          borderColor: _goldBright.withValues(alpha: 0.3),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  _buildNahualIcon(todayIdx, 60, _goldBright),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${todayNahual['name'].toUpperCase()} (TON $todayTone)', style: GoogleFonts.cinzel(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 2)),
                        Text('${todayNahual['words'].toUpperCase()}\n${todayToneData['title']!.toUpperCase()}', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 9, fontWeight: FontWeight.w500, letterSpacing: 1.5)),
                      ],
                    ),
                  ),
                  _buildGeomScore(genEnergy, "GENEL"),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLinearStoneScore("İLİŞKİ", relEnergy, Colors.pinkAccent),
                  _buildLinearStoneScore("KARİYER", workEnergy, Colors.lightBlueAccent),
                ],
              ),
              const SizedBox(height: 24),
              _buildTaskRow(Icons.check_box_outlined, _jade, "YAP", doWhat),
              const SizedBox(height: 10),
              _buildTaskRow(Icons.cancel_presentation_outlined, _amber, "ERTELE", dontWhat),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'GÜNKÜL HİZALANMA',
          style: TextStyle(color: _jade, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 2),
        ),
        const SizedBox(height: 12),
        _buildAncientCard(
          borderColor: alignScore > 65 ? _jade.withValues(alpha: 0.5) : _amber.withValues(alpha: 0.3),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text('%$alignScore', style: const TextStyle(color: _jade, fontSize: 36, fontWeight: FontWeight.w900)),
                      Text('UYUMLU', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                    ],
                  ),
                  Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.1)),
                  Column(
                    children: [
                      Text('%$riskScore', style: const TextStyle(color: _amber, fontSize: 36, fontWeight: FontWeight.w900)),
                      Text('RİSKLİ', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: ShapeDecoration(
                  color: alignScore > 65 ? _jade.withValues(alpha: 0.1) : _amber.withValues(alpha: 0.1),
                  shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                alignment: Alignment.center,
                child: Text(
                  advice,
                  style: TextStyle(
                    color: alignScore > 65 ? _jade : _amber,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGeomScore(int val, String label) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                value: val / 100,
                color: _jade,
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                strokeWidth: 6,
              ),
            ),
            Text(
              '$val',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildLinearStoneScore(String label, int val, Color c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 80,
              height: 8,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05)),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: val / 100,
                child: Container(color: c),
              ),
            ),
            const SizedBox(width: 8),
            Text('%$val', style: TextStyle(color: c, fontSize: 14, fontWeight: FontWeight.w900)),
          ],
        ),
      ],
    );
  }

  Widget _buildTaskRow(IconData icon, Color color, String title, String body) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
              const SizedBox(height: 4),
              Text(body, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
            ],
          ),
        ),
      ],
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
            const Text('ENERJİ DALGALANMA GRAFİĞİ', style: TextStyle(color: _jade, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 2)),
            Text('30 GÜN', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        _buildAncientCard(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: SizedBox(
            height: 180,
            width: double.infinity,
            child: CustomPaint(
              painter: _WaveGraphPainter(
                color: _jade,
                accent: _goldBright,
                seed: _getSeed(DateTime.now()) + _userIdx,
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
      {'n': MayanZodiacData.nahuales[dnaIndices[1]], 'p': _jade, 'c': _jade},
      {'n': MayanZodiacData.nahuales[dnaIndices[2]], 'p': p3, 'c': Colors.lightBlueAccent},
      {'n': MayanZodiacData.nahuales[dnaIndices[3]], 'p': p4, 'c': Colors.pinkAccent},
    ];
    
    String desc1 = dnaList[0]['n']['words'].split('&')[0].trim();
    String desc2 = dnaList[1]['n']['words'].split('&').last.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('MAYA ENERJİ DNA\'SI', style: TextStyle(color: _jade, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 2)),
        const SizedBox(height: 8),
        Text('Ruhunun antik kodlaması', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
        const SizedBox(height: 24),
        
        ...dnaList.map((dna) {
          final n = dna['n'];
          final p = dna['p'] is Color ? p2 : dna['p'] as int;
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
        
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: ShapeDecoration(
            color: _goldBright.withValues(alpha: 0.05),
            shape: BeveledRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: _goldBright.withValues(alpha: 0.2), width: 1.5),
            ),
          ),
          child: Column(
            children: [
              const Text('HAKİM ENERJİ SENTEZİ', style: TextStyle(color: _goldBright, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
              const SizedBox(height: 12),
              Text(
                '"$desc1 & $desc2"',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
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
}

// ══════════════════════════════════════════
// CUSTOM PAINTER: DALGALANMA GRAFİĞİ (Obsidian Edge)
// ══════════════════════════════════════════
class _WaveGraphPainter extends CustomPainter {
  final Color color;
  final Color accent;
  final int seed;
  
  _WaveGraphPainter({required this.color, required this.accent, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    
    // Keskin ızgara hatları
    final gridPaint = Paint()..color = Colors.white.withValues(alpha: 0.05)..strokeWidth = 1;
    for(int i=1; i<4; i++) {
       canvas.drawLine(Offset(0, h*i/4), Offset(w, h*i/4), gridPaint);
    }
    for(int i=1; i<6; i++) {
       canvas.drawLine(Offset(w*i/6, 0), Offset(w*i/6, h), gridPaint);
    }

    final path = Path();
    path.moveTo(0, h/2);
    
    List<Offset> points = [];
    for(int i = 0; i <= 30; i++) {
      double x = (i / 30) * w;
      double waveStr = math.sin(i * 0.4 + (seed % 10)) * 0.4 
                     + math.cos(i * 0.2 + (seed % 7)) * 0.3
                     + math.sin(i * 0.8) * 0.1;
      double y = h/2 - (waveStr * h/2.2); 
      points.add(Offset(x, y));
    }

    path.moveTo(points[0].dx, points[0].dy);
    for(int i=0; i<points.length-1; i++) {
      // Maya'nın eski geometrisini anımsatsın diye line kullanalım (tamamen smooth curve yerine köşeli de olabilir) ama okunaklı olsun diye curve tutalım
      final p0 = points[i];
      final p1 = points[i+1];
      path.quadraticBezierTo(p0.dx, p0.dy, (p0.dx + p1.dx)/2, (p0.dy + p1.dy)/2);
    }
    path.lineTo(points.last.dx, points.last.dy);

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.bevel;

    canvas.drawPath(path, linePaint);

    // Kritik noktalar
    _drawPoint(canvas, points[5], "+5\nYÜKSEK", color);
    _drawPoint(canvas, points[12], "+12\nDÜŞÜK", const Color(0xFFFF6D00));
    _drawPoint(canvas, points[20], "+20\nFIRSAT", accent);
  }

  void _drawPoint(Canvas canvas, Offset offset, String text, Color c) {
    canvas.drawRect(Rect.fromCenter(center: offset, width: 8, height: 8), Paint()..color = Colors.black);
    canvas.drawRect(Rect.fromCenter(center: offset, width: 6, height: 6), Paint()..color = c);

    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, height: 1.3)),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.layout();
    
    double dyOffset = offset.dy < 60 ? 12 : -tp.height - 8;
    tp.paint(canvas, Offset(offset.dx - tp.width/2, offset.dy + dyOffset));
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
