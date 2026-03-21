import 'package:flutter/material.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';
import '../constants/colors.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/fade_page_route.dart';
import '../services/storage_service.dart';
import 'home_page.dart';
import 'profile_page.dart';
import '../models/cookie_card.dart';

class CollectionPage extends StatefulWidget {
  final bool showBottomNav;
  final ValueChanged<int>? onNavTapOverride;

  const CollectionPage({
    super.key,
    this.showBottomNav = true,
    this.onNavTapOverride,
  });

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  int _currentNavIndex = 1;
  String _rarityFilter = 'all'; // all, common, rare, legendary

  void _onNavTap(int index) {
    if (widget.onNavTapOverride != null) {
      widget.onNavTapOverride!(index);
      return;
    }
    if (index == 0) {
      Navigator.pushReplacement(context, SwipeFadePageRoute(page: const HomePage()));
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        SwipeFadePageRoute(page: const ProfilePage()),
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
    final languageCode = Localizations.localeOf(context).languageCode;
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.collectionTitle,
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.collectionSubtitle,
                          style: const TextStyle(
                            color: AppColors.textWhite50,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.grid_view_rounded,
                            color: AppColors.textWhite70,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.filter_alt_outlined,
                            color: AppColors.primaryOrange,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _loadCollectionData(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final data = snapshot.data!;
                    final List<CookieCard> cards = data['cards'];
                    final totalOpened = data['totalOpened'] as int;
                    final discovered = cards
                        .where((c) => c.firstObtainedDate != null)
                        .length;
                    final rareCount = cards
                        .where(
                          (c) =>
                              (c.rarity == 'rare' || c.rarity == 'legendary') &&
                              c.firstObtainedDate != null,
                        )
                        .length;

                    final filtered = cards.where((c) {
                      if (_rarityFilter == 'all') return true;
                      return c.rarity == _rarityFilter;
                    }).toList();

                    final hasAny = cards.any(
                      (c) => c.firstObtainedDate != null,
                    );

                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SummaryCard(
                            discovered: discovered,
                            totalTypes: cards.length,
                            totalOpened: totalOpened,
                            rareCount: rareCount,
                            l10n: l10n,
                          ),
                          const SizedBox(height: 14),
                          _RarityFilter(
                            current: _rarityFilter,
                            onChanged: (v) => setState(() => _rarityFilter = v),
                            l10n: l10n,
                          ),
                          const SizedBox(height: 14),
                          if (!hasAny)
                            _EmptyPlaceholder(
                              totalTypes: cards.length,
                              l10n: l10n,
                            )
                          else
                            _CookieGrid(
                              cards: filtered,
                              onTap: (card) => _showCardDetail(card),
                              l10n: l10n,
                              cookieNameForId: _cookieNameForId,
                              languageCode: languageCode,
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: widget.showBottomNav
          ? BottomNav(currentIndex: _currentNavIndex, onTap: _onNavTap)
          : null,
    );
  }

  Future<Map<String, dynamic>> _loadCollectionData() async {
    final collection = await StorageService.getCookieCollection();
    final totalOpened = await StorageService.getTotalCookies();
    return {'cards': collection, 'totalOpened': totalOpened};
  }

  String _cookieNameForId(
    String id,
    String fallback,
    String languageCode,
  ) {
    const namesTr = {
      'spring_wreath': 'Bahar Çelengi',
      'lucky_clover': 'Şanslı Yonca',
      'royal_hearts': 'Kraliyet Kalpleri',
      'evil_eye': 'Nazar',
      'pizza_party': 'Pizza Partisi',
      'sakura_bloom': 'Sakura',
      'blue_porcelain': 'Mavi Porselen',
      'pink_blossom': 'Pembe Çiçek',
      'fortune_cat': 'Şans Kedisi',
      'wildflower': 'Kır Çiçeği',
      'cupid_ribbon': 'Aşk Kurdelesi',
      'panda_bamboo': 'Panda',
      'ramadan_cute': 'Ramazan',
      'enchanted_forest': 'Büyülü Orman',
      'golden_arabesque': 'Altın Arabesk',
      'midnight_mosaic': 'Gece Mozaiği',
      'pearl_lace': 'İnci Dantel',
      'golden_sakura': 'Altın Sakura',
      'dragon_phoenix': 'Ejderha & Anka',
      'gold_beasts': 'Altın Canavarlar',
    };
    const namesEn = {
      'spring_wreath': 'Spring Wreath',
      'lucky_clover': 'Lucky Clover',
      'royal_hearts': 'Royal Hearts',
      'evil_eye': 'Evil Eye',
      'pizza_party': 'Pizza Party',
      'sakura_bloom': 'Sakura Bloom',
      'blue_porcelain': 'Blue Porcelain',
      'pink_blossom': 'Pink Blossom',
      'fortune_cat': 'Fortune Cat',
      'wildflower': 'Wildflower',
      'cupid_ribbon': 'Cupid Ribbon',
      'panda_bamboo': 'Panda Bamboo',
      'ramadan_cute': 'Ramadan',
      'enchanted_forest': 'Enchanted Forest',
      'golden_arabesque': 'Golden Arabesque',
      'midnight_mosaic': 'Midnight Mosaic',
      'pearl_lace': 'Pearl Lace',
      'golden_sakura': 'Golden Sakura',
      'dragon_phoenix': 'Dragon Phoenix',
      'gold_beasts': 'Gold Beasts',
    };
    final names = languageCode == 'tr' ? namesTr : namesEn;
    return names[id] ?? fallback;
  }

  void _showCardDetail(CookieCard card) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    final dateStr = card.firstObtainedDate != null
        ? '${card.firstObtainedDate!.day.toString().padLeft(2, '0')}.${card.firstObtainedDate!.month.toString().padLeft(2, '0')}.${card.firstObtainedDate!.year}'
        : l10n.collectionNotYet;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1F2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _EmojiBadge(card: card, size: 64),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _cookieNameForId(card.id, card.name, languageCode),
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _RarityChip(rarity: card.rarity, dense: true),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await StorageService.toggleCookieFavorite(
                        card.id,
                        !card.isFavorite,
                      );
                      setState(() {});
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      card.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: card.isFavorite
                          ? AppColors.primaryPink
                          : AppColors.textWhite50,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _DetailItem(label: l10n.collectionFirstTime, value: dateStr),
                  _DetailItem(
                    label: l10n.collectionTotalOpened,
                    value: 'x${card.countObtained}',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Text(
                  l10n.collectionCookieDescription,
                  style: const TextStyle(
                    color: AppColors.textWhite70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int discovered;
  final int totalTypes;
  final int totalOpened;
  final int rareCount;
  final AppLocalizations l10n;

  const _SummaryCard({
    required this.discovered,
    required this.totalTypes,
    required this.totalOpened,
    required this.rareCount,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.collectionSummaryTitle,
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _SummaryItem(
                label: l10n.collectionSummaryTypes,
                value: '$discovered / $totalTypes',
              ),
              const SizedBox(width: 14),
              _SummaryItem(
                label: l10n.collectionSummaryTotalOpened,
                value: '$totalOpened',
              ),
              const SizedBox(width: 14),
              _SummaryItem(label: l10n.collectionSummaryRare, value: '$rareCount'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            l10n.collectionSummaryFooter,
            style: TextStyle(
              color: AppColors.textWhite50,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textWhite50,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RarityFilter extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;
  final AppLocalizations l10n;

  const _RarityFilter({
    required this.current,
    required this.onChanged,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'key': 'all', 'label': l10n.rarityAll},
      {'key': 'common', 'label': l10n.rarityCommon},
      {'key': 'rare', 'label': l10n.rarityRare},
      {'key': 'legendary', 'label': l10n.rarityLegendary},
    ];
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: items.map((item) {
          final isActive = current == item['key'];
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(item['key']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primaryOrange.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: isActive
                      ? Border.all(
                          color: AppColors.primaryOrange.withOpacity(0.3),
                        )
                      : null,
                ),
                child: Center(
                  child: Text(
                    item['label']!,
                    style: TextStyle(
                      color: isActive
                          ? AppColors.textWhite
                          : AppColors.textWhite50,
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CookieGrid extends StatelessWidget {
  final List<CookieCard> cards;
  final ValueChanged<CookieCard> onTap;
  final AppLocalizations l10n;
  final String languageCode;
  final String Function(String id, String fallback, String languageCode)
      cookieNameForId;

  const _CookieGrid({
    required this.cards,
    required this.onTap,
    required this.l10n,
    required this.languageCode,
    required this.cookieNameForId,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        final obtained = card.firstObtainedDate != null;
        return GestureDetector(
          onTap: obtained ? () => onTap(card) : null,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _rarityColor(
                  card.rarity,
                ).withOpacity(obtained ? 0.4 : 0.1),
              ),
              boxShadow: obtained
                  ? [
                      BoxShadow(
                        color: _rarityColor(card.rarity).withOpacity(0.25),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _EmojiBadge(card: card),
                    if (obtained)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'x${card.countObtained}',
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  obtained
                      ? cookieNameForId(card.id, card.name, languageCode)
                      : l10n.collectionUndiscovered,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: obtained
                        ? AppColors.textWhite
                        : AppColors.textWhite50,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                obtained
                    ? _RarityChip(rarity: card.rarity)
                    : Text(
                        l10n.collectionNotFoundYet,
                        style: const TextStyle(
                          color: AppColors.textWhite50,
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmojiBadge extends StatelessWidget {
  final CookieCard card;
  final double size;
  const _EmojiBadge({required this.card, this.size = 42});

  @override
  Widget build(BuildContext context) {
    final obtained = card.firstObtainedDate != null;
    final imagePath = 'assets/images/cookies/${card.id}.webp';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _rarityColor(card.rarity).withOpacity(obtained ? 0.25 : 0.05),
            Colors.white.withOpacity(0.04),
          ],
        ),
      ),
      child: Center(
        child: Opacity(
          opacity: obtained ? 1 : 0.35,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imagePath,
              width: size * 0.7,
              height: size * 0.7,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Text('🥠', style: TextStyle(fontSize: size * 0.5, fontFamilyFallback: const ['Apple Color Emoji']));
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _RarityChip extends StatelessWidget {
  final String rarity;
  final bool dense;
  const _RarityChip({required this.rarity, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = _rarityColor(rarity);
    final label = rarity == 'legendary'
        ? l10n.rarityLegendary
        : rarity == 'rare'
        ? l10n.rarityRare
        : l10n.rarityCommon;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: dense ? 11 : 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _DetailItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textWhite50,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  final int totalTypes;
  final AppLocalizations l10n;

  const _EmptyPlaceholder({
    required this.totalTypes,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Opacity(
            opacity: 0.7,
            child: const Text('🥠', style: TextStyle(fontSize: 48, fontFamilyFallback: ['Apple Color Emoji'])),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.collectionEmptyTitle,
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.collectionEmptySubtitle(totalTypes),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textWhite50,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

Color _rarityColor(String rarity) {
  switch (rarity) {
    case 'legendary':
      return const Color(0xFFFFA947); // turuncu parlak
    case 'rare':
      return const Color(0xFF7C7BFF); // mor-mavi
    default:
      return Colors.white70;
  }
}
