import 'dart:ui';
import 'package:flutter/material.dart';

class RedGlassBackground extends StatelessWidget {
  const RedGlassBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient — daha açık ve yumuşak
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF3D1520), // yumuşak bordo
                Color(0xFF7A2235), // açık cherry rose
                Color(0xFF1A0D12), // koyu siyah-kırmızı
              ],
              stops: [0.0, 0.50, 1.0],
            ),
          ),
        ),

        // Büyük bulanık blob'lar — daha soft ve daha fazla blur
        Positioned(
          top: -100,
          right: -100,
          child: _BlurBlob(color: const Color(0xFFFF4466), size: 380, blur: 80, opacity: 0.22),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.35,
          left: -160,
          child: _BlurBlob(color: const Color(0xFFE83050), size: 400, blur: 90, opacity: 0.16),
        ),
        Positioned(
          bottom: -140,
          right: -120,
          child: _BlurBlob(color: const Color(0xFFC41830), size: 450, blur: 100, opacity: 0.14),
        ),

        // Vignette — kenarları yumuşak koyulaştır
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.30),
              ],
              stops: const [0.5, 1.0],
            ),
          ),
        ),

        child,
      ],
    );
  }
}

class _BlurBlob extends StatelessWidget {
  const _BlurBlob({
    required this.color,
    required this.size,
    required this.blur,
    required this.opacity,
  });

  final Color color;
  final double size;
  final double blur;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(opacity),
        ),
      ),
    );
  }
}

