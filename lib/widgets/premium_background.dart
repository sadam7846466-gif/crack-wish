import 'dart:math';
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

/// Premium, calm background layer (no UI). Fits any size; designed for 9:16.
class PremiumBackground extends StatelessWidget {
  final double aspectRatio;
  final int seed;

  const PremiumBackground({
    super.key,
    this.aspectRatio = 9 / 16,
    this.seed = 42,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: CustomPaint(
        painter: _PremiumBackgroundPainter(seed),
        size: Size.infinite,
      ),
    );
  }
}

class _PremiumBackgroundPainter extends CustomPainter {
  final int seed;
  _PremiumBackgroundPainter(this.seed);

  late final Random _rand = Random(seed);

  @override
  void paint(Canvas canvas, Size size) {
    _paintGradient(canvas, size);
    _paintClouds(canvas, size);
    _paintLeaves(canvas, size);
    _paintMist(canvas, size);
    _paintNoise(canvas, size);
    _paintStars(canvas, size);
    _paintBokeh(canvas, size);
  }

  void _paintGradient(Canvas canvas, Size size) {
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        Color(0xFF1F4F59), // üst: derin teal
        Color(0xFFF6C27A), // orta: parlak amber
        Color(0xFFFAD8A6), // geçiş: sıcak bulut
        Color(0xFF1E5A63), // alt: teal-mavi
      ],
      stops: const [0.0, 0.28, 0.62, 1.0],
    );
    final paint = Paint()..shader = gradient.createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, paint);
  }

  void _paintMist(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120);

    for (final spot in _mistSpots()) {
      canvas.drawCircle(
        Offset(spot.dx * size.width, spot.dy * size.height),
        spot.radius * size.shortestSide,
        paint,
      );
    }
  }

  void _paintClouds(Canvas canvas, Size size) {
    final paints = [
      Paint()
        ..color = const Color(0xFFFFD9A8).withOpacity(0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 70),
      Paint()
        ..color = const Color(0xFFE9F4E6).withOpacity(0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80),
      Paint()
        ..color = const Color(0xFF8FD6C2).withOpacity(0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90),
    ];

    Offset pos(double x, double y) => Offset(x * size.width, y * size.height);
    double r(double v) => v * size.shortestSide;

    final blobs = <_CloudBlob>[
      _CloudBlob(pos(0.28, 0.22), r(0.26), 0),
      _CloudBlob(pos(0.68, 0.18), r(0.22), 1),
      _CloudBlob(pos(0.48, 0.34), r(0.28), 0),
      _CloudBlob(pos(0.62, 0.46), r(0.24), 2),
      _CloudBlob(pos(0.32, 0.52), r(0.30), 1),
      _CloudBlob(pos(0.18, 0.66), r(0.24), 0),
      _CloudBlob(pos(0.52, 0.70), r(0.30), 2),
      _CloudBlob(pos(0.78, 0.62), r(0.26), 1),
      _CloudBlob(pos(0.42, 0.84), r(0.28), 0),
      _CloudBlob(pos(0.70, 0.86), r(0.22), 2),
    ];

    for (final blob in blobs) {
      final p = paints[blob.paintIndex];
      canvas.drawCircle(blob.center, blob.radius, p);
    }
  }

  void _paintLeaves(Canvas canvas, Size size) {
    // Hafif, yarı saydam yaprak silüetleri (mint/yeşil), büyük blur ile.
    final leafPaints = [
      Paint()
        ..color = const Color(0xFF8BC9A7).withOpacity(0.26)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      Paint()
        ..color = const Color(0xFF6FB18E).withOpacity(0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    ];

    Path leafPath(Size s) {
      final p = Path();
      p.moveTo(0.5 * s.width, 0.0);
      p.quadraticBezierTo(
        0.95 * s.width,
        0.3 * s.height,
        0.5 * s.width,
        s.height,
      );
      p.quadraticBezierTo(0.05 * s.width, 0.3 * s.height, 0.5 * s.width, 0.0);
      return p;
    }

    void drawLeaf(
      Canvas c,
      Offset center,
      double scale,
      double angle,
      Paint paint,
    ) {
      final leafSize = Size(220 * scale, 360 * scale);
      final path = leafPath(leafSize);
      c.save();
      c.translate(center.dx, center.dy);
      c.rotate(angle);
      c.translate(-leafSize.width / 2, -leafSize.height / 2);
      c.drawPath(path, paint);
      c.restore();
    }

    final leaves = <_Leaf>[
      _Leaf(Offset(size.width * 0.22, size.height * 0.32), 0.9, -0.35, 0),
      _Leaf(Offset(size.width * 0.72, size.height * 0.28), 0.82, 0.28, 1),
      _Leaf(Offset(size.width * 0.58, size.height * 0.58), 1.05, -0.12, 0),
      _Leaf(Offset(size.width * 0.32, size.height * 0.68), 0.9, 0.22, 1),
      // Ekstra net yaprak
      _Leaf(Offset(size.width * 0.52, size.height * 0.44), 1.1, 0.05, 0),
    ];

    for (final leaf in leaves) {
      drawLeaf(
        canvas,
        leaf.center,
        leaf.scale,
        leaf.angle,
        leafPaints[leaf.paintIndex],
      );
    }
  }

  void _paintNoise(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.4);

    final count = 220;
    for (var i = 0; i < count; i++) {
      final dx = _rand.nextDouble();
      final dy = _rand.nextDouble();
      final r =
          0.0015 +
          _rand.nextDouble() * 0.0022; // radius proportional to min dimension
      canvas.drawCircle(
        Offset(dx * size.width, dy * size.height),
        r * size.shortestSide,
        paint,
      );
    }
  }

  void _paintStars(Canvas canvas, Size size) {
    final starPaint = Paint()..style = PaintingStyle.fill;

    // Small stars (çok daha görünür)
    const smallCount = 300;
    for (var i = 0; i < smallCount; i++) {
      final dx = _rand.nextDouble();
      final dy = _rand.nextDouble();
      final r = 0.0016 + _rand.nextDouble() * 0.0020;
      final op = 0.60 + _rand.nextDouble() * 0.30;
      starPaint
        ..color = Colors.white.withOpacity(op)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.25);
      canvas.drawCircle(
        Offset(dx * size.width, dy * size.height),
        r * size.shortestSide,
        starPaint,
      );
    }

    // Bright glints with hafif sıcak tonlar
    const bigCount = 40;
    const bigPalette = [
      Colors.white,
      Color(0xFFFFF5E1), // sıcak açık
      Color(0xFFFFE1B3), // hafif amber
    ];
    for (var i = 0; i < bigCount; i++) {
      final dx = _rand.nextDouble();
      final dy = _rand.nextDouble();
      final r = 0.0052 + _rand.nextDouble() * 0.0068;
      final op = 0.85 + _rand.nextDouble() * 0.15;
      final base = bigPalette[_rand.nextInt(bigPalette.length)];
      starPaint
        ..color = base.withOpacity(op)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.9);
      canvas.drawCircle(
        Offset(dx * size.width, dy * size.height),
        r * size.shortestSide,
        starPaint,
      );
    }
  }

  void _paintBokeh(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.8);
    const palette = [
      Color(0xFFFFC48D), // sıcak turuncu parıltı
      Color(0xFF9FE8D5), // mint-yeşil parıltı
      Colors.white, // nötr ışık
    ];

    final count = 28;
    for (var i = 0; i < count; i++) {
      final dx = _rand.nextDouble();
      final dy = _rand.nextDouble();
      final r = lerpDouble(0.004, 0.008, _rand.nextDouble())!;
      final opacityJitter = 0.03 + _rand.nextDouble() * 0.03;
      final base = palette[_rand.nextInt(palette.length)];
      paint.color = base.withOpacity(opacityJitter);
      canvas.drawCircle(
        Offset(dx * size.width, dy * size.height),
        r * size.shortestSide,
        paint,
      );
    }
  }

  List<_MistSpot> _mistSpots() {
    // Sparse, large blurred spots to fake fog; positions deterministic by seed.
    final spots = <_MistSpot>[];
    for (var i = 0; i < 6; i++) {
      final dx = _rand.nextDouble() * 0.9 + 0.05;
      final dy = _rand.nextDouble() * 0.9 + 0.05;
      final radius = 0.08 + _rand.nextDouble() * 0.05; // relative to min side
      spots.add(_MistSpot(dx, dy, radius));
    }
    return spots;
  }

  @override
  bool shouldRepaint(covariant _PremiumBackgroundPainter oldDelegate) =>
      oldDelegate.seed != seed;
}

class _MistSpot {
  final double dx;
  final double dy;
  final double radius;
  const _MistSpot(this.dx, this.dy, this.radius);
}

class _CloudBlob {
  final Offset center;
  final double radius;
  final int paintIndex;
  const _CloudBlob(this.center, this.radius, this.paintIndex);
}

class _Leaf {
  final Offset center;
  final double scale;
  final double angle;
  final int paintIndex;
  const _Leaf(this.center, this.scale, this.angle, this.paintIndex);
}
