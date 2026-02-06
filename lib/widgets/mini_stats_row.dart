import 'package:flutter/material.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';
import '../constants/colors.dart';
import '../services/storage_service.dart';

class MiniStatsRow extends StatefulWidget {
  final VoidCallback? onRefresh;

  const MiniStatsRow({super.key, this.onRefresh});

  @override
  State<MiniStatsRow> createState() => _MiniStatsRowState();
}

class _MiniStatsRowState extends State<MiniStatsRow> {
  int _cookieCount = 0;
  int _streakDays = 0;
  String _mood = '';

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  void didUpdateWidget(MiniStatsRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onRefresh != null && widget.onRefresh != oldWidget.onRefresh) {
      _loadStats();
    }
  }

  Future<void> _loadStats() async {
    final cookieCount = await StorageService.getCookieCount();
    final streakDays = await StorageService.getStreakDays();
    final mood = await StorageService.getMood();
    final l10n = AppLocalizations.of(context)!;

    if (mounted) {
      setState(() {
        _cookieCount = cookieCount;
        _streakDays = streakDays;
        _mood = _getMoodText(mood, l10n);
      });
    }
  }

  String _getMoodText(String? mood, AppLocalizations l10n) {
    if (mood == null) return l10n.moodGood;
    final moodMap = {
      '😢': l10n.moodSad,
      '😔': l10n.moodBad,
      '😊': l10n.moodGood,
      '😄': l10n.moodHappy,
      '🤩': l10n.moodGreat,
    };
    return moodMap[mood] ?? l10n.moodGood;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _MiniStatCard(
            icon: '🔥',
            value: '$_streakDays',
            label: l10n.statStreakDays,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MiniStatCard(
            icon: '🥠',
            value: '$_cookieCount',
            label: l10n.statCookies,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MiniStatCard(
            icon: '💜',
            value: _mood,
            label: l10n.statMood,
          ),
        ),
      ],
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;

  const _MiniStatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(icon, style: const TextStyle(fontSize: 18)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      height: 1.05,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
