import 'package:flutter/material.dart';
import 'swipe_back_wrapper.dart';

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

/// Instagram/X tarzı sağa kaydırarak kapatma + slide right geçişi
/// 
/// Özellikler:
/// - Açılırken SAĞDAN SOLA kayarak gelir
/// - HER YERDEN sağa kaydırarak geri dönülebilir
/// - Hızlı fırlatma desteği
/// - Kayarken köşeler yuvarlanır + hafif fade
class SwipeFadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SwipeFadePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              SwipeBackWrapper(child: page),
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          opaque: false,  // Alttaki sayfa görünsün (swipe sırasında)
          barrierColor: null,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Açılma: sağdan slide + fade
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            final slideAnimation = Tween<Offset>(
              begin: const Offset(1.0, 0.0), // Sağdan gelir
              end: Offset.zero,
            ).animate(curvedAnimation);

            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
            ));

            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
        );

  @override
  bool get popGestureEnabled => false; // Kendi swipe wrapper'ımız var

  @override
  bool get maintainState => true;
}
