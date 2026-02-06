import 'dart:math';
import 'package:flutter/material.dart';

/// Very subtle animated dust/mist overlay.
/// Keep opacity low; intended as a passive background effect.
class AnimatedDustOverlay extends StatefulWidget {
  final int particleCount;
  final Duration duration;
  final double maxRadius;
  final Color color;

  const AnimatedDustOverlay({
    super.key,
    this.particleCount = 48,
    this.duration = const Duration(seconds: 16),
    this.maxRadius = 0.01, // relative to shortestSide
    this.color = const Color(0xFFFFFBF7), // near-white for visibility on peach
  });

  @override
  State<AnimatedDustOverlay> createState() => _AnimatedDustOverlayState();
}

class _AnimatedDustOverlayState extends State<AnimatedDustOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_DustParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);
    _particles = List.generate(
      widget.particleCount,
      (i) => _DustParticle.random(Random(i * 97 + 13)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _DustPainter(
            progress: _controller.value,
            particles: _particles,
            maxRadius: widget.maxRadius,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class _DustParticle {
  final double x;
  final double y;
  final double baseRadius;
  final double driftX;
  final double driftY;
  final double opacity;

  const _DustParticle({
    required this.x,
    required this.y,
    required this.baseRadius,
    required this.driftX,
    required this.driftY,
    required this.opacity,
  });

  factory _DustParticle.random(Random rand) {
    final x = rand.nextDouble();
    final y = rand.nextDouble();
    final baseRadius = 0.005 + rand.nextDouble() * 0.0065;
    final driftX = (rand.nextDouble() - 0.5) * 0.02;
    final driftY = (rand.nextDouble() - 0.5) * 0.02;
    final opacity = 0.035 + rand.nextDouble() * 0.045;
    return _DustParticle(
      x: x,
      y: y,
      baseRadius: baseRadius,
      driftX: driftX,
      driftY: driftY,
      opacity: opacity,
    );
  }
}

class _DustPainter extends CustomPainter {
  final double progress;
  final List<_DustParticle> particles;
  final double maxRadius;
  final Color color;

  _DustPainter({
    required this.progress,
    required this.particles,
    required this.maxRadius,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    for (final p in particles) {
      // Gentle drift
      final dx = (p.x + p.driftX * (progress - 0.5)) * size.width;
      final dy = (p.y + p.driftY * (progress - 0.5)) * size.height;
      final radius = (p.baseRadius + (progress - 0.5).abs() * maxRadius) *
          size.shortestSide;
      final opacity = p.opacity * (0.7 + 0.3 * sin(progress * pi * 2));
      paint.color = color.withOpacity(opacity.clamp(0.0, 0.35));
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DustPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.particles != particles ||
      oldDelegate.maxRadius != maxRadius;
}
