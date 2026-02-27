import 'package:flutter/material.dart';

class WindyNazar extends StatefulWidget {
  final String imagePath;
  final double width;
  final double height;

  const WindyNazar({
    super.key,
    required this.imagePath,
    this.width = 200,
    this.height = 400,
  });

  @override
  State<WindyNazar> createState() => _WindyNazarState();
}

class _WindyNazarState extends State<WindyNazar>
    with TickerProviderStateMixin {
  late AnimationController _primaryController;
  late AnimationController _secondaryController;
  late AnimationController _breathController;

  late Animation<double> _primarySwing;
  late Animation<double> _secondarySwing;
  late Animation<double> _breathAnimation;

  @override
  void initState() {
    super.initState();

    // Ana sallanma - yavas, genis hareket
    _primaryController = AnimationController(
      duration: const Duration(milliseconds: 4000), // 2800 → 4000 (daha az GPU)
      vsync: this,
    );
    _primarySwing = Tween<double>(begin: -0.07, end: 0.07).animate(
      CurvedAnimation(
        parent: _primaryController,
        curve: Curves.easeInOut,
      ),
    );
    _primaryController.repeat(reverse: true);

    // Ikincil mikro hareket - hizli, kucuk ruzgar etkisi
    _secondaryController = AnimationController(
      duration: const Duration(milliseconds: 2000), // 1100 → 2000 (daha az GPU)
      vsync: this,
    );
    _secondarySwing = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(
        parent: _secondaryController,
        curve: Curves.easeInOut,
      ),
    );
    _secondaryController.repeat(reverse: true);

    // Nefes alma efekti - cok yavas, hafif buyuyup kuculme
    _breathController = AnimationController(
      duration: const Duration(milliseconds: 6000), // 4000 → 6000 (daha az GPU)
      vsync: this,
    );
    _breathAnimation = Tween<double>(begin: 1.0, end: 1.015).animate(
      CurvedAnimation(
        parent: _breathController,
        curve: Curves.easeInOut,
      ),
    );
    _breathController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _primaryController.dispose();
    _secondaryController.dispose();
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _primarySwing,
        _secondarySwing,
        _breathAnimation,
      ]),
      builder: (context, child) {
        final totalRotation = _primarySwing.value + _secondarySwing.value;

        return Transform(
          alignment: Alignment.topCenter, // Ust orta noktadan asili
          transform: Matrix4.identity()
            ..rotateZ(totalRotation)
            ..scale(_breathAnimation.value),
          child: child,
        );
      },
      child: Image.asset(
        widget.imagePath,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.contain,
      ),
    );
  }
}

class WindyNazarNetwork extends StatefulWidget {
  final String imageUrl;
  final double width;
  final double height;

  const WindyNazarNetwork({
    super.key,
    required this.imageUrl,
    this.width = 200,
    this.height = 400,
  });

  @override
  State<WindyNazarNetwork> createState() => _WindyNazarNetworkState();
}

class _WindyNazarNetworkState extends State<WindyNazarNetwork>
    with TickerProviderStateMixin {
  late AnimationController _primaryController;
  late AnimationController _secondaryController;
  late AnimationController _breathController;

  late Animation<double> _primarySwing;
  late Animation<double> _secondarySwing;
  late Animation<double> _breathAnimation;

  @override
  void initState() {
    super.initState();

    _primaryController = AnimationController(
      duration: const Duration(milliseconds: 4000), // 2800 → 4000 (daha az GPU)
      vsync: this,
    );
    _primarySwing = Tween<double>(begin: -0.07, end: 0.07).animate(
      CurvedAnimation(parent: _primaryController, curve: Curves.easeInOut),
    );
    _primaryController.repeat(reverse: true);

    _secondaryController = AnimationController(
      duration: const Duration(milliseconds: 2000), // 1100 → 2000 (daha az GPU)
      vsync: this,
    );
    _secondarySwing = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(parent: _secondaryController, curve: Curves.easeInOut),
    );
    _secondaryController.repeat(reverse: true);

    _breathController = AnimationController(
      duration: const Duration(milliseconds: 6000), // 4000 → 6000 (daha az GPU)
      vsync: this,
    );
    _breathAnimation = Tween<double>(begin: 1.0, end: 1.015).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
    _breathController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _primaryController.dispose();
    _secondaryController.dispose();
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _primarySwing,
        _secondarySwing,
        _breathAnimation,
      ]),
      builder: (context, child) {
        final totalRotation = _primarySwing.value + _secondarySwing.value;

        return Transform(
          alignment: Alignment.topCenter,
          transform: Matrix4.identity()
            ..rotateZ(totalRotation)
            ..scale(_breathAnimation.value),
          child: child,
        );
      },
      child: Image.network(
        widget.imageUrl,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.contain,
      ),
    );
  }
}
