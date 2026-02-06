import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Mystical Modal for monetization - "Sunk Cost" strategy
class MysticalModal extends StatefulWidget {
  final VoidCallback onWatchAd;
  final VoidCallback onClose;
  final int freeReadingsRemaining;

  const MysticalModal({
    super.key,
    required this.onWatchAd,
    required this.onClose,
    this.freeReadingsRemaining = 0,
  });

  @override
  State<MysticalModal> createState() => _MysticalModalState();

  /// Show the modal as an overlay
  static Future<bool?> show(BuildContext context, {int freeReadings = 0}) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return MysticalModal(
          freeReadingsRemaining: freeReadings,
          onWatchAd: () {
            Navigator.of(context).pop(true);
          },
          onClose: () {
            Navigator.of(context).pop(false);
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
  }
}

class _MysticalModalState extends State<MysticalModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Blur background
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                color: const Color(0xFF0F1123).withOpacity(0.7),
              ),
            ),
          ),

          // Modal content
          Center(
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1A0A2E).withOpacity(0.95),
                        const Color(0xFF0F1123).withOpacity(0.98),
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFFD4AF37)
                          .withOpacity(_glowAnimation.value),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37)
                            .withOpacity(_glowAnimation.value * 0.4),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Close button
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: widget.onClose,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Color(0xFFA89880),
                              size: 20,
                            ),
                          ),
                        ),
                      ),

                      // Crystal ball icon
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFD4AF37).withOpacity(0.3),
                              const Color(0xFFD4AF37).withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFFD4AF37),
                          size: 48,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Title
                      Text(
                        AppLocalizations.of(context)!.tarotEnergyDepletedTitle,
                        style: GoogleFonts.unifrakturMaguntia(
                          color: const Color(0xFFD4AF37),
                          fontSize: 28,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Description
                      Text(
                        AppLocalizations.of(context)!.tarotEnergyDepletedBody,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cormorantGaramond(
                          color: const Color(0xFFE8D5B5),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Sub-description
                      Text(
                        AppLocalizations.of(context)!.tarotEnergyDepletedSub,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cormorantGaramond(
                          color: const Color(0xFFA89880),
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Watch Ad Button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          widget.onWatchAd();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFD4AF37),
                                Color(0xFFB8860B),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4AF37).withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.play_circle_fill,
                                color: Color(0xFF0F1123),
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                AppLocalizations.of(context)!.tarotWatchAd,
                                style: GoogleFonts.cormorantGaramond(
                                  color: const Color(0xFF0F1123),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Free readings info
                      Text(
                        AppLocalizations.of(context)!.tarotFreeRemaining(
                          widget.freeReadingsRemaining,
                        ),
                        style: GoogleFonts.cormorantGaramond(
                          color: const Color(0xFFA89880),
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Premium upsell hint
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.workspace_premium,
                              color: const Color(0xFFD4AF37).withOpacity(0.7),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Premium ile sınırsız okuma',
                              style: GoogleFonts.cormorantGaramond(
                                color: const Color(0xFFD4AF37).withOpacity(0.8),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
