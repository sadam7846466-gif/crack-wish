import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';
import '../constants/colors.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../services/supabase_owl_service.dart';
import '../services/sound_service.dart';
import '../services/season_config.dart';
import '../widgets/mini_stats_row.dart';
import '../widgets/cookie_section.dart';
import '../widgets/cookie_selector.dart';
import '../widgets/daily_tip_card.dart';
import '../widgets/bento_grid.dart';
import '../widgets/cosmic_badge.dart';
import '../widgets/daily_horoscope_card.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/fade_page_route.dart';
import 'profile_page.dart';
import 'collection_page.dart';
import 'owl_letter_page.dart';
import '../widgets/cosmic_toast.dart';

class HomePage extends StatefulWidget {
  final bool showBottomNav;
  final ValueChanged<int>? onNavTapOverride;

  const HomePage({super.key, this.showBottomNav = true, this.onNavTapOverride});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentNavIndex = 0;
  String _selectedCookieEmoji = 'spring_wreath'; // Default cookie ID
  int _selectedCookieIndex = 0; // Seçili cookie index'i (cookie selector için)
  int _inventoryVersion = 0;
  final GlobalKey<State<CookieSection>> _cookieSectionKey =
      GlobalKey<State<CookieSection>>();
  final GlobalKey _owlButtonKey = GlobalKey();
  int _unreadOwlCount = 0;
  late String _randomSubtitle;
  late bool _showTimeSubtitle;
  String? _userName;
  static final _mottledPainter = _MottledPainter();

  static const _subtitles = [
    'Kır, Oku, Gülümse.',
    'Şansın cebinde.',
    'Günün mesajı: Sen.',
    'Bir kırık, bir sürpriz.',
    'Küçük bir kurabiye, büyük bir his.',
    'Kader değil, tatlı bir ipucu.',
    'Bugün ne diyor şansın?',
    'Aç, keşfet, devam et.',
    'Şans bir tık uzağında.',
    'Her kırışta yeni bir başlangıç.',
    'Mesajını bul.',
    'Rastgele değil… tam sana göre.',
    'Şansını kır, gününü yakala.',
    'Gülümseten minik kehanetler.',
    'Sürpriz iyi gelir.',
  ];

  late List<String> _cookieTypes;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _cookieTypes = [
      ...SeasonConfig.getWeeklyFreeCookies().map((c) => c['id'] as String),
      ...SeasonConfig.getWeeklyPaidCookies().map((c) => c['id'] as String),
    ];
    _randomSubtitle = _subtitles[math.Random().nextInt(_subtitles.length)];
    _showTimeSubtitle = math.Random().nextBool();
    _checkUnreadOwlLetters();
    _loadSelectedCookie();
    _loadUserName();
    SupabaseOwlService().addListener(_onMockOwlUpdate);
    
    // Uygulama açılışında gelen sesleri engellemek için 3 saniyelik bir koruma kalkanı
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _isFirstLoad = false;
    });
    
    // Milestones kontrolünü gecikmeli çalıştır ki UI render edilsin
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkMilestones();
    });
  }

  Future<void> _loadUserName() async {
    final name = await StorageService.getUserName();
    if (mounted) {
      setState(() => _userName = name);
    }
  }

  void _onMockOwlUpdate() {
    if (!mounted) return;
    // Sadece unread count değiştiyse rebuild et — gereksiz zıplamayı önler
    _checkUnreadOwlLetters();
  }

  @override
  void dispose() {
    SupabaseOwlService().removeListener(_onMockOwlUpdate);
    super.dispose();
  }

  Future<void> _checkMilestones() async {
    final appOpenDays = await StorageService.getAppOpenDays();
    final claimedMilestones = await StorageService.getClaimedMilestones();
    
    final int totalDays = appOpenDays.length;
    final List<int> thresholds = [7, 14, 30, 50, 100, 365];
    
    for (final threshold in thresholds) {
      if (totalDays >= threshold && !claimedMilestones.contains(threshold)) {
        // Hedefe ulaşılmış ve toplanmamış!
        if (mounted) {
          _showMilestoneCelebration(threshold);
        }
        break; // Aynı anda sadece bir tane kutla (en düşüğü önce)
      }
    }
  }

  void _showMilestoneCelebration(int threshold) {
    HapticFeedback.heavyImpact();
    
    String rewardText = "";
    IconData rewardIcon = Icons.auto_awesome;
    Color rewardColor = const Color(0xFFC084FC);
    
    if (threshold == 7) { rewardText = "+15 Aura"; }
    else if (threshold == 14) { rewardText = "+30 Aura"; }
    else if (threshold == 30) { rewardText = "+1 Ruh Taşı"; rewardIcon = Icons.diamond_rounded; rewardColor = const Color(0xFF60A5FA); }
    else if (threshold == 50) { rewardText = "+2 Ruh Taşı"; rewardIcon = Icons.diamond_rounded; rewardColor = const Color(0xFF60A5FA); }
    else if (threshold == 100) { rewardText = "+3 Ruh Taşı"; rewardIcon = Icons.diamond_rounded; rewardColor = const Color(0xFF60A5FA); }
    else if (threshold == 365) { rewardText = "+5 Ruh Taşı"; rewardIcon = Icons.diamond_rounded; rewardColor = const Color(0xFF60A5FA); }

    CosmicToast.show(
      context: context,
      title: 'İnanılmaz Odak!',
      message: 'Günlük serin tam $threshold güne ulaştı.',
      reward: rewardText,
      icon: rewardIcon,
      iconColor: const Color(0xFFFF6B6B),
      rewardColor: rewardColor,
    );
    
    // Arka planda topla
    StorageService.claimMilestone(threshold);
  }

  Future<void> _loadSelectedCookie() async {
    final savedCookie = await StorageService.getSelectedCookie();
    
    final collection = await StorageService.getCookieCollection();
    final ownedIds = collection.where((c) => c.countObtained > 0).map((c) => c.id).toSet();
    
    final showcaseIds = [
      ...SeasonConfig.getWeeklyFreeCookies().map((c) => c['id'] as String),
      ...SeasonConfig.getWeeklyPaidCookies().map((c) => c['id'] as String),
    ];
    final allCookies = SeasonConfig.getAllCookies().map((c) => c['id'] as String).toList();
    final ownedButNotShown = allCookies.where((id) {
      return ownedIds.contains(id) && !showcaseIds.contains(id);
    }).toList();

    if (mounted) {
      setState(() {
        _cookieTypes = [...showcaseIds, ...ownedButNotShown];
        
        if (!_cookieTypes.contains(savedCookie) && _cookieTypes.isNotEmpty) {
          _selectedCookieEmoji = _cookieTypes[0];
          _selectedCookieIndex = 0;
          StorageService.setSelectedCookie(_cookieTypes[0]);
        } else {
          _selectedCookieEmoji = savedCookie;
          _selectedCookieIndex = _getCookieIndex(savedCookie);
        }
      });
    }
  }

  void _playOwlNotificationSound() async {
    try {
      await SoundService().playOwlLetter();
    } catch (e) {
      debugPrint('Bildirim sesi oynatılamadı: $e');
    }
  }

  void _checkUnreadOwlLetters() {
    final count = SupabaseOwlService().unreadLetterCount + SupabaseOwlService().pendingRequestCount;
    if (!mounted) return;
    
    // Eğer yeni mektup geldiyse ve uygulama yeni açılmadıysa
    if (!_isFirstLoad) {
      if (_unreadOwlCount > 0 && count > _unreadOwlCount) {
        _playOwlNotificationSound();
      } else if (_unreadOwlCount == 0 && count > 0) {
        _playOwlNotificationSound();
      }
    }

    // Sadece değer değiştiyse rebuild et — gereksiz rebuild'leri önle
    if (_unreadOwlCount != count) {
      setState(() => _unreadOwlCount = count);
    }
  }

  void _openOwlLetterPage() {
    HapticFeedback.mediumImpact();
    Rect rect = const Rect.fromLTWH(0, 0, 52, 52);
    final box = _owlButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      final pos = box.localToGlobal(Offset.zero);
      final size = box.size;
      rect = Rect.fromLTWH(pos.dx, pos.dy, size.width, size.height);
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        pageBuilder: (context, _, __) => OwlLetterPage(buttonRect: rect),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    ).then((_) => _checkUnreadOwlLetters());
  }

  void _hideFortune() {
    (_cookieSectionKey.currentState as dynamic)?.hideFortune();
  }

  void _refreshStats() {
    // Cookie tıklanınca stats güncellenir
    // NOT: setState çağırma - bu tüm sayfayı rebuild eder ve cookie selector'ı etkiler
    // MiniStatsRow otomatik olarak güncellenecek (didChangeDependencies veya başka bir yöntemle)
    // Şimdilik boş bırakıyoruz - cookie selector kaymasın
    // İleride MiniStatsRow'a bir StreamController veya ValueNotifier eklenebilir
  }

  void _onCookieSelected(String emoji) {
    // Cookie selector'dan veya koleksiyon panelinden seçim yapıldığında
    setState(() {
      _selectedCookieEmoji = emoji;
      _selectedCookieIndex = _getCookieIndex(emoji);
    });
    // Kalıcı olarak kaydet
    StorageService.setSelectedCookie(emoji);
    // Açık bir şans mesajı varsa kapat
    (_cookieSectionKey.currentState as dynamic)?.hideFortune();
  }

  void _onPurchaseSuccess() {
    if (mounted) {
      setState(() {
        _inventoryVersion++;
      });
    }
  }

  // Kurabiye bazlı arka plan gradienti (tüm görseller için varsayılan)
  LinearGradient _getCookieGradient(String cookieId) {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF0D0F1A),
        Color(0xFF121528),
        Color(0xFF151933),
        Color(0xFF121528),
        Color(0xFF0D0F1A),
      ],
    );
  }

  // Cookie emoji'den index bul - CookieSelector'daki _cookieTypes listesine göre
  int _getCookieIndex(String emoji) {
    final index = _cookieTypes.indexOf(emoji);
    // Emoji bulunamazsa 0 döndür (varsayılan)
    return index >= 0 ? index : 0;
  }

  void _onNavTap(int index) {
    if (widget.onNavTapOverride != null) {
      widget.onNavTapOverride!(index);
      return;
    }
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        SwipeFadePageRoute(page: const CollectionPage()),
      );
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
    
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: ValueListenableBuilder(
        valueListenable: AppThemeController.notifier,
        builder: (context, palette, _) {
          return Container(
            decoration: BoxDecoration(gradient: palette.bgGradient),
            child: Stack(
              children: [
                // Rastgele benekli (mottled) overlay — CustomPainter
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _mottledPainter,
                    ),
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _hideFortune,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                      clipBehavior: Clip.none,
                      child: Transform.translate(
                        offset: const Offset(0, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(l10n),
                            const SizedBox(height: 22),
                            RepaintBoundary(
                              child: MiniStatsRow(
                                onCookieSelected: _onCookieSelected,
                                onCookieNavigate: (cookieId) {
                                  setState(() {
                                    _selectedCookieEmoji = cookieId;
                                    _selectedCookieIndex = _getCookieIndex(cookieId);
                                  });
                                },
                                selectedCookieId: _selectedCookieEmoji,
                              ),
                            ),
                            const SizedBox(height: 28),
                            Transform.translate(
                              offset: const Offset(0, -40),
                              child: Center(
                                child: _SlidingCookie(
                                  emoji: _selectedCookieEmoji,
                                  cookieTypes: _cookieTypes,
                                  currentIndex: _selectedCookieIndex,
                                  onCookieChanged: (emoji, index) {
                                    setState(() {
                                      _selectedCookieEmoji = emoji;
                                      _selectedCookieIndex = index;
                                    });
                                  },
                                  onTapped: _refreshStats,
                                  onPurchaseSuccess: _onPurchaseSuccess,
                                ),
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(0, -60),
                              child: RepaintBoundary(
                                child: CookieSelector(
                                  key: ValueKey('cookie_selector_fixed_$_inventoryVersion'),
                                  initialSelectedIndex: _selectedCookieIndex,
                                  onCookieSelected: _onCookieSelected,
                                ),
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(0, -80),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const DailyTipCard(),
                                  const BentoGrid(),
                                  const SizedBox(height: 16),
                                  const DailyHoroscopeCard(),
                                ],
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
        },
      ),
      // Alt menü: Ekranın dibinde (ekstra SafeArea/padding yok)
      bottomNavigationBar: widget.showBottomNav
          ? BottomNav(currentIndex: _currentNavIndex, onTap: _onNavTap)
          : null,
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    final isTr = l10n.localeName == 'tr';
    final hour = DateTime.now().hour;
    
    final int totalUnread = _unreadOwlCount + SupabaseOwlService().pendingRequestCount + SupabaseOwlService().unreadLetterCount;
    
    String greeting;
    String timeSubtitle;
    IconData timeIcon;
    Color timeColor;
    
    if (hour >= 5 && hour < 12) {
      greeting = isTr ? 'Günaydın' : 'Good Morning';
      timeSubtitle = isTr ? 'Kahvenin yanına taze bir mesaj geldi.' : 'Fresh message with your coffee.';
      timeIcon = Icons.wb_twilight_rounded; // Gündoğumu
      timeColor = const Color(0xFFFFB74D); // Soft Orange
    } else if (hour >= 12 && hour < 18) {
      greeting = isTr ? 'İyi Günler' : 'Good Afternoon';
      timeSubtitle = isTr ? 'Günün koşturmacasına sihirli bir mola.' : 'A magical break in your day.';
      timeIcon = Icons.wb_sunny_rounded; // Dolu, tok bir güneş
      timeColor = const Color(0xFFFFD54F); // Soft Amber
    } else if (hour >= 18 && hour < 22) {
      greeting = isTr ? 'İyi Akşamlar' : 'Good Evening';
      timeSubtitle = isTr ? 'Günün yorgunluğunu atacak tatlı bir kehanet.' : 'A sweet prophecy to unwind.';
      timeIcon = Icons.nights_stay_rounded; // Ay ve bulut (İhtişamlı)
      timeColor = const Color(0xFF9FA8DA); // Soft Indigo
    } else {
      greeting = isTr ? 'İyi Geceler' : 'Good Night';
      timeSubtitle = isTr ? 'Yıldızlar bu gece senin için parlıyor.' : 'The stars shine for you tonight.';
      timeIcon = Icons.bedtime_rounded; // Tok ve net bir Hilal Ay
      timeColor = const Color(0xFF90CAF9); // Soft Blue
    }

    // Eğer isim çok uzunsa ve ekrana sığmıyorsa sadece ilk ismi alalım
    String displayName = _userName ?? '';
    if (displayName.trim().isNotEmpty) {
      displayName = displayName.trim().split(' ').first;
      greeting = '$greeting, $displayName';
    }

    // Yarı rastgele, yarı zamana özel bir alt başlık
    final finalSubtitle = _showTimeSubtitle ? timeSubtitle : _randomSubtitle;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      greeting,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    timeIcon,
                    size: 20,
                    color: timeColor,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                finalSubtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textGrey.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Baykuş butonu — tıklanınca buzlu cam mektup paneli açılır
        _OwlButton(
          key: _owlButtonKey,
          unreadCount: totalUnread,
          onTap: _openOwlLetterPage,
        ),
      ],
    );
  }
}

class _OwlButton extends StatefulWidget {
  final int unreadCount;
  final VoidCallback onTap;

  const _OwlButton({
    super.key,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  State<_OwlButton> createState() => _OwlButtonState();
}

class _OwlButtonState extends State<_OwlButton> {
  bool _pressed = false;
  final GlobalKey _btnKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) setState(() => _pressed = false);
          widget.onTap();
        });
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: RepaintBoundary(
        child: AnimatedScale(
          scale: _pressed ? 0.88 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeInOut,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
                GlassContainer(
                  key: widget.key, // Artık parent'taki GlobalKey'i kullanıyoruz
                  useOwnLayer: true,
                width: 52,
                height: 52,
                settings: const LiquidGlassSettings(
                  thickness: 18,
                  blur: 2,
                  glassColor: Colors.transparent,
                  chromaticAberration: 0.1,
                  lightIntensity: 0.7,
                  ambientStrength: 0.6,
                  refractiveIndex: 1.2,
                  saturation: 1.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFD4B8A0), // Bej
                        Color(0xFF964040), // Kırmızı
                        Color(0xFF2A4A6C), // Mavi
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.45),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF964040).withOpacity(0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 6,
                        right: 6,
                        top: 6,
                        height: 12,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.4),
                                Colors.white.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Image.asset(
                          'assets/images/owl.png',
                          width: 52,
                          height: 52,
                          gaplessPlayback: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Okunmamış mektup badge'i
              if (widget.unreadCount > 0)
                const Positioned(
                  right: 0,
                  top: 0,
                  child: CosmicBadge(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Parmakla sürüklenebilir kurabiye widget'ı
class _SlidingCookie extends StatefulWidget {
  final String emoji;
  final List<String> cookieTypes;
  final int currentIndex;
  final void Function(String emoji, int index) onCookieChanged;
  final VoidCallback onTapped;
  final VoidCallback? onPurchaseSuccess;

  const _SlidingCookie({
    required this.emoji,
    required this.cookieTypes,
    required this.currentIndex,
    required this.onCookieChanged,
    required this.onTapped,
    this.onPurchaseSuccess,
  });

  @override
  State<_SlidingCookie> createState() => _SlidingCookieState();
}

class _SlidingCookieState extends State<_SlidingCookie>
    with SingleTickerProviderStateMixin {
  late AnimationController _snapController;
  double _dragOffset = 0;
  bool _isDragging = false;

  // Geçiş animasyonu için
  String? _outgoingEmoji; // Çıkan kurabiye
  int _swipeDirection = 0; // -1: sola, 1: sağa, 0: yok
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _snapController.addListener(() => setState(() {}));
    _snapController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _outgoingEmoji = null;
          _isTransitioning = false;
          _dragOffset = 0;
          _swipeDirection = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  void _onDragStart(DragStartDetails details) {
    _isDragging = true;
    _snapController.stop();
    _isTransitioning = false;
    _outgoingEmoji = null;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    setState(() {
      _dragOffset += details.delta.dx;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    _isDragging = false;
    final velocity = details.velocity.pixelsPerSecond.dx;
    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.25; // %25 geçince değiştir

    // Hızlı fırlatma veya yeterince sürükleme
    final shouldSwipe = velocity.abs() > 400 || _dragOffset.abs() > threshold;

    if (shouldSwipe) {
      // Hangi yöne? (velocity öncelikli)
      int direction;
      if (velocity.abs() > 400) {
        direction = velocity > 0 ? -1 : 1;
      } else {
        direction = _dragOffset > 0 ? -1 : 1;
      }

      final nextIndex =
          (widget.currentIndex + direction) % widget.cookieTypes.length;
      final safeIndex = nextIndex < 0
          ? widget.cookieTypes.length - 1
          : nextIndex;

      // Çıkan emoji'yi kaydet ve geçiş moduna gir
      _outgoingEmoji = widget.emoji;
      _swipeDirection = direction;
      _isTransitioning = true;

      widget.onCookieChanged(widget.cookieTypes[safeIndex], safeIndex);
      _snapController.forward(from: 0);
    } else {
      // Geri dön (animasyon ile)
      _isTransitioning = false;
      _snapController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final t = Curves.easeOutCubic.transform(_snapController.value);

    // Offset hesaplamaları
    double currentOffset;
    double? outgoingOffset;
    String? sideEmoji;
    double? sideOffset;

    if (_isTransitioning && _outgoingEmoji != null) {
      // Geçiş animasyonu: çıkan kurabiye dışarı, giren kurabiye içeri
      // Çıkan: mevcut pozisyondan ekran dışına
      final outEnd = _swipeDirection > 0 ? -screenWidth : screenWidth;
      outgoingOffset = ui.lerpDouble(_dragOffset, outEnd, t);

      // Giren: ekran dışından merkeze
      final inStart = _swipeDirection > 0 ? screenWidth : -screenWidth;
      currentOffset = ui.lerpDouble(inStart + _dragOffset, 0, t)!;
    } else if (_isDragging || _dragOffset != 0) {
      // Sürükleme veya geri dönüş animasyonu
      if (_snapController.isAnimating) {
        // Geri dönüş animasyonu
        currentOffset = ui.lerpDouble(_dragOffset, 0, t)!;
      } else {
        currentOffset = _dragOffset;
      }

      // Sürükleme sırasında yan kurabiyeyi göster
      if (_dragOffset > 0) {
        // Sağa sürükleme - soldaki kurabiye görünür
        final prevIndex = (widget.currentIndex - 1) < 0
            ? widget.cookieTypes.length - 1
            : widget.currentIndex - 1;
        sideEmoji = widget.cookieTypes[prevIndex];
        sideOffset = currentOffset - screenWidth;
      } else if (_dragOffset < 0) {
        // Sola sürükleme - sağdaki kurabiye görünür
        final nextIndex = (widget.currentIndex + 1) % widget.cookieTypes.length;
        sideEmoji = widget.cookieTypes[nextIndex];
        sideOffset = currentOffset + screenWidth;
      }
    } else {
      currentOffset = 0;
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
           // Kayan kurabiyeler - Sadece gerekli olanlar render edilir (performans)
          SizedBox(
            height: 320, // CookieSection'ın sabit yüksekliği
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Önceki kurabiye - SADECE sürükleme sırasında oluştur
                if (!_isTransitioning && _dragOffset > 0 && sideEmoji != null)
                  Transform.translate(
                    offset: Offset(sideOffset ?? -screenWidth, 0),
                    child: CookieSection(
                      key: ValueKey('side_prev_$sideEmoji'),
                      onCookieTapped: () {},
                      selectedCookieEmoji: sideEmoji!,
                      hideLabels: true,
                      onPurchaseSuccess: widget.onPurchaseSuccess,
                    ),
                  ),
                // Sonraki kurabiye - SADECE sürükleme sırasında oluştur
                if (!_isTransitioning && _dragOffset < 0 && sideEmoji != null)
                  Transform.translate(
                    offset: Offset(sideOffset ?? screenWidth, 0),
                    child: CookieSection(
                      key: ValueKey('side_next_$sideEmoji'),
                      onCookieTapped: () {},
                      selectedCookieEmoji: sideEmoji!,
                      hideLabels: true,
                      onPurchaseSuccess: widget.onPurchaseSuccess,
                    ),
                  ),
                // Çıkan kurabiye - SADECE geçiş animasyonu sırasında oluştur
                if (_isTransitioning && _outgoingEmoji != null)
                  Transform.translate(
                    offset: Offset(outgoingOffset ?? 0, 0),
                    child: CookieSection(
                      key: ValueKey('out_$_outgoingEmoji'),
                      onCookieTapped: () {},
                      selectedCookieEmoji: _outgoingEmoji!,
                      hideLabels: true,
                      onPurchaseSuccess: widget.onPurchaseSuccess,
                    ),
                  ),
                // Mevcut/giren kurabiye - HER ZAMAN render
                Transform.translate(
                  offset: Offset(currentOffset, 0),
                  child: CookieSection(
                    key: ValueKey('current_${widget.emoji}'),
                    onCookieTapped: widget.onTapped,
                    selectedCookieEmoji: widget.emoji,
                    hideLabels: true,
                    onPurchaseSuccess: widget.onPurchaseSuccess,
                  ),
                ),
              ],
            ),
          ),
          // Sabit yazılar (kaymaz)
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.dailyCookieTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.dailyCookieSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

/// 3 renkli (bej, kırmızı, mavi) dairesel geçiş arka planı
class _MottledPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);

    // 3 renk ailesi karışık — bej, kırmızı (ağırlıklı), mavi
    final allColors = [
      // Bej tonları (3)
      const Color(0xFFD4B8A0), // Sıcak bej
      const Color(0xFFC8A890), // Orta bej
      const Color(0xFFE0C8B0), // Açık bej
      // Kırmızı tonları (6) — daha ağırlıklı
      const Color(0xFF8B3A3A), // Koyu şarap
      const Color(0xFF7A3030), // Derin bordo
      const Color(0xFF964040), // Koyu gül
      const Color(0xFFA04848), // Sıcak kırmızı
      const Color(0xFF6E2828), // Karanlık kırmızı
      const Color(0xFF883838), // Şarap kırmızısı
      // Mavi tonları (3)
      const Color(0xFF1A3A5C), // Derin gece mavisi
      const Color(0xFF2A4A6C), // Orta mavi
      const Color(0xFF1E3050), // Koyu teal-mavi
    ];

    // 26 orta boy daire — kırmızı ağırlıklı
    for (int i = 0; i < 26; i++) {
      final color = allColors[rng.nextInt(allColors.length)];
      final opacity = 0.28 + rng.nextDouble() * 0.30; // 0.28 - 0.58
      final radius = 80.0 + rng.nextDouble() * 170.0; // 80 - 250px
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;

      final paint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(x, y),
          radius,
          [
            color.withOpacity(opacity),
            color.withOpacity(opacity * 0.75),
            color.withOpacity(opacity * 0.25),
            color.withOpacity(0),
          ],
          [0.0, 0.45, 0.75, 1.0],
        );

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
