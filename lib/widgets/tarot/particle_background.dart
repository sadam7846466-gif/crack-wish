import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// AAA-Quality Mystical Background with Particle System and Gyroscope Parallax
class ParticleBackground extends StatefulWidget {
  final Widget child;
  final bool enableParallax;
  final int particleCount;

  const ParticleBackground({
    super.key,
    required this.child,
    this.enableParallax = true,
    this.particleCount = 60,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with TickerProviderStateMixin {
  // Gyroscope values for parallax
  double _gyroX = 0.0;
  double _gyroY = 0.0;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;

  // Animation controller for particles
  late AnimationController _particleController;

  // Particle system
  late List<_Particle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initParticles();
    _initAnimations();
    if (widget.enableParallax) {
      _initGyroscope();
    }
  }

  void _initParticles() {
    _particles = List.generate(widget.particleCount, (_) => _Particle.random(_random));
  }

  void _initAnimations() {
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    _particleController.addListener(() {
      if (mounted) {
        setState(() {
          for (var particle in _particles) {
            particle.update();
          }
        });
      }
    });
  }

  void _initGyroscope() {
    _gyroscopeSubscription = gyroscopeEventStream(
      samplingPeriod: const Duration(milliseconds: 50),
    ).listen((GyroscopeEvent event) {
      if (mounted) {
        setState(() {
          // Smooth damping for natural feel
          _gyroX = _gyroX * 0.85 + event.y * 0.15 * 8;
          _gyroY = _gyroY * 0.85 + event.x * 0.15 * 8;
          // Clamp values
          _gyroX = _gyroX.clamp(-15.0, 15.0);
          _gyroY = _gyroY.clamp(-15.0, 15.0);
        });
      }
    });
  }

  @override
  void dispose() {
    _gyroscopeSubscription?.cancel();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Deep Space Gradient Background
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A0A1A), // Deepest navy
                  Color(0xFF0F1123), // Deep Navy
                  Color(0xFF151530), // Midnight
                  Color(0xFF0D0D1A), // Near black
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),
        ),

        // Nebula/Cosmic Dust Layer (subtle radial gradients)
        Positioned.fill(
          child: Transform.translate(
            offset: Offset(_gyroX * 2, _gyroY * 2),
            child: CustomPaint(
              painter: _NebulaPainter(),
            ),
          ),
        ),

        // Parallax Star Layer 1 (far - slow movement)
        Positioned.fill(
          child: Transform.translate(
            offset: Offset(_gyroX * 0.5, _gyroY * 0.5),
            child: CustomPaint(
              painter: _StarLayerPainter(
                particles: _particles.where((p) => p.layer == 0).toList(),
                opacity: 0.3,
              ),
            ),
          ),
        ),

        // Parallax Star Layer 2 (mid - medium movement)
        Positioned.fill(
          child: Transform.translate(
            offset: Offset(_gyroX * 1.0, _gyroY * 1.0),
            child: CustomPaint(
              painter: _StarLayerPainter(
                particles: _particles.where((p) => p.layer == 1).toList(),
                opacity: 0.5,
              ),
            ),
          ),
        ),

        // Parallax Star Layer 3 (near - fast movement)
        Positioned.fill(
          child: Transform.translate(
            offset: Offset(_gyroX * 1.5, _gyroY * 1.5),
            child: CustomPaint(
              painter: _StarLayerPainter(
                particles: _particles.where((p) => p.layer == 2).toList(),
                opacity: 0.8,
              ),
            ),
          ),
        ),

        // Floating Particles (glowing orbs moving upward)
        Positioned.fill(
          child: IgnorePointer(
            child: Transform.translate(
              offset: Offset(_gyroX * 2.0, _gyroY * 2.0),
              child: CustomPaint(
                painter: _FloatingParticlesPainter(
                  particles: _particles,
                  time: _particleController.value,
                ),
              ),
            ),
          ),
        ),

        // Golden ambient glow at bottom
        Positioned(
          bottom: -100,
          left: 0,
          right: 0,
          child: Transform.translate(
            offset: Offset(_gyroX * 0.3, 0),
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.bottomCenter,
                  radius: 1.5,
                  colors: [
                    const Color(0xFFD4AF37).withOpacity(0.08),
                    const Color(0xFFD4AF37).withOpacity(0.03),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // Content
        widget.child,
      ],
    );
  }
}

// Particle data class
class _Particle {
  double x;
  double y;
  double radius;
  double speed;
  double opacity;
  int layer; // 0 = far, 1 = mid, 2 = near
  double twinklePhase;
  bool isGlowing;

  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.opacity,
    required this.layer,
    required this.twinklePhase,
    required this.isGlowing,
  });

  factory _Particle.random(Random random) {
    return _Particle(
      x: random.nextDouble(),
      y: random.nextDouble(),
      radius: random.nextDouble() * 2 + 0.5,
      speed: random.nextDouble() * 0.0008 + 0.0002,
      opacity: random.nextDouble() * 0.6 + 0.2,
      layer: random.nextInt(3),
      twinklePhase: random.nextDouble() * pi * 2,
      isGlowing: random.nextDouble() > 0.85,
    );
  }

  void update() {
    y -= speed;
    twinklePhase += 0.02;
    if (y < -0.05) {
      y = 1.05;
      x = Random().nextDouble();
    }
  }
}

// Nebula/Cosmic dust painter
class _NebulaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Purple nebula
    paint.shader = RadialGradient(
      center: const Alignment(-0.3, -0.5),
      radius: 0.8,
      colors: [
        const Color(0xFF2D1B4E).withOpacity(0.15),
        const Color(0xFF1A0A2E).withOpacity(0.08),
        Colors.transparent,
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Blue nebula
    paint.shader = RadialGradient(
      center: const Alignment(0.5, 0.3),
      radius: 0.6,
      colors: [
        const Color(0xFF1A2B4E).withOpacity(0.12),
        const Color(0xFF0F1123).withOpacity(0.05),
        Colors.transparent,
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Static star layer painter
class _StarLayerPainter extends CustomPainter {
  final List<_Particle> particles;
  final double opacity;

  _StarLayerPainter({required this.particles, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var particle in particles) {
      final x = particle.x * size.width;
      final y = particle.y * size.height;
      final twinkle = (sin(particle.twinklePhase) + 1) / 2;
      final finalOpacity = particle.opacity * opacity * (0.5 + twinkle * 0.5);

      paint.color = Colors.white.withOpacity(finalOpacity.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(x, y), particle.radius, paint);

      // Add glow for special particles
      if (particle.isGlowing) {
        paint.color = const Color(0xFFD4AF37).withOpacity(finalOpacity * 0.3);
        canvas.drawCircle(Offset(x, y), particle.radius * 3, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StarLayerPainter oldDelegate) => true;
}

// Floating particles painter (upward moving orbs)
class _FloatingParticlesPainter extends CustomPainter {
  final List<_Particle> particles;
  final double time;

  _FloatingParticlesPainter({required this.particles, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var particle in particles) {
      if (!particle.isGlowing) continue;

      final x = particle.x * size.width;
      final y = particle.y * size.height;
      final twinkle = (sin(particle.twinklePhase + time * pi * 2) + 1) / 2;
      final pulseRadius = particle.radius * (1.0 + twinkle * 0.5);

      // Inner glow (gold)
      paint.color = const Color(0xFFD4AF37).withOpacity(0.6 * twinkle);
      canvas.drawCircle(Offset(x, y), pulseRadius, paint);

      // Outer glow
      paint.color = const Color(0xFFD4AF37).withOpacity(0.2 * twinkle);
      canvas.drawCircle(Offset(x, y), pulseRadius * 2.5, paint);

      // Core (white)
      paint.color = Colors.white.withOpacity(0.8 * twinkle);
      canvas.drawCircle(Offset(x, y), pulseRadius * 0.4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FloatingParticlesPainter oldDelegate) => true;
}
