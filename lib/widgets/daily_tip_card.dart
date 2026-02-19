
import 'package:flutter/material.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';
import '../constants/colors.dart';
import '../screens/dream_page.dart';
import '../screens/tarot_page.dart';
import '../screens/zodiac_page.dart';
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

    _SuggestionType next;
    if (!dreamDone) {
      next = _SuggestionType.dream;
    } else if (!tarotDone) {
      next = _SuggestionType.tarot;
    } else if (!zodiacDone) {
      next = _SuggestionType.zodiac;
    } else {
      next = _SuggestionType.allDone;
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
          FadePageRoute(page: const DreamPage()),
        );
        break;
      case _SuggestionType.tarot:
        Navigator.push(
          context,
          FadePageRoute(page: const TarotPage()),
        );
        break;
      case _SuggestionType.zodiac:
        Navigator.push(
          context,
          FadePageRoute(page: const ZodiacPage()),
        );
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
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: _go,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        scale: _pressed ? 0.975 : 1.0,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          opacity: _pressed ? 0.93 : 1.0,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryOrange.withOpacity(0.3),
                  AppColors.primaryOrange.withOpacity(0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.orangeGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryOrange.withOpacity(0.42),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.star_rounded, color: Colors.white, size: 24),
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
    );
  }
}

enum _SuggestionType { dream, tarot, zodiac, allDone }
