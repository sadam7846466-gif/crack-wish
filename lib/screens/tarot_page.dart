// lib/screens/tarot_page.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

import '../widgets/bottom_nav.dart';
import '../widgets/fade_page_route.dart';
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
  final String _cardBackAsset = 'assets/images/tarot/tarot_back.png';
  final List<TarotCardDef> _allCards = [
    TarotCardDef(
      id: 0,
      nameTr: 'Deli',
      nameEn: 'The Fool',
      frontAsset: 'assets/images/tarot/(The Fool).png',
    ),
    TarotCardDef(
      id: 1,
      nameTr: 'Büyücü',
      nameEn: 'The Magician',
      frontAsset: 'assets/images/tarot/(The Magician).png',
    ),
    TarotCardDef(
      id: 2,
      nameTr: 'Başrahibe',
      nameEn: 'The High Priestess',
      frontAsset: 'assets/images/tarot/(The High Priestess).png',
    ),
    TarotCardDef(
      id: 3,
      nameTr: 'İmparatoriçe',
      nameEn: 'The Empress',
      frontAsset: 'assets/images/tarot/(The Empress).png',
    ),
    TarotCardDef(
      id: 4,
      nameTr: 'İmparator',
      nameEn: 'The Emperor',
      frontAsset: 'assets/images/tarot/(The Emperor).png',
    ),
    TarotCardDef(
      id: 5,
      nameTr: 'Aziz',
      nameEn: 'The Hierophant',
      frontAsset: 'assets/images/tarot/(The Hierophant).png',
    ),
    TarotCardDef(
      id: 6,
      nameTr: 'Aşıklar',
      nameEn: 'The Lovers',
      frontAsset: 'assets/images/tarot/(The Lovers).png',
    ),
    TarotCardDef(
      id: 7,
      nameTr: 'Savaş Arabası',
      nameEn: 'The Chariot',
      frontAsset: 'assets/images/tarot/(The Chariot).png',
    ),
    TarotCardDef(
      id: 8,
      nameTr: 'Güç',
      nameEn: 'Strength',
      frontAsset: 'assets/images/tarot/(Strength).png',
    ),
    TarotCardDef(
      id: 9,
      nameTr: 'Ermiş',
      nameEn: 'The Hermit',
      frontAsset: 'assets/images/tarot/(The Hermit).png',
    ),
    TarotCardDef(
      id: 10,
      nameTr: 'Kader Çarkı',
      nameEn: 'Wheel of Fortune',
      frontAsset: 'assets/images/tarot/(Wheel of Fortune).png',
    ),
    TarotCardDef(
      id: 11,
      nameTr: 'Adalet',
      nameEn: 'Justice',
      frontAsset: 'assets/images/tarot/(Justice).png',
    ),
    TarotCardDef(
      id: 12,
      nameTr: 'Asılan Adam',
      nameEn: 'The Hanged Man',
      frontAsset: 'assets/images/tarot/(The Hanged Man).png',
    ),
    TarotCardDef(
      id: 13,
      nameTr: 'Ölüm',
      nameEn: 'Death',
      frontAsset: 'assets/images/tarot/(Death).png',
    ),
    TarotCardDef(
      id: 14,
      nameTr: 'Denge',
      nameEn: 'Temperance',
      frontAsset: 'assets/images/tarot/(Temperance).png',
    ),
    TarotCardDef(
      id: 15,
      nameTr: 'Şeytan',
      nameEn: 'The Devil',
      frontAsset: 'assets/images/tarot/(The Devil).png',
    ),
    TarotCardDef(
      id: 16,
      nameTr: 'Kule',
      nameEn: 'The Tower',
      frontAsset: 'assets/images/tarot/(The Tower).png',
    ),
    TarotCardDef(
      id: 17,
      nameTr: 'Yıldız',
      nameEn: 'The Star',
      frontAsset: 'assets/images/tarot/(The Star).png',
    ),
    TarotCardDef(
      id: 18,
      nameTr: 'Ay',
      nameEn: 'The Moon',
      frontAsset: 'assets/images/tarot/(The Moon).png',
    ),
    TarotCardDef(
      id: 19,
      nameTr: 'Güneş',
      nameEn: 'The Sun',
      frontAsset: 'assets/images/tarot/(The Sun).png',
    ),
    TarotCardDef(
      id: 20,
      nameTr: 'Yargı',
      nameEn: 'Judgement',
      frontAsset: 'assets/images/tarot/(Judgement).png',
    ),
    TarotCardDef(
      id: 21,
      nameTr: 'Dünya',
      nameEn: 'The World',
      frontAsset: 'assets/images/tarot/(The World).png',
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
    _fogCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    _bgPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

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
    super.dispose();
  }

  Future<void> _bootstrap() async {
    _prefs = await SharedPreferences.getInstance();
    _loadGateAndStreak();
    _setStateSafe(() => _state = RitualState.idle);
    _updateCtaText();
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

    final slotIndex = _selectedTablePositions.length;
    _isSelecting = true;
    await _animateCardToSlot(cardKey, _slotKeys[slotIndex]);

    if (!mounted) return;
    setState(() => _selectedTablePositions.add(index));
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
    final size = fromBox.size;

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    final curve = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOutCubic,
    );

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) {
        final t = curve.value;
        final dx = ui.lerpDouble(from.dx, to.dx, t) ?? from.dx;
        final dy = ui.lerpDouble(from.dy, to.dy, t) ?? from.dy;
        final lift = sin(t * pi) * -24;
        final scale = t < 0.85
            ? (ui.lerpDouble(1.0, 0.95, t) ?? 1.0)
            : (ui.lerpDouble(0.95, 1.03, (t - 0.85) / 0.15) ?? 1.0);
        final flip = t < 0.6 ? 0.0 : (t - 0.6) / 0.4;
        final showFront = t >= 0.6;

        return Positioned(
          left: dx,
          top: dy + lift,
          child: IgnorePointer(
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(flip * pi),
              child: Transform.scale(
                scale: scale,
                child: SizedBox(
                  width: size.width,
                  height: size.height,
                  child: showFront ? _selectedCardView() : _tarotCard(),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);
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
      width: 78,
      height: 122,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4B0082), Color(0xFF301958), Color(0xFF1E0F3C)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD4A5FF).withOpacity(0.3)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 14,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFD4A5FF).withOpacity(0.2)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF4B0082).withOpacity(0.3),
              const Color(0xFF301958).withOpacity(0.5),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFD4A5FF).withOpacity(0.3),
                    const Color(0xFF8A2BE2).withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFFD4A5FF).withOpacity(0.3),
                ),
              ),
              child: const Icon(
                Icons.nights_stay,
                size: 16,
                color: Color(0xFFD4A5FF),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'TAROT',
              style: TextStyle(
                fontSize: 7,
                letterSpacing: 1,
                color: const Color(0xFFD4A5FF).withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptySlot() {
    return Container(
      width: 78,
      height: 122,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFD4A5FF).withOpacity(0.3),
          width: 2,
        ),
      ),
    );
  }

  Widget _selectedCardView() {
    return Container(
      width: 78,
      height: 122,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A1A4A), Color(0xFF1A0A2E)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFD4A5FF).withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20),
        ],
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
      backgroundColor: const Color(0xFF120A1F),
      body: Stack(
        children: [
          // Background gradient (no image)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1B0B2A),
                    Color(0xFF2B123F),
                    Color(0xFF3A1B54),
                  ],
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),

          // Soft nebula glow (adds depth)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.0, 0.15),
                    radius: 0.85,
                    colors: [Color(0x663C1A5A), Color(0x001B0B2A)],
                    stops: [0.0, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Secondary nebula glow (adds space depth)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.35, 0.35),
                    radius: 0.95,
                    colors: [Color(0x442A0F46), Color(0x001B0B2A)],
                    stops: [0.0, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Background image (full screen)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgPulseCtrl,
              builder: (_, __) {
                return Opacity(
                  opacity: 0.95 + _bgPulseCtrl.value * 0.05,
                  child: Image.asset(
                    'assets/images/tarot/falcı.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                );
              },
            ),
          ),

          // Stars + dust (procedural, no image)
          Positioned.fill(child: _StarsEffect(animation: _starsCtrl)),

          // Fog layer (disabled for now)
          // Positioned.fill(child: _FogEffect(animation: _fogCtrl)),

          // Dark overlay at top for text visibility
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 260,
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0A0510), Color(0x000A0510)],
                  ),
                ),
              ),
            ),
          ),

          // Hanging decorations (fixed positions)
          _buildIp(1, _ip1Top, _ip1Left),
          _buildIp(2, _ip2Top, _ip2Left),
          _buildIp(3, _ip3Top, _ip3Left),
          _buildIp(4, _ip4Top, _ip4Left),
          _buildIp(5, _ip5Top, _ip5Left),
          _buildIp(6, _ip6Top, _ip6Left),
          _buildIp(7, _ip7Top, _ip7Left, height: 200),
          _buildIp(8, _ip8Top, _ip8Left),

          // Vignette overlay
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.1,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.35),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 22),

                // Title
                const Text(
                  'Tarot',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _t('Kartlarını seç', 'Pick your cards'),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 10),
                AnimatedOpacity(
                  opacity: _miniStatusText.isEmpty ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 180),
                  child: Text(
                    _miniStatusText,
                    style: TextStyle(
                      color: const Color(0xFFE7D6A5).withOpacity(0.85),
                      fontSize: 13,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: Column(
                    children: [
                      _glassPanel(
                        child: SizedBox(
                          height: 150,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (i) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: SizedBox(
                                  key: _slotKeys[i],
                                  child: _selectedTablePositions.length > i
                                      ? _selectedCardView()
                                      : _emptySlot(),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                      const Spacer(),
                      _FloatingTarotDeck(
                        onCardTap: _selectCard,
                        cardBuilder: _tarotCard,
                        cardKeys: _cardKeys,
                      ),
                      const SizedBox(height: 20),
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
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (index == _currentNavIndex) return;
          setState(() => _currentNavIndex = index);
          Navigator.pushReplacement(
            context,
            FadePageRoute(page: RootShell(initialIndex: index)),
          );
        },
      ),
    );
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
    // Faint background dust
    for (int i = 0; i < 12000; i++) {
      final phase = (i % 97) * 0.18;
      final driftX = sin(t * 2 * pi + phase) * 2.2;
      final driftY = cos(t * 2 * pi + phase) * 2.2;
      final x = random.nextDouble() * size.width + driftX;
      // Bias toward top (more stars at top)
      final yRaw = random.nextDouble();
      final yBiased = yRaw * yRaw; // Square makes it denser at top
      final y = yBiased * size.height + driftY;
      final radius = random.nextDouble() * 0.18 + 0.05;
      final opacity = random.nextDouble() * 0.06 + 0.012;
      final twinkle = 0.75 + 0.25 * sin((i % 37) * 0.4 + t * 2 * pi);
      starPaint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius * twinkle, starPaint);
    }

    // Brighter stars with soft glow
    for (int i = 0; i < 2200; i++) {
      final phase = (i % 67) * 0.22;
      final driftX = sin(t * 2 * pi + phase) * 3.4;
      final driftY = cos(t * 2 * pi + phase) * 3.4;
      final x = random.nextDouble() * size.width + driftX;
      // Bias toward top (more stars at top)
      final yRaw = random.nextDouble();
      final yBiased = yRaw * yRaw;
      final y = yBiased * size.height + driftY;
      final radius = random.nextDouble() * 0.5 + 0.15;
      final opacity = random.nextDouble() * 0.28 + 0.10;
      final glowRadius = radius * 2.0;
      final glowOpacity =
          opacity * (0.32 + 0.12 * sin((i % 29) * 0.6 + t * 2 * pi));

      glowPaint.color = Colors.white.withOpacity(glowOpacity);
      canvas.drawCircle(Offset(x, y), glowRadius, glowPaint);

      starPaint.color = Colors.white.withOpacity(opacity);
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
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        asset,
        width: width,
        fit: BoxFit.cover,
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
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    a,
                    width: 40,
                    height: 62,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      backAsset,
                      width: 40,
                      height: 62,
                      fit: BoxFit.cover,
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
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              cardAsset,
              width: 50,
              height: 78,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset(
                backAsset,
                width: 50,
                height: 78,
                fit: BoxFit.cover,
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
  const _FloatingTarotDeck({
    required this.onCardTap,
    required this.cardBuilder,
    required this.cardKeys,
  });

  @override
  State<_FloatingTarotDeck> createState() => _FloatingTarotDeckState();
}

class _FloatingTarotDeckState extends State<_FloatingTarotDeck>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<int> _rowSizes = [7, 7, 8];
  int? _pressedIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              final centerX = width / 2;
              final centerY = height * 0.76;
              const cardW = 78.0;
              const cardH = 122.0;

              final layerAngles = [100.0, 85.0, 70.0];
              final layerRadii = [height * 0.43, height * 0.32, height * 0.21];
              final layerScales = [1.0, 0.97, 0.94];

              int cardIndex = 0;
              final cards = <Widget>[];

              for (int layer = 0; layer < _rowSizes.length; layer++) {
                final count = _rowSizes[layer];
                final angle = layerAngles[layer];
                final step = angle / (count - 1);
                final start = -90.0 - (angle / 2);
                final radius = layerRadii[layer];

                for (int i = 0; i < count; i++) {
                  final angleDeg = start + (i * step);
                  final angleRad = angleDeg * (pi / 180);
                  final x = centerX + cos(angleRad) * radius - (cardW / 2);
                  final baseY = centerY + sin(angleRad) * radius - (cardH / 2);
                  final floatY =
                      sin(_controller.value * 2 * pi + cardIndex) * 1.2;
                  final y = baseY + floatY;
                  final rotation = (angleDeg + 90) * (pi / 180);
                  final indexForTap = cardIndex;
                  final cardKey = widget.cardKeys[indexForTap];
                  final scale = layerScales[layer];
                  cardIndex++;
                  final isPressed = _pressedIndex == indexForTap;

                  cards.add(
                    Positioned(
                      left: x,
                      top: y,
                      child: Transform(
                        alignment: Alignment.bottomCenter,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateX(0.95),
                        child: Transform.rotate(
                          angle: rotation,
                          alignment: Alignment.center,
                          child: Transform.scale(
                            scale: scale,
                            child: AnimatedScale(
                              scale: isPressed ? 1.03 : 1.0,
                              duration: const Duration(milliseconds: 120),
                              curve: Curves.easeOut,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 120),
                                transform: Matrix4.translationValues(
                                  0,
                                  isPressed ? -4 : 0,
                                  0,
                                ),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    if (isPressed)
                                      BoxShadow(
                                        color: const Color(
                                          0xFFD4A5FF,
                                        ).withOpacity(0.25),
                                        blurRadius: 18,
                                        spreadRadius: 2,
                                      ),
                                  ],
                                ),
                                child: GestureDetector(
                                  onTapDown: (_) {
                                    setState(() => _pressedIndex = indexForTap);
                                  },
                                  onTapUp: (_) {
                                    setState(() => _pressedIndex = null);
                                  },
                                  onTapCancel: () {
                                    setState(() => _pressedIndex = null);
                                  },
                                  onTap: () {
                                    setState(() => _pressedIndex = null);
                                    widget.onCardTap(indexForTap, cardKey);
                                  },
                                  child: KeyedSubtree(
                                    key: cardKey,
                                    child: widget.cardBuilder(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              }

              return Stack(children: cards);
            },
          );
        },
      ),
    );
  }
}
