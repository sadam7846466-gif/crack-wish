import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';
import '../services/supabase_owl_service.dart';
import '../services/push_notification_service.dart';
import '../services/storage_service.dart';
import '../widgets/cosmic_reward_dialog.dart';
import '../widgets/cosmic_toast.dart';
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
    
    // Büyük ödül modal'larını (Hoşgeldin, Referans vb.) kontrol et
    _checkPendingRewardDialogs();
    
    // Cihazdaki güncel Aura ve Ruh Taşını anında veritabanına yansıt (Senkronize et)
    StorageService.syncEconomyToCloud();
  }

  Future<void> _checkPendingRewardDialogs() async {
    await Future.delayed(const Duration(seconds: 1)); // Sayfa yüklenmesi için bekle
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();

    // 1. Hoş Geldin Bonusu Dialogu
    if (prefs.getBool('needs_welcome_dialog') == true) {
      if (!mounted) return;
      await prefs.remove('needs_welcome_dialog');
      await CosmicRewardDialog.show(
        context: context,
        title: "Evrene Hoş Geldin",
        description: "Yolculuğuna başlaman için sana küçük bir hediye bıraktık.\n\n+3 Ruh Taşı",
        icon: "🎁",
      );
      await Future.delayed(const Duration(milliseconds: 500)); // Dialog kapanmasını bekle
    }

    // 2. Davet ile Gelen Kişiye Verilen Ödül Dialogu
    if (prefs.getBool('needs_referral_receiver_dialog') == true) {
      if (!mounted) return;
      final inviter = prefs.getString('referral_inviter_name') ?? 'Bir arkadaşın';
      await prefs.remove('needs_referral_receiver_dialog');
      await prefs.remove('referral_inviter_name');
      
      await CosmicRewardDialog.show(
        context: context,
        title: "Beklenmedik Bir Hediye",
        description: "$inviter seni buraya davet ettiği için sana bir karşılama hediyesi bıraktı.\n\n+50 Aura\n+2 Ruh Taşı",
        icon: "💌",
        glowColor: const Color(0xFFC36E6E), // Kırmızımsı/pembe
      );
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // 3. Davet Eden Kişiye (Arkadaşı Geldiği İçin) Verilen Ödül Dialogu
    final inviterRewardCount = prefs.getInt('needs_inviter_reward_dialog_count') ?? 0;
    if (inviterRewardCount > 0) {
      if (!mounted) return;
      await prefs.remove('needs_inviter_reward_dialog_count');
      
      final totalAura = inviterRewardCount * 25;
      final totalStones = inviterRewardCount * 2;
      
      await CosmicRewardDialog.show(
        context: context,
        title: "Çağrın Duyuldu!",
        description: "$inviterRewardCount arkadaşın evrene katıldı. Yol gösterici olduğun için ödüllendirildin.\n\n+$totalAura Aura\n+$totalStones Ruh Taşı",
        icon: "🦉",
        glowColor: const Color(0xFF38BDF8), // Mavi
      );
    }
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
      final iconData = achievement['iconData'] as IconData;
      final color = achievement['color'] as Color;
      final imagePath = achievement['imagePath'] as String?;
      
      CosmicToast.show(
        context: context,
        title: achievement['title'] as String,
        message: achievement['desc'] as String,
        reward: rewardText,
        icon: iconData,
        imagePath: imagePath,
        iconColor: color,
        rewardColor: color,
      );
      await Future.delayed(const Duration(seconds: 4));
    }

    // Unvan (Rank) yükselmesi kontrolü
    if (!mounted) return;
    final newRank = await StorageService.checkAndClaimRankUp();
    if (newRank != null && mounted) {
      HapticFeedback.heavyImpact();
      CosmicToast.show(
        context: context,
        title: 'Kozmik Terfi!',
        message: 'Aura gücün arttı. Yeni unvanın: $newRank',
        reward: 'Yeni Rütbe',
        icon: Icons.workspace_premium_rounded,
        iconColor: const Color(0xFFFFD700), // Altın sarısı
        rewardColor: const Color(0xFFFFD700),
      );
      await Future.delayed(const Duration(seconds: 4));
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
