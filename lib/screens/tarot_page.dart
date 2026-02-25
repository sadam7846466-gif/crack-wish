// lib/screens/tarot_page.dart
import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

import 'tarot_meanings.dart';

enum RitualState {
  gateCheck,
  idle,
  shuffling,
  selecting,
  readyToReveal,
  revealing,
  revealed,
}

enum TarotTopic { general, love, money, career }

class TarotCardDef {
  final int id;
  final String nameTr;
  final String nameEn;
  final String frontAsset;
  TarotCardDef({
    required this.id,
    required this.nameTr,
    required this.nameEn,
    required this.frontAsset,
  });

  String nameFor(String languageCode) =>
      languageCode == 'tr' ? nameTr : nameEn;
}

class TarotPage extends StatefulWidget {
  const TarotPage({super.key});

  @override
  State<TarotPage> createState() => _TarotPageState();
}

class _TarotPageState extends State<TarotPage> with TickerProviderStateMixin {
  String _localeCode = 'en';
  bool get _isTr => _localeCode == 'tr';

  String _t(String tr, String en) => _isTr ? tr : en;

  String _cardName(int index) => _allCards[index].nameFor(_localeCode);
  // ======================
  // ASSET YOLLARI
  // ======================
  final String _cardBackAsset = 'assets/images/tarot/tarot/card_back.png';
  final List<TarotCardDef> _allCards = [
    TarotCardDef(
      id: 0,
      nameTr: 'Deli',
      nameEn: 'The Fool',
      frontAsset: 'assets/images/tarot/tarot/The_Fool.png',
    ),
    TarotCardDef(
      id: 1,
      nameTr: 'Büyücü',
      nameEn: 'The Magician',
      frontAsset: 'assets/images/tarot/tarot/The_Magician.png',
    ),
    TarotCardDef(
      id: 2,
      nameTr: 'Başrahibe',
      nameEn: 'The High Priestess',
      frontAsset: 'assets/images/tarot/tarot/The_High_Priestess.png',
    ),
    TarotCardDef(
      id: 3,
      nameTr: 'İmparatoriçe',
      nameEn: 'The Empress',
      frontAsset: 'assets/images/tarot/tarot/The_Empress.png',
    ),
    TarotCardDef(
      id: 4,
      nameTr: 'İmparator',
      nameEn: 'The Emperor',
      frontAsset: 'assets/images/tarot/tarot/The_Emperor.png',
    ),
    TarotCardDef(
      id: 5,
      nameTr: 'Aziz',
      nameEn: 'The Hierophant',
      frontAsset: 'assets/images/tarot/tarot/The_Hierophant.png',
    ),
    TarotCardDef(
      id: 6,
      nameTr: 'Aşıklar',
      nameEn: 'The Lovers',
      frontAsset: 'assets/images/tarot/tarot/The_Lovers.png',
    ),
    TarotCardDef(
      id: 7,
      nameTr: 'Savaş Arabası',
      nameEn: 'The Chariot',
      frontAsset: 'assets/images/tarot/tarot/The_Chariot.png',
    ),
    TarotCardDef(
      id: 8,
      nameTr: 'Güç',
      nameEn: 'Strength',
      frontAsset: 'assets/images/tarot/tarot/Strength.png',
    ),
    TarotCardDef(
      id: 9,
      nameTr: 'Ermiş',
      nameEn: 'The Hermit',
      frontAsset: 'assets/images/tarot/tarot/The_Hermit.png',
    ),
    TarotCardDef(
      id: 10,
      nameTr: 'Kader Çarkı',
      nameEn: 'Wheel of Fortune',
      frontAsset: 'assets/images/tarot/tarot/Wheel_of_Fortune.png',
    ),
    TarotCardDef(
      id: 11,
      nameTr: 'Adalet',
      nameEn: 'Justice',
      frontAsset: 'assets/images/tarot/tarot/Justice.png',
    ),
    TarotCardDef(
      id: 12,
      nameTr: 'Asılan Adam',
      nameEn: 'The Hanged Man',
      frontAsset: 'assets/images/tarot/tarot/The_Hanged_Man.png',
    ),
    TarotCardDef(
      id: 13,
      nameTr: 'Ölüm',
      nameEn: 'Death',
      frontAsset: 'assets/images/tarot/tarot/Death.png',
    ),
    TarotCardDef(
      id: 14,
      nameTr: 'Denge',
      nameEn: 'Temperance',
      frontAsset: 'assets/images/tarot/tarot/Temperance.png',
    ),
    TarotCardDef(
      id: 15,
      nameTr: 'Şeytan',
      nameEn: 'The Devil',
      frontAsset: 'assets/images/tarot/tarot/The_Devil.png',
    ),
    TarotCardDef(
      id: 16,
      nameTr: 'Kule',
      nameEn: 'The Tower',
      frontAsset: 'assets/images/tarot/tarot/The_Tower.png',
    ),
    TarotCardDef(
      id: 17,
      nameTr: 'Yıldız',
      nameEn: 'The Star',
      frontAsset: 'assets/images/tarot/tarot/The_Star.png',
    ),
    TarotCardDef(
      id: 18,
      nameTr: 'Ay',
      nameEn: 'The Moon',
      frontAsset: 'assets/images/tarot/tarot/The_Moon.png',
    ),
    TarotCardDef(
      id: 19,
      nameTr: 'Güneş',
      nameEn: 'The Sun',
      frontAsset: 'assets/images/tarot/tarot/The_Sun.png',
    ),
    TarotCardDef(
      id: 20,
      nameTr: 'Yargı',
      nameEn: 'Judgement',
      frontAsset: 'assets/images/tarot/tarot/Judgement.png',
    ),
    TarotCardDef(
      id: 21,
      nameTr: 'Dünya',
      nameEn: 'The World',
      frontAsset: 'assets/images/tarot/tarot/The_World.png',
    ),
  ];
  // ======================
  // Storage keys
  // ======================
  static const _kLastFreeDate = 'tarot_last_free_date_v1';
  static const _kAdCredits = 'tarot_ad_credits_v1';
  static const _kHistory = 'tarot_history_v1';
  static const _kStreak = 'tarot_streak_v1';
  static const _kLastReadDate = 'tarot_last_read_date_v1';
  static const _kFreezeUsedAt = 'tarot_freeze_used_at_v1';

  // ======================
  // State
  // ======================
  RitualState _state = RitualState.gateCheck;
  TarotTopic _topic = TarotTopic.general;

  final Random _rng = Random();
  late SharedPreferences _prefs;

  bool _dailyFreeUsed = false;
  int _adCredits = 0;
  int _streak = 1;
  bool _isBusy = false;

  // deck
  late List<int> _deckOrder;
  late List<int> _tableCards;
  int get _tableCount {
    if (_isBuyukArkana) return 22;
    if (_selectedCategory == null) return 0;
    return _selectedCategory == 0 ? 22 : 14;
  }
  int? _selectedCategory; // null = show categories, 0=Major, 1=Cups, 2=Wands, 3=Swords, 4=Pentacles

  // selection
  final List<int> _selectedTablePositions = [];
  final List<GlobalKey> _cardKeys = List<GlobalKey>.generate(
    78,
    (_) => GlobalKey(),
  );
  final List<GlobalKey> _slotKeys = List<GlobalKey>.generate(
    5,
    (_) => GlobalKey(),
  );
  int get _maxSlots => _isBuyukArkana ? 3 : 5;
  int _deckRebuildKey = 0;
  bool _btnStayVisible = false;
  int _reservedSlotCount = 0; // slots reserved but animation not done yet
  final AudioPlayer _cardFlipPlayer = AudioPlayer();
  final Set<int> _hiddenCards = {};
  late final List<AnimationController> _slotGlowControllers;

  // reveal
  int _revealedCount = 0;
  late List<int> _selectedCardIndexes;
  TarotReading? _latestReading;

  // share
  final GlobalKey _shareKey = GlobalKey();

  // Draggable image positions (for development)
  // Fixed positions for ip images
  static const double _ip1Top = 104.36;
  static const double _ip1Left = 55.02;
  static const double _ip2Top = 70.73;
  static const double _ip2Left = 82.76;
  static const double _ip3Top = 94.37;
  static const double _ip3Left = 122.98;
  static const double _ip4Top = 89.01;
  static const double _ip4Left = 264.97;
  static const double _ip5Top = 53.20;
  static const double _ip5Left = 155.63;
  static const double _ip6Top = 96.39;
  static const double _ip6Left = 187.97;
  static const double _ip7Top = 72.96;
  static const double _ip7Left = 294.08;
  static const double _ip8Top = 70.85;
  static const double _ip8Left = 228.19;

  // Animations
  late AnimationController _shuffleCtrl;
  late AnimationController _ctaScrambleCtrl;
  late AnimationController _starsCtrl;
  late AnimationController _fogCtrl;
  late AnimationController _bgPulseCtrl;
  late AnimationController _slotEntranceCtrl;

  String _ctaText = '';
  String _miniStatusText = '';
  Timer? _miniStatusTimer;

  // Navigation
  int _currentNavIndex = 0;

  // Deck selection
  bool _isBuyukArkana = true;

  // ======================
  // Init / Dispose
  // ======================
  @override
  void initState() {
    super.initState();
    _ctaText = 'Shuffle';

    _deckOrder = List<int>.generate(_allCards.length, (i) => i);
    _tableCards = [];
    _selectedCardIndexes = [];

    _shuffleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _ctaScrambleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _starsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 48),
    )..repeat();
    _slotGlowControllers = List.generate(5, (_) => AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      value: 1.0, // Start completed = no glow
    ));
    _fogCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    _bgPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);

    _slotEntranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600), // Yuvaların gelme süresini uzattık (daha soft)
    );

    _bootstrap();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final code = Localizations.localeOf(context).languageCode;
    if (_localeCode == code) return;
    _localeCode = code;
    _updateCtaText();
  }

  @override
  void dispose() {
    _miniStatusTimer?.cancel();
    _shuffleCtrl.dispose();
    _ctaScrambleCtrl.dispose();
    _starsCtrl.dispose();
    _fogCtrl.dispose();
    _bgPulseCtrl.dispose();
    _slotEntranceCtrl.dispose();
    for (final c in _slotGlowControllers) c.dispose();
    _cardFlipPlayer.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    _prefs = await SharedPreferences.getInstance();
    _loadGateAndStreak();
    _setStateSafe(() => _state = RitualState.idle);
    _updateCtaText();

    // Kısa bekleme - sayfa geçişi
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    // Deck'i hemen karıştır ve hazırla (animasyon beklemeden)
    _deckOrder.shuffle(_rng);
    final count = min(_tableCount, _deckOrder.length);
    _tableCards = _deckOrder.take(count).toList();

    _slotEntranceCtrl.forward(from: 0.0);

    // Kısa bekle sonra kartları göster
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    // Doğrudan selecting durumuna geç - buton hemen çalışsın
    _setStateSafe(() => _state = RitualState.selecting);
    _updateCtaText();
  }

  void _loadGateAndStreak() {
    final today = _yyyyMmDd(DateTime.now());
    final lastFree = _prefs.getString(_kLastFreeDate);
    _dailyFreeUsed = (lastFree == today);
    _adCredits = _prefs.getInt(_kAdCredits) ?? 0;
    _streak = _prefs.getInt(_kStreak) ?? 1;
  }

  // ======================
  // Helpers
  // ======================
  String _yyyyMmDd(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  void _setStateSafe(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  void _setMiniStatus(String text, {int ms = 600}) {
    _miniStatusTimer?.cancel();
    _setStateSafe(() => _miniStatusText = text);
    _miniStatusTimer = Timer(Duration(milliseconds: ms), () {
      if (!mounted) return;
      setState(() => _miniStatusText = '');
    });
  }

  Future<void> _scrambleTo(String target) async {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final start = _ctaText;
    if (start == target) return;

    _ctaScrambleCtrl.reset();
    _ctaScrambleCtrl.forward();

    const frames = 10;
    for (int i = 0; i < frames; i++) {
      await Future.delayed(const Duration(milliseconds: 35));
      final t = (i + 1) / frames;
      final out = List.generate(target.length, (idx) {
        final keep = _rng.nextDouble() < t;
        if (keep) return target[idx];
        return chars[_rng.nextInt(chars.length)];
      }).join();
      if (!mounted) return;
      setState(() => _ctaText = out);
    }
    if (!mounted) return;
    setState(() => _ctaText = target);
  }

  void _updateCtaText() {
    String next;
    switch (_state) {
      case RitualState.idle:
        next = _t('Kartları Karıştır', 'Shuffle Cards');
        break;
      case RitualState.shuffling:
        next = _t('Karıştırılıyor…', 'Shuffling…');
        break;
      case RitualState.selecting:
        next = _t(
          'Kart Seç (${_selectedTablePositions.length}/3)',
          'Select Cards (${_selectedTablePositions.length}/3)',
        );
        break;
      case RitualState.readyToReveal:
        next = _t('Kartları Aç', 'Reveal Cards');
        break;
      case RitualState.revealing:
        next = _t('Açılıyor…', 'Revealing…');
        break;
      case RitualState.revealed:
        next = _t('Yorumu Gör', 'View Reading');
        break;
      case RitualState.gateCheck:
        next = _t('Karıştır', 'Shuffle');
        break;
    }
    _scrambleTo(next);
  }

  // ======================
  // Gate: daily free + rewarded ad
  // ======================
  Future<bool> _ensureAllowance() async {
    if (kDebugMode) return true;
    if (!_dailyFreeUsed) return true;
    if (_adCredits > 0) return true;

    return false;
  }

  Future<void> _consumeAllowanceOnCommit() async {
    final today = _yyyyMmDd(DateTime.now());

    if (!_dailyFreeUsed) {
      _dailyFreeUsed = true;
      await _prefs.setString(_kLastFreeDate, today);
      return;
    }

    if (_adCredits > 0) {
      _adCredits -= 1;
      await _prefs.setInt(_kAdCredits, _adCredits);
    }
  }

  // ======================
  // Streak
  // ======================
  Future<void> _updateStreakOnCompleteRead() async {
    final now = DateTime.now();
    final today = _yyyyMmDd(now);
    final last = _prefs.getString(_kLastReadDate);

    if (last == today) return;

    int gapDays = 999;
    if (last != null) {
      final lastDt = DateTime.tryParse(last);
      if (lastDt != null) {
        final diff = DateTime(
          now.year,
          now.month,
          now.day,
        ).difference(DateTime(lastDt.year, lastDt.month, lastDt.day));
        gapDays = diff.inDays;
      }
    } else {
      gapDays = 999;
    }

    final freezeUsedAt = _prefs.getInt(_kFreezeUsedAt) ?? 0;
    final canUseFreeze =
        freezeUsedAt == 0 ||
        DateTime.now().millisecondsSinceEpoch - freezeUsedAt >
            const Duration(days: 30).inMilliseconds;

    if (gapDays == 1) {
      _streak += 1;
    } else if (gapDays == 2 && canUseFreeze) {
      await _prefs.setInt(
        _kFreezeUsedAt,
        DateTime.now().millisecondsSinceEpoch,
      );
    } else {
      _streak = 1;
    }

    await _prefs.setInt(_kStreak, _streak);
    await _prefs.setString(_kLastReadDate, today);

    if (!mounted) return;
    setState(() {});
  }

  // ======================
  // Flow actions
  // ======================
  void _resetDeck() {
    if (!_isBuyukArkana && _selectedCategory == null) {
      // Tam Arkana mode, no category selected - show no cards
      _tableCards = [];
      _revealedCount = 0;
      _selectedCardIndexes = [];
      _updateCtaText();
      return;
    }
    
    List<int> cardPool;
    if (_isBuyukArkana) {
      cardPool = List<int>.generate(22, (i) => i);
    } else {
      final range = _categoryCardRange(_selectedCategory!);
      cardPool = List<int>.generate(range.$2 - range.$1, (i) => range.$1 + i);
    }
    cardPool.shuffle(_rng);
    _tableCards = cardPool;
    _deckOrder = List<int>.generate(_allCards.length, (i) => i)..shuffle(_rng);
    _revealedCount = 0;
    _selectedCardIndexes = [];
    _updateCtaText();
    // Re-play entrance animations
    _slotEntranceCtrl.forward(from: 0.0);
    _setStateSafe(() => _deckRebuildKey++);
  }

  /// Returns (startId, endId) for a category index
  (int, int) _categoryCardRange(int category) {
    switch (category) {
      case 0: return (0, 22);    // Major Arcana
      case 1: return (22, 36);   // Cups
      case 2: return (36, 50);   // Wands
      case 3: return (50, 64);   // Swords
      default: return (64, 78);  // Pentacles
    }
  }

  void _selectCategory(int category) {
    HapticFeedback.lightImpact();
    _setStateSafe(() {
      _selectedCategory = category;
      _hiddenCards.clear();
    });
    _resetDeck();
  }

  Future<void> _onShufflePressed() async {
    if (_isBusy) return;

    HapticFeedback.lightImpact();

    _setStateSafe(() {
      _isBusy = true;
      _state = RitualState.shuffling;
      _selectedTablePositions.clear();
      _revealedCount = 0;
      _selectedCardIndexes = [];
    });
    _updateCtaText();

    _setMiniStatus(_t('Karıştırılıyor…', 'Shuffling…'), ms: 700);

    _deckOrder.shuffle(_rng);

    final count = min(_tableCount, _deckOrder.length);
    _tableCards = _deckOrder.take(count).toList();

    _shuffleCtrl.reset();
    await _shuffleCtrl.forward();

    if (!mounted) return;
    _setStateSafe(() {
      _isBusy = false;
      _state = RitualState.selecting;
    });
    _setMiniStatus(_t('Karıştırıldı', 'Shuffled'), ms: 650);
    _updateCtaText();
  }

  /// 3 kart seçildi — yorum ekranını aç
  Future<void> _commitAndReveal() async {
    final allowed = await _ensureAllowance();
    if (!allowed) {
      _setMiniStatus(_t('Bugünlük hakkın bitti', 'Daily limit reached'), ms: 900);
      return;
    }
    await _consumeAllowanceOnCommit();

    HapticFeedback.mediumImpact();
    _setStateSafe(() {
      _isBusy = true;
      _selectedCardIndexes = _selectedTablePositions
          .map((pos) => _tableCards[pos])
          .toList();
    });

    // --- Saspans (Yorumlama / Bekleme) Hissi ---
    _setMiniStatus(_t('Kaderin fısıltısı dinleniyor...', 'Listening to whispers of fate...'), ms: 800);
    // 3. kartın yuvasına yerleşmesini görecek kadar (sadece 400ms) bekliyoruz
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    // -------------------------------------------

    // Yorumu üret
    final reading = generateReading(
      card1Id: _allCards[_selectedCardIndexes[0]].id,
      card2Id: _allCards[_selectedCardIndexes[1]].id,
      card3Id: _allCards[_selectedCardIndexes[2]].id,
      card1Name: _cardName(_selectedCardIndexes[0]),
      card2Name: _cardName(_selectedCardIndexes[1]),
      card3Name: _cardName(_selectedCardIndexes[2]),
      isTr: _isTr,
    );

    _setStateSafe(() {
      _isBusy = false;
      _state = RitualState.revealed;
      _latestReading = reading;
    });
    _updateCtaText();
    await _updateStreakOnCompleteRead();
    if (!mounted) return;
    
    // Yorum zaten RitualState.revealed ile fullscreen blur üstünde gösteriliyor
    // _openReadingSheet ayrı BottomSheet açıyor, o yüzden kullanmıyoruz
  }

  Widget _buildHeroCardView(int index, Color glowColor, double scale) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 100,
        height: 156,
        decoration: BoxDecoration(
          color: const Color(0xFF101428),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _buildCardFront(index),
        ),
      ),
    );
  }

  void _openReadingSheet(TarotReading reading) {
    final names = _selectedCardIndexes.map(_cardName).toList();
    final colors = [
      const Color(0xFF4AC8EA), // Past: Blue
      const Color(0xFFF09A59), // Present: Orange
      const Color(0xFFB35CDA), // Direction: Purple
    ];
    final labels = _isTr ? ['Geçmiş', 'Şimdi', 'Yön'] : ['Past', 'Present', 'Direction'];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.transparent,
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.90,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0C16).withOpacity(0.85),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    0, 24, 0, 40 + MediaQuery.of(ctx).padding.bottom,
                  ),
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(ctx),
                              child: Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                                ),
                                child: Icon(Icons.close, color: Colors.white.withOpacity(0.7), size: 18),
                              ),
                            ),
                            const Spacer(),
                            Text(
                               reading.flowLabel,
                               style: GoogleFonts.inter(
                                 color: const Color(0xFFE2C48E).withOpacity(0.9),
                                 fontSize: 13,
                                 fontWeight: FontWeight.w600,
                               ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Title
                      Text(
                        _t('Kaderin Fısıltısı', 'Whisper of Fate'),
                         style: GoogleFonts.unifrakturMaguntia(
                           color: Colors.white,
                           fontSize: 32,
                           letterSpacing: 1.2,
                         ),
                      ),
                      const SizedBox(height: 36),

                      // Hero Cards Graphic
                      SizedBox(
                        height: 180,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                             // Back cards fanned out
                             Row(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                  // Left Card (Past)
                                  Transform.translate(
                                     offset: const Offset(30, 20),
                                     child: Transform.rotate(
                                       angle: -0.25,
                                       child: _buildHeroCardView(_selectedCardIndexes[0], colors[0], 0.85),
                                     ),
                                  ),
                                  // Right Card (Direction)
                                  Transform.translate(
                                     offset: const Offset(-30, 20),
                                     child: Transform.rotate(
                                       angle: 0.25,
                                       child: _buildHeroCardView(_selectedCardIndexes[2], colors[2], 0.85),
                                     ),
                                  ),
                               ],
                             ),
                             // Present card in front
                             _buildHeroCardView(_selectedCardIndexes[1], colors[1], 1.0),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 48),

                      // General Theme Text
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Text(
                          reading.generalTheme,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cormorantGaramond(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // The 3 Blocks
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                             _ReadingBlock(
                               label: labels[0],
                               title: _t('Geçmiş Etkisi', 'Past Influence'),
                               cardName: names[0],
                               text: reading.pastInfluence,
                               cardIndex: _selectedCardIndexes[0],
                               glowColor: colors[0],
                               cardFront: _buildCardFront(_selectedCardIndexes[0]),
                             ),
                             _ReadingBlock(
                               label: labels[1],
                               title: _t('Şu An Enerjisi', 'Present Energy'),
                               cardName: names[1],
                               text: reading.presentEnergy,
                               cardIndex: _selectedCardIndexes[1],
                               glowColor: colors[1],
                               cardFront: _buildCardFront(_selectedCardIndexes[1]),
                             ),
                             _ReadingBlock(
                               label: labels[2],
                               title: _t('Yakın Yön', 'Direction'),
                               cardName: names[2],
                               text: reading.directionAdvice,
                               cardIndex: _selectedCardIndexes[2],
                               glowColor: colors[2],
                               cardFront: _buildCardFront(_selectedCardIndexes[2]),
                             ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),

                      // Closing
                      Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 24),
                         child: Container(
                           padding: const EdgeInsets.all(24),
                           decoration: BoxDecoration(
                             color: const Color(0xFFE2C48E).withOpacity(0.04),
                             borderRadius: BorderRadius.circular(24),
                             border: Border.all(color: const Color(0xFFE2C48E).withOpacity(0.15)),
                           ),
                           child: Text(
                             reading.closingMessage,
                             textAlign: TextAlign.center,
                             style: GoogleFonts.cormorantGaramond(
                               color: const Color(0xFFE2C48E),
                               fontSize: 16,
                               fontWeight: FontWeight.w600,
                               height: 1.5,
                             ),
                           ),
                         ),
                      ),
                      const SizedBox(height: 48),

                      // Shuffle Again Button
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                        },
                        child: Container(
                           padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                           decoration: BoxDecoration(
                             gradient: const LinearGradient(
                               colors: [Color(0xFFE2C48E), Color(0xFFC7A563)],
                             ),
                             borderRadius: BorderRadius.circular(100),
                             boxShadow: [
                               BoxShadow(
                                 color: const Color(0xFFE2C48E).withOpacity(0.25),
                                 blurRadius: 16,
                                 offset: const Offset(0, 6),
                               ),
                             ],
                           ),
                           child: Text(
                              _t('Yeniden Rastgele Çek', 'Shuffle Again'),
                              style: GoogleFonts.inter(
                                color: const Color(0xFF101428),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                           ),
                        ),
                      ),
                    ].animate(interval: 200.ms).fade(duration: 800.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ).then((_) {
      if (mounted && _state == RitualState.revealed) {
        _resetToIdle();
      }
    });
  }

  void _resetToIdle() {
    HapticFeedback.lightImpact();
    _setStateSafe(() {
      _state = RitualState.idle;
      _selectedTablePositions.clear();
      _hiddenCards.clear();
      _reservedSlotCount = 0;
      _revealedCount = 0;
      _selectedCardIndexes = [];
      _tableCards = [];
    });
    _updateCtaText();
  }

  void _playCardFlipSound() async {
    try {
      final player = AudioPlayer();
      player.setPlayerMode(PlayerMode.mediaPlayer);
      await player.play(AssetSource('sounds/kartsesi1.wav'));
      player.onPlayerComplete.listen((_) => player.dispose());
    } catch (e) {
      debugPrint('Sound error: $e');
    }
  }

  Future<void> _selectCard(int index, GlobalKey cardKey) async {
    if (_isBusy) return;
    final totalReserved = _selectedTablePositions.length + _reservedSlotCount;
    if (totalReserved >= _maxSlots) return;
    if (_selectedTablePositions.contains(index)) return;
    if (_hiddenCards.contains(index)) return;

    final slotIndex = totalReserved;
    _reservedSlotCount++;
    
    // Hide the card from deck immediately
    setState(() => _hiddenCards.add(index));
    
    // Play card flip sound (non-blocking)
    _playCardFlipSound();
    
    // Fire animation in background - don't block next selection
    _animateCardToSlot(cardKey, _slotKeys[slotIndex], index).then((_) {
      if (!mounted) return;
      _reservedSlotCount--;
      setState(() {
        _selectedTablePositions.add(index);
        _hiddenCards.remove(index);
      });
      _slotGlowControllers[slotIndex].forward(from: 0.0);
      
      if (_selectedTablePositions.length == _maxSlots) {
        _commitAndReveal();
      }
    });
  }

  Future<void> _animateCardToSlot(GlobalKey fromKey, GlobalKey toKey, int tablePosition) async {
    final overlay = Overlay.of(context);
    final fromBox = fromKey.currentContext?.findRenderObject() as RenderBox?;
    final toBox = toKey.currentContext?.findRenderObject() as RenderBox?;
    if (fromBox == null || toBox == null) return;

    final from = fromBox.localToGlobal(Offset.zero);
    final to = toBox.localToGlobal(Offset.zero);
    final fromSize = fromBox.size;
    final toSize = toBox.size;
    final cardIdx = _tableCards[tablePosition];
    final frontAsset = _safeFrontAsset(cardIdx);

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    final curve = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    );

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) {
        final t = curve.value;
        final dx = ui.lerpDouble(from.dx, to.dx, t) ?? from.dx;
        final dy = ui.lerpDouble(from.dy, to.dy, t) ?? from.dy;
        final lift = sin(t * pi) * -20 * (1.0 - t);
        final w = ui.lerpDouble(fromSize.width, toSize.width, t) ?? fromSize.width;
        final h = ui.lerpDouble(fromSize.height, toSize.height, t) ?? fromSize.height;
        final flip = t < 0.7 ? 0.0 : ((t - 0.7) / 0.3).clamp(0.0, 1.0);
        final showFront = flip >= 0.5;
        final flipAngle = flip < 0.5 ? flip * pi : (1.0 - flip) * pi;

        return Positioned(
          left: dx,
          top: dy + lift,
          child: IgnorePointer(
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(flipAngle),
              child: SizedBox(
                width: w,
                height: h,
                child: showFront
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: _buildCardFront(cardIdx),
                      )
                    : _tarotCard(),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);
    controller.addListener(() => entry.markNeedsBuild());
    await controller.forward();
    entry.remove();
    controller.dispose();
  }

  String _safeFrontAsset(int idx) {
    final a = _allCards[idx].frontAsset;
    return a.isNotEmpty ? a : _cardBackAsset;
  }

  // ── Card design data ──

  static const _suitSymbols = {'cups': 0, 'wands': 1, 'swords': 2, 'pentacles': 3};

  static List<Color> _cardGradient(int id) {
    if (id < 22) {
      // Major Arcana - soft purple
      return [const Color(0xFF4A3578), const Color(0xFF352660), const Color(0xFF261B4A)];
    }
    final suitIdx = (id - 22) ~/ 14;
    switch (suitIdx) {
      case 0: return [const Color(0xFF354A78), const Color(0xFF263560), const Color(0xFF1B264A)]; // Cups - soft blue
      case 1: return [const Color(0xFF785035), const Color(0xFF603A26), const Color(0xFF4A2D1B)]; // Wands - warm
      case 2: return [const Color(0xFF484858), const Color(0xFF363645), const Color(0xFF282835)]; // Swords - cool grey
      default: return [const Color(0xFF357848), const Color(0xFF266035), const Color(0xFF1B4A28)]; // Pentacles - sage
    }
  }

  static Color _cardAccent(int id) {
    if (id < 22) return const Color(0xFFD4AF37); // gold
    final suitIdx = (id - 22) ~/ 14;
    switch (suitIdx) {
      case 0: return const Color(0xFF6CA6D4); // blue
      case 1: return const Color(0xFFD4976C); // amber
      case 2: return const Color(0xFFA0A0B8); // silver
      default: return const Color(0xFF6CD49C); // green
    }
  }


  String _romanNumeral(int id) {
    if (id < 22) {
      const romans = ['0', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X',
        'XI', 'XII', 'XIII', 'XIV', 'XV', 'XVI', 'XVII', 'XVIII', 'XIX', 'XX', 'XXI'];
      return romans[id];
    }
    final cardInSuit = (id - 22) % 14;
    const ranks = ['A', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X', 'P', 'N', 'Q', 'K'];
    return ranks[cardInSuit];
  }

  Widget _buildCategorySelection() {
    final categories = [
      {
        'icon': '✦',
        'nameTr': 'Büyük Arkana',
        'nameEn': 'Major Arcana',
        'count': 22,
        'colors': [const Color(0xFF4A3578), const Color(0xFF261B4A)],
        'accent': const Color(0xFFD4AF37),
      },
      {
        'icon': '🏆',
        'nameTr': 'Kupalar',
        'nameEn': 'Cups',
        'count': 14,
        'colors': [const Color(0xFF354A78), const Color(0xFF1B264A)],
        'accent': const Color(0xFF6CA6D4),
      },
      {
        'icon': '🔥',
        'nameTr': 'Asalar',
        'nameEn': 'Wands',
        'count': 14,
        'colors': [const Color(0xFF785035), const Color(0xFF4A2D1B)],
        'accent': const Color(0xFFD4976C),
      },
      {
        'icon': '⚔️',
        'nameTr': 'Kılıçlar',
        'nameEn': 'Swords',
        'count': 14,
        'colors': [const Color(0xFF484858), const Color(0xFF282835)],
        'accent': const Color(0xFFA0A0B8),
      },
      {
        'icon': '⭐',
        'nameTr': 'Tılsımlar',
        'nameEn': 'Pentacles',
        'count': 14,
        'colors': [const Color(0xFF357848), const Color(0xFF1B4A28)],
        'accent': const Color(0xFF6CD49C),
      },
    ];

    Widget buildCatCard(int idx) {
      final cat = categories[idx];
      final accent = cat['accent'] as Color;
      final colors = cat['colors'] as List<Color>;
      return GestureDetector(
        onTap: () => _selectCategory(idx),
        child: AnimatedBuilder(
          animation: _bgPulseCtrl,
          builder: (_, __) {
            final pulse = sin(_bgPulseCtrl.value * pi * 2) * 0.5 + 0.5;
            return Container(
              width: 100,
              height: 130,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: colors,
                ),
                border: Border.all(
                  color: accent.withOpacity(0.25 + pulse * 0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.1 + pulse * 0.08),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Inner frame
                  Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: accent.withOpacity(0.15 + pulse * 0.1),
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                  // Icon
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        cat['icon'] as String,
                        style: TextStyle(
                          fontSize: 28,
                          shadows: [
                            Shadow(
                              color: accent.withOpacity(0.4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Name
                  Positioned(
                    bottom: 28,
                    left: 4,
                    right: 4,
                    child: Text(
                      _isTr ? cat['nameTr'] as String : cat['nameEn'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  // Count badge
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${cat['count']}',
                          style: TextStyle(
                            color: accent.withOpacity(0.8),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Corner dots
                  ...[
                    const Alignment(-0.8, -0.88),
                    const Alignment(0.8, -0.88),
                    const Alignment(-0.8, 0.88),
                    const Alignment(0.8, 0.88),
                  ].map((a) => Align(
                    alignment: a,
                    child: Container(
                      width: 2, height: 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withOpacity(0.3),
                      ),
                    ),
                  )),
                ],
              ),
            );
          },
        ),
      );
    }

    return SizedBox(
      height: 360,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _t('Bir Kategori Seç', 'Choose a Category'),
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          // Top row: 3 categories
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildCatCard(0),
              buildCatCard(1),
              buildCatCard(2),
            ],
          ),
          const SizedBox(height: 10),
          // Bottom row: 2 categories
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildCatCard(3),
              buildCatCard(4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardFront(int cardIdx) {
    final id = _allCards[cardIdx].id;
    final name = _cardName(cardIdx);
    final gradColors = _cardGradient(id);
    final accent = _cardAccent(id);
    final roman = _romanNumeral(id);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradColors,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Subtle radial glow ──
          Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accent.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // ── Inner golden frame ──
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: accent.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
            ),
          ),
          // ── Top glass highlight ──
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 25,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // ── Roman numeral at top ──
          Positioned(
            top: 8, left: 0, right: 0,
            child: Text(
              roman,
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorantGaramond(
                color: accent.withOpacity(0.7),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
          // ── Small ornament line under numeral ──
          Positioned(
            top: 22, left: 0, right: 0,
            child: Center(
              child: Container(
                width: 14,
                height: 0.5,
                color: accent.withOpacity(0.25),
              ),
            ),
          ),
          // ── Center symbol ──
          Center(
            child: SizedBox(
              width: 40,
              height: 40,
              child: CustomPaint(
                painter: _TarotSymbolPainter(id: id, color: accent),
              ),
            ),
          ),
          // ── Small ornament line above name ──
          LayoutBuilder(
            builder: (context, constraints) {
              final h = constraints.maxHeight;
              final fontSize = h * 0.048;
              return Stack(
                children: [
                  Positioned(
                    bottom: h * 0.16, left: 0, right: 0,
                    child: Center(
                      child: Container(
                        width: 14,
                        height: 0.5,
                        color: accent.withOpacity(0.25),
                      ),
                    ),
                  ),
                  // ── Card name at bottom ──
                  Align(
                    alignment: const Alignment(0.0, 0.88),
                    child: FractionallySizedBox(
                      widthFactor: 0.88,
                      child: Text(
                        name.toUpperCase(),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cormorantGaramond(
                          color: accent.withOpacity(0.85),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          height: 1.0,
                          fontSize: fontSize,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          // ── Corner dots ──
          Positioned(top: 7, left: 7, child: _accentDot(accent)),
          Positioned(top: 7, right: 7, child: _accentDot(accent)),
          Positioned(bottom: 7, left: 7, child: _accentDot(accent)),
          Positioned(bottom: 7, right: 7, child: _accentDot(accent)),
          // ── Second inner frame (double border) ──
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1),
                border: Border.all(
                  color: accent.withOpacity(0.12),
                  width: 0.3,
                ),
              ),
            ),
          ),
          // ── Corner flourish arcs ──
          Positioned(
            top: 4, left: 4,
            child: CustomPaint(size: const Size(14, 14), painter: _CornerArcPainter(accent, 0)),
          ),
          Positioned(
            top: 4, right: 4,
            child: CustomPaint(size: const Size(14, 14), painter: _CornerArcPainter(accent, 1)),
          ),
          Positioned(
            bottom: 4, left: 4,
            child: CustomPaint(size: const Size(14, 14), painter: _CornerArcPainter(accent, 2)),
          ),
          Positioned(
            bottom: 4, right: 4,
            child: CustomPaint(size: const Size(14, 14), painter: _CornerArcPainter(accent, 3)),
          ),
          // ── Side dots (midpoints) ──
          Positioned(top: 0, bottom: 0, left: 5, child: Center(child: _accentDot(accent))),
          Positioned(top: 0, bottom: 0, right: 5, child: Center(child: _accentDot(accent))),
          // ── Diamond above name ──
          Positioned(
            bottom: 26, left: 0, right: 0,
            child: Center(
              child: Transform.rotate(
                angle: pi / 4,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _accentDot(Color accent) => Container(
    width: 2,
    height: 2,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: accent.withOpacity(0.4),
    ),
  );

  // ======================
  // UI
  // ======================
  Widget _buildIp(int num, double top, double left, {double height = 150}) {
    // Different phase and speed for each ip (speed must be integer for seamless loop)
    final phase = num * 0.9;
    final speed = 1 + (num % 3); // 1, 2, or 3 - integer for seamless continuity
    final amplitude = 0.028 + (num % 4) * 0.01;

    return Positioned(
      top: top,
      left: left,
      child: AnimatedBuilder(
        animation: _starsCtrl,
        builder: (context, child) {
          final angle =
              sin(_starsCtrl.value * 2 * pi * speed + phase) * amplitude;
          return Transform.rotate(
            angle: angle,
            alignment: Alignment.topCenter,
            child: child,
          );
        },
        child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.center,
              colors: [Colors.transparent, Colors.white],
              stops: [0.0, 0.6],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: Image.asset(
            'assets/images/tarot/ip$num.png',
            height: height,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _tarotCard() {
    return Container(
      width: 88,
      height: 138,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: const Color(0xFF6C3FA0).withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
        // Frosted glass gradient
        gradient: LinearGradient(
          begin: const Alignment(-0.3, -1.2),
          end: const Alignment(0.3, 1.2),
          colors: [
            Colors.white.withOpacity(0.14),
            Colors.white.withOpacity(0.06),
            Colors.white.withOpacity(0.02),
            Colors.white.withOpacity(0.08),
          ],
          stops: const [0.0, 0.3, 0.6, 1.0],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.18),
          width: 0.8,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Stack(
          children: [
            // ── Frosted base (simulated blur) ──
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF12102E).withOpacity(0.85),
                ),
              ),
            ),
            // ── Top glass highlight ──
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(5),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            // ── Inner frame ──
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 0.5,
                  ),
                ),
              ),
            ),
            // ── Center mystical star ──
            Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CustomPaint(
                  painter: _CardStarPainter(),
                ),
              ),
            ),
            // ── Top ornament line ──
            Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 14,
                  height: 0.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.25),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // ── Bottom ornament line ──
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 14,
                  height: 0.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.25),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // ── Corner dots ──
            Positioned(top: 10, left: 10, child: _cornerDot()),
            Positioned(top: 10, right: 10, child: _cornerDot()),
            Positioned(bottom: 10, left: 10, child: _cornerDot()),
            Positioned(bottom: 10, right: 10, child: _cornerDot()),
            // ── Bottom glass reflection ──
            Positioned(
              bottom: 4,
              left: 12,
              right: 12,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cornerDot() {
    return Container(
      width: 2.5,
      height: 2.5,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.20),
      ),
    );
  }

  Widget _emptySlot() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          width: 88,
          height: 138,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Center(
            child: Icon(
              Icons.add_rounded,
              size: 22,
              color: Colors.white.withOpacity(0.20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectedCardView() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          width: 88,
          height: 138,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: Center(
            child: Icon(
              Icons.auto_awesome,
              size: 18,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassPanel({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white12),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF0E0E2A),
      body: AnimatedBuilder(
        animation: Listenable.merge([_bgPulseCtrl, _fogCtrl]),
        builder: (context, _) {
          final bv = _bgPulseCtrl.value; // 0‥1 ping‑pong
          final rv = _fogCtrl.value; // 0‥1 continuous rotation
          final screenW = MediaQuery.of(context).size.width;
          final screenH = MediaQuery.of(context).size.height;
          return Stack(
        children: [
          // ── Temel mor gradient (diagonal) ──
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0E0E2A),  // Koyu gece
                    Color(0xFF1E1845),  // Derin mor-mavi
                    Color(0xFF2A2050),  // Orta mor
                    Color(0xFF141238),  // Koyu mor
                  ],
                  stops: [0.0, 0.35, 0.65, 1.0],
                ),
              ),
            ),
          ),


          // ── Statik dairesel renk geçişi (ana sayfa stili) ──
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                size: Size.infinite,
                painter: _TarotMottledPainter(),
              ),
            ),
          ),

          // ── Üst yoğun toz/duman bulutu 1 ──
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.15 + sin(bv * pi * 2) * 0.15, -0.55 + cos(bv * pi * 2) * 0.10),
                    radius: 0.6,
                    colors: [
                      Color.fromRGBO((150 + sin(bv * pi * 2) * 40).round().clamp(0,255), (64 + cos(bv * pi * 2) * 30).round().clamp(0,255), (100 + sin(bv * pi * 2 + 1) * 35).round().clamp(0,255), 0.45 + sin(bv * pi * 2) * 0.10),
                      Color.fromRGBO((120 + sin(bv * pi * 2) * 30).round().clamp(0,255), (50 + cos(bv * pi * 2) * 20).round().clamp(0,255), 90, 0.25 + sin(bv * pi * 2) * 0.05),
                      Color.fromRGBO(90, 40, 75, 0.10),
                      const Color.fromRGBO(90, 40, 75, 0.0),
                    ],
                    stops: const [0.0, 0.25, 0.50, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // ── Üst yoğun toz/duman bulutu 2 (biraz sola kaymış) ──
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.30 + sin(bv * pi * 2 + 1.5) * 0.12, -0.40 + cos(bv * pi * 2 + 1.5) * 0.08),
                    radius: 0.55,
                    colors: [
                      Color.fromRGBO((180 + cos(bv * pi * 2) * 30).round().clamp(0,255), (160 + sin(bv * pi * 2 + 2) * 40).round().clamp(0,255), (210 + cos(bv * pi * 2 + 1) * 25).round().clamp(0,255), 0.28 + sin(bv * pi * 2 + 1.5) * 0.08),
                      Color.fromRGBO(160, (140 + sin(bv * pi * 2) * 25).round().clamp(0,255), 190, 0.14 + sin(bv * pi * 2 + 1.5) * 0.04),
                      const Color.fromRGBO(140, 120, 170, 0.0),
                    ],
                    stops: const [0.0, 0.35, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // ── Ana merkez toz bulutu (büyük pembe/magenta nebula) ──
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.05 + sin(bv * pi * 2 + 0.8) * 0.12, 0.05 + cos(bv * pi * 2 + 0.8) * 0.10),
                    radius: 0.75,
                    colors: [
                      Color.fromRGBO((120 + cos(bv * pi * 2 + 0.5) * 35).round().clamp(0,255), (55 + sin(bv * pi * 2 + 1.5) * 30).round().clamp(0,255), (110 + cos(bv * pi * 2) * 40).round().clamp(0,255), 0.48 + sin(bv * pi * 2 + 0.8) * 0.08),
                      Color.fromRGBO(100, (45 + cos(bv * pi * 2) * 20).round().clamp(0,255), (95 + sin(bv * pi * 2 + 2) * 30).round().clamp(0,255), 0.28 + sin(bv * pi * 2 + 0.8) * 0.06),
                      Color.fromRGBO(75, 35, 80, 0.12 + sin(bv * pi * 2 + 0.8) * 0.03),
                      const Color.fromRGBO(75, 35, 80, 0.0),
                    ],
                    stops: const [0.0, 0.3, 0.55, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // ── İkinci toz bulutu (alt-sol, derinlik için) ──
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.25 + sin(bv * pi * 2 + 2.5) * 0.15, 0.35 + cos(bv * pi * 2 + 2.5) * 0.10),
                    radius: 0.65,
                    colors: [
                      Color.fromRGBO((42 + sin(bv * pi * 2 + 1) * 25).round().clamp(0,255), (55 + cos(bv * pi * 2) * 30).round().clamp(0,255), (108 + sin(bv * pi * 2 + 2) * 35).round().clamp(0,255), 0.40 + sin(bv * pi * 2 + 2.5) * 0.08),
                      Color.fromRGBO(38, 48, 95, 0.18 + sin(bv * pi * 2 + 2.5) * 0.03),
                      const Color.fromRGBO(38, 48, 95, 0.0),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // ── Üst-sağ lila parıltı (köşe derinliği) ──
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.7 + sin(bv * pi * 2 + 3.8) * 0.10, -0.6 + cos(bv * pi * 2 + 3.8) * 0.08),
                    radius: 0.55,
                    colors: [
                      Color.fromRGBO((85 + cos(bv * pi * 2 + 2) * 30).round().clamp(0,255), (55 + sin(bv * pi * 2) * 25).round().clamp(0,255), (140 + cos(bv * pi * 2 + 1) * 30).round().clamp(0,255), 0.22 + sin(bv * pi * 2 + 3.8) * 0.06),
                      Color.fromRGBO(85, 55, 140, 0.06),
                      const Color.fromRGBO(85, 55, 140, 0.0),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // ── Alt-sol koyu mor derinlik ──
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.7 + sin(bv * pi * 2 + 5.0) * 0.12, 0.8 + cos(bv * pi * 2 + 5.0) * 0.08),
                    radius: 0.5,
                    colors: [
                      Color.fromRGBO((26 + sin(bv * pi * 2) * 15).round().clamp(0,255), (20 + cos(bv * pi * 2 + 1) * 10).round().clamp(0,255), (64 + sin(bv * pi * 2 + 2) * 20).round().clamp(0,255), 0.50),
                      const Color(0xFF1A1440).withOpacity(0.18),
                      const Color(0xFF1A1440).withOpacity(0.0),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
          ),



          // ── Noise/grain overlay ──
          IgnorePointer(
            child: Opacity(
              opacity: 0.04,
              child: CustomPaint(
                size: Size.infinite,
                painter: _NoisePainter(),
              ),
            ),
          ),

          // ── ✨ Aurora + Stars ──
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _StarFieldPainter(pulse: bv),
              ),
            ),
          ),

          // ── 🔮 Bokeh Light Orbs ──
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _BokehPainter(pulse: bv),
              ),
            ),
          ),

          // ── ✨ Star Dust (tiny space particles) ──
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _StarDustPainter(pulse: bv),
              ),
            ),
          ),


          // ── 💫 Floating Light Particles ──
          ...List.generate(12, (i) {
            final seed = i * 137.5;
            final xPos = (sin(seed) * 0.5 + 0.5) * screenW;
            final baseY = (cos(seed * 0.7) * 0.5 + 0.5) * screenH;
            final floatY = sin(bv * pi * 2 + seed * 0.1) * 20;
            final floatX = cos(bv * pi * 2 * 0.7 + seed * 0.15) * 8;
            final opacity = (0.08 + sin(bv * pi * 2 + seed * 0.3) * 0.06).clamp(0.0, 1.0);
            final size = 2.0 + sin(seed * 2.3) * 1.5;
            return Positioned(
              left: xPos + floatX,
              top: baseY + floatY,
              child: IgnorePointer(
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB388FF).withOpacity(0.3),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),

          // ── ⭕ Sacred Geometry / Zodiac Wheel — Center ──
          Positioned(
            left: screenW * 0.5 - 140,
            top: screenH * 0.33,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.10 + sin(bv * pi * 2) * 0.02,
                child: Transform.rotate(
                  angle: rv * pi * 2 * 0.1,
                  child: SizedBox(
                    width: 280,
                    height: 280,
                    child: CustomPaint(
                      painter: _SacredGeometryPainter(),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── ⭕ Sacred Geometry — Top Left (smaller) ──
          Positioned(
            left: -40,
            top: screenH * 0.05,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.06 + sin(bv * pi * 2 + 1.5) * 0.02,
                child: Transform.rotate(
                  angle: -rv * pi * 2 * 0.08,
                  child: SizedBox(
                    width: 160,
                    height: 160,
                    child: CustomPaint(
                      painter: _SacredGeometryPainter(),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── ⭕ Sacred Geometry — Bottom Right ──
          Positioned(
            right: -30,
            bottom: screenH * 0.08,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.08 + sin(bv * pi * 2 + 3.0) * 0.02,
                child: Transform.rotate(
                  angle: rv * pi * 2 * 0.07,
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: CustomPaint(
                      painter: _SacredGeometryPainter(),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── ⭕ Sacred Geometry — Top Right (small) ──
          Positioned(
            right: 10,
            top: screenH * 0.15,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.05 + sin(bv * pi * 2 + 4.5) * 0.015,
                child: Transform.rotate(
                  angle: -rv * pi * 2 * 0.12,
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: CustomPaint(
                      painter: _SacredGeometryPainter(),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── ✨ Elegant Golden Border Frame (bottom fade-in) ──
          Positioned.fill(
            child: IgnorePointer(
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.white,
                  ],
                  stops: [0.0, 0.4, 0.75],
                ).createShader(bounds),
                blendMode: BlendMode.dstIn,
                child: Opacity(
                  opacity: 0.35 + sin(bv * pi * 2) * 0.05,
                  child: CustomPaint(
                    painter: _GoldenBorderPainter(),
                  ),
                ),
              ),
            ),
          ),


          SafeArea(
            child: Column(
              children: [
                // Header with back button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      // Back button – frosted glass iOS style
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.18),
                                  width: 0.6,
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white.withOpacity(0.85),
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ShaderMask(
                          shaderCallback: (bounds) {
                            final shimmerPos = sin(bv * pi * 2) * 1.0; // smooth -1 to 1
                            return LinearGradient(
                              begin: Alignment(shimmerPos - 0.3, 0),
                              end: Alignment(shimmerPos + 0.3, 0),
                              colors: [
                                Colors.white,
                                const Color(0xFFE7D6A5), // gold shimmer
                                Colors.white,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ).createShader(bounds);
                          },
                          child: const Text(
                            'Tarot',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      // Spacer to balance the back button
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _t('Kartlarını Seç', 'Pick Your Cards'),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 6),
                // ── Decorative diamond line ornament ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 0.8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        '◆',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 6,
                        ),
                      ),
                    ),
                    Container(
                      width: 24,
                      height: 0.8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Ana oyun içerikleri (Kart seçimi vb.)
                Expanded(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                    opacity: _state == RitualState.revealed ? 0.0 : 1.0,
                    child: IgnorePointer(
                      ignoring: _state == RitualState.revealed,
                      child: Column(
                        children: [
                          // ── Glow behind card slots ──
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 340,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(80),
                                  gradient: RadialGradient(
                                    colors: [
                                      Color.fromRGBO(180, 140, 220, 0.18 + sin(bv * pi * 2) * 0.04),
                                      Color.fromRGBO(226, 196, 142, 0.08 + sin(bv * pi * 2 + 1) * 0.02),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.45, 1.0],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromRGBO(180, 140, 220, 0.12 + sin(bv * pi * 2) * 0.03),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                height: 175,
                            child: AnimatedBuilder(
                              animation: Listenable.merge([_slotEntranceCtrl, _bgPulseCtrl, ..._slotGlowControllers]),
                              builder: (_, __) {
                                final slotLabels3 = [
                                  _t('Geçmiş', 'Past'),
                                  _t('Şimdi', 'Present'),
                                  _t('Gelecek', 'Future'),
                                ];
                                final slotLabels5 = [
                                  _t('Slot 1', 'Slot 1'),
                                  _t('Slot 2', 'Slot 2'),
                                  _t('Slot 3', 'Slot 3'),
                                  _t('Slot 4', 'Slot 4'),
                                  _t('Slot 5', 'Slot 5'),
                                ];
                                final slotLabels = _isBuyukArkana ? slotLabels3 : slotLabels5;
                                final slotSymbols3 = ['☽', '◉', '✦'];
                                final slotSymbols5 = ['☽', '◉', '✦', '⚝', '⊛'];
                                final symbols = _isBuyukArkana ? slotSymbols3 : slotSymbols5;
                                final cardW = _isBuyukArkana ? 88.0 : 52.0;
                                final cardH = _isBuyukArkana ? 138.0 : 68.0;
                                final topCount = _isBuyukArkana ? 3 : 3;
                                final bottomCount = _isBuyukArkana ? 0 : 2;

                                Widget buildSlot(int i) {
                                  final isFilled = _selectedTablePositions.length > i;
                                  final delay = i * 0.12;
                                  final duration = 0.6;
                                  final rawT = ((_slotEntranceCtrl.value - delay) / duration).clamp(0.0, 1.0);
                                  final scaleT = Curves.easeOutQuint.transform(rawT); 
                                  final fadeT = Curves.easeOutQuad.transform(rawT);
                                  final slideY = (1.0 - fadeT) * 12.0; 
  
                                  return Padding(
                                    padding: EdgeInsets.symmetric(horizontal: _isBuyukArkana ? 8 : 5),
                                    child: Transform.translate(
                                      offset: Offset(0, slideY),
                                      child: Transform.scale(
                                        scale: scaleT,
                                        child: Opacity(
                                          opacity: fadeT,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              isFilled ? 
                                                Builder(
                                                  builder: (context) {
                                                    final animGlow = 1.0 - _slotGlowControllers[i].value;
                                                    final totalGlow = (0.2 + animGlow * 0.8).clamp(0.0, 1.0);
                                                    return Container(
                                                      key: _slotKeys[i],
                                                      width: cardW,
                                                      height: cardH,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(4),
                                                        boxShadow: totalGlow > 0.05 ? [
                                                          BoxShadow(
                                                            color: const Color(0xFFE7D6A5).withOpacity(0.15 * totalGlow),
                                                            blurRadius: 6 * totalGlow,
                                                          ),
                                                        ] : null,
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(4),
                                                        child: _buildCardFront(_tableCards[_selectedTablePositions[i]]),
                                                      ),
                                                    );
                                                  }
                                                ) : 
                                                Builder(
                                                  builder: (context) {
                                                    final pulse = sin(_bgPulseCtrl.value * pi * 2) * 0.5 + 0.5;
                                                    return Container(
                                                      key: _slotKeys[i],
                                                      width: cardW,
                                                      height: cardH,
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFF1E1E45).withOpacity(0.35),
                                                        borderRadius: BorderRadius.circular(16),
                                                        border: Border.all(
                                                          color: Colors.white.withOpacity(0.08 + pulse * 0.10),
                                                          width: 0.8,
                                                        ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: const Color(0xFF6C3FA0).withOpacity(0.06 * pulse),
                                                            blurRadius: 12,
                                                            spreadRadius: 1,
                                                          ),
                                                        ],
                                                      ),
                                                      child: Stack(
                                                        children: [
                                                          Positioned.fill(
                                                            child: Container(
                                                              margin: const EdgeInsets.all(6),
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(10),
                                                                border: Border.all(
                                                                  color: Colors.white.withOpacity(0.08 + pulse * 0.08),
                                                                  width: 0.5,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Center(
                                                            child: Text(
                                                              symbols[i],
                                                              style: TextStyle(
                                                                fontSize: _isBuyukArkana ? 26 : 20,
                                                                color: Colors.white.withOpacity(0.15 + pulse * 0.15),
                                                                shadows: [
                                                                  Shadow(
                                                                    color: const Color(0xFFB388FF).withOpacity(0.3 * pulse),
                                                                    blurRadius: 8,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Positioned(
                                                            top: 10, left: 0, right: 0,
                                                            child: Center(
                                                              child: Container(
                                                                width: 20, height: 0.5,
                                                                color: Colors.white.withOpacity(0.12 + pulse * 0.10),
                                                              ),
                                                            ),
                                                          ),
                                                          Positioned(
                                                            bottom: 10, left: 0, right: 0,
                                                            child: Center(
                                                              child: Container(
                                                                width: 20, height: 0.5,
                                                                color: Colors.white.withOpacity(0.12 + pulse * 0.10),
                                                              ),
                                                            ),
                                                          ),
                                                          ...[
                                                            const Alignment(-0.75, -0.85),
                                                            const Alignment(0.75, -0.85),
                                                            const Alignment(-0.75, 0.85),
                                                            const Alignment(0.75, 0.85),
                                                          ].map((align) => Align(
                                                            alignment: align,
                                                            child: Container(
                                                              width: 2.5, height: 2.5,
                                                              decoration: BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                color: Colors.white.withOpacity(0.18 + pulse * 0.12),
                                                              ),
                                                            ),
                                                          )),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              const SizedBox(height: 6),
                                              Text(
                                                slotLabels[i],
                                                style: TextStyle(
                                                  color: isFilled 
                                                      ? Colors.white.withOpacity(0.7)
                                                      : Colors.white.withOpacity(0.35),
                                                  fontSize: _isBuyukArkana ? 11 : 9,
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(topCount, (i) => buildSlot(i)),
                                    ),
                                    if (bottomCount > 0) ...[
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: List.generate(bottomCount, (i) => buildSlot(topCount + i)),
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),
                          ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // ── Mystical glow behind deck ──
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 300,
                                height: 220,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Color.fromRGBO(160, 120, 220, 0.20 + sin(bv * pi * 2) * 0.05),
                                      Color.fromRGBO(226, 196, 142, 0.10 + sin(bv * pi * 2 + 1) * 0.03),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.4, 1.0],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromRGBO(160, 120, 220, 0.15 + sin(bv * pi * 2) * 0.04),
                                      blurRadius: 50,
                                      spreadRadius: 15,
                                    ),
                                  ],
                                ),
                              ),
                              // ── Card Fan or Category Selection ──
                              if (!_isBuyukArkana && _selectedCategory == null)
                                _buildCategorySelection()
                              else
                                _FloatingTarotDeck(
                                  key: ValueKey('deck_$_deckRebuildKey'),
                                  onCardTap: _selectCard,
                                  cardBuilder: _tarotCard,
                                  cardKeys: _cardKeys.sublist(0, _tableCount),
                                  selectedPositions: _selectedTablePositions,
                                  hiddenCards: _hiddenCards,
                                ),
                            ],
                          ),
                          // ── Guide text ──
                          Transform.translate(
                            offset: const Offset(0, -20),
                            child: AnimatedBuilder(
                            animation: _bgPulseCtrl,
                            builder: (_, __) {
                              final selected = _selectedTablePositions.length;
                              final max = _maxSlots;
                              return Opacity(
                                opacity: selected < max ? 0.5 : 0.0,
                                child: Text(
                                  selected == 0
                                      ? _t('Bir kart seç veya rastgele çek', 'Pick a card or shuffle')
                                      : _t('$selected / $max kart seçildi', '$selected / $max cards selected'),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              );
                            },
                          ),
                          ),
                          const SizedBox(height: 4),
                          // Büyük Arkana / Tam Arkana buttons - stay visible after first entrance
                          AnimatedBuilder(
                            animation: _slotEntranceCtrl,
                            builder: (context, child) {
                              final t = ((_slotEntranceCtrl.value - 0.4) / 0.6).clamp(0.0, 1.0);
                              final curved = Curves.easeOutCubic.transform(t);
                              final opacity = _btnStayVisible ? 1.0 : curved;
                              final offsetY = _btnStayVisible ? 0.0 : 20 * (1.0 - curved);
                              if (curved >= 0.99) _btnStayVisible = true;
                              return Opacity(
                                opacity: opacity,
                                child: Transform.translate(
                                  offset: Offset(0, offsetY),
                                  child: child,
                                ),
                              );
                            },
                            child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      _setStateSafe(() {
                                        _isBuyukArkana = true;
                                        _selectedTablePositions.clear();
                                        _reservedSlotCount = 0;
                                        _hiddenCards.clear();
                                        _state = RitualState.idle;
                                      });
                                      _resetDeck();
                                    },
                                    child: AnimatedScale(
                                      scale: _isBuyukArkana ? 1.0 : 0.97,
                                      duration: const Duration(milliseconds: 200),
                                      child: Container(
                                        height: 44,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          gradient: LinearGradient(
                                            begin: const Alignment(-0.5, -1.2),
                                            end: const Alignment(0.5, 1.2),
                                            colors: [
                                              Colors.white.withOpacity(_isBuyukArkana ? 0.18 : 0.10),
                                              Colors.white.withOpacity(0.06),
                                              Colors.white.withOpacity(0.02),
                                              Colors.white.withOpacity(_isBuyukArkana ? 0.10 : 0.06),
                                            ],
                                            stops: const [0.0, 0.35, 0.65, 1.0],
                                          ),
                                          border: Border.all(
                                            color: _isBuyukArkana
                                                ? const Color(0xFFE7D6A5).withOpacity(0.55)
                                                : Colors.white.withOpacity(0.14),
                                            width: _isBuyukArkana ? 1.2 : 0.8,
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            // Liquid highlight strip
                                            Positioned(
                                              top: 2,
                                              left: 16,
                                              right: 16,
                                              child: Container(
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8),
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.white.withOpacity(0.0),
                                                      Colors.white.withOpacity(_isBuyukArkana ? 0.14 : 0.08),
                                                      Colors.white.withOpacity(0.0),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Center(
                                              child: Text(
                                                'Büyük Arkana',
                                                style: TextStyle(
                                                  color: _isBuyukArkana
                                                      ? Colors.white
                                                      : Colors.white70,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      _setStateSafe(() {
                                        _isBuyukArkana = false;
                                        _selectedCategory = null;
                                        _selectedTablePositions.clear();
                                        _reservedSlotCount = 0;
                                        _hiddenCards.clear();
                                        _state = RitualState.idle;
                                      });
                                      _resetDeck();
                                    },
                                    child: AnimatedScale(
                                      scale: !_isBuyukArkana ? 1.0 : 0.97,
                                      duration: const Duration(milliseconds: 200),
                                      child: Container(
                                        height: 44,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          gradient: LinearGradient(
                                            begin: const Alignment(-0.5, -1.2),
                                            end: const Alignment(0.5, 1.2),
                                            colors: [
                                              Colors.white.withOpacity(!_isBuyukArkana ? 0.18 : 0.10),
                                              Colors.white.withOpacity(0.04),
                                              Colors.white.withOpacity(0.01),
                                              Colors.white.withOpacity(!_isBuyukArkana ? 0.10 : 0.06),
                                            ],
                                            stops: const [0.0, 0.35, 0.65, 1.0],
                                          ),
                                          border: Border.all(
                                            color: !_isBuyukArkana
                                                ? const Color(0xFFE7D6A5).withOpacity(0.55)
                                                : Colors.white.withOpacity(0.14),
                                            width: !_isBuyukArkana ? 1.2 : 0.8,
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            // Liquid highlight strip
                                            Positioned(
                                              top: 2,
                                              left: 16,
                                              right: 16,
                                              child: Container(
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8),
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.white.withOpacity(0.0),
                                                      Colors.white.withOpacity(!_isBuyukArkana ? 0.12 : 0.06),
                                                      Colors.white.withOpacity(0.0),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Center(
                                              child: Text(
                                                'Tam Arkana',
                                                style: TextStyle(
                                                  color: !_isBuyukArkana
                                                      ? Colors.white
                                                      : Colors.white70,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
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
                          ),
                          const SizedBox(height: 16),
                          // ── Bottom decorative wave lines with diamond ──
                          AnimatedBuilder(
                            animation: _slotEntranceCtrl,
                            builder: (context, child) {
                              final t = ((_slotEntranceCtrl.value - 0.5) / 0.5).clamp(0.0, 1.0);
                              final curved = Curves.easeOutCubic.transform(t);
                              return Opacity(opacity: curved, child: child);
                            },
                            child: SizedBox(
                              width: 200,
                              height: 28,
                              child: CustomPaint(
                                painter: _WaveDiamondPainter(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),


          // ── TAM EKRAN (FULLSCREEN) BLUR EFEKTİ ──
          if (_state == RitualState.revealed)
            Positioned.fill(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return BackdropFilter(
                    filter: ui.ImageFilter.blur(
                      sigmaX: 18 * value, 
                      sigmaY: 18 * value,
                    ),
                    child: Container(
                      color: Colors.black.withOpacity(0.55 * value),
                      // Tıklamaları engellememesi vs durumu:
                    ),
                  );
                },
              ),
            ),
         
          // ── TAM EKRAN (FULLSCREEN) YORUM İÇERİĞİ ──
          if (_state == RitualState.revealed && _latestReading != null)
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 32, // Çentiği(notch) güvenli alana katmak
                  bottom: MediaQuery.of(context).padding.bottom + 32,
                  left: 20,
                  right: 20,
                ),
                child: Column(
                    children: [
                      // Üst Bar: Kapat Butonu (Sadece kapat butonu kalacak)
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _resetToIdle,
                            child: Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withOpacity(0.15)),
                              ),
                              child: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.8), size: 22),
                            ),
                          ),
                          const Spacer(),
                          // Dönüşüm Akışı vb yazıyı sildik ("_latestReading!.flowLabel")
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // Ana Başlık
                      Text(
                        _t('Kaderin Fısıltısı', 'Whisper of Fate'),
                         style: GoogleFonts.cormorantGaramond(
                           color: Colors.white,
                           fontSize: 36, // Küçültüldü (Önceki 44 idi)
                           fontWeight: FontWeight.w700,
                           letterSpacing: 1.0,
                         ),
                      ),
                      const SizedBox(height: 48),

                      // Cam Panel + 3 Kart Yelpaze
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.10),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6C3FA0).withOpacity(0.15),
                              blurRadius: 40,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: SizedBox(
                          height: 220,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                               // Sol Kart (Geçmiş)
                               Transform.translate(
                                  offset: const Offset(-75, 25),
                                  child: Transform.rotate(
                                    angle: -0.26,
                                    child: _buildHeroCardView(_selectedCardIndexes[0], const Color(0xFF4AC8EA), 0.90),
                                  ),
                               ),
                               // Sağ Kart (Yön)
                               Transform.translate(
                                  offset: const Offset(75, 25),
                                  child: Transform.rotate(
                                    angle: 0.26,
                                    child: _buildHeroCardView(_selectedCardIndexes[2], const Color(0xFFB35CDA), 0.90),
                                  ),
                               ),
                               // Orta Kart (Şimdi)
                               _buildHeroCardView(_selectedCardIndexes[1], const Color(0xFFF09A59), 1.10),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 56),

                      // Ana Özeti / Tema
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          _latestReading!.generalTheme,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cormorantGaramond(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 22,
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Yorum Blokları
                      _ReadingBlock(
                        label: _isTr ? 'Geçmiş' : 'Past',
                        title: _t('Geçmiş Etki', 'Past Influence'),
                        cardName: _cardName(_selectedCardIndexes[0]),
                        text: _latestReading!.pastInfluence,
                        cardIndex: _selectedCardIndexes[0],
                        glowColor: const Color(0xFF4AC8EA),
                        cardFront: _buildCardFront(_selectedCardIndexes[0]),
                      ),
                      _ReadingBlock(
                        label: _isTr ? 'Ders' : 'Lesson',
                        title: _t('Şu Anın Dersi', 'Present Lesson'),
                        cardName: _cardName(_selectedCardIndexes[1]),
                        text: _latestReading!.presentEnergy,
                        cardIndex: _selectedCardIndexes[1],
                        glowColor: const Color(0xFFF09A59),
                        cardFront: _buildCardFront(_selectedCardIndexes[1]),
                      ),
                      _ReadingBlock(
                        label: _isTr ? 'Yön' : 'Direction',
                        title: _t('Yakın Yön / Tavsiye', 'Direction & Advice'),
                        cardName: _cardName(_selectedCardIndexes[2]),
                        text: _latestReading!.directionAdvice,
                        cardIndex: _selectedCardIndexes[2],
                        glowColor: const Color(0xFFB35CDA),
                        cardFront: _buildCardFront(_selectedCardIndexes[2]),
                      ),
                      const SizedBox(height: 24),

                      // Bonus Bilgiler (Girişim / Gölge / Güç)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _t('⚠️ Dikkat Et:', '⚠️ Watch Out:'),
                              style: GoogleFonts.inter(
                                color: const Color(0xFFFA8B8B),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _latestReading!.directionAdvice,
                              style: GoogleFonts.cormorantGaramond(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _t('🌟 Güçlü Tarafın:', '🌟 Your Strength:'),
                              style: GoogleFonts.inter(
                                color: const Color(0xFF8BFAAB),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _latestReading!.closingMessage,
                              style: GoogleFonts.cormorantGaramond(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Kapanış Mesajı
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2C48E).withOpacity(0.06),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE2C48E).withOpacity(0.2)),
                        ),
                        child: Text(
                          _latestReading!.closingMessage,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cormorantGaramond(
                            color: const Color(0xFFE2C48E),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 56),

                      // Yeni Okuma Butonu
                      GestureDetector(
                        onTap: _resetToIdle,
                        child: Container(
                           padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
                           decoration: BoxDecoration(
                             gradient: const LinearGradient(
                               colors: [Color(0xFFE2C48E), Color(0xFFC7A563)],
                             ),
                             borderRadius: BorderRadius.circular(100),
                             boxShadow: [
                               BoxShadow(
                                 color: const Color(0xFFE2C48E).withOpacity(0.35),
                                 blurRadius: 20,
                                 offset: const Offset(0, 8),
                               ),
                             ],
                           ),
                           child: Text(
                              _t('Yeniden Rastgele Çek', 'Shuffle Again'),
                              style: GoogleFonts.inter(
                                color: const Color(0xFF101428),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                           ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ].animate(interval: 250.ms).fade(duration: 900.ms).slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
                  ),
                ),
            ),
         
        ],
      );  // Stack
        },  // builder
      ),  // AnimatedBuilder
    );  // Scaffold
  }
}



// ============================================================
// Rewarded Ad Service (stub)
// ============================================================
class RewardedAdService {
  RewardedAdService._();
  static final instance = RewardedAdService._();

  Future<bool> showRewardedAd() async {
    // TODO: google_mobile_ads ile RewardedAd entegre et
    if (kDebugMode) {
      await Future.delayed(const Duration(milliseconds: 900));
      return true;
    }
    return false;
  }
}

// ============================================================
// UI Widgets
// ============================================================

class _StarsEffect extends StatelessWidget {
  final Animation<double> animation;
  const _StarsEffect({required this.animation});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: animation,
        builder: (_, __) {
          return CustomPaint(
            painter: _StarsPainter(t: animation.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _StarsPainter extends CustomPainter {
  final double t;
  _StarsPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);
    final starPaint = Paint()..color = Colors.white;
    final glowPaint = Paint()..color = Colors.white;

    // Background dust – subtle, spread everywhere
    for (int i = 0; i < 8000; i++) {
      final phase = (i % 97) * 0.18;
      final driftX = sin(t * 2 * pi + phase) * 1.5;
      final driftY = cos(t * 2 * pi + phase) * 1.5;
      final x = random.nextDouble() * size.width + driftX;
      final y = random.nextDouble() * size.height + driftY;
      final radius = random.nextDouble() * 0.25 + 0.08;
      final opacity = random.nextDouble() * 0.06 + 0.01;
      final twinkle = 0.7 + 0.3 * sin((i % 37) * 0.4 + t * 2 * pi);
      starPaint.color = Colors.white.withOpacity(opacity * twinkle);
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }

    // Medium stars – clearly visible, with soft glow
    for (int i = 0; i < 1800; i++) {
      final phase = (i % 67) * 0.22;
      final driftX = sin(t * 2 * pi + phase) * 2.5;
      final driftY = cos(t * 2 * pi + phase) * 2.5;
      final x = random.nextDouble() * size.width + driftX;
      final y = random.nextDouble() * size.height + driftY;
      final radius = random.nextDouble() * 0.7 + 0.25;
      final opacity = random.nextDouble() * 0.18 + 0.06;
      final twinkle = 0.6 + 0.4 * sin((i % 29) * 0.6 + t * 2 * pi * 1.3);
      final glowRadius = radius * 2.5;
      final glowOpacity = opacity * 0.3 * twinkle;

      glowPaint.color = Colors.white.withOpacity(glowOpacity);
      canvas.drawCircle(Offset(x, y), glowRadius, glowPaint);

      starPaint.color = Colors.white.withOpacity(opacity * twinkle);
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }

    // Bright highlight stars – few but eye-catching
    for (int i = 0; i < 60; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.2 + 0.6;
      final twinkle = 0.5 + 0.5 * sin((i % 11) * 1.2 + t * 2 * pi * 0.8);
      final glowRadius = radius * 4.0;

      // Outer glow
      glowPaint.color = Colors.white.withOpacity(0.04 * twinkle);
      canvas.drawCircle(Offset(x, y), glowRadius, glowPaint);

      // Inner glow
      glowPaint.color = Colors.white.withOpacity(0.08 * twinkle);
      canvas.drawCircle(Offset(x, y), radius * 2.0, glowPaint);

      // Core
      starPaint.color = Colors.white.withOpacity(0.30 * twinkle);
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarsPainter oldDelegate) => oldDelegate.t != t;
}

class _CardImage extends StatelessWidget {
  final String asset;
  final double width;
  const _CardImage({required this.asset, required this.width});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.asset(
        asset,
        width: width,
        fit: BoxFit.fill,
        cacheWidth: 300,
        errorBuilder: (_, __, ___) {
          return Container(
            width: width,
            height: width * 1.55,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFE7D6A5).withOpacity(0.3),
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome,
                color: Color(0xFFE7D6A5),
                size: 28,
              ),
            ),
          );
        },
      ),
    );
  }
}


class _FloatingTarotDeck extends StatefulWidget {
  final Future<void> Function(int index, GlobalKey key) onCardTap;
  final Widget Function() cardBuilder;
  final List<GlobalKey> cardKeys;
  final List<int> selectedPositions;
  final Set<int> hiddenCards;
  const _FloatingTarotDeck({
    super.key,
    required this.onCardTap,
    required this.cardBuilder,
    required this.cardKeys,
    required this.selectedPositions,
    required this.hiddenCards,
  });

  @override
  State<_FloatingTarotDeck> createState() => _FloatingTarotDeckState();
}

class _FloatingTarotDeckState extends State<_FloatingTarotDeck>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _entranceController;
  late AnimationController _btnBounceCtrl;
  int? _pressedIndex;
  // Store card positions for hit-testing during drag
  final Map<int, Rect> _cardRects = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
    
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _btnBounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _entranceController.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _entranceController.dispose();
    _btnBounceCtrl.dispose();
    super.dispose();
  }

  Offset? _btnCenter;
  
  int? _hitTestCard(Offset localPos) {
    // Exclude center button area (Rastgele Çek)
    if (_btnCenter != null) {
      final dx = localPos.dx - _btnCenter!.dx;
      final dy = localPos.dy - _btnCenter!.dy;
      if (dx * dx + dy * dy <= 48 * 48) return null; // 48px radius
    }
    
    final totalCards = widget.cardKeys.length;
    
    // Reverse iterate so top-drawn cards get priority
    for (int i = totalCards - 1; i >= 0; i--) {
      final rect = _cardRects[i];
      if (rect == null) continue;
      if (widget.selectedPositions.contains(i) || widget.hiddenCards.contains(i)) continue;
      // Expand hit area for easier touch on small rotated cards
      if (rect.inflate(12).contains(localPos)) return i;
    }
    return null;
  }

  void _onPointerEvent(Offset localPos) {
    final hit = _hitTestCard(localPos);
    if (hit != _pressedIndex) {
      setState(() => _pressedIndex = hit);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCards = widget.cardKeys.length;
    
    return RepaintBoundary(
      child: SizedBox(
      height: 360,
      child: AnimatedBuilder(
        animation: Listenable.merge([_controller, _entranceController]),
        builder: (_, __) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              final centerX = width / 2;
              final centerY = height * 0.72;
              final isSmall = totalCards > 30;
              final cardW = isSmall ? 36.0 : 56.0;
              final cardH = isSmall ? 36.0 * (138.0 / 88.0) : 56.0 * (138.0 / 88.0);

              final cards = <Widget>[];
              _cardRects.clear();
              _btnCenter = Offset(centerX, centerY);

              // Dynamic layers based on card count
              final int layerCount = isSmall ? 3 : 2;
              final cardsPerLayer = <int>[];
              if (isSmall) {
                // 78 cards: ~26 per layer (outer, mid, inner)
                final perLayer = totalCards ~/ 3;
                cardsPerLayer.addAll([perLayer, perLayer, totalCards - perLayer * 2]);
              } else {
                // 22 cards: 13 outer, 9 inner
                cardsPerLayer.addAll([13, totalCards - 13]);
              }

              const fanAngle = 200.0;
              final layerRadii = isSmall
                  ? [height * 0.42, height * 0.32, height * 0.22]
                  : [height * 0.38, height * 0.26];
              final layerScales = isSmall ? [0.85, 0.92, 1.0] : [0.92, 1.0];
              
              final entranceT = _entranceController.value;

              // Helper to build a card with entrance animation
              Widget buildCard(int cardIdx, double targetX, double targetY, double cardRotation, double baseScale) {
                // Check if card is already selected
                final isSelected = widget.selectedPositions.contains(cardIdx) || widget.hiddenCards.contains(cardIdx);
                // Staggered delay: right to left (reverse index)
                final reverseIdx = totalCards - 1 - cardIdx;
                final delay = (reverseIdx / totalCards) * 0.5;
                final cardT = ((entranceT - delay) / (1.0 - delay)).clamp(0.0, 1.0);
                final curved = Curves.easeOutCubic.transform(cardT);
                
                // Animate from center to target position
                final startX = centerX - (cardW / 2);
                final startY = centerY - (cardH / 2);
                final x = startX + (targetX - startX) * curved;
                final y = startY + (targetY - startY) * curved;
                final rotation = cardRotation * curved;
                final scale = baseScale;
                final opacity = isSelected ? 0.0 : curved.clamp(0.0, 1.0);
                
                // Store rect for hit-testing
                _cardRects[cardIdx] = Rect.fromLTWH(x, y, cardW * scale, cardH * scale);
                
                final cardKey = widget.cardKeys[cardIdx];
                final isPressed = _pressedIndex == cardIdx;

                return Positioned(
                  left: x,
                  top: y,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.rotate(
                      angle: rotation,
                      child: AnimatedScale(
                        scale: isPressed ? scale * 1.25 : scale,
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOutCubic,
                        child: SizedBox(
                          width: cardW,
                          height: cardH,
                          child: KeyedSubtree(
                            key: cardKey,
                            child: widget.cardBuilder(),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }

              // --- Build all layers ---
              int cardOffset = 0;
              for (int layer = 0; layer < layerCount; layer++) {
                final count = cardsPerLayer[layer];
                final radius = layerRadii[layer];
                final scale = layerScales[layer];
                final step = count > 1 ? fanAngle / (count - 1) : 0.0;
                final start = -90.0 - (fanAngle / 2);

                for (int i = 0; i < count; i++) {
                  final cardIdx = cardOffset + i;
                  if (cardIdx >= totalCards) break;
                  final angleDeg = start + (i * step);
                  final angleRad = angleDeg * (pi / 180);
                  final floatY = sin(_controller.value * 2 * pi + cardIdx * 0.5) * 4.0
                      + sin(_controller.value * 2 * pi * 2 + cardIdx * 0.8) * 2.0;
                  final floatX = cos(_controller.value * 2 * pi + cardIdx * 0.6) * 2.5;
                  
                  final x = centerX + cos(angleRad) * radius - (cardW / 2) + floatX;
                  final y = centerY + sin(angleRad) * radius - (cardH / 2) + floatY;
                  final cardRotation = (angleDeg + 90) * (pi / 180);

                  cards.add(buildCard(cardIdx, x, y, cardRotation, scale));
                }
                cardOffset += count;
              }

              // Center button - "Rastgele Çek"
              final btnEntranceT = ((entranceT - 0.3) / 0.7).clamp(0.0, 1.0);
              final btnCurved = Curves.easeOutCubic.transform(btnEntranceT);

              cards.add(
                Positioned(
                  left: centerX - 44,
                  top: centerY - 44,
                  child: Opacity(
                    opacity: btnCurved,
                    child: Transform.scale(
                      scale: 0.5 + (0.5 * btnCurved),
                      child: GestureDetector(
                    onTapDown: (_) {
                      HapticFeedback.lightImpact();
                      _btnBounceCtrl.forward();
                    },
                    onTapUp: (_) async {
                      await Future.delayed(const Duration(milliseconds: 80));
                      _btnBounceCtrl.reverse();
                      // Pick a random unselected card
                      final available = List.generate(totalCards, (i) => i)
                          .where((i) => !widget.selectedPositions.contains(i) && !widget.hiddenCards.contains(i))
                          .toList();
                      if (available.isEmpty) return;
                      available.shuffle();
                      final pick = available.first;
                      widget.onCardTap(pick, widget.cardKeys[pick]);
                    },
                    onTapCancel: () {
                      _btnBounceCtrl.reverse();
                    },
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_btnBounceCtrl, _controller]),
                      builder: (context, child) {
                        final press = _btnBounceCtrl.value;
                        final scale = 1.0 - (press * 0.08);
                        final depthShift = press * 2.0;
                        return Transform.translate(
                          offset: Offset(0, depthShift),
                          child: Transform.scale(scale: scale, child: child),
                        );
                      },
                      child: Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              // Liquid glass base
                              gradient: LinearGradient(
                                begin: const Alignment(-0.5, -1.2),
                                end: const Alignment(0.5, 1.2),
                                colors: [
                                  Colors.white.withOpacity(0.18),
                                  Colors.white.withOpacity(0.06),
                                  Colors.white.withOpacity(0.02),
                                  Colors.white.withOpacity(0.08),
                                ],
                                stops: const [0.0, 0.35, 0.65, 1.0],
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.20),
                                width: 0.8,
                              ),
                            ),
                            child: ClipOval(
                              child: Stack(
                              children: [
                                // ── Colorful mist/smoke inside ──
                                Positioned.fill(
                                  child: AnimatedBuilder(
                                    animation: _controller,
                                    builder: (context, _) {
                                      final t = _controller.value;
                                      return Stack(
                                        children: [
                                          // Purple mist
                                          Positioned(
                                            left: 10 + sin(t * pi * 2) * 15,
                                            top: 10 + cos(t * pi * 2) * 12,
                                            child: Container(
                                              width: 45,
                                              height: 45,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: RadialGradient(
                                                  colors: [
                                                    Color.fromRGBO(160, 100, 255, 0.30 + sin(t * pi * 2) * 0.10),
                                                    Colors.transparent,
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Teal mist
                                          Positioned(
                                            right: 8 + cos(t * pi * 2 + 2) * 12,
                                            bottom: 12 + sin(t * pi * 2 + 2) * 10,
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: RadialGradient(
                                                  colors: [
                                                    Color.fromRGBO(80, 200, 200, 0.25 + cos(t * pi * 2) * 0.08),
                                                    Colors.transparent,
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Gold mist
                                          Positioned(
                                            left: 20 + cos(t * pi * 2 + 4) * 14,
                                            bottom: 15 + sin(t * pi * 2 + 4) * 12,
                                            child: Container(
                                              width: 35,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: RadialGradient(
                                                  colors: [
                                                    Color.fromRGBO(226, 196, 142, 0.22 + sin(t * pi * 2 + 1) * 0.08),
                                                    Colors.transparent,
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                // ── Liquid highlight blob ──
                                Positioned(
                                  top: 6,
                                  left: 10,
                                  child: Container(
                                    width: 60,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(30),
                                        topRight: Radius.circular(30),
                                        bottomLeft: Radius.circular(12),
                                        bottomRight: Radius.circular(12),
                                      ),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.white.withOpacity(0.20),
                                          Colors.white.withOpacity(0.0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // ── Bottom liquid reflection ──
                                Positioned(
                                  bottom: 8,
                                  right: 12,
                                  child: Container(
                                    width: 36,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.0),
                                          Colors.white.withOpacity(0.06),
                                          Colors.white.withOpacity(0.0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // ── Text ──
                                Center(
                                  child: Text(
                                    'Rastgele\nÇek',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.55),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      height: 1.3,
                                    ),
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
              );

              return Listener(
                onPointerDown: (e) => _onPointerEvent(e.localPosition),
                onPointerMove: (e) => _onPointerEvent(e.localPosition),
                onPointerUp: (e) {
                  final hit = _hitTestCard(e.localPosition);
                  setState(() => _pressedIndex = null);
                  if (hit != null) {
                    widget.onCardTap(hit, widget.cardKeys[hit]);
                  }
                },
                onPointerCancel: (_) => setState(() => _pressedIndex = null),
                behavior: HitTestBehavior.translucent,
                child: Stack(children: cards),
              );
            },
          );
        },
        ),
    ),
    );
  }
}

// ============================================================
// Dust Clouds Effect
// ============================================================
class _DustClouds extends StatelessWidget {
  final Animation<double> animation;
  const _DustClouds({required this.animation});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: animation,
        builder: (_, __) {
          return CustomPaint(
            painter: _DustCloudsPainter(t: animation.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _DustCloudsPainter extends CustomPainter {
  final double t;
  _DustCloudsPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Cloud definitions: [xRatio, yRatio, baseRadius, color, speed, phase]
    final clouds = <List<double>>[
      // Large slow-moving purple nebula clouds
      [0.15, 0.25, 0.28, 0, 0.7, 0.0],    // left upper
      [0.85, 0.35, 0.25, 0, 0.5, 1.2],    // right
      [0.50, 0.75, 0.32, 0, 0.6, 2.4],    // center bottom
      [0.20, 0.65, 0.22, 0, 0.8, 3.6],    // left lower
      [0.75, 0.15, 0.20, 0, 0.9, 4.8],    // right upper
      // Gold-tinted wisps
      [0.40, 0.40, 0.18, 1, 1.0, 0.8],    // center
      [0.65, 0.60, 0.15, 1, 1.2, 2.0],    // right center
      [0.30, 0.85, 0.16, 1, 0.7, 3.2],    // left bottom
    ];

    for (final c in clouds) {
      final xRatio = c[0];
      final yRatio = c[1];
      final baseRadius = c[2];
      final isGold = c[3] == 1;
      final speed = c[4];
      final phase = c[5];

      // Drift slowly
      final driftX = sin(t * 2 * pi * speed + phase) * size.width * 0.04;
      final driftY = cos(t * 2 * pi * speed * 0.7 + phase) * size.height * 0.03;
      // Pulse size
      final pulse = 0.85 + 0.15 * sin(t * 2 * pi * speed * 0.5 + phase);

      final cx = size.width * xRatio + driftX;
      final cy = size.height * yRatio + driftY;
      final radius = size.width * baseRadius * pulse;

      final Color centerColor;
      final Color edgeColor;
      if (isGold) {
        centerColor = const Color(0xFF9C6BFF).withOpacity(0.02);
        edgeColor = const Color(0xFFE7D6A5).withOpacity(0.0);
      } else {
        centerColor = const Color(0xFF6B3FA0).withOpacity(0.03);
        edgeColor = const Color(0xFF2B123F).withOpacity(0.0);
      }

      paint.shader = ui.Gradient.radial(
        Offset(cx, cy),
        radius,
        [centerColor, edgeColor],
        [0.0, 1.0],
      );

      canvas.drawCircle(Offset(cx, cy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DustCloudsPainter oldDelegate) =>
      oldDelegate.t != t;
}

// ── Noise Painter (hafif grain) ──────────────
// ============================================================
// Sparkle Particle Painter - Floating mystical particles
// ============================================================
class _SparkleParticlePainter extends CustomPainter {
  final double time;
  final double screenW;
  final double screenH;
  
  _SparkleParticlePainter(this.time, this.screenW, this.screenH);
  
  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(77);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    for (int i = 0; i < 40; i++) {
      final baseX = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final speed = 0.3 + rng.nextDouble() * 0.7;
      final phase = rng.nextDouble() * pi * 2;
      final angle = rng.nextDouble() * pi * 2;
      final lineLen = 4.0 + rng.nextDouble() * 10.0;
      
      // Slow upward drift + horizontal sway
      final y = (baseY - time * speed * 60) % size.height;
      final x = baseX + sin(time * pi * 2 + phase) * 8;
      
      // Twinkle effect
      final twinkle = (sin(time * pi * 4 + phase * 3) * 0.5 + 0.5);
      final opacity = (0.08 + twinkle * 0.22).clamp(0.0, 1.0);
      
      paint.color = Colors.white.withOpacity(opacity);
      paint.strokeWidth = 0.5 + twinkle * 0.8;
      
      final dx = cos(angle) * lineLen * 0.5;
      final dy = sin(angle) * lineLen * 0.5;
      canvas.drawLine(
        Offset(x - dx, y - dy),
        Offset(x + dx, y + dy),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant _SparkleParticlePainter oldDelegate) => 
    oldDelegate.time != time;
}

// ── Aurora / Northern Lights ──
class _StarFieldPainter extends CustomPainter {
  final double pulse;
  _StarFieldPainter({required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final bands = [
      {'y': 0.25, 'color': const Color(0xFF7B68EE), 'amp': 25.0, 'freq': 2.5, 'phase': 0.0},
      {'y': 0.35, 'color': const Color(0xFF40E0D0), 'amp': 18.0, 'freq': 3.0, 'phase': 1.2},
      {'y': 0.55, 'color': const Color(0xFFB388FF), 'amp': 22.0, 'freq': 2.0, 'phase': 2.5},
      {'y': 0.70, 'color': const Color(0xFFE2C48E), 'amp': 15.0, 'freq': 3.5, 'phase': 3.8},
    ];

    for (final band in bands) {
      final baseY = size.height * (band['y'] as double);
      final color = band['color'] as Color;
      final amp = band['amp'] as double;
      final freq = band['freq'] as double;
      final ph = band['phase'] as double;

      final path = Path();
      path.moveTo(0, baseY);

      for (double x = 0; x <= size.width; x += 3) {
        final wave1 = sin((x / size.width) * pi * freq + pulse * pi * 2 * 0.4 + ph) * amp;
        final wave2 = sin((x / size.width) * pi * (freq * 1.7) + pulse * pi * 2 * 0.25 + ph * 1.5) * amp * 0.4;
        final y = baseY + wave1 + wave2;
        path.lineTo(x, y);
      }

      final twinkle = sin(pulse * pi * 2 * 0.5 + ph) * 0.5 + 0.5;
      final opacity = (0.03 + twinkle * 0.04).clamp(0.0, 1.0);

      // Wide blurred band
      canvas.drawPath(path, Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 40 + twinkle * 20
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30));

      // Bright core
      canvas.drawPath(path, Paint()
        ..color = color.withOpacity(opacity * 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6 + twinkle * 4
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
    }
  }

  @override
  bool shouldRepaint(_StarFieldPainter old) => old.pulse != pulse;
}

// ── Sacred Geometry / Zodiac Wheel ──
// ── Bokeh Light Orbs ──
// ── Star Dust Particles ──
class _StarDustPainter extends CustomPainter {
  final double pulse;
  _StarDustPainter({required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(77);
    final paint = Paint()..style = PaintingStyle.fill;

    // 1500 drifting tiny stars
    for (int i = 0; i < 1500; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final ph = rng.nextDouble() * pi * 2;
      final driftX = sin(pulse * pi * 2 * 0.5 + ph) * 8;
      final driftY = cos(pulse * pi * 2 * 0.4 + ph * 1.3) * 6;
      final sz = 0.2 + rng.nextDouble() * 0.6;
      final opacity = 0.08 + rng.nextDouble() * 0.18;
      paint.color = Color.fromRGBO(255, 255, 255, opacity);
      canvas.drawCircle(Offset(x + driftX, y + driftY), sz, paint);
    }

    // 500 twinkling + drifting stars
    for (int i = 0; i < 500; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final phase = rng.nextDouble() * pi * 2;
      final speed = 0.3 + rng.nextDouble() * 1.5;
      final twinkle = sin(pulse * pi * 2 * speed + phase) * 0.5 + 0.5;
      final driftX = sin(pulse * pi * 2 * 0.6 + phase) * 12;
      final driftY = cos(pulse * pi * 2 * 0.45 + phase * 0.8) * 10;
      final sz = 0.3 + rng.nextDouble() * 1.2;
      final opacity = (0.06 + twinkle * 0.30).clamp(0.0, 1.0);

      final isGold = rng.nextDouble() < 0.15;
      paint.color = isGold
          ? Color.fromRGBO(226, 196, 142, opacity)
          : Color.fromRGBO(255, 255, 255, opacity);

      canvas.drawCircle(Offset(x + driftX, y + driftY), sz * (0.6 + twinkle * 0.4), paint);
    }
  }

  @override
  bool shouldRepaint(_StarDustPainter old) => old.pulse != pulse;
}

class _BokehPainter extends CustomPainter {
  final double pulse;
  _BokehPainter({required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(99); // Different seed from aurora

    for (int i = 0; i < 20; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final baseR = 10.0 + rng.nextDouble() * 30.0;
      final phase = rng.nextDouble() * pi * 2;
      final speed = 0.3 + rng.nextDouble() * 0.5;
      final twinkle = sin(pulse * pi * 2 * speed + phase) * 0.5 + 0.5;

      final colorChoice = rng.nextInt(3);
      final Color baseColor;
      switch (colorChoice) {
        case 0: baseColor = const Color(0xFFE2C48E); break;
        case 1: baseColor = const Color(0xFFB388FF); break;
        default: baseColor = const Color(0xFFFFFFFF); break;
      }

      final opacity = (0.015 + twinkle * 0.03).clamp(0.0, 1.0);
      final r = baseR * (0.85 + twinkle * 0.15);

      final gradient = RadialGradient(
        colors: [
          baseColor.withOpacity(opacity),
          baseColor.withOpacity(opacity * 0.3),
          baseColor.withOpacity(0),
        ],
        stops: const [0.0, 0.4, 1.0],
      );

      final rect = Rect.fromCircle(center: Offset(x, y), radius: r);
      canvas.drawCircle(Offset(x, y), r, Paint()..shader = gradient.createShader(rect));
    }
  }

  @override
  bool shouldRepaint(_BokehPainter old) => old.pulse != pulse;
}

class _SacredGeometryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final paint = Paint()
      ..color = const Color(0xFFE2C48E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    // Outer circle
    canvas.drawCircle(Offset(cx, cy), cx * 0.95, paint);
    // Inner circles
    canvas.drawCircle(Offset(cx, cy), cx * 0.75, paint..strokeWidth = 0.4);
    canvas.drawCircle(Offset(cx, cy), cx * 0.45, paint..strokeWidth = 0.3);

    // 12 zodiac marks
    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * pi * 2 - pi / 2;
      final innerR = cx * 0.75;
      final outerR = cx * 0.95;
      final x1 = cx + cos(angle) * innerR;
      final y1 = cy + sin(angle) * innerR;
      final x2 = cx + cos(angle) * outerR;
      final y2 = cy + sin(angle) * outerR;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint..strokeWidth = 0.4);

      // Small dot at mark
      canvas.drawCircle(
        Offset(cx + cos(angle) * cx * 0.85, cy + sin(angle) * cx * 0.85),
        1.5,
        Paint()..color = const Color(0xFFE2C48E).withOpacity(0.5)..style = PaintingStyle.fill,
      );
    }

    // Center dot
    canvas.drawCircle(
      Offset(cx, cy), 2,
      Paint()..color = const Color(0xFFE2C48E).withOpacity(0.4)..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}



// ── Elegant Thin Golden Border ──
class _GoldenBorderPainter extends CustomPainter {
  static const _gold = Color(0xFFE2C48E);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(14, 14, size.width - 28, size.height - 28);

    // Single thin border
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(22)),
      Paint()..color = _gold.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 0.6,
    );

    // Corner ornaments — tiny elegant curls
    final p = Paint()
      ..color = _gold.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..strokeCap = StrokeCap.round;

    for (final c in [
      [rect.left + 24.0, rect.top + 24.0, 1.0, 1.0],
      [rect.right - 24.0, rect.top + 24.0, -1.0, 1.0],
      [rect.left + 24.0, rect.bottom - 24.0, 1.0, -1.0],
      [rect.right - 24.0, rect.bottom - 24.0, -1.0, -1.0],
    ]) {
      final cx = c[0], cy = c[1], dx = c[2], dy = c[3];
      // Short L-arms
      canvas.drawLine(Offset(cx, cy), Offset(cx + dx * 18, cy), p);
      canvas.drawLine(Offset(cx, cy), Offset(cx, cy + dy * 18), p);
      // Tiny inward curl
      final curl = Path()
        ..moveTo(cx + dx * 18, cy)
        ..quadraticBezierTo(cx + dx * 20, cy + dy * 4, cx + dx * 15, cy + dy * 5);
      canvas.drawPath(curl, p);
      final curl2 = Path()
        ..moveTo(cx, cy + dy * 18)
        ..quadraticBezierTo(cx + dx * 4, cy + dy * 20, cx + dx * 5, cy + dy * 15);
      canvas.drawPath(curl2, p);
      // Corner dot
      canvas.drawCircle(Offset(cx, cy), 1.2, Paint()..color = _gold.withOpacity(0.4)..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class _NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42);
    final paint = Paint()..color = Colors.white;
    for (int i = 0; i < 2000; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        rng.nextDouble() * 0.8,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Alt kısımda yoğunlaşan gerçekçi toz bulutu ──
/// Tarot arka planı için statik dairesel renk geçişi
/// Ana sayfadaki _MottledPainter ile aynı mantık, mor tonlarla
class _TarotMottledPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(55);

    // Mor tonlu 3 renk ailesi: lavanta, erik moru, mor-mavi
    final allColors = [
      // Lavanta tonları (bej→mor)
      const Color(0xFFB4A0D2), // Lavanta
      const Color(0xFFA090C0), // Orta lavanta
      const Color(0xFFC8B8E0), // Açık lavanta
      // Erik moru tonları (kırmızı→mor)
      const Color(0xFF964064), // Erik moru
      const Color(0xFF7A3055), // Koyu erik
      const Color(0xFF80486E), // Sıcak erik
      const Color(0xFF6E285A), // Derin erik
      // Mor-mavi tonları (mavi→mor)
      const Color(0xFF2A376C), // Mor-mavi
      const Color(0xFF3A4580), // Orta mor-mavi
      const Color(0xFF1E2A55), // Koyu mor-mavi
    ];

    for (int i = 0; i < 22; i++) {
      final color = allColors[rng.nextInt(allColors.length)];
      final opacity = 0.25 + rng.nextDouble() * 0.28;
      final radius = 80.0 + rng.nextDouble() * 180.0;
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;

      final paint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(x, y),
          radius,
          [
            color.withOpacity(opacity),
            color.withOpacity(opacity * 0.65),
            color.withOpacity(opacity * 0.2),
            color.withOpacity(0),
          ],
          [0.0, 0.40, 0.70, 1.0],
        );

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ReadingBlock extends StatelessWidget {
  final String label;
  final String title;
  final String cardName;
  final String text;
  final int cardIndex;
  final Color glowColor;
  final Widget cardFront;

  const _ReadingBlock({
    required this.label,
    required this.title,
    required this.cardName,
    required this.cardIndex,
    required this.text,
    required this.glowColor,
    required this.cardFront,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 24, bottom: 12),
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.cormorantGaramond(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                cardName,
                style: GoogleFonts.cormorantGaramond(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                text,
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 20,
          child: Container(
            width: 54,
            height: 84,
            decoration: BoxDecoration(
              color: const Color(0xFF101428),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: glowColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: glowColor.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: cardFront,
            ),
          ),
        ),
        Positioned(
          top: 40,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: glowColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: glowColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 12, color: glowColor.withOpacity(0.9)),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: glowColor.withOpacity(0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Deck Arc Painter - Decorative arc lines around card fan
// ============================================================
class _DeckArcPainter extends CustomPainter {
  final double centerX;
  final double centerY;
  final double outerRadius;
  final double innerRadius;
  final double fanAngle;
  final double opacity;

  _DeckArcPainter({
    required this.centerX,
    required this.centerY,
    required this.outerRadius,
    required this.innerRadius,
    required this.fanAngle,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity < 0.01) return;

    final center = Offset(centerX, centerY);
    
    // Convert fan angle to radians
    final halfFan = (fanAngle / 2) * (pi / 180);
    // Start and sweep angles for the arc (upper semicircle of the fan)
    final startAngle = -pi / 2 - halfFan;
    final sweepAngle = halfFan * 2;

    // ── Outer arc ──
    final outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = Colors.white.withOpacity(0.12 * opacity);

    // Draw outer arc with gradient fade at edges
    final outerPath = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: outerRadius),
        startAngle,
        sweepAngle,
      );
    
    // Outer glow (wider, softer)
    final outerGlowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.white.withOpacity(0.03 * opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(outerPath, outerGlowPaint);
    canvas.drawPath(outerPath, outerPaint);

    // ── Inner arc ──
    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..color = Colors.white.withOpacity(0.08 * opacity);

    final innerPath = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: innerRadius),
        startAngle,
        sweepAngle,
      );

    // Inner glow
    final innerGlowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = Colors.white.withOpacity(0.02 * opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawPath(innerPath, innerGlowPaint);
    canvas.drawPath(innerPath, innerPaint);

    // ── Small decorative dots at arc endpoints ──
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.20 * opacity);

    // Outer arc endpoints
    final outerLeftX = centerX + cos(startAngle) * outerRadius;
    final outerLeftY = centerY + sin(startAngle) * outerRadius;
    final outerRightX = centerX + cos(startAngle + sweepAngle) * outerRadius;
    final outerRightY = centerY + sin(startAngle + sweepAngle) * outerRadius;
    canvas.drawCircle(Offset(outerLeftX, outerLeftY), 1.5, dotPaint);
    canvas.drawCircle(Offset(outerRightX, outerRightY), 1.5, dotPaint);

    // Inner arc endpoints
    final innerLeftX = centerX + cos(startAngle) * innerRadius;
    final innerLeftY = centerY + sin(startAngle) * innerRadius;
    final innerRightX = centerX + cos(startAngle + sweepAngle) * innerRadius;
    final innerRightY = centerY + sin(startAngle + sweepAngle) * innerRadius;
    canvas.drawCircle(Offset(innerLeftX, innerLeftY), 1.2, dotPaint);
    canvas.drawCircle(Offset(innerRightX, innerRightY), 1.2, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _DeckArcPainter oldDelegate) =>
      oldDelegate.opacity != opacity ||
      oldDelegate.centerX != centerX ||
      oldDelegate.centerY != centerY;
}

// ============================================================
// ============================================================
// Card Star Painter - Mystical star for card back center
// ============================================================
// ============================================================
// Tarot Card Front Symbol Painter
// ============================================================
class _TarotSymbolPainter extends CustomPainter {
  final int id;
  final Color color;
  _TarotSymbolPainter({required this.id, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.4;
    final paint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final fillP = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    if (id < 22) {
      _drawMajor(canvas, cx, cy, r, paint, fillP);
    } else {
      final suitIdx = (id - 22) ~/ 14;
      _drawSuit(canvas, cx, cy, r, paint, fillP, suitIdx);
    }
  }

  void _drawMajor(Canvas canvas, double cx, double cy, double r, Paint p, Paint f) {
    switch (id) {
      case 0: // Fool - spiral
        final path = Path();
        for (double t = 0; t < 4 * pi; t += 0.1) {
          final sr = r * 0.1 + (t / (4 * pi)) * r * 0.8;
          final x = cx + cos(t) * sr;
          final y = cy + sin(t) * sr;
          if (t == 0) path.moveTo(x, y); else path.lineTo(x, y);
        }
        canvas.drawPath(path, p);
      case 1: // Magician - infinity
        final path = Path();
        for (double t = 0; t < 2 * pi; t += 0.05) {
          final x = cx + r * cos(t) / (1 + sin(t) * sin(t));
          final y = cy + r * sin(t) * cos(t) / (1 + sin(t) * sin(t));
          if (t == 0) path.moveTo(x, y); else path.lineTo(x, y);
        }
        canvas.drawPath(path, p);
      case 2: // High Priestess - crescents
        canvas.drawArc(Rect.fromCircle(center: Offset(cx - 4, cy), radius: r * 0.7), -pi / 2, pi, false, p);
        canvas.drawArc(Rect.fromCircle(center: Offset(cx + 4, cy), radius: r * 0.7), pi / 2, pi, false, p);
      case 3: // Empress - Venus
        canvas.drawCircle(Offset(cx, cy - r * 0.2), r * 0.45, p);
        canvas.drawLine(Offset(cx, cy + r * 0.25), Offset(cx, cy + r * 0.9), p);
        canvas.drawLine(Offset(cx - r * 0.3, cy + r * 0.55), Offset(cx + r * 0.3, cy + r * 0.55), p);
      case 4: // Emperor - square
        canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy), width: r * 1.3, height: r * 1.5), p);
        canvas.drawLine(Offset(cx, cy - r * 0.75), Offset(cx, cy + r * 0.75), p);
        canvas.drawLine(Offset(cx - r * 0.65, cy), Offset(cx + r * 0.65, cy), p);
      case 5: // Hierophant - triple cross
        canvas.drawLine(Offset(cx, cy - r), Offset(cx, cy + r), p);
        canvas.drawLine(Offset(cx - r * 0.5, cy - r * 0.4), Offset(cx + r * 0.5, cy - r * 0.4), p);
        canvas.drawLine(Offset(cx - r * 0.35, cy + r * 0.1), Offset(cx + r * 0.35, cy + r * 0.1), p);
      case 6: // Lovers - overlapping circles
        canvas.drawCircle(Offset(cx - r * 0.3, cy), r * 0.5, p);
        canvas.drawCircle(Offset(cx + r * 0.3, cy), r * 0.5, p);
      case 7: // Chariot - arrow up
        final path = Path()
          ..moveTo(cx, cy - r)..lineTo(cx + r * 0.6, cy)..lineTo(cx + r * 0.25, cy)
          ..lineTo(cx + r * 0.25, cy + r)..lineTo(cx - r * 0.25, cy + r)
          ..lineTo(cx - r * 0.25, cy)..lineTo(cx - r * 0.6, cy)..close();
        canvas.drawPath(path, p);
      case 8: // Strength - infinity + circle
        canvas.drawCircle(Offset(cx, cy + r * 0.3), r * 0.55, p);
        final inf = Path();
        for (double t = 0; t < 2 * pi; t += 0.05) {
          final x = cx + r * 0.4 * cos(t) / (1 + sin(t) * sin(t));
          final y = (cy - r * 0.5) + r * 0.25 * sin(t) * cos(t) / (1 + sin(t) * sin(t));
          if (t == 0) inf.moveTo(x, y); else inf.lineTo(x, y);
        }
        canvas.drawPath(inf, p);
      case 9: // Hermit - lantern
        canvas.drawCircle(Offset(cx, cy - r * 0.4), r * 0.35, p);
        canvas.drawCircle(Offset(cx, cy - r * 0.4), r * 0.35, f);
        canvas.drawLine(Offset(cx, cy - r * 0.05), Offset(cx, cy + r * 0.9), p);
      case 10: // Wheel - spoked circle
        canvas.drawCircle(Offset(cx, cy), r * 0.85, p);
        canvas.drawCircle(Offset(cx, cy), r * 0.35, p);
        for (int i = 0; i < 8; i++) {
          final a = i * pi / 4;
          canvas.drawLine(Offset(cx + cos(a) * r * 0.35, cy + sin(a) * r * 0.35),
              Offset(cx + cos(a) * r * 0.85, cy + sin(a) * r * 0.85), p);
        }
      case 11: // Justice - scales
        canvas.drawLine(Offset(cx, cy - r * 0.8), Offset(cx, cy + r * 0.8), p);
        canvas.drawLine(Offset(cx - r * 0.8, cy - r * 0.3), Offset(cx + r * 0.8, cy - r * 0.3), p);
        canvas.drawArc(Rect.fromCircle(center: Offset(cx - r * 0.7, cy), radius: r * 0.3), 0, pi, false, p);
        canvas.drawArc(Rect.fromCircle(center: Offset(cx + r * 0.7, cy), radius: r * 0.3), 0, pi, false, p);
      case 12: // Hanged Man - inverted triangle
        final path = Path()..moveTo(cx, cy + r * 0.8)..lineTo(cx - r * 0.7, cy - r * 0.6)..lineTo(cx + r * 0.7, cy - r * 0.6)..close();
        canvas.drawPath(path, p);
        canvas.drawCircle(Offset(cx, cy - r * 0.1), r * 0.2, f);
      case 13: // Death - scythe
        canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.8), -pi * 0.8, pi * 1.2, false, p);
      case 14: // Temperance - two triangles
        final up = Path()..moveTo(cx - r * 0.5, cy)..lineTo(cx, cy - r * 0.8)..lineTo(cx + r * 0.5, cy)..close();
        final dn = Path()..moveTo(cx - r * 0.5, cy)..lineTo(cx, cy + r * 0.8)..lineTo(cx + r * 0.5, cy)..close();
        canvas.drawPath(up, p); canvas.drawPath(dn, p);
      case 15: // Devil - inverted pentagram
        _drawPentagram(canvas, cx, cy, r * 0.85, p, inverted: true);
      case 16: // Tower - lightning
        final path = Path()..moveTo(cx, cy - r)..lineTo(cx - r * 0.35, cy * 0.15)
          ..lineTo(cx + r * 0.1, cy - r * 0.15)..lineTo(cx - r * 0.15, cy + r * 0.6);
        canvas.drawPath(path, p);
      case 17: // Star - 6-pointed
        _drawStar(canvas, cx, cy, r * 0.85, 6, p);
        canvas.drawCircle(Offset(cx, cy), r * 0.15, f);
      case 18: // Moon - thick crescent
        canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.7), pi * 0.3, pi * 1.4, false,
            Paint()..color = p.color..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round);
      case 19: // Sun - circle with rays
        canvas.drawCircle(Offset(cx, cy), r * 0.4, p);
        canvas.drawCircle(Offset(cx, cy), r * 0.4, f);
        for (int i = 0; i < 12; i++) {
          final a = i * pi / 6;
          canvas.drawLine(Offset(cx + cos(a) * r * 0.5, cy + sin(a) * r * 0.5),
              Offset(cx + cos(a) * r * 0.85, cy + sin(a) * r * 0.85), p);
        }
      case 20: // Judgement - cross + circle
        canvas.drawCircle(Offset(cx, cy - r * 0.3), r * 0.4, p);
        canvas.drawLine(Offset(cx, cy + r * 0.1), Offset(cx, cy + r * 0.9), p);
        canvas.drawLine(Offset(cx - r * 0.4, cy + r * 0.35), Offset(cx + r * 0.4, cy + r * 0.35), p);
      case 21: // World - double circle + star
        canvas.drawCircle(Offset(cx, cy), r * 0.85, p);
        canvas.drawCircle(Offset(cx, cy), r * 0.65, p);
        _drawStar(canvas, cx, cy, r * 0.3, 4, p);
    }
  }

  void _drawSuit(Canvas canvas, double cx, double cy, double r, Paint p, Paint f, int suit) {
    switch (suit) {
      case 0: // Cups - chalice
        final path = Path()
          ..moveTo(cx - r * 0.5, cy - r * 0.6)
          ..quadraticBezierTo(cx - r * 0.5, cy + r * 0.2, cx, cy + r * 0.4)
          ..quadraticBezierTo(cx + r * 0.5, cy + r * 0.2, cx + r * 0.5, cy - r * 0.6)..close();
        canvas.drawPath(path, p); canvas.drawPath(path, f);
        canvas.drawLine(Offset(cx, cy + r * 0.4), Offset(cx, cy + r * 0.8), p);
        canvas.drawLine(Offset(cx - r * 0.3, cy + r * 0.8), Offset(cx + r * 0.3, cy + r * 0.8), p);
      case 1: // Wands - staff + diamond
        canvas.drawLine(Offset(cx, cy - r), Offset(cx, cy + r), p);
        final d = Path()..moveTo(cx, cy - r * 0.9)..lineTo(cx + r * 0.2, cy - r * 0.6)
          ..lineTo(cx, cy - r * 0.3)..lineTo(cx - r * 0.2, cy - r * 0.6)..close();
        canvas.drawPath(d, p); canvas.drawPath(d, f);
      case 2: // Swords - blade
        canvas.drawLine(Offset(cx, cy - r), Offset(cx, cy + r * 0.5), p);
        canvas.drawLine(Offset(cx - r * 0.5, cy - r * 0.1), Offset(cx + r * 0.5, cy - r * 0.1), p);
        canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy + r * 0.1), width: r * 0.15, height: r * 0.5), p);
      case 3: // Pentacles - star in circle
        canvas.drawCircle(Offset(cx, cy), r * 0.8, p);
        _drawPentagram(canvas, cx, cy, r * 0.6, p);
    }
  }

  void _drawStar(Canvas canvas, double cx, double cy, double r, int points, Paint p) {
    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final a = (i * pi / points) - pi / 2;
      final sr = i.isEven ? r : r * 0.4;
      if (i == 0) path.moveTo(cx + cos(a) * sr, cy + sin(a) * sr);
      else path.lineTo(cx + cos(a) * sr, cy + sin(a) * sr);
    }
    path.close();
    canvas.drawPath(path, p);
  }

  void _drawPentagram(Canvas canvas, double cx, double cy, double r, Paint p, {bool inverted = false}) {
    final off = inverted ? pi / 2 : -pi / 2;
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final a = off + (i * 4 * pi / 5);
      if (i == 0) path.moveTo(cx + cos(a) * r, cy + sin(a) * r);
      else path.lineTo(cx + cos(a) * r, cy + sin(a) * r);
    }
    path.close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _TarotSymbolPainter old) => old.id != id || old.color != color;
}

class _CardStarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final goldColor = Colors.white.withOpacity(0.30);
    
    final paint = Paint()
      ..color = goldColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    
    // Outer circle
    canvas.drawCircle(Offset(cx, cy), size.width * 0.45, paint);
    
    // Inner circle
    canvas.drawCircle(Offset(cx, cy), size.width * 0.18, 
      Paint()..color = goldColor.withOpacity(0.3)..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(cx, cy), size.width * 0.18, paint);
    
    // 8-pointed star lines
    final r = size.width * 0.42;
    for (int i = 0; i < 8; i++) {
      final angle = (i * pi / 4) - (pi / 2);
      final dx = cx + cos(angle) * r;
      final dy = cy + sin(angle) * r;
      canvas.drawLine(Offset(cx, cy), Offset(dx, dy), paint);
    }
    
    // Small diamond at top
    final diamondPaint = Paint()
      ..color = goldColor
      ..style = PaintingStyle.fill;
    final topPath = Path()
      ..moveTo(cx, cy - r - 2)
      ..lineTo(cx + 2, cy - r + 1)
      ..lineTo(cx, cy - r + 4)
      ..lineTo(cx - 2, cy - r + 1)
      ..close();
    canvas.drawPath(topPath, diamondPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================
// Wave Diamond Painter - Decorative wave lines with diamond center
// ============================================================
class _WaveDiamondPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withOpacity(0.20);

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withOpacity(0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    // Diamond size
    const diamondSize = 5.0;
    const gap = 10.0; // gap between diamond and wave start

    // ── Left wave (swoops down then up) ──
    final leftPath = Path();
    final leftStart = centerX - gap - diamondSize;
    leftPath.moveTo(leftStart, centerY);
    // Graceful S-curve going left
    leftPath.cubicTo(
      leftStart - 20, centerY + 8,   // control point 1 - dip down
      leftStart - 45, centerY - 6,   // control point 2 - curve up
      leftStart - 70, centerY,       // end point
    );

    canvas.drawPath(leftPath, glowPaint);
    canvas.drawPath(leftPath, linePaint);

    // ── Right wave (swoops down then up, mirrored) ──
    final rightPath = Path();
    final rightStart = centerX + gap + diamondSize;
    rightPath.moveTo(rightStart, centerY);
    rightPath.cubicTo(
      rightStart + 20, centerY + 8,
      rightStart + 45, centerY - 6,
      rightStart + 70, centerY,
    );

    canvas.drawPath(rightPath, glowPaint);
    canvas.drawPath(rightPath, linePaint);

    // ── Center diamond (◇) ──
    final diamondPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = Colors.white.withOpacity(0.30);

    final diamondPath = Path()
      ..moveTo(centerX, centerY - diamondSize)
      ..lineTo(centerX + diamondSize, centerY)
      ..lineTo(centerX, centerY + diamondSize)
      ..lineTo(centerX - diamondSize, centerY)
      ..close();

    // Diamond glow
    final diamondGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.white.withOpacity(0.06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawPath(diamondPath, diamondGlow);
    canvas.drawPath(diamondPath, diamondPaint);

    // Small inner diamond dot
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.15);
    canvas.drawCircle(Offset(centerX, centerY), 1.2, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CornerArcPainter extends CustomPainter {
  final Color color;
  final int corner;
  _CornerArcPainter(this.color, this.corner);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..strokeCap = StrokeCap.round;
    final w = size.width;
    final h = size.height;
    switch (corner) {
      case 0:
        canvas.drawLine(Offset(0, h * 0.6), const Offset(0, 0), paint);
        canvas.drawLine(const Offset(0, 0), Offset(w * 0.6, 0), paint);
      case 1:
        canvas.drawLine(Offset(w, h * 0.6), Offset(w, 0), paint);
        canvas.drawLine(Offset(w, 0), Offset(w * 0.4, 0), paint);
      case 2:
        canvas.drawLine(Offset(0, h * 0.4), Offset(0, h), paint);
        canvas.drawLine(Offset(0, h), Offset(w * 0.6, h), paint);
      case 3:
        canvas.drawLine(Offset(w, h * 0.4), Offset(w, h), paint);
        canvas.drawLine(Offset(w, h), Offset(w * 0.4, h), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
