import 'package:flutter/material.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';
import '../constants/colors.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/fade_page_route.dart';
import '../screens/tarot_page.dart';
import '../screens/dream_page.dart';
import '../screens/zodiac_page.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'collection_page.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  int _currentNavIndex = 1;

  void _onNavTap(int index) {
    if (index == _currentNavIndex) return;
    Widget destination;
    switch (index) {
      case 0:
        destination = const HomePage();
        break;
      case 1:
        destination = const CollectionPage();
        break;
      case 2:
        destination = const ProfilePage();
        break;
      default:
        return;
    }
    Navigator.pushReplacement(context, FadePageRoute(page: destination));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.discoverTitle,
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.discoverSubtitle,
                      style: TextStyle(
                        color: AppColors.textWhite50,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FeaturedCard(),
                      const SizedBox(height: 20),
                      Text(
                        l10n.discoverCategories,
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.1,
                        children: [
                          _CategoryCard(
                            icon: '🎴',
                            title: l10n.categoryTarotTitle,
                            desc: l10n.categoryTarotDesc,
                            color: AppColors.primaryPurple,
                            onTap: () {
                              Navigator.push(
                                context,
                                FadePageRoute(
                                  page: const TarotPage(),
                                ),
                              );
                            },
                          ),
                          _CategoryCard(
                            icon: '🌙',
                            title: l10n.categoryDreamTitle,
                            desc: l10n.categoryDreamDesc,
                            color: AppColors.primaryTeal,
                            onTap: () {
                              Navigator.push(
                                context,
                                FadePageRoute(
                                  page: const DreamPage(),
                                ),
                              );
                            },
                          ),
                          _CategoryCard(
                            icon: '⭐',
                            title: l10n.categoryZodiacTitle,
                            desc: l10n.categoryZodiacDesc,
                            color: AppColors.primaryPink,
                            onTap: () {
                              Navigator.push(
                                context,
                                FadePageRoute(
                                  page: const ZodiacPage(),
                                ),
                              );
                            },
                          ),
                          _CategoryCard(
                            icon: '🧠',
                            title: l10n.categoryPersonalityTitle,
                            desc: l10n.categoryPersonalityDesc,
                            color: AppColors.primaryOrange,
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            FadePageRoute(
                              page: const DreamPage(),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF964040).withOpacity(0.30),
                                const Color(0xFFD4B8A0).withOpacity(0.15),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF964040).withOpacity(0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Text(
                                  '💫',
                                  style: TextStyle(fontSize: 36),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.discoverDailySuggestionTitle,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        l10n.discoverDailySuggestionHeadline,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        l10n.discoverDailySuggestionSubtitle,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white.withOpacity(0.6),
                                  size: 20,
                                ),
                              ],
                            ),
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
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryPurple.withOpacity(0.4),
            AppColors.primaryTeal.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 6),
                  Text(
                    l10n.discoverFeaturedTag,
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('🔮', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              l10n.discoverFeaturedTitle,
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.discoverFeaturedSubtitle,
              style: TextStyle(
                color: AppColors.textWhite70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  FadePageRoute(page: const TarotPage()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.ctaStart,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String icon;
  final String title;
  final String desc;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.55),
              color.withOpacity(0.30),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.60), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.40),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(0.65), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.35),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: TextStyle(
                  color: AppColors.textWhite70,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
