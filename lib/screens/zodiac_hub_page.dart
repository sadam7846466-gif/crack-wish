import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../widgets/glass_back_button.dart';
import '../widgets/guidance_booklet.dart';
import '../widgets/fade_page_route.dart';
import 'zodiac_page.dart';
import 'zodiac_chinese_page.dart';
import 'zodiac_mayan_page.dart';

class ZodiacHubPage extends StatefulWidget {
  const ZodiacHubPage({super.key});
  @override
  State<ZodiacHubPage> createState() => _ZodiacHubPageState();
}

class _ZodiacHubPageState extends State<ZodiacHubPage>
    with TickerProviderStateMixin {
  late AnimationController _spin;
  late AnimationController _entrance;
  late Animation<double> _t1, _t2, _t3;

  static const Color _gold = Color(0xFFFFD060);
  static const Color _goldL = Color(0xFFFFE8A1);
  static const Color _goldD = Color(0xFFB07020);
  static const Color _bg = Color(0xFF0F1210);

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(vsync: this, duration: const Duration(seconds: 180)); // Şimdilik durduruldu
    _entrance = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..forward();
    _t1 = CurvedAnimation(parent: _entrance, curve: const Interval(0, .4, curve: Curves.easeOutCubic));
    _t2 = CurvedAnimation(parent: _entrance, curve: const Interval(.15, .55, curve: Curves.easeOutCubic));
    _t3 = CurvedAnimation(parent: _entrance, curve: const Interval(.3, .7, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() { _spin.dispose(); _entrance.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    // Çark boyutunu üçü de sığacak şekilde dinamik hesaplıyoruz:
    final wheelSize = math.min(w * 0.48, h * 0.22);
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(children: [
        // Arka plan
        Container(decoration: BoxDecoration(gradient: RadialGradient(
          center: const Alignment(0, -0.6), radius: 1.6,
          colors: [_goldD.withOpacity(0.2), _bg], stops: const [0, 1],
        ))),
        SafeArea(top: false, bottom: false, child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10,
            bottom: 40,
          ),
          child: Column(children: [
            // Üst Bar (Geri Butonu)
            _animWrap(_t1, Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const GlassBackButton(),
                  GuidanceBookletButton(
                    dialogTitleTr: 'Burç Rehberi',
                    dialogTitleEn: 'Zodiac Guide',
                    items: const [
                      GuidanceItem(
                        titleTr: '3 Kadim Gelenek',
                        titleEn: '3 Ancient Traditions',
                        descTr: 'Batı Zodiyağı, Çin Astrolojisi ve Maya Takvimi — binlerce yıllık üç farklı gelenek, yıldızları ve zamanı farklı yorumlasa da ortak amaçları aynı: insanın iç dünyasını anlamak.',
                        descEn: 'Western Zodiac, Chinese Astrology, and Maya Calendar — three traditions spanning millennia. Though they interpret stars and time differently, they share a common goal: understanding the inner self.',
                        icon: Icons.auto_awesome,
                      ),
                      GuidanceItem(
                        titleTr: 'Batı Zodiyağı',
                        titleEn: 'Western Zodiac',
                        descTr: 'Güneşin doğum anındaki konumuna göre 12 burç belirlenir. Her burç, kişiliğinizin farklı yönlerini — güçlü yanlarınızı, zorluklarınızı ve duygusal eğilimlerinizi yansıtır.',
                        descEn: 'Based on the sun\'s position at birth, 12 signs are determined. Each reflects different aspects of your personality — strengths, challenges, and emotional tendencies.',
                        icon: Icons.wb_sunny_outlined,
                      ),
                      GuidanceItem(
                        titleTr: 'Çin Astrolojisi',
                        titleEn: 'Chinese Astrology',
                        descTr: '12 yıllık döngülerle çalışan bu sistem, doğum yılınıza göre bir hayvan burcu atar. Her hayvan, karakterinizi, uyumlu ilişkilerinizi ve yaşam enerjinizi temsil eder.',
                        descEn: 'Working in 12-year cycles, this system assigns an animal sign based on your birth year. Each animal represents your character, compatible relationships, and life energy.',
                        icon: Icons.pets_outlined,
                      ),
                      GuidanceItem(
                        titleTr: 'Maya Takvimi',
                        titleEn: 'Maya Calendar',
                        descTr: '20 Nahual (gün işareti) ve 13 galaktik tondan oluşan Tzolkin takvimi, doğum gününüze göre kozmik misyonunuzu ortaya koyar. En kadim astroloji sistemlerinden biridir.',
                        descEn: 'The Tzolkin calendar, composed of 20 Nahuales (day signs) and 13 galactic tones, reveals your cosmic mission based on your birth day. One of the most ancient astrology systems.',
                        icon: Icons.calendar_today_outlined,
                      ),
                      GuidanceItem(
                        titleTr: 'Element Sistemi',
                        titleEn: 'Element System',
                        descTr: 'Her üç gelenek de elementleri kullanır: Ateş, Su, Toprak, Hava. Elementiniz, enerjinizin doğasını ve ruhani yöneliminizi belirler.',
                        descEn: 'All three traditions use elements: Fire, Water, Earth, Air. Your element determines the nature of your energy and spiritual orientation.',
                        icon: Icons.local_fire_department_outlined,
                      ),
                      GuidanceItem(
                        titleTr: 'Bilimsel Not',
                        titleEn: 'Scientific Note',
                        descTr: 'Astroloji bilimsel olarak kanıtlanmış bir yöntem değildir, ancak binlerce yıldır insanların kendini tanıma yolculuğuna eşlik eden güçlü bir sembolik dildir.',
                        descEn: 'Astrology is not a scientifically proven method, but it is a powerful symbolic language that has accompanied humanity\'s self-discovery journey for thousands of years.',
                        icon: Icons.science_outlined,
                      ),
                    ],
                  ),
                ],
              ),
            )),
            
            // ── ÜÇ ÇARK (Tek ekrana sığması için kompakt tasarlandı) ──
            _animWrap(_t1, _wheelSection(
              wheelSize: wheelSize, label: 'BATI ZODYAK', 
              painter: (p) => _WesternWheelPainter(rotation: p, gold: _gold, goldD: _goldD),
              onTap: () => Navigator.push(context, SwipeFadePageRoute(page: const ZodiacPage())),
            )),
            const SizedBox(height: 36),
            _animWrap(_t2, _wheelSection(
              wheelSize: wheelSize, label: 'ASYA ASTROLOJİSİ', 
              painter: (p) => _ChineseWheelPainter(rotation: p, gold: _gold, goldD: _goldD),
              onTap: () => Navigator.push(context, SwipeFadePageRoute(page: const ZodiacChinesePage())),
            )),
            const SizedBox(height: 36),
            _animWrap(_t3, _wheelSection(
              wheelSize: wheelSize, label: 'MAYA TAKVİMİ', 
              painter: (p) => _MayanWheelPainter(rotation: p, gold: _gold, goldD: _goldD),
              onTap: () => Navigator.push(context, SwipeFadePageRoute(page: const ZodiacMayanPage())),
            )),
          ]),
        )),
      ]),
    );
  }

  Widget _animWrap(Animation<double> a, Widget child) => FadeTransition(
    opacity: a, child: SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, .12), end: Offset.zero).animate(a), child: child));

  Widget _wheelSection({required double wheelSize, required String label,
    required CustomPainter Function(double progress) painter, required VoidCallback onTap}) {
    return Column(children: [
        // Çark Etiketi
        Text(label, style: TextStyle(color: _gold.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 3)),
        const SizedBox(height: 6),
        // Çarkın Kendisi - Artık buton (ripple efektli)
        Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            splashColor: _goldL.withOpacity(0.15),
            highlightColor: _goldD.withOpacity(0.1),
            child: SizedBox(width: wheelSize, height: wheelSize, child: AnimatedBuilder(
              animation: _spin,
              builder: (c, _) => CustomPaint(size: Size(wheelSize, wheelSize), painter: painter(_spin.value)),
            )),
          ),
        ),
    ]);
  }

  Widget _badge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(color: _goldD.withOpacity(0.15), borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _gold.withOpacity(0.2))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      const Text('✨', style: TextStyle(fontSize: 12)), const SizedBox(width: 5),
      Text('3 Kadim Gelenek', style: TextStyle(color: _goldL.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.w600)),
    ]),
  );
}

// BATI ZODIAC ÇARKI — Referans görselden ilham
class _WesternWheelPainter extends CustomPainter {
  final double rotation;
  final Color gold, goldD;
  _WesternWheelPainter({required this.rotation, required this.gold, required this.goldD});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final p = Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;

    // Dış çift halka
    p..color = gold.withOpacity(0.3)..strokeWidth = 1.8;
    canvas.drawCircle(c, r - 2, p);
    p..color = gold.withOpacity(0.15)..strokeWidth = 1.0;
    canvas.drawCircle(c, r - 8, p);
    p..color = gold.withOpacity(0.22)..strokeWidth = 1.2;
    canvas.drawCircle(c, r * 0.36, p);

    // 12 segment bölmesi
    for (int i = 0; i < 12; i++) {
      final a = (i * 30 - 90 + rotation * 4) * math.pi / 180;
      p..color = gold.withOpacity(0.1)..strokeWidth = 0.6;
      canvas.drawLine(c + Offset(math.cos(a) * r * 0.36, math.sin(a) * r * 0.36),
        c + Offset(math.cos(a) * (r - 8), math.sin(a) * (r - 8)), p);
    }

    // 12 burç sembolü — daha büyük alan
    final sp = Paint()..color = gold.withOpacity(0.9)..style = PaintingStyle.stroke
      ..strokeWidth = 2.4..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
    for (int i = 0; i < 12; i++) {
      final a = (i * 30 - 75 + rotation * 4) * math.pi / 180;
      _drawSym(canvas, i, c + Offset(math.cos(a) * r * 0.68, math.sin(a) * r * 0.68), r * 0.15, sp);
    }

    // ── MERKEZ GÜNEŞ — ışınlar segmentlere yayılıyor ──
    final discR = r * 0.1;

    // Sıcak parıltı (geniş)
    canvas.drawCircle(c, r * 0.5, Paint()..shader = RadialGradient(
      colors: [gold.withOpacity(0.08), gold.withOpacity(0.02), Colors.transparent],
      stops: const [0.1, 0.5, 1.0],
    ).createShader(Rect.fromCircle(center: c, radius: r * 0.5)));

    // 36 uzun ışın — segmentlere kadar uzanıyor
    for (int i = 0; i < 36; i++) {
      final a = (i * 10 + rotation * 6) * math.pi / 180;
      final type = i % 3;
      // Uzun ışınlar sembol halkasına yaklaşıyor
      final outerEnd = type == 0 ? r * 0.52 : (type == 2 ? r * 0.42 : r * 0.34);
      final innerStart = discR * 1.3;
      // Opaklık dışa doğru azalıyor
      final baseOpacity = type == 0 ? 0.25 : (type == 2 ? 0.15 : 0.08);
      final width = type == 0 ? 1.3 : (type == 2 ? 0.8 : 0.4);
      p..color = gold.withOpacity(baseOpacity)..strokeWidth = width;
      canvas.drawLine(
        c + Offset(math.cos(a) * innerStart, math.sin(a) * innerStart),
        c + Offset(math.cos(a) * outerEnd, math.sin(a) * outerEnd), p);
    }

    // İkinci katman — 12 ana ışın (daha kalın, daha uzun)
    for (int i = 0; i < 12; i++) {
      final a = (i * 30 + 15 + rotation * 6) * math.pi / 180;
      p..color = gold.withOpacity(0.12)..strokeWidth = 2.0;
      canvas.drawLine(
        c + Offset(math.cos(a) * discR * 1.5, math.sin(a) * discR * 1.5),
        c + Offset(math.cos(a) * r * 0.48, math.sin(a) * r * 0.48), p);
      // Paralel ince ışınlar (kenar çizgileri)
      for (final offset in [-0.03, 0.03]) {
        final aOff = a + offset;
        p..color = gold.withOpacity(0.06)..strokeWidth = 0.5;
        canvas.drawLine(
          c + Offset(math.cos(aOff) * discR * 2, math.sin(aOff) * discR * 2),
          c + Offset(math.cos(aOff) * r * 0.44, math.sin(aOff) * r * 0.44), p);
      }
    }

    // Güneş diski — çift halka
    p..color = gold.withOpacity(0.4)..strokeWidth = 2.0;
    canvas.drawCircle(c, discR, p);
    p..color = gold.withOpacity(0.2)..strokeWidth = 0.8;
    canvas.drawCircle(c, discR * 1.6, p);

    // Disk iç parıltı
    canvas.drawCircle(c, discR * 1.2, Paint()..shader = RadialGradient(
      colors: [gold.withOpacity(0.18), gold.withOpacity(0.05), Colors.transparent],
    ).createShader(Rect.fromCircle(center: c, radius: discR * 1.2)));

    // Parlak çekirdek
    canvas.drawCircle(c, 3, Paint()..color = gold.withOpacity(0.75)..style = PaintingStyle.fill);
    canvas.drawCircle(c, 1.2, Paint()..color = gold.withOpacity(0.95)..style = PaintingStyle.fill);

    // Dış noktalar
    for (int i = 0; i < 36; i++) {
      final a = (i * 10) * math.pi / 180;
      canvas.drawCircle(c + Offset(math.cos(a) * (r - 5), math.sin(a) * (r - 5)),
        i % 3 == 0 ? 1.5 : 0.7, Paint()..color = gold.withOpacity(i % 3 == 0 ? 0.25 : 0.08)..style = PaintingStyle.fill);
    }

    // Dönen ışık
    final ga = rotation * 2 * math.pi;
    final gp = c + Offset(math.cos(ga) * r * 0.91, math.sin(ga) * r * 0.91);
    canvas.drawCircle(gp, 10, Paint()..shader = RadialGradient(
      colors: [gold.withOpacity(0.5), gold.withOpacity(0)]).createShader(Rect.fromCircle(center: gp, radius: 10)));
  }

  void _drawSym(Canvas canvas, int i, Offset o, double s, Paint p) {
    final path = Path();
    switch (i) {
      case 0: // ♈ Koç — V boynuz + alt çizgi
        path..moveTo(o.dx - s * .35, o.dy - s * .55);
        path.cubicTo(o.dx - s * .55, o.dy - s * .15, o.dx - s * .15, o.dy + s * .1, o.dx, o.dy + s * .35);
        path.cubicTo(o.dx + s * .15, o.dy + s * .1, o.dx + s * .55, o.dy - s * .15, o.dx + s * .35, o.dy - s * .55);
        path..moveTo(o.dx, o.dy + s * .35); path.lineTo(o.dx, o.dy + s * .65);
      case 1: // ♉ Boğa — daire + hilal boynuz
        canvas.drawCircle(Offset(o.dx, o.dy + s * .2), s * .28, p);
        path..moveTo(o.dx - s * .45, o.dy);
        path.cubicTo(o.dx - s * .55, o.dy - s * .55, o.dx - s * .1, o.dy - s * .7, o.dx, o.dy - s * .4);
        path.cubicTo(o.dx + s * .1, o.dy - s * .7, o.dx + s * .55, o.dy - s * .55, o.dx + s * .45, o.dy);
      case 2: // ♊ İkizler — iki sütun + yay bağlantılar
        path..moveTo(o.dx - s * .3, o.dy - s * .55); path.lineTo(o.dx - s * .3, o.dy + s * .55);
        path..moveTo(o.dx + s * .3, o.dy - s * .55); path.lineTo(o.dx + s * .3, o.dy + s * .55);
        path..moveTo(o.dx - s * .45, o.dy - s * .4);
        path.quadraticBezierTo(o.dx, o.dy - s * .75, o.dx + s * .45, o.dy - s * .4);
        path..moveTo(o.dx - s * .45, o.dy + s * .4);
        path.quadraticBezierTo(o.dx, o.dy + s * .75, o.dx + s * .45, o.dy + s * .4);
      case 3: // ♋ Yengeç — 69 şekli
        path..moveTo(o.dx + s * .15, o.dy - s * .15);
        path.cubicTo(o.dx - s * .2, o.dy - s * .15, o.dx - s * .5, o.dy - s * .55, o.dx - s * .1, o.dy - s * .5);
        path..moveTo(o.dx + s * .15, o.dy - s * .15);
        path.cubicTo(o.dx + s * .5, o.dy - s * .15, o.dx + s * .5, o.dy + s * .15, o.dx + s * .15, o.dy + s * .15);
        path..moveTo(o.dx - s * .15, o.dy + s * .15);
        path.cubicTo(o.dx + s * .2, o.dy + s * .15, o.dx + s * .5, o.dy + s * .55, o.dx + s * .1, o.dy + s * .5);
        path..moveTo(o.dx - s * .15, o.dy + s * .15);
        path.cubicTo(o.dx - s * .5, o.dy + s * .15, o.dx - s * .5, o.dy - s * .15, o.dx - s * .15, o.dy - s * .15);
      case 4: // ♌ Aslan — daire + S kuyruk
        canvas.drawCircle(Offset(o.dx + s * .2, o.dy + s * .25), s * .2, p);
        path..moveTo(o.dx, o.dy + s * .25);
        path.cubicTo(o.dx - s * .4, o.dy + s * .25, o.dx - s * .5, o.dy - s * .1, o.dx - s * .2, o.dy - s * .35);
        path.cubicTo(o.dx, o.dy - s * .6, o.dx + s * .4, o.dy - s * .5, o.dx + s * .35, o.dy - s * .15);
      case 5: // ♍ Başak — m dalga + çapraz kuyruk
        path..moveTo(o.dx - s * .45, o.dy + s * .4); path.lineTo(o.dx - s * .45, o.dy);
        path.cubicTo(o.dx - s * .45, o.dy - s * .45, o.dx - s * .15, o.dy - s * .45, o.dx - s * .15, o.dy);
        path.cubicTo(o.dx - s * .15, o.dy - s * .45, o.dx + s * .15, o.dy - s * .45, o.dx + s * .15, o.dy);
        path.cubicTo(o.dx + s * .15, o.dy - s * .45, o.dx + s * .45, o.dy - s * .45, o.dx + s * .45, o.dy);
        path.lineTo(o.dx + s * .45, o.dy + s * .2);
        path..moveTo(o.dx + s * .2, o.dy + s * .15); path.lineTo(o.dx + s * .55, o.dy + s * .5);
        path..moveTo(o.dx + s * .3, o.dy + s * .38); path.lineTo(o.dx + s * .55, o.dy + s * .25);
      case 6: // ♎ Terazi — kubbe + iki çizgi
        path..moveTo(o.dx - s * .5, o.dy + s * .35); path.lineTo(o.dx + s * .5, o.dy + s * .35);
        path..moveTo(o.dx - s * .5, o.dy + s * .1); path.lineTo(o.dx + s * .5, o.dy + s * .1);
        path..moveTo(o.dx - s * .35, o.dy + s * .1);
        path.cubicTo(o.dx - s * .35, o.dy - s * .55, o.dx + s * .35, o.dy - s * .55, o.dx + s * .35, o.dy + s * .1);
      case 7: // ♏ Akrep — m dalga + ok kuyruk
        path..moveTo(o.dx - s * .5, o.dy + s * .35); path.lineTo(o.dx - s * .5, o.dy - s * .05);
        path.cubicTo(o.dx - s * .5, o.dy - s * .45, o.dx - s * .2, o.dy - s * .45, o.dx - s * .2, o.dy - s * .05);
        path.cubicTo(o.dx - s * .2, o.dy - s * .45, o.dx + s * .1, o.dy - s * .45, o.dx + s * .1, o.dy - s * .05);
        path.lineTo(o.dx + s * .1, o.dy + s * .25); path.lineTo(o.dx + s * .4, o.dy + s * .45);
        path..moveTo(o.dx + s * .4, o.dy + s * .45); path.lineTo(o.dx + s * .5, o.dy + s * .25);
        path..moveTo(o.dx + s * .4, o.dy + s * .45); path.lineTo(o.dx + s * .2, o.dy + s * .4);
      case 8: // ♐ Yay — çapraz ok
        path..moveTo(o.dx - s * .45, o.dy + s * .55); path.lineTo(o.dx + s * .45, o.dy - s * .45);
        path.lineTo(o.dx + s * .15, o.dy - s * .45);
        path..moveTo(o.dx + s * .45, o.dy - s * .45); path.lineTo(o.dx + s * .45, o.dy - s * .15);
        path..moveTo(o.dx - s * .15, o.dy + s * .05); path.lineTo(o.dx + s * .2, o.dy + s * .3);
      case 9: // ♑ Oğlak — üst kıvrım + kuyruk döngüsü
        path..moveTo(o.dx - s * .3, o.dy - s * .5);
        path.cubicTo(o.dx - s * .45, o.dy - s * .65, o.dx - s * .05, o.dy - s * .7, o.dx, o.dy - s * .4);
        path.lineTo(o.dx + s * .1, o.dy + s * .1);
        path.cubicTo(o.dx + s * .45, o.dy + s * .6, o.dx + s * .05, o.dy + s * .7, o.dx - s * .15, o.dy + s * .45);
        path.cubicTo(o.dx - s * .35, o.dy + s * .2, o.dx + s * .05, o.dy + s * .1, o.dx + s * .1, o.dy + s * .35);
      case 10: // ♒ Kova — iki S dalga
        for (int j = 0; j < 2; j++) {
          final y = o.dy + (j == 0 ? -s * .15 : s * .2);
          path..moveTo(o.dx - s * .5, y);
          path.cubicTo(o.dx - s * .35, y - s * .25, o.dx - s * .15, y + s * .25, o.dx, y);
          path.cubicTo(o.dx + s * .15, y - s * .25, o.dx + s * .35, y + s * .25, o.dx + s * .5, y);
        }
      case 11: // ♓ Balık — iki karşılıklı yay + çizgi
        path..moveTo(o.dx - s * .45, o.dy); path.lineTo(o.dx + s * .45, o.dy);
        path..moveTo(o.dx - s * .15, o.dy - s * .5);
        path.cubicTo(o.dx - s * .55, o.dy - s * .2, o.dx - s * .55, o.dy + s * .2, o.dx - s * .15, o.dy + s * .5);
        path..moveTo(o.dx + s * .15, o.dy - s * .5);
        path.cubicTo(o.dx + s * .55, o.dy - s * .2, o.dx + s * .55, o.dy + s * .2, o.dx + s * .15, o.dy + s * .5);
    }
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _WesternWheelPainter old) => old.rotation != rotation;
}

// ÇİN ZODIAC ÇARKI — Net Altın Silüetler (Görseldeki gibi net ve tanınabilir)
class _ChineseWheelPainter extends CustomPainter {
  final double rotation;
  final Color gold, goldD;
  _ChineseWheelPainter({required this.rotation, required this.gold, required this.goldD});

  static const List<String> _names = ['FARE', 'ÖKÜZ', 'KAPLAN', 'TAVŞAN', 'EJDERHA', 'YILAN', 'AT', 'KEÇİ', 'MAYMUN', 'HOROZ', 'KÖPEK', 'DOMUZ'];

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    
    final ringR = r * 0.76;
    final animalR = r * 0.18; // Boyutlar dengelendi ve dışa alındı

    // Merkezdeki Zarif Parlama
    canvas.drawCircle(c, r * 0.35, Paint()..shader = RadialGradient(
      colors: [gold.withOpacity(0.08), Colors.transparent],
    ).createShader(Rect.fromCircle(center: c, radius: r * 0.35)));

    // MERKEZ - Büyük Asya Mühür Çerçevesi (Dış çerçevelerle tam uyumlu)
    canvas.save();
    canvas.translate(c.dx, c.dy);
    
    final frameColor = const Color(0xFFC62828);
    final cR = r * 0.32; // Büyük merkez çerçevenin boyutu

    // Kalın kızıl dış çerçeve (Köşeleri yuvarlatılmış)
    final cRr = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: cR * 2, height: cR * 2),
      const Radius.circular(16)
    );
    canvas.drawRRect(cRr, Paint()..color = frameColor.withOpacity(0.08)..style = PaintingStyle.fill);
    canvas.drawRRect(cRr, Paint()..color = frameColor.withOpacity(0.6)..style = PaintingStyle.stroke..strokeWidth = 2.5);
    
    // İnce altın iç çerçeve
    final cInnerRr = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: cR * 1.70, height: cR * 1.70),
      const Radius.circular(10)
    );
    canvas.drawRRect(cInnerRr, Paint()..color = gold.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 1.2);

    // Geleneksel Çin köşelikleri (Lattice Window Corners)
    final q = cR * 0.85;
    final wl = cR * 0.25; 
    final cbPaint = Paint()..color = gold.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 2.0;
    
    // Sol Üst
    canvas.drawPath(Path()..moveTo(-q, -q+wl)..lineTo(-q, -q)..lineTo(-q+wl, -q), cbPaint);
    // Sağ Üst
    canvas.drawPath(Path()..moveTo(q-wl, -q)..lineTo(q, -q)..lineTo(q, -q+wl), cbPaint);
    // Sağ Alt
    canvas.drawPath(Path()..moveTo(q, q-wl)..lineTo(q, q)..lineTo(q-wl, q), cbPaint);
    // Sol Alt
    canvas.drawPath(Path()..moveTo(-q+wl, q)..lineTo(-q, q)..lineTo(-q, q-wl), cbPaint);

    // Merkez: Yin-Yang ile Ejderha-Anka Kuşu Motifi (Asya tarzı, Batıdan tamamen farklı)
    _drawCenterYinYangDragon(canvas, cR * 0.72, gold);

    canvas.restore();

    // Dışarıdaki o kötü duran çember/halka çizgileri tamamen silindi.
    // p..color = gold.withOpacity(0.12)..strokeWidth = 1.0;
    // canvas.drawCircle(c, ringR, p);

    // 12 Hayvan ve Etraflarında Hafif Renkli Çerçeve
    for (int i = 0; i < 12; i++) {
      final a = (i * 30 - 90 + rotation * 360) * math.pi / 180;
      final pos = c + Offset(math.cos(a) * ringR, math.sin(a) * ringR);
      
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      // Çark dönerken hayvanlar dik dursun (Ferris wheel effect)
      
      // Çok zarif ve hafif kızıl-altın karışımı Asya Mühür Çerçevesi (Rounded Rect)
      final frameColor = const Color(0xFFC62828); // Hafif crimson/kırmızı
      final rectRadius = animalR * 1.02; // Karelerin birbirine girmemesi için boyut küçültüldü
      final rr = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: rectRadius * 2, height: rectRadius * 2),
        const Radius.circular(8)
      );
      
      // Çerçevenin transparan hafif dolgusu
      canvas.drawRRect(rr, Paint()..color = frameColor.withOpacity(0.06)..style = PaintingStyle.fill);
      // Çerçevenin ince çizgileleri (ikili çerçeve çok daha şık duruyor)
      canvas.drawRRect(rr, Paint()..color = frameColor.withOpacity(0.4)..style = PaintingStyle.stroke..strokeWidth = 1.5);
      
      final innerRr = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: rectRadius * 1.7, height: rectRadius * 1.7),
        const Radius.circular(5)
      );
      canvas.drawRRect(innerRr, Paint()..color = gold.withOpacity(0.2)..style = PaintingStyle.stroke..strokeWidth = 0.8);

      // Hayvanı çiz (Artık hiçbir metin yok, tamamen saf tasarımlar)
      _drawIcon(canvas, i, animalR * 0.85); // Çerçeveye tam oturması için ikonu hafif orantıladık

      canvas.restore();
    }
  }

  void _drawCenterYinYangDragon(Canvas canvas, double r, Color gold) {
    // Yin-Yang tarzı çift kıvrımlı ejderha-anka kuşu motifi
    final pStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final pFill = Paint()..style = PaintingStyle.fill;

    // Ana Yin-Yang dairesi (ince altın çizgi)
    pStroke..color = gold.withOpacity(0.5)..strokeWidth = 1.5;
    canvas.drawCircle(Offset.zero, r, pStroke);

    // Yin-Yang S-eğrisi (ortayı ikiye bölen akışkan kıvrım)
    final sCurve = Path()
      ..moveTo(0, -r)
      ..cubicTo(r * 0.8, -r * 0.6, r * 0.8, 0, 0, 0)
      ..cubicTo(-r * 0.8, 0, -r * 0.8, r * 0.6, 0, r);
    pStroke..color = gold.withOpacity(0.6)..strokeWidth = 1.8;
    canvas.drawPath(sCurve, pStroke);

    // Yin tarafı (sol üst yarım) - hafif dolgu
    final yinPath = Path()
      ..moveTo(0, -r)
      ..arcTo(Rect.fromCircle(center: Offset.zero, radius: r), -math.pi / 2, -math.pi, false)
      ..cubicTo(-r * 0.8, r * 0.6, -r * 0.8, 0, 0, 0)
      ..cubicTo(r * 0.8, -r * 0.6, r * 0.8, 0, 0, -r + 0.01);
    // Gerçek Yin-Yang: sol yarısı koyu dolguyla
    pFill..color = gold.withOpacity(0.08);
    // Sağ yarıyı dolduralım (Yang = parlak)
    final yangPath = Path()
      ..moveTo(0, -r)
      ..arcTo(Rect.fromCircle(center: Offset.zero, radius: r), -math.pi / 2, math.pi, false)
      ..cubicTo(-r * 0.8, r * 0.6, -r * 0.8, 0, 0, 0)
      ..cubicTo(r * 0.8, -r * 0.6, r * 0.8, 0, 0, -r + 0.01);
    // Yang tarafını hafif altın dolgu
    canvas.drawPath(yangPath, Paint()..color = gold.withOpacity(0.12)..style = PaintingStyle.fill);

    // Yin-Yang göz noktaları (büyük dairesel noktalar)
    // Üst göz (Yang gözü - karanlık tarafta parlak nokta)
    canvas.drawCircle(Offset(0, -r * 0.42), r * 0.14, Paint()..color = gold.withOpacity(0.6)..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(0, -r * 0.42), r * 0.14, pStroke..color = gold.withOpacity(0.4)..strokeWidth = 1.0);
    // Alt göz (Yin gözü - aydınlık tarafta koyu nokta)
    canvas.drawCircle(Offset(0, r * 0.42), r * 0.14, Paint()..color = gold.withOpacity(0.15)..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(0, r * 0.42), r * 0.14, pStroke..color = gold.withOpacity(0.5)..strokeWidth = 1.0);

    // ── Ejderha kıvrımı (sağ üst - Yang tarafı) ──
    // Ejderha başı (küçük detaylar)
    final dragonP = Paint()
      ..color = gold.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    
    // Ejderha boynuzu / bıyıklar
    canvas.drawLine(Offset(r * 0.25, -r * 0.75), Offset(r * 0.45, -r * 0.9), dragonP);
    canvas.drawLine(Offset(r * 0.15, -r * 0.72), Offset(r * 0.08, -r * 0.92), dragonP);
    // Küçük ejderha göz
    canvas.drawCircle(Offset(r * 0.18, -r * 0.65), r * 0.04, Paint()..color = gold.withOpacity(0.8)..style = PaintingStyle.fill);
    
    // Ejderha yüzgeç/bıyık kıvrımı  
    final whisker = Path()
      ..moveTo(r * 0.35, -r * 0.6)
      ..quadraticBezierTo(r * 0.55, -r * 0.5, r * 0.5, -r * 0.35);
    canvas.drawPath(whisker, dragonP..strokeWidth = 1.2);
    
    // ── Anka kuşu kıvrımı (sol alt - Yin tarafı) ──  
    // Anka kuşu kuyruk tüyleri
    final phoenixP = Paint()
      ..color = gold.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    // Kıvrımlı kuyruk tüyleri
    final feather1 = Path()
      ..moveTo(-r * 0.25, r * 0.6)
      ..quadraticBezierTo(-r * 0.55, r * 0.85, -r * 0.3, r * 0.9);
    canvas.drawPath(feather1, phoenixP);
    
    final feather2 = Path()
      ..moveTo(-r * 0.2, r * 0.55)
      ..quadraticBezierTo(-r * 0.6, r * 0.65, -r * 0.45, r * 0.85);
    canvas.drawPath(feather2, phoenixP..strokeWidth = 1.0);
    
    final feather3 = Path()
      ..moveTo(-r * 0.15, r * 0.65)
      ..quadraticBezierTo(-r * 0.4, r * 0.95, -r * 0.15, r * 0.92);
    canvas.drawPath(feather3, phoenixP..strokeWidth = 1.2);

    // Dış dekoratif noktalar (8 nokta, pusula gibi)
    for (int i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      final dotR = i % 2 == 0 ? r * 0.04 : r * 0.025;
      final dotPos = Offset(math.cos(a) * r * 0.88, math.sin(a) * r * 0.88);
      canvas.drawCircle(dotPos, dotR, Paint()..color = gold.withOpacity(i % 2 == 0 ? 0.5 : 0.3)..style = PaintingStyle.fill);
    }

    // İç ince halka (merkezi çevreleyen zarif çizgi)
    pStroke..color = gold.withOpacity(0.25)..strokeWidth = 0.6;
    canvas.drawCircle(Offset.zero, r * 0.28, pStroke);
  }

  void _drawIcon(Canvas canvas, int idx, double s) {
    // Görseldeki gibi şahane 3D hissi veren altın/bronz gradyanı
    final Rect bounds = Rect.fromCircle(center: Offset.zero, radius: s * 0.8);
    final Paint f = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFF6D9), Color(0xFFFFD060), Color(0xFFD48A18)],
        stops: [0.0, 0.4, 1.0],
      ).createShader(bounds)
      ..style = PaintingStyle.fill;
    
    // Primitive Çizim Araçları (Çok daha net ve tanınan geometrik şekiller için)
    void circle(double x, double y, double r) => canvas.drawCircle(Offset(s * x, s * y), s * r, f);
    void oval(double x, double y, double w, double h, [double angle = 0]) {
      canvas.save();
      canvas.translate(s * x, s * y);
      canvas.rotate(angle);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: s * w, height: s * h), f);
      canvas.restore();
    }
    void capsule(double x1, double y1, double x2, double y2, double w) {
      final p = Path()..moveTo(s * x1, s * y1)..lineTo(s * x2, s * y2);
      canvas.drawPath(p, Paint()..shader = f.shader..style = PaintingStyle.stroke..strokeWidth = s * w..strokeCap = StrokeCap.round);
    }
    void poly(List<double> pts) {
      final p = Path()..moveTo(s * pts[0], s * pts[1]);
      for (int j = 2; j < pts.length; j += 2) p.lineTo(s * pts[j], s * pts[j + 1]);
      p.close();
      canvas.drawPath(p, f);
    }

    switch (idx) {
      case 0: // Fare (Rat)
        oval(-0.1, 0.15, 0.55, 0.45, -0.2); // Gövde
        oval(0.2, -0.1, 0.45, 0.25, 0.2); // Baş
        circle(0.1, -0.25, 0.18); // Büyük kulak
        poly([0.3, -0.1, 0.55, -0.15, 0.3, 0.05]); // Burun
        capsule(0.2, 0.15, 0.35, 0.2, 0.08); // Eller
        capsule(-0.15, 0.3, -0.2, 0.45, 0.06); // Ayak
        // Kıvrık kuyruk
        final tp = Path()..moveTo(-s * 0.3, s * 0.3)..cubicTo(-s * 0.7, s * 0.6, s * 0.5, s * 0.6, s * 0.5, s * 0.45);
        canvas.drawPath(tp, Paint()..shader = f.shader..style = PaintingStyle.stroke..strokeWidth = s * 0.06..strokeCap = StrokeCap.round);
        break;
      case 1: // Öküz (Ox)
        oval(-0.05, 0.0, 0.8, 0.45, 0); // Güçlü gövde
        oval(0.4, -0.15, 0.35, 0.2, 0.2); // Baş
        capsule(0.4, -0.2, 0.6, -0.4, 0.08); // İleri boynuz
        capsule(-0.35, 0.1, -0.35, 0.45, 0.12); // Arka bacak
        capsule(0.25, 0.1, 0.25, 0.45, 0.14); // Ön bacak
        capsule(-0.15, 0.1, -0.15, 0.45, 0.1); // Arka iç bacak
        capsule(0.05, 0.1, 0.05, 0.45, 0.1); // Ön iç bacak
        capsule(-0.4, -0.05, -0.45, 0.35, 0.06); // İnce kuyruk
        break;
      case 2: // Kaplan (Tiger)
        oval(0.0, 0.0, 0.85, 0.35, 0); // Zayıf ve uzun gövde
        circle(0.4, -0.15, 0.2); // Baş
        circle(0.4, -0.32, 0.08); // Kulak
        poly([0.4, -0.05, 0.6, -0.1, 0.5, 0.05]); // Çene
        capsule(-0.35, 0.1, -0.3, 0.45, 0.12);
        capsule(-0.15, 0.1, -0.1, 0.45, 0.12);
        capsule(0.2, 0.1, 0.2, 0.45, 0.12);
        capsule(0.35, 0.1, 0.4, 0.45, 0.12);
        // İnik ve kıvrık kuyruk
        final tp = Path()..moveTo(-s * 0.4, -s * 0.05)..quadraticBezierTo(-s * 0.6, s * 0.3, -s * 0.45, s * 0.45);
        canvas.drawPath(tp, Paint()..shader = f.shader..style = PaintingStyle.stroke..strokeWidth = s * 0.1..strokeCap = StrokeCap.round);
        break;
      case 3: // Tavşan (Rabbit)
        oval(-0.15, 0.2, 0.6, 0.4, 0); // Yuvarlak gövde
        circle(0.25, -0.05, 0.18); // Baş
        oval(-0.05, -0.35, 0.5, 0.12, -0.6); // Dik ve geriye kulak 1
        oval(0.05, -0.4, 0.5, 0.12, -0.4); // Dik ve geriye kulak 2
        circle(-0.45, 0.25, 0.12); // Ponpon kuyruk
        capsule(0.25, 0.2, 0.25, 0.45, 0.08); // Ön ayak
        capsule(-0.2, 0.2, -0.25, 0.45, 0.1); // Arka ayak
        break;
      case 4: // Ejderha (Dragon)
        // Belirgin kıvrımlı S Gövde
        final dp = Path()..moveTo(-s * 0.35, s * 0.2)..cubicTo(-s * 0.8, -s * 0.5, s * 0.2, -s * 0.5, 0, s * 0.1)..cubicTo(-s * 0.1, s * 0.4, s * 0.4, s * 0.3, s * 0.3, -s * 0.15);
        canvas.drawPath(dp, Paint()..shader = f.shader..style = PaintingStyle.stroke..strokeWidth = s * 0.16..strokeCap = StrokeCap.round);
        oval(0.35, -0.25, 0.3, 0.15, 0.2); // Baş
        capsule(0.25, -0.3, 0.1, -0.45, 0.05); // Boynuz
        capsule(0.35, -0.3, 0.25, -0.45, 0.05); // Boynuz
        capsule(-0.15, -0.1, -0.25, 0.1, 0.06); // Pençe 1
        capsule(0.0, 0.2, 0.1, 0.35, 0.06); // Pençe 2
        capsule(0.15, 0.1, 0.25, 0.2, 0.06); // Pençe 3
        break;
      case 5: // Yılan (Snake)
        final sp = Path()..moveTo(-s * 0.3, s * 0.2)..cubicTo(-s * 0.8, s * 0.1, -s * 0.1, -s * 0.5, 0, -s * 0.1)..cubicTo(s * 0.1, s * 0.3, s * 0.5, 0.1, s * 0.3, -s * 0.25);
        canvas.drawPath(sp, Paint()..shader = f.shader..style = PaintingStyle.stroke..strokeWidth = s * 0.18..strokeCap = StrokeCap.round);
        oval(0.3, -0.25, 0.25, 0.15, 0.3); // Yassı baş
        capsule(0.4, -0.2, 0.5, -0.15, 0.04); // Dil
        break;
      case 6: // At (Horse)
        oval(0.0, 0.0, 0.6, 0.35, 0); // Gövde
        oval(0.3, -0.25, 0.2, 0.4, 0.5); // Dik boyun
        oval(0.4, -0.45, 0.35, 0.15, 0.3); // İleri baş
        capsule(-0.25, 0.1, -0.3, 0.5, 0.08); // Arka bacak
        capsule(-0.15, 0.1, -0.1, 0.5, 0.08); // Arka bacak
        capsule(0.2, 0.1, 0.25, 0.5, 0.08); // Ön bacak
        capsule(0.35, 0.1, 0.4, 0.45, 0.08); // Ön bacak
        oval(-0.4, 0.0, 0.35, 0.1, -0.4); // Görkemli kuyruk
        // Yele
        capsule(0.2, -0.35, 0.1, -0.25, 0.05);
        capsule(0.25, -0.25, 0.15, -0.15, 0.05);
        break;
      case 7: // Keçi (Goat)
        oval(0.05, 0.05, 0.6, 0.35, 0); // Gövde
        oval(0.4, -0.2, 0.2, 0.15, 0.3); // Baş
        capsule(0.3, -0.25, 0.1, -0.4, 0.06); // Geri kıvrık boynuz
        capsule(-0.2, 0.15, -0.2, 0.5, 0.08); // Bacaklar
        capsule(-0.05, 0.15, -0.05, 0.5, 0.08);
        capsule(0.25, 0.15, 0.25, 0.5, 0.08);
        capsule(0.4, 0.15, 0.4, 0.5, 0.08);
        poly([0.45, -0.1, 0.4, 0.0, 0.5, -0.05]); // Sakal
        capsule(-0.35, 0.05, -0.45, 0.1, 0.06); // Kısa kuyruk
        break;
      case 8: // Maymun (Monkey)
        oval(0.0, 0.1, 0.35, 0.45, -0.2); // Gövde (ayakta/kambur)
        circle(0.15, -0.2, 0.18); // Baş
        capsule(0.1, -0.05, 0.4, 0.25, 0.08); // Uzun kolları
        capsule(0.05, 0.25, -0.15, 0.5, 0.08); // Bacakları
        capsule(0.15, 0.25, 0.0, 0.5, 0.08); // Bacakları
        // Dev Karakteristik Kuyruk (S Şeklinde kıvrım)
        final mp = Path()..moveTo(-s * 0.1, s * 0.3)..cubicTo(-s * 0.8, s * 0.4, -s * 0.8, -s * 0.5, -s * 0.2, -s * 0.4);
        canvas.drawPath(mp, Paint()..shader = f.shader..style = PaintingStyle.stroke..strokeWidth = s * 0.1..strokeCap = StrokeCap.round);
        break;
      case 9: // Horoz (Rooster)
        oval(0.0, 0.1, 0.4, 0.35, -0.2); // Göğüs
        circle(0.2, -0.15, 0.12); // Baş
        poly([0.3, -0.18, 0.45, -0.15, 0.3, -0.12]); // Gaga
        circle(0.2, -0.28, 0.06); // İbik
        circle(0.28, -0.25, 0.05); // İbik
        // Dev Yelpaze Kuyruk
        oval(-0.25, -0.15, 0.4, 0.15, -0.8);
        oval(-0.3, -0.05, 0.4, 0.15, -0.4);
        oval(-0.3, 0.1, 0.45, 0.15, 0.0);
        capsule(0.0, 0.3, -0.05, 0.55, 0.05); // Bacak
        capsule(0.1, 0.3, 0.15, 0.55, 0.05); // Bacak
        break;
      case 10: // Köpek (Dog)
        oval(0.0, 0.1, 0.6, 0.3, 0); // Gövde
        capsule(0.2, 0.1, 0.35, -0.05, 0.15); // Boyun
        circle(0.35, -0.1, 0.14); // Baş
        capsule(0.35, -0.1, 0.55, -0.05, 0.12); // Burun
        poly([0.28, -0.1, 0.25, -0.3, 0.38, -0.15]); // Dik kulak
        capsule(-0.3, 0.1, -0.4, -0.15, 0.1); // Dik kuyruk
        capsule(-0.2, 0.2, -0.2, 0.5, 0.08); // Arka bacak
        capsule(0.2, 0.2, 0.2, 0.5, 0.08); // Ön bacak
        break;
      case 11: // Domuz (Pig)
        oval(0.0, 0.1, 0.8, 0.45, 0); // Tombul gövde
        circle(0.4, 0.05, 0.22); // Baş
        oval(0.55, 0.1, 0.15, 0.2, 0); // Burun/Domuz Burn
        circle(0.38, -0.12, 0.09); // Kulak
        capsule(-0.3, 0.3, -0.3, 0.5, 0.1); // Bacak 1
        capsule(-0.1, 0.3, -0.1, 0.5, 0.1); // Bacak 2
        capsule(0.2, 0.3, 0.2, 0.5, 0.1); // Bacak 3
        capsule(0.4, 0.3, 0.4, 0.5, 0.1); // Bacak 4
        poly([-0.4, 0.0, -0.5, 0.0, -0.4, -0.1]); // Kıvrık minik kuyruk
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _ChineseWheelPainter old) => old.rotation != rotation;
}

class _MayanWheelPainter extends CustomPainter {
  final double rotation;
  final Color gold, goldD;
  _MayanWheelPainter({required this.rotation, required this.gold, required this.goldD});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    
    // Uygulamanın ana temasıyla tam uyumlu zarif altın (Parlaklık azaltıldı, sadelik arttı)
    final g = gold; 

    // Hafif zemin izi (Diğer çarklarla uyumlu şeffaflık)
    canvas.drawCircle(c, r, Paint()..shader = RadialGradient(
      colors: [g.withOpacity(0.05), Colors.transparent],
    ).createShader(Rect.fromCircle(center: c, radius: r)));

    // Daha ince ve narin çizgiler
    final pLine = Paint()..color = g.withOpacity(0.6)..style = PaintingStyle.stroke..strokeWidth = 1.0..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(rotation * math.pi * 0.5); // Ağır dönüş
    
    // 1. Dış Sınırlar (Daha sade titreşim)
    canvas.drawCircle(Offset.zero, r - 2, pLine..strokeWidth = 1.2);
    canvas.drawCircle(Offset.zero, r - 6, pLine..strokeWidth = 0.5);

    // 2. Dış 20 Nawal (Tzolkin Glifleri)
    final glyphR = r * 0.82;
    final glyphRadius = r * 0.12;
    for (int i = 0; i < 20; i++) {
        canvas.save();
        canvas.rotate(i * (math.pi * 2 / 20));
        canvas.translate(0, -glyphR);
        
        // Klasik Maya Hiyeroglif Çerçevesi (Sadeleştirildi)
        final crRect = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: glyphRadius * 1.8, height: glyphRadius * 1.6), const Radius.circular(8));
        canvas.drawRRect(crRect, Paint()..color = g.withOpacity(0.03)..style = PaintingStyle.fill);
        canvas.drawRRect(crRect, pLine..strokeWidth = 0.8);
        
        // İçine GERÇEK Maya Burç piktogramlarını (Nawal) çiziyoruz
        _drawAuthenticNawal(canvas, i, glyphRadius * 0.9, g.withOpacity(0.8));

        canvas.restore();
    }

    // 3. Bölücü Sınır 
    final innerBoundR = r * 0.68;
    canvas.drawCircle(Offset.zero, innerBoundR, pLine..strokeWidth = 2.0);
    canvas.drawCircle(Offset.zero, innerBoundR - 4, pLine..strokeWidth = 0.8);

    // 4. GALAKTİK TONLAR HALKASI (Tam 13 Adet - İç içe girme sorunu çözüldü)
    // Tzolkin'deki 13 sayı rakamı, bu sayede sistem 20x13 orantısına kavuşuyor
    final toneR = r * 0.55;
    for (int i = 0; i < 13; i++) {
        canvas.save();
        canvas.rotate(i * (math.pi * 2 / 13));
        
        // 13 Dilim ayırıcı çizgiler
        canvas.drawLine(Offset(0, -innerBoundR + 4), Offset(0, -toneR), Paint()..color=g.withOpacity(0.3)..style=PaintingStyle.stroke..strokeWidth=1.5);

        // 1 ile 13 arası sırayla sayılar (Daha narin ve ince çizgilerle)
        int num = i + 1;
        int bars = num ~/ 5;
        int dots = num % 5;
        
        double currentR = innerBoundR - 12;
        final pBar = Paint()..color = g.withOpacity(0.7)..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round;
        final pDot = Paint()..color = g.withOpacity(0.7)..style = PaintingStyle.fill;
        
        // Çubuklar
        for (int b = 0; b < bars; b++) {
            final sweep = math.pi * 2 / 13 * 0.45; 
            canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: currentR), -math.pi / 2 - sweep / 2, sweep, false, pBar);
            currentR -= 8; // İçeri doğru diz
        }
        
        if (bars > 0 && dots > 0) currentR -= 2;
        
        // Noktalar
        if (dots > 0) {
            final arcLen = math.pi * 2 / 13 * 0.35;
            final dotStep = dots > 1 ? arcLen / (dots - 1) : 0;
            final startA = -math.pi / 2 - (dots > 1 ? arcLen / 2 : 0);
            for (int d = 0; d < dots; d++) {
                final dAngle = startA + d * dotStep;
                canvas.drawCircle(Offset(math.cos(dAngle) * currentR, math.sin(dAngle) * currentR), 2.0, pDot);
            }
        }
        canvas.restore();
    }

    // 5. İç İnce Sınır (Tonların tabanı)
    canvas.drawCircle(Offset.zero, toneR, pLine..strokeWidth = 1.5);
    
    // 6. Orta Katman - Maya Güneş Dalgaları (Petals/Işınlar)
    final centerFaceR = r * 0.38;
    for (int i = 0; i < 20; i++) {
        canvas.save();
        canvas.rotate((i + 0.5) * (math.pi * 2 / 20));
        final rayP = Path()
           ..moveTo(0, -centerFaceR)
           ..lineTo(-r*0.06, -toneR)
           ..lineTo(r*0.06, -toneR)
           ..close();
        canvas.drawPath(rayP, Paint()..color = g.withOpacity(0.15)..style = PaintingStyle.fill);
        canvas.drawPath(rayP, Paint()..color = g.withOpacity(0.4)..style = PaintingStyle.stroke..strokeWidth=1.0);
        canvas.restore();
    }

    // 7. MERKEZ: Rustik Maya Güneş Tanrısı (Tonatiuh)
    // Yuvarlak ve taş oyması hissi (Tamamen uyumlu, temiz ve sadeleştirilmiş yapı)
    canvas.drawCircle(Offset.zero, centerFaceR, Paint()..color = g.withOpacity(0.04)..style = PaintingStyle.fill);
    canvas.drawCircle(Offset.zero, centerFaceR, pLine..strokeWidth = 1.2);
    canvas.drawCircle(Offset.zero, centerFaceR - 4, pLine..strokeWidth = 0.5);
    
    _drawRusticSunCenter(canvas, centerFaceR * 0.85, g.withOpacity(0.85));

    canvas.restore();
  }

  void _drawRusticSunCenter(Canvas c, double r, Color g) {
    final pLine = Paint()..color = g..style = PaintingStyle.stroke..strokeWidth = 2.0..strokeCap=StrokeCap.round;
    final pFill = Paint()..color = g..style = PaintingStyle.fill;
    
    // Kafa çerçevesi (Oval)
    c.drawOval(Rect.fromCenter(center: Offset(0, -r*0.1), width: r*1.5, height: r*1.2), pLine);
    
    // Klasik dışa sarkan dil
    c.drawRect(Rect.fromCenter(center: Offset(0, r*0.6), width: r*0.4, height: r*0.6), pLine);
    c.drawLine(Offset(0, r*0.4), Offset(0, r*0.8), pLine); // Dilin dikey yırtığı
    // Dilin etrafındaki çene takısı
    c.drawArc(Rect.fromCenter(center: Offset(0, r*0.1), width: r*1.6, height: r*1.5), 0.2, math.pi-0.4, false, pLine);

    // Dev, açık, yuvarlak Maya gözleri
    c.drawCircle(Offset(-r*0.35, -r*0.2), r*0.25, pLine);
    c.drawCircle(Offset(r*0.35, -r*0.2), r*0.25, pLine);
    c.drawCircle(Offset(-r*0.35, -r*0.2), r*0.08, pFill);
    c.drawCircle(Offset(r*0.35, -r*0.2), r*0.08, pFill);

    // Burun - V şeklinde yatay
    c.drawLine(Offset(-r*0.2, 0), Offset(0, r*0.25), pLine);
    c.drawLine(Offset(r*0.2, 0), Offset(0, r*0.25), pLine);

    // Alın Takısı (3 nokta ve çizgi)
    c.drawLine(Offset(-r*0.4, -r*0.5), Offset(r*0.4, -r*0.5), pLine);
    c.drawCircle(Offset(0, -r*0.65), r*0.06, pFill);
    c.drawCircle(Offset(-r*0.25, -r*0.65), r*0.06, pFill);
    c.drawCircle(Offset(r*0.25, -r*0.65), r*0.06, pFill);
    
    // Yandan sarkan dev küpeler
    c.drawRect(Rect.fromCenter(center: Offset(-r*0.9, 0), width: r*0.3, height: r*0.6), pLine);
    c.drawRect(Rect.fromCenter(center: Offset(r*0.9, 0), width: r*0.3, height: r*0.6), pLine);
    c.drawCircle(Offset(-r*0.9, 0), r*0.08, pFill);
    c.drawCircle(Offset(r*0.9, 0), r*0.08, pFill);
  }

  void _drawAuthenticNawal(Canvas c, int i, double h, Color g) {
     // GERÇEK 20 Nawal (Tzolkin Burçları) Soyutlamaları. Batıdan tamamen bağımsız, aslına uygun geometrik formlar.
     final p = Paint()..color = g..style = PaintingStyle.stroke..strokeWidth = 1.6..strokeCap = StrokeCap.round;
     final f = Paint()..color = g..style = PaintingStyle.fill;
     
     // Her sembol, resimdeki gerçek 20 Maya hiyeroglifine doğrudan atıf yapar.
     switch (i) {
         case 0: // B'atz (Maymun / Kıvrımlı sarmaşık)
             c.drawArc(Rect.fromCenter(center: Offset(0, -h*0.2), width: h*1.2, height: h*1.2), 0, math.pi*1.5, false, p..strokeWidth=2.5);
             c.drawLine(Offset(0, -h*0.8), Offset(0, 0), p);
             break;
         case 1: // E (Yol / Basamaklı Dişler)
             c.drawLine(Offset(-h*0.6, h*0.4), Offset(h*0.6, h*0.4), p); // Taban
             c.drawRect(Rect.fromLTRB(-h*0.4, -h*0.2, -h*0.1, h*0.4), p);
             c.drawRect(Rect.fromLTRB(h*0.1, -h*0.2, h*0.4, h*0.4), p);
             c.drawCircle(Offset(0, h*0.1), 2, f);
             break;
         case 2: // Aj (Tohum, Sazlık / 3 dikine sap)
             c.drawLine(Offset(-h*0.4, -h*0.6), Offset(-h*0.4, h*0.6), p);
             c.drawLine(Offset(0, -h*0.6), Offset(0, h*0.6), p);
             c.drawLine(Offset(h*0.4, -h*0.6), Offset(h*0.4, h*0.6), p);
             c.drawLine(Offset(-h*0.8, 0), Offset(h*0.8, 0), p);
             break;
         case 3: // I'x (Jaguar / Kalp ve 3 benek)
             c.drawCircle(Offset(-h*0.3, -h*0.3), h*0.15, p);
             c.drawCircle(Offset(h*0.3, -h*0.3), h*0.15, p);
             c.drawCircle(Offset(0, h*0.2), h*0.15, p);
             // Noktalar
             c.drawCircle(Offset(-h*0.3, -h*0.3), 2, f);
             c.drawCircle(Offset(h*0.3, -h*0.3), 2, f);
             c.drawCircle(Offset(0, h*0.2), 2, f);
             break;
         case 4: // Tz'ikin (Kuş / Kartal Gagası)
             c.drawArc(Rect.fromCenter(center: Offset.zero, width: h*1.2, height: h*1.2), math.pi, math.pi/2, false, p);
             c.drawLine(Offset(0, -h*0.6), Offset(0, h*0.2), p);
             c.drawLine(Offset(0, h*0.2), Offset(h*0.6, h*0.2), p); // Gaga
             c.drawCircle(Offset(-h*0.2, -h*0.2), 3, f); // Göz
             break;
         case 5: // Ajmaq (Baykuş / İki yay ve nokta)
             c.drawArc(Rect.fromCenter(center: Offset(-h*0.3, 0), width: h*0.6, height: h*0.8), math.pi/2, math.pi, false, p);
             c.drawArc(Rect.fromCenter(center: Offset(h*0.3, 0), width: h*0.6, height: h*0.8), -math.pi/2, math.pi, false, p);
             c.drawCircle(Offset(0, h*0.2), 3, f);
             break;
         case 6: // No'j (Dünya/Bilgelik / Loblu beyin kıvrımı)
             final pth1 = Path()..moveTo(-h*0.6, h*0.4)..quadraticBezierTo(0, -h*0.8, h*0.6, h*0.4);
             c.drawPath(pth1, p);
             final pth2 = Path()..moveTo(-h*0.3, h*0.4)..quadraticBezierTo(0, -h*0.2, h*0.3, h*0.4);
             c.drawPath(pth2, p);
             break;
         case 7: // Tijax (Obsidyen, Bıçak / Çapraz kesişim ve dişler)
             c.drawLine(Offset(-h*0.6, -h*0.6), Offset(h*0.6, h*0.6), p);
             c.drawLine(Offset(h*0.6, -h*0.6), Offset(-h*0.6, h*0.6), p); // Çarpı
             c.drawArc(Rect.fromCenter(center: Offset(0, -h*0.3), width: h*0.4, height: h*0.4), 0, math.pi, true, p); // Üst taş parçası
             break;
         case 8: // Kawoq (Fırtına / Bulut kümeleri)
             c.drawCircle(Offset(-h*0.3, -h*0.2), h*0.3, p);
             c.drawCircle(Offset(h*0.3, -h*0.2), h*0.3, p);
             c.drawCircle(Offset(0, h*0.3), h*0.3, p);
             c.drawCircle(Offset(0, h*0.3), 3, f);
             break;
         case 9: // Ajpu (Güneş / Üfleme Çubuğu nişancısı yüzü)
             c.drawOval(Rect.fromCenter(center: Offset.zero, width: h*1.2, height: h*1.2), p);
             c.drawCircle(Offset(-h*0.2, -h*0.1), h*0.15, p);
             c.drawCircle(Offset(h*0.2, -h*0.1), h*0.15, p);
             c.drawCircle(Offset(0, h*0.3), h*0.2, p); // Ağız / Üfleme deliği
             break;
         case 10: // Imox (Söğüt/Kök / Tırtıklı yarım ay)
             c.drawArc(Rect.fromCenter(center: Offset(0, 0), width: h*1.4, height: h*1.2), math.pi/2, math.pi, false, p..strokeWidth=2.0);
             c.drawLine(Offset(0, -h*0.6), Offset(h*0.4, -h*0.6), p);
             c.drawLine(Offset(0, 0), Offset(h*0.4, 0), p);
             c.drawLine(Offset(0, h*0.6), Offset(h*0.4, h*0.6), p);
             break;
         case 11: // Iq' (Rüzgar / T Şekli Pencere)
             c.drawLine(Offset(-h*0.5, -h*0.3), Offset(h*0.5, -h*0.3), p..strokeWidth=3.0); // Kalın üst
             c.drawLine(Offset(0, -h*0.3), Offset(0, h*0.5), p..strokeWidth=3.0);
             c.drawLine(Offset(-h*0.4, h*0.5), Offset(h*0.4, h*0.5), p..strokeWidth=3.0); // Alt taban
             break;
         case 12: // Aq'ab'al (Gece-Gündüz / Ortadan bölük ve noktalar)
             c.drawOval(Rect.fromCenter(center: Offset.zero, width: h*1.4, height: h*1.4), p);
             c.drawLine(Offset(0, -h*0.7), Offset(0, h*0.7), p..strokeWidth=2.5);
             c.drawCircle(Offset(-h*0.3, 0), h*0.12, f); // Koyu yan
             c.drawCircle(Offset(h*0.3, 0), h*0.12, p); // Açık yan
             break;
         case 13: // K'at (Ağ, Tohum Kümesi / Çapraz Hasır)
             c.drawRect(Rect.fromCenter(center: Offset.zero, width: h*1.2, height: h*1.2), p);
             c.drawLine(Offset(-h*0.6, -h*0.2), Offset(h*0.6, -h*0.2), p);
             c.drawLine(Offset(-h*0.6, h*0.2), Offset(h*0.6, h*0.2), p);
             c.drawLine(Offset(-h*0.2, -h*0.6), Offset(-h*0.2, h*0.6), p);
             c.drawLine(Offset(h*0.2, -h*0.6), Offset(h*0.2, h*0.6), p);
             break;
         case 14: // Kan (Yılan / Güç ve kıvrım)
             final snakeP = Path()..moveTo(-h*0.6, -h*0.4)..quadraticBezierTo(0, -h*0.8, h*0.4, -h*0.2)..quadraticBezierTo(h*0.8, 0, h*0.4, h*0.2)..quadraticBezierTo(0, h*0.4, -h*0.6, h*0.4);
             c.drawPath(snakeP, p..strokeWidth=2.4);
             c.drawCircle(Offset(h*0.5, 0), 2, f); // Göz
             break;
         case 15: // Keme (Ölüm / Kafatası, Kapalı Göz)
             c.drawOval(Rect.fromCenter(center: Offset(0, -h*0.1), width: h*1.2, height: h*1.0), p);
             c.drawLine(Offset(-h*0.5, h*0.4), Offset(h*0.5, h*0.4), p); // Diş çizgisi
             c.drawLine(Offset(0, h*0.3), Offset(0, h*0.5), p);
             c.drawLine(Offset(-h*0.3, -h*0.2), Offset(h*0.3, -h*0.2), p); // Kapalı göz
             break;
         case 16: // Kej (Geyik / El şeklinde organ, kıvrımlı tutuş)
             c.drawLine(Offset(-h*0.4, -h*0.5), Offset(-h*0.4, h*0.5), p);
             // 3 Parmak
             c.drawArc(Rect.fromCenter(center: Offset(0, -h*0.3), width: h*0.8, height: h*0.4), 0, math.pi, false, p);
             c.drawArc(Rect.fromCenter(center: Offset(0, 0), width: h*0.8, height: h*0.4), 0, math.pi, false, p);
             c.drawArc(Rect.fromCenter(center: Offset(0, h*0.3), width: h*0.8, height: h*0.4), 0, math.pi, false, p);
             break;
         case 17: // Q'anil (Venüs, Yıldız, Tohum / Elmas ve 4 nokta)
             final diaP = Path()..moveTo(0, -h*0.4)..lineTo(h*0.4, 0)..lineTo(0, h*0.4)..lineTo(-h*0.4, 0)..close();
             c.drawPath(diaP, p);
             c.drawCircle(Offset(0, -h*0.6), 3, f);
             c.drawCircle(Offset(0, h*0.6), 3, f);
             c.drawCircle(Offset(-h*0.6, 0), 3, f);
             c.drawCircle(Offset(h*0.6, 0), 3, f);
             break;
         case 18: // Toj (Ateş, Su Damlası / Yeşim kolye damlası)
             final dropP = Path()..moveTo(0, -h*0.6)..quadraticBezierTo(-h*0.6, h*0.2, 0, h*0.6)..quadraticBezierTo(h*0.6, h*0.2, 0, -h*0.6);
             c.drawPath(dropP, p..strokeWidth=2.0);
             c.drawCircle(Offset(0, h*0.2), h*0.15, p);
             break;
         case 19: // Tz'i' (Köpek / Sarkık kulak ve dik yüz)
             c.drawOval(Rect.fromCenter(center: Offset.zero, width: h*1.0, height: h*1.4), p);
             c.drawArc(Rect.fromCenter(center: Offset(-h*0.5, 0), width: h*0.6, height: h*0.8), -math.pi/2, math.pi, false, p); // Sarkık kulak
             c.drawCircle(Offset(h*0.2, -h*0.2), 3, f); // Göz
             c.drawCircle(Offset(h*0.2, h*0.3), h*0.1, p); // Burun
             break;
     }
  }

  @override
  bool shouldRepaint(covariant _MayanWheelPainter old) => old.rotation != rotation;
}
