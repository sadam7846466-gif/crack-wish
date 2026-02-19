import 'package:flutter/material.dart';
import '../../data/mbti_data.dart';

class MBTIProgressBar extends StatelessWidget {
  final double value;
  final double height;
  const MBTIProgressBar({
    super.key,
    required this.value,
    this.height = MBTIProgressDefaults.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: MBTIProgressDefaults.trackColor,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth * value.clamp(0.0, 1.0);
          return Stack(
            children: [
              AnimatedContainer(
                duration: MBTIAnimations.progressFill,
                curve: MBTIAnimations.progressCurve,
                width: w,
                decoration: BoxDecoration(
                  gradient: MBTIColors.progressGradient,
                  borderRadius: BorderRadius.circular(height / 2),
                  boxShadow: const [MBTIProgressDefaults.fillGlow],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class MBTIProgressDefaults {
  static const double height = 6.0;
  static const double borderRadius = 3.0;
  static const Color trackColor = Color(0x14FFFFFF);
  static const BoxShadow fillGlow = BoxShadow(
    color: Color(0x80F7941D),
    blurRadius: 10,
  );
}
