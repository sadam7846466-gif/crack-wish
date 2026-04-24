import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/sound_service.dart';

class CosmicRewardDialog extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final String buttonText;
  final VoidCallback onClaim;
  final Color glowColor;
  final int? auraReward;
  final int? stoneReward;

  const CosmicRewardDialog({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.buttonText = "Teşekkürler",
    required this.onClaim,
    this.glowColor = const Color(0xFFFFD700),
    this.auraReward,
    this.stoneReward,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    String buttonText = "Teşekkürler",
    Color glowColor = const Color(0xFFFFD700),
    int? auraReward,
    int? stoneReward,
  }) {
    HapticFeedback.heavyImpact();
    SoundService().playPanelReward(); // Yeni eklenen ses efektini çağır
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'CosmicRewardDismiss',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, anim1, anim2) {
        return CosmicRewardDialog(
          title: title,
          description: description,
          icon: icon,
          buttonText: buttonText,
          glowColor: glowColor,
          auraReward: auraReward,
          stoneReward: stoneReward,
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
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onClaim();
      },
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.5),
                  boxShadow: [
                    BoxShadow(color: widget.glowColor.withOpacity(0.1), blurRadius: 40, spreadRadius: -5),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // İçerik ne kadarsa o kadar yer kapla
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Parlayan İkon Animasyonu
                    AnimatedBuilder(
                      animation: _pulseAnim,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnim.value,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.glowColor.withOpacity(0.1),
                              boxShadow: [
                                BoxShadow(color: widget.glowColor.withOpacity(0.4), blurRadius: 40, spreadRadius: 5),
                              ],
                            ),
                            child: Icon(
                              widget.icon,
                              size: 48,
                              color: widget.glowColor,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cinzel(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.description,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    if (widget.auraReward != null || widget.stoneReward != null) ...[
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.auraReward != null) ...[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset("assets/images/aura_core.png", width: 24, height: 24),
                                const SizedBox(width: 6),
                                Text(
                                  "+${widget.auraReward} Aura",
                                  style: GoogleFonts.nunito(
                                    color: const Color(0xFF818CF8),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (widget.auraReward != null && widget.stoneReward != null) const SizedBox(width: 20),
                          if (widget.stoneReward != null) ...[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.diamond_rounded, color: Color(0xFF4EE6C5), size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  "+${widget.stoneReward} Ruh Taşı",
                                  style: GoogleFonts.nunito(
                                    color: const Color(0xFF4EE6C5),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
