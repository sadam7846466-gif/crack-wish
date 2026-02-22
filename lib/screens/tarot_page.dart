// lib/screens/tarot_page.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

import '../widgets/bottom_nav.dart';
import '../widgets/fade_page_route.dart';
import '../services/storage_service.dart';
import 'root_shell.dart';

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
      frontAsset: 'assets/images/tarot/tarot/The Fool.jpeg',
    ),
    TarotCardDef(
      id: 1,
      nameTr: 'Büyücü',
      nameEn: 'The Magician',
      frontAsset: 'assets/images/tarot/tarot/The Magician.png',
    ),
    TarotCardDef(
      id: 2,
      nameTr: 'Başrahibe',
      nameEn: 'The High Priestess',
      frontAsset: 'assets/images/tarot/tarot/The High Priestess.png',
    ),
    TarotCardDef(
      id: 3,
      nameTr: 'İmparatoriçe',
      nameEn: 'The Empress',
      frontAsset: 'assets/images/tarot/tarot/The Empress.png',
    ),
    TarotCardDef(
      id: 4,
      nameTr: 'İmparator',
      nameEn: 'The Emperor',
      frontAsset: 'assets/images/tarot/tarot/The Emperor.png',
    ),
    TarotCardDef(
      id: 5,
      nameTr: 'Aziz',
      nameEn: 'The Hierophant',
      frontAsset: 'assets/images/tarot/tarot/The Hierophant.png',
    ),
    TarotCardDef(
      id: 6,
      nameTr: 'Aşıklar',
      nameEn: 'The Lovers',
      frontAsset: 'assets/images/tarot/tarot/The Lovers.png',
    ),
    TarotCardDef(
      id: 7,
      nameTr: 'Savaş Arabası',
      nameEn: 'The Chariot',
      frontAsset: 'assets/images/tarot/tarot/The Chariot.png',
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
      frontAsset: 'assets/images/tarot/tarot/The Hermit.png',
    ),
    TarotCardDef(
      id: 10,
      nameTr: 'Kader Çarkı',
      nameEn: 'Wheel of Fortune',
      frontAsset: 'assets/images/tarot/tarot/Wheel of Fortune.png',
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
      frontAsset: 'assets/images/tarot/tarot/The Hanged Man.png',
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
      frontAsset: 'assets/images/tarot/tarot/The Devil.png',
    ),
    TarotCardDef(
      id: 16,
      nameTr: 'Kule',
      nameEn: 'The Tower',
      frontAsset: 'assets/images/tarot/tarot/The Tower.png',
    ),
    TarotCardDef(
      id: 17,
      nameTr: 'Yıldız',
      nameEn: 'The Star',
      frontAsset: 'assets/images/tarot/tarot/The Star.png',
    ),
    TarotCardDef(
      id: 18,
      nameTr: 'Ay',
      nameEn: 'The Moon',
      frontAsset: 'assets/images/tarot/tarot/The Moon.png',
    ),
    TarotCardDef(
      id: 19,
      nameTr: 'Güneş',
      nameEn: 'The Sun',
      frontAsset: 'assets/images/tarot/tarot/The Sun.png',
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
      frontAsset: 'assets/images/tarot/tarot/The World.png',
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
  final int _tableCount = 22;

  // selection
  final List<int> _selectedTablePositions = [];
  final List<GlobalKey> _cardKeys = List<GlobalKey>.generate(
    22,
    (_) => GlobalKey(),
  );
  final List<GlobalKey> _slotKeys = List<GlobalKey>.generate(
    3,
    (_) => GlobalKey(),
  );
  bool _isSelecting = false;
  final Set<int> _hiddenCards = {};
  late final List<AnimationController> _slotGlowControllers;

  // reveal
  int _revealedCount = 0;
  late List<int> _selectedCardIndexes;

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
    _slotGlowControllers = List.generate(3, (_) => AnimationController(
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
      duration: const Duration(seconds: 15),
    )..repeat();

    _slotEntranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
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
    super.dispose();
  }

  Future<void> _bootstrap() async {
    _prefs = await SharedPreferences.getInstance();
    _loadGateAndStreak();
    _setStateSafe(() => _state = RitualState.idle);
    _updateCtaText();
    _slotEntranceCtrl.forward(from: 0.0);
    _onShufflePressed();
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

  Future<void> _commitAndReveal() async {
    final allowed = await _ensureAllowance();
    if (!allowed) {
      _setMiniStatus(_t('Bugünlük hakkın bitti', 'Daily limit reached'), ms: 900);
      return;
    }
    await _consumeAllowanceOnCommit();
    await _startReveal();
  }

  Future<void> _startReveal() async {
    HapticFeedback.mediumImpact();
    _setStateSafe(() {
      _isBusy = true;
      _state = RitualState.revealing;
      _revealedCount = 0;

      _selectedCardIndexes = _selectedTablePositions
          .map((pos) => _tableCards[pos])
          .toList();
    });
    _updateCtaText();

    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    for (int i = 0; i < 3; i++) {
      HapticFeedback.mediumImpact();
      _setStateSafe(() => _revealedCount = i + 1);
      await Future.delayed(const Duration(milliseconds: 420));
      if (!mounted) return;
    }

    _setStateSafe(() {
      _isBusy = false;
      _state = RitualState.revealed;
    });
    _updateCtaText();

    await _updateStreakOnCompleteRead();
    if (!mounted) return;
    _openReadingSheet();
  }

  // ======================
  // Reading generation
  // ======================
  Map<String, String> _makeReadingText() {
    final names = _selectedCardIndexes.map(_cardName).toList();
    final fallback = _t('Kart', 'Card');
    final a = names.isNotEmpty ? names[0] : fallback;
    final b = names.length > 1 ? names[1] : fallback;
    final c = names.length > 2 ? names[2] : fallback;

    String oneLiner;
    switch (_topic) {
      case TarotTopic.love:
        oneLiner = _t(
          'Kalbin netlik istiyor: $a → $b → $c çizgisinde doğru seçim açılıyor.',
          'Your heart seeks clarity: the right choice opens along $a → $b → $c.',
        );
        break;
      case TarotTopic.money:
        oneLiner = _t(
          'Bugün finansal yönde sadeleş: $a, sonra $b ile güçlen, $c ile sonucu al.',
          'Simplify finances today: $a, then strengthen with $b, and seal it with $c.',
        );
        break;
      case TarotTopic.career:
        oneLiner = _t(
          'Kariyerde anahtar: $a ile hazırlık, $b ile atılım, $c ile görünür başarı.',
          'Career key: prepare with $a, advance with $b, and gain visibility with $c.',
        );
        break;
      case TarotTopic.general:
        oneLiner = _t(
          'Günün mesajı: $a geçmişi kapatır, $b gücü toplar, $c yeni yolu açar.',
          'Today’s message: $a closes the past, $b gathers strength, $c opens a new path.',
        );
        break;
    }

    final love = _topic == TarotTopic.love
        ? _t(
            'Duyguların netleşiyor; acele etme, açık konuş.',
            'Your feelings are clarifying; do not rush, speak openly.',
          )
        : _t(
            'İlişkide denge: küçük bir adım büyük rahatlama getirir.',
            'Balance in relationships: a small step brings big relief.',
          );
    final money = _topic == TarotTopic.money
        ? _t(
            'Harcamayı kıs, tek hedefe odaklan; sabır kazandırır.',
            'Cut spending, focus on one goal; patience pays.',
          )
        : _t(
            'Parada sade plan: gereksizleri ele, istikrara dön.',
            'A simple money plan: remove the unnecessary, return to stability.',
          );
    final career = _topic == TarotTopic.career
        ? _t(
            'Görünür ol: tek işi bitir, sonra bir üst adım.',
            'Be visible: finish one task, then take the next step up.',
          )
        : _t(
            'İş tarafında netlik: kısa bir karar uzun huzur getirir.',
            'Clarity at work: a short decision brings long peace.',
          );

    return {
      'one': oneLiner,
      'love': love,
      'money': money,
      'career': career,
      'past': _t(
        '$a — seni buraya getiren yol. Öğrendiğin dersi unutma.',
        '$a — the path that brought you here. Do not forget the lesson.',
      ),
      'now': _t(
        '$b — mevcut enerjin. Sakin kal, gücün içeride.',
        '$b — your current energy. Stay calm, your strength is within.',
      ),
      'future': _t(
        '$c — olasılık. Küçük cesaret büyük kapı açar.',
        '$c — possibility. Small courage opens a big door.',
      ),
    };
  }

  // ======================
  // Save / Share
  // ======================
  Future<void> _saveToHistory() async {
    final reading = _makeReadingText();
    final today = _yyyyMmDd(DateTime.now());

    final item = <String, dynamic>{
      'ts': DateTime.now().millisecondsSinceEpoch,
      'date': today,
      'topic': _topic.name,
      'cards': _selectedCardIndexes
          .map((idx) => {'id': _allCards[idx].id, 'name': _cardName(idx)})
          .toList(),
      'oneLiner': reading['one'],
      'love': reading['love'],
      'money': reading['money'],
      'career': reading['career'],
    };

    final raw = _prefs.getString(_kHistory);
    final List<dynamic> list = raw == null
        ? []
        : (jsonDecode(raw) as List<dynamic>);
    list.insert(0, item);

    if (list.length > 200) {
      list.removeRange(200, list.length);
    }

    await _prefs.setString(_kHistory, jsonEncode(list));
    await StorageService.setTarotDoneToday();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✨ Kaydedildi'),
        backgroundColor: const Color(0xFF1A0E3B),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _shareResultCard() async {
    try {
      final boundary =
          _shareKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) return;

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/tarot_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: _t('🔮 Bugünün tarot mesajı', '🔮 Today’s tarot message'));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_t('Paylaşım başarısız', 'Share failed')),
          backgroundColor: const Color(0xFF1A0E3B),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openReadingSheet() {
    final reading = _makeReadingText();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return _GlassSheet(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              14,
              16,
              16 + MediaQuery.of(ctx).padding.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Kartların Yorumu',
                        style: GoogleFonts.unifrakturMaguntia(
                          color: const Color(0xFFE2C48E),
                          fontSize: 24,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.12),
                          ),
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white.withOpacity(0.75),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _t(
                      'Kartların sana bugün ne söylüyor…',
                      'What are the cards telling you today…',
                    ),
                    style: GoogleFonts.cormorantGaramond(
                      color: Colors.white.withOpacity(0.70),
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                RepaintBoundary(
                  key: _shareKey,
                  child: _ShareCard(
                    oneLiner: reading['one']!,
                    love: reading['love']!,
                    money: reading['money']!,
                    career: reading['career']!,
                    thumbAssets: _selectedCardIndexes
                        .map((i) => _safeFrontAsset(i))
                        .toList(),
                    backAsset: _cardBackAsset,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _saveToHistory,
                        icon: const Icon(Icons.star_border, size: 18),
                        label: const Text('Kaydet'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFE7D6A5),
                          side: BorderSide(
                            color: const Color(0xFFE7D6A5).withOpacity(0.5),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _shareResultCard,
                        icon: const Icon(Icons.ios_share, size: 18),
                        label: Text(_t('Paylaş', 'Share')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE7D6A5),
                          foregroundColor: const Color(0xFF0A0E1A),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                _DetailBlock(
                  title: _t('Geçmiş', 'Past'),
                  text: reading['past']!,
                  cardAsset: _safeFrontAsset(_selectedCardIndexes[0]),
                  backAsset: _cardBackAsset,
                  icon: Icons.nights_stay,
                ),
                const SizedBox(height: 10),
                _DetailBlock(
                  title: _t('Şimdi', 'Now'),
                  text: reading['now']!,
                  cardAsset: _safeFrontAsset(_selectedCardIndexes[1]),
                  backAsset: _cardBackAsset,
                  icon: Icons.wb_sunny,
                ),
                const SizedBox(height: 10),
                _DetailBlock(
                  title: 'Gelecek',
                  text: reading['future']!,
                  cardAsset: _safeFrontAsset(_selectedCardIndexes[2]),
                  backAsset: _cardBackAsset,
                  icon: Icons.auto_awesome,
                ),

                const SizedBox(height: 16),

                // Tekrar karıştır butonu
                GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    _resetToIdle();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE7D6A5).withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      _t('Tekrar Karıştır', 'Shuffle Again'),
                      style: const TextStyle(
                        color: Color(0xFFE7D6A5),
                        fontWeight: FontWeight.w600,
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
  }

  void _resetToIdle() {
    HapticFeedback.lightImpact();
    _setStateSafe(() {
      _state = RitualState.idle;
      _selectedTablePositions.clear();
      _revealedCount = 0;
      _selectedCardIndexes = [];
      _tableCards = [];
    });
    _updateCtaText();
  }

  Future<void> _selectCard(int index, GlobalKey cardKey) async {
    if (_isBusy || _isSelecting) return;
    if (_selectedTablePositions.length >= 3) return;
    if (_selectedTablePositions.contains(index)) return;
    if (_hiddenCards.contains(index)) return;

    final slotIndex = _selectedTablePositions.length;
    _isSelecting = true;
    
    // Hide the card from deck immediately
    setState(() => _hiddenCards.add(index));
    
    await _animateCardToSlot(cardKey, _slotKeys[slotIndex]);

    if (!mounted) return;
    setState(() {
      _selectedTablePositions.add(index);
      _hiddenCards.remove(index);
    });
    // Trigger glow on the filled slot
    _slotGlowControllers[slotIndex].forward(from: 0.0);
    _isSelecting = false;

    if (_selectedTablePositions.length == 3) {
      await _commitAndReveal();
    }
  }

  Future<void> _animateCardToSlot(GlobalKey fromKey, GlobalKey toKey) async {
    final overlay = Overlay.of(context);
    final fromBox = fromKey.currentContext?.findRenderObject() as RenderBox?;
    final toBox = toKey.currentContext?.findRenderObject() as RenderBox?;
    if (fromBox == null || toBox == null) return;

    final from = fromBox.localToGlobal(Offset.zero);
    final to = toBox.localToGlobal(Offset.zero);
    final fromSize = fromBox.size;
    final toSize = toBox.size;

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
        // Position: smooth lerp from card pos to slot pos
        final dx = ui.lerpDouble(from.dx, to.dx, t) ?? from.dx;
        final dy = ui.lerpDouble(from.dy, to.dy, t) ?? from.dy;
        // Arc lift: fades out near the end so card settles exactly at slot
        final lift = sin(t * pi) * -20 * (1.0 - t);
        // Size: interpolate from card size to slot size
        final w = ui.lerpDouble(fromSize.width, toSize.width, t) ?? fromSize.width;
        final h = ui.lerpDouble(fromSize.height, toSize.height, t) ?? fromSize.height;
        // No scale bounce — ends at exactly 1.0
        const scale = 1.0;
        // Flip: starts at 30% of animation
        final flip = t < 0.3 ? 0.0 : ((t - 0.3) / 0.7).clamp(0.0, 1.0);
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
              child: Transform.scale(
                scale: scale,
                child: SizedBox(
                  width: w,
                  height: h,
                  child: showFront ? _selectedCardView() : _tarotCard(),
                ),
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
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          _cardBackAsset,
          fit: BoxFit.fill,
          cacheWidth: 200,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(Icons.error, color: Colors.red),
          ),
        ),
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
        animation: _bgPulseCtrl,
        builder: (context, _) {
          final bv = _bgPulseCtrl.value; // 0‥1 ping‑pong
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
                      Color.fromRGBO(150, 64, 100, 0.45 + sin(bv * pi * 2) * 0.10),  // Kırmızı→erik moru
                      Color.fromRGBO(120, 50, 90, 0.25 + sin(bv * pi * 2) * 0.05),
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
                      Color.fromRGBO(180, 160, 210, 0.28 + sin(bv * pi * 2 + 1.5) * 0.08),  // Bej→lavanta
                      Color.fromRGBO(160, 140, 190, 0.14 + sin(bv * pi * 2 + 1.5) * 0.04),
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
                      Color.fromRGBO(120, 55, 110, 0.48 + sin(bv * pi * 2 + 0.8) * 0.08),  // Kırmızı→mor nebula
                      Color.fromRGBO(100, 45, 95, 0.28 + sin(bv * pi * 2 + 0.8) * 0.06),
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
                      Color.fromRGBO(42, 55, 108, 0.40 + sin(bv * pi * 2 + 2.5) * 0.08),  // Mavi→mor-mavi
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
                      Color.fromRGBO(85, 55, 140, 0.22 + sin(bv * pi * 2 + 3.8) * 0.06),  // Mor parıltı
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
                      const Color(0xFF1A1440).withOpacity(0.50),
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
                      const Expanded(
                        child: Text(
                            'Tarot',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
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
                  _t('Kartlarını seç', 'Pick your cards'),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 160,
                        child: AnimatedBuilder(
                          animation: Listenable.merge([_slotEntranceCtrl, ..._slotGlowControllers]),
                          builder: (_, __) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (i) {
                                final isFilled = _selectedTablePositions.length > i;
                                // Stagger: each slot enters with delay
                                final delay = i * 0.20;
                                final rawT = ((_slotEntranceCtrl.value - delay) / (1.0 - delay)).clamp(0.0, 1.0);
                                final scaleT = Curves.easeOutCubic.transform(rawT);
                                final fadeT = Curves.easeOutCubic.transform(rawT.clamp(0.0, 1.0));
                                final slideY = (1.0 - fadeT) * 28.0;

                                // Glow animation
                                final animGlow = 1.0 - _slotGlowControllers[i].value;
                                final baseGlow = isFilled ? 0.2 : 0.0;
                                final totalGlow = (baseGlow + animGlow * 0.8).clamp(0.0, 1.0);
                                final borderColor = Color.lerp(
                                  Colors.white.withOpacity(isFilled ? 0.15 : 0.08),
                                  const Color(0xFFE7D6A5),
                                  totalGlow,
                                )!;
                                final borderWidth = 0.8 + totalGlow * 0.7;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Transform.translate(
                                    offset: Offset(0, slideY),
                                    child: Opacity(
                                      opacity: fadeT,
                                      child: Transform.scale(
                                        scale: scaleT,
                                        child: Container(
                                          key: _slotKeys[i],
                                          width: 88,
                                          height: 138,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(isFilled ? 4 : 16),
                                            border: isFilled ? null : Border.all(
                                              color: borderColor,
                                              width: borderWidth,
                                            ),
                                            boxShadow: totalGlow > 0.05 ? [
                                              BoxShadow(
                                                color: const Color(0xFFE7D6A5).withOpacity(0.15 * totalGlow),
                                                blurRadius: 6 * totalGlow,
                                              ),
                                            ] : null,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(isFilled ? 4 : 15),
                                            child: BackdropFilter(
                                              filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                                              child: Container(
                                                color: Colors.white.withOpacity(isFilled ? 0.0 : 0.08),
                                                child: isFilled
                                                    ? Image.asset(
                                                        (_state == RitualState.revealed || _state == RitualState.revealing) && _revealedCount > i
                                                            ? _safeFrontAsset(_selectedCardIndexes[i])
                                                            : _cardBackAsset,
                                                        fit: BoxFit.fill,
                                                        cacheWidth: 200,
                                                      )
                                                    : Center(
                                                        child: Icon(
                                                          Icons.add_rounded,
                                                          size: 22,
                                                          color: Colors.white.withOpacity(0.20),
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
                              }),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      _FloatingTarotDeck(
                        onCardTap: _selectCard,
                        cardBuilder: _tarotCard,
                        cardKeys: _cardKeys,
                        selectedPositions: _selectedTablePositions,
                        hiddenCards: _hiddenCards,
                      ),
                      // Büyük Arkana / Tam Arkana buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  // TODO: Büyük Arkana seçimi
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: BackdropFilter(
                                    filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                    child: Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.10),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: Colors.white24),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Büyük Arkana',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
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
                                  // TODO: Tam Arkana seçimi
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: BackdropFilter(
                                    filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                    child: Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.06),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: Colors.white12),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Tam Arkana',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
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
                      const Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_state == RitualState.revealing || _state == RitualState.revealed)
            _RevealOverlay(
              backAsset: _cardBackAsset,
              selectedFrontAssets: _selectedCardIndexes
                  .map(_safeFrontAsset)
                  .toList(),
              selectedNames: _selectedCardIndexes
                  .map(_cardName)
                  .toList(),
              revealedCount: _revealedCount,
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

class _RevealOverlay extends StatelessWidget {
  final String backAsset;
  final List<String> selectedFrontAssets;
  final List<String> selectedNames;
  final int revealedCount;

  const _RevealOverlay({
    required this.backAsset,
    required this.selectedFrontAssets,
    required this.selectedNames,
    required this.revealedCount,
  });

  @override
  Widget build(BuildContext context) {
    final index = (revealedCount.clamp(1, 3) - 1);
    final showIndex = index < 0 ? 0 : index;
    final title = selectedNames.isNotEmpty ? selectedNames[showIndex] : '';

    return Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC9A24E).withOpacity(0.45),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: _CardImage(
                  asset: selectedFrontAssets.isNotEmpty
                      ? selectedFrontAssets[showIndex]
                      : backAsset,
                  width: 190,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.unifrakturMaguntia(
                  color: const Color(0xFFE2C48E),
                  fontSize: 28,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GlassSheet extends StatelessWidget {
  final Widget child;
  const _GlassSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF101428).withOpacity(0.82),
              border: Border(
                top: BorderSide(
                  color: const Color(0xFFE2C48E).withOpacity(0.2),
                ),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _ShareCard extends StatelessWidget {
  final String oneLiner;
  final String love;
  final String money;
  final String career;
  final List<String> thumbAssets;
  final String backAsset;

  const _ShareCard({
    required this.oneLiner,
    required this.love,
    required this.money,
    required this.career,
    required this.thumbAssets,
    required this.backAsset,
  });

  @override
  Widget build(BuildContext context) {
    String t(String tr, String en) =>
        Localizations.localeOf(context).languageCode == 'tr' ? tr : en;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2C48E).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('Bugünün ana mesajı:', 'Today’s main message:'),
            style: GoogleFonts.cormorantGaramond(
              color: Colors.white.withOpacity(0.60),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            oneLiner,
            style: GoogleFonts.cormorantGaramond(
              color: const Color(0xFFE2C48E),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          _MiniLine(label: t('Aşk', 'Love'), text: love),
          _MiniLine(label: t('Para', 'Money'), text: money),
          _MiniLine(label: t('Kariyer', 'Career'), text: career),
          const SizedBox(height: 12),
          Row(
            children: thumbAssets.take(3).map((a) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.asset(
                    a,
                    width: 40,
                    height: 62,
                    fit: BoxFit.fill,
                    cacheWidth: 200,
                    errorBuilder: (_, __, ___) => Image.asset(
                      backAsset,
                      width: 40,
                      height: 62,
                      fit: BoxFit.fill,
                      cacheWidth: 200,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _MiniLine extends StatelessWidget {
  final String label;
  final String text;
  const _MiniLine({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Text(
              label,
              style: GoogleFonts.cormorantGaramond(
                color: const Color(0xFFE2C48E),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.cormorantGaramond(
                color: Colors.white.withOpacity(0.75),
                height: 1.25,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailBlock extends StatelessWidget {
  final String title;
  final String text;
  final String cardAsset;
  final String backAsset;
  final IconData icon;

  const _DetailBlock({
    required this.title,
    required this.text,
    required this.cardAsset,
    required this.backAsset,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(
              cardAsset,
              width: 50,
              height: 78,
              fit: BoxFit.fill,
              cacheWidth: 200,
              errorBuilder: (_, __, ___) => Image.asset(
                backAsset,
                width: 50,
                height: 78,
                fit: BoxFit.fill,
                cacheWidth: 200,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: const Color(0xFFE2C48E), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: GoogleFonts.cormorantGaramond(
                        color: const Color(0xFFE2C48E),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: GoogleFonts.cormorantGaramond(
                    color: Colors.white.withOpacity(0.70),
                    height: 1.35,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
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
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  int? _hitTestCard(Offset localPos) {
    // Check inner layer first (drawn on top)
    final totalCards = widget.cardKeys.length.clamp(0, 22);
    // Reverse iterate so top-drawn cards get priority
    for (int i = totalCards - 1; i >= 0; i--) {
      final rect = _cardRects[i];
      if (rect == null) continue;
      if (widget.selectedPositions.contains(i) || widget.hiddenCards.contains(i)) continue;
      // Expand hit area slightly for easier touch
      if (rect.inflate(4).contains(localPos)) return i;
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
    final totalCards = widget.cardKeys.length.clamp(0, 22);
    
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
              const cardW = 56.0;
              const cardH = 56.0 * (138.0 / 88.0); // match slot ratio (88:138)

              final cards = <Widget>[];
              _cardRects.clear();

              // 2 layers: 13 outer, 9 inner
              const outerCount = 13;
              final innerCount = totalCards - outerCount;
              
              const fanAngle = 200.0;
              final outerRadius = height * 0.38;
              final innerRadius = height * 0.26;
              
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
                        child: GestureDetector(
                          onTap: () {
                            widget.onCardTap(cardIdx, cardKey);
                          },
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
                  ),
                );
              }

              // --- Outer layer (drawn first = behind) ---
              final outerStep = fanAngle / (outerCount - 1);
              final outerStart = -90.0 - (fanAngle / 2);
              
              for (int i = 0; i < outerCount; i++) {
                final cardIdx = i;
                final angleDeg = outerStart + (i * outerStep);
                final angleRad = angleDeg * (pi / 180);
                final floatY = sin(_controller.value * 2 * pi + cardIdx * 0.5) * 4.0
                    + sin(_controller.value * 2 * pi * 2 + cardIdx * 0.8) * 2.0;
                final floatX = cos(_controller.value * 2 * pi + cardIdx * 0.6) * 2.5;
                
                final x = centerX + cos(angleRad) * outerRadius - (cardW / 2) + floatX;
                final y = centerY + sin(angleRad) * outerRadius - (cardH / 2) + floatY;
                final cardRotation = (angleDeg + 90) * (pi / 180);

                cards.add(buildCard(cardIdx, x, y, cardRotation, 0.92));
              }

              // --- Inner layer (drawn second = in front) ---
              final innerStep = fanAngle / (innerCount - 1);
              final innerStart = -90.0 - (fanAngle / 2);
              
              for (int i = 0; i < innerCount; i++) {
                final cardIdx = outerCount + i;
                final angleDeg = innerStart + (i * innerStep);
                final angleRad = angleDeg * (pi / 180);
                final floatY = sin(_controller.value * 2 * pi + cardIdx * 0.5) * 5.0
                    + sin(_controller.value * 2 * pi * 2 + cardIdx * 0.9) * 2.5;
                final floatX = cos(_controller.value * 2 * pi + cardIdx * 0.7) * 3.0;
                
                final x = centerX + cos(angleRad) * innerRadius - (cardW / 2) + floatX;
                final y = centerY + sin(angleRad) * innerRadius - (cardH / 2) + floatY;
                final cardRotation = (angleDeg + 90) * (pi / 180);

                cards.add(buildCard(cardIdx, x, y, cardRotation, 1.0));
              }

              // Center button - "Rastgele Çek"
              cards.add(
                Positioned(
                  left: centerX - 44,
                  top: centerY - 44,
                  child: GestureDetector(
                    onTap: () {
                      // Pick a random unselected card
                      final available = List.generate(totalCards, (i) => i)
                          .where((i) => !widget.selectedPositions.contains(i))
                          .toList();
                      if (available.isEmpty) return;
                      available.shuffle();
                      final pick = available.first;
                      widget.onCardTap(pick, widget.cardKeys[pick]);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(44),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                              width: 0.8,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Rastgele\nÇek',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
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


