import 'package:flutter/material.dart';

/// iOS tarzı — doğal sola kaydırarak geri dönme.
/// 
/// Davranış:
/// - Sayfa parmağı birebir takip eder (düz kayma, opacity/scale yok)
/// - Sol kenarda hafif gölge
/// - Bırakıldığında iOS spring fiziği ile yerine oturur veya çıkar
/// - Minimum 20px yatay hareket gerekir (tıklamayı tetiklemez)
/// - Yatay hareket dikeyden baskın olmalı (scroll ile çakışmaz)
class SwipeBackWrapper extends StatefulWidget {
  final Widget child;
  
  /// Dismiss eşiği — ekran genişliğinin bu oranı kaydırılırsa kapanır
  final double dismissThreshold;
  
  /// Hızlı fırlatma eşiği (px/sn)
  final double velocityThreshold;

  /// Herhangi bir SwipeBackWrapper aktif sürükleme yapıyorsa true.
  /// Alt widget'lar bu flag'i kontrol ederek dokunmayı engelleyebilir.
  static bool isSwiping = false;

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

  // Velocity tracking
  Offset? _lastPosition;
  DateTime? _lastTime;
  double _velocity = 0.0;

  // Minimum hareket eşiği — bu kadar px hareket etmeden karar verilmez
  static const double _directionThreshold = 20.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    if (_isPopping) return;
    
    // Eğer sayfada aktif bir PopScope engeli varsa veya sayfa kendi pop'unu yönetiyorsa kaydırmayı tamamen iptal et.
    final route = ModalRoute.of(context);
    if (route != null) {
      if (route.willHandlePopInternally || route.popDisposition == RoutePopDisposition.doNotPop) {
        return;
      }
    }

    _initialPosition = event.position;
    _lastPosition = event.position;
    _lastTime = DateTime.now();
    _velocity = 0.0;
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
      if (_swipeAccepted) SwipeBackWrapper.isSwiping = true;
    }
    
    // Kabul edilmediyse hiçbir şey yapma
    if (!_swipeAccepted) return;

    // Velocity hesapla
    final now = DateTime.now();
    if (_lastPosition != null && _lastTime != null) {
      final dt = now.difference(_lastTime!).inMicroseconds / 1000000.0;
      if (dt > 0) {
        _velocity = (event.position.dx - _lastPosition!.dx) / dt;
      }
    }
    _lastPosition = event.position;
    _lastTime = now;
    
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
    
    // iOS davranışı: %30'dan fazla kaydırıldıysa VEYA hızlı fırlatıldıysa → çık
    if (dragRatio > widget.dismissThreshold || _velocity > widget.velocityThreshold) {
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
    
    // iOS tarzı hızlı çıkış — kalan mesafeye göre süre ayarla
    final remaining = (endOffset - startOffset) / screenWidth;
    final duration = (remaining * 250).toInt().clamp(100, 250);
    
    _animController.reset();
    _animController.duration = Duration(milliseconds: duration);
    
    late final VoidCallback listener;
    listener = () {
      setState(() {
        _dragOffset = startOffset + (endOffset - startOffset) * Curves.easeOutCubic.transform(_animController.value);
      });
      
      if (_animController.isCompleted) {
        _animController.removeListener(listener);
        if (mounted) {
          Navigator.of(context).maybePop().then((didPop) {
            if (!didPop && mounted) {
              // PopScope blocked the pop — snap back instead
              _isPopping = false;
              _snapBack();
            }
          });
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
    
    // iOS spring fiziği — doğal yay etkisi
    _animController.reset();
    _animController.duration = const Duration(milliseconds: 350);
    
    late final VoidCallback listener;
    listener = () {
      setState(() {
        // Spring benzeri overshoot efekti
        _dragOffset = startOffset * (1.0 - Curves.easeOutBack.transform(_animController.value));
        if (_dragOffset < 0) _dragOffset = 0; // Overshoot'u sıfırda kes
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
    final wasSwiping = _swipeAccepted;
    _swipeDecided = false;
    _swipeAccepted = false;
    _initialPosition = null;
    _lastPosition = null;
    _lastTime = null;
    _velocity = 0.0;
    if (_dragOffset != 0.0) {
      setState(() {
        _dragOffset = 0.0;
      });
    }
    // isSwiping flag'ini gecikmeli sıfırla — GestureDetector.onTapUp
    // pointer-up'tan SONRA tetiklenebilir, bu da yanlış kart seçimine yol açar.
    if (wasSwiping) {
      Future.delayed(const Duration(milliseconds: 100), () {
        SwipeBackWrapper.isSwiping = false;
      });
    } else {
      SwipeBackWrapper.isSwiping = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Gölge opaklığı — kaydırma ilerledikçe azalır
    final shadowAlpha = _dragOffset > 0 
        ? (0.2 * (1.0 - (_dragOffset / screenWidth).clamp(0.0, 1.0)))
        : 0.0;

    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      behavior: HitTestBehavior.translucent,
      child: Transform.translate(
        offset: Offset(_dragOffset, 0),
        child: ClipRect(
          child: DecoratedBox(
            // iOS tarzı sol kenar gölgesi — sadece kaydırma aktifken
            decoration: BoxDecoration(
              boxShadow: shadowAlpha > 0
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: shadowAlpha),
                      blurRadius: 25,
                      spreadRadius: -5,
                      offset: const Offset(-8, 0),
                    ),
                  ]
                : null,
            ),
            child: AbsorbPointer(
              absorbing: _swipeAccepted || _isPopping,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
