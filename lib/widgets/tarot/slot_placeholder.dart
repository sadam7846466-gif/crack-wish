import 'dart:math';
import 'package:flutter/material.dart';

/// Slot placeholder for selected cards with particle burst effect
class SlotPlaceholder extends StatefulWidget {
  final double width;
  final double height;
  final int slotIndex;
  final Widget? child;
  final bool showBurst;
  final VoidCallback? onBurstComplete;

  const SlotPlaceholder({
    super.key,
    this.width = 80,
    this.height = 120,
    required this.slotIndex,
    this.child,
    this.showBurst = false,
    this.onBurstComplete,
  });

  @override
  State<SlotPlaceholder> createState() => _SlotPlaceholderState();
}

class _SlotPlaceholderState extends State<SlotPlaceholder>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _burstController;
  late Animation<double> _pulseAnimation;

  List<_BurstParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _burstController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onBurstComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(SlotPlaceholder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showBurst && !oldWidget.showBurst) {
      _triggerBurst();
    }
  }

  void _triggerBurst() {
    _particles = List.generate(20, (_) => _BurstParticle.random(_random));
    _burstController.forward(from: 0);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _burstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width + 20,
      height: widget.height + 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow effect (when empty)
          if (widget.child == null)
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  width: widget.width,
                  height: widget.height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFD4AF37)
                          .withOpacity(_pulseAnimation.value),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37)
                            .withOpacity(_pulseAnimation.value * 0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          color: const Color(0xFFD4AF37)
                              .withOpacity(_pulseAnimation.value),
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.slotIndex + 1}',
                          style: TextStyle(
                            color: const Color(0xFFD4AF37)
                                .withOpacity(_pulseAnimation.value),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

          // Card (when filled)
          if (widget.child != null)
            Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: widget.child,
            ),

          // Burst particles
          if (widget.showBurst)
            AnimatedBuilder(
              animation: _burstController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(widget.width + 60, widget.height + 60),
                  painter: _BurstPainter(
                    particles: _particles,
                    progress: _burstController.value,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _BurstParticle {
  final double angle;
  final double distance;
  final double size;
  final Color color;

  _BurstParticle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
  });

  factory _BurstParticle.random(Random random) {
    return _BurstParticle(
      angle: random.nextDouble() * 2 * pi,
      distance: random.nextDouble() * 50 + 30,
      size: random.nextDouble() * 4 + 2,
      color: random.nextBool()
          ? const Color(0xFFD4AF37)
          : const Color(0xFFFFFFFF),
    );
  }
}

class _BurstPainter extends CustomPainter {
  final List<_BurstParticle> particles;
  final double progress;

  _BurstPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    for (var particle in particles) {
      final currentDistance = particle.distance * progress;
      final opacity = (1 - progress).clamp(0.0, 1.0);

      final x = center.dx + cos(particle.angle) * currentDistance;
      final y = center.dy + sin(particle.angle) * currentDistance;

      paint.color = particle.color.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), particle.size * (1 - progress * 0.5), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Selected card row at the bottom
class SelectedCardsRow extends StatelessWidget {
  final List<Widget?> cards;
  final double cardWidth;
  final double cardHeight;

  const SelectedCardsRow({
    super.key,
    required this.cards,
    this.cardWidth = 80,
    this.cardHeight = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < 3; i++) ...[
          SlotPlaceholder(
            width: cardWidth,
            height: cardHeight,
            slotIndex: i,
            child: i < cards.length ? cards[i] : null,
            showBurst: false,
          ),
          if (i < 2) const SizedBox(width: 16),
        ],
      ],
    );
  }
}
