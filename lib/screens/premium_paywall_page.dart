import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/purchase_service.dart';
import '../services/analytics_service.dart';
import '../services/profile_sync_service.dart';
class PremiumPaywallPage extends StatefulWidget {
  const PremiumPaywallPage({super.key});

  @override
  State<PremiumPaywallPage> createState() => _PremiumPaywallPageState();
}

class _PremiumPaywallPageState extends State<PremiumPaywallPage> with TickerProviderStateMixin {
  late AnimationController _animController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  int _selectedPackageIndex = 2; // Yıllık Varsayılan
  bool _isRestoring = false;
  bool _isPurchasing = false;
  bool _isAlreadyElite = false;
  int? _activePackageIndex;

  @override
  void initState() {
    super.initState();
    _checkEliteStatus();
    AnalyticsService().logPaywallViewed();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    
    _animController.forward();
  }

  Future<void> _checkEliteStatus() async {
    if (!mounted) return;
    
    // 1. Önce Supabase'den güncel statüyü çek
    final isEliteInCloud = await ProfileSyncService().fetchEliteStatus();
    
    // 2. Lokal veriyi güncelle
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_elite', isEliteInCloud);
    await prefs.setBool('is_premium_test_mode', isEliteInCloud); // Eski uyumluluk için
    
    if (!mounted) return;
    setState(() {
      _isAlreadyElite = isEliteInCloud;
      
      final type = prefs.getString('elite_plan_type');
      if (type == 'weekly') _activePackageIndex = 0;
      else if (type == 'monthly') _activePackageIndex = 1;
      else if (type == 'yearly') _activePackageIndex = 2;

      // Plan yükseltmeyi teşvik et: Mümkünse bir üst paketi varsayılan seç
      if (_isAlreadyElite && _activePackageIndex != null) {
        if (_activePackageIndex == 0) _selectedPackageIndex = 1;
        else if (_activePackageIndex == 1) _selectedPackageIndex = 2;
        else if (_activePackageIndex == 2) _selectedPackageIndex = 2;
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          }
        },
        child: Stack(
          children: [
          // ── TÜM SAYFA BUZLU CAM EFEKTİ ──
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                color: const Color(0xFF0A0A0C).withOpacity(0.7), // Alt sayfayı gösteren yarı saydam lüks siyah
              ),
            ),
          ),

          // ── ARKA PLAN IŞIK EFEKTLERİ ──
          Positioned(
            top: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFC084FC).withOpacity(0.25),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFD700).withOpacity(0.20),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(),
              ),
            ),
          ),

          // ── TEK SAYFA DÜZENİ ──
          SafeArea(
            child: Column(
              children: [
                // ── ÜST BAR (SABİT) ──
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 10), // Tepe barlarına yapışmayı engellemek için top paddding 24 eklendi
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (_isRestoring) return;
                          HapticFeedback.lightImpact();
                          setState(() => _isRestoring = true);
                          
                          try {
                            await PurchaseService().restorePurchases();
                            await Future.delayed(const Duration(seconds: 2));
                            
                            final isElite = await PurchaseService().isUserElite();
                            
                            if (!mounted) return;
                            setState(() => _isRestoring = false);
                            
                            if (isElite) {
                              HapticFeedback.heavyImpact();
                              setState(() => _isAlreadyElite = true);
                              
                              // Supabase'e bildir
                              await ProfileSyncService().syncEliteStatus(true);
                              
                              _showGlassMessage(
                                "Elite Geri Yüklendi",
                                "Kozmik farkındalığa yeniden hoş geldiniz. Sınırlarınız kaldırıldı.",
                                Icons.check_circle_rounded,
                                const Color(0xFF10B981),
                                onOk: () {
                                  Navigator.pop(context);
                                }
                              );
                            } else {
                              HapticFeedback.vibrate();
                              _showGlassMessage(
                                "Aktif Abonelik Yok",
                                "Geri yüklenebilecek aktif bir Crack Wish Elite üyeliği bulunamadı. Lütfen paketleri inceleyin.",
                                Icons.error_outline_rounded,
                                const Color(0xFFF87171),
                              );
                            }
                          } catch (e) {
                            debugPrint('Geri yükleme hatası: $e');
                            if (mounted) setState(() => _isRestoring = false);
                          }
                        },
                        child: _isRestoring 
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2))
                          : const Text("Satın Alımları Geri Yükle", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.3)),
                      )
                    ],
                  ),
                ),

                // ── MERKEZİ İÇERİK ──
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(), // Ekran küçükse veya taşma varsa kullanıcı kaydırabilsin (Taşıp butonları ezmesin)
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: constraints.maxHeight),
                            child: IntrinsicHeight(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                            // ── ICON & BAŞLIK ──
                            ScaleTransition(
                              scale: _pulseAnimation,
                              child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [const Color(0xFFFFD700).withOpacity(0.15), const Color(0xFFC084FC).withOpacity(0.1)],
                                ),
                                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3), width: 0.5),
                                boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.15), blurRadius: 20, spreadRadius: 2)],
                              ),
                              child: const Icon(Icons.workspace_premium_rounded, color: Color(0xFFE5C07B), size: 26),
                            ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Crack Wish Elite",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22, // reduced
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isAlreadyElite 
                                ? "Kozmik farkındalığın zaten açık.\nPlanını yükselterek aydınlanmanı güçlendir."
                                : "Kozmik farkındalığa giden kapıyı aç.\nSınırları tamamen kaldır.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 12, // reduced
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 16), // from 26

                            // ── MENÜ BAR STİLİ CAM PANEL İÇİNDE ÖZELLİKLER ──
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18), // reduced slightly
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // reduced
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.03),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: Colors.white.withOpacity(0.06), width: 0.5),
                                  ),
                                  child: Column(
                                    children: [
                                      _buildCompactFeature(Icons.diamond_rounded, const Color(0xFF4EE6C5), "Günde 5 Taze Ruh Taşı"),
                                      _buildCompactFeature(Icons.psychology_alt_rounded, const Color(0xFFC084FC), "Master Analiz Modu"),
                                      _buildCompactFeature(Icons.auto_awesome, const Color(0xFFFFD700), "x3 Hızlı Aura Kazanımı"),
                                      _buildCompactFeature(Icons.auto_stories_rounded, const Color(0xFF94A3B8), "Sonsuz Klinik Arşiv"),
                                      _buildCompactFeature(Icons.block_rounded, const Color(0xFFF87171), "Reklamsız Kesintisiz Deneyim", isLast: true),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 16), // from 28

                            // ── CAM TASARIMLI 3'LÜ PAKET DİZİLİMİ ──
                            _buildGlassPackageRow(0, "Haftalık Uyanış", "\$2.99", "/ week"),
                            _buildGlassPackageRow(1, "Aylık Sezgi", "\$7.99", "/ month", subText: "Save 33%"),
                            _buildGlassPackageRow(2, "Yıllık Aydınlanma", "\$39.99", "/ year", badge: "Popular", subText: "Just \$3.33/mo (Save 58%)"),
                            const SizedBox(height: 16), // from 24
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // ── ALT BUTON VE YASAL METİN (SABİT) ──
                SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 16), // from 24, 8, 24, 24
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(26), // from 30
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                            child: Builder(
                              builder: (context) {
                                final bool isCurrentPlan = _isAlreadyElite && _selectedPackageIndex == _activePackageIndex;
                                final bool isDowngrade = _isAlreadyElite && _activePackageIndex != null && _selectedPackageIndex < _activePackageIndex!;
                                final bool isUpgrade = _isAlreadyElite && _activePackageIndex != null && _selectedPackageIndex > _activePackageIndex!;
                                
                                final bool useGradient = !isCurrentPlan && !isDowngrade;
                                final bool isDisabled = _isPurchasing || isCurrentPlan;

                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: useGradient 
                                      ? const LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [Color(0xFFFFD700), Color(0xFFC084FC)],
                                        )
                                      : null,
                                    color: !useGradient ? Colors.white.withOpacity(0.08) : null,
                                    borderRadius: BorderRadius.circular(26),
                                    boxShadow: useGradient 
                                      ? [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4))]
                                      : null,
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(26),
                                      onTap: isDisabled ? null : () async {
                                        if (isDowngrade) {
                                          HapticFeedback.lightImpact();
                                          // Apple/Google store'a yönlendir
                                          final url = Theme.of(context).platform == TargetPlatform.iOS 
                                            ? "https://apps.apple.com/account/subscriptions" 
                                            : "https://play.google.com/store/account/subscriptions";
                                          _launchURL(url);
                                          return;
                                        }

                                        HapticFeedback.heavyImpact();
                                        setState(() => _isPurchasing = true);
                                        
                                        try {
                                          final productId = _selectedPackageIndex == 0 
                                            ? PurchaseService.eliteWeeklyId 
                                            : (_selectedPackageIndex == 1 
                                              ? PurchaseService.eliteMonthlyId 
                                              : PurchaseService.eliteYearlyId);
                                          
                                          final success = await PurchaseService().purchase(productId);
                                          
                                          if (success && mounted) {
                                            final prefs = await SharedPreferences.getInstance();
                                            final plan = _selectedPackageIndex == 0 ? 'weekly' : (_selectedPackageIndex == 1 ? 'monthly' : 'yearly');
                                            await prefs.setString('elite_plan_type', plan);
                                            await prefs.setInt('daily_elite_soul_stones', 5);
                                            
                                            await ProfileSyncService().syncEliteStatus(true);
                                            
                                            if (!mounted) return;
                                            setState(() {
                                              _isPurchasing = false;
                                              _isAlreadyElite = true;
                                              _activePackageIndex = _selectedPackageIndex;
                                            });
                                            
                                            _showGlassMessage(
                                              isUpgrade ? "Aydınlanma Yükseldi" : "Aydınlanmaya Hoşgeldiniz",
                                              isUpgrade ? "Planınız başarıyla yükseltildi." : "Artık bir Elite üyesisiniz. Kozmik sınırlar sizin için kaldırıldı.",
                                              Icons.auto_awesome,
                                              const Color(0xFFFFD700),
                                              onOk: () {
                                                Navigator.pop(context, true);
                                              }
                                            );
                                          } else if (mounted) {
                                            setState(() => _isPurchasing = false);
                                            _showGlassMessage(
                                              "Bağlantı Hatası",
                                              "Mağazaya bağlanılamadı veya işlem iptal edildi. Ürünler henüz App Store/Play Console'da yayına alınmamış olabilir. Lütfen daha sonra tekrar deneyin.",
                                              Icons.error_outline_rounded,
                                              const Color(0xFFF87171),
                                            );
                                          }
                                        } catch (e) {
                                          debugPrint('Elite satın alma hatası: $e');
                                          if (mounted) setState(() => _isPurchasing = false);
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        child: Center(
                                          child: _isPurchasing
                                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                              : Text(
                                                  isCurrentPlan 
                                                    ? "Mevcut Planın" 
                                                    : (isDowngrade ? "Mağazadan Yönet" : (isUpgrade ? "Planı Yükselt" : "Elite Sınırlarını Aç")),
                                                  style: TextStyle(
                                                    color: useGradient ? const Color(0xFF1A1A2E) : Colors.white.withOpacity(isCurrentPlan ? 0.3 : 0.9), 
                                                    fontSize: 16, 
                                                    fontWeight: FontWeight.w800, 
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Aboneliğiniz, mevcut dönemin bitiminden en az 24 saat önce iptal edilmediği sürece otomatik olarak yenilenir. Aboneliğinizi mağaza hesap ayarlarınızdan dilediğiniz zaman yönetebilirsiniz.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 9, height: 1.3),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                final lang = Localizations.localeOf(context).languageCode;
                                _launchURL("https://crackwish.com/privacy.html#$lang");
                              },
                              child: Text("Gizlilik Sözleşmesi", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9, decoration: TextDecoration.underline, decorationColor: Colors.white.withOpacity(0.5))),
                            ),
                            Text("   •   ", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 9)),
                            GestureDetector(
                              onTap: () {
                                final lang = Localizations.localeOf(context).languageCode;
                                _launchURL("https://crackwish.com/terms.html#$lang");
                              },
                              child: Text("Kullanım Şartları", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9, decoration: TextDecoration.underline, decorationColor: Colors.white.withOpacity(0.5))),
                            ),
                          ],
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
    );
  }

  void _selectPackage(int index) {
    if (_selectedPackageIndex != index) {
      HapticFeedback.selectionClick();
      setState(() {
        _selectedPackageIndex = index;
      });
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Launch URL error: $e');
    }
  }

  Widget _buildCompactFeature(IconData icon, Color color, String title, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 6), // from 8
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4), // from 5
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 12), // from 14
          ),
          const SizedBox(width: 10), // from 14
          Text(title, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12, fontWeight: FontWeight.w500)), // from 13
        ],
      ),
    );
  }

  Widget _buildGlassPackageRow(int index, String title, String price, String duration, {String? badge, String? subText}) {
    final bool isDowngrade = _isAlreadyElite && _activePackageIndex != null && index < _activePackageIndex!;
    final bool isSelected = _selectedPackageIndex == index;
    final bool isActivePlan = _isAlreadyElite && _activePackageIndex == index;
    final Color highlightColor = isActivePlan ? const Color(0xFF10B981) : const Color(0xFFFFD700);
    final String? finalBadge = isActivePlan ? "MEVCUT PLAN" : badge;

    return GestureDetector(
      onTap: isDowngrade ? null : () => _selectPackage(index),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isDowngrade ? 0.3 : 1.0,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                    ? highlightColor.withOpacity(0.08)
                    : (isActivePlan ? highlightColor.withOpacity(0.04) : Colors.white.withOpacity(0.03)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? highlightColor.withOpacity(0.5) : (isActivePlan ? highlightColor.withOpacity(0.3) : Colors.white.withOpacity(0.08)),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    // Seçim Halkası
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? highlightColor : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? highlightColor : (isActivePlan ? highlightColor.withOpacity(0.6) : Colors.white.withOpacity(0.2)),
                          width: 1.0,
                        ),
                      ),
                      child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.black) : null,
                    ),
                    const SizedBox(width: 14),
                    
                    // Paket Adı ve Alt Metin
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                              if (finalBadge != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: highlightColor, borderRadius: BorderRadius.circular(6)),
                                  child: Text(finalBadge.toUpperCase(), style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900)),
                                ),
                              ]
                            ],
                          ),
                          if (subText != null) ...[
                            const SizedBox(height: 4),
                            Text(subText, style: TextStyle(color: highlightColor.withOpacity(0.9), fontSize: 11, fontWeight: FontWeight.w500)),
                          ]
                        ],
                      ),
                    ),

                    // Fiyat
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(price, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        Text(duration, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
                      ],
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

  void _showGlassMessage(String title, String subtitle, IconData icon, Color color, {VoidCallback? onOk}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1E).withOpacity(0.6), // Çok koyu saydam lüks zemin
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: color.withOpacity(0.3), width: 1),
                        ),
                        child: Icon(icon, color: color, size: 36),
                      ),
                      const SizedBox(height: 20),
                      Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
                      const SizedBox(height: 8),
                      Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, height: 1.4)),
                      const SizedBox(height: 28),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context); // Modal kapat
                          if (onOk != null) onOk(); // Varsa ek action (örn: paywall kapat)
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: const Text("Tamam", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutBack)),
            child: child,
          ),
        );
      },
    );
  }
}
