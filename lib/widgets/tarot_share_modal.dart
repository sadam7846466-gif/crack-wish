import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import '../services/analytics_service.dart';

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

class _TarotShareModalState extends State<TarotShareModal> with TickerProviderStateMixin {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isExporting = false;
  bool _isStoryFormat = true;

  late final AnimationController _entranceCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  // Pre-cached images
  Uint8List? _cachedStoryImage;
  Uint8List? _cachedPostImage;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic),
    );
    _entranceCtrl.forward();
    _preCacheImages();
  }

  Future<void> _preCacheImages() async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;
    _cachedStoryImage = await _renderImage(true);
    if (!mounted) return;
    _cachedPostImage = await _renderImage(false);
  }

  Future<Uint8List?> _renderImage(bool story) async {
    try {
      final height = story ? 1920.0 : 1350.0;
      return await _screenshotController.captureFromWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.noScaling),
          child: story ? _buildExportCard() : _buildPostCard(),
        ),
        context: context,
        pixelRatio: 2.0,
        targetSize: Size(1080, height),
        delay: Duration.zero,
      );
    } catch (e) {
      debugPrint('Image render error: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  Future<void> _dismissModal() async {
    await _entranceCtrl.reverse();
    if (mounted) Navigator.of(context).pop();
  }

  Future<Uint8List?> _getImage() async {
    if (_isStoryFormat) {
      return _cachedStoryImage ??= await _renderImage(true);
    } else {
      return _cachedPostImage ??= await _renderImage(false);
    }
  }

  void _saveToGallery() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    
    try {
      final image = await _getImage();
      if (image == null) return;
      
      final result = await ImageGallerySaverPlus.saveImage(
        image,
        quality: 95,
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
                Text(success ? 'Galeriye kaydedildi!' : 'Kaydetme başarısız'),
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
    
    try {
      final image = await _getImage();
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
      AnalyticsService().logTarotShared();
    } catch(e) { 
      debugPrint('Share error: $e');
    } finally {
      if(mounted) setState(() => _isExporting = false);
    }
  }

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
                const SizedBox(height: 60),
                
                // Tepedeki zarif etiket (Kutu yerine sadece metin)
                Text(
                  widget.isMajorArcana ? '◆  M A J O R   A R C A N A  ◆' : '◆  F U L L   A R C A N A  ◆',
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFFE7D6A5).withOpacity(0.95),
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 6.0,
                    decoration: TextDecoration.none,
                  ),
                ),
                
                const SizedBox(height: 70),

                // Kart görselleri (Daha zarif etkileşim ve altın kenarlık)
                SizedBox(
                  height: 440,
                  child: Stack(
                    alignment: Alignment.center,
                    children: List.generate(
                      widget.cardAssets.length,
                      (i) {
                        final count = widget.cardAssets.length;
                        final isMany = count > 3;
                        double cWidth = 250.0;
                        double cHeight = 420.0;
                        double leftOffset = 0.0;
                        double offsetY = 0.0;
                        double angle = 0.0;

                        if (count == 7) {
                          cWidth = 175.0;
                          cHeight = 293.0;
                          final spacing = 225.0;
                          
                          if (i < 4) { // Arka sıra (4 kart)
                            final offsetFromCenter = i - 1.5;
                            leftOffset = offsetFromCenter * spacing;
                            offsetY = (offsetFromCenter * offsetFromCenter) * 10.0 - 85.0;
                            angle = offsetFromCenter * 0.05;
                          } else { // Ön sıra (3 kart)
                            final localIndex = i - 4;
                            final offsetFromCenter = localIndex - 1.0;
                            leftOffset = offsetFromCenter * spacing;
                            offsetY = (offsetFromCenter * offsetFromCenter) * 10.0 + 85.0;
                            angle = offsetFromCenter * 0.05;
                          }
                        } else {
                          final centerIndex = (count - 1) / 2.0;
                          final offsetFromCenter = i - centerIndex;
                          final spacing = isMany ? 115.0 : 270.0;
                          cWidth = isMany ? 180.0 : 250.0;
                          cHeight = isMany ? 302.0 : 420.0;
                          leftOffset = offsetFromCenter * spacing;
                          offsetY = (offsetFromCenter * offsetFromCenter) * (isMany ? 8.0 : 12.0) - (isMany ? 0 : 20);
                          angle = offsetFromCenter * (isMany ? 0.05 : 0.06);
                        }
                        
                        return Transform.translate(
                          offset: Offset(leftOffset, offsetY),
                          child: Transform.rotate(
                            angle: angle,
                            child: Container(
                              width: cWidth,
                              height: cHeight,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D0A1A),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFE7D6A5).withOpacity(0.35),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(color: const Color(0xFFE7D6A5).withOpacity(0.12), blurRadius: 35, spreadRadius: -5),
                                  BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 25, offset: const Offset(0, 10)),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                clipBehavior: Clip.hardEdge,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Transform.scale(
                                      scale: 1.12,
                                      child: Image.asset(widget.cardAssets[i], width: cWidth, height: cHeight, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: const Color(0xFF160E24))),
                                    ),
                                    Positioned(bottom: 0, left: 0, right: 0, height: count == 7 ? 50 : (isMany ? 60 : 90), child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, const Color(0xFF0D0A1A).withOpacity(0.7), const Color(0xFF0D0A1A).withOpacity(0.95)])))),
                                    Positioned(bottom: count == 7 ? 12 : (isMany ? 10 : 20), left: 0, right: 0, child: Text(widget.cardNames.length > i ? widget.cardNames[i] : '', textAlign: TextAlign.center, style: GoogleFonts.cinzel(color: const Color(0xFFE7D6A5), fontSize: count == 7 ? 10 : (isMany ? 11 : 20), fontWeight: FontWeight.w600, letterSpacing: isMany ? 1.0 : 2.5, decoration: TextDecoration.none))),
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

                const SizedBox(height: 40),
                
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
                
                const SizedBox(height: 30),

                // Ana mesaj — Kartların gizli fısıltısı
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 65),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, color: const Color(0xFFE7D6A5).withOpacity(0.5), size: 28),
                          const SizedBox(height: 35),
                          Text(
                            widget.closingMessage,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lora(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: 52,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                              letterSpacing: 0.3,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 35),
                          Icon(Icons.auto_awesome, color: const Color(0xFFE7D6A5).withOpacity(0.5), size: 28),
                        ],
                      ),
                    ),
                  ),
                ),

                // Keywords (Neon renkler iptal → şampanya altını ve minimalist)
                if (widget.promises.isNotEmpty) ...[
                  const SizedBox(height: 30),
                  Text(
                    widget.promises.take(3).map((p) => p.toUpperCase()).join('   ◆   '),
                    style: GoogleFonts.cinzel(
                      color: const Color(0xFFE7D6A5).withOpacity(0.95),
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
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
                    color: const Color(0xFFE7D6A5).withOpacity(0.5),
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

  // 4:5 Gönderi Kartı (1080x1350) - Tarot
  Widget _buildPostCard() {
    return Container(
      width: 1080,
      height: 1350,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0710),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF160E24),
            Color(0xFF0A0710),
            Color(0xFF100A1C),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Arka plan ışıkları
          Positioned(
            top: -150,
            left: -150,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [const Color(0xFF6C3FA0).withOpacity(0.10), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -150,
            child: Container(
              width: 700,
              height: 700,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [const Color(0xFFE7D6A5).withOpacity(0.05), Colors.transparent],
                ),
              ),
            ),
          ),

          // Noise
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: Image.asset('assets/images/noise.png', fit: BoxFit.cover, errorBuilder: (_,__,___) => const SizedBox()),
            ),
          ),

          // İçerik
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 70),
            child: Column(
              children: [
                const SizedBox(height: 30),

                // Etiket
                Text(
                  widget.isMajorArcana ? '◆  M A J O R   A R C A N A  ◆' : '◆  F U L L   A R C A N A  ◆',
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFFE7D6A5).withOpacity(0.95),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 5.0,
                    decoration: TextDecoration.none,
                  ),
                ),

                const SizedBox(height: 60),

                // Kart görselleri (kompakt)
                SizedBox(
                  height: 320,
                  child: Stack(
                    alignment: Alignment.center,
                    children: List.generate(
                      widget.cardAssets.length,
                      (i) {
                        final count = widget.cardAssets.length;
                        final isMany = count > 3;
                        double cWidth = 190.0;
                        double cHeight = 310.0;
                        double leftOffset = 0.0;
                        double offsetY = 0.0;
                        double angle = 0.0;

                        if (count == 7) {
                          cWidth = 145.0;
                          cHeight = 243.0;
                          final spacing = 190.0;
                          
                          if (i < 4) { // Arka sıra
                            final offsetFromCenter = i - 1.5;
                            leftOffset = offsetFromCenter * spacing;
                            offsetY = (offsetFromCenter * offsetFromCenter) * 8.0 - 70.0;
                            angle = offsetFromCenter * 0.05;
                          } else { // Ön sıra
                            final localIndex = i - 4;
                            final offsetFromCenter = localIndex - 1.0;
                            leftOffset = offsetFromCenter * spacing;
                            offsetY = (offsetFromCenter * offsetFromCenter) * 8.0 + 60.0;
                            angle = offsetFromCenter * 0.05;
                          }
                        } else {
                          final centerIndex = (count - 1) / 2.0;
                          final offsetFromCenter = i - centerIndex;
                          final spacing = isMany ? 90.0 : 206.0;
                          cWidth = isMany ? 140.0 : 190.0;
                          cHeight = isMany ? 235.0 : 310.0;
                          leftOffset = offsetFromCenter * spacing;
                          offsetY = (offsetFromCenter * offsetFromCenter) * (isMany ? 5.0 : 8.0) - (isMany ? 0 : 15);
                          angle = offsetFromCenter * (isMany ? 0.05 : 0.05);
                        }
                        
                        return Transform.translate(
                          offset: Offset(leftOffset, offsetY),
                          child: Transform.rotate(
                            angle: angle,
                            child: Container(
                              width: cWidth,
                              height: cHeight,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D0A1A),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE7D6A5).withOpacity(0.30),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(color: const Color(0xFFE7D6A5).withOpacity(0.10), blurRadius: 25, spreadRadius: -5),
                                  BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 8)),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                clipBehavior: Clip.hardEdge,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Transform.scale(
                                      scale: 1.12,
                                      child: Image.asset(widget.cardAssets[i], width: cWidth, height: cHeight, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: const Color(0xFF160E24))),
                                    ),
                                    Positioned(bottom: 0, left: 0, right: 0, height: count == 7 ? 40 : (isMany ? 50 : 70), child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, const Color(0xFF0D0A1A).withOpacity(0.7), const Color(0xFF0D0A1A).withOpacity(0.95)])))),
                                    Positioned(bottom: count == 7 ? 8 : (isMany ? 8 : 14), left: 0, right: 0, child: Text(widget.cardNames.length > i ? widget.cardNames[i] : '', textAlign: TextAlign.center, style: GoogleFonts.cinzel(color: const Color(0xFFE7D6A5), fontSize: count == 7 ? 9 : (isMany ? 10 : 16), fontWeight: FontWeight.w600, letterSpacing: isMany ? 1.0 : 2.0, decoration: TextDecoration.none))),
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

                const SizedBox(height: 40),

                // Ayırıcı
                Container(
                  width: 120,
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

                const SizedBox(height: 25),

                // Mesaj — Tek güçlü fısıltı
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, color: const Color(0xFFE7D6A5).withOpacity(0.5), size: 22),
                          const SizedBox(height: 16),
                          Text(
                            widget.closingMessage,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lora(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: 42,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              height: 1.45,
                              letterSpacing: 0.3,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Icon(Icons.auto_awesome, color: const Color(0xFFE7D6A5).withOpacity(0.5), size: 22),
                        ],
                      ),
                    ),
                  ),
                ),

                // Keywords
                if (widget.promises.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    widget.promises.take(3).map((p) => p.toUpperCase()).join('   ◆   '),
                    style: GoogleFonts.cinzel(
                      color: const Color(0xFFE7D6A5).withOpacity(0.95),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3.0,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],

                const SizedBox(height: 50),

                // Branding
                Text(
                  'CRACK & WISH',
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFFE7D6A5).withOpacity(0.5),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 14.0,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aspectRatio = _isStoryFormat ? 1080.0 / 1920.0 : 1080.0 / 1350.0;
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: SizedBox.expand(
      child: Material(
        color: Colors.transparent,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: GestureDetector(
            onTap: _dismissModal,
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
                    // FORMAT SEÇİCİ
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildFormatTab('Hikaye', Icons.auto_stories_rounded, _isStoryFormat),
                          _buildFormatTab('Gönderi', Icons.grid_on_rounded, !_isStoryFormat),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // KART ÖNİZLEME
                    Flexible(
                      child: GestureDetector(
                        onTap: _dismissModal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.64),
                          child: AnimatedSize(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 350),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child: AspectRatio(
                                key: ValueKey(_isStoryFormat),
                                aspectRatio: aspectRatio,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(32),
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 40, spreadRadius: 10)],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(32),
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: _isStoryFormat ? _buildExportCard() : _buildPostCard(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // BUTONLAR
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
                                if (_isExporting)
                                  Opacity(
                                    opacity: 0.4,
                                    child: Icon(Icons.download_rounded, color: const Color(0xFFE7D6A5).withOpacity(0.7), size: 14),
                                  )
                                else
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
                                if (_isExporting)
                                  Opacity(
                                    opacity: 0.4,
                                    child: Icon(Icons.ios_share_rounded, color: Colors.white.withOpacity(0.85), size: 14),
                                  )
                                else
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
    ),
    ),
    );
  }

  Widget _buildFormatTab(String label, IconData icon, bool isSelected) {
    return _TarotTapButton(
      onTap: () => setState(() => _isStoryFormat = label == 'Hikaye'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.white.withOpacity(0.4), size: 14),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
              fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              letterSpacing: 0.3, decoration: TextDecoration.none,
            )),
          ],
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
  DateTime? _pressTime;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _pressTime = DateTime.now();
        setState(() => _pressed = true);
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) async {
        final elapsed = DateTime.now().difference(_pressTime ?? DateTime.now());
        final remaining = const Duration(milliseconds: 150) - elapsed;
        if (remaining > Duration.zero) await Future.delayed(remaining);
        if (mounted) setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.5 : 1.0,
          duration: const Duration(milliseconds: 80),
          child: widget.child,
        ),
      ),
    );
  }
}
