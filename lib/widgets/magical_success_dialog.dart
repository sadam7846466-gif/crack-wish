import 'dart:ui';
import 'package:flutter/material.dart';

class MagicalSuccessDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final IconData? fallbackIcon;
  final Color themeColor;

  const MagicalSuccessDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.fallbackIcon,
    required this.themeColor,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String imagePath,
    IconData? fallbackIcon,
    Color themeColor = const Color(0xFFC084FC),
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, anim1, anim2) {
        return MagicalSuccessDialog(
          title: title,
          subtitle: subtitle,
          imagePath: imagePath,
          fallbackIcon: fallbackIcon,
          themeColor: themeColor,
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutBack)),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<MagicalSuccessDialog> createState() => _MagicalSuccessDialogState();
}

class _MagicalSuccessDialogState extends State<MagicalSuccessDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.5, end: 1.5).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              decoration: BoxDecoration(
                color: const Color(0xFF13131A).withOpacity(0.8),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: widget.themeColor.withOpacity(0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(color: widget.themeColor.withOpacity(0.1), blurRadius: 40, spreadRadius: 10),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _glowAnim,
                    builder: (context, child) {
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: widget.themeColor.withOpacity(0.4 * _glowAnim.value), blurRadius: 40 * _glowAnim.value, spreadRadius: 10 * _glowAnim.value),
                          ],
                        ),
                        child: child,
                      );
                    },
                    child: widget.imagePath.isNotEmpty
                        ? Image.asset(widget.imagePath, fit: BoxFit.contain)
                        : Icon(widget.fallbackIcon ?? Icons.diamond_rounded, size: 80, color: widget.themeColor),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, height: 1.5, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [widget.themeColor, widget.themeColor.withOpacity(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: widget.themeColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 4)),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "Muhteşem",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
