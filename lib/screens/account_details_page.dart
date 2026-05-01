import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/glass_back_button.dart';
import '../widgets/fade_page_route.dart';
import '../constants/colors.dart';
import '../theme/app_theme.dart';
import 'onboarding_page.dart';

class AccountDetailsPage extends StatefulWidget {
  final String userName;

  const AccountDetailsPage({super.key, required this.userName});

  @override
  State<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {

  void _deleteAccount() {
    final lang = Localizations.localeOf(context).languageCode;
    HapticFeedback.heavyImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              height: 310,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 0.5,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF2D55).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_forever_rounded,
                      color: Color(0xFFFF2D55),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    lang == 'tr' ? 'Hesabı Sil' : 'Delete Account',
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: Text(
                      lang == 'tr'
                          ? 'Tüm verilerin kalıcı olarak silinecek.\nBu işlem geri alınamaz.'
                          : 'All your data will be deleted.\nThis action cannot be undone.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textWhite.withOpacity(0.5),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                lang == 'tr' ? 'Vazgeç' : 'Cancel',
                                style: const TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            Navigator.pop(ctx);
                            try {
                              await Supabase.instance.client.rpc('delete_user');
                              await Supabase.instance.client.auth.signOut();
                            } catch (e) {
                              debugPrint("Delete Account Error: $e");
                            }
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.clear();
                            if (mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      const OnboardingPage(),
                                  transitionsBuilder: (_, anim, __, child) =>
                                      FadeTransition(
                                        opacity: anim,
                                        child: child,
                                      ),
                                  transitionDuration: const Duration(
                                    milliseconds: 600,
                                  ),
                                ),
                                (route) => false,
                              );
                            }
                          },
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF2D55),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                lang == 'tr' ? 'Hesabı Sil' : 'Delete',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeController.current;
    final lang = Localizations.localeOf(context).languageCode;
    final user = Supabase.instance.client.auth.currentUser;
    final String fullEmail = user?.email ?? '';
    final String provider = user?.appMetadata['provider'] ?? 'E-posta';

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
                          lang == 'tr' ? 'Hesap Detayları' : 'Account Details',
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
                      lang == 'tr' ? 'Kişisel bilgilerin ve hesap yönetimin' : 'Personal info and account management',
                      style: TextStyle(
                        color: AppColors.textWhite.withOpacity(0.5),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                      child: Column(
                        children: [
                          _AccountDetailCard(
                            icon: Icons.person_rounded,
                            title: lang == 'tr' ? 'Kullanıcı Adı' : 'Username',
                            value: widget.userName,
                          ),
                          const SizedBox(height: 12),
                          _AccountDetailCard(
                            icon: Icons.email_rounded,
                            title: lang == 'tr' ? 'Bağlı E-posta' : 'Linked Email',
                            value: fullEmail.isEmpty ? '-' : fullEmail,
                          ),
                          const SizedBox(height: 12),
                          _AccountDetailCard(
                            icon: Icons.security_rounded,
                            title: lang == 'tr' ? 'Giriş Yöntemi' : 'Sign-in Method',
                            value: provider.toUpperCase(),
                          ),
                          
                          const SizedBox(height: 48),

                          GestureDetector(
                            onTap: _deleteAccount,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF2D55).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFFF2D55).withOpacity(0.25),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.delete_forever_rounded, color: Color(0xFFFF2D55), size: 22),
                                  const SizedBox(width: 8),
                                  Text(
                                    lang == 'tr' ? 'Hesabı Kalıcı Olarak Sil' : 'Delete Account Permanently',
                                    style: const TextStyle(
                                      color: Color(0xFFFF2D55),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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

class _AccountDetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _AccountDetailCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Icon(
                icon,
                color: Colors.white.withOpacity(0.6),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textWhite.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    color: AppColors.textWhite.withOpacity(0.95),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
