import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

class CoffeeShareModal extends StatefulWidget {
  final String story;
  final String? advice;
  final List<Map<String, dynamic>> symbols;
  final File? cupImage;

  const CoffeeShareModal({
    super.key,
    required this.story,
    this.advice,
    required this.symbols,
    this.cupImage,
  });

  @override
  State<CoffeeShareModal> createState() => _CoffeeShareModalState();
}

class _CoffeeShareModalState extends State<CoffeeShareModal> with TickerProviderStateMixin {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isExporting = false;
  bool _isStoryFormat = true;
  bool _isSaved = false;

  late final AnimationController _entranceCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  Uint8List? _cachedStoryImage;
  Uint8List? _cachedPostImage;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnim = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic));
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
      final h = story ? 1920.0 : 1350.0;
      return await _screenshotController.captureFromWidget(
        MediaQuery(data: const MediaQueryData(textScaler: TextScaler.noScaling), child: story ? _buildStoryCard() : _buildPostCard()),
        context: context, pixelRatio: 2.0, targetSize: Size(1080, h), delay: Duration.zero,
      );
    } catch (e) { return null; }
  }

  @override
  void dispose() { _entranceCtrl.dispose(); super.dispose(); }
  Future<void> _dismissModal() async { await _entranceCtrl.reverse(); if (mounted) Navigator.of(context).pop(); }

  Future<Uint8List?> _getImage() async {
    if (_isStoryFormat) return _cachedStoryImage ??= await _renderImage(true);
    return _cachedPostImage ??= await _renderImage(false);
  }

  void _saveToGallery() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    try {
      final image = await _getImage();
      if (image == null) return;
      final result = await ImageGallerySaverPlus.saveImage(image, quality: 95, name: 'crack_wish_coffee_${DateTime.now().millisecondsSinceEpoch}');
      if (mounted) {
        final ok = result != null && (result['isSuccess'] == true || result['isSuccess'] == 1);
        if (ok) { HapticFeedback.mediumImpact(); setState(() => _isSaved = true); Future.delayed(const Duration(seconds: 2), () { if (mounted) setState(() => _isSaved = false); }); }
      }
    } catch (_) {} finally { if (mounted) setState(() => _isExporting = false); }
  }

  void _shareContent() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    try {
      final image = await _getImage();
      if (image == null) return;
      final dir = await getTemporaryDirectory();
      final file = await File('${dir.path}/crack_wish_coffee.png').create();
      await file.writeAsBytes(image);
      final rb = context.findRenderObject() as RenderBox?;
      final rect = rb != null ? rb.localToGlobal(Offset.zero) & rb.size : Rect.zero;
      await Share.shareXFiles([XFile(file.path)], text: "Fincanımdaki sırlar çözüldü! ☕✨\n#CrackWish", sharePositionOrigin: rect);
    } catch (_) {} finally { if (mounted) setState(() => _isExporting = false); }
  }

  String get _displayText {
    final advice = widget.advice ?? '';
    if (advice.isNotEmpty && advice.length < 250) return advice;
    final s = widget.story;
    final sentences = s.split(RegExp(r'(?<=[.!?])\s+'));
    if (sentences.length <= 2) return s;
    return sentences.take(2).join(' ');
  }

  String get _symbolsLine {
    if (widget.symbols.isEmpty) return '';
    return widget.symbols.take(5).map((s) => s['name']?.toString() ?? '').where((s) => s.isNotEmpty).join('  ◆  ');
  }

  // ═════════════════════════════════════════
  // KART İÇERİĞİ
  // ═════════════════════════════════════════
  Widget _buildCardContent({required double w, required double h, required double fs, required double imgSz}) {
    const gold = Color(0xFFD4A373);
    const cream = Color(0xFFE8D5C4);
    final hasCup = widget.cupImage != null && widget.cupImage!.existsSync();

    return Container(
      width: w, height: h,
      decoration: const BoxDecoration(color: Color(0xFF0C0A09)),
      child: Stack(children: [
        // Arka plan: sıcak kahve tonlu gradient
        Positioned.fill(child: Container(decoration: BoxDecoration(gradient: RadialGradient(
          center: const Alignment(0, -0.3), radius: 1.2,
          colors: [const Color(0xFF2A1C10), const Color(0xFF130E0A), const Color(0xFF0C0A09)],
          stops: const [0.0, 0.5, 1.0],
        )))),

        // Altın ışık hüzmesi — yukarıdan
        Positioned(top: -h * 0.1, left: w * 0.15, right: w * 0.15, child: Container(
          height: h * 0.45,
          decoration: BoxDecoration(gradient: RadialGradient(
            colors: [gold.withOpacity(0.10), gold.withOpacity(0.03), Colors.transparent],
            stops: const [0.0, 0.4, 1.0],
          )),
        )),

        // Yıldız tozları
        ...List.generate(15, (i) {
          final rng = math.Random(i * 37 + 7);
          return Positioned(
            left: rng.nextDouble() * w, top: rng.nextDouble() * h,
            child: Container(
              width: 2 + rng.nextDouble() * 3, height: 2 + rng.nextDouble() * 3,
              decoration: BoxDecoration(shape: BoxShape.circle, color: gold.withOpacity(0.08 + rng.nextDouble() * 0.12)),
            ),
          );
        }),

        // ═══ İÇERİK ═══
        Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.08),
          child: Column(children: [
            SizedBox(height: h * 0.07),

            // ─── BAŞLIK BÖLÜMÜ ───
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: w * 0.12, height: 0.5, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, gold.withOpacity(0.6)]))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(children: [
                  Icon(Icons.auto_awesome, color: gold.withOpacity(0.5), size: 20),
                  const SizedBox(height: 10),
                  Text('Kahve Falı', style: GoogleFonts.playfairDisplay(
                    color: gold, fontSize: fs * 0.55, fontWeight: FontWeight.w600,
                    letterSpacing: 6.0, decoration: TextDecoration.none,
                  )),
                ]),
              ),
              Container(width: w * 0.12, height: 0.5, decoration: BoxDecoration(gradient: LinearGradient(colors: [gold.withOpacity(0.6), Colors.transparent]))),
            ]),

            SizedBox(height: h * 0.04),

            // ─── FİNCAN GÖRSELİ ───
            if (hasCup)
              SizedBox(
                width: imgSz + 50, height: imgSz + 50,
                child: Stack(alignment: Alignment.center, children: [
                  // Dış halo — büyük altın parıltı
                  Container(width: imgSz + 50, height: imgSz + 50, decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [gold.withOpacity(0.18), gold.withOpacity(0.05), Colors.transparent], stops: const [0.3, 0.65, 1.0]),
                  )),
                  // Orta halka — ince altın çizgi
                  Container(width: imgSz + 16, height: imgSz + 16, decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: gold.withOpacity(0.25), width: 1),
                  )),
                  // Altın çerçeve
                  Container(width: imgSz + 6, height: imgSz + 6, decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(colors: [
                      gold.withOpacity(0.7), gold.withOpacity(0.2),
                      gold.withOpacity(0.5), gold.withOpacity(0.15),
                      gold.withOpacity(0.7),
                    ]),
                  )),
                  // Fotoğraf
                  Container(width: imgSz, height: imgSz, decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(image: FileImage(widget.cupImage!), fit: BoxFit.cover),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30, spreadRadius: -5)],
                  )),
                  // Üst parıltı
                  Positioned(top: 8, right: imgSz * 0.15, child: Icon(Icons.auto_awesome, color: gold.withOpacity(0.6), size: 22)),
                ]),
              )
            else
              Text('☕', style: TextStyle(fontSize: imgSz * 0.6, fontFamilyFallback: const ['Apple Color Emoji'], decoration: TextDecoration.none)),

            SizedBox(height: h * 0.025),

            // ─── DEKORATİF AYIRICI ───
            SizedBox(
              width: w * 0.5,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Expanded(child: Container(height: 0.5, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, gold.withOpacity(0.4)])))),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Icon(Icons.flare, color: gold.withOpacity(0.35), size: 12)),
                Expanded(child: Container(height: 0.5, decoration: BoxDecoration(gradient: LinearGradient(colors: [gold.withOpacity(0.4), Colors.transparent])))),
              ]),
            ),

            SizedBox(height: h * 0.025),

            // ─── FAL METNİ ───
            const Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.05),
              child: Text(
                _displayText,
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(
                  color: cream.withOpacity(0.95), fontSize: fs,
                  fontWeight: FontWeight.w400, fontStyle: FontStyle.italic,
                  height: 1.55, decoration: TextDecoration.none,
                ),
              ),
            ),
            const Spacer(),

            SizedBox(height: h * 0.01),

            // ─── SEMBOLLER ───
            if (_symbolsLine.isNotEmpty) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: w * 0.06, vertical: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: gold.withOpacity(0.15)),
                  color: gold.withOpacity(0.04),
                ),
                child: Text(_symbolsLine.toUpperCase(), textAlign: TextAlign.center, style: GoogleFonts.cinzel(
                  color: gold.withOpacity(0.8), fontSize: fs * 0.28,
                  fontWeight: FontWeight.w600, letterSpacing: 4.0, decoration: TextDecoration.none,
                )),
              ),
              SizedBox(height: h * 0.035),
            ],

            // ─── LOGO ───
            Text('C R A C K  &  W I S H', style: GoogleFonts.montserrat(
              color: gold.withOpacity(0.3), fontSize: fs * 0.32,
              fontWeight: FontWeight.w500, letterSpacing: 4.0, decoration: TextDecoration.none,
            )),
            SizedBox(height: h * 0.045),
          ]),
        ),

        // Üst vinyet
        Positioned(top: 0, left: 0, right: 0, height: h * 0.06, child: Container(
          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [const Color(0xFF0C0A09), Colors.transparent])),
        )),
        // Alt vinyet
        Positioned(bottom: 0, left: 0, right: 0, height: h * 0.06, child: Container(
          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [const Color(0xFF0C0A09), Colors.transparent])),
        )),
      ]),
    );
  }

  Widget _buildStoryCard() => _buildCardContent(w: 1080, h: 1920, fs: 52, imgSz: 340);
  Widget _buildPostCard() => _buildCardContent(w: 1080, h: 1350, fs: 42, imgSz: 260);

  // ═════════════════════════════════════════
  // ANA UI
  // ═════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final ar = _isStoryFormat ? 1080.0 / 1920.0 : 1080.0 / 1350.0;
    return FadeTransition(opacity: _fadeAnim, child: ScaleTransition(scale: _scaleAnim,
      child: Dialog(backgroundColor: Colors.transparent, elevation: 0, insetPadding: EdgeInsets.zero,
        child: BackdropFilter(filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: GestureDetector(onTap: _dismissModal, behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity, height: double.infinity,
              color: Colors.black.withOpacity(0.4),
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
              child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
                Padding(padding: const EdgeInsets.only(top: 15), child: Column(mainAxisSize: MainAxisSize.min, children: [
                  // Format seçici
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(100)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      _tab('Hikaye', Icons.auto_stories_rounded, _isStoryFormat),
                      _tab('Gönderi', Icons.grid_on_rounded, !_isStoryFormat),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  // Önizleme
                  Flexible(child: GestureDetector(onTap: _dismissModal, child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.56),
                    child: AnimatedSize(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        transitionBuilder: (c, a) => FadeTransition(opacity: a, child: ScaleTransition(scale: Tween<double>(begin: 0.95, end: 1.0).animate(a), child: c)),
                        child: AspectRatio(key: ValueKey(_isStoryFormat), aspectRatio: ar,
                          child: Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 40, spreadRadius: 10)]),
                            child: ClipRRect(borderRadius: BorderRadius.circular(32), child: FittedBox(fit: BoxFit.contain, child: _isStoryFormat ? _buildStoryCard() : _buildPostCard())),
                          ),
                        ),
                      ),
                    ),
                  ))),
                  const SizedBox(height: 24),
                  // Butonlar
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _btn(_isSaved ? 'Kaydedildi ✓' : 'İndir', _isSaved ? Icons.check_circle_rounded : Icons.download_rounded,
                      _isSaved ? const Color(0xFF2D7A50) : Colors.transparent, _isSaved ? Colors.white : const Color(0xFFD4A373),
                      _isSaved ? Colors.transparent : const Color(0xFFD4A373).withOpacity(0.5), _saveToGallery),
                    const SizedBox(width: 12),
                    _btn('Paylaş', Icons.ios_share_rounded, const Color(0xFF3A3020), const Color(0xFFE8D5C4), Colors.transparent, _shareContent),
                  ]),
                ])),
              ]),
            ),
          ),
        ),
      ),
    ));
  }

  Widget _tab(String label, IconData icon, bool sel) => GestureDetector(
    onTap: () { HapticFeedback.lightImpact(); setState(() { _isStoryFormat = label == 'Hikaye'; _cachedStoryImage = null; _cachedPostImage = null; }); },
    child: AnimatedContainer(duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: sel ? Colors.white.withOpacity(0.15) : Colors.transparent, borderRadius: BorderRadius.circular(100)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: sel ? Colors.white : Colors.white.withOpacity(0.4), size: 14), const SizedBox(width: 6),
        Text(label, style: TextStyle(color: sel ? Colors.white : Colors.white.withOpacity(0.4), fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, decoration: TextDecoration.none)),
      ]),
    ),
  );

  Widget _btn(String label, IconData icon, Color bg, Color fg, Color border, VoidCallback onTap) => GestureDetector(
    onTap: _isExporting ? null : onTap,
    child: AnimatedContainer(duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100), border: border != Colors.transparent ? Border.all(color: border) : null),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: fg, size: 14), const SizedBox(width: 6),
        Text(label, style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w500, decoration: TextDecoration.none)),
      ]),
    ),
  );
}
