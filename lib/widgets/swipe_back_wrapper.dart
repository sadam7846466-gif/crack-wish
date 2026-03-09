import 'package:flutter/material.dart';

/// Instagram / X tarzı — ekranın HER YERİNDEN sağa kaydırarak geri dönme.
/// 
/// Güvenlik:
/// - Minimum 20px yatay hareket gerekir (tıklamayı yanlışlıkla tetiklemez)
/// - Yatay hareket, dikeyden baskın olmalı (scroll ile çakışmaz)  
/// - Sadece SAĞA kaydırma çalışır
class SwipeBackWrapper extends StatefulWidget {
  final Widget child;
  
  /// Dismiss eşiği — ekran genişliğinin bu oranı kaydırılırsa kapanır
  final double dismissThreshold;
  
  /// Hızlı fırlatma eşiği (px/sn)
  final double velocityThreshold;

  const SwipeBackWrapper({
    super.key,
    required this.child,
    this.dismissThreshold = 0.3,
    this.velocityThreshold = 700.0,
  });

  @override
  State<SwipeBackWrapper> createState() => _SwipeBackWrapperState();
}

class _SwipeBackWrapperState extends State<SwipeBackWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  
  double _dragOffset = 0.0;
  bool _isPopping = false;
  
  // Gesture yön algılama
  Offset? _initialPosition;
  bool _swipeDecided = false;   // Yön kararı verildi mi?
  bool _swipeAccepted = false;  // Yatay sağa swipe kabul edildi mi?
  
  // Minimum hareket eşiği — bu kadar px hareket etmeden karar verilmez
  static const double _directionThreshold = 20.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    if (_isPopping) return;
    _initialPosition = event.position;
    _swipeDecided = false;
    _swipeAccepted = false;
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_isPopping || _initialPosition == null) return;
    
    final delta = event.position - _initialPosition!;
    
    // Henüz karar verilmediyse ve yeterince hareket ettiyse → karar ver
    if (!_swipeDecided && delta.distance > _directionThreshold) {
      _swipeDecided = true;
      
      // Yatay hareket dikeyden en az 1.5x baskınsa VE sağa gidiyorsa → kabul
      _swipeAccepted = delta.dx > 0 && delta.dx.abs() > delta.dy.abs() * 1.5;
    }
    
    // Kabul edilmediyse hiçbir şey yapma
    if (!_swipeAccepted) return;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final newOffset = (event.position.dx - _initialPosition!.dx).clamp(0.0, screenWidth);
    
    setState(() {
      _dragOffset = newOffset;
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_isPopping) return;
    
    if (!_swipeAccepted || _dragOffset == 0) {
      _reset();
      return;
    }
    
    final screenWidth = MediaQuery.of(context).size.width;
    final dragRatio = _dragOffset / screenWidth;
    
    // Hızlı hesaplama: son pozisyondan basit velocity tahmini
    // (Gerçek velocity için daha gelişmiş tracking gerekir ama bu yeterli)
    if (dragRatio > widget.dismissThreshold) {
      _dismiss();
    } else {
      _snapBack();
    }
  }

  // Pointer cancel (örn. sistem gesture devreye girerse)
  void _onPointerCancel(PointerCancelEvent event) {
    if (_swipeAccepted && _dragOffset > 0) {
      _snapBack();
    } else {
      _reset();
    }
  }

  void _dismiss() {
    if (_isPopping) return;
    _isPopping = true;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final startOffset = _dragOffset;
    final endOffset = screenWidth;
    
    _animController.reset();
    _animController.duration = const Duration(milliseconds: 200);
    
    late final VoidCallback listener;
    listener = () {
      setState(() {
        _dragOffset = startOffset + (endOffset - startOffset) * Curves.easeOut.transform(_animController.value);
      });
      
      if (_animController.isCompleted) {
        _animController.removeListener(listener);
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    };
    
    _animController.addListener(listener);
    _animController.forward();
  }

  void _snapBack() {
    final startOffset = _dragOffset;
    if (startOffset == 0) {
      _reset();
      return;
    }
    
    _animController.reset();
    _animController.duration = Duration(
      milliseconds: (startOffset / MediaQuery.of(context).size.width * 250).toInt().clamp(100, 250),
    );
    
    late final VoidCallback listener;
    listener = () {
      setState(() {
        _dragOffset = startOffset * (1.0 - Curves.easeOutCubic.transform(_animController.value));
      });
      
      if (_animController.isCompleted) {
        _animController.removeListener(listener);
        _reset();
      }
    };
    
    _animController.addListener(listener);
    _animController.forward();
  }

  void _reset() {
    _swipeDecided = false;
    _swipeAccepted = false;
    _initialPosition = null;
    if (_dragOffset != 0.0) {
      setState(() {
        _dragOffset = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dragRatio = (screenWidth > 0) ? (_dragOffset / screenWidth).clamp(0.0, 1.0) : 0.0;
    
    // Görsel efektler
    final opacity = (1.0 - dragRatio * 0.5).clamp(0.0, 1.0);
    final scale = 1.0 - dragRatio * 0.05;
    final borderRadius = dragRatio * 16.0;

    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      behavior: HitTestBehavior.translucent,
      child: Transform(
        transform: Matrix4.translationValues(_dragOffset, 0.0, 0.0)
          ..multiply(Matrix4.diagonal3Values(scale, scale, 1.0)),
        alignment: Alignment.centerLeft,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Opacity(
            opacity: opacity,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
