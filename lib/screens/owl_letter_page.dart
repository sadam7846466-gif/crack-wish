import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/mock_owl_service.dart';
import '../models/owl_models.dart';
import '../models/cookie_card.dart';
import '../services/storage_service.dart';

/// Baykuş butonundan açılan buzlu cam panel (glassmorphism)
class OwlLetterPage extends StatefulWidget {
  final Rect buttonRect;
  const OwlLetterPage({super.key, required this.buttonRect});

  @override
  State<OwlLetterPage> createState() => _OwlLetterPageState();
}

class _OwlLetterPageState extends State<OwlLetterPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  bool _showingLetter = false;
  int _selectedTab = 0; // 0=Arkadaşlarım, 1=Gelen Mektup
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  final _service = MockOwlService();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
    _service.loadMockData();
    _service.addListener(_onServiceUpdate);
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _searchCtrl.dispose();
    _service.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _close() {
    _ctrl.reverse().then((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final br = widget.buttonRect;

    const panelW = 340.0;
    final panelH = (screen.height * 0.55).clamp(300.0, 460.0);
    final centerX = (screen.width - panelW) / 2;
    final centerY = (screen.height - panelH) / 2;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _anim,
          builder: (context, _) {
            final t = _anim.value;

            final left = lerpDouble(br.left, centerX, t)!;
            final top = lerpDouble(br.top, centerY, t)!;
            final width = lerpDouble(br.width, panelW, t)!;
            final height = lerpDouble(br.height, panelH, t)!;
            final radius = lerpDouble(14, 22, t)!;

            return Stack(
              children: [
                // Arka plan karartma (hafif)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _close,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 12 * t,
                        sigmaY: 12 * t,
                      ),
                      child: Container(
                        color: Colors.black.withOpacity(0.25 * t),
                      ),
                    ),
                  ),
                ),
                // Glassmorphism panel
                Positioned(
                  left: left,
                  top: top,
                  width: width,
                  height: height,
                  child: IgnorePointer(
                    ignoring: _showingLetter,
                    child: AnimatedOpacity(
                      opacity: _showingLetter ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: ClipRRect(
                    borderRadius: BorderRadius.circular(radius),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 24 * t,
                        sigmaY: 24 * t,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(radius),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.08 * t),
                              Colors.white.withOpacity(0.03 * t),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.18 * t),
                            width: 1,
                          ),
                        ),
                        child: ClipRect(
                          child: Opacity(
                            opacity: t.clamp(0.0, 1.0),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              child: Column(
                                children: [
                                  // Baykuş
                                  Image.asset('assets/images/owl.webp', width: 48, height: 48),
                                  const SizedBox(height: 10),
                                  // Arkadaşlarım ve Gelen Mektup yan yana
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _menuItem(
                                          icon: Icons.people_rounded,
                                          label: 'Arkadaşlarım',
                                          isSelected: _selectedTab == 0,
                                          onTap: () => setState(() => _selectedTab = 0),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _menuItem(
                                          icon: Icons.mail_rounded,
                                          label: 'Gelen Mektup',
                                          isSelected: _selectedTab == 1,
                                          onTap: () => setState(() => _selectedTab = 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  // Arama alanı (sadece Arkadaşlarım sekmesinde)
                                  if (_selectedTab == 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white.withOpacity(0.08),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.1),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.search_rounded,
                                            color: Colors.white.withOpacity(0.4),
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: TextField(
                                              controller: _searchCtrl,
                                              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.9),
                                                fontSize: 12,
                                              ),
                                              decoration: InputDecoration(
                                                hintText: 'Arkadaş ara...',
                                                hintStyle: TextStyle(
                                                  color: Colors.white.withOpacity(0.35),
                                                  fontSize: 12,
                                                ),
                                                border: InputBorder.none,
                                                isDense: true,
                                                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                              ),
                                            ),
                                          ),
                                          if (_searchQuery.isNotEmpty)
                                            GestureDetector(
                                              onTap: () {
                                                _searchCtrl.clear();
                                                setState(() => _searchQuery = '');
                                              },
                                              child: Icon(
                                                Icons.close_rounded,
                                                color: Colors.white.withOpacity(0.4),
                                                size: 14,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  if (_selectedTab == 0)
                                    const SizedBox(height: 10),
                                  // İçerik
                                  Expanded(
                                    child: _selectedTab == 0
                                        ? _buildContactsList(br)
                                        : _buildInbox(),
                                  ),
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
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isSelected
              ? Colors.white.withOpacity(0.18)
              : Colors.white.withOpacity(0.06),
          border: Border.all(
            color: isSelected
                ? Colors.white.withOpacity(0.25)
                : Colors.white.withOpacity(0.08),
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white.withOpacity(isSelected ? 1.0 : 0.6), size: 16),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(isSelected ? 1.0 : 0.7),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsList(Rect br) {
    final friends = _service.searchFriends(_searchQuery);
    final requests = _service.incomingRequests;

    if (friends.isEmpty && requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _searchQuery.isEmpty ? 'Henüz arkadaşın yok' : 'Sonuç bulunamadı',
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
            ),
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 8),
              _addFriendButton(),
            ],
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Gelen istekler
        if (requests.isNotEmpty && _searchQuery.isEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              'Arkadaşlık İstekleri',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...requests.map((req) => _buildRequestItem(req)),
          const SizedBox(height: 8),
          Divider(color: Colors.white.withOpacity(0.1), height: 1),
          const SizedBox(height: 8),
        ],
        // Arkadaş listesi
        ...friends.map((f) => _ContactItem(
              name: f.user.name,
              emoji: f.user.emoji,
              isAppUser: true,
              owlButtonRect: br,
              friend: f,
            )),
        // Arkadaş ekle butonu
        if (_searchQuery.isEmpty) ...[
          const SizedBox(height: 8),
          _addFriendButton(),
        ],
      ],
    );
  }

  Widget _buildRequestItem(FriendRequest req) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(req.from.emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              req.from.name,
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              _service.acceptRequest(req.id);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: const Color(0xFF4CAF50).withOpacity(0.3),
              ),
              child: Text('Kabul', style: TextStyle(color: Colors.green[200], fontSize: 9, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _service.rejectRequest(req.id);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.white.withOpacity(0.06),
              ),
              child: Text('Red', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addFriendButton() {
    return GestureDetector(
      onTap: () => _showAddFriendDialog(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.12), width: 0.5),
          color: Colors.white.withOpacity(0.04),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add_rounded, color: Colors.white.withOpacity(0.5), size: 14),
            const SizedBox(width: 6),
            Text(
              'Arkadaş Ekle',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFriendDialog() {
    final codeCtrl = TextEditingController();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, a1, a2, child) {
        return Transform.scale(
          scale: 0.9 + 0.1 * a1.value,
          child: Opacity(
            opacity: a1.value,
            child: Dialog(
              backgroundColor: const Color(0xFF2E1420),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/owl.webp', width: 32, height: 32),
                    const SizedBox(height: 10),
                    Text(
                      'Senin Baykuş Kodun',
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: '#${_service.currentUser.owlCode}'));
                        HapticFeedback.lightImpact();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white.withOpacity(0.08),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '#${_service.currentUser.owlCode}',
                              style: TextStyle(
                                color: Colors.amber[200],
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.copy_rounded, color: Colors.white.withOpacity(0.4), size: 14),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.white.withOpacity(0.08)),
                    const SizedBox(height: 12),
                    Text(
                      'Arkadaşının Kodunu Gir',
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: codeCtrl,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                      decoration: InputDecoration(
                        hintText: 'OWL-XXXX',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), letterSpacing: 1.5),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.06),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.amber.withOpacity(0.4)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 12),
                    StatefulBuilder(
                      builder: (ctx2, setDialogState) {
                        return ElevatedButton(
                          onPressed: () async {
                            final code = codeCtrl.text.trim();
                            if (code.isEmpty) return;
                            HapticFeedback.mediumImpact();
                            final success = await _service.sendFriendRequest(code);
                            if (ctx2.mounted) Navigator.pop(ctx2);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF8A3D),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('İstek Gönder ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                              Image.asset('assets/images/owl.webp', width: 14, height: 14),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInbox() {
    final letters = _service.inbox;
    final pending = _service.pendingLetters;

    if (letters.isEmpty && pending.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mail_outline_rounded, color: Colors.white.withOpacity(0.3), size: 28),
            const SizedBox(height: 8),
            Text(
              'Henüz mektup yok',
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        if (pending.isNotEmpty) ...[
          ...pending.map((l) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Image.asset('assets/images/owl.webp', width: 18, height: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${l.from.name} mektup gönderdi...',
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, fontStyle: FontStyle.italic),
                      ),
                    ),
                    Text('Baykuş yolda 🕊️', style: TextStyle(color: Colors.amber.withOpacity(0.5), fontSize: 8)),
                  ],
                ),
              )),
          if (letters.isNotEmpty) ...[
            const SizedBox(height: 6),
            Divider(color: Colors.white.withOpacity(0.1), height: 1),
            const SizedBox(height: 6),
          ],
        ],
        ...letters.map((letter) => GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _service.markAsRead(letter.id);
                _showReceivedLetter(context, letter);
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text(letter.from.emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            letter.from.name,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                              fontWeight: letter.isRead ? FontWeight.w400 : FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            letter.message,
                            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (letter.attachedCookieId != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(
                          '🥠',
                          style: TextStyle(
                            fontSize: 12,
                            color: letter.cookieClaimed
                                ? Colors.white.withOpacity(0.3)
                                : null,
                          ),
                        ),
                      ),
                    if (!letter.isRead)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.amber[400],
                        ),
                      ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  void _showReceivedLetter(BuildContext context, OwlLetter letter) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, a1, a2, child) {
        final curve = CurvedAnimation(parent: a1, curve: Curves.easeOutBack);
        return Transform.scale(
          scale: 0.8 + 0.2 * curve.value,
          child: Opacity(
            opacity: a1.value,
            child: _ReceivedLetterView(
              senderName: letter.from.name,
              senderEmoji: letter.from.emoji,
              message: letter.message,
              cookieId: letter.attachedCookieId,
              cookieName: letter.attachedCookieName,
              cookieClaimed: letter.cookieClaimed,
              onClaimCookie: () async {
                letter.cookieClaimed = true;
                if (letter.attachedCookieId != null) {
                  await StorageService.addCookieToCollection(letter.attachedCookieId!);
                }
                if (mounted) setState(() {});
              },
            ),
          ),
        );
      },
    );
  }
}

/// Gelen mektup görüntüleyici
class _ReceivedLetterView extends StatefulWidget {
  final String senderName;
  final String senderEmoji;
  final String message;
  final String? cookieId;
  final String? cookieName;
  final bool cookieClaimed;
  final VoidCallback? onClaimCookie;

  const _ReceivedLetterView({
    required this.senderName,
    required this.senderEmoji,
    required this.message,
    this.cookieId,
    this.cookieName,
    this.cookieClaimed = false,
    this.onClaimCookie,
  });

  @override
  State<_ReceivedLetterView> createState() => _ReceivedLetterViewState();
}

class _ReceivedLetterViewState extends State<_ReceivedLetterView>
    with SingleTickerProviderStateMixin {
  late AnimationController _cookieCtrl;
  late Animation<double> _cookieScale;
  bool _claimed = false;

  static const Map<String, String> _cookieImageMap = {
    'spring_wreath': 'assets/images/cookies/spring_wreath.webp',
    'lucky_clover': 'assets/images/cookies/lucky_clover.webp',
    'royal_hearts': 'assets/images/cookies/royal_hearts.webp',
    'evil_eye': 'assets/images/cookies/evil_eye.webp',
    'pizza_party': 'assets/images/cookies/pizza_party.webp',
    'sakura_bloom': 'assets/images/cookies/sakura_bloom.webp',
    'blue_porcelain': 'assets/images/cookies/blue_porcelain.webp',
    'pink_blossom': 'assets/images/cookies/pink_blossom.webp',
    'fortune_cat': 'assets/images/cookies/fortune_cat.webp',
    'wildflower': 'assets/images/cookies/wildflower.webp',
    'cupid_ribbon': 'assets/images/cookies/cupid_ribbon.webp',
    'panda_bamboo': 'assets/images/cookies/panda_bamboo.webp',
    'ramadan_cute': 'assets/images/cookies/ramadan_cute.webp',
    'enchanted_forest': 'assets/images/cookies/enchanted_forest.webp',
    'golden_arabesque': 'assets/images/cookies/golden_arabesque.webp',
    'midnight_mosaic': 'assets/images/cookies/midnight_mosaic.webp',
    'pearl_lace': 'assets/images/cookies/pearl_lace.webp',
    'golden_sakura': 'assets/images/cookies/golden_sakura.webp',
    'dragon_phoenix': 'assets/images/cookies/dragon_phoenix.webp',
    'gold_beasts': 'assets/images/cookies/gold_beasts.webp',
  };

  @override
  void initState() {
    super.initState();
    _claimed = widget.cookieClaimed;
    _cookieCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cookieScale = CurvedAnimation(parent: _cookieCtrl, curve: Curves.elasticOut);
    // Kurabiye varsa giriş animasyonu
    if (widget.cookieId != null && !_claimed) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _cookieCtrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _cookieCtrl.dispose();
    super.dispose();
  }

  void _claimCookie() {
    HapticFeedback.heavyImpact();
    setState(() => _claimed = true);
    widget.onClaimCookie?.call();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final hasCookie = widget.cookieId != null;
    final imgPath = hasCookie ? _cookieImageMap[widget.cookieId] : null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 24),
      child: SizedBox(
        width: screenWidth * 0.85,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 176,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.only(top: 2, left: 1),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: ClipPath(
                      clipper: _LetterTornClipper(),
                      child: Container(
                        color: const Color(0xFFF2E8D5),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Spacer(),
                                  Column(
                                    children: [
                                      Text(widget.senderEmoji, style: const TextStyle(fontSize: 16)),
                                      const SizedBox(height: 2),
                                      Text(
                                        widget.senderName,
                                        style: const TextStyle(
                                          color: Color(0xFF4A3928),
                                          fontSize: 8,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    widget.message,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFF4A3928),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Roboto',
                                      height: 1.6,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Kurabiye mühür — sağ alt köşe
                  if (hasCookie)
                    Positioned(
                      right: 14,
                      bottom: 12,
                      child: ScaleTransition(
                        scale: _cookieScale,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFE8D4B8),
                            border: Border.all(
                              color: const Color(0xFFD4A574),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.brown.withOpacity(0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: imgPath != null
                                ? Image.asset(imgPath, width: 24, height: 24, fit: BoxFit.contain)
                                : const Text('🥠', style: TextStyle(fontSize: 14)),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Kurabiye Al butonu
            if (hasCookie && !_claimed) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _claimCookie,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF8A3D), Color(0xFFFF6B2C)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF8A3D).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (imgPath != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Image.asset(imgPath, width: 20, height: 20, fit: BoxFit.contain),
                        ),
                      const Text(
                        'Kurabiyeyi Al',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text(' 🥠', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
            // Zaten alınmış
            if (hasCookie && _claimed) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.green[300], size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Kurabiye koleksiyona eklendi!',
                    style: TextStyle(
                      color: Colors.green[300],
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final String name;
  final String emoji;
  final bool isAppUser;
  final Rect owlButtonRect;
  final Friend? friend;

  const _ContactItem({
    required this.name,
    required this.emoji,
    required this.isAppUser,
    required this.owlButtonRect,
    this.friend,
  });

  void _showLetterPaper(BuildContext context) {
    // Paneli gizle
    final pageState = context.findAncestorStateOfType<_OwlLetterPageState>();
    pageState?.setState(() => pageState._showingLetter = true);  
    HapticFeedback.mediumImpact();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, a1, a2, child) {
        final curve = CurvedAnimation(parent: a1, curve: Curves.easeOutBack);
        return Transform.scale(
          scale: 0.8 + 0.2 * curve.value,
          child: Opacity(
            opacity: a1.value,
            child: _LetterPaper(recipientName: name, recipientEmoji: emoji, owlButtonRect: owlButtonRect, friend: friend),
          ),
        );
      },
    ).then((_) {
      // Mektup kapandı — paneli geri getir
      pageState?.setState(() => pageState._showingLetter = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (isAppUser) {
                _showLetterPaper(context);
              } else {
                HapticFeedback.lightImpact();
                // TODO: davet et
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isAppUser
                    ? const Color(0xFFFF8A3D).withOpacity(0.2)
                    : Colors.white.withOpacity(0.08),
                border: Border.all(
                  color: isAppUser
                      ? const Color(0xFFFF8A3D).withOpacity(0.4)
                      : Colors.white.withOpacity(0.15),
                  width: 0.5,
                ),
              ),
              child: Text(
                isAppUser ? 'Gönder' : 'Davet Et',
                style: TextStyle(
                  color: isAppUser
                      ? const Color(0xFFFF8A3D)
                      : Colors.white.withOpacity(0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mektup kağıdı — boş kağıt, mesaj yaz ve gönder
class _LetterPaper extends StatefulWidget {
  final String recipientName;
  final String recipientEmoji;
  final Rect owlButtonRect;
  final Friend? friend;

  const _LetterPaper({
    required this.recipientName,
    required this.recipientEmoji,
    required this.owlButtonRect,
    this.friend,
  });

  @override
  State<_LetterPaper> createState() => _LetterPaperState();
}

class _LetterPaperState extends State<_LetterPaper> with TickerProviderStateMixin {
  final _textCtrl = TextEditingController();
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  bool _hasText = false;

  bool _isSending = false;
  late AnimationController _sendCtrl;
  late Animation<double> _pullAnim;

  // Kurabiye ekleme
  List<CookieCard> _ownedCookies = [];
  String? _selectedCookieId;
  bool _showCookiePicker = false;

  // Kurabiye uçma animasyonu
  late AnimationController _cookieFlyCtrl;
  OverlayEntry? _flyingCookieEntry;
  final GlobalKey _paperKey = GlobalKey();
  Offset _flyFrom = Offset.zero;
  Offset _flyTo = Offset.zero;
  String? _flyingCookieImgPath;
  String? _flyingCookieId; // animasyon sırasında listeden gizlenir (x1 ise)

  static const Map<String, String> _cookieImageMap = {
    'spring_wreath': 'assets/images/cookies/spring_wreath.webp',
    'lucky_clover': 'assets/images/cookies/lucky_clover.webp',
    'royal_hearts': 'assets/images/cookies/royal_hearts.webp',
    'evil_eye': 'assets/images/cookies/evil_eye.webp',
    'pizza_party': 'assets/images/cookies/pizza_party.webp',
    'sakura_bloom': 'assets/images/cookies/sakura_bloom.webp',
    'blue_porcelain': 'assets/images/cookies/blue_porcelain.webp',
    'pink_blossom': 'assets/images/cookies/pink_blossom.webp',
    'fortune_cat': 'assets/images/cookies/fortune_cat.webp',
    'wildflower': 'assets/images/cookies/wildflower.webp',
    'cupid_ribbon': 'assets/images/cookies/cupid_ribbon.webp',
    'panda_bamboo': 'assets/images/cookies/panda_bamboo.webp',
    'ramadan_cute': 'assets/images/cookies/ramadan_cute.webp',
    'enchanted_forest': 'assets/images/cookies/enchanted_forest.webp',
    'golden_arabesque': 'assets/images/cookies/golden_arabesque.webp',
    'midnight_mosaic': 'assets/images/cookies/midnight_mosaic.webp',
    'pearl_lace': 'assets/images/cookies/pearl_lace.webp',
    'golden_sakura': 'assets/images/cookies/golden_sakura.webp',
    'dragon_phoenix': 'assets/images/cookies/dragon_phoenix.webp',
    'gold_beasts': 'assets/images/cookies/gold_beasts.webp',
  };

  static const Map<String, Color> _cookieColorMap = {
    'spring_wreath': Color(0xFF8BC34A),
    'lucky_clover': Color(0xFF4CAF50),
    'royal_hearts': Color(0xFFE91E63),
    'evil_eye': Color(0xFF2196F3),
    'pizza_party': Color(0xFFFF9800),
    'sakura_bloom': Color(0xFFF48FB1),
    'blue_porcelain': Color(0xFF42A5F5),
    'pink_blossom': Color(0xFFEC407A),
    'fortune_cat': Color(0xFFFFB74D),
    'wildflower': Color(0xFFAB47BC),
    'cupid_ribbon': Color(0xFFEF5350),
    'panda_bamboo': Color(0xFF66BB6A),
    'ramadan_cute': Color(0xFF7E57C2),
    'enchanted_forest': Color(0xFF26A69A),
    'golden_arabesque': Color(0xFFFFD700),
    'midnight_mosaic': Color(0xFF5C6BC0),
    'pearl_lace': Color(0xFFE0E0E0),
    'golden_sakura': Color(0xFFF8BBD0),
    'dragon_phoenix': Color(0xFFFF5722),
    'gold_beasts': Color(0xFFFFAB00),
  };

  @override
  void initState() {
    super.initState();
    _textCtrl.addListener(() {
      final has = _textCtrl.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
    _sendCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000));
    _pullAnim = CurvedAnimation(parent: _sendCtrl, curve: Curves.easeInOutCubic);
    _cookieFlyCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    _loadCookies();
  }

  Future<void> _loadCookies() async {
    final collection = await StorageService.getCookieCollection();
    final owned = collection.where((c) => c.firstObtainedDate != null && c.countObtained > 0).toList();
    owned.sort((a, b) => b.countObtained.compareTo(a.countObtained));
    // Test: sayıları x1, x2, x3 olarak sınırla
    final capped = owned.asMap().entries.map((e) {
      final cap = (e.key % 3) + 1; // 1, 2, 3, 1, 2, 3...
      return e.value.copyWith(countObtained: cap);
    }).toList();
    if (mounted) setState(() => _ownedCookies = capped);
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _sendCtrl.dispose();
    _cookieFlyCtrl.dispose();
    _flyingCookieEntry?.remove();
    super.dispose();
  }

  void _send() async {
    HapticFeedback.mediumImpact();
    FocusScope.of(context).unfocus();
    setState(() {
      _isSending = true;
      _showCookiePicker = false;
    });

    // Mock servise mektup gönder
    if (widget.friend != null) {
      final service = MockOwlService();
      final cookieName = _selectedCookieId != null
          ? _ownedCookies.firstWhere((c) => c.id == _selectedCookieId, orElse: () => _ownedCookies.first).name
          : null;

      service.sendLetter(
        toFriend: widget.friend!,
        message: _textCtrl.text.trim(),
        drawingStrokes: _strokes.isNotEmpty
            ? _strokes.map((s) => s.map((o) => {'x': o.dx, 'y': o.dy}).toList()).toList()
            : null,
        attachedCookieId: _selectedCookieId,
        attachedCookieName: cookieName,
      );

      if (_selectedCookieId != null) {
        await _deductCookie(_selectedCookieId!);
      }
    }

    _sendCtrl.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) Navigator.pop(context);
      });
    });
  }

  Future<void> _deductCookie(String cookieId) async {
    await StorageService.deductCookieCard(cookieId);
  }

  void _startCookieFly(GlobalKey itemKey, String cookieId, String? imgPath) {
    final fromBox = itemKey.currentContext?.findRenderObject() as RenderBox?;
    final paperBox = _paperKey.currentContext?.findRenderObject() as RenderBox?;
    if (fromBox == null || paperBox == null) {
      setState(() => _selectedCookieId = cookieId);
      return;
    }

    // Kurabiye sayısını bul
    final cookie = _ownedCookies.firstWhere((c) => c.id == cookieId);
    final isLastOne = cookie.countObtained <= 1;

    final fromPos = fromBox.localToGlobal(Offset(fromBox.size.width / 2, fromBox.size.height / 2));
    final paperPos = paperBox.localToGlobal(Offset.zero);
    final toPos = Offset(
      paperPos.dx + paperBox.size.width - 30,
      paperPos.dy + paperBox.size.height - 28,
    );

    _flyFrom = fromPos;
    _flyTo = toPos;
    _flyingCookieImgPath = imgPath;
    _cookieFlyCtrl.reset();

    // x1 ise listedeki kurabiyeyi gizle (kendisi uçacak)
    if (isLastOne) {
      setState(() => _flyingCookieId = cookieId);
    }

    final overlay = Overlay.of(context);
    _flyingCookieEntry?.remove();

    // Kavisli yol için kontrol noktası (yukarı doğru ark)
    final controlPoint = Offset(
      (_flyFrom.dx + _flyTo.dx) / 2,
      math.min(_flyFrom.dy, _flyTo.dy) - 80,
    );

    _flyingCookieEntry = OverlayEntry(
      builder: (context) {
        return AnimatedBuilder(
          animation: _cookieFlyCtrl,
          builder: (context, _) {
            final raw = _cookieFlyCtrl.value;
            final t = Curves.easeOutCubic.transform(raw);

            // Quadratic Bezier eğrisi — kavisli yol
            final p0 = _flyFrom;
            final p1 = controlPoint;
            final p2 = _flyTo;
            final pos = Offset(
              (1 - t) * (1 - t) * p0.dx + 2 * (1 - t) * t * p1.dx + t * t * p2.dx,
              (1 - t) * (1 - t) * p0.dy + 2 * (1 - t) * t * p1.dy + t * t * p2.dy,
            );

            // Ölçek: başta hafif büyür, sona doğru nazikçe 1.0'a döner
            final scale = 1.0 + 0.15 * math.sin(t * math.pi * 0.8);

            // Yumuşak dönüş — sona doğru sıfıra iner
            final rotation = math.sin(t * math.pi * 0.7) * 0.25 * (1.0 - t * t);

            // Son %25'te kaybol — mühür zaten belirmiş olacak
            final fadeOut = raw > 0.75 ? 1.0 - ((raw - 0.75) / 0.25) : 1.0;

            return Positioned(
              left: pos.dx - 22,
              top: pos.dy - 22,
              child: Opacity(
                opacity: fadeOut.clamp(0.0, 1.0),
                child: Transform.scale(
                scale: scale,
                child: Transform.rotate(
                  angle: rotation,
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: _flyingCookieImgPath != null
                        ? Image.asset(_flyingCookieImgPath!, fit: BoxFit.contain)
                        : const Text('🥠', style: TextStyle(fontSize: 24)),
                  ),
                ),
              ),
              ),
            );
          },
        );
      },
    );

    overlay.insert(_flyingCookieEntry!);

    // Animasyon %70'e gelince mühürü göster (crossfade)
    bool stampShown = false;
    _cookieFlyCtrl.addListener(() {
      if (_cookieFlyCtrl.value > 0.70 && !stampShown && mounted) {
        stampShown = true;
        setState(() => _selectedCookieId = cookieId);
      }
    });

    _cookieFlyCtrl.forward().then((_) {
      _flyingCookieEntry?.remove();
      _flyingCookieEntry = null;
      if (mounted) {
        setState(() {
          _flyingCookieId = null;
          // x1 ise listeden kaldır
          if (isLastOne) {
            _ownedCookies.removeWhere((c) => c.id == cookieId);
          } else {
            // x2+ ise sayıyı düşür
            final idx = _ownedCookies.indexWhere((c) => c.id == cookieId);
            if (idx >= 0) {
              _ownedCookies[idx] = _ownedCookies[idx].copyWith(
                countObtained: _ownedCookies[idx].countObtained - 1,
              );
            }
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return AnimatedBuilder(
      animation: _sendCtrl,
      builder: (context, _) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 24),
          child: SizedBox(
              width: screenWidth * 0.85,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ══════════════ ANA ALAN ══════════════
                    if (_isSending) ...[
                      // Gönderirken: Zarfı göster
                      SizedBox(
                        width: screenWidth * 0.75,
                        height: screenWidth * 0.75 * 0.55,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            // Arka gövde
                            Positioned.fill(
                              child: Image.asset(
                                'assets/images/envelope/envelope_back.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            // Ön V yüzü
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: SizedBox(
                                height: screenWidth * 0.75 * 0.25,
                                child: Image.asset(
                                  'assets/images/envelope/envelope_front.png',
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            // Kapak (üstte, kapalı)
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: SizedBox(
                                height: screenWidth * 0.75 * 0.30,
                                child: Image.asset(
                                  'assets/images/envelope/envelope_flap.png',
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Normal: Kağıdı göster
                      SizedBox(
                        key: _paperKey,
                        width: double.infinity,
                        height: 176,
                        child: Stack(
                          children: [
                            // Gölge
                            Positioned.fill(
                              child: Container(
                                margin: const EdgeInsets.only(top: 2, left: 1),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                      spreadRadius: -2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Yırtık kenarlı kağıt
                            Positioned.fill(
                              child: ClipPath(
                                clipper: _LetterTornClipper(),
                                child: Container(
                                  color: const Color(0xFFF2E8D5),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        right: 30, top: 20,
                                        child: Transform.rotate(
                                          angle: 0.3,
                                          child: Container(width: 18, height: 0.3, color: Colors.black.withOpacity(0.04)),
                                        ),
                                      ),
                                      Positioned(
                                        left: 40, bottom: 60,
                                        child: Transform.rotate(
                                          angle: -0.15,
                                          child: Container(width: 22, height: 0.3, color: Colors.black.withOpacity(0.03)),
                                        ),
                                      ),
                                      // İçerik
                                      Positioned.fill(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  const Spacer(),
                                                  Column(
                                                    children: [
                                                      Text(widget.recipientEmoji, style: const TextStyle(fontSize: 16)),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        widget.recipientName,
                                                        style: const TextStyle(
                                                          color: Color(0xFF4A3928),
                                                          fontSize: 8,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const Spacer(),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Expanded(
                                                child: Stack(
                                                  children: [
                                                    Center(
                                                      child: TextField(
                                                        controller: _textCtrl,
                                                        maxLength: 150,
                                                        maxLines: 5,
                                                        minLines: 1,
                                                        textAlign: TextAlign.center,
                                                        style: const TextStyle(
                                                          color: Color(0xFF4A3928),
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                          fontFamily: 'Roboto',
                                                          height: 1.6,
                                                          letterSpacing: 0.1,
                                                        ),
                                                        decoration: const InputDecoration(
                                                          hintText: 'Mektubunu yaz...',
                                                          hintStyle: TextStyle(
                                                            color: Color(0xFFB0A484),
                                                            fontSize: 13,
                                                          ),
                                                          border: InputBorder.none,
                                                          isDense: true,
                                                          contentPadding: EdgeInsets.zero,
                                                          counterText: '',
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned.fill(
                                                      child: IgnorePointer(
                                                        child: CustomPaint(
                                                          painter: _DrawingPainter(strokes: _strokes, currentStroke: _currentStroke),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Kurabiye mühür
                                      if (_selectedCookieId != null)
                                        Builder(
                                          builder: (context) {
                                            final stampColor = _cookieColorMap[_selectedCookieId!] ?? const Color(0xFFD4A574);
                                            return Positioned(
                                              right: 10,
                                              bottom: 8,
                                              child: TweenAnimationBuilder<double>(
                                                tween: Tween(begin: 0.0, end: 1.0),
                                                duration: const Duration(milliseconds: 350),
                                                curve: Curves.easeOutCubic,
                                                builder: (context, value, child) {
                                                  return Opacity(
                                                    opacity: value,
                                                    child: Transform.scale(
                                                      scale: 0.6 + 0.4 * value,
                                                      child: child,
                                                    ),
                                                  );
                                                },
                                                child: GestureDetector(
                                                  onTap: () => setState(() => _selectedCookieId = null),
                                                  child: Container(
                                                    width: 44,
                                                    height: 44,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: stampColor.withOpacity(0.15),
                                                      border: Border.all(
                                                        color: stampColor.withOpacity(0.7),
                                                        width: 1.5,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: stampColor.withOpacity(0.25),
                                                          blurRadius: 6,
                                                          offset: const Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Center(
                                                      child: _cookieImageMap[_selectedCookieId] != null
                                                          ? Image.asset(
                                                              _cookieImageMap[_selectedCookieId]!,
                                                              width: 32,
                                                              height: 32,
                                                              fit: BoxFit.contain,
                                                            )
                                                          : const Text('🥠', style: TextStyle(fontSize: 18)),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
            // Butonlar yan yana: sol Baykuşa Ver, sağ Kurabiye Ekle
            if (!_isSending) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Baykuşa Ver butonu (sol)
                  GestureDetector(
                    onTap: _hasText ? _send : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: _hasText
                            ? const Color(0xFFFF8A3D).withOpacity(0.2)
                            : Colors.white.withOpacity(0.06),
                        border: Border.all(
                          color: _hasText
                              ? const Color(0xFFFF8A3D).withOpacity(0.4)
                              : Colors.white.withOpacity(0.1),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        _selectedCookieId != null ? '🦉 Baykuşa Ver 🥠' : '🦉 Baykuşa Ver',
                        style: TextStyle(
                          color: _hasText
                              ? const Color(0xFFFF8A3D)
                              : Colors.white.withOpacity(0.3),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Kurabiye Ekle butonu (sağ)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _showCookiePicker = !_showCookiePicker);
                    },
                    child: Builder(
                      builder: (context) {
                        final selColor = _selectedCookieId != null
                            ? (_cookieColorMap[_selectedCookieId!] ?? const Color(0xFFFF8A3D))
                            : const Color(0xFFFF8A3D);
                        return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: _selectedCookieId != null
                            ? selColor.withOpacity(0.2)
                            : Colors.white.withOpacity(0.1),
                        border: Border.all(
                          color: _selectedCookieId != null
                              ? selColor.withOpacity(0.4)
                              : Colors.white.withOpacity(0.15),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedCookieId != null ? '🥠 Eklendi' : '🥠 Kurabiye Ekle',
                            style: TextStyle(
                              color: _selectedCookieId != null
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.6),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_showCookiePicker)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(
                                Icons.keyboard_arrow_up_rounded,
                                color: Colors.white.withOpacity(0.4),
                                size: 14,
                              ),
                            ),
                        ],
                      ),
                    );
                      },
                    ),
                  ),
                ],
              ),
              // Kurabiye seçici — yatay scroll
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: _showCookiePicker
                    ? Container(
                        margin: const EdgeInsets.only(top: 8),
                        height: 56,
                        child: _ownedCookies.isEmpty
                            ? Center(
                                child: Text(
                                  'Koleksiyonunda kurabiye yok',
                                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10),
                                ),
                              )
                            : ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                itemCount: _ownedCookies.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final cookie = _ownedCookies[index];
                                  final isSelected = _selectedCookieId == cookie.id;
                                  final imgPath = _cookieImageMap[cookie.id];
                                  final itemKey = GlobalKey();
                                  final cookieColor = _cookieColorMap[cookie.id] ?? const Color(0xFFFF8A3D);
                                  return GestureDetector(
                                    key: itemKey,
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      if (isSelected) {
                                        setState(() => _selectedCookieId = null);
                                        return;
                                      }
                                      // Kurabiye uçma animasyonu başlat
                                      _startCookieFly(itemKey, cookie.id, imgPath);
                                    },
                                    child: _flyingCookieId == cookie.id
                                      ? const SizedBox(width: 48) // x1: uçarken boş yer bırak
                                      : AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 48,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: isSelected
                                            ? cookieColor.withOpacity(0.25)
                                            : Colors.white.withOpacity(0.06),
                                        border: Border.all(
                                          color: isSelected
                                              ? cookieColor.withOpacity(0.6)
                                              : Colors.white.withOpacity(0.1),
                                          width: isSelected ? 1.5 : 0.5,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          imgPath != null
                                              ? Image.asset(imgPath, width: 28, height: 28, fit: BoxFit.contain)
                                              : const Text('🥠', style: TextStyle(fontSize: 18)),
                                          const SizedBox(height: 2),
                                          Text(
                                            'x${cookie.countObtained}',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.4),
                                              fontSize: 7,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ],
        ),
      ),
    ),
  );
      },
    );
  }
}

/// Mektup kağıdı yırtık kenar — fortune paper ile aynı stil
class _LetterTornClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(0, 0);
    for (double x = 0; x <= w; x += 1) {
      final y = math.sin(x * 0.12) * 0.4 + math.sin(x * 0.35) * 0.2;
      path.lineTo(x, y + 0.6);
    }
    for (double y = 0; y <= h; y += 1) {
      final x = w - 0.6 + math.sin(y * 0.15) * 0.4 + math.sin(y * 0.4) * 0.2;
      path.lineTo(x, y);
    }
    for (double x = w; x >= 0; x -= 1) {
      final y = h - 0.6 + math.sin(x * 0.14) * 0.5 + math.sin(x * 0.38) * 0.2;
      path.lineTo(x, y);
    }
    for (double y = h; y >= 0; y -= 1) {
      final x = 0.6 + math.sin(y * 0.16) * 0.4 + math.sin(y * 0.42) * 0.2;
      path.lineTo(x, y);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Çizim için painter
class _DrawingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;

  _DrawingPainter({required this.strokes, required this.currentStroke});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4A3928)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      _drawStroke(canvas, stroke, paint);
    }
    if (currentStroke.isNotEmpty) {
      _drawStroke(canvas, currentStroke, paint);
    }
  }

  void _drawStroke(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.length < 2) {
      if (points.length == 1) {
        canvas.drawCircle(points[0], 1, paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;
      }
      return;
    }
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) => true;
}
