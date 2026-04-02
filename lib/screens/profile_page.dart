import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';
import '../constants/colors.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/fade_page_route.dart';
import '../widgets/glass_back_button.dart';
import 'notification_settings_page.dart';
import 'home_page.dart';
import 'collection_page.dart';
import '../services/locale_controller.dart';
import '../services/storage_service.dart';

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final snapshot = await StorageService.getUserSnapshot();
    final streak = await StorageService.getStreakDays();
    final avatar = await StorageService.getAvatar() ?? 'assets/images/owl.webp';
    if (!mounted) return;
    setState(() {
      _userName = (snapshot['userName'] as String?) ?? '';
      _totalCookies = (snapshot['totalCookies'] as int?) ?? 0;
      _totalTarots = (snapshot['totalTarots'] as int?) ?? 0;
      _totalDreams = (snapshot['totalDreams'] as int?) ?? 0;
      _streakDays = streak;
      _userAvatar = avatar;
      _isLoading = false;
    });
  }

  // ── Kullanıcı seviyesi hesapla ──
  String _getUserLevel(String lang) {
    final total = _totalCookies + _totalTarots + _totalDreams;
    if (lang == 'tr') {
      if (total == 0) return 'Yeni Başlayan';
      if (total <= 10) return 'Acemi Kahin';
      if (total <= 50) return 'Çırak Kahin';
      if (total <= 100) return 'Deneyimli Kahin';
      return 'Usta Kahin';
    } else {
      if (total == 0) return 'Newcomer';
      if (total <= 10) return 'Novice Seer';
      if (total <= 50) return 'Apprentice Seer';
      if (total <= 100) return 'Experienced Seer';
      return 'Master Seer';
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
        ? 'Crack&Wish ile şansını keşfet! 🥠✨\nKurabiye kır, tarot aç, rüya yorumla.\n\nhttps://crackandwish.com'
        : 'Discover your fortune with Crack&Wish! 🥠✨\nCrack cookies, read tarot, interpret dreams.\n\nhttps://crackandwish.com';
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
            const Text('⭐', style: TextStyle(fontSize: 18)),
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
  void _openProfileSettings() {
    final lang = Localizations.localeOf(context).languageCode;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
                value: lang == 'tr' ? 'Ayarlanmadı' : 'Not set',
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime(2000, 1, 1),
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
                    if (ctx.mounted) Navigator.pop(ctx);
                  }
                },
              ),
              const SizedBox(height: 12),
              // Burç
              _SettingsRow(
                icon: Icons.stars_rounded,
                label: lang == 'tr' ? 'Burcun' : 'Zodiac Sign',
                value: lang == 'tr' ? 'Otomatik' : 'Automatic',
                onTap: () {
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
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

🥠 Kurabiye nasıl kırılır?
Ana sayfadaki kurabiyeye dokun ve kırmak için kaydır. Her gün yeni bir kurabiye seni bekliyor.

🔮 Tarot falı nasıl bakılır?
Ana sayfadan Tarot kartına dokun. 3 kart seç ve günlük mesajını oku.

💭 Rüya yorumu nasıl yapılır?
Rüya sayfasına git, rüyanı yaz ve AI destekli yorumunu al.

⭐ Burç yorumum nerede?
Ana sayfadan Burç kartına dokun. Batı, Çin ve Maya burç yorumlarını keşfet.

🔥 Gün serisi nedir?
Her gün uygulamayı kullandığında serin artar. Bir gün atlarsan seri sıfırlanır.

📱 Verilerim güvende mi?
Evet! Tüm verilerin cihazında yerel olarak saklanır, hiçbir yere gönderilmez.

📧 İletişim
info@crackandwish.com'''
          : '''Frequently Asked Questions

🥠 How to crack a cookie?
Tap the cookie on the home page and swipe to crack it. A new cookie awaits you every day.

🔮 How to read tarot?
Tap the Tarot card on the home page. Select 3 cards and read your daily message.

💭 How to interpret dreams?
Go to the Dream page, write your dream, and get an AI-powered interpretation.

⭐ Where is my horoscope?
Tap the Zodiac card on the home page. Discover Western, Chinese, and Mayan horoscopes.

🔥 What is a day streak?
Your streak increases every day you use the app. Miss a day and it resets.

📱 Is my data safe?
Yes! All your data is stored locally on your device and is never sent anywhere.

📧 Contact
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
                // Mottled overlay (aynı arka plan)
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(painter: _mottledPainter),
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── 1. PROFİL KARTI ──
                        _ProfileCard(
                          userName: _userName,
                          userAvatar: _userAvatar,
                          levelTitle: _getUserLevel(lang),
                          totalCookies: _totalCookies,
                          totalTarots: _totalTarots,
                          totalDreams: _totalDreams,
                          streakDays: _streakDays,
                          isLoading: _isLoading,
                          onEditTap: _editProfile,
                          cookieLabel: l10n.statCookies,
                          tarotLabel: lang == 'tr' ? 'Tarot' : 'Tarot',
                          dreamLabel: l10n.statDreams,
                          streakLabel: l10n.statStreakDays,
                        ),
                        const SizedBox(height: 20),

                        // ── 2. PREMİUM BANNER ──
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Text('👑', style: TextStyle(fontSize: 18)),
                                    const SizedBox(width: 8),
                                    Text(
                                      lang == 'tr'
                                          ? 'Premium çok yakında aktif olacak!'
                                          : 'Premium coming very soon!',
                                      style: const TextStyle(color: Colors.white, fontSize: 13),
                                    ),
                                  ],
                                ),
                                backgroundColor: const Color(0xFF1A1A2E),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFFFD166),
                                  Color(0xFFFF9A5C),
                                  Color(0xFFFF6B6B),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFD166).withOpacity(0.25),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.workspace_premium_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        lang == 'tr' ? 'Premium\'a Geç' : 'Go Premium',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        lang == 'tr'
                                            ? 'Sınırsız kurabiye ve özel özellikler'
                                            : 'Unlimited cookies and exclusive features',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ── 3. GENEL ──
                        _SectionLabel(lang == 'tr' ? 'Genel' : 'General'),
                        const SizedBox(height: 12),
                        _ProfileMenuItem(
                          icon: Icons.language_rounded,
                          iconBgColor: const Color(0xFF5A8BFF),
                          title: l10n.language,
                          trailing: l10n.languageValue(languageValue),
                          onTap: _openLanguagePicker,
                        ),
                        const SizedBox(height: 10),
                        _ProfileMenuItem(
                          icon: Icons.notifications_none_rounded,
                          iconBgColor: const Color(0xFFFF6B6B),
                          title: lang == 'tr' ? 'Bildirimler' : 'Notifications',
                          onTap: () {
                            Navigator.push(
                              context,
                              SwipeFadePageRoute(
                                page: const NotificationSettingsPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        _ProfileMenuItem(
                          icon: Icons.person_outline_rounded,
                          iconBgColor: const Color(0xFF7B61FF),
                          title: lang == 'tr' ? 'Profil Ayarları' : 'Profile Settings',
                          onTap: _openProfileSettings,
                        ),

                        const SizedBox(height: 32),

                        // ── 4. PAYLAŞ & DESTEK ──
                        _SectionLabel(
                          lang == 'tr' ? 'Paylaş & Destek' : 'Share & Support',
                        ),
                        const SizedBox(height: 12),
                        _ProfileMenuItem(
                          icon: Icons.share_rounded,
                          iconBgColor: const Color(0xFF2DD4BF),
                          title: lang == 'tr'
                              ? 'Arkadaşlarınla Paylaş'
                              : 'Share with Friends',
                          onTap: _shareApp,
                        ),
                        const SizedBox(height: 10),
                        _ProfileMenuItem(
                          icon: Icons.star_border_rounded,
                          iconBgColor: const Color(0xFFFFD166),
                          title: lang == 'tr'
                              ? 'Uygulamayı Değerlendir'
                              : 'Rate the App',
                          onTap: _rateApp,
                        ),
                        const SizedBox(height: 10),
                        _ProfileMenuItem(
                          icon: Icons.help_outline_rounded,
                          iconBgColor: const Color(0xFFC084FC),
                          title: lang == 'tr'
                              ? 'Yardım Merkezi'
                              : 'Help Center',
                          onTap: _openHelpCenter,
                        ),

                        const SizedBox(height: 32),

                        // ── 5. YASAL ──
                        _SectionLabel(lang == 'tr' ? 'Yasal' : 'Legal'),
                        const SizedBox(height: 12),
                        _ProfileMenuItem(
                          icon: Icons.shield_outlined,
                          iconBgColor: const Color(0xFF4CAF50),
                          title: lang == 'tr'
                              ? 'Gizlilik Politikası'
                              : 'Privacy Policy',
                          onTap: _openPrivacyPolicy,
                        ),
                        const SizedBox(height: 10),
                        _ProfileMenuItem(
                          icon: Icons.description_outlined,
                          iconBgColor: const Color(0xFF78909C),
                          title: lang == 'tr'
                              ? 'Kullanım Koşulları'
                              : 'Terms of Service',
                          onTap: _openTermsOfService,
                        ),

                        const SizedBox(height: 32),

                        // ── 6. ÇIKIŞ YAP ──
                        _ProfileMenuItem(
                          icon: Icons.logout_rounded,
                          iconBgColor: const Color(0xFFFF4D4D),
                          title: lang == 'tr' ? 'Çıkış Yap' : 'Sign Out',
                          isDestructive: true,
                          onTap: _signOut,
                        ),

                        const SizedBox(height: 40),

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
                        const SizedBox(height: 8),
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
// PROFİL KARTI (Avatar + İsim + Level + 4 İstatistik)
// ═══════════════════════════════════════════════════════════════

class _ProfileCard extends StatelessWidget {
  final String userName;
  final String userAvatar;
  final String levelTitle;
  final int totalCookies;
  final int totalTarots;
  final int totalDreams;
  final int streakDays;
  final bool isLoading;
  final VoidCallback onEditTap;
  final String cookieLabel;
  final String tarotLabel;
  final String dreamLabel;
  final String streakLabel;

  const _ProfileCard({
    required this.userName,
    required this.userAvatar,
    required this.levelTitle,
    required this.totalCookies,
    required this.totalTarots,
    required this.totalDreams,
    required this.streakDays,
    required this.isLoading,
    required this.onEditTap,
    required this.cookieLabel,
    required this.tarotLabel,
    required this.dreamLabel,
    required this.streakLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayName = userName.isNotEmpty ? userName : l10n.profileUserTitle;

    return GlassCard(
      useOwnLayer: true,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      shape: const LiquidRoundedSuperellipse(borderRadius: 28),
      settings: const LiquidGlassSettings(
        thickness: 30,
        blur: 8,
        glassColor: Colors.transparent,
        chromaticAberration: 0.15,
        lightIntensity: 0.8,
        ambientStrength: 0.7,
        refractiveIndex: 1.3,
        saturation: 1.1,
      ),
      child: Column(
        children: [
          // ── Avatar ──
          GestureDetector(
            onTap: onEditTap,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer Glow
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryOrange.withOpacity(0.25),
                        blurRadius: 32,
                        spreadRadius: 8,
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 60,
                        spreadRadius: 15,
                      ),
                    ],
                  ),
                ),
                // Inner Glass Ring
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryOrange.withOpacity(0.35),
                      width: 2.5,
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 16,
                        spreadRadius: -4,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Image.asset(
                        userAvatar,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                // Tiny Edit Badge
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1F2A),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.edit_rounded,
                        color: AppColors.primaryOrange.withOpacity(0.9),
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── İsim (düzenlenebilir) ──
          GestureDetector(
            onTap: onEditTap,
            child: Text(
              displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFFFD166),
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // ── Level başlığı ──
          Text(
            levelTitle,
            style: TextStyle(
              color: AppColors.textWhite.withOpacity(0.55),
              fontSize: 13,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 28),

          // ── 4 İstatistik ──
          if (isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textWhite.withOpacity(0.3),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: _ProfileStat(
                    value: totalCookies,
                    label: cookieLabel,
                    icon: Icons.bakery_dining_rounded,
                  ),
                ),
                _VerticalDivider(),
                Expanded(
                  child: _ProfileStat(
                    value: totalTarots,
                    label: tarotLabel,
                    icon: Icons.auto_awesome_rounded,
                  ),
                ),
                _VerticalDivider(),
                Expanded(
                  child: _ProfileStat(
                    value: totalDreams,
                    label: dreamLabel,
                    icon: Icons.nights_stay_rounded,
                  ),
                ),
                _VerticalDivider(),
                Expanded(
                  child: _ProfileStat(
                    value: streakDays,
                    label: streakLabel,
                    icon: Icons.local_fire_department_rounded,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white.withOpacity(0.08),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final int value;
  final String label;
  final IconData icon;

  const _ProfileStat({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: value),
          duration: const Duration(milliseconds: 1600),
          curve: Curves.easeOutCubic,
          builder: (context, val, child) {
            return Text(
              val.toString(),
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            );
          },
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: AppColors.textWhite.withOpacity(0.55),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textWhite.withOpacity(0.45),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ],
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

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final String title;
  final String? trailing;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileMenuItem({
    required this.icon,
    required this.iconBgColor,
    required this.title,
    required this.onTap,
    this.trailing,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.05),
              Colors.white.withOpacity(0.01),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    iconBgColor.withOpacity(0.25),
                    iconBgColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: iconBgColor.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: iconBgColor.withOpacity(0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Center(
                child: Icon(icon, color: iconBgColor.withOpacity(0.9), size: 20),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isDestructive
                      ? const Color(0xFFFF4D4D)
                      : AppColors.textWhite.withOpacity(0.95),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            if (trailing != null) ...[
              Text(
                trailing!,
                style: TextStyle(
                  color: AppColors.textWhite.withOpacity(0.4),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textWhite.withOpacity(0.2),
              size: 14,
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
