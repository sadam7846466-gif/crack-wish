import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
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

  // Görseli oluştur (ortak method)
  Future<Uint8List?> _generateImage() async {
    try {
      return await _screenshotController.captureFromWidget(
        _buildExportCard(),
        context: context,
        pixelRatio: 1.0,
        delay: const Duration(milliseconds: 50),
      );
    } catch (e) {
      debugPrint('Image generation error: $e');
      return null;
    }
  }

  // KAYDET: Direkt galeriye kaydet
  void _saveToGallery() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    await Future.delayed(const Duration(milliseconds: 100));
    
    try {
      final image = await _generateImage();
      if (image == null) return;
      
      final result = await ImageGallerySaverPlus.saveImage(
        image,
        quality: 100,
        name: 'crack_wish_${DateTime.now().millisecondsSinceEpoch}',
      );
      
      if (mounted) {
        final success = result != null && (result['isSuccess'] == true || result['isSuccess'] == 1);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(success ? Icons.check_circle : Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(success ? 'Galeriye kaydedildi! ✨' : 'Kaydetme başarısız'),
              ],
            ),
            backgroundColor: success ? const Color(0xFF2D7A50) : Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch(e) { 
      debugPrint('Save error: $e');
    } finally {
      if(mounted) setState(() => _isExporting = false);
    }
  }

  // PAYLAŞ: Yerel paylaşım menüsü (Instagram, WhatsApp, TikTok, X - hepsi burada)
  void _shareContent() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    await Future.delayed(const Duration(milliseconds: 100));
    
    try {
      final image = await _generateImage();
      if (image == null) return;

      final directory = await getTemporaryDirectory();
      final file = await File('${directory.path}/crack_wish_share.png').create();
      await file.writeAsBytes(image);

      final renderBox = context.findRenderObject() as RenderBox?;
      final rect = renderBox != null ? renderBox.localToGlobal(Offset.zero) & renderBox.size : Rect.zero;

      await Share.shareXFiles(
        [XFile(file.path)], 
        text: "Günün kurabiyesinden bana bu çıktı! 🥠✨\n#CrackWish", 
        sharePositionOrigin: rect,
      );
    } catch(e) { 
      debugPrint('Share error: $e');
    } finally {
      if(mounted) setState(() => _isExporting = false);
    }
  }

  Color _mapFortuneColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('yeşil')) return const Color(0xFF00FF88);
    if (lower.contains('turkuaz') || lower.contains('mavi')) return const Color(0xFF00EAFF);
    if (lower.contains('lacivert')) return const Color(0xFF4466CC);
    if (lower.contains('kırmızı') || lower.contains('yakut')) return const Color(0xFFFF3366);
    if (lower.contains('mor') || lower.contains('eflatun')) return const Color(0xFFD400FF);
    if (lower.contains('pembe')) return const Color(0xFFFF66CC);
    if (lower.contains('turuncu')) return const Color(0xFFFF8C00);
    if (lower.contains('kahverengi') || lower.contains('kahve')) return const Color(0xFFA0724A);
    if (lower.contains('beyaz') || lower.contains('gümüş') || lower.contains('kristal')) return const Color(0xFFE2F1FF);
    if (lower.contains('siyah') || lower.contains('obsidyen')) return const Color(0xFFFFC000);
    return const Color(0xFFFFD700); // Default gold/sarı/altın
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

  // Şans rengine göre muazzam özel minimal temalardan birini sunar:
  ({Color bgStart, Color bgEnd, Color aura, Color mainText, Color quoteText, Color statsText, Color separator, Color brandText, bool isDark}) _getTheme(String colorName) {
    final lower = colorName.toLowerCase();
    
    // PEMBE TEMA (Gül bahçesi)
    if (lower.contains('pembe')) {
      return (
        bgStart: const Color(0xFFDC8AAF), bgEnd: const Color(0xFFA45678), // Zengin gül pembesi
        aura: const Color(0xFFFFB8D4), 
        mainText: const Color(0xFFFFFFFF), 
        quoteText: const Color(0xFFFFE4EF), 
        statsText: const Color(0xFFFFFFFF),
        separator: const Color(0xFFBB7090), 
        brandText: const Color(0xFFFFD6E8), 
        isDark: true,
      );
    }

    // TURUNCU TEMA (Gün batımı)
    if (lower.contains('turuncu') || lower.contains('orange')) {
      return (
        bgStart: const Color(0xFFCC7A35), bgEnd: const Color(0xFF8B4A18), // Zengin amber/turuncu
        aura: const Color(0xFFFFAA55), 
        mainText: const Color(0xFFFFFFFF), 
        quoteText: const Color(0xFFFFE0C0), 
        statsText: const Color(0xFFFFFFFF),
        separator: const Color(0xFFB07040), 
        brandText: const Color(0xFFFFD4AA), 
        isDark: true,
      );
    }

    // KIRMIZI TEMA (Kadife kırmızı)
    if (lower.contains('kırmızı') || lower.contains('yakut') || lower.contains('nar')) {
      return (
        bgStart: const Color(0xFFAA2525), bgEnd: const Color(0xFF6B1010), // Zengin kadife kırmızı
        aura: const Color(0xFFFF6666), 
        mainText: const Color(0xFFFFFFFF), 
        quoteText: const Color(0xFFFFD4D4), 
        statsText: const Color(0xFFFFFFFF),
        separator: const Color(0xFF993333), 
        brandText: const Color(0xFFFFBBBB), 
        isDark: true,
      );
    }

    // YEŞİL TEMA (Zümrüt)
    if (lower.contains('yeşil') || lower.contains('zümrüt') || lower.contains('nane')) {
      return (
        bgStart: const Color(0xFF2D7A50), bgEnd: const Color(0xFF1A4A30), // Zengin zümrüt yeşili
        aura: const Color(0xFF66DDAA), 
        mainText: const Color(0xFFFFFFFF), 
        quoteText: const Color(0xFFD4F0E0), 
        statsText: const Color(0xFFFFFFFF),
        separator: const Color(0xFF408060), 
        brandText: const Color(0xFFBBE0CC), 
        isDark: true,
      );
    }

    // MAVİ TEMA (Okyanus mavisi)
    if (lower.contains('mavi') || lower.contains('turkuaz')) {
      return (
        bgStart: const Color(0xFF2266AA), bgEnd: const Color(0xFF0F3D6B), // Zengin kraliyet mavisi
        aura: const Color(0xFF66AAEE), 
        mainText: const Color(0xFFFFFFFF), 
        quoteText: const Color(0xFFD4E8FF), 
        statsText: const Color(0xFFFFFFFF),
        separator: const Color(0xFF3377AA), 
        brandText: const Color(0xFFBBD8F0), 
        isDark: true,
      );
    }

    // ALTIN TEMA (Kraliyet altını)
    if (lower.contains('altın') || lower.contains('sarı') || lower.contains('gold')) {
      return (
        bgStart: const Color(0xFFB8942A), bgEnd: const Color(0xFF7A6218), // Zengin kraliyet altını
        aura: const Color(0xFFFFDD66), 
        mainText: const Color(0xFFFFFFFF), 
        quoteText: const Color(0xFFFFF4D4), 
        statsText: const Color(0xFFFFFFFF),
        separator: const Color(0xFFA08830), 
        brandText: const Color(0xFFFFEEBB), 
        isDark: true,
      );
    }

    // KAHVERENGİ TEMA (Espresso)
    if (lower.contains('kahverengi') || lower.contains('kahve') || lower.contains('brown')) {
      return (
        bgStart: const Color(0xFF7A5535), bgEnd: const Color(0xFF4A3020), // Zengin espresso
        aura: const Color(0xFFCCAA77), 
        mainText: const Color(0xFFFFFFFF), 
        quoteText: const Color(0xFFEED8C0), 
        statsText: const Color(0xFFFFFFFF),
        separator: const Color(0xFF8B6B45), 
        brandText: const Color(0xFFDDC4A0), 
        isDark: true,
      );
    }

    // LACİVERT TEMA (Gece gökyüzü)
    if (lower.contains('lacivert') || lower.contains('navy')) {
      return (
        bgStart: const Color(0xFF1A2D55), bgEnd: const Color(0xFF0D1A35), // Zengin lacivert
        aura: const Color(0xFF5588CC), 
        mainText: const Color(0xFFFFFFFF), 
        quoteText: const Color(0xFFD0DDF0), 
        statsText: const Color(0xFFFFFFFF),
        separator: const Color(0xFF3A5580), 
        brandText: const Color(0xFFB0C4DD), 
        isDark: true,
      );
    }
    
    // MOR TEMA (Ametist)
    if (lower.contains('mor') || lower.contains('eflatun') || lower.contains('lila')) {
      return (
        bgStart: const Color(0xFF6B35AA), bgEnd: const Color(0xFF3D1A6B), // Zengin ametist moru
        aura: const Color(0xFFAA77EE), 
        mainText: const Color(0xFFFFFFFF), 
        quoteText: const Color(0xFFE4D4F5), 
        statsText: const Color(0xFFFFFFFF),
        separator: const Color(0xFF7A50AA), 
        brandText: const Color(0xFFD0BBE8), 
        isDark: true,
      );
    }
    
    // SİYAH TEMA (Obsidyen & altın)
    if (lower.contains('siyah') || lower.contains('gece') || lower.contains('karanlık') || lower.contains('obsidyen') || lower.contains('black')) {
      return (
        bgStart: const Color(0xFF1A1A1A), bgEnd: const Color(0xFF0A0A0A), // Saf siyah
        aura: const Color(0xFFFFC000), 
        mainText: const Color(0xFFFFFFFF), 
        quoteText: const Color(0xFFD4B872), 
        statsText: const Color(0xFFFFFFFF), 
        separator: const Color(0xFF6E5F46), 
        brandText: const Color(0xFFA1937A), 
        isDark: true,
      );
    }

    // BEYAZ TEMA (Lüks davetiye) - VARSAYILAN
    return (
      bgStart: const Color(0xFFFCFBF8), bgEnd: const Color(0xFFEBE6DF),
      aura: const Color(0xFFDACBA3), 
      mainText: const Color(0xFF4A1515),
      quoteText: const Color(0xFF9E7538),
      statsText: const Color(0xFF4A1515),
      separator: const Color(0xFF9F8B60),
      brandText: const Color(0xFF422F2F),
      isDark: false,
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
          // 0. Vinyet ve Kağıt Efekti (Kenarlara Doğru Yumuşak Gölgeleme)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.25, 
                  colors: [
                    Colors.transparent, 
                    theme.isDark ? Colors.black.withOpacity(0.5) : const Color(0xFF2C1919).withOpacity(0.08)
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
          ),
          
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
                    // Arkasındaki Işık Hüzmesi (Sadece Koyu Temalarda Parıltı)
                    if (theme.isDark)
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
                      
                    // Zemin Gölgesi (Aydınlıkta fiziksel kahverengi gölge, Karanlıkta renkli ışık yansıması)
                    Positioned(
                      bottom: theme.isDark ? 40 : 35, // Aydınlık temada gölge biraz daha alta yayvanca iniyor
                      child: Container(
                        width: theme.isDark ? 80 : 130, // Aydınlıkta daha geniş temas alanı
                        height: theme.isDark ? 8 : 14,  // Aydınlıkta elips formu daha belirgin
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: theme.isDark
                              ? [actualAura.withOpacity(0.8), actualAura.withOpacity(0.0)]
                              : [const Color(0xFF3B2727).withOpacity(0.35), const Color(0xFF3B2727).withOpacity(0.0)], // Fisiksel masa üstü koyu kahve gölge
                            stops: const [0.1, 1.0],
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
                  style: GoogleFonts.lora( // Lora fontu ekranda en net okunan serif fontlardandır
                    color: theme.quoteText, 
                    fontSize: 100, 
                    fontWeight: FontWeight.w700, 
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
                    style: GoogleFonts.lora(
                      color: theme.mainText,
                      fontSize: 62, // Lora çok tok bir font olduğundan boyutu optimize ettik
                      fontWeight: FontWeight.w500, // Okunabilirliği arşa çıkaran kalınlık
                      fontStyle: FontStyle.italic, 
                      height: 1.45, // Daha ferah satır aralığı
                      decoration: TextDecoration.none,
                      letterSpacing: 0.5,
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
                    Text('${widget.fortune.luckyNumber}', style: GoogleFonts.montserrat(color: theme.statsText, fontSize: 44, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                    const SizedBox(width: 40),
                    Icon(Icons.flare, color: theme.separator, size: 24),
                    const SizedBox(width: 40),
                    Text(widget.fortune.luckyColor, style: GoogleFonts.montserrat(color: theme.statsText, fontSize: 44, fontWeight: FontWeight.w600, letterSpacing: 2.0, decoration: TextDecoration.none)),
                    const SizedBox(width: 40),
                    Icon(Icons.flare, color: theme.separator, size: 24),
                    const SizedBox(width: 40),
                    Text('%${widget.fortune.luckPercent}', style: GoogleFonts.montserrat(color: theme.statsText, fontSize: 44, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
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
                style: GoogleFonts.montserrat(
                  color: theme.brandText, 
                  fontSize: 34, 
                  fontWeight: FontWeight.w600, // Cılız değil, net ve kalın bir logo duruşu
                  letterSpacing: 22.0, 
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
      insetPadding: EdgeInsets.zero,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.4),
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
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
                
                // PREMIUM BUTON GRUBU (2 Buton: İndir + Paylaş)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // İNDİR - Açık çerçeveli krem buton
                    _buildStyledButton(
                      label: 'İndir', 
                      icon: Icons.download_rounded,
                      bgColor: Colors.transparent,
                      textColor: const Color(0xFFBBA090),
                      borderColor: const Color(0xFFBBA090).withOpacity(0.5),
                      onTap: _saveToGallery,
                    ),
                    const SizedBox(width: 12),
                    // PAYLAŞ - Koyu dolgulu buton
                    _buildStyledButton(
                      label: 'Paylaş', 
                      icon: Icons.ios_share_rounded,
                      bgColor: const Color(0xFF3A3530),
                      textColor: Colors.white.withOpacity(0.9),
                      borderColor: Colors.transparent,
                      onTap: _shareContent,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      ),
      ),
      ),
    );
  }

  Widget _buildStyledButton({
    required String label, 
    required IconData icon, 
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return _TapButton(
      onTap: _isExporting ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(100),
          border: borderColor != Colors.transparent 
            ? Border.all(color: borderColor, width: 1.0) 
            : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor, size: 14),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.3, decoration: TextDecoration.none)),
          ],
        ),
      ),
    );
  }
}

// Basma efekti veren minimal buton wrapper
class _TapButton extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget child;
  const _TapButton({required this.onTap, required this.child});

  @override
  State<_TapButton> createState() => _TapButtonState();
}

class _TapButtonState extends State<_TapButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedOpacity(
          opacity: _pressed ? 0.7 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: widget.child,
        ),
      ),
    );
  }
}
