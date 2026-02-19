import 'dart:math';
import 'package:flutter/material.dart';

/// Açılıp kapanan zarf widget'ı.
/// [isOpen] değiştiğinde kapak animasyonlu açılır/kapanır.
class AnimatedEnvelope extends StatefulWidget {
  final bool isOpen;
  final double width;
  final double height;
  final Duration duration;
  final Widget? child; // Zarfın içine konacak kağıt/mektup widget'ı

  const AnimatedEnvelope({
    super.key,
    this.isOpen = false,
    this.width = 220,
    this.height = 140,
    this.duration = const Duration(milliseconds: 700),
    this.child,
  });

  @override
  State<AnimatedEnvelope> createState() => AnimatedEnvelopeState();
}

class AnimatedEnvelopeState extends State<AnimatedEnvelope>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _flapAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _flapAnim = Tween<double>(begin: 0, end: -pi).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    if (widget.isOpen) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant AnimatedEnvelope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen != oldWidget.isOpen) {
      widget.isOpen ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  /// Dışarıdan programatik kontrol
  void open() => _ctrl.forward();
  void close() => _ctrl.reverse();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.width;
    final h = widget.height;
    final flapH = h * 0.65;

    return SizedBox(
      width: w,
      height: h + flapH + 8, // kapak + gövde + gölge payı
      child: AnimatedBuilder(
        animation: _flapAnim,
        builder: (context, _) {
          final flapVal = _flapAnim.value; // 0 → -pi
          final flapProgress = flapVal.abs() / pi; // 0 → 1

          return Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              // ── GÖLGE ──
              Positioned(
                bottom: -4,
                child: Container(
                  width: w * 0.85,
                  height: 12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(w),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF8A3D).withOpacity(0.15),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),

              // ── 1) ZARF ARKA GÖVDE ──
              Container(
                width: w,
                height: h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFD4862A), // koyu amber üst
                      Color(0xFFE8A044), // orta
                      Color(0xFFC47820), // alt koyu
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),

              // ── 2) İÇERİK (mektup kağıdı) — kapak arkasında ──
              if (widget.child != null)
                Positioned(
                  bottom: 10,
                  child: SizedBox(
                    width: w - 20,
                    height: h - 20,
                    child: widget.child!,
                  ),
                ),

              // ── 3) ZARF ÖN YÜZÜ (V cebi) ──
              CustomPaint(
                size: Size(w, h),
                painter: _EnvelopeFrontPainter(),
              ),

              // ── 4) MÜHÜR (wax seal) ──
              Positioned(
                bottom: h * 0.45,
                child: AnimatedOpacity(
                  opacity: flapProgress < 0.3 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFFB8651A), Color(0xFF8B4513)],
                      ),
                      border: Border.all(
                        color: const Color(0xFFD4862A),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🦉', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ),
              ),

              // ── 5) HAREKETLİ ÜST KAPAK ──
              Positioned(
                bottom: h,
                child: Transform(
                  alignment: Alignment.bottomCenter,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateX(flapVal),
                  child: ClipPath(
                    clipper: _FlapClipper(),
                    child: Container(
                      width: w,
                      height: flapH,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: flapProgress > 0.5
                              ? [
                                  // Arka yüz (açıkken)
                                  const Color(0xFFA06420),
                                  const Color(0xFFB87830),
                                ]
                              : [
                                  // Ön yüz (kapalıyken)
                                  const Color(0xFFE8A044),
                                  const Color(0xFFD49038),
                                ],
                        ),
                      ),
                      // Baykuş watermark (kapak ön yüzünde)
                      child: flapProgress < 0.5
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Opacity(
                                  opacity: 0.12,
                                  child: Text(
                                    '🦉',
                                    style: TextStyle(fontSize: w * 0.14),
                                  ),
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ),

              // ── 6) SOL-SAĞ ÜÇGENLERİ (kapak kenarları) ──
              // Sol üçgen
              Positioned(
                bottom: h - 1,
                left: 0,
                child: CustomPaint(
                  size: Size(w / 2, flapH * 0.35),
                  painter: _SideTrianglePainter(isLeft: true),
                ),
              ),
              // Sağ üçgen
              Positioned(
                bottom: h - 1,
                right: 0,
                child: CustomPaint(
                  size: Size(w / 2, flapH * 0.35),
                  painter: _SideTrianglePainter(isLeft: false),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Zarfın ön V cebi ──
class _EnvelopeFrontPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFD49038),
          const Color(0xFFE8A044),
          const Color(0xFFD08030),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height * 0.7)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);

    // İnce kenar çizgisi
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFFA06420).withOpacity(0.3)
      ..strokeWidth = 0.5;
    final borderPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height * 0.7)
      ..lineTo(size.width, 0);
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// ── Kapak üçgen clip ──
class _FlapClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ── Yan üçgenler (kapak ile gövde arasındaki bağlantı) ──
class _SideTrianglePainter extends CustomPainter {
  final bool isLeft;
  _SideTrianglePainter({required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFBE7828);

    final path = Path();
    if (isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(size.width, 0);
      path.lineTo(0, 0);
      path.close();
    } else {
      path.moveTo(size.width, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
      path.close();
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
