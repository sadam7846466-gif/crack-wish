import 'dart:ui';
import 'package:flutter/material.dart';

class GlassLens extends StatelessWidget {
  final double size;

  const GlassLens({super.key, this.size = 160});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              width: size,
              height: size,
              color: Colors.white.withOpacity(0.10),
            ),
          ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  offset: const Offset(0, 18),
                  blurRadius: 36,
                ),
              ],
            ),
          ),
          Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: Alignment(-0.3, -0.3),
                radius: 0.9,
                colors: [Colors.white24, Colors.transparent],
              ),
            ),
          ),
          Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.center,
                colors: [Colors.white38, Colors.transparent],
              ),
            ),
          ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
                width: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
