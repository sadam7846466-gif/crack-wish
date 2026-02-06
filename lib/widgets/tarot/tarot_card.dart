import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

/// Premium Tarot Card Widget with Shimmer, Flip Animation, and Gyroscope Effects
class TarotCard extends StatefulWidget {
  final String? frontAsset;
  final String backAsset;
  final double width;
  final double height;
  final bool isFlipped;
  final bool isSelected;
  final bool enableShimmer;
  final bool enableHover;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TarotCard({
    super.key,
    this.frontAsset,
    required this.backAsset,
    this.width = 120,
    this.height = 200,
    this.isFlipped = false,
    this.isSelected = false,
    this.enableShimmer = false,
    this.enableHover = true,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<TarotCard> createState() => _TarotCardState();
}

class _TarotCardState extends State<TarotCard> with TickerProviderStateMixin {
  // Flip animation
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  // Hover/Press animation
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  // Shimmer animation
  late AnimationController _shimmerController;

  // Gyroscope for shimmer direction
  double _gyroX = 0.0;
  double _gyroY = 0.0;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    if (widget.enableShimmer) {
      _initAccelerometer();
    }
  }

  void _initAnimations() {
    // Flip animation
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flipAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutCubic),
    );

    // Hover animation
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
    _elevationAnimation = Tween<double>(begin: 8, end: 20).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );

    // Shimmer animation (continuous)
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Set initial flip state
    if (widget.isFlipped) {
      _flipController.value = 1.0;
    }
  }

  void _initAccelerometer() {
    _accelerometerSubscription = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 50),
    ).listen((AccelerometerEvent event) {
      if (mounted) {
        setState(() {
          _gyroX = _gyroX * 0.8 + event.x * 0.2;
          _gyroY = _gyroY * 0.8 + event.y * 0.2;
          _gyroX = _gyroX.clamp(-10.0, 10.0);
          _gyroY = _gyroY.clamp(-10.0, 10.0);
        });
      }
    });
  }

  @override
  void didUpdateWidget(TarotCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped) {
      if (widget.isFlipped) {
        _flipController.forward();
      } else {
        _flipController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _hoverController.dispose();
    _shimmerController.dispose();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  void _onTapDown(_) {
    if (!widget.enableHover) return;
    setState(() => _isPressed = true);
    _hoverController.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(_) {
    if (!widget.enableHover) return;
    setState(() => _isPressed = false);
    _hoverController.reverse();
  }

  void _onTapCancel() {
    if (!widget.enableHover) return;
    setState(() => _isPressed = false);
    _hoverController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _flipAnimation,
          _scaleAnimation,
          _shimmerController,
        ]),
        builder: (context, child) {
          final showFront = _flipAnimation.value > pi / 2;

          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // perspective
                ..rotateY(_flipAnimation.value),
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    // Gold glow for selected cards
                    if (widget.isSelected)
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.5),
                        blurRadius: 25,
                        spreadRadius: 5,
                      ),
                    // Main shadow
                    BoxShadow(
                      color: Colors.black.withOpacity(_isPressed ? 0.6 : 0.4),
                      blurRadius: _elevationAnimation.value,
                      offset: Offset(0, _elevationAnimation.value / 2),
                      spreadRadius: _isPressed ? 2 : 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // Card face
                      Positioned.fill(
                        child: showFront
                            ? Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(pi),
                                child: _buildCardFace(
                                  widget.frontAsset ?? widget.backAsset,
                                  isFront: true,
                                ),
                              )
                            : _buildCardFace(widget.backAsset, isFront: false),
                      ),

                      // Shimmer overlay (only on front face when enabled)
                      if (widget.enableShimmer && showFront)
                        Positioned.fill(
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(pi),
                            child: _buildShimmerOverlay(),
                          ),
                        ),

                      // Selection glow border
                      if (widget.isSelected)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFD4AF37),
                                width: 2,
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
        },
      ),
    );
  }

  Widget _buildCardFace(String asset, {required bool isFront}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Image.asset(
        asset,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isFront
                    ? [
                        const Color(0xFF2D1B4E),
                        const Color(0xFF1A0A2E),
                      ]
                    : [
                        const Color(0xFF1A1A2E),
                        const Color(0xFF0F0F1A),
                      ],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.auto_awesome,
                color: const Color(0xFFD4AF37).withOpacity(0.5),
                size: 40,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerOverlay() {
    // Calculate shimmer position based on gyroscope
    final shimmerX = (_gyroX / 10.0 + _shimmerController.value * 2) % 2 - 0.5;
    final shimmerY = (_gyroY / 10.0 + _shimmerController.value) % 2 - 0.5;

    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment(shimmerX - 0.5, shimmerY - 0.5),
            end: Alignment(shimmerX + 0.5, shimmerY + 0.5),
            colors: [
              Colors.transparent,
              const Color(0xFFD4AF37).withOpacity(0.15),
              const Color(0xFFFFFFFF).withOpacity(0.25),
              const Color(0xFFD4AF37).withOpacity(0.15),
              Colors.transparent,
            ],
            stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
          ),
        ),
      ),
    );
  }
}

/// A card that shows just the back (for deck display)
class TarotBackCard extends StatelessWidget {
  final String backAsset;
  final double width;
  final double height;
  final double rotation;
  final Offset offset;

  const TarotBackCard({
    super.key,
    required this.backAsset,
    this.width = 100,
    this.height = 160,
    this.rotation = 0,
    this.offset = Offset.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          width: width,
          height: height,
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
              backAsset,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
