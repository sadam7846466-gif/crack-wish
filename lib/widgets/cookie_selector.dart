import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';

class CookieSelector extends StatefulWidget {
  final Function(String)? onCookieSelected;
  final int? initialSelectedIndex;

  const CookieSelector({
    super.key,
    this.onCookieSelected,
    this.initialSelectedIndex,
  });

  @override
  State<CookieSelector> createState() => _CookieSelectorState();
}

class _CookieSelectorState extends State<CookieSelector> {
  late int _selectedIndex;
  final AudioPlayer _audioPlayer = AudioPlayer();

  static final List<Map<String, dynamic>> _cookieTypes = [
    {'icon': '🏯', 'key': 'cookieClassic', 'isSpecial': true},
    {'icon': '🎃', 'key': 'cookieHalloween', 'isSpecial': false},
    {'icon': '🥠', 'key': 'cookiePlain', 'isSpecial': false},
    {'icon': '🍪', 'key': 'cookieChocolate', 'isSpecial': false},
    {'icon': '⭐', 'key': 'cookieStar', 'isSpecial': false},
    {'icon': '🔮', 'key': 'cookieMystic', 'isSpecial': false},
    {'icon': '🐉', 'key': 'cookieDragon', 'isSpecial': false},
    {'icon': '🦋', 'key': 'cookieButterfly', 'isSpecial': false},
    {'icon': '🎭', 'key': 'cookieTheater', 'isSpecial': false},
    {'icon': '🍀', 'key': 'cookieLucky', 'isSpecial': false},
    {'icon': '💎', 'key': 'cookieDiamond', 'isSpecial': false},
    {'icon': '🔥', 'key': 'cookieFire', 'isSpecial': false},
    {'icon': '⚡', 'key': 'cookieLightning', 'isSpecial': false},
    {'icon': '🌈', 'key': 'cookieRainbow', 'isSpecial': false},
    {'icon': '👁️', 'key': 'cookieEye', 'isSpecial': false},
    {'icon': '🎪', 'key': 'cookieCircus', 'isSpecial': false},
    {'icon': '🦄', 'key': 'cookieUnicorn', 'isSpecial': false},
    {'icon': '🐱', 'key': 'cookieCat', 'isSpecial': false},
    {'icon': '🌺', 'key': 'cookieFlower', 'isSpecial': false},
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelectedIndex ?? 0;
  }

  @override
  void didUpdateWidget(CookieSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSelectedIndex != null &&
        widget.initialSelectedIndex != oldWidget.initialSelectedIndex &&
        widget.initialSelectedIndex! != _selectedIndex) {
      _selectedIndex = widget.initialSelectedIndex!;
    }
  }

  Future<void> _playSelectSound() async {
    return;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ClipRect(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 0),
        child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.transparent,
                Colors.white,
                Colors.white,
                Colors.transparent,
              ],
              stops: [0.0, 0.18, 0.82, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              key: const ValueKey('cookie_selector_row'),
              children: [
                const SizedBox(width: 6),
                ...List.generate(_cookieTypes.length, (index) {
                  final currentSelectedIndex =
                      widget.initialSelectedIndex ?? _selectedIndex;
                  final isSelected = currentSelectedIndex == index;

                  return Padding(
                    key: ValueKey('cookie_item_$index'),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: _CookieSelectorItem(
                      key: ValueKey(
                        'cookie_selector_item_${index}_$isSelected',
                      ),
                      icon: _cookieTypes[index]['icon'] as String,
                      label: _cookieLabel(l10n, _cookieTypes[index]['key'] as String),
                      isSelected: isSelected,
                      isSpecial: _cookieTypes[index]['isSpecial'] as bool,
                      onTap: () {
                        setState(() => _selectedIndex = index);
                        _playSelectSound();
                        widget.onCookieSelected?.call(
                          _cookieTypes[index]['icon'] as String,
                        );
                      },
                    ),
                  );
                }),
                const SizedBox(width: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _cookieLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'cookieClassic':
        return l10n.cookieClassic;
      case 'cookieHalloween':
        return l10n.cookieHalloween;
      case 'cookiePlain':
        return l10n.cookiePlain;
      case 'cookieChocolate':
        return l10n.cookieChocolate;
      case 'cookieStar':
        return l10n.cookieStar;
      case 'cookieMystic':
        return l10n.cookieMystic;
      case 'cookieDragon':
        return l10n.cookieDragon;
      case 'cookieButterfly':
        return l10n.cookieButterfly;
      case 'cookieTheater':
        return l10n.cookieTheater;
      case 'cookieLucky':
        return l10n.cookieLucky;
      case 'cookieDiamond':
        return l10n.cookieDiamond;
      case 'cookieFire':
        return l10n.cookieFire;
      case 'cookieLightning':
        return l10n.cookieLightning;
      case 'cookieRainbow':
        return l10n.cookieRainbow;
      case 'cookieEye':
        return l10n.cookieEye;
      case 'cookieCircus':
        return l10n.cookieCircus;
      case 'cookieUnicorn':
        return l10n.cookieUnicorn;
      case 'cookieCat':
        return l10n.cookieCat;
      case 'cookieFlower':
        return l10n.cookieFlower;
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

class _CookieSelectorItem extends StatelessWidget {
  final String icon;
  final String label;
  final bool isSelected;
  final bool isSpecial;
  final VoidCallback onTap;

  const _CookieSelectorItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isSpecial,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.12 : 1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(isSelected ? 0.25 : 0.15),
                Colors.white.withOpacity(isSelected ? 0.10 : 0.05),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(isSelected ? 0.4 : 0.2),
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 27)),
          ),
        ),
      ),
    );
  }
}
