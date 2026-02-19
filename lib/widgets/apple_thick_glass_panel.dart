import 'dart:ui';
import 'package:flutter/material.dart';

class AppleThickGlassPanel extends StatefulWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final double refractionStrength;
  final double chromaticAberration;

  const AppleThickGlassPanel({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(26)),
    this.padding = const EdgeInsets.all(16),
    this.refractionStrength = 10,
    this.chromaticAberration = 0.35,
  });

  @override
  State<AppleThickGlassPanel> createState() => _AppleThickGlassPanelState();
}

class _AppleThickGlassPanelState extends State<AppleThickGlassPanel> {
  late final Future<FragmentProgram> _program = FragmentProgram.fromAsset(
    'assets/shaders/glass_refraction.frag',
  );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: Stack(
        children: [
          FutureBuilder<FragmentProgram>(
            future: _program,
            builder: (context, snapshot) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  if (!snapshot.hasData ||
                      !size.width.isFinite ||
                      !size.height.isFinite) {
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935).withOpacity(0.03),
                        borderRadius: widget.borderRadius,
                      ),
                    );
                  }

                  final shader = snapshot.data!.fragmentShader();
                  shader.setFloat(0, size.width);
                  shader.setFloat(1, size.height);
                  shader.setFloat(2, widget.refractionStrength);
                  shader.setFloat(3, widget.chromaticAberration);

                  return BackdropFilter(
                    filter: ImageFilter.shader(shader),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935).withOpacity(0.03),
                        borderRadius: widget.borderRadius,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.16),
                  offset: const Offset(0, 12),
                  blurRadius: 22,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  offset: const Offset(0, 4),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.14),
                  const Color(0xFFE53935).withOpacity(0.06),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.30, 1.0],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              border: Border.all(
                color: Colors.white.withOpacity(0.22),
                width: 1.4,
              ),
            ),
          ),
          Padding(padding: widget.padding, child: widget.child),
        ],
      ),
    );
  }
}
