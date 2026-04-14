import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../widgets/glass_back_button.dart';
import '../widgets/guidance_booklet.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/fade_page_route.dart';
import 'zodiac_page.dart';
import 'zodiac_chinese_page.dart';
import 'zodiac_mayan_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_service.dart';
import '../services/ad_service.dart';
import 'premium_paywall_page.dart';

class ZodiacHubPage extends StatefulWidget {
  final int? autoOpenIndex;
  const ZodiacHubPage({super.key, this.autoOpenIndex});
  @override
  State<ZodiacHubPage> createState() => _ZodiacHubPageState();
}

class _ZodiacHubPageState extends State<ZodiacHubPage>
    with TickerProviderStateMixin {
  late AnimationController _spin;
  late AnimationController _entrance;
  late Animation<double> _t1, _t2, _t3;

  static const Color _gold = Color(0xFFFFD060);
  static const Color _goldL = Color(0xFFFFE8A1);
  static const Color _goldD = Color(0xFFB07020);
  static const Color _bg = Color(0xFF0F1210);

  bool _isPremiumUser = false;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(vsync: this, duration: const Duration(seconds: 180));
    _entrance = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..forward();
    _t1 = CurvedAnimation(parent: _entrance, curve: const Interval(0, .4, curve: Curves.easeOutCubic));
    _t2 = CurvedAnimation(parent: _entrance, curve: const Interval(.15, .55, curve: Curves.easeOutCubic));
    _t3 = CurvedAnimation(parent: _entrance, curve: const Interval(.3, .7, curve: Curves.easeOutCubic));
    _initPremiumState();
  }

  Future<void> _initPremiumState() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isPremiumUser = prefs.getBool('is_premium_test_mode') ?? false;
      });
    }
  }

  @override
  void dispose() { _spin.dispose(); _entrance.dispose(); super.dispose(); }

  Widget _premiumInfoRow(IconData icon, String text, bool isActive) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? const Color(0xFF22D3EE).withOpacity(0.12)
                : Colors.white.withOpacity(0.05),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isActive
                ? const Color(0xFF22D3EE).withOpacity(0.8)
                : Colors.white.withOpacity(0.3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isActive
                  ? Colors.white.withOpacity(0.75)
                  : Colors.white.withOpacity(0.4),
              fontSize: 13,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showSoulStoneInfoPanel() async {
    final soulStones = await StorageService.getSoulStones();
    if (!mounted) return;
    await showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible: true,
      barrierLabel: 'SoulStoneInfo',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        final panelW = MediaQuery.of(context).size.width * 0.85;
        return Center(
          child: SizedBox(
            width: panelW,
            child: Material(
              type: MaterialType.transparency,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    height: _isPremiumUser ? 320 : 360,
                    alignment: Alignment.topCenter,
                    decoration: BoxDecoration(
                      color: _isPremiumUser
                          ? const Color(0xFF22D3EE).withOpacity(0.08)
                          : Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _isPremiumUser
                            ? const Color(0xFF22D3EE).withOpacity(0.35)
                            : Colors.white.withOpacity(0.25),
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Icon(
                          Icons.diamond_rounded,
                          color: soulStones >= 1
                              ? const Color(0xFF22D3EE)
                              : Colors.white.withOpacity(0.3),
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Ruh Taşların",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF22D3EE).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF22D3EE).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.diamond_outlined,
                                size: 14,
                                color: Color(0xFF22D3EE),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                soulStones > 0
                                      ? "$soulStones Ruh Taşın var"
                                      : "Ruh Taşın bitti",
                                style: const TextStyle(
                                  color: Color(0xFF22D3EE),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _premiumInfoRow(
                          Icons.auto_awesome,
                          "Kozmik Kapı'dan geçiş izni",
                          true,
                        ),
                        const SizedBox(height: 10),
                        _premiumInfoRow(
                          Icons.diamond_outlined,
                          "Her astroloji 1 Ruh Taşı harcar",
                          soulStones >= 1,
                        ),
                        const SizedBox(height: 10),
                        _premiumInfoRow(
                          Icons.workspace_premium,
                          _isPremiumUser
                                ? "Elite ayrıcalığı: Her gece 5 Ruh Taşı yenilenir"
                                : "Elite ile her gece 5 Ruh Taşı kazan",
                          _isPremiumUser,
                        ),

                        if (!_isPremiumUser) ...[
                          const Spacer(),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFF22D3EE,
                              ).withOpacity(0.15),
                              elevation: 0,
                              minimumSize: const Size(double.infinity, 44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: const Color(
                                    0xFF22D3EE,
                                  ).withOpacity(0.4),
                                ),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PremiumPaywallPage(),
                                ),
                              );
                            },
                            child: const Text(
                              "Elite Abone Ol",
                              style: TextStyle(
                                color: Color(0xFF22D3EE),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: const SizedBox.expand(),
            ),
            FadeTransition(
              opacity: anim1,
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: anim1,
                  curve: Curves.easeOutBack,
                ),
                child: child,
              ),
            ),
          ],
        );
      },
    );
  }

  // --- Premium Modal Gösterimi ---
  Future<void> _playPortalOpenRitual(String title, CustomPainter Function(double) painterBuilder, double wheelSize, Widget targetPage) async {
    HapticFeedback.lightImpact();
    Future.delayed(const Duration(milliseconds: 800), () => HapticFeedback.mediumImpact());
    Future.delayed(const Duration(milliseconds: 1600), () => HapticFeedback.heavyImpact());

    await Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 2600),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, anim1, anim2) {
          final isForward = anim1.status == AnimationStatus.forward || anim1.status == AnimationStatus.completed;

          return Stack(
            fit: StackFit.expand,
            children: [
              // ARKA PLANDA BELİRECEK OLAN YENİ SAYFA
              FadeTransition(
                opacity: isForward 
                    ? CurvedAnimation(parent: anim1, curve: const Interval(0.4, 1.0, curve: Curves.easeIn))
                    : anim1, // Geri dönüşte standart fade out
                child: targetPage,
              ),

              // ÖN PLANDA DEV ÇARK (Sadece ileri gidiyorken çalışır, geri gelişte asla görünmez)
              if (isForward)
                IgnorePointer(
                  child: FadeTransition(
                    // Animasyonun 2. yarısında çark çok yavaşça ve pamuk gibi eriyerek kaybolur (1.0 -> 0.0)
                    opacity: Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
                      parent: anim1,
                      curve: const Interval(0.60, 1.0, curve: Curves.easeInOut), 
                    )),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(color: Colors.black87),
                        
                        Hero(
                          tag: 'wheel_$title',
                          child: SizedBox(
                            width: wheelSize,
                            height: wheelSize,
                            child: AnimatedBuilder(
                              animation: _spin,
                              builder: (c, _) => CustomPaint(
                                size: Size(wheelSize, wheelSize),
                                painter: painterBuilder(_spin.value),
                              ),
                            ),
                          )
                          .animate(onComplete: (controller) => controller.stop()) // Tıklama başına sadece 1 kere oynat!
                          .scale(begin: const Offset(1, 1), end: const Offset(7.5, 7.5), duration: 2600.ms, curve: Curves.easeInOutCubic)
                          .rotate(begin: 0, end: 1.5, duration: 2600.ms, curve: Curves.easeInOutCubic)
                          .fadeOut(delay: 1000.ms, duration: 1600.ms, curve: Curves.easeInOut), // Uzuuun ve pamuk gibi bir erime
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handlePremiumAccess(BuildContext context, String moduleKey, VoidCallback onUnlock) async {
    // 1. Günlük kilit açık mı kontrolü
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final unlockKey = 'zodiac_unlocked_${moduleKey}_$today';
    final isUnlocked = prefs.getBool(unlockKey) ?? false;

    // 2. Bugün kilit ZATEN AÇILMIŞSA direkt gir (Premium da olsa, ücretsiz de olsa).
    if (isUnlocked) {
      onUnlock();
      return;
    }

    // 3. Kullanıcı Premium (Elite) ise, paneli göstermeden "doğrudan Ruh Taşı kullanıma" çalış.
    if (_isPremiumUser) {
      bool success = await StorageService.deductSoulStones(1);
      if (success) {
        await prefs.setBool(unlockKey, true);
        HapticFeedback.lightImpact(); // Başarılı, hızlı geçiş hissi.
        onUnlock();
        return;
      }
      // Eğer Premium olmasına rağmen taş kalmadıysa, mecburen alttaki paneli göster ki yetersiz bakiye olduğunu görsün.
    }
    
    // 4. Ücretsiz kullanıcıysa VEYA Premium olup taşı bitenlerse KADİM BİLGELİĞİN KAPISI panelini göster!
    if (!context.mounted) return;
    
    // Ücretsiz kullanıcı için Merkezi Kilit Modalı (Tarot tarzı)
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible: true,
      barrierLabel: 'PremiumAccess',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (dialogCtx, anim1, anim2) {
        return StatefulBuilder(
          builder: (stContext, setState) {
            final panelW = MediaQuery.of(stContext).size.width * 0.85;
            return Center(
              child: SizedBox(
                width: panelW,
                child: Material(
                  type: MaterialType.transparency,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25), 
                            width: 0.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 40,
                              spreadRadius: -5,
                            ),
                          ],
                        ),
                        child: ValueListenableBuilder<int>(
                          valueListenable: StorageService.soulStonesNotifier,
                          builder: (context, soulStones, _) {
                            final hasEnough = soulStones >= 1;
                            return Column(
                              key: const ValueKey('pay_wall'),
                              mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.diamond_rounded, 
                                            color: hasEnough ? const Color(0xFF22D3EE) : Colors.white.withOpacity(0.3), 
                                            size: 48
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            'Kozmik Bilgelik Kapısı',
                                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF22D3EE).withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: const Color(0xFF22D3EE).withOpacity(0.3), width: 1),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.diamond_outlined, size: 14, color: Color(0xFF22D3EE)),
                                                const SizedBox(width: 6),
                                                Text(
                                                  "$soulStones Ruh Taşın var",
                                                  style: const TextStyle(color: Color(0xFF22D3EE), fontSize: 13, fontWeight: FontWeight.w600),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          _premiumInfoRow(
                                            Icons.auto_awesome,
                                            "Burç derinlikleri için giriş izni",
                                            true,
                                          ),
                                          const SizedBox(height: 10),
                                          _premiumInfoRow(
                                            Icons.diamond_outlined,
                                            "Her astroloji haritası 1 Ruh Taşı harcar",
                                            hasEnough,
                                          ),
                                          const SizedBox(height: 10),
                                          _premiumInfoRow(
                                            Icons.workspace_premium,
                                            _isPremiumUser
                                                ? "Elite ayrıcalığı: Her gece 5 Ruh Taşı yenilenir"
                                                : "Elite ile her gece 5 Ruh Taşı kazan",
                                            _isPremiumUser,
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            children: [
                                              if (hasEnough)
                                                Expanded(
                                                  child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: const Color(0xFF22D3EE).withOpacity(0.15),
                                                      elevation: 0,
                                                      padding: const EdgeInsets.symmetric(vertical: 0),
                                                      minimumSize: const Size(double.infinity, 48),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(16),
                                                        side: BorderSide(
                                                          color: const Color(0xFF22D3EE).withOpacity(0.4),
                                                        ),
                                                      ),
                                                    ),
                                                    onPressed: () async {
                                                      final success = await StorageService.deductSoulStones(1);
                                                      if (success) {
                                                        await prefs.setBool(unlockKey, true); // O gün için açıldı
                                                        if (context.mounted) {
                                                          Navigator.pop(dialogCtx);
                                                          onUnlock();
                                                        }
                                                      }
                                                    },
                                                    child: const FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Text(
                                                        "1 Ruh Taşı Kullan",
                                                        style: TextStyle(
                                                          color: Color(0xFF22D3EE),
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              else ...[
                                                Expanded(
                                                  child: ElevatedButton.icon(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.white.withOpacity(0.08),
                                                      elevation: 0,
                                                      minimumSize: const Size(double.infinity, 48),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(16),
                                                        side: BorderSide(color: Colors.white.withOpacity(0.2)),
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      AdService().showRewardedAd(() async {
                                                        await StorageService.updateSoulStones(1);
                                                        final success = await StorageService.deductSoulStones(1);
                                                        if (success) {
                                                          await prefs.setBool(unlockKey, true);
                                                          if (context.mounted) {
                                                            Navigator.pop(dialogCtx);
                                                            onUnlock();
                                                          }
                                                        }
                                                      }, () {});
                                                    },
                                                    icon: Icon(Icons.play_circle_filled_rounded, color: Colors.white.withOpacity(0.7), size: 18),
                                                    label: FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Text(
                                                        "Reklam İzle",
                                                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: ElevatedButton.icon(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: const Color(0xFF22D3EE).withOpacity(0.15),
                                                      elevation: 0,
                                                      minimumSize: const Size(double.infinity, 48),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(16),
                                                        side: BorderSide(color: const Color(0xFF22D3EE).withOpacity(0.4)),
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.pop(dialogCtx);
                                                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumPaywallPage()));
                                                    },
                                                    icon: const Icon(Icons.workspace_premium, color: Color(0xFF22D3EE), size: 18),
                                                    label: const FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Text(
                                                        "Elite Al",
                                                        style: TextStyle(color: Color(0xFF22D3EE), fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
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
          },
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    // Çark boyutunu üçü de sığacak şekilde dinamik hesaplıyoruz:
    final wheelSize = math.min(w * 0.48, h * 0.22);
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(children: [
        // Arka plan
        Container(decoration: BoxDecoration(gradient: RadialGradient(
          center: const Alignment(0, -0.6), radius: 1.6,
          colors: [_goldD.withOpacity(0.2), _bg], stops: const [0, 1],
        ))),

        // Kaydırılabilir Çarklar (Yumuşak üst sınır)
        Positioned.fill(
          child: ShaderMask(
            shaderCallback: (Rect rect) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.4),
                  Colors.black,
                  Colors.black,
                ],
                stops: const [0.0, 0.05, 0.08, 1.0],
              ).createShader(rect);
            },
            blendMode: BlendMode.dstIn,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 30,
                bottom: 40,
              ),
              child: Column(children: [
                const SizedBox(height: 10),
                // ── ÜÇ ÇARK (Tek ekrana sığması için kompakt tasarlandı) ──
                _animWrap(_t1, _wheelSection(
                  wheelSize: wheelSize, label: 'BATI ASTROLOJİSİ', 
                  painter: (p) => WesternWheelPainter(rotation: p, gold: _gold, goldD: _goldD),
                  onTap: () async {
                    await _playPortalOpenRitual('BATI ASTROLOJİSİ', (p) => WesternWheelPainter(rotation: p, gold: _gold, goldD: _goldD), wheelSize, const ZodiacPage());
                  },
                )),
                const SizedBox(height: 28),
                _animWrap(_t2, _wheelSection(
                  wheelSize: wheelSize, label: 'ASYA ASTROLOJİSİ', 
                  painter: (p) => ChineseWheelPainter(rotation: p, gold: _gold, goldD: _goldD),
                  isPremium: true,
                  onTap: () => _handlePremiumAccess(context, 'asian', () async {
                    await _playPortalOpenRitual('ASYA ASTROLOJİSİ', (p) => ChineseWheelPainter(rotation: p, gold: _gold, goldD: _goldD), wheelSize, const ZodiacChinesePage());
                  }),
                )),
                const SizedBox(height: 28),
                _animWrap(_t3, _wheelSection(
                  wheelSize: wheelSize, label: 'MAYA ASTROLOJİSİ', 
                  painter: (p) => MayanWheelPainter(rotation: p, gold: _gold, goldD: _goldD),
                  isPremium: true,
                  onTap: () => _handlePremiumAccess(context, 'mayan', () async {
                    await _playPortalOpenRitual('MAYA ASTROLOJİSİ', (p) => MayanWheelPainter(rotation: p, gold: _gold, goldD: _goldD), wheelSize, const ZodiacMayanPage());
                  }),
                )),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ),

        // Sabit Üst Bar (Geri Butonu ve Rehber)
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 20,
          right: 20,
          child: _animWrap(_t1, Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const GlassBackButton(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GuidanceBookletButton(
                    dialogTitleTr: 'Burç Rehberi',
                    dialogTitleEn: 'Zodiac Guide',
                    items: const [
                      GuidanceItem(
                        titleTr: 'Batı Astrolojisi',
                        titleEn: 'Western Astrology',
                        descTr: 'Gökyüzü haritasına kazınmış kimliğiniz. Doğum anınızdaki ışıklar potansiyelinizi ve temel karakterinizi aydınlatır.',
                        descEn: 'Your identity carved into the sky map. The lights at your birth illuminate your potential and core character.',
                        icon: Icons.flare_outlined,
                      ),
                      GuidanceItem(
                        titleTr: 'Asya Astrolojisi',
                        titleEn: 'Asian Astrology',
                        descTr: '12 yıllık evrensel döngüler. Doğum yılınızdaki hayvan figürü, ruhunuza yüklenen kader bağlarını ve yaşam heyecanını açıklar.',
                        descEn: '12-year universal cycles. The animal of your birth year explains fateful bonds and excitement imprinted on your soul.',
                        icon: Icons.brightness_medium_outlined,
                      ),
                      GuidanceItem(
                        titleTr: 'Maya Astrolojisi',
                        titleEn: 'Mayan Astrology',
                        descTr: 'Doğanın kusursuz matematiği. 20 mühür ve 13 tonun birleşimi, evrendeki ritminizi ve "Kozmik Misyonunuzu" söyler.',
                        descEn: 'Flawless mathematics of nature. The union of 20 seals and 13 tones reveals your rhythm and "Cosmic Mission".',
                        icon: Icons.filter_vintage_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  ValueListenableBuilder<int>(
                    valueListenable: StorageService.soulStonesNotifier,
                    builder: (context, soulStones, _) {
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showSoulStoneInfoPanel();
                        },
                        child: ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.10),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF22D3EE).withOpacity(0.3),
                                  width: 0.6,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.diamond_outlined, 
                                    size: 11, 
                                    color: soulStones > 0 ? const Color(0xFF22D3EE).withOpacity(0.9) : Colors.white.withOpacity(0.3)
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '$soulStones',
                                    style: TextStyle(
                                      color: soulStones > 0 ? const Color(0xFF22D3EE).withOpacity(0.9) : Colors.white.withOpacity(0.3),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          )),
        ),
      ]),
    );
  }

  Widget _animWrap(Animation<double> a, Widget child) => FadeTransition(
    opacity: a, child: SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, .12), end: Offset.zero).animate(a), child: child));

  Widget _wheelSection({
    required double wheelSize, 
    required String label,
    required CustomPainter Function(double progress) painter, 
    required VoidCallback onTap,
    bool isPremium = false,
  }) {
    return Column(children: [
        // Çark Etiketi ve Ruh Taşı İkonu (Merkez bozulmasın diye Stack kullanıldı)
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Text(label, style: TextStyle(color: _gold.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 3)),
            if (isPremium)
              Positioned(
                right: -20,
                child: const Icon(Icons.diamond_outlined, color: Color(0xFF22D3EE), size: 14),
              ),
          ],
        ),
        const SizedBox(height: 6),
        // Çarkın Kendisi - Artık buton (ripple efektli)
        Hero(
          tag: 'wheel_$label',
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              splashColor: _goldL.withOpacity(0.15),
              highlightColor: _goldD.withOpacity(0.1),
              child: SizedBox(width: wheelSize, height: wheelSize, child: AnimatedBuilder(
                animation: _spin,
                builder: (c, _) => CustomPaint(size: Size(wheelSize, wheelSize), painter: painter(_spin.value)),
              )),
            ),
          ),
        ),
    ]);
  }

  Widget _badge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(color: _goldD.withOpacity(0.15), borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _gold.withOpacity(0.2))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      const Text('✨', style: TextStyle(fontSize: 12)), const SizedBox(width: 5),
      Text('3 Kadim Gelenek', style: TextStyle(color: _goldL.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.w600)),
    ]),
  );
}

// BATI ZODIAC ÇARKI — Referans görselden ilham
class WesternWheelPainter extends CustomPainter {
  final double rotation;
  final Color gold, goldD;
  WesternWheelPainter({required this.rotation, required this.gold, required this.goldD});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final p = Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;

    // Dış çift halka
    p..color = gold.withOpacity(0.3)..strokeWidth = 1.8;
    canvas.drawCircle(c, r - 2, p);
    p..color = gold.withOpacity(0.15)..strokeWidth = 1.0;
    canvas.drawCircle(c, r - 8, p);
    p..color = gold.withOpacity(0.22)..strokeWidth = 1.2;
    canvas.drawCircle(c, r * 0.36, p);

    // 12 segment bölmesi
    for (int i = 0; i < 12; i++) {
      final a = (i * 30 - 90 + rotation * 360) * math.pi / 180;
      p..color = gold.withOpacity(0.1)..strokeWidth = 0.6;
      canvas.drawLine(c + Offset(math.cos(a) * r * 0.36, math.sin(a) * r * 0.36),
        c + Offset(math.cos(a) * (r - 8), math.sin(a) * (r - 8)), p);
    }

    // 12 burç sembolü — daha büyük alan
    final sp = Paint()..color = gold.withOpacity(0.9)..style = PaintingStyle.stroke
      ..strokeWidth = 2.4..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
    for (int i = 0; i < 12; i++) {
      final a = (i * 30 - 75 + rotation * 360) * math.pi / 180;
      _drawSym(canvas, i, c + Offset(math.cos(a) * r * 0.68, math.sin(a) * r * 0.68), r * 0.15, sp);
    }

    // ── MERKEZ GÜNEŞ — ışınlar segmentlere yayılıyor ──
    final discR = r * 0.1;

    // Sıcak parıltı (geniş)
    canvas.drawCircle(c, r * 0.5, Paint()..shader = RadialGradient(
      colors: [gold.withOpacity(0.08), gold.withOpacity(0.02), Colors.transparent],
      stops: const [0.1, 0.5, 1.0],
    ).createShader(Rect.fromCircle(center: c, radius: r * 0.5)));

    // 36 uzun ışın — segmentlere kadar uzanıyor
    for (int i = 0; i < 36; i++) {
      final a = (i * 10 + rotation * 360) * math.pi / 180;
      final type = i % 3;
      // Uzun ışınlar sembol halkasına yaklaşıyor
      final outerEnd = type == 0 ? r * 0.52 : (type == 2 ? r * 0.42 : r * 0.34);
      final innerStart = discR * 1.3;
      // Opaklık dışa doğru azalıyor
      final baseOpacity = type == 0 ? 0.25 : (type == 2 ? 0.15 : 0.08);
      final width = type == 0 ? 1.3 : (type == 2 ? 0.8 : 0.4);
      p..color = gold.withOpacity(baseOpacity)..strokeWidth = width;
      canvas.drawLine(
        c + Offset(math.cos(a) * innerStart, math.sin(a) * innerStart),
        c + Offset(math.cos(a) * outerEnd, math.sin(a) * outerEnd), p);
    }

    // İkinci katman — 12 ana ışın (daha kalın, daha uzun)
    for (int i = 0; i < 12; i++) {
      final a = (i * 30 + 15 + rotation * 360) * math.pi / 180;
      p..color = gold.withOpacity(0.12)..strokeWidth = 2.0;
      canvas.drawLine(
        c + Offset(math.cos(a) * discR * 1.5, math.sin(a) * discR * 1.5),
        c + Offset(math.cos(a) * r * 0.48, math.sin(a) * r * 0.48), p);
      // Paralel ince ışınlar (kenar çizgileri)
      for (final offset in [-0.03, 0.03]) {
        final aOff = a + offset;
        p..color = gold.withOpacity(0.06)..strokeWidth = 0.5;
        canvas.drawLine(
          c + Offset(math.cos(aOff) * discR * 2, math.sin(aOff) * discR * 2),
          c + Offset(math.cos(aOff) * r * 0.44, math.sin(aOff) * r * 0.44), p);
      }
    }

    // Güneş diski — çift halka
    p..color = gold.withOpacity(0.4)..strokeWidth = 2.0;
    canvas.drawCircle(c, discR, p);
    p..color = gold.withOpacity(0.2)..strokeWidth = 0.8;
    canvas.drawCircle(c, discR * 1.6, p);

    // Disk iç parıltı
    canvas.drawCircle(c, discR * 1.2, Paint()..shader = RadialGradient(
      colors: [gold.withOpacity(0.18), gold.withOpacity(0.05), Colors.transparent],
    ).createShader(Rect.fromCircle(center: c, radius: discR * 1.2)));

    // Parlak çekirdek
    canvas.drawCircle(c, 3, Paint()..color = gold.withOpacity(0.75)..style = PaintingStyle.fill);
    canvas.drawCircle(c, 1.2, Paint()..color = gold.withOpacity(0.95)..style = PaintingStyle.fill);

    // Dış noktalar
    for (int i = 0; i < 36; i++) {
      final a = (i * 10 + rotation * 360) * math.pi / 180;
      canvas.drawCircle(c + Offset(math.cos(a) * (r - 5), math.sin(a) * (r - 5)),
        i % 3 == 0 ? 1.5 : 0.7, Paint()..color = gold.withOpacity(i % 3 == 0 ? 0.25 : 0.08)..style = PaintingStyle.fill);
    }
  }

  void _drawSym(Canvas canvas, int i, Offset o, double s, Paint p) {
    final path = Path();
    switch (i) {
      case 0: // ♈ Koç — V boynuz + alt çizgi
        path..moveTo(o.dx - s * .35, o.dy - s * .55);
        path.cubicTo(o.dx - s * .55, o.dy - s * .15, o.dx - s * .15, o.dy + s * .1, o.dx, o.dy + s * .35);
        path.cubicTo(o.dx + s * .15, o.dy + s * .1, o.dx + s * .55, o.dy - s * .15, o.dx + s * .35, o.dy - s * .55);
        path..moveTo(o.dx, o.dy + s * .35); path.lineTo(o.dx, o.dy + s * .65);
      case 1: // ♉ Boğa — daire + hilal boynuz
        canvas.drawCircle(Offset(o.dx, o.dy + s * .2), s * .28, p);
        path..moveTo(o.dx - s * .45, o.dy);
        path.cubicTo(o.dx - s * .55, o.dy - s * .55, o.dx - s * .1, o.dy - s * .7, o.dx, o.dy - s * .4);
        path.cubicTo(o.dx + s * .1, o.dy - s * .7, o.dx + s * .55, o.dy - s * .55, o.dx + s * .45, o.dy);
      case 2: // ♊ İkizler — iki sütun + yay bağlantılar
        path..moveTo(o.dx - s * .3, o.dy - s * .55); path.lineTo(o.dx - s * .3, o.dy + s * .55);
        path..moveTo(o.dx + s * .3, o.dy - s * .55); path.lineTo(o.dx + s * .3, o.dy + s * .55);
        path..moveTo(o.dx - s * .45, o.dy - s * .4);
        path.quadraticBezierTo(o.dx, o.dy - s * .75, o.dx + s * .45, o.dy - s * .4);
        path..moveTo(o.dx - s * .45, o.dy + s * .4);
        path.quadraticBezierTo(o.dx, o.dy + s * .75, o.dx + s * .45, o.dy + s * .4);
      case 3: // ♋ Yengeç — 69 şekli
        path..moveTo(o.dx + s * .15, o.dy - s * .15);
        path.cubicTo(o.dx - s * .2, o.dy - s * .15, o.dx - s * .5, o.dy - s * .55, o.dx - s * .1, o.dy - s * .5);
        path..moveTo(o.dx + s * .15, o.dy - s * .15);
        path.cubicTo(o.dx + s * .5, o.dy - s * .15, o.dx + s * .5, o.dy + s * .15, o.dx + s * .15, o.dy + s * .15);
        path..moveTo(o.dx - s * .15, o.dy + s * .15);
        path.cubicTo(o.dx + s * .2, o.dy + s * .15, o.dx + s * .5, o.dy + s * .55, o.dx + s * .1, o.dy + s * .5);
        path..moveTo(o.dx - s * .15, o.dy + s * .15);
        path.cubicTo(o.dx - s * .5, o.dy + s * .15, o.dx - s * .5, o.dy - s * .15, o.dx - s * .15, o.dy - s * .15);
      case 4: // ♌ Aslan — daire + S kuyruk
        canvas.drawCircle(Offset(o.dx + s * .2, o.dy + s * .25), s * .2, p);
        path..moveTo(o.dx, o.dy + s * .25);
        path.cubicTo(o.dx - s * .4, o.dy + s * .25, o.dx - s * .5, o.dy - s * .1, o.dx - s * .2, o.dy - s * .35);
        path.cubicTo(o.dx, o.dy - s * .6, o.dx + s * .4, o.dy - s * .5, o.dx + s * .35, o.dy - s * .15);
      case 5: // ♍ Başak — m dalga + çapraz kuyruk
        path..moveTo(o.dx - s * .45, o.dy + s * .4); path.lineTo(o.dx - s * .45, o.dy);
        path.cubicTo(o.dx - s * .45, o.dy - s * .45, o.dx - s * .15, o.dy - s * .45, o.dx - s * .15, o.dy);
        path.cubicTo(o.dx - s * .15, o.dy - s * .45, o.dx + s * .15, o.dy - s * .45, o.dx + s * .15, o.dy);
        path.cubicTo(o.dx + s * .15, o.dy - s * .45, o.dx + s * .45, o.dy - s * .45, o.dx + s * .45, o.dy);
        path.lineTo(o.dx + s * .45, o.dy + s * .2);
        path..moveTo(o.dx + s * .2, o.dy + s * .15); path.lineTo(o.dx + s * .55, o.dy + s * .5);
        path..moveTo(o.dx + s * .3, o.dy + s * .38); path.lineTo(o.dx + s * .55, o.dy + s * .25);
      case 6: // ♎ Terazi — kubbe + iki çizgi
        path..moveTo(o.dx - s * .5, o.dy + s * .35); path.lineTo(o.dx + s * .5, o.dy + s * .35);
        path..moveTo(o.dx - s * .5, o.dy + s * .1); path.lineTo(o.dx + s * .5, o.dy + s * .1);
        path..moveTo(o.dx - s * .35, o.dy + s * .1);
        path.cubicTo(o.dx - s * .35, o.dy - s * .55, o.dx + s * .35, o.dy - s * .55, o.dx + s * .35, o.dy + s * .1);
      case 7: // ♏ Akrep — m dalga + ok kuyruk
        path..moveTo(o.dx - s * .5, o.dy + s * .35); path.lineTo(o.dx - s * .5, o.dy - s * .05);
        path.cubicTo(o.dx - s * .5, o.dy - s * .45, o.dx - s * .2, o.dy - s * .45, o.dx - s * .2, o.dy - s * .05);
        path.cubicTo(o.dx - s * .2, o.dy - s * .45, o.dx + s * .1, o.dy - s * .45, o.dx + s * .1, o.dy - s * .05);
        path.lineTo(o.dx + s * .1, o.dy + s * .25); path.lineTo(o.dx + s * .4, o.dy + s * .45);
        path..moveTo(o.dx + s * .4, o.dy + s * .45); path.lineTo(o.dx + s * .5, o.dy + s * .25);
        path..moveTo(o.dx + s * .4, o.dy + s * .45); path.lineTo(o.dx + s * .2, o.dy + s * .4);
      case 8: // ♐ Yay — çapraz ok
        path..moveTo(o.dx - s * .45, o.dy + s * .55); path.lineTo(o.dx + s * .45, o.dy - s * .45);
        path.lineTo(o.dx + s * .15, o.dy - s * .45);
        path..moveTo(o.dx + s * .45, o.dy - s * .45); path.lineTo(o.dx + s * .45, o.dy - s * .15);
        path..moveTo(o.dx - s * .15, o.dy + s * .05); path.lineTo(o.dx + s * .2, o.dy + s * .3);
      case 9: // ♑ Oğlak — üst kıvrım + kuyruk döngüsü
        path..moveTo(o.dx - s * .3, o.dy - s * .5);
        path.cubicTo(o.dx - s * .45, o.dy - s * .65, o.dx - s * .05, o.dy - s * .7, o.dx, o.dy - s * .4);
        path.lineTo(o.dx + s * .1, o.dy + s * .1);
        path.cubicTo(o.dx + s * .45, o.dy + s * .6, o.dx + s * .05, o.dy + s * .7, o.dx - s * .15, o.dy + s * .45);
        path.cubicTo(o.dx - s * .35, o.dy + s * .2, o.dx + s * .05, o.dy + s * .1, o.dx + s * .1, o.dy + s * .35);
      case 10: // ♒ Kova — iki S dalga
        for (int j = 0; j < 2; j++) {
          final y = o.dy + (j == 0 ? -s * .15 : s * .2);
          path..moveTo(o.dx - s * .5, y);
          path.cubicTo(o.dx - s * .35, y - s * .25, o.dx - s * .15, y + s * .25, o.dx, y);
          path.cubicTo(o.dx + s * .15, y - s * .25, o.dx + s * .35, y + s * .25, o.dx + s * .5, y);
        }
      case 11: // ♓ Balık — iki karşılıklı yay + çizgi
        path..moveTo(o.dx - s * .45, o.dy); path.lineTo(o.dx + s * .45, o.dy);
        path..moveTo(o.dx - s * .15, o.dy - s * .5);
        path.cubicTo(o.dx - s * .55, o.dy - s * .2, o.dx - s * .55, o.dy + s * .2, o.dx - s * .15, o.dy + s * .5);
        path..moveTo(o.dx + s * .15, o.dy - s * .5);
        path.cubicTo(o.dx + s * .55, o.dy - s * .2, o.dx + s * .55, o.dy + s * .2, o.dx + s * .15, o.dy + s * .5);
    }
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant WesternWheelPainter old) => old.rotation != rotation;
}

// ÇİN ZODIAC ÇARKI — Net Altın Silüetler (Görseldeki gibi net ve tanınabilir)
class ChineseWheelPainter extends CustomPainter {
  final double rotation;
  final Color gold, goldD;
  ChineseWheelPainter({required this.rotation, required this.gold, required this.goldD});

  static const List<String> _names = ['FARE', 'ÖKÜZ', 'KAPLAN', 'TAVŞAN', 'EJDERHA', 'YILAN', 'AT', 'KEÇİ', 'MAYMUN', 'HOROZ', 'KÖPEK', 'DOMUZ'];

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    
    final ringR = r * 0.76;
    final animalR = r * 0.18; // Boyutlar dengelendi ve dışa alındı

    // Merkezdeki Zarif Parlama
    canvas.drawCircle(c, r * 0.35, Paint()..shader = RadialGradient(
      colors: [gold.withOpacity(0.08), Colors.transparent],
    ).createShader(Rect.fromCircle(center: c, radius: r * 0.35)));

    // MERKEZ - Büyük Asya Mühür Çerçevesi (Dış çerçevelerle tam uyumlu)
    canvas.save();
    canvas.translate(c.dx, c.dy);
    
    final frameColor = gold == Colors.white ? Colors.white.withOpacity(0.3) : const Color(0xFFC62828);
    final cR = r * 0.32; // Büyük merkez çerçevenin boyutu

    // Kalın kızıl dış çerçeve (Köşeleri yuvarlatılmış)
    final cRr = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: cR * 2, height: cR * 2),
      const Radius.circular(16)
    );
    canvas.drawRRect(cRr, Paint()..color = frameColor.withOpacity(0.08)..style = PaintingStyle.fill);
    canvas.drawRRect(cRr, Paint()..color = frameColor.withOpacity(0.6)..style = PaintingStyle.stroke..strokeWidth = 2.5);
    
    // İnce altın iç çerçeve
    final cInnerRr = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: cR * 1.70, height: cR * 1.70),
      const Radius.circular(10)
    );
    canvas.drawRRect(cInnerRr, Paint()..color = gold.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 1.2);

    // Geleneksel Çin köşelikleri (Lattice Window Corners)
    final q = cR * 0.85;
    final wl = cR * 0.25; 
    final cbPaint = Paint()..color = gold.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 2.0;
    
    // Sol Üst
    canvas.drawPath(Path()..moveTo(-q, -q+wl)..lineTo(-q, -q)..lineTo(-q+wl, -q), cbPaint);
    // Sağ Üst
    canvas.drawPath(Path()..moveTo(q-wl, -q)..lineTo(q, -q)..lineTo(q, -q+wl), cbPaint);
    // Sağ Alt
    canvas.drawPath(Path()..moveTo(q, q-wl)..lineTo(q, q)..lineTo(q-wl, q), cbPaint);
    // Sol Alt
    canvas.drawPath(Path()..moveTo(-q+wl, q)..lineTo(-q, q)..lineTo(-q, q-wl), cbPaint);

    // Merkez: Yin-Yang ile Ejderha-Anka Kuşu Motifi (Asya tarzı, Batıdan tamamen farklı)
    _drawCenterYinYangDragon(canvas, cR * 0.72, gold);

    canvas.restore();

    // Dışarıdaki o kötü duran çember/halka çizgileri tamamen silindi.
    // p..color = gold.withOpacity(0.12)..strokeWidth = 1.0;
    // canvas.drawCircle(c, ringR, p);

    // 12 Hayvan ve Etraflarında Hafif Renkli Çerçeve
    for (int i = 0; i < 12; i++) {
      final a = (i * 30 - 90 + rotation * 360) * math.pi / 180;
      final pos = c + Offset(math.cos(a) * ringR, math.sin(a) * ringR);
      
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      // Çark dönerken hayvanlar dik dursun (Ferris wheel effect)
      
      // Çok zarif ve hafif kızıl-altın karışımı Asya Mühür Çerçevesi (Rounded Rect)
      final frameColor = gold == Colors.white ? Colors.white.withOpacity(0.3) : const Color(0xFFC62828);
      final rectRadius = animalR * 1.02; // Karelerin birbirine girmemesi için boyut küçültüldü
      final rr = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: rectRadius * 2, height: rectRadius * 2),
        const Radius.circular(8)
      );
      
      // Çerçevenin transparan hafif dolgusu
      canvas.drawRRect(rr, Paint()..color = frameColor.withOpacity(0.06)..style = PaintingStyle.fill);
      // Çerçevenin ince çizgileleri (ikili çerçeve çok daha şık duruyor)
      canvas.drawRRect(rr, Paint()..color = frameColor.withOpacity(0.4)..style = PaintingStyle.stroke..strokeWidth = 1.5);
      
      final innerRr = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: rectRadius * 1.7, height: rectRadius * 1.7),
        const Radius.circular(5)
      );
      canvas.drawRRect(innerRr, Paint()..color = gold.withOpacity(0.2)..style = PaintingStyle.stroke..strokeWidth = 0.8);

      // Hayvanı çiz (Artık hiçbir metin yok, tamamen saf tasarımlar)
      _drawIcon(canvas, i, animalR * 0.85, gold); // Çerçeveye tam oturması için ikonu hafif orantıladık

      canvas.restore();
    }
  }

  void _drawCenterYinYangDragon(Canvas canvas, double r, Color gold) {
    // Yin-Yang tarzı çift kıvrımlı ejderha-anka kuşu motifi
    final pStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final pFill = Paint()..style = PaintingStyle.fill;

    // Ana Yin-Yang dairesi (ince altın çizgi)
    pStroke..color = gold.withOpacity(0.5)..strokeWidth = 1.5;
    canvas.drawCircle(Offset.zero, r, pStroke);

    // Yin-Yang S-eğrisi (ortayı ikiye bölen akışkan kıvrım)
    final sCurve = Path()
      ..moveTo(0, -r)
      ..cubicTo(r * 0.8, -r * 0.6, r * 0.8, 0, 0, 0)
      ..cubicTo(-r * 0.8, 0, -r * 0.8, r * 0.6, 0, r);
    pStroke..color = gold.withOpacity(0.6)..strokeWidth = 1.8;
    canvas.drawPath(sCurve, pStroke);

    // Yin tarafı (sol üst yarım) - hafif dolgu
    final yinPath = Path()
      ..moveTo(0, -r)
      ..arcTo(Rect.fromCircle(center: Offset.zero, radius: r), -math.pi / 2, -math.pi, false)
      ..cubicTo(-r * 0.8, r * 0.6, -r * 0.8, 0, 0, 0)
      ..cubicTo(r * 0.8, -r * 0.6, r * 0.8, 0, 0, -r + 0.01);
    // Gerçek Yin-Yang: sol yarısı koyu dolguyla
    pFill..color = gold.withOpacity(0.08);
    // Sağ yarıyı dolduralım (Yang = parlak)
    final yangPath = Path()
      ..moveTo(0, -r)
      ..arcTo(Rect.fromCircle(center: Offset.zero, radius: r), -math.pi / 2, math.pi, false)
      ..cubicTo(-r * 0.8, r * 0.6, -r * 0.8, 0, 0, 0)
      ..cubicTo(r * 0.8, -r * 0.6, r * 0.8, 0, 0, -r + 0.01);
    // Yang tarafını hafif altın dolgu
    canvas.drawPath(yangPath, Paint()..color = gold.withOpacity(0.12)..style = PaintingStyle.fill);

    // Yin-Yang göz noktaları (büyük dairesel noktalar)
    // Üst göz (Yang gözü - karanlık tarafta parlak nokta)
    canvas.drawCircle(Offset(0, -r * 0.42), r * 0.14, Paint()..color = gold.withOpacity(0.6)..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(0, -r * 0.42), r * 0.14, pStroke..color = gold.withOpacity(0.4)..strokeWidth = 1.0);
    // Alt göz (Yin gözü - aydınlık tarafta koyu nokta)
    canvas.drawCircle(Offset(0, r * 0.42), r * 0.14, Paint()..color = gold.withOpacity(0.15)..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(0, r * 0.42), r * 0.14, pStroke..color = gold.withOpacity(0.5)..strokeWidth = 1.0);

    // ── Ejderha kıvrımı (sağ üst - Yang tarafı) ──
    // Ejderha başı (küçük detaylar)
    final dragonP = Paint()
      ..color = gold.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    
    // Ejderha boynuzu / bıyıklar
    canvas.drawLine(Offset(r * 0.25, -r * 0.75), Offset(r * 0.45, -r * 0.9), dragonP);
    canvas.drawLine(Offset(r * 0.15, -r * 0.72), Offset(r * 0.08, -r * 0.92), dragonP);
    // Küçük ejderha göz
    canvas.drawCircle(Offset(r * 0.18, -r * 0.65), r * 0.04, Paint()..color = gold.withOpacity(0.8)..style = PaintingStyle.fill);
    
    // Ejderha yüzgeç/bıyık kıvrımı  
    final whisker = Path()
      ..moveTo(r * 0.35, -r * 0.6)
      ..quadraticBezierTo(r * 0.55, -r * 0.5, r * 0.5, -r * 0.35);
    canvas.drawPath(whisker, dragonP..strokeWidth = 1.2);
    
    // ── Anka kuşu kıvrımı (sol alt - Yin tarafı) ──  
    // Anka kuşu kuyruk tüyleri
    final phoenixP = Paint()
      ..color = gold.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    // Kıvrımlı kuyruk tüyleri
    final feather1 = Path()
      ..moveTo(-r * 0.25, r * 0.6)
      ..quadraticBezierTo(-r * 0.55, r * 0.85, -r * 0.3, r * 0.9);
    canvas.drawPath(feather1, phoenixP);
    
    final feather2 = Path()
      ..moveTo(-r * 0.2, r * 0.55)
      ..quadraticBezierTo(-r * 0.6, r * 0.65, -r * 0.45, r * 0.85);
    canvas.drawPath(feather2, phoenixP..strokeWidth = 1.0);
    
    final feather3 = Path()
      ..moveTo(-r * 0.15, r * 0.65)
      ..quadraticBezierTo(-r * 0.4, r * 0.95, -r * 0.15, r * 0.92);
    canvas.drawPath(feather3, phoenixP..strokeWidth = 1.2);

    // Dış dekoratif noktalar (8 nokta, pusula gibi)
    for (int i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      final dotR = i % 2 == 0 ? r * 0.04 : r * 0.025;
      final dotPos = Offset(math.cos(a) * r * 0.88, math.sin(a) * r * 0.88);
      canvas.drawCircle(dotPos, dotR, Paint()..color = gold.withOpacity(i % 2 == 0 ? 0.5 : 0.3)..style = PaintingStyle.fill);
    }

    // İç ince halka (merkezi çevreleyen zarif çizgi)
    pStroke..color = gold.withOpacity(0.25)..strokeWidth = 0.6;
    canvas.drawCircle(Offset.zero, r * 0.28, pStroke);
  }

  void _drawIcon(Canvas canvas, int idx, double s, Color baseColor) {
    final Rect bounds = Rect.fromCircle(center: Offset.zero, radius: s * 0.8);
    final Paint f = Paint();
    if (baseColor == Colors.white) {
      f.color = Colors.white.withOpacity(0.9);
      f.style = PaintingStyle.fill;
    } else {
      f.shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFF6D9), Color(0xFFFFD060), Color(0xFFD48A18)],
        stops: [0.0, 0.4, 1.0],
      ).createShader(bounds);
      f.style = PaintingStyle.fill;
    }
    
    // Primitive Çizim Araçları (Çok daha net ve tanınan geometrik şekiller için)
    void circle(double x, double y, double r) => canvas.drawCircle(Offset(s * x, s * y), s * r, f);
    void oval(double x, double y, double w, double h, [double angle = 0]) {
      canvas.save();
      canvas.translate(s * x, s * y);
      canvas.rotate(angle);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: s * w, height: s * h), f);
      canvas.restore();
    }
    void capsule(double x1, double y1, double x2, double y2, double w) {
      final p = Path()..moveTo(s * x1, s * y1)..lineTo(s * x2, s * y2);
      canvas.drawPath(p, Paint()..shader = f.shader..style = PaintingStyle.stroke..strokeWidth = s * w..strokeCap = StrokeCap.round);
    }
    void poly(List<double> pts) {
      final p = Path()..moveTo(s * pts[0], s * pts[1]);
      for (int j = 2; j < pts.length; j += 2) p.lineTo(s * pts[j], s * pts[j + 1]);
      p.close();
      canvas.drawPath(p, f);
    }

    switch (idx) {
      case 0: // Fare (Rat)
        oval(-0.1, 0.15, 0.55, 0.45, -0.2); // Gövde
        oval(0.2, -0.1, 0.45, 0.25, 0.2); // Baş
        circle(0.1, -0.25, 0.18); // Büyük kulak
        poly([0.3, -0.1, 0.55, -0.15, 0.3, 0.05]); // Burun
        capsule(0.2, 0.15, 0.35, 0.2, 0.08); // Eller
        capsule(-0.15, 0.3, -0.2, 0.45, 0.06); // Ayak
        // Kıvrık kuyruk
        final tp = Path()..moveTo(-s * 0.3, s * 0.3)..cubicTo(-s * 0.7, s * 0.6, s * 0.5, s * 0.6, s * 0.5, s * 0.45);
        canvas.drawPath(tp, Paint()..shader = f.shader..style = PaintingStyle.stroke..strokeWidth = s * 0.06..strokeCap = StrokeCap.round);
        break;
      case 1: // Öküz (Ox)
        oval(-0.05, 0.0, 0.8, 0.45, 0); // Güçlü gövde
        oval(0.4, -0.15, 0.35, 0.2, 0.2); // Baş
        capsule(0.4, -0.2, 0.6, -0.4, 0.08); // İleri boynuz
        capsule(-0.35, 0.1, -0.35, 0.45, 0.12); // Arka bacak
        capsule(0.25, 0.1, 0.25, 0.45, 0.14); // Ön bacak
        capsule(-0.15, 0.1, -0.15, 0.45, 0.1); // Arka iç bacak
        capsule(0.05, 0.1, 0.05, 0.45, 0.1); // Ön iç bacak
        capsule(-0.4, -0.05, -0.45, 0.35, 0.06); // İnce kuyruk
        break;
      case 2: // Kaplan (Tiger)
        oval(0.0, 0.0, 0.85, 0.35, 0); // Zayıf ve uzun gövde
        circle(0.4, -0.15, 0.2); // Baş
        circle(0.4, -0.32, 0.08); // Kulak
        poly([0.4, -0.05, 0.6, -0.1, 0.5, 0.05]); // Çene
        capsule(-0.35, 0.1, -0.3, 0.45, 0.12);
        capsule(-0.15, 0.1, -0.1, 0.45, 0.12);
        capsule(0.2, 0.1, 0.2, 0.45, 0.12);
        capsule(0.35, 0.1, 0.4, 0.45, 0.12);
        // İnik ve kıvrık kuyruk
        final tp = Path()..moveTo(-s * 0.4, -s * 0.05)..quadraticBezierTo(-s * 0.6, s * 0.3, -s * 0.45, s * 0.45);
        canvas.drawPath(tp, Paint()..shader = f.shader..style = PaintingStyle.stroke..strokeWidth = s * 0.1..strokeCap = StrokeCap.round);
        break;
      case 3: // Tavşan (Rabbit)
        oval(-0.15, 0.2, 0.6, 0.4, 0); // Yuvarlak gövde
        circle(0.25, -0.05, 0.18); // Baş
        oval(-0.05, -0.35, 0.5, 0.12, -0.6); // Dik ve geriye kulak 1
        oval(0.05, -0.4, 0.5, 0.12, -0.4); // Dik ve geriye kulak 2
        circle(-0.45, 0.25, 0.12); // Ponpon kuyruk
        capsule(0.25, 0.2, 0.25, 0.45, 0.08); // Ön ayak
        capsule(-0.2, 0.2, -0.25, 0.45, 0.1); // Arka ayak
        break;
      case 4: // Ejderha (Dragon)
        // Belirgin kıvrımlı S Gövde
        final dp = Path()..moveTo(-s * 0.35, s * 0.2)..cubicTo(-s * 0.8, -s * 0.5, s * 0.2, -s * 0.5, 0, s * 0.1)..cubicTo(-s * 0.1, s * 0.4, s * 0.4, s * 0.3, s * 0.3, -s * 0.15);
        canvas.drawPath(dp, Paint()..shader = f.shader..style = PaintingStyle.stroke..strokeWidth = s * 0.16..strokeCap = StrokeCap.round);
        oval(0.35, -0.25, 0.3, 0.15, 0.2); // Baş
        capsule(0.25, -0.3, 0.1, -0.45, 0.05); // Boynuz
        capsule(0.35, -0.3, 0.25, -0.45, 0.05); // Boynuz
        capsule(-0.15, -0.1, -0.25, 0.1, 0.06); // Pençe 1
        capsule(0.0, 0.2, 0.1, 0.35, 0.06); // Pençe 2
        capsule(0.15, 0.1, 0.25, 0.2, 0.06); // Pençe 3
        break;
      case 5: // Yılan (Snake)
        final sp = Path()..moveTo(-s * 0.3, s * 0.2)..cubicTo(-s * 0.8, s * 0.1, -s * 0.1, -s * 0.5, 0, -s * 0.1)..cubicTo(s * 0.1, s * 0.3, s * 0.5, 0.1, s * 0.3, -s * 0.25);
        canvas.drawPath(sp, Paint()..shader = f.shader..style = PaintingStyle.stroke..strokeWidth = s * 0.18..strokeCap = StrokeCap.round);
        oval(0.3, -0.25, 0.25, 0.15, 0.3); // Yassı baş
        capsule(0.4, -0.2, 0.5, -0.15, 0.04); // Dil
        break;
      case 6: // At (Horse)
        oval(0.0, 0.0, 0.6, 0.35, 0); // Gövde
        oval(0.3, -0.25, 0.2, 0.4, 0.5); // Dik boyun
        oval(0.4, -0.45, 0.35, 0.15, 0.3); // İleri baş
        capsule(-0.25, 0.1, -0.3, 0.5, 0.08); // Arka bacak
        capsule(-0.15, 0.1, -0.1, 0.5, 0.08); // Arka bacak
        capsule(0.2, 0.1, 0.25, 0.5, 0.08); // Ön bacak
        capsule(0.35, 0.1, 0.4, 0.45, 0.08); // Ön bacak
        oval(-0.4, 0.0, 0.35, 0.1, -0.4); // Görkemli kuyruk
        // Yele
        capsule(0.2, -0.35, 0.1, -0.25, 0.05);
        capsule(0.25, -0.25, 0.15, -0.15, 0.05);
        break;
      case 7: // Keçi (Goat)
        oval(0.05, 0.05, 0.6, 0.35, 0); // Gövde
        oval(0.4, -0.2, 0.2, 0.15, 0.3); // Baş
        capsule(0.3, -0.25, 0.1, -0.4, 0.06); // Geri kıvrık boynuz
        capsule(-0.2, 0.15, -0.2, 0.5, 0.08); // Bacaklar
        capsule(-0.05, 0.15, -0.05, 0.5, 0.08);
        capsule(0.25, 0.15, 0.25, 0.5, 0.08);
        capsule(0.4, 0.15, 0.4, 0.5, 0.08);
        poly([0.45, -0.1, 0.4, 0.0, 0.5, -0.05]); // Sakal
        capsule(-0.35, 0.05, -0.45, 0.1, 0.06); // Kısa kuyruk
        break;
      case 8: // Maymun (Monkey)
        oval(0.0, 0.1, 0.35, 0.45, -0.2); // Gövde (ayakta/kambur)
        circle(0.15, -0.2, 0.18); // Baş
        capsule(0.1, -0.05, 0.4, 0.25, 0.08); // Uzun kolları
        capsule(0.05, 0.25, -0.15, 0.5, 0.08); // Bacakları
        capsule(0.15, 0.25, 0.0, 0.5, 0.08); // Bacakları
        // Dev Karakteristik Kuyruk (S Şeklinde kıvrım)
        final mp = Path()..moveTo(-s * 0.1, s * 0.3)..cubicTo(-s * 0.8, s * 0.4, -s * 0.8, -s * 0.5, -s * 0.2, -s * 0.4);
        canvas.drawPath(mp, Paint()..shader = f.shader..style = PaintingStyle.stroke..strokeWidth = s * 0.1..strokeCap = StrokeCap.round);
        break;
      case 9: // Horoz (Rooster)
        oval(0.0, 0.1, 0.4, 0.35, -0.2); // Göğüs
        circle(0.2, -0.15, 0.12); // Baş
        poly([0.3, -0.18, 0.45, -0.15, 0.3, -0.12]); // Gaga
        circle(0.2, -0.28, 0.06); // İbik
        circle(0.28, -0.25, 0.05); // İbik
        // Dev Yelpaze Kuyruk
        oval(-0.25, -0.15, 0.4, 0.15, -0.8);
        oval(-0.3, -0.05, 0.4, 0.15, -0.4);
        oval(-0.3, 0.1, 0.45, 0.15, 0.0);
        capsule(0.0, 0.3, -0.05, 0.55, 0.05); // Bacak
        capsule(0.1, 0.3, 0.15, 0.55, 0.05); // Bacak
        break;
      case 10: // Köpek (Dog)
        oval(0.0, 0.1, 0.6, 0.3, 0); // Gövde
        capsule(0.2, 0.1, 0.35, -0.05, 0.15); // Boyun
        circle(0.35, -0.1, 0.14); // Baş
        capsule(0.35, -0.1, 0.55, -0.05, 0.12); // Burun
        poly([0.28, -0.1, 0.25, -0.3, 0.38, -0.15]); // Dik kulak
        capsule(-0.3, 0.1, -0.4, -0.15, 0.1); // Dik kuyruk
        capsule(-0.2, 0.2, -0.2, 0.5, 0.08); // Arka bacak
        capsule(0.2, 0.2, 0.2, 0.5, 0.08); // Ön bacak
        break;
      case 11: // Domuz (Pig)
        oval(0.0, 0.1, 0.8, 0.45, 0); // Tombul gövde
        circle(0.4, 0.05, 0.22); // Baş
        oval(0.55, 0.1, 0.15, 0.2, 0); // Burun/Domuz Burn
        circle(0.38, -0.12, 0.09); // Kulak
        capsule(-0.3, 0.3, -0.3, 0.5, 0.1); // Bacak 1
        capsule(-0.1, 0.3, -0.1, 0.5, 0.1); // Bacak 2
        capsule(0.2, 0.3, 0.2, 0.5, 0.1); // Bacak 3
        capsule(0.4, 0.3, 0.4, 0.5, 0.1); // Bacak 4
        poly([-0.4, 0.0, -0.5, 0.0, -0.4, -0.1]); // Kıvrık minik kuyruk
        break;
    }
  }

  @override
  bool shouldRepaint(covariant ChineseWheelPainter old) => old.rotation != rotation;
}

class MayanWheelPainter extends CustomPainter {
  final double rotation;
  final Color gold, goldD;
  final bool isMini;
  MayanWheelPainter({required this.rotation, required this.gold, required this.goldD, this.isMini = false});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    
    // Uygulamanın ana temasıyla tam uyumlu zarif altın 
    final g = gold; 
    final double sm = isMini ? 0.35 : 1.0; // Stroke Multiplier (Mini modda çizgiler ipince olur)

    // Hafif zemin izi (Eğer mini değilse, blur ve gradient korunsun)
    if (!isMini) {
      canvas.drawCircle(c, r, Paint()..shader = RadialGradient(
        colors: [g.withOpacity(0.05), Colors.transparent],
      ).createShader(Rect.fromCircle(center: c, radius: r)));
    }

    // Daha ince ve narin çizgiler
    final pLine = Paint()..color = g.withOpacity(0.6)..style = PaintingStyle.stroke..strokeWidth = 1.0 * sm..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(rotation * math.pi * 0.5); // Ağır dönüş
    
    // 1. Dış Sınırlar 
    canvas.drawCircle(Offset.zero, r - 2, pLine..strokeWidth = 1.2 * sm);
    canvas.drawCircle(Offset.zero, r - 6, pLine..strokeWidth = 0.5 * sm);

    // 2. Dış 20 Nawal (Tzolkin Glifleri)
    final glyphR = r * 0.82;
    final glyphRadius = r * 0.12;
    for (int i = 0; i < 20; i++) {
        canvas.save();
        canvas.rotate(i * (math.pi * 2 / 20));
        canvas.translate(0, -glyphR);
        
        // Klasik Maya Hiyeroglif Çerçevesi (Sadeleştirildi)
        final crRect = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: glyphRadius * 1.8, height: glyphRadius * 1.6), const Radius.circular(8));
        if (!isMini) canvas.drawRRect(crRect, Paint()..color = g.withOpacity(0.03)..style = PaintingStyle.fill);
        canvas.drawRRect(crRect, pLine..strokeWidth = 0.8 * sm);
        
        // İçine GERÇEK Maya Burç piktogramlarını (Nawal) çiziyoruz
        _drawAuthenticNawal(canvas, i, glyphRadius * 0.9, g.withOpacity(0.8), sm);

        canvas.restore();
    }

    // 3. Bölücü Sınır 
    final innerBoundR = r * 0.68;
    canvas.drawCircle(Offset.zero, innerBoundR, pLine..strokeWidth = 2.0 * sm);
    canvas.drawCircle(Offset.zero, innerBoundR - 4, pLine..strokeWidth = 0.8 * sm);

    // 4. GALAKTİK TONLAR HALKASI 
    final toneR = r * 0.55;
    for (int i = 0; i < 13; i++) {
        canvas.save();
        canvas.rotate(i * (math.pi * 2 / 13));
        
        canvas.drawLine(Offset(0, -innerBoundR + 4), Offset(0, -toneR), Paint()..color=g.withOpacity(0.3)..style=PaintingStyle.stroke..strokeWidth=1.5 * sm);

        int num = i + 1;
        int bars = num ~/ 5;
        int dots = num % 5;
        
        double currentR = innerBoundR - 12;
        final pBar = Paint()..color = g.withOpacity(0.7)..style = PaintingStyle.stroke..strokeWidth = 2.5 * sm..strokeCap = StrokeCap.round;
        final pDot = Paint()..color = g.withOpacity(0.7)..style = PaintingStyle.fill;
        
        for (int b = 0; b < bars; b++) {
            final sweep = math.pi * 2 / 13 * 0.45; 
            canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: currentR), -math.pi / 2 - sweep / 2, sweep, false, pBar);
            currentR -= 8; 
        }
        
        if (bars > 0 && dots > 0) currentR -= 2;
        
        if (dots > 0) {
            final arcLen = math.pi * 2 / 13 * 0.35;
            final dotStep = dots > 1 ? arcLen / (dots - 1) : 0;
            final startA = -math.pi / 2 - (dots > 1 ? arcLen / 2 : 0);
            for (int d = 0; d < dots; d++) {
                final dAngle = startA + d * dotStep;
                canvas.drawCircle(Offset(math.cos(dAngle) * currentR, math.sin(dAngle) * currentR), 2.0 * sm, pDot);
            }
        }
        canvas.restore();
    }

    // 5. İç İnce Sınır 
    canvas.drawCircle(Offset.zero, toneR, pLine..strokeWidth = 1.5 * sm);
    
    // 6. Orta Katman - Maya Güneş Dalgaları 
    final centerFaceR = r * 0.38;
    for (int i = 0; i < 20; i++) {
        canvas.save();
        canvas.rotate((i + 0.5) * (math.pi * 2 / 20));
        final rayP = Path()
           ..moveTo(0, -centerFaceR)
           ..lineTo(-r*0.06, -toneR)
           ..lineTo(r*0.06, -toneR)
           ..close();
        if(!isMini) canvas.drawPath(rayP, Paint()..color = g.withOpacity(0.15)..style = PaintingStyle.fill);
        canvas.drawPath(rayP, Paint()..color = g.withOpacity(0.4)..style = PaintingStyle.stroke..strokeWidth=1.0 * sm);
        canvas.restore();
    }

    // 7. MERKEZ: Hunab Ku
    if (!isMini) canvas.drawCircle(Offset.zero, centerFaceR, Paint()..color = g.withOpacity(0.04)..style = PaintingStyle.fill);
    canvas.drawCircle(Offset.zero, centerFaceR, pLine..strokeWidth = 1.2 * sm);
    canvas.drawCircle(Offset.zero, centerFaceR - 4, pLine..strokeWidth = 0.5 * sm);
    
    _drawTrueMayanHunabKu(canvas, centerFaceR * 0.85, g.withOpacity(0.85), sm, isMini);

    canvas.restore();
  }

  void _drawTrueMayanHunabKu(Canvas c, double r, Color g, double sm, bool isMini) {
    final pLine = Paint()..color = g..style = PaintingStyle.stroke..strokeWidth = 2.0 * sm..strokeCap = StrokeCap.round;
    final pFill = Paint()..color = g.withValues(alpha: 0.15)..style = PaintingStyle.fill;
    final pGlow = Paint()..color = g.withValues(alpha: 0.1)..style = PaintingStyle.fill..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    if (!isMini) {
      c.drawCircle(Offset.zero, r * 0.45, pGlow);
      c.drawCircle(Offset.zero, r * 0.45, pFill);
    }

    c.drawCircle(Offset.zero, r * 0.45, pLine);

    final dualPath = Path()
      ..moveTo(0, -r * 0.45)
      ..cubicTo(-r * 0.4, -r * 0.15, r * 0.4, r * 0.15, 0, r * 0.45);
    c.drawPath(dualPath, pLine..strokeWidth = 2.5 * sm);

    if (!isMini) {
      c.drawCircle(Offset(-r * 0.2, -r * 0.15), r * 0.07 * sm, Paint()..color = g..style = PaintingStyle.fill);
      c.drawCircle(Offset(r * 0.2, r * 0.15), r * 0.07 * sm, Paint()..color = g..style = PaintingStyle.fill);
    }

    for (int i = 0; i < 4; i++) {
        c.save();
        c.rotate(i * math.pi / 2);
        
        final petalPath = Path()
          ..moveTo(-r * 0.12, -r * 0.5)
          ..quadraticBezierTo(-r * 0.2, -r * 0.8, 0, -r * 0.95) 
          ..quadraticBezierTo(r * 0.2, -r * 0.8, r * 0.12, -r * 0.5);
          
        c.drawPath(petalPath, pLine..strokeWidth = 1.6 * sm);
        if (!isMini) c.drawPath(petalPath, pFill);
        
        c.drawLine(Offset(0, -r * 0.52), Offset(0, -r * 0.88), pLine..strokeWidth = 1.0 * sm);
        
        c.restore();
        c.save();
        c.rotate(i * math.pi / 2 + math.pi / 4);
        c.drawLine(Offset(0, r * 0.5), Offset(0, r * 0.75), pLine..strokeWidth = 1.8 * sm);
        if (!isMini) c.drawCircle(Offset(0, r * 0.8), r * 0.04 * sm, Paint()..color = g..style = PaintingStyle.fill);
        c.restore();
    }
  }

  void _drawAuthenticNawal(Canvas c, int i, double h, Color g, double sm) {
     final p = Paint()..color = g..style = PaintingStyle.stroke..strokeWidth = 1.6 * sm..strokeCap = StrokeCap.round;
     final f = Paint()..color = g..style = PaintingStyle.fill;

     
     // Her sembol, resimdeki gerçek 20 Maya hiyeroglifine doğrudan atıf yapar.
     switch (i) {
         case 0: // B'atz (Maymun / Kıvrımlı sarmaşık)
             c.drawArc(Rect.fromCenter(center: Offset(0, -h*0.2), width: h*1.2, height: h*1.2), 0, math.pi*1.5, false, p..strokeWidth=2.5);
             c.drawLine(Offset(0, -h*0.8), Offset(0, 0), p);
             break;
         case 1: // E (Yol / Basamaklı Dişler)
             c.drawLine(Offset(-h*0.6, h*0.4), Offset(h*0.6, h*0.4), p); // Taban
             c.drawRect(Rect.fromLTRB(-h*0.4, -h*0.2, -h*0.1, h*0.4), p);
             c.drawRect(Rect.fromLTRB(h*0.1, -h*0.2, h*0.4, h*0.4), p);
             c.drawCircle(Offset(0, h*0.1), 2, f);
             break;
         case 2: // Aj (Tohum, Sazlık / 3 dikine sap)
             c.drawLine(Offset(-h*0.4, -h*0.6), Offset(-h*0.4, h*0.6), p);
             c.drawLine(Offset(0, -h*0.6), Offset(0, h*0.6), p);
             c.drawLine(Offset(h*0.4, -h*0.6), Offset(h*0.4, h*0.6), p);
             c.drawLine(Offset(-h*0.8, 0), Offset(h*0.8, 0), p);
             break;
         case 3: // I'x (Jaguar / Kalp ve 3 benek)
             c.drawCircle(Offset(-h*0.3, -h*0.3), h*0.15, p);
             c.drawCircle(Offset(h*0.3, -h*0.3), h*0.15, p);
             c.drawCircle(Offset(0, h*0.2), h*0.15, p);
             // Noktalar
             c.drawCircle(Offset(-h*0.3, -h*0.3), 2, f);
             c.drawCircle(Offset(h*0.3, -h*0.3), 2, f);
             c.drawCircle(Offset(0, h*0.2), 2, f);
             break;
         case 4: // Tz'ikin (Kuş / Kartal Gagası)
             c.drawArc(Rect.fromCenter(center: Offset.zero, width: h*1.2, height: h*1.2), math.pi, math.pi/2, false, p);
             c.drawLine(Offset(0, -h*0.6), Offset(0, h*0.2), p);
             c.drawLine(Offset(0, h*0.2), Offset(h*0.6, h*0.2), p); // Gaga
             c.drawCircle(Offset(-h*0.2, -h*0.2), 3, f); // Göz
             break;
         case 5: // Ajmaq (Baykuş / İki yay ve nokta)
             c.drawArc(Rect.fromCenter(center: Offset(-h*0.3, 0), width: h*0.6, height: h*0.8), math.pi/2, math.pi, false, p);
             c.drawArc(Rect.fromCenter(center: Offset(h*0.3, 0), width: h*0.6, height: h*0.8), -math.pi/2, math.pi, false, p);
             c.drawCircle(Offset(0, h*0.2), 3, f);
             break;
         case 6: // No'j (Dünya/Bilgelik / Loblu beyin kıvrımı)
             final pth1 = Path()..moveTo(-h*0.6, h*0.4)..quadraticBezierTo(0, -h*0.8, h*0.6, h*0.4);
             c.drawPath(pth1, p);
             final pth2 = Path()..moveTo(-h*0.3, h*0.4)..quadraticBezierTo(0, -h*0.2, h*0.3, h*0.4);
             c.drawPath(pth2, p);
             break;
         case 7: // Tijax (Obsidyen, Bıçak / Çapraz kesişim ve dişler)
             c.drawLine(Offset(-h*0.6, -h*0.6), Offset(h*0.6, h*0.6), p);
             c.drawLine(Offset(h*0.6, -h*0.6), Offset(-h*0.6, h*0.6), p); // Çarpı
             c.drawArc(Rect.fromCenter(center: Offset(0, -h*0.3), width: h*0.4, height: h*0.4), 0, math.pi, true, p); // Üst taş parçası
             break;
         case 8: // Kawoq (Fırtına / Bulut kümeleri)
             c.drawCircle(Offset(-h*0.3, -h*0.2), h*0.3, p);
             c.drawCircle(Offset(h*0.3, -h*0.2), h*0.3, p);
             c.drawCircle(Offset(0, h*0.3), h*0.3, p);
             c.drawCircle(Offset(0, h*0.3), 3, f);
             break;
         case 9: // Ajpu (Güneş / Üfleme Çubuğu nişancısı yüzü)
             c.drawOval(Rect.fromCenter(center: Offset.zero, width: h*1.2, height: h*1.2), p);
             c.drawCircle(Offset(-h*0.2, -h*0.1), h*0.15, p);
             c.drawCircle(Offset(h*0.2, -h*0.1), h*0.15, p);
             c.drawCircle(Offset(0, h*0.3), h*0.2, p); // Ağız / Üfleme deliği
             break;
         case 10: // Imox (Söğüt/Kök / Tırtıklı yarım ay)
             c.drawArc(Rect.fromCenter(center: Offset(0, 0), width: h*1.4, height: h*1.2), math.pi/2, math.pi, false, p..strokeWidth=2.0);
             c.drawLine(Offset(0, -h*0.6), Offset(h*0.4, -h*0.6), p);
             c.drawLine(Offset(0, 0), Offset(h*0.4, 0), p);
             c.drawLine(Offset(0, h*0.6), Offset(h*0.4, h*0.6), p);
             break;
         case 11: // Iq' (Rüzgar / T Şekli Pencere)
             c.drawLine(Offset(-h*0.5, -h*0.3), Offset(h*0.5, -h*0.3), p..strokeWidth=3.0); // Kalın üst
             c.drawLine(Offset(0, -h*0.3), Offset(0, h*0.5), p..strokeWidth=3.0);
             c.drawLine(Offset(-h*0.4, h*0.5), Offset(h*0.4, h*0.5), p..strokeWidth=3.0); // Alt taban
             break;
         case 12: // Aq'ab'al (Gece-Gündüz / Ortadan bölük ve noktalar)
             c.drawOval(Rect.fromCenter(center: Offset.zero, width: h*1.4, height: h*1.4), p);
             c.drawLine(Offset(0, -h*0.7), Offset(0, h*0.7), p..strokeWidth=2.5);
             c.drawCircle(Offset(-h*0.3, 0), h*0.12, f); // Koyu yan
             c.drawCircle(Offset(h*0.3, 0), h*0.12, p); // Açık yan
             break;
         case 13: // K'at (Ağ, Tohum Kümesi / Çapraz Hasır)
             c.drawRect(Rect.fromCenter(center: Offset.zero, width: h*1.2, height: h*1.2), p);
             c.drawLine(Offset(-h*0.6, -h*0.2), Offset(h*0.6, -h*0.2), p);
             c.drawLine(Offset(-h*0.6, h*0.2), Offset(h*0.6, h*0.2), p);
             c.drawLine(Offset(-h*0.2, -h*0.6), Offset(-h*0.2, h*0.6), p);
             c.drawLine(Offset(h*0.2, -h*0.6), Offset(h*0.2, h*0.6), p);
             break;
         case 14: // Kan (Yılan / Güç ve kıvrım)
             final snakeP = Path()..moveTo(-h*0.6, -h*0.4)..quadraticBezierTo(0, -h*0.8, h*0.4, -h*0.2)..quadraticBezierTo(h*0.8, 0, h*0.4, h*0.2)..quadraticBezierTo(0, h*0.4, -h*0.6, h*0.4);
             c.drawPath(snakeP, p..strokeWidth=2.4);
             c.drawCircle(Offset(h*0.5, 0), 2, f); // Göz
             break;
         case 15: // Keme (Ölüm / Kafatası, Kapalı Göz)
             c.drawOval(Rect.fromCenter(center: Offset(0, -h*0.1), width: h*1.2, height: h*1.0), p);
             c.drawLine(Offset(-h*0.5, h*0.4), Offset(h*0.5, h*0.4), p); // Diş çizgisi
             c.drawLine(Offset(0, h*0.3), Offset(0, h*0.5), p);
             c.drawLine(Offset(-h*0.3, -h*0.2), Offset(h*0.3, -h*0.2), p); // Kapalı göz
             break;
         case 16: // Kej (Geyik / El şeklinde organ, kıvrımlı tutuş)
             c.drawLine(Offset(-h*0.4, -h*0.5), Offset(-h*0.4, h*0.5), p);
             // 3 Parmak
             c.drawArc(Rect.fromCenter(center: Offset(0, -h*0.3), width: h*0.8, height: h*0.4), 0, math.pi, false, p);
             c.drawArc(Rect.fromCenter(center: Offset(0, 0), width: h*0.8, height: h*0.4), 0, math.pi, false, p);
             c.drawArc(Rect.fromCenter(center: Offset(0, h*0.3), width: h*0.8, height: h*0.4), 0, math.pi, false, p);
             break;
         case 17: // Q'anil (Venüs, Yıldız, Tohum / Elmas ve 4 nokta)
             final diaP = Path()..moveTo(0, -h*0.4)..lineTo(h*0.4, 0)..lineTo(0, h*0.4)..lineTo(-h*0.4, 0)..close();
             c.drawPath(diaP, p);
             c.drawCircle(Offset(0, -h*0.6), 3, f);
             c.drawCircle(Offset(0, h*0.6), 3, f);
             c.drawCircle(Offset(-h*0.6, 0), 3, f);
             c.drawCircle(Offset(h*0.6, 0), 3, f);
             break;
         case 18: // Toj (Ateş, Su Damlası / Yeşim kolye damlası)
             final dropP = Path()..moveTo(0, -h*0.6)..quadraticBezierTo(-h*0.6, h*0.2, 0, h*0.6)..quadraticBezierTo(h*0.6, h*0.2, 0, -h*0.6);
             c.drawPath(dropP, p..strokeWidth=2.0);
             c.drawCircle(Offset(0, h*0.2), h*0.15, p);
             break;
         case 19: // Tz'i' (Köpek / Sarkık kulak ve dik yüz)
             c.drawOval(Rect.fromCenter(center: Offset.zero, width: h*1.0, height: h*1.4), p);
             c.drawArc(Rect.fromCenter(center: Offset(-h*0.5, 0), width: h*0.6, height: h*0.8), -math.pi/2, math.pi, false, p); // Sarkık kulak
             c.drawCircle(Offset(h*0.2, -h*0.2), 3, f); // Göz
             c.drawCircle(Offset(h*0.2, h*0.3), h*0.1, p); // Burun
             break;
     }
  }

  @override
  bool shouldRepaint(covariant MayanWheelPainter old) => old.rotation != rotation;
}
