import 'package:flutter/material.dart';

class FloatingAstronaut1 extends StatefulWidget {
  final Widget child;

  const FloatingAstronaut1({
    super.key,
    required this.child,
  });

  @override
  State<FloatingAstronaut1> createState() => _FloatingAstronaut1State();
}

class _FloatingAstronaut1State extends State<FloatingAstronaut1>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatY;
  late Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 8000),
      vsync: this,
    )..repeat(reverse: true);

    _floatY = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotate = Tween<double>(begin: -0.03, end: 0.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
          offset: Offset(0, _floatY.value),
          child: Transform.rotate(
            angle: _rotate.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
