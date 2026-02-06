import 'package:flutter/material.dart';

class FloatingAstronaut2 extends StatefulWidget {
  final Widget child;

  const FloatingAstronaut2({super.key, required this.child});

  @override
  State<FloatingAstronaut2> createState() => _FloatingAstronaut2State();
}

class _FloatingAstronaut2State extends State<FloatingAstronaut2>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatY;
  late Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 6000), // Farklı süre
      vsync: this,
    )..repeat(reverse: true);

    // Yatay hareket (sola-sağa)
    _floatY = Tween<double>(
      begin: -4,
      end: 4,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _rotate = Tween<double>(
      begin: 0.04,
      end: -0.04,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_floatY.value, _floatY.value * 0.5), // Çapraz hareket
          child: Transform.rotate(angle: _rotate.value, child: child),
        );
      },
      child: widget.child,
    );
  }
}
