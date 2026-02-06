import 'package:flutter/material.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';
import '../constants/colors.dart';

class SocialFeedItem {
  final String type;
  final String emoji;
  final String tag;
  final Color accent;
  final int sparkle;
  final int heart;
  final int clover;

  const SocialFeedItem({
    required this.type,
    required this.emoji,
    required this.tag,
    required this.accent,
    this.sparkle = 0,
    this.heart = 0,
    this.clover = 0,
  });
}

class SocialFeedSection extends StatelessWidget {
  final List<SocialFeedItem>? items;

  const SocialFeedSection({
    super.key,
    this.items,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final feedItems = items ?? _buildDefaultFeed(l10n);
    if (feedItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.socialFeedTitle,
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...feedItems.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SocialFeedCard(item: item),
          ),
        ),
      ],
    );
  }
}

class _SocialFeedCard extends StatefulWidget {
  final SocialFeedItem item;

  const _SocialFeedCard({required this.item});

  @override
  State<_SocialFeedCard> createState() => _SocialFeedCardState();
}

class _SocialFeedCardState extends State<_SocialFeedCard> {
  late int sparkle = widget.item.sparkle;
  late int heart = widget.item.heart;
  late int clover = widget.item.clover;

  void _bump(String reaction) {
    setState(() {
      switch (reaction) {
        case '✨':
          sparkle++;
          break;
        case '❤️':
          heart++;
          break;
        case '🍀':
          clover++;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.item.accent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 0.6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.item.accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.item.emoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.item.tag,
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  widget.item.type,
                  style: TextStyle(
                    color: AppColors.textWhite50,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Center(
              child: Text(
                widget.item.emoji,
                style: const TextStyle(fontSize: 44),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ReactionButton(
                  label: '✨',
                  count: sparkle,
                  onTap: () => _bump('✨'),
                ),
                _ReactionButton(
                  label: '❤️',
                  count: heart,
                  onTap: () => _bump('❤️'),
                ),
                _ReactionButton(
                  label: '🍀',
                  count: clover,
                  onTap: () => _bump('🍀'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  final String label;
  final int count;
  final VoidCallback onTap;

  const _ReactionButton({
    required this.label,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 0.4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              count.toString(),
              style: const TextStyle(
                color: AppColors.textWhite70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<SocialFeedItem> _buildDefaultFeed(AppLocalizations l10n) => [
  SocialFeedItem(
    type: l10n.feedTypeCookie,
    emoji: '🥠',
    tag: l10n.feedTagDailyCookie,
    accent: AppColors.primaryOrange,
    sparkle: 24,
    heart: 12,
    clover: 6,
  ),
  SocialFeedItem(
    type: l10n.feedTypeTarot,
    emoji: '🔮',
    tag: l10n.feedTagThreeCard,
    accent: AppColors.primaryPurple,
    sparkle: 18,
    heart: 9,
    clover: 4,
  ),
  SocialFeedItem(
    type: l10n.feedTypeDream,
    emoji: '🌙',
    tag: l10n.feedTagDreamMode,
    accent: AppColors.bambooGreen,
    sparkle: 10,
    heart: 7,
    clover: 5,
  ),
  SocialFeedItem(
    type: l10n.feedTypeZodiac,
    emoji: '♑️',
    tag: l10n.feedTagDailyEnergy,
    accent: AppColors.primaryTeal,
    sparkle: 15,
    heart: 5,
    clover: 3,
  ),
  SocialFeedItem(
    type: l10n.feedTypeMotivation,
    emoji: '⚡',
    tag: l10n.feedTagMiniAction,
    accent: AppColors.primaryPink,
    sparkle: 9,
    heart: 8,
    clover: 2,
  ),
];
