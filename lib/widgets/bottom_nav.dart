import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
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

    final tabs = [
      _TabItem(icon: Icons.home_rounded, label: l10n.navHome),
      // _TabItem(icon: Icons.apps_rounded, label: l10n.navCollection), // Koleksiyon geçici olarak gizlendi
      _TabItem(icon: Icons.person_rounded, label: l10n.navProfile),
    ];

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding + 8, left: 24, right: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30), // Daha fazla blur
          child: Container(
            height: 56, // Daha ince 
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05), // Daha transparan
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withOpacity(0.12), // Çok ince ve saydam border
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(tabs.length, (i) {
                final selected = i == currentIndex;
                const activeColor = Color(0xFFC09498);
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onTap(i);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(vertical: 4), // Padding azaltıldı
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center, // Ortalaması için eklendi
                        children: [
                          Icon(
                            tabs[i].icon,
                            size: 20, // İkon biraz küçüldü
                            color: selected
                                ? activeColor
                                : AppColors.textWhite50,
                            // Parlama efekti eklendi
                            shadows: selected
                                ? [Shadow(color: activeColor.withOpacity(0.6), blurRadius: 10)]
                                : null,
                          ),
                          const SizedBox(height: 3), // Aradaki boşluk kısaldı
                          Text(
                            tabs[i].label,
                            style: TextStyle(
                              fontSize: 9, // Font 10'dan 9'a ufaldı
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w500,
                              color: selected
                                  ? activeColor
                                  : AppColors.textWhite50,
                              // Metine de parlama eklendi
                              shadows: selected
                                  ? [Shadow(color: activeColor.withOpacity(0.6), blurRadius: 8)]
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  const _TabItem({required this.icon, required this.label});
}
