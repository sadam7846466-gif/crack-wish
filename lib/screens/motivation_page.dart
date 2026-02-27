import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MotivationPage extends StatefulWidget {
  const MotivationPage({super.key});
  @override
  State<MotivationPage> createState() => _MotivationPageState();
}

class _MotivationPageState extends State<MotivationPage>
    with TickerProviderStateMixin {
  late AnimationController _starsCtrl;
  late AnimationController _spinCtrl;
  late AnimationController _selectCtrl;
  late AnimationController _rippleCtrl;
  double _wheelAngle = 0.0;
  double _spinVelocity = 0.0;
  double _autoRotationBase = 0.0;
  bool _isDragging = false;
  Offset _wheelCenter = Offset.zero;
  int? _selectedIndex;

  // Swipe-to-dismiss
  double _swipeOffset = 0.0;
  bool _isSwiping = false;

  static const double _friction = 0.97;
  static const double _autoSpeed = 0.0002;

  static const List<Map<String, dynamic>> characters = [
    {'emoji': '\u{1F60A}', 'label': 'Mutlu', 'color': Color(0xFFFFD700)},
    {'emoji': '\u{26A1}', 'label': 'Enerjik', 'color': Color(0xFFFF6B00)},
    {'emoji': '\u{1F60C}', 'label': 'Sakin', 'color': Color(0xFF7EC8E3)},
    {'emoji': '\u{1F3AF}', 'label': 'Odak', 'color': Color(0xFF4A90D9)},
    {'emoji': '\u{1F495}', 'label': 'Romantik', 'color': Color(0xFFFF69B4)},
    {'emoji': '\u{1F634}', 'label': 'Yorgun', 'color': Color(0xFF6B5B95)},
    {'emoji': '\u{1F630}', 'label': 'Stresli', 'color': Color(0xFFCC4444)},
    {'emoji': '\u{1F631}', 'label': 'Panik', 'color': Color(0xFFFF2222)},
    {'emoji': '\u{1F525}', 'label': 'Motivasyon', 'color': Color(0xFFFF8C00)},
    {'emoji': '\u{1F914}', 'label': 'Merakl\u{0131}', 'color': Color(0xFF50C878)},
    {'emoji': '\u{1F622}', 'label': '\u{00DC}zg\u{00FC}n', 'color': Color(0xFF5577AA)},
    {'emoji': '\u{1F60E}', 'label': 'Rahat', 'color': Color(0xFF88CC88)},
  ];

  @override
  void initState() {
    super.initState();
    _starsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _spinCtrl.addListener(_updateWheel);

    _selectCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _selectCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _rippleCtrl.reset();
        _rippleCtrl.repeat();
      }
    });

    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );
  }

  void _updateWheel() {
    if (_selectedIndex != null) return;
    if (!_isDragging) {
      if (_spinVelocity.abs() > 0.0001) {
        _spinVelocity *= _friction;
        setState(() {
          _wheelAngle += _spinVelocity;
        });
      } else {
        _spinVelocity = 0;
        setState(() {
          _autoRotationBase += _autoSpeed;
          _wheelAngle += _autoSpeed;
        });
      }
    }
  }

  void _onPanStart(DragStartDetails details) {
    if (_selectedIndex != null) return;
    _isDragging = true;
    _spinVelocity = 0;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_selectedIndex != null) return;
    final pos = details.globalPosition;
    final prev = pos - details.delta;
    final a1 = math.atan2(prev.dy - _wheelCenter.dy, prev.dx - _wheelCenter.dx);
    final a2 = math.atan2(pos.dy - _wheelCenter.dy, pos.dx - _wheelCenter.dx);
    var delta = a2 - a1;
    if (delta > math.pi) delta -= 2 * math.pi;
    if (delta < -math.pi) delta += 2 * math.pi;
    setState(() {
      _wheelAngle += delta;
      _spinVelocity = delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _isDragging = false;
  }

  void _onCharacterTap(int index) {
    if (_selectedIndex != null) return;
    _spinVelocity = 0;
    _isDragging = false;
    setState(() {
      _selectedIndex = index;
    });
    _selectCtrl.forward();
  }

  void _onDeselectCharacter() {
    _rippleCtrl.stop();
    _rippleCtrl.reset();
    _selectCtrl.reverse().then((_) {
      setState(() {
        _selectedIndex = null;
      });
    });
  }

  @override
  void dispose() {
    _spinCtrl.removeListener(_updateWheel);
    _spinCtrl.dispose();
    _starsCtrl.dispose();
    _selectCtrl.dispose();
    _rippleCtrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final swipeProgress = (_swipeOffset / screenWidth).clamp(0.0, 1.0);
    final scale = 1.0 - (swipeProgress * 0.08);
    final opacity = 1.0 - (swipeProgress * 0.5);

    return Transform(
      transform: Matrix4.identity()
        ..translate(_swipeOffset)
        ..scale(scale),
      alignment: Alignment.centerLeft,
      child: Opacity(
        opacity: opacity,
        child: Scaffold(
      body: Stack(
        children: [
          // Animated cosmic background
          RepaintBoundary(
            child: SizedBox.expand(
              child: AnimatedBuilder(
                animation: Listenable.merge([_starsCtrl, _selectCtrl]),
                builder: (ctx, _) {
                  Color? moodColor;
                  double moodBlend = 0.0;
                  if (_selectedIndex != null) {
                    moodColor = characters[_selectedIndex!]['color'] as Color;
                    moodBlend = Curves.easeInOut.transform(_selectCtrl.value);
                  }
                  return CustomPaint(
                    painter: _CosmicBgPainter(_starsCtrl.value, moodColor: moodColor, moodBlend: moodBlend),
                  );
                },
              ),
            ),
          ),
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          // Title
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 40,
            right: 40,
            child: AnimatedOpacity(
              opacity: _selectedIndex == null ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              child: const Text(
                'Bugün modun nasıl?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          // 12 interactive glass frames
          LayoutBuilder(
            builder: (ctx, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              final centerX = w / 2;
              final centerY = h / 2;
              final circleRadius = w * 0.4;
              const frameSize = 52.0;
              const selectedSize = 100.0;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                final box = context.findRenderObject() as RenderBox?;
                if (box != null) {
                  _wheelCenter = box.localToGlobal(Offset(centerX, centerY));
                }
              });

              return AnimatedBuilder(
                animation: _selectCtrl,
                builder: (ctx, _) {
                  final t = Curves.easeInOutCubic.transform(_selectCtrl.value);

                  return GestureDetector(
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    behavior: HitTestBehavior.translucent,
                    child: Stack(
                      children: List.generate(12, (i) {
                        final angle = (i * math.pi * 2 / 12) - (math.pi / 2) + _wheelAngle;
                        final wheelX = centerX + math.cos(angle) * circleRadius - frameSize / 2;
                        final wheelY = centerY + math.sin(angle) * circleRadius - frameSize / 2;

                        final isSelected = _selectedIndex == i;

                        if (_selectedIndex != null && !isSelected) {
                          return Positioned(
                            left: wheelX,
                            top: wheelY,
                            child: Opacity(
                              opacity: 1.0 - t,
                              child: _GlassFrame(
                                size: frameSize,
                                emoji: characters[i]['emoji'] as String,
                                label: characters[i]['label'] as String,
                              ),
                            ),
                          );
                        }

                        if (isSelected) {
                          final targetX = centerX - selectedSize / 2;
                          final targetY = centerY - selectedSize / 2;
                          final curX = wheelX + (targetX - wheelX) * t;
                          final curY = wheelY + (targetY - wheelY) * t;
                          final curSize = frameSize + (selectedSize - frameSize) * t;
                          final moodClr = characters[i]['color'] as Color;

                          return Positioned(
                            left: curX,
                            top: curY,
                            child: GestureDetector(
                              onTap: _onDeselectCharacter,
                              child: AnimatedBuilder(
                                animation: _rippleCtrl,
                                builder: (ctx, child) {
                                  if (t < 1.0) return child!;
                                  return CustomPaint(
                                    painter: _RipplePainter(
                                      progress: _rippleCtrl.value,
                                      color: Colors.white,
                                      ringCount: 4,
                                    ),
                                    child: child,
                                  );
                                },
                                child: SizedBox(
                                  width: curSize,
                                  height: curSize,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: moodClr.withValues(alpha: 0.5 * t),
                                          blurRadius: 24,
                                          spreadRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        characters[i]['emoji'] as String,
                                        style: TextStyle(fontSize: curSize * 0.6),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        return Positioned(
                          left: wheelX,
                          top: wheelY,
                          child: GestureDetector(
                            onTap: () => _onCharacterTap(i),
                            child: _GlassFrame(
                              size: frameSize,
                              emoji: characters[i]['emoji'] as String,
                              label: characters[i]['label'] as String,
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                },
              );
            },
          ),
          // Bottom hint text
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 40,
            left: 40,
            right: 40,
            child: AnimatedOpacity(
              opacity: _selectedIndex == null ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              child: Text(
                'Çarkı çevir, ruh halini seç ✨',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          // Left-edge swipe-to-dismiss strip
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 24,
            child: GestureDetector(
              onHorizontalDragStart: (_) {
                _isSwiping = true;
              },
              onHorizontalDragUpdate: (details) {
                if (!_isSwiping) return;
                setState(() {
                  _swipeOffset = (details.globalPosition.dx).clamp(0.0, screenWidth);
                });
              },
              onHorizontalDragEnd: (details) {
                if (!_isSwiping) return;
                _isSwiping = false;
                if (_swipeOffset > screenWidth * 0.3 ||
                    details.velocity.pixelsPerSecond.dx > 800) {
                  Navigator.of(context).pop();
                } else {
                  setState(() { _swipeOffset = 0.0; });
                }
              },
              behavior: HitTestBehavior.translucent,
            ),
          ),
        ],
      ),
      ),
      ),
    );
  }
}

class _ArcTextPainter extends CustomPainter {
  final String text;
  final TextStyle style;
  final double arcRadius;

  _ArcTextPainter({required this.text, required this.style, this.arcRadius = 300});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, arcRadius + 10);
    
    // Measure each character
    final charWidths = <double>[];
    for (final char in text.characters) {
      final tp = TextPainter(
        text: TextSpan(text: char, style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      charWidths.add(tp.width);
    }
    
    final totalWidth = charWidths.fold(0.0, (a, b) => a + b);
    final totalAngle = totalWidth / arcRadius;
    var currentAngle = -math.pi / 2 - totalAngle / 2;
    
    int i = 0;
    for (final char in text.characters) {
      final charAngle = charWidths[i] / arcRadius;
      final midAngle = currentAngle + charAngle / 2;
      
      final x = center.dx + arcRadius * math.cos(midAngle);
      final y = center.dy + arcRadius * math.sin(midAngle);
      
      final tp = TextPainter(
        text: TextSpan(text: char, style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(midAngle + math.pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
      
      currentAngle += charAngle;
      i++;
    }
  }

  @override
  bool shouldRepaint(covariant _ArcTextPainter old) =>
      old.text != text || old.arcRadius != arcRadius;
}

class _GlassFrame extends StatelessWidget {
  final double size;
  final String emoji;
  final String label;
  const _GlassFrame({required this.size, required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.06),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 0.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(emoji, style: TextStyle(fontSize: size * 0.5)),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _RipplePainter extends CustomPainter {
  final double progress;
  final Color color;
  final int ringCount;

  _RipplePainter({required this.progress, required this.color, this.ringCount = 3});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.max(size.width, size.height) * 5;
    const spawnDelay = 0.3; // each ring spawns 30% after the previous

    for (int i = 0; i < ringCount; i++) {
      final spawnTime = i * spawnDelay;
      if (progress < spawnTime) continue; // not born yet

      // This ring's own progress (0 to 1) since it spawned
      final ringLife = (progress - spawnTime) / (1.0 - spawnTime);
      final clampedLife = ringLife.clamp(0.0, 1.0);

      final radius = clampedLife * maxRadius;
      final opacity = (1.0 - clampedLife) * 0.4;

      if (opacity > 0.01 && radius > 0) {
        canvas.drawCircle(
          center,
          radius,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = color.withValues(alpha: opacity),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RipplePainter old) => old.progress != progress;
}

class _StarData {
  final double x, y, radius, speedX, speedY;
  final Color color;
  const _StarData({
    required this.x, required this.y, required this.radius,
    required this.speedX, required this.speedY, required this.color,
  });
}

class _CosmicBgPainter extends CustomPainter {
  final double t;
  final Color? moodColor;
  final double moodBlend;
  static List<_StarData>? _stars;
  static Size? _lastSize;
  static int _version = 3;

  _CosmicBgPainter(this.t, {this.moodColor, this.moodBlend = 0.0});

  static void _generateStars(Size size) {
    final rng = math.Random(77);
    final w = size.width;
    final h = size.height;
    final list = <_StarData>[];

    for (int i = 0; i < 1500; i++) {
      // Radial distribution from center — dense in middle, covers full page
      final angle = rng.nextDouble() * math.pi * 2;
      final dist = math.pow(rng.nextDouble(), 0.7) as double;
      final maxR = math.max(w, h) * 0.75;
      final r = dist * maxR;
      final x = w * 0.5 + math.cos(angle) * r;
      final y = h * 0.5 + math.sin(angle) * r;

      final radius = rng.nextDouble() * 0.65 + 0.15;

      // Distance from center for color
      final cdx = (x - w * 0.5) / w;
      final cdy = (y - h * 0.5) / h;
      final colorDist = math.sqrt(cdx * cdx + cdy * cdy);

      Color starColor;
      if (colorDist < 0.15) {
        final alpha = rng.nextDouble() * 0.55 + 0.25;
        starColor = Color.fromRGBO(
          225 + rng.nextInt(30), 195 + rng.nextInt(40), 155 + rng.nextInt(50), alpha);
      } else if (colorDist < 0.3) {
        final alpha = rng.nextDouble() * 0.35 + 0.15;
        starColor = Color.fromRGBO(
          170 + rng.nextInt(50), 175 + rng.nextInt(50), 200 + rng.nextInt(40), alpha);
      } else {
        final alpha = rng.nextDouble() * 0.25 + 0.08;
        starColor = Color.fromRGBO(
          150 + rng.nextInt(50), 160 + rng.nextInt(50), 190 + rng.nextInt(40), alpha);
      }

      final speedX = (rng.nextDouble() - 0.5) * 25;
      final speedY = (rng.nextDouble() - 0.5) * 16;

      list.add(_StarData(
        x: x, y: y, radius: radius,
        speedX: speedX, speedY: speedY, color: starColor,
      ));
    }
    _stars = list;
    _lastSize = size;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    if (_stars == null || _lastSize != size || _version != 8) {
      _version = 8;
      _generateStars(size);
    }

    // Base: dusty blue-gray, blended with mood color
    final baseColor = moodColor != null
        ? Color.lerp(const Color(0xFF3A4D68), Color.lerp(const Color(0xFF2E1420), moodColor!, 0.3)!, moodBlend)!
        : const Color(0xFF3A4D68);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = baseColor,
    );

    // Layer 1: Overall dusty blue-lavender wash
    _radial(canvas, Offset(w * 0.5, h * 0.5), w * 1.2, [
      const Color(0x30607090),
      const Color(0x18485870),
      const Color(0x002B3A52),
    ], blur: 20);

    // Center glow — blended with mood color
    final glowCore = moodColor != null
        ? Color.lerp(const Color(0x60EEDDC0), moodColor!.withValues(alpha: 0.5), moodBlend)!
        : const Color(0x60EEDDC0);
    final glowMid = moodColor != null
        ? Color.lerp(const Color(0x30E0D0B0), moodColor!.withValues(alpha: 0.25), moodBlend)!
        : const Color(0x30E0D0B0);
    _radial(canvas, Offset(w * 0.5, h * 0.5), w * 0.65, [
      glowCore,
      glowMid,
      const Color(0x15D0C0A0),
      const Color(0x08B8A890),
      const Color(0x002B3A52),
    ], blur: 40);
    // Mid spread: very wide, very faint
    _radial(canvas, Offset(w * 0.5, h * 0.49), w * 1.2, [
      const Color(0x20D8C8B0),
      const Color(0x10C0B0A0),
      const Color(0x08A09888),
      const Color(0x04787068),
      const Color(0x002B3A52),
    ], blur: 50);
    // Slight offset for organic feel
    _radial(canvas, Offset(w * 0.47, h * 0.51), w * 0.5, [
      const Color(0x30E8D8C0),
      const Color(0x14D0C0A8),
      const Color(0x002B3A52),
    ], blur: 35);

    // (bottom glow removed)

    // Layer 4: Soft blue on left side
    _radial(canvas, Offset(w * 0.1, h * 0.45), w * 0.5, [
      const Color(0x185878A0),
      const Color(0x0C405070),
      const Color(0x002B3A52),
    ], blur: 35);

    // Layer 5: Soft blue on right side
    _radial(canvas, Offset(w * 0.9, h * 0.4), w * 0.45, [
      const Color(0x145070A0),
      const Color(0x08405070),
      const Color(0x002B3A52),
    ], blur: 35);

    // Vignette: darken edges and corners
    final vignetteRect = Rect.fromLTWH(0, 0, w, h);
    canvas.drawRect(
      vignetteRect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.04, -0.2),
          radius: 0.75,
          colors: const [
            Color(0x00000000),
            Color(0x00000000),
            Color(0x30101828),
            Color(0x60101828),
          ],
          stops: const [0.0, 0.4, 0.75, 1.0],
        ).createShader(vignetteRect),
    );


    // Animated star particles
    final paint = Paint()..style = PaintingStyle.fill;
    for (final star in _stars!) {
      final ox = math.sin(t * math.pi * 2 + star.speedX) * star.speedX;
      final oy = math.cos(t * math.pi * 2 + star.speedY) * star.speedY;

      final sx = (star.x + ox) % w;
      final sy = (star.y + oy) % h;

      paint.color = star.color;
      canvas.drawCircle(Offset(sx, sy), star.radius, paint);
    }
  }

  void _radial(Canvas canvas, Offset center, double radius, List<Color> colors,
      {double blur = 30}) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(colors: colors).createShader(
          Rect.fromCircle(center: center, radius: radius),
        )
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
    );
  }

  @override
  bool shouldRepaint(covariant _CosmicBgPainter old) => old.t != t || old.moodColor != moodColor || old.moodBlend != moodBlend;
}
