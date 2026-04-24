import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CosmicRewardDialog extends StatefulWidget {
  final String title;
  final String description;
  final String icon;
  final String buttonText;
  final VoidCallback onClaim;
  final Color glowColor;

  const CosmicRewardDialog({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.buttonText = "Teşekkürler",
    required this.onClaim,
    this.glowColor = const Color(0xFFFFD700),
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String description,
    required String icon,
    String buttonText = "Teşekkürler",
    Color glowColor = const Color(0xFFFFD700),
  }) {
    HapticFeedback.heavyImpact();
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, anim1, anim2) {
        return CosmicRewardDialog(
          title: title,
          description: description,
          icon: icon,
          buttonText: buttonText,
          glowColor: glowColor,
          onClaim: () => Navigator.of(context).pop(),
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
  State<CosmicRewardDialog> createState() => _CosmicRewardDialogState();
}

class _CosmicRewardDialogState extends State<CosmicRewardDialog> with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.15).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05), // Çok daha şeffaf ve pürüzsüz
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.5), // İnce zarif çerçeve
                  boxShadow: [
                    BoxShadow(color: widget.glowColor.withOpacity(0.15), blurRadius: 60, spreadRadius: 10),
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Parlayan İkon Animasyonu
                    AnimatedBuilder(
                      animation: _pulseAnim,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnim.value,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.glowColor.withOpacity(0.1),
                              boxShadow: [
                                BoxShadow(color: widget.glowColor.withOpacity(0.4), blurRadius: 40, spreadRadius: 5),
                              ],
                            ),
                            child: Text(
                              widget.icon,
                              style: const TextStyle(fontSize: 64),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cinzel(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.description,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Claim Butonu
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        widget.onClaim();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [widget.glowColor.withOpacity(0.8), widget.glowColor.withOpacity(0.4)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(color: widget.glowColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Text(
                          widget.buttonText,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
