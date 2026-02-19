import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';
import '../constants/colors.dart';
import '../screens/tarot_page.dart';
import '../screens/dream_page.dart';
import '../screens/zodiac_page.dart';
import '../services/storage_service.dart';
import '../widgets/windy_nazar.dart';
import '../widgets/floating_astronaut1.dart';
import '../widgets/floating_astronaut2.dart';

class BentoGrid extends StatefulWidget {
  const BentoGrid({super.key});

  @override
  State<BentoGrid> createState() => _BentoGridState();
}

class _BentoGridState extends State<BentoGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tarotFloatController;

  @override
  void initState() {
    super.initState();
    _tarotFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6800),
    )..repeat();
  }

  @override
  void dispose() {
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
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _BentoCard(
                        compact: true,
                        contentBottom: false,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TarotPage(),
                            ),
                          );
                        },
                        icon: '🎴', // Tarot simgesi
                        title: l10n.bentoTarotTitle,
                        desc: l10n.bentoTarotDesc,
                        accent: const Color(0xFF9C6BFF), // Derin mor-lila
                        accentSoft: const Color(0xFF4B3A87), // Gölge moru
                        badgeText: l10n.bentoTarotBadge,
                        badgeHidden: true,
                        overlayImageAsset:
                            'assets/images/tarot/tarotbutonucember.png',
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
                              child: Image.asset(
                                'assets/images/tarot/tarotbuton_büyüktarot.webp',
                                width: 258,
                                height: 258,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _BentoCard(
                          compact: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DreamPage(),
                              ),
                            );
                          },
                          icon: '☁️', // Rüya simgesi
                          title: l10n.bentoDreamTitle,
                          desc: l10n.bentoDreamDesc,
                          accent: const Color(0xFF40C9FF), // Parlak cam mavi
                          accentSoft: const Color(0xFF164D73), // Gece mavisi
                          badgeText: l10n.bentoDreamBadge,
                          badgeHidden: true,
                        ),
                        Positioned(
                          right: -26,
                          top: 6,
                          child: IgnorePointer(
                            child: Image.asset(
                              'assets/images/ruyabulut.png',
                              width: 175,
                              height: 102,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 10,
                          top: 68,
                          child: IgnorePointer(
                            child: WindyNazar(
                              imagePath: 'assets/images/NAZAR.png',
                              width: 68,
                              height: 68,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Motivasyon kartı - dış Stack (gezegen taşabilir)
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // İç ClipRRect (roket, astronotlar içeride kalır)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Stack(
                            clipBehavior: Clip.hardEdge,
                            children: [
                              _BentoCard(
                                compact: true,
                                onTap: () {
                                  // Motivasyon akışı henüz yok
                                },
                                icon: '💪',
                                title: l10n.bentoMotivationTitle,
                                desc: l10n.bentoMotivationDesc,
                                accent: const Color(0xFF5ED39C),
                                accentSoft: const Color(0xFF1F5B3E),
                                badgeText: l10n.bentoMotivationBadge,
                                badgeHidden: true,
                              ),
                              // Roket - SABİT KONUM
                              Positioned(
                                right: -7 * scale,
                                top: -20 * scale,
                                child: IgnorePointer(
                                  child: Image.asset(
                                    'assets/images/motiveroket.png',
                                    width: 185 * scale,
                                    height: 185 * scale,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              // Astronot 2 - SABİT KONUM
                              Positioned(
                                right: -10 * scale,
                                bottom: -30 * scale,
                                child: IgnorePointer(
                                  child: FloatingAstronaut2(
                                    child: Image.asset(
                                      'assets/images/motiveastronot2.png',
                                      width: 160 * scale,
                                      height: 160 * scale,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              // Astronot 1 - SABİT KONUM
                              Positioned(
                                left: -3 * scale,
                                bottom: -19 * scale,
                                child: IgnorePointer(
                                  child: FloatingAstronaut1(
                                    child: Image.asset(
                                      'assets/images/motiveastronot1.png',
                                      width: 180 * scale,
                                      height: 180 * scale,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Gezegen - hafif yüzme hareketi
                        Positioned(
                          right: -16 * scale,
                          top: -29 * scale,
                          child: IgnorePointer(
                            child: _FloatingWidget(
                              child: Image.asset(
                                'assets/images/motivegezegen.png',
                                width: 160 * scale,
                                height: 160 * scale,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        // Yıldız - SABİT KONUM
                        Positioned(
                          left: 55 * scale,
                          top: 37 * scale,
                          child: IgnorePointer(
                            child: Image.asset(
                              'assets/images/motiveYILDIZ.png',
                              width: 80 * scale,
                              height: 80 * scale,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Burç kartı - zodyak görseli ile
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _BentoCard(
                          compact: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ZodiacPage(),
                              ),
                            );
                          },
                          icon: '⭐',
                          title: l10n.bentoZodiacTitle,
                          desc: l10n.bentoZodiacDesc,
                          accent: const Color(0xFFFFB347),
                          accentSoft: const Color(0xFF6B4A1A),
                          badgeText: l10n.bentoZodiacBadge,
                          badgeHidden: true,
                        ),
                        // Zodyak görseli - yavaş dönen
                        Positioned(
                          right: -4 * scale,
                          top: -3 * scale,
                          child: IgnorePointer(
                            child: _SlowRotatingWidget(
                              child: Image.asset(
                                'assets/images/zodiac.png',
                                width: 120 * scale,
                                height: 120 * scale,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Mood Section
        _MoodCard(),
      ],
    );
  }
}

class _MoodCard extends StatefulWidget {
  @override
  State<_MoodCard> createState() => _MoodCardState();
}

class _MoodCardState extends State<_MoodCard> {
  String? _selectedMood;

  @override
  void initState() {
    super.initState();
    _loadMood();
  }

  Future<void> _loadMood() async {
    final mood = await StorageService.getMood();
    setState(() {
      _selectedMood = mood;
    });
  }

  Future<void> _selectMood(String mood) async {
    await StorageService.setMood(mood);
    setState(() {
      _selectedMood = mood;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
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
                  _MoodEmojiButton(
                    emoji: '😢',
                    isSelected: _selectedMood == '😢',
                    onTap: () => _selectMood('😢'),
                  ),
                  const SizedBox(width: 6),
                  _MoodEmojiButton(
                    emoji: '😔',
                    isSelected: _selectedMood == '😔',
                    onTap: () => _selectMood('😔'),
                  ),
                  const SizedBox(width: 6),
                  _MoodEmojiButton(
                    emoji: '😊',
                    isSelected: _selectedMood == '😊',
                    onTap: () => _selectMood('😊'),
                  ),
                  const SizedBox(width: 6),
                  _MoodEmojiButton(
                    emoji: '😄',
                    isSelected: _selectedMood == '😄',
                    onTap: () => _selectMood('😄'),
                  ),
                  const SizedBox(width: 6),
                  _MoodEmojiButton(
                    emoji: '🤩',
                    isSelected: _selectedMood == '🤩',
                    onTap: () => _selectMood('🤩'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoodEmojiButton extends StatelessWidget {
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodEmojiButton({
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? [
                        AppColors.primaryOrange.withOpacity(0.4),
                        AppColors.primaryOrange.withOpacity(0.2),
                      ]
                    : [
                        Colors.white.withOpacity(0.12),
                        Colors.white.withOpacity(0.06),
                      ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryOrange.withOpacity(0.5)
                    : Colors.white.withOpacity(0.18),
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryOrange.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                emoji,
                style: TextStyle(fontSize: isSelected ? 18 : 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BentoCard extends StatefulWidget {
  final String icon;
  final String title;
  final String desc;
  final Color accent;
  final Color accentSoft;
  final String? badgeText;
  final bool badgeHidden;
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
    required this.icon,
    required this.title,
    required this.desc,
    required this.accent,
    required this.accentSoft,
    this.badgeText,
    this.badgeHidden = false,
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
          icon: widget.icon,
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
  final String title;
  final String desc;
  final Color accent;
  final Color accentSoft;
  final Color accentOverlay;
  final String? badgeText;
  final bool badgeHidden;
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
    required this.title,
    required this.desc,
    required this.accent,
    required this.accentSoft,
    required this.accentOverlay,
    required this.badgeText,
    required this.badgeHidden,
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
      duration: const Duration(seconds: 360),
    )..repeat();
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
    final titleFont = compact ? 13.0 : 16.0;
    final descFont = compact ? 10.0 : 12.0;
    final gapAfterBadge = compact ? 3.0 : 6.0;
    final gapAfterIcon = compact ? 6.0 : 12.0;
    final overlayOffset = widget.overlayDragOffset ?? _overlayDragOffset;
    final effectiveOverlayOffset = overlayOffset;
    final rotationTurns = _overlayRotateController.drive(
      Tween(begin: 0.0, end: widget.overlayRotateClockwise ? 1.0 : -1.0),
    );
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) => widget.onPressedChange(true),
      onTapCancel: () => widget.onPressedChange(false),
      onTapUp: (_) => widget.onPressedChange(false),
      onTap: widget.onTap,
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
        scale: pressed ? 0.98 : 1.0,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 120),
          opacity: pressed ? 0.95 : 1.0,
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
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(color: Colors.white.withOpacity(0.05)),
                      ),
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
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: pressed ? 8 : 7,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: widget.accent.withOpacity(0.14),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.accent.withOpacity(pressed ? 0.60 : 0.50),
                            widget.accentSoft.withOpacity(
                              pressed ? 0.44 : 0.34,
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
                                    color: widget.accent.withOpacity(0.16),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: widget.accent.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    widget.badgeText!,
                                    style: TextStyle(
                                      color: AppColors.textWhite,
                                      fontSize: badgeFont,
                                      fontWeight: FontWeight.w700,
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
                                  child: Text(
                                    widget.icon,
                                    style: TextStyle(fontSize: iconFont),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: gapAfterIcon),
                          Text(
                            widget.title,
                            style: TextStyle(
                              color: AppColors.textWhite,
                              fontSize: titleFont,
                              fontWeight: FontWeight.w800,
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
                      )
                    : Positioned(
                        right: widget.overlayRight + effectiveOverlayOffset.dx,
                        top: widget.overlayUseBottom
                            ? null
                            : widget.overlayTop + effectiveOverlayOffset.dy,
                        bottom: widget.overlayUseBottom
                            ? widget.overlayBottom + effectiveOverlayOffset.dy
                            : null,
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
                      ))
              else if (widget.overlayImageAsset != null)
                Positioned.fill(
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
            ],
          ),
        ),
      ),
    );
  }
}

// Yavaş dönen widget (sola doğru)
class _SlowRotatingWidget extends StatefulWidget {
  final Widget child;
  const _SlowRotatingWidget({required this.child});

  @override
  State<_SlowRotatingWidget> createState() => _SlowRotatingWidgetState();
}

class _SlowRotatingWidgetState extends State<_SlowRotatingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 180), // 3 dakikada bir tur
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: -_controller.value * 2 * math.pi, // Sola dönüş (negatif)
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// Hafif yüzme hareketi
class _FloatingWidget extends StatefulWidget {
  final Widget child;
  const _FloatingWidget({required this.child});

  @override
  State<_FloatingWidget> createState() => _FloatingWidgetState();
}

class _FloatingWidgetState extends State<_FloatingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final offset = math.sin(_controller.value * math.pi) * 6;
        return Transform.translate(offset: Offset(0, offset), child: child);
      },
      child: widget.child,
    );
  }
}
