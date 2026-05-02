import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';
import '../constants/colors.dart';
import '../screens/dream_page.dart';
import '../screens/tarot_page.dart';
import '../screens/zodiac_hub_page.dart';
import '../services/storage_service.dart';
import '../widgets/fade_page_route.dart';

class DailyTipCard extends StatefulWidget {
  const DailyTipCard({super.key});

  @override
  State<DailyTipCard> createState() => _DailyTipCardState();
}

class _DailyTipCardState extends State<DailyTipCard> {
  bool _pressed = false;
  _SuggestionType? _suggestion;

  @override
  void initState() {
    super.initState();
    _loadSuggestion();
  }

  Future<void> _loadSuggestion() async {
    final dreamDone = await StorageService.isDreamDoneToday();
    final tarotDone = await StorageService.isTarotDoneToday();
    final zodiacDone = await StorageService.isZodiacDoneToday();

    final available = <_SuggestionType>[];
    if (!dreamDone) available.add(_SuggestionType.dream);
    if (!tarotDone) available.add(_SuggestionType.tarot);
    if (!zodiacDone) available.add(_SuggestionType.zodiac);

    _SuggestionType next;
    if (available.isEmpty) {
      next = _SuggestionType.allDone;
    } else {
      available.shuffle();
      next = available.first;
    }

    if (mounted) {
      setState(() => _suggestion = next);
    }
  }

  void _go() {
    switch (_suggestion) {
      case _SuggestionType.dream:
        Navigator.push(
          context,
          SwipeFadePageRoute(page: const DreamPage()),
        ).then((_) => _loadSuggestion());
        break;
      case _SuggestionType.tarot:
        Navigator.push(
          context,
          SwipeFadePageRoute(page: const TarotPage()),
        ).then((_) => _loadSuggestion());
        break;
      case _SuggestionType.zodiac:
        Navigator.push(
          context,
          SwipeFadePageRoute(page: const ZodiacHubPage()),
        ).then((_) => _loadSuggestion());
        break;
      case _SuggestionType.allDone:
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final suggestion = _suggestion ?? _SuggestionType.dream;
    final headline = switch (suggestion) {
      _SuggestionType.dream => l10n.dailySuggestionDreamHeadline,
      _SuggestionType.tarot => l10n.dailySuggestionTarotHeadline,
      _SuggestionType.zodiac => l10n.dailySuggestionZodiacHeadline,
      _SuggestionType.allDone => l10n.dailySuggestionAllDoneHeadline,
    };
    final subtitle = switch (suggestion) {
      _SuggestionType.dream => l10n.dailySuggestionDreamSubtitle,
      _SuggestionType.tarot => l10n.dailySuggestionTarotSubtitle,
      _SuggestionType.zodiac => l10n.dailySuggestionZodiacSubtitle,
      _SuggestionType.allDone => l10n.dailySuggestionAllDoneSubtitle,
    };

    final IconData iconData = switch (suggestion) {
      _SuggestionType.dream => Icons.nights_stay_rounded,
      _SuggestionType.tarot => Icons.style_rounded,
      _SuggestionType.zodiac => Icons.brightness_high_rounded,
      _SuggestionType.allDone => Icons.check_circle_rounded,
    };

    final List<Color> accentColors = [
      Colors.white,
      Colors.white.withOpacity(0.7),
    ];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _pressed = true);
      },
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {},
      onTap: () {
        HapticFeedback.mediumImpact();
        setState(() => _pressed = true);
        Future.delayed(const Duration(milliseconds: 120), () {
          if (mounted) {
            setState(() => _pressed = false);
            _go();
          }
        });
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        curve: _pressed ? Curves.easeInCubic : Curves.easeOutCubic,
        scale: _pressed ? 0.94 : 1.0,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 120),
          curve: _pressed ? Curves.easeInCubic : Curves.easeOutCubic,
          opacity: _pressed ? 0.85 : 1.0,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 14,
                  sigmaY: 14,
                ), // 30 → 14 (performans)
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentColors[0].withOpacity(0.20),
                        accentColors[1].withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                      width: 0.8,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: accentColors,
                          ).createShader(bounds),
                          child: Icon(
                            iconData,
                            color: Colors.white,
                            size: 38,
                            shadows: [
                              Shadow(
                                color: accentColors[1].withOpacity(0.5),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.discoverDailySuggestionTitle,
                                style: TextStyle(
                                  color: AppColors.textWhite.withOpacity(0.75),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                headline,
                                style: TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
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
                        Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.textWhite50,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _SuggestionType { dream, tarot, zodiac, allDone }
