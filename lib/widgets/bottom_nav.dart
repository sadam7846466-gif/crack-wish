import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';
import '../constants/colors.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: GlassBottomBar(
        tabs: [
          GlassBottomBarTab(
            label: l10n.navHome,
            icon: Icons.home_rounded,
            glowColor: AppColors.primaryOrange,
          ),
          GlassBottomBarTab(
            label: l10n.navCollection,
            icon: Icons.apps_rounded,
            glowColor: AppColors.primaryOrange,
          ),
          GlassBottomBarTab(
            label: l10n.navProfile,
            icon: Icons.person_rounded,
            glowColor: AppColors.primaryOrange,
          ),
        ],
        selectedIndex: currentIndex,
        onTabSelected: onTap,
        barHeight: 64,
        barBorderRadius: 32,
        horizontalPadding: 16,
        verticalPadding: 8,
        tabPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        selectedIconColor: AppColors.primaryOrange,
        unselectedIconColor: AppColors.textWhite50,
        iconSize: 22,
        glassSettings: const LiquidGlassSettings(
          thickness: 18,
          blur: 2,
          glassColor: AppColors.cardBackground,
          chromaticAberration: 0.15,
          lightIntensity: 0.45,
          ambientStrength: 0.6,
          refractiveIndex: 1.4,
          saturation: 0.8,
        ),
        indicatorSettings: const LiquidGlassSettings(
          thickness: 14,
          blur: 0.6,
          glassColor: AppColors.cardBackgroundAlt,
          chromaticAberration: 0.2,
          lightIntensity: 0.65,
          refractiveIndex: 1.3,
          saturation: 0.9,
        ),
        maskingQuality: MaskingQuality.high,
      ),
    );
  }
}
