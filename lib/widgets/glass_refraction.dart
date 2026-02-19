import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class GlassRefraction extends StatefulWidget {
  final Widget child;
  final double blur;
  final double refraction;
  final double zoom;
  final Color tintColor;
  final double tintOpacity;

  const GlassRefraction({
    super.key,
    required this.child,
    this.blur = 0.3,
    this.refraction = 0.5,
    this.zoom = 1.05,
    this.tintColor = const Color(0xFF1A1A3E),
    this.tintOpacity = 0.3,
  });

  @override
  State<GlassRefraction> createState() => _GlassRefractionState();
}

class _GlassRefractionState extends State<GlassRefraction> {
  ui.FragmentShader? _shader;
  bool _shaderLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadShader();
  }

  Future<void> _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
        'assets/shaders/glass_refraction.frag',
      );
      setState(() {
        _shader = program.fragmentShader();
        _shaderLoaded = true;
      });
    } catch (e) {
      debugPrint('Shader yuklenemedi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_shaderLoaded || _shader == null) {
      return _buildFallback();
    }

    return _buildWithShader();
  }

  Widget _buildWithShader() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          if (!size.width.isFinite || !size.height.isFinite) {
            return _buildFallback();
          }

          final shader = _shader!;
          shader.setFloat(0, size.width);
          shader.setFloat(1, size.height);
          shader.setFloat(2, widget.blur);
          shader.setFloat(3, widget.refraction);
          shader.setFloat(4, widget.zoom);

          return BackdropFilter(
            filter: ui.ImageFilter.shader(shader),
            child: Container(
              decoration: BoxDecoration(
                color: widget.tintColor.withOpacity(widget.tintOpacity),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 1,
                ),
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }

  Widget _buildFallback() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: widget.blur * 20,
          sigmaY: widget.blur * 20,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: widget.tintColor.withOpacity(widget.tintOpacity),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// CustomPaint yerine BackdropFilter ile shader kullaniliyor.
