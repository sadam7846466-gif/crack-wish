import 'package:flutter/material.dart';
import 'dart:math' as math;

class StarsBackground extends StatefulWidget {
  const StarsBackground({super.key});

  @override
  State<StarsBackground> createState() => _StarsBackgroundState();
}

class _StarsBackgroundState extends State<StarsBackground>
    with SingleTickerProviderStateMixin {
  static const double _cycleSeconds = 28;
  late final AnimationController _controller;
  late final List<_Star> _stars;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (_cycleSeconds * 1000).round()),
    )..repeat();
    _stars = _generateStars();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_Star> _generateStars() {
    final random = math.Random(42);
    final stars = <_Star>[];

    for (int i = 0; i < 120; i++) {
      stars.add(
        _Star(
          x: random.nextDouble(),
          y: random.nextDouble(),
          radius: random.nextDouble() * 1.0 + 0.3,
          vx: (random.nextDouble() * 2 - 1) * 2.0,
          vy: (random.nextDouble() * 2 - 1) * 2.0,
          color: Colors.white.withOpacity(0.6),
        ),
      );
    }

    for (int i = 0; i < 50; i++) {
      stars.add(
        _Star(
          x: random.nextDouble(),
          y: random.nextDouble(),
          radius: random.nextDouble() * 1.4 + 0.6,
          vx: (random.nextDouble() * 2 - 1) * 2.4,
          vy: (random.nextDouble() * 2 - 1) * 2.4,
          color: const Color(0xFF25F4EE).withOpacity(0.4),
        ),
      );
    }

    return stars;
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: StarsPainter(
        stars: _stars,
        animation: _controller,
        cycleSeconds: _cycleSeconds,
      ),
      child: Container(),
    );
  }
}

class StarsPainter extends CustomPainter {
  final List<_Star> stars;
  final Animation<double> animation;
  final double cycleSeconds;

  StarsPainter({
    required this.stars,
    required this.animation,
    required this.cycleSeconds,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value * cycleSeconds;
    final paint = Paint()..style = PaintingStyle.fill;

    for (final star in stars) {
      final baseX = star.x * size.width;
      final baseY = star.y * size.height;
      var dx = baseX + star.vx * t;
      var dy = baseY + star.vy * t;
      dx = dx % size.width;
      dy = dy % size.height;
      if (dx < 0) dx += size.width;
      if (dy < 0) dy += size.height;
      paint.color = star.color;
      canvas.drawCircle(Offset(dx, dy), star.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant StarsPainter oldDelegate) {
    return oldDelegate.stars != stars ||
        oldDelegate.animation != animation ||
        oldDelegate.cycleSeconds != cycleSeconds;
  }
}

class _Star {
  final double x;
  final double y;
  final double radius;
  final double vx;
  final double vy;
  final Color color;

  const _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.vx,
    required this.vy,
    required this.color,
  });
}
