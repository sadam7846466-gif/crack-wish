import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

class TarotShareModal extends StatefulWidget {
  final String closingMessage;
  final List<String> promises; // yalnızlık, sezgi, bağımlılık gibi
  final List<String> cardNames; // Seçilen kart isimleri
  final List<String> cardAssets; // Kart görselleri
  final bool isMajorArcana;
  final String lang;

  const TarotShareModal({
    super.key,
    required this.closingMessage,
    required this.promises,
    required this.cardNames,
    required this.cardAssets,
    required this.isMajorArcana,
    required this.lang,
  });

  @override
  State<TarotShareModal> createState() => _TarotShareModalState();
}

class _TarotShareModalState extends State<TarotShareModal> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isExporting = false;

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
        name: 'crack_wish_tarot_${DateTime.now().millisecondsSinceEpoch}',
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

  void _shareContent() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    await Future.delayed(const Duration(milliseconds: 100));
    
    try {
      final image = await _generateImage();
      if (image == null) return;

      final directory = await getTemporaryDirectory();
      final file = await File('${directory.path}/crack_wish_tarot_share.png').create();
      await file.writeAsBytes(image);

      final renderBox = context.findRenderObject() as RenderBox?;
      final rect = renderBox != null ? renderBox.localToGlobal(Offset.zero) & renderBox.size : Rect.zero;

      await Share.shareXFiles(
        [XFile(file.path)], 
        text: "Kartlar bana böyle konuştu! 🔮✨\n#CrackWish #Tarot", 
        sharePositionOrigin: rect,
      );
    } catch(e) { 
      debugPrint('Share error: $e');
    } finally {
      if(mounted) setState(() => _isExporting = false);
    }
  }

  // 1080x1920 Export Kartı
  Widget _buildExportCard() {
    return Container(
      width: 1080,
      height: 1920,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0710), // Daha koyu, daha lüks bir zemin
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF160E24), // Çok koyu mistik mor
            Color(0xFF0A0710), // Hemen hemen siyah
            Color(0xFF100A1C), // Çok koyu lacivert/mor
          ],
        ),
      ),
      child: Stack(
        children: [
          // Çok hafif, zarif arka plan ışıkları
          Positioned(
            top: -200,
            left: -200,
            child: Container(
              width: 800,
              height: 800,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [const Color(0xFF6C3FA0).withOpacity(0.12), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -200,
            child: Container(
              width: 900,
              height: 900,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [const Color(0xFFE7D6A5).withOpacity(0.06), Colors.transparent],
                ),
              ),
            ),
          ),
          
          // Noise texture efekti (opsiyonel lüks hissiyatı)
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: Image.asset('assets/images/noise.png', fit: BoxFit.cover, errorBuilder: (_,__,___) => const SizedBox()),
            ),
          ),

          // İçerik
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 110),
            child: Column(
              children: [
                const SizedBox(height: 70),
                
                // Tepedeki zarif etiket (Kutu yerine sadece metin)
                Text(
                  widget.isMajorArcana ? '✦  M A J O R   A R C A N A  ✦' : '✦  F U L L   A R C A N A  ✦',
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFFE7D6A5).withOpacity(0.7),
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 6.0,
                    decoration: TextDecoration.none,
                  ),
                ),
                
                const SizedBox(height: 110),

                // Kart görselleri (Daha zarif etkileşim ve altın kenarlık)
                SizedBox(
                  height: 440,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.cardAssets.length.clamp(0, 3),
                      (i) {
                        final isCenter = i == 1;
                        final angle = i == 0 ? -0.06 : (i == 2 ? 0.06 : 0.0);
                        final offsetY = isCenter ? -20.0 : 10.0;
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Transform.translate(
                            offset: Offset(0, offsetY),
                            child: Transform.rotate(
                              angle: angle,
                              child: Container(
                                width: 250,
                                height: 420,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0D0A1A),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFE7D6A5).withOpacity(0.35),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFE7D6A5).withOpacity(0.12),
                                      blurRadius: 35,
                                      spreadRadius: -5,
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.6),
                                      blurRadius: 25,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  clipBehavior: Clip.hardEdge,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      // Kart görseli
                                      Transform.scale(
                                        scale: 1.12,
                                        child: Image.asset(
                                          widget.cardAssets[i],
                                          width: 250,
                                          height: 420,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            color: const Color(0xFF160E24),
                                            child: Center(
                                              child: Icon(Icons.auto_awesome, color: const Color(0xFFE7D6A5).withOpacity(0.5), size: 40),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Alt kısma karanlık degrade (yazının okunması için)
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        height: 90,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                const Color(0xFF0D0A1A).withOpacity(0.7),
                                                const Color(0xFF0D0A1A).withOpacity(0.95),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Kart İsmi
                                      Positioned(
                                        bottom: 20,
                                        left: 0,
                                        right: 0,
                                        child: Text(
                                          widget.cardNames.length > i ? widget.cardNames[i] : '',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.cinzel(
                                            color: const Color(0xFFE7D6A5),
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 2.5,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 70),
                
                // İnce minimalist ayırıcı
                Container(
                  width: 140,
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        const Color(0xFFE7D6A5).withOpacity(0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 60),

                // Ana mesaj (Büyük tırnaklar yerine zarif typography)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        widget.closingMessage,
                        textAlign: TextAlign.justify,
                        maxLines: 12,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cormorantGaramond(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 34,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          height: 1.35,
                          letterSpacing: 0.3,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ),

                // Keywords (Neon renkler iptal → şampanya altını ve minimalist)
                if (widget.promises.isNotEmpty) ...[
                  const SizedBox(height: 30),
                  Text(
                    widget.promises.take(3).map((p) => p.toUpperCase()).join('   ✦   '),
                    style: GoogleFonts.cinzel(
                      color: const Color(0xFFE7D6A5).withOpacity(0.6),
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 4.0,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],

                const SizedBox(height: 90),

                // Branding
                Text(
                  'CRACK & WISH',
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFFE7D6A5).withOpacity(0.25),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 18.0,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Material(
        color: Colors.transparent,
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
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 9:16 Kart Önizleme
                    Flexible(
                      child: GestureDetector(
                        onTap: () {}, // Karta tıklanınca kapanmasın
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.56),
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
                                  fit: BoxFit.contain,
                                  child: _buildExportCard(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Butonlar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _TarotTapButton(
                          onTap: _isExporting ? null : _saveToGallery,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: const Color(0xFFE7D6A5).withOpacity(0.4), width: 1.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.download_rounded, color: const Color(0xFFE7D6A5).withOpacity(0.7), size: 14),
                                const SizedBox(width: 6),
                                Text('İndir', style: TextStyle(color: const Color(0xFFE7D6A5).withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.3, decoration: TextDecoration.none)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _TarotTapButton(
                          onTap: _isExporting ? null : _shareContent,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A1F4A),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.ios_share_rounded, color: Colors.white.withOpacity(0.85), size: 14),
                                const SizedBox(width: 6),
                                Text('Paylaş', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.3, decoration: TextDecoration.none)),
                              ],
                            ),
                          ),
                        ),
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
}

// Basma efekti
class _TarotTapButton extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget child;
  const _TarotTapButton({required this.onTap, required this.child});

  @override
  State<_TarotTapButton> createState() => _TarotTapButtonState();
}

class _TarotTapButtonState extends State<_TarotTapButton> {
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
