import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PaperPlaneWrapper extends StatefulWidget {
  const PaperPlaneWrapper({super.key});

  @override
  State<PaperPlaneWrapper> createState() => _PaperPlaneWrapperState();
}

class _PaperPlaneWrapperState extends State<PaperPlaneWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _playAnimation() {
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kağıt Animasyonu")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/fortune_paper.json',
              controller: _controller,
              onLoaded: (composition) {
                _controller.duration = composition.duration;
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _playAnimation,
              icon: const Icon(Icons.send),
              label: const Text("Animasyonu Başlat"),
            ),
          ],
        ),
      ),
    );
  }
}
