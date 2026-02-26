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

/// FadePageRoute ile aynı açılış + sola kaydırarak kapatma desteği
class SwipeFadePageRoute<T> extends CupertinoPageRoute<T> {
  final Widget page;

  SwipeFadePageRoute({required this.page})
      : super(builder: (_) => page);

  @override
  bool get popGestureEnabled => true;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 480);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Always use Cupertino transitions (includes back gesture detector)
    final cupertinoChild = super.buildTransitions(
      context, animation, secondaryAnimation, child,
    );

    // On forward animation (opening): add fade effect on top
    if (animation.status == AnimationStatus.forward) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutQuart,
      );
      return FadeTransition(
        opacity: curvedAnimation,
        child: cupertinoChild,
      );
    }

    return cupertinoChild;
  }
}

