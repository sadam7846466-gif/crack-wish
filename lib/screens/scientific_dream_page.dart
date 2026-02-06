import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';
import '../constants/colors.dart';
import '../models/scientific_dream_analysis.dart';
import '../services/scientific_dream_service.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/fade_page_route.dart';
import '../widgets/stars_background.dart';
import 'home_page.dart';
import 'collection_page.dart';
import 'profile_page.dart';

/// Scientific Dream Analysis Screen
/// Based on psychology and neuroscience - NOT fortune telling
class ScientificDreamPage extends StatefulWidget {
  const ScientificDreamPage({super.key});

  @override
  State<ScientificDreamPage> createState() => _ScientificDreamPageState();
}

class _ScientificDreamPageState extends State<ScientificDreamPage>
    with SingleTickerProviderStateMixin {
  AppLocalizations get _l10n => AppLocalizations.of(context)!;
  // Gradient for scientific/calm theme
  static const LinearGradient _scientificGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0B1424),
      Color(0xFF132238),
      Color(0xFF1A2F4A),
      Color(0xFF1E3A5C),
      Color(0xFF234468),
      Color(0xFF1A2F4A),
    ],
    stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
  );

  final TextEditingController _dreamController = TextEditingController();
  final FocusNode _dreamFocusNode = FocusNode();
  final ValueNotifier<int> _characterCount = ValueNotifier(0);
  final ScientificDreamService _analysisService = ScientificDreamService();

  int _currentNavIndex = 0;

  ScientificEmotion? _selectedEmotion;
  DreamClarity? _selectedClarity;
  bool _isAnalyzing = false;
  bool _showResults = false;
  ScientificDreamAnalysis? _analysisResult;

  @override
  void initState() {
    super.initState();
    _dreamController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    _characterCount.value = _dreamController.text.length;
  }

  @override
  void dispose() {
    _dreamController.removeListener(_onTextChanged);
    _dreamController.dispose();
    _dreamFocusNode.dispose();
    _characterCount.dispose();
    super.dispose();
  }

  bool get _canAnalyze =>
      _dreamController.text.trim().length >= 15 &&
      _selectedEmotion != null &&
      _selectedClarity != null;

  Future<void> _performAnalysis() async {
    if (!_canAnalyze || _isAnalyzing) return;

    setState(() => _isAnalyzing = true);

    final input = ScientificDreamInput(
      dreamText: _dreamController.text.trim(),
      emotion: _selectedEmotion!,
      clarity: _selectedClarity!,
    );

    final result = await _analysisService.analyzeDream(input);

    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _analysisResult = result;
        _showResults = true;
      });
    }
  }

  void _closeResults() {
    setState(() => _showResults = false);
  }

  void _resetForm() {
    setState(() {
      _dreamController.clear();
      _selectedEmotion = null;
      _selectedClarity = null;
      _showResults = false;
      _analysisResult = null;
    });
  }

  void _onNavTap(int index) {
    if (index == _currentNavIndex) return;
    setState(() => _currentNavIndex = index);

    Widget destination;
    switch (index) {
      case 0:
        destination = const HomePage();
        break;
      case 1:
        destination = const CollectionPage();
        break;
      case 2:
        destination = const ProfilePage();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(context, FadePageRoute(page: destination));
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 24;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Background
          IgnorePointer(
            child: RepaintBoundary(
              child: Container(
                decoration: const BoxDecoration(gradient: _scientificGradient),
              ),
            ),
          ),
          // Stars
          IgnorePointer(
            child: Positioned.fill(
              child: RepaintBoundary(
                child: Opacity(opacity: 0.3, child: const StarsBackground()),
              ),
            ),
          ),
          // Main Content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildDreamInputSection(),
                        const SizedBox(height: 32),
                        _buildEmotionSection(),
                        const SizedBox(height: 32),
                        _buildClaritySection(),
                        const SizedBox(height: 40),
                        _buildAnalyzeButton(),
                        const SizedBox(height: 24),
                        _buildDisclaimer(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Loading Overlay
          if (_isAnalyzing) _buildLoadingOverlay(),
          // Results Overlay
          if (_showResults && _analysisResult != null) _buildResultsOverlay(),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              _l10n.scientificTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance for back button
        ],
      ),
    );
  }

  Widget _buildDreamInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.edit_note, color: AppColors.textWhite70, size: 20),
            const SizedBox(width: 8),
            Text(
              _l10n.scientificDreamPromptTitle,
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              TextField(
                controller: _dreamController,
                focusNode: _dreamFocusNode,
                minLines: 6,
                maxLines: 10,
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 14,
                  height: 1.6,
                ),
                decoration: InputDecoration(
                  hintText: _l10n.scientificDreamHint,
                  hintStyle: TextStyle(
                    color: AppColors.textWhite50,
                    fontSize: 14,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  border: InputBorder.none,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ValueListenableBuilder<int>(
                      valueListenable: _characterCount,
                      builder: (context, count, child) {
                        final color = count < 15
                            ? AppColors.textWhite30
                            : AppColors.textWhite50;
                        return Text(
                          '$count karakter',
                          style: TextStyle(color: color, fontSize: 12),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.mood, color: AppColors.textWhite70, size: 20),
            const SizedBox(width: 8),
            Text(
              _l10n.scientificEmotionQuestion,
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _l10n.scientificEmotionHint,
          style: TextStyle(color: AppColors.textWhite50, fontSize: 12),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: ScientificEmotion.values.map((emotion) {
            final isSelected = _selectedEmotion == emotion;
            return _EmotionChip(
              emotion: emotion,
              isSelected: isSelected,
              onTap: () {
                setState(() => _selectedEmotion = emotion);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildClaritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.visibility, color: AppColors.textWhite70, size: 20),
            const SizedBox(width: 8),
            Text(
              _l10n.scientificClarityQuestion,
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: DreamClarity.values.map((clarity) {
            final isSelected = _selectedClarity == clarity;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: clarity == DreamClarity.clear ? 8 : 0,
                  left: clarity == DreamClarity.fragmented ? 8 : 0,
                ),
                child: _ClarityOption(
                  clarity: clarity,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() => _selectedClarity = clarity);
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAnalyzeButton() {
    final isActive = _canAnalyze;
    final activeColors = [
      const Color(0xFF4A90D9),
      const Color(0xFF5BA0E8),
      const Color(0xFF6CB0F0),
      const Color(0xFF7DBDF5),
      const Color(0xFF8ECAFF),
    ];
    final inactiveColors = activeColors
        .map((c) => c.withOpacity(0.35))
        .toList();

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: GlassButton.custom(
        width: double.infinity,
        height: 56,
        onTap: _canAnalyze ? () => _performAnalysis() : () {},
        useOwnLayer: true,
        quality: GlassQuality.standard,
        shape: const LiquidRoundedSuperellipse(borderRadius: 28),
        interactionScale: 0.97,
        stretch: 0.25,
        resistance: 0.08,
        glowColor: const Color(0xFF4A90D9).withOpacity(isActive ? 0.5 : 0.2),
        glowRadius: isActive ? 2.4 : 1.6,
        settings: const LiquidGlassSettings(
          thickness: 16,
          blur: 1.2,
          glassColor: Color(0x0BFFFFFF),
          chromaticAberration: 0.08,
          lightIntensity: 0.6,
          ambientStrength: 0.7,
          refractiveIndex: 1.45,
          saturation: 1.3,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: isActive ? activeColors : inactiveColors,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.02),
                        Colors.white.withOpacity(0.0),
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white.withOpacity(0.18),
                      width: 0.7,
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.psychology,
                      color: AppColors.textWhite,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Bilimsel Analiz Yap',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.textWhite50, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _l10n.scientificDisclaimer,
              style: TextStyle(
                color: AppColors.textWhite50,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          color: Colors.black.withOpacity(0.4),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    color: const Color(0xFF4A90D9),
                    backgroundColor: AppColors.textWhite30,
                    strokeWidth: 4,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Bilimsel analiz yapılıyor...',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _l10n.scientificLoading,
                  style: TextStyle(color: AppColors.textWhite70, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsOverlay() {
    final result = _analysisResult!;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Calculate percentages for the brain visualization
    final emotionPercent = _selectedEmotion != null ? 30 : 0;
    final clarityPercent = _selectedClarity == DreamClarity.clear ? 30 : 20;
    final stressPercent = 10;

    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A1628),
              Color(0xFF0D1E30),
              Color(0xFF101F35),
              Color(0xFF0A1628),
            ],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header with back arrow
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(8, topPadding + 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _closeResults,
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          _l10n.scientificResultsTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance for back button
                  ],
                ),
              ),
            ),
            // Holographic Brain Visualization
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: _HolographicBrainVisualization(
                  emotionPercent: emotionPercent,
                  clarityPercent: clarityPercent,
                  stressPercent: stressPercent,
                ),
              ),
            ),
            // Result Cards - New Design
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Temel Duygu Card
                  _InterpretationCard(
                    icon: Icons.favorite_outline,
                    title: 'Temel Duygu',
                    content: result.emotionalTheme.content,
                  ),
                  // Semboller Card
                  _SymbolsCard(symbols: _extractSymbols(result)),
                  // Yakın Geçmiş Etkileri Card
                  _InterpretationCard(
                    icon: Icons.history,
                    title: _l10n.scientificRecentPastTitle,
                    content: result.lifeConnection.content,
                    bulletPoints: _extractBulletPoints(
                      result.lifeConnection.content,
                    ),
                  ),
                ]),
              ),
            ),
            // Save Dream Button
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, bottomPadding + 100),
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: const Color(0xFF3A7BD5).withOpacity(0.5),
                      width: 1,
                    ),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF3A7BD5).withOpacity(0.15),
                        const Color(0xFF3A7BD5).withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(26),
                      onTap: () {
                        // Save dream logic here
                        _closeResults();
                        _resetForm();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_l10n.scientificSaved),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Center(
                        child: Text(
                          _l10n.scientificSaveButton,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _extractSymbols(ScientificDreamAnalysis result) {
    final isTr = Localizations.localeOf(context).languageCode == 'tr';
    // Extract symbols from the mental representation content
    final content = result.mentalRepresentation.content;
    final symbols = <Map<String, String>>[];

    // Default symbols based on content analysis
    if (content.contains('yol') || content.contains('hareket')) {
      symbols.add({
        'name': isTr ? 'Yollar' : 'Paths',
        'meaning': isTr
            ? 'Hayatta yön arayışı veya belirsizlik'
            : 'Searching for direction or uncertainty in life',
        'icon': 'route',
      });
    }
    if (content.contains('ev') || content.contains('güven')) {
      symbols.add({
        'name': isTr ? 'Ev' : 'Home',
        'meaning': isTr
            ? 'Güven ve aidiyet ihtiyacı'
            : 'Need for safety and belonging',
        'icon': 'home',
      });
    }
    if (content.contains('insan') || content.contains('kişi')) {
      symbols.add({
        'name': isTr ? 'İnsanlar' : 'People',
        'meaning': isTr
            ? 'Gerçek kişilerden çok duygularını temsil edebilir'
            : 'May represent emotions more than real people',
        'icon': 'people',
      });
    }

    // If no specific symbols found, add generic ones
    if (symbols.isEmpty) {
      symbols.add({
        'name': isTr ? 'Sahneler' : 'Scenes',
        'meaning': isTr
            ? 'Zihinsel işleme süreçlerini yansıtır'
            : 'Reflect mental processing',
        'icon': 'scene',
      });
    }

    return symbols;
  }

  List<String> _extractBulletPoints(String content) {
    // Split content into bullet points
    final sentences = content
        .split(RegExp(r'[.!]'))
        .where((s) => s.trim().isNotEmpty)
        .toList();
    if (sentences.length >= 2) {
      return sentences.take(2).map((s) => s.trim()).toList();
    }
    return [content];
  }
}

/// Holographic Brain Visualization Widget
class _HolographicBrainVisualization extends StatelessWidget {
  final int emotionPercent;
  final int clarityPercent;
  final int stressPercent;

  const _HolographicBrainVisualization({
    required this.emotionPercent,
    required this.clarityPercent,
    required this.stressPercent,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow effect behind
          Positioned.fill(child: CustomPaint(painter: _BrainGlowPainter())),
          // Main brain shape
          CustomPaint(
            size: const Size(280, 140),
            painter: _HolographicBrainPainter(),
          ),
          // Percentage labels
          Positioned(
            left: 50,
            top: 50,
            child: _PercentageLabel(value: '$emotionPercent%'),
          ),
          Positioned(
            left: 130,
            top: 70,
            child: _PercentageLabel(value: '$clarityPercent%'),
          ),
          Positioned(
            right: 60,
            top: 60,
            child: _PercentageLabel(value: '$stressPercent%'),
          ),
        ],
      ),
    );
  }
}

class _PercentageLabel extends StatelessWidget {
  final String value;

  const _PercentageLabel({required this.value});

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: TextStyle(
        color: Colors.white.withOpacity(0.9),
        fontSize: 14,
        fontWeight: FontWeight.w500,
        shadows: [
          Shadow(
            color: const Color(0xFF3A7BD5).withOpacity(0.8),
            blurRadius: 10,
          ),
        ],
      ),
    );
  }
}

class _BrainGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Outer glow
    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFF3A7BD5).withOpacity(0.3),
              const Color(0xFF3A7BD5).withOpacity(0.1),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(
            Rect.fromCenter(
              center: center,
              width: size.width,
              height: size.height,
            ),
          );

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.8,
        height: size.height * 0.6,
      ),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HolographicBrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Main brain outline - elliptical shape
    final brainPath = Path();

    // Draw brain-like shape with curves
    brainPath.moveTo(centerX - 100, centerY);
    brainPath.cubicTo(
      centerX - 100,
      centerY - 50,
      centerX - 50,
      centerY - 60,
      centerX,
      centerY - 55,
    );
    brainPath.cubicTo(
      centerX + 50,
      centerY - 60,
      centerX + 100,
      centerY - 50,
      centerX + 100,
      centerY,
    );
    brainPath.cubicTo(
      centerX + 100,
      centerY + 50,
      centerX + 50,
      centerY + 60,
      centerX,
      centerY + 55,
    );
    brainPath.cubicTo(
      centerX - 50,
      centerY + 60,
      centerX - 100,
      centerY + 50,
      centerX - 100,
      centerY,
    );

    // Glow paint
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF3A7BD5).withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawPath(brainPath, glowPaint);

    // Main stroke
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFF5BA0E8).withOpacity(0.8);

    canvas.drawPath(brainPath, strokePaint);

    // Inner wave lines
    for (var i = 0; i < 3; i++) {
      final wavePath = Path();
      final yOffset = centerY - 20 + (i * 20);

      wavePath.moveTo(centerX - 80, yOffset);
      for (var x = -80.0; x <= 80; x += 10) {
        final y = yOffset + 5 * (i % 2 == 0 ? 1 : -1) * (x / 80).abs();
        wavePath.lineTo(centerX + x, y);
      }

      final wavePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = const Color(0xFF3A7BD5).withOpacity(0.3 + i * 0.1);

      canvas.drawPath(wavePath, wavePaint);
    }

    // Elliptical rings
    for (var i = 1; i <= 2; i++) {
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = const Color(0xFF3A7BD5).withOpacity(0.2);

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(centerX, centerY + 30),
          width: size.width * (0.7 + i * 0.15),
          height: 30 + i * 10,
        ),
        ringPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Interpretation Card - matches mockup design
class _InterpretationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final List<String>? bulletPoints;

  const _InterpretationCard({
    required this.icon,
    required this.title,
    required this.content,
    this.bulletPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3A7BD5).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A7BD5).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF3A7BD5).withOpacity(0.3),
                  ),
                ),
                child: Icon(icon, size: 18, color: const Color(0xFF5BA0E8)),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (bulletPoints != null && bulletPoints!.isNotEmpty)
            ...bulletPoints!.map(
              (point) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: AppColors.textWhite50,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        point,
                        style: TextStyle(
                          color: AppColors.textWhite70,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Text(
              content,
              style: TextStyle(
                color: AppColors.textWhite70,
                fontSize: 13,
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }
}

/// Symbols Card - special design for symbols section
class _SymbolsCard extends StatelessWidget {
  final List<Map<String, String>> symbols;

  const _SymbolsCard({required this.symbols});

  IconData _getSymbolIcon(String iconName) {
    switch (iconName) {
      case 'route':
        return Icons.route;
      case 'home':
        return Icons.home_outlined;
      case 'people':
        return Icons.people_outline;
      case 'scene':
        return Icons.landscape_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3A7BD5).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Semboller',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...symbols.map(
            (symbol) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _getSymbolIcon(symbol['icon'] ?? ''),
                    size: 18,
                    color: const Color(0xFF5BA0E8),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          symbol['name'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          symbol['meaning'] ?? '',
                          style: TextStyle(
                            color: AppColors.textWhite70,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Emotion selection chip
class _EmotionChip extends StatelessWidget {
  final ScientificEmotion emotion;
  final bool isSelected;
  final VoidCallback onTap;

  const _EmotionChip({
    required this.emotion,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getEmotionIcon() {
    switch (emotion) {
      case ScientificEmotion.fear:
        return Icons.warning_amber;
      case ScientificEmotion.stress:
        return Icons.flash_on;
      case ScientificEmotion.guilt:
        return Icons.sentiment_dissatisfied;
      case ScientificEmotion.relief:
        return Icons.air;
      case ScientificEmotion.confusion:
        return Icons.help_outline;
      case ScientificEmotion.sadness:
        return Icons.water_drop;
      case ScientificEmotion.calm:
        return Icons.self_improvement;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4A90D9).withOpacity(0.25)
              : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4A90D9).withOpacity(0.6)
                : Colors.white.withOpacity(0.15),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4A90D9).withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getEmotionIcon(),
              size: 16,
              color: isSelected ? Colors.white : AppColors.textWhite70,
            ),
            const SizedBox(width: 6),
            Text(
              emotion.label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textWhite70,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Clarity selection option
class _ClarityOption extends StatelessWidget {
  final DreamClarity clarity;
  final bool isSelected;
  final VoidCallback onTap;

  const _ClarityOption({
    required this.clarity,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getClarityIcon() {
    switch (clarity) {
      case DreamClarity.clear:
        return Icons.visibility;
      case DreamClarity.fragmented:
        return Icons.blur_on;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4A90D9).withOpacity(0.2)
              : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4A90D9).withOpacity(0.5)
                : Colors.white.withOpacity(0.12),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _getClarityIcon(),
              size: 24,
              color: isSelected ? Colors.white : AppColors.textWhite70,
            ),
            const SizedBox(height: 8),
            Text(
              clarity.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textWhite70,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
