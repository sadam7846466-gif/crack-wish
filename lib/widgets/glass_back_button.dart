import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Tutarlı glassmorphism geri butonu — tüm sayfalarda aynı görünüm + tıklama efekti
class GlassBackButton extends StatefulWidget {
  final VoidCallback? onTap;
  final IconData icon;

  const GlassBackButton({
    super.key,
    this.onTap,
    this.icon = Icons.arrow_back_ios_new_rounded,
  });

  @override
  State<GlassBackButton> createState() => _GlassBackButtonState();
}

class _GlassBackButtonState extends State<GlassBackButton> {
  bool _pressed = false;

  void _handleTap() {
    setState(() => _pressed = true);
    HapticFeedback.lightImpact();
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      setState(() => _pressed = false);
      Future.delayed(const Duration(milliseconds: 60), () {
        if (!mounted) return;
        if (widget.onTap != null) {
          widget.onTap!();
        } else {
          Navigator.pop(context);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: _handleTap,
      child: AnimatedScale(
        scale: _pressed ? 0.82 : 1.0,
        duration: Duration(milliseconds: _pressed ? 80 : 180),
        curve: _pressed ? Curves.easeInCubic : Curves.easeOutBack,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.6 : 1.0,
          duration: Duration(milliseconds: _pressed ? 80 : 180),
          child: ClipOval(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(_pressed ? 0.18 : 0.10),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.18),
                    width: 0.6,
                  ),
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white.withOpacity(0.85),
                  size: 17,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
