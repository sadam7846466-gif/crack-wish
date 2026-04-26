import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class GuidanceItem {
  final String titleTr;
  final String titleEn;
  final String descTr;
  final String descEn;
  final IconData icon;

  const GuidanceItem({
    required this.titleTr,
    required this.titleEn,
    required this.descTr,
    required this.descEn,
    required this.icon,
  });
}

class GuidanceBookletButton extends StatefulWidget {
  final List<GuidanceItem> items;
  final String dialogTitleTr;
  final String dialogTitleEn;
  final int showCount;

  const GuidanceBookletButton({
    super.key,
    required this.items,
    required this.dialogTitleTr,
    required this.dialogTitleEn,
    this.showCount = 3,
  });

  @override
  State<GuidanceBookletButton> createState() => _GuidanceBookletButtonState();
}

class _GuidanceBookletButtonState extends State<GuidanceBookletButton> {
  bool _pressed = false;

  bool get _isTr => Localizations.localeOf(context).languageCode == 'tr';

  void _handleTap() {
    setState(() => _pressed = true);
    HapticFeedback.lightImpact();
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      setState(() => _pressed = false);
      Future.delayed(const Duration(milliseconds: 60), () {
        if (!mounted) return;
        _showDialog();
      });
    });
  }

  void _showDialog() {
    final isTr = _isTr;
    final selected = widget.items;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'GuidanceBooklet',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: Colors.black.withOpacity(0.4),
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.7,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.18),
                            width: 0.6,
                          ),
                        ),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.menu_book_rounded,
                                color: Colors.white.withOpacity(0.7),
                                size: 24,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                isTr
                                    ? widget.dialogTitleTr
                                    : widget.dialogTitleEn,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.cormorantGaramond(
                                  color: Colors.white.withOpacity(0.95),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 0.5,
                                width: 60,
                                color: Colors.white.withOpacity(0.2),
                              ),
                              const SizedBox(height: 16),
                              ...selected.map((item) => _buildItem(
                                    isTr ? item.titleTr : item.titleEn,
                                    isTr ? item.descTr : item.descEn,
                                    item.icon,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildItem(String title, String desc, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 0.5,
              ),
            ),
            child: Icon(icon, color: Colors.white.withOpacity(0.7), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: _handleTap,
      child: AnimatedScale(
        scale: _pressed ? 0.82 : 1.0,
        duration: Duration(milliseconds: _pressed ? 80 : 180),
        curve: _pressed ? Curves.easeInCubic : Curves.easeOutBack,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.6 : 1.0,
          duration: Duration(milliseconds: _pressed ? 80 : 180),
          child: ClipOval(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(_pressed ? 0.18 : 0.10),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.18),
                    width: 0.6,
                  ),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white.withOpacity(0.85),
                  size: 17,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
