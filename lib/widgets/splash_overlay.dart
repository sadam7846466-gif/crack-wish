import 'package:flutter/material.dart';

class SplashOverlay extends StatefulWidget {
  final Widget child;
  const SplashOverlay({super.key, required this.child});

  @override
  State<SplashOverlay> createState() => _SplashOverlayState();
}

class _SplashOverlayState extends State<SplashOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // X app (Twitter) tarzı: Önce ikon bir süre ekranda kalır, sonra aniden büyüyerek erir
    // Çok fazla büyütmek Flutter Impeller'ı çökerttiği için (texture limit), maksimum 25.0'da tutup fade out'u hızlandırıyoruz
    _scaleAnimation = Tween<double>(begin: 1.0, end: 25.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInExpo), 
      ),
    );

    // Büyüme başladığında ikon ve arka plan hemen şeffaflaşıp altındaki sayfayı göstersin
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.65, 0.95, curve: Curves.easeOut),
      ),
    );

    _ctrl.forward().then((_) {
      if (mounted) setState(() => _isVisible = false);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child, // Gerçek uygulama
        if (_isVisible)
          AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              // IgnorePointer ile alt tarafa tıklamayı engelle / serbest bırak
              return IgnorePointer(
                ignoring: _opacityAnimation.value == 0.0,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Container(
                    color: const Color(0xFFB46471), // Native splash rengi
                    child: Center(
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Image.asset(
                          'assets/icons/splash_cookie.png',
                          width: 168,
                          height: 168,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
