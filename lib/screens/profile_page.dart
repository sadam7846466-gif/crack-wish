import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';
import '../constants/colors.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/fade_page_route.dart';
import '../widgets/glass_back_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'premium_paywall_page.dart';
import 'welcome_screen.dart';
import 'notification_settings_page.dart';
import 'home_page.dart';
import 'onboarding_page.dart';
import 'collection_page.dart';
import '../services/locale_controller.dart';
import '../services/storage_service.dart';
import '../widgets/cosmic_badge.dart';
import '../services/mock_owl_service.dart';
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
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  static final _mottledPainter = _MottledPainter();
  int _currentNavIndex = 2;

  // ── Gerçek kullanıcı verileri ──
  String _userName = '';
  String _userAvatar = 'assets/images/owl.webp';
  int _unreadOwlCount = 0;
  int _totalCookies = 0;
  int _totalTarots = 0;
  int _totalDreams = 0;
  int _streakDays = 0;
  int _spentAura = 0; // Ruh Taşı çeviriminde harcanmış Aura
  int _bonusAura = 0; // Günlük takvimden ve hedeflerden gelen ekstra Aura
  bool _isLoading = true;
  bool _isPremiumUser = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
    MockOwlService().addListener(_onMockOwlUpdate);
  }

  void _onMockOwlUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    MockOwlService().removeListener(_onMockOwlUpdate);
    super.dispose();
  }

  Future<void> loadUserData() async {
    final snapshot = await StorageService.getUserSnapshot();
    final streak = await StorageService.getStreakDays();
    final avatar = await StorageService.getAvatar() ?? 'assets/images/owl.webp';
    final bonusAura = await StorageService.getDailyBonusAura();
    final prefs = await SharedPreferences.getInstance();
    
    final spentAura = await StorageService.getSpentAura();
    final tarotCount = await UserStatsService.getTotalTarotReadings();
    final unreadOwl = await StorageService.getUnreadOwlLetterCount();
    if (!mounted) return;
    setState(() {
      _userName = (snapshot['userName'] as String?) ?? '';
      _totalCookies = (snapshot['totalCookies'] as int?) ?? 0;
      _totalTarots = tarotCount;
      _totalDreams = (snapshot['totalDreams'] as int?) ?? 0;
      _spentAura = spentAura;
      _bonusAura = bonusAura;
      _streakDays = streak;
      _userAvatar = avatar;
      _unreadOwlCount = unreadOwl;
      _isLoading = false;
      _isPremiumUser = prefs.getBool('is_premium_test_mode') ?? false;
    });

    // Günlük Elite Ruh Taşlarını yenile (merkezi sistem)
    await StorageService.getSoulStones();
  }

  // ── Kullanıcı seviyesi hesapla (Aura bazlı) ──
  // Emoji yerine Material Icon kullanıyoruz — her cihazda çalışır.
  ({IconData icon, Color color, String title}) _getUserLevel(String lang) {
    // YENİ SİSTEM: Aura doğrudan eklentiler yerine, sadece toplanan (_bonusAura) havuzundan okunur.
    final int aura = _bonusAura;
    
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
      'assets/images/owl.png',
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
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
                      border: Border.all(color: Colors.white.withOpacity(0.25), width: 0.5),
                    ),
                    padding: const EdgeInsets.fromLTRB(28, 16, 28, 36),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 48,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          lang == 'tr' ? 'Profilini Düzenle' : 'Edit Profile',
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          lang == 'tr'
                              ? 'Sihirli avatarını seç.'
                              : 'Choose your magical avatar.',
                          style: TextStyle(
                            color: AppColors.textWhite.withOpacity(0.5),
                            fontSize: 15,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 36),
                        
                        // Avatar Seçimi
                        SizedBox(
                          height: 104,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: avatars.length,
                            physics: const BouncingScrollPhysics(),
                            clipBehavior: Clip.none,
                            itemBuilder: (context, index) {
                              final avatar = avatars[index];
                              final isSelected = avatar == selectedAvatar;
                              return GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setModalState(() => selectedAvatar = avatar);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutCubic,
                                  margin: const EdgeInsets.only(right: 20),
                                  width: isSelected ? 104 : 90,
                                  height: isSelected ? 104 : 90,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? AppColors.primaryOrange.withOpacity(0.9) : Colors.white.withOpacity(0.08),
                                      width: isSelected ? 3 : 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primaryOrange.withOpacity(0.35),
                                              blurRadius: 24,
                                              spreadRadius: 4,
                                            )
                                          ]
                                        : [],
                                    gradient: LinearGradient(
                                      colors: isSelected
                                          ? [
                                              AppColors.primaryOrange.withOpacity(0.15),
                                              Colors.black.withOpacity(0.3),
                                            ]
                                          : [
                                              Colors.white.withOpacity(0.08),
                                              Colors.white.withOpacity(0.02),
                                            ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                        avatar.contains('owl')
                                            ? (isSelected ? 2.0 : 6.0)
                                            : avatar.contains('cookies')
                                                ? (isSelected ? 16.0 : 20.0)
                                                : 0.0,
                                      ),
                                      child: Transform.scale(
                                        scale: avatar.contains('owl') ? 1.35 : 1.0,
                                        child: Image.asset(
                                          avatar,
                                          fit: (avatar.contains('cookies') || avatar.contains('owl'))
                                              ? BoxFit.contain
                                              : BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // İsim Düzenleme Alanı
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: TextField(
                            controller: controller,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            cursorColor: AppColors.primaryOrange,
                            decoration: InputDecoration(
                              hintText: lang == 'tr' ? 'Kozmik Adın' : 'Cosmic Name',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                              prefixIcon: Icon(Icons.person_outline_rounded, color: Colors.white.withOpacity(0.4)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Kaydet Butonu
                        GestureDetector(
                          onTap: () async {
                            HapticFeedback.mediumImpact();
                            
                            final newName = controller.text.trim();
                            if (newName.isNotEmpty) {
                              await StorageService.setUserName(newName);
                            }
                            await StorageService.setAvatar(selectedAvatar);

                            if (mounted) {
                              setState(() {
                                _userAvatar = selectedAvatar;
                                if (newName.isNotEmpty) {
                                  _userName = newName;
                                }
                              });
                            }
                            if (ctx.mounted) Navigator.pop(ctx);
                          },
                          child: Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primaryOrange,
                                  Color(0xFFFF7A00),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryOrange.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                )
                              ],
                            ),
                            child: Center(
                              child: Text(
                                lang == 'tr' ? 'Mührü Onayla' : 'Seal Profile',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
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

  // ── Kozmik Harita (Otomatik Burç Hesaplayıcı) ──
  void _openCosmicChart() async {
    final lang = Localizations.localeOf(context).languageCode;
    final savedBirthDate = await StorageService.getBirthDate();

    if (!mounted) return;

    DateTime? currentBirthDate = savedBirthDate;

    String getWesternZodiac(DateTime? d) {
      if (d == null) return lang == 'tr' ? 'Sır' : 'Secret';
      final month = d.month;
      final day = d.day;
      final signs = lang == 'tr'
          ? ['Oğlak', 'Kova', 'Balık', 'Koç', 'Boğa', 'İkizler', 'Yengeç', 'Aslan', 'Başak', 'Terazi', 'Akrep', 'Yay', 'Oğlak']
          : ['Capricorn', 'Aquarius', 'Pisces', 'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 'Libra', 'Scorpio', 'Sagittarius', 'Capricorn'];
      const cutoffs = [20, 19, 20, 20, 21, 21, 23, 23, 23, 23, 22, 22];
      return day < cutoffs[month - 1] ? signs[month - 1] : signs[month];
    }

    String getChineseZodiac(DateTime? d) {
      if (d == null) return lang == 'tr' ? 'Sır' : 'Secret';
      final animals = lang == 'tr'
          ? ['Fare', 'Öküz', 'Kaplan', 'Tavşan', 'Ejderha', 'Yılan', 'At', 'Keçi', 'Maymun', 'Horoz', 'Köpek', 'Domuz']
          : ['Rat', 'Ox', 'Tiger', 'Rabbit', 'Dragon', 'Snake', 'Horse', 'Goat', 'Monkey', 'Rooster', 'Dog', 'Pig'];
      // Very basic approximation: (Year - 4) % 12
      return animals[(d.year - 4) % 12];
    }

    String getMayanZodiac(DateTime? d) {
      if (d == null) return lang == 'tr' ? 'Sır' : 'Secret';
      final mayanSigns = lang == 'tr'
          ? ['Timsah', 'Rüzgar', 'Gece', 'Tohum', 'Yılan', 'Ölüm', 'Geyik', 'Yıldız', 'Su', 'Köpek', 'Maymun', 'Yol', 'Saz', 'Jaguar', 'Kartal', 'Baykuş', 'Toprak', 'Ayna', 'Fırtına', 'Güneş']
          : ['Crocodile', 'Wind', 'Night', 'Seed', 'Serpent', 'Death', 'Deer', 'Star', 'Water', 'Dog', 'Monkey', 'Road', 'Reed', 'Jaguar', 'Eagle', 'Owl', 'Earth', 'Mirror', 'Storm', 'Sun'];
      // Just a pseudo-calculation for fun, a real Tzolk'in requires complex math
      final pseudoIndex = (d.month * d.day + d.year) % 20;
      return mayanSigns[pseudoIndex];
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
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF16151A).withOpacity(0.85),
                    const Color(0xFF0D0C11).withOpacity(0.95),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              padding: const EdgeInsets.fromLTRB(28, 16, 28, 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    lang == 'tr' ? 'Kozmik Haritan' : 'Cosmic Chart',
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lang == 'tr'
                        ? 'Dünyaya iniş tarihini gir, evrensel sırlarını çözelim.'
                        : 'Enter your arrival date, let cosmos reveal your secrets.',
                    style: TextStyle(
                      color: AppColors.textWhite.withOpacity(0.5),
                      fontSize: 14,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Doğum Tarihi Seçici Row
                  _SettingsRow(
                    icon: Icons.calendar_month_rounded,
                    label: lang == 'tr' ? 'Dünyaya İniş' : 'Arrival Date',
                    value: currentBirthDate == null
                        ? (lang == 'tr' ? 'Belirle' : 'Set Date')
                        : '${currentBirthDate!.day.toString().padLeft(2, '0')}.${currentBirthDate!.month.toString().padLeft(2, '0')}.${currentBirthDate!.year}',
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: currentBirthDate ?? DateTime(2000, 1, 1),
                        firstDate: DateTime(1920),
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
                        await StorageService.setZodiacSign(getWesternZodiac(picked));
                        setModalState(() => currentBirthDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Kozmik Sonuçlar (Only show if date is selected)
                  if (currentBirthDate != null)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Column(
                        children: [
                          _buildZodiacInfo(
                            icon: Icons.auto_awesome_rounded,
                            title: lang == 'tr' ? 'Batı Astrolojisi' : 'Western Zodiac',
                            value: getWesternZodiac(currentBirthDate),
                            color: const Color(0xFFC084FC),
                          ),
                          const Divider(height: 32, color: Colors.white10),
                          _buildZodiacInfo(
                            icon: Icons.pentagon_rounded,
                            title: lang == 'tr' ? 'Çin Burcu' : 'Chinese Zodiac',
                            value: getChineseZodiac(currentBirthDate),
                            color: const Color(0xFFFF6B6B),
                          ),
                          const Divider(height: 32, color: Colors.white10),
                          _buildZodiacInfo(
                            icon: Icons.light_mode_rounded,
                            title: lang == 'tr' ? 'Maya İşareti' : 'Mayan Sign',
                            value: getMayanZodiac(currentBirthDate),
                            color: const Color(0xFF2DD4BF),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildZodiacInfo({required IconData icon, required String title, required String value, required Color color}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ],
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
                      onTap: () async {
                        Navigator.pop(ctx);
                        
                        // Clear Supabase session if any
                        try {
                          await Supabase.instance.client.auth.signOut();
                        } catch(e) {
                          debugPrint("SignOut Error: $e");
                        }
                        
                        // Reset Welcome state
                        await StorageService.setHasSeenWelcome(false);
                        
                        // Navigate to WelcomeScreen and reset stack
                        if (mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => const WelcomeScreen(),
                              transitionsBuilder: (_, anim, __, child) =>
                                  FadeTransition(opacity: anim, child: child),
                              transitionDuration: const Duration(milliseconds: 600),
                            ),
                            (route) => false,
                          );
                        }
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
                            return ValueListenableBuilder<int>(
                              valueListenable: StorageService.soulStonesNotifier,
                              builder: (context, currentSoulStones, child) {
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
                                  soulStones: currentSoulStones,
                                  spentAura: _spentAura,
                                  bonusAura: _bonusAura,
                                  onConvertAura: () async {
                                    final int multiplier = _isPremiumUser ? 3 : 1;
                                    final int baseAura = (_totalCookies * 1) + (_totalTarots * 2) + (_totalDreams * 3) + (_streakDays * 5);
                                    final totalAura = (baseAura * multiplier) + _bonusAura;
                                    final success = await StorageService.convertAuraToSoulStone(currentTotalAura: totalAura, cost: 200);
                                    if (success && mounted) {
                                      setState(() {
                                        _spentAura += 200;
                                      });
                                      HapticFeedback.heavyImpact();
                                    }
                                    return success;
                                  },
                                  onAuraClaimed: () {
                                    // Bize lazım olan yeni Aura bilgisini yeniden yüklemek
                                    loadUserData();
                                  },
                                  onRefresh: () => loadUserData(),
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // ── 3. PREMİUM BANNER ──
                        _BentoPremiumBanner(
                          lang: lang,
                          isPremium: _isPremiumUser,
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
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.clear(); // TAMAMEN SIFIRLA (Borçlar, isim vs her şey)!
                            if (mounted) {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const WelcomeScreen()));
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.redAccent),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '🛠️ TEST (Profili Sıfırla): Login Ekranına Git',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── 4. QUICK ACTIONS (2x2 Bento Grid) ──
                        _SectionLabel(lang == 'tr' ? 'Genel' : 'General'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _BentoActionTile(
                                icon: Icons.local_post_office_rounded,
                                iconColor: const Color(0xFFD4AF37), // Altın rengi Baykuş Postası
                                label: lang == 'tr' ? 'Baykuş Postası' : 'Owl Mail',
                                hasBadge: _unreadOwlCount > 0 || MockOwlService().pendingRequestCount > 0 || MockOwlService().unreadLetterCount > 0,
                                onTap: () {
                                  // TODO: Arkadaş Ekle / Kurabiye Gönder modalı eklenecek
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        lang == 'tr' ? 'Baykuş postası hazırlanıyor! Yakında...' : 'Owl mail is preparing! Coming soon...',
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                      backgroundColor: const Color(0xFF16151A),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _BentoActionTile(
                                icon: Icons.insights_rounded,
                                iconColor: const Color(0xFFC084FC),
                                label: lang == 'tr' ? 'Kozmik Haritan' : 'Cosmic Chart',
                                onTap: _openCosmicChart,
                              ),
                            ),
                          ],
                        ),
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
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _BentoActionTile(
                                icon: Icons.logout_rounded,
                                iconColor: const Color(0xFFFF4D4D),
                                label: lang == 'tr' ? 'Çıkış' : 'Sign Out',
                                onTap: _signOut,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // ── DEV ──
                        _SectionLabel('Dahili Test (Sonra Silinecek)'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _BentoActionTile(
                                icon: Icons.rocket_launch_rounded,
                                iconColor: const Color(0xFFF7941D),
                                label: 'Onboarding Test',
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OnboardingPage()));
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _BentoActionTile(
                                icon: Icons.local_fire_department_rounded,
                                iconColor: const Color(0xFFFF6B6B),
                                label: 'Seri (Ateş) Ekle',
                                onTap: () async {
                                  final prefs = await SharedPreferences.getInstance();
                                  final now = DateTime.now();
                                  final days = prefs.getStringList('app_open_days') ?? [];
                                  final claimed = prefs.getStringList('claimed_aura_days') ?? [];
                                  
                                  // Geçmiş 5 gün ekle ve claim durumlarını sıfırla:
                                  for (int i = 1; i <= 5; i++) {
                                    final d = now.subtract(Duration(days: i));
                                    final key = "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
                                    if (!days.contains(key)) {
                                      days.add(key);
                                    }
                                    claimed.remove(key); // Test için toplanmamış hale getir
                                  }
                                  
                                  await prefs.setStringList('app_open_days', days);
                                  await prefs.setStringList('claimed_aura_days', claimed);
                                  await prefs.setInt('app_streak_days', 7); // Seri sayısını da 7 yapalım ki profilde görünsün
                                  
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Geçmiş 5 gün test için eklendi! Yenilemek için Profil sayfasına tekrar tıklayın.")),
                                    );
                                  }
                                },
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
  final int bonusAura;
  final Future<bool> Function() onConvertAura;
  final VoidCallback? onAuraClaimed;
  final VoidCallback? onRefresh;

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
    required this.bonusAura,
    required this.onConvertAura,
    this.onAuraClaimed,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = userName.isNotEmpty ? userName : profileTitle;
    
    // YENİ SİSTEM: Tüm kazanılan ve toplanan Aura sadece bonusAura havuzunda saklanır.
    final int auraPoints = bonusAura;
    final int rawAvail = auraPoints - spentAura; 
    final int availableAura = rawAvail < 0 ? 0 : rawAvail;
    
    final String formattedAura = availableAura >= 1000 
        ? '${(availableAura / 1000).toStringAsFixed(1)}k' 
        : availableAura.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 36),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36),
          color: const Color(0xFF1E1E1E).withOpacity(0.55),
          border: Border.all(
            color: Colors.white.withOpacity(0.12),
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
            child: Column(
              children: [
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

                _BentoTouch(
                  onTap: onEditTap,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
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
                              padding: EdgeInsets.all(
                                userAvatar.contains('owl')
                                    ? 4.0 // Baykuş avatarı pofuduk olduğu için paddingi sıfıra yaklaştırdım
                                    : userAvatar.contains('cookies')
                                        ? 22.0
                                        : 0.0,
                              ),
                              child: Transform.scale(
                                scale: userAvatar.contains('owl') ? 1.35 : 1.0,
                                child: Image.asset(
                                  userAvatar,
                                  fit: (userAvatar.contains('cookies') || userAvatar.contains('owl'))
                                      ? BoxFit.contain
                                      : BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _BentoTouch(
                  onTap: onEditTap,
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FutureBuilder<List<dynamic>>(
                      future: Future.wait([
                        StorageService.getClaimedAuraSources(),
                        StorageService.getPendingAura('fal'),
                        StorageService.getPendingAura('kurabiye'),
                        StorageService.getPendingAura('ruya'),
                        StorageService.getPendingAura('baykus'),
                      ]),
                      builder: (context, snapshot) {
                        bool hasUnclaimed = false;
                        if (snapshot.hasData) {
                          final claimed = snapshot.data![0] as Set<String>;
                          final pendingFal = snapshot.data![1] as int;
                          final pendingCookie = snapshot.data![2] as int;
                          final pendingDream = snapshot.data![3] as int;
                          final pendingOwl = snapshot.data![4] as int;
                          // Nokta sadece gerçekten toplanacak Aura varsa yansın
                          hasUnclaimed = (!claimed.contains('fal') && pendingFal > 0) ||
                              (!claimed.contains('kurabiye') && pendingCookie > 0) ||
                              (!claimed.contains('ruya') && pendingDream > 0) ||
                              (!claimed.contains('baykus') && pendingOwl > 0);
                        }
                        return _GlassBadge(
                          imagePath: 'assets/images/aura_core.png',
                          label: "$formattedAura Aura",
                          color: const Color(0xFFC084FC),
                          hasNotification: hasUnclaimed,
                          onTap: () => _showStatModal(context, "Aura Puanı", availableAura, Icons.auto_awesome, const Color(0xFFC084FC)),
                        );
                      },
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
                const SizedBox(height: 38),
              ],
            ),
          ),
        ),
      ),
    ),
  ),

    Positioned(
      bottom: 0,
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
                FutureBuilder<bool>(
                  future: StorageService.hasUnseenCookies(),
                  builder: (context, snap) {
                    final hasNew = snap.data ?? false;
                    return _HeroStatCircle(
                      icon: Icons.bakery_dining_rounded,
                      iconColor: const Color(0xFFFFD166),
                      imagePath: 'assets/icons/splash_cookie.png',
                      value: totalCookies,
                      hasDot: hasNew,
                      onTap: () => _showStatModal(context, "Açılan Kurabiyeler", totalCookies, Icons.bakery_dining_rounded, const Color(0xFFFFD166)),
                    );
                  },
                ),
                _HeroStatCircle(
                  icon: Icons.amp_stories_rounded,
                  iconColor: const Color(0xFFC084FC),
                  value: totalTarots,
                  isLocked: !isPremium,
                  onTap: () => _showStatModal(context, "Tarot Falları", totalTarots, Icons.amp_stories_rounded, const Color(0xFFC084FC)),
                ),
                _HeroStatCircle(
                  icon: Icons.nights_stay_rounded,
                  iconColor: const Color(0xFF5A8BFF),
                  value: totalDreams,
                  isLocked: !isPremium,
                  onTap: () => _showStatModal(context, "Rüya Analizleri", totalDreams, Icons.nights_stay_rounded, const Color(0xFF5A8BFF)),
                ),
                FutureBuilder<bool>(
                  future: _hasUnclaimedReward(streakDays),
                  builder: (context, snap) {
                    final hasReward = snap.data ?? false;
                    return _HeroStatCircle(
                      icon: Icons.local_fire_department_rounded,
                      iconColor: const Color(0xFFFF6B6B),
                      value: streakDays,
                      hasDot: hasReward,
                      onTap: () => _showStatModal(context, "Günlük Seri", streakDays, Icons.local_fire_department_rounded, const Color(0xFFFF6B6B)),
                    );
                  },
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

  static Future<bool> _hasUnclaimedReward(int streakDays) async {
    // Milestone eşikleri
    const thresholds = [7, 14, 30, 50, 100, 365];
    final claimed = await StorageService.getClaimedMilestones();
    for (final t in thresholds) {
      if (streakDays >= t && !claimed.contains(t)) return true;
    }
    
    // YENİ SİSTEM: Herhangi bir toplanmamış bekleyen (pending) Aura var mı?
    final fal = await StorageService.getPendingAura('fal');
    final cookie = await StorageService.getPendingAura('kurabiye');
    final dream = await StorageService.getPendingAura('ruya');
    final owl = await StorageService.getPendingAura('baykus');
    
    if (fal > 0 || cookie > 0 || dream > 0 || owl > 0) return true;
    
    return false;
  }

  void _showStatModal(BuildContext context, String title, int value, IconData icon, Color color) async {
    // YENİ SİSTEM: Tüm kazanımlar sadece "bonusAura" (toplanan aura havuzu) üzerinden okunur.
    // Doğrudan geçmiş verilerden Aura Puanı çarpanı kaldırıldı.
    int modalAuraTotal = bonusAura;
    int modalSpentAura = spentAura;
    int modalSoulStones = soulStones;
    const int conversionCost = 200;
    bool showSuccess = false;

    int selectedStoreIndex = -1;
    
    // Anlık olarak StorageService'dan çekilecek bekleyen aura değerleri
    int pendingFal = 0;
    int pendingKurabiye = 0;
    int pendingRuya = 0;
    int pendingBaykus = 0;
    int pendingZodiac = 0;
    
    int collectedBonus = 0;
    bool sourcesLoaded = false;
    
    int dreamTimeFilter = 7;

    await showGeneralDialog(
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
            // İlk açılışta diskten bekleyen auraları yükle
            if (!sourcesLoaded) {
              sourcesLoaded = true;
              Future.wait([
                StorageService.getPendingAura('fal'),
                StorageService.getPendingAura('kurabiye'),
                StorageService.getPendingAura('ruya'),
                StorageService.getPendingAura('baykus'),
                StorageService.getPendingAura('zodiac'),
              ]).then((results) {
                setModalState(() {
                  pendingFal = results[0];
                  pendingKurabiye = results[1];
                  pendingRuya = results[2];
                  pendingBaykus = results[3];
                  pendingZodiac = results[4];
                });
              });
            }
            final int baseAvailable = (modalAuraTotal - modalSpentAura).clamp(0, 999999);
            final int availableAura = baseAvailable + collectedBonus;
            final bool canConvert = availableAura >= conversionCost;

            return GestureDetector(
              onTap: () => Navigator.pop(context),
              child: GestureDetector(
              onTap: () {}, // içeriğe tıklayınca modal kapanmasın
              child: Container(
                width: 320,
                height: 320,
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
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Colors.white.withOpacity(0.25), width: 0.5),
                      ),
                      child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    if (title == "Aura Puanı")
                      Image.asset("assets/images/aura_core.png", width: 56, height: 56, fit: BoxFit.contain)
                    else if (title == "Açılan Kurabiyeler")
                      Image.asset("assets/icons/splash_cookie.png", width: 48, height: 48, fit: BoxFit.contain)
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
                          Text("${value}", style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: 1)),
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

                    if (title == "Aura Puanı") ...[
                      Column(
                        children: [
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
                                              canConvert ? "Ruh Taşına Çevir" : "Yetersiz Aura ($availableAura/200)",
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

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedScale(
                            scale: showSuccess ? 1.3 : 1.0,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutBack,
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
                      const SizedBox(height: 4),


                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
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
                              _buildAuraSource(Icons.nights_stay_rounded, "Rüya", pendingRuya, () {
                                if (pendingRuya == 0) return;
                                HapticFeedback.heavyImpact();
                                final pts = pendingRuya;
                                setModalState(() {
                                  pendingRuya = 0;
                                  collectedBonus += pts;
                                  modalAuraTotal += pts;
                                });
                                StorageService.clearPendingAura('ruya');
                                StorageService.addBonusAura(pts);
                                onAuraClaimed?.call();
                              }, color: const Color(0xFF5A8BFF)),
                              _buildAuraSource(Icons.amp_stories_rounded, "Tarot", pendingFal, () {
                                if (pendingFal == 0) return;
                                HapticFeedback.heavyImpact();
                                final pts = pendingFal;
                                setModalState(() {
                                  pendingFal = 0;
                                  collectedBonus += pts;
                                  modalAuraTotal += pts;
                                });
                                StorageService.clearPendingAura('fal');
                                StorageService.addBonusAura(pts);
                                onAuraClaimed?.call();
                              }, color: const Color(0xFFC084FC)),
                              _buildAuraSource(Icons.data_usage_rounded, "Burç", pendingZodiac, () {
                                if (pendingZodiac == 0) return;
                                HapticFeedback.heavyImpact();
                                final pts = pendingZodiac;
                                setModalState(() {
                                  pendingZodiac = 0;
                                  collectedBonus += pts;
                                  modalAuraTotal += pts;
                                });
                                StorageService.clearPendingAura('zodiac');
                                StorageService.addBonusAura(pts);
                                onAuraClaimed?.call();
                              }, color: const Color(0xFFFFD700)),
                              _buildAuraSource(Icons.cookie, "Kurabiye", pendingKurabiye, () {
                                if (pendingKurabiye == 0) return;
                                HapticFeedback.heavyImpact();
                                final pts = pendingKurabiye;
                                setModalState(() {
                                  pendingKurabiye = 0;
                                  collectedBonus += pts;
                                  modalAuraTotal += pts;
                                });
                                StorageService.clearPendingAura('kurabiye');
                                StorageService.addBonusAura(pts);
                                onAuraClaimed?.call();
                              }, color: const Color(0xFFFFD166), imagePath: 'assets/icons/splash_cookie.png'),
                              _buildAuraSource(Icons.mail_rounded, "Baykuş", pendingBaykus, () {
                                if (pendingBaykus == 0) return;
                                HapticFeedback.heavyImpact();
                                final pts = pendingBaykus;
                                setModalState(() {
                                  pendingBaykus = 0;
                                  collectedBonus += pts;
                                  modalAuraTotal += pts;
                                });
                                StorageService.clearPendingAura('baykus');
                                StorageService.addBonusAura(pts);
                                onAuraClaimed?.call();
                              }, color: const Color(0xFF4EE6C5)),
                              _buildAuraSource(Icons.diamond_rounded, "Ruh Taşı", 0, () {
                                HapticFeedback.selectionClick();
                              }, color: const Color(0xFF22D3EE)),
                            ],
                          ),
                        ),
                      ),

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

                    ] else if (title == "Açılan Kurabiyeler") ...[
                      const SizedBox(height: 4),
                      Expanded(child: const _ProfileCookieCarousel()),
                    ] else if (title == "Tarot Falları") ...[
                      const SizedBox(height: 4),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 4,
                              child: FutureBuilder<SignatureResult?>(
                                future: UserStatsService.getSignatureCard(),
                                builder: (context, snapshot) {
                                  final result = snapshot.data;
                                  final bool isLocked = result == null;
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
                                    
                                    final allAssets = getAllCardAssets();
                                    
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
                      FutureBuilder<List<dynamic>>(
                        future: Future.wait([
                          StorageService.getInstallDate(),
                          StorageService.getAppOpenDays(),
                          StorageService.getClaimedAuraDays(),
                        ]),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xFFFF6B6B))));
                          }
                          
                          final installDate = snapshot.data![0] as DateTime;
                          final appOpenDays = snapshot.data![1] as Set<String>;
                          final claimedDays = snapshot.data![2] as Set<String>;
                          final now = DateTime.now();
                          final nowNorm = DateTime(now.year, now.month, now.day);
                          
                          int totalMonths = (now.year - installDate.year) * 12 + now.month - installDate.month + 1;
                          if (totalMonths < 1) totalMonths = 1;

                          final totalOpenDays = appOpenDays.length;
                          int nextTarget = 7;
                          if (totalOpenDays >= 7) nextTarget = 14;
                          if (totalOpenDays >= 14) nextTarget = 30;
                          if (totalOpenDays >= 30) nextTarget = 50;
                          if (totalOpenDays >= 50) nextTarget = 100;
                          if (totalOpenDays >= 100) nextTarget = 365;

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
                                    Center(child: Text(day, style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 12, fontWeight: FontWeight.bold))),
                                  );
                                }

                                for (int i = 1; i < firstWeekday; i++) {
                                  calendarDays.add(const SizedBox());
                                }

                                for (int i = 1; i <= daysInMonth; i++) {
                                  final testDate = DateTime(targetYear, targetMonth, i);
                                  final isToday = testDate.year == nowNorm.year && testDate.month == nowNorm.month && testDate.day == nowNorm.day;
                                  final isFuture = testDate.isAfter(nowNorm);
                                  final dateKey = "${targetYear.toString().padLeft(4, '0')}-${targetMonth.toString().padLeft(2, '0')}-${i.toString().padLeft(2, '0')}";
                                  final isAppOpenDay = appOpenDays.contains(dateKey);
                                  final isClaimed = claimedDays.contains(dateKey);

                                  calendarDays.add(
                                    _ClaimableFireCell(
                                      day: i,
                                      isToday: isToday,
                                      isFuture: isFuture,
                                      isAppOpenDay: isAppOpenDay,
                                      isClaimed: isClaimed,
                                      dateKey: dateKey,
                                      onClaimed: () {
                                        setModalState(() {
                                          claimedDays.add(dateKey);
                                          modalAuraTotal += 1;
                                        });
                                        if (onAuraClaimed != null) {
                                          onAuraClaimed!();
                                        }
                                      },
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
                                            Text("${monthNames[targetMonth - 1]} $targetYear", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                            Row(
                                              children: [
                                                const Icon(Icons.local_fire_department_rounded, color: Color(0xFFFF6B6B), size: 12),
                                                const SizedBox(width: 4),
                                                Text("$nextTarget Gün Hedefi", style: TextStyle(color: const Color(0xFFFF6B6B).withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.w600)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            final rowCount = (calendarDays.length / 7).ceil();
                                            const spacing = 5.0;
                                            final totalSpacing = spacing * (rowCount - 1);
                                            double itemHeight = (constraints.maxHeight - totalSpacing) / rowCount;

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
                                      const SizedBox(height: 6),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        }
                      ),
                      // ── Toplanmamış Milestone Ödülleri ──
                      FutureBuilder<List<int>>(
                        future: StorageService.getClaimedMilestones(),
                        builder: (context, milestoneSnap) {
                          final claimed = milestoneSnap.data ?? [];
                          const thresholds = [7, 14, 30, 50, 100, 365];
                          final rewards = <String, dynamic>{
                            '7': {'text': '+15 Aura', 'icon': Icons.auto_awesome, 'color': const Color(0xFFC084FC)},
                            '14': {'text': '+30 Aura', 'icon': Icons.auto_awesome, 'color': const Color(0xFFC084FC)},
                            '30': {'text': '+1 Ruh Taşı', 'icon': Icons.diamond_rounded, 'color': const Color(0xFF4EE6C5)},
                            '50': {'text': '+2 Ruh Taşı', 'icon': Icons.diamond_rounded, 'color': const Color(0xFF4EE6C5)},
                            '100': {'text': '+3 Ruh Taşı', 'icon': Icons.diamond_rounded, 'color': const Color(0xFF4EE6C5)},
                            '365': {'text': '+5 Ruh Taşı', 'icon': Icons.diamond_rounded, 'color': const Color(0xFF4EE6C5)},
                          };
                          final unclaimed = thresholds.where((t) => value >= t && !claimed.contains(t)).toList();
                          if (unclaimed.isEmpty) return const SizedBox.shrink();
                          return Column(
                            children: unclaimed.map((t) {
                              final r = rewards[t.toString()]!;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: GestureDetector(
                                  onTap: () async {
                                    HapticFeedback.heavyImpact();
                                    await StorageService.claimMilestone(t);
                                    setModalState(() {
                                      claimed.add(t);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: (r['color'] as Color).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: (r['color'] as Color).withOpacity(0.25), width: 0.5),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.local_fire_department_rounded, color: const Color(0xFFFF6B6B), size: 16),
                                        const SizedBox(width: 8),
                                        Text("$t Gün", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                                        const Spacer(),
                                        Icon(r['icon'] as IconData, color: r['color'] as Color, size: 14),
                                        const SizedBox(width: 4),
                                        Text(r['text'] as String, style: TextStyle(color: r['color'] as Color, fontSize: 11, fontWeight: FontWeight.bold)),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Text("Topla", style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ],
                 ),
              ),
             ),
            ),
            )
           )
           );
          },
        ),
      ),
    );
    // Modal kapandı — dış buton noktalarını güncelle
    if (onRefresh != null) onRefresh!();
  }

  Widget _buildAuraSource(IconData icon, String title, int unclaimedAura, VoidCallback onTap, {Color color = const Color(0xFF4EE6C5), String? imagePath, String? emoji}) {
    bool hasAura = unclaimedAura > 0;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 72,
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
                if (emoji != null)
                  Text(emoji, style: const TextStyle(fontSize: 18))
                else if (imagePath != null)
                  Transform.translate(
                    offset: const Offset(0, 1.5), // Görselin içindeki boşluktan kaynaklı yukarı kaymayı düzeltmek için
                    child: Transform.scale(
                      scale: 1.4, // PNG'nin iç boşluğundan dolayı küçük görünmesini telafi etmek için büyütme
                      child: Image.asset(
                        imagePath, 
                        width: 16, 
                        height: 16,
                        color: hasAura ? color : Colors.white.withOpacity(0.2),
                        colorBlendMode: BlendMode.srcIn,
                      ),
                    ),
                  )
                else
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
          color: isSelected ? color.withOpacity(0.2) : color.withOpacity(0.04),
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

class _GlassBadge extends StatelessWidget {
  final IconData? icon;
  final String? imagePath;
  final String label;
  final Color color;
  final bool hasNotification;
  final VoidCallback onTap;

  const _GlassBadge({
    this.icon,
    this.imagePath,
    required this.label,
    required this.color,
    this.hasNotification = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _BentoTouch(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
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
          // Bildirim noktası (toplanacak kaynak varsa)
          if (hasNotification)
            const Positioned(
              top: -2,
              right: 0,
              child: CosmicBadge(), // Ortak Zümrüt Yeşili rozet!
            ),
        ],
      ),
    );
  }
}

class _HeroStatCircle extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String? imagePath;
  final int value;
  final bool hasDot;
  final bool isLocked;
  final VoidCallback onTap;

  const _HeroStatCircle({
    required this.icon,
    required this.iconColor,
    this.imagePath,
    required this.value,
    this.hasDot = false,
    this.isLocked = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _BentoTouch(
      onTap: isLocked ? () => HapticFeedback.selectionClick() : onTap,
      child: Stack(
      clipBehavior: Clip.none,
      children: [
        ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1E1E1E).withOpacity(0.55),
                border: Border.all(
                  color: Colors.white.withOpacity(isLocked ? 0.06 : 0.12),
                  width: 0.5,
                ),
              ),
              child: ImageFiltered(
                imageFilter: isLocked 
                    ? ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5)
                    : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                child: Opacity(
                  opacity: isLocked ? 0.55 : 1.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 32,
                        child: Center(
                          child: imagePath != null
                            ? Image.asset(
                                imagePath!,
                                width: 36,
                                height: 36,
                                fit: BoxFit.contain,
                                color: iconColor,
                                errorBuilder: (_, __, ___) => Icon(icon, color: iconColor.withOpacity(0.95), size: 30),
                              )
                            : Icon(
                                icon, 
                                color: iconColor.withOpacity(0.95), 
                                size: icon == Icons.amp_stories_rounded ? 32 : 30,
                              ),
                        ),
                      ),
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
                              fontWeight: FontWeight.w400,
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
          ),
        ),
        if (hasDot && !isLocked)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFB347),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFB347).withOpacity(0.8),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.8),
                    blurRadius: 2,
                    spreadRadius: -1,
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
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () async {
        HapticFeedback.lightImpact(); 

        if (!_pressed && mounted) setState(() => _pressed = true);
        
        await Future.delayed(const Duration(milliseconds: 80));
        
        if (mounted) setState(() => _pressed = false);
        
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

class _BentoActionTile extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool compact;
  final bool hasBadge;

  const _BentoActionTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.compact = false,
    this.hasBadge = false,
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
              height: widget.compact ? 84 : 72,
              padding: EdgeInsets.symmetric(
                  horizontal: widget.compact ? 8 : 16,
                  vertical: widget.compact ? 12 : 0),
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
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: widget.iconColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              Icon(widget.icon, color: widget.iconColor.withValues(alpha: 0.85), size: 16),
                              if (widget.hasBadge)
                                const Positioned(
                                  top: -2,
                                  right: 0,
                                  child: CosmicBadge(), // Nokta formatında cosmic badge
                                ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          widget.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: widget.iconColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: widget.iconColor.withValues(alpha: 0.15),
                              width: 0.5,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              Icon(widget.icon, color: widget.iconColor.withValues(alpha: 0.85), size: 18),
                              if (widget.hasBadge)
                                const Positioned(
                                  top: -2,
                                  right: 0,
                                  child: CosmicBadge(), // Orijinal noktalardan şaşmıyoruz ama standart
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              if (widget.subtitle != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  widget.subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
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

class _BentoPremiumBanner extends StatefulWidget {
  final String lang;
  final bool isPremium;
  final VoidCallback onTap;

  const _BentoPremiumBanner({
    required this.lang,
    required this.isPremium,
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
                  colors: widget.isPremium
                      ? [
                          const Color(0xFF22D3EE).withOpacity(0.25),
                          const Color(0xFF14B8A6).withOpacity(0.10),
                          const Color(0xFF0EA5E9).withOpacity(0.08),
                        ]
                      : [
                          const Color(0xFFD4A574).withOpacity(0.25),
                          const Color(0xFFFFD166).withOpacity(0.10),
                          const Color(0xFFFF9A5C).withOpacity(0.08),
                        ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.isPremium
                      ? const Color(0xFF22D3EE).withOpacity(0.2)
                      : const Color(0xFFD4A574).withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.isPremium
                            ? [const Color(0xFF22D3EE), const Color(0xFF0EA5E9)]
                            : [const Color(0xFFD4A574), const Color(0xFFB8956A)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: widget.isPremium
                              ? const Color(0xFF22D3EE).withOpacity(0.3)
                              : const Color(0xFFD4A574).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        widget.isPremium ? Icons.diamond_rounded : Icons.workspace_premium_rounded,
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
                          widget.isPremium
                              ? (widget.lang == 'tr' ? 'Elite Büyücüsün' : 'You are Elite')
                              : (widget.lang == 'tr' ? 'Premium\'a Geç' : 'Go Premium'),
                          style: TextStyle(
                            color: widget.isPremium ? const Color(0xFF22D3EE) : const Color(0xFFD4A574),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.isPremium
                              ? (widget.lang == 'tr' ? 'Mistk kapılar emrinde' : 'Mystical gates await')
                              : (widget.lang == 'tr' ? 'Sınırsız kurabiye ve özel özellikler' : 'Unlimited cookies and exclusive features'),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!widget.isPremium)
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: const Color(0xFFD4A574).withOpacity(0.5),
                      size: 16,
                    ),
                  if (widget.isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22D3EE).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Aktif', style: TextStyle(color: Color(0xFF22D3EE), fontSize: 10, fontWeight: FontWeight.bold)),
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
  Set<String> _seenIds = {};
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
    owned.sort((a, b) => b.countObtained.compareTo(a.countObtained));
    final seen = await StorageService.getSeenCookieIds();
    if (mounted) {
      setState(() {
        _ownedCookies = owned;
        _seenIds = seen;
        _loading = false;
      });
    }
  }

  static const _cookieMeta = <String, Map<String, String>>{
    'spring_wreath': {'name': 'Bahar Çelengi', 'desc': 'Doğanın uyanışını simgeler. Taze başlangıçların habercisi.', 'rarity': 'Yaygın', 'quote': '"Her bahar, evren sana ikinci bir şans verir."'},
    'lucky_clover': {'name': 'Şanslı Yonca', 'desc': 'Dört yapraklı yonca — her yaprağı bir dilek taşır.', 'rarity': 'Yaygın', 'quote': '"Şans, hazırlığın fırsatla buluştuğu andır."'},
    'royal_hearts': {'name': 'Kraliyet Kalbi', 'desc': 'Sarayların gizli aşk notalarından ilham alır.', 'rarity': 'Nadir', 'quote': '"Gerçek zarafet, kalpten gelir."'},
    'evil_eye': {'name': 'Nazar Boncuğu', 'desc': 'Kötü bakışlara karşı kadim bir koruyucu.', 'rarity': 'Yaygın', 'quote': '"Seni koruyan görünmez bir kalkan her zaman var."'},
    'pizza_party': {'name': 'Pizza Partisi', 'desc': 'Neşe ve arkadaşlığın lezzetli kutlaması.', 'rarity': 'Yaygın', 'quote': '"Hayatın en güzel anları paylaşılanlardır."'},
    'sakura_bloom': {'name': 'Sakura Çiçeği', 'desc': 'Japon kiraz çiçeklerinin kısa ama büyüleyici dansı.', 'rarity': 'Nadir', 'quote': '"Güzellik geçicidir, ama anılar sonsuzdur."'},
    'blue_porcelain': {'name': 'Hanedan Porseleni', 'desc': 'Uzak Doğu\'nun kadim ejderha motifleriyle süslenmiş porselen.', 'rarity': 'Epik', 'quote': '"Kadim bilgelik, sabırla işlenen detaylarda gizlidir."'},
    'pink_blossom': {'name': 'Pembe Tomurcuk', 'desc': 'Baharın ilk açan çiçeği gibi taptaze.', 'rarity': 'Yaygın', 'quote': '"Küçük şeyler, büyük mutluluklar getirir."'},
    'fortune_cat': {'name': 'Şans Kedisi', 'desc': 'Maneki-neko — patiyle bereket çağırır.', 'rarity': 'Nadir', 'quote': '"Bereket kapını çalıyor, açmayı unutma."'},
    'wildflower': {'name': 'Kır Çiçeği', 'desc': 'Rüzgârın taşıdığı özgür ve vahşi güzellik.', 'rarity': 'Yaygın', 'quote': '"Özgürlük, ruhunun çiçek açmasıdır."'},
    'cupid_ribbon': {'name': 'Aşk Kurdelesi', 'desc': 'Cupid\'in okunu saran ipek kurdele.', 'rarity': 'Nadir', 'quote': '"Aşk, kelimelerin bıraktığı yerde başlar."'},
    'panda_bamboo': {'name': 'Panda Ormanı', 'desc': 'Bambu koruluğundaki huzurlu panda.', 'rarity': 'Yaygın', 'quote': '"Huzur, en büyük lükstür."'},
    'ramadan_cute': {'name': 'Ramazan Neşesi', 'desc': 'Hilal ve fenerlerle süslü kutsal bir gece.', 'rarity': 'Nadir', 'quote': '"Sabır eden, güzel günlere kavuşur."'},
    'enchanted_forest': {'name': 'Büyülü Orman', 'desc': 'Perilerin dans ettiği gizemli bir orman.', 'rarity': 'Epik', 'quote': '"Büyü, inanmaya cesaret edenler içindir."'},
    'golden_arabesque': {'name': 'Altın Arabesk', 'desc': 'İslam sanatının geometrik mükemmelliği.', 'rarity': 'Epik', 'quote': '"Sonsuzluk, bir desenin tekrarında gizlidir."'},
    'midnight_mosaic': {'name': 'Gece Mozaiği', 'desc': 'Gece yarısı gökyüzünden toplanan parçalar.', 'rarity': 'Epik', 'quote': '"Karanlık, yıldızları görmek için vardır."'},
    'pearl_lace': {'name': 'İnci Dantel', 'desc': 'Deniz kabuklarından süzülen zarif işçilik.', 'rarity': 'Nadir', 'quote': '"En değerli inciler, en derin sularda bulunur."'},
    'golden_sakura': {'name': 'Altın Sakura', 'desc': 'Altınla kaplanmış efsanevi kiraz çiçeği.', 'rarity': 'Efsanevi', 'quote': '"Efsaneler, sıradanlığı reddedenlerce yazılır."'},
    'dragon_phoenix': {'name': 'Ejder & Anka', 'desc': 'Ateş ve yeniden doğuşun kadim dansı.', 'rarity': 'Efsanevi', 'quote': '"Küllerin arasından yükselmek, kaderin ta kendisidir."'},
    'gold_beasts': {'name': 'Altın Canavarlar', 'desc': 'Mitolojinin en güçlü yaratıkları altınla buluşur.', 'rarity': 'Efsanevi', 'quote': '"Güç sahibi ol, ama merhametli kal."'},
  };

  static Color _rarityColor(String rarity) {
    switch (rarity) {
      case 'Efsanevi': return const Color(0xFFFFD700);
      case 'Epik': return const Color(0xFFC084FC);
      case 'Nadir': return const Color(0xFF60A5FA);
      default: return const Color(0xFF4EE6C5);
    }
  }

  void _showCookieActionMenu(CookieCard cookie, BuildContext context) {
    HapticFeedback.selectionClick();
    final meta = _cookieMeta[cookie.id] ?? {'name': 'Gizemli Kurabiye', 'desc': 'Bu kurabiye henüz keşfedilmemiş...', 'rarity': 'Yaygın'};
    final rarityColor = _rarityColor(meta['rarity']!);
    final firstDate = cookie.firstObtainedDate;
    final dateStr = firstDate != null ? "${firstDate.day.toString().padLeft(2, '0')}.${firstDate.month.toString().padLeft(2, '0')}.${firstDate.year}" : "—";

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1E).withOpacity(0.65),
              border: Border.all(color: Colors.white.withOpacity(0.12), width: 0.5),
              boxShadow: [
                BoxShadow(color: rarityColor.withOpacity(0.1), blurRadius: 40, spreadRadius: -5),
              ],
            ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Kurabiye görseli + glow
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: rarityColor.withOpacity(0.2), blurRadius: 30, spreadRadius: 2),
                  ],
                ),
                child: Image.asset(
                  'assets/images/cookies/${cookie.id}.webp',
                  errorBuilder: (_, __, ___) => Icon(Icons.bakery_dining_rounded, color: rarityColor, size: 48),
                ),
              ),
              const SizedBox(height: 16),
              // İsim
              Text(
                meta['name']!,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.3),
              ),
              const SizedBox(height: 6),
              // Nadirlik rozeti
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: rarityColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: rarityColor.withOpacity(0.3), width: 0.5),
                ),
                child: Text(
                  meta['rarity']!,
                  style: TextStyle(color: rarityColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
              const SizedBox(height: 14),
              // Açıklama
              Text(
                meta['desc']!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 13, height: 1.5, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 18),
              // Alt bilgi satırı
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today_rounded, color: Colors.white.withOpacity(0.3), size: 13),
                    const SizedBox(width: 6),
                    Text("İlk bulunma: $dateStr", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Mini bilgelik mesajı
              Text(
                meta['quote'] ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(color: rarityColor.withOpacity(0.7), fontSize: 11.5, height: 1.4, letterSpacing: 0.2),
              ),
            ],
          ),
        ),
       ),
      ),
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
                  onTap: () {
                    StorageService.markCookieSeen(cookie.id);
                    setState(() => _seenIds.add(cookie.id));
                    _showCookieActionMenu(cookie, context);
                  },
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
                      // 🔴 Yeni kurabiye noktası (görülmemişse)
                      if (!_seenIds.contains(cookie.id))
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFFFB347),
                              boxShadow: [
                                BoxShadow(color: const Color(0xFFFFB347).withOpacity(0.7), blurRadius: 6, spreadRadius: 1),
                              ],
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

// ═══════════════════════════════════════════════════════════════
// CLAIMABLE FIRE CELL (Takvim Ateş Hücresi — Tıklanabilir Ödül)
// ═══════════════════════════════════════════════════════════════

class _ClaimableFireCell extends StatefulWidget {
  final int day;
  final bool isToday;
  final bool isFuture;
  final bool isAppOpenDay;
  final bool isClaimed;
  final String dateKey;
  final VoidCallback? onClaimed;

  const _ClaimableFireCell({
    required this.day,
    required this.isToday,
    required this.isFuture,
    required this.isAppOpenDay,
    required this.isClaimed,
    required this.dateKey,
    this.onClaimed,
  });

  @override
  State<_ClaimableFireCell> createState() => _ClaimableFireCellState();
}

class _ClaimableFireCellState extends State<_ClaimableFireCell> with TickerProviderStateMixin {
  late AnimationController _explosionController;
  late AnimationController _flyController;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;
  late Animation<double> _flyUpAnim;
  late Animation<double> _flyFadeAnim;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _justClaimed = false;

  @override
  void initState() {
    super.initState();
    _explosionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    // Aniden 2.5 katına fırlayıp geri oturma
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.8).chain(CurveTween(curve: Curves.easeOutBack)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.8, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 50),
    ]).animate(_explosionController);

    // Altın sarısı glow
    _glowAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_explosionController);

    _flyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    
    // "+1" yazısı için yüksek uçuş
    _flyUpAnim = Tween<double>(begin: 0, end: -60).animate(
      CurvedAnimation(parent: _flyController, curve: Curves.easeOutCubic),
    );
    _flyFadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _flyController, curve: const Interval(0.4, 1.0, curve: Curves.easeOut)),
    );
  }

  @override
  void dispose() {
    _explosionController.dispose();
    _flyController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (!widget.isAppOpenDay || widget.isClaimed || widget.isFuture || _justClaimed) return;

    // Tok bir titreşim ve güçlü etki
    HapticFeedback.heavyImpact();

    // Yeni indirdiğimiz Level Up sesi (Versiyon 01)
    try {
      await _audioPlayer.play(AssetSource('sounds/level_up_bonus_01.mp3'), mode: PlayerMode.lowLatency);
    } catch (_) {}

    final success = await StorageService.claimDailyAura(widget.dateKey);
    if (success && mounted) {
      setState(() => _justClaimed = true);
      
      _explosionController.forward(from: 0);
      _flyController.forward(from: 0);
      
      widget.onClaimed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool claimed = widget.isClaimed || _justClaimed;
    final bool canClaim = widget.isAppOpenDay && !claimed && !widget.isFuture;

    return GestureDetector(
      onTap: canClaim ? _handleTap : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: Listenable.merge([_explosionController, _flyController]),
        builder: (context, child) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Ana hücre (Pop efekti ile)
              Transform.scale(
                scale: _explosionController.isAnimating ? _scaleAnim.value : 1.0,
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isToday 
                      ? const Color(0xFFFF6B6B).withOpacity(0.15) 
                      : (widget.isAppOpenDay && !claimed ? const Color(0xFFFF6B6B).withOpacity(0.08) : Colors.transparent),
                    border: widget.isToday ? Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.5), width: 1) : null,
                    boxShadow: [
                      if (_explosionController.isAnimating)
                        BoxShadow(
                          color: const Color(0xFFFFC107).withOpacity(_glowAnim.value * 0.6),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                    ],
                  ),
                  child: Center(
                    child: widget.isAppOpenDay
                      ? Icon(
                          Icons.local_fire_department_rounded, 
                          color: claimed 
                            ? (_explosionController.isAnimating ? const Color(0xFFFFC107) : Colors.white.withOpacity(0.15))
                            : const Color(0xFFFF6B6B),
                          size: 18,
                        )
                      : Text("${widget.day}", style: TextStyle(
                          color: widget.isFuture 
                            ? Colors.white.withOpacity(0.2) 
                            : (widget.isToday ? const Color(0xFFFF6B6B) : Colors.white.withOpacity(0.65)), 
                          fontSize: 14, 
                          fontWeight: widget.isToday ? FontWeight.bold : FontWeight.w500
                        )),
                  ),
                ),
              ),
              // Uçan "+1 Aura" yazısı
              if (_justClaimed && _flyController.isAnimating)
                Positioned(
                  left: -20,
                  right: -20, // Ortalamak için
                  top: _flyUpAnim.value - 10,
                  child: Opacity(
                    opacity: _flyFadeAnim.value,
                    child: Center(
                      child: Text(
                        "+1",
                        style: const TextStyle(
                          color: Color(0xFFFFC107), 
                          fontSize: 22, 
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(color: Color(0x88FF6B6B), blurRadius: 10)
                          ]
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
