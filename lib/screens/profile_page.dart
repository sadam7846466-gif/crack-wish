import 'dart:math' as math;
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:provider/provider.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';
import '../constants/colors.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/liquid_glass_card.dart';
import '../widgets/fade_page_route.dart';
import 'home_page.dart';
import 'collection_page.dart';
import '../services/locale_controller.dart';
import 'notification_settings_page.dart';

class ProfilePage extends StatefulWidget {
  final bool showBottomNav;
  final ValueChanged<int>? onNavTapOverride;

  const ProfilePage({
    super.key,
    this.showBottomNav = true,
    this.onNavTapOverride,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static final _mottledPainter = _MottledPainter();
  int _currentNavIndex = 2;

  void _openLanguagePicker() {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.read<LocaleController>();
    final options = <_LanguageOption>[
      _LanguageOption(const Locale('tr'), l10n.turkish),
      _LanguageOption(const Locale('en'), l10n.english),
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        final palette = AppThemeController.current;
        return Container(
          decoration: BoxDecoration(
            color: palette.cardBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.selectLanguage,
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l10n.close,
                            style: const TextStyle(color: AppColors.textWhite),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...options.map(
                    (opt) {
                      final bool isSelected = controller.locale?.languageCode ==
                              opt.locale?.languageCode &&
                          (controller.locale == null) == (opt.locale == null);
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: AppColors.textWhite,
                        ),
                        title: Text(
                          opt.label,
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onTap: () async {
                          await controller.setLocale(opt.locale);
                          if (mounted) Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }



  void _onNavTap(int index) {
    if (widget.onNavTapOverride != null) {
      widget.onNavTapOverride!(index);
      return;
    }
    if (index == 0) {
      Navigator.pushReplacement(context, FadePageRoute(page: const HomePage()));
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        FadePageRoute(page: const CollectionPage()),
      );
    } else {
      setState(() {
        _currentNavIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: ValueListenableBuilder(
        valueListenable: AppThemeController.notifier,
        builder: (context, palette, _) {
          final controller = context.watch<LocaleController>();
          final languageValue = controller.getLabel(
            system: l10n.systemLanguage,
            turkish: l10n.turkish,
            english: l10n.english,
          );
          return Container(
            decoration: BoxDecoration(gradient: palette.bgGradient),
            child: Stack(
              children: [
                // Same mottled overlay as home page
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _mottledPainter,
                    ),
                  ),
                ),
                SafeArea(
                  bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProfileCard(
                      onSettingsTap: () {},
                      onEditTap: () {},
                      cookieCount: 128,
                      owlNetworkCount: 14,
                    ),
                    const SizedBox(height: 24),

                    // — Get Premium Banner
                    GestureDetector(
                      onTap: () {
                        // TODO: Navigate to premium page
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFFD166),
                              Color(0xFFFF9A5C),
                              Color(0xFFFF6B6B),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD166).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Center(
                                child: Text('👑', style: TextStyle(fontSize: 22)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Premium\'a Geç',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Sınırsız kurabiye ve özel özellikler',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white.withOpacity(0.8),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // — General
                    _SectionLabel('Genel'),
                    const SizedBox(height: 12),
                    _ProfileMenuItem(
                      icon: Icons.language_rounded,
                      iconBgColor: const Color(0xFF5A8BFF),
                      title: l10n.language,
                      trailing: l10n.languageValue(languageValue),
                      onTap: _openLanguagePicker,
                    ),
                    const SizedBox(height: 10),
                    _ProfileMenuItem(
                      icon: Icons.notifications_none_rounded,
                      iconBgColor: const Color(0xFFFF6B6B),
                      title: 'Bildirimler',
                      onTap: () {
                        Navigator.push(
                          context,
                          FadePageRoute(page: const NotificationSettingsPage()),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _ProfileMenuItem(
                      icon: Icons.person_outline_rounded,
                      iconBgColor: const Color(0xFF7B61FF),
                      title: 'Profil Ayarları',
                      onTap: () {},
                    ),

                    const SizedBox(height: 28),

                    // — Share & Support
                    _SectionLabel('Paylaş & Destek'),
                    const SizedBox(height: 12),
                    _ProfileMenuItem(
                      icon: Icons.share_rounded,
                      iconBgColor: const Color(0xFF2DD4BF),
                      title: 'Arkadaşlarınla Paylaş',
                      onTap: () {},
                    ),
                    const SizedBox(height: 10),
                    _ProfileMenuItem(
                      icon: Icons.star_border_rounded,
                      iconBgColor: const Color(0xFFFFD166),
                      title: 'Uygulamayı Değerlendir',
                      onTap: () {},
                    ),
                    const SizedBox(height: 10),
                    _ProfileMenuItem(
                      icon: Icons.help_outline_rounded,
                      iconBgColor: const Color(0xFFC084FC),
                      title: 'Yardım Merkezi',
                      onTap: () {},
                    ),

                    const SizedBox(height: 28),

                    // — Log Out
                    _ProfileMenuItem(
                      icon: Icons.logout_rounded,
                      iconBgColor: const Color(0xFFFF4D4D),
                      title: 'Çıkış Yap',
                      isDestructive: true,
                      onTap: () {},
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
              ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: widget.showBottomNav
          ? BottomNav(currentIndex: _currentNavIndex, onTap: _onNavTap)
          : null,
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final VoidCallback onSettingsTap;
  final VoidCallback onEditTap;
  final int cookieCount;
  final int owlNetworkCount;

  const _ProfileCard({
    required this.onSettingsTap,
    required this.onEditTap,
    this.cookieCount = 0,
    this.owlNetworkCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeController.current;
    final l10n = AppLocalizations.of(context)!;
    return GlassCard(
      useOwnLayer: true,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
      shape: const LiquidRoundedSuperellipse(borderRadius: 28),
      settings: const LiquidGlassSettings(
        thickness: 30,
        blur: 8,
        glassColor: Colors.transparent,
        chromaticAberration: 0.15,
        lightIntensity: 0.8,
        ambientStrength: 0.7,
        refractiveIndex: 1.3,
        saturation: 1.1,
      ),
      child: Column(
        children: [
          // Avatar with halo + camera badge
          GestureDetector(
            onTap: onEditTap,
            child: Stack(
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4B8A0), Color(0xFF964040)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.12),
                        blurRadius: 44,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset('assets/images/owl.webp', width: 60, height: 60),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5A8BFF),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onEditTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.profileUserTitle,
                  style: const TextStyle(
                    color: Color(0xFFFFD166),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.edit_rounded, color: Colors.white.withOpacity(0.5), size: 16),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Mistisizmin yolcusu',
            style: TextStyle(
              color: AppColors.textWhite.withOpacity(0.6),
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ProfileStat(value: cookieCount, label: 'Kurabiye 🥠'),
              Container(
                width: 1,
                height: 32,
                color: Colors.white.withOpacity(0.1),
              ),
              _ProfileStat(value: owlNetworkCount, label: 'Baykuş Ağı 🦉'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final int value;
  final String label;

  const _ProfileStat({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: value),
          duration: const Duration(milliseconds: 1800),
          curve: Curves.easeOutCubic,
          builder: (context, val, child) {
            return Text(
              val.toString(),
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textWhite.withOpacity(0.5),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _TagPill extends StatelessWidget {
  final String text;
  final IconData icon;

  const _TagPill({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textWhite),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final double? width;
  final Color? color;

  const _MiniActionButton({
    required this.icon,
    required this.label,
    this.width,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: color ?? Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.textWhite.withOpacity(0.9), size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textWhite.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final String title;
  final String? trailing;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileMenuItem({
    required this.icon,
    required this.iconBgColor,
    required this.title,
    required this.onTap,
    this.trailing,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(icon, color: iconBgColor, size: 20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isDestructive
                      ? const Color(0xFFFF4D4D)
                      : AppColors.textWhite.withOpacity(0.95),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            if (trailing != null) ...[
              Text(
                trailing!,
                style: TextStyle(
                  color: AppColors.textWhite.withOpacity(0.4),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
            ],
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textWhite.withOpacity(0.25),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: AppColors.textWhite.withOpacity(0.4),
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _ActivityEntry extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _ActivityEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeController.current;
    return Container(
      decoration: BoxDecoration(
        color: palette.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
              child: Center(
                child: Icon(icon, color: AppColors.textWhite, size: 18),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textWhite70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textWhite50),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption {
  final Locale? locale;
  final String label;

  const _LanguageOption(this.locale, this.label);
}

class ThemeGalleryPage extends StatelessWidget {
  final List<String> options;
  final String selected;

  const ThemeGalleryPage({
    super.key,
    required this.options,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeController.current;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: palette.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new),
                      color: AppColors.textWhite,
                      onPressed: () => Navigator.pop(context),
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.themeGalleryTitle,
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                  itemCount: options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final opt = options[index];
                    final bool isSelected = opt == selected;
                    return GestureDetector(
                      onTap: () => Navigator.pop(context, opt),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? palette.cardBackgroundAlt
                              : palette.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: AppColors.textWhite,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  opt,
                                  style: TextStyle(
                                    color: AppColors.textWhite,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: AppColors.textWhite70,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MottledPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);

    final allColors = [
      const Color(0xFFD4B8A0),
      const Color(0xFFC8A890),
      const Color(0xFFE0C8B0),
      const Color(0xFF8B3A3A),
      const Color(0xFF7A3030),
      const Color(0xFF964040),
      const Color(0xFFA04848),
      const Color(0xFF6E2828),
      const Color(0xFF883838),
      const Color(0xFF1A3A5C),
      const Color(0xFF2A4A6C),
      const Color(0xFF1E3050),
    ];

    for (int i = 0; i < 26; i++) {
      final color = allColors[rng.nextInt(allColors.length)];
      final opacity = 0.28 + rng.nextDouble() * 0.30;
      final radius = 80.0 + rng.nextDouble() * 170.0;
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;

      final paint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(x, y),
          radius,
          [
            color.withOpacity(opacity),
            color.withOpacity(opacity * 0.75),
            color.withOpacity(opacity * 0.25),
            color.withOpacity(0),
          ],
          [0.0, 0.45, 0.75, 1.0],
        );

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
