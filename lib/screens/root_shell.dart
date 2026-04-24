import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';
import '../services/supabase_owl_service.dart';
import '../services/push_notification_service.dart';
import '../services/storage_service.dart';
import 'home_page.dart';
import 'profile_page.dart';

/// Ortak tab shell: alt menü sabit, sayfalar IndexedStack ile korunur.
class RootShell extends StatefulWidget {
  final int initialIndex;

  const RootShell({super.key, this.initialIndex = 0});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  late int _currentIndex = widget.initialIndex.clamp(0, 1);
  final GlobalKey<ProfilePageState> _profileKey = GlobalKey<ProfilePageState>();

  late final List<Widget> _tabs = [
    HomePage(showBottomNav: false, onNavTapOverride: _handleNavTap),
    ProfilePage(key: _profileKey, showBottomNav: false, onNavTapOverride: _handleNavTap),
  ];

  @override
  void initState() {
    super.initState();
    SupabaseOwlService().initialize();
    PushNotificationService().requestPermissionAndGetToken();
    
    // Başarım kontrolü — yeni kazanılan varsa bildir
    _checkAchievements();
  }

  Future<void> _checkAchievements() async {
    await Future.delayed(const Duration(seconds: 2)); // UI hazır olsun
    if (!mounted) return;
    
    final newAchievements = await StorageService.checkAndClaimAchievements();
    for (final achievement in newAchievements) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      final stones = achievement['stones'] as int;
      final aura = achievement['aura'] as int;
      final rewardText = stones > 0 ? '+$stones Ruh Taşı' : '+$aura Aura';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Text(achievement['icon'] as String, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🏆 ${achievement['title']}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      '${achievement['desc']} — $rewardText',
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1A1A2E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  void _handleNavTap(int index) {
    if (index == _currentIndex) {
      if (index == 1) {
        _profileKey.currentState?.loadUserData();
      }
      return;
    }
    setState(() => _currentIndex = index);
    if (index == 1) {
      _profileKey.currentState?.loadUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeData>(
      valueListenable: AppThemeController.notifier,
      builder: (context, palette, _) {
        return LiquidGlassScope.stack(
          background: Container(
            decoration: BoxDecoration(gradient: palette.bgGradient),
          ),
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
