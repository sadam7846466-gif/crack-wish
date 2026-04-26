import 'package:flutter/material.dart';

/// Her burç için benzersiz, el-çizimi estetiğinde altın semboller çizen Painter.
/// Kullanım: CustomPaint(size: Size(120,120), painter: ZodiacGlyphPainter(signIndex: 0))
class ZodiacGlyphPainter extends CustomPainter {
  final int signIndex; // 0=Koç .. 11=Balık
  final Color color;
  final Color glowColor;

  ZodiacGlyphPainter({
    required this.signIndex,
    this.color = const Color(0xFFFFD060),
    this.glowColor = const Color(0xFFFFE8A1),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final scale = size.width / 100; // Normalize to 100x100

    // Glow altlık
    final glowPaint = Paint()
      ..color = glowColor.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    
    // Ana çizgi stili
    final pen = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    // İnce dekoratif çizgi
    final thinPen = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 * scale
      ..strokeCap = StrokeCap.round;

    // Nokta dolgu
    final dot = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(cx, cy);

    // Glow efekti
    _drawGlyphPath(canvas, scale, glowPaint, signIndex);
    // Ana sembol
    _drawGlyphPath(canvas, scale, pen, signIndex);
    // Dekoratif detaylar
    _drawDetails(canvas, scale, thinPen, dot, signIndex);

    canvas.restore();
  }

  void _drawGlyphPath(Canvas canvas, double s, Paint paint, int index) {
    final path = Path();
    switch (index) {
      case 0: _drawAries(path, s); break;
      case 1: _drawTaurus(path, s); break;
      case 2: _drawGemini(path, s); break;
      case 3: _drawCancer(path, s); break;
      case 4: _drawLeo(path, s); break;
      case 5: _drawVirgo(path, s); break;
      case 6: _drawLibra(path, s); break;
      case 7: _drawScorpio(path, s); break;
      case 8: _drawSagittarius(path, s); break;
      case 9: _drawCapricorn(path, s); break;
      case 10: _drawAquarius(path, s); break;
      case 11: _drawPisces(path, s); break;
    }
    canvas.drawPath(path, paint);
  }

  // ═══════════════════════════════════════
  // ♈ KOÇ (Aries) — Koçboynuzu spiralleri
  // ═══════════════════════════════════════
  void _drawAries(Path p, double s) {
    // Sol boynuz - zarif spiral
    p.moveTo(-2 * s, 20 * s);
    p.cubicTo(-2 * s, -5 * s, -22 * s, -28 * s, -22 * s, -10 * s);
    p.cubicTo(-22 * s, 2 * s, -12 * s, 2 * s, -8 * s, -8 * s);
    
    // Sağ boynuz - zarif spiral
    p.moveTo(2 * s, 20 * s);
    p.cubicTo(2 * s, -5 * s, 22 * s, -28 * s, 22 * s, -10 * s);
    p.cubicTo(22 * s, 2 * s, 12 * s, 2 * s, 8 * s, -8 * s);

    // Orta dikey çizgi
    p.moveTo(0, -15 * s);
    p.lineTo(0, 25 * s);
  }

  // ═══════════════════════════════════════
  // ♉ BOĞA (Taurus) — Boğa başı ve boynuzlar
  // ═══════════════════════════════════════
  void _drawTaurus(Path p, double s) {
    // Daire (baş)
    final r = 14 * s;
    p.addOval(Rect.fromCircle(center: Offset(0, 10 * s), radius: r));
    
    // Sol boynuz
    p.moveTo(-14 * s, 2 * s);
    p.cubicTo(-20 * s, -10 * s, -24 * s, -22 * s, -16 * s, -28 * s);
    
    // Sağ boynuz
    p.moveTo(14 * s, 2 * s);
    p.cubicTo(20 * s, -10 * s, 24 * s, -22 * s, 16 * s, -28 * s);
  }

  // ═══════════════════════════════════════
  // ♊ İKİZLER (Gemini) — İki paralel figür
  // ═══════════════════════════════════════
  void _drawGemini(Path p, double s) {
    // Üst bağlantı yayı
    p.moveTo(-16 * s, -24 * s);
    p.cubicTo(-6 * s, -16 * s, 6 * s, -16 * s, 16 * s, -24 * s);
    
    // Alt bağlantı yayı
    p.moveTo(-16 * s, 24 * s);
    p.cubicTo(-6 * s, 16 * s, 6 * s, 16 * s, 16 * s, 24 * s);
    
    // Sol dikey
    p.moveTo(-12 * s, -24 * s);
    p.lineTo(-12 * s, 24 * s);
    
    // Sağ dikey
    p.moveTo(12 * s, -24 * s);
    p.lineTo(12 * s, 24 * s);
  }

  // ═══════════════════════════════════════
  // ♋ YENGEÇ (Cancer) — İki iç içe geçen yay
  // ═══════════════════════════════════════
  void _drawCancer(Path p, double s) {
    // Üst yay (sağa açılan)
    p.moveTo(18 * s, -6 * s);
    p.cubicTo(18 * s, -22 * s, -18 * s, -22 * s, -18 * s, -6 * s);
    // Üst küçük daire
    p.addOval(Rect.fromCircle(center: Offset(18 * s, -6 * s), radius: 5.5 * s));

    // Alt yay (sola açılan)
    p.moveTo(-18 * s, 6 * s);
    p.cubicTo(-18 * s, 22 * s, 18 * s, 22 * s, 18 * s, 6 * s);
    // Alt küçük daire
    p.addOval(Rect.fromCircle(center: Offset(-18 * s, 6 * s), radius: 5.5 * s));
  }

  // ═══════════════════════════════════════
  // ♌ ASLAN (Leo) — Aslan yelesi spirali
  // ═══════════════════════════════════════
  void _drawLeo(Path p, double s) {
    // Büyük daire (yele)
    p.addOval(Rect.fromCircle(center: Offset(-6 * s, 4 * s), radius: 14 * s));
    
    // Kuyruk - zarif kıvrım yukarı
    p.moveTo(8 * s, 4 * s);
    p.cubicTo(16 * s, 4 * s, 22 * s, -6 * s, 22 * s, -14 * s);
    p.cubicTo(22 * s, -22 * s, 14 * s, -26 * s, 10 * s, -20 * s);
    p.cubicTo(6 * s, -14 * s, 14 * s, -10 * s, 18 * s, -14 * s);
    
    // Alt dekoratif kuyruk
    p.moveTo(-6 * s, 18 * s);
    p.cubicTo(-2 * s, 26 * s, 6 * s, 28 * s, 12 * s, 24 * s);
  }

  // ═══════════════════════════════════════
  // ♍ BAŞAK (Virgo) — M harfi + sağda kıvrım
  // ═══════════════════════════════════════
  void _drawVirgo(Path p, double s) {
    // M yapısı
    p.moveTo(-20 * s, 20 * s);
    p.lineTo(-20 * s, -8 * s);
    p.cubicTo(-20 * s, -20 * s, -10 * s, -20 * s, -10 * s, -8 * s);
    p.lineTo(-10 * s, 20 * s);

    p.moveTo(-10 * s, -8 * s);
    p.cubicTo(-10 * s, -20 * s, 0, -20 * s, 0, -8 * s);
    p.lineTo(0, 20 * s);

    p.moveTo(0, -8 * s);
    p.cubicTo(0, -20 * s, 10 * s, -20 * s, 10 * s, -8 * s);
    p.lineTo(10 * s, 12 * s);
    
    // Sağ elegant kıvrım (Başak'ın ayak izi)
    p.cubicTo(10 * s, 18 * s, 16 * s, 22 * s, 22 * s, 18 * s);
    p.cubicTo(26 * s, 14 * s, 20 * s, 8 * s, 16 * s, 12 * s);
  }

  // ═══════════════════════════════════════
  // ♎ TERAZİ (Libra) — Terazi kefeleri
  // ═══════════════════════════════════════
  void _drawLibra(Path p, double s) {
    // Alt çizgi
    p.moveTo(-22 * s, 18 * s);
    p.lineTo(22 * s, 18 * s);
    
    // Orta çizgi
    p.moveTo(-22 * s, 6 * s);
    p.lineTo(22 * s, 6 * s);
    
    // Üst yay (kefe)
    p.moveTo(-22 * s, 6 * s);
    p.cubicTo(-22 * s, -16 * s, 22 * s, -16 * s, 22 * s, 6 * s);
  }

  // ═══════════════════════════════════════
  // ♏ AKREP (Scorpio) — M + ok kuyruğu
  // ═══════════════════════════════════════
  void _drawScorpio(Path p, double s) {
    // M yapısı
    p.moveTo(-20 * s, 20 * s);
    p.lineTo(-20 * s, -6 * s);
    p.cubicTo(-20 * s, -20 * s, -10 * s, -20 * s, -10 * s, -6 * s);
    p.lineTo(-10 * s, 20 * s);

    p.moveTo(-10 * s, -6 * s);
    p.cubicTo(-10 * s, -20 * s, 0, -20 * s, 0, -6 * s);
    p.lineTo(0, 20 * s);

    p.moveTo(0, -6 * s);
    p.cubicTo(0, -20 * s, 10 * s, -20 * s, 10 * s, -6 * s);
    p.lineTo(10 * s, 14 * s);
    
    // Ok kuyruğu (Akrep iğnesi)
    p.cubicTo(10 * s, 20 * s, 16 * s, 24 * s, 22 * s, 18 * s);
    // Ok ucu
    p.moveTo(22 * s, 18 * s);
    p.lineTo(18 * s, 12 * s);
    p.moveTo(22 * s, 18 * s);
    p.lineTo(26 * s, 14 * s);
  }

  // ═══════════════════════════════════════
  // ♐ YAY (Sagittarius) — Ok ve yay
  // ═══════════════════════════════════════
  void _drawSagittarius(Path p, double s) {
    // Çapraz ok
    p.moveTo(-18 * s, 22 * s);
    p.lineTo(22 * s, -18 * s);
    
    // Ok ucu
    p.moveTo(22 * s, -18 * s);
    p.lineTo(10 * s, -18 * s);
    p.moveTo(22 * s, -18 * s);
    p.lineTo(22 * s, -6 * s);
    
    // Çapraz kısa çizgi (yay gövdesi)
    p.moveTo(-8 * s, 6 * s);
    p.lineTo(8 * s, -10 * s);
    
    // Yay kavis
    p.moveTo(-8 * s, 6 * s);
    p.cubicTo(-20 * s, 0, -14 * s, -12 * s, -2 * s, -6 * s);
  }

  // ═══════════════════════════════════════
  // ♑ OĞLAK (Capricorn) — Dağ keçisi kuyruğu
  // ═══════════════════════════════════════
  void _drawCapricorn(Path p, double s) {
    // Sol bacak
    p.moveTo(-18 * s, -24 * s);
    p.lineTo(-18 * s, 6 * s);
    p.cubicTo(-18 * s, 16 * s, -8 * s, 16 * s, -8 * s, 6 * s);
    
    // Orta bağlantı
    p.moveTo(-8 * s, 6 * s);
    p.lineTo(-8 * s, -14 * s);
    p.cubicTo(-8 * s, -24 * s, 4 * s, -24 * s, 4 * s, -14 * s);
    p.lineTo(4 * s, 8 * s);
    
    // Kuyruk kıvrımı (balık kuyruğu)
    p.cubicTo(4 * s, 18 * s, 14 * s, 24 * s, 20 * s, 18 * s);
    p.cubicTo(26 * s, 12 * s, 20 * s, 6 * s, 14 * s, 10 * s);
    p.cubicTo(8 * s, 14 * s, 12 * s, 22 * s, 18 * s, 24 * s);
  }

  // ═══════════════════════════════════════
  // ♒ KOVA (Aquarius) — İki dalgalı çizgi
  // ═══════════════════════════════════════
  void _drawAquarius(Path p, double s) {
    // Üst dalga
    for (int i = 0; i < 3; i++) {
      final x = -20 * s + i * 14 * s;
      p.moveTo(x, -8 * s);
      p.lineTo(x + 4 * s, -16 * s);
      p.lineTo(x + 10 * s, -8 * s);
    }
    // Alt dalga
    for (int i = 0; i < 3; i++) {
      final x = -20 * s + i * 14 * s;
      p.moveTo(x, 8 * s);
      p.lineTo(x + 4 * s, 0);
      p.lineTo(x + 10 * s, 8 * s);
    }
  }

  // ═══════════════════════════════════════
  // ♓ BALIK (Pisces) — İki karşılıklı yay
  // ═══════════════════════════════════════
  void _drawPisces(Path p, double s) {
    // Sol yay (sola açık)
    p.moveTo(-14 * s, -24 * s);
    p.cubicTo(-28 * s, -12 * s, -28 * s, 12 * s, -14 * s, 24 * s);
    
    // Sağ yay (sağa açık)
    p.moveTo(14 * s, -24 * s);
    p.cubicTo(28 * s, -12 * s, 28 * s, 12 * s, 14 * s, 24 * s);
    
    // Orta yatay çizgi
    p.moveTo(-20 * s, 0);
    p.lineTo(20 * s, 0);
  }

  // ═══════════════════════════════════════
  // Dekoratif detaylar (her burca özel küçük dokunuşlar)
  // ═══════════════════════════════════════
  void _drawDetails(Canvas canvas, double s, Paint thinPen, Paint dot, int index) {
    // Merkez küçük parıltı noktası
    canvas.drawCircle(Offset.zero, 1.5 * s, dot);
  }

  @override
  bool shouldRepaint(covariant ZodiacGlyphPainter old) => old.signIndex != signIndex;
}
