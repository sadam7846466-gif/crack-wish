import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/glass_back_button.dart';
import '../constants/colors.dart';
import '../theme/app_theme.dart';
import '../services/locale_controller.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeController.current;
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<LocaleController>();
    final lang = Localizations.localeOf(context).languageCode;

    final options = [
      {'locale': const Locale('tr'), 'label': 'Türkçe'},
      {'locale': const Locale('en'), 'label': 'English'},
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
                      lang == 'tr' ? 'Uygulama dilini belirle' : 'Choose app language',
                      style: TextStyle(
                        color: AppColors.textWhite.withOpacity(0.5),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options[index];
                        final optLocale = option['locale'] as Locale;
                        final optLabel = option['label'] as String;
                        
                        // Either controller locale matches or both are null (default)
                        final bool isSelected = (controller.locale?.languageCode == optLocale.languageCode) || 
                            (controller.locale == null && optLocale.languageCode == 'en'); 
                            // assuming default is english if null, or just rely on controller setting.
                            // Actually better to just check languageCode against current lang
                        
                        final bool isReallySelected = lang == optLocale.languageCode;

                        return GestureDetector(
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            await controller.setLocale(optLocale);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            decoration: BoxDecoration(
                              color: isReallySelected ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isReallySelected ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.08),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  optLabel,
                                  style: TextStyle(
                                    color: isReallySelected ? AppColors.textWhite : AppColors.textWhite.withOpacity(0.6),
                                    fontSize: 16,
                                    fontWeight: isReallySelected ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  isReallySelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                                  color: isReallySelected ? Colors.white : Colors.white.withOpacity(0.3),
                                ),
                              ],
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
