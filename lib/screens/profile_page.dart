import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';
import '../constants/colors.dart';
import '../services/season_config.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/fade_page_route.dart';
import '../widgets/glass_back_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'premium_paywall_page.dart';
import 'onboarding_page.dart';
import 'notification_settings_page.dart';
import 'account_details_page.dart';
import 'language_settings_page.dart';
import 'home_page.dart';
import 'collection_page.dart';
import '../services/locale_controller.dart';
import '../services/storage_service.dart';
import '../services/profile_sync_service.dart';
import '../services/content_moderation_service.dart';
import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:image_cropper/image_cropper.dart';
import '../widgets/cosmic_badge.dart';
import 'cosmic_profile_page.dart';
import '../services/supabase_owl_service.dart';
import '../models/cookie_card.dart';
import '../services/user_stats_service.dart';
import '../services/sound_service.dart';
import '../services/analytics_service.dart';


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
  String _userHandle = '';
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
    SupabaseOwlService().addListener(_onMockOwlUpdate);
  }

  void _onMockOwlUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    SupabaseOwlService().removeListener(_onMockOwlUpdate);
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
      _userHandle = (snapshot['userHandle'] as String?) ?? '';
      _totalCookies = (snapshot['totalCookies'] as int?) ?? 0;
      _totalTarots = tarotCount;
      _totalDreams = (snapshot['totalDreams'] as int?) ?? 0;
      _spentAura = spentAura;
      _bonusAura = bonusAura;
      _streakDays = streak;
      _userAvatar = avatar;
      _unreadOwlCount = unreadOwl;
      _isLoading = false;
      _isPremiumUser = prefs.getBool('is_elite') ?? false;
    });

    // Günlük Elite Ruh Taşlarını yenile (merkezi sistem)
    await StorageService.getSoulStones();

    // Segmentasyon için kullanıcı özelliklerini Analytics'e gönder
    AnalyticsService().setUserProperty(
      name: 'user_level',
      value: _getUserLevel(Localizations.localeOf(context).languageCode).title,
    );
    AnalyticsService().setUserProperty(
      name: 'is_elite',
      value: _isPremiumUser.toString(),
    );
    AnalyticsService().setUserProperty(
      name: 'streak_days',
      value: _streakDays.toString(),
    );
  }

  // ── Kullanıcı seviyesi hesapla (Aura bazlı) ──
  // Emoji yerine Material Icon kullanıyoruz — her cihazda çalışır.
  ({IconData icon, Color color, String title}) _getUserLevel(String lang) {
    // YENİ SİSTEM: Aura doğrudan eklentiler yerine, sadece toplanan (_bonusAura) havuzundan okunur.
    final int aura = _bonusAura;

    if (lang == 'tr') {
      if (aura < 51)
        return (
          icon: Icons.eco_rounded,
          color: const Color(0xFF4ADE80),
          title: 'Acemi Kahin',
        );
      if (aura < 151)
        return (
          icon: Icons.local_fire_department_rounded,
          color: const Color(0xFFFBBF24),
          title: 'Çırak Kahin',
        );
      if (aura < 301)
        return (
          icon: Icons.auto_awesome_rounded,
          color: const Color(0xFFA78BFA),
          title: 'Kahin',
        );
      if (aura < 601)
        return (
          icon: Icons.visibility_rounded,
          color: const Color(0xFF38BDF8),
          title: 'Bilge Kahin',
        );
      if (aura < 1001)
        return (
          icon: Icons.bolt_rounded,
          color: const Color(0xFFF97316),
          title: 'Usta Kahin',
        );
      return (
        icon: Icons.workspace_premium_rounded,
        color: const Color(0xFFFFD700),
        title: 'Kozmik Kahin',
      );
    } else {
      if (aura < 51)
        return (
          icon: Icons.eco_rounded,
          color: const Color(0xFF4ADE80),
          title: 'Novice Seer',
        );
      if (aura < 151)
        return (
          icon: Icons.local_fire_department_rounded,
          color: const Color(0xFFFBBF24),
          title: 'Apprentice Seer',
        );
      if (aura < 301)
        return (
          icon: Icons.auto_awesome_rounded,
          color: const Color(0xFFA78BFA),
          title: 'Seer',
        );
      if (aura < 601)
        return (
          icon: Icons.visibility_rounded,
          color: const Color(0xFF38BDF8),
          title: 'Wise Seer',
        );
      if (aura < 1001)
        return (
          icon: Icons.bolt_rounded,
          color: const Color(0xFFF97316),
          title: 'Master Seer',
        );
      return (
        icon: Icons.workspace_premium_rounded,
        color: const Color(0xFFFFD700),
        title: 'Cosmic Seer',
      );
    }
  }

  // ── İsim & Profil Düzenleme ──
  void _editProfile() {
    final nameController = TextEditingController(text: _userName);
    final lang = Localizations.localeOf(context).languageCode;
    String selectedAvatar = _userAvatar;

    final avatars = [
      (!_userAvatar.startsWith('http') && !_userAvatar.startsWith('assets'))
          ? _userAvatar
          : 'gallery',
      // 12 adet Kozmik Hazır Avatar
      'assets/images/avatars/avatar_1.png',
      'assets/images/avatars/avatar_2.png',
      'assets/images/avatars/avatar_3.png',
      'assets/images/avatars/avatar_4.png',
      'assets/images/avatars/avatar_5.png',
      'assets/images/avatars/avatar_6.png',
      'assets/images/avatars/avatar_7.png',
      'assets/images/avatars/avatar_8.png',
      'assets/images/avatars/avatar_9.png',
      'assets/images/avatars/avatar_10.png',
      'assets/images/avatars/avatar_11.png',
      'assets/images/avatars/avatar_12.png',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        bool _isSaving = false;
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(36),
                ),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(36),
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 0.5,
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(28, 16, 28, 36),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
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
                                  onTap: () async {
                                    HapticFeedback.selectionClick();
                                    if (index == 0) {
                                      try {
                                        final picker = ImagePicker();
                                        final pickedFile = await picker
                                            .pickImage(
                                              source: ImageSource.gallery,
                                            );
                                        if (pickedFile != null) {
                                          final croppedFile =
                                              await ImageCropper().cropImage(
                                                sourcePath: pickedFile.path,
                                                aspectRatio:
                                                    const CropAspectRatio(
                                                      ratioX: 1,
                                                      ratioY: 1,
                                                    ),
                                                compressQuality: 85,
                                                uiSettings: [
                                                  AndroidUiSettings(
                                                    toolbarTitle:
                                                        'Kozmik Kesim',
                                                    toolbarColor:
                                                        AppColors.bgDark1,
                                                    toolbarWidgetColor:
                                                        Colors.white,
                                                    initAspectRatio:
                                                        CropAspectRatioPreset
                                                            .square,
                                                    cropStyle: CropStyle.circle,
                                                    lockAspectRatio: true,
                                                  ),
                                                  IOSUiSettings(
                                                    title: 'Kozmik Kesim',
                                                    cancelButtonTitle: 'İptal',
                                                    doneButtonTitle: 'Tamam',
                                                    cropStyle: CropStyle.circle,
                                                    aspectRatioLockEnabled:
                                                        true,
                                                    resetAspectRatioEnabled:
                                                        false,
                                                    rotateButtonsHidden: true,
                                                    rotateClockwiseButtonHidden:
                                                        true,
                                                    aspectRatioPickerButtonHidden:
                                                        true,
                                                  ),
                                                ],
                                              );

                                          if (croppedFile != null) {
                                            setModalState(() {
                                              selectedAvatar = croppedFile.path;
                                              avatars[0] = croppedFile.path;
                                            });
                                          } else {
                                            if (avatars[0] != 'gallery') {
                                              setModalState(
                                                () =>
                                                    selectedAvatar = avatars[0],
                                              );
                                            }
                                          }
                                        } else {
                                          if (avatars[0] != 'gallery') {
                                            setModalState(
                                              () => selectedAvatar = avatars[0],
                                            );
                                          }
                                        }
                                      } catch (e) {
                                        debugPrint('Image pick error: \$e');
                                      }
                                    } else {
                                      setModalState(
                                        () => selectedAvatar = avatar,
                                      );
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOutCubic,
                                    margin: const EdgeInsets.only(right: 20),
                                    width: 96,
                                    height: 96,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primaryOrange
                                                  .withOpacity(0.9)
                                            : Colors.white.withOpacity(0.08),
                                        width: isSelected ? 3 : 1,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: AppColors.primaryOrange
                                                    .withOpacity(0.35),
                                                blurRadius: 24,
                                                spreadRadius: 4,
                                              ),
                                            ]
                                          : [],
                                      gradient: LinearGradient(
                                        colors: isSelected
                                            ? [
                                                AppColors.primaryOrange
                                                    .withOpacity(0.15),
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
                                              : 0.0,
                                        ),
                                        child: Transform.scale(
                                          scale: avatar.contains('owl')
                                              ? 1.35
                                              : (avatar.contains('avatar_')
                                                    ? 1.15
                                                    : 1.0),
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              if (avatar == 'gallery')
                                                Icon(
                                                  Icons
                                                      .add_photo_alternate_rounded,
                                                  color: Colors.white
                                                      .withOpacity(0.5),
                                                  size: 36,
                                                )
                                              else if (avatar.startsWith(
                                                'http',
                                              ))
                                                Image.network(
                                                  avatar,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      Icon(
                                                        Icons.person_rounded,
                                                        color: Colors.white
                                                            .withOpacity(0.3),
                                                        size: 40,
                                                      ),
                                                )
                                              else if (avatar.startsWith(
                                                'assets',
                                              ))
                                                Image.asset(
                                                  avatar,
                                                  fit: avatar.contains('owl')
                                                      ? BoxFit.contain
                                                      : BoxFit.cover,
                                                )
                                              else
                                                Image.file(
                                                  File(avatar),
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      Icon(
                                                        Icons.person_rounded,
                                                        color: Colors.white
                                                            .withOpacity(0.3),
                                                        size: 40,
                                                      ),
                                                ),

                                              // Ön İzleme üstündeki minik galeri butonu işareti (1. Sıra ise)
                                              if (index == 0 &&
                                                  avatar != 'gallery')
                                                Container(
                                                  color: Colors.black
                                                      .withOpacity(0.35),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons
                                                          .cameraswitch_rounded,
                                                      color: Colors.white
                                                          .withOpacity(0.8),
                                                      size: 26,
                                                    ),
                                                  ),
                                                ),
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
                          const SizedBox(height: 24),

                          // İsim Düzenleme Alanı
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: TextField(
                              controller: nameController,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              cursorColor: AppColors.primaryOrange,
                              decoration: InputDecoration(
                                hintText: lang == 'tr'
                                    ? 'Kozmik Adın'
                                    : 'Cosmic Name',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                                prefixIcon: Icon(
                                  Icons.person_outline_rounded,
                                  color: Colors.white.withOpacity(0.4),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // @Handle — Salt Okunur (Onboarding'de belirleniyor)
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.02),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.06),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.alternate_email_rounded,
                                  color: Colors.white.withOpacity(0.25),
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _userHandle.isNotEmpty
                                        ? _userHandle
                                        : '@${_userName.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.35),
                                      fontSize: 15,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.lock_outline_rounded,
                                  color: Colors.white.withOpacity(0.15),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Kaydet Butonu
                          GestureDetector(
                            onTap: _isSaving
                                ? null
                                : () async {
                                    HapticFeedback.mediumImpact();

                                    setModalState(() => _isSaving = true);

                                    final newName = nameController.text.trim();
                                    String finalAvatarToSave = selectedAvatar;

                                    // Eğer lokalden bir resim seçilmişse (URL/Asset değilse) Yapay Zeka denetimden geçir ve Supabase'e yükle
                                    if (!selectedAvatar.startsWith('http') &&
                                        !selectedAvatar.startsWith('assets')) {
                                      final imageFile = File(selectedAvatar);

                                      // 1. YAPAY ZEKA GÜVENLİK KONTROLÜ
                                      final moderationResult =
                                          await ContentModerationService()
                                              .analyzeImage(imageFile);

                                      if (moderationResult !=
                                          ModerationResult.approved) {
                                        final errorMessage =
                                            ContentModerationService()
                                                .getErrorMessage(
                                                  moderationResult,
                                                );
                                        setModalState(() => _isSaving = false);

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                const Icon(
                                                  Icons.shield_rounded,
                                                  color: Colors.orangeAccent,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    errorMessage,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            backgroundColor: const Color(
                                              0xFF1E1E2A,
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                        return; // İŞLEMİ İPTAL ET (Asla Buluta Çıkartma!)
                                      }

                                      // 2. ONAYLANDI -> BULUTA YÜKLE
                                      final publicUrl =
                                          await ProfileSyncService()
                                              .uploadAvatar(imageFile);
                                      if (publicUrl != null) {
                                        finalAvatarToSave = publicUrl;
                                      } else {
                                        // YÜKLEME BAŞARISIZ OLDU! Geçici dosyayı kaydetmeyi engelle.
                                        if (mounted) {
                                          setModalState(
                                            () => _isSaving = false,
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Fotoğraf buluta yüklenemedi! Lütfen bağlantını kontrol et.',
                                              ),
                                              backgroundColor: Colors.redAccent,
                                            ),
                                          );
                                        }
                                        return;
                                      }
                                    }

                                    if (newName.isNotEmpty) {
                                      await StorageService.setUserName(newName);
                                    }
                                    await StorageService.setAvatar(
                                      finalAvatarToSave,
                                    );

                                    // SUPABASE BULUTUNA SENKRONİZE ET
                                    await ProfileSyncService().syncProfileData(
                                      userName: newName.isNotEmpty
                                          ? newName
                                          : _userName,
                                      userHandle: _userHandle,
                                      avatarUrl: finalAvatarToSave,
                                    );

                                    if (mounted) {
                                      setState(() {
                                        _userAvatar = finalAvatarToSave;
                                        if (newName.isNotEmpty) {
                                          _userName = newName;
                                        }
                                      });
                                      AnalyticsService().logAvatarChanged();
                                    }
                                    if (ctx.mounted) {
                                      Navigator.pop(ctx);
                                    }
                                  },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: double.infinity,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                gradient: LinearGradient(
                                  colors: _isSaving
                                      ? [
                                          Colors.grey.shade800,
                                          Colors.grey.shade900,
                                        ]
                                      : [
                                          AppColors.primaryOrange,
                                          const Color(0xFFFF7A00),
                                        ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                boxShadow: _isSaving
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: AppColors.primaryOrange
                                              .withOpacity(0.4),
                                          blurRadius: 20,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                              ),
                              child: Center(
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Text(
                                        lang == 'tr'
                                            ? 'Mührü Onayla'
                                            : 'Seal Profile',
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
                    ), // end SingleChildScrollView
                  ), // end Container
                ), // end BackdropFilter
              ), // end ClipRRect
            ); // end Padding
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
  void _rateApp() async {
    HapticFeedback.lightImpact();
    
    // Uygulama yayınlandığında mağaza linkleriyle çalışacak profesyonel yapı
    final Uri url = Uri.parse(
      Platform.isIOS
          ? 'https://apps.apple.com/app/idYOUR_APP_ID' // iOS App Store Linki
          : 'https://play.google.com/store/apps/details?id=com.sadam.vlucky_flutter' // Google Play Linki
    );
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Mağaza bulunamazsa zarif bir hata göster
        final lang = Localizations.localeOf(context).languageCode;
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lang == 'tr' ? 'Mağaza bağlantısı şu an kurulamıyor.' : 'Store link is unavailable.',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            backgroundColor: const Color(0xFF1A1A2E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      debugPrint("Rate app error: $e");
    }
  }

  // ── Kozmik Harita (Otomatik Burç Hesaplayıcı) ──
  Future<void> _openCosmicChart() async {
    HapticFeedback.lightImpact();
    final result = await Navigator.push(
      context,
      SwipeFadePageRoute(page: const CosmicProfilePage()),
    );
    if (result == true && mounted) {
      await loadUserData();
    }
  }

  // ── Yardım merkezi ──
  void _openHelpCenter() async {
    HapticFeedback.lightImpact();
    // Destek ekibine doğrudan mail atan ciddi yapı
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@crackandwish.com',
      queryParameters: {
        'subject': 'Crack&Wish Support / Destek',
      },
    );
    
    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        // Mail uygulaması yoksa zarif fallback
        final lang = Localizations.localeOf(context).languageCode;
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lang == 'tr' ? 'Mail uygulaması bulunamadı. support@crackandwish.com adresine yazabilirsiniz.' : 'No mail app found. You can write to support@crackandwish.com',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            backgroundColor: const Color(0xFF1A1A2E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      debugPrint("Help center error: $e");
    }
  }

  // ── Davet Et & Kazan Sistemi Modalı ──
  void _showInviteModal() {
    final lang = Localizations.localeOf(context).languageCode;
    HapticFeedback.heavyImpact();

    // Geçici sahte kod üretimi (ileride Supabase'den gerçek kod çekilecek)
    final inviteCode = _userName.trim().isNotEmpty
        ? '${_userName.trim().toUpperCase()}-777'
        : 'MYSTIC-777';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF16151A).withOpacity(0.95),
                  const Color(0xFF0D0C11).withOpacity(0.98),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(36),
              ),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            padding: const EdgeInsets.fromLTRB(28, 16, 28, 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE879F9).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.group_add_rounded,
                        color: Color(0xFFE879F9),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang == 'tr'
                                ? 'Bağlarını Güçlendir'
                                : 'Strengthen Bonds',
                            style: const TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lang == 'tr'
                                ? 'Kozmik evreni arkadaşlarınla büyüt.'
                                : 'Expand the cosmic universe with friends.',
                            style: TextStyle(
                              color: AppColors.textWhite.withOpacity(0.5),
                              fontSize: 14,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),

                // Senin Davet Kodun Bölümü
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFE879F9).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            lang == 'tr' ? 'Ritüel Kodun' : 'Ritual Code',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.diamond_rounded,
                                color: Color(0xFF60A5FA),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                lang == 'tr'
                                    ? '+2 Ruh Taşı Kazan'
                                    : 'Earn +2 Soul Stones',
                                style: const TextStyle(
                                  color: Color(0xFF60A5FA),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              inviteCode,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                Clipboard.setData(
                                  ClipboardData(text: inviteCode),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      lang == 'tr'
                                          ? 'Kod kopyalandı!'
                                          : 'Code copied!',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: const Color(0xFFE879F9),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFE879F9,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.copy_rounded,
                                  color: Color(0xFFE879F9),
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Paylaş Butonu
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Share.share(
                            lang == 'tr'
                                ? 'Crack&Wish evrenine katıl! ✨\nRitüel Kodum: $inviteCode\n\nBu kodu girerek +1 Ruh Taşı, +50 Aura ve sürpriz bir Premium Kurabiye kazanabilirsin!\nhttps://crackandwish.com'
                                : 'Join the Crack&Wish universe! ✨\nMy Ritual Code: $inviteCode\n\nEnter this code to earn +1 Soul Stone, +50 Aura, and a surprise Premium Cookie!\nhttps://crackandwish.com',
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFC084FC), Color(0xFFE879F9)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.share_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  lang == 'tr' ? 'Kodu Paylaş' : 'Share Code',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Removed code entering section since it's "coming soon"
              ],
            ),
          ),
        );
      },
      useSafeArea: true,
    );
  }

  // ── Bağlı e-posta adresini al ──
  String _getConnectedEmail() {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null && user.email != null && user.email!.isNotEmpty) {
        final email = user.email!;
        // E-postayı kısalt: sa***@gmail.com
        final parts = email.split('@');
        if (parts.length == 2 && parts[0].length > 2) {
          return '${parts[0].substring(0, 2)}***@${parts[1]}';
        }
        return email;
      }
    } catch (_) {}
    return '';
  }

  // ── Kozmik bilgi düzenleme ──

  String _calculateZodiacFromDate(DateTime date) {
    final int d = date.day;
    final int m = date.month;
    if ((m == 3 && d >= 21) || (m == 4 && d <= 19)) return 'aries';
    if ((m == 4 && d >= 20) || (m == 5 && d <= 20)) return 'taurus';
    if ((m == 5 && d >= 21) || (m == 6 && d <= 20)) return 'gemini';
    if ((m == 6 && d >= 21) || (m == 7 && d <= 22)) return 'cancer';
    if ((m == 7 && d >= 23) || (m == 8 && d <= 22)) return 'leo';
    if ((m == 8 && d >= 23) || (m == 9 && d <= 22)) return 'virgo';
    if ((m == 9 && d >= 23) || (m == 10 && d <= 22)) return 'libra';
    if ((m == 10 && d >= 23) || (m == 11 && d <= 21)) return 'scorpio';
    if ((m == 11 && d >= 22) || (m == 12 && d <= 21)) return 'sagittarius';
    if ((m == 12 && d >= 22) || (m == 1 && d <= 19)) return 'capricorn';
    if ((m == 1 && d >= 20) || (m == 2 && d <= 18)) return 'aquarius';
    return 'pisces';
  }

  // ── Hesap silme ──
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
            filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
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
                              // 1. Önce buluttan kullanıcının kendi data'sını kalıcı sil (Postgres RPC)
                              await Supabase.instance.client.rpc('delete_user');
                              // 2. Auth statüsünü temizle
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

  // ── Çıkış yap ──
  void _signOut() {
    final lang = Localizations.localeOf(context).languageCode;
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
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
                  SizedBox(
                    height: 40,
                    child: Text(
                      lang == 'tr'
                          ? 'Hesap oturumundan çıkış yapmak\nüzere olduğundan emin misin?'
                          : 'Are you sure you want to sign out\nof your active account session?',
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
                              await Supabase.instance.client.auth.signOut();
                            } catch (e) {
                              debugPrint("SignOut Error: $e");
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
                              color: const Color(0xFFFF4D4D),
                              borderRadius: BorderRadius.circular(16),
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
            ),
          ),
        );
      },
    );
  }

  // ── Gizlilik Politikası ──
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Launch URL error: $e');
    }
  }

  void _openPrivacyPolicy() {
    final lang = Localizations.localeOf(context).languageCode;
    _launchURL("https://crackwish.com/privacy.html#$lang");
    return;
    _showLegalSheet(
      title: lang == 'tr' ? 'Gizlilik Politikası' : 'Privacy Policy',
      content: lang == 'tr'
          ? '''Crack&Wish Gizlilik Politikası
Son güncelleme: 23 Nisan 2026

Bu gizlilik politikası, Crack&Wish mobil uygulamasının ("Uygulama") kişisel verilerinizi nasıl topladığını, kullandığını, sakladığını ve koruduğunu açıklar.

1. TOPLANAN VERİLER

1.1 Hesap Verileri
Google veya Apple hesabınızla giriş yaptığınızda; adınız, e-posta adresiniz ve benzersiz kullanıcı kimliğiniz (User ID) Supabase altyapısında güvenle saklanır.

1.2 Profil Verileri
Kullanıcı adınız (@handle), doğum tarihiniz, burç bilginiz, doğum yeriniz ve seçtiğiniz profil fotoğrafı bulut sunucularımızda depolanır.

1.3 Uygulama İçi Veriler
Kurabiye falları, rüya kayıtları, tarot okumaları, ruh taşı bakiyesi ve ayarlarınız öncelikle cihazınızda yerel olarak saklanır. Giriş yaptığınızda bu veriler Supabase bulut sunucusuna şifreli olarak yedeklenir.

1.4 Sosyal Veriler
Arkadaş istekleri, kabul edilen bağlantılar ve Baykuş Postası (Owl Letter) mektupları Supabase veritabanında saklanır. Mektup içerikleri yalnızca gönderen ve alıcı tarafından görüntülenebilir.

1.5 Profil Fotoğrafı
Yüklediğiniz profil fotoğrafları, uygunsuz içerik tespiti için yapay zeka tabanlı içerik moderasyon sisteminden geçirilir. Uygun bulunan fotoğraflar Supabase Storage'da saklanır.

1.6 Rüya Analizi
Rüya metinleriniz analiz için Google Gemini AI servisine anonim olarak gönderilir. Gönderilen metinler kullanıcı kimliğinizle ilişkilendirilmez ve AI servisi tarafından kalıcı olarak saklanmaz.

1.7 Rehber Erişimi
Arkadaş bulma özelliği için cihaz rehberinize erişim izni istenebilir. Rehber verileri yalnızca eşleşme amacıyla kullanılır ve sunucularımızda saklanmaz.

2. VERİ KULLANIMI

Verileriniz yalnızca şu amaçlarla kullanılır:
• Hesap yönetimi ve kimlik doğrulama
• Bulut senkronizasyonu (cihaz değişikliğinde verilerinizi koruma)
• Sosyal özellikler (arkadaşlık, mektup gönderme)
• Rüya analizi ve kişiselleştirilmiş yorumlar
• Uygulama içi satın alma işlemleri (RevenueCat)
• Reklam gösterimi (Google AdMob)

3. ÜÇÜNCÜ TARAF HİZMETLER

Uygulama şu üçüncü taraf hizmetleri kullanır:
• Supabase: Veritabanı, kimlik doğrulama ve dosya depolama
• Google Gemini AI: Rüya analizi
• Google AdMob: Reklam gösterimi
• RevenueCat: Abonelik yönetimi
• Google/Apple Sign-In: Kimlik doğrulama

Her hizmet sağlayıcı kendi gizlilik politikasına tabidir.

4. VERİ GÜVENLİĞİ

• Tüm veri iletişimi HTTPS/TLS şifreleme ile korunur.
• Supabase veritabanı Row Level Security (RLS) ile korunmaktadır.
• Her kullanıcı yalnızca kendi verilerine erişebilir.
• Profil fotoğrafları içerik moderasyonundan geçirilir.

5. VERİ SAKLAMA SÜRESİ

Verileriniz hesabınız aktif olduğu sürece saklanır. Hesabınızı sildiğinizde tüm verileriniz (profil, mektuplar, arkadaşlıklar, bulut yedekleri) kalıcı olarak silinir.

6. KULLANICI HAKLARI

Aşağıdaki haklara sahipsiniz:
• Verilerinize erişim talep etme
• Verilerinizin düzeltilmesini isteme
• Hesabınızı ve tüm verilerinizi silme (Profil → Hesabı Sil)
• Bildirim tercihlerini değiştirme

7. ÇOCUKLARIN GİZLİLİĞİ

Crack&Wish 13 yaş altı kullanıcılara yönelik değildir. Bilerek 13 yaş altı kullanıcılardan veri toplamayız.

8. DEĞİŞİKLİKLER

Bu politika gerektiğinde güncellenebilir. Önemli değişikliklerde uygulama içi bildirim yapılır.

9. İLETİŞİM

Sorularınız için: info@crackandwish.com'''
          : '''Crack&Wish Privacy Policy
Last updated: April 23, 2026

This privacy policy explains how the Crack&Wish mobile application ("App") collects, uses, stores, and protects your personal data.

1. DATA COLLECTED

1.1 Account Data
When you sign in with Google or Apple, your name, email address, and unique user ID are securely stored on Supabase infrastructure.

1.2 Profile Data
Your username (@handle), date of birth, zodiac sign, birth location, and profile photo are stored on our cloud servers.

1.3 In-App Data
Fortune cookies, dream entries, tarot readings, soul stone balance, and preferences are primarily stored locally on your device. When signed in, this data is encrypted and backed up to Supabase cloud.

1.4 Social Data
Friend requests, accepted connections, and Owl Letter messages are stored in the Supabase database. Letter contents are viewable only by the sender and recipient.

1.5 Profile Photo
Uploaded profile photos pass through an AI-based content moderation system. Approved photos are stored in Supabase Storage.

1.6 Dream Analysis
Dream texts are sent anonymously to Google Gemini AI for analysis. Submitted texts are not associated with your identity and are not permanently stored by the AI service.

1.7 Contact Access
Permission to access your device contacts may be requested for friend discovery. Contact data is used only for matching and is not stored on our servers.

2. DATA USAGE

Your data is used solely for:
• Account management and authentication
• Cloud synchronization (protecting your data across devices)
• Social features (friendships, letter sending)
• Dream analysis and personalized interpretations
• In-app purchases (RevenueCat)
• Advertisement display (Google AdMob)

3. THIRD-PARTY SERVICES

The App uses the following third-party services:
• Supabase: Database, authentication, and file storage
• Google Gemini AI: Dream analysis
• Google AdMob: Advertisement display
• RevenueCat: Subscription management
• Google/Apple Sign-In: Authentication

Each service provider is subject to its own privacy policy.

4. DATA SECURITY

• All data transmission is protected with HTTPS/TLS encryption.
• Supabase database is protected with Row Level Security (RLS).
• Each user can only access their own data.
• Profile photos undergo content moderation.

5. DATA RETENTION

Your data is retained as long as your account is active. When you delete your account, all your data (profile, letters, friendships, cloud backups) is permanently deleted.

6. USER RIGHTS

You have the following rights:
• Request access to your data
• Request correction of your data
• Delete your account and all data (Profile → Delete Account)
• Change notification preferences

7. CHILDREN'S PRIVACY

Crack&Wish is not intended for users under 13. We do not knowingly collect data from children under 13.

8. CHANGES

This policy may be updated as needed. Important changes will be communicated via in-app notification.

9. CONTACT

For questions: info@crackandwish.com''',
    );
  }

  // ── Kullanım Koşulları ──
  void _openTermsOfService() {
    final lang = Localizations.localeOf(context).languageCode;
    _launchURL("https://crackwish.com/terms.html#$lang");
    return;
    _showLegalSheet(
      title: lang == 'tr' ? 'Kullanım Koşulları' : 'Terms of Use',
      content: lang == 'tr'
          ? '''Crack&Wish Kullanım Koşulları
Son güncelleme: 23 Nisan 2026

Crack&Wish uygulamasını ("Uygulama") kullanarak aşağıdaki koşulları kabul etmiş olursunuz.

1. HİZMET TANIMI

Crack&Wish bir eğlence ve kişisel keşif uygulamasıdır. Kurabiye falları, tarot okumaları, rüya yorumları ve burç analizleri tamamen eğlence amaçlıdır ve profesyonel psikolojik, tıbbi veya finansal tavsiye niteliği taşımaz.

2. HESAP VE GÜVENLİK

• Uygulamayı kullanmak için Google veya Apple hesabıyla giriş yapmanız gerekir.
• Hesap bilgilerinizin güvenliği sizin sorumluluğunuzdadır.
• Her kullanıcı yalnızca bir hesap oluşturabilir.
• Kullanıcı adınız (@handle) kayıt sonrası değiştirilemez.

3. KULLANICI DAVRANIŞLARI

Aşağıdaki davranışlar kesinlikle yasaktır:
• Spam, hakaret, taciz veya uygunsuz içerik gönderme
• Başka kullanıcıları taklit etme
• Uygunsuz profil fotoğrafı yükleme
• Uygulamanın güvenlik sistemlerini atlatmaya çalışma
• Bot veya otomatik araçlar kullanma
• Uygulama içeriklerini izinsiz kopyalama veya dağıtma

İhlal durumunda hesabınız önceden uyarı yapılmaksızın askıya alınabilir veya kalıcı olarak silinebilir.

4. SOSYAL ÖZELLİKLER

• Baykuş Postası (Owl Letter) ile gönderdiğiniz mektuplar yalnızca alıcı tarafından okunabilir.
• Arkadaşlık bağlantıları karşılıklı onay gerektirir.
• Gönderilen kurabiyeler envanterden düşer ve geri alınamaz.
• Uygunsuz içerikli mektuplar sistem tarafından filtrelenebilir.

5. SATIN ALMALAR VE ABONELİKLER

• Crack&Wish Elite aboneliği aylık yenilenen bir abonelik hizmetidir.
• Abonelikler Apple App Store veya Google Play Store üzerinden yönetilir.
• İptal işlemi ilgili mağaza üzerinden yapılmalıdır.
• Ruh taşları ve premium kurabiyeler sanal ürünlerdir ve gerçek para karşılığı iade edilemez.
• Satın alımlar Apple/Google hesabınız üzerinden faturalandırılır.

6. FİKRİ MÜLKİYET

Uygulama içindeki tüm tasarımlar, görseller, metinler, animasyonlar ve kaynak kodu Crack&Wish'e aittir ve telif hakkı ile korunmaktadır. İzinsiz kullanım yasaktır.

7. YAPAY ZEKA KULLANIMI

• Rüya yorumları Google Gemini AI tarafından üretilir.
• AI tarafından üretilen içerikler profesyonel tavsiye değildir.
• AI yorumları her seferinde farklılık gösterebilir.
• Crack&Wish, AI tarafından üretilen içeriklerin doğruluğunu garanti etmez.

8. SORUMLULUK SINIRLAMALARI

• Uygulama "olduğu gibi" sunulur, herhangi bir garanti verilmez.
• Kurabiye falları, tarot okumaları ve rüya yorumları eğlence amaçlıdır.
• Bu içeriklere dayanarak alınan kararlardan Crack&Wish sorumlu tutulamaz.
• Uygulama kesintisiz veya hatasız çalışmayı garanti etmez.

9. HESAP SONLANDIRMA

• Hesabınızı istediğiniz zaman Profil → Hesabı Sil seçeneğiyle silebilirsiniz.
• Hesap silme işlemi geri alınamaz ve tüm verileriniz kalıcı olarak kaldırılır.
• Koşulları ihlal eden hesaplar önceden bildirim yapılmaksızın sonlandırılabilir.

10. UYGULANACAK HUKUK

Bu koşullar Türkiye Cumhuriyeti yasalarına tabidir. Uyuşmazlıklar İstanbul mahkemelerinde çözümlenir.

11. DEĞİŞİKLİKLER

Bu koşullar gerektiğinde güncellenebilir. Önemli değişikliklerde uygulama içi bildirim yapılır. Değişiklik sonrası uygulamayı kullanmaya devam etmeniz, yeni koşulları kabul ettiğiniz anlamına gelir.

12. İLETİŞİM

Sorularınız için: info@crackandwish.com'''
          : '''Crack&Wish Terms of Use
Last updated: April 23, 2026

By using the Crack&Wish application ("App"), you agree to the following terms.

1. SERVICE DESCRIPTION

Crack&Wish is an entertainment and personal discovery application. Fortune cookies, tarot readings, dream interpretations, and zodiac analyses are purely for entertainment and do not constitute professional psychological, medical, or financial advice.

2. ACCOUNT AND SECURITY

• You must sign in with a Google or Apple account to use the App.
• You are responsible for the security of your account credentials.
• Each user may create only one account.
• Your username (@handle) cannot be changed after registration.

3. USER CONDUCT

The following behaviors are strictly prohibited:
• Sending spam, insults, harassment, or inappropriate content
• Impersonating other users
• Uploading inappropriate profile photos
• Attempting to bypass the App's security systems
• Using bots or automated tools
• Copying or distributing App content without permission

In case of violations, your account may be suspended or permanently deleted without prior notice.

4. SOCIAL FEATURES

• Letters sent via Owl Letter can only be read by the recipient.
• Friend connections require mutual approval.
• Sent cookies are deducted from inventory and cannot be retrieved.
• Letters with inappropriate content may be filtered by the system.

5. PURCHASES AND SUBSCRIPTIONS

• Crack&Wish Elite subscription is a monthly auto-renewing subscription.
• Subscriptions are managed through Apple App Store or Google Play Store.
• Cancellation must be done through the respective store.
• Soul stones and premium cookies are virtual products and are non-refundable.
• Purchases are billed through your Apple/Google account.

6. INTELLECTUAL PROPERTY

All designs, images, texts, animations, and source code within the App are owned by Crack&Wish and protected by copyright. Unauthorized use is prohibited.

7. ARTIFICIAL INTELLIGENCE USAGE

• Dream interpretations are generated by Google Gemini AI.
• AI-generated content is not professional advice.
• AI interpretations may vary each time.
• Crack&Wish does not guarantee the accuracy of AI-generated content.

8. LIMITATION OF LIABILITY

• The App is provided "as is" without any warranties.
• Fortune cookies, tarot readings, and dream interpretations are for entertainment.
• Crack&Wish cannot be held liable for decisions made based on this content.
• The App does not guarantee uninterrupted or error-free operation.

9. ACCOUNT TERMINATION

• You may delete your account at any time via Profile → Delete Account.
• Account deletion is irreversible and all your data is permanently removed.
• Accounts violating these terms may be terminated without prior notice.

10. GOVERNING LAW

These terms are governed by the laws of the Republic of Turkey. Disputes shall be resolved in Istanbul courts.

11. CHANGES

These terms may be updated as needed. Important changes will be communicated via in-app notification. Continued use of the App after changes constitutes acceptance of the new terms.

12. CONTACT

For questions: info@crackandwish.com''',
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
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
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
    final isCurrent = ModalRoute.of(context)?.isCurrent ?? true;

    return TickerMode(
      enabled: isCurrent,
      child: Scaffold(
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
                  padding: EdgeInsets.fromLTRB(
                    16,
                    MediaQuery.of(context).padding.top + 8,
                    16,
                    100,
                  ),
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
                              final displayHandle = _userHandle.isNotEmpty
                                  ? _userHandle
                                  : '@${_userName.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}';
                              return _BentoHeroCard(
                                userName: _userName,
                                userHandle: displayHandle,
                                userAvatar: _userAvatar,
                                levelTitle: level.title,
                                levelIcon: level.icon,
                                levelColor: level.color,
                                isLoading: _isLoading,
                                isPremium: _isPremiumUser,
                                onAvatarLongPress: null,
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
                                  final totalAura = _bonusAura;
                                  final success =
                                      await StorageService.convertAuraToSoulStone(
                                        currentTotalAura: totalAura,
                                        cost: 200,
                                      );
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

                      // ── 3. PREMİUM & KOZMİK PROFIL ──
                      _SettingsListGroup(
                        children: [
                          _SettingsListTile(
                            icon: Icons.workspace_premium_rounded,
                            iconColor: const Color(0xFFFFD166),
                            label: lang == 'tr' ? 'Elite\'e Geç' : 'Get Elite',
                            subtitle: lang == 'tr' ? 'Farkındalığa giden kapı' : 'Doorway to awareness',
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
                          _SettingsListTile(
                            icon: Icons.auto_graph_rounded,
                            iconColor: const Color(0xFFC084FC),
                            label: lang == 'tr' ? 'Kozmik Profilim' : 'Cosmic Profile',
                            subtitle: lang == 'tr' ? 'Harita, Saat ve Konum Bilgileri' : 'Chart, Time and Location',
                            onTap: _openCosmicChart,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── BÖLÜM 1: HESAP ──
                      _SectionLabel(lang == 'tr' ? 'Hesap' : 'Account'),
                      const SizedBox(height: 10),
                      _SettingsListGroup(
                        children: [
                          _SettingsListTile(
                            icon: Icons.email_outlined,
                            iconColor: Colors.white,
                            label: lang == 'tr' ? 'E-posta' : 'Email',
                            subtitle: _getConnectedEmail(),
                            onTap: () {
                              Navigator.push(
                                context,
                                SwipeFadePageRoute(
                                  page: AccountDetailsPage(
                                    userName: _userHandle.isNotEmpty 
                                        ? _userHandle 
                                        : '@${_userName.toLowerCase().replaceAll(' ', '')}',
                                  ),
                                ),
                              );
                            },
                          ),
                          _SettingsListTile(
                            icon: Icons.language_rounded,
                            iconColor: Colors.white,
                            label: l10n.language,
                            subtitle: languageValue,
                            onTap: () {
                              Navigator.push(
                                context,
                                SwipeFadePageRoute(
                                  page: LanguageSettingsPage(),
                                ),
                              );
                            },
                          ),
                          _SettingsListTile(
                            icon: Icons.notifications_none_rounded,
                            iconColor: Colors.white,
                            label: lang == 'tr'
                                ? 'Bildirimler'
                                : 'Notifications',
                            onTap: () {
                              Navigator.push(
                                context,
                                SwipeFadePageRoute(
                                  page: const NotificationSettingsPage(),
                                ),
                              );
                            },
                          ),


                        ],
                      ),

                      const SizedBox(height: 24),

                      // ── BÖLÜM 2: DESTEK & DENEYİM ──
                      _SectionLabel(
                        lang == 'tr'
                            ? 'Destek & Deneyim'
                            : 'Support & Experience',
                      ),
                      const SizedBox(height: 10),
                      _SettingsListGroup(
                        children: [

                          _SettingsListTile(
                            icon: Icons.help_outline_rounded,
                            iconColor: Colors.white,
                            label: lang == 'tr' ? 'Yardım' : 'Help',
                            onTap: _openHelpCenter,
                          ),
                          _SettingsListTile(
                            icon: Icons.share_rounded,
                            iconColor: Colors.white,
                            label: lang == 'tr' ? 'Paylaş' : 'Share',
                            onTap: _shareApp,
                          ),
                          _SettingsListTile(
                            icon: Icons.star_border_rounded,
                            iconColor: Colors.white,
                            label: lang == 'tr' ? 'Değerlendir' : 'Rate',
                            onTap: _rateApp,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      _SettingsListGroup(
                        children: [
                          _SettingsListTile(
                            icon: Icons.logout_rounded,
                            iconColor: const Color(0xFFFCA5A5), // Soft red
                            label: lang == 'tr' ? 'Çıkış Yap' : 'Sign Out',
                            isDestructive: true,
                            onTap: _signOut,
                          ),

                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── FOOTER & YASAL ──
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: _openPrivacyPolicy,
                                child: Text(
                                  lang == 'tr'
                                      ? 'Gizlilik Politikası'
                                      : 'Privacy Policy',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.35),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              GestureDetector(
                                onTap: _openTermsOfService,
                                child: Text(
                                  lang == 'tr'
                                      ? 'Kullanım Koşulları'
                                      : 'Terms of Use',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.35),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
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
      ), // Scaffold
    ); // TickerMode
  }
}

// ═══════════════════════════════════════════════════════════════
// BENTO HERO CARD (Arch-top Avatar + Name + Level)
// ═══════════════════════════════════════════════════════════════

class _BentoHeroCard extends StatelessWidget {
  final String userName;
  final String userHandle;
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
    required this.userHandle,
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
                            Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.white.withOpacity(0.8),
                              size: 14,
                            ),
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
                                    color: const Color(
                                      0xFFD4A574,
                                    ).withOpacity(0.4),
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
                                        userAvatar.contains('owl') ? 4.0 : 0.0,
                                      ),
                                      child: Transform.scale(
                                        scale: userAvatar.contains('owl')
                                            ? 1.35
                                            : (userAvatar.contains('avatar_')
                                                  ? 1.15
                                                  : 1.0),
                                        child: userAvatar.startsWith('http')
                                            ? Image.network(
                                                userAvatar,
                                                key: ValueKey(userAvatar),
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Icon(
                                                      Icons.person_rounded,
                                                      color: Colors.white
                                                          .withOpacity(0.3),
                                                      size: 48,
                                                    ),
                                              )
                                            : userAvatar.startsWith('assets')
                                            ? Image.asset(
                                                userAvatar,
                                                key: ValueKey(userAvatar),
                                                fit: userAvatar.contains('owl')
                                                    ? BoxFit.contain
                                                    : BoxFit.cover,
                                              )
                                            : Image.file(
                                                File(userAvatar),
                                                key: ValueKey(userAvatar),
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Icon(
                                                      Icons.person_rounded,
                                                      color: Colors.white
                                                          .withOpacity(0.3),
                                                      size: 48,
                                                    ),
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
                                if (userHandle.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    userHandle,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.45),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      levelIcon,
                                      color: levelColor,
                                      size: 16,
                                    ),
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
                                StorageService.getPendingAura('zodiac'),
                                StorageService.getPendingAura('kahve'),
                              ]),
                              builder: (context, snapshot) {
                                bool hasUnclaimed = false;
                                int totalPending = 0;
                                if (snapshot.hasData) {
                                  // Gün içinde birden fazla toplanabileceği için 'claimed' kilidi kapatıldı. (Sadece bekleyen fona bakılır)
                                  final pendingFal = snapshot.data![1] as int;
                                  final pendingCookie =
                                      snapshot.data![2] as int;
                                  final pendingDream = snapshot.data![3] as int;
                                  final pendingOwl = snapshot.data![4] as int;

                                  // Nokta sadece gerçekten toplanacak Aura varsa yansın
                                  final pendingZodiac = snapshot.data!.length > 5 ? snapshot.data![5] as int : 0;
                                  final pendingKahve = snapshot.data!.length > 6 ? snapshot.data![6] as int : 0;
                                  totalPending = pendingFal + pendingCookie + pendingDream + pendingOwl + pendingZodiac + pendingKahve;
                                  hasUnclaimed = totalPending > 0;
                                }
                                return _GlassBadge(
                                  imagePath: 'assets/images/aura_core.png',
                                  label: "$formattedAura Aura",
                                  color: const Color(0xFFC084FC),
                                  hasNotification: hasUnclaimed,
                                  onTap: () => _showStatModal(
                                    context,
                                    "Aura Puanı",
                                    availableAura,
                                    Icons.auto_awesome,
                                    const Color(0xFFC084FC),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 10),
                            _GlassBadge(
                              icon: Icons.diamond_rounded,
                              label: "$soulStones Ruh Taşı",
                              color: const Color(0xFF4EE6C5),
                              onTap: () => _showStatModal(
                                context,
                                "Kalan Ruh Taşı",
                                soulStones,
                                Icons.diamond_rounded,
                                const Color(0xFF4EE6C5),
                              ),
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
                            onTap: () => _showStatModal(
                              context,
                              "Açılan Kurabiyeler",
                              totalCookies,
                              Icons.bakery_dining_rounded,
                              const Color(0xFFFFD166),
                            ),
                          );
                        },
                      ),
                      _HeroStatCircle(
                        icon: Icons.amp_stories_rounded,
                        iconColor: const Color(0xFFC084FC),
                        value: totalTarots,
                        isLocked: !isPremium,
                        onTap: () => _showStatModal(
                          context,
                          "Tarot Falları",
                          totalTarots,
                          Icons.amp_stories_rounded,
                          const Color(0xFFC084FC),
                        ),
                      ),
                      _HeroStatCircle(
                        icon: Icons.nights_stay_rounded,
                        iconColor: const Color(0xFF5A8BFF),
                        value: totalDreams,
                        isLocked: !isPremium,
                        onTap: () => _showStatModal(
                          context,
                          "Rüya Analizleri",
                          totalDreams,
                          Icons.nights_stay_rounded,
                          const Color(0xFF5A8BFF),
                        ),
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
                            onTap: () => _showStatModal(
                              context,
                              "Günlük Seri",
                              streakDays,
                              Icons.local_fire_department_rounded,
                              const Color(0xFFFF6B6B),
                            ),
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

  Widget _buildTimeFilterChip(
    String label,
    int value,
    int currentValue,
    Function(int) onChange,
  ) {
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
          color: isSelected
              ? const Color(0xFF6366F1).withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6366F1).withOpacity(0.8)
                : Colors.white.withOpacity(0.05),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static Future<bool> _hasUnclaimedReward(int streakDays) async {
    // Takvimde bugün toplanmamış ateş var mı?
    final today = DateTime.now().toIso8601String().split('T')[0];
    final claimedDays = await StorageService.getClaimedAuraDays();
    if (!claimedDays.contains(today)) return true;

    // Milestone eşikleri
    const thresholds = [7, 14, 30, 50, 100, 365];
    final claimed = await StorageService.getClaimedMilestones();
    for (final t in thresholds) {
      if (streakDays >= t && !claimed.contains(t)) return true;
    }

    return false;
  }

  void _showStatModal(
    BuildContext context,
    String title,
    int value,
    IconData icon,
    Color color,
  ) async {
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
    int pendingKahve = 0;

    int collectedBonus = 0;
    bool sourcesLoaded = false;

    int dreamTimeFilter = 7;

    bool isModalMounted = true;
    int particleCounter = 0;
    List<Map<String, dynamic>> flyingAuras = [];

    void spawnFlyingAura(int amount, Color color, StateSetter setModalState, BuildContext ctx) {
      final id = particleCounter++;
      setModalState(() {
        flyingAuras.add({
          'id': id,
          'amount': amount,
          'color': color,
          'left': 130.0 + (id % 3) * 15.0,
        });
      });
      Future.delayed(const Duration(milliseconds: 700), () {
        if (isModalMounted) {
          setModalState(() {
            flyingAuras.removeWhere((e) => e['id'] == id);
          });
        }
      });
    }

    await showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.15),
      barrierDismissible: true,
      barrierLabel: 'StatModal',
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, anim1, anim2, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 8 * anim1.value,
            sigmaY: 8 * anim1.value,
          ),
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
                StorageService.getPendingAura('kahve'),
              ]).then((results) {
                setModalState(() {
                  pendingFal = results[0];
                  pendingKurabiye = results[1];
                  pendingRuya = results[2];
                  pendingBaykus = results[3];
                  pendingZodiac = results[4];
                  pendingKahve = results[5];
                });
              });
            }
            final int baseAvailable = (modalAuraTotal - modalSpentAura).clamp(
              0,
              999999,
            );
            final int availableAura =
                baseAvailable; // collectedBonus zaten modalAuraTotal içine eklendiği için tekrar eklenmemeli
            final bool canConvert = availableAura >= conversionCost;

            return GestureDetector(
              onTap: () {
                isModalMounted = false;
                Navigator.pop(context);
              },
              child: GestureDetector(
                onTap: () {}, // içeriğe tıklayınca modal kapanmasın
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 40,
                        offset: const Offset(0, 10),
                      ),
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
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            if (title == "Aura Puanı")
                              Image.asset(
                                "assets/images/aura_core.png",
                                width: 56,
                                height: 56,
                                fit: BoxFit.contain,
                              )
                            else if (title == "Açılan Kurabiyeler")
                              Image.asset(
                                "assets/icons/splash_cookie.png",
                                width: 48,
                                height: 48,
                                fit: BoxFit.contain,
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                ),
                                child: Icon(icon, color: color, size: 32),
                              ),
                            const SizedBox(height: 6),
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            if (title == "Aura Puanı")
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(
                                  end: availableAura.toDouble(),
                                ),
                                duration: const Duration(milliseconds: 700),
                                curve: Curves.easeOutCirc,
                                builder: (context, val, child) => Text(
                                  val.toInt().toString(),
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                  ),
                                ),
                              )
                            else if (title == "Kalan Ruh Taşı")
                              Column(
                                children: [
                                  Text(
                                    "${value}",
                                    style: TextStyle(
                                      color: color,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  if (isPremium) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.workspace_premium_rounded,
                                          color: Color(0xFFFFD700),
                                          size: 12,
                                        ),
                                        const SizedBox(width: 4),
                                        const Text(
                                          "5 Günlük (Elite)",
                                          style: TextStyle(
                                            color: Color(0xFFFFD700),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              )
                            else if (title != "Tarot Falları" &&
                                title != "Rüya Analizleri" &&
                                title != "Açılan Kurabiyeler" &&
                                title != "Günlük Seri")
                              Text(
                                "$value",
                                style: TextStyle(
                                  color: color,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                            if (title == "Aura Puanı")
                              Padding(
                                padding: const EdgeInsets.only(top: 0),
                                child: Text(
                                  "Toplam $modalAuraTotal Aura kazanıldı",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.3),
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 6),

                            if (title == "Aura Puanı") ...[
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      "200 Aura = 1 Ruh Taşı",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.35),
                                        fontSize: 11,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),

                                  Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(24),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 150,
                                      ),
                                      decoration: BoxDecoration(
                                        color: showSuccess
                                            ? const Color(
                                                0xFF10B981,
                                              ).withOpacity(0.12)
                                            : (canConvert
                                                  ? const Color(
                                                      0xFF4EE6C5,
                                                    ).withOpacity(0.12)
                                                  : Colors.white.withOpacity(
                                                      0.03,
                                                    )),
                                        border: Border.all(
                                          color: showSuccess
                                              ? const Color(
                                                  0xFF10B981,
                                                ).withOpacity(0.3)
                                              : (canConvert
                                                    ? const Color(
                                                        0xFF4EE6C5,
                                                      ).withOpacity(0.3)
                                                    : Colors.white.withOpacity(
                                                        0.08,
                                                      )),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: InkWell(
                                        onTap: (canConvert && !showSuccess)
                                            ? () async {
                                                HapticFeedback.heavyImpact();
                                                final success =
                                                    await onConvertAura();
                                                if (success) {
                                                  setModalState(() {
                                                    modalSpentAura +=
                                                        conversionCost;
                                                    modalSoulStones += 1;
                                                    showSuccess = true;
                                                  });
                                                  Future.delayed(
                                                    const Duration(
                                                      milliseconds: 1000,
                                                    ),
                                                    () {
                                                      if (context.mounted)
                                                        setModalState(
                                                          () => showSuccess =
                                                              false,
                                                        );
                                                    },
                                                  );
                                                }
                                              }
                                            : null,
                                        borderRadius: BorderRadius.circular(24),
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          child: AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 150,
                                            ),
                                            child: showSuccess
                                                ? const Row(
                                                    key: ValueKey("success"),
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .check_circle_rounded,
                                                        color: Color(
                                                          0xFF10B981,
                                                        ),
                                                        size: 16,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        "Ruh Taşı Üretildi",
                                                        style: TextStyle(
                                                          color: Color(
                                                            0xFF10B981,
                                                          ),
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          letterSpacing: 1,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Row(
                                                    key: const ValueKey(
                                                      "convert",
                                                    ),
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.diamond_rounded,
                                                        color: canConvert
                                                            ? const Color(
                                                                0xFF4EE6C5,
                                                              )
                                                            : Colors.white
                                                                  .withOpacity(
                                                                    0.2,
                                                                  ),
                                                        size: 16,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        canConvert
                                                            ? "Ruh Taşına Çevir"
                                                            : "Yetersiz Aura ($availableAura/200)",
                                                        style: TextStyle(
                                                          color: canConvert
                                                              ? const Color(
                                                                  0xFF4EE6C5,
                                                                )
                                                              : Colors.white
                                                                    .withOpacity(
                                                                      0.2,
                                                                    ),
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          letterSpacing: 1,
                                                        ),
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
                                      color: showSuccess
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFF4EE6C5),
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.02),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.05),
                                  ),
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      _buildAuraSource(
                                        Icons.nights_stay_rounded,
                                        "Rüya",
                                        pendingRuya,
                                        () {
                                          if (pendingRuya == 0) return;
                                          HapticFeedback.heavyImpact();
                                          final pts = pendingRuya;
                                          setModalState(() {
                                            pendingRuya = 0;
                                            collectedBonus += pts;
                                            modalAuraTotal += pts;
                                          });
                                          spawnFlyingAura(pts, const Color(0xFF5A8BFF), setModalState, context);
                                          StorageService.clearPendingAura(
                                            'ruya',
                                          );
                                          StorageService.addBonusAura(pts);
                                          onAuraClaimed?.call();
                                        },
                                        color: const Color(0xFF5A8BFF),
                                      ),
                                      _buildAuraSource(
                                        Icons.amp_stories_rounded,
                                        "Tarot",
                                        pendingFal,
                                        () {
                                          if (pendingFal == 0) return;
                                          HapticFeedback.heavyImpact();
                                          final pts = pendingFal;
                                          setModalState(() {
                                            pendingFal = 0;
                                            collectedBonus += pts;
                                            modalAuraTotal += pts;
                                          });
                                          spawnFlyingAura(pts, const Color(0xFFC084FC), setModalState, context);
                                          StorageService.clearPendingAura(
                                            'fal',
                                          );
                                          StorageService.addBonusAura(pts);
                                          onAuraClaimed?.call();
                                        },
                                        color: const Color(0xFFC084FC),
                                      ),
                                      _buildAuraSource(
                                        Icons.data_usage_rounded,
                                        "Burç",
                                        pendingZodiac,
                                        () {
                                          if (pendingZodiac == 0) return;
                                          HapticFeedback.heavyImpact();
                                          final pts = pendingZodiac;
                                          setModalState(() {
                                            pendingZodiac = 0;
                                            collectedBonus += pts;
                                            modalAuraTotal += pts;
                                          });
                                          spawnFlyingAura(pts, const Color(0xFFFFD700), setModalState, context);
                                          StorageService.clearPendingAura(
                                            'zodiac',
                                          );
                                          StorageService.addBonusAura(pts);
                                          onAuraClaimed?.call();
                                        },
                                        color: const Color(0xFFFFD700),
                                      ),
                                      _buildAuraSource(
                                        Icons.cookie,
                                        "Kurabiye",
                                        pendingKurabiye,
                                        () {
                                          if (pendingKurabiye == 0) return;
                                          HapticFeedback.heavyImpact();
                                          final pts = pendingKurabiye;
                                          setModalState(() {
                                            pendingKurabiye = 0;
                                            collectedBonus += pts;
                                            modalAuraTotal += pts;
                                          });
                                          spawnFlyingAura(pts, const Color(0xFFFFD166), setModalState, context);
                                          StorageService.clearPendingAura(
                                            'kurabiye',
                                          );
                                          StorageService.addBonusAura(pts);
                                          onAuraClaimed?.call();
                                        },
                                        color: const Color(0xFFFFD166),
                                        imagePath:
                                            'assets/icons/splash_cookie.png',
                                      ),
                                      _buildAuraSource(
                                        Icons.mail_rounded,
                                        "Baykuş",
                                        pendingBaykus,
                                        () {
                                          if (pendingBaykus == 0) return;
                                          HapticFeedback.heavyImpact();
                                          final pts = pendingBaykus;
                                          setModalState(() {
                                            pendingBaykus = 0;
                                            collectedBonus += pts;
                                            modalAuraTotal += pts;
                                          });
                                          spawnFlyingAura(pts, const Color(0xFF4EE6C5), setModalState, context);
                                          StorageService.clearPendingAura(
                                            'baykus',
                                          );
                                          StorageService.addBonusAura(pts);
                                          onAuraClaimed?.call();
                                        },
                                        color: const Color(0xFF4EE6C5),
                                      ),
                                      _buildAuraSource(
                                        Icons.local_cafe_rounded,
                                        "Kahve",
                                        pendingKahve,
                                        () {
                                          if (pendingKahve == 0) return;
                                          HapticFeedback.heavyImpact();
                                          final pts = pendingKahve;
                                          setModalState(() {
                                            pendingKahve = 0;
                                            collectedBonus += pts;
                                            modalAuraTotal += pts;
                                          });
                                          spawnFlyingAura(pts, const Color(0xFFD4A373), setModalState, context);
                                          StorageService.clearPendingAura(
                                            'kahve',
                                          );
                                          StorageService.addBonusAura(pts);
                                          onAuraClaimed?.call();
                                        },
                                        color: const Color(0xFFD4A373),
                                      ),
                                      _buildAuraSource(
                                        Icons.diamond_rounded,
                                        "Ruh Taşı",
                                        0,
                                        () {
                                          HapticFeedback.selectionClick();
                                        },
                                        color: const Color(0xFF22D3EE),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ] else if (title == "Kalan Ruh Taşı") ...[
                              Text(
                                "Not: Aura Puanı panelinden\npuanlarınızı Ruh Taşına dönüştürebilirsiniz.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 9,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildSoulStoreCard(
                                      context,
                                      "1 Taş",
                                      "₺24.99",
                                      const Color(0xFF4EE6C5),
                                      isSelected: selectedStoreIndex == 0,
                                      onTap: () => setModalState(
                                        () => selectedStoreIndex = 0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: _buildSoulStoreCard(
                                      context,
                                      "3 Taş",
                                      "₺59.99",
                                      const Color(0xFFC084FC),
                                      isPopular: true,
                                      isSelected: selectedStoreIndex == 1,
                                      onTap: () => setModalState(
                                        () => selectedStoreIndex = 1,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: _buildSoulStoreCard(
                                      context,
                                      "10 Taş",
                                      "₺149.99",
                                      const Color(0xFFFFD700),
                                      isSelected: selectedStoreIndex == 2,
                                      onTap: () => setModalState(
                                        () => selectedStoreIndex = 2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: selectedStoreIndex != -1
                                      ? () {
                                          HapticFeedback.heavyImpact();
                                        }
                                      : null,
                                  borderRadius: BorderRadius.circular(24),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: selectedStoreIndex != -1
                                          ? const Color(
                                              0xFFC084FC,
                                            ).withOpacity(0.18)
                                          : Colors.white.withOpacity(0.03),
                                      border: Border.all(
                                        color: selectedStoreIndex != -1
                                            ? const Color(
                                                0xFFC084FC,
                                              ).withOpacity(0.4)
                                            : Colors.white.withOpacity(0.08),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Satın Al",
                                        style: TextStyle(
                                          color: selectedStoreIndex != -1
                                              ? const Color(0xFFC084FC)
                                              : Colors.white.withOpacity(0.2),
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Elite üyeler her gün 5 bedava Ruh Taşı kazanır.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(
                                    0xFFFFD700,
                                  ).withOpacity(0.8),
                                  fontSize: 9,
                                ),
                              ),
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
                                        future:
                                            UserStatsService.getSignatureCard(),
                                        builder: (context, snapshot) {
                                          final result = snapshot.data;
                                          final bool isLocked = result == null;
                                          final String cardImagePath = isLocked
                                              ? ''
                                              : resolveCardAsset(
                                                  result.cardName,
                                                  result.cardAsset,
                                                );

                                          return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "İmza Kartın",
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.7),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              const SizedBox(height: 1),
                                              Text(
                                                isLocked
                                                    ? "Fal baktır ve keşfet"
                                                    : result.periodLabel,
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                  fontSize: 7.5,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Container(
                                                width: 78,
                                                height: 118,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: isLocked
                                                      ? []
                                                      : [
                                                          BoxShadow(
                                                            color: const Color(
                                                              0xFFC084FC,
                                                            ).withOpacity(0.3),
                                                            blurRadius: 20,
                                                            spreadRadius: 2,
                                                          ),
                                                        ],
                                                  border: Border.all(
                                                    color: isLocked
                                                        ? Colors.white
                                                              .withOpacity(0.1)
                                                        : Colors.white
                                                              .withOpacity(0.3),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: isLocked
                                                    ? Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                9,
                                                              ),
                                                          gradient: LinearGradient(
                                                            colors: [
                                                              Colors.white
                                                                  .withOpacity(
                                                                    0.08,
                                                                  ),
                                                              Colors.white
                                                                  .withOpacity(
                                                                    0.02,
                                                                  ),
                                                            ],
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                          ),
                                                        ),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .lock_outline_rounded,
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                    0.3,
                                                                  ),
                                                              size: 28,
                                                            ),
                                                            const SizedBox(
                                                              height: 6,
                                                            ),
                                                            Text(
                                                              "GİZLİ",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                      0.4,
                                                                    ),
                                                                fontSize: 8,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                letterSpacing:
                                                                    1,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    : ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              9,
                                                            ),
                                                        child: Transform.scale(
                                                          scale: 1.15,
                                                          child: Image.asset(
                                                            cardImagePath,
                                                            width: 78,
                                                            height: 118,
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (_, __, ___) => Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .auto_awesome,
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                        0.5,
                                                                      ),
                                                                  size: 24,
                                                                ),
                                                                const SizedBox(
                                                                  height: 4,
                                                                ),
                                                                Text(
                                                                  result
                                                                      .cardName,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                          0.6,
                                                                        ),
                                                                    fontSize: 7,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                isLocked
                                                    ? "? ? ?"
                                                    : result.cardName,
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.9),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      color: Colors.white.withOpacity(0.08),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12.0,
                                        ),
                                        child: FutureBuilder<Set<String>>(
                                          future:
                                              UserStatsService.getDiscoveredCards(),
                                          builder: (context, snapshot) {
                                            final discovered =
                                                snapshot.data ?? {};
                                            final int count = discovered.length;
                                            const int totalCards = 78;

                                            final allAssets =
                                                getAllCardAssets();

                                            String rank;
                                            Color rankColor;
                                            if (count == 0) {
                                              rank = "Keşfedilmemiş";
                                              rankColor = Colors.white
                                                  .withOpacity(0.3);
                                            } else if (count < 10) {
                                              rank = "Çırak";
                                              rankColor = const Color(
                                                0xFF94A3B8,
                                              );
                                            } else if (count < 25) {
                                              rank = "Gezgin";
                                              rankColor = const Color(
                                                0xFF38BDF8,
                                              );
                                            } else if (count < 45) {
                                              rank = "Kaşif";
                                              rankColor = const Color(
                                                0xFFA78BFA,
                                              );
                                            } else if (count < 65) {
                                              rank = "Bilge";
                                              rankColor = const Color(
                                                0xFFC084FC,
                                              );
                                            } else if (count < 78) {
                                              rank = "Usta";
                                              rankColor = const Color(
                                                0xFFF59E0B,
                                              );
                                            } else {
                                              rank = "Grandmaster";
                                              rankColor = const Color(
                                                0xFFD4AF37,
                                              );
                                            }

                                            return Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "$count",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      " / $totalCards",
                                                      style: TextStyle(
                                                        color: Colors.white
                                                            .withOpacity(0.3),
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 3),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                    color: rankColor
                                                        .withOpacity(0.15),
                                                  ),
                                                  child: Text(
                                                    rank,
                                                    style: TextStyle(
                                                      color: rankColor,
                                                      fontSize: 8,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      letterSpacing: 0.3,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 10),

                                                Wrap(
                                                  spacing: 2.5,
                                                  runSpacing: 2.5,
                                                  alignment:
                                                      WrapAlignment.center,
                                                  children: List.generate(
                                                    allAssets.length,
                                                    (i) {
                                                      final isDiscovered =
                                                          discovered.contains(
                                                            allAssets[i],
                                                          );
                                                      return Container(
                                                        width: 10,
                                                        height: 13,
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                2,
                                                              ),
                                                          color: isDiscovered
                                                              ? const Color(
                                                                  0xFFC084FC,
                                                                )
                                                              : Colors.white
                                                                    .withOpacity(
                                                                      0.06,
                                                                    ),
                                                          boxShadow:
                                                              isDiscovered
                                                              ? [
                                                                  BoxShadow(
                                                                    color: const Color(
                                                                      0xFFC084FC,
                                                                    ).withOpacity(0.4),
                                                                    blurRadius:
                                                                        4,
                                                                  ),
                                                                ]
                                                              : [],
                                                        ),
                                                      );
                                                    },
                                                  ),
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
                                    final lastDream = hasDream
                                        ? dreams.first
                                        : null;

                                    String lastTitle = "Teşhis Yok";
                                    String userDraft =
                                        "Henüz bir rüya kaydetmediniz.";

                                    if (hasDream && lastDream != null) {
                                      userDraft =
                                          lastDream['text'] ??
                                          "Bilinçaltı verisi...";
                                      if (userDraft.length > 45)
                                        userDraft =
                                            "${userDraft.substring(0, 42)}...";

                                      lastTitle =
                                          lastDream['title'] ??
                                          (lastDream['text'] != null
                                              ? "Bilinçaltı Mesajı"
                                              : "Gizemli Rüya");
                                      if (lastTitle.length > 25)
                                        lastTitle =
                                            "${lastTitle.substring(0, 22)}...";
                                    }

                                    List<Map<String, dynamic>> filteredDreams =
                                        dreams;
                                    if (dreamTimeFilter > 0) {
                                      final limitDate = DateTime.now().subtract(
                                        Duration(days: dreamTimeFilter),
                                      );
                                      filteredDreams = dreams.where((d) {
                                        if (d['date'] == null) return false;
                                        try {
                                          return DateTime.parse(
                                            d['date'].toString(),
                                          ).isAfter(limitDate);
                                        } catch (_) {
                                          return false;
                                        }
                                      }).toList();
                                    }

                                    final totalCount = filteredDreams.length;

                                    Map<String, int> emotionCounts = {};
                                    for (var d in filteredDreams) {
                                      String? em =
                                          d['emotion']?.toString() ??
                                          d['mood']?.toString();
                                      if (em != null && em.isNotEmpty) {
                                        emotionCounts[em] =
                                            (emotionCounts[em] ?? 0) + 1;
                                      }
                                    }

                                    String dominantInsight = "";
                                    if (emotionCounts.isNotEmpty) {
                                      var sorted =
                                          emotionCounts.entries.toList()..sort(
                                            (a, b) =>
                                                b.value.compareTo(a.value),
                                          );
                                      var topEmotion = sorted.first;
                                      int pct =
                                          ((topEmotion.value / totalCount) *
                                                  100)
                                              .toInt();

                                      Map<String, String> trMap = {
                                        'fear': 'Korku',
                                        'anxiety': 'Kaygı',
                                        'joy': 'Neşe',
                                        'sadness': 'Hüzün',
                                        'confusion': 'Karmaşa',
                                        'peace': 'Huzur',
                                        'anger': 'Öfke',
                                      };
                                      String emLabel =
                                          trMap[topEmotion.key] ??
                                          topEmotion.key;

                                      if (dreamTimeFilter == 3) {
                                        dominantInsight =
                                            "Uyku anlarının %$pct kadarı '$emLabel' temalı.";
                                      } else if (dreamTimeFilter == 7) {
                                        dominantInsight =
                                            "Haftalık rüyalarının %$pct kadarı '$emLabel' etkisinde.";
                                      } else if (dreamTimeFilter == 30) {
                                        dominantInsight =
                                            "Aylık rüyalarının %$pct kadarı '$emLabel' yüklü.";
                                      } else {
                                        dominantInsight =
                                            "Genel olarak rüyalarının %$pct kadarı '$emLabel' temalı.";
                                      }
                                    } else {
                                      if (dreamTimeFilter == 3) {
                                        dominantInsight =
                                            "Son 3 güne ait kaydın yok. Zihnini keşfetmek için ilk adımını at.";
                                      } else if (dreamTimeFilter == 7) {
                                        dominantInsight =
                                            "Bu hafta henüz rüya kaydetmedin. Bilinçaltınla bağ kurmaya başla.";
                                      } else {
                                        dominantInsight =
                                            "Bu ayki rüya günlüğün henüz boş. Gizemleri çözmek için beklemedeyiz.";
                                      }
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14.0,
                                        vertical: 4.0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              _buildTimeFilterChip(
                                                "3 Gün",
                                                3,
                                                dreamTimeFilter,
                                                (val) => setModalState(
                                                  () => dreamTimeFilter = val,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              _buildTimeFilterChip(
                                                "7 Gün",
                                                7,
                                                dreamTimeFilter,
                                                (val) => setModalState(
                                                  () => dreamTimeFilter = val,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              _buildTimeFilterChip(
                                                "1 Ay",
                                                30,
                                                dreamTimeFilter,
                                                (val) => setModalState(
                                                  () => dreamTimeFilter = val,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),

                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF6366F1,
                                              ).withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: const Color(
                                                  0xFF6366F1,
                                                ).withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: const Color(
                                                      0xFF818CF8,
                                                    ).withOpacity(0.2),
                                                  ),
                                                  child: const Icon(
                                                    Icons.insights_rounded,
                                                    color: Color(0xFF818CF8),
                                                    size: 16,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        dreamTimeFilter == 3
                                                            ? "SON 3 GÜN"
                                                            : (dreamTimeFilter ==
                                                                      7
                                                                  ? "HAFTALIK ÖZET"
                                                                  : "AYLIK ÖZET"),
                                                        style: TextStyle(
                                                          color: const Color(
                                                            0xFF818CF8,
                                                          ).withOpacity(0.8),
                                                          fontSize: 8,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          letterSpacing: 1.0,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        dominantInsight,
                                                        style: TextStyle(
                                                          color: Colors.white
                                                              .withOpacity(
                                                                0.85,
                                                              ),
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          height: 1.3,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(height: 10),

                                          if (totalCount <
                                              (dreamTimeFilter == 3
                                                  ? 3
                                                  : (dreamTimeFilter == 7
                                                        ? 7
                                                        : 15))) ...[
                                            // Minimum rüya gerekli — dönem bazlı mesaj
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 6.0,
                                                  ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      dreamTimeFilter == 3
                                                          ? "Son 3 günde en az 3 rüya kaydet."
                                                          : dreamTimeFilter == 7
                                                          ? "Son 7 günde en az 7 rüya kaydet."
                                                          : "Son 1 ayda en az 15 rüya kaydet.",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.white
                                                            .withOpacity(0.3),
                                                        fontSize: 10,
                                                        height: 1.4,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  GestureDetector(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (_) => AlertDialog(
                                                          backgroundColor:
                                                              const Color(
                                                                0xFF1A1A2E,
                                                              ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  16,
                                                                ),
                                                          ),
                                                          title: Text(
                                                            "Duygu Dağılımı Nedir?",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                          ),
                                                          content: Text(
                                                            "Rüya günlüğüne kaydettiğin rüyalar, yapay zeka tarafından analiz edilerek duygusal temalar belirlenir.\n\nSeçtiğin zaman dilimi (3, 7 veya 30 gün) için yeterli veri toplandıktan sonra hangi duyguların ön plana çıktığını görebilirsin.",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                    0.7,
                                                                  ),
                                                              fontSize: 12,
                                                              height: 1.5,
                                                            ),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                  ),
                                                              child: const Text(
                                                                "Anladım",
                                                                style: TextStyle(
                                                                  color: Color(
                                                                    0xFF818CF8,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                    child: Icon(
                                                      Icons
                                                          .help_outline_rounded,
                                                      color: Colors.white
                                                          .withOpacity(0.2),
                                                      size: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ] else ...[
                                            // Yeterli veri var — grafik göster
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 4.0,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "Duygu Dağılımı",
                                                    style: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(0.5),
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Text(
                                                    "$totalCount Kayıt Analizi",
                                                    style: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(0.3),
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 10),

                                            if (emotionCounts.isEmpty)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8.0,
                                                    ),
                                                child: Center(
                                                  child: Text(
                                                    "Grafik oluşturmak için veri bekleniyor.",
                                                    style: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(0.3),
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            else
                                              Builder(
                                                builder: (context) {
                                                  // Duygu çevirisi ve renk haritası
                                                  const Map<String, String>
                                                  localTr = {
                                                    'fear': 'Korku',
                                                    'anxiety': 'Kaygı',
                                                    'joy': 'Neşe',
                                                    'happy': 'Mutluluk',
                                                    'happiness': 'Mutluluk',
                                                    'sadness': 'Hüzün',
                                                    'sad': 'Hüzün',
                                                    'confusion': 'Karmaşa',
                                                    'peace': 'Huzur',
                                                    'peaceful': 'Huzurlu',
                                                    'anger': 'Öfke',
                                                    'angry': 'Öfkeli',
                                                    'neutral': 'Nötr',
                                                    'curiosity': 'Merak',
                                                    'surprise': 'Şaşkınlık',
                                                    'love': 'Aşk',
                                                    'hope': 'Umut',
                                                    'nostalgia': 'Nostalji',
                                                    'excitement': 'Heyecan',
                                                  };
                                                  const Map<String, Color>
                                                  emotionColors = {
                                                    'Korku': Color(0xFFFF6B6B),
                                                    'Kaygı': Color(0xFFFF9F43),
                                                    'Neşe': Color(0xFF4EE6C5),
                                                    'Mutluluk': Color(
                                                      0xFF48DBFB,
                                                    ),
                                                    'Hüzün': Color(0xFF818CF8),
                                                    'Karmaşa': Color(
                                                      0xFFFECA57,
                                                    ),
                                                    'Huzur': Color(0xFF1DD1A1),
                                                    'Huzurlu': Color(
                                                      0xFF1DD1A1,
                                                    ),
                                                    'Öfke': Color(0xFFEE5A6F),
                                                    'Öfkeli': Color(0xFFEE5A6F),
                                                    'Nötr': Color(0xFF636E72),
                                                    'Merak': Color(0xFFA29BFE),
                                                    'Şaşkınlık': Color(
                                                      0xFFFF6348,
                                                    ),
                                                    'Aşk': Color(0xFFFF6B81),
                                                    'Umut': Color(0xFF55EFC4),
                                                    'Nostalji': Color(
                                                      0xFFDDA0DD,
                                                    ),
                                                    'Heyecan': Color(
                                                      0xFFFFD32A,
                                                    ),
                                                  };
                                                  const Map<String, String>
                                                  emotionEmojis = {
                                                    'Korku': '😰',
                                                    'Kaygı': '😟',
                                                    'Neşe': '😊',
                                                    'Mutluluk': '😄',
                                                    'Hüzün': '😢',
                                                    'Karmaşa': '😵‍💫',
                                                    'Huzur': '😌',
                                                    'Huzurlu': '😌',
                                                    'Öfke': '😤',
                                                    'Öfkeli': '😤',
                                                    'Nötr': '😐',
                                                    'Merak': '🧐',
                                                    'Şaşkınlık': '😮',
                                                    'Aşk': '❤️',
                                                    'Umut': '🌱',
                                                    'Nostalji': '🌅',
                                                    'Heyecan': '🤩',
                                                  };

                                                  final sorted =
                                                      emotionCounts.entries
                                                          .toList()
                                                        ..sort(
                                                          (a, b) =>
                                                              b.value.compareTo(
                                                                a.value,
                                                              ),
                                                        );
                                                  final top = sorted
                                                      .take(5)
                                                      .toList();

                                                  // Donut grafik verileri
                                                  final List<_EmotionSlice>
                                                  slices = top.map((e) {
                                                    final label =
                                                        localTr[e.key
                                                            .toLowerCase()] ??
                                                        e.key;
                                                    final pct =
                                                        (e.value /
                                                        totalCount *
                                                        100);
                                                    final color =
                                                        emotionColors[label] ??
                                                        const Color(0xFF818CF8);
                                                    final emoji =
                                                        emotionEmojis[label] ??
                                                        '🔮';
                                                    return _EmotionSlice(
                                                      label: label,
                                                      percentage: pct,
                                                      color: color,
                                                      emoji: emoji,
                                                      count: e.value,
                                                    );
                                                  }).toList();

                                                  return Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      // Sol: Donut Chart
                                                      SizedBox(
                                                        width: 95,
                                                        height: 95,
                                                        child: TweenAnimationBuilder<double>(
                                                          tween: Tween<double>(
                                                            begin: 0.0,
                                                            end: 1.0,
                                                          ),
                                                          duration:
                                                              const Duration(
                                                                milliseconds:
                                                                    1400,
                                                              ),
                                                          curve: Curves
                                                              .easeOutCubic,
                                                          builder: (context, value, child) {
                                                            return CustomPaint(
                                                              painter:
                                                                  _EmotionDonutPainter(
                                                                    slices:
                                                                        slices,
                                                                    animationValue:
                                                                        value,
                                                                  ),
                                                              child: child,
                                                            );
                                                          },
                                                          child: Center(
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Text(
                                                                  "$totalCount",
                                                                  style: const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w800,
                                                                    height: 1.0,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 2,
                                                                ),
                                                                Text(
                                                                  "rüya",
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                          0.4,
                                                                        ),
                                                                    fontSize: 9,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    letterSpacing:
                                                                        0.5,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 20),
                                                      // Sağ: Legend listesi
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: slices.map((
                                                            s,
                                                          ) {
                                                            return Padding(
                                                              padding:
                                                                  const EdgeInsets.only(
                                                                    bottom: 5.0,
                                                                  ),
                                                              child: Row(
                                                                children: [
                                                                  Container(
                                                                    width: 9,
                                                                    height: 9,
                                                                    decoration: BoxDecoration(
                                                                      color: s
                                                                          .color,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            3,
                                                                          ),
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color: s.color.withOpacity(
                                                                            0.5,
                                                                          ),
                                                                          blurRadius:
                                                                              5,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 8,
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      s.label,
                                                                      style: TextStyle(
                                                                        color: Colors
                                                                            .white
                                                                            .withOpacity(
                                                                              0.9,
                                                                            ),
                                                                        fontSize:
                                                                            11,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        letterSpacing:
                                                                            0.2,
                                                                      ),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    "%${s.percentage.toInt()}",
                                                                    style: TextStyle(
                                                                      color: s
                                                                          .color
                                                                          .withOpacity(
                                                                            0.95,
                                                                          ),
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w900,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          }).toList(),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                          ], // else (totalCount >= 3)
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
                                    return const Expanded(
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: Color(0xFFFF6B6B),
                                        ),
                                      ),
                                    );
                                  }

                                  final installDate =
                                      snapshot.data![0] as DateTime;
                                  final appOpenDays =
                                      snapshot.data![1] as Set<String>;
                                  final claimedDays =
                                      snapshot.data![2] as Set<String>;
                                  final now = DateTime.now();
                                  final nowNorm = DateTime(
                                    now.year,
                                    now.month,
                                    now.day,
                                  );

                                  int totalMonths =
                                      (now.year - installDate.year) * 12 +
                                      now.month -
                                      installDate.month +
                                      1;
                                  if (totalMonths < 1) totalMonths = 1;

                                  final totalOpenDays = appOpenDays.length;
                                  int nextTarget = 7;
                                  if (totalOpenDays >= 7) nextTarget = 14;
                                  if (totalOpenDays >= 14) nextTarget = 30;
                                  if (totalOpenDays >= 30) nextTarget = 50;
                                  if (totalOpenDays >= 50) nextTarget = 100;
                                  if (totalOpenDays >= 100) nextTarget = 365;

                                  final monthNames = [
                                    "Ocak",
                                    "Şubat",
                                    "Mart",
                                    "Nisan",
                                    "Mayıs",
                                    "Haziran",
                                    "Temmuz",
                                    "Ağustos",
                                    "Eylül",
                                    "Ekim",
                                    "Kasım",
                                    "Aralık",
                                  ];
                                  final weekDays = [
                                    "Pzt",
                                    "Sal",
                                    "Çar",
                                    "Per",
                                    "Cum",
                                    "Cmt",
                                    "Paz",
                                  ];

                                  return Expanded(
                                    child: PageView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      controller: PageController(
                                        initialPage: totalMonths - 1,
                                      ),
                                      itemCount: totalMonths,
                                      itemBuilder: (context, pageIndex) {
                                        int targetMonth =
                                            installDate.month + pageIndex;
                                        int targetYear =
                                            installDate.year +
                                            ((targetMonth - 1) ~/ 12);
                                        targetMonth =
                                            ((targetMonth - 1) % 12) + 1;

                                        final firstDayOfMonth = DateTime(
                                          targetYear,
                                          targetMonth,
                                          1,
                                        );
                                        final lastDayOfMonth = DateTime(
                                          targetYear,
                                          targetMonth + 1,
                                          0,
                                        );
                                        final daysInMonth = lastDayOfMonth.day;
                                        final firstWeekday =
                                            firstDayOfMonth.weekday;

                                        List<Widget> calendarDays = [];

                                        for (var day in weekDays) {
                                          calendarDays.add(
                                            Center(
                                              child: Text(
                                                day,
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.45),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          );
                                        }

                                        for (int i = 1; i < firstWeekday; i++) {
                                          calendarDays.add(const SizedBox());
                                        }

                                        for (int i = 1; i <= daysInMonth; i++) {
                                          final testDate = DateTime(
                                            targetYear,
                                            targetMonth,
                                            i,
                                          );
                                          final isToday =
                                              testDate.year == nowNorm.year &&
                                              testDate.month == nowNorm.month &&
                                              testDate.day == nowNorm.day;
                                          final isFuture = testDate.isAfter(
                                            nowNorm,
                                          );
                                          final dateKey =
                                              "${targetYear.toString().padLeft(4, '0')}-${targetMonth.toString().padLeft(2, '0')}-${i.toString().padLeft(2, '0')}";
                                          final isAppOpenDay =
                                              isToday ||
                                              appOpenDays.contains(
                                                dateKey,
                                              ); // Bugün her zaman açık — kullanıcı şu an uygulamada
                                          final isClaimed = claimedDays
                                              .contains(dateKey);

                                          final prevDate = testDate.subtract(
                                            const Duration(days: 1),
                                          );
                                          final nextDate = testDate.add(
                                            const Duration(days: 1),
                                          );
                                          final prevKey =
                                              "${prevDate.year.toString().padLeft(4, '0')}-${prevDate.month.toString().padLeft(2, '0')}-${prevDate.day.toString().padLeft(2, '0')}";
                                          final nextKey =
                                              "${nextDate.year.toString().padLeft(4, '0')}-${nextDate.month.toString().padLeft(2, '0')}-${nextDate.day.toString().padLeft(2, '0')}";

                                          final dayIdx =
                                              firstWeekday - 1 + i - 1;
                                          final isPrevOpen =
                                              appOpenDays.contains(prevKey) ||
                                              (prevDate.year == nowNorm.year &&
                                                  prevDate.month ==
                                                      nowNorm.month &&
                                                  prevDate.day == nowNorm.day);
                                          final isNextOpen =
                                              appOpenDays.contains(nextKey) ||
                                              (nextDate.year == nowNorm.year &&
                                                  nextDate.month ==
                                                      nowNorm.month &&
                                                  nextDate.day == nowNorm.day);
                                          final isConnectedLeft =
                                              dayIdx % 7 != 0 &&
                                              isAppOpenDay &&
                                              isPrevOpen;
                                          final isConnectedRight =
                                              dayIdx % 7 != 6 &&
                                              isAppOpenDay &&
                                              isNextOpen;

                                          calendarDays.add(
                                            _ClaimableFireCell(
                                              day: i,
                                              isToday: isToday,
                                              isFuture: isFuture,
                                              isAppOpenDay: isAppOpenDay,
                                              isClaimed: isClaimed,
                                              isConnectedLeft: isConnectedLeft,
                                              isConnectedRight:
                                                  isConnectedRight,
                                              isWeekend:
                                                  testDate.weekday ==
                                                      DateTime.saturday ||
                                                  testDate.weekday ==
                                                      DateTime.sunday,
                                              dateKey: dateKey,
                                              onClaimed: () {
                                                final weekendBonus =
                                                    (testDate.weekday ==
                                                            DateTime.saturday ||
                                                        testDate.weekday ==
                                                            DateTime.sunday)
                                                    ? 2
                                                    : 1;
                                                setModalState(() {
                                                  claimedDays.add(dateKey);
                                                  modalAuraTotal +=
                                                      weekendBonus;
                                                });
                                                if (onAuraClaimed != null) {
                                                  onAuraClaimed!();
                                                }
                                              },
                                            ),
                                          );
                                        }

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 0,
                                          ),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 0,
                                                  bottom: 10,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "${monthNames[targetMonth - 1]} $targetYear",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons
                                                              .local_fire_department_rounded,
                                                          color: Color(
                                                            0xFFFF6B6B,
                                                          ),
                                                          size: 12,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          "$nextTarget Gün Hedefi",
                                                          style: TextStyle(
                                                            color: const Color(
                                                              0xFFFF6B6B,
                                                            ).withOpacity(0.8),
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: LayoutBuilder(
                                                  builder: (context, constraints) {
                                                    final rowCount =
                                                        (calendarDays.length /
                                                                7)
                                                            .ceil();
                                                    const spacing = 5.0;
                                                    final totalSpacing =
                                                        spacing *
                                                        (rowCount - 1);
                                                    double itemHeight =
                                                        (constraints.maxHeight -
                                                            totalSpacing) /
                                                        rowCount;

                                                    return GridView.builder(
                                                      padding: EdgeInsets.zero,
                                                      shrinkWrap: false,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      gridDelegate:
                                                          SliverGridDelegateWithFixedCrossAxisCount(
                                                            crossAxisCount: 7,
                                                            mainAxisSpacing:
                                                                spacing,
                                                            crossAxisSpacing:
                                                                spacing,
                                                            mainAxisExtent:
                                                                itemHeight,
                                                          ),
                                                      itemCount:
                                                          calendarDays.length,
                                                      itemBuilder:
                                                          (context, index) =>
                                                              calendarDays[index],
                                                    );
                                                  },
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                              // ── Toplanmamış Milestone Ödülleri ──
                              FutureBuilder<List<int>>(
                                future: StorageService.getClaimedMilestones(),
                                builder: (context, milestoneSnap) {
                                  final claimed = milestoneSnap.data ?? [];
                                  const thresholds = [7, 14, 30, 50, 100, 365];
                                  final rewards = <String, dynamic>{
                                    '7': {
                                      'text': '+15 Aura',
                                      'icon': Icons.auto_awesome,
                                      'color': const Color(0xFFC084FC),
                                    },
                                    '14': {
                                      'text': '+30 Aura',
                                      'icon': Icons.auto_awesome,
                                      'color': const Color(0xFFC084FC),
                                    },
                                    '30': {
                                      'text': '+1 Ruh Taşı',
                                      'icon': Icons.diamond_rounded,
                                      'color': const Color(0xFF4EE6C5),
                                    },
                                    '50': {
                                      'text': '+2 Ruh Taşı',
                                      'icon': Icons.diamond_rounded,
                                      'color': const Color(0xFF4EE6C5),
                                    },
                                    '100': {
                                      'text': '+3 Ruh Taşı',
                                      'icon': Icons.diamond_rounded,
                                      'color': const Color(0xFF4EE6C5),
                                    },
                                    '365': {
                                      'text': '+5 Ruh Taşı',
                                      'icon': Icons.diamond_rounded,
                                      'color': const Color(0xFF4EE6C5),
                                    },
                                  };
                                  final unclaimed = thresholds
                                      .where(
                                        (t) =>
                                            value >= t && !claimed.contains(t),
                                      )
                                      .toList();
                                  if (unclaimed.isEmpty)
                                    return const SizedBox.shrink();
                                  return Column(
                                    children: unclaimed.map((t) {
                                      final r = rewards[t.toString()]!;
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 6,
                                        ),
                                        child: GestureDetector(
                                          onTap: () async {
                                            HapticFeedback.heavyImpact();
                                            await StorageService.claimMilestone(
                                              t,
                                            );
                                            setModalState(() {
                                              claimed.add(t);
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: (r['color'] as Color)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              border: Border.all(
                                                color: (r['color'] as Color)
                                                    .withOpacity(0.25),
                                                width: 0.5,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .local_fire_department_rounded,
                                                  color: const Color(
                                                    0xFFFF6B6B,
                                                  ),
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "$t Gün",
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Icon(
                                                  r['icon'] as IconData,
                                                  color: r['color'] as Color,
                                                  size: 14,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  r['text'] as String,
                                                  style: TextStyle(
                                                    color: r['color'] as Color,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: const Text(
                                                    "Topla",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
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
                    ),
                    // YUKARI UÇAN AURA ANİMASYONLARI
                    ...flyingAuras.map((fa) => _FlyingAuraParticle(
                          key: ValueKey(fa['id']),
                          amount: fa['amount'],
                          color: fa['color'],
                          leftPos: fa['left'],
                        )),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
    // Modal kapandı — dış buton noktalarını güncelle
    if (onRefresh != null) onRefresh!();
  }

  Widget _buildAuraSource(
    IconData icon,
    String title,
    int unclaimedAura,
    VoidCallback onTap, {
    Color color = const Color(0xFF4EE6C5),
    String? imagePath,
    String? emoji,
  }) {
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
            border: Border.all(
              color: hasAura ? color.withOpacity(0.3) : Colors.transparent,
              width: 0.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (emoji != null)
                Text(emoji, style: const TextStyle(fontSize: 18))
              else if (imagePath != null)
                Transform.translate(
                  offset: const Offset(
                    0,
                    1.5,
                  ), // Görselin içindeki boşluktan kaynaklı yukarı kaymayı düzeltmek için
                  child: Transform.scale(
                    scale:
                        1.4, // PNG'nin iç boşluğundan dolayı küçük görünmesini telafi etmek için büyütme
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
                Icon(
                  icon,
                  color: hasAura ? color : Colors.white.withOpacity(0.2),
                  size: 16,
                ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: hasAura
                      ? color.withOpacity(0.8)
                      : Colors.white.withOpacity(0.3),
                  fontSize: 9,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                hasAura ? "+$unclaimedAura" : "0",
                style: TextStyle(
                  color: hasAura ? Colors.white : Colors.white.withOpacity(0.2),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoulStoreCard(
    BuildContext context,
    String countText,
    String price,
    Color color, {
    bool isPopular = false,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
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
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.1),
            width: isSelected ? 1.5 : 0.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            if (isPopular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                margin: const EdgeInsets.only(bottom: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "POPÜLER",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              const SizedBox(height: 13),
            Icon(Icons.diamond_rounded, color: color, size: 14),
            const SizedBox(height: 4),
            Text(
              countText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              price,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 8,
              ),
            ),
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
  final String? notificationText;
  final VoidCallback onTap;

  const _GlassBadge({
    this.icon,
    this.imagePath,
    required this.label,
    required this.color,
    this.hasNotification = false,
    this.notificationText,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                    width: 0.5,
                  ),
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
                            ? Image.asset(
                                imagePath!,
                                width: 36,
                                height: 36,
                                fit: BoxFit.contain,
                              )
                            : (icon != null
                                  ? Icon(icon, color: color, size: 18)
                                  : const SizedBox()),
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
            Positioned(
              top: notificationText != null ? -12 : -2,
              right: notificationText != null ? 6 : 0,
              child: notificationText != null
                  ? Transform.rotate(
                      angle: 0.15,
                      child: Text(
                        notificationText!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          shadows: [
                            Shadow(color: Color(0xFFFFD166), offset: Offset(1, 1)),
                            Shadow(color: Color(0xFFFFB347), offset: Offset(2, 2)),
                            Shadow(color: Color(0xFFFF9800), offset: Offset(3, 3)),
                            Shadow(color: Color(0xFFFF6B6B), offset: Offset(4, 4)),
                            Shadow(color: Color(0x66000000), offset: Offset(4, 8), blurRadius: 12),
                            Shadow(color: Color(0xAAFF6B6B), blurRadius: 20),
                          ],
                        ),
                      ),
                    )
                  : const CosmicBadge(), // Ortak Zümrüt Yeşili rozet!
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
                                    errorBuilder: (_, __, ___) => Icon(
                                      icon,
                                      color: iconColor.withOpacity(0.95),
                                      size: 30,
                                    ),
                                  )
                                : Icon(
                                    icon,
                                    color: iconColor.withOpacity(0.95),
                                    size: icon == Icons.amp_stories_rounded
                                        ? 32
                                        : 30,
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
                vertical: widget.compact ? 12 : 0,
              ),
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
                              Icon(
                                widget.icon,
                                color: widget.iconColor.withValues(alpha: 0.85),
                                size: 16,
                              ),
                              if (widget.hasBadge)
                                const Positioned(
                                  top: -2,
                                  right: 0,
                                  child:
                                      CosmicBadge(), // Nokta formatında cosmic badge
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
                              Icon(
                                widget.icon,
                                color: widget.iconColor.withValues(alpha: 0.85),
                                size: 18,
                              ),
                              if (widget.hasBadge)
                                const Positioned(
                                  top: -2,
                                  right: 0,
                                  child:
                                      CosmicBadge(), // Orijinal noktalardan şaşmıyoruz ama standart
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
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: widget.isPremium
                    ? Colors.white.withOpacity(0.08)
                    : const Color(0xFFD4A574).withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: widget.isPremium
                      ? Colors.white.withOpacity(0.15)
                      : const Color(0xFFD4A574).withOpacity(0.3),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.isPremium
                            ? [const Color(0xFF38BDF8), const Color(0xFF0284C7)]
                            : [
                                const Color(0xFFD4A574),
                                const Color(0xFFB8956A),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: widget.isPremium
                              ? const Color(0xFF0284C7).withOpacity(0.3)
                              : const Color(0xFFD4A574).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        widget.isPremium
                            ? Icons.diamond_rounded
                            : Icons.workspace_premium_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isPremium
                              ? (widget.lang == 'tr'
                                    ? 'Elite Büyücüsün'
                                    : 'You are Elite')
                              : (widget.lang == 'tr'
                                    ? 'Elite\'e Geç'
                                    : 'Go Elite'),
                          style: TextStyle(
                            color: widget.isPremium
                                ? const Color(0xFFE0F2FE)
                                : const Color(0xFFD4A574),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          widget.isPremium
                              ? (widget.lang == 'tr'
                                    ? 'Mistik kapıları incele'
                                    : 'View mystical gates')
                              : (widget.lang == 'tr'
                                    ? 'Farkındalığa giden kapı'
                                    : 'Door to awareness'),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.isPremium) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Aktif',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: widget.isPremium
                        ? Colors.white.withOpacity(0.2)
                        : const Color(0xFFD4A574).withOpacity(0.5),
                    size: 12,
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

class _BentoCosmicBanner extends StatefulWidget {
  final String lang;
  final VoidCallback onTap;

  const _BentoCosmicBanner({required this.lang, required this.onTap});

  @override
  State<_BentoCosmicBanner> createState() => _BentoCosmicBannerState();
}

class _BentoCosmicBannerState extends State<_BentoCosmicBanner> {
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
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(
                  0.08,
                ), // Bright pure translucent glass
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFC084FC), Color(0xFF9333EA)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9333EA).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.insights_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.lang == 'tr'
                              ? 'Kozmik Profilim'
                              : 'My Cosmic Profile',
                          style: const TextStyle(
                            color: Color(0xFFF3E8FF),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.lang == 'tr'
                              ? 'Harita, Saat ve Konum Bilgileri'
                              : 'Chart, Time, and Place Details',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withOpacity(0.25),
                    size: 14,
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

class _BentoInviteBanner extends StatefulWidget {
  final String lang;
  final VoidCallback onTap;

  const _BentoInviteBanner({required this.lang, required this.onTap});

  @override
  State<_BentoInviteBanner> createState() => _BentoInviteBannerState();
}

class _BentoInviteBannerState extends State<_BentoInviteBanner> {
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
                    const Color(0xFFC084FC).withOpacity(0.20),
                    const Color(0xFFE879F9).withOpacity(0.10),
                    const Color(0xFFFF6B6B).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE879F9).withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE879F9).withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE879F9).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.group_add_rounded,
                        color: Color(0xFFE879F9),
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
                          widget.lang == 'tr'
                              ? 'Arkadaşlarını Davet Et'
                              : 'Invite Friends',
                          style: const TextStyle(
                            color: Color(0xFFE879F9),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.lang == 'tr'
                              ? 'Kozmik bağlar kur, birlikte kazan'
                              : 'Build cosmic bonds, earn together',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE879F9).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFE879F9).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.diamond_rounded,
                          color: Color(0xFF60A5FA),
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '+3',
                          style: TextStyle(
                            color: Color(0xFF60A5FA),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                    GlassBackButton(onTap: () => Navigator.pop(context)),
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
      setState(
        () => _crossAxisCount = prefs.getInt('custom_cookie_grid_count') ?? 4,
      );
    }
  }

  Future<void> _savePreference(int val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('custom_cookie_grid_count', val);
  }

  Future<void> _loadOwnedCookies() async {
    final collection = await StorageService.getCookieCollection();
    final owned = collection
        .where((c) => c.firstObtainedDate != null && c.id != 'pizza_party' && c.id != 'cosmic_dust')
        .toList();
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

  String _resolveCookieImagePath(String id) {
    try {
      final all = SeasonConfig.getAllCookies();
      for (final c in all) {
        if (c['id'] == id) return c['imagePath'] as String;
      }
    } catch (_) {}
    return 'assets/images/cookies/$id.webp';
  }

  static const _cookieMeta = <String, Map<String, String>>{
    'spring_wreath': {
      'name': 'Bahar Çelengi',
      'desc': 'Doğanın uyanışını simgeler. Taze başlangıçların habercisi.',
      'rarity': 'Yaygın',
      'quote': '"Her bahar, evren sana ikinci bir şans verir."',
    },
    'lucky_clover': {
      'name': 'Şanslı Yonca',
      'desc': 'Dört yapraklı yonca — her yaprağı bir dilek taşır.',
      'rarity': 'Yaygın',
      'quote': '"Şans, hazırlığın fırsatla buluştuğu andır."',
    },
    'royal_hearts': {
      'name': 'Kraliyet Kalbi',
      'desc': 'Sarayların gizli aşk notalarından ilham alır.',
      'rarity': 'Nadir',
      'quote': '"Gerçek zarafet, kalpten gelir."',
    },
    'evil_eye': {
      'name': 'Nazar Boncuğu',
      'desc': 'Kötü bakışlara karşı kadim bir koruyucu.',
      'rarity': 'Yaygın',
      'quote': '"Seni koruyan görünmez bir kalkan her zaman var."',
    },
    'silver_lotus': {
      'name': 'Gümüş Nilüfer',
      'desc': 'Sessiz zarafetin ve içsel huzurun sembolü.',
      'rarity': 'Yaygın',
      'quote': '"Huzur, içindeki parıltıda saklı."',
    },
    'sakura_bloom': {
      'name': 'Sakura Çiçeği',
      'desc': 'Japon kiraz çiçeklerinin kısa ama büyüleyici dansı.',
      'rarity': 'Nadir',
      'quote': '"Güzellik geçicidir, ama anılar sonsuzdur."',
    },
    'blue_porcelain': {
      'name': 'Hanedan Porseleni',
      'desc': 'Uzak Doğu\'nun kadim ejderha motifleriyle süslenmiş porselen.',
      'rarity': 'Epik',
      'quote': '"Kadim bilgelik, sabırla işlenen detaylarda gizlidir."',
    },
    'pink_blossom': {
      'name': 'Pembe Tomurcuk',
      'desc': 'Baharın ilk açan çiçeği gibi taptaze.',
      'rarity': 'Yaygın',
      'quote': '"Küçük şeyler, büyük mutluluklar getirir."',
    },
    'fortune_cat': {
      'name': 'Şans Kedisi',
      'desc': 'Maneki-neko — patiyle bereket çağırır.',
      'rarity': 'Nadir',
      'quote': '"Bereket kapını çalıyor, açmayı unutma."',
    },
    'wildflower': {
      'name': 'Kır Çiçeği',
      'desc': 'Rüzgârın taşıdığı özgür ve vahşi güzellik.',
      'rarity': 'Yaygın',
      'quote': '"Özgürlük, ruhunun çiçek açmasıdır."',
    },
    'cupid_ribbon': {
      'name': 'Aşk Kurdelesi',
      'desc': 'Cupid\'in okunu saran ipek kurdele.',
      'rarity': 'Nadir',
      'quote': '"Aşk, kelimelerin bıraktığı yerde başlar."',
    },
    'panda_bamboo': {
      'name': 'Panda Ormanı',
      'desc': 'Bambu koruluğundaki huzurlu panda.',
      'rarity': 'Yaygın',
      'quote': '"Huzur, en büyük lükstür."',
    },
    'ramadan_cute': {
      'name': 'Ramazan Neşesi',
      'desc': 'Hilal ve fenerlerle süslü kutsal bir gece.',
      'rarity': 'Nadir',
      'quote': '"Sabır eden, güzel günlere kavuşur."',
    },
    'enchanted_forest': {
      'name': 'Büyülü Orman',
      'desc': 'Perilerin dans ettiği gizemli bir orman.',
      'rarity': 'Epik',
      'quote': '"Büyü, inanmaya cesaret edenler içindir."',
    },
    'golden_arabesque': {
      'name': 'Altın Arabesk',
      'desc': 'İslam sanatının geometrik mükemmelliği.',
      'rarity': 'Epik',
      'quote': '"Sonsuzluk, bir desenin tekrarında gizlidir."',
    },
    'midnight_mosaic': {
      'name': 'Gece Mozaiği',
      'desc': 'Gece yarısı gökyüzünden toplanan parçalar.',
      'rarity': 'Epik',
      'quote': '"Karanlık, yıldızları görmek için vardır."',
    },
    'pearl_lace': {
      'name': 'İnci Dantel',
      'desc': 'Deniz kabuklarından süzülen zarif işçilik.',
      'rarity': 'Nadir',
      'quote': '"En değerli inciler, en derin sularda bulunur."',
    },
    'golden_sakura': {
      'name': 'Altın Sakura',
      'desc': 'Altınla kaplanmış efsanevi kiraz çiçeği.',
      'rarity': 'Efsanevi',
      'quote': '"Efsaneler, sıradanlığı reddedenlerce yazılır."',
    },
    'dragon_phoenix': {
      'name': 'Ejder & Anka',
      'desc': 'Ateş ve yeniden doğuşun kadim dansı.',
      'rarity': 'Efsanevi',
      'quote': '"Küllerin arasından yükselmek, kaderin ta kendisidir."',
    },
    'gold_beasts': {
      'name': 'Altın Canavarlar',
      'desc': 'Mitolojinin en güçlü yaratıkları altınla buluşur.',
      'rarity': 'Efsanevi',
      'quote': '"Güç sahibi ol, ama merhametli kal."',
    },
  };

  static Color _rarityColor(String rarity) {
    switch (rarity) {
      case 'Efsanevi':
        return const Color(0xFFFFD700);
      case 'Epik':
        return const Color(0xFFC084FC);
      case 'Nadir':
        return const Color(0xFF60A5FA);
      default:
        return const Color(0xFF4EE6C5);
    }
  }

  void _showCookieActionMenu(CookieCard cookie, BuildContext context) {
    HapticFeedback.selectionClick();
    final meta =
        _cookieMeta[cookie.id] ??
        {
          'name': 'Gizemli Kurabiye',
          'desc': 'Bu kurabiye henüz keşfedilmemiş...',
          'rarity': 'Yaygın',
        };
    final rarityColor = _rarityColor(meta['rarity']!);
    final firstDate = cookie.firstObtainedDate;
    final dateStr = firstDate != null
        ? "${firstDate.day.toString().padLeft(2, '0')}.${firstDate.month.toString().padLeft(2, '0')}.${firstDate.year}"
        : "—";

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'CookiePopup',
      barrierColor: Colors.black.withOpacity(0.65), // Yumuşak karanlık arkaplan
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // Arkaplan Pırıltısı (Arkada devasa bir aydınlanma)
                Positioned(
                  top: 20,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: rarityColor.withOpacity(0.35),
                          blurRadius: 100,
                          spreadRadius: 30,
                        ),
                      ],
                    ),
                  ),
                ),

                // Ana Cam Kart
                Container(
                  margin: const EdgeInsets.only(top: 80, left: 32, right: 32),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(
                          28,
                          70,
                          28,
                          36,
                        ), // Üst padding kurabiyeye yer açar
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(
                            0.12,
                          ), // Çok hafif açık tonlu cam (Frosty effect)
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 40,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              meta['name']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Date & Adet Pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    color: rarityColor,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Keşif: $dateStr",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (cookie.countObtained > 1) ...[
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      width: 1,
                                      height: 12,
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                    Icon(
                                      Icons.auto_awesome_motion_rounded,
                                      color: rarityColor,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "x${cookie.countObtained}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),
                            // Açıklama
                            Text(
                              meta['desc']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 15,
                                height: 1.6,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Panele Taşan (Overflow) Animasyonlu Merkez Kurabiye
                Positioned(
                  top: 0,
                  child: _SensorParallaxWidget(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.2, end: 1.0),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Transform.translate(
                            offset: Offset(
                              0,
                              15 * (1 - scale),
                            ), // Pop up as it grows
                            child: child,
                          ),
                        );
                      },
                      child: SizedBox(
                        width: 140,
                        height: 140,
                        child: Image.asset(
                          _resolveCookieImagePath(cookie.id),
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.bakery_dining_rounded,
                            color: rarityColor,
                            size: 80,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10 * animation.value,
            sigmaY: 10 * animation.value,
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(curve),
            child: FadeTransition(opacity: animation, child: child),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 90,
        child: Center(child: CircularProgressIndicator(color: Colors.white24)),
      );
    }
    if (_ownedCookies.isEmpty) {
      return Container(
        height: 90,
        alignment: Alignment.center,
        child: Text(
          "Henüz koleksiyonunda eşsiz kurabiye yok.\nAna sayfadan kurabiye kırarak siftah yap!",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
            height: 1.4,
          ),
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
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _crossAxisCount = 4;
                    });
                    _savePreference(4);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.grid_view_rounded,
                      color: _crossAxisCount == 4
                          ? Colors.white
                          : Colors.white24,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _crossAxisCount = 6;
                    });
                    _savePreference(6);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.apps_rounded,
                      color: _crossAxisCount == 6
                          ? Colors.white
                          : Colors.white24,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 0.5,
                ),
              ),
              child: Text(
                "Koleksiyon: ${_ownedCookies.length}",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
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
                stops: [
                  0.0,
                  0.08,
                  1.0,
                ], // Sadece tepede (top) %8'lik yumuşak silikleşme
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
                              BoxShadow(
                                color: Colors.white.withOpacity(0.02),
                                blurRadius: 12,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Kurabiye Görseli
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Image.asset(
                            _resolveCookieImagePath(cookie.id),
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.bakery_dining_rounded,
                              color: Color(0xFFFFD166),
                            ),
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
                                BoxShadow(
                                  color: const Color(
                                    0xFFFFB347,
                                  ).withOpacity(0.7),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
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
  final bool isConnectedLeft;
  final bool isConnectedRight;
  final bool isWeekend;
  final String dateKey;
  final VoidCallback? onClaimed;

  const _ClaimableFireCell({
    required this.day,
    required this.isToday,
    required this.isFuture,
    required this.isAppOpenDay,
    required this.isClaimed,
    this.isConnectedLeft = false,
    this.isConnectedRight = false,
    this.isWeekend = false,
    required this.dateKey,
    this.onClaimed,
  });

  @override
  State<_ClaimableFireCell> createState() => _ClaimableFireCellState();
}

class _ClaimableFireCellState extends State<_ClaimableFireCell>
    with TickerProviderStateMixin {
  late AnimationController _explosionController;
  late AnimationController _flyController;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;
  late Animation<double> _flyUpAnim;
  late Animation<double> _flyFadeAnim;
  late AnimationController _breatheController;
  late Animation<double> _breatheAnim;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _justClaimed = false;

  @override
  void initState() {
    super.initState();
    _explosionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _breatheAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.2,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 50,
      ),
    ]).animate(_breatheController);

    final bool canClaimInit =
        widget.isAppOpenDay &&
        !widget.isClaimed &&
        !widget.isFuture &&
        !_justClaimed;
    if (canClaimInit) {
      _breatheController.repeat();
    }

    // Aniden 2.5 katına fırlayıp geri oturma
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.8,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.8,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
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
      CurvedAnimation(
        parent: _flyController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _explosionController.dispose();
    _flyController.dispose();
    _breatheController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _ClaimableFireCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool canClaim =
        widget.isAppOpenDay &&
        !widget.isClaimed &&
        !widget.isFuture &&
        !_justClaimed;
    if (canClaim) {
      if (!_breatheController.isAnimating) _breatheController.repeat();
    } else {
      if (_breatheController.isAnimating) {
        _breatheController.stop();
        _breatheController.reset();
      }
    }
  }

  Future<void> _handleTap() async {
    if (!widget.isAppOpenDay ||
        widget.isClaimed ||
        widget.isFuture ||
        _justClaimed)
      return;

    // Tok bir titreşim ve güçlü etki
    HapticFeedback.heavyImpact();

    // Yeni indirdiğimiz Level Up sesi (Versiyon 01)
    try {
      await _audioPlayer.play(
        AssetSource('sounds/level_up_bonus_01.mp3'),
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {}

    final success = await StorageService.claimDailyAura(widget.dateKey);
    if (success && mounted) {
      setState(() {
        _justClaimed = true;
        _breatheController.stop();
        _breatheController.reset();
      });

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
        animation: Listenable.merge([
          _explosionController,
          _flyController,
          _breatheController,
        ]),
        builder: (context, child) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Bağlantı çubuğu (Seriyi birleştirmek için arkada kalacak çizgi)
              if (widget.isConnectedLeft || widget.isConnectedRight)
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: widget.isConnectedLeft
                      ? -3
                      : 19.5, // 19.5 radius merkeze denk getirir yaklaşık olarak, dengelemek için
                  right: widget.isConnectedRight ? -3 : 19.5,
                  child: Center(
                    child: Container(
                      height: 1.5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.35),
                        borderRadius: BorderRadius.horizontal(
                          left: widget.isConnectedLeft
                              ? Radius.zero
                              : const Radius.circular(1),
                          right: widget.isConnectedRight
                              ? Radius.zero
                              : const Radius.circular(1),
                        ),
                      ),
                    ),
                  ),
                ),
              // Ana hücre (Pop efekti ile)
              Transform.scale(
                scale: _explosionController.isAnimating
                    ? _scaleAnim.value
                    : (canClaim ? _breatheAnim.value : 1.0),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isToday
                        ? const Color(0xFFFF6B6B).withOpacity(0.15)
                        : (widget.isAppOpenDay && !claimed
                              ? const Color(0xFFFF6B6B).withOpacity(0.08)
                              : Colors.transparent),
                    border: widget.isToday
                        ? Border.all(
                            color: const Color(0xFFFF6B6B).withOpacity(0.5),
                            width: 1,
                          )
                        : null,
                    boxShadow: [
                      if (_explosionController.isAnimating)
                        BoxShadow(
                          color: const Color(
                            0xFFFFC107,
                          ).withOpacity(_glowAnim.value * 0.6),
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
                                ? (_explosionController.isAnimating
                                      ? const Color(0xFFFFC107)
                                      : Colors.white.withOpacity(0.15))
                                : const Color(0xFFFF6B6B),
                            size: 18,
                          )
                        : Text(
                            "${widget.day}",
                            style: TextStyle(
                              color: widget.isFuture
                                  ? Colors.white.withOpacity(0.2)
                                  : (widget.isToday
                                        ? const Color(0xFFFF6B6B)
                                        : Colors.white.withOpacity(0.65)),
                              fontSize: 14,
                              fontWeight: widget.isToday
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ),
              // Uçan "+1 Aura" yazısı
              if (_justClaimed && _flyController.isAnimating)
                Positioned(
                  left: -20,
                  right: -20,
                  top: _flyUpAnim.value - 10,
                  child: Opacity(
                    opacity: _flyFadeAnim.value,
                    child: Center(
                      child: Text(
                        widget.isWeekend ? "+2" : "+1",
                        style: const TextStyle(
                          color: Color(0xFFFFC107),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          shadows: [
                            Shadow(color: Color(0x66000000), offset: Offset(1, 2), blurRadius: 4),
                          ],
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

class _SettingsListGroup extends StatelessWidget {
  final List<Widget> children;

  const _SettingsListGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final List<Widget> spacedChildren = [];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(const SizedBox(height: 12));
      }
    }

    return Column(children: spacedChildren);
  }
}

class _SettingsListTile extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsListTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.isDestructive = false,
  });

  @override
  State<_SettingsListTile> createState() => _SettingsListTileState();
}

class _SettingsListTileState extends State<_SettingsListTile> {
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
        duration: const Duration(milliseconds: 150),
        scale: _pressed ? 0.90 : 1.0,
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 100),
          opacity: _pressed ? 0.6 : 1.0,
          child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: widget.isDestructive
                    ? const Color(0xFFF87171).withOpacity(0.12)
                    : const Color(0xFF1E1E1E).withOpacity(0.55),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.isDestructive
                      ? const Color(0xFFF87171).withOpacity(0.3)
                      : Colors.white.withOpacity(0.12),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: Icon(
                        widget.icon,
                        color: widget.iconColor,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.isDestructive
                          ? const Color(0xFFFF4D4D)
                          : Colors.white.withOpacity(0.95),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (widget.subtitle != null &&
                      widget.subtitle!.isNotEmpty) ...[
                    Expanded(
                      child: Text(
                        widget.subtitle!,
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: widget.isDestructive
                              ? const Color(0xFFFF4D4D).withOpacity(0.6)
                              : Colors.white.withOpacity(0.45),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ] else
                    const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: widget.isDestructive
                        ? const Color(0xFFFF4D4D).withOpacity(0.4)
                        : Colors.white.withOpacity(0.25),
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}

class _SensorParallaxWidget extends StatefulWidget {
  final Widget child;
  const _SensorParallaxWidget({Key? key, required this.child})
    : super(key: key);

  @override
  State<_SensorParallaxWidget> createState() => _SensorParallaxWidgetState();
}

class _SensorParallaxWidgetState extends State<_SensorParallaxWidget> {
  double _pitch = 0.0;
  double _roll = 0.0;
  StreamSubscription<AccelerometerEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    try {
      _subscription = accelerometerEventStream().listen((
        AccelerometerEvent event,
      ) {
        if (mounted) {
          setState(() {
            _pitch = (event.y * 0.05).clamp(-0.25, 0.25);
            _roll = (event.x * -0.05).clamp(-0.25, 0.25);
          });
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100), // Hızlı ama pürüzsüz tepki
      transformAlignment: FractionalOffset.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // perspective
        ..rotateX(_pitch)
        ..rotateY(_roll),
      child: widget.child,
    );
  }
}

// ══════════════════════════════════════════════
// 🍩 DUYGU DAĞILIMI DONUT GRAFİĞİ
// ══════════════════════════════════════════════

class _EmotionSlice {
  final String label;
  final double percentage;
  final Color color;
  final String emoji;
  final int count;

  const _EmotionSlice({
    required this.label,
    required this.percentage,
    required this.color,
    required this.emoji,
    required this.count,
  });
}

class _EmotionDonutPainter extends CustomPainter {
  final List<_EmotionSlice> slices;
  final double animationValue;

  _EmotionDonutPainter({required this.slices, this.animationValue = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 12.0;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    // Arka plan halkası
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    // Dilimleri çiz
    const gapAngle = 0.06; // Dilimler arası boşluk (radyan)
    const startAngle = -math.pi / 2; // 12 saat yönünden başla
    final totalGap = gapAngle * slices.length;
    final availableAngle = 2 * math.pi - totalGap;

    double currentAngle = startAngle;

    for (final slice in slices) {
      final targetSweepAngle = (slice.percentage / 100) * availableAngle;
      final sweepAngle = targetSweepAngle * animationValue;

      // Glow efekti
      final glowPaint = Paint()
        ..color = slice.color.withOpacity(0.35 * animationValue)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawArc(rect, currentAngle, sweepAngle, false, glowPaint);

      // Ana dilim
      final slicePaint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, currentAngle, sweepAngle, false, slicePaint);

      currentAngle += targetSweepAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _EmotionDonutPainter oldDelegate) {
    return oldDelegate.slices.length != slices.length ||
        oldDelegate.animationValue != animationValue;
  }
}

class _FlyingAuraParticle extends StatefulWidget {
  final int amount;
  final Color color;
  final double leftPos;

  const _FlyingAuraParticle({
    Key? key,
    required this.amount,
    required this.color,
    required this.leftPos,
  }) : super(key: key);

  @override
  State<_FlyingAuraParticle> createState() => _FlyingAuraParticleState();
}

class _FlyingAuraParticleState extends State<_FlyingAuraParticle> {
  double _opacity = 1.0;
  double _dy = 240.0; // Alt kısımdaki butonların ortalama yüksekliği

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _dy = 60.0; // Üstteki aura sayısının olduğu hiza
          _opacity = 0.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      top: _dy,
      left: widget.leftPos,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 600),
        opacity: _opacity,
        child: Text(
          "+${widget.amount}",
          style: TextStyle(
            color: widget.color,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                color: widget.color.withOpacity(0.6),
                blurRadius: 12,
              )
            ],
          ),
        ),
      ),
    );
  }
}
