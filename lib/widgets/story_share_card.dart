import 'package:flutter/material.dart';
import '../models/fortune.dart';

class StoryShareCard extends StatelessWidget {
  final Fortune fortune;
  final String cookieEmoji;
  final String cookieName;
  
  const StoryShareCard({
    Key? key,
    required this.fortune,
    required this.cookieEmoji,
    required this.cookieName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1080,
      height: 1920,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
      ),
    );
  }
}
