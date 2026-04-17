// lib/widgets/feature_header_actions.dart
// Sayfalar arası ortak rehber + kredi butonları

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Tıklama efektli buton (scale animasyonu + haptic)
class TapScaleButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  const TapScaleButton({super.key, required this.onTap, required this.child});

  @override
  State<TapScaleButton> createState() => _TapScaleButtonState();
}

class _TapScaleButtonState extends State<TapScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _ctrl.forward();
      },
      onTapUp: (_) async {
        await Future.delayed(const Duration(milliseconds: 60));
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) {
          final scale = 1.0 - (_ctrl.value * 0.15);
          return Transform.scale(scale: scale, child: child);
        },
        child: widget.child,
      ),
    );
  }
}

/// Her sayfanın sağ üst köşesindeki rehber + kredi butonları
class FeatureHeaderActions extends StatelessWidget {
  final bool isTr;
  final int creditCount;
  final bool hasCredit;
  final VoidCallback onGuideTap;
  final VoidCallback onCreditTap;

  const FeatureHeaderActions({
    super.key,
    required this.isTr,
    required this.creditCount,
    required this.hasCredit,
    required this.onGuideTap,
    required this.onCreditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Rehber butonu
          TapScaleButton(
            onTap: onGuideTap,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.10),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.18),
                        width: 0.6,
                      ),
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white.withOpacity(0.85),
                      size: 17,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Kredi göstergesi
          TapScaleButton(
            onTap: onCreditTap,
            child: ClipOval(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.18),
                      width: 0.6,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 11,
                        color: hasCredit
                            ? Colors.white.withOpacity(0.85)
                            : Colors.white.withOpacity(0.25),
                      ),
                      const SizedBox(width: 1),
                      Text(
                        '$creditCount',
                        style: TextStyle(
                          color: hasCredit
                              ? Colors.white.withOpacity(0.85)
                              : Colors.white.withOpacity(0.3),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
    );
  }
}

/// Kredi bilgi paneli — glass efektli dialog
void showCreditInfoDialog({
  required BuildContext context,
  required bool isTr,
  required int creditCount,
  required bool hasCredit,
  required bool dailyFreeUsed,
  required String featureNameTr,
  required String featureNameEn,
  required VoidCallback onWatchAd,
  required VoidCallback onGoPremium,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'CreditInfo',
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (ctx, anim1, anim2) {
      return GestureDetector(
        onTap: () => Navigator.pop(ctx),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            color: Colors.black.withOpacity(0.4),
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: () {}, // prevent dismiss on card tap
                  child: SizedBox(
                    width: MediaQuery.of(ctx).size.width * 0.85,
                    child: GlassCard(
                      useOwnLayer: true,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      shape: const LiquidRoundedSuperellipse(borderRadius: 24),
                      settings: const LiquidGlassSettings(
                        thickness: 24,
                        blur: 15,
                        glassColor: Color(0x1A1E1845),
                        chromaticAberration: 0.12,
                        lightIntensity: 1.0,
                        ambientStrength: 0.8,
                        refractiveIndex: 1.3,
                        saturation: 1.1,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icon
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFE2C48E).withOpacity(0.25),
                                  const Color(0xFF9C6BFF).withOpacity(0.15),
                                ],
                              ),
                              border: Border.all(
                                color: const Color(0xFFE7D6A5).withOpacity(0.3),
                                width: 0.5,
                              ),
                            ),
                            child: Icon(
                              Icons.auto_awesome,
                              color: hasCredit
                                  ? const Color(0xFFE2C48E)
                                  : Colors.white.withOpacity(0.4),
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Title
                          Text(
                            isTr ? 'Okuma Hakların' : 'Your Reading Credits',
                            style: GoogleFonts.cinzel(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Credit count
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                color: hasCredit
                                    ? const Color(0xFFE2C48E)
                                    : Colors.white.withOpacity(0.3),
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isTr
                                    ? '$creditCount ${isTr ? featureNameTr : featureNameEn} hakkın var'
                                    : '$creditCount ${featureNameEn} credits remaining',
                                style: TextStyle(
                                  color: hasCredit
                                      ? const Color(0xFFE2C48E).withOpacity(0.9)
                                      : Colors.white.withOpacity(0.4),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Info items
                          _CreditInfoRow(
                            icon: Icons.wb_sunny_outlined,
                            text: isTr
                                ? 'Her gün 1 ücretsiz hak'
                                : '1 free credit every day',
                            isActive: !dailyFreeUsed,
                          ),
                          const SizedBox(height: 12),
                          _CreditInfoRow(
                            icon: Icons.play_circle_outline,
                            text: isTr
                                ? 'Reklam izleyerek +1 hak kazan'
                                : 'Watch ad to earn +1 credit',
                            isActive: true,
                          ),
                          const SizedBox(height: 12),
                          _CreditInfoRow(
                            icon: Icons.refresh_rounded,
                            text: isTr
                                ? 'Haklar her gece sıfırlanır'
                                : 'Credits reset every midnight',
                            isActive: false,
                          ),
                          const SizedBox(height: 24),
                          // Action buttons
                          Row(
                            children: [
                              // Reklam İzle
                              Expanded(
                                child: TapScaleButton(
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    onWatchAd();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.white.withOpacity(0.08),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.15),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.play_circle_filled_rounded,
                                          color: Colors.white.withOpacity(0.7),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          isTr ? 'Reklam İzle' : 'Watch Ad',
                                          style: GoogleFonts.inter(
                                            color: Colors.white.withOpacity(0.75),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Premium
                              Expanded(
                                child: TapScaleButton(
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    onGoPremium();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFD4A54A),
                                          Color(0xFFE8C97A),
                                          Color(0xFFD4A54A),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFD4A54A).withOpacity(0.3),
                                          blurRadius: 12,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.workspace_premium_rounded,
                                          color: Color(0xFF2A1810),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          isTr ? "Elite'e Geç" : 'Go Elite',
                                          style: GoogleFonts.inter(
                                            color: const Color(0xFF2A1810),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (ctx, a1, a2, child) {
      return FadeTransition(
        opacity: a1,
        child: ScaleTransition(
          scale: CurvedAnimation(parent: a1, curve: Curves.easeOutBack),
          child: child,
        ),
      );
    },
  );
}

/// Rehber diyaloğu — glass efektli
void showGuideDialog({
  required BuildContext context,
  required bool isTr,
  required String titleTr,
  required String titleEn,
  required List<GuideItem> items,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'GuideDialog',
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (ctx, anim1, anim2) {
      return GestureDetector(
        onTap: () => Navigator.pop(ctx),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            color: Colors.black.withOpacity(0.4),
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: () {},
                  child: SizedBox(
                    width: MediaQuery.of(ctx).size.width * 0.85,
                    child: GlassCard(
                      useOwnLayer: true,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: const LiquidRoundedSuperellipse(borderRadius: 24),
                      settings: const LiquidGlassSettings(
                        thickness: 24,
                        blur: 15,
                        glassColor: Color(0x1A1E1845),
                        chromaticAberration: 0.12,
                        lightIntensity: 1.0,
                        ambientStrength: 0.8,
                        refractiveIndex: 1.3,
                        saturation: 1.1,
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              color: Color(0xFFE7D6A5),
                              size: 24,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              isTr ? titleTr : titleEn,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cinzel(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...items.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFFE7D6A5).withOpacity(0.12),
                                    ),
                                    child: Icon(
                                      item.icon,
                                      size: 14,
                                      color: const Color(0xFFE7D6A5).withOpacity(0.8),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isTr ? item.titleTr : item.titleEn,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.85),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          isTr ? item.descTr : item.descEn,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.55),
                                            fontSize: 12,
                                            height: 1.35,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (ctx, a1, a2, child) {
      return FadeTransition(
        opacity: a1,
        child: ScaleTransition(
          scale: CurvedAnimation(parent: a1, curve: Curves.easeOutBack),
          child: child,
        ),
      );
    },
  );
}

class GuideItem {
  final IconData icon;
  final String titleTr;
  final String titleEn;
  final String descTr;
  final String descEn;

  const GuideItem({
    required this.icon,
    required this.titleTr,
    required this.titleEn,
    required this.descTr,
    required this.descEn,
  });
}

class _CreditInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isActive;

  const _CreditInfoRow({
    required this.icon,
    required this.text,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? const Color(0xFFE2C48E).withOpacity(0.12)
                : Colors.white.withOpacity(0.05),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isActive
                ? const Color(0xFFE2C48E).withOpacity(0.8)
                : Colors.white.withOpacity(0.3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isActive
                  ? Colors.white.withOpacity(0.75)
                  : Colors.white.withOpacity(0.4),
              fontSize: 13,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
