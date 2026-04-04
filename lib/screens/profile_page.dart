import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';
import '../constants/colors.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/fade_page_route.dart';
import '../widgets/glass_back_button.dart';
import 'premium_paywall_page.dart';
import 'notification_settings_page.dart';
import 'home_page.dart';
import 'collection_page.dart';
import '../services/locale_controller.dart';
import '../services/storage_service.dart';
import '../models/cookie_card.dart';
import '../services/user_stats_service.dart';

class ProfilePage extends StatefulWidget {
  final bool showBottomNav;
  final ValueChanged<int>? onNavTapOverride;

  const ProfilePage({
    super.key,
    this.showBottomNav = true,
    this.onNavTapOverride,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static final _mottledPainter = _MottledPainter();
  int _currentNavIndex = 2;

  // ── Gerçek kullanıcı verileri ──
  String _userName = '';
  String _userAvatar = 'assets/images/owl.webp';
  int _totalCookies = 0;
  int _totalTarots = 0;
  int _totalDreams = 0;
  int _streakDays = 0;
  int _soulStones = 3; // Krediler için state
  int _spentAura = 0; // Ruh Taşı çeviriminde harcanmış Aura
  bool _isLoading = true;
  bool _isPremiumUser = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final snapshot = await StorageService.getUserSnapshot();
    final streak = await StorageService.getStreakDays();
    final avatar = await StorageService.getAvatar() ?? 'assets/images/owl.webp';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('spent_aura', 0); // TEST İÇİN SIFIRLADIK
    await prefs.setInt('soul_stones', 0); // RUH TAŞI SIFIRLANDI
    final spentAura = await StorageService.getSpentAura();
    final tarotCount = await UserStatsService.getTotalTarotReadings();
    if (!mounted) return;
    setState(() {
      _userName = (snapshot['userName'] as String?) ?? '';
      _totalCookies = 1000; // TEST İÇİN 1000 AURA GEÇİCİ
      _totalTarots = tarotCount;
      _totalDreams = (snapshot['totalDreams'] as int?) ?? 0;
      _soulStones = 0; // LOCAL STATE'DE DE SIFIRLANDI
      _spentAura = 0; // TEST İÇİN GEÇİCİ
      _streakDays = streak;
      _userAvatar = avatar;
      _isLoading = false;
      _isPremiumUser = prefs.getBool('is_premium_test_mode') ?? false;
    });
  }

  // ── Kullanıcı seviyesi hesapla (Aura bazlı) ──
  // Emoji yerine Material Icon kullanıyoruz — her cihazda çalışır.
  ({IconData icon, Color color, String title}) _getUserLevel(String lang) {
    final int aura = (_totalCookies * 1) + (_totalTarots * 2) + (_totalDreams * 3) + (_streakDays * 5);
    
    if (lang == 'tr') {
      if (aura < 100) return (icon: Icons.eco_rounded, color: const Color(0xFF4ADE80), title: 'Yeni Başlayan');
      if (aura < 500) return (icon: Icons.local_fire_department_rounded, color: const Color(0xFFFBBF24), title: 'Acemi Kahin');
      if (aura < 1500) return (icon: Icons.auto_awesome_rounded, color: const Color(0xFFA78BFA), title: 'Çırak Kahin');
      if (aura < 5000) return (icon: Icons.visibility_rounded, color: const Color(0xFF38BDF8), title: 'Bilge Kahin');
      if (aura < 10000) return (icon: Icons.bolt_rounded, color: const Color(0xFFF97316), title: 'Usta Kahin');
      return (icon: Icons.workspace_premium_rounded, color: const Color(0xFFFFD700), title: 'Yüce Başbüyücü');
    } else {
      if (aura < 100) return (icon: Icons.eco_rounded, color: const Color(0xFF4ADE80), title: 'Newcomer');
      if (aura < 500) return (icon: Icons.local_fire_department_rounded, color: const Color(0xFFFBBF24), title: 'Novice Seer');
      if (aura < 1500) return (icon: Icons.auto_awesome_rounded, color: const Color(0xFFA78BFA), title: 'Apprentice Seer');
      if (aura < 5000) return (icon: Icons.visibility_rounded, color: const Color(0xFF38BDF8), title: 'Wise Seer');
      if (aura < 10000) return (icon: Icons.bolt_rounded, color: const Color(0xFFF97316), title: 'Master Seer');
      return (icon: Icons.workspace_premium_rounded, color: const Color(0xFFFFD700), title: 'Grandmaster');
    }
  }

  // ── İsim & Profil Düzenleme ──
  void _editProfile() {
    final controller = TextEditingController(text: _userName);
    final lang = Localizations.localeOf(context).languageCode;
    String selectedAvatar = _userAvatar;

    final avatars = [
      'assets/images/owl.webp',
      'assets/images/cookies/sakura_bloom.webp',
      'assets/images/cookies/midnight_mosaic.webp',
      'assets/images/cookies/dragon_phoenix.webp',
      'assets/images/ruyabulut.webp',
      'assets/images/NAZAR.webp',
      'assets/images/motiveYILDIZ.webp',
      'assets/images/cookies/pearl_lace.webp',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1F2A),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 40,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 24),
                    Text(
                      lang == 'tr' ? 'Profilini Düzenle' : 'Edit Profile',
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      lang == 'tr'
                          ? 'Sihirli avatarını seç ve adını belirle.'
                          : 'Choose your magical avatar and set your name.',
                      style: TextStyle(
                        color: AppColors.textWhite.withOpacity(0.45),
                        fontSize: 14,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 28),
                    
                    // Avatar Seçimi
                    SizedBox(
                      height: 86,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: avatars.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final avatar = avatars[index];
                          final isSelected = avatar == selectedAvatar;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setModalState(() => selectedAvatar = avatar);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.only(right: 16),
                              width: 86,
                              height: 86,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? AppColors.primaryOrange : Colors.transparent,
                                  width: 2.5,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primaryOrange.withOpacity(0.25),
                                          blurRadius: 16,
                                          spreadRadius: 2,
                                        )
                                      ]
                                    : null,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.12),
                                    Colors.white.withOpacity(0.04),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Image.asset(
                                  avatar,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),

                    // İsim
                    TextField(
                      controller: controller,
                      autofocus: false,
                      maxLength: 20,
                      textCapitalization: TextCapitalization.words,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: lang == 'tr' ? 'Kahinin adı...' : 'Seer\'s name...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.06),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppColors.primaryOrange,
                            width: 1.5,
                          ),
                        ),
                        counterStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Kaydet
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () async {
                          HapticFeedback.mediumImpact();
                          final name = controller.text.trim();
                          
                          if (name.isNotEmpty) await StorageService.setUserName(name);
                          await StorageService.setAvatar(selectedAvatar);

                          if (mounted) {
                            setState(() {
                              if (name.isNotEmpty) _userName = name;
                              _userAvatar = selectedAvatar;
                            });
                          }
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          lang == 'tr' ? 'Kaydet' : 'Save Profile',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      useSafeArea: true,
    );
  }

  // ── Uygulamayı paylaş ──
  void _shareApp() {
    HapticFeedback.lightImpact();
    final lang = Localizations.localeOf(context).languageCode;
    final text = lang == 'tr'
        ? 'Crack&Wish ile şansını keşfet! •✨\nKurabiye kır, tarot aç, rüya yorumla.\n\nhttps://crackandwish.com'
        : 'Discover your fortune with Crack&Wish! •✨\nCrack cookies, read tarot, interpret dreams.\n\nhttps://crackandwish.com';
    final box = context.findRenderObject() as RenderBox?;
    if (box != null) {
      Share.share(
        text,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
      );
    } else {
      Share.share(text);
    }
  }

  // ── Uygulamayı değerlendir ──
  void _rateApp() {
    HapticFeedback.lightImpact();
    final lang = Localizations.localeOf(context).languageCode;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('•', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                lang == 'tr'
                    ? 'Uygulama yayınlandığında değerlendirebilirsiniz!'
                    : 'You can rate the app once it\'s published!',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Profil ayarları ──
  void _openProfileSettings() async {
    final lang = Localizations.localeOf(context).languageCode;
    final savedBirthDate = await StorageService.getBirthDate();

    if (!mounted) return;

    DateTime? currentBirthDate = savedBirthDate;

    String formatDate(DateTime? d) {
      if (d == null) return lang == 'tr' ? 'Ayarlanmadı' : 'Not set';
      return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
    }

    String getZodiacFromDate(DateTime? d) {
      if (d == null) return lang == 'tr' ? 'Otomatik' : 'Automatic';
      final month = d.month;
      final day = d.day;
      final signs = lang == 'tr'
          ? ['Oğlak', 'Kova', 'Balık', 'Koç', 'Boğa', 'İkizler', 'Yengeç', 'Aslan', 'Başak', 'Terazi', 'Akrep', 'Yay', 'Oğlak']
          : ['Capricorn', 'Aquarius', 'Pisces', 'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 'Libra', 'Scorpio', 'Sagittarius', 'Capricorn'];
      const cutoffs = [20, 19, 20, 20, 21, 21, 23, 23, 23, 23, 22, 22];
      return day < cutoffs[month - 1] ? signs[month - 1] : signs[month];
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F1F2A),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 20),
                  Text(
                    lang == 'tr' ? 'Profil Ayarları' : 'Profile Settings',
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // İsim
                  _SettingsRow(
                    icon: Icons.person_rounded,
                    label: lang == 'tr' ? 'İsim' : 'Name',
                    value: _userName.isNotEmpty
                        ? _userName
                        : (lang == 'tr' ? 'Ayarlanmadı' : 'Not set'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _editProfile();
                    },
                  ),
                  const SizedBox(height: 12),
                  // Doğum Tarihi
                  _SettingsRow(
                    icon: Icons.cake_rounded,
                    label: lang == 'tr' ? 'Doğum Tarihi' : 'Birth Date',
                    value: formatDate(currentBirthDate),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: currentBirthDate ?? DateTime(2000, 1, 1),
                        firstDate: DateTime(1940),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: AppColors.primaryOrange,
                                surface: Color(0xFF0F1F2A),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        await StorageService.setBirthDate(picked);
                        final zodiac = getZodiacFromDate(picked);
                        await StorageService.setZodiacSign(zodiac);
                        setModalState(() => currentBirthDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  // Burç
                  _SettingsRow(
                    icon: Icons.stars_rounded,
                    label: lang == 'tr' ? 'Burcun' : 'Zodiac Sign',
                    value: getZodiacFromDate(currentBirthDate),
                    onTap: () {
                      if (currentBirthDate == null) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text(
                              lang == 'tr'
                                  ? 'Doğum tarihini ayarla, burcun otomatik belirlensin!'
                                  : 'Set your birth date to auto-detect your zodiac sign!',
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                            backgroundColor: const Color(0xFF1A1A2E),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Yardım merkezi ──
  void _openHelpCenter() {
    final lang = Localizations.localeOf(context).languageCode;
    _showLegalSheet(
      title: lang == 'tr' ? 'Yardım Merkezi' : 'Help Center',
      content: lang == 'tr'
          ? '''Sıkça Sorulan Sorular

• Kurabiye nasıl kırılır?
Ana sayfadaki kurabiyeye dokun ve kırmak için kaydır. Her gün yeni bir kurabiye seni bekliyor.

• Tarot falı nasıl bakılır?
Ana sayfadan Tarot kartına dokun. 3 kart seç ve günlük mesajını oku.

• Rüya yorumu nasıl yapılır?
Rüya sayfasına git, rüyanı yaz ve AI destekli yorumunu al.

• Burç yorumum nerede?
Ana sayfadan Burç kartına dokun. Batı, Çin ve Maya burç yorumlarını keşfet.

• Gün serisi nedir?
Her gün uygulamayı kullandığında serin artar. Bir gün atlarsan seri sıfırlanır.

• Verilerim güvende mi?
Evet! Tüm verilerin cihazında yerel olarak saklanır, hiçbir yere gönderilmez.

• İletişim
info@crackandwish.com'''
          : '''Frequently Asked Questions

• How to crack a cookie?
Tap the cookie on the home page and swipe to crack it. A new cookie awaits you every day.

• How to read tarot?
Tap the Tarot card on the home page. Select 3 cards and read your daily message.

• How to interpret dreams?
Go to the Dream page, write your dream, and get an AI-powered interpretation.

• Where is my horoscope?
Tap the Zodiac card on the home page. Discover Western, Chinese, and Mayan horoscopes.

• What is a day streak?
Your streak increases every day you use the app. Miss a day and it resets.

• Is my data safe?
Yes! All your data is stored locally on your device and is never sent anywhere.

• Contact
info@crackandwish.com''',
    );
  }

  // ── Çıkış yap ──
  void _signOut() {
    final lang = Localizations.localeOf(context).languageCode;
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F1F2A),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
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
              const SizedBox(height: 24),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4D4D).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFFF4D4D),
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                lang == 'tr' ? 'Çıkış Yap' : 'Sign Out',
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                lang == 'tr'
                    ? 'Hesabından çıkış yapmak istediğine emin misin?'
                    : 'Are you sure you want to sign out?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textWhite.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(14),
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
                      onTap: () {
                        Navigator.pop(ctx);
                        // TODO: Auth entegrasyonunda gerçek sign-out eklenecek
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4D4D),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            lang == 'tr' ? 'Çıkış Yap' : 'Sign Out',
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
        );
      },
    );
  }

  // ── Gizlilik Politikası ──
  void _openPrivacyPolicy() {
    final lang = Localizations.localeOf(context).languageCode;
    _showLegalSheet(
      title: lang == 'tr' ? 'Gizlilik Politikası' : 'Privacy Policy',
      content: lang == 'tr'
          ? '''Crack&Wish Gizlilik Politikası
Son güncelleme: Nisan 2026

1. Toplanan Veriler
Crack&Wish, kullanıcı verilerini cihazınızda yerel olarak saklar. Kurabiye geçmişi, rüya kayıtları, tarot okumaları ve kullanıcı tercihleri yalnızca cihazınızda tutulur.

2. Veri Paylaşımı
Kişisel verileriniz üçüncü taraflarla paylaşılmaz. Rüya analizi için anonim olarak AI servislerine metin gönderilir; bu metinler saklanmaz.

3. Çerezler ve İzleme
Uygulama çerez kullanmaz ve kullanıcı davranışlarını izlemez.

4. Veri Güvenliği
Verileriniz cihazınızın yerel depolama alanında şifreli olarak saklanır.

5. İletişim
Sorularınız için: info@crackandwish.com'''
          : '''Crack&Wish Privacy Policy
Last updated: April 2026

1. Data Collection
Crack&Wish stores user data locally on your device. Cookie history, dream entries, tarot readings, and preferences are kept only on your device.

2. Data Sharing
Your personal data is not shared with third parties. For dream analysis, anonymous text is sent to AI services; these texts are not stored.

3. Cookies and Tracking
The app does not use cookies and does not track user behavior.

4. Data Security
Your data is stored encrypted in your device's local storage.

5. Contact
For questions: info@crackandwish.com''',
    );
  }

  // ── Kullanım Koşulları ──
  void _openTermsOfService() {
    final lang = Localizations.localeOf(context).languageCode;
    _showLegalSheet(
      title: lang == 'tr' ? 'Kullanım Koşulları' : 'Terms of Service',
      content: lang == 'tr'
          ? '''Crack&Wish Kullanım Koşulları
Son güncelleme: Nisan 2026

1. Kabul
Uygulamayı kullanarak bu koşulları kabul etmiş olursunuz.

2. Hizmet Tanımı
Crack&Wish bir eğlence uygulamasıdır. Kurabiye falı, tarot okumaları ve rüya yorumları tamamen eğlence amaçlıdır ve profesyonel tavsiye niteliği taşımaz.

3. Kullanıcı Sorumlulukları
Uygulamayı yasal amaçlarla kullanmayı kabul edersiniz. İçerikleri ticari amaçla kopyalayamazsınız.

4. Fikri Mülkiyet
Uygulama içeriği, tasarımı ve kodu Crack&Wish'e aittir.

5. Sorumluluk Sınırı
Uygulama "olduğu gibi" sunulur. Fallar ve yorumlar eğlence amaçlıdır.

6. Değişiklikler
Bu koşullar önceden bildirimde bulunmaksızın güncellenebilir.

7. İletişim
info@crackandwish.com'''
          : '''Crack&Wish Terms of Service
Last updated: April 2026

1. Acceptance
By using the app, you accept these terms.

2. Service Description
Crack&Wish is an entertainment app. Fortune cookies, tarot readings, and dream interpretations are for entertainment only and do not constitute professional advice.

3. User Responsibilities
You agree to use the app for lawful purposes only. You may not copy content for commercial use.

4. Intellectual Property
App content, design, and code belong to Crack&Wish.

5. Limitation of Liability
The app is provided "as is." Fortunes and readings are for entertainment purposes.

6. Changes
These terms may be updated without prior notice.

7. Contact
info@crackandwish.com''',
    );
  }

  // ── Yasal metin gösterici (paylaşılan) ──
  void _showLegalSheet({required String title, required String content}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          builder: (_, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F1F2A),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  // Handle bar + title
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                    child: Column(
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
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(ctx),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: AppColors.textWhite,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Divider(
                          color: Colors.white.withOpacity(0.08),
                          height: 1,
                        ),
                      ],
                    ),
                  ),
                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                      child: Text(
                        content,
                        style: TextStyle(
                          color: AppColors.textWhite.withOpacity(0.75),
                          fontSize: 14,
                          height: 1.7,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Dil seçici (mevcut — çalışıyor) ──
  void _openLanguagePicker() {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.read<LocaleController>();
    final options = <_LanguageOption>[
      _LanguageOption(const Locale('tr'), l10n.turkish),
      _LanguageOption(const Locale('en'), l10n.english),
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        final palette = AppThemeController.current;
        return Container(
          decoration: BoxDecoration(
            color: palette.cardBackground,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(18)),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.selectLanguage,
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l10n.close,
                            style:
                                const TextStyle(color: AppColors.textWhite),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...options.map(
                    (opt) {
                      final bool isSelected =
                          controller.locale?.languageCode ==
                                  opt.locale?.languageCode &&
                              (controller.locale == null) ==
                                  (opt.locale == null);
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: AppColors.textWhite,
                        ),
                        title: Text(
                          opt.label,
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onTap: () async {
                          await controller.setLocale(opt.locale);
                          if (mounted) Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Alt navigasyon ──
  void _onNavTap(int index) {
    if (widget.onNavTapOverride != null) {
      widget.onNavTapOverride!(index);
      return;
    }
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        SwipeFadePageRoute(page: const HomePage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        SwipeFadePageRoute(page: const CollectionPage()),
      );
    } else {
      setState(() => _currentNavIndex = index);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = l10n.localeName;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: ValueListenableBuilder(
        valueListenable: AppThemeController.notifier,
        builder: (context, palette, _) {
          final localeCtrl = context.watch<LocaleController>();
          final languageValue = localeCtrl.getLabel(
            system: l10n.systemLanguage,
            turkish: l10n.turkish,
            english: l10n.english,
          );

          return Container(
            decoration: BoxDecoration(gradient: palette.bgGradient),
            child: Stack(
              children: [
                // Mottled overlay
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(painter: _mottledPainter),
                  ),
                ),
                SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── 1. HERO PROFIL KARTI (Arch-top glassmorphism + Stats) ──
                        Builder(
                          builder: (context) {
                            final level = _getUserLevel(lang);
                            return _BentoHeroCard(
                          userName: _userName,
                          userAvatar: _userAvatar,
                          levelTitle: level.title,
                          levelIcon: level.icon,
                          levelColor: level.color,
                          isLoading: _isLoading,
                          isPremium: _isPremiumUser,
                          onAvatarLongPress: () async {
                            final prefs = await SharedPreferences.getInstance();
                            setState(() => _isPremiumUser = !_isPremiumUser);
                            await prefs.setBool('is_premium_test_mode', _isPremiumUser);
                            HapticFeedback.heavyImpact();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('TEST MODU: Elite Üyelik ${_isPremiumUser ? "AKTİF 💎" : "KAPALI 🛑"}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: Colors.black87));
                            }
                          },
                          onEditTap: _editProfile,
                          profileTitle: l10n.profileUserTitle,
                          totalCookies: _totalCookies,
                          totalTarots: _totalTarots,
                          totalDreams: _totalDreams,
                          streakDays: _streakDays,
                          soulStones: _soulStones,
                          spentAura: _spentAura,
                          onConvertAura: () async {
                            final totalAura = (_totalCookies * 1) + (_totalTarots * 2) + (_totalDreams * 3) + (_streakDays * 5);
                            final success = await StorageService.convertAuraToSoulStone(currentTotalAura: totalAura);
                            if (success && mounted) {
                              setState(() {
                                _soulStones += 1;
                                _spentAura += 100;
                              });
                              HapticFeedback.heavyImpact();
                            }
                            return success;
                          },
                        );
                          },
                        ),
                        // Note: Bireysel bento stat kartları (2x2 grid) kaldırıldı,
                        // istatistikler artık _BentoHeroCard'ın içerisinde yuvarlak ikonlar olarak yer alıyor.
                        const SizedBox(height: 24),

                        // ── 3. PREMİUM BANNER ──
                        _BentoPremiumBanner(
                          lang: lang,
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                opaque: false,
                                transitionDuration: const Duration(milliseconds: 300),
                                pageBuilder: (context, animation, secondaryAnimation) => const PremiumPaywallPage(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return SlideTransition(
                                    position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
                                      CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                                    ),
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // ── 4. QUICK ACTIONS (2x2 Bento Grid) ──
                        _SectionLabel(lang == 'tr' ? 'Genel' : 'General'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _BentoActionTile(
                                icon: Icons.language_rounded,
                                iconColor: const Color(0xFF5A8BFF),
                                label: l10n.language,
                                subtitle: languageValue,
                                onTap: _openLanguagePicker,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _BentoActionTile(
                                icon: Icons.notifications_none_rounded,
                                iconColor: const Color(0xFFFF6B6B),
                                label: lang == 'tr' ? 'Bildirimler' : 'Notifications',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    SwipeFadePageRoute(
                                      page: const NotificationSettingsPage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _BentoActionTile(
                                icon: Icons.person_outline_rounded,
                                iconColor: const Color(0xFF7B61FF),
                                label: lang == 'tr' ? 'Hesap Ayarları' : 'Account Settings',
                                onTap: _openProfileSettings,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ── 5. PAYLAŞ & DESTEK (Compact Row) ──
                        _SectionLabel(
                          lang == 'tr' ? 'Paylaş & Destek' : 'Share & Support',
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _BentoActionTile(
                                icon: Icons.share_rounded,
                                iconColor: const Color(0xFF2DD4BF),
                                label: lang == 'tr' ? 'Paylaş' : 'Share',
                                onTap: _shareApp,
                                compact: true,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _BentoActionTile(
                                icon: Icons.star_border_rounded,
                                iconColor: const Color(0xFFFFD166),
                                label: lang == 'tr' ? 'Değerlendir' : 'Rate',
                                onTap: _rateApp,
                                compact: true,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _BentoActionTile(
                                icon: Icons.help_outline_rounded,
                                iconColor: const Color(0xFFC084FC),
                                label: lang == 'tr' ? 'Yardım' : 'Help',
                                onTap: _openHelpCenter,
                                compact: true,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ── 6. YASAL ──
                        _SectionLabel(lang == 'tr' ? 'Yasal' : 'Legal'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _BentoActionTile(
                                icon: Icons.shield_outlined,
                                iconColor: const Color(0xFF4CAF50),
                                label: lang == 'tr' ? 'Gizlilik & Koşullar' : 'Privacy & Terms',
                                onTap: _openPrivacyPolicy,
                                compact: true,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _BentoActionTile(
                                icon: Icons.logout_rounded,
                                iconColor: const Color(0xFFFF4D4D),
                                label: lang == 'tr' ? 'Çıkış' : 'Sign Out',
                                onTap: _signOut,
                                compact: true,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // ── 7. VERSİYON ──
                        Center(
                          child: Text(
                            'Crack&Wish  v1.0.0',
                            style: TextStyle(
                              color: AppColors.textWhite.withOpacity(0.2),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: Text(
                            lang == 'tr'
                                ? 'Sevgiyle yapıldı ✨'
                                : 'Made with love ✨',
                            style: TextStyle(
                              color: AppColors.textWhite.withOpacity(0.15),
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: widget.showBottomNav
          ? BottomNav(currentIndex: _currentNavIndex, onTap: _onNavTap)
          : null,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// BENTO HERO CARD (Arch-top Avatar + Name + Level)
// ═══════════════════════════════════════════════════════════════

class _BentoHeroCard extends StatelessWidget {
  final String userName;
  final String userAvatar;
  final String levelTitle;
  final IconData levelIcon;
  final Color levelColor;
  final bool isLoading;
  final bool isPremium;
  final VoidCallback onEditTap;
  final VoidCallback? onAvatarLongPress;
  final String profileTitle;
  final int totalCookies;
  final int totalTarots;
  final int totalDreams;
  final int streakDays;
  final int soulStones;
  final int spentAura;
  final Future<bool> Function() onConvertAura;

  const _BentoHeroCard({
    required this.userName,
    required this.userAvatar,
    required this.levelTitle,
    required this.levelIcon,
    required this.levelColor,
    required this.isLoading,
    required this.isPremium,
    required this.onEditTap,
    this.onAvatarLongPress,
    required this.profileTitle,
    required this.totalCookies,
    required this.totalTarots,
    required this.totalDreams,
    required this.streakDays,
    required this.soulStones,
    required this.spentAura,
    required this.onConvertAura,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = userName.isNotEmpty ? userName : profileTitle;
    
    // Aura Puanı (XP) Hesaplama Modeli
    final int auraPoints = (totalCookies * 1) + (totalTarots * 2) + (totalDreams * 3) + (streakDays * 5);
    final int availableAura = auraPoints - spentAura; // Kullanılabilir Aura (harcanan düşüldü)
    
    // Kısaltma: Örn. 1250 -> 1.2k — Badge'de kullanılabilir aura gösterilir
    final String formattedAura = availableAura >= 1000 
        ? '${(availableAura / 1000).toStringAsFixed(1)}k' 
        : availableAura.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 40), // Kartın dışına taşan butonlar için yer
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // ── ANA CAM KART ──
          Padding(
            padding: const EdgeInsets.only(bottom: 36), // Butonların sığacağı resmi hit-test alanı
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36),
          color: const Color(0xFF1E1E1E).withOpacity(0.55), // Apple Dark Liquid Material
          border: Border.all(
            color: Colors.white.withOpacity(0.12), // Apple Signature Rim Light
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            // İç gradientleri tamamen sildik, malzemenin kendi pürüzsüz dokusu konuşsun.
            child: Column(
              children: [
                // ── Üstteki İnce Header (Görseldeki "Next session..." benzeri) ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: Colors.white.withOpacity(0.8), size: 14),
                    const SizedBox(width: 8),
                    Text(
                      "Crack & Wish",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Devasa Avatar ve Yoğun Işık Halesi ──
                _BentoTouch(
                  onTap: onEditTap,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 3. Keskin parlak çerçeve (Görseldeki yansıyan çember)
                      Container(
                        width: 174,
                        height: 174,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFD4A574).withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                      ),
                      // Avatar container devasa
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.15),
                              Colors.white.withOpacity(0.02),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 24,
                              spreadRadius: -4,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onLongPress: onAvatarLongPress,
                          child: ClipOval(
                            child: Padding(
                              padding: const EdgeInsets.all(22),
                              child: Image.asset(
                                userAvatar,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Edit badge silindi, görseldeki gibi avatar tertemiz kaldı
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Name ve Subtitle (Tıklanabilir) ──
                _BentoTouch(
                  onTap: onEditTap,
                  child: Container(
                    color: Colors.transparent, // Tıklama alanı için
                    child: Column(
                      children: [
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w400, // Görseldeki gibi ince zarif
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // ── Subtitle (Icon + Title) ──
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(levelIcon, color: levelColor, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              levelTitle,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // ── GAMIFICATION BADGE'LERİ (Premium Ekosistem) ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _GlassBadge(
                      imagePath: 'assets/images/aura_core.png',
                      label: "$formattedAura Aura",
                      color: const Color(0xFFC084FC),
                      onTap: () => _showStatModal(context, "Aura Puanı", availableAura, Icons.auto_awesome, const Color(0xFFC084FC)),
                    ),
                    const SizedBox(width: 10),
                    _GlassBadge(
                      icon: Icons.diamond_rounded,
                      label: "$soulStones Ruh Taşı",
                      color: const Color(0xFF4EE6C5),
                      onTap: () => _showStatModal(context, "Kalan Ruh Taşı", soulStones, Icons.diamond_rounded, const Color(0xFF4EE6C5)),
                    ),
                  ],
                ),
                const SizedBox(height: 38), // Kartın alt boşluğu (butonların yarısı buraya gelecek)
              ],
            ),
          ),
        ),
      ),
    ),
  ),

    // ── KARTIN ALT SINIRINA ASILI YUVARLAK STAT BUTONLARI ──
    Positioned(
      bottom: 0, // HitTest alanının (Padding) dibine oturttuk, Overflow yok!
      left: 14,
      right: 14,
      child: isLoading
          ? const Center(
              child: SizedBox(
                height: 72,
                child: CircularProgressIndicator(color: Colors.white24),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _HeroStatCircle(
                  icon: Icons.bakery_dining_rounded,
                  iconColor: const Color(0xFFFFD166),
                  value: totalCookies,
                  onTap: () => _showStatModal(context, "Açılan Kurabiyeler", totalCookies, Icons.bakery_dining_rounded, const Color(0xFFFFD166)),
                ),
                _HeroStatCircle(
                  icon: Icons.auto_awesome_rounded,
                  iconColor: const Color(0xFFC084FC),
                  value: totalTarots,
                  onTap: () => _showStatModal(context, "Tarot Falları", totalTarots, Icons.auto_awesome_rounded, const Color(0xFFC084FC)),
                ),
                _HeroStatCircle(
                  icon: Icons.nights_stay_rounded,
                  iconColor: const Color(0xFF5A8BFF),
                  value: totalDreams,
                  hasDot: true, // Görseldeki o meşhur neon nokta!
                  onTap: () => _showStatModal(context, "Rüya Analizleri", totalDreams, Icons.nights_stay_rounded, const Color(0xFF5A8BFF)),
                ),
                _HeroStatCircle(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: const Color(0xFFFF6B6B),
                  value: streakDays,
                  onTap: () => _showStatModal(context, "Günlük Seri", streakDays, Icons.local_fire_department_rounded, const Color(0xFFFF6B6B)),
                ),
              ],
            ),
    ),
          ],
        ),
      );
  }
  
  Widget _buildTimeFilterChip(String label, int value, int currentValue, Function(int) onChange) {
    bool isSelected = currentValue == value;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onChange(value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1).withOpacity(0.3) : Colors.white.withOpacity(0.05),
          border: Border.all(color: isSelected ? const Color(0xFF6366F1).withOpacity(0.8) : Colors.white.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showStatModal(BuildContext context, String title, int value, IconData icon, Color color) {
    int modalAuraTotal = (totalCookies * 1) + (totalTarots * 2) + (totalDreams * 3) + (streakDays * 5);
    int modalSpentAura = spentAura;
    int modalSoulStones = soulStones;
    const int conversionCost = 200; // Kullanıcı sadakat dengesi: Aylık ~2.5 Taş (Free) / ~7.5 Taş (Elite)
    bool showSuccess = false;
    int selectedStoreIndex = -1; // Hiçbiri seçili değil, tıklandığında değişecek
    
    // Geçici MOCK veriler (Backend entegrasyonuna kadar, toplanabilir auralar)
    int unclaimedDreamAura = 3; 
    int unclaimedTarotAura = 0; // Bugün henüz tarot bakmadı
    int unclaimedCookieAura = 1;
    int unclaimedStreakAura = 5;
    int unclaimedOwlAura = 2; // Baykuş - Mektup gönderimi
    int unclaimedRewardAura = 10; // Özel ödül
    int unclaimedSoulStone = 1; // Hediye Ruh Taşı
    int dreamTimeFilter = 7; // Varsayılan: Son 7 Gün

    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.15),
      barrierDismissible: true,
      barrierLabel: 'StatModal',
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, anim1, anim2, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8 * anim1.value, sigmaY: 8 * anim1.value),
          child: Transform.scale(
            scale: Curves.easeOutCubic.transform(anim1.value) * 0.05 + 0.95,
            child: FadeTransition(opacity: anim1, child: child),
          ),
        );
      },
      pageBuilder: (context, anim1, anim2) => Dialog(
        backgroundColor: Colors.transparent,
        child: StatefulBuilder(
          builder: (context, setModalState) {
            final int rawAvailableAura = modalAuraTotal - modalSpentAura;
            final int availableAura = rawAvailableAura < 0 ? 0 : rawAvailableAura;
            final bool canConvert = availableAura >= conversionCost;

            return GestureDetector(
              onTap: () => Navigator.pop(context),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 320,
                height: 320, // KESİN BİR ŞEKİLDE SABİT - HİÇBİR ZAMAN DEĞİŞMEYECEK
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 40, offset: const Offset(0, 10)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12), // Menü bar ile birebir (buzlu cam aydınlığı)
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Colors.white.withOpacity(0.25), width: 0.5),
                      ),
                      child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16), // İçeriği yukarı taşımak için üst boşluk
                    // ── Başlık ──
                    if (title == "Aura Puanı")
                      Image.asset("assets/images/aura_core.png", width: 56, height: 56, fit: BoxFit.contain)
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0),
                        child: Icon(icon, color: color, size: 32),
                      ),
                    const SizedBox(height: 6),
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                    const SizedBox(height: 2),
                    if (title == "Aura Puanı")
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(end: availableAura.toDouble()),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCirc,
                        builder: (context, val, child) => Text(
                          val.toInt().toString(),
                          style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 1),
                        ),
                      )
                    else if (title == "Kalan Ruh Taşı")
                      Column(
                        children: [
                          Text("${value + (isPremium ? 5 : 0)}", style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: 1)),
                          if (isPremium) ...[
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFD700), size: 12),
                                const SizedBox(width: 4),
                                const Text("5 Günlük (Elite)", style: TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ],
                      )
                    else if (title != "Tarot Falları" && title != "Rüya Analizleri" && title != "Açılan Kurabiyeler" && title != "Günlük Seri")
                      Text("$value", style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 1)),
                    if (title == "Aura Puanı")
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: Text("Toplam $modalAuraTotal Aura kazanıldı", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10)),
                      ),
                    const SizedBox(height: 6),

                    // ════════════════════════════════════════════
                    // AURA PUANI PANELİ (Minimalist)
                    // ════════════════════════════════════════════
                    if (title == "Aura Puanı") ...[
                      
                      // ── ÇEVİR BUTONU VE BAŞARI EFEKTİ (Sabit Boyutlu) ──
                      Column(
                        children: [
                          // Bilgi satırı
                          if (canConvert || showSuccess)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text("200 Aura = 1 Ruh Taşı", style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 11, letterSpacing: 0.3)),
                            ),

                          Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: showSuccess 
                                    ? const Color(0xFF10B981).withOpacity(0.12)
                                    : (canConvert ? const Color(0xFF4EE6C5).withOpacity(0.12) : Colors.white.withOpacity(0.03)),
                                border: Border.all(
                                  color: showSuccess 
                                      ? const Color(0xFF10B981).withOpacity(0.3)
                                      : (canConvert ? const Color(0xFF4EE6C5).withOpacity(0.3) : Colors.white.withOpacity(0.08)),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: InkWell(
                                onTap: (canConvert && !showSuccess) ? () async {
                                  HapticFeedback.heavyImpact();
                                  final success = await onConvertAura();
                                  if (success) {
                                    setModalState(() {
                                      modalSpentAura += conversionCost;
                                      modalSoulStones += 1;
                                      showSuccess = true;
                                    });
                                    Future.delayed(const Duration(milliseconds: 1000), () {
                                      if (context.mounted) setModalState(() => showSuccess = false);
                                    });
                                  }
                                } : null,
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 150),
                                    child: showSuccess
                                      ? const Row(
                                          key: ValueKey("success"),
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16),
                                            SizedBox(width: 8),
                                            Text("Ruh Taşı Üretildi", style: TextStyle(color: Color(0xFF10B981), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                          ],
                                        )
                                      : Row(
                                          key: const ValueKey("convert"),
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.diamond_rounded, color: canConvert ? const Color(0xFF4EE6C5) : Colors.white.withOpacity(0.2), size: 16),
                                            const SizedBox(width: 8),
                                            Text(
                                              canConvert ? "Ruh Taşına Çevir" : "Yetersiz Aura",
                                              style: TextStyle(color: canConvert ? const Color(0xFF4EE6C5) : Colors.white.withOpacity(0.2), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1),
                                            ),
                                          ],
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // ── RUH TAŞI BAKİYESİ ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedScale(
                            scale: showSuccess ? 1.3 : 1.0,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutBack, // Daha hızlı ve belirgin pop efekti
                            child: Icon(
                              Icons.diamond_rounded, 
                              color: showSuccess ? const Color(0xFF10B981) : const Color(0xFF4EE6C5), 
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "$modalSoulStones Ruh Taşı", 
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5), 
                              fontSize: 13, 
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── TOPLANABİLİR AURALAR (Tıkla ve Ana Bakiyeye Ekle!) ──
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4), // Kutuyu taşmaması için daraltıldı
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            children: [
                              _buildAuraSource(Icons.nights_stay_rounded, "Rüya", unclaimedDreamAura, () {
                                if (unclaimedDreamAura > 0) {
                                  HapticFeedback.heavyImpact();
                                  setModalState(() {
                                    modalAuraTotal += unclaimedDreamAura;
                                    unclaimedDreamAura = 0; // Toplandı!
                                  });
                                }
                              }),
                              _buildAuraSource(Icons.auto_awesome, "Fal", unclaimedTarotAura, () {
                                if (unclaimedTarotAura > 0) {
                                  HapticFeedback.heavyImpact();
                                  setModalState(() {
                                    modalAuraTotal += unclaimedTarotAura;
                                    unclaimedTarotAura = 0; // Toplandı!
                                  });
                                }
                              }),
                              _buildAuraSource(Icons.cookie, "Kurabiye", unclaimedCookieAura, () {
                                if (unclaimedCookieAura > 0) {
                                  HapticFeedback.heavyImpact();
                                  setModalState(() {
                                    modalAuraTotal += unclaimedCookieAura;
                                    unclaimedCookieAura = 0; // Toplandı!
                                  });
                                }
                              }),
                              _buildAuraSource(Icons.local_fire_department_rounded, "Seri", unclaimedStreakAura, () {
                                if (unclaimedStreakAura > 0) {
                                  HapticFeedback.heavyImpact();
                                  setModalState(() {
                                    modalAuraTotal += unclaimedStreakAura;
                                    unclaimedStreakAura = 0; // Toplandı!
                                  });
                                }
                              }),
                              _buildAuraSource(Icons.mail_rounded, "Baykuş", unclaimedOwlAura, () {
                                if (unclaimedOwlAura > 0) {
                                  HapticFeedback.heavyImpact();
                                  setModalState(() {
                                    modalAuraTotal += unclaimedOwlAura;
                                    unclaimedOwlAura = 0; // Toplandı!
                                  });
                                }
                              }),
                              _buildAuraSource(Icons.card_giftcard_rounded, "Ödül", unclaimedRewardAura, () {
                                if (unclaimedRewardAura > 0) {
                                  HapticFeedback.heavyImpact();
                                  setModalState(() {
                                    modalAuraTotal += unclaimedRewardAura;
                                    unclaimedRewardAura = 0; // Toplandı!
                                  });
                                }
                              }),
                              _buildAuraSource(Icons.diamond_rounded, "Ruh Taşı", unclaimedSoulStone, () {
                                if (unclaimedSoulStone > 0) {
                                  HapticFeedback.heavyImpact();
                                  setModalState(() {
                                    modalSoulStones += unclaimedSoulStone;
                                    unclaimedSoulStone = 0; // Toplandı!
                                  });
                                }
                              }, color: const Color(0xFFFFD700)),
                            ],
                          ),
                        ),
                      ),

                    // ════════════════════════════════════════════
                    // KALAN RUH TAŞI PANELİ
                    // ════════════════════════════════════════════
                    ] else if (title == "Kalan Ruh Taşı") ...[
                      Text(
                        "Not: Aura Puanı panelinden\npuanlarınızı Ruh Taşına dönüştürebilirsiniz.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9, height: 1.3),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                           Expanded(child: _buildSoulStoreCard(context, "1 Taş", "₺24.99", const Color(0xFF4EE6C5), isSelected: selectedStoreIndex == 0, onTap: () => setModalState(() => selectedStoreIndex = 0))),
                           const SizedBox(width: 6),
                           Expanded(child: _buildSoulStoreCard(context, "3 Taş", "₺59.99", const Color(0xFFC084FC), isPopular: true, isSelected: selectedStoreIndex == 1, onTap: () => setModalState(() => selectedStoreIndex = 1))),
                           const SizedBox(width: 6),
                           Expanded(child: _buildSoulStoreCard(context, "10 Taş", "₺149.99", const Color(0xFFFFD700), isSelected: selectedStoreIndex == 2, onTap: () => setModalState(() => selectedStoreIndex = 2))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: selectedStoreIndex != -1 ? () {
                            HapticFeedback.heavyImpact();
                            // Satın alma akışı tetiklenecek
                          } : null,
                          borderRadius: BorderRadius.circular(24),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selectedStoreIndex != -1 ? const Color(0xFFC084FC).withOpacity(0.18) : Colors.white.withOpacity(0.03), 
                              border: Border.all(color: selectedStoreIndex != -1 ? const Color(0xFFC084FC).withOpacity(0.4) : Colors.white.withOpacity(0.08), width: 1),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Center(
                              child: Text("Satın Al", style: TextStyle(color: selectedStoreIndex != -1 ? const Color(0xFFC084FC) : Colors.white.withOpacity(0.2), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text("Elite üyeler her gün 5 bedava Ruh Taşı kazanır.", textAlign: TextAlign.center, style: TextStyle(color: const Color(0xFFFFD700).withOpacity(0.8), fontSize: 9)),

                    // ════════════════════════════════════════════
                    // DİĞER PANELLER
                    // ════════════════════════════════════════════
                    ] else if (title == "Açılan Kurabiyeler") ...[
                      const SizedBox(height: 4),
                      Expanded(child: const _ProfileCookieCarousel()),
                    ] else if (title == "Tarot Falları") ...[
                      const SizedBox(height: 4),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // ── MİSTİK KADER KARTI (Sol Taraf) ──
                            Expanded(
                              flex: 4,
                              child: FutureBuilder<SignatureResult?>(
                                future: UserStatsService.getSignatureCard(),
                                builder: (context, snapshot) {
                                  final result = snapshot.data;
                                  final bool isLocked = result == null;
                                  // Eski/yeni kayıt fark etmez, her zaman doğru asset yolunu çözer
                                  final String cardImagePath = isLocked ? '' : resolveCardAsset(result.cardName, result.cardAsset);
                                  
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("İmza Kartın", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                                      const SizedBox(height: 1),
                                      Text(isLocked ? "Fal baktır ve keşfet" : result.periodLabel, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 7.5)),
                                      const SizedBox(height: 6),
                                      Container(
                                        width: 78,
                                        height: 118,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: isLocked ? [] : [
                                            BoxShadow(color: const Color(0xFFC084FC).withOpacity(0.3), blurRadius: 20, spreadRadius: 2),
                                          ],
                                          border: Border.all(color: isLocked ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.3), width: 1),
                                        ),
                                        child: isLocked
                                          ? Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(9),
                                                gradient: LinearGradient(
                                                  colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.02)],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.lock_outline_rounded, color: Colors.white.withOpacity(0.3), size: 28),
                                                  const SizedBox(height: 6),
                                                  Text("GİZLİ", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                                ],
                                              ),
                                            )
                                          : ClipRRect(
                                              borderRadius: BorderRadius.circular(9),
                                              child: Transform.scale(
                                                scale: 1.15,
                                                child: Image.asset(
                                                  cardImagePath,
                                                  width: 78,
                                                  height: 118,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) => Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.auto_awesome, color: Colors.white.withOpacity(0.5), size: 24),
                                                      const SizedBox(height: 4),
                                                      Text(result.cardName, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 7)),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(isLocked ? "? ? ?" : result.cardName, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                    ],
                                  );
                                },
                              ),
                            ),
                            Container(width: 1, color: Colors.white.withOpacity(0.08)),
                            Expanded(
                              flex: 5,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 12.0),
                                child: FutureBuilder<Set<String>>(
                                  future: UserStatsService.getDiscoveredCards(),
                                  builder: (context, snapshot) {
                                    final discovered = snapshot.data ?? {};
                                    final int count = discovered.length;
                                    const int totalCards = 78;
                                    
                                    // Tüm 78 kartın asset listesi (sıralı)
                                    final allAssets = getAllCardAssets();
                                    
                                    // Seviye unvanı + renk
                                    String rank;
                                    Color rankColor;
                                    if (count == 0) { rank = "Keşfedilmemiş"; rankColor = Colors.white.withOpacity(0.3); }
                                    else if (count < 10) { rank = "Çırak"; rankColor = const Color(0xFF94A3B8); }
                                    else if (count < 25) { rank = "Gezgin"; rankColor = const Color(0xFF38BDF8); }
                                    else if (count < 45) { rank = "Kaşif"; rankColor = const Color(0xFFA78BFA); }
                                    else if (count < 65) { rank = "Bilge"; rankColor = const Color(0xFFC084FC); }
                                    else if (count < 78) { rank = "Usta"; rankColor = const Color(0xFFF59E0B); }
                                    else { rank = "Grandmaster"; rankColor = const Color(0xFFD4AF37); }
                                    
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // ── Başlık + Sayı ──
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text("$count", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                            Text(" / $totalCards", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10)),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(6),
                                            color: rankColor.withOpacity(0.15),
                                          ),
                                          child: Text(rank, style: TextStyle(color: rankColor, fontSize: 8, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
                                        ),
                                        const SizedBox(height: 10),
                                        
                                        // ── 78 Kart Grid Haritası ──
                                        Wrap(
                                          spacing: 2.5,
                                          runSpacing: 2.5,
                                          alignment: WrapAlignment.center,
                                          children: List.generate(allAssets.length, (i) {
                                            final isDiscovered = discovered.contains(allAssets[i]);
                                            return Container(
                                              width: 10,
                                              height: 13,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(2),
                                                color: isDiscovered 
                                                  ? const Color(0xFFC084FC) 
                                                  : Colors.white.withOpacity(0.06),
                                                boxShadow: isDiscovered ? [
                                                  BoxShadow(color: const Color(0xFFC084FC).withOpacity(0.4), blurRadius: 4),
                                                ] : [],
                                              ),
                                            );
                                          }),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (title == "Rüya Analizleri") ...[
                      const SizedBox(height: 4),
                      Expanded(
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: StorageService.getDreams(),
                          builder: (context, snapshot) {
                            final dreams = snapshot.data ?? [];
                            final hasDream = dreams.isNotEmpty;
                            final lastDream = hasDream ? dreams.first : null;
                            
                            String lastTitle = "Teşhis Yok";
                            String userDraft = "Henüz bir rüya kaydetmediniz.";
                            
                            if (hasDream && lastDream != null) {
                              userDraft = lastDream['text'] ?? "Bilinçaltı verisi...";
                              if (userDraft.length > 45) userDraft = "${userDraft.substring(0, 42)}...";
                              
                              lastTitle = lastDream['title'] ?? (lastDream['text'] != null ? "Bilinçaltı Mesajı" : "Gizemli Rüya");
                              if (lastTitle.length > 25) lastTitle = "${lastTitle.substring(0, 22)}...";
                            }

                            // ── ZAMAN FİLTRESİ ──
                            List<Map<String, dynamic>> filteredDreams = dreams;
                            if (dreamTimeFilter > 0) {
                              final limitDate = DateTime.now().subtract(Duration(days: dreamTimeFilter));
                              filteredDreams = dreams.where((d) {
                                if (d['date'] == null) return false;
                                try {
                                  return DateTime.parse(d['date'].toString()).isAfter(limitDate);
                                } catch(_) { return false; }
                              }).toList();
                            }
                            
                            final totalCount = filteredDreams.length;
                            
                            // Duygusal İstatistik Hesaplama (Baskın Duyguyu Bulma)
                            Map<String, int> emotionCounts = {};
                            for (var d in filteredDreams) {
                              String? em = d['emotion']?.toString() ?? d['mood']?.toString();
                              if (em != null && em.isNotEmpty) {
                                emotionCounts[em] = (emotionCounts[em] ?? 0) + 1;
                              }
                            }
                            
                            String dominantInsight = "";
                            if (emotionCounts.isNotEmpty) {
                              var sorted = emotionCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
                              var topEmotion = sorted.first;
                              int pct = ((topEmotion.value / totalCount) * 100).toInt();
                              
                              // Basit Çeviri
                              Map<String, String> trMap = {
                                'fear': 'Korku', 'anxiety': 'Kaygı', 'joy': 'Neşe', 
                                'sadness': 'Hüzün', 'confusion': 'Karmaşa', 'peace': 'Huzur',
                                'anger': 'Öfke'
                              };
                              String emLabel = trMap[topEmotion.key] ?? topEmotion.key;
                              
                              if (dreamTimeFilter == 3) {
                                dominantInsight = "Uyku anlarının %$pct kadarı '$emLabel' temalı.";
                              } else if (dreamTimeFilter == 7) {
                                dominantInsight = "Haftalık rüyalarının %$pct kadarı '$emLabel' etkisinde.";
                              } else if (dreamTimeFilter == 30) {
                                dominantInsight = "Aylık rüyalarının %$pct kadarı '$emLabel' yüklü.";
                              } else {
                                dominantInsight = "Genel olarak rüyalarının %$pct kadarı '$emLabel' temalı.";
                              }
                            } else {
                              if (dreamTimeFilter == 3) {
                                dominantInsight = "Son 3 güne ait kaydın yok. Zihnini keşfetmek için ilk adımını at.";
                              } else if (dreamTimeFilter == 7) {
                                dominantInsight = "Bu hafta henüz rüya kaydetmedin. Bilinçaltınla bağ kurmaya başla.";
                              } else {
                                dominantInsight = "Bu ayki rüya günlüğün henüz boş. Gizemleri çözmek için beklemedeyiz.";
                              }
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // ── ZAMAN FİLTRESİ SEKMELERİ ──
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildTimeFilterChip("3 Gün", 3, dreamTimeFilter, (val) => setModalState(() => dreamTimeFilter = val)),
                                      const SizedBox(width: 8),
                                      _buildTimeFilterChip("7 Gün", 7, dreamTimeFilter, (val) => setModalState(() => dreamTimeFilter = val)),
                                      const SizedBox(width: 8),
                                      _buildTimeFilterChip("1 Ay", 30, dreamTimeFilter, (val) => setModalState(() => dreamTimeFilter = val)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // ── KİŞİSEL BİLİNÇALTI ÖZETİ (Insight) ──
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6366F1).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3), width: 1),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF818CF8).withOpacity(0.2)),
                                          child: const Icon(Icons.insights_rounded, color: Color(0xFF818CF8), size: 16),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                dreamTimeFilter == 3 ? "SON 3 GÜN" : (dreamTimeFilter == 7 ? "HAFTALIK ÖZET" : "AYLIK ÖZET"), 
                                                style: TextStyle(color: const Color(0xFF818CF8).withOpacity(0.8), fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 1.0)
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                dominantInsight,
                                                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 10, fontWeight: FontWeight.w500, height: 1.3),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 6),
                                  
                                  // ── BİLİNÇALTI DAĞILIMI (DUYGU GRAFİĞİ) ──
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                    child: Row(
                                      children: [
                                        Text("Duygu Dağılımı", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.w600)),
                                        const Spacer(),
                                        Text("$totalCount Kayıt Analizi", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  
                                  if (emotionCounts.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Center(child: Text("Grafik oluşturmak için veri bekleniyor.", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10))),
                                    )
                                  else
                                    Column(
                                      children: (emotionCounts.entries.toList()..sort((a,b) => b.value.compareTo(a.value))).take(3).map((e) {
                                        int pct = ((e.value / totalCount) * 100).toInt();
                                        Map<String, String> localTr = {
                                          'fear': 'Korku', 'anxiety': 'Kaygı', 'joy': 'Neşe', 'happy': 'Mutluluk', 'happiness': 'Mutluluk',
                                          'sadness': 'Hüzün', 'sad': 'Hüzün', 'confusion': 'Karmaşa', 'peace': 'Huzur', 'peaceful': 'Huzurlu',
                                          'anger': 'Öfke', 'angry': 'Öfkeli', 'neutral': 'Nötr'
                                        };
                                        String label = localTr[e.key.toLowerCase()] ?? e.key;
                                        
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 6.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                                                  const Spacer(),
                                                  Text("%$pct", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 9, fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(4),
                                                child: LinearProgressIndicator(
                                                  value: pct / 100,
                                                  backgroundColor: Colors.white.withOpacity(0.05),
                                                  valueColor: AlwaysStoppedAnimation(
                                                    label == 'Kaygı' || label == 'Korku' ? const Color(0xFFFF6B6B) : 
                                                    label == 'Huzur' || label == 'Neşe' ? const Color(0xFF4EE6C5) : 
                                                    const Color(0xFF818CF8)
                                                  ),
                                                  minHeight: 5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ] else if (title == "Günlük Seri") ...[
                      FutureBuilder<DateTime>(
                        future: StorageService.getInstallDate(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xFFFF6B6B))));
                          }
                          
                          final installDate = snapshot.data!;
                          final now = DateTime.now();
                          final nowNorm = DateTime(now.year, now.month, now.day);
                          // Streak başlangıç tarihi
                          final streakStartDate = nowNorm.subtract(Duration(days: value > 0 ? value - 1 : 0));
                          
                          int totalMonths = (now.year - installDate.year) * 12 + now.month - installDate.month + 1;
                          if (totalMonths < 1) totalMonths = 1;

                          int nextTarget = 7;
                          if (value >= 7) nextTarget = 14;
                          if (value >= 14) nextTarget = 30;
                          if (value >= 30) nextTarget = 50;
                          if (value >= 50) nextTarget = 100;
                          if (value >= 100) nextTarget = 365;

                          final monthNames = ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"];
                          final weekDays = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"];

                          return Expanded(
                            child: PageView.builder(
                              physics: const BouncingScrollPhysics(),
                              controller: PageController(initialPage: totalMonths - 1),
                              itemCount: totalMonths,
                              itemBuilder: (context, pageIndex) {
                                int targetMonth = installDate.month + pageIndex;
                                int targetYear = installDate.year + ((targetMonth - 1) ~/ 12);
                                targetMonth = ((targetMonth - 1) % 12) + 1;
                                
                                final firstDayOfMonth = DateTime(targetYear, targetMonth, 1);
                                final lastDayOfMonth = DateTime(targetYear, targetMonth + 1, 0);
                                final daysInMonth = lastDayOfMonth.day;
                                final firstWeekday = firstDayOfMonth.weekday;

                                List<Widget> calendarDays = [];

                                for (var day in weekDays) {
                                  calendarDays.add(
                                    Center(child: Text(day, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.bold))),
                                  );
                                }

                                for (int i = 1; i < firstWeekday; i++) {
                                  calendarDays.add(const SizedBox());
                                }

                                for (int i = 1; i <= daysInMonth; i++) {
                                  final testDate = DateTime(targetYear, targetMonth, i);
                                  final isToday = testDate.year == nowNorm.year && testDate.month == nowNorm.month && testDate.day == nowNorm.day;
                                  
                                  // Streak tarihi içinde mi?
                                  bool isStreakDay = false;
                                  if (value > 0) {
                                    isStreakDay = testDate.compareTo(streakStartDate) >= 0 && testDate.compareTo(nowNorm) <= 0;
                                  }

                                  calendarDays.add(
                                    Container(
                                      margin: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isToday 
                                          ? const Color(0xFFFF6B6B).withOpacity(0.15) 
                                          : (isStreakDay ? const Color(0xFFFF6B6B).withOpacity(0.08) : Colors.transparent),
                                        border: isToday ? Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.5), width: 1) : null,
                                      ),
                                      child: Center(
                                        child: isStreakDay
                                          ? const Icon(Icons.local_fire_department_rounded, color: Color(0xFFFF6B6B), size: 12)
                                          : Text("$i", style: TextStyle(
                                              color: isToday ? const Color(0xFFFF6B6B) : Colors.white.withOpacity(0.5), 
                                              fontSize: 10, 
                                              fontWeight: isToday ? FontWeight.bold : FontWeight.w500
                                            )),
                                      ),
                                    ),
                                  );
                                }

                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 0, bottom: 10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("${monthNames[targetMonth - 1]} $targetYear", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                            Row(
                                              children: [
                                                const Icon(Icons.local_fire_department_rounded, color: Color(0xFFFF6B6B), size: 10),
                                                const SizedBox(width: 4),
                                                Text("$nextTarget Gün Hedef!", style: TextStyle(color: const Color(0xFFFF6B6B).withOpacity(0.8), fontSize: 9, fontWeight: FontWeight.w600)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            final rowCount = (calendarDays.length / 7).ceil();
                                            const spacing = 4.0; // Boşlukları daraltarak kazanıyoruz
                                            final totalSpacing = spacing * (rowCount - 1);
                                            double itemHeight = (constraints.maxHeight - totalSpacing) / rowCount;
                                            // Asla taşmaması için minimum limit koymuyoruz, kalan yerin tamamını alacak

                                            return GridView.builder(
                                              padding: EdgeInsets.zero,
                                              shrinkWrap: false,
                                              physics: const NeverScrollableScrollPhysics(),
                                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 7,
                                                mainAxisSpacing: spacing,
                                                crossAxisSpacing: spacing,
                                                mainAxisExtent: itemHeight,
                                              ),
                                              itemCount: calendarDays.length,
                                              itemBuilder: (context, index) => calendarDays[index],
                                            );
                                          }
                                        ),
                                      ),
                                      const SizedBox(height: 6), // Alt boşluğu azalttım
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        }
                      ),
                    ],
                  ],
                ),
               ),
              ),
             ),
            ),
           );
          },
        ),
      ),
    );
  }

  Widget _buildAuraSource(IconData icon, String title, int unclaimedAura, VoidCallback onTap, {Color color = const Color(0xFF4EE6C5)}) {
    bool hasAura = unclaimedAura > 0;
    return GestureDetector(
      onTap: hasAura ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 72, // Scroll içerisinde standart boyut
        margin: const EdgeInsets.symmetric(horizontal: 2),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: hasAura ? color.withOpacity(0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: hasAura ? color.withOpacity(0.3) : Colors.transparent, width: 0.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: hasAura ? color : Colors.white.withOpacity(0.2), size: 16),
                const SizedBox(height: 4),
                Text(title, style: TextStyle(color: hasAura ? color.withOpacity(0.8) : Colors.white.withOpacity(0.3), fontSize: 9)),
                const SizedBox(height: 2),
                Text(hasAura ? "+$unclaimedAura" : "0", style: TextStyle(color: hasAura ? Colors.white : Colors.white.withOpacity(0.2), fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildTarotHistoryRow(IconData icon, String title, String time, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              Text(time, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildElementBar(String name, int count, int total, Color color) {
    final pct = total > 0 ? count / total : 0.0;
    return Row(
      children: [
        SizedBox(width: 34, child: Text(name, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 7))),
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: pct.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(width: 18, child: Text("${(pct * 100).round()}%", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 6), textAlign: TextAlign.right)),
      ],
    );
  }

  Widget _buildMiniStat(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.08),
        border: Border.all(color: color.withOpacity(0.12), width: 0.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 10, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 6)),
        ],
      ),
    );
  }


  Widget _buildSoulStoreCard(BuildContext context, String countText, String price, Color color, {bool isPopular = false, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : color.withOpacity(0.04), // Seçiliyken parlak
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : color.withOpacity(0.1), width: isSelected ? 1.5 : 0.5),
          boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, spreadRadius: 0)] : [],
        ),
        child: Column(
          children: [
            if (isPopular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                margin: const EdgeInsets.only(bottom: 2),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                child: const Text("POPÜLER", style: TextStyle(color: Colors.black, fontSize: 7, fontWeight: FontWeight.bold)),
              )
            else
              const SizedBox(height: 13),
            Icon(Icons.diamond_rounded, color: color, size: 14),
            const SizedBox(height: 4),
            Text(countText, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(price, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 8)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ICON INFO TILE (Ruh Taşı paneli bilgi satırı)
// ═══════════════════════════════════════════════════════════════

class _IconInfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _IconInfoTile({required this.icon, required this.iconColor, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: iconColor, size: 14),
      ),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
      ])),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════
// GLASS BADGE (Aura & Ruh Taşı Hap Butonları)
// ═══════════════════════════════════════════════════════════════

class _GlassBadge extends StatelessWidget {
  final IconData? icon;
  final String? imagePath;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _GlassBadge({
    this.icon,
    this.imagePath,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _BentoTouch(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08), // Daha ince açık cam
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.12), width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: OverflowBox(
                    maxWidth: 38,
                    maxHeight: 38,
                    child: imagePath != null
                        ? Image.asset(imagePath!, width: 36, height: 36, fit: BoxFit.contain)
                        : (icon != null ? Icon(icon, color: color, size: 18) : const SizedBox()),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HERO STAT CIRCLE (4 Stat İçin Yuvarlak Cam Butonlar)
// ═══════════════════════════════════════════════════════════════

class _HeroStatCircle extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final int value;
  final bool hasDot; // Neon dot for aesthetic match
  final VoidCallback onTap;

  const _HeroStatCircle({
    required this.icon,
    required this.iconColor,
    required this.value,
    this.hasDot = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _BentoTouch(
      onTap: onTap,
      child: Stack(
      clipBehavior: Clip.none,
      children: [
        // Tamponlanmış, koyu renkli buzlu cam (Görseldeki "1-1" etki)
        ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1E1E1E).withOpacity(0.55), // Apple Dark Liquid Material
                border: Border.all(
                  color: Colors.white.withOpacity(0.12), // İncecik metalik zar
                  width: 0.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: iconColor.withOpacity(0.95), size: 18), // İkon boyutu kibarlaştı
                  const SizedBox(height: 5),
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: value),
                    duration: const Duration(milliseconds: 1600),
                    curve: Curves.easeOutCubic,
                    builder: (context, val, child) {
                      return Text(
                        val.toString(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13,
                          fontWeight: FontWeight.w400, // Görsel diline uygun, çok ince rakamlar
                          letterSpacing: 0.8,
                          height: 1.0,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        // Neon Nokta (Görseldeki gibi şeffaf çerçevenin üst sınırına tünemiş, turuncu altın ışık)
        if (hasDot)
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFB347), // Görseldeki şeftali/altın sarısı
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFB347).withOpacity(0.8),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.8),
                    blurRadius: 2,
                    spreadRadius: -1, // İç parlama efekti (core glow)
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}
}

// ═══════════════════════════════════════════════════════════════
// DİNAMİK TIKLAMA EFEKTİ (Apple Luxury Bounce)
// ═══════════════════════════════════════════════════════════════

class _BentoTouch extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _BentoTouch({required this.child, required this.onTap});

  @override
  State<_BentoTouch> createState() => _BentoTouchState();
}

class _BentoTouchState extends State<_BentoTouch> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque, // Hayati önem
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      // onTapUp tarafını sildik, küçülmeden dönme işlemini tamamen onTap'in koreografisine bağladık
      onTap: () async {
        HapticFeedback.lightImpact(); 

        // Eğer kullanıcı aşırı hızlı bastıysa butonu zorla küçültülmüş moda al
        if (!_pressed && mounted) setState(() => _pressed = true);
        
        // Küçülme animasyonunun gözle net görülmesi için ufak bir tampon bekleme
        await Future.delayed(const Duration(milliseconds: 80));
        
        // Yay gibi eski haline dön (Genişle)
        if (mounted) setState(() => _pressed = false);
        
        // Büyüme animasyonunun (150ms) tamamlanmasına ramak kala pencereyi/aksiyonu tetikle!
        // Eskiden bu anında oluyordu, o yüzden sen butona bastığın an pencere ekranı kapattığı için efekt yarıda kesiliyordu.
        await Future.delayed(const Duration(milliseconds: 140));
        
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.90 : 1.0, 
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack, 
        child: AnimatedOpacity(
          opacity: _pressed ? 0.6 : 1.0, 
          duration: const Duration(milliseconds: 100),
          child: widget.child,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// BENTO ACTION TILE (Frosted Glass Aksiyon Kartı)
// ═══════════════════════════════════════════════════════════════

class _BentoActionTile extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool compact;

  const _BentoActionTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.compact = false,
  });

  @override
  State<_BentoActionTile> createState() => _BentoActionTileState();
}

class _BentoActionTileState extends State<_BentoActionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.96 : 1.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              height: widget.compact ? 100 : 124,
              padding: EdgeInsets.all(widget.compact ? 12 : 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF111118).withValues(alpha: 0.55),
                    const Color(0xFF111118).withValues(alpha: 0.35),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 0.5,
                ),
              ),
              child: widget.compact
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: widget.iconColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(widget.icon, color: widget.iconColor.withValues(alpha: 0.85), size: 19),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: widget.iconColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: widget.iconColor.withOpacity(0.15),
                              width: 0.5,
                            ),
                          ),
                          child: Center(
                            child: Icon(widget.icon, color: widget.iconColor.withOpacity(0.85), size: 20),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            widget.subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.35),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// BENTO PREMIUM BANNER
// ═══════════════════════════════════════════════════════════════

class _BentoPremiumBanner extends StatefulWidget {
  final String lang;
  final VoidCallback onTap;

  const _BentoPremiumBanner({
    required this.lang,
    required this.onTap,
  });

  @override
  State<_BentoPremiumBanner> createState() => _BentoPremiumBannerState();
}

class _BentoPremiumBannerState extends State<_BentoPremiumBanner> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.97 : 1.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFD4A574).withOpacity(0.25),
                    const Color(0xFFFFD166).withOpacity(0.10),
                    const Color(0xFFFF9A5C).withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFD4A574).withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD4A574), Color(0xFFB8956A)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4A574).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.workspace_premium_rounded,
                        color: Colors.white,
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
                          widget.lang == 'tr' ? 'Premium\'a Geç' : 'Go Premium',
                          style: const TextStyle(
                            color: Color(0xFFD4A574),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.lang == 'tr'
                              ? 'Sınırsız kurabiye ve özel özellikler'
                              : 'Unlimited cookies and exclusive features',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: const Color(0xFFD4A574).withOpacity(0.5),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PAYLAŞILAN WIDGET'LAR
// ═══════════════════════════════════════════════════════════════

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textWhite.withOpacity(0.6), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: AppColors.textWhite.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: AppColors.textWhite.withOpacity(0.35),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textWhite.withOpacity(0.2),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: AppColors.textWhite.withOpacity(0.4),
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _LanguageOption {
  final Locale? locale;
  final String label;

  const _LanguageOption(this.locale, this.label);
}

// ═══════════════════════════════════════════════════════════════
// TEMA GALERİSİ (dışarıdan referans ediliyor — sakla)
// ═══════════════════════════════════════════════════════════════

class ThemeGalleryPage extends StatelessWidget {
  final List<String> options;
  final String selected;

  const ThemeGalleryPage({
    super.key,
    required this.options,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeController.current;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: palette.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                child: Row(
                  children: [
                    GlassBackButton(
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.themeGalleryTitle,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                  itemCount: options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final opt = options[index];
                    final bool isSelected = opt == selected;
                    return GestureDetector(
                      onTap: () => Navigator.pop(context, opt),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? palette.cardBackgroundAlt
                              : palette.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: AppColors.textWhite,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  opt,
                                  style: const TextStyle(
                                    color: AppColors.textWhite,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: AppColors.textWhite70,
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
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ARKA PLAN (Mottled Painter)
// ═══════════════════════════════════════════════════════════════

class _MottledPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);

    final allColors = [
      const Color(0xFFD4B8A0),
      const Color(0xFFC8A890),
      const Color(0xFFE0C8B0),
      const Color(0xFF8B3A3A),
      const Color(0xFF7A3030),
      const Color(0xFF964040),
      const Color(0xFFA04848),
      const Color(0xFF6E2828),
      const Color(0xFF883838),
      const Color(0xFF1A3A5C),
      const Color(0xFF2A4A6C),
      const Color(0xFF1E3050),
    ];

    for (int i = 0; i < 26; i++) {
      final color = allColors[rng.nextInt(allColors.length)];
      final opacity = 0.28 + rng.nextDouble() * 0.30;
      final radius = 80.0 + rng.nextDouble() * 170.0;
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;

      final paint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(x, y),
          radius,
          [
            color.withOpacity(opacity),
            color.withOpacity(opacity * 0.75),
            color.withOpacity(opacity * 0.25),
            color.withOpacity(0),
          ],
          [0.0, 0.45, 0.75, 1.0],
        );

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════
// KİŞİSEL KURABİYE KOLEKSİYONU KAYDIRICI EKRANI (PROFIL MODAL İÇİ)
// ═══════════════════════════════════════════════════════════════

class _ProfileCookieCarousel extends StatefulWidget {
  const _ProfileCookieCarousel();

  @override
  State<_ProfileCookieCarousel> createState() => _ProfileCookieCarouselState();
}

class _ProfileCookieCarouselState extends State<_ProfileCookieCarousel> {
  List<CookieCard> _ownedCookies = [];
  bool _loading = true;
  int _crossAxisCount = 4;

  @override
  void initState() {
    super.initState();
    _loadOwnedCookies();
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _crossAxisCount = prefs.getInt('custom_cookie_grid_count') ?? 4);
    }
  }

  Future<void> _savePreference(int val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('custom_cookie_grid_count', val);
  }

  Future<void> _loadOwnedCookies() async {
    final collection = await StorageService.getCookieCollection();
    final owned = collection.where((c) => c.firstObtainedDate != null).toList();
    // En çok çıkandan aza sırala
    owned.sort((a, b) => b.countObtained.compareTo(a.countObtained));
    if (mounted) {
      setState(() {
        _ownedCookies = owned;
        _loading = false;
      });
    }
  }

  void _showCookieActionMenu(CookieCard cookie, BuildContext context) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white.withOpacity(0.12), width: 0.5),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 84,
                height: 84,
                child: Image.asset(
                  'assets/images/cookies/${cookie.id}.webp',
                  errorBuilder: (_, __, ___) => const Icon(Icons.bakery_dining_rounded, color: Color(0xFFFFD166), size: 40),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Koleksiyon Kurabiyesi",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                "Bu nadir parçadan toplam ${cookie.countObtained} adet buldun.",
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionBtn(Icons.push_pin_rounded, "📌 Sabitle", () {
                    // TODO: Sabitleme (Pin) entegrasyonu
                    HapticFeedback.lightImpact();
                    Navigator.pop(ctx);
                  }),
                  _actionBtn(Icons.send_rounded, "✉️ Gönder", () {
                    // TODO: Mektupla kurabiye gönderme ekranına pasla
                    HapticFeedback.lightImpact();
                    Navigator.pop(ctx);
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.5),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(height: 90, child: Center(child: CircularProgressIndicator(color: Colors.white24)));
    }
    if (_ownedCookies.isEmpty) {
      return Container(
        height: 90,
        alignment: Alignment.center,
        child: Text(
          "Henüz koleksiyonunda eşsiz kurabiye yok.\nAna sayfadan kurabiye kırarak siftah yap!",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, height: 1.4),
        ),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () { HapticFeedback.selectionClick(); setState(() { _crossAxisCount = 4; }); _savePreference(4); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.grid_view_rounded, color: _crossAxisCount == 4 ? Colors.white : Colors.white24, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () { HapticFeedback.selectionClick(); setState(() { _crossAxisCount = 6; }); _savePreference(6); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.apps_rounded, color: _crossAxisCount == 6 ? Colors.white : Colors.white24, size: 20),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.5),
              ),
              child: Text(
                "Koleksiyon: ${_ownedCookies.length}",
                style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.white, Colors.white],
                stops: [0.0, 0.08, 1.0], // Sadece tepede (top) %8'lik yumuşak silikleşme
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: GridView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
            physics: const BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _crossAxisCount,
                mainAxisSpacing: _crossAxisCount == 6 ? 8 : 16,
                crossAxisSpacing: _crossAxisCount == 6 ? 8 : 12,
                childAspectRatio: 1.0, // Tam kare oran, kurabiyeler nefes alsın
              ),
              itemCount: _ownedCookies.length,
              itemBuilder: (context, index) {
                final cookie = _ownedCookies[index];
                return _BentoTouch(
                  onTap: () => _showCookieActionMenu(cookie, context),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Arka Plan Mistik Işıması (Glow Ekranı)
                      Center(
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.white.withOpacity(0.02), blurRadius: 12, spreadRadius: 0),
                            ],
                          ),
                        ),
                      ),
                      // Kurabiye Görseli
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Image.asset(
                            'assets/images/cookies/${cookie.id}.webp',
                            errorBuilder: (_, __, ___) => const Icon(Icons.bakery_dining_rounded, color: Color(0xFFFFD166)),
                          ),
                        ),
                      ),
                      // Minimal x Adet Rozeti (Sağ Alt) Sadece birden fazlaysa göster
                      if (cookie.countObtained > 1)
                        Positioned(
                          right: 2,
                          bottom: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.65), // Çok hafif, siyah transparan
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "x${cookie.countObtained}",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 8, // İyice küçüldü
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ), // Expanded bitti
      ],
    );
  }
}
