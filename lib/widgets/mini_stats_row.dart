import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';
import '../constants/colors.dart';
import '../services/storage_service.dart';
import '../models/cookie_card.dart';
import '../screens/owl_letter_page.dart';

class MiniStatsRow extends StatefulWidget {
  final VoidCallback? onRefresh;
  final ValueChanged<String>? onCookieSelected;
  final ValueChanged<String>? onCookieNavigate;
  final String? selectedCookieId;

  const MiniStatsRow({super.key, this.onRefresh, this.onCookieSelected, this.onCookieNavigate, this.selectedCookieId});

  @override
  State<MiniStatsRow> createState() => _MiniStatsRowState();
}

class _MiniStatsRowState extends State<MiniStatsRow> {
  int _collectionCount = 0; // Sahip olunan kurabiye çeşit sayısı
  int _totalTypes = 20; // Toplam kurabiye çeşit sayısı
  String _pinnedCookieId = 'spring_wreath'; // StorageService'den yüklenen sabitlenmiş kurabiye
  final GlobalKey _rowKey = GlobalKey();
  final GlobalKey _key0 = GlobalKey();
  final GlobalKey _key1 = GlobalKey();
  final GlobalKey _key2 = GlobalKey();

  // Günün teması
  static const _themes = [
    {'emoji': '💕', 'tr': 'Aşk', 'en': 'Love',
     'descTr': 'Bugün kalbinin sesini dinle. Sevgi enerjin yüksek, yakınlarına vakit ayır.',
     'descEn': 'Listen to your heart today. Your love energy is high, spend time with loved ones.'},
    {'emoji': '💰', 'tr': 'Para', 'en': 'Money',
     'descTr': 'Finansal fırsatlar kapında. Küçük adımlar büyük kazançlar getirebilir.',
     'descEn': 'Financial opportunities await. Small steps can lead to big gains.'},
    {'emoji': '🚀', 'tr': 'Kariyer', 'en': 'Career',
     'descTr': 'Bugün kariyerinde yeni kapılar açılabilir. Cesur ol ve fırsatları değerlendir.',
     'descEn': 'New doors may open in your career today. Be bold and seize opportunities.'},
    {'emoji': '🌿', 'tr': 'Sağlık', 'en': 'Health',
     'descTr': 'Bedenine ve ruhuna iyi bak. Bugün kendine vakit ayırman gereken bir gün.',
     'descEn': 'Take care of your body and soul. Today is a day to focus on yourself.'},
  ];

  // Tılsımlar
  static const _talismans = [
    {'emoji': '🧿', 'tr': 'Nazar Boncuğu', 'en': 'Evil Eye',
     'descTr': 'Negatif enerjilere karşı güçlü bir kalkan. Bugün seni kötü gözlerden koruyacak.',
     'descEn': 'A powerful shield against negative energy. It will protect you from the evil eye today.'},
    {'emoji': '🔴', 'tr': 'Kırmızı İplik', 'en': 'Red String',
     'descTr': 'Kader bağın güçlü. Bugün doğru insanlarla karşılaşabilirsin.',
     'descEn': 'Your fate bond is strong. You may meet the right people today.'},
    {'emoji': '🧲', 'tr': 'At Nalı', 'en': 'Horseshoe',
     'descTr': 'Şans kapında! Beklenmedik güzel sürprizlere hazır ol.',
     'descEn': 'Luck is at your door! Be ready for unexpected pleasant surprises.'},
    {'emoji': '🍀', 'tr': 'Dört Yaprak', 'en': 'Four Leaf',
     'descTr': 'Nadir bulunan bu şans simgesi bugün seninle. Her adımında şans var.',
     'descEn': 'This rare luck symbol is with you today. Luck is in every step.'},
    {'emoji': '✨', 'tr': 'Yıldız Tozu', 'en': 'Stardust',
     'descTr': 'Kozmik enerji seninle. Dileklerin gerçekleşmeye daha yakın.',
     'descEn': 'Cosmic energy is with you. Your wishes are closer to coming true.'},
    {'emoji': '🌙', 'tr': 'Ay Işığı', 'en': 'Moonlight',
     'descTr': 'İç huzur ve sezgilerin güçleniyor. Bugün duygularına güven.',
     'descEn': 'Inner peace and intuition are strengthening. Trust your feelings today.'},
    {'emoji': '💎', 'tr': 'Göz Taşı', 'en': 'Eye Stone',
     'descTr': 'Berraklık ve odak günün. Doğru kararlar vereceksin.',
     'descEn': 'Clarity and focus are your day. You will make the right decisions.'},
  ];

  late int _themeIndex;
  late int _talismanIndex;

  @override
  void initState() {
    super.initState();
    _pickDailyValues();
    _loadStats();
    _loadPinnedCookie();
  }

  Future<void> _loadPinnedCookie() async {
    final pinned = await StorageService.getSelectedCookie();
    if (mounted) {
      setState(() => _pinnedCookieId = pinned);
    }
  }

  @override
  void didUpdateWidget(MiniStatsRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onRefresh != null && widget.onRefresh != oldWidget.onRefresh) {
      _loadStats();
    }
  }

  void _pickDailyValues() {
    final now = DateTime.now();
    final daySeed = now.year * 10000 + now.month * 100 + now.day;
    final rng = Random(daySeed);
    _themeIndex = rng.nextInt(_themes.length);
    _talismanIndex = rng.nextInt(_talismans.length);
  }

  Future<void> _loadStats() async {
    final collection = await StorageService.getCookieCollection();
    final owned = collection.where((c) => c.firstObtainedDate != null).length;
    if (mounted) {
      setState(() {
        _collectionCount = owned;
        _totalTypes = collection.length;
      });
    }
  }

  void _openOverlay(int index) {
    HapticFeedback.lightImpact();

    // Tıklanan kutunun ekran konumunu bul
    final keys = [_key0, _key1, _key2];
    final btnBox = keys[index].currentContext?.findRenderObject() as RenderBox?;
    if (btnBox == null) return;
    final btnPos = btnBox.localToGlobal(Offset.zero);
    final btnSize = btnBox.size;
    // Satırın konumunu da al (panel genişliği için)
    final rowBox = _rowKey.currentContext?.findRenderObject() as RenderBox?;
    if (rowBox == null) return;
    final rowPos = rowBox.localToGlobal(Offset.zero);
    final rowSize = rowBox.size;
    // Panel kutuların hemen altından başlasın
    final topY = rowPos.dy + rowSize.height + 8;
    // Butonun merkez X'i
    final btnCenterX = btnPos.dx + btnSize.width / 2;

    final l10n = AppLocalizations.of(context)!;
    final isTr = l10n.localeName == 'tr';

    String emoji, title, desc;
    if (index == 0) {
      final t = _themes[_themeIndex];
      emoji = t['emoji']!;
      title = isTr ? t['tr']! : t['en']!;
      desc = isTr ? t['descTr']! : t['descEn']!;
    } else if (index == 1) {
      // Koleksiyon overlay'ı — özel kurabiye grid göster
      Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false,
          barrierDismissible: false,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (context, _, __) => _CollectionOverlay(
            topY: topY,
            btnCenterX: btnCenterX,
            selectedCookieId: widget.selectedCookieId,
            onCookieSelected: (cookieId) {
              widget.onCookieSelected?.call(cookieId);
              setState(() => _pinnedCookieId = cookieId);
            },
            onCookieNavigate: widget.onCookieNavigate,
          ),
        ),
      );
      return;
    } else {
      final t = _talismans[_talismanIndex];
      emoji = t['emoji']!;
      title = isTr ? t['tr']! : t['en']!;
      desc = isTr ? t['descTr']! : t['descEn']!;
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, _, __) => _StatOverlay(
          topY: topY,
          btnCenterX: btnCenterX,
          emoji: emoji,
          title: title,
          description: desc,
        ),
      ),
    );
  }

  static const Map<String, String> _cookieImageMap = {
    'spring_wreath': 'assets/images/cookies/spring_wreath.png',
    'lucky_clover': 'assets/images/cookies/lucky_clover.png',
    'royal_hearts': 'assets/images/cookies/royal_hearts.png',
    'evil_eye': 'assets/images/cookies/evil_eye.png',
    'pizza_party': 'assets/images/cookies/pizza_party.png',
    'sakura_bloom': 'assets/images/cookies/sakura_bloom.png',
    'blue_porcelain': 'assets/images/cookies/blue_porcelain.png',
    'pink_blossom': 'assets/images/cookies/pink_blossom.png',
    'fortune_cat': 'assets/images/cookies/fortune_cat.png',
    'wildflower': 'assets/images/cookies/wildflower.png',
    'cupid_ribbon': 'assets/images/cookies/cupid_ribbon.png',
    'panda_bamboo': 'assets/images/cookies/panda_bamboo.png',
    'ramadan_cute': 'assets/images/cookies/ramadan_cute.png',
    'enchanted_forest': 'assets/images/cookies/enchanted_forest.png',
    'golden_arabesque': 'assets/images/cookies/golden_arabesque.png',
    'midnight_mosaic': 'assets/images/cookies/midnight_mosaic.png',
    'pearl_lace': 'assets/images/cookies/pearl_lace.png',
    'golden_sakura': 'assets/images/cookies/golden_sakura.png',
    'dragon_phoenix': 'assets/images/cookies/dragon_phoenix.png',
    'gold_beasts': 'assets/images/cookies/gold_beasts.png',
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = _themes[_themeIndex];
    final talisman = _talismans[_talismanIndex];

    // Sabitlenmiş kurabiyenin görseli (swipe ile değişmez)
    final cookieImagePath = _cookieImageMap[_pinnedCookieId];
    Widget? cookieIconWidget;
    if (cookieImagePath != null) {
      cookieIconWidget = Image.asset(
        cookieImagePath,
        width: 22,
        height: 22,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Text('🥠', style: TextStyle(fontSize: 20)),
      );
    }

    return Row(
      key: _rowKey,
      children: [
        Expanded(
          child: _MiniStatCard(
            key: _key0,
            icon: theme['emoji']!,
            label: l10n.statTheme,
            onTap: () => _openOverlay(0),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MiniStatCard(
            key: _key1,
            icon: '🥠',
            iconWidget: cookieIconWidget,
            label: l10n.statCollection,
            onTap: () => _openOverlay(1),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MiniStatCard(
            key: _key2,
            icon: talisman['emoji']!,
            label: l10n.statTalisman,
            onTap: () => _openOverlay(2),
          ),
        ),
      ],
    );
  }
}

// ── Overlay sayfası (baykuş butonu gibi) ──
class _StatOverlay extends StatefulWidget {
  final double topY;
  final double btnCenterX;
  final String emoji;
  final String title;
  final String description;

  const _StatOverlay({
    required this.topY,
    required this.btnCenterX,
    required this.emoji,
    required this.title,
    required this.description,
  });

  @override
  State<_StatOverlay> createState() => _StatOverlayState();
}

class _StatOverlayState extends State<_StatOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool _closing = false;

  void _close() {
    if (_closing) return;
    _closing = true;
    _ctrl.reverse().then((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  void _closeImmediate() {
    if (_closing) return;
    _closing = true;
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {},
      onPointerMove: (_) => _closeImmediate(),
      onPointerUp: (_) => _close(),
      child: Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) {
            final screenW = MediaQuery.of(context).size.width;
            final panelW = screenW - 32;
            final alignX = ((widget.btnCenterX - 16) / panelW) * 2 - 1;
            final clampedAlignX = alignX.clamp(-1.0, 1.0);

            return Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.35 * _fadeAnim.value),
                  ),
                ),
                Positioned(
                  top: widget.topY + 32,
                  left: 16,
                  right: 16,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: ScaleTransition(
                        scale: _scaleAnim,
                        alignment: Alignment(clampedAlignX, -1.0),
                        child: _buildPanel(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPanel() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          height: 260,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(0.35),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 52)),
              const SizedBox(height: 14),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Basit stat kartı ──
class _MiniStatCard extends StatefulWidget {
  final String icon;
  final Widget? iconWidget;
  final String? value;
  final String label;
  final VoidCallback? onTap;

  const _MiniStatCard({
    super.key,
    required this.icon,
    this.iconWidget,
    this.value,
    required this.label,
    this.onTap,
  });

  @override
  State<_MiniStatCard> createState() => _MiniStatCardState();
}

class _MiniStatCardState extends State<_MiniStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 250),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.value != null;

    return GestureDetector(
      onTapDown: (_) => _scaleCtrl.forward(),
      onTapUp: (_) {
        Future.delayed(const Duration(milliseconds: 80), () {
          _scaleCtrl.reverse();
          widget.onTap?.call();
        });
      },
      onTapCancel: () => _scaleCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 0.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                child: hasValue
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Center(
                              child: widget.iconWidget ?? Text(widget.icon, style: const TextStyle(fontSize: 16)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.value!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textWhite,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  widget.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.textGrey,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Center(
                              child: widget.iconWidget ?? Text(widget.icon, style: const TextStyle(fontSize: 16)),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              widget.label,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                            ),
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

// ── Koleksiyon Overlay — sahip olunan kurabiyeleri gösterir ──
class _CollectionOverlay extends StatefulWidget {
  final double topY;
  final double btnCenterX;
  final String? selectedCookieId;
  final ValueChanged<String>? onCookieSelected;
  final ValueChanged<String>? onCookieNavigate;

  const _CollectionOverlay({
    required this.topY,
    required this.btnCenterX,
    this.selectedCookieId,
    this.onCookieSelected,
    this.onCookieNavigate,
  });

  @override
  State<_CollectionOverlay> createState() => _CollectionOverlayState();
}

class _CollectionOverlayState extends State<_CollectionOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<Offset> _slideAnim;

  List<CookieCard> _ownedCookies = [];
  bool _loading = true;

  static const Map<String, String> _cookieImageMap = {
    'spring_wreath': 'assets/images/cookies/spring_wreath.png',
    'lucky_clover': 'assets/images/cookies/lucky_clover.png',
    'royal_hearts': 'assets/images/cookies/royal_hearts.png',
    'evil_eye': 'assets/images/cookies/evil_eye.png',
    'pizza_party': 'assets/images/cookies/pizza_party.png',
    'sakura_bloom': 'assets/images/cookies/sakura_bloom.png',
    'blue_porcelain': 'assets/images/cookies/blue_porcelain.png',
    'pink_blossom': 'assets/images/cookies/pink_blossom.png',
    'fortune_cat': 'assets/images/cookies/fortune_cat.png',
    'wildflower': 'assets/images/cookies/wildflower.png',
    'cupid_ribbon': 'assets/images/cookies/cupid_ribbon.png',
    'panda_bamboo': 'assets/images/cookies/panda_bamboo.png',
    'ramadan_cute': 'assets/images/cookies/ramadan_cute.png',
    'enchanted_forest': 'assets/images/cookies/enchanted_forest.png',
    'golden_arabesque': 'assets/images/cookies/golden_arabesque.png',
    'midnight_mosaic': 'assets/images/cookies/midnight_mosaic.png',
    'pearl_lace': 'assets/images/cookies/pearl_lace.png',
    'golden_sakura': 'assets/images/cookies/golden_sakura.png',
    'dragon_phoenix': 'assets/images/cookies/dragon_phoenix.png',
    'gold_beasts': 'assets/images/cookies/gold_beasts.png',
  };

  static const Set<String> _paidCookieIds = {
    'golden_arabesque',
    'midnight_mosaic',
    'pearl_lace',
    'golden_sakura',
    'dragon_phoenix',
    'gold_beasts',
  };

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero)
        .animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _ctrl.forward();
    _loadOwnedCookies();
  }

  Future<void> _loadOwnedCookies() async {
    final collection = await StorageService.getCookieCollection();
    final owned =
        collection.where((c) => c.firstObtainedDate != null).toList();
    // Çok kırılandan aza doğru sırala
    owned.sort((a, b) => b.countObtained.compareTo(a.countObtained));
    if (mounted) {
      setState(() {
        _ownedCookies = owned;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool _closing = false;
  OverlayEntry? _contextMenuOverlay;
  bool _menuActive = false;
  final ValueNotifier<int> _hoveredIndex = ValueNotifier(-1); // -1: yok, 0: sabitle, 1: gönder
  double _menuLeft = 0;
  double _menuTop = 0;
  static const double _menuW = 150.0;
  static const double _menuH = 36.0;
  String? _contextCookieId;

  void _close() {
    if (_closing) return;
    _closing = true;
    _removeContextMenu();
    _ctrl.reverse().then((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  void _closeImmediate() {
    if (_closing) return;
    _closing = true;
    _removeContextMenu();
    if (mounted) Navigator.pop(context);
  }

  void _removeContextMenu() {
    _contextMenuOverlay?.remove();
    _contextMenuOverlay = null;
    _hoveredIndex.value = -1;
    _contextCookieId = null;
    if (_menuActive) {
      _menuActive = false;
      if (mounted) setState(() {});
    }
  }

  int _hitTestMenu(Offset globalPos) {
    final dx = globalPos.dx;
    final dy = globalPos.dy;
    if (dy < _menuTop || dy > _menuTop + _menuH) return -1;
    if (dx < _menuLeft || dx > _menuLeft + _menuW) return -1;
    // Sol yarı = Sabitle (0), Sağ yarı = Gönder (1)
    if (dx < _menuLeft + _menuW / 2) return 0;
    return 1;
  }

  void _onMenuMoveUpdate(Offset globalPos) {
    _hoveredIndex.value = _hitTestMenu(globalPos);
  }

  void _onMenuRelease(Offset globalPos, String cookieId, bool isTr) {
    final hit = _hitTestMenu(globalPos);
    _removeContextMenu();

    if (hit == 0) {
      // Sabitle
      HapticFeedback.selectionClick();
      widget.onCookieSelected?.call(cookieId);
      _close();
    } else if (hit == 1) {
      // Gönder — koleksiyon panelini kapat, mektup panelini aç
      HapticFeedback.selectionClick();
      final nav = Navigator.of(context);
      final screen = MediaQuery.of(context).size;
      _close();
      Future.delayed(const Duration(milliseconds: 400), () {
        final rect = Rect.fromCenter(
          center: Offset(screen.width / 2, screen.height / 2),
          width: 40,
          height: 40,
        );
        nav.push(
          PageRouteBuilder(
            opaque: false,
            barrierDismissible: false,
            pageBuilder: (context, _, __) => OwlLetterPage(buttonRect: rect),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      });
    }
  }

  void _showCookieContextMenu(
    BuildContext ctx,
    String cookieId,
    String cookieName,
    String? imagePath,
    bool isTr,
    Offset globalPosition,
  ) {
    _removeContextMenu();
    _contextCookieId = cookieId;

    final overlay = Overlay.of(ctx);
    final screenSize = MediaQuery.of(ctx).size;

    _menuLeft = globalPosition.dx - _menuW / 2;
    _menuTop = globalPosition.dy - 56;

    if (_menuLeft < 8) _menuLeft = 8;
    if (_menuLeft + _menuW > screenSize.width - 8) _menuLeft = screenSize.width - _menuW - 8;
    if (_menuTop < 40) _menuTop = globalPosition.dy + 20;

    _contextMenuOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: _menuLeft,
        top: _menuTop,
        child: Material(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                width: _menuW,
                height: _menuH,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ValueListenableBuilder<int>(
                  valueListenable: _hoveredIndex,
                  builder: (context, hovered, _) {
                    return Row(
                      children: [
                        // Sabitle
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: hovered == 0
                                  ? Colors.white.withOpacity(0.15)
                                  : Colors.transparent,
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(12),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              isTr ? '📌 Sabitle' : '📌 Pin',
                              style: TextStyle(
                                color: Colors.white.withOpacity(hovered == 0 ? 1.0 : 0.9),
                                fontSize: 11,
                                fontWeight: hovered == 0 ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 0.5,
                          height: 20,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        // Gönder
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: hovered == 1
                                  ? Colors.white.withOpacity(0.15)
                                  : Colors.transparent,
                              borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(12),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              isTr ? '✉️ Gönder' : '✉️ Send',
                              style: TextStyle(
                                color: Colors.white.withOpacity(hovered == 1 ? 1.0 : 0.9),
                                fontSize: 11,
                                fontWeight: hovered == 1 ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_contextMenuOverlay!);
    _menuActive = true;
    setState(() {});
  }

  String _cookieNameLocalized(String id, String fallback, String languageCode) {
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
      'dragon_phoenix': 'Dragon & Phoenix',
      'gold_beasts': 'Gold Beasts',
    };
    if (languageCode == 'tr') return namesTr[id] ?? fallback;
    return namesEn[id] ?? fallback;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isTr = l10n.localeName == 'tr';
    final languageCode = isTr ? 'tr' : 'en';

    return Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) {
            final screenW = MediaQuery.of(context).size.width;
            final screenH = MediaQuery.of(context).size.height;
            final panelW = screenW - 32;
            final alignX =
                ((widget.btnCenterX - 16) / panelW) * 2 - 1;
            final clampedAlignX = alignX.clamp(-1.0, 1.0);
            final maxPanelH = screenH - widget.topY - 80;

            return Stack(
              children: [
                // Arka plan — dokunulunca kapat
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _close,
                    child: Container(
                      color:
                          Colors.black.withOpacity(0.35 * _fadeAnim.value),
                    ),
                  ),
                ),
                // Panel — scroll ve tap çalışır
                Positioned(
                  top: widget.topY + 32,
                  left: 16,
                  right: 16,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: ScaleTransition(
                        scale: _scaleAnim,
                        alignment: Alignment(clampedAlignX, -1.0),
                        child: _buildPanel(
                          isTr,
                          languageCode,
                          maxPanelH,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
    );
  }

  Widget _buildPanel(bool isTr, String languageCode, double maxH) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          height: 260,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(0.35),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Başlık
              Text(
                _cookieNameLocalized(
                  widget.selectedCookieId ?? '',
                  isTr ? 'Kurabiyelerim' : 'My Cookies',
                  languageCode,
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isTr
                    ? '${_ownedCookies.length} çeşit · dokun → sabitle'
                    : '${_ownedCookies.length} types · tap → pin',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.45),
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              // Kurabiye listesi
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                )
              else if (_ownedCookies.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    isTr
                        ? 'Henüz koleksiyonunda kurabiye yok.\nAna sayfadan kurabiye kırarak başla!'
                        : 'No cookies in your collection yet.\nStart cracking cookies from the home page!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                )
              else
                Expanded(
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.white,
                          Colors.white,
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.12, 0.85, 1.0],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: GridView.builder(
                      physics: _menuActive
                          ? const NeverScrollableScrollPhysics()
                          : null,
                      padding: const EdgeInsets.only(top: 4, bottom: 18),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _ownedCookies.length,
                      itemBuilder: (context, index) {
                        final card = _ownedCookies[index];
                        final imagePath = _cookieImageMap[card.id];
                        final isPaid = _paidCookieIds.contains(card.id);
                        final name = _cookieNameLocalized(
                          card.id,
                          card.name,
                          languageCode,
                        );

                        return _CookieGridItem(
                          cookieId: card.id,
                          name: name,
                          imagePath: imagePath,
                          isPaid: isPaid,
                          count: card.countObtained,
                          isTr: isTr,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            widget.onCookieNavigate?.call(card.id);
                            _close();
                          },
                          onLongPressStart: (details) {
                            HapticFeedback.mediumImpact();
                            _showCookieContextMenu(
                              context,
                              card.id,
                              name,
                              imagePath,
                              isTr,
                              details.globalPosition,
                            );
                          },
                          onLongPressMoveUpdate: (details) {
                            _onMenuMoveUpdate(details.globalPosition);
                          },
                          onLongPressEnd: (details) {
                            _onMenuRelease(details.globalPosition, card.id, isTr);
                          },
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

// ── Kurabiye grid öğesi — basılı tutma scale efektli ──
class _CookieGridItem extends StatefulWidget {
  final String cookieId;
  final String name;
  final String? imagePath;
  final bool isPaid;
  final int count;
  final bool isTr;
  final VoidCallback? onTap;
  final void Function(LongPressStartDetails) onLongPressStart;
  final void Function(LongPressMoveUpdateDetails) onLongPressMoveUpdate;
  final void Function(LongPressEndDetails) onLongPressEnd;

  const _CookieGridItem({
    required this.cookieId,
    required this.name,
    required this.imagePath,
    required this.isPaid,
    required this.count,
    required this.isTr,
    this.onTap,
    required this.onLongPressStart,
    required this.onLongPressMoveUpdate,
    required this.onLongPressEnd,
  });

  @override
  State<_CookieGridItem> createState() => _CookieGridItemState();
}

class _CookieGridItemState extends State<_CookieGridItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  Timer? _longPressTimer;
  Offset? _startPos;
  bool _longPressTriggered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 250),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent e) {
    _ctrl.forward();
    _startPos = e.position;
    _longPressTriggered = false;
    _longPressTimer = Timer(const Duration(milliseconds: 120), () {
      _longPressTriggered = true;
      HapticFeedback.mediumImpact();
      widget.onLongPressStart(
        LongPressStartDetails(globalPosition: _startPos!),
      );
    });
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (_longPressTriggered) {
      widget.onLongPressMoveUpdate(
        LongPressMoveUpdateDetails(
          globalPosition: e.position,
          localPosition: e.localPosition,
        ),
      );
    } else if (_startPos != null) {
      // Parmak hareket ettiyse scroll intent — timer'ı iptal et
      final delta = (e.position - _startPos!).distance;
      if (delta > 8) {
        _longPressTimer?.cancel();
        _ctrl.reverse();
        _startPos = null;
      }
    }
  }

  void _onPointerUp(PointerUpEvent e) {
    _longPressTimer?.cancel();
    _ctrl.reverse();
    if (_longPressTriggered) {
      widget.onLongPressEnd(
        LongPressEndDetails(globalPosition: e.position),
      );
      _longPressTriggered = false;
    } else if (_startPos != null) {
      // Kısa tıklama — yönlendir
      widget.onTap?.call();
    }
    _startPos = null;
  }

  void _onPointerCancel(PointerCancelEvent e) {
    _longPressTimer?.cancel();
    _ctrl.reverse();
    _longPressTriggered = false;
    _startPos = null;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: widget.isPaid
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFFD700).withOpacity(0.7),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.25),
                          blurRadius: 10,
                        ),
                      ],
                    )
                  : null,
              child: Center(
                child: widget.imagePath != null
                    ? Image.asset(
                        widget.imagePath!,
                        width: 36,
                        height: 36,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stack) => const Text(
                          '🥠',
                          style: TextStyle(fontSize: 20),
                        ),
                      )
                    : const Text(
                        '🥠',
                        style: TextStyle(fontSize: 20),
                      ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              widget.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: widget.isPaid
                    ? const Color(0xFFFFD700).withOpacity(0.9)
                    : Colors.white.withOpacity(0.85),
                fontSize: 8,
                fontWeight: widget.isPaid ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
            Text(
              'x${widget.count}',
              style: TextStyle(
                color: widget.isPaid
                    ? const Color(0xFFFFD700).withOpacity(0.5)
                    : Colors.white.withOpacity(0.4),
                fontSize: 7,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
