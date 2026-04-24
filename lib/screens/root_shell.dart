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

  // ═══════════════════════════════════════════════════════════════
  // ÖZEL GÜN / BAYRAM TAKVİMİ (Her yıl güncellenir)
  // ═══════════════════════════════════════════════════════════════
  // locale: 'all' = herkes, 'TR' = Türkiye, 'US' = ABD, 'DE' = Almanya vb.
  // Birden fazla ülke: 'US,CA' gibi virgülle ayrılır
  static final List<Map<String, dynamic>> _specialDays = [
    // ── EVRENSEL ──
    {'month': 1, 'day': 1, 'title': 'Yeni Yılın Kutlu Olsun!', 'title_en': 'Happy New Year!', 'desc': 'Yeni bir yıl, yeni bir başlangıç.', 'desc_en': 'A new year, a new beginning. The universe whispers beautiful things.', 'icon': Icons.celebration_rounded, 'color': Color(0xFFFFD700), 'locale': 'all'},
    {'month': 2, 'day': 14, 'title': 'Sevgililer Günün Kutlu Olsun', 'title_en': 'Happy Valentine\'s Day', 'desc': 'Aşk enerjisi bugün her yerde.', 'desc_en': 'Love energy is everywhere today.', 'icon': Icons.favorite_rounded, 'color': Color(0xFFFF6B9D), 'locale': 'all'},
    {'month': 3, 'day': 8, 'title': 'Dünya Kadınlar Günü', 'title_en': 'International Women\'s Day', 'desc': 'Güçlü, zarif ve kozmik.', 'desc_en': 'Strong, elegant and cosmic. Today is your day.', 'icon': Icons.spa_rounded, 'color': Color(0xFFC084FC), 'locale': 'all'},
    {'month': 10, 'day': 31, 'title': 'Cadılar Bayramı', 'title_en': 'Halloween', 'desc': 'Bugün perdenin ötesi biraz daha yakın!', 'desc_en': 'The veil is thin today!', 'icon': Icons.nightlight_round, 'color': Color(0xFFFF8C00), 'locale': 'all'},
    {'month': 12, 'day': 25, 'title': 'Kış Gündönümü', 'title_en': 'Winter Solstice', 'desc': 'Işık geri dönüyor, yeni bir döngü başlıyor.', 'desc_en': 'After the longest night, light returns.', 'icon': Icons.ac_unit_rounded, 'color': Color(0xFF60A5FA), 'locale': 'all'},
    {'month': 12, 'day': 31, 'title': 'Yılbaşı Gecesi', 'title_en': 'New Year\'s Eve', 'desc': 'Bu yıl seninle güzeldi.', 'desc_en': 'May your cosmic journey continue.', 'icon': Icons.auto_awesome_rounded, 'color': Color(0xFFFFD700), 'locale': 'all'},
    // ── TÜRKİYE (TR) ──
    {'month': 4, 'day': 23, 'title': '23 Nisan Kutlu Olsun!', 'desc': 'Ulusal Egemenlik ve Çocuk Bayramı kutlu olsun.', 'icon': Icons.flag_rounded, 'color': Color(0xFFEF4444), 'locale': 'TR'},
    {'month': 5, 'day': 19, 'title': '19 Mayıs Kutlu Olsun!', 'desc': 'Gençlik ve Spor Bayramı. Gençliğin enerjisi seninle.', 'icon': Icons.sports_soccer_rounded, 'color': Color(0xFFEF4444), 'locale': 'TR'},
    {'month': 8, 'day': 30, 'title': '30 Ağustos Zafer Bayramı', 'desc': 'Zafer, inananlarındır.', 'icon': Icons.military_tech_rounded, 'color': Color(0xFFEF4444), 'locale': 'TR'},
    {'month': 10, 'day': 29, 'title': 'Cumhuriyet Bayramı Kutlu Olsun!', 'desc': 'En büyük bayram.', 'icon': Icons.flag_rounded, 'color': Color(0xFFEF4444), 'locale': 'TR'},
    // ── AMERİKA (US) ──
    {'month': 7, 'day': 4, 'title_en': 'Happy Independence Day', 'desc_en': 'Celebrate freedom and the cosmic spark of liberty.', 'icon': Icons.flag_rounded, 'color': Color(0xFF3B82F6), 'locale': 'US'},
    {'month': 11, 'day': 27, 'title_en': 'Happy Thanksgiving', 'desc_en': 'A day to be grateful. The universe appreciates your gratitude.', 'icon': Icons.restaurant_rounded, 'color': Color(0xFFF59E0B), 'locale': 'US,CA'},
    // ── ALMANYA (DE) ──
    {'month': 10, 'day': 3, 'title_en': 'Happy German Unity Day', 'desc_en': 'Celebrating unity and togetherness.', 'icon': Icons.handshake_rounded, 'color': Color(0xFFFBBF24), 'locale': 'DE'},
    // ── FRANSA (FR) ──
    {'month': 7, 'day': 14, 'title_en': 'Joyeux 14 Juillet', 'desc_en': 'Bastille Day — celebrating freedom.', 'icon': Icons.flag_rounded, 'color': Color(0xFF3B82F6), 'locale': 'FR'},
    // ── İSPANYA (ES) ──
    {'month': 10, 'day': 12, 'title_en': 'Feliz Dia de la Hispanidad', 'desc_en': 'Celebrating culture and heritage.', 'icon': Icons.public_rounded, 'color': Color(0xFFEF4444), 'locale': 'ES'},
    // ── BREZİLYA (BR) ──
    {'month': 9, 'day': 7, 'title_en': 'Feliz Dia da Independencia', 'desc_en': 'Celebrating independence.', 'icon': Icons.flag_rounded, 'color': Color(0xFF22C55E), 'locale': 'BR'},
    // ── MEKSİKA (MX) ──
    {'month': 9, 'day': 16, 'title_en': 'Feliz Dia de la Independencia', 'desc_en': 'Celebrating independence.', 'icon': Icons.flag_rounded, 'color': Color(0xFF22C55E), 'locale': 'MX'},
    {'month': 11, 'day': 1, 'title_en': 'Dia de los Muertos', 'desc_en': 'Honor those who passed. The veil is thinnest today.', 'icon': Icons.local_florist_rounded, 'color': Color(0xFFF97316), 'locale': 'MX'},
    // ── HİNDİSTAN (IN) ──
    {'month': 1, 'day': 26, 'title_en': 'Happy Republic Day', 'desc_en': 'Celebrating the spirit of the Constitution.', 'icon': Icons.flag_rounded, 'color': Color(0xFFF97316), 'locale': 'IN'},
    {'month': 8, 'day': 15, 'title_en': 'Happy Independence Day', 'desc_en': 'Celebrating cosmic freedom.', 'icon': Icons.flag_rounded, 'color': Color(0xFF22C55E), 'locale': 'IN'},
    // ── JAPONYA (JP) ──
    {'month': 11, 'day': 3, 'title_en': 'Happy Culture Day', 'desc_en': 'Celebrating culture, art, and achievement.', 'icon': Icons.palette_rounded, 'color': Color(0xFFC084FC), 'locale': 'JP'},
    // ── İNGİLTERE (GB) ──
    {'month': 11, 'day': 5, 'title_en': 'Guy Fawkes Night', 'desc_en': 'The cosmic fire burns bright tonight.', 'icon': Icons.local_fire_department_rounded, 'color': Color(0xFFF97316), 'locale': 'GB'},
    // ── 2026 DİNİ BAYRAMLAR ──
    // Ramazan 2026: 20-22 Mart
    {'month': 3, 'day': 20, 'title': 'Ramazan Bayramınız Kutlu Olsun', 'title_en': 'Happy Eid al-Fitr', 'desc': 'Evren sana huzur diliyor.', 'desc_en': 'The universe wishes you peace on this blessed Eid.', 'icon': Icons.mosque_rounded, 'color': Color(0xFF10B981), 'locale': 'all'},
    {'month': 3, 'day': 21, 'title': 'Ramazan Bayramı 2. Gün', 'title_en': 'Eid al-Fitr Day 2', 'desc': 'Huzur seninle olsun.', 'desc_en': 'May blessings be with you.', 'icon': Icons.mosque_rounded, 'color': Color(0xFF10B981), 'locale': 'all'},
    {'month': 3, 'day': 22, 'title': 'Ramazan Bayramı 3. Gün', 'title_en': 'Eid al-Fitr Day 3', 'desc': 'Güzel anılar biriktir.', 'desc_en': 'Create beautiful memories.', 'icon': Icons.mosque_rounded, 'color': Color(0xFF10B981), 'locale': 'all'},
    // Kurban 2026: 27-30 Mayıs
    {'month': 5, 'day': 27, 'title': 'Kurban Bayramınız Kutlu Olsun', 'title_en': 'Happy Eid al-Adha', 'desc': 'Bayramınız mübarek olsun.', 'desc_en': 'May your Eid be blessed.', 'icon': Icons.mosque_rounded, 'color': Color(0xFF10B981), 'locale': 'all'},
    {'month': 5, 'day': 28, 'title': 'Kurban Bayramı 2. Gün', 'title_en': 'Eid al-Adha Day 2', 'desc': 'Bereket seninle olsun.', 'desc_en': 'Another day of blessings.', 'icon': Icons.mosque_rounded, 'color': Color(0xFF10B981), 'locale': 'all'},
    {'month': 5, 'day': 29, 'title': 'Kurban Bayramı 3. Gün', 'title_en': 'Eid al-Adha Day 3', 'desc': 'Kalpler birlikte atsın.', 'desc_en': 'May hearts beat together.', 'icon': Icons.mosque_rounded, 'color': Color(0xFF10B981), 'locale': 'all'},
    {'month': 5, 'day': 30, 'title': 'Kurban Bayramı 4. Gün', 'title_en': 'Eid al-Adha Day 4', 'desc': 'Evrene şükranlarını sun.', 'desc_en': 'Offer your gratitude.', 'icon': Icons.mosque_rounded, 'color': Color(0xFF10B981), 'locale': 'all'},
  ];

  @override
  void initState() {
    super.initState();
    SupabaseOwlService().initialize();
    PushNotificationService().requestPermissionAndGetToken();
    
    // Başarım kontrolü — yeni kazanılan varsa bildir
    _checkAchievements();
    
    // Büyük ödül modal'larını (Hoşgeldin, Doğum günü, Bayram, Referans vb.) kontrol et
    _checkPendingRewardDialogs();
    
    // Kurabiye hatırlatıcı (öğleden sonra)
    _checkCookieReminder();
    
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
        description: "Yolculuğuna başlaman için sana küçük bir hediye bıraktık.",
        icon: Icons.card_giftcard,
        stoneReward: 3,
      );
      await Future.delayed(const Duration(milliseconds: 500));
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
        description: "$inviter seni buraya davet ettiği için sana bir karşılama hediyesi bıraktı.",
        icon: Icons.mail_outline,
        glowColor: const Color(0xFFC36E6E),
        auraReward: 50,
        stoneReward: 2,
      );
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // 3. Davet Eden Kişiye (Arkadaşı Geldiği İçin) Verilen Ödül Dialogu
    final inviterRewardCount = prefs.getInt('needs_inviter_reward_dialog_count') ?? 0;
    if (inviterRewardCount > 0) {
      if (!mounted) return;
      final newNames = prefs.getStringList('needs_inviter_reward_dialog_names') ?? [];
      
      await prefs.remove('needs_inviter_reward_dialog_count');
      await prefs.remove('needs_inviter_reward_dialog_names');
      
      final totalAura = inviterRewardCount * 25;
      final totalStones = inviterRewardCount * 2;
      
      String descText;
      if (newNames.isNotEmpty) {
        if (inviterRewardCount == 1) {
          descText = "${newNames.first} evrene katıldı. Yol gösterici olduğun için ödüllendirildin.";
        } else {
          descText = "${newNames.first} ve ${inviterRewardCount - 1} arkadaşın daha evrene katıldı. Yol gösterici olduğun için ödüllendirildin.";
        }
      } else {
        descText = "$inviterRewardCount arkadaşın evrene katıldı. Yol gösterici olduğun için ödüllendirildin.";
      }
      
      await CosmicRewardDialog.show(
        context: context,
        title: "Çağrın Duyuldu!",
        description: descText,
        icon: Icons.person_add_alt_1,
        glowColor: const Color(0xFF38BDF8),
        auraReward: totalAura,
        stoneReward: totalStones,
      );
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // ═══════════════════════════════════════════════════════════════
    // 4. 🎂 DOĞUM GÜNÜ KUTLAMASI (Yılda 1 kez + hile önleme)
    //    - birthday_celebrated_YYYY: Bu yıl kutlandı mı?
    //    - birthday_dob_used_YYYY: Hangi DOB ile ödül alındı?
    //    → DOB değiştirilse bile aynı yılda tekrar ödül alınamaz.
    // ═══════════════════════════════════════════════════════════════
    if (!mounted) return;
    final dobString = prefs.getString('date_of_birth');
    if (dobString != null) {
      try {
        final dob = DateTime.parse(dobString);
        final now = DateTime.now();
        if (dob.month == now.month && dob.day == now.day) {
          final birthdayKey = 'birthday_celebrated_${now.year}';
          if (!(prefs.getBool(birthdayKey) ?? false)) {
            // Ödülü ver ve hangi DOB için verildiğini kaydet
            await StorageService.updateSoulStones(2);
            await StorageService.addBonusAura(30);
            await prefs.setBool(birthdayKey, true);
            await prefs.setString('birthday_dob_used_${now.year}', '${dob.month}-${dob.day}');

            if (!mounted) return;
            final userName = await StorageService.getUserName();
            final displayName = (userName != null && userName.isNotEmpty) ? userName : null;
            await CosmicRewardDialog.show(
              context: context,
              title: displayName != null
                  ? "$displayName, Doğum Günün Kutlu Olsun!"
                  : "Doğum Günün Kutlu Olsun!",
              description: "Bugün ruhunun bu dünyaya indiği kutsal gün. Evren sana özel bir hediye bıraktı.",
              icon: Icons.cake_rounded,
              glowColor: const Color(0xFFFF6B9D),
              auraReward: 30,
              stoneReward: 2,
            );
            await Future.delayed(const Duration(milliseconds: 500));
          }
        }
      } catch (_) {}
    }

    // ═══════════════════════════════════════════════════════════════
    // 5. 🎉 ÖZEL GÜN / BAYRAM KUTLAMASI (Sadece kutlama, ödül yok)
    // ═══════════════════════════════════════════════════════════════
    if (!mounted) return;
    final now = DateTime.now();
    final locale = Localizations.localeOf(context);
    final lang = locale.languageCode;
    // Ülke kodu: önce countryCode, yoksa dil kodundan tahmin (tr→TR, en→US)
    final country = locale.countryCode?.toUpperCase() ?? lang.toUpperCase();
    for (final day in _specialDays) {
      if (day['month'] == now.month && day['day'] == now.day) {
        // Ülke filtresi: 'all' herkes, 'TR' sadece Türkiye, 'US,CA' ABD+Kanada
        final dayLocale = day['locale'] as String? ?? 'all';
        if (dayLocale != 'all') {
          final allowedCountries = dayLocale.split(',').map((c) => c.trim()).toList();
          if (!allowedCountries.contains(country)) continue;
        }

        final specialKey = 'special_day_${now.year}_${now.month}_${now.day}';
        if (!(prefs.getBool(specialKey) ?? false)) {
          await prefs.setBool(specialKey, true);

          // Dile göre başlık ve açıklama seç
          final title = (lang != 'tr' && day.containsKey('title_en'))
              ? day['title_en'] as String
              : (day['title'] ?? day['title_en']) as String;
          final desc = (lang != 'tr' && day.containsKey('desc_en'))
              ? day['desc_en'] as String
              : (day['desc'] ?? day['desc_en']) as String;

          if (!mounted) return;
          await CosmicRewardDialog.show(
            context: context,
            title: title,
            description: desc,
            icon: day['icon'] as IconData,
            glowColor: day['color'] as Color,
          );
          await Future.delayed(const Duration(milliseconds: 500));
          break; // Aynı gün birden fazla bayram olsa bile 1 tane göster
        }
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🍪 KURABİYE HATIRLATICI (Saat 14:00'dan sonra kırılmadıysa)
  // ═══════════════════════════════════════════════════════════════
  Future<void> _checkCookieReminder() async {
    await Future.delayed(const Duration(seconds: 5)); // Diğer panellerden sonra göster
    if (!mounted) return;

    final now = DateTime.now();
    if (now.hour < 14) return; // Sabah çok erken rahatsız etme

    final prefs = await SharedPreferences.getInstance();
    final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    // Bugün hatırlatıcı gösterildi mi?
    final reminderKey = 'cookie_reminder_$todayKey';
    if (prefs.getBool(reminderKey) ?? false) return;
    
    // Bugün kurabiye kırıldı mı?
    final cracksToday = await StorageService.getCookieCracksToday();
    if (cracksToday > 0) return; // Zaten kırmış, rahatsız etme

    await prefs.setBool(reminderKey, true);
    if (!mounted) return;
    
    HapticFeedback.lightImpact();
    CosmicToast.show(
      context: context,
      title: 'Bugün Kurabiye Kırmadın',
      message: 'Günlük şans mesajın seni bekliyor!',
      reward: '3 Hak',
      icon: Icons.cookie_rounded,
      iconColor: const Color(0xFFFBBF24),
      rewardColor: const Color(0xFFFBBF24),
    );
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
    final rankResult = await StorageService.checkAndClaimRankUp();
    if (rankResult != null && mounted) {
      HapticFeedback.heavyImpact();

      final newRank = rankResult['title'] as String;
      final auraReward = rankResult['auraReward'] as int;

      // Her unvana özel ikon ve renk (Material ikonlar = %100 arka plansız)
      IconData rankIcon;
      Color rankColor;
      switch (newRank) {
        case 'Acemi Kahin':
          rankIcon = Icons.eco_rounded;
          rankColor = const Color(0xFF81C784);
          break;
        case 'Çırak Kahin':
          rankIcon = Icons.star_rounded;
          rankColor = const Color(0xFF64B5F6);
          break;
        case 'Kahin':
          rankIcon = Icons.visibility_rounded;
          rankColor = const Color(0xFFBA68C8);
          break;
        case 'Bilge Kahin':
          rankIcon = Icons.auto_stories_rounded;
          rankColor = const Color(0xFFFFB74D);
          break;
        case 'Usta Kahin':
          rankIcon = Icons.shield_rounded;
          rankColor = const Color(0xFFE57373);
          break;
        case 'Kozmik Kahin':
          rankIcon = Icons.diamond_rounded;
          rankColor = const Color(0xFFFFD700);
          break;
        default:
          rankIcon = Icons.workspace_premium_rounded;
          rankColor = const Color(0xFFFFD700);
      }

      CosmicToast.show(
        context: context,
        title: 'Kozmik Terfi!',
        message: 'Aura gücün arttı. Yeni unvanın: $newRank',
        reward: '+$auraReward Aura',
        icon: rankIcon,
        iconColor: rankColor,
        rewardColor: rankColor,
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
