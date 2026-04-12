import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_service.dart';
import '../services/ad_service.dart';
import '../screens/premium_paywall_page.dart';

class ZodiacAccessService {
  static const String _kWesternFreeDate = 'zodiac_western_free_date';
  static const String _kWesternAdCredits = 'zodiac_western_ad_credits';
  static const Color _gold = Color(0xFFFFD060);

  // Batı Astrolojisi için giriş kontrolü
  static Future<void> handleWesternAccess(BuildContext context, VoidCallback onUnlock) async {
    final prefs = await SharedPreferences.getInstance();
    final bool isPremiumUser = prefs.getBool('is_premium_test_mode') ?? false;
    final today = DateTime.now().toIso8601String().split('T')[0];

    // Elite isen
    if (isPremiumUser) {
      final lastEliteAccess = prefs.getString('zodiac_elite_first_access_west_$today') ?? '';
      if (lastEliteAccess != today) {
        await prefs.setString('zodiac_elite_first_access_west_$today', today);
        await StorageService.addPendingAura('zodiac', 1);
      }
      onUnlock();
      return;
    }

    // Ücretsiz günlük hak kontrolü
    final savedDate = prefs.getString(_kWesternFreeDate) ?? '';
    bool westernDailyFreeUsed = (savedDate == today);
    int westernAdCredits = prefs.getInt(_kWesternAdCredits) ?? 0;

    if (!westernDailyFreeUsed) {
      await prefs.setString(_kWesternFreeDate, today);
      await StorageService.addPendingAura('zodiac', 1);
      onUnlock();
      return;
    }

    if (westernAdCredits > 0) {
      westernAdCredits -= 1;
      await prefs.setInt(_kWesternAdCredits, westernAdCredits);
      await StorageService.addPendingAura('zodiac', 1);
      onUnlock();
      return;
    }

    if (!context.mounted) return;
    _showWesternAdPanel(context, onUnlock);
  }

  // Asya/Maya Astrolojisi için giriş kontrolü
  static Future<void> handlePremiumAccess(BuildContext context, String moduleKey, VoidCallback onUnlock) async {
    final prefs = await SharedPreferences.getInstance();
    final bool isPremiumUser = prefs.getBool('is_premium_test_mode') ?? false;
    await StorageService.getSoulStones(); // Günlük taşları garantiye al
    final today = DateTime.now().toIso8601String().split('T')[0];
    final dailyKey = 'zodiac_elite_unlocked_${moduleKey}_$today';

    if (isPremiumUser) {
      final alreadyUnlocked = prefs.getBool(dailyKey) ?? false;
      if (alreadyUnlocked) {
        onUnlock();
        return;
      }
      bool success = await StorageService.deductSoulStones(1);
      if (success) {
        await prefs.setBool(dailyKey, true);
        onUnlock();
        return;
      }
    }

    if (!context.mounted) return;
    _showPremiumGatePanel(context, isPremiumUser, onUnlock);
  }

  static void _showWesternAdPanel(BuildContext context, VoidCallback onUnlock) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible: true,
      barrierLabel: 'WesternAd',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (dialogCtx, anim1, anim2) {
        final panelW = MediaQuery.of(dialogCtx).size.width * 0.85;
        return Center(
          child: SizedBox(
            width: panelW,
            child: Material(
              type: MaterialType.transparency,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.25), width: 0.5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.flare_outlined, color: _gold, size: 48),
                        const SizedBox(height: 12),
                        const Text(
                          'Günlük Ücretsiz Hakkın Doldu',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Batı Astrolojisi\'ne tekrar girmek için kısa bir reklam izleyebilirsin.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, height: 1.4),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.08),
                                  elevation: 0,
                                  minimumSize: const Size(double.infinity, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(color: _gold.withOpacity(0.3)),
                                  ),
                                ),
                                onPressed: () {
                                  AdService().showRewardedAd(() async {
                                    final prefs = await SharedPreferences.getInstance();
                                    int credits = prefs.getInt(_kWesternAdCredits) ?? 0;
                                    await prefs.setInt(_kWesternAdCredits, credits + 1);
                                    if (dialogCtx.mounted) {
                                      Navigator.pop(dialogCtx);
                                      // Zincirleme kontrolü yeniden başlat
                                      handleWesternAccess(context, onUnlock);
                                    }
                                  }, () {});
                                },
                                icon: Icon(Icons.play_circle_filled_rounded, color: _gold.withOpacity(0.8), size: 18),
                                label: Text(
                                  'Reklam İzle',
                                  style: TextStyle(color: _gold.withOpacity(0.9), fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF22D3EE).withOpacity(0.15),
                                  elevation: 0,
                                  minimumSize: const Size(double.infinity, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(color: const Color(0xFF22D3EE).withOpacity(0.4)),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(dialogCtx);
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumPaywallPage()));
                                },
                                icon: const Icon(Icons.workspace_premium, color: Color(0xFF22D3EE), size: 18),
                                label: const Text(
                                  'Elite Al',
                                  style: TextStyle(color: Color(0xFF22D3EE), fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(opacity: anim1, child: ScaleTransition(scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack), child: child));
      },
    );
  }

  static void _showPremiumGatePanel(BuildContext context, bool isPremiumUser, VoidCallback onUnlock) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible: true,
      barrierLabel: 'PremiumAccess',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (dialogCtx, anim1, anim2) {
        final panelW = MediaQuery.of(dialogCtx).size.width * 0.85;
        return Center(
          child: SizedBox(
            width: panelW,
            child: Material(
              type: MaterialType.transparency,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.25), width: 0.5),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40, spreadRadius: -5),
                    ],
                    ),
                    child: ValueListenableBuilder<int>(
                      valueListenable: StorageService.soulStonesNotifier,
                      builder: (context, soulStones, _) {
                        final hasEnough = soulStones >= 1;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.diamond_rounded, color: hasEnough ? const Color(0xFF22D3EE) : Colors.white.withOpacity(0.3), size: 48),
                            const SizedBox(height: 12),
                            const Text('Kozmik Bilgelik Kapısı', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF22D3EE).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF22D3EE).withOpacity(0.3), width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.diamond_outlined, size: 14, color: Color(0xFF22D3EE)),
                                  const SizedBox(width: 6),
                                  Text("$soulStones Ruh Taşın var", style: const TextStyle(color: Color(0xFF22D3EE), fontSize: 13, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _premiumInfoRow(Icons.auto_awesome, "Burç derinlikleri için giriş izni", true),
                            const SizedBox(height: 10),
                            _premiumInfoRow(Icons.diamond_outlined, "Her astroloji haritası 1 Ruh Taşı harcar", hasEnough),
                            const SizedBox(height: 10),
                            _premiumInfoRow(Icons.workspace_premium, isPremiumUser ? "Elite: Günde 1 Ruh Taşı ile sınırsız giriş" : "Elite ile günde 1 Ruh Taşı yeterli", isPremiumUser),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: hasEnough ? const Color(0xFF22D3EE).withOpacity(0.15) : Colors.white.withOpacity(0.05),
                                      elevation: 0,
                                      minimumSize: const Size(double.infinity, 48),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: hasEnough ? const Color(0xFF22D3EE).withOpacity(0.4) : Colors.white.withOpacity(0.1))),
                                    ),
                                    onPressed: hasEnough ? () async {
                                      final success = await StorageService.deductSoulStones(1);
                                      if (success) {
                                        await StorageService.addPendingAura('zodiac', 1);
                                        if (dialogCtx.mounted) {
                                          Navigator.pop(dialogCtx);
                                          // Yeniden kontrol eder ve kilidi açar
                                          onUnlock();
                                        }
                                      }
                                    } : null,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text("1 Ruh Taşı", style: TextStyle(color: hasEnough ? const Color(0xFF22D3EE) : Colors.white.withOpacity(0.3), fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF22D3EE).withOpacity(0.15),
                                      elevation: 0,
                                      minimumSize: const Size(double.infinity, 48),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: const Color(0xFF22D3EE).withOpacity(0.4))),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(dialogCtx);
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumPaywallPage()));
                                    },
                                    icon: const Icon(Icons.workspace_premium, color: Color(0xFF22D3EE), size: 18),
                                    label: const FittedBox(fit: BoxFit.scaleDown, child: Text("Elite Al", style: TextStyle(color: Color(0xFF22D3EE), fontWeight: FontWeight.bold))),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(opacity: anim1, child: ScaleTransition(scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack), child: child));
      },
    );
  }

  static Widget _premiumInfoRow(IconData icon, String text, bool isActive) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(shape: BoxShape.circle, color: isActive ? const Color(0xFF22D3EE).withOpacity(0.12) : Colors.white.withOpacity(0.05)),
          child: Icon(icon, size: 16, color: isActive ? const Color(0xFF22D3EE).withOpacity(0.8) : Colors.white.withOpacity(0.3)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: TextStyle(color: isActive ? Colors.white.withOpacity(0.75) : Colors.white.withOpacity(0.4), fontSize: 13, height: 1.3))),
      ],
    );
  }
}
