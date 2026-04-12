import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CosmicBadge extends StatelessWidget {
  final int? count;
  final double size;
  final bool hasGlow;

  const CosmicBadge({
    super.key,
    this.count,
    this.size = 18.0,
    this.hasGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    if (count != null && count == 0) {
      return const SizedBox.shrink(); // Sayısal durumda 0 ise gösterme
    }

    // Uygulamanın asil, lüks ve sıcak DNA'sı: Amber/Aura Turuncusu
    const Color badgeColor = AppColors.primaryOrange;

    // Ortak Çerçeve: Parlayan küçük sihirli bir taş (Sessiz lüks amber boncuğu)
    BoxDecoration decoration = BoxDecoration(
      color: badgeColor,
      shape: BoxShape.circle,
      border: Border.all(color: const Color(0xFF16151A), width: 1.5),
      boxShadow: hasGlow
          ? [
              BoxShadow(
                color: badgeColor.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 1,
              )
            ]
          : null,
    );

    // Her zaman sadece küçük sihirli nokta gösterilir
    return Container(
      width: 10,
      height: 10,
      decoration: decoration,
    );
  }
}
