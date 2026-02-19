import 'dart:ui';
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
      _TabItem(icon: Icons.apps_rounded, label: l10n.navCollection),
      _TabItem(icon: Icons.person_rounded, label: l10n.navProfile),
    ];

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding + 8, left: 16, right: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(tabs.length, (i) {
                final selected = i == currentIndex;
                // Her tab kendi rengini alıyor: Bej, Kırmızı, Mavi
                const tabColors = [
                  Color(0xFFE8CBB0), // Home — parlak bej
                  Color(0xFFD06058), // Collection — parlak kırmızı
                  Color(0xFF5C8AB8), // Profile — parlak mavi
                ];
                final activeColor = tabColors[i];
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            tabs[i].icon,
                            size: 22,
                            color: selected
                                ? activeColor
                                : AppColors.textWhite50,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tabs[i].label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w500,
                              color: selected
                                  ? activeColor
                                  : AppColors.textWhite50,
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
