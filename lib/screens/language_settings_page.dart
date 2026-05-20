import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/glass_back_button.dart';
import '../constants/colors.dart';
import '../theme/app_theme.dart';
import '../services/locale_controller.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';
import 'package:circle_flags/circle_flags.dart';

class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({super.key});

  @override
  State<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  String? _pendingLangCode;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeController.current;
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<LocaleController>();
    
    // Anlık tıklama hissiyatı için pending (bekleyen) dili kullan
    final currentAppLang = Localizations.localeOf(context).languageCode;
    final lang = _pendingLangCode ?? currentAppLang;

    final options = [
      {'locale': const Locale('tr'), 'label': 'Türkçe', 'flag': 'tr'},
      {'locale': const Locale('en'), 'label': 'English', 'flag': 'gb'},
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(gradient: palette.bgGradient),
        child: Stack(
          children: [
            // Abstract background matching Notification Settings / Profile
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFF6B6B).withOpacity(0.5),
                      const Color(0xFFFF6B6B).withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -40,
              right: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF7B61FF).withOpacity(0.4),
                      const Color(0xFF5A8BFF).withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(color: Colors.transparent),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      children: [
                        const GlassBackButton(),
                        const SizedBox(width: 10),
                        Text(
                          l10n.selectLanguage,
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      l10n.languageSettingsSubtitle,
                      style: TextStyle(
                        color: AppColors.textWhite.withOpacity(0.5),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options[index];
                        final optLocale = option['locale'] as Locale;
                        final optLabel = option['label'] as String;
                        final optFlag = option['flag'] as String;
                        
                        final bool isReallySelected = lang == optLocale.languageCode;

                        return GestureDetector(
                          onTap: () async {
                            if (currentAppLang == optLocale.languageCode || _pendingLangCode == optLocale.languageCode) return;
                            
                            HapticFeedback.lightImpact();
                            setState(() {
                              _pendingLangCode = optLocale.languageCode;
                              _isProcessing = true;
                            });
                            
                            // Kullanıcı sürecin farkına varsın diye 1000ms (1 saniye) yükleme efekti süresi
                            await Future.delayed(const Duration(milliseconds: 1000));
                            
                            if (mounted) {
                              await controller.setLocale(optLocale);
                              if (mounted) {
                                setState(() {
                                  _pendingLangCode = null;
                                  _isProcessing = false;
                                });
                              }
                            }
                          },
                          child: AnimatedScale(
                            scale: isReallySelected ? 1.025 : 1.0,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutCubic,
                              margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isReallySelected 
                                ? const Color(0xFF8B5CF6).withOpacity(0.12) // Subtle purple tint
                                : Colors.white.withOpacity(0.03), // Very dark/transparent unselected
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: isReallySelected 
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF8B5CF6).withOpacity(0.25), 
                                      blurRadius: 32,
                                      spreadRadius: 4,
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                            ),
                            child: Row(
                              children: [
                                // Glowing Flag Container
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      // Flag's own dominant color glow
                                      BoxShadow(
                                        color: optFlag == 'tr' 
                                          ? const Color(0xFFE63946).withOpacity(0.5) 
                                          : const Color(0xFF4361EE).withOpacity(0.5),
                                        blurRadius: 16,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      ClipOval(
                                        child: CircleFlag(
                                          optFlag,
                                          size: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  optLabel,
                                  style: TextStyle(
                                    color: isReallySelected ? AppColors.textWhite : AppColors.textWhite.withOpacity(0.7),
                                    fontSize: 16,
                                    fontWeight: isReallySelected ? FontWeight.w600 : FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const Spacer(),
                                // Glowing Checkmark
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isReallySelected ? const Color(0xFF9D4EDD) : Colors.transparent,
                                    border: Border.all(
                                      color: isReallySelected ? const Color(0xFF9D4EDD) : Colors.white.withOpacity(0.2),
                                      width: 1.5,
                                    ),
                                    boxShadow: isReallySelected 
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF9D4EDD).withOpacity(0.6),
                                            blurRadius: 12,
                                            spreadRadius: 2,
                                          )
                                        ]
                                      : [],
                                  ),
                                  child: isReallySelected 
                                    ? Center(
                                        child: (_isProcessing && _pendingLangCode == optLocale.languageCode)
                                            ? const SizedBox(
                                                width: 12,
                                                height: 12,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 1.5,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                ),
                                              )
                                            : const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                                      )
                                    : null,
                                ),
                              ],
                            ),
                          ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
