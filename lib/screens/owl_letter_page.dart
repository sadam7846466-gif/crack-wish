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
  late PageController _pageCtrl;
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
    _pageCtrl = PageController(initialPage: _selectedTab);
    _service.loadMockData();
    _service.addListener(_onServiceUpdate);
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _pageCtrl.dispose();
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
                          // Kenarları parlak renkli cam ışığına dönüştüren muazzam efekt:
                          border: Border.all(
                            color: const Color(0xFFAEC4FF).withOpacity(0.3 * t), // Buzlu mavi parlaklık
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF5A8BFF).withOpacity(0.15 * t), // Dışa dönük mavi aydınlatma
                              blurRadius: 40,
                              spreadRadius: -10,
                            ),
                            BoxShadow(
                              color: const Color(0xFFFF8A3D).withOpacity(0.10 * t), // Ters köşeye turuncu sıcaklık
                              blurRadius: 40,
                              offset: const Offset(10, 10),
                              spreadRadius: -5,
                            ),
                          ],
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
                                  // Arkadaşlarım ve Gelen Mektup yan yana (Sleek Reference Design)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _AnimatedMenuItem(
                                          label: 'Arkadaşlarım',
                                          isSelected: _selectedTab == 0,
                                          onTap: () {
                                            if (_selectedTab != 0) {
                                              setState(() => _selectedTab = 0);
                                              _pageCtrl.animateToPage(0, duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _AnimatedMenuItem(
                                          label: 'Bağlantılar',
                                          isSelected: _selectedTab == 1,
                                          onTap: () {
                                            if (_selectedTab != 1) {
                                              setState(() => _selectedTab = 1);
                                              _pageCtrl.animateToPage(1, duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _AnimatedMenuItem(
                                          label: 'Gelen Mektup',
                                          isSelected: _selectedTab == 2,
                                          onTap: () {
                                            if (_selectedTab != 2) {
                                              setState(() => _selectedTab = 2);
                                              _pageCtrl.animateToPage(2, duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // İçerik - PageView (Tamamen Pürüzsüz Slide)
                                  Expanded(
                                    child: PageView(
                                      controller: _pageCtrl,
                                      physics: const ClampingScrollPhysics(),
                                      onPageChanged: (idx) {
                                        if (_selectedTab != idx) {
                                          setState(() => _selectedTab = idx);
                                        }
                                      },
                                      children: [
                                        _buildContactsTab(br),
                                        _buildDiscoverTab(br),
                                        _buildInboxTab(br),
                                      ],
                                    ),
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


  Widget _buildContactsTab(Rect br) {
    return Column(
      children: [
        // Arama çubuğu
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.black.withOpacity(0.20),
            border: Border.all(color: Colors.white.withOpacity(0.05), width: 0.5),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.35), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Arkadaş ara...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 12),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              if (_searchQuery.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.4), size: 14),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Liste
        Expanded(child: _buildContactsList(br)),
      ],
    );
  }

  // YENİ SEKMELER: Uygulama içi olmayan/veya rehberden gelenlerin gösterileceği yer.
  Widget _buildDiscoverTab(Rect br) {
    return Column(
      children: [
        // Bağlantılar için Arama Çubuğu
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.black.withOpacity(0.20),
            border: Border.all(color: Colors.white.withOpacity(0.05), width: 0.5),
          ),
          child: Row(
            children: [
              Icon(Icons.person_search_rounded, color: Colors.white.withOpacity(0.35), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Kişilerini bul veya davet et...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 12),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.contact_phone_rounded, color: Colors.white.withOpacity(0.15), size: 40),
                const SizedBox(height: 10),
                Text(
                  'Rehberine Eriş',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Uygulamayı kullananları bul ve kullanmayanlara davet gönder.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                  ),
                ),
                const SizedBox(height: 16),
                _addFriendButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInboxTab(Rect br) {
    return _buildInbox(br);
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
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'Arkadaşlık İstekleri',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // ...requests.map((req) => _buildRequestItem(req)),
          // vs. İsteğe göre istekler burada tutulabilir.
          ...requests.map((req) => _buildRequestItem(req)),
          const SizedBox(height: 12),
        ],
        // Arkadaş listesi
        ...friends.map((f) => _ContactItem(
              name: f.user.name,
              emoji: f.user.emoji,
              isAppUser: true,
              owlButtonRect: br,
              friend: f,
            )),
      ],
    );
  }

  Widget _buildRequestItem(FriendRequest req) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                  border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.0),
                ),
                child: Center(
                  child: Text(req.from.emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      req.from.name,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _service.acceptRequest(req.id);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFF4A7A6A).withOpacity(0.15),
                        border: Border.all(color: const Color(0xFF6DE8B8).withOpacity(0.35), width: 1.0),
                      ),
                      child: const Text('Kabul', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _service.rejectRequest(req.id);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFF9A4A4A).withOpacity(0.15), // Pastel kırmızımsı mat zemin
                        border: Border.all(color: const Color(0xFFE86D6D).withOpacity(0.35), width: 1.0), // Parlak pastel kırmızı çerçeve
                      ),
                      child: const Text('Red', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(color: Colors.white.withOpacity(0.05), height: 1),
      ],
    );
  }

  Widget _addFriendButton() {
    return GestureDetector(
      onTap: () => _showAddFriendDialog(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withOpacity(0.04), // Tamamen siyah yerine çok şeffaf beyaz buz
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  child: Icon(Icons.person_add_rounded, color: Colors.white.withOpacity(0.8), size: 12),
                ),
                const SizedBox(width: 8),
                Text(
                  'Arkadaş Ekle',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
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

  Widget _buildInbox(Rect br) {
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
        ...letters.map((letter) {
          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _service.markAsRead(letter.id);
                  _showReceivedLetter(context, letter, br);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.0),
                        ),
                        child: Center(
                          child: Text(letter.from.emoji, style: const TextStyle(fontSize: 22)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              letter.from.name,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.95),
                                fontSize: 14,
                                fontWeight: letter.isRead ? FontWeight.w500 : FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              letter.message,
                              style: TextStyle(
                                color: letter.isRead ? Colors.white.withOpacity(0.5) : Colors.white.withOpacity(0.8), 
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (letter.attachedCookieId != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            '🥠',
                            style: TextStyle(
                              fontSize: 16,
                              color: letter.cookieClaimed
                                  ? Colors.white.withOpacity(0.3)
                                  : null,
                            ),
                          ),
                        ),
                      if (!letter.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.amber[400],
                            boxShadow: [
                              BoxShadow(color: Colors.amber.withOpacity(0.4), blurRadius: 4, offset: Offset.zero),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Divider(color: Colors.white.withOpacity(0.05), height: 1),
            ],
          );
        }),
      ],
    );
  }

  void _showReceivedLetter(BuildContext context, OwlLetter letter, Rect owlButtonRect) {
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
              onReply: () {
                Navigator.pop(ctx); // Önce mektubu kapat
                
                // Mektup okuma penceresi kapandıktan hemen sonra (hafif gecikme ile) Mektup Yazma arayüzünü aç
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (!mounted) return;
                  final friend = _service.searchFriends('').where((f) => f.user.id == letter.from.id).firstOrNull;
                  
                  setState(() => _showingLetter = true);
                  showGeneralDialog(
                    context: context,
                    barrierDismissible: true,
                    barrierLabel: 'Close',
                    barrierColor: Colors.black54,
                    transitionDuration: const Duration(milliseconds: 350),
                    pageBuilder: (c, a1, a2) => const SizedBox.shrink(),
                    transitionBuilder: (c, a1, a2, child) {
                      final cCurve = CurvedAnimation(parent: a1, curve: Curves.easeOutBack);
                      return Transform.scale(
                        scale: 0.8 + 0.2 * cCurve.value,
                        child: Opacity(
                          opacity: a1.value,
                          child: _LetterPaper(
                            recipientName: letter.from.name,
                            recipientEmoji: letter.from.emoji,
                            owlButtonRect: owlButtonRect,
                            friend: friend,
                          ),
                        ),
                      );
                    },
                  ).then((_) {
                    if (mounted) setState(() => _showingLetter = false);
                  });
                });
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
  final VoidCallback? onReply;

  const _ReceivedLetterView({
    required this.senderName,
    required this.senderEmoji,
    required this.message,
    this.cookieId,
    this.cookieName,
    this.cookieClaimed = false,
    this.onClaimCookie,
    this.onReply,
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
            // Yanıtla Butonu (Herkeste çıkmalı)
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                widget.onReply?.call();
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withOpacity(0.05),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.reply_rounded, color: Colors.white.withOpacity(0.9), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Yanıtla',
                          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedMenuItem extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  const _AnimatedMenuItem({
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  State<_AnimatedMenuItem> createState() => _AnimatedMenuItemState();
}

class _AnimatedMenuItemState extends State<_AnimatedMenuItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: widget.isSelected ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.04),
                border: Border.all(
                  color: widget.isSelected ? Colors.white.withOpacity(0.4) : Colors.white.withOpacity(0.12),
                  width: widget.isSelected ? 1.0 : 0.6,
                ),
              ),
              child: Text(
                widget.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: widget.isSelected ? Colors.white : Colors.white.withOpacity(0.75),
                  fontSize: 12,
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                  border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.0),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (isAppUser) {
                    _showLetterPaper(context);
                  } else {
                    HapticFeedback.lightImpact();
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: isAppUser 
                            ? const Color(0xFF4A6A8A).withOpacity(0.15) // Şık buz mavisi mat zemin
                            : Colors.white.withOpacity(0.04),
                        border: Border.all(
                          color: isAppUser ? const Color(0xFF6DAEE8).withOpacity(0.35) : Colors.white.withOpacity(0.2), // Parlak buz mavisi çerçeve
                          width: 0.8
                        ),
                      ),
                      child: isAppUser
                          ? const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                '🪶', 
                                style: TextStyle(fontSize: 16), // Renkli emoji olduğu için color vermeye gerek yok
                              ),
                            )
                          : Text(
                              'Davet Et',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(color: Colors.white.withOpacity(0.05), height: 1),
      ],
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
  final _textFocusNode = FocusNode();
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  bool _hasText = false;

  bool _isSending = false;
  late AnimationController _sendCtrl;
  late Animation<double> _pullAnim;

  // Katlama ve Zarf
  late AnimationController _foldCtrl;
  late AnimationController _envelopeCtrl;
  late Animation<double> _flapAnimation;
  late Animation<double> _letterTranslateAnimation;
  late Animation<double> _letterScaleAnimation;
  bool _isFolding = false;
  bool _isEnveloping = false;

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
    _sendCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _pullAnim = CurvedAnimation(parent: _sendCtrl, curve: Curves.easeInOutCubic);
    _foldCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _envelopeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _flapAnimation = Tween<double>(begin: 0, end: -math.pi).animate(
      CurvedAnimation(parent: _envelopeCtrl, curve: const Interval(0.0, 0.5, curve: Curves.easeInOut)),
    );
    _letterTranslateAnimation = Tween<double>(begin: 0, end: -110).animate(
      CurvedAnimation(parent: _envelopeCtrl, curve: const Interval(0.4, 1.0, curve: Curves.easeOutBack)),
    );
    _letterScaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _envelopeCtrl, curve: const Interval(0.4, 1.0, curve: Curves.easeOut)),
    );
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
    _textFocusNode.dispose();
    _sendCtrl.dispose();
    _foldCtrl.dispose();
    _envelopeCtrl.dispose();
    _cookieFlyCtrl.dispose();
    _flyingCookieEntry?.remove();
    super.dispose();
  }

  void _send() async {
    HapticFeedback.mediumImpact();
    FocusScope.of(context).unfocus();
    setState(() {
      _isSending = true;
      _isFolding = true;
    });

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

    // Adım 1: Muhteşem origami katlama başlar
    await _foldCtrl.forward().orCancel;
    if (!mounted) return;

    // Kısa bekleme — daha akıcı ve hızlı geçiş
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;

    // Adım 2: Mektup zarfa girer, kapak kapanır
    setState(() => _isEnveloping = true);
    await _envelopeCtrl.forward().orCancel;
    if (!mounted) return;

    // Adım 3: Zarf havada çok kısa asılı kalır ve sonra baykuşa uçar
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    
    HapticFeedback.mediumImpact(); // Uçuşa geçerken hafif titreşim
    await _sendCtrl.forward().orCancel;

    // Animasyon tamamlandığında paneli kapatıp mektup göndermeyi bitir
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  // Kullanıcının yazdığı içeriğin birebir kopyası (katlama animasyonunda gösterilecek yüzeyler için)
  Widget _buildPaperInnerContent() {
    return Stack(
      children: [
        Positioned(
          right: 30, top: 20,
          child: Transform.rotate(angle: 0.3, child: Container(width: 18, height: 0.3, color: Colors.black.withOpacity(0.04))),
        ),
        Positioned(
          left: 40, bottom: 60,
          child: Transform.rotate(angle: -0.15, child: Container(width: 22, height: 0.3, color: Colors.black.withOpacity(0.03))),
        ),
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
                          style: const TextStyle(color: Color(0xFF4A3928), fontSize: 8, fontWeight: FontWeight.w600),
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
                        child: Text(
                          _textCtrl.text,
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
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _DrawingPainter(strokes: _strokes, currentStroke: _currentStroke),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_selectedCookieId != null)
          Positioned(
            right: 10, bottom: 8,
            child: Transform.scale(
              scale: 1.0,
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (_cookieColorMap[_selectedCookieId!] ?? const Color(0xFFD4A574)).withOpacity(0.15),
                  border: Border.all(color: (_cookieColorMap[_selectedCookieId!] ?? const Color(0xFFD4A574)).withOpacity(0.7), width: 1.5),
                ),
                child: Center(
                  child: _cookieImageMap[_selectedCookieId] != null
                      ? Image.asset(_cookieImageMap[_selectedCookieId]!, width: 32, height: 32, fit: BoxFit.contain)
                      : const Text('🥠', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Kağıdın belirli bir parçasını kesip alan yardımcı metod
  Widget _buildPaperSlice(double paperW, double paperH, double sliceX, double sliceY, double sliceW, double sliceH) {
    return ClipRect(
      child: SizedBox(
        width: sliceW,
        height: sliceH,
        child: Stack(
          children: [
            Positioned(
              left: -sliceX,
              top: -sliceY,
              child: SizedBox(
                width: paperW,
                height: paperH,
                child: _buildPaperInnerContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoldingPaper(double paperW, double paperH) {
    const frontColor = Color(0xFFF2E8D5);
    const backColor = Color(0xFFE0D0B8);
    final quarterW = paperW / 4;
    final centerW = paperW / 2;
    final halfH = paperH / 2;

    return AnimatedBuilder(
      animation: _foldCtrl,
      builder: (context, _) {
        final t = _foldCtrl.value;
        final fLift = (t / 0.15).clamp(0.0, 1.0);
        
        // Daha yumuşak ve esnek katlama hissi için fastOutSlowIn veya easeOutBack kullanıyoruz
        final fLeft = Curves.easeOutBack.transform(((t - 0.05) / 0.40).clamp(0.0, 1.0));
        final fRight = Curves.easeOutBack.transform(((t - 0.20) / 0.40).clamp(0.0, 1.0));
        final fTop = Curves.easeOutBack.transform(((t - 0.45) / 0.45).clamp(0.0, 1.0));
        final fDrop = Curves.easeInOutCubic.transform(((t - 0.75) / 0.25).clamp(0.0, 1.0));

        final scale = 1.0 - (0.05 * fLift) - (0.05 * fTop) + (0.10 * fDrop);
        final tiltX = (math.pi / 12) * fLift * (1 - fDrop); // Daha belirgin eğilme
        final tiltY = -(math.pi / 18) * fLift * (1 - fDrop);
        final elevation = 25.0 * fLift * (1 - fDrop) + 5.0;

        Widget buildSideFlap(double f, bool isLeft, double sliceY) {
          final isBack = f > 0.5;
          final sliceX = isLeft ? 0.0 : paperW - quarterW;
          return Transform(
            alignment: isLeft ? Alignment.centerRight : Alignment.centerLeft,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0025) // 3D derinliği arttırıldı
              ..rotateY(isLeft ? f * math.pi : -f * math.pi),
            child: Container(
              width: quarterW,
              height: halfH,
              decoration: BoxDecoration(
                color: isBack ? backColor : frontColor,
                boxShadow: [
                  if (f < 0.1) BoxShadow(color: Colors.black.withOpacity(0.2 * (1 - f * 10)), blurRadius: elevation, offset: Offset(0, elevation)),
                  if (f > 0.01 && f < 0.99) BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 15 * (1 - f).abs(), offset: Offset(isLeft ? 5 : -5, 0)),
                ],
              ),
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  if (!isBack) _buildPaperSlice(paperW, paperH, sliceX, sliceY, quarterW, halfH),
                  if (f > 0 && f < 0.5) Container(color: Colors.white.withOpacity(f * 0.3)),
                  if (isBack) Container(color: Colors.black.withOpacity((f - 0.5) * 0.15)),
                ],
              ),
            ),
          );
        }

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015) // Havalanırken olan derinlik
            ..scale(scale)
            ..rotateX(tiltX)
            ..rotateZ(tiltY * 0.4)
            ..rotateY(tiltY * 1.2),
          child: SizedBox(
            width: paperW,
            height: paperH,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ── ALT YARI (SABİT ZEMİN) ──
                Positioned(
                  left: quarterW, top: halfH, width: centerW, height: halfH,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        decoration: BoxDecoration(color: frontColor, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: elevation, offset: Offset(0, elevation))]),
                        child: Stack(
                          fit: StackFit.passthrough,
                          children: [
                            _buildPaperSlice(paperW, paperH, quarterW, halfH, centerW, halfH),
                            if (fTop > 0) Container(color: Colors.black.withOpacity(fTop * 0.3)), // Üst katlanırken altı gölgeler
                          ]
                        ),
                      ),
                      Positioned(right: centerW, top: 0, child: buildSideFlap(fLeft, true, halfH)),
                      Positioned(left: centerW, top: 0, child: buildSideFlap(fRight, false, halfH)),
                      if (fLeft > 0) Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black.withOpacity(0.15 * fLeft), Colors.transparent], begin: Alignment.centerLeft, end: Alignment.centerRight))),
                      if (fRight > 0) Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black.withOpacity(0.15 * fRight), Colors.transparent], begin: Alignment.centerRight, end: Alignment.centerLeft))),
                    ],
                  ),
                ),

                // ── ÜST YARI (AŞAĞI DOĞRU KAPAK GİBİ KAPANIR) ──
                Positioned(
                  left: quarterW, top: 0, width: centerW, height: halfH,
                  child: Transform(
                    alignment: Alignment.bottomCenter,
                    transform: Matrix4.identity()..setEntry(3, 2, 0.0025)..rotateX(-fTop * math.pi),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: fTop > 0.5 ? backColor : frontColor,
                            boxShadow: [
                              if (fTop < 0.1) BoxShadow(color: Colors.black.withOpacity(0.2 * (1 - fTop * 10)), blurRadius: elevation, offset: Offset(0, elevation)),
                              if (fTop > 0.01 && fTop < 0.99) BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20 * (1 - fTop).abs(), offset: const Offset(0, 10))
                            ]
                          ),
                          child: Stack(
                            fit: StackFit.passthrough,
                            children: [
                              if (fTop < 0.5) _buildPaperSlice(paperW, paperH, quarterW, 0, centerW, halfH),
                              if (fTop > 0 && fTop < 0.5) Container(color: Colors.white.withOpacity(fTop * 0.2)),
                              if (fTop >= 0.5) Container(color: Colors.black.withOpacity((fTop - 0.5) * 0.15)),
                            ]
                          ),
                        ),
                        Positioned(right: centerW, top: 0, child: buildSideFlap(fLeft, true, 0)),
                        Positioned(left: centerW, top: 0, child: buildSideFlap(fRight, false, 0)),
                        if (fLeft > 0 && fTop < 0.5) Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black.withOpacity(0.15 * fLeft), Colors.transparent], begin: Alignment.centerLeft, end: Alignment.centerRight))),
                        if (fRight > 0 && fTop < 0.5) Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black.withOpacity(0.15 * fRight), Colors.transparent], begin: Alignment.centerRight, end: Alignment.centerLeft))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==== YENİ 3D BİRLEŞTİRİLMİŞ ZARF VE KAĞIT ANİMASYONU (KESİNTİSİZ) ====
  Widget _buildUnifiedAnimation(double paperW, double paperH) {
    final envW = paperW * 0.58;
    final envH = envW * 0.58;
    final flapH = envH * 0.78;

    return AnimatedBuilder(
      animation: Listenable.merge([_foldCtrl, _envelopeCtrl]),
      builder: (context, _) {
        final tFold = _foldCtrl.value;
        final tEnv = _envelopeCtrl.value;

        // Mektup zarfa girme hızı (0.0 - 0.4) -> Hızlı ve zarif süzülüş
        final fSlide = Curves.fastOutSlowIn.transform((tEnv / 0.45).clamp(0.0, 1.0));
        // Kapak kapanma hızı (0.50 - 1.0) -> Yumuşak kapanış
        final fFlap = Curves.fastOutSlowIn.transform(((tEnv - 0.50) / 0.50).clamp(0.0, 1.0));

        // Kağıt yukarı doğru hareket ederken hedefine ulaşır: Zarfa gireceği sınır `envH`
        // Katlama bittiğinde bottom = 20.0 + envH + 2 (Tam cebin üstünde)
        final paperBottom = 20.0 + (envH + 2.0) * tFold - (envH * 0.8) * fSlide;
        // Zarfın içinde kaybolma efekti için opacity
        final paperOpacity = fSlide > 0.85 ? (1.0 - ((fSlide - 0.85) / 0.15)).clamp(0.0, 1.0) : 1.0;

        final isPaperInFront = tEnv == 0.0; // Zarf kapanma başlayınca arkaya geçer

        final envelopeBack = Container(
          width: envW,
          height: envH,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF8D6E63), Color(0xFF4E342E)],
            ),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 10))],
          ),
        );

        final envelopeFlapOpen = Opacity(
          opacity: 1.0 - fFlap,
          child: Transform.flip(
            flipY: true,
            child: ClipPath(
              clipper: _EnvelopeFlapClipper(),
              child: Container(
                width: envW,
                height: flapH,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xFF6D4C41), Color(0xFF5D4037)],
                  ),
                ),
              ),
            ),
          ),
        );

        final envelopeFrontPocket = Container(
          width: envW,
          height: envH,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFEFEBE9), Color(0xFFD7CCC8)],
            ),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
          ),
        );

        final envelopeFlapClosed = fFlap > 0
            ? Transform(
                alignment: Alignment.topCenter,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.003) // Kapak kapanırken daha da belirgin 3D derinlik
                  ..rotateX(math.pi * (1.0 - fFlap)),
                child: ClipPath(
                  clipper: _EnvelopeFlapClipper(),
                  child: Container(
                    width: envW,
                    height: flapH,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: fFlap > 0.5
                            ? const [Color(0xFFFAFAFA), Color(0xFFEFEBE9)]
                            : const [Color(0xFF6D4C41), Color(0xFF5D4037)],
                      ),
                      boxShadow: fFlap > 0.3
                          ? [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 4))]
                          : null,
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink();

        // Zarfa ekstra uçma/süzülme (hover) efekti
        // Hızlandırılmış animasyonda aşırı titreme olmaması için dalga frekansını çok düşürdük
        // ("yavaşça süzülüş / yelpazelenme" hissini geri getirmek için)
        final floatY = math.sin((tFold + tEnv) * math.pi * 1.2) * 12.0; // Çok yavaş ve yumuşak yukarı-aşağı salınım
        final floatRot = math.sin((tFold + tEnv) * math.pi * 0.8) * 0.035; // Çok daha yavaş bir hafif yalpama (rotation)

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(0.0, floatY) // Ekranda yukarı aşağı gitme
            ..rotateZ(floatRot), // Sağ-sol hafif süzülme gibi yatma
          child: SizedBox(
            width: paperW,
            height: envH + flapH + 40, // Merkezlemeyi düzgün yapabilmesi için yüksekliği zarfa göre kıstık
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                // ARKA ZARF VE AÇIK KAPAK
                Positioned(
                  bottom: 20,
                  child: SizedBox(
                    width: envW,
                    height: envH + flapH,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(bottom: 0, left: 0, right: 0, child: envelopeBack),
                        Positioned(top: 0, left: 0, right: 0, child: envelopeFlapOpen),
                      ],
                    ),
                  ),
                ),

                // ÖN CEP (KAĞIT ÖNDEYSE BURADA CİZİLİR)
                if (isPaperInFront)
                  Positioned(
                    bottom: 20,
                    child: envelopeFrontPocket,
                  ),

                // KATLANAN KAĞIT
                Positioned(
                  bottom: paperBottom,
                  child: Opacity(
                    opacity: paperOpacity,
                    child: SizedBox(
                      width: paperW,
                      height: paperH,
                      child: Center(
                        child: _buildFoldingPaper(paperW, paperH),
                      ),
                    ),
                  ),
                ),

                // ÖN CEP (KAĞIT ZARFA GİRERKEN ÖNE GEÇER)
                if (!isPaperInFront)
                  Positioned(
                    bottom: 20,
                    child: envelopeFrontPocket,
                  ),

                // KAPANAN KAPAK
                if (fFlap > 0)
                  Positioned(
                    bottom: 20 + envH - flapH,
                    child: envelopeFlapClosed,
                  ),
              ],
            ),
          ),
        );
      },
    );
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
        final t = _pullAnim.value;
        // Baykuş butonunun tam merkezine doğru uç
        final owlCenter = widget.owlButtonRect.center;
        
        final blockCenterX = screenWidth / 2;
        final blockCenterY = screenHeight / 2;
        
        final paperW = screenWidth * 0.85;
        final envW = paperW * 0.58;
        final envH = envW * 0.58;
        final flapH = envH * 0.78;
        final childHeight = envH + flapH + 40;
        final parentHeight = screenHeight * 0.55;
        
        // Mektubun görsel olarak başladığı yer: Alignment(0, -0.25) sebebiyle parent merkezinden biraz yukarıdadır
        final offset = 0.125 * (parentHeight - childHeight);
        
        // Zarf animasyonu bittiğinde üzerindeki süzülme efekti (floatY) yaklaşık 11.4 piksel aşağı itmiş durumdadır:
        final floatY = math.sin(2.4 * math.pi) * 12.0; 
        
        // Son anında %20 boyutuna inecek
        final targetScaleAtT1 = 0.20; 
        final scale = 1.0 - t * (1.0 - targetScaleAtT1); 
        
        // Scale ve ekstra offset'ler hesaba katılarak mektubun tam hedefin merkezine girmesini sağlayan matematik:
        final dx = t * (owlCenter.dx - blockCenterX);
        final dy = t * (owlCenter.dy - blockCenterY + (offset - floatY) * targetScaleAtT1);
        
        final rotation = t * 0.12;
        // Zarfın butonla temas etmesine daha çok (son %8'lik, 0.92) varken şeffaflaşıp kaybolmasını sağla
        // Bu sayede hedef butona gerçekten değdiği görünür ve sadece işin son anında yumuşakça yok olur.
        final opacity = t > 0.92 ? (1.0 - ((t - 0.92) / 0.08)).clamp(0.0, 1.0) : 1.0;

        final mainDialog = Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 24),
          child: Transform.translate(
            offset: Offset(dx, dy),
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.center,
              child: Transform.rotate(
                angle: rotation,
                alignment: Alignment.center,
                child: Opacity(
                  opacity: opacity,
                  child: SizedBox(
                    width: screenWidth * 0.85,
        child: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isFolding || _isEnveloping) ...[
              SizedBox(
                key: _paperKey,
                width: double.infinity,
                height: screenHeight * 0.55, // Biraz daha geniş ve ortalanmış hissettirsin
                child: Container(
                  alignment: const Alignment(0, -0.25), // Tam ortadan hafif yukarı hizalayarak mektubun daha güzel gözükmesini sağla
                  child: _buildUnifiedAnimation(screenWidth * 0.85, 176),
                ),
              ),
            ] else ...[
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
                            // İçerik — sadece göndermiyorken
                            if (!_isSending)
                              Positioned.fill(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                                child: GestureDetector(
                                  onTap: () => _textFocusNode.requestFocus(),
                                  behavior: HitTestBehavior.opaque,
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
                                    // Yazı + Çizim alanı — ikisi aynı anda
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          // Yazı alanı — ortadan başlar, yazdıkça yukarı çıkar
                                          Center(
                                            child: TextField(
                                              focusNode: _textFocusNode,
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
                                          // Çizim katmanı
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
                            ),
            // Kurabiye mühür — seçilmişse kağıdın sağ alt köşesinde
            if (_selectedCookieId != null && !_isSending)
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
            // Butonlar yan yana: sol Baykuşa Ver, sağ Kurabiye Ekle
            if (!_isSending) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Baykuşa Ver butonu (sol)
                  GestureDetector(
                    onTap: _hasText ? _send : null,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: _hasText
                                ? const Color(0xFFFF8A3D).withOpacity(0.15)
                                : Colors.white.withOpacity(0.04),
                            border: Border.all(
                              color: _hasText
                                  ? const Color(0xFFFF8A3D).withOpacity(0.35)
                                  : Colors.white.withOpacity(0.1),
                              width: 0.8,
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
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: _selectedCookieId != null
                                    ? selColor.withOpacity(0.15)
                                    : Colors.white.withOpacity(0.04),
                                border: Border.all(
                                  color: _selectedCookieId != null
                                      ? selColor.withOpacity(0.35)
                                      : Colors.white.withOpacity(0.15),
                                  width: 0.8,
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
                            ),
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
            ], // else (normal kağıt)
          ],
        ),
        ),
                  ),
                ),
              ),
            ),
          ),
        );

        if (t == 0.0) return mainDialog;

        // Uçuş anında, baykuş butonunda emilim/parlama efekti (glow and absorb) oluşur.
        // Zarf sadece hedefe çok yaklaştığında (t > 0.75) parlama ortaya çıkar,
        // temas gerçekleşirken kabarır ve tam temas anında (t = 1.0) kaybolur.
        final effectT = t > 0.75 ? (t - 0.75) / 0.25 : 0.0;
        final glowOpacity = math.sin(effectT * math.pi); // Sine curve 0 -> 1 -> 0
        final btnOpacity = (math.sin(effectT * math.pi) * 1.5).clamp(0.0, 1.0); 
        final btnScale = 1.0 + (glowOpacity * 0.15); // Zarf gelirken butonu biraz şişir

        final targetGlowEffect = Opacity(
          opacity: btnOpacity,
          child: Transform.scale(
            scale: btnScale,
            child: Container(
              width: widget.owlButtonRect.width,
              height: widget.owlButtonRect.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFD4B8A0), // Bej
                    Color(0xFF964040), // Kırmızı
                    Color(0xFF2A4A6C), // Mavi
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.45 + (0.55 * glowOpacity)),
                  width: 1.0 + (1.5 * glowOpacity),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF964040).withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                  if (glowOpacity > 0.05)
                    BoxShadow(
                      color: const Color(0xFFFFAB00).withOpacity(0.7 * glowOpacity),
                      blurRadius: 20 * glowOpacity,
                      spreadRadius: 4 * glowOpacity,
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Positioned(
                      left: 6,
                      right: 6,
                      top: 6,
                      height: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withOpacity(0.4),
                              Colors.white.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Center(child: Image.asset('assets/images/owl.webp', width: 52, height: 52, fit: BoxFit.contain)),
                    if (glowOpacity > 0.05)
                      Container(
                        color: Colors.white.withOpacity(0.2 * glowOpacity),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );

        return Material(
          type: MaterialType.transparency,
          child: SizedBox.expand(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(child: mainDialog),
                Positioned(
                  left: widget.owlButtonRect.left,
                  top: widget.owlButtonRect.top,
                  child: IgnorePointer(
                    child: targetGlowEffect,
                  ),
                ),
              ],
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

// ==== ZARF KAPAK KESİM SINIFI ====
class _EnvelopeFlapClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const double r = 8.0;

    path.moveTo(r, 0);
    path.lineTo(size.width - r, 0);
    path.quadraticBezierTo(size.width, 0, size.width, r);
    path.lineTo(size.width * 0.58, size.height * 0.82);
    path.quadraticBezierTo(
      size.width * 0.5, size.height,
      size.width * 0.42, size.height * 0.82,
    );
    path.lineTo(0, r);
    path.quadraticBezierTo(0, 0, r, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
