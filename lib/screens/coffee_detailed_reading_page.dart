import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CoffeeDetailedReadingPage extends StatelessWidget {
  const CoffeeDetailedReadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0A09),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 18),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'DETAYLI YORUM',
          style: GoogleFonts.inter(
            color: const Color(0xFFE8D5C4),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 3.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // Title Section
            Text(
              'Falının Derin Mesajı',
              style: GoogleFonts.outfit(
                color: const Color(0xFFE8D5C4),
                fontSize: 32,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Telvelerde saklı işaretler tek tek yorumlandı.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Genel Yorum
            _buildGlassCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIconCircle(Icons.local_cafe_rounded),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Genel Yorum',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFE8D5C4),
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Falında bekleyişten çıkış enerjisi görünüyor.\nYakın zamanda netleşecek bir haber, içini rahatlatacak.\nÖnünde açılan yeni bir yol ve küçük bir kısmet var.\nKararsız kaldığın konu yavaş yavaş açıklığa kavuşuyor.',
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2x2 Grid for 4 zones
            Row(
              children: [
                Expanded(
                  child: _buildZoneCard(
                    Icons.coffee_rounded,
                    'Fincan İçi',
                    'İç dünyanda yoğun\ndüşünceler var. Bir konuya\nfazla takılmış olabilirsin.',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildZoneCard(
                    Icons.gesture_rounded, // or Icons.gesture
                    'Kenar',
                    'Yakın çevrenden haber\nve görüşme enerjisi\ngeliyor.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildZoneCard(
                    Icons.adjust_rounded, // Dip icon
                    'Dip',
                    'Geçmişten kalan bir\nmesele kapanışa\nyaklaşıyor.',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildZoneCard(
                    Icons.panorama_fish_eye_rounded, // Tabak icon
                    'Tabak',
                    'Dilek enerjin açık.\nKüçük ama sevindirici\nbir sonuç var.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Öne Çıkan Semboller
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.flare_rounded, color: Color(0xFFD4A373), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Öne Çıkan Semboller',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFE8D5C4),
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSymbolChip(Icons.edit_road_rounded, 'Yol'),
                      _buildSymbolChip(Icons.flutter_dash_rounded, 'Kuş'),
                      _buildSymbolChip(Icons.vpn_key_rounded, 'Anahtar'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Yakın Gelecek Timeline
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, color: Color(0xFFD4A373), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Yakın Gelecek',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFE8D5C4),
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildTimelineItem('1-3 Gün', 'Beklediğin bir haber geliyor.\nİçini rahatlatacak bir gelişme var.', isFirst: true),
                  _buildTimelineItem('1 Hafta', 'Yeni bir görüşme veya buluşma görünüyor.\nİletişim güçleniyor.'),
                  _buildTimelineItem('2-3 Hafta', 'Kısmetli bir başlangıç kapıda.\nKüçük bir fırsat büyüyebilir.', isLast: true),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Dilek Mesajı
            _buildGlassCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIconCircle(Icons.auto_awesome_rounded),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dilek Mesajı',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFE8D5C4),
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Dileğin oluyor; fakat sabırla ilerliyor.\nÖnce küçük bir işaret, sonra net bir gelişme görünüyor.',
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Falımı Paylaş Button
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A373),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.ios_share_rounded, color: Color(0xFF161311), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Falımı Paylaş',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF161311),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Yeni Fal Bak Button
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.refresh_rounded, color: Color(0xFFD4A373), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Yeni Fal Bak',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFD4A373),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4A373).withOpacity(0.3)),
      ),
      child: child,
    );
  }

  Widget _buildIconCircle(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD4A373).withOpacity(0.5)),
        gradient: RadialGradient(
          colors: [
            const Color(0xFFD4A373).withOpacity(0.15),
            Colors.transparent,
          ],
        ),
      ),
      child: Icon(icon, color: const Color(0xFFD4A373), size: 20),
    );
  }

  Widget _buildZoneCard(IconData icon, String title, String content) {
    return _buildGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildIconCircle(icon),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFE8D5C4),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymbolChip(IconData icon, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFD4A373), size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                color: const Color(0xFFE8D5C4),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String time, String desc, {bool isFirst = false, bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline line and dot
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Container(
                  width: 1,
                  height: 8,
                  color: isFirst ? Colors.transparent : const Color(0xFFD4A373).withOpacity(0.3),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4A373),
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 1,
                    color: isLast ? Colors.transparent : const Color(0xFFD4A373).withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Time label
          SizedBox(
            width: 80,
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                time,
                style: GoogleFonts.inter(
                  color: const Color(0xFFE8D5C4),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Description
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0, top: 2.0),
              child: Text(
                desc,
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
