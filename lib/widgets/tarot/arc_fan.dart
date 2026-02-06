// lib/widgets/tarot/arc_fan.dart
// SIFIRDAN YAZILDI - TAM ÇALIŞAN VERSİYON

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================
// DATA MODEL
// ============================================================

class ArcFanCardData {
  final int id;
  final String name;
  final String frontAsset;
  final String description;

  const ArcFanCardData({
    required this.id,
    required this.name,
    required this.frontAsset,
    this.description = '',
  });
}

// ============================================================
// MAIN WIDGET
// ============================================================

class ArcFan extends StatefulWidget {
  final List<ArcFanCardData> cards;
  final double cardWidth;
  final double cardHeight;
  final String backAsset;
  final void Function(List<ArcFanCardData> selected)? onSelected3;
  final int maxSelections;

  const ArcFan({
    super.key,
    required this.cards,
    this.cardWidth = 100,
    this.cardHeight = 150,
    required this.backAsset,
    this.onSelected3,
    this.maxSelections = 3,
  });

  @override
  State<ArcFan> createState() => _ArcFanState();
}

class _ArcFanState extends State<ArcFan> with TickerProviderStateMixin {
  // Deck & Selection
  late List<ArcFanCardData> _deck;
  final List<ArcFanCardData> _selectedCards = [];
  final Set<int> _selectedIds = {};
  final Set<int> _flyingIds = {};
  int? _draggingIndex;
  bool _dragThrowTriggered = false;
  int? _previewingId;

  // Carousel rotation
  double _rotation = 0;
  late AnimationController _flingController;

  // Deal animation
  late AnimationController _dealController;

  // Flying cards - her biri kendi animasyonunu yönetir
  final Map<int, _FlyingCardState> _flyingCardStates = {};

  // Layout cache
  double _centerX = 0;
  double _arcRadius = 300;
  static const double _step = 0.15;
  static const double _deckYOffset = 210;

  @override
  void initState() {
    super.initState();
    _deck = List.of(widget.cards);

    _flingController = AnimationController.unbounded(vsync: this);
    _flingController.addListener(() {
      setState(() => _rotation = _flingController.value);
    });

    _dealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dealController.forward();
    });
  }

  @override
  void dispose() {
    _flingController.dispose();
    _dealController.dispose();
    for (final state in _flyingCardStates.values) {
      state.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(ArcFan oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_deckChanged(oldWidget.cards, widget.cards)) {
      _resetAll();
    }
  }

  bool _deckChanged(List<ArcFanCardData> a, List<ArcFanCardData> b) {
    if (a.length != b.length) return true;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return true;
    }
    return false;
  }

  void _resetAll() {
    _deck = List.of(widget.cards);
    _selectedCards.clear();
    _selectedIds.clear();
    _flyingIds.clear();
    for (final state in _flyingCardStates.values) {
      state.dispose();
    }
    _flyingCardStates.clear();
    _dealController.forward(from: 0);
    setState(() {});
  }

  // ============================================================
  // GESTURES
  // ============================================================

  void _onPanStart(DragStartDetails _) {
    _flingController.stop();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _rotation += details.delta.dx * 0.0012;
    _flingController.value = _rotation;
  }

  void _onPanEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dx * 0.0012;
    if (velocity.abs() < 0.01) {
      _snapToNearest();
      return;
    }

    final simulation = _FrictionSimulation(0.4, _rotation, velocity);
    _flingController.animateWith(simulation).then((_) => _snapToNearest());
  }

  void _snapToNearest() {
    final snapIndex = (-_rotation / _step).round();
    final snapRotation = -snapIndex * _step;
    _flingController.animateTo(
      snapRotation,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  // ============================================================
  // CARD SELECTION
  // ============================================================

  void _onCardTap(int deckIndex) {
    if (_selectedCards.length >= widget.maxSelections) return;

    final card = _deck[deckIndex];
    if (_selectedIds.contains(card.id)) return;
    if (_flyingIds.contains(card.id)) return;

    HapticFeedback.mediumImpact();

    // Hedef slot HEMEN belirle
    final targetSlot = _selectedCards.length + _flyingIds.length;
    if (targetSlot >= widget.maxSelections) return;

    // Flying olarak işaretle
    _flyingIds.add(card.id);

    // Başlangıç pozisyonunu hesapla
    final startPose = _calculateCardPose(deckIndex);
    _startFlyCard(
      card: card,
      targetSlot: targetSlot,
      startCenter: startPose.center,
      startAngle: startPose.angle,
    );
  }

  void _onFlyComplete(ArcFanCardData card, int slot) {
    setState(() {
      _flyingIds.remove(card.id);
      _flyingCardStates.remove(card.id);
      _selectedIds.add(card.id);
      _selectedCards.add(card);
    });

    if (_selectedCards.length == widget.maxSelections) {
      widget.onSelected3?.call(List.unmodifiable(_selectedCards));
    }
  }

  void _onCardThrow(int deckIndex, Offset startCenter, double startAngle) {
    if (_selectedCards.length >= widget.maxSelections) return;

    final card = _deck[deckIndex];
    if (_selectedIds.contains(card.id)) return;
    if (_flyingIds.contains(card.id)) return;

    // Hedef slot HEMEN belirle
    final targetSlot = _selectedCards.length + _flyingIds.length;
    if (targetSlot >= widget.maxSelections) return;

    // Flying olarak işaretle
    _flyingIds.add(card.id);

    _startFlyCard(
      card: card,
      targetSlot: targetSlot,
      startCenter: startCenter,
      startAngle: startAngle,
    );
  }

  void _startFlyCard({
    required ArcFanCardData card,
    required int targetSlot,
    required Offset startCenter,
    required double startAngle,
  }) {
    // Hedef pozisyonunu hesapla
    final endCenter = _calculateSlotCenter(targetSlot);

    // Flying card state oluştur
    final flyState = _FlyingCardState(
      card: card,
      targetSlot: targetSlot,
      startCenter: startCenter,
      startAngle: startAngle,
      endCenter: endCenter,
      vsync: this,
      onComplete: () => _onFlyComplete(card, targetSlot),
    );

    _flyingCardStates[card.id] = flyState;

    setState(() {});

    // Animasyonu başlat
    flyState.start();
  }

  _CardPose _calculateCardPose(int deckIndex) {
    final total = _deck.length;
    final half = total ~/ 2;
    final displayCenter = ((-_rotation / _step) % total + total) % total;
    final relativeIndex = ((deckIndex - displayCenter + half) % total) - half;
    final angle = relativeIndex * _step;

    final x = _centerX + sin(angle) * _arcRadius;
    final y = cos(angle) * 30 + _deckYOffset + widget.cardHeight / 2;

    return _CardPose(center: Offset(x, y), angle: angle * 0.5 * 0.7);
  }

  Offset _calculateSlotCenter(int slotIndex) {
    final size = MediaQuery.of(context).size;
    final cardW = widget.cardWidth * 0.75;
    final cardH = widget.cardHeight * 0.75;
    final slotGap = cardW * 0.95;
    final totalWidth = cardW + (widget.maxSelections - 1) * slotGap;
    final startX = (size.width - totalWidth) / 2;
    final slotY = size.height * -0.05;

    return Offset(startX + cardW / 2 + slotIndex * slotGap, slotY + cardH / 2);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    _centerX = screenWidth / 2;

    return SizedBox(
      height: widget.cardHeight + 150,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: AnimatedBuilder(
          animation: Listenable.merge([_dealController, _flingController]),
          builder: (context, _) {
            final dealT = Curves.easeOutCubic.transform(_dealController.value);

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Slot'lar (arkada)
                ..._buildSlots(),

                // 2. Deste kartları
                ..._buildDeckCards(dealT),

                // 3. Uçan kartlar (en önde)
                ..._buildFlyingCards(),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildSlots() {
    final cardW = widget.cardWidth * 0.75;
    final cardH = widget.cardHeight * 0.75;

    return List.generate(widget.maxSelections, (i) {
      final center = _calculateSlotCenter(i);
      final isFilled = i < _selectedCards.length;

      return Positioned(
        left: center.dx - cardW / 2,
        top: center.dy - cardH / 2,
        child: Container(
          width: cardW,
          height: cardH,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: null,
          ),
          child: isFilled
              ? Transform.scale(
                  scale: i == 1 ? 1.2 : 1.0,
                  child: GestureDetector(
                    onTap: () => _showCardPreview(_selectedCards[i]),
                    child: Opacity(
                      opacity: _previewingId == _selectedCards[i].id
                          ? 0.0
                          : 1.0,
                      child: Hero(
                        tag: 'tarot_preview_${_selectedCards[i].id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                _selectedCards[i].frontAsset,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 12,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: _buildCardTitle(
                                    _selectedCards[i].name,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : null,
        ),
      );
    });
  }

  List<Widget> _buildDeckCards(double dealT) {
    final total = _deck.length;
    final half = total ~/ 2;
    final displayCenter = ((-_rotation / _step) % total + total) % total;

    final List<_DeckCardInfo> cardInfos = [];

    for (int i = 0; i < total; i++) {
      final card = _deck[i];
      // Seçilmiş veya uçuyor ise gösterme
      if (_selectedIds.contains(card.id) || _flyingIds.contains(card.id)) {
        continue;
      }

      final relativeIndex = ((i - displayCenter + half) % total) - half;
      final displayAngle = relativeIndex * _step;

      final x =
          _centerX + sin(displayAngle) * _arcRadius - widget.cardWidth / 2;
      final y = cos(displayAngle) * 30 + _deckYOffset;
      final rotation = displayAngle * 0.5;
      final scale = (1.0 - (relativeIndex.abs() * 0.05)).clamp(0.7, 1.2);

      // Deal animation
      final startX = _centerX - widget.cardWidth / 2;
      final startY = y + 200;

      final drawX = _lerpDouble(startX, x, dealT);
      final drawY = _lerpDouble(startY, y, dealT);
      final drawRotation = _lerpDouble(0, rotation, dealT);
      final drawScale = _lerpDouble(0.6, scale, dealT);

      cardInfos.add(
        _DeckCardInfo(
          index: i,
          x: drawX,
          y: drawY,
          rotation: drawRotation,
          scale: drawScale,
          zIndex: (100 - relativeIndex.abs() * 10).toInt(),
        ),
      );
    }

    // Z-index'e göre sırala
    cardInfos.sort((a, b) => a.zIndex.compareTo(b.zIndex));

    return cardInfos.map((info) {
      return Positioned(
        left: info.x,
        top: info.y,
        child: GestureDetector(
          onTap: () => _onCardTap(info.index),
          onLongPress: () {
            final startCenter = Offset(
              info.x + widget.cardWidth / 2,
              info.y + widget.cardHeight / 2,
            );
            _onCardThrow(info.index, startCenter, info.rotation * 0.7);
          },
          onVerticalDragStart: (_) {
            _draggingIndex = info.index;
            _dragThrowTriggered = false;
          },
          onVerticalDragUpdate: (details) {
            if (_draggingIndex != info.index || _dragThrowTriggered) return;
            if (details.delta.dy < -6) {
              final startCenter = Offset(
                info.x + widget.cardWidth / 2,
                info.y + widget.cardHeight / 2,
              );
              _dragThrowTriggered = true;
              _onCardThrow(info.index, startCenter, info.rotation * 0.7);
            }
          },
          onVerticalDragEnd: (details) {
            _draggingIndex = null;
            _dragThrowTriggered = false;
            if (details.velocity.pixelsPerSecond.dy < -800) {
              final startCenter = Offset(
                info.x + widget.cardWidth / 2,
                info.y + widget.cardHeight / 2,
              );
              _onCardThrow(info.index, startCenter, info.rotation * 0.7);
            }
          },
          onVerticalDragCancel: () {
            _draggingIndex = null;
            _dragThrowTriggered = false;
          },
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0015)
              ..rotateX(-0.85)
              ..rotateZ(info.rotation * 0.7)
              ..scale(info.scale * 0.98),
            child: Container(
              width: widget.cardWidth,
              height: widget.cardHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(widget.backAsset, fit: BoxFit.cover),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildFlyingCards() {
    final cardW = widget.cardWidth * 0.75;
    final cardH = widget.cardHeight * 0.75;

    return _flyingCardStates.values.map((flyState) {
      return AnimatedBuilder(
        animation: flyState.animation,
        builder: (context, _) {
          final progress = flyState.flyProgress;
          final flipProgress = flyState.flipProgress;

          // Pozisyon interpolasyonu
          final currentCenter = Offset.lerp(
            flyState.startCenter,
            flyState.endCenter,
            Curves.easeOutCubic.transform(progress),
          )!;

          // Boyut interpolasyonu
          final currentW = _lerpDouble(widget.cardWidth, cardW, progress);
          final currentH = _lerpDouble(widget.cardHeight, cardH, progress);

          // Açı interpolasyonu
          final currentAngle = _lerpDouble(flyState.startAngle, 0, progress);

          // Flip değeri
          final flipValue = Curves.easeInOut.transform(flipProgress) * pi;

          return Positioned(
            left: currentCenter.dx - currentW / 2,
            top: currentCenter.dy - currentH / 2,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateZ(currentAngle)
                ..rotateY(flipValue),
              child: SizedBox(
                width: currentW,
                height: currentH,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: flipValue < pi / 2
                      ? Image.asset(widget.backAsset, fit: BoxFit.cover)
                      : Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(pi),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                flyState.card.frontAsset,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 12,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: _buildCardTitle(
                                    flyState.card.name,
                                    fontSize: 12,
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
      );
    }).toList();
  }

  double _lerpDouble(double a, double b, double t) => a + (b - a) * t;

  Widget _buildCardTitle(String title, {double fontSize = 18}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: GoogleFonts.uncialAntiqua(
          color: const Color(0xFFE6D2A3),
          fontWeight: FontWeight.w700,
          fontSize: fontSize,
          letterSpacing: 0.6,
          shadows: const [
            Shadow(
              color: Color(0xFF0E0A05),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  void _showCardPreview(ArcFanCardData card) {
    setState(() => _previewingId = card.id);
    Navigator.of(context)
        .push(_CardPreviewRoute(card: card, titleBuilder: _buildCardTitle))
        .then((_) {
          if (!mounted) return;
          setState(() => _previewingId = null);
        });
  }
}

class _CardPreviewRoute extends PageRouteBuilder<void> {
  _CardPreviewRoute({required this.card, required this.titleBuilder})
    : super(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.75),
        transitionDuration: const Duration(milliseconds: 520),
        reverseTransitionDuration: const Duration(milliseconds: 420),
        pageBuilder: (context, _, __) =>
            _CardPreviewView(card: card, titleBuilder: titleBuilder),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );

  final ArcFanCardData card;
  final Widget Function(String, {double fontSize}) titleBuilder;
}

class _CardPreviewView extends StatelessWidget {
  const _CardPreviewView({required this.card, required this.titleBuilder});

  final ArcFanCardData card;
  final Widget Function(String, {double fontSize}) titleBuilder;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Center(
        child: Transform.translate(
          offset: const Offset(0, -56),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 0,
              bottom: 96,
            ),
            child: Stack(
              children: [
                Hero(
                  tag: 'tarot_preview_${card.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Transform.scale(
                      scale: 0.7,
                      child: Image.asset(card.frontAsset, fit: BoxFit.contain),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 36,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    widthFactor: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          titleBuilder(card.name),
                          if (card.description.trim().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                card.description,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.uncialAntiqua(
                                  color: const Color(0xFFE6D2A3),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                  height: 1.3,
                                  shadows: const [
                                    Shadow(
                                      color: Color(0xFF0E0A05),
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// HELPER CLASSES
// ============================================================

class _CardPose {
  final Offset center;
  final double angle;
  _CardPose({required this.center, required this.angle});
}

class _DeckCardInfo {
  final int index;
  final double x, y, rotation, scale;
  final int zIndex;
  _DeckCardInfo({
    required this.index,
    required this.x,
    required this.y,
    required this.rotation,
    required this.scale,
    required this.zIndex,
  });
}

class _FlyingCardState {
  final ArcFanCardData card;
  final int targetSlot;
  final Offset startCenter;
  final Offset endCenter;
  final double startAngle;
  final VoidCallback onComplete;

  late AnimationController _controller;

  static const _flyDuration = 400; // ms
  static const _flipDuration = 500; // ms
  static const _totalDuration = _flyDuration + _flipDuration;

  _FlyingCardState({
    required this.card,
    required this.targetSlot,
    required this.startCenter,
    required this.endCenter,
    required this.startAngle,
    required TickerProvider vsync,
    required this.onComplete,
  }) {
    _controller = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: _totalDuration),
    );
  }

  Animation<double> get animation => _controller;

  double get flyProgress {
    // 0-400ms arası fly
    final t = (_controller.value * _totalDuration / _flyDuration).clamp(
      0.0,
      1.0,
    );
    return t;
  }

  double get flipProgress {
    // 400-900ms arası flip
    final elapsed = _controller.value * _totalDuration;
    if (elapsed < _flyDuration) return 0;
    final t = ((elapsed - _flyDuration) / _flipDuration).clamp(0.0, 1.0);
    return t;
  }

  void start() {
    _controller.forward().then((_) => onComplete());
  }

  void dispose() {
    _controller.dispose();
  }
}

class _FrictionSimulation extends Simulation {
  final double drag;
  final double _startPosition;
  final double _startVelocity;

  _FrictionSimulation(this.drag, this._startPosition, this._startVelocity);

  @override
  double x(double time) {
    return _startPosition + _startVelocity * time * exp(-drag * time);
  }

  @override
  double dx(double time) {
    return _startVelocity * exp(-drag * time) * (1 - drag * time);
  }

  @override
  bool isDone(double time) {
    return dx(time).abs() < 0.01;
  }
}
