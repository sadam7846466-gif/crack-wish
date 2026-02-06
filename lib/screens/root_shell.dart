import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
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
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: _handleNavTap,
      ),
    );
  }
}
