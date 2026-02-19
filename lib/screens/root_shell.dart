import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/red_glass_background.dart';
import 'home_page.dart';
import 'collection_page.dart';
import 'profile_page.dart';

/// Ortak tab shell: alt menü sabit, sayfalar IndexedStack ile korunur.
class RootShell extends StatefulWidget {
  final int initialIndex;

  const RootShell({super.key, this.initialIndex = 0});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  late int _currentIndex = widget.initialIndex.clamp(0, 2);

  late final List<Widget> _tabs = [
    HomePage(showBottomNav: false, onNavTapOverride: _handleNavTap),
    CollectionPage(showBottomNav: false, onNavTapOverride: _handleNavTap),
    ProfilePage(showBottomNav: false, onNavTapOverride: _handleNavTap),
  ];

  void _handleNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeData>(
      valueListenable: AppThemeController.notifier,
      builder: (context, palette, _) {
        return LiquidGlassScope.stack(
          background: const RedGlassBackground(child: SizedBox.expand()),
          content: Scaffold(
            extendBody: true,
            backgroundColor: Colors.transparent,
            body: IndexedStack(index: _currentIndex, children: _tabs),
            bottomNavigationBar: BottomNav(
              currentIndex: _currentIndex,
              onTap: _handleNavTap,
            ),
          ),
        );
      },
    );
  }
}
