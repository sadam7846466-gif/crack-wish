import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../models/fortune.dart';

class ShareModal extends StatefulWidget {
  final Fortune fortune;
  final String cookieEmoji;
  final String lang;
  final String cookieName;
  final String? imagePath;

  const ShareModal({
    super.key,
    required this.fortune,
    required this.cookieEmoji,
    required this.lang,
    required this.cookieName,
    this.imagePath,
  });

  @override
  State<ShareModal> createState() => _ShareModalState();
}

class _ShareModalState extends State<ShareModal> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isExporting = false;

  void _shareContent(String actionType) async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    
    // Add small delay to let UI show circular progress before thread blocking image generation
    await Future.delayed(const Duration(milliseconds: 100));
    
    try {
      final image = await _screenshotController.captureFromWidget(
        _buildExportCard(),
        context: context,
        pixelRatio: 1.0,
        delay: const Duration(milliseconds: 50),
      );
      final directory = await getTemporaryDirectory();
      final file = await File('${directory.path}/crack_wish_share.png').create();
      await file.writeAsBytes(image);

      final renderBox = context.findRenderObject() as RenderBox?;
      final rect = renderBox != null ? renderBox.localToGlobal(Offset.zero) & renderBox.size : Rect.zero;

      if (actionType == 'story') {
        await Share.shareXFiles([XFile(file.path)], text: '#CrackWish', sharePositionOrigin: rect);
      } else {
        await Share.shareXFiles([XFile(file.path)], text: "Günün kurabiyesinden bana bu çıktı! 🥠✨\nSen de kendi kaderini keşfetmek istersen #CrackWish'i indir!", sharePositionOrigin: rect);
      }
    } catch(e) { 
      debugPrint("Share error: $e");
    } finally {
      if(mounted) setState(() => _isExporting = false);
    }
  }

  Color _mapFortuneColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('yeşil')) return const Color(0xFF00FF88);
    if (lower.contains('turkuaz') || lower.contains('mavi')) return const Color(0xFF00EAFF);
    if (lower.contains('kırmızı') || lower.contains('yakut')) return const Color(0xFFFF3366);
    if (lower.contains('mor') || lower.contains('eflatun')) return const Color(0xFFD400FF);
    if (lower.contains('pembe')) return const Color(0xFFFF66CC);
    if (lower.contains('beyaz') || lower.contains('gümüş') || lower.contains('kristal')) return const Color(0xFFE2F1FF);
    if (lower.contains('siyah') || lower.contains('obsidyen')) return const Color(0xFF6B4CC9);
    return const Color(0xFFFFD700); // Default gold/sarı
  }

  Widget _buildGoldFoilText(String text, double fontSize, {FontWeight weight = FontWeight.bold, String? fontFamily}) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFF7D6), Color(0xFFD4AF37), Color(0xFFAA771C), Color(0xFFF9E596)],
        stops: [0.0, 0.4, 0.7, 1.0],
      ).createShader(bounds),
      child: Text(
        text, 
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize, 
          color: Colors.white, 
          fontWeight: weight, 
          fontFamily: fontFamily,
          height: 1.4,
          decoration: TextDecoration.none,
          letterSpacing: 2,
        ),
      ),
    );
  }

  // Şans rengine göre muazzam 3 farklı minimal temadan birini sunar:
  ({Color bgStart, Color bgEnd, Color aura, Color mainText, Color quoteText, Color statsText, Color separator, Color brandText, bool isDark}) _getTheme(String colorName) {
    final lower = colorName.toLowerCase();
    
    // BEYAZ TEMA (Saf, Aydınlık, Zarif)
    if (lower.contains('beyaz') || lower.contains('gümüş') || lower.contains('kristal') || lower.contains('inci')) {
      return (
        bgStart: const Color(0xFFFCFBF8), bgEnd: const Color(0xFFEBE6DF),
        aura: const Color(0xFFDACBA3), mainText: const Color(0xFF6B2A2A), // Koyu zarif kiremit / Bordo
        quoteText: const Color(0xFFBD955A), statsText: const Color(0xFF755B5B),
        separator: const Color(0xFFD4C7A3), brandText: const Color(0xFF8B7355), isDark: false,
      );
    }
    
    // MOR TEMA (Gece, Mistik, Derin)
    if (lower.contains('mor') || lower.contains('mavi') || lower.contains('pembe') || lower.contains('turkuaz') || lower.contains('eflatun')) {
      return (
        bgStart: const Color(0xFF2B184F), bgEnd: const Color(0xFF0F071D),
        aura: const Color(0xFF9845FF), mainText: const Color(0xFFE8E1F5),
        quoteText: const Color(0xFFC792FF), statsText: const Color(0xFFB4A1D9),
        separator: const Color(0xFF533A82), brandText: const Color(0xFF785B9E), isDark: true,
      );
    }
    
    // ALTIN / SİYAH TEMA (Efsanevi, Lüks) - Varsayılan
    return (
      bgStart: const Color(0xFF1C1A17), bgEnd: const Color(0xFF080706),
      aura: const Color(0xFFFFB300), mainText: const Color(0xFFE8DAC3),
      quoteText: const Color(0xFFC49A50), statsText: const Color(0xFFB5A795),
      separator: const Color(0xFF4A4132), brandText: const Color(0xFF8F7B59), isDark: true,
    );
  }

  // Yüksek çözünürlüklü 1080x1920 dışa aktarma (Instagram Story boyutu - Minimalist Premium)
  Widget _buildExportCard() {
    final theme = _getTheme(widget.fortune.luckyColor);
    final auraBase = _mapFortuneColor(widget.fortune.luckyColor); 
    // Aydınlık temada auraBase patlamasın diye temanın soft aurası kullanılır. Koyu temada neon renk kullanılır.
    final actualAura = theme.isDark ? auraBase : theme.aura; 

    return Container(
      width: 1080,
      height: 1920,
      decoration: BoxDecoration(
        color: theme.bgEnd,
        gradient: RadialGradient(
          center: const Alignment(0, -0.4),
          radius: 1.5,
          colors: [theme.bgStart, theme.bgEnd],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Yıldız Tozları (Background Stars)
          if (theme.isDark)
            ...List.generate(10, (i) => Positioned(
              left: [150.0, 850.0, 250.0, 750.0, 400.0, 600.0, 100.0, 900.0, 300.0, 800.0][i],
              top: [300.0, 450.0, 1100.0, 1400.0, 200.0, 1600.0, 800.0, 900.0, 1300.0, 1500.0][i],
              child: Icon(Icons.star, color: actualAura.withOpacity(0.15), size: [12.0, 8.0, 15.0, 10.0, 6.0, 9.0, 14.0, 7.0, 11.0, 9.0][i]),
            )),

          // --- İÇERİK KATMANLARI --- //

          // 1. En Üst Kısım: Kurabiye Katmanı (Kesin Olarak Top: 240)
          Positioned(
            top: 240, left: 0, right: 0,
            child: Center(
              child: SizedBox(
                width: 400, height: 260,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Arkasındaki Işık Hüzmesi
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [actualAura.withOpacity(0.45), actualAura.withOpacity(0.0)],
                            stops: const [0.0, 0.6],
                          ),
                        ),
                      ),
                    ),
                    // Kurabiye
                    if (widget.imagePath != null)
                      Image.asset(widget.imagePath!, width: 160, height: 160, fit: BoxFit.contain)
                    else 
                      Text(widget.cookieEmoji, style: const TextStyle(fontSize: 120, fontFamilyFallback: ['Apple Color Emoji'], decoration: TextDecoration.none)),
                    
                    // Mistik Yıldız
                    Positioned(
                      top: 25, right: 110,
                      child: Icon(Icons.auto_awesome, color: actualAura.withOpacity(0.9), size: 36),
                    )
                  ],
                ),
              ),
            ),
          ),

          // 2. Tam Ekranın Matematiksel Merkezi: Şans Mesajı Katmanı (Top/Bottom Yok)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Alıntı Başlangıcı (Tırnak)
                Text(
                  '"', 
                  style: GoogleFonts.ebGaramond(
                    color: theme.quoteText, 
                    fontSize: 100, 
                    fontWeight: FontWeight.w600, 
                    height: 0.4, 
                    decoration: TextDecoration.none
                  )
                ),
                
                const SizedBox(height: 60),
                
                // Fortune Mesajı
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 110.0), // Yazı büyüdüğü için kenar boşluğu biraz daraltıldı
                  child: Text(
                    widget.fortune.meaning,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ebGaramond(
                      color: theme.mainText,
                      fontSize: 66, 
                      fontWeight: FontWeight.w500, 
                      fontStyle: FontStyle.italic, // Görseldeki o klasik, ince, zarif şiirsel eğim
                      height: 1.35, 
                      decoration: TextDecoration.none,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Alt Katman: İstatistikler (Kesin Olarak Bottom: 280)
          Positioned(
            bottom: 280, left: 0, right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Üst Çizgi
                Container(width: 650, height: 1.5, color: theme.separator),
                const SizedBox(height: 45),
                
                // İstatistik Satırı
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${widget.fortune.luckyNumber}', style: GoogleFonts.ebGaramond(color: theme.statsText, fontSize: 44, fontWeight: FontWeight.w500, decoration: TextDecoration.none)),
                    const SizedBox(width: 40),
                    Icon(Icons.flare, color: theme.separator, size: 22),
                    const SizedBox(width: 40),
                    Text(widget.fortune.luckyColor, style: GoogleFonts.ebGaramond(color: theme.statsText, fontSize: 44, fontWeight: FontWeight.w500, letterSpacing: 2.0, decoration: TextDecoration.none)),
                    const SizedBox(width: 40),
                    Icon(Icons.flare, color: theme.separator, size: 22),
                    const SizedBox(width: 40),
                    Text('%${widget.fortune.luckPercent}', style: GoogleFonts.ebGaramond(color: theme.statsText, fontSize: 44, fontWeight: FontWeight.w500, decoration: TextDecoration.none)),
                  ],
                ),
                
                const SizedBox(height: 45),
                // Alt Çizgi
                Container(width: 650, height: 1.5, color: theme.separator),
              ],
            ),
          ),

          // 4. En Alt Katman: İmza Logosu (Kesin Olarak Bottom: 120)
          Positioned(
            bottom: 120, left: 0, right: 0,
            child: Center(
              child: Text(
                'CRACK & WISH', 
                style: GoogleFonts.ebGaramond(
                  color: theme.brandText, 
                  fontSize: 34, 
                  fontWeight: FontWeight.w500, // Alt metin de resimdeki gibi tırnaklı serif logoya sahip
                  letterSpacing: 20.0, 
                  decoration: TextDecoration.none
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 9:16 KART ALANI (Tıkladığında kapanabilmesi için eklendi)
                Flexible(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(), // Butonlar hariç karta tıklanınca kapanır
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.56), // Çok daha kompakt ve orantılı
                      child: AspectRatio(
                        aspectRatio: 1080 / 1920,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 40, spreadRadius: 10)],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: FittedBox(
                              fit: BoxFit.contain, // İçerideki dev 1080p resmi sığdırır
                              child: _buildExportCard(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // PREMIUM BUTON GRUBU
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSoftButton(
                      label: 'İndir', 
                      icon: Icons.download_rounded, 
                      onTap: () => _shareContent('download'),
                    ),
                    const SizedBox(width: 10),
                    _buildSoftButton(
                      label: 'Story', 
                      icon: Icons.camera_alt_rounded, 
                      onTap: () => _shareContent('story'),
                    ),
                    const SizedBox(width: 10),
                    _buildSoftButton(
                      label: 'Paylaş', 
                      icon: Icons.ios_share_rounded, 
                      onTap: () => _shareContent('share'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoftButton({required String label, required IconData icon, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: _isExporting ? null : onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18), // Daha aydınlık beyaz
                border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.2), // Şık bir cam sınır
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: _isExporting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.5, decoration: TextDecoration.none)),
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
