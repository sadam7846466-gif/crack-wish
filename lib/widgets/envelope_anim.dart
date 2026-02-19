import 'dart:math' as math;
import 'package:flutter/material.dart';

class EnvelopeAnim extends StatefulWidget {
  const EnvelopeAnim({super.key});

  @override
  State<EnvelopeAnim> createState() => _EnvelopeAnimState();
}

class _EnvelopeAnimState extends State<EnvelopeAnim>
    with SingleTickerProviderStateMixin {
  late final AnimationController c;

  late final Animation<double> flapT;   // 0..1
  late final Animation<double> letterT; // 0..1

  bool open = false;

  @override
  void initState() {
    super.initState();
    c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    flapT = CurvedAnimation(
      parent: c,
      curve: const Interval(0.0, 0.45, curve: Curves.easeInOut),
    );

    letterT = CurvedAnimation(
      parent: c,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  void toggle() {
    setState(() => open = !open);
    if (open) {
      c.forward();
    } else {
      c.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: toggle,
        child: AnimatedBuilder(
          animation: c,
          builder: (_, __) {
            // mektup yukarı (negatif y)
            final double letterY = lerpDouble(40, -70, letterT.value)!;

            // flap açısı: kapalıyken 0, açılınca -110 derece gibi
            final double flapAngle = lerpDouble(0, -110, flapT.value)! * math.pi / 180;

            return SizedBox(
              width: 220,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Mektup (arkada)
                  Transform.translate(
                    offset: Offset(0, letterY),
                    child: Container(
                      width: 170,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 18,
                            offset: Offset(0, 10),
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Zarf arka
                  Container(
                    width: 200,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9E0D6),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 20,
                          offset: Offset(0, 14),
                          color: Colors.black12,
                        ),
                      ],
                    ),
                  ),

                  // Zarf ön kapağı (ön yüz)
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: 200,
                      height: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8CCBE),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(18),
                          bottomRight: Radius.circular(18),
                        ),
                      ),
                    ),
                  ),

                  // Flap (üst kapak) - rotateX
                  Positioned(
                    top: 30,
                    child: Transform(
                      alignment: Alignment.topCenter,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0018) // perspektif
                        ..rotateX(flapAngle),
                      child: ClipPath(
                        clipper: _TriangleClipper(),
                        child: Container(
                          width: 200,
                          height: 80,
                          color: const Color(0xFFD1C3B4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();
    p.moveTo(0, 0);
    p.lineTo(size.width, 0);
    p.lineTo(size.width / 2, size.height);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

double? lerpDouble(num? a, num? b, double t) {
  if (a == null && b == null) return null;
  a ??= 0.0;
  b ??= 0.0;
  return a + (b - a) * t;
}
