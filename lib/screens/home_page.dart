import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';
import '../constants/colors.dart';
import '../theme/app_theme.dart';
import '../widgets/mini_stats_row.dart';
import '../widgets/cookie_section.dart';
import '../widgets/cookie_selector.dart';
import '../widgets/daily_tip_card.dart';
import '../widgets/bento_grid.dart';
import '../widgets/quote_banner.dart';
import '../widgets/daily_horoscope_card.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/fade_page_route.dart';
import 'profile_page.dart';
import 'collection_page.dart';

class HomePage extends StatefulWidget {
  final bool showBottomNav;
  final ValueChanged<int>? onNavTapOverride;

  const HomePage({super.key, this.showBottomNav = true, this.onNavTapOverride});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentNavIndex = 0;
  String _selectedCookieEmoji = '🏯'; // Default cookie emoji
  int _selectedCookieIndex = 0; // Seçili cookie index'i (cookie selector için)
  final GlobalKey<State<CookieSection>> _cookieSectionKey =
      GlobalKey<State<CookieSection>>();

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
    // Cookie selector'dan seçim yapıldığında
    setState(() {
      _selectedCookieEmoji = emoji;
      // Seçili cookie'nin index'ini bul
      _selectedCookieIndex = _getCookieIndex(emoji);
    });
    // Açık bir şans mesajı varsa kapat
    (_cookieSectionKey.currentState as dynamic)?.hideFortune();
  }

  // Kurabiye bazlı arka plan gradientleri (yumuşak ve subtle)
  LinearGradient _getCookieGradient(String emoji) {
    switch (emoji) {
      case '🏯': // Torii - Kırmızı/Altın (yumuşak)
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D0F1A),
            Color(0xFF1A1520),
            Color(0xFF201518),
            Color(0xFF1A1515),
            Color(0xFF0D0F1A),
          ],
        );
      case '🎃': // Cadılar Bayramı - Turuncu/Mor (yumuşak)
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D0A15),
            Color(0xFF15101A),
            Color(0xFF1A1018),
            Color(0xFF1A1510),
            Color(0xFF0D0A15),
          ],
        );
      case '🔮': // Mistik - Mor (yumuşak)
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D0A18),
            Color(0xFF12101F),
            Color(0xFF181525),
            Color(0xFF12101F),
            Color(0xFF0D0A18),
          ],
        );
      case '🐉': // Ejder - Kırmızı (yumuşak)
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F0A0A),
            Color(0xFF15100E),
            Color(0xFF1A1210),
            Color(0xFF15100E),
            Color(0xFF0F0A0A),
          ],
        );
      case '🍀': // Şans - Yeşil (yumuşak)
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A0F0D),
            Color(0xFF0E1510),
            Color(0xFF101A14),
            Color(0xFF0E1510),
            Color(0xFF0A0F0D),
          ],
        );
      case '💎': // Elmas - Mavi (yumuşak)
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A0D15),
            Color(0xFF0E1520),
            Color(0xFF101A28),
            Color(0xFF0E1520),
            Color(0xFF0A0D15),
          ],
        );
      case '🔥': // Ateş - Turuncu/Kırmızı (yumuşak)
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F0A08),
            Color(0xFF18100A),
            Color(0xFF1F150C),
            Color(0xFF18100A),
            Color(0xFF0F0A08),
          ],
        );
      case '🦋': // Kelebek - Mavi/Mor (yumuşak)
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A0A15),
            Color(0xFF0E1018),
            Color(0xFF12151F),
            Color(0xFF0E1018),
            Color(0xFF0A0A15),
          ],
        );
      case '🦄': // Tekboynuz - Pembe/Mor (yumuşak)
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F0A12),
            Color(0xFF150E18),
            Color(0xFF1A101F),
            Color(0xFF150E18),
            Color(0xFF0F0A12),
          ],
        );
      case '🌈': // Gökkuşağı - Çok renkli (yumuşak)
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D0A12),
            Color(0xFF100E18),
            Color(0xFF12101A),
            Color(0xFF100E18),
            Color(0xFF0D0A12),
          ],
        );
      default: // Varsayılan - Orijinal koyu mavi
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
  }

  // Cookie emoji'den index bul - CookieSelector'daki _cookieTypes listesine göre
  int _getCookieIndex(String emoji) {
    // CookieSelector'daki _cookieTypes listesindeki emojileri kullan
    const cookieTypes = [
      '🏯',
      '🎃',
      '🥠',
      '🍪',
      '⭐',
      '🔮',
      '🐉',
      '🦋',
      '🎭',
      '🍀',
      '💎',
      '🔥',
      '⚡',
      '🌈',
      '👁️',
      '🎪',
      '🦄',
      '🐱',
      '🌺',
    ];
    final index = cookieTypes.indexOf(emoji);
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
        FadePageRoute(page: const CollectionPage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        FadePageRoute(page: const ProfilePage()),
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
                SafeArea(
                  bottom: false,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap:
                        _hideFortune, // Ekranın herhangi bir yerine tıklayınca mesajı kapat
                    child: SingleChildScrollView(
                      // Genel dikey boşlukları azaltarak tüm içeriği yukarı çek
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      clipBehavior:
                          Clip.none, // Glow efektinin kesilmemesi için
                      child: Transform.translate(
                        offset: const Offset(
                          0,
                          0,
                        ), // Yukarı çekme yok, biraz aşağıda kalsın
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header (artık scroll edilebilir - sayfa ile birlikte kayıp gidiyor)
                            _buildHeader(l10n),
                            const SizedBox(height: 22),
                            // Mini Stats (Header'dan hemen sonra)
                            const MiniStatsRow(),
                            const SizedBox(height: 28),
                            // Kurabiye Section - Tam ortada, biraz yukarı
                            Transform.translate(
                              offset: const Offset(0, -40),
                              child: Center(
                                child: CookieSection(
                                  key: _cookieSectionKey,
                                  onCookieTapped: _refreshStats,
                                  selectedCookieEmoji: _selectedCookieEmoji,
                                ),
                              ),
                            ),
                            // Cookie Selector (HTML'de cookie'den hemen sonra)
                            Transform.translate(
                              offset: const Offset(0, -60),
                              child: RepaintBoundary(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 0,
                                  ), // Yukarıda
                                  child: CookieSelector(
                                    key: const ValueKey(
                                      'cookie_selector_fixed',
                                    ), // Sabit key - state korunur
                                    initialSelectedIndex:
                                        _selectedCookieIndex, // Seçili index - cookie tıklama ile değişmez
                                    onCookieSelected: _onCookieSelected,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 0),
                            // Günün Önerisi ve aşağısını yukarı taşı
                            Transform.translate(
                              offset: const Offset(0, -36),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const DailyTipCard(),
                                  const BentoGrid(),
                                  const SizedBox(height: 16),
                                  const QuoteBanner(),
                                  const DailyHoroscopeCard(),
                                  const SizedBox(height: 0),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Görseldeki gibi büyük beyaz başlık
            Text(
              l10n.homeGreeting,
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 22, // Görselde orantılı
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            // Görseldeki gibi küçük gri metin
            Text(
              l10n.homeFeeling,
              style: TextStyle(
                color: AppColors.textGrey.withOpacity(
                  0.8,
                ), // Görselde biraz daha koyu
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
            ),
          ],
        ),
        // Turuncu cam panel görünümü (daha parlak ve şık)
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryOrange.withOpacity(0.9),
                    AppColors.primaryOrange.withOpacity(0.55),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryOrange.withOpacity(0.55),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // üst highlight
                  Positioned(
                    left: 6,
                    right: 6,
                    top: 6,
                    height: 14,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.45),
                            Colors.white.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Center(
                    child: Text('🦉', style: TextStyle(fontSize: 22)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
