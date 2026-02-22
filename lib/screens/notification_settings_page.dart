import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../constants/colors.dart';
import '../theme/app_theme.dart';

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
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
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
                    padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          color: AppColors.textWhite,
                          iconSize: 20,
                        ),
                        const SizedBox(width: 4),
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
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _NotifToggle(
                            icon: Icons.campaign_rounded,
                            iconBgColor: const Color(0xFF5A8BFF),
                            title: 'Duyurular',
                            subtitle: 'Yeni özellikler ve güncellemeler',
                            value: _announcements,
                            onChanged: (v) =>
                                setState(() => _announcements = v),
                          ),
                          const SizedBox(height: 12),
                          _NotifToggle(
                            icon: Icons.record_voice_over_rounded,
                            iconBgColor: const Color(0xFFC084FC),
                            title: 'Sesler',
                            subtitle: 'Sesli bildirim uyarıları',
                            value: _voices,
                            onChanged: (v) => setState(() => _voices = v),
                          ),
                          const SizedBox(height: 12),
                          _NotifToggle(
                            icon: Icons.cookie_rounded,
                            iconBgColor: const Color(0xFFFFD166),
                            title: 'Yeni Kurabiye Alarmı',
                            subtitle: 'Yeni fortune cookie geldiğinde',
                            value: _newCookieAlarm,
                            onChanged: (v) =>
                                setState(() => _newCookieAlarm = v),
                          ),
                          const SizedBox(height: 12),
                          _NotifToggle(
                            icon: Icons.people_rounded,
                            iconBgColor: const Color(0xFF2DD4BF),
                            title: 'Arkadaş Alarmı',
                            subtitle: 'Baykuş ağından yeni bağlantılar',
                            value: _friendsAlarm,
                            onChanged: (v) =>
                                setState(() => _friendsAlarm = v),
                          ),
                          const SizedBox(height: 12),
                          _NotifToggle(
                            icon: Icons.access_alarm_rounded,
                            iconBgColor: const Color(0xFFFF9A5C),
                            title: 'Günlük Hatırlatıcılar',
                            subtitle: 'Günlük kurabiyeni almayı unutma',
                            value: _dailyReminders,
                            onChanged: (v) =>
                                setState(() => _dailyReminders = v),
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
  final IconData icon;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotifToggle({
    required this.icon,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: value
            ? Colors.white.withOpacity(0.08)
            : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: value
              ? Colors.white.withOpacity(0.12)
              : Colors.white.withOpacity(0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor.withOpacity(value ? 0.2 : 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Icon(
                icon,
                color: value ? iconBgColor : iconBgColor.withOpacity(0.4),
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
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textWhite.withOpacity(0.35),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: iconBgColor.withOpacity(0.8),
            thumbColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
