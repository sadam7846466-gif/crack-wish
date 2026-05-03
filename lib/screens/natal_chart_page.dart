import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'natal_chart_engine.dart';

class NatalChartPage extends StatefulWidget {
  final String birthTime;
  final String birthPlace;
  final Map<String, dynamic> sunSignData;
  final int selectedIndex;
  const NatalChartPage({super.key, required this.birthTime, required this.birthPlace, required this.sunSignData, required this.selectedIndex});
  @override
  State<NatalChartPage> createState() => _NatalChartPageState();
}

class _NatalChartPageState extends State<NatalChartPage> {
  static const _accent = Color(0xFFD4C5A0);
  static const _accentLight = Color(0xFFE8DCC8);
  late final NatalChartEngine _engine;
  late final List<Aspect> _aspects;
  int _activeTab = 0;
  late final PageController _pageController;

  List<_InsightData> get _insights => [
    _InsightData('Ana Kişilik Özeti', '☉', [
      'Güneş ${NatalChartEngine.signs[_engine.planets[0].signIndex]} · ${_engine.planets[0].house}. Ev',
      'Ay ${NatalChartEngine.signs[_engine.planets[1].signIndex]} · ${_engine.planets[1].house}. Ev',
      'Yükselen ${NatalChartEngine.signs[_engine.ascSignIndex]}',
    ], _engine.getPersonalitySummary()),
    _InsightData('Aşk & İlişkiler', '♡', [
      'Venüs ${NatalChartEngine.signs[_engine.planets[3].signIndex]} · ${_engine.planets[3].house}. Ev',
      'Mars ${NatalChartEngine.signs[_engine.planets[4].signIndex]} · ${_engine.planets[4].house}. Ev',
    ], _engine.getLoveInterpretation()),
    _InsightData('Kariyer & Para', '⬡', [
      'MC ${NatalChartEngine.signs[_engine.mcSignIndex]}',
      'Satürn ${NatalChartEngine.signs[_engine.planets[6].signIndex]} · ${_engine.planets[6].house}. Ev',
    ], _engine.getCareerInterpretation()),
    _InsightData('Duygusal Yapı', '☽', [
      'Ay ${NatalChartEngine.signs[_engine.planets[1].signIndex]} · ${_engine.planets[1].house}. Ev',
    ], _engine.getEmotionalInterpretation()),
    _InsightData('Güçlü & Zayıf Yönler', '✦', [
      'Mars ${NatalChartEngine.signs[_engine.planets[4].signIndex]}',
      'Satürn ${NatalChartEngine.signs[_engine.planets[6].signIndex]}',
    ], _engine.getStrengthsWeaknesses()),
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final signMonths = [3,4,5,6,7,8,9,10,11,12,1,2];
    final signDays = [30,10,21,1,11,22,2,13,23,4,14,25];
    final m = signMonths[widget.selectedIndex];
    final d = signDays[widget.selectedIndex];
    final birthDate = DateTime(now.year - 25, m, d);
    _engine = NatalChartEngine(birthDate: birthDate, birthTime: widget.birthTime, birthPlace: widget.birthPlace);
    _aspects = _engine.getAspects();
    _pageController = PageController(initialPage: _activeTab);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFF0F1210),
      body: Stack(children: [
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.5),
              radius: 1.3,
              colors: [
                const Color(0xFFB07020).withOpacity(0.25),
                const Color(0xFF0F1210),
                const Color(0xFF0A0D0A),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        // ── FULL SCREEN SCROLLABLE CONTENT ──
        Positioned.fill(
          child: ShaderMask(
            shaderCallback: (Rect rect) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.white,
                  Colors.white,
                  Colors.transparent,
                ],
                stops: [0.0, 0.15, 0.95, 1.0],
              ).createShader(rect);
            },
            blendMode: BlendMode.dstIn,
            child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 80, // Header için boşluk
              bottom: MediaQuery.of(context).padding.bottom + 40, // Alt kısımdan boşluk
              left: 20,
              right: 20,
            ),
            children: [
              Center(
                child: Text(
                  '${widget.birthTime} · ${widget.birthPlace}',
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, letterSpacing: 1),
                ),
              ),
              const SizedBox(height: 24),

              // ── NATAL CHART WHEEL ──
              Center(child: _buildChartWheel(w)),
              const SizedBox(height: 32),

            // ── PLANET TABLE ──
            _buildPlanetTable(),
            const SizedBox(height: 32),

            // ── ANGULAR POINTS INFO ──
            _buildAngularPointsInfo(),
            const SizedBox(height: 32),

            // ── UNIFIED BUBBLE PANEL ──
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _accent.withOpacity(0.08)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20)],
              ),
              child: Column(children: [
                // ── TABS WITH OVERSIZED BUBBLE ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center, // FIXES ICON CENTERING!
                    children: [
                      // Base pill background for the tabs
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                      ),
                      // Sliding Bubble (Scroll-Linked)
                      AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double page = _activeTab.toDouble();
                          if (_pageController.hasClients && _pageController.position.haveDimensions) {
                            page = _pageController.page ?? _activeTab.toDouble();
                          }
                          return Align(
                            alignment: Alignment(-1.0 + (page * (2.0 / (_insights.length - 1))), 0),
                            child: FractionallySizedBox(
                              widthFactor: 1.0 / _insights.length,
                              child: Center(
                                child: Container(
                                  width: 60, // Oversized bubble
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [_accent.withOpacity(0.25), _accent.withOpacity(0.05)],
                                    ),
                                    border: Border.all(color: _accent.withOpacity(0.5), width: 1.5),
                                    boxShadow: [BoxShadow(color: _accent.withOpacity(0.15), blurRadius: 16, spreadRadius: 4)],
                                  ),
                                  child: ClipOval(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                      child: Container(color: Colors.transparent),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      // Icons
                      SizedBox(
                        height: 48,
                        child: Row(children: List.generate(_insights.length, (index) {
                          final isActive = _activeTab == index;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _activeTab = index);
                                _pageController.animateToPage(index, duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Center(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutBack,
                                  transform: Matrix4.translationValues(0, 0, 0), // Kept at 0
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 300),
                                    style: TextStyle(
                                      fontSize: isActive ? 22 : 16,
                                      color: isActive ? _accent : Colors.white.withOpacity(0.3),
                                      shadows: isActive ? [BoxShadow(color: _accent.withOpacity(0.8), blurRadius: 12)] : null,
                                    ),
                                    child: Text(_insights[index].symbol),
                                  ),
                                ),
                              ),
                            ),
                          );
                        })),
                      ),
                    ],
                  ),
                ),
                
                // ── SEPARATOR & HINT ──
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(children: [
                    Divider(height: 1, color: _accent.withOpacity(0.05), indent: 32, endIndent: 32),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.chevron_left_rounded, color: Colors.white.withOpacity(0.15), size: 14),
                      const SizedBox(width: 4),
                      Text('Kaydırarak İncele', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 9, letterSpacing: 1)),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.15), size: 14),
                    ]),
                  ]),
                ),

                // ── SWIPEABLE CONTENT ──
                SizedBox(
                  height: 220,
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (index) => setState(() => _activeTab = index),
                    itemCount: _insights.length,
                    itemBuilder: (context, index) => _buildInsightContent(_insights[index]),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 32),
          ],
        ),
      )), // ShaderMask ve Positioned.fill bitti


      // ── SMOOTH GRADIENT HEADER ──
      Positioned(
        top: 0, left: 0, right: 0,
        child: IgnorePointer(
          ignoring: false,
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              bottom: 40,
              left: 16,
              right: 16,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0F1210).withOpacity(1.0),
                  const Color(0xFF0F1210).withOpacity(0.8),
                  const Color(0xFF0F1210).withOpacity(0.0),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Doğum Haritası',
                      style: GoogleFonts.cinzel(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  const SizedBox(width: 48), // Merkezi hizalama için boşluk
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildPlanetTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accent.withOpacity(0.08)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: _accent.withOpacity(0.08))),
          ),
          child: Row(children: [
            Container(width: 3, height: 14, decoration: BoxDecoration(color: _accent.withOpacity(0.5), borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 10),
            Text('GEZEGEN POZİSYONLARI', style: TextStyle(color: _accent.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2)),
          ]),
        ),
        // Rows
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(children: _engine.planets.map((p) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              SizedBox(width: 22, child: Text(p.symbol, style: TextStyle(color: _accent, fontSize: 15))),
              const SizedBox(width: 10),
              Expanded(child: Text(p.name, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12, fontWeight: FontWeight.w500))),
              Text(NatalChartEngine.signs[p.signIndex], style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
              const SizedBox(width: 6),
              Text('${p.degree.toInt() % 30}°', style: TextStyle(color: _accent.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.w600)),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: _accent.withOpacity(0.06), borderRadius: BorderRadius.circular(6)),
                child: Text('${p.house}. Ev', style: TextStyle(color: _accent.withOpacity(0.45), fontSize: 9, fontWeight: FontWeight.w600)),
              ),
            ]),
          )).toList()),
        ),
      ]),
    );
  }

  Widget _buildAngularPointsInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _accent.withOpacity(0.015),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accent.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: _accent.withOpacity(0.8), size: 14),
              const SizedBox(width: 8),
              Text('KÖŞE NOKTALARI', style: TextStyle(color: _accent.withOpacity(0.9), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 16),
          _buildPointInfo('ASC (Yükselen)', 'Dış dünyaya gösterdiğiniz maske, imajınız ve ilk izleniminiz.'),
          const SizedBox(height: 10),
          _buildPointInfo('MC (Tepe)', 'Kariyeriniz, toplum önündeki imajınız ve hayat hedefleriniz.'),
          const SizedBox(height: 10),
          _buildPointInfo('DC (Alçalan)', 'İlişkiler, evlilik ve ortaklıklarda aradığınız temel özellikler.'),
          const SizedBox(height: 10),
          _buildPointInfo('IC (Dip)', 'Kökleriniz, aileniz, geçmişiniz ve iç dünyanızdaki temel güvenceniz.'),
        ],
      ),
    );
  }

  Widget _buildPointInfo(String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 105,
          child: Text(title, style: const TextStyle(color: _accentLight, fontSize: 12, fontWeight: FontWeight.w700)),
        ),
        Expanded(
          child: Text(desc, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12, height: 1.4)),
        ),
      ],
    );
  }

  Widget _buildInsightContent(_InsightData data, {Key? key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      // Background and border are now handled by the parent panel
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center, 
        children: [
        Text(data.title, style: const TextStyle(color: _accentLight, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8, runSpacing: 8, 
          children: data.tags.map((t) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: _accent.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
            child: Text(t, style: TextStyle(color: _accent.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.w600)),
          )).toList()
        ),
        const SizedBox(height: 20),
        Text(
          data.body, 
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 14, height: 1.7, letterSpacing: 0.2)
        ),
      ]),
    );
  }

  Widget _buildChartWheel(double screenW) {
    final chartSize = screenW * 0.92;
    return SizedBox(
      width: chartSize,
      height: chartSize,
      child: CustomPaint(painter: _NatalWheelPainter(engine: _engine, aspects: _aspects)),
    );
  }
}

// ── NATAL WHEEL PAINTER ──
class _NatalWheelPainter extends CustomPainter {
  final NatalChartEngine engine;
  final List<Aspect> aspects;

  static const _ring = Color(0xFF8A7E6B);
  static const _labelColor = Color(0xFFD4C5A0);
  static const _axisColor = Color(0xFFE8DCC8);

  _NatalWheelPainter({required this.engine, required this.aspects});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    final rOuter = r * 0.94;
    final rSignInner = r * 0.76;
    final rHouseOuter = rSignInner;
    final rHouseInner = r * 0.48;
    final rAspect = rHouseInner;

    final pRingOuter = Paint()..color = _ring.withOpacity(0.7)..style = PaintingStyle.stroke..strokeWidth = 1.2..isAntiAlias = true..strokeCap = StrokeCap.round;
    final pRingMid = Paint()..color = _ring.withOpacity(0.4)..style = PaintingStyle.stroke..strokeWidth = 0.8..isAntiAlias = true..strokeCap = StrokeCap.round;
    final pTick = Paint()..color = _ring.withOpacity(0.25)..style = PaintingStyle.stroke..strokeWidth = 0.5..isAntiAlias = true..strokeCap = StrokeCap.round;

    canvas.drawCircle(c, rOuter, pRingOuter);
    canvas.drawCircle(c, rSignInner, pRingMid);
    canvas.drawCircle(c, rHouseInner, pRingMid);

    final ascRad = -engine.ascDegree * math.pi / 180;

    // ── ZODIAC SEGMENTS + CUSTOM SYMBOLS ──
    final symPaint = Paint()..color = _labelColor.withOpacity(0.85)..style = PaintingStyle.stroke
      ..strokeWidth = 1.8..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..isAntiAlias = true;
    for (int i = 0; i < 12; i++) {
      final angle = ascRad + i * math.pi / 6;
      canvas.drawLine(_polar(c, rSignInner, angle), _polar(c, rOuter, angle), pRingMid);

      // Custom path-based symbol
      final midAngle = angle + math.pi / 12;
      final signR = (rOuter + rSignInner) / 2;
      final symPos = _polar(c, signR, midAngle);
      final symSize = (rOuter - rSignInner) * 0.35;
      _drawSym(canvas, i, symPos, symSize, symPaint);

      for (int j = 1; j < 6; j++) {
        final tickAngle = angle + j * (math.pi / 36);
        final tickLen = (j == 3) ? 0.25 : 0.10;
        canvas.drawLine(_polar(c, rSignInner, tickAngle), _polar(c, rSignInner + (rOuter - rSignInner) * tickLen, tickAngle), pTick);
      }
    }

    // ── HOUSE LINES ──
    for (int i = 0; i < 12; i++) {
      final cusp = engine.housesCusps[i][0];
      final angle = ascRad + (cusp - engine.ascDegree) * math.pi / 180;
      final isAxis = (i == 0 || i == 3 || i == 6 || i == 9);
      canvas.drawLine(_polar(c, 0, angle), _polar(c, rHouseOuter, angle), isAxis ? pRingOuter : pTick);

      // House numbers
      final nextCusp = engine.housesCusps[(i + 1) % 12][0];
      final midDeg = cusp + ((nextCusp - cusp + 360) % 360) / 2;
      final numAngle = ascRad + (midDeg - engine.ascDegree) * math.pi / 180;
      _drawText(canvas, '${i + 1}', _polar(c, (rHouseOuter + rHouseInner) / 2, numAngle), Colors.white.withOpacity(0.25), 10);
    }

    // ── ASPECT LINES (extend to full house inner ring) ──
    for (final asp in aspects) {
      final a1 = ascRad + (engine.planets[asp.planet1].degree - engine.ascDegree) * math.pi / 180;
      final a2 = ascRad + (engine.planets[asp.planet2].degree - engine.ascDegree) * math.pi / 180;
      final pos1 = _polar(c, rAspect, a1);
      final pos2 = _polar(c, rAspect, a2);

      Color aspColor;
      if (asp.exactAngle == 120 || asp.exactAngle == 60) {
        aspColor = const Color(0xFF60A5FA);
      } else if (asp.exactAngle == 90 || asp.exactAngle == 180) {
        aspColor = const Color(0xFFFF6B6B);
      } else {
        aspColor = const Color(0xFF2DD4BF);
      }
      canvas.drawLine(pos1, pos2, Paint()..color = aspColor.withOpacity(0.35)..strokeWidth = 0.8..isAntiAlias = true..strokeCap = StrokeCap.round);
    }

    // ── PLANET SYMBOLS ──
    for (final p in engine.planets) {
      final angle = ascRad + (p.degree - engine.ascDegree) * math.pi / 180;
      final pR = (rHouseInner + rAspect) / 2 + 4;
      final pos = _polar(c, pR, angle);

      // Backdrop
      canvas.drawCircle(pos, 11, Paint()..color = const Color(0xFF0A0C10).withOpacity(0.85)..isAntiAlias = true);
      canvas.drawCircle(pos, 11, Paint()..color = _ring.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 0.5..isAntiAlias = true);
      _drawText(canvas, p.symbol, pos, Colors.white.withOpacity(0.9), 13);
    }

    // ── ASC / MC / DC / IC AXES ──
    final pAxis = Paint()..color = _axisColor.withOpacity(0.8)..style = PaintingStyle.stroke..strokeWidth = 1.5..isAntiAlias = true..strokeCap = StrokeCap.round;
    final ascA = ascRad;
    final mcA = ascRad + (engine.mcDegree - engine.ascDegree) * math.pi / 180;

    // Draw full axis lines through center
    canvas.drawLine(_polar(c, rOuter + 4, ascA), _polar(c, rOuter + 4, ascA + math.pi), pAxis);
    canvas.drawLine(_polar(c, rOuter + 4, mcA), _polar(c, rOuter + 4, mcA + math.pi), pAxis);

    // Labels
    _drawText(canvas, 'ASC', _polar(c, rOuter + 16, ascA), _axisColor, 10, bold: true);
    _drawText(canvas, 'DC', _polar(c, rOuter + 16, ascA + math.pi), _axisColor, 10, bold: true);
    _drawText(canvas, 'MC', _polar(c, rOuter + 16, mcA), _axisColor, 10, bold: true);
    _drawText(canvas, 'IC', _polar(c, rOuter + 16, mcA + math.pi), _axisColor, 10, bold: true);

    // Center point
    canvas.drawCircle(c, 2.5, Paint()..color = _labelColor..isAntiAlias = true);
  }

  Offset _polar(Offset c, double r, double angle) => Offset(c.dx + math.cos(angle) * r, c.dy + math.sin(angle) * r);

  void _drawText(Canvas canvas, String text, Offset pos, Color color, double fontSize, {bool bold = false}) {
    final span = TextSpan(text: text, style: TextStyle(color: color, fontSize: fontSize, fontWeight: bold ? FontWeight.bold : FontWeight.normal));
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  void _drawSym(Canvas canvas, int i, Offset o, double s, Paint p) {
    final path = Path();
    switch (i) {
      case 0: // Koç
        path..moveTo(o.dx - s * .35, o.dy - s * .55);
        path.cubicTo(o.dx - s * .55, o.dy - s * .15, o.dx - s * .15, o.dy + s * .1, o.dx, o.dy + s * .35);
        path.cubicTo(o.dx + s * .15, o.dy + s * .1, o.dx + s * .55, o.dy - s * .15, o.dx + s * .35, o.dy - s * .55);
        path..moveTo(o.dx, o.dy + s * .35); path.lineTo(o.dx, o.dy + s * .65);
      case 1: // Boğa
        canvas.drawCircle(Offset(o.dx, o.dy + s * .2), s * .28, p);
        path..moveTo(o.dx - s * .45, o.dy);
        path.cubicTo(o.dx - s * .55, o.dy - s * .55, o.dx - s * .1, o.dy - s * .7, o.dx, o.dy - s * .4);
        path.cubicTo(o.dx + s * .1, o.dy - s * .7, o.dx + s * .55, o.dy - s * .55, o.dx + s * .45, o.dy);
      case 2: // İkizler
        path..moveTo(o.dx - s * .3, o.dy - s * .55); path.lineTo(o.dx - s * .3, o.dy + s * .55);
        path..moveTo(o.dx + s * .3, o.dy - s * .55); path.lineTo(o.dx + s * .3, o.dy + s * .55);
        path..moveTo(o.dx - s * .45, o.dy - s * .4);
        path.quadraticBezierTo(o.dx, o.dy - s * .75, o.dx + s * .45, o.dy - s * .4);
        path..moveTo(o.dx - s * .45, o.dy + s * .4);
        path.quadraticBezierTo(o.dx, o.dy + s * .75, o.dx + s * .45, o.dy + s * .4);
      case 3: // Yengeç
        path..moveTo(o.dx + s * .15, o.dy - s * .15);
        path.cubicTo(o.dx - s * .2, o.dy - s * .15, o.dx - s * .5, o.dy - s * .55, o.dx - s * .1, o.dy - s * .5);
        path..moveTo(o.dx + s * .15, o.dy - s * .15);
        path.cubicTo(o.dx + s * .5, o.dy - s * .15, o.dx + s * .5, o.dy + s * .15, o.dx + s * .15, o.dy + s * .15);
        path..moveTo(o.dx - s * .15, o.dy + s * .15);
        path.cubicTo(o.dx + s * .2, o.dy + s * .15, o.dx + s * .5, o.dy + s * .55, o.dx + s * .1, o.dy + s * .5);
        path..moveTo(o.dx - s * .15, o.dy + s * .15);
        path.cubicTo(o.dx - s * .5, o.dy + s * .15, o.dx - s * .5, o.dy - s * .15, o.dx - s * .15, o.dy - s * .15);
      case 4: // Aslan
        canvas.drawCircle(Offset(o.dx + s * .2, o.dy + s * .25), s * .2, p);
        path..moveTo(o.dx, o.dy + s * .25);
        path.cubicTo(o.dx - s * .4, o.dy + s * .25, o.dx - s * .5, o.dy - s * .1, o.dx - s * .2, o.dy - s * .35);
        path.cubicTo(o.dx, o.dy - s * .6, o.dx + s * .4, o.dy - s * .5, o.dx + s * .35, o.dy - s * .15);
      case 5: // Başak
        path..moveTo(o.dx - s * .45, o.dy + s * .4); path.lineTo(o.dx - s * .45, o.dy);
        path.cubicTo(o.dx - s * .45, o.dy - s * .45, o.dx - s * .15, o.dy - s * .45, o.dx - s * .15, o.dy);
        path.cubicTo(o.dx - s * .15, o.dy - s * .45, o.dx + s * .15, o.dy - s * .45, o.dx + s * .15, o.dy);
        path.cubicTo(o.dx + s * .15, o.dy - s * .45, o.dx + s * .45, o.dy - s * .45, o.dx + s * .45, o.dy);
        path.lineTo(o.dx + s * .45, o.dy + s * .2);
        path..moveTo(o.dx + s * .2, o.dy + s * .15); path.lineTo(o.dx + s * .55, o.dy + s * .5);
        path..moveTo(o.dx + s * .3, o.dy + s * .38); path.lineTo(o.dx + s * .55, o.dy + s * .25);
      case 6: // Terazi
        path..moveTo(o.dx - s * .5, o.dy + s * .35); path.lineTo(o.dx + s * .5, o.dy + s * .35);
        path..moveTo(o.dx - s * .5, o.dy + s * .1); path.lineTo(o.dx + s * .5, o.dy + s * .1);
        path..moveTo(o.dx - s * .35, o.dy + s * .1);
        path.cubicTo(o.dx - s * .35, o.dy - s * .55, o.dx + s * .35, o.dy - s * .55, o.dx + s * .35, o.dy + s * .1);
      case 7: // Akrep
        path..moveTo(o.dx - s * .5, o.dy + s * .35); path.lineTo(o.dx - s * .5, o.dy - s * .05);
        path.cubicTo(o.dx - s * .5, o.dy - s * .45, o.dx - s * .2, o.dy - s * .45, o.dx - s * .2, o.dy - s * .05);
        path.cubicTo(o.dx - s * .2, o.dy - s * .45, o.dx + s * .1, o.dy - s * .45, o.dx + s * .1, o.dy - s * .05);
        path.lineTo(o.dx + s * .1, o.dy + s * .25); path.lineTo(o.dx + s * .4, o.dy + s * .45);
        path..moveTo(o.dx + s * .4, o.dy + s * .45); path.lineTo(o.dx + s * .5, o.dy + s * .25);
        path..moveTo(o.dx + s * .4, o.dy + s * .45); path.lineTo(o.dx + s * .2, o.dy + s * .4);
      case 8: // Yay
        path..moveTo(o.dx - s * .45, o.dy + s * .55); path.lineTo(o.dx + s * .45, o.dy - s * .45);
        path.lineTo(o.dx + s * .15, o.dy - s * .45);
        path..moveTo(o.dx + s * .45, o.dy - s * .45); path.lineTo(o.dx + s * .45, o.dy - s * .15);
        path..moveTo(o.dx - s * .15, o.dy + s * .05); path.lineTo(o.dx + s * .2, o.dy + s * .3);
      case 9: // Oğlak
        path..moveTo(o.dx - s * .3, o.dy - s * .5);
        path.cubicTo(o.dx - s * .45, o.dy - s * .65, o.dx - s * .05, o.dy - s * .7, o.dx, o.dy - s * .4);
        path.lineTo(o.dx + s * .1, o.dy + s * .1);
        path.cubicTo(o.dx + s * .45, o.dy + s * .6, o.dx + s * .05, o.dy + s * .7, o.dx - s * .15, o.dy + s * .45);
        path.cubicTo(o.dx - s * .35, o.dy + s * .2, o.dx + s * .05, o.dy + s * .1, o.dx + s * .1, o.dy + s * .35);
      case 10: // Kova
        for (int j = 0; j < 2; j++) {
          final y = o.dy + (j == 0 ? -s * .15 : s * .2);
          path..moveTo(o.dx - s * .5, y);
          path.cubicTo(o.dx - s * .35, y - s * .25, o.dx - s * .15, y + s * .25, o.dx, y);
          path.cubicTo(o.dx + s * .15, y - s * .25, o.dx + s * .35, y + s * .25, o.dx + s * .5, y);
        }
      case 11: // Balık
        path..moveTo(o.dx - s * .45, o.dy); path.lineTo(o.dx + s * .45, o.dy);
        path..moveTo(o.dx - s * .15, o.dy - s * .5);
        path.cubicTo(o.dx - s * .55, o.dy - s * .2, o.dx - s * .55, o.dy + s * .2, o.dx - s * .15, o.dy + s * .5);
        path..moveTo(o.dx + s * .15, o.dy - s * .5);
        path.cubicTo(o.dx + s * .55, o.dy - s * .2, o.dx + s * .55, o.dy + s * .2, o.dx + s * .15, o.dy + s * .5);
    }
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InsightData {
  final String title;
  final String symbol;
  final List<String> tags;
  final String body;
  _InsightData(this.title, this.symbol, this.tags, this.body);
}
