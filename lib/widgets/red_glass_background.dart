import 'dart:ui';
import 'package:flutter/material.dart';

class RedGlassBackground extends StatelessWidget {
  const RedGlassBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2A0B12), // deep burgundy
                Color(0xFF5A0F1D), // cherry
                Color(0xFF0B0B0D), // near-black
              ],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
        ),

        // Blobs
        Positioned(
          top: -120,
          right: -120,
          child: _BlurBlob(color: const Color(0xFFFF2D55), size: 320, blur: 40, opacity: 0.30),
        ),
        Positioned(
          bottom: 120,
          left: -140,
          child: _BlurBlob(color: const Color(0xFFFF3B30), size: 360, blur: 55, opacity: 0.22),
        ),
        Positioned(
          bottom: -160,
          right: -140,
          child: _BlurBlob(color: const Color(0xFFB0122A), size: 420, blur: 70, opacity: 0.18),
        ),

        // Optional vignette (kenarları koyulaştırır)
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.35),
              ],
              stops: const [0.55, 1.0],
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
