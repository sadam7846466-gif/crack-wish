import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/glass_back_button.dart';
import 'package:flutter/cupertino.dart';
import '../constants/colors.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../services/push_notification_service.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {

  bool _announcements = true;
  bool _voices = false;
  bool _newCookieAlarm = true;
  bool _friendsAlarm = true;
  bool _dailyReminders = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await StorageService.getNotificationSettings();
    if (!mounted) return;
    setState(() {
      _announcements = settings['announcements'] ?? true;
      _voices = settings['voices'] ?? false;
      _newCookieAlarm = settings['newCookieAlarm'] ?? true;
      _friendsAlarm = settings['friendsAlarm'] ?? true;
      _dailyReminders = settings['dailyReminders'] ?? false;
    });
  }

  void _updateSetting(String key, bool value) {
    StorageService.setNotificationSetting(key, value);
    if (key == 'dailyReminders') {
      PushNotificationService().updateDailyReminders(value);
    } else if (key != 'voices') {
      PushNotificationService().updateTopicSubscription(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppThemeController.current;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(gradient: palette.bgGradient),
        child: Stack(
          children: [
            // — Abstract color blobs (same style as profile)
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
            Positioned(
              top: 200,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFFD166).withOpacity(0.35),
                      const Color(0xFFFFD166).withOpacity(0.05),
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
                  // — Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      children: [
                        GlassBackButton(),
                        const SizedBox(width: 10),
                        const Text(
                          'Bildirimler',
                          style: TextStyle(
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
                      'Hangi bildirimleri almak istediğini seç',
                      style: TextStyle(
                        color: AppColors.textWhite.withOpacity(0.5),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // — Toggle List
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _NotifToggle(
                            icon: Icons.campaign_rounded,
                            title: 'Duyurular',
                            subtitle: 'Yeni özellikler ve güncellemeler',
                            value: _announcements,
                            onChanged: (v) {
                              setState(() => _announcements = v);
                              _updateSetting('announcements', v);
                            },
                          ),
                          const SizedBox(height: 18),
                          _NotifToggle(
                            icon: Icons.record_voice_over_rounded,
                            title: 'Sesler',
                            subtitle: 'Sesli bildirim uyarıları',
                            value: _voices,
                            onChanged: (v) {
                              setState(() => _voices = v);
                              _updateSetting('voices', v);
                            },
                          ),
                          const SizedBox(height: 18),
                          _NotifToggle(
                            iconAsset: 'assets/icons/splash_cookie.png',
                            title: 'Yeni Kurabiye Alarmı',
                            subtitle: 'Yeni fortune cookie geldiğinde',
                            value: _newCookieAlarm,
                            onChanged: (v) {
                              setState(() => _newCookieAlarm = v);
                              _updateSetting('newCookieAlarm', v);
                            },
                          ),
                          const SizedBox(height: 18),
                          _NotifToggle(
                            icon: Icons.people_rounded,
                            title: 'Arkadaş Alarmı',
                            subtitle: 'Baykuş ağından yeni bağlantılar',
                            value: _friendsAlarm,
                            onChanged: (v) {
                              setState(() => _friendsAlarm = v);
                              _updateSetting('friendsAlarm', v);
                            },
                          ),
                          const SizedBox(height: 18),
                          _NotifToggle(
                            icon: Icons.access_alarm_rounded,
                            title: 'Günlük Hatırlatıcılar',
                            subtitle: 'Günlük kurabiyeni almayı unutma',
                            value: _dailyReminders,
                            onChanged: (v) {
                              setState(() => _dailyReminders = v);
                              _updateSetting('dailyReminders', v);
                            },
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

class _NotifToggle extends StatelessWidget {
  final IconData? icon;
  final String? iconAsset;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotifToggle({
    this.icon,
    this.iconAsset,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFFEAD8D8); // Very light, frosted glass dusty rose

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: value
            ? Colors.white.withOpacity(0.06)
            : Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: value
              ? Colors.white.withOpacity(0.12)
              : Colors.white.withOpacity(0.04),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(value ? 0.08 : 0.03),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: iconAsset != null
                  ? Image.asset(
                      iconAsset!,
                      width: 22,
                      height: 22,
                      color: value ? activeColor : Colors.white.withOpacity(0.4),
                    )
                  : Icon(
                      icon,
                      color: value ? activeColor : Colors.white.withOpacity(0.4),
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
                    color: value
                        ? AppColors.textWhite.withOpacity(0.95)
                        : AppColors.textWhite.withOpacity(0.5),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textWhite.withOpacity(0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: activeColor.withOpacity(0.6),
            thumbColor: Colors.white,
            trackColor: Colors.white.withOpacity(0.05),
          ),
        ],
      ),
    );
  }
}
