import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';
import '../constants/colors.dart';
import '../screens/zodiac_hub_page.dart';
import '../widgets/fade_page_route.dart';

class DailyHoroscopeCard extends StatefulWidget {
  const DailyHoroscopeCard({super.key});

  @override
  State<DailyHoroscopeCard> createState() => _DailyHoroscopeCardState();
}

class _DailyHoroscopeCardState extends State<DailyHoroscopeCard> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  int _activeIndex = 0; // 0: Batı, 1: Asya, 2: Maya

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    if (_activeIndex == index) return;
    HapticFeedback.lightImpact();
    setState(() {
      _activeIndex = index;
    });
  }

  void _navigateToDetailPage() {
    Navigator.push(
      context,
      SwipeFadePageRoute(
        page: ZodiacHubPage(autoOpenIndex: _activeIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isTr = l10n.localeName == 'tr';

    // Konsept başlığı
    final String title = isTr ? 'Günün Enerjisi' : 'Today\'s Energy';

    // Özlü günlük yorumlar
    final List<Map<String, dynamic>> insights = isTr 
        ? [
            {
              'title': 'Batı Astrolojisi',
              'icon': Icons.flare_outlined,
              'text': 'Yıldızlar kariyerin için hizalanıyor. Hızlı ve kararlı adımlar atmalısın.',
            },
            {
              'title': 'Asya Bilgeliği',
              'icon': Icons.brightness_medium_outlined,
              'text': 'Su elementi devrede. Sezgilerin çok güçlü, bugün sadece kalbini dinle.',
            },
            {
              'title': 'Maya Ruhu',
              'icon': Icons.filter_vintage_outlined,
              'text': 'Ton 4 aktif. Hayatında düzen kurmak ve plan yapmak için mükemmel bir gün.',
            },
          ]
        : [
            {
              'title': 'Western Ast.',
              'icon': Icons.flare_outlined,
              'text': 'Stars align for your career. Take swift and decisive steps.',
            },
            {
              'title': 'Asian Wisdom',
              'icon': Icons.brightness_medium_outlined,
              'text': 'Water element is active. Your intuition is strong, just listen to your heart.',
            },
            {
              'title': 'Mayan Spirit',
              'icon': Icons.filter_vintage_outlined,
              'text': 'Tone 4 is active. A perfect day to establish order and plan your life.',
            },
          ];

    return GestureDetector(
      onTap: _navigateToDetailPage,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          // Uyumlu Cam Hissi (Glassmorphism)
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.12),
              Colors.white.withOpacity(0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.18),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Arka plan animasyonlu parlama
              Positioned(
                right: -40,
                bottom: -40,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primaryOrange.withOpacity(0.15),
                              AppColors.primaryOrange.withOpacity(0.02),
                              Colors.transparent,
                            ],
                            stops: const [0.1, 0.5, 1.0],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Area
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.explore_rounded,
                          color: AppColors.primaryOrange,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        // Küçük navigasyon ikonu
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primaryOrange.withOpacity(0.35),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(isTr ? 'Keşfet' : 'Explore', style: const TextStyle(color: AppColors.primaryOrange, fontSize: 11, fontWeight: FontWeight.w700)),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primaryOrange, size: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Etkileşimli Tab (Sekmeler) Bölümü
                    Row(
                      children: List.generate(insights.length, (index) {
                        final isActive = _activeIndex == index;
                        final insight = insights[index];
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => _onTabChanged(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              margin: EdgeInsets.only(right: index < insights.length - 1 ? 8 : 0),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isActive 
                                    ? AppColors.primaryOrange.withOpacity(0.15) 
                                    : Colors.white.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isActive 
                                      ? AppColors.primaryOrange.withOpacity(0.5) 
                                      : Colors.white.withOpacity(0.08),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(
                                      insight['icon'] as IconData,
                                      key: ValueKey<bool>(isActive),
                                      color: isActive ? AppColors.primaryOrange : Colors.white54,
                                      size: isActive ? 20 : 18,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    insight['title'] as String,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isActive ? Colors.white : Colors.white54,
                                      fontSize: 10,
                                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    
                    const SizedBox(height: 16),

                    // İçerik (AnimatedSwitcher ile yumuşak geçiş)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.1),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          )),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        key: ValueKey<int>(_activeIndex),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white10,
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                color: AppColors.primaryOrange,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                insights[_activeIndex]['text'] as String,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 13,
                                  height: 1.5,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


