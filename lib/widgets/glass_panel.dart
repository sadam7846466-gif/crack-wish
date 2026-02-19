import 'dart:ui';
import 'package:flutter/material.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.radius = 24,
    this.blur = 22,
    this.opacity = 0.13,
    this.borderOpacity = 0.18,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final double radius;
  final double blur;
  final double opacity;
  final double borderOpacity;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withOpacity(borderOpacity), width: 1),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(opacity + 0.06),
                Colors.white.withOpacity(opacity),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
