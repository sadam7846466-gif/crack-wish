import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/sound_service.dart';

class CosmicToast {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    required String reward,
    IconData? icon,
    String? imagePath, // Özel resim ikonları için (örneğin kurabiye)
    Color iconColor = const Color(0xFFE9D5FF),
    Color rewardColor = const Color(0xFFD8B4FE),
    Duration duration = const Duration(seconds: 4),
  }) {
    // Ses ve titreşim efektini tetikle
    SoundService().playCosmicToast();

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    // Toast'u ekrandan yavaşça silmek için bir controller kullanacağız
    final AnimationController controller = AnimationController(
      vsync: overlay,
      duration: const Duration(milliseconds: 600), // Yavaş açılıp kapanma süresi
    );

    // Aşağıdan yukarıya yavaşça süzülme ve Fade-in animasyonu
    final Animation<double> fadeAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    );
    
    final Animation<Offset> slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    ));

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: bottomPadding + 8, // Menü barın hemen üstü
        left: 24,
        right: 24,
        child: Material(
          color: Colors.transparent,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05), // Daha transparan cam
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15), // İnce cam sınırı
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: const Color(0xFFC084FC).withOpacity(0.1),
                          blurRadius: 30,
                          spreadRadius: -5,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // İkon Çerçevesi
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC084FC).withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFC084FC).withOpacity(0.3), width: 1),
                          ),
                          child: imagePath != null
                              ? Image.asset(imagePath, width: 24, height: 24)
                              : Icon(icon ?? Icons.star_rounded, color: iconColor, size: 24),
                        ),
                        const SizedBox(width: 14),
                        // Metinler
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white, 
                                  fontWeight: FontWeight.w700, 
                                  fontSize: 14,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                message,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6), 
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Ödül Miktarı
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC084FC).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            reward, 
                            style: TextStyle(
                              color: rewardColor, 
                              fontWeight: FontWeight.w800, 
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    controller.forward();

    // Belirlenen süre sonra yavaşça kaybol
    Future.delayed(duration, () async {
      await controller.reverse();
      overlayEntry.remove();
      controller.dispose();
    });
  }
}
