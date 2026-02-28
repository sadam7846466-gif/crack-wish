import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// Premium Fade + Slide Up geçiş animasyonu
/// Sayfa hafifçe yukarı kayarak belirir, geri dönerken aşağı kayarak solar
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadePageRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 480),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Yumuşak eğri
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutQuart,
            reverseCurve: Curves.easeInCubic,
          );

          // Slide: çok hafif aşağıdan → 0
          final slideAnimation = Tween<Offset>(
            begin: const Offset(0, 0.03), // Ekranın %3'ü kadar
            end: Offset.zero,
          ).animate(curvedAnimation);

          return FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: child,
            ),
          );
        },
      );
}

/// Instagram tarzı sağa kaydırarak kapatma + fade efekti
class SwipeFadePageRoute<T> extends CupertinoPageRoute<T> {
  final Widget page;

  SwipeFadePageRoute({required this.page})
      : super(builder: (_) => page);

  @override
  bool get popGestureEnabled => true;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 350);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Cupertino'nun doğal slide + parallax geçişi
    final cupertinoChild = super.buildTransitions(
      context, animation, secondaryAnimation, child,
    );

    // Kaydırırken fade-out efekti: sayfa kayarken aynı anda solar
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        // animation.value: 1.0 = tam görünür, 0.0 = tamamen kaybolmuş
        // Fade biraz daha hızlı olsun (0.3'ten sonra tamamen şeffaf)
        final opacity = animation.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: opacity,
          child: cupertinoChild,
        );
      },
    );
  }
}

