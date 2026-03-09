import 'package:flutter/material.dart';
import 'dart:ui';
import '../widgets/glass_back_button.dart';
import '../constants/colors.dart';

class ZodiacPage extends StatefulWidget {
  const ZodiacPage({super.key});

  @override
  State<ZodiacPage> createState() => _ZodiacPageState();
}

class _ZodiacPageState extends State<ZodiacPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  final Color _goldAccent = const Color(0xFFFFD060);
  final Color _goldDark = const Color(0xFFB07020);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    _opacityAnimation = Tween<double>(begin: 0.35, end: 0.55).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0F1513), // Koyu arka plan
      body: Stack(
        children: [
          // Arka plan gradient
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.6),
                radius: 1.2,
                colors: [
                  _goldDark.withOpacity(0.35),
                  const Color(0xFF0F1513),
                  const Color(0xFF0A0F0D),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),

          // Arka planda devasa, flulaştırılmış, özel tasarlanmış Aslan burcu resmi
          Positioned(
            top: -20,
            right: -60,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Transform.rotate(
                  angle: -0.05, // Hafif bir eğim
                  child: Image.asset(
                    'assets/images/zodiac_signs/leo.png',
                    width: 440,
                    height: 440,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          // Alt kısımdan yukarı doğru hafif altın/siyah soft geçiş (scroll kolaylaşsın diye)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF0A0F0D).withOpacity(0.5),
                    const Color(0xFF0A0F0D),
                  ],
                  stops: const [0.5, 0.8, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Geri butonu
                        Row(
                          children: [
                            const GlassBackButton(),
                            const Spacer(),
                            // Kendi burcunu gösteren ufak badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _goldAccent.withOpacity(0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '♌', // Aslan burcu sembolü
                                    style: TextStyle(
                                      color: _goldAccent,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Aslan',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 35),

                        // Kullanıcıya özel selamlama
                        FadeInAnimation(
                          delay: const Duration(milliseconds: 100),
                          child: Text(
                            "Kozmik Yolcu,",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 18,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        FadeInAnimation(
                          delay: const Duration(milliseconds: 200),
                          child: ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [_goldAccent, const Color(0xFFFFE8A1)],
                            ).createShader(bounds),
                            child: const Text(
                              "Sen bir Aslan'sın",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 44,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.8,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),
                        FadeInAnimation(
                          delay: const Duration(milliseconds: 300),
                          child: Text(
                            "23 Temmuz - 22 Ağustos",
                            style: TextStyle(
                              color: _goldAccent.withOpacity(0.8),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Element, Gezegen & Nitelik kartları
                        FadeInAnimation(
                          delay: const Duration(milliseconds: 400),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildInfoBadge("Element", "Ateş", "🔥"),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInfoBadge(
                                  "Gezegen",
                                  "Güneş",
                                  "☀️",
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInfoBadge("Nitelik", "Sabit", "⚓"),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Günlük Yorum Kartı
                        FadeInAnimation(
                          delay: const Duration(milliseconds: 500),
                          child: _buildDailyHoroscopeCard(),
                        ),

                        const SizedBox(height: 40),

                        // Anahtar Kelimeler / Özellikler
                        FadeInAnimation(
                          delay: const Duration(milliseconds: 600),
                          child: const Text(
                            "Öne Çıkan Özelliklerin",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeInAnimation(
                          delay: const Duration(milliseconds: 700),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _buildTraitChip("Özgüvenli"),
                              _buildTraitChip("Lider Ruhlu"),
                              _buildTraitChip("Cömert"),
                              _buildTraitChip("Yaratıcı"),
                              _buildTraitChip("Tutkulu"),
                              _buildTraitChip("Sadık"),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 120,
                        ), // alt boşluk, scroll kolaylaşsın diye
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

  Widget _buildInfoBadge(String label, String value, String icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: _goldAccent,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTraitChip(String trait) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: _goldDark.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _goldAccent.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: _goldAccent.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        trait,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildDailyHoroscopeCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _goldAccent.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      color: _goldAccent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Günlük Yıldız Falın",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Bugün",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "Bugün yaratıcılığının zirvesinde olacaksın. İçindeki ateşi hisset ve projelerinde liderliği ele almaktan çekinme. Etrafındakiler senin enerjinden ilham alıyor. Güneş her zamanki gibi senin için parlıyor! Yeni adımlar için mükemmel bir zaman.",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 16,
                  height: 1.6,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              // Şanslı Sayı ve Renk
              Row(
                children: [
                  _buildLuckyItem("Şanslı Sayı", "7"),
                  const SizedBox(width: 24),
                  _buildLuckyItem("Şanslı Renk", "Altın Sarısı"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLuckyItem(String label, String value) {
    return Row(
      children: [
        Text(
          "$label:",
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            color: _goldAccent,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// Basit bir giriş animasyonu (Fade & Yukardan kayma)
class FadeInAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const FadeInAnimation({super.key, required this.child, required this.delay});

  @override
  State<FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}
