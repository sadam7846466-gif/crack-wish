import 'package:flutter/material.dart';
import 'dart:math' as math;

class StarsBackground extends StatelessWidget {
  const StarsBackground({super.key});

  static final List<_Star> _stars = _generateStars();

  static List<_Star> _generateStars() {
    final random = math.Random(42);
    final stars = <_Star>[];

    for (int i = 0; i < 50; i++) {
      stars.add(
        _Star(
          x: random.nextDouble(),
          y: random.nextDouble(),
          radius: random.nextDouble() * 1.0 + 0.3,
          color: Colors.white.withValues(alpha: 0.5 + random.nextDouble() * 0.3),
        ),
      );
    }

    for (int i = 0; i < 12; i++) {
      stars.add(
        _Star(
          x: random.nextDouble(),
          y: random.nextDouble(),
          radius: random.nextDouble() * 1.4 + 0.6,
          color: const Color(0xFF25F4EE).withValues(alpha: 0.3),
        ),
      );
    }

    return stars;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _StaticStarsPainter(stars: _stars),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _StaticStarsPainter extends CustomPainter {
  final List<_Star> stars;

  _StaticStarsPainter({required this.stars});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final star in stars) {
      final dx = star.x * size.width;
      final dy = star.y * size.height;
      paint.color = star.color;
      canvas.drawCircle(Offset(dx, dy), star.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StaticStarsPainter oldDelegate) => false;
}

class _Star {
  final double x;
  final double y;
  final double radius;
  final Color color;

  const _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.color,
  });
}
