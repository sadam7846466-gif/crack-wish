import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';
import 'dart:ui' show Color, ImageFilter;

class CookieSelector extends StatefulWidget {
  final Function(String)? onCookieSelected;
  final int? initialSelectedIndex;

  const CookieSelector({
    super.key,
    this.onCookieSelected,
    this.initialSelectedIndex,
  });

  /// İlk ücretli kurabiyenin index'i
  static int get lockedStartIndex =>
      CookieSelectorState._cookieTypes.indexWhere((c) => c['isPaid'] == true);

  @override
  State<CookieSelector> createState() => CookieSelectorState();
}

class CookieSelectorState extends State<CookieSelector> {
  late int _selectedIndex;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late ScrollController _scrollController;

  // Her bir kurabiye item'ının yaklaşık genişliği (padding dahil)
  static const double _itemWidth = 60.0; // 48 (item) + 12 (horizontal padding)
  
  // Sonsuz scroll için çok büyük bir sayı (lazy loading ile performans sorunu olmaz)
  static const int _infiniteCount = 10000;
  
  // Başlangıç offset'ini hesapla
  double _calculateInitialOffset(int selectedIndex, double screenWidth) {
    final middleStart = (_infiniteCount ~/ 2) - ((_infiniteCount ~/ 2) % _cookieTypes.length);
    final targetIndex = middleStart + selectedIndex;
    // Artık centerPadding kullanıyoruz, offset sadece index * itemWidth
    return targetIndex * _itemWidth;
  }

  static final List<Map<String, dynamic>> _cookieTypes = [
    // Ücretsiz (14 adet)
    {'id': 'spring_wreath', 'key': 'cookieSpringWreath', 'imagePath': 'assets/images/cookies/spring_wreath.png', 'isPaid': false, 'color': const Color(0xFF8BC34A)},
    {'id': 'lucky_clover', 'key': 'cookieLuckyClover', 'imagePath': 'assets/images/cookies/lucky_clover.png', 'isPaid': false, 'color': const Color(0xFF4CAF50)},
    {'id': 'royal_hearts', 'key': 'cookieRoyalHearts', 'imagePath': 'assets/images/cookies/royal_hearts.png', 'isPaid': false, 'color': const Color(0xFFE91E63)},
    {'id': 'evil_eye', 'key': 'cookieEvilEye', 'imagePath': 'assets/images/cookies/evil_eye.png', 'isPaid': false, 'color': const Color(0xFF2196F3)},
    {'id': 'pizza_party', 'key': 'cookiePizzaParty', 'imagePath': 'assets/images/cookies/pizza_party.png', 'isPaid': false, 'color': const Color(0xFFFF9800)},
    {'id': 'sakura_bloom', 'key': 'cookieSakuraBloom', 'imagePath': 'assets/images/cookies/sakura_bloom.png', 'isPaid': false, 'color': const Color(0xFFF48FB1)},
    {'id': 'blue_porcelain', 'key': 'cookieBluePorcelain', 'imagePath': 'assets/images/cookies/blue_porcelain.png', 'isPaid': false, 'color': const Color(0xFF42A5F5)},
    {'id': 'pink_blossom', 'key': 'cookiePinkBlossom', 'imagePath': 'assets/images/cookies/pink_blossom.png', 'isPaid': false, 'color': const Color(0xFFEC407A)},
    {'id': 'fortune_cat', 'key': 'cookieFortuneCat', 'imagePath': 'assets/images/cookies/fortune_cat.png', 'isPaid': false, 'color': const Color(0xFFFFB74D)},
    {'id': 'wildflower', 'key': 'cookieWildflower', 'imagePath': 'assets/images/cookies/wildflower.png', 'isPaid': false, 'color': const Color(0xFFAB47BC)},
    {'id': 'cupid_ribbon', 'key': 'cookieCupidRibbon', 'imagePath': 'assets/images/cookies/cupid_ribbon.png', 'isPaid': false, 'color': const Color(0xFFEF5350)},
    {'id': 'panda_bamboo', 'key': 'cookiePandaBamboo', 'imagePath': 'assets/images/cookies/panda_bamboo.png', 'isPaid': false, 'color': const Color(0xFF66BB6A)},
    {'id': 'ramadan_cute', 'key': 'cookieRamadanCute', 'imagePath': 'assets/images/cookies/ramadan_cute.png', 'isPaid': false, 'color': const Color(0xFF7E57C2)},
    {'id': 'enchanted_forest', 'key': 'cookieEnchantedForest', 'imagePath': 'assets/images/cookies/enchanted_forest.png', 'isPaid': false, 'color': const Color(0xFF26A69A)},
    // Ücretli (6 adet)
    {'id': 'golden_arabesque', 'key': 'cookieGoldenArabesque', 'imagePath': 'assets/images/cookies/golden_arabesque.png', 'isPaid': true, 'color': const Color(0xFFFFD700)},
    {'id': 'midnight_mosaic', 'key': 'cookieMidnightMosaic', 'imagePath': 'assets/images/cookies/midnight_mosaic.png', 'isPaid': true, 'color': const Color(0xFF5C6BC0)},
    {'id': 'pearl_lace', 'key': 'cookiePearlLace', 'imagePath': 'assets/images/cookies/pearl_lace.png', 'isPaid': true, 'color': const Color(0xFFE0E0E0)},
    {'id': 'golden_sakura', 'key': 'cookieGoldenSakura', 'imagePath': 'assets/images/cookies/golden_sakura.png', 'isPaid': true, 'color': const Color(0xFFF8BBD0)},
    {'id': 'dragon_phoenix', 'key': 'cookieDragonPhoenix', 'imagePath': 'assets/images/cookies/dragon_phoenix.png', 'isPaid': true, 'color': const Color(0xFFFF5722)},
    {'id': 'gold_beasts', 'key': 'cookieGoldBeasts', 'imagePath': 'assets/images/cookies/gold_beasts.png', 'isPaid': true, 'color': const Color(0xFFFFAB00)},
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelectedIndex ?? 0;
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // İlk kez oluşturuluyorsa scroll controller'ı başlat
    if (!_scrollControllerInitialized) {
      final screenWidth = MediaQuery.of(context).size.width;
      final initialOffset = _calculateInitialOffset(_selectedIndex, screenWidth);
      _scrollController = ScrollController(initialScrollOffset: initialOffset);
      _scrollControllerInitialized = true;
    }
  }
  
  bool _scrollControllerInitialized = false;

  @override
  void didUpdateWidget(CookieSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSelectedIndex != null &&
        widget.initialSelectedIndex != oldWidget.initialSelectedIndex &&
        widget.initialSelectedIndex! != _selectedIndex) {
      _selectedIndex = widget.initialSelectedIndex!;
      // Seçili kurabiyeye scroll et
      _scrollToSelected();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  /// Kilitli kurabiyeye scroll et (dışarıdan çağırılabilir)
  void scrollToLockedCookie() {
    final lockedIndex = _cookieTypes.indexWhere((c) => c['isPaid'] == true);
    if (lockedIndex < 0) return;
    setState(() {
      _selectedIndex = lockedIndex;
    });
    _scrollToSelected();
    // Küçük bir gecikmeyle kilitli dialog'ı göster
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        _showLockedDialog(context, _cookieLabel(l10n, _cookieTypes[lockedIndex]['key'] as String));
      }
    });
  }

  void _scrollToSelected() {
    if (!_scrollController.hasClients) return;
    
    final currentOffset = _scrollController.offset;
    final totalWidth = _cookieTypes.length * _itemWidth;
    
    // Mevcut pozisyona en yakın hedefi bul
    // Önce mevcut "tekrar"ı hesapla
    final baseRepeat = (currentOffset / totalWidth).floor();
    
    // 3 olası hedef: önceki tekrar, mevcut tekrar, sonraki tekrar
    final candidates = [
      (baseRepeat - 1) * totalWidth + (_selectedIndex * _itemWidth),
      baseRepeat * totalWidth + (_selectedIndex * _itemWidth),
      (baseRepeat + 1) * totalWidth + (_selectedIndex * _itemWidth),
    ];
    
    // En yakın olanı seç
    double targetOffset = candidates[1];
    double minDistance = (currentOffset - targetOffset).abs();
    
    for (final candidate in candidates) {
      final distance = (currentOffset - candidate).abs();
      if (distance < minDistance) {
        minDistance = distance;
        targetOffset = candidate;
      }
    }
    
    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _playSelectSound() async {
    return;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return NotificationListener<ScrollNotification>(
      onNotification: (_) => true,
      child: ClipRect(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 0),
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.transparent,
                  Colors.white,
                  Colors.white,
                  Colors.transparent,
                ],
                stops: [0.0, 0.18, 0.82, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final centerPadding = (constraints.maxWidth / 2) - 24;
                return SizedBox(
                  height: 90,
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    itemExtent: _itemWidth,
                    cacheExtent: 1000,
                    addRepaintBoundaries: false,
                    addAutomaticKeepAlives: false,
                    padding: EdgeInsets.only(
                      left: centerPadding,
                      right: centerPadding,
                      top: 6,
                      bottom: 6,
                    ),
                    itemCount: _infiniteCount,
                    itemBuilder: (context, i) {
                      final index = i % _cookieTypes.length;
                      final currentSelectedIndex =
                          widget.initialSelectedIndex ?? _selectedIndex;
                      final isSelected = currentSelectedIndex == index;

                      return _CookieSelectorItem(
                        imagePath: _cookieTypes[index]['imagePath'] as String,
                        label: _cookieLabel(l10n, _cookieTypes[index]['key'] as String),
                        isSelected: isSelected,
                        isPaid: _cookieTypes[index]['isPaid'] as bool,
                        accentColor: _cookieTypes[index]['color'] as Color,
                        onTap: () {
                          final isPaid = _cookieTypes[index]['isPaid'] as bool;
                          if (isPaid) {
                            _showLockedDialog(context, _cookieLabel(l10n, _cookieTypes[index]['key'] as String));
                            return;
                          }
                          setState(() => _selectedIndex = index);
                          _playSelectSound();
                          widget.onCookieSelected?.call(
                            _cookieTypes[index]['id'] as String,
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showLockedDialog(BuildContext context, String cookieName) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, a1, a2, child) {
        return Transform.scale(
          scale: 0.85 + 0.15 * a1.value,
          child: Opacity(
            opacity: a1.value,
            child: Dialog(
              backgroundColor: const Color(0xFF2E1420),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔒', style: TextStyle(fontSize: 32)),
                    const SizedBox(height: 12),
                    Text(
                      cookieName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.amber[200],
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bu özel kurabiye kilitli',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFFD700).withOpacity(0.2),
                            const Color(0xFFFF8A3D).withOpacity(0.2),
                          ],
                        ),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withOpacity(0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Yakında Satışa Çıkacak ✨',
                          style: TextStyle(
                            color: Colors.amber[200],
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _cookieLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'cookieSpringWreath':
        return l10n.cookieSpringWreath;
      case 'cookieLuckyClover':
        return l10n.cookieLuckyClover;
      case 'cookieRoyalHearts':
        return l10n.cookieRoyalHearts;
      case 'cookieEvilEye':
        return l10n.cookieEvilEye;
      case 'cookiePizzaParty':
        return l10n.cookiePizzaParty;
      case 'cookieSakuraBloom':
        return l10n.cookieSakuraBloom;
      case 'cookieBluePorcelain':
        return l10n.cookieBluePorcelain;
      case 'cookiePinkBlossom':
        return l10n.cookiePinkBlossom;
      case 'cookieFortuneCat':
        return l10n.cookieFortuneCat;
      case 'cookieWildflower':
        return l10n.cookieWildflower;
      case 'cookieCupidRibbon':
        return l10n.cookieCupidRibbon;
      case 'cookiePandaBamboo':
        return l10n.cookiePandaBamboo;
      case 'cookieRamadanCute':
        return l10n.cookieRamadanCute;
      case 'cookieEnchantedForest':
        return l10n.cookieEnchantedForest;
      case 'cookieGoldenArabesque':
        return l10n.cookieGoldenArabesque;
      case 'cookieMidnightMosaic':
        return l10n.cookieMidnightMosaic;
      case 'cookiePearlLace':
        return l10n.cookiePearlLace;
      case 'cookieGoldenSakura':
        return l10n.cookieGoldenSakura;
      case 'cookieDragonPhoenix':
        return l10n.cookieDragonPhoenix;
      case 'cookieGoldBeasts':
        return l10n.cookieGoldBeasts;
      default:
        return '';
    }
  }
}

class _CookieSelectorItem extends StatelessWidget {
  final String imagePath;
  final String label;
  final bool isSelected;
  final bool isPaid;
  final Color accentColor;
  final VoidCallback onTap;

  const _CookieSelectorItem({
    super.key,
    required this.imagePath,
    required this.label,
    required this.isSelected,
    required this.isPaid,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const double containerSize = 48.0;
    const double imageSize = 28.0;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 60,
        height: containerSize,
        child: Center(
          child: AnimatedScale(
            scale: isSelected ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: containerSize,
                height: containerSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accentColor.withOpacity(isSelected ? 0.25 : 0.08),
                      accentColor.withOpacity(isSelected ? 0.10 : 0.03),
                    ],
                  ),
                  border: Border.all(
                    color: isSelected
                        ? accentColor.withOpacity(0.8)
                        : accentColor.withOpacity(0.15),
                    width: isSelected ? 2.0 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: accentColor.withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(imageSize / 2),
                    child: ImageFiltered(
                      imageFilter: isPaid
                          ? ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0)
                          : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                      child: Image.asset(
                        imagePath,
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Text('🥠', style: TextStyle(fontSize: 22));
                        },
                      ),
                    ),
                  ),
                ),
              ),
              // Ücretli kurabiye kilit ikonu
              if (isPaid)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF2E1420),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.lock,
                        size: 9,
                        color: Color(0xFF2E1420),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
