import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';
import 'package:flutter/services.dart';

/// Animated Card Deck that responds to shuffle gestures
class CardDeck extends StatefulWidget {
  final String backAsset;
  final double cardWidth;
  final double cardHeight;
  final int cardCount;
  final bool isShuffling;
  final VoidCallback? onShuffleComplete;
  final Function(bool)? onShuffleStateChanged;

  const CardDeck({
    super.key,
    required this.backAsset,
    this.cardWidth = 120,
    this.cardHeight = 180,
    this.cardCount = 22,
    this.isShuffling = false,
    this.onShuffleComplete,
    this.onShuffleStateChanged,
  });

  @override
  State<CardDeck> createState() => _CardDeckState();
}

class _CardDeckState extends State<CardDeck> with TickerProviderStateMixin {
  late AnimationController _jitterController;
  late AnimationController _organizeController;
  late Animation<double> _organizeAnimation;

  final List<_DeckCard> _cards = [];
  final Random _random = Random();

  bool _isInteracting = false;
  Offset _lastPosition = Offset.zero;
  double _totalRotation = 0;
  int _shuffleCount = 0;

  @override
  void initState() {
    super.initState();
    _initCards();
    _initAnimations();
  }

  void _initCards() {
    for (int i = 0; i < min(widget.cardCount, 15); i++) {
      _cards.add(_DeckCard(
        offsetX: _random.nextDouble() * 4 - 2,
        offsetY: i * -2.0,
        rotation: _random.nextDouble() * 0.04 - 0.02,
        zIndex: i,
      ));
    }
  }

  void _initAnimations() {
    _jitterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _organizeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _organizeAnimation = CurvedAnimation(
      parent: _organizeController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void didUpdateWidget(CardDeck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isShuffling && !oldWidget.isShuffling) {
      _startAutoShuffle();
    }
  }

  void _startAutoShuffle() async {
    widget.onShuffleStateChanged?.call(true);

    for (int i = 0; i < 8; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 200));
      _doShuffleIteration();
      HapticFeedback.selectionClick();
    }

    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      HapticFeedback.mediumImpact();
      _organizeCards();
      widget.onShuffleComplete?.call();
      widget.onShuffleStateChanged?.call(false);
    }
  }

  void _doShuffleIteration() {
    setState(() {
      for (var card in _cards) {
        card.offsetX = _random.nextDouble() * 30 - 15;
        card.offsetY = card.zIndex * -2.0 + _random.nextDouble() * 10 - 5;
        card.rotation = _random.nextDouble() * 0.3 - 0.15;
      }
      // Shuffle z-order
      _cards.shuffle(_random);
      for (int i = 0; i < _cards.length; i++) {
        _cards[i].zIndex = i;
      }
    });
  }

  void _organizeCards() {
    _organizeController.forward(from: 0);
    _organizeController.addListener(_onOrganizeUpdate);
  }

  void _onOrganizeUpdate() {
    if (!mounted) return;
    final progress = _organizeAnimation.value;
    setState(() {
      for (int i = 0; i < _cards.length; i++) {
        final card = _cards[i];
        card.offsetX = card.offsetX * (1 - progress);
        card.offsetY = (i * -2.0) * progress + card.offsetY * (1 - progress);
        card.rotation = card.rotation * (1 - progress);
      }
    });
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isInteracting = true;
      _lastPosition = details.localPosition;
      _totalRotation = 0;
      _shuffleCount = 0;
    });
    widget.onShuffleStateChanged?.call(true);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isInteracting) return;

    final currentPosition = details.localPosition;
    final delta = currentPosition - _lastPosition;

    // Calculate rotation (cross product for circular motion)
    final center = Offset(widget.cardWidth / 2, widget.cardHeight / 2);
    final prevVector = _lastPosition - center;
    final currVector = currentPosition - center;
    final cross = prevVector.dx * currVector.dy - prevVector.dy * currVector.dx;

    _totalRotation += cross.abs() * 0.001;

    // Trigger haptic on each "shuffle unit"
    if (_totalRotation > (_shuffleCount + 1) * pi / 4) {
      _shuffleCount++;
      HapticFeedback.lightImpact();
      _doShuffleIteration();
    }

    // Apply jitter based on movement
    setState(() {
      for (var card in _cards) {
        card.offsetX += delta.dx * 0.3 * _random.nextDouble();
        card.rotation += delta.dx * 0.002;
      }
    });

    _lastPosition = currentPosition;
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isInteracting = false;
    });

    if (_shuffleCount >= 3) {
      HapticFeedback.mediumImpact();
      _organizeCards();
      widget.onShuffleComplete?.call();
    }

    widget.onShuffleStateChanged?.call(false);
  }

  @override
  void dispose() {
    _jitterController.dispose();
    _organizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: SizedBox(
        width: widget.cardWidth + 40,
        height: widget.cardHeight + 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glow under deck
            Container(
              width: widget.cardWidth + 20,
              height: 30,
              margin: EdgeInsets.only(top: widget.cardHeight),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
            // Cards
            ..._cards.map((card) => AnimatedPositioned(
                  duration: _isInteracting
                      ? const Duration(milliseconds: 50)
                      : const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  left: 20 + card.offsetX,
                  top: 20 + card.offsetY.abs(),
                  child: Transform.rotate(
                    angle: card.rotation,
                    child: Container(
                      width: widget.cardWidth,
                      height: widget.cardHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          widget.backAsset,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                )),
            // Shuffle instruction
            if (!_isInteracting && !widget.isShuffling)
              Positioned(
                bottom: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app,
                        color: const Color(0xFFD4AF37).withOpacity(0.8),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppLocalizations.of(context)!.tarotShuffleHint,
                        style: TextStyle(
                          color: const Color(0xFFD4AF37).withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DeckCard {
  double offsetX;
  double offsetY;
  double rotation;
  int zIndex;

  _DeckCard({
    required this.offsetX,
    required this.offsetY,
    required this.rotation,
    required this.zIndex,
  });
}
