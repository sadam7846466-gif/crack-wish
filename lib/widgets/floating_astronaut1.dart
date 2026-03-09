import 'package:flutter/material.dart';

class FloatingAstronaut1 extends StatelessWidget {
  final Widget child;

  const FloatingAstronaut1({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, 0),
      child: Transform.rotate(
        angle: -0.01,
        child: child,
      ),
    );
  }
}
