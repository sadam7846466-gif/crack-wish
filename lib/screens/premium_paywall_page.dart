import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PremiumPaywallPage extends StatefulWidget {
  const PremiumPaywallPage({super.key});

  @override
  State<PremiumPaywallPage> createState() => _PremiumPaywallPageState();
}

class _PremiumPaywallPageState extends State<PremiumPaywallPage> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _selectedPackageIndex = 2; // Yıllık Varsayılan

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
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
                color: const Color(0xFFC084FC).withOpacity(0.12),
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
                color: const Color(0xFFFFD700).withOpacity(0.08),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                        onTap: () {
                          HapticFeedback.selectionClick();
                        },
                        child: const Text("Satın Alımları Geri Yükle", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.3)),
                      )
                    ],
                  ),
                ),

                // ── MERKEZİ İÇERİK (Sığarsa kaymaz, taşarsa kayar) ──
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(), // Ekran sığıyorsa sekmeyi engeller, lüks hissi korur.
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        child: Column(
                          children: [
                            // ── ICON & BAŞLIK ──
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFFFD700).withOpacity(0.15),
                                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3), width: 1),
                              ),
                              child: const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFD700), size: 36),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Crack Wish Elite",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Kozmik farkındalığa giden kapıyı aç.\nSınırları tamamen kaldır.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // ── ODAKLI MİNİMAL ÖZELLİK LİSTESİ ──
                            _buildCompactFeature(Icons.diamond_rounded, const Color(0xFF4EE6C5), "Günde 5 Taze Ruh Taşı"),
                            _buildCompactFeature(Icons.psychology_alt_rounded, const Color(0xFFC084FC), "Master Analiz Modu"),
                            _buildCompactFeature(Icons.auto_awesome, const Color(0xFFFFD700), "x3 Hızlı Aura Kazanımı"),
                            _buildCompactFeature(Icons.auto_stories_rounded, const Color(0xFF94A3B8), "Sonsuz Klinik Arşiv"),
                            _buildCompactFeature(Icons.block_rounded, const Color(0xFFF87171), "Reklamsız Kesintisiz Deneyim"),
                            
                            const SizedBox(height: 20),

                            // ── CAM TASARIMLI 3'LÜ PAKET DİZİLİMİ ──
                            _buildGlassPackageRow(0, "Haftalık Uyanış", "₺49.99", "/ hafta"),
                            _buildGlassPackageRow(1, "Aylık Sezgi", "₺129.99", "/ ay", subText: "%35 Tasarruf Edin"),
                            _buildGlassPackageRow(2, "Yıllık Aydınlanma", "₺699.99", "/ yıl", badge: "Popüler", subText: "Aylık Sadece ₺58.33 (%70 Kazanç)"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── ALT BUTON VE YASAL METİN (SABİT) ──
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.heavyImpact();
                            // Satın Alma Tetikleyici
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(color: Colors.white.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8)),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              "Elite Sınırlarını Aç",
                              style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Abonelik iptal edilmediği sürece yenilenir. 24 saat önceden iptal edilebilir.\nGizlilik Sözleşmesi ve Kullanım Şartları",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 9, height: 1.3),
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

  Widget _buildCompactFeature(IconData icon, Color color, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 14),
          Text(title, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildGlassPackageRow(int index, String title, String price, String duration, {String? badge, String? subText}) {
    final bool isSelected = _selectedPackageIndex == index;
    final Color highlightColor = const Color(0xFFFFD700);

    return GestureDetector(
      onTap: () => _selectPackage(index),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? highlightColor.withOpacity(0.12) : Colors.white.withOpacity(0.06), // Buzlu cam şeffaflığı
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? highlightColor.withOpacity(0.6) : Colors.white.withOpacity(0.12),
                  width: isSelected ? 1.5 : 0.5,
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
                        color: isSelected ? highlightColor : Colors.white.withOpacity(0.3),
                        width: 1.5,
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
                            if (badge != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: highlightColor, borderRadius: BorderRadius.circular(6)),
                                child: Text(badge.toUpperCase(), style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900)),
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
                      Text(price, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(duration, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
