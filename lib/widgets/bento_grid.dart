import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';
import '../constants/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/tarot_page.dart';
import '../screens/dream_page.dart';
import '../screens/zodiac_hub_page.dart';
import '../screens/coffee_page.dart';
import '../widgets/fade_page_route.dart';
import '../widgets/windy_nazar.dart';

class BentoGrid extends StatefulWidget {
  const BentoGrid({super.key});

  @override
  State<BentoGrid> createState() => _BentoGridState();
}

class _BentoGridState extends State<BentoGrid>
    with SingleTickerProviderStateMixin, RouteAware {
  late final AnimationController _tarotFloatController;
  bool _hasUnreadCoffee = false;
  bool _hasUnreadZodiac = false;
  bool _hasUnreadDream = false;
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _tarotFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
      value: 0.25, // Sabit pozisyon
    );
    _checkUnreadStatuses();

    // Arka planda biten işlemleri (Kahve vb.) anında ekrana yansıtmak için periyodik kontrol
    _statusTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkUnreadStatuses();
    });
  }

  Future<void> _checkUnreadStatuses() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastZodiacDate = prefs.getString('last_zodiac_read_date') ?? '';

    setState(() {
      _hasUnreadCoffee = prefs.getBool('coffee_last_reading_viewed') == false;
      _hasUnreadDream = prefs.getBool('dream_last_reading_viewed') == false;
      _hasUnreadZodiac = lastZodiacDate != today;
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _tarotFloatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Ekran genişliğine göre ölçekleme
    // Referans: iPhone 14 Pro = 393pt
    final screenWidth = MediaQuery.of(context).size.width;
    // Scale faktörü - ama çok uç değerler olmasın (0.85 - 1.15 arası)
    final rawScale = screenWidth / 393.0;
    final scale = rawScale.clamp(0.85, 1.15);

    return Column(
      children: [
        // 1x3 Sağ kol + solda büyük Tarot (yükseklik hizalı)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 2,
                child: SizedBox.expand(
                  child: _PressableCardWrapper(
                    onTap: () {
                      Navigator.push(
                        context,
                        SwipeFadePageRoute(
                          page: const TarotPage(),
                        ),
                      );
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _BentoCard(
                          compact: true,
                          contentBottom: false,
                          iconWidget: const Icon(
                            Icons.amp_stories_rounded,
                            size: 24,
                            color: AppColors.textWhite,
                          ),
                          title: l10n.bentoTarotTitle,
                          desc: l10n.bentoTarotDesc,
                          accent: const Color(0xFFC48DFF), // Parlak canlı mor-lila
                          accentSoft: const Color(0xFF8040CC), // Doygun koyu mor
                          badgeText: l10n.bentoTarotBadge,
                          badgeHidden: true,
                          overlayImageAsset:
                              'assets/images/tarot/tarotbutonucember.webp',
                          overlayPositioned: true,
                          overlayRight: -95,
                          overlayTop: 30,
                          overlayWidth: 410,
                          overlayHeight: 410,
                          overlayClipToCard: true,
                          overlayRotate: true,
                          overlayRotateClockwise: true,
                          overlayImageDraggable: false,
                          overlayDragOffset: Offset.zero,
                        ),
                        Positioned(
                          right: -20,
                          top: 95,
                          child: IgnorePointer(
                            child: AnimatedBuilder(
                              animation: _tarotFloatController,
                              builder: (context, child) {
                                final floatY =
                                    math.sin(
                                      _tarotFloatController.value * math.pi * 2,
                                    ) *
                                    6;
                                return Transform.translate(
                                  offset: Offset(0, floatY),
                                  child: child!,
                                );
                              },
                              child: Transform.rotate(
                                angle: -0.08,
                                child: RepaintBoundary(
                                  child: Image.asset(
                                    'assets/images/tarot/tarotbuton_buyuktarot.webp',
                                    width: 258,
                                    height: 258,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _PressableCardWrapper(
                      onTap: () {
                        Navigator.push(
                          context,
                          SwipeFadePageRoute(
                            page: const DreamPage(),
                          ),
                        );
                      },
                      child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _BentoCard(
                          compact: true,
                          iconWidget: const Icon(
                            Icons.nights_stay_rounded,
                            size: 18,
                            color: AppColors.textWhite,
                          ),
                          title: l10n.bentoDreamTitle,
                          desc: l10n.bentoDreamDesc,
                          accent: const Color(0xFF60E0FF), // Parlak neon mavi
                          accentSoft: const Color(0xFF2080C0), // Doygun derin mavi
                          badgeText: _hasUnreadDream ? (l10n.localeName == 'tr' ? 'HAZIR' : 'READY') : l10n.bentoDreamBadge,
                          badgeHidden: !_hasUnreadDream,
                          badgeColor: _hasUnreadDream ? Colors.white : null,
                        ),
                        Positioned(
                          right: -26,
                          top: 6,
                          child: IgnorePointer(
                            child: RepaintBoundary(
                              child: Image.asset(
                                'assets/images/ruyabulut.webp',
                                width: 175,
                                height: 102,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 10,
                          top: 68,
                          child: IgnorePointer(
                            child: WindyNazar(
                              imagePath: 'assets/images/NAZAR.webp',
                              width: 68,
                              height: 68,
                            ),
                          ),
                        ),
                      ],
                    ),
                    ),
                    const SizedBox(height: 8),
                    // Kahve Falı Kartı
                    _PressableCardWrapper(
                      onTap: () {
                        // Yeni Kahve sayfasına yönlendireceğiz
                        Navigator.push(
                          context,
                          SwipeFadePageRoute(
                            page: const CoffeePage(),
                          ),
                        ).then((_) => _checkUnreadStatuses());
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _BentoCard(
                            compact: true,
                            iconWidget: const Icon(
                              Icons.local_cafe_rounded,
                              size: 16,
                              color: AppColors.textWhite,
                            ),
                            title: l10n.localeName == 'tr' ? 'Kahve Falı' : 'Coffee Reading',
                            desc: l10n.localeName == 'tr' ? 'Telvelerin dili' : 'Whispers of grounds',
                            accent: const Color(0xFFD4A373),
                            accentSoft: const Color(0xFF8B5A2B), // Koyu kahve
                            badgeText: _hasUnreadCoffee ? (l10n.localeName == 'tr' ? 'HAZIR' : 'READY') : (l10n.localeName == 'tr' ? 'YENİ' : 'NEW'),
                            badgeHidden: !_hasUnreadCoffee && false,
                            badgeColor: _hasUnreadCoffee ? Colors.white : null,
                          ),
                          // Büyük kahve arka plan ikonu
                          Positioned(
                            right: -20 * scale,
                            bottom: -20 * scale,
                            child: IgnorePointer(
                              child: Opacity(
                                opacity: 0.15,
                                child: Transform.rotate(
                                  angle: -0.2,
                                  child: const Icon(
                                    Icons.local_cafe_rounded,
                                    size: 140,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Küçük yıldız dekorasyonları
                          Positioned(
                            left: 80 * scale,
                            top: 20 * scale,
                            child: IgnorePointer(
                              child: Opacity(
                                opacity: 0.25,
                                child: const Icon(
                                  Icons.star_rounded,
                                  size: 24,
                                  color: Colors.amberAccent,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 40 * scale,
                            top: 10 * scale,
                            child: IgnorePointer(
                              child: Opacity(
                                opacity: 0.2,
                                child: const Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 32,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Burç kartı - zodyak görseli ile
                    _PressableCardWrapper(
                      onTap: () {
                        Navigator.push(
                          context,
                          SwipeFadePageRoute(
                            page: const ZodiacHubPage(),
                          ),
                        ).then((_) => _checkUnreadStatuses());
                      },
                      child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _BentoCard(
                          compact: true,
                          iconWidget: const Icon(
                            Icons.stars_rounded,
                            size: 16,
                            color: AppColors.textWhite,
                          ),
                          title: l10n.bentoZodiacTitle,
                          desc: l10n.bentoZodiacDesc,
                          accent: const Color(0xFFFFD060), // Parlak altın sarısı
                          accentSoft: const Color(0xFFB07020), // Doygun koyu altın
                          badgeText: _hasUnreadZodiac ? (l10n.localeName == 'tr' ? 'YENİ' : 'NEW') : l10n.bentoZodiacBadge,
                          badgeHidden: !_hasUnreadZodiac,
                          badgeColor: _hasUnreadZodiac ? Colors.white : null,
                          overlayImageAsset: 'assets/images/zodiac.webp',
                          overlayPositioned: true,
                          overlayRight: -4 * scale,
                          overlayTop: -3 * scale,
                          overlayWidth: 120 * scale,
                          overlayHeight: 120 * scale,
                          overlayClipToCard: false,
                          overlayRotate: false,
                        ),
                      ],
                    ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MoodCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.lock_clock_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  l10n.localeName == 'tr' ? 'Bu alan henüz keşfedilmeyi bekliyor...' : 'This realm is waiting to be explored...',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
            backgroundColor: Colors.white.withOpacity(0.12),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Stack(
        children: [
          Opacity(
            opacity: 0.4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.12),
                    Colors.white.withOpacity(0.06),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.18)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.moodQuestion,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LockedEmojiIcon(icon: CupertinoIcons.cloud_rain_fill),
                      const SizedBox(width: 6),
                      _LockedEmojiIcon(icon: CupertinoIcons.cloud_sun_fill),
                      const SizedBox(width: 6),
                      _LockedEmojiIcon(icon: CupertinoIcons.smiley_fill),
                      const SizedBox(width: 6),
                      _LockedEmojiIcon(icon: Icons.sentiment_very_satisfied_rounded),
                      const SizedBox(width: 6),
                      _LockedEmojiIcon(icon: Icons.auto_awesome_rounded),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_rounded, color: Colors.white.withOpacity(0.5), size: 13),
                      const SizedBox(width: 6),
                      Text(
                        l10n.localeName == 'tr' ? 'Mühürlü' : 'Sealed',
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedEmojiIcon extends StatelessWidget {
  final IconData icon;
  const _LockedEmojiIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.12),
            Colors.white.withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Center(
        child: Icon(icon, size: 16, color: Colors.white.withOpacity(0.4)),
      ),
    );
  }
}

class _BentoCard extends StatefulWidget {
  final String icon;
  final Widget? iconWidget;
  final String title;
  final String desc;
  final Color accent;
  final Color accentSoft;
  final String? badgeText;
  final bool badgeHidden;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final VoidCallback? onTap;
  final bool compact;
  final bool contentBottom;
  final String? backgroundImageAsset;
  final String? overlayImageAsset;
  final bool backgroundImageDraggable;
  final bool overlayImageDraggable;
  final double overlayScale;
  final Offset overlayOffset;
  final bool overlayClipToCard;
  final EdgeInsets overlayPadding;
  final bool overlayPositioned;
  final double overlayRight;
  final double overlayTop;
  final double overlayBottom;
  final double overlayWidth;
  final double overlayHeight;
  final bool overlayRotate;
  final bool overlayRotateClockwise;
  final BoxFit overlayFit;
  final bool overlayUseBottom;
  final Offset? overlayDragOffset;
  final ValueChanged<Offset>? overlayDragUpdate;
  final VoidCallback? overlayDragEnd;

  const _BentoCard({
    this.icon = '',
    this.iconWidget,
    required this.title,
    required this.desc,
    required this.accent,
    required this.accentSoft,
    this.badgeText,
    this.badgeHidden = false,
    this.badgeColor,
    this.badgeTextColor,
    this.onTap,
    this.compact = false,
    this.contentBottom = false,
    this.backgroundImageAsset,
    this.overlayImageAsset,
    this.backgroundImageDraggable = false,
    this.overlayImageDraggable = false,
    this.overlayScale = 1.0,
    this.overlayOffset = Offset.zero,
    this.overlayClipToCard = false,
    this.overlayPadding = EdgeInsets.zero,
    this.overlayPositioned = false,
    this.overlayRight = 0,
    this.overlayTop = 0,
    this.overlayBottom = 0,
    this.overlayWidth = 0,
    this.overlayHeight = 0,
    this.overlayRotate = true,
    this.overlayRotateClockwise = false,
    this.overlayFit = BoxFit.contain,
    this.overlayUseBottom = false,
    this.overlayDragOffset,
    this.overlayDragUpdate,
    this.overlayDragEnd,
  });

  @override
  State<_BentoCard> createState() => _BentoCardState();
}

class _BentoCardState extends State<_BentoCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final accentOverlay = widget.accent.withOpacity(0.24);
    return Stack(
      children: [
        _InteractiveCard(
          accent: widget.accent,
          accentSoft: widget.accentSoft,
          accentOverlay: accentOverlay,
          badgeText: widget.badgeText,
          badgeHidden: widget.badgeHidden,
          badgeColor: widget.badgeColor,
          badgeTextColor: widget.badgeTextColor,
          icon: widget.icon,
          iconWidget: widget.iconWidget,
          title: widget.title,
          desc: widget.desc,
          compact: widget.compact,
          contentBottom: widget.contentBottom,
          backgroundImageAsset: widget.backgroundImageAsset,
          overlayImageAsset: widget.overlayImageAsset,
          backgroundImageDraggable: widget.backgroundImageDraggable,
          overlayImageDraggable: widget.overlayImageDraggable,
          overlayScale: widget.overlayScale,
          overlayOffset: widget.overlayOffset,
          overlayClipToCard: widget.overlayClipToCard,
          overlayPadding: widget.overlayPadding,
          overlayPositioned: widget.overlayPositioned,
          overlayRight: widget.overlayRight,
          overlayTop: widget.overlayTop,
          overlayBottom: widget.overlayBottom,
          overlayWidth: widget.overlayWidth,
          overlayHeight: widget.overlayHeight,
          overlayRotate: widget.overlayRotate,
          overlayRotateClockwise: widget.overlayRotateClockwise,
          overlayFit: widget.overlayFit,
          overlayUseBottom: widget.overlayUseBottom,
          overlayDragOffset: widget.overlayDragOffset,
          overlayDragUpdate: widget.overlayDragUpdate,
          overlayDragEnd: widget.overlayDragEnd,
          onTap: widget.onTap,
          pressed: _pressed,
          onPressedChange: (v) => setState(() => _pressed = v),
        ),
      ],
    );
  }
}

class _InteractiveCard extends StatefulWidget {
  final String icon;
  final Widget? iconWidget;
  final String title;
  final String desc;
  final Color accent;
  final Color accentSoft;
  final Color accentOverlay;
  final String? badgeText;
  final bool badgeHidden;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final VoidCallback? onTap;
  final bool compact;
  final bool contentBottom;
  final String? backgroundImageAsset;
  final String? overlayImageAsset;
  final bool backgroundImageDraggable;
  final bool overlayImageDraggable;
  final double overlayScale;
  final Offset overlayOffset;
  final bool overlayClipToCard;
  final EdgeInsets overlayPadding;
  final bool overlayPositioned;
  final double overlayRight;
  final double overlayTop;
  final double overlayBottom;
  final double overlayWidth;
  final double overlayHeight;
  final bool overlayRotate;
  final bool overlayRotateClockwise;
  final BoxFit overlayFit;
  final bool overlayUseBottom;
  final Offset? overlayDragOffset;
  final ValueChanged<Offset>? overlayDragUpdate;
  final VoidCallback? overlayDragEnd;
  final bool pressed;
  final ValueChanged<bool> onPressedChange;

  const _InteractiveCard({
    required this.icon,
    this.iconWidget,
    required this.title,
    required this.desc,
    required this.accent,
    required this.accentSoft,
    required this.accentOverlay,
    required this.badgeText,
    required this.badgeHidden,
    this.badgeColor,
    this.badgeTextColor,
    required this.onTap,
    required this.compact,
    required this.contentBottom,
    required this.backgroundImageAsset,
    required this.overlayImageAsset,
    required this.backgroundImageDraggable,
    required this.overlayImageDraggable,
    required this.overlayScale,
    required this.overlayOffset,
    required this.overlayClipToCard,
    required this.overlayPadding,
    required this.overlayPositioned,
    required this.overlayRight,
    required this.overlayTop,
    required this.overlayBottom,
    required this.overlayWidth,
    required this.overlayHeight,
    required this.overlayRotate,
    required this.overlayRotateClockwise,
    required this.overlayFit,
    required this.overlayUseBottom,
    required this.overlayDragOffset,
    required this.overlayDragUpdate,
    required this.overlayDragEnd,
    required this.pressed,
    required this.onPressedChange,
  });

  @override
  State<_InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<_InteractiveCard>
    with SingleTickerProviderStateMixin {
  Offset _dragOffset = Offset.zero;
  Offset _overlayDragOffset = Offset.zero;
  late final AnimationController _overlayRotateController;

  @override
  void initState() {
    super.initState();
    _dragOffset = Offset.zero;
    _overlayDragOffset = Offset.zero;
    _overlayRotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 600),
      value: 0.0, // Sabit pozisyonda dur
    );
  }

  @override
  void dispose() {
    _overlayRotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pressed = widget.pressed;
    final compact = widget.compact;
    final contentBottom = widget.contentBottom;
    final edgePadding = compact ? 8.0 : 14.0;
    final badgePadH = compact ? 7.0 : 10.0;
    final badgePadV = compact ? 3.0 : 5.0;
    final badgeFont = compact ? 8.0 : 10.0;
    final iconBox = compact ? 34.0 : 50.0;
    final iconRadius = compact ? 10.0 : 14.0;
    final iconFont = compact ? 14.0 : 20.0;
    final titleFont = compact ? 15.0 : 18.0;
    final descFont = compact ? 10.0 : 12.0;
    final gapAfterBadge = compact ? 3.0 : 6.0;
    final gapAfterIcon = compact ? 6.0 : 12.0;
    final overlayOffset = widget.overlayDragOffset ?? _overlayDragOffset;
    final effectiveOverlayOffset = overlayOffset;
    final rotationTurns = _overlayRotateController.drive(
      Tween(begin: 0.0, end: widget.overlayRotateClockwise ? 1.0 : -1.0),
    );
    final hasTap = widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: hasTap ? (_) {
        HapticFeedback.lightImpact();
        widget.onPressedChange(true);
      } : null,
      onTapCancel: hasTap ? () => widget.onPressedChange(false) : null,
      onTapUp: hasTap ? (_) {} : null,
      onTap: hasTap ? () {
        widget.onPressedChange(true);
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) {
            widget.onPressedChange(false);
            widget.onTap?.call();
          }
        });
      } : null,
      onPanUpdate: widget.overlayImageDraggable && widget.overlayPositioned
          ? (details) {
              setState(() {
                if (widget.overlayDragUpdate != null) {
                  widget.overlayDragUpdate!(overlayOffset + details.delta);
                } else {
                  _overlayDragOffset = overlayOffset + details.delta;
                }
              });
            }
          : null,
      onPanEnd: widget.overlayImageDraggable && widget.overlayPositioned
          ? (_) => widget.overlayDragEnd?.call()
          : null,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: pressed ? 0.94 : 1.0,
        curve: pressed ? Curves.easeInCubic : Curves.easeOutCubic,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 120),
          opacity: pressed ? 0.85 : 1.0,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    if (widget.backgroundImageAsset != null)
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.95,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onPanUpdate: widget.backgroundImageDraggable
                                ? (details) {
                                    setState(() {
                                      _dragOffset += details.delta;
                                    });
                                  }
                                : null,
                            child: Transform.translate(
                              offset: _dragOffset,
                              child: Transform.scale(
                                scale: 1.2,
                                alignment: Alignment.bottomRight,
                                child: Image.asset(
                                  widget.backgroundImageAsset!,
                                  fit: BoxFit.contain,
                                  alignment: Alignment.bottomRight,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Positioned.fill(
                      child: Container(color: Colors.white.withOpacity(0.05)),
                    ),
                    Container(
                      padding: EdgeInsets.all(edgePadding),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(pressed ? 0.07 : 0.06),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.18),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: pressed ? 10 : 8,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: widget.accent.withOpacity(0.30),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.accent.withOpacity(pressed ? 1.0 : 1.0),
                            widget.accentSoft.withOpacity(
                              pressed ? 1.0 : 1.0,
                            ),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.badgeText != null)
                            Align(
                              alignment: Alignment.topRight,
                              child: Opacity(
                                opacity: widget.badgeHidden ? 0.0 : 1.0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: badgePadH,
                                    vertical: badgePadV,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.badgeColor != null ? widget.badgeColor! : widget.accent.withOpacity(0.16),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: widget.badgeColor != null ? widget.badgeColor! : widget.accent.withOpacity(0.3),
                                    ),
                                    boxShadow: widget.badgeColor != null ? [
                                      BoxShadow(
                                        color: widget.badgeColor!.withOpacity(0.4),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      )
                                    ] : null,
                                  ),
                                  child: Text(
                                    widget.badgeText!,
                                    style: TextStyle(
                                      color: widget.badgeColor == Colors.white ? const Color(0xFF1A1A1E) : (widget.badgeColor ?? AppColors.textWhite),
                                      fontSize: badgeFont,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (contentBottom) const Spacer(),
                          SizedBox(height: gapAfterBadge),
                          Stack(
                            children: [
                              // Highlight spot
                              Positioned(
                                right: -6,
                                top: -6,
                                child: Container(
                                  width: compact ? 24 : 36,
                                  height: compact ? 24 : 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.14),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: iconBox,
                                height: iconBox,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(0.25),
                                      widget.accent.withOpacity(0.45),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    iconRadius,
                                  ),
                                  border: Border.all(
                                    color: widget.accentSoft.withOpacity(0.28),
                                  ),
                                ),
                                child: Center(
                                  child: widget.iconWidget ?? Text(
                                    widget.icon,
                                    style: TextStyle(fontSize: iconFont, fontFamilyFallback: const ['Apple Color Emoji']),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: gapAfterIcon),
                          Text(
                            widget.title,
                            style: GoogleFonts.quicksand(
                              color: AppColors.textWhite,
                              fontSize: titleFont,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.desc,
                            style: TextStyle(
                              color: AppColors.textWhite70,
                              fontSize: descFont,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.overlayImageAsset != null && widget.overlayPositioned)
                (widget.overlayClipToCard
                    ? Positioned.fill(
                        child: AnimatedSlide(
                          duration: const Duration(milliseconds: 150),
                          offset: pressed ? const Offset(0, -0.12) : Offset.zero,
                          curve: pressed ? Curves.easeOutCubic : Curves.easeInOutCubic,
                          child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Stack(
                            clipBehavior: Clip.hardEdge,
                            children: [
                              Positioned(
                                right:
                                    widget.overlayRight +
                                    effectiveOverlayOffset.dx,
                                top: widget.overlayUseBottom
                                    ? null
                                    : widget.overlayTop +
                                          effectiveOverlayOffset.dy,
                                bottom: widget.overlayUseBottom
                                    ? widget.overlayBottom +
                                          effectiveOverlayOffset.dy
                                    : null,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onPanUpdate: widget.overlayImageDraggable
                                      ? (details) {
                                          setState(() {
                                            if (widget.overlayDragUpdate !=
                                                null) {
                                              widget.overlayDragUpdate!(
                                                overlayOffset + details.delta,
                                              );
                                            } else {
                                              _overlayDragOffset =
                                                  overlayOffset + details.delta;
                                            }
                                          });
                                        }
                                      : null,
                                  onPanEnd: widget.overlayImageDraggable
                                      ? (_) => widget.overlayDragEnd?.call()
                                      : null,
                                  child: SizedBox(
                                    width: widget.overlayWidth,
                                    height: widget.overlayHeight,
                                    child: widget.overlayRotate
                                        ? RotationTransition(
                                            turns: rotationTurns,
                                            child: Image.asset(
                                              widget.overlayImageAsset!,
                                              fit: widget.overlayFit,
                                              alignment: Alignment.center,
                                            ),
                                          )
                                        : Image.asset(
                                            widget.overlayImageAsset!,
                                            fit: widget.overlayFit,
                                            alignment: Alignment.center,
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ),
                      )
                    : Positioned(
                        right: widget.overlayRight + effectiveOverlayOffset.dx,
                        top: widget.overlayUseBottom
                            ? null
                            : widget.overlayTop + effectiveOverlayOffset.dy,
                        bottom: widget.overlayUseBottom
                            ? widget.overlayBottom + effectiveOverlayOffset.dy
                            : null,
                        child: AnimatedSlide(
                          duration: const Duration(milliseconds: 150),
                          offset: pressed ? const Offset(0, -0.12) : Offset.zero,
                          curve: pressed ? Curves.easeOutCubic : Curves.easeInOutCubic,
                          child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onPanUpdate: widget.overlayImageDraggable
                              ? (details) {
                                  setState(() {
                                    if (widget.overlayDragUpdate != null) {
                                      widget.overlayDragUpdate!(
                                        overlayOffset + details.delta,
                                      );
                                    } else {
                                      _overlayDragOffset =
                                          overlayOffset + details.delta;
                                    }
                                  });
                                }
                              : null,
                          onPanEnd: widget.overlayImageDraggable
                              ? (_) => widget.overlayDragEnd?.call()
                              : null,
                          child: SizedBox(
                            width: widget.overlayWidth,
                            height: widget.overlayHeight,
                            child: widget.overlayRotate
                                ? RotationTransition(
                                    turns: rotationTurns,
                                    child: Image.asset(
                                      widget.overlayImageAsset!,
                                      fit: widget.overlayFit,
                                      alignment: Alignment.center,
                                    ),
                                  )
                                : Image.asset(
                                    widget.overlayImageAsset!,
                                    fit: widget.overlayFit,
                                    alignment: Alignment.center,
                                  ),
                          ),
                        ),
                        ),
                      ))
              else if (widget.overlayImageAsset != null)
                Positioned.fill(
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 150),
                    offset: pressed ? const Offset(0, -0.12) : Offset.zero,
                    curve: pressed ? Curves.easeOutCubic : Curves.easeInOutCubic,
                    child: LayoutBuilder(
                    builder: (context, constraints) {
                      final size = Size(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      );
                      final padding = widget.overlayPadding;
                      final frameWidth = (size.width - padding.horizontal)
                          .clamp(0.0, size.width);
                      final frameHeight = (size.height - padding.vertical)
                          .clamp(0.0, size.height);
                      final baseSize = math.min(frameWidth, frameHeight);
                      final circleSize = baseSize * widget.overlayScale;
                      final frameCenter = Offset(
                        padding.left + frameWidth / 2,
                        padding.top + frameHeight / 2,
                      );

                      Offset clampOffset(Offset raw) {
                        final adjusted = raw + widget.overlayOffset;
                        final localPosition = frameCenter + adjusted;
                        final halfSize = circleSize / 2;
                        final minX = padding.left + halfSize;
                        final maxX = padding.left + frameWidth - halfSize;
                        final minY = padding.top + halfSize;
                        final maxY = padding.top + frameHeight - halfSize;

                        double newX = localPosition.dx;
                        double newY = localPosition.dy;

                        newX = minX > maxX
                            ? frameCenter.dx
                            : newX.clamp(minX, maxX);
                        newY = minY > maxY
                            ? frameCenter.dy
                            : newY.clamp(minY, maxY);

                        return (Offset(newX, newY) - frameCenter) -
                            widget.overlayOffset;
                      }

                      return GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onPanUpdate: widget.overlayImageDraggable
                            ? (details) {
                                final nextOffset = clampOffset(
                                  effectiveOverlayOffset + details.delta,
                                );
                                setState(() {
                                  _overlayDragOffset = nextOffset;
                                });
                                widget.overlayDragUpdate?.call(nextOffset);
                              }
                            : null,
                        child: Transform.translate(
                          offset:
                              clampOffset(effectiveOverlayOffset) +
                              widget.overlayOffset,
                          child: widget.overlayClipToCard
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Padding(
                                    padding: widget.overlayPadding,
                                    child: Transform.scale(
                                      scale: widget.overlayScale,
                                      alignment: Alignment.center,
                                      child: widget.overlayRotate
                                          ? RotationTransition(
                                              turns: rotationTurns,
                                              child: Image.asset(
                                                widget.overlayImageAsset!,
                                                fit: widget.overlayFit,
                                                alignment: Alignment.center,
                                              ),
                                            )
                                          : Image.asset(
                                              widget.overlayImageAsset!,
                                              fit: widget.overlayFit,
                                              alignment: Alignment.center,
                                            ),
                                    ),
                                  ),
                                )
                              : Transform.scale(
                                  scale: widget.overlayScale,
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: widget.overlayPadding,
                                    child: widget.overlayRotate
                                        ? RotationTransition(
                                            turns: rotationTurns,
                                            child: Image.asset(
                                              widget.overlayImageAsset!,
                                              fit: widget.overlayFit,
                                              alignment: Alignment.center,
                                            ),
                                          )
                                        : Image.asset(
                                            widget.overlayImageAsset!,
                                            fit: widget.overlayFit,
                                            alignment: Alignment.center,
                                          ),
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Yavaş dönen widget (sola doğru)
class _SlowRotatingWidget extends StatelessWidget {
  final Widget child;
  const _SlowRotatingWidget({required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}


// Hafif yüzme hareketi
class _FloatingWidget extends StatelessWidget {
  final Widget child;
  const _FloatingWidget({required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}


/// Tüm kartı (görsel + arka plan) basınca küçülten wrapper
class _PressableCardWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _PressableCardWrapper({
    required this.child,
    this.onTap,
  });

  @override
  State<_PressableCardWrapper> createState() => _PressableCardWrapperState();
}

class _PressableCardWrapperState extends State<_PressableCardWrapper> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {},
      onTap: () {
        setState(() => _pressed = true);
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) {
            setState(() => _pressed = false);
            widget.onTap?.call();
          }
        });
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.94 : 1.0,
        curve: _pressed ? Curves.easeInCubic : Curves.easeOutCubic,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 120),
          opacity: _pressed ? 0.85 : 1.0,
          child: widget.child,
        ),
      ),
    );
  }
}
