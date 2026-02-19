import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';
import '../constants/colors.dart';
import '../screens/zodiac_page.dart';
import '../widgets/fade_page_route.dart';

class DailyHoroscopeCard extends StatelessWidget {
  const DailyHoroscopeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          FadePageRoute(page: const ZodiacPage()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.18),
                    Colors.white.withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primaryOrange.withOpacity(0.25),
                                    AppColors.primaryOrange.withOpacity(0.12),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.25),
                                  width: 0.8,
                                ),
                              ),
                              child: const Center(
                                child: Text('♈', style: TextStyle(fontSize: 22)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.dailyHoroscopeTitle,
                                style: TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                l10n.dailyHoroscopeSubtitle,
                                style: TextStyle(
                                  color: AppColors.textWhite70,
                                  fontSize: 11,
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
                    const SizedBox(height: 12),
                    Text(
                      l10n.dailyHoroscopeBody,
                      style: TextStyle(
                        color: AppColors.textWhite70,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _StatItem(
                            emoji: '💕',
                            label: l10n.zodiacLove,
                            value: 0.8,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatItem(
                            emoji: '💼',
                            label: l10n.zodiacCareer,
                            value: 0.9,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatItem(
                            emoji: '💰',
                            label: l10n.zodiacMoney,
                            value: 0.7,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String emoji;
  final String label;
  final double value;

  const _StatItem({
    required this.emoji,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: AppColors.textWhite70, fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            widthFactor: value,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.orangeGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
