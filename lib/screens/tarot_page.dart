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
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../widgets/glass_back_button.dart';
import '../widgets/swipe_back_wrapper.dart';
import '../widgets/tarot_share_modal.dart';
import 'tarot_meanings.dart';
import '../services/user_stats_service.dart';

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
  final String _cardBackAsset = 'assets/images/tarot/tarot/card_back.webp';
  final List<TarotCardDef> _allCards = [
    TarotCardDef(
      id: 0,
      nameTr: 'Deli',
      nameEn: 'The Fool',
      frontAsset: 'assets/images/tarot/tarot/The_Fool.webp',
    ),
    TarotCardDef(
      id: 1,
      nameTr: 'Büyücü',
      nameEn: 'The Magician',
      frontAsset: 'assets/images/tarot/tarot/The_Magician.webp',
    ),
    TarotCardDef(
      id: 2,
      nameTr: 'Başrahibe',
      nameEn: 'The High Priestess',
      frontAsset: 'assets/images/tarot/tarot/The_High_Priestess.webp',
    ),
    TarotCardDef(
      id: 3,
      nameTr: 'İmparatoriçe',
      nameEn: 'The Empress',
      frontAsset: 'assets/images/tarot/tarot/The_Empress.webp',
    ),
    TarotCardDef(
      id: 4,
      nameTr: 'İmparator',
      nameEn: 'The Emperor',
      frontAsset: 'assets/images/tarot/tarot/The_Emperor.webp',
    ),
    TarotCardDef(
      id: 5,
      nameTr: 'Aziz',
      nameEn: 'The Hierophant',
      frontAsset: 'assets/images/tarot/tarot/The_Hierophant.webp',
    ),
    TarotCardDef(
      id: 6,
      nameTr: 'Aşıklar',
      nameEn: 'The Lovers',
      frontAsset: 'assets/images/tarot/tarot/The_Lovers.webp',
    ),
    TarotCardDef(
      id: 7,
      nameTr: 'Savaş Arabası',
      nameEn: 'The Chariot',
      frontAsset: 'assets/images/tarot/tarot/The_Chariot.webp',
    ),
    TarotCardDef(
      id: 8,
      nameTr: 'Güç',
      nameEn: 'Strength',
      frontAsset: 'assets/images/tarot/tarot/Strength.webp',
    ),
    TarotCardDef(
      id: 9,
      nameTr: 'Ermiş',
      nameEn: 'The Hermit',
      frontAsset: 'assets/images/tarot/tarot/The_Hermit.webp',
    ),
    TarotCardDef(
      id: 10,
      nameTr: 'Kader Çarkı',
      nameEn: 'Wheel of Fortune',
      frontAsset: 'assets/images/tarot/tarot/Wheel_of_Fortune.webp',
    ),
    TarotCardDef(
      id: 11,
      nameTr: 'Adalet',
      nameEn: 'Justice',
      frontAsset: 'assets/images/tarot/tarot/Justice.webp',
    ),
    TarotCardDef(
      id: 12,
      nameTr: 'Asılan Adam',
      nameEn: 'The Hanged Man',
      frontAsset: 'assets/images/tarot/tarot/The_Hanged_Man.webp',
    ),
    TarotCardDef(
      id: 13,
      nameTr: 'Ölüm',
      nameEn: 'Death',
      frontAsset: 'assets/images/tarot/tarot/Death.webp',
    ),
    TarotCardDef(
      id: 14,
      nameTr: 'Denge',
      nameEn: 'Temperance',
      frontAsset: 'assets/images/tarot/tarot/Temperance.webp',
    ),
    TarotCardDef(
      id: 15,
      nameTr: 'Şeytan',
      nameEn: 'The Devil',
      frontAsset: 'assets/images/tarot/tarot/The_Devil.webp',
    ),
    TarotCardDef(
      id: 16,
      nameTr: 'Kule',
      nameEn: 'The Tower',
      frontAsset: 'assets/images/tarot/tarot/The_Tower.webp',
    ),
    TarotCardDef(
      id: 17,
      nameTr: 'Yıldız',
      nameEn: 'The Star',
      frontAsset: 'assets/images/tarot/tarot/The_Star.webp',
    ),
    TarotCardDef(
      id: 18,
      nameTr: 'Ay',
      nameEn: 'The Moon',
      frontAsset: 'assets/images/tarot/tarot/The_Moon.webp',
    ),
    TarotCardDef(
      id: 19,
      nameTr: 'Güneş',
      nameEn: 'The Sun',
      frontAsset: 'assets/images/tarot/tarot/The_Sun.webp',
    ),
    TarotCardDef(
      id: 20,
      nameTr: 'Yargı',
      nameEn: 'Judgement',
      frontAsset: 'assets/images/tarot/tarot/Judgement.webp',
    ),
    TarotCardDef(
      id: 21,
      nameTr: 'Dünya',
      nameEn: 'The World',
      frontAsset: 'assets/images/tarot/tarot/The_World.webp',
    ),
    // ============================================================
    // MINOR ARCANA — CUPS (Kâseler) — 14 kart (id: 22–35)
    // ============================================================
    TarotCardDef(id: 22, nameTr: 'Kâselerin Ası', nameEn: 'Ace of Cups', frontAsset: 'assets/images/tarot/tarot/Ace_of_Cups.webp'),
    TarotCardDef(id: 23, nameTr: 'Kâselerin İkisi', nameEn: 'Two of Cups', frontAsset: 'assets/images/tarot/tarot/Two_of_Cups.webp'),
    TarotCardDef(id: 24, nameTr: 'Kâselerin Üçü', nameEn: 'Three of Cups', frontAsset: 'assets/images/tarot/tarot/Three_of_Cups.webp'),
    TarotCardDef(id: 25, nameTr: 'Kâselerin Dörtü', nameEn: 'Four of Cups', frontAsset: 'assets/images/tarot/tarot/Four_of_Cups.webp'),
    TarotCardDef(id: 26, nameTr: 'Kâselerin Beşi', nameEn: 'Five of Cups', frontAsset: 'assets/images/tarot/tarot/Five_of_Cups.webp'),
    TarotCardDef(id: 27, nameTr: 'Kâselerin Altısı', nameEn: 'Six of Cups', frontAsset: 'assets/images/tarot/tarot/Six_of_Cups.webp'),
    TarotCardDef(id: 28, nameTr: 'Kâselerin Yedisi', nameEn: 'Seven of Cups', frontAsset: 'assets/images/tarot/tarot/Seven_of_Cups.webp'),
    TarotCardDef(id: 29, nameTr: 'Kâselerin Sekizi', nameEn: 'Eight of Cups', frontAsset: 'assets/images/tarot/tarot/Eight_of_Cups.webp'),
    TarotCardDef(id: 30, nameTr: 'Kâselerin Dokuzu', nameEn: 'Nine of Cups', frontAsset: 'assets/images/tarot/tarot/Nine_of_Cups.webp'),
    TarotCardDef(id: 31, nameTr: 'Kâselerin Onu', nameEn: 'Ten of Cups', frontAsset: 'assets/images/tarot/tarot/Ten_of_Cups.webp'),
    TarotCardDef(id: 32, nameTr: 'Kâselerin Uşağı', nameEn: 'Page of Cups', frontAsset: 'assets/images/tarot/tarot/Page_of_Cups.webp'),
    TarotCardDef(id: 33, nameTr: 'Kâselerin Şövalyesi', nameEn: 'Knight of Cups', frontAsset: 'assets/images/tarot/tarot/Knight_of_Cups.webp'),
    TarotCardDef(id: 34, nameTr: 'Kâselerin Kraliçesi', nameEn: 'Queen of Cups', frontAsset: 'assets/images/tarot/tarot/Queen_of_Cups.webp'),
    TarotCardDef(id: 35, nameTr: 'Kâselerin Kralı', nameEn: 'King of Cups', frontAsset: 'assets/images/tarot/tarot/King_of_Cups.webp'),
    // ============================================================
    // MINOR ARCANA — WANDS (Asalar) — 14 kart (id: 36–49)
    // ============================================================
    TarotCardDef(id: 36, nameTr: 'Asaların Ası', nameEn: 'Ace of Wands', frontAsset: 'assets/images/tarot/tarot/Ace_of_Wands.webp'),
    TarotCardDef(id: 37, nameTr: 'Asaların İkisi', nameEn: 'Two of Wands', frontAsset: 'assets/images/tarot/tarot/Two_of_Wands.webp'),
    TarotCardDef(id: 38, nameTr: 'Asaların Üçü', nameEn: 'Three of Wands', frontAsset: 'assets/images/tarot/tarot/Three_of_Wands.webp'),
    TarotCardDef(id: 39, nameTr: 'Asaların Dörtü', nameEn: 'Four of Wands', frontAsset: 'assets/images/tarot/tarot/Four_of_Wands.webp'),
    TarotCardDef(id: 40, nameTr: 'Asaların Beşi', nameEn: 'Five of Wands', frontAsset: 'assets/images/tarot/tarot/Five_of_Wands.webp'),
    TarotCardDef(id: 41, nameTr: 'Asaların Altısı', nameEn: 'Six of Wands', frontAsset: 'assets/images/tarot/tarot/Six_of_Wands.webp'),
    TarotCardDef(id: 42, nameTr: 'Asaların Yedisi', nameEn: 'Seven of Wands', frontAsset: 'assets/images/tarot/tarot/Seven_of_Wands.webp'),
    TarotCardDef(id: 43, nameTr: 'Asaların Sekizi', nameEn: 'Eight of Wands', frontAsset: 'assets/images/tarot/tarot/Eight_of_Wands.webp'),
    TarotCardDef(id: 44, nameTr: 'Asaların Dokuzu', nameEn: 'Nine of Wands', frontAsset: 'assets/images/tarot/tarot/Nine_of_Wands.webp'),
    TarotCardDef(id: 45, nameTr: 'Asaların Onu', nameEn: 'Ten of Wands', frontAsset: 'assets/images/tarot/tarot/Ten_of_Wands.webp'),
    TarotCardDef(id: 46, nameTr: 'Asaların Uşağı', nameEn: 'Page of Wands', frontAsset: 'assets/images/tarot/tarot/Page_of_Wands.webp'),
    TarotCardDef(id: 47, nameTr: 'Asaların Şövalyesi', nameEn: 'Knight of Wands', frontAsset: 'assets/images/tarot/tarot/Knight_of_Wands.webp'),
    TarotCardDef(id: 48, nameTr: 'Asaların Kraliçesi', nameEn: 'Queen of Wands', frontAsset: 'assets/images/tarot/tarot/Queen_of_Wands.webp'),
    TarotCardDef(id: 49, nameTr: 'Asaların Kralı', nameEn: 'King of Wands', frontAsset: 'assets/images/tarot/tarot/King_of_Wands.webp'),
    // ============================================================
    // MINOR ARCANA — SWORDS (Kılıçlar) — 14 kart (id: 50–63)
    // ============================================================
    TarotCardDef(id: 50, nameTr: 'Kılıçların Ası', nameEn: 'Ace of Swords', frontAsset: 'assets/images/tarot/tarot/Ace_of_Swords.webp'),
    TarotCardDef(id: 51, nameTr: 'Kılıçların İkisi', nameEn: 'Two of Swords', frontAsset: 'assets/images/tarot/tarot/Two_of_Swords.webp'),
    TarotCardDef(id: 52, nameTr: 'Kılıçların Üçü', nameEn: 'Three of Swords', frontAsset: 'assets/images/tarot/tarot/Three_of_Swords.webp'),
    TarotCardDef(id: 53, nameTr: 'Kılıçların Dörtü', nameEn: 'Four of Swords', frontAsset: 'assets/images/tarot/tarot/Four_of_Swords.webp'),
    TarotCardDef(id: 54, nameTr: 'Kılıçların Beşi', nameEn: 'Five of Swords', frontAsset: 'assets/images/tarot/tarot/Five_of_Swords.webp'),
    TarotCardDef(id: 55, nameTr: 'Kılıçların Altısı', nameEn: 'Six of Swords', frontAsset: 'assets/images/tarot/tarot/Six_of_Swords.webp'),
    TarotCardDef(id: 56, nameTr: 'Kılıçların Yedisi', nameEn: 'Seven of Swords', frontAsset: 'assets/images/tarot/tarot/Seven_of_Swords.webp'),
    TarotCardDef(id: 57, nameTr: 'Kılıçların Sekizi', nameEn: 'Eight of Swords', frontAsset: 'assets/images/tarot/tarot/Eight_of_Swords.webp'),
    TarotCardDef(id: 58, nameTr: 'Kılıçların Dokuzu', nameEn: 'Nine of Swords', frontAsset: 'assets/images/tarot/tarot/Nine_of_Swords.webp'),
    TarotCardDef(id: 59, nameTr: 'Kılıçların Onu', nameEn: 'Ten of Swords', frontAsset: 'assets/images/tarot/tarot/Ten_of_Swords.webp'),
    TarotCardDef(id: 60, nameTr: 'Kılıçların Uşağı', nameEn: 'Page of Swords', frontAsset: 'assets/images/tarot/tarot/Page_of_Swords.webp'),
    TarotCardDef(id: 61, nameTr: 'Kılıçların Şövalyesi', nameEn: 'Knight of Swords', frontAsset: 'assets/images/tarot/tarot/Knight_of_Swords.webp'),
    TarotCardDef(id: 62, nameTr: 'Kılıçların Kraliçesi', nameEn: 'Queen of Swords', frontAsset: 'assets/images/tarot/tarot/Queen_of_Swords.webp'),
    TarotCardDef(id: 63, nameTr: 'Kılıçların Kralı', nameEn: 'King of Swords', frontAsset: 'assets/images/tarot/tarot/King_of_Swords.webp'),
    // ============================================================
    // MINOR ARCANA — PENTACLES (Sikkeler) — 14 kart (id: 64–77)
    // ============================================================
    TarotCardDef(id: 64, nameTr: 'Sikkelerin Ası', nameEn: 'Ace of Pentacles', frontAsset: 'assets/images/tarot/tarot/Ace_of_Pentacles.webp'),
    TarotCardDef(id: 65, nameTr: 'Sikkelerin İkisi', nameEn: 'Two of Pentacles', frontAsset: 'assets/images/tarot/tarot/Two_of_Pentacles.webp'),
    TarotCardDef(id: 66, nameTr: 'Sikkelerin Üçü', nameEn: 'Three of Pentacles', frontAsset: 'assets/images/tarot/tarot/Three_of_Pentacles.webp'),
    TarotCardDef(id: 67, nameTr: 'Sikkelerin Dörtü', nameEn: 'Four of Pentacles', frontAsset: 'assets/images/tarot/tarot/Four_of_Pentacles.webp'),
    TarotCardDef(id: 68, nameTr: 'Sikkelerin Beşi', nameEn: 'Five of Pentacles', frontAsset: 'assets/images/tarot/tarot/Five_of_Pentacles.webp'),
    TarotCardDef(id: 69, nameTr: 'Sikkelerin Altısı', nameEn: 'Six of Pentacles', frontAsset: 'assets/images/tarot/tarot/Six_of_Pentacles.webp'),
    TarotCardDef(id: 70, nameTr: 'Sikkelerin Yedisi', nameEn: 'Seven of Pentacles', frontAsset: 'assets/images/tarot/tarot/Seven_of_Pentacles.webp'),
    TarotCardDef(id: 71, nameTr: 'Sikkelerin Sekizi', nameEn: 'Eight of Pentacles', frontAsset: 'assets/images/tarot/tarot/Eight_of_Pentacles.webp'),
    TarotCardDef(id: 72, nameTr: 'Sikkelerin Dokuzu', nameEn: 'Nine of Pentacles', frontAsset: 'assets/images/tarot/tarot/Nine_of_Pentacles.webp'),
    TarotCardDef(id: 73, nameTr: 'Sikkelerin Onu', nameEn: 'Ten of Pentacles', frontAsset: 'assets/images/tarot/tarot/Ten_of_Pentacles.webp'),
    TarotCardDef(id: 74, nameTr: 'Sikkelerin Uşağı', nameEn: 'Page of Pentacles', frontAsset: 'assets/images/tarot/tarot/Page_of_Pentacles.webp'),
    TarotCardDef(id: 75, nameTr: 'Sikkelerin Şövalyesi', nameEn: 'Knight of Pentacles', frontAsset: 'assets/images/tarot/tarot/Knight_of_Pentacles.webp'),
    TarotCardDef(id: 76, nameTr: 'Sikkelerin Kraliçesi', nameEn: 'Queen of Pentacles', frontAsset: 'assets/images/tarot/tarot/Queen_of_Pentacles.webp'),
    TarotCardDef(id: 77, nameTr: 'Sikkelerin Kralı', nameEn: 'King of Pentacles', frontAsset: 'assets/images/tarot/tarot/King_of_Pentacles.webp'),
  ];
  // ======================
  // Storage keys
  // ======================
  static const _kLastFreeDate = 'tarot_last_free_date_v1';
  static const _kAdCredits = 'tarot_ad_credits_v1';

  static const _kStreak = 'tarot_streak_v1';
  static const _kLastReadDate = 'tarot_last_read_date_v1';
  static const _kFreezeUsedAt = 'tarot_freeze_used_at_v1';

  // ======================
  // State
  // ======================
  RitualState _state = RitualState.gateCheck;


  final Random _rng = Random();
  late SharedPreferences _prefs;

  bool _dailyFreeUsed = false;
  int _adCredits = 0;
  int _streak = 1;
  bool _isBusy = false;
  bool _magicBtnPressed = false;

  // deck
  late List<int> _deckOrder;
  late List<int> _tableCards;
  int get _tableCount {
    if (_isBuyukArkana) return 22;
    return 78; // Tam Arkana: tüm kartlar
  }
  int? _selectedCategory;


  // selection
  final List<int> _selectedTablePositions = [];
  final List<GlobalKey> _cardKeys = List<GlobalKey>.generate(
    78,
    (_) => GlobalKey(),
  );
  final List<GlobalKey> _slotKeys = List<GlobalKey>.generate(
    7,
    (_) => GlobalKey(),
  );
  int get _maxSlots => _isBuyukArkana ? 3 : 7;
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
  FullTarotReading? _latestFullReading;

  // Full Arcana card carousel
  PageController? _fullCardPageCtrl;
  int _fullCardPageIndex = 0;
  AnimationController? _infoRevealCtrl;





  // Animations
  late AnimationController _shuffleCtrl;
  late AnimationController _ctaScrambleCtrl;
  late AnimationController _starsCtrl;
  late AnimationController _fogCtrl;
  late AnimationController _bgPulseCtrl;
  late AnimationController _slotEntranceCtrl;
  final ScrollController _readingScrollCtrl = ScrollController();

  String _ctaText = '';
  String _miniStatusText = '';
  Timer? _miniStatusTimer;



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
      duration: const Duration(seconds: 40),
    );
    _slotGlowControllers = List.generate(7, (_) => AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      value: 1.0,
    ));
    _fogCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 36),
    );
    _bgPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    );
    // Arka plan animasyonlarını gecikmeli başlat — sayfa geçişi takılmasın
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      _starsCtrl.repeat();
      _fogCtrl.repeat();
      _bgPulseCtrl.repeat(reverse: true);
    });

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
    _readingScrollCtrl.dispose();
    for (final c in _slotGlowControllers) c.dispose();
    _cardFlipPlayer.dispose();
    _fullCardPageCtrl?.dispose();
    _infoRevealCtrl?.dispose();
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
    List<int> cardPool;
    if (_isBuyukArkana) {
      cardPool = List<int>.generate(22, (i) => i);
    } else {
      cardPool = List<int>.generate(78, (i) => i);
    }
    cardPool.shuffle(_rng);
    _tableCards = cardPool;
    _deckOrder = List<int>.generate(_allCards.length, (i) => i)..shuffle(_rng);

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
  // Ad Popup (Rewarded Ad Gate)
  // ======================
  Future<bool> _showAdPopup() async {
    if (!mounted) return false;
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'ad_popup',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, a1, a2, child) {
        return FadeTransition(
          opacity: a1,
          child: ScaleTransition(
            scale: CurvedAnimation(parent: a1, curve: Curves.easeOutBack),
            child: child,
          ),
        );
      },
      pageBuilder: (context, _, __) {
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1030).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C3FA0).withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFE2C48E).withOpacity(0.25),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        color: const Color(0xFFE2C48E).withOpacity(0.8),
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Title
                    Text(
                      _t('Bugünlük Ücretsiz Hakkın Bitti', 'Daily Free Reading Used'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cormorantGaramond(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Subtitle
                    Text(
                      _t(
                        'Kısa bir reklam izleyerek yeni bir okuma hakkı kazanabilirsin.',
                        'Watch a short ad to earn another reading.',
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Watch Ad Button
                    _AdWatchButton(
                      label: _t('Reklam İzle  ▶', 'Watch Ad  ▶'),
                      onComplete: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                    const SizedBox(height: 12),
                    // Close
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(false),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          _t('Vazgeç', 'Cancel'),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.35),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    if (result == true) {
      // Grant ad credit
      _adCredits += 1;
      await _prefs.setInt(_kAdCredits, _adCredits);
      return true;
    }
    return false;
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
    List<int> cardPool;
    if (_isBuyukArkana) {
      cardPool = List<int>.generate(22, (i) => i);
    } else {
      // Tam Arkana: tüm 78 kart
      cardPool = List<int>.generate(78, (i) => i);
    }
    cardPool.shuffle(_rng);
    _tableCards = cardPool;
    _deckOrder = List<int>.generate(_allCards.length, (i) => i)..shuffle(_rng);
    _revealedCount = 0;
    _selectedCardIndexes = [];
    _updateCtaText();
    // Re-play entrance animations
    _slotEntranceCtrl.forward(from: 0.0);
    _setStateSafe(() {
      _deckRebuildKey++;
      _state = RitualState.selecting;
    });
    _updateCtaText();
  }

  void _selectCategory(int category) {
    HapticFeedback.lightImpact();
    _setStateSafe(() {
      _selectedCategory = category;
      _hiddenCards.clear();
    });
    _resetDeck();
  }



  /// 3 kart seçildi — yorum ekranını aç
  Future<void> _commitAndReveal() async {
    /* 
    // ŞİMDİLİK İPTAL EDİLDİ - HERKES SINIRSIZ GÖREBİLİR
    final allowed = await _ensureAllowance();
    if (!allowed) {
      // Show ad popup instead of just mini status
      final granted = await _showAdPopup();
      if (!granted) return;
    }
    await _consumeAllowanceOnCommit();
    */

    HapticFeedback.mediumImpact();
    _setStateSafe(() {
      _isBusy = true;
      _selectedCardIndexes = _selectedTablePositions
          .map((pos) => _tableCards[pos])
          .toList();
    });

    // --- Saspans (Yorumlama / Bekleme) Hissi ---
    _setMiniStatus(_t('Kaderin fısıltısı dinleniyor...', 'Listening to whispers of fate...'), ms: 800);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    // -------------------------------------------

    // Yorumu üret
    if (_isBuyukArkana) {
      // Major Arcana: 3 kart
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
        _latestFullReading = null;
      });
    } else {
      // Full Arcana: 7 kart
      final cardIds = _selectedCardIndexes.map((i) => _allCards[i].id).toList();
      final cardNames = _selectedCardIndexes.map((i) => _cardName(i)).toList();
      final fullReading = generateFullReading(
        cardIds: cardIds,
        cardNames: cardNames,
        isTr: _isTr,
      );
      _setStateSafe(() {
        _isBusy = false;
        _state = RitualState.revealed;
        _latestFullReading = fullReading;
        _latestReading = null;
      });
    }
    _updateCtaText();
    await _updateStreakOnCompleteRead();
    if (!mounted) return;
    
    // ── Tarot İstatistik Kaydı (TÜM seçilen kartları kaydet) ──
    // _selectedCategory: 0=Büyük Arkana, 1=Kupalar, 2=Asalar, 3=Kılıçlar, 4=Tılsımlar, null=Tam Deste
    final deckTypes = ['Büyük Arkana', 'Kupalar', 'Asalar', 'Kılıçlar', 'Tılsımlar'];
    final category = (_selectedCategory != null && _selectedCategory! < deckTypes.length) ? deckTypes[_selectedCategory!] : 'Genel';
    for (final idx in _selectedCardIndexes) {
      final name = _cardName(idx);
      final asset = _allCards[idx].frontAsset;
      await UserStatsService.addTarotReading(name, category, '', cardAsset: asset);
    }
    
    // Yorum zaten RitualState.revealed ile fullscreen blur üstünde gösteriliyor
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

  Widget _buildMysticalDivider(IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 0.8,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                const Color(0xFFE7D6A5).withOpacity(0.4),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(
            icon,
            color: const Color(0xFFE7D6A5).withOpacity(0.7),
            size: 16,
            shadows: [
              Shadow(
                color: const Color(0xFFE7D6A5).withOpacity(0.5),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        Container(
          width: 60,
          height: 0.8,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFE7D6A5).withOpacity(0.4),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlowingQuoteCard(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: GlassCard(
        useOwnLayer: true,
        padding: EdgeInsets.zero,
        shape: const LiquidRoundedSuperellipse(borderRadius: 20),
        settings: const LiquidGlassSettings(
          thickness: 24,
          blur: 10, // Daha derin ve puslu bir cam
          glassColor: Color(0x1AE7D6A5), // Çok hafif sıcak/altın bir renk tonu (%10 opacity)
          chromaticAberration: 0.15,
          lightIntensity: 1.2, // Işık yansımasını artırdık, hafif bir parlama yaratıyor
          ambientStrength: 0.85,
          refractiveIndex: 1.3,
          saturation: 1.1, // Arkadaki renkleri daha canlı gösterir
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Işıklı İnce Ayraç (Line - Diamond - Line)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, const Color(0xFFE7D6A5).withOpacity(0.8)],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Transform.rotate(
                  angle: pi / 4,
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7D6A5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE7D6A5).withOpacity(0.8),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 60,
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFFE7D6A5).withOpacity(0.8), Colors.transparent],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 0),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(44, 4, 44, 20),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cormorantGaramond(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.6,
                      letterSpacing: 0.2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
                // Sol üst tırnak
                Positioned(
                  top: -8,
                  left: 12,
                  child: Text(
                    '\u201c',
                    style: GoogleFonts.cormorantGaramond(
                      color: const Color(0xFFE7D6A5).withOpacity(0.85),
                      fontSize: 52,
                      fontWeight: FontWeight.w700,
                      shadows: [Shadow(color: const Color(0xFFE7D6A5).withOpacity(0.5), blurRadius: 8)],
                    ),
                  ),
                ),
                // Sağ alt tırnak
                Positioned(
                  bottom: -6,
                  right: 12,
                  child: Text(
                    '\u201d',
                    style: GoogleFonts.cormorantGaramond(
                      color: const Color(0xFFE7D6A5).withOpacity(0.85),
                      fontSize: 52,
                      fontWeight: FontWeight.w700,
                      shadows: [Shadow(color: const Color(0xFFE7D6A5).withOpacity(0.5), blurRadius: 8)],
                    ),
                  ),
                ),
                // Ortadaki alt zarif kavis çizgisi
                Positioned(
                  bottom: 6,
                  left: 0,
                  right: 0,
                  child: CustomPaint(
                    size: const Size(double.infinity, 20),
                    painter: _BottomSwooshPainter(),
                  ),
                ),
                // Alt merkezdeki belirgin parlayan ışık noktası (BottomSwoosh'un tam ortasında olan büyük parlama)
                Positioned(
                  bottom: -2,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.8),
                            blurRadius: 6,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: const Color(0xFFE7D6A5).withOpacity(0.6),
                            blurRadius: 12,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Görünen kelimeye göre ikon eşleştirme — çok geniş, her kelimeye özel
  static const Map<String, IconData> _keywordIcons = {
    // Türkçe
    'yeni başlangıç': Icons.hiking_outlined,
    'masumiyet': Icons.child_care_outlined,
    'cesaret': Icons.bolt,
    'irade': Icons.auto_fix_high_outlined,
    'yaratıcılık': Icons.brush_outlined,
    'ustalık': Icons.architecture_outlined,
    'sezgi': Icons.remove_red_eye_outlined,
    'gizem': Icons.lock_outlined,
    'içsel bilgelik': Icons.self_improvement_outlined,
    'bereket': Icons.spa_outlined,
    'doğurganlık': Icons.eco_outlined,
    'şefkat': Icons.volunteer_activism_outlined,
    'otorite': Icons.account_balance_outlined,
    'yapı': Icons.domain_outlined,
    'düzen': Icons.grid_view_outlined,
    'gelenek': Icons.menu_book_outlined,
    'rehberlik': Icons.assistant_navigation,
    'inanç sistemi': Icons.temple_buddhist_outlined,
    'seçim': Icons.alt_route_outlined,
    'ilişki': Icons.favorite_border,
    'uyum': Icons.handshake_outlined,
    'zafer': Icons.emoji_events_outlined,
    'ilerleme': Icons.rocket_launch_outlined,
    'iç güç': Icons.shield_outlined,
    'sabır': Icons.access_time_outlined,
    'içe dönüş': Icons.explore_outlined,
    'arayış': Icons.travel_explore_outlined,
    'yalnızlık': Icons.person_outlined,
    'kader': Icons.rotate_right_outlined,
    'döngü': Icons.loop_outlined,
    'dönüm noktası': Icons.swap_vert_circle_outlined,
    'adalet': Icons.balance_outlined,
    'denge': Icons.water_drop_outlined,
    'doğruluk': Icons.verified_outlined,
    'fedakârlık': Icons.hourglass_empty_outlined,
    'bekleyiş': Icons.pause_circle_outlined,
    'farklı bakış açısı': Icons.flip_outlined,
    'dönüşüm': Icons.change_circle_outlined,
    'kapanış': Icons.door_sliding_outlined,
    'yenilenme': Icons.autorenew_outlined,
    'ılımlılık': Icons.thermostat_outlined,
    'bağımlılık': Icons.link_off_outlined,
    'gölge': Icons.dark_mode_outlined,
    'yüzleşme': Icons.face_retouching_natural_outlined,
    'yıkım': Icons.local_fire_department_outlined,
    'kriz': Icons.warning_amber_outlined,
    'ani değişim': Icons.flash_on_outlined,
    'umut': Icons.star_outline,
    'ilham': Icons.lightbulb_outlined,
    'iyileşme': Icons.healing_outlined,
    'yanılsama': Icons.visibility_off_outlined,
    'korku': Icons.nightlight_outlined,
    'bilinçaltı': Icons.psychology_outlined,
    'başarı': Icons.wb_sunny_outlined,
    'canlılık': Icons.local_florist_outlined,
    'aydınlanma': Icons.flare_outlined,
    'uyanış': Icons.notifications_active_outlined,
    'yargı': Icons.gavel_outlined,
    'çağrı': Icons.campaign_outlined,
    'tamamlanma': Icons.all_inclusive_rounded,
    'bütünlük': Icons.public_outlined,
    // English
    'new beginning': Icons.hiking_outlined,
    'innocence': Icons.child_care_outlined,
    'courage': Icons.bolt,
    'willpower': Icons.auto_fix_high_outlined,
    'creativity': Icons.brush_outlined,
    'mastery': Icons.architecture_outlined,
    'intuition': Icons.remove_red_eye_outlined,
    'mystery': Icons.lock_outlined,
    'inner wisdom': Icons.self_improvement_outlined,
    'abundance': Icons.spa_outlined,
    'fertility': Icons.eco_outlined,
    'nurturing': Icons.volunteer_activism_outlined,
    'authority': Icons.account_balance_outlined,
    'structure': Icons.domain_outlined,
    'order': Icons.grid_view_outlined,
    'tradition': Icons.menu_book_outlined,
    'guidance': Icons.assistant_navigation,
    'belief system': Icons.temple_buddhist_outlined,
    'choice': Icons.alt_route_outlined,
    'relationship': Icons.favorite_border,
    'harmony': Icons.handshake_outlined,
    'victory': Icons.emoji_events_outlined,
    'forward movement': Icons.rocket_launch_outlined,
    'inner strength': Icons.shield_outlined,
    'patience': Icons.access_time_outlined,
    'introspection': Icons.explore_outlined,
    'seeking': Icons.travel_explore_outlined,
    'solitude': Icons.person_outlined,
    'fate': Icons.rotate_right_outlined,
    'cycle': Icons.loop_outlined,
    'turning point': Icons.swap_vert_circle_outlined,
    'justice': Icons.balance_outlined,
    'balance': Icons.water_drop_outlined,
    'truth': Icons.verified_outlined,
    'sacrifice': Icons.hourglass_empty_outlined,
    'waiting': Icons.pause_circle_outlined,
    'new perspective': Icons.flip_outlined,
    'transformation': Icons.change_circle_outlined,
    'ending': Icons.door_sliding_outlined,
    'renewal': Icons.autorenew_outlined,
    'moderation': Icons.thermostat_outlined,
    'attachment': Icons.link_off_outlined,
    'shadow': Icons.dark_mode_outlined,
    'confrontation': Icons.face_retouching_natural_outlined,
    'destruction': Icons.local_fire_department_outlined,
    'crisis': Icons.warning_amber_outlined,
    'sudden change': Icons.flash_on_outlined,
    'hope': Icons.star_outline,
    'inspiration': Icons.lightbulb_outlined,
    'healing': Icons.healing_outlined,
    'illusion': Icons.visibility_off_outlined,
    'fear': Icons.nightlight_outlined,
    'subconscious': Icons.psychology_outlined,
    'success': Icons.wb_sunny_outlined,
    'vitality': Icons.local_florist_outlined,
    'enlightenment': Icons.flare_outlined,
    'awakening': Icons.notifications_active_outlined,
    'judgement': Icons.gavel_outlined,
    'calling': Icons.campaign_outlined,
    'completion': Icons.all_inclusive_rounded,
    'wholeness': Icons.public_outlined,
    'triumph': Icons.military_tech_outlined,
  };

  IconData _getIconForKeyword(String keyword) {
    final lower = keyword.toLowerCase().trim();
    // Türkçe anahtar kelime eşleşmeleri
    final trMap = <String, IconData>{
      'büyüme': Icons.eco_outlined,
      'dönüşüm': Icons.change_circle_outlined,
      'güç': Icons.flash_on_outlined,
      'cesaret': Icons.shield_outlined,
      'aşk': Icons.favorite_border,
      'sevgi': Icons.favorite_outlined,
      'umut': Icons.wb_twilight_outlined,
      'iyileşme': Icons.healing_outlined,
      'huzur': Icons.spa_outlined,
      'iç huzur': Icons.self_improvement_outlined,
      'denge': Icons.balance_outlined,
      'yenilenme': Icons.autorenew_outlined,
      'başlangıç': Icons.rocket_launch_outlined,
      'yeni başlangıç': Icons.brightness_5_outlined,
      'bilgelik': Icons.menu_book_outlined,
      'özgürlük': Icons.air_outlined,
      'tutku': Icons.local_fire_department_outlined,
      'ilham': Icons.lightbulb_outlined,
      'seziş': Icons.remove_red_eye_outlined,
      'sezgi': Icons.psychology_outlined,
      'bereket': Icons.local_florist_outlined,
      'zafer': Icons.emoji_events_outlined,
      'başarı': Icons.military_tech_outlined,
      'değişim': Icons.swap_vert_circle_outlined,
      'sabır': Icons.hourglass_empty_outlined,
      'inanç': Icons.temple_buddhist_outlined,
      'koruma': Icons.security_outlined,
      'duygular': Icons.mood_outlined,
      'şifa': Icons.healing_outlined,
      'keşif': Icons.explore_outlined,
      'içe dönüş': Icons.self_improvement_outlined,
      'yolculuk': Icons.directions_walk_outlined,
      'adalet': Icons.gavel_outlined,
      'kader': Icons.loop_outlined,
      'ışık': Icons.flare_outlined,
      'hayal': Icons.cloud_outlined,
      'güven': Icons.verified_outlined,
      'bağımsızlık': Icons.open_in_new_outlined,
      'zihin': Icons.psychology_alt_outlined,
      'bağlılık': Icons.link_outlined,
      'sadakat': Icons.handshake_outlined,
      'farkındalık': Icons.visibility_outlined,
      'kararlılık': Icons.trending_up_outlined,
      'yeniden doğuş': Icons.wb_sunny_outlined,
      'arınma': Icons.water_drop_outlined,
      'bolluk': Icons.park_outlined,
      'akış': Icons.waves_outlined,
      'ruh': Icons.air_outlined,
      'öz': Icons.fingerprint_outlined,
      'netlik': Icons.center_focus_strong_outlined,
      'kabul': Icons.check_circle_outlined,
      'bırakma': Icons.back_hand_outlined,
      'kendini keşfet': Icons.person_search_outlined,
      'yaratıcılık': Icons.palette_outlined,
      'irade': Icons.fitness_center_outlined,
      'sınır': Icons.fence_outlined,
      'derinlik': Icons.scuba_diving_outlined,
      'birlik': Icons.group_outlined,
      'barış': Icons.diversity_1_outlined,
      'direniş': Icons.front_hand_outlined,
      'sorumluluk': Icons.assignment_turned_in_outlined,
      'bütünlük': Icons.public_outlined,
    };
    // Türkçe eşleşme
    if (trMap.containsKey(lower)) return trMap[lower]!;
    for (final entry in trMap.entries) {
      if (lower.contains(entry.key) || entry.key.contains(lower)) return entry.value;
    }
    // İngilizce eşleşme
    if (_keywordIcons.containsKey(lower)) return _keywordIcons[lower]!;
    for (final entry in _keywordIcons.entries) {
      if (lower.contains(entry.key) || entry.key.contains(lower)) return entry.value;
    }
    // Fallback — keyword'ün hash'ine göre farklı sembol
    final fallbackIcons = [
      Icons.diamond_outlined,
      Icons.auto_awesome_outlined,
      Icons.hexagon_outlined,
      Icons.star_border_purple500_outlined,
      Icons.compass_calibration_outlined,
      Icons.blur_on_outlined,
      Icons.brightness_7_outlined,
      Icons.lens_blur_outlined,
      Icons.circle_outlined,
      Icons.filter_vintage_outlined,
    ];
    return fallbackIcons[lower.hashCode.abs() % fallbackIcons.length];
  }

  Widget _buildVerticalMisticLine() {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFFE7D6A5).withOpacity(0.5),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildPromiseItem(String text, IconData icon, Color glowColor) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Parlayan gradient çizgi + dot
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 72,
                height: 1.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      glowColor,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Container(
                width: 3.5,
                height: 3.5,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: glowColor,
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.6),
                      blurRadius: 2,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Premium Full Arcana UI Widget'ları
  // ============================================================

  /// Kozmik Uyum Skoru widget'ı
  Widget _buildCosmicScorePanel(int score, String label) {
    const gold = Color(0xFFE7D6A5);
    final normalizedScore = score.clamp(0, 100) / 100.0;

    // Her kartın rengini suit/türüne göre belirle
    Color _cardColor(int cardIndex) {
      final id = _allCards[cardIndex].id;
      if (id <= 21) return const Color(0xFFE7D6A5);       // Major Arcana → Altın
      if (id <= 35) return const Color(0xFFE8A07C);       // Wands → Ateş/Amber
      if (id <= 49) return const Color(0xFF8CB8D4);       // Cups → Su/Mavi
      if (id <= 63) return const Color(0xFFB9A0D2);       // Swords → Hava/Lavanta
      return const Color(0xFF9EC8A0);                      // Pentacles → Toprak/Yeşil
    }

    final ringColors = _selectedCardIndexes.length >= 7
        ? List.generate(7, (i) => _cardColor(_selectedCardIndexes[i]))
        : List.generate(7, (_) => gold);

    final posLabels = _isTr
        ? ['Geçmiş', 'Şimdi', 'Bilinç', 'Engel', 'İlişki', 'Yol', 'Sonuç']
        : ['Past', 'Now', 'Mind', 'Block', 'Bond', 'Path', 'Result'];

    final ringValues = List.generate(7, (i) {
      final offsets = [0.08, -0.05, 0.12, -0.10, 0.06, -0.03, 0.09];
      return (normalizedScore + offsets[i]).clamp(0.05, 1.0);
    });

    return GestureDetector(
      onTap: () => _showCosmicHarmonyInfo(score, label, ringColors, posLabels),
      child: ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A1F3D).withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: gold.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: gold.withValues(alpha: 0.08),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            builder: (context, anim, _) => Column(
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('✨ ', style: TextStyle(fontSize: 14)),
                          Text(
                            _isTr ? 'KOZMİK UYUM' : 'COSMIC HARMONY',
                            style: TextStyle(
                              color: gold, fontSize: 11,
                              fontWeight: FontWeight.w700, letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.info_outline_rounded,
                            color: gold.withValues(alpha: 0.35), size: 14),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('${(score * anim).round()}', style: TextStyle(
                            color: gold, fontSize: 36,
                            fontWeight: FontWeight.w800, height: 1,
                          )),
                          const SizedBox(width: 3),
                          Text('/100', style: TextStyle(
                            color: gold.withValues(alpha: 0.4),
                            fontSize: 13, fontWeight: FontWeight.w400,
                          )),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Opacity(
                        opacity: anim.clamp(0.0, 1.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: gold.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: gold.withValues(alpha: 0.15)),
                          ),
                          child: Text(label, style: TextStyle(
                            color: gold, fontSize: 12, fontWeight: FontWeight.w600,
                          )),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 110, height: 65,
                    child: CustomPaint(
                      painter: _RadialRingChartPainter(
                        values: ringValues.map((v) => v * anim).toList(),
                        colors: ringColors,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(7, (i) {
                  final dotDelay = i / 7.0 * 0.3;
                  final dotAnim = ((anim - dotDelay) / (1 - dotDelay)).clamp(0.0, 1.0);
                  return Transform.scale(
                    scale: 0.3 + 0.7 * dotAnim,
                    child: Opacity(
                      opacity: dotAnim,
                      child: Column(
                        children: [
                          Container(
                            width: 6, height: 6,
                            decoration: BoxDecoration(
                              color: ringColors[i].withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(posLabels[i], style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 8, fontWeight: FontWeight.w500,
                          )),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          ),
        ),
      ),
      ),
    );
  }

  void _showCosmicHarmonyInfo(int score, String label, List<Color> colors, List<String> posLabels) {
    const gold = Color(0xFFE7D6A5);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('✨ ', style: TextStyle(fontSize: 20)),
                Text(
                  _isTr ? 'Kozmik Uyum Nedir?' : 'What is Cosmic Harmony?',
                  style: TextStyle(
                    color: gold, fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _isTr
                  ? 'Kozmik uyum skoru, seçtiğiniz 7 kartın elementel dengesini, arketipsel bağlantılarını ve enerji akışını analiz ederek hesaplanır. Her kart bireysel olarak ve diğer kartlarla etkileşimi açısından değerlendirilir.'
                  : 'The cosmic harmony score is calculated by analyzing the elemental balance, archetypal connections, and energy flow of your 7 selected cards. Each card is evaluated individually and in terms of its interaction with other cards.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14, height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _isTr ? 'Grafikteki Renkler' : 'Chart Colors',
              style: TextStyle(
                color: gold, fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 16, runSpacing: 8,
              children: [
                _harmonyColorChip(_isTr ? 'Major Arcana' : 'Major Arcana', const Color(0xFFE7D6A5)),
                _harmonyColorChip(_isTr ? 'Asalar (Ateş)' : 'Wands (Fire)', const Color(0xFFE8A07C)),
                _harmonyColorChip(_isTr ? 'Kupalar (Su)' : 'Cups (Water)', const Color(0xFF8CB8D4)),
                _harmonyColorChip(_isTr ? 'Kılıçlar (Hava)' : 'Swords (Air)', const Color(0xFFB9A0D2)),
                _harmonyColorChip(_isTr ? 'Tılsımlar (Toprak)' : 'Pentacles (Earth)', const Color(0xFF9EC8A0)),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _isTr ? 'Skor Seviyeleri' : 'Score Levels',
              style: TextStyle(
                color: gold, fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            ..._harmonyScoreLevels(),
            const SizedBox(height: 8),
          ],
        ),
      ),
        ),
      ),
    );
  }

  Widget _harmonyColorChip(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.8),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(
          color: Colors.white.withValues(alpha: 0.6),
          fontSize: 12,
        )),
      ],
    );
  }

  List<Widget> _harmonyScoreLevels() {
    final levels = _isTr
        ? [
            ['90-100', 'Mükemmel Uyum', 'Kartlarınız kusursuz bir enerji akışı içinde.'],
            ['70-89', 'Güçlü Uyum', 'Kartlar arasında güçlü bağlantılar var.'],
            ['50-69', 'Dengeli', 'Kartlar genel olarak uyumlu, bazı gerilimler mevcut.'],
            ['30-49', 'Karışık Enerji', 'Çelişkili enerjiler; büyüme fırsatları barındırır.'],
            ['0-29', 'Kaotik', 'Güçlü çatışmalar; dönüşüm potansiyeli yüksek.'],
          ]
        : [
            ['90-100', 'Perfect Harmony', 'Your cards flow in perfect energy alignment.'],
            ['70-89', 'Strong Harmony', 'Strong connections between your cards.'],
            ['50-69', 'Balanced', 'Generally harmonious with some tensions.'],
            ['30-49', 'Mixed Energy', 'Conflicting energies; growth opportunities.'],
            ['0-29', 'Chaotic', 'Strong conflicts; high transformation potential.'],
          ];
    return levels.map((l) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Text(l[0], style: TextStyle(
              color: const Color(0xFFE7D6A5).withValues(alpha: 0.7),
              fontSize: 11, fontWeight: FontWeight.w600,
            )),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${l[1]} · ',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 11, fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: l[2],
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    )).toList();
  }

  /// Element Analizi widget'ı
  Widget _buildElementAnalysisPanel(ElementAnalysis analysis) {
    const fireColor = Color(0xFFFF6B35);
    const waterColor = Color(0xFF4A9FE5);
    const airColor = Color(0xFF7EC8A0);
    const earthColor = Color(0xFFC9956B);

    Color accentColor;
    switch (analysis.dominantElement) {
      case 'Ateş': accentColor = fireColor; break;
      case 'Su': accentColor = waterColor; break;
      case 'Hava': accentColor = airColor; break;
      case 'Toprak': accentColor = earthColor; break;
      default: accentColor = const Color(0xFFE7D6A5);
    }

    final elementData = [
      {'name': _isTr ? 'Ateş' : 'Fire', 'element': 'fire', 'value': analysis.elements['Ateş'] ?? 0.0, 'color': fireColor},
      {'name': _isTr ? 'Su' : 'Water', 'element': 'water', 'value': analysis.elements['Su'] ?? 0.0, 'color': waterColor},
      {'name': _isTr ? 'Hava' : 'Air', 'element': 'air', 'value': analysis.elements['Hava'] ?? 0.0, 'color': airColor},
      {'name': _isTr ? 'Toprak' : 'Earth', 'element': 'earth', 'value': analysis.elements['Toprak'] ?? 0.0, 'color': earthColor},
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1533).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.06),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            children: [
              _buildElementSymbol(
                {'Ateş': 'fire', 'Su': 'water', 'Hava': 'air', 'Toprak': 'earth'}[analysis.dominantElement] ?? 'fire',
                accentColor, true,
              ),
              const SizedBox(width: 8),
              Text(
                _isTr ? 'ELEMENT ANALİZİ' : 'ELEMENT ANALYSIS',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Element barları
          ...elementData.map((e) {
            final value = e['value'] as double;
            final color = e['color'] as Color;
            final isDominant = (e['name'] as String).contains(analysis.dominantElement) ||
                (analysis.dominantElement == 'Ateş' && (e['name'] as String).contains('Fire')) ||
                (analysis.dominantElement == 'Su' && (e['name'] as String).contains('Water')) ||
                (analysis.dominantElement == 'Hava' && (e['name'] as String).contains('Air')) ||
                (analysis.dominantElement == 'Toprak' && (e['name'] as String).contains('Earth'));
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  _buildElementSymbol(e['element'] as String, color, isDominant),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 48,
                    child: Text(
                      e['name'] as String,
                      style: TextStyle(
                        color: isDominant ? color : Colors.white70,
                        fontSize: 12,
                        fontWeight: isDominant ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: isDominant ? 10 : 6,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: FractionallySizedBox(
                        widthFactor: value.clamp(0.05, 1.0),
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [color.withValues(alpha: 0.5), color]),
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: isDominant ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 1)] : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '%${(value * 100).round()}',
                      style: TextStyle(
                        color: isDominant ? color : Colors.white54,
                        fontSize: 12,
                        fontWeight: isDominant ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          // Baskın element açıklaması
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentColor.withValues(alpha: 0.15)),
            ),
            child: Text(
              _isTr ? analysis.dominantDescriptionTr : analysis.dominantDescriptionEn,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 13,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }

  /// Özel element sembolü widget'ı
  Widget _buildElementSymbol(String element, Color color, bool isDominant) {
    final size = isDominant ? 22.0 : 18.0;
    final glowAlpha = isDominant ? 0.5 : 0.25;
    
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ElementSymbolPainter(
          element: element,
          color: color,
          glowAlpha: glowAlpha,
          isDominant: isDominant,
        ),
      ),
    );
  }

  /// Kart İlişkileri widget'ı — Apple Liquid Glass Teması
  Widget _buildCardRelationsPanel(List<CardRelation> relations) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF161225).withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 0.5),
                      ),
                      child: SizedBox(
                        width: 18, height: 18,
                        child: CustomPaint(painter: _ConnectionSymbolPainter()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isTr ? 'KART İLİŞKİLERİ' : 'CARD CONNECTIONS',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Her ilişki kartı (Inner Apple-style glass boxes)
                ...relations.map((r) {
                  final suit1 = _detectCardSuit(r.card1Name);
                  final suit2 = _detectCardSuit(r.card2Name);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withValues(alpha: 0.03),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                        width: 0.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 2, right: 16),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withValues(alpha: 0.2),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.06),
                                width: 0.5,
                              ),
                            ),
                            child: SizedBox(
                              width: 20, height: 20,
                              child: CustomPaint(
                                painter: _CardPairSymbolPainter(
                                  suit1: suit1,
                                  suit2: suit2,
                                  card1Name: r.card1Name,
                                  card2Name: r.card2Name,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              _isTr ? r.relationTextTr : r.relationTextEn,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 13.5,
                                height: 1.6,
                                letterSpacing: 0.3,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Kart isminden suit türünü tespit et
  String _detectCardSuit(String cardName) {
    final lower = cardName.toLowerCase();
    if (lower.contains('asa') || lower.contains('wand') || lower.contains('rod')) return 'wands';
    if (lower.contains('kupa') || lower.contains('cup') || lower.contains('chalice')) return 'cups';
    if (lower.contains('kılıç') || lower.contains('sword') || lower.contains('blade')) return 'swords';
    if (lower.contains('pentakl') || lower.contains('pentacle') || lower.contains('coin') || lower.contains('disk')) return 'pentacles';
    // Major Arcana kartları
    return 'major';
  }

  /// Tavsiye + Gizli Mesaj birleşik widget'ı — Soft Gold Glass teması
  Widget _buildInsightPanel(String advice, String secretMessage) {
    const softGold = Color(0xFFD4C5A0);
    const warmBeige = Color(0xFFCBB989);
    const creamWhite = Color(0xFFF5ECD7);
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: softGold.withValues(alpha: 0.1),
            blurRadius: 30,
            spreadRadius: 3,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2E2418).withValues(alpha: 0.3),
                  const Color(0xFF1F1A10).withValues(alpha: 0.25),
                  const Color(0xFF2A2015).withValues(alpha: 0.3),
                ],
              ),
              border: Border.all(
                width: 1,
                color: softGold.withValues(alpha: 0.15),
              ),
            ),
            child: Stack(
              children: [
                // Sağ üst köşede yumuşak ışık orb
                Positioned(
                  top: -10, right: -10,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          softGold.withValues(alpha: 0.12),
                          softGold.withValues(alpha: 0.04),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ),
                // Sol alt köşede yumuşak ışık orb
                Positioned(
                  bottom: -8, left: -8,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          warmBeige.withValues(alpha: 0.1),
                          warmBeige.withValues(alpha: 0.03),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                // Köşe süsleri
                Positioned(top: 10, left: 12,
                  child: Text('✧', style: TextStyle(color: softGold.withValues(alpha: 0.3), fontSize: 13))),
                Positioned(top: 10, right: 12,
                  child: Text('✦', style: TextStyle(color: warmBeige.withValues(alpha: 0.25), fontSize: 11))),
                Positioned(bottom: 10, left: 12,
                  child: Text('✦', style: TextStyle(color: warmBeige.withValues(alpha: 0.22), fontSize: 11))),
                Positioned(bottom: 10, right: 12,
                  child: Text('✧', style: TextStyle(color: softGold.withValues(alpha: 0.28), fontSize: 13))),
                // Dağınık parıltı sembolleri
                Positioned(top: 30, right: 30,
                  child: Text('⊹', style: TextStyle(color: creamWhite.withValues(alpha: 0.15), fontSize: 8))),
                Positioned(top: 50, left: 40,
                  child: Text('·', style: TextStyle(color: softGold.withValues(alpha: 0.25), fontSize: 10))),
                Positioned(bottom: 40, right: 50,
                  child: Text('⋆', style: TextStyle(color: creamWhite.withValues(alpha: 0.12), fontSize: 9))),
                Positioned(bottom: 55, left: 25,
                  child: Text('⊹', style: TextStyle(color: warmBeige.withValues(alpha: 0.15), fontSize: 7))),
                Positioned(top: 70, right: 18,
                  child: Text('·', style: TextStyle(color: softGold.withValues(alpha: 0.2), fontSize: 6))),
                // Üst hafif ışık yansıması
                Positioned(
                  top: 0, left: 30, right: 30,
                  child: Container(
                    height: 1.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          creamWhite.withValues(alpha: 0.25),
                          softGold.withValues(alpha: 0.2),
                          creamWhite.withValues(alpha: 0.25),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                      ),
                    ),
                  ),
                ),
                // Ana içerik
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Column(
                    children: [
                      // Başlık
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bedtime_rounded, 
                            color: softGold.withValues(alpha: 0.4),
                            size: 14,
                            shadows: [Shadow(color: softGold.withValues(alpha: 0.3), blurRadius: 6)],
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _isTr ? 'KARTLARIN FISILTISI' : 'WHISPER OF THE CARDS',
                            style: TextStyle(
                              color: creamWhite.withValues(alpha: 0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.5,
                              shadows: [
                                Shadow(
                                  color: softGold.withValues(alpha: 0.4),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.bedtime_rounded, 
                            color: softGold.withValues(alpha: 0.4),
                            size: 14,
                            shadows: [Shadow(color: softGold.withValues(alpha: 0.3), blurRadius: 6)],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Başlık altı dekoratif çizgi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 30, height: 0.5,
                            color: softGold.withValues(alpha: 0.2),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text('⟡', style: TextStyle(color: softGold.withValues(alpha: 0.35), fontSize: 8)),
                          ),
                          Container(
                            width: 30, height: 0.5,
                            color: softGold.withValues(alpha: 0.2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // Sol kenar çizgili içerik alanı
                      Container(
                        padding: const EdgeInsets.only(left: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: softGold.withValues(alpha: 0.22),
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          '$advice\n\n$secretMessage',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                            height: 1.75,
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
    );
  }




  Widget _buildPromisesPanel() {
    final promises = _latestReading?.promises ?? _latestFullReading?.promises;
    if (promises == null || promises.isEmpty) return const SizedBox.shrink();
    
    final p1 = promises[0];
    final p2 = promises.length > 1 ? promises[1] : promises[0];
    final p3 = promises.length > 2 ? promises[2] : promises[0];

    // Her promise'a farklı ikon garanti et
    final icon1 = _getIconForKeyword(p1);
    var icon2 = _getIconForKeyword(p2);
    var icon3 = _getIconForKeyword(p3);
    
    // Pozisyona özel alternatif ikonlar
    final altIcons = [
      Icons.diamond_outlined,
      Icons.auto_awesome_outlined,
      Icons.hexagon_outlined,
      Icons.filter_vintage_outlined,
      Icons.brightness_7_outlined,
      Icons.lens_blur_outlined,
      Icons.blur_circular_outlined,
      Icons.compass_calibration_outlined,
      Icons.panorama_fish_eye_outlined,
      Icons.bubble_chart_outlined,
    ];
    
    if (icon2 == icon1) {
      icon2 = altIcons[p2.hashCode.abs() % altIcons.length];
    }
    if (icon3 == icon1 || icon3 == icon2) {
      for (final alt in altIcons) {
        if (alt != icon1 && alt != icon2) { icon3 = alt; break; }
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: GlassCard(
        useOwnLayer: true,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        shape: const LiquidRoundedSuperellipse(borderRadius: 20),
        settings: const LiquidGlassSettings(
          thickness: 16,
          blur: 10,
          glassColor: Color(0x1AE7D6A5),
          chromaticAberration: 0.1,
          lightIntensity: 1.0,
          ambientStrength: 0.85,
          refractiveIndex: 1.25,
          saturation: 1.1,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildPromiseItem(p1, icon1, const Color(0xFFFF4081)),
            _buildVerticalMisticLine(),
            _buildPromiseItem(p2, icon2, const Color(0xFFFFCA28)),
            _buildVerticalMisticLine(),
            _buildPromiseItem(p3, icon3, const Color(0xFF40C4FF)),
          ],
        ),
      ),
    );
  }

  Widget _buildMagicButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: () async {
        _setStateSafe(() => _magicBtnPressed = true);
        HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 200));
        if (!mounted) return;
        _setStateSafe(() => _magicBtnPressed = false);
        await Future.delayed(const Duration(milliseconds: 100));
        onTap();
      },
      child: AnimatedScale(
        scale: _magicBtnPressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: _magicBtnPressed 
                ? const Color(0xFFE7D6A5).withOpacity(0.15)
                : Colors.white.withOpacity(0.06),
            border: Border.all(
              color: _magicBtnPressed
                  ? const Color(0xFFE7D6A5).withOpacity(0.8)
                  : const Color(0xFFE7D6A5).withOpacity(0.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE7D6A5).withOpacity(_magicBtnPressed ? 0.25 : 0.08),
                blurRadius: _magicBtnPressed ? 35 : 20,
                spreadRadius: _magicBtnPressed ? 2 : -2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.refresh_rounded,
                color: const Color(0xFFE7D6A5).withOpacity(0.8),
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.cormorantGaramond(
                  color: const Color(0xFFE7D6A5),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyAdviceCard(String title, String advice) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Üst altın çizgi
          Container(
            height: 0.8,
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFFE7D6A5).withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          // Sonsuzluk ikonu
          Icon(
            Icons.all_inclusive_rounded,
            color: const Color(0xFFE7D6A5).withOpacity(0.4),
            size: 24,
          ),
          const SizedBox(height: 20),
          // Mesaj metni - büyük, vurucu
          Text(
            advice,
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              color: Colors.white.withOpacity(0.95),
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.6,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 28),
          // Alt altın çizgi
          Container(
            height: 0.8,
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFFE7D6A5).withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreditInfoPanel() {
    final isTr = _isTr;
    final hasCredit = !_dailyFreeUsed || _adCredits > 0;
    final creditCount = !_dailyFreeUsed ? 1 : _adCredits;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'CreditInfo',
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
                  child: GestureDetector(
                    onTap: () {}, // prevent dismiss on card tap
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: GlassCard(
                        useOwnLayer: true,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        shape: const LiquidRoundedSuperellipse(borderRadius: 24),
                        settings: const LiquidGlassSettings(
                          thickness: 24,
                          blur: 15,
                          glassColor: Color(0x1A1E1845),
                          chromaticAberration: 0.12,
                          lightIntensity: 1.0,
                          ambientStrength: 0.8,
                          refractiveIndex: 1.3,
                          saturation: 1.1,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Icon
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFE2C48E).withOpacity(0.25),
                                    const Color(0xFF9C6BFF).withOpacity(0.15),
                                  ],
                                ),
                                border: Border.all(
                                  color: const Color(0xFFE7D6A5).withOpacity(0.3),
                                  width: 0.5,
                                ),
                              ),
                              child: Icon(
                                Icons.auto_awesome,
                                color: hasCredit
                                    ? const Color(0xFFE2C48E)
                                    : Colors.white.withOpacity(0.4),
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Title
                            Text(
                              isTr ? 'Okuma Hakların' : 'Your Reading Credits',
                              style: GoogleFonts.cinzel(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Credit count
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  color: hasCredit
                                      ? const Color(0xFFE2C48E)
                                      : Colors.white.withOpacity(0.3),
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isTr
                                      ? '$creditCount okuma hakkın var'
                                      : '$creditCount credits remaining',
                                  style: TextStyle(
                                    color: hasCredit
                                        ? const Color(0xFFE2C48E).withOpacity(0.9)
                                        : Colors.white.withOpacity(0.4),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Info items
                            _creditInfoRow(
                              Icons.wb_sunny_outlined,
                              isTr
                                  ? 'Her gün 1 ücretsiz okuma hakkın var'
                                  : 'You get 1 free reading every day',
                              !_dailyFreeUsed,
                            ),
                            const SizedBox(height: 12),
                            _creditInfoRow(
                              Icons.play_circle_outline,
                              isTr
                                  ? 'Reklam izleyerek ek hak kazan'
                                  : 'Watch ads to earn extra credits',
                              true,
                            ),
                            const SizedBox(height: 12),
                            _creditInfoRow(
                              Icons.refresh_rounded,
                              isTr
                                  ? 'Haklar her gece sıfırlanır'
                                  : 'Credits reset every midnight',
                              false,
                            ),
                            const SizedBox(height: 24),
                            // Action buttons
                            Row(
                              children: [
                                // Reklam İzle butonu
                                Expanded(
                                  child: _TapScaleButton(
                                    onTap: () {
                                      Navigator.pop(context);
                                      _showAdPopup();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: Colors.white.withOpacity(0.08),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.15),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.play_circle_filled_rounded,
                                            color: Colors.white.withOpacity(0.7),
                                            size: 18,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            isTr ? 'Reklam İzle' : 'Watch Ad',
                                            style: GoogleFonts.inter(
                                              color: Colors.white.withOpacity(0.75),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Premium butonu
                                Expanded(
                                  child: _TapScaleButton(
                                    onTap: () {
                                      Navigator.pop(context);
                                      // TODO: Premium sayfasına yönlendir
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFD4A54A),
                                            Color(0xFFE8C97A),
                                            Color(0xFFD4A54A),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFD4A54A).withOpacity(0.3),
                                            blurRadius: 12,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.workspace_premium_rounded,
                                            color: Color(0xFF2A1810),
                                            size: 18,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            isTr ? 'Premium\'a Geç' : 'Go Premium',
                                            style: GoogleFonts.inter(
                                              color: const Color(0xFF2A1810),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
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
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, a1, a2, child) {
        return FadeTransition(
          opacity: a1,
          child: ScaleTransition(
            scale: CurvedAnimation(parent: a1, curve: Curves.easeOutBack),
            child: child,
          ),
        );
      },
    );
  }

  Widget _creditInfoRow(IconData icon, String text, bool isActive) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? const Color(0xFFE2C48E).withOpacity(0.12)
                : Colors.white.withOpacity(0.05),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isActive
                ? const Color(0xFFE2C48E).withOpacity(0.8)
                : Colors.white.withOpacity(0.3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isActive
                  ? Colors.white.withOpacity(0.75)
                  : Colors.white.withOpacity(0.4),
              fontSize: 13,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  void _showTarotGuidanceDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'TarotGuidance',
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                          _isTr ? 'Tarot Rehberi' : 'Tarot Guide',
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
                        ..._getRandomGuidanceItems(),
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
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(CurvedAnimation(
              parent: anim1,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
    );
  }

  List<Widget> _getRandomGuidanceItems() {
    final allItems = [
      _buildGuidanceItem(
        _isTr ? 'İçsel Bir Ayna' : 'An Inner Mirror',
        _isTr
            ? 'Mistik Tarot, kesin bir gelecek söylemek yerine kendi içine tutulan bir aynadır. Zihnindeki karmaşayı, korkularını ve gerçek umutlarını semboller aracılığıyla gün yüzüne çıkarır.'
            : 'Mystical Tarot is a mirror reflecting your inner self. It brings your hidden fears, hopes, and confusion to light through symbols.',
        Icons.visibility_outlined,
      ),
      _buildGuidanceItem(
        _isTr ? 'Objektif Perspektif' : 'Objective Perspective',
        _isTr
            ? 'Olayların içindeyken büyük resmi göremeyiz. Kartlar seni olayın dışına çıkartıp, durumu daha bilge ve tarafsız bir gözle değerlendirmeni sağlar.'
            : 'When you are in the middle of events, it is hard to see the big picture. Cards pull you out and let you observe with a wise, objective eye.',
        Icons.landscape_outlined,
      ),
      _buildGuidanceItem(
        _isTr ? 'Rehberlik ve Eylem' : 'Guidance and Action',
        _isTr
            ? 'Tarot seni çaresiz hissettirmez; "Senin elinde ne güç var?" sorusuna odaklanır. Şimdiki durumunu analiz eder ve en doğru eylemi sana nazikçe fısıldar.'
            : 'Tarot focuses on "What power do you hold?". It analyzes your present and gently whispers the best action to take.',
        Icons.explore_outlined,
      ),
      _buildGuidanceItem(
        _isTr ? 'Bilinçaltının Sesi' : 'Voice of the Subconscious',
        _isTr
            ? 'Kartlar, bilinçaltında sakladığın cevapları yüzeye çıkarır. Aslında cevabı zaten biliyorsun; kartlar sadece onu hatırlatır.'
            : 'Cards bring answers hidden in your subconscious to the surface. You already know the answer; cards simply remind you.',
        Icons.psychology_outlined,
      ),
      _buildGuidanceItem(
        _isTr ? 'Sembollerin Dili' : 'Language of Symbols',
        _isTr
            ? 'Her kart, binlerce yıllık arketipsel bir sembol taşır. Bu semboller evrenseldir ve ruhunun derinliklerine hitap eder.'
            : 'Each card carries an archetypal symbol thousands of years old. These symbols are universal and speak to the depths of your soul.',
        Icons.auto_stories_outlined,
      ),
      _buildGuidanceItem(
        _isTr ? 'Zamanın Akışı' : 'Flow of Time',
        _isTr
            ? 'Geçmiş seni şekillendirdi, şimdi seni tanımlar, gelecek ise senin ellerinde. Kartlar bu üç zamanın arasındaki köprüyü kurar.'
            : 'The past shaped you, the present defines you, and the future is in your hands. Cards build the bridge between these three times.',
        Icons.timeline_outlined,
      ),
      _buildGuidanceItem(
        _isTr ? 'Cesarete Davet' : 'Invitation to Courage',
        _isTr
            ? 'Bazen en zor kart, en gerekli mesajı taşır. Rahatsız eden bir yorum, aslında büyümenin kapısını aralıyor olabilir.'
            : 'Sometimes the hardest card carries the most needed message. An uncomfortable interpretation may be opening the door to growth.',
        Icons.local_fire_department_outlined,
      ),
      _buildGuidanceItem(
        _isTr ? 'Dönüşüm Gücü' : 'Power of Transformation',
        _isTr
            ? 'Her çekim, bir dönüşüm fırsatıdır. Kartlar sana ne olduğunu değil, ne olabileceğini gösterir. Değişim senin içinde başlar.'
            : 'Every reading is an opportunity for transformation. Cards show not what is, but what can be. Change begins within you.',
        Icons.change_circle_outlined,
      ),
      _buildGuidanceItem(
        _isTr ? 'Sezgisel Bilgelik' : 'Intuitive Wisdom',
        _isTr
            ? 'Mantık sınırlıdır ama sezgi sınırsızdır. Kartları seçerken hissettiğin çekim, bilinçaltının sana yol göstermesidir.'
            : 'Logic is limited but intuition is boundless. The pull you feel when choosing cards is your subconscious guiding you.',
        Icons.self_improvement_outlined,
      ),
    ];
    allItems.shuffle(Random());
    return allItems.take(3).toList();
  }

  Widget _buildGuidanceItem(String title, String desc, IconData icon) {
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

  Widget _buildReadingSection({
    required String title,
    required String content,
    required String cardName,
    required String cardAsset,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sol Taraf: Kart Görseli (kompakt)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: color.withOpacity(0.12),
                  blurRadius: 10,
                  spreadRadius: -3,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 65,
                height: 100,
                child: Transform.scale(
                  scale: 1.15,
                  child: Image.asset(
                    cardAsset,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Sağ Taraf: Kart İsmi + Yorum
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                // Kart İsmi
                Text(
                  cardName,
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                // Yorum
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2, right: 8),
                      width: 2,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [color.withOpacity(0.7), color.withOpacity(0.0)],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        content,
                        style: GoogleFonts.lora(
                          color: Colors.white.withOpacity(0.92),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          height: 1.45,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Full Arcana — 7 Kart Carousel (Yana Kaydırmalı, Sembol Dallanmalı)
  Widget _buildFullCardCarousel() {
    if (_latestFullReading == null) return const SizedBox.shrink();
    final reading = _latestFullReading!;

    // PageController'ı lazy init
    _fullCardPageCtrl ??= PageController(viewportFraction: 1.0);

    // İnfografik açılış animasyonu
    if (_infoRevealCtrl == null) {
      _infoRevealCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      )..forward();
    }

    // Her pozisyon için benzersiz renk ve ikon


    return Column(
      children: [
        // ── SABİT POZİSYON YAZISI ──
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            reading.cardReadings[_fullCardPageIndex].positionTitle.toUpperCase(),
            key: ValueKey(_fullCardPageIndex),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 2),
        // Carousel — tam ekran genişliğinde (parent padding yok)
        SizedBox(
          height: 390,
          child: PageView.builder(
            controller: _fullCardPageCtrl,
            itemCount: reading.cardReadings.length,
            onPageChanged: (i) {
              _setStateSafe(() => _fullCardPageIndex = i);
              _infoRevealCtrl?.forward(from: 0.0);
            },
            itemBuilder: (context, pageIndex) {
              final cardId = reading.cardReadings[pageIndex].cardIndex;
              final cardAsset = _allCards[cardId].frontAsset;
              final symbols = getCardSymbols(cardId);
              final symbolCount = getSymbolCountForPosition(pageIndex, symbols.length);
              final selectedSymbols = symbols.take(symbolCount).toList();
              final isActivePage = pageIndex == _fullCardPageIndex;
              // Her oturumda aynı kart için tutarlı ama her oturumda farklı anlamlar
              final symbolRng = Random(cardId * 1000 + DateTime.now().day * 31 + DateTime.now().hour);

              const cardW = 155.0;
              const cardH = 240.0;
              const cardTop = 15.0;

              // ── KOORDINAT DÖNÜŞÜM (640x640 → 155x240) ──
              // All card images are 640x640 (square).
              // BoxFit.cover renders at 240x240 (match height), then
              // crops (240-155)/2 = 42.5px from each side horizontally.
              // Transform.scale(1.12) then zooms 12% from center.
              const imgRenderedW = 240.0; // square image → rendered width = height
              const cropX = (imgRenderedW - cardW) / 2; // 42.5
              const scale = 1.12;

              return LayoutBuilder(
                builder: (context, constraints) {
                  final stackW = constraints.maxWidth;
                  final cardLeft = (stackW - cardW) / 2;

                  // Convert original image coord (0-1) to widget pixel offset
                  double anchorPxX(double ax) {
                    final covered = ax * imgRenderedW - cropX;
                    return cardLeft + cardW / 2 + (covered - cardW / 2) * scale;
                  }
                  double anchorPxY(double ay) {
                    final covered = ay * cardH;
                    return cardTop + cardH / 2 + (covered - cardH / 2) * scale;
                  }

                  // ── SOL / SAĞ SEMBOL DAĞILIMI ──
                  final leftSymbols = <CardSymbol>[];
                  final rightSymbols = <CardSymbol>[];
                  for (final s in selectedSymbols) {
                    if (s.anchorX < 0.45) {
                      leftSymbols.add(s);
                    } else if (s.anchorX > 0.55) {
                      rightSymbols.add(s);
                    } else {
                      // Merkez semboller — kısa tarafa ekle
                      if (leftSymbols.length <= rightSymbols.length) {
                        leftSymbols.add(s);
                      } else {
                        rightSymbols.add(s);
                      }
                    }
                  }
                  // En az 1 sembol her tarafta olsun (görsel denge)
                  if (leftSymbols.isEmpty && rightSymbols.length >= 2) {
                    leftSymbols.add(rightSymbols.removeLast());
                  } else if (rightSymbols.isEmpty && leftSymbols.length >= 2) {
                    rightSymbols.add(leftSymbols.removeLast());
                  }
                  // Y sırasına göre sırala → çizgi çaprazlanmasını engelle
                  leftSymbols.sort((a, b) => a.anchorY.compareTo(b.anchorY));
                  rightSymbols.sort((a, b) => a.anchorY.compareTo(b.anchorY));

                  // ── ÇİZGİ + ETİKET HESAPLAMA ──
                  final linePoints = <Map<String, double>>[];
                  final labelWidgets = <Widget>[];
                  const labelH = 38.0;
                  const labelGap = 4.0;

                  // Sol taraf etiketler
                  if (leftSymbols.isNotEmpty) {
                    final totalH = leftSymbols.length * labelH +
                        (leftSymbols.length - 1) * labelGap;
                    final baseY = cardTop + (cardH - totalH) / 2;
                    for (int i = 0; i < leftSymbols.length; i++) {
                      final s = leftSymbols[i];
                      final startX = anchorPxX(s.anchorX);
                      final startY = anchorPxY(s.anchorY);
                      final labelY = baseY + i * (labelH + labelGap);
                      final lineY = labelY + labelH / 2;
                      final leftEndX = cardLeft - 35;
                      linePoints.add({
                        'startX': startX, 'startY': startY,
                        'elbowX': cardLeft - 8,
                        'endX': leftEndX, 'endY': lineY,
                      });
                      labelWidgets.add(Positioned(
                        left: 0, top: labelY,
                        width: leftEndX - 4,
                        child: AnimatedBuilder(
                          animation: _infoRevealCtrl!,
                          builder: (context, _) {
                            if (!isActivePage) return const SizedBox.shrink();
                            final t = Curves.easeOutCubic.transform(_infoRevealCtrl!.value);
                            final labelOpacity = ((t - 0.25) / 0.75).clamp(0.0, 1.0);
                            return Opacity(
                              opacity: labelOpacity,
                              child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _isTr ? s.nameTr : s.nameEn,
                              textAlign: TextAlign.right,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                            Text(
                              _isTr ? s.meaningTr(symbolRng) : s.meaningEn(symbolRng),
                              textAlign: TextAlign.right,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: const Color(0xFFE9C46A).withValues(alpha: 0.7),
                                fontSize: 8,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                            );
                          },
                        ),
                      ));
                    }
                  }

                  // Sağ taraf etiketler
                  if (rightSymbols.isNotEmpty) {
                    final totalH = rightSymbols.length * labelH +
                        (rightSymbols.length - 1) * labelGap;
                    final baseY = cardTop + (cardH - totalH) / 2;
                    for (int i = 0; i < rightSymbols.length; i++) {
                      final s = rightSymbols[i];
                      final startX = anchorPxX(s.anchorX);
                      final startY = anchorPxY(s.anchorY);
                      final labelY = baseY + i * (labelH + labelGap);
                      final lineY = labelY + labelH / 2;
                      final rightEndX = cardLeft + cardW + 35;
                      linePoints.add({
                        'startX': startX, 'startY': startY,
                        'elbowX': cardLeft + cardW + 8,
                        'endX': rightEndX, 'endY': lineY,
                      });
                      labelWidgets.add(Positioned(
                        left: rightEndX + 4, top: labelY, right: 0,
                        child: AnimatedBuilder(
                          animation: _infoRevealCtrl!,
                          builder: (context, _) {
                            if (!isActivePage) return const SizedBox.shrink();
                            final t = Curves.easeOutCubic.transform(_infoRevealCtrl!.value);
                            final labelOpacity = ((t - 0.25) / 0.75).clamp(0.0, 1.0);
                            return Opacity(
                              opacity: labelOpacity,
                              child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _isTr ? s.nameTr : s.nameEn,
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                            Text(
                              _isTr ? s.meaningTr(symbolRng) : s.meaningEn(symbolRng),
                              textAlign: TextAlign.left,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: const Color(0xFFE9C46A).withValues(alpha: 0.7),
                                fontSize: 8,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                            );
                          },
                        ),
                      ));
                    }
                  }

                  return Container(
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: cardH + 20,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // ── KART ──
                              Positioned(
                                top: cardTop,
                                left: cardLeft,
                                child: Hero(
                                  tag: 'reading_card_$pageIndex',
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.5),
                                          blurRadius: 24,
                                          spreadRadius: 4,
                                          offset: const Offset(0, 12),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      clipBehavior: Clip.hardEdge,
                                      child: GestureDetector(
                                        onTapUp: (details) {
                                          final dx = details.localPosition.dx;
                                          final dy = details.localPosition.dy;
                                          final scaleX = (dx - cardW / 2) / scale + cardW / 2;
                                          final scaleY = (dy - cardH / 2) / scale + cardH / 2;
                                          final coveredX = scaleX + cropX;
                                          final coveredY = scaleY;
                                          final ax = coveredX / imgRenderedW;
                                          final ay = coveredY / cardH;
                                          
                                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Card $cardId Koordinat: [${ax.toStringAsFixed(2)}, ${ay.toStringAsFixed(2)}]',
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                              ),
                                              backgroundColor: Colors.blueAccent.withValues(alpha: 0.9),
                                              duration: const Duration(seconds: 4),
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        },
                                        child: SizedBox(
                                          width: cardW,
                                          height: cardH,
                                          child: Transform.scale(
                                            scale: 1.12,
                                            child: Image.asset(cardAsset, fit: BoxFit.cover),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // ── İNFOGRAFİK ÇİZGİLER (animasyonlu) ──
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: AnimatedBuilder(
                                    animation: _infoRevealCtrl!,
                                    builder: (context, child) {
                                      if (!isActivePage) return const SizedBox.shrink();
                                      // 0.0-0.6 arası çizgiler büyür
                                      final t = Curves.easeOutCubic.transform(_infoRevealCtrl!.value);
                                      final lineProgress = (t / 0.35).clamp(0.0, 1.0);
                                      return Opacity(
                                        opacity: lineProgress,
                                        child: CustomPaint(
                                          painter: _InfographicLinePainter(linePoints, progress: lineProgress),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              // ── SEMBOL ETİKETLERİ (animasyonlu) ──
                              ...labelWidgets,
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // ── KART İSMİ (animasyonlu) ──
                        AnimatedBuilder(
                          animation: _infoRevealCtrl!,
                          builder: (context, _) {
                            if (!isActivePage) return const SizedBox.shrink();
                            final t = Curves.easeOutCubic.transform(_infoRevealCtrl!.value);
                            final nameOpacity = ((t - 0.35) / 0.65).clamp(0.0, 1.0);
                            return Opacity(
                              opacity: nameOpacity,
                              child: Text(
                                _isTr ? _allCards[cardId].nameTr : _allCards[cardId].nameEn,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        // ── ETKİLİ YORUM (animasyonlu) ──
                        AnimatedBuilder(
                          animation: _infoRevealCtrl!,
                          builder: (context, _) {
                            if (!isActivePage) return const SizedBox.shrink();
                            final t = Curves.easeOutCubic.transform(_infoRevealCtrl!.value);
                            final contentOpacity = ((t - 0.45) / 0.55).clamp(0.0, 1.0);
                            return Opacity(
                              opacity: contentOpacity,
                                child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Text(
                                  reading.cardReadings[pageIndex].content,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.75),
                                    fontSize: 13.5,
                                    height: 1.5,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Sayfa göstergesi (dot indicators)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(7, (i) {
            final isActive = i == _fullCardPageIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 24 : 10,
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: isActive ? Colors.white.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.08),
                border: Border.all(
                  color: isActive ? Colors.white.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        // Kaydırma ipucu
        Text(
          _isTr ? '← kaydır →' : '← swipe →',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.30),
            fontSize: 11,
            letterSpacing: 1,
          ),
        ),
      ],
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
      _latestReading = null;
      _latestFullReading = null;
      _selectedTablePositions.clear();
      _hiddenCards.clear();
      _reservedSlotCount = 0;
      _revealedCount = 0;
      _selectedCardIndexes = [];
    });
    _resetDeck();
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
    // SwipeBackWrapper sürükleme sırasında kart seçimini engelle
    if (SwipeBackWrapper.isSwiping) return;
    // Sayfa kaydırılırken (geri jesti) veya kapanırken kart tıklanmasını engelle
    final route = ModalRoute.of(context);
    if (route != null && route.animation != null) {
      final anim = route.animation!;
      // Sayfa kapanıyorsa (reverse) veya henüz tam açılmadıysa engelle
      if (anim.status == AnimationStatus.reverse) return;
      if (anim.status != AnimationStatus.completed) return;
      // SwipeBackWrapper sürükleme sırasında value düşer — bunu da yakala
      if (anim.value < 0.99) return;
    }
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
                ..scale(cos(flipAngle).abs().clamp(0.01, 1.0), 1.0, 1.0),
              child: SizedBox(
                width: w,
                height: h,
                child: showFront
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildCardFront(cardIdx),
                      )
                    : _tarotCard(0, 22),
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

  // ── 78 Card Grid for Tam Arkana ──
  Widget _buildFullArcanaGrid() {
    const columns = 6;
    const spacing = 4.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final gridWidth = constraints.maxWidth > 0 ? constraints.maxWidth : MediaQuery.of(context).size.width - 48;
        final cardW = (gridWidth - (columns - 1) * spacing) / columns;
        final cardH = cardW * 1.5;
        final rows = (78 / columns).ceil();
        final gridHeight = rows * (cardH + spacing) - spacing;
        
        return SizedBox(
          height: gridHeight.clamp(0, 380),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: List.generate(78, (i) {
                  final cardIndex = _tableCards.isNotEmpty && i < _tableCards.length
                      ? _tableCards[i]
                      : i;
                  final isSelected = _selectedTablePositions.contains(i);
                  final isHidden = _hiddenCards.contains(i);

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (_) {
                      if (SwipeBackWrapper.isSwiping) return;
                      if (isSelected || isHidden) return;
                      _selectCard(i, _cardKeys[i]);
                    },
                    child: AnimatedScale(
                      scale: isHidden ? 0.85 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: AnimatedOpacity(
                        opacity: isHidden ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: SizedBox(
                          key: _cardKeys[i],
                          width: cardW,
                          height: cardH,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFF2A1F4E),
                                  Color(0xFF1A0F2E),
                                ],
                              ),
                              border: Border.all(
                                color: const Color(0xFFE7D6A5).withOpacity(0.2),
                                width: 0.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Card back pattern
                                Center(
                                  child: Icon(
                                    Icons.auto_awesome,
                                    size: 14,
                                    color: const Color(0xFFE7D6A5).withOpacity(0.15),
                                  ),
                                ),
                                // Corner decorations
                                Positioned(
                                  top: 2,
                                  left: 2,
                                  child: Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFFE7D6A5).withOpacity(0.12),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 2,
                                  right: 2,
                                  child: Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFFE7D6A5).withOpacity(0.12),
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
                }),
              ),
            ),
          ),
        );
      },
    );
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
    final frontAsset = _safeFrontAsset(cardIdx);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.hardEdge,
      child: Transform.scale(
        scale: 1.12,
        child: Image.asset(
          frontAsset,
          fit: BoxFit.cover,
        ),
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
            'assets/images/tarot/ip$num.webp',
            height: height,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _tarotCard([int index = 0, int totalCards = 22]) {
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
    return PopScope(
      canPop: _state != RitualState.revealed,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _state == RitualState.revealed) {
          _resetToIdle();
        }
      },
      child: Scaffold(
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
            child: RepaintBoundary(
              child: IgnorePointer(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _TarotMottledPainter(),
                ),
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
          RepaintBoundary(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.04,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _NoisePainter(),
                ),
              ),
            ),
          ),

          // ── ✨ Aurora + Stars ──
          Positioned.fill(
            child: RepaintBoundary(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _StarFieldPainter(pulse: bv),
                ),
              ),
            ),
          ),

          // ── 🔮 Bokeh Light Orbs ──
          Positioned.fill(
            child: RepaintBoundary(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _BokehPainter(pulse: bv),
                ),
              ),
            ),
          ),

          // ── ✨ Star Dust (tiny space particles) ──
          Positioned.fill(
            child: RepaintBoundary(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _StarDustPainter(pulse: bv),
                ),
              ),
            ),
          ),


          // ── 💫 Floating Light Particles ──
          ...List.generate(6, (i) {
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
                    Colors.white,
                    Colors.white,
                  ],
                  stops: [0.0, 0.3, 1.0],
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


          // ── TAM EKRAN BLUR EFEKTİ VE NEFES ALAN ARKA PLAN AURASI ──
          if (_state == RitualState.revealed)
            Positioned.fill(
              child: IgnorePointer(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1100),
                curve: Curves.easeInOut,
                builder: (context, value, _) {
                  return Opacity(
                    opacity: value,
                    child: Stack(
                      children: [
                        // Blur Layer
                        Positioned.fill(
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(
                              sigmaX: 14.0,
                              sigmaY: 14.0,
                            ),
                            child: Container(
                              color: Colors.black.withOpacity(0.55),
                            ),
                          ),
                        ),
                        
                        // Breathable Aura Glow Layer
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _bgPulseCtrl,
                            builder: (context, child) {
                              final pulse = sin(_bgPulseCtrl.value * pi * 2) * 0.5 + 0.5;
                              
                              // Aura rengi flowType'a veya mistik temaya göre değişebilir,
                              // şimdilik derin bir büyü / ametist moru + altın karışımı.
                              final Color auraColor1 = const Color(0xFF6C3FA0).withOpacity(0.15 + pulse * 0.1);
                              final Color auraColor2 = const Color(0xFFE7D6A5).withOpacity(0.05 + pulse * 0.05);

                              return Container(
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    center: const Alignment(0, -0.2), // Ekranın hafif üst merkezinden
                                    radius: 1.2 + pulse * 0.1, // Nefes alarak büyüyüp küçülen
                                    colors: [
                                      auraColor1,
                                      auraColor2,
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.4, 1.0],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            ),

          SafeArea(
            child: AnimatedBuilder(
              animation: _readingScrollCtrl,
              builder: (context, child) {
                double offset = 0;
                if (_readingScrollCtrl.hasClients) {
                  offset = _readingScrollCtrl.offset.clamp(0.0, double.infinity);
                }
                return Transform.translate(
                  offset: Offset(0, -offset),
                  child: child,
                );
              },
              child: Column(
                children: [
                // Header with back button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      // Back button – frosted glass iOS style
                      // revealed durumda overlay butonu var, çakışma olmasın
                      Opacity(
                        opacity: _state == RitualState.revealed ? 0.0 : 1.0,
                        child: IgnorePointer(
                          ignoring: _state == RitualState.revealed,
                          child: SizedBox(
                            width: 95,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: GlassBackButton(
                                onTap: () {
                                  if (_state == RitualState.revealed) {
                                    _resetToIdle();
                                  } else {
                                    Navigator.pop(context);
                                  }
                                },
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
                          child: Text(
                            'Tarot',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cinzel(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      // Kredi göstergesi ve Rehberlik butonu
                      Opacity(
                        opacity: _state == RitualState.revealed ? 0.0 : 1.0,
                        child: IgnorePointer(
                          ignoring: _state == RitualState.revealed,
                          child: SizedBox(
                        width: 95,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                              children: [
                                _TapScaleButton(
                                  onTap: _showTarotGuidanceDialog,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ClipOval(
                                      child: BackdropFilter(
                                        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                        child: Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.10),
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
                                _TapScaleButton(
                                  onTap: _showCreditInfoPanel,
                                  child: ClipOval(
                                    child: BackdropFilter(
                                      filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                      child: Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.10),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.18),
                                            width: 0.6,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.auto_awesome,
                                              size: 11,
                                              color: (!_dailyFreeUsed || _adCredits > 0)
                                                  ? Colors.white.withOpacity(0.85)
                                                  : Colors.white.withOpacity(0.25),
                                            ),
                                            const SizedBox(width: 1),
                                            Text(
                                              !_dailyFreeUsed ? '1' : '$_adCredits',
                                              style: TextStyle(
                                                color: (!_dailyFreeUsed || _adCredits > 0)
                                                    ? Colors.white.withOpacity(0.85)
                                                    : Colors.white.withOpacity(0.3),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
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
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedBuilder(
                  animation: Listenable.merge([_bgPulseCtrl]),
                  builder: (_, __) {
                    final selected = _selectedTablePositions.length;
                    final max = _maxSlots;
                    final String subtitle;
                    if (selected == 0) {
                      subtitle = _t('Kartlarını Seç', 'Pick Your Cards');
                    } else if (selected < max) {
                      subtitle = _t('$selected / $max kart seçildi', '$selected / $max cards selected');
                    } else {
                      subtitle = _t('Yorumu Gör ✦', 'View Reading ✦');
                    }
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: Text(
                        subtitle,
                        key: ValueKey(subtitle),
                        style: GoogleFonts.cinzel(
                          color: selected >= max 
                              ? const Color(0xFFE2C48E) 
                              : Colors.white70,
                          fontSize: 13,
                          fontWeight: selected >= max ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    );
                  },
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
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // ── Deck + Guide + Buttons (altta sabit) ──
                      Positioned(
                        left: 0, right: 0, bottom: -30,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                          opacity: _state == RitualState.revealed ? 0.0 : 1.0,
                          child: IgnorePointer(
                            ignoring: _state == RitualState.revealed,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
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
                                    // ── Card Fan ──
                                    _FloatingTarotDeck(
                                      key: ValueKey('deck_${_isBuyukArkana ? "b" : "t"}_$_deckRebuildKey'),
                                      onCardTap: _selectCard,
                                      cardBuilder: (int idx, int total) => _tarotCard(idx, total),
                                      cardKeys: _cardKeys.sublist(0, _tableCount),
                                      selectedPositions: _selectedTablePositions,
                                      hiddenCards: _hiddenCards,
                                    ),
                                  ],
                                ),
                                // ── Guide text ──
                                Transform.translate(
                                  offset: const Offset(0, -42),
                                  child: AnimatedBuilder(
                                    animation: _bgPulseCtrl,
                                    builder: (_, __) {
                                      return Opacity(
                                        opacity: 0.7,
                                        child: Text(
                                          _t('Bir kart seç veya rastgele çek', 'Pick a card or shuffle'),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            letterSpacing: 0.5,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Büyük Arkana / Tam Arkana buttons ve altındaki çizgi
                                Transform.translate(
                                  offset: const Offset(0, -30),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
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
                                                          Positioned(
                                                            top: 2, left: 16, right: 16,
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
                                                              'Major Arcana',
                                                              style: TextStyle(
                                                                color: _isBuyukArkana ? Colors.white : Colors.white70,
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
                                                          Positioned(
                                                            top: 2, left: 16, right: 16,
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
                                                              'Full Arcana',
                                                              style: TextStyle(
                                                                color: !_isBuyukArkana ? Colors.white : Colors.white70,
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
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // ── Slots (üstte) ──
                      Column(
                        mainAxisSize: MainAxisSize.min,
                    children: [
                          // ── Glow behind card slots & The Slots ──
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.0, end: _state == RitualState.revealed ? 1.0 : 0.0),
                            duration: const Duration(milliseconds: 1100),
                            curve: Curves.easeInOut,
                            builder: (context, val, child) {
                              return Transform.translate(
                                offset: Offset(0, 40.0 * val),
                                child: child,
                              );
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
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
                                height: _isBuyukArkana ? 175 : 350,
                            child: AnimatedBuilder(
                              animation: Listenable.merge([_slotEntranceCtrl, _bgPulseCtrl, ..._slotGlowControllers]),
                              builder: (_, __) {
                                final slotLabels3 = [
                                  _t('Geçmiş', 'Past'),
                                  _t('Şimdi', 'Present'),
                                  _t('Gelecek', 'Future'),
                                ];
                                final slotLabels7 = [
                                  _t('Geçmiş', 'Past'),
                                  _t('Şimdi', 'Present'),
                                  _t('Gizli Etki', 'Hidden'),
                                  _t('Engel', 'Obstacle'),
                                  _t('Çevre', 'Environ.'),
                                  _t('Tavsiye', 'Advice'),
                                  _t('Sonuç', 'Outcome'),
                                ];
                                final slotLabels = _isBuyukArkana ? slotLabels3 : slotLabels7;
                                final slotSymbols3 = [Icons.nightlight_round, Icons.circle_outlined, Icons.auto_awesome];
                                final slotSymbols7 = [Icons.nightlight_round, Icons.circle_outlined, Icons.auto_awesome, Icons.star_outline, Icons.brightness_low, Icons.nights_stay, Icons.diamond_outlined];
                                final symbols = _isBuyukArkana ? slotSymbols3 : slotSymbols7;
                                final cardW = _isBuyukArkana ? 88.0 : 70.0;
                                final cardH = _isBuyukArkana ? 138.0 : 105.0;
                                final topCount = _isBuyukArkana ? 3 : 4;
                                final bottomCount = _isBuyukArkana ? 0 : 3;

                                Widget buildSlot(int i) {
                                  final isFilled = _selectedTablePositions.length > i;
                                  final totalSlots = topCount + bottomCount;
                                  final delayPerSlot = totalSlots > 1 ? 0.4 / (totalSlots - 1) : 0.0;
                                  final delay = i * delayPerSlot;
                                  final duration = 0.6;
                                  final rawT = ((_slotEntranceCtrl.value - delay) / duration).clamp(0.0, 1.0);
                                  final scaleT = Curves.easeOutQuint.transform(rawT); 
                                  final fadeT = Curves.easeOutQuad.transform(rawT);
                                  final slideY = (1.0 - fadeT) * 12.0; 
  
                                  final isRevealed = _state == RitualState.revealed;
  
                                  return TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 0.0, end: isRevealed ? 1.0 : 0.0),
                                    duration: const Duration(milliseconds: 1100),
                                    curve: Curves.easeInOut,
                                    builder: (context, revealT, child) {
                                      // Yorum paneli açıldığındaki değerler (revealT: 0.0 -> 1.0)
                                      final currentScale = 1.0 + ((_isBuyukArkana ? 0.20 : 0.05) * revealT); 
                                      // Full Arcana: dalgalı dizilim (tek kartlar yukarı, çift kartlar aşağı)
                                      double currentY;
                                      if (_isBuyukArkana) {
                                        currentY = (i != 1) ? 40.0 * revealT : 0.0;
                                      } else {
                                      // 7 kart için zigzag — tek kartlar yukarı, çift kartlar aşağı (hizalı)
                                        const waveOffsets = [-28.0, -28.0, -28.0, -28.0, -18.0, -18.0, -18.0];
                                        final waveY = (i < waveOffsets.length) ? waveOffsets[i] : 0.0;
                                        currentY = waveY * revealT;
                                      }
                                      final basePadding = _isBuyukArkana ? 8.0 : 4.0;
                                      final maxPadding = _isBuyukArkana ? 16.0 : 6.0;
                                      final currentPadding = basePadding + ((maxPadding - basePadding) * revealT);

                                      return Padding(
                                        padding: EdgeInsets.symmetric(horizontal: currentPadding),
                                        child: Transform.translate(
                                          offset: Offset(0, slideY),
                                          child: Transform.scale(
                                            scale: scaleT,
                                            child: Opacity(
                                              opacity: fadeT,
                                              child: Transform(
                                                alignment: Alignment.center,
                                                transform: Matrix4.identity()
                                                  ..translate(0.0, currentY)
                                                  ..scale(currentScale, currentScale),
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
                                                          borderRadius: BorderRadius.circular(12),
                                                          boxShadow: totalGlow > 0.05 ? [
                                                            BoxShadow(
                                                              color: const Color(0xFFE7D6A5).withOpacity(0.15 * totalGlow),
                                                              blurRadius: 6 * totalGlow,
                                                            ),
                                                          ] : null,
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(12),
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
                                                            child: Icon(
                                                              symbols[i],
                                                              size: _isBuyukArkana ? 26 : 20,
                                                              color: Colors.white.withOpacity(0.15 + pulse * 0.15),
                                                              shadows: [
                                                                Shadow(
                                                                  color: const Color(0xFFB388FF).withOpacity(0.3 * pulse),
                                                                  blurRadius: 8,
                                                                ),
                                                              ],
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
                                              const SizedBox(height: 4),
                                              SizedBox(
                                                width: cardW + 8,
                                                height: _isBuyukArkana ? 16 : 28,
                                                child: AnimatedSwitcher(
                                                  duration: const Duration(milliseconds: 400),
                                                  child: Text(
                                                    isFilled 
                                                        ? _cardName(_tableCards[_selectedTablePositions[i]])
                                                        : slotLabels[i],
                                                    key: ValueKey(isFilled 
                                                        ? 'card_${_selectedTablePositions[i]}' 
                                                        : 'label_$i'),
                                                    textAlign: TextAlign.center,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: GoogleFonts.cinzel(
                                                      color: isFilled 
                                                          ? Colors.white.withOpacity(0.7)
                                                          : Colors.white.withOpacity(0.55),
                                                      fontSize: _isBuyukArkana ? 10 : 9,
                                                      fontWeight: isFilled ? FontWeight.w700 : FontWeight.w600,
                                                      letterSpacing: 0.3,
                                                      height: 1.1,
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
                                );
                                    },
                                  );
                                }

                                return OverflowBox(
                                  maxHeight: double.infinity,
                                  maxWidth: double.infinity,
                                  alignment: _isBuyukArkana ? Alignment.center : Alignment.topCenter,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: List.generate(topCount, (i) => buildSlot(i)),
                                        ),
                                        if (bottomCount > 0) ...[
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: List.generate(bottomCount, (i) => buildSlot(topCount + i)),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                              ],
                            ),
                          ),
                    ],
                  ),
                    ],
                  ),
                ),
              ],  // main Column children
            ),  // main Column
            ),  // AnimatedBuilder
          ),  // SafeArea (body padding)



          // ── YORUM METİNLERİ (Sadece Yazılar, Kartların Altında) ──
          if (_state == RitualState.revealed && (_latestReading != null || _latestFullReading != null))
            Positioned.fill(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                builder: (context, value, _) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 30 * (1.0 - value)),
                      child: Container(
                        child: SingleChildScrollView(
                            controller: _readingScrollCtrl,
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // ── ÜST KISIM (Tüm yazılar ve paneller Carousel'e kadar) ──
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    SizedBox(height: MediaQuery.of(context).padding.top + (_isBuyukArkana ? 365 : 440)),

                                    // Ana Tema cümlesi (sadece Major Arcana)
                                    if (_isBuyukArkana)
                                    _buildGlowingQuoteCard(
                                      _latestReading?.generalTheme ?? _latestFullReading!.generalTheme,
                                    ).animate()
                                      .fadeIn(duration: 800.ms, delay: 300.ms)
                                      .slideY(begin: 0.15, end: 0, duration: 800.ms, delay: 300.ms, curve: Curves.easeOut),
                                    if (_isBuyukArkana)
                                    const SizedBox(height: 16),

                                    // Major Arcana: 3 kart yorumu
                                    if (_latestReading != null) ...[
                                      _buildReadingSection(
                                        title: _isTr ? 'Geçmiş' : 'Past',
                                        content: _latestReading!.pastInfluence,
                                        cardName: _cardName(_selectedCardIndexes[0]),
                                        cardAsset: _allCards[_selectedCardIndexes[0]].frontAsset,
                                        icon: Icons.history_edu,
                                        color: const Color(0xFFE7D6A5),
                                      ).animate()
                                        .fadeIn(duration: 800.ms, delay: 900.ms)
                                        .slideY(begin: 0.2, end: 0, duration: 800.ms, delay: 900.ms, curve: Curves.easeOut),
                                      const SizedBox(height: 12),
                                      _buildMysticalDivider(Icons.bedtime_rounded).animate()
                                        .fadeIn(duration: 600.ms, delay: 1400.ms),
                                      const SizedBox(height: 12),
                                      
                                      _buildReadingSection(
                                        title: _isTr ? 'Şimdi' : 'Present',
                                        content: _latestReading!.presentEnergy,
                                        cardName: _cardName(_selectedCardIndexes[1]),
                                        cardAsset: _allCards[_selectedCardIndexes[1]].frontAsset,
                                        icon: Icons.visibility,
                                        color: const Color(0xFFE7D6A5),
                                      ).animate()
                                        .fadeIn(duration: 800.ms, delay: 1800.ms)
                                        .slideY(begin: 0.2, end: 0, duration: 800.ms, delay: 1800.ms, curve: Curves.easeOut),
                                      const SizedBox(height: 12),
                                      _buildMysticalDivider(Icons.auto_awesome).animate()
                                        .fadeIn(duration: 600.ms, delay: 2300.ms),
                                      const SizedBox(height: 12),
                                      
                                      _buildReadingSection(
                                        title: _isTr ? 'Yön' : 'Direction',
                                        content: _latestReading!.directionAdvice,
                                        cardName: _cardName(_selectedCardIndexes[2]),
                                        cardAsset: _allCards[_selectedCardIndexes[2]].frontAsset,
                                        icon: Icons.explore,
                                        color: const Color(0xFFE7D6A5),
                                      ).animate()
                                        .fadeIn(duration: 800.ms, delay: 2700.ms)
                                        .slideY(begin: 0.2, end: 0, duration: 800.ms, delay: 2700.ms, curve: Curves.easeOut),
                                      const SizedBox(height: 24),
                                    ],

                                    // Full Arcana: Premium yorum akışı (Carousel Öncesi)
                                    if (_latestFullReading != null) ...[
                                      const SizedBox(height: 24),
                                      // 1. Kozmik Uyum Skoru
                                      _buildCosmicScorePanel(
                                        _latestFullReading!.cosmicScore,
                                        _isTr ? _latestFullReading!.cosmicLabelTr : _latestFullReading!.cosmicLabelEn,
                                      ).animate()
                                        .fadeIn(duration: 800.ms, delay: 600.ms)
                                        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 800.ms, delay: 600.ms, curve: Curves.easeOut),
                                      const SizedBox(height: 16),

                                      _buildMysticalDivider(Icons.flare_rounded).animate()
                                        .fadeIn(duration: 600.ms, delay: 1000.ms),
                                      const SizedBox(height: 16),
                                    ],
                                  ],
                                ),
                              ),

                              // ── CAROUSEL BÖLÜMÜ (Padding Yok! Tam kenardan kenara ekranı kaplar) ──
                              if (_latestFullReading != null) ...[
                                // 2. 7 kart yorumu — Carousel (Tüm ekran genişliğinde)
                                _buildFullCardCarousel().animate()
                                  .fadeIn(duration: 800.ms, delay: 1200.ms)
                                  .slideY(begin: 0.15, end: 0, duration: 800.ms, delay: 1200.ms, curve: Curves.easeOut),

                                const SizedBox(height: 20),
                              ],

                              // ── ALT KISIM (Carousel sonrası paneller tekrar Padding içinde) ──
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    if (_latestFullReading != null) ...[
                                      // 3. Kart İlişkileri
                                      _buildCardRelationsPanel(
                                        _latestFullReading!.cardRelations,
                                      ).animate()
                                        .fadeIn(duration: 800.ms, delay: 2200.ms)
                                        .slideY(begin: 0.15, end: 0, duration: 800.ms, delay: 2200.ms, curve: Curves.easeOut),
                                      const SizedBox(height: 16),

                                      // 4. Element Analizi
                                      _buildElementAnalysisPanel(
                                        _latestFullReading!.elementAnalysis,
                                      ).animate()
                                        .fadeIn(duration: 800.ms, delay: 2800.ms)
                                        .slideX(begin: -0.1, end: 0, duration: 800.ms, delay: 2800.ms, curve: Curves.easeOut),
                                      const SizedBox(height: 16),

                                      // 5. Tavsiye + Gizli Mesaj (birleşik panel)
                                      _buildInsightPanel(
                                        _latestFullReading!.adviceParagraph,
                                        _isTr ? _latestFullReading!.secretMessageTr : _latestFullReading!.secretMessageEn,
                                      ).animate()
                                        .fadeIn(duration: 800.ms, delay: 3400.ms)
                                        .slideY(begin: 0.15, end: 0, duration: 800.ms, delay: 3400.ms, curve: Curves.easeOut),
                                      const SizedBox(height: 24),
                                    ],

                                    // Kartların vaat ettiği anahtar kelimeler
                                    _buildPromisesPanel().animate()
                                      .fadeIn(duration: 800.ms, delay: _latestFullReading != null ? 4000.ms : 3300.ms)
                                      .slideY(begin: 0.2, end: 0, duration: 800.ms, delay: _latestFullReading != null ? 4000.ms : 3300.ms, curve: Curves.easeOut),
                                    const SizedBox(height: 24),
                                    
                                    // PAYLAŞ BUTONU
                                    Center(
                                      child: _TapAnimButton(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          final promises = _latestReading?.promises ?? _latestFullReading?.promises ?? [];
                                          final cardNames = _selectedCardIndexes.map((i) => _cardName(i)).toList();
                                          final cardAssets = _selectedCardIndexes.map((i) => _allCards[i].frontAsset).toList();
                                          
                                          // Sosyal medya paylaşımı için tek güçlü mesaj
                                          String readingText = _latestReading?.closingMessage 
                                              ?? _latestFullReading?.closingMessage 
                                              ?? '';
                                          
                                          Navigator.of(context).push(
                                            PageRouteBuilder(
                                              opaque: false,
                                              barrierDismissible: false,
                                              pageBuilder: (context, _, __) => TarotShareModal(
                                                closingMessage: readingText,
                                                promises: promises,
                                                cardNames: cardNames,
                                                cardAssets: cardAssets,
                                                isMajorArcana: _isBuyukArkana,
                                                lang: _isTr ? 'tr' : 'en',
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(100),
                                            color: Colors.white.withOpacity(0.06),
                                            border: Border.all(
                                              color: const Color(0xFFE7D6A5).withOpacity(0.3),
                                              width: 0.8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.ios_share_rounded, color: const Color(0xFFE7D6A5).withOpacity(0.6), size: 16),
                                              const SizedBox(width: 8),
                                              Text(
                                                _isTr ? 'Paylaş' : 'Share',
                                                style: GoogleFonts.cinzel(
                                                  color: const Color(0xFFE7D6A5).withOpacity(0.6),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 1.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ).animate()
                                      .fadeIn(duration: 800.ms, delay: _latestFullReading != null ? 4200.ms : 3600.ms)
                                      .slideY(begin: 0.15, end: 0, duration: 800.ms, delay: _latestFullReading != null ? 4200.ms : 3600.ms, curve: Curves.easeOut),
                                    const SizedBox(height: 32),
                                    // Kartların Gizli Fısıltısı
                                    _buildDailyAdviceCard(
                                      _isTr ? 'Kartların Gizli Fısıltısı' : 'Secret Whisper of the Cards',
                                      _latestReading?.closingMessage ?? _latestFullReading!.closingMessage,
                                    ).animate()
                                      .fadeIn(duration: 1000.ms, delay: 4500.ms)
                                      .slideY(begin: 0.15, end: 0, duration: 1000.ms, delay: 4500.ms, curve: Curves.easeOut),
                                    const SizedBox(height: 32),

                                    // Magic Buton - Yeni Çekim Yap (en sonda)
                                    Center(
                                      child: _buildMagicButton(
                                        _isTr ? 'Yeni Çekim Yap' : 'Draw Again',
                                        () {
                                          HapticFeedback.lightImpact();
                                          _setStateSafe(() {
                                            _state = RitualState.idle;
                                            _latestReading = null;
                                            _latestFullReading = null;
                                            _selectedCardIndexes.clear();
                                            _selectedTablePositions.clear();
                                            _revealedCount = 0;
                                          });
                                        },
                                      ),
                                    ).animate()
                                      .fadeIn(duration: 800.ms, delay: 5000.ms)
                                      .slideY(begin: 0.15, end: 0, duration: 800.ms, delay: 5000.ms, curve: Curves.easeOut),
                                    const SizedBox(height: 60), // En alt boşluk
                                  ],
                                ),
                              ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                },
              ),
            ),


          // Yorum ekranında sabit geri butonu — scroll yapınca da erişilebilir
          if (_state == RitualState.revealed)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 20,
              child: GlassBackButton(
                onTap: _resetToIdle,
              ),
            ),


        ],
      );  // Stack
        },  // builder
      ),  // AnimatedBuilder
    ),  // Scaffold
    );  // PopScope
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
    return RepaintBoundary(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: animation,
          builder: (_, __) {
            return CustomPaint(
              painter: _StarsPainter(t: animation.value),
              size: Size.infinite,
              isComplex: true,
              willChange: true,
            );
          },
        ),
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
    for (int i = 0; i < 800; i++) {
      final phase = (i % 97) * 0.18;
      final driftX = sin(t * 2 * pi + phase) * 1.5;
      final driftY = cos(t * 2 * pi + phase) * 1.5;
      final x = random.nextDouble() * size.width + driftX;
      final y = random.nextDouble() * size.height + driftY;
      final radius = random.nextDouble() * 0.25 + 0.08;
      final opacity = random.nextDouble() * 0.06 + 0.01;
      final twinkle = 0.4 + 0.6 * sin((i % 37) * 0.4 + t * 2 * pi * 2.5);
      starPaint.color = Colors.white.withOpacity(opacity * twinkle);
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }

    // Medium stars – clearly visible, with soft glow
    for (int i = 0; i < 200; i++) {
      final phase = (i % 67) * 0.22;
      final driftX = sin(t * 2 * pi + phase) * 2.5;
      final driftY = cos(t * 2 * pi + phase) * 2.5;
      final x = random.nextDouble() * size.width + driftX;
      final y = random.nextDouble() * size.height + driftY;
      final radius = random.nextDouble() * 0.7 + 0.25;
      final opacity = random.nextDouble() * 0.18 + 0.06;
      final twinkle = 0.3 + 0.7 * sin((i % 29) * 0.6 + t * 2 * pi * 2.0);
      final glowRadius = radius * 2.5;
      final glowOpacity = opacity * 0.3 * twinkle;

      glowPaint.color = Colors.white.withOpacity(glowOpacity);
      canvas.drawCircle(Offset(x, y), glowRadius, glowPaint);

      starPaint.color = Colors.white.withOpacity(opacity * twinkle);
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }

    // Bright highlight stars – few but eye-catching
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.2 + 0.6;
      final twinkle = 0.2 + 0.8 * sin((i % 11) * 1.2 + t * 2 * pi * 1.5);
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
  final Widget Function(int index, int totalCards) cardBuilder;
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
  // Store custom oriented rects for precise hit-testing
  final Map<int, ({Offset center, Size size, double angle})> _cardHitboxes = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24), // 14s → 24s (performans)
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
    final double inflation = 0.0; // Enflasyonu sıfırladık, böylece Majör Arkana'da da yandaki karta taşmıyor
    
    // Reverse iterate so top-drawn cards get priority
    for (int i = totalCards - 1; i >= 0; i--) {
      final hb = _cardHitboxes[i];
      if (hb == null) continue;
      if (widget.selectedPositions.contains(i) || widget.hiddenCards.contains(i)) continue;
      
      // Mathematical rotation check for Oriented Bounding Box (AABB vs OBB collision logic)
      final dx = localPos.dx - hb.center.dx;
      final dy = localPos.dy - hb.center.dy;
      
      // Inverse rotation to bring localPos into the card's unrotated local coordinate space
      final cosA = cos(-hb.angle);
      final sinA = sin(-hb.angle);
      final rx = dx * cosA - dy * sinA;
      final ry = dx * sinA + dy * cosA;
      
      final hw = (hb.size.width / 2) + inflation;
      final hh = (hb.size.height / 2) + inflation;
      
      if (rx >= -hw && rx <= hw && ry >= -hh && ry <= hh) {
        return i;
      }
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
              _cardHitboxes.clear();
              _btnCenter = Offset(centerX, centerY);

              // Dynamic layers based on card count
              final int layerCount = isSmall ? 3 : 2;
              final cardsPerLayer = <int>[];
              if (isSmall) {
                // 78 cards: outer=34, mid=26, inner=18 (less crowded inside)
                cardsPerLayer.addAll([34, 26, 18]);
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
                
                // Store precise oriented bounds for hit-testing
                _cardHitboxes[cardIdx] = (
                  center: Offset(x + cardW / 2, y + cardH / 2),
                  size: Size(cardW * scale, cardH * scale),
                  angle: rotation,
                );
                
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
                            child: widget.cardBuilder(cardIdx, totalCards),
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
                  final floatY = isSmall ? 0.0 : sin(_controller.value * 2 * pi + cardIdx * 0.5) * 4.0
                      + (isSmall ? 0.0 : sin(_controller.value * 2 * pi * 2 + cardIdx * 0.8) * 2.0);
                  final floatX = isSmall ? 0.0 : cos(_controller.value * 2 * pi + cardIdx * 0.6) * 2.5;
                  
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
                              gradient: SweepGradient(
                                center: Alignment.center,
                                colors: [
                                  Color.fromRGBO(160, 100, 255, 0.25),
                                  Color.fromRGBO(80, 200, 200, 0.20),
                                  Color.fromRGBO(226, 196, 142, 0.22),
                                  Color.fromRGBO(160, 100, 255, 0.25),
                                ],
                                stops: const [0.0, 0.33, 0.66, 1.0],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(160, 100, 255, 0.18),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: Color.fromRGBO(80, 200, 200, 0.12),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                              ],
                              border: Border.all(
                                color: const Color(0xFFD4B896).withOpacity(0.30),
                                width: 1.0,
                              ),
                            ),
                            child: ClipOval(
                              child: Stack(
                              alignment: Alignment.center,
                              children: [
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
                                SizedBox.expand(
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'RASTGELE\nÇEK',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.inter(
                                            color: Colors.white.withOpacity(0.70),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 2.5,
                                            height: 1.4,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Icon(
                                          Icons.shuffle_rounded,
                                          color: Colors.white.withOpacity(0.45),
                                          size: 14,
                                        ),
                                      ],
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

      for (double x = 0; x <= size.width; x += 6) {
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

    // 400 drifting tiny stars (performans için azaltıldı)
    for (int i = 0; i < 400; i++) {
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

    // 150 twinkling + drifting stars (performans için azaltıldı)
    for (int i = 0; i < 150; i++) {
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
    for (int i = 0; i < 600; i++) {
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
                style: GoogleFonts.cinzel(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
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
  final Color color;
  _CardStarPainter({this.color = const Color(0x4DFFFFFF)});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final goldColor = color.withOpacity(0.40);
    
    final paint = Paint()
      ..color = goldColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    
    // Outer circle
    canvas.drawCircle(Offset(cx, cy), size.width * 0.45, paint);
    
    // Inner circle with glow
    canvas.drawCircle(Offset(cx, cy), size.width * 0.18, 
      Paint()..color = goldColor.withOpacity(0.25)..style = PaintingStyle.fill);
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
  bool shouldRepaint(covariant _CardStarPainter oldDelegate) => oldDelegate.color != color;
}


// ============================================================
// Corner Flourish Painter - Decorative corner ornaments
// ============================================================
class _CornerFlourishPainter extends CustomPainter {
  final bool isTopLeft;
  _CornerFlourishPainter({required this.isTopLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE7D6A5).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final path = Path();

    if (isTopLeft) {
      // Sol üst köşe: dikey çizgi + kıvrım
      path.moveTo(0, size.height * 0.8);
      path.lineTo(0, size.height * 0.2);
      path.quadraticBezierTo(0, 0, size.width * 0.2, 0);
      path.lineTo(size.width * 0.8, 0);
      // Küçük dekoratif nokta
      canvas.drawCircle(Offset(size.width * 0.85, 0), 1.5, paint..style = PaintingStyle.fill);
      paint.style = PaintingStyle.stroke;
    } else {
      // Sağ alt köşe: dikey çizgi + kıvrım
      path.moveTo(size.width, size.height * 0.2);
      path.lineTo(size.width, size.height * 0.8);
      path.quadraticBezierTo(size.width, size.height, size.width * 0.8, size.height);
      path.lineTo(size.width * 0.2, size.height);
      // Küçük dekoratif nokta
      canvas.drawCircle(Offset(size.width * 0.15, size.height), 1.5, paint..style = PaintingStyle.fill);
      paint.style = PaintingStyle.stroke;
    }

    canvas.drawPath(path, paint);
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

// ============================================================
// Ad Watch Button - Simulated Rewarded Ad
// ============================================================
class _AdWatchButton extends StatefulWidget {
  final String label;
  final VoidCallback onComplete;
  const _AdWatchButton({required this.label, required this.onComplete});

  @override
  State<_AdWatchButton> createState() => _AdWatchButtonState();
}

class _AdWatchButtonState extends State<_AdWatchButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  bool _watching = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.mediumImpact();
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _startWatching() {
    if (_watching) return;
    HapticFeedback.lightImpact();
    setState(() => _watching = true);
    _ctrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _startWatching,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFE2C48E).withOpacity(0.25),
                  const Color(0xFFD4A853).withOpacity(0.15),
                ],
              ),
              border: Border.all(
                color: const Color(0xFFE2C48E).withOpacity(0.4),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                children: [
                  // Progress fill
                  if (_watching)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: (MediaQuery.of(context).size.width * 0.7) * _ctrl.value,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFE2C48E).withOpacity(0.3),
                              const Color(0xFFD4A853).withOpacity(0.15),
                            ],
                          ),
                        ),
                      ),
                    ),
                  // Label
                  Center(
                    child: Text(
                      _watching ? '⏳ ${(2 - _ctrl.value * 2).toStringAsFixed(0)}s...' : widget.label,
                      style: TextStyle(
                        color: const Color(0xFFE2C48E).withOpacity(0.9),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BottomSwooshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE7D6A5).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.25, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.5, size.height * 1.5, size.width * 0.75, size.height * 0.1);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================
// Tap Scale Button — Reusable press effect widget
// ============================================================
class _TapScaleButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  const _TapScaleButton({required this.onTap, required this.child});

  @override
  State<_TapScaleButton> createState() => _TapScaleButtonState();
}

class _TapScaleButtonState extends State<_TapScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _ctrl.forward();
      },
      onTapUp: (_) async {
        await Future.delayed(const Duration(milliseconds: 60));
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) {
          final scale = 1.0 - (_ctrl.value * 0.15);
          return Transform.scale(scale: scale, child: child);
        },
        child: widget.child,
      ),
    );
  }
}

/// Özel element sembolü painter'ı
class _ElementSymbolPainter extends CustomPainter {
  final String element;
  final Color color;
  final double glowAlpha;
  final bool isDominant;

  _ElementSymbolPainter({
    required this.element,
    required this.color,
    required this.glowAlpha,
    required this.isDominant,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = isDominant ? 2.0 : 1.5
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = color.withValues(alpha: glowAlpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isDominant ? 3.0 : 2.0;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: isDominant ? 0.2 : 0.1)
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.4;

    switch (element) {
      case 'fire':
        final path = Path();
        path.moveTo(cx, cy - r * 1.1);
        path.cubicTo(cx + r * 0.3, cy - r * 0.4, cx + r * 0.9, cy + r * 0.2, cx + r * 0.5, cy + r * 0.9);
        path.quadraticBezierTo(cx, cy + r * 0.4, cx, cy + r * 0.1);
        path.quadraticBezierTo(cx, cy + r * 0.4, cx - r * 0.5, cy + r * 0.9);
        path.cubicTo(cx - r * 0.9, cy + r * 0.2, cx - r * 0.3, cy - r * 0.4, cx, cy - r * 1.1);
        canvas.drawPath(path, glowPaint);
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, paint);
        canvas.drawCircle(Offset(cx, cy + r * 0.2), isDominant ? 2.0 : 1.5,
          Paint()..color = color.withValues(alpha: 0.6)..style = PaintingStyle.fill);
        break;

      case 'water':
        final dropPath = Path();
        dropPath.moveTo(cx, cy - r * 0.9);
        dropPath.quadraticBezierTo(cx + r * 0.5, cy - r * 0.1, cx, cy + r * 0.2);
        dropPath.quadraticBezierTo(cx - r * 0.5, cy - r * 0.1, cx, cy - r * 0.9);
        canvas.drawPath(dropPath, glowPaint);
        canvas.drawPath(dropPath, fillPaint);
        canvas.drawPath(dropPath, paint);
        for (var i = 0; i < 2; i++) {
          final waveY = cy + r * 0.5 + i * r * 0.4;
          final wavePath = Path();
          wavePath.moveTo(cx - r * 0.8, waveY);
          wavePath.quadraticBezierTo(cx - r * 0.3, waveY - r * 0.25, cx, waveY);
          wavePath.quadraticBezierTo(cx + r * 0.3, waveY + r * 0.25, cx + r * 0.8, waveY);
          canvas.drawPath(wavePath, Paint()
            ..color = color.withValues(alpha: i == 0 ? 0.7 : 0.4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = isDominant ? 1.5 : 1.0
            ..strokeCap = StrokeCap.round);
        }
        break;

      case 'air':
        for (var i = 0; i < 3; i++) {
          final yOff = (i - 1) * r * 0.55;
          final alpha = i == 1 ? 0.8 : 0.45;
          final windPath = Path();
          windPath.moveTo(cx - r * 0.9, cy + yOff);
          windPath.cubicTo(
            cx - r * 0.3, cy + yOff - r * 0.3,
            cx + r * 0.3, cy + yOff + r * 0.3,
            cx + r * 0.7, cy + yOff - r * 0.15,
          );
          windPath.quadraticBezierTo(
            cx + r * 1.0, cy + yOff - r * 0.35,
            cx + r * 0.8, cy + yOff - r * 0.45,
          );
          canvas.drawPath(windPath, Paint()
            ..color = color.withValues(alpha: alpha)
            ..style = PaintingStyle.stroke
            ..strokeWidth = isDominant ? 1.8 : 1.2
            ..strokeCap = StrokeCap.round);
          if (isDominant && i == 1) {
            canvas.drawPath(windPath, Paint()
              ..color = color.withValues(alpha: 0.25)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.0);
          }
        }
        break;

      case 'earth':
        final path = Path();
        path.moveTo(cx, cy - r);
        path.lineTo(cx + r * 0.85, cy);
        path.lineTo(cx, cy + r);
        path.lineTo(cx - r * 0.85, cy);
        path.close();
        canvas.drawPath(path, glowPaint);
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, paint);
        final innerPaint = Paint()
          ..color = color.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8;
        canvas.drawLine(Offset(cx, cy - r), Offset(cx, cy + r), innerPaint);
        canvas.drawLine(Offset(cx - r * 0.85, cy), Offset(cx + r * 0.85, cy), innerPaint);
        canvas.drawCircle(Offset(cx, cy), isDominant ? 2.0 : 1.5,
          Paint()..color = color.withValues(alpha: 0.5)..style = PaintingStyle.fill);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _ElementSymbolPainter old) =>
      element != old.element || color != old.color || isDominant != old.isDominant;
}

/// Kart İlişkileri başlık sembolü — iki kesişen daire + merkez parıltı
class _ConnectionSymbolPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const color = Color(0xFFB08DD4);

    canvas.drawCircle(Offset(cx - 5, cy), 5,
      Paint()..color = color.withValues(alpha: 0.15)..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(cx - 5, cy), 5,
      Paint()..color = color.withValues(alpha: 0.6)..style = PaintingStyle.stroke..strokeWidth = 1.2);

    canvas.drawCircle(Offset(cx + 5, cy), 5,
      Paint()..color = color.withValues(alpha: 0.15)..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(cx + 5, cy), 5,
      Paint()..color = color.withValues(alpha: 0.6)..style = PaintingStyle.stroke..strokeWidth = 1.2);

    canvas.drawCircle(Offset(cx, cy), 2,
      Paint()..color = color.withValues(alpha: 0.7)..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(cx, cy), 2,
      Paint()..color = color.withValues(alpha: 0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// İki kartın suit'ine göre çift sembol çizen painter
class _CardPairSymbolPainter extends CustomPainter {
  final String suit1;
  final String suit2;
  final String card1Name;
  final String card2Name;

  _CardPairSymbolPainter({required this.suit1, required this.suit2, required this.card1Name, required this.card2Name});

  static const _suitColors = {
    'wands': Color(0xFFFF8A50),
    'cups': Color(0xFF64B5F6),
    'swords': Color(0xFF90A4AE),
    'pentacles': Color(0xFFFFD54F),
    'major': Color(0xFFCE93D8),
  };

  @override
  void paint(Canvas canvas, Size size) {
    final color1 = _suitColors[suit1] ?? const Color(0xFFCE93D8);
    final color2 = _suitColors[suit2] ?? const Color(0xFFCE93D8);
    final blended = Color.lerp(color1, color2, 0.5)!;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.38;

    final shape = (card1Name.hashCode ^ card2Name.hashCode).abs() % 8;

    final stroke = Paint()
      ..color = blended
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final fill = Paint()
      ..color = blended.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final glow = Paint()
      ..color = blended.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
      ..style = PaintingStyle.fill;

    switch (shape) {
      case 0: // İç içe hilaller
        final left = Path()
          ..addArc(Rect.fromCircle(center: Offset(cx - 1.5, cy), radius: r), pi * 0.6, pi * 1.8);
        final right = Path()
          ..addArc(Rect.fromCircle(center: Offset(cx + 1.5, cy), radius: r), -pi * 0.4, pi * 1.8);
        canvas.drawPath(left, stroke..color = color1.withValues(alpha: 0.7));
        canvas.drawPath(right, stroke..color = color2.withValues(alpha: 0.7));
        canvas.drawCircle(Offset(cx, cy), 2, Paint()..color = blended.withValues(alpha: 0.6)..style = PaintingStyle.fill);
        canvas.drawCircle(Offset(cx, cy), 4, glow);
        break;

      case 1: // Daire + iç üçgen
        canvas.drawCircle(Offset(cx, cy), r, fill);
        canvas.drawCircle(Offset(cx, cy), r, stroke..color = blended);
        final tri = Path()
          ..moveTo(cx, cy - r * 0.7)
          ..lineTo(cx + r * 0.65, cy + r * 0.45)
          ..lineTo(cx - r * 0.65, cy + r * 0.45)
          ..close();
        canvas.drawPath(tri, stroke..color = blended.withValues(alpha: 0.6));
        canvas.drawCircle(Offset(cx, cy), 2, Paint()..color = blended.withValues(alpha: 0.5)..style = PaintingStyle.fill);
        canvas.drawCircle(Offset(cx, cy), 4, glow);
        break;

      case 2: // Spiral çember
        final spiral = Path();
        for (var t = 0.0; t < pi * 3; t += 0.15) {
          final sr = r * 0.2 + (t / (pi * 3)) * r * 0.75;
          final x = cx + sr * cos(t - pi / 2);
          final y = cy + sr * sin(t - pi / 2);
          if (t == 0) spiral.moveTo(x, y); else spiral.lineTo(x, y);
        }
        canvas.drawPath(spiral, stroke..color = blended.withValues(alpha: 0.7));
        canvas.drawCircle(Offset(cx, cy), 2, Paint()..color = blended.withValues(alpha: 0.5)..style = PaintingStyle.fill);
        canvas.drawCircle(Offset(cx, cy), 4, glow);
        break;

      case 3: // Elmas + yatay göz
        final diamond = Path()
          ..moveTo(cx, cy - r)..lineTo(cx + r * 0.6, cy)
          ..lineTo(cx, cy + r)..lineTo(cx - r * 0.6, cy)..close();
        canvas.drawPath(diamond, fill);
        canvas.drawPath(diamond, stroke..color = blended);
        // Yatay göz çizgisi
        canvas.drawLine(Offset(cx - r * 0.6, cy), Offset(cx + r * 0.6, cy),
          Paint()..color = blended.withValues(alpha: 0.35)..strokeWidth = 0.8);
        canvas.drawCircle(Offset(cx, cy), 2, Paint()..color = blended.withValues(alpha: 0.6)..style = PaintingStyle.fill);
        canvas.drawCircle(Offset(cx, cy), 4, glow);
        break;

      case 4: // Çiçek — 6 yaprak
        for (var i = 0; i < 6; i++) {
          final angle = i * pi / 3;
          final petal = Path();
          petal.moveTo(cx, cy);
          petal.quadraticBezierTo(
            cx + r * 0.5 * cos(angle - 0.4), cy + r * 0.5 * sin(angle - 0.4),
            cx + r * 0.8 * cos(angle), cy + r * 0.8 * sin(angle));
          petal.quadraticBezierTo(
            cx + r * 0.5 * cos(angle + 0.4), cy + r * 0.5 * sin(angle + 0.4),
            cx, cy);
          canvas.drawPath(petal, stroke..color = blended.withValues(alpha: 0.5 + (i % 2) * 0.2));
        }
        canvas.drawCircle(Offset(cx, cy), 2.5, Paint()..color = blended.withValues(alpha: 0.5)..style = PaintingStyle.fill);
        canvas.drawCircle(Offset(cx, cy), 4, glow);
        break;

      case 5: // Rün haçı — dört kol + köşe noktaları
        canvas.drawLine(Offset(cx, cy - r), Offset(cx, cy + r), stroke..color = blended.withValues(alpha: 0.7));
        canvas.drawLine(Offset(cx - r, cy), Offset(cx + r, cy), stroke..color = blended.withValues(alpha: 0.7));
        // Çapraz kısa çizgiler
        final short = r * 0.5;
        canvas.drawLine(Offset(cx - short, cy - short), Offset(cx + short, cy + short),
          Paint()..color = blended.withValues(alpha: 0.35)..strokeWidth = 0.8..strokeCap = StrokeCap.round);
        canvas.drawLine(Offset(cx + short, cy - short), Offset(cx - short, cy + short),
          Paint()..color = blended.withValues(alpha: 0.35)..strokeWidth = 0.8..strokeCap = StrokeCap.round);
        // Uç noktaları
        for (final off in [Offset(cx, cy - r), Offset(cx, cy + r), Offset(cx - r, cy), Offset(cx + r, cy)]) {
          canvas.drawCircle(off, 1.5, Paint()..color = blended.withValues(alpha: 0.5)..style = PaintingStyle.fill);
        }
        canvas.drawCircle(Offset(cx, cy), 2, Paint()..color = blended.withValues(alpha: 0.6)..style = PaintingStyle.fill);
        canvas.drawCircle(Offset(cx, cy), 4, glow);
        break;

      case 6: // Altıgen yıldız (hexagram)
        final triUp = Path()
          ..moveTo(cx, cy - r)
          ..lineTo(cx + r * 0.87, cy + r * 0.5)
          ..lineTo(cx - r * 0.87, cy + r * 0.5)..close();
        final triDown = Path()
          ..moveTo(cx, cy + r)
          ..lineTo(cx + r * 0.87, cy - r * 0.5)
          ..lineTo(cx - r * 0.87, cy - r * 0.5)..close();
        canvas.drawPath(triUp, stroke..color = color1.withValues(alpha: 0.6));
        canvas.drawPath(triDown, stroke..color = color2.withValues(alpha: 0.6));
        canvas.drawCircle(Offset(cx, cy), 2, Paint()..color = blended.withValues(alpha: 0.6)..style = PaintingStyle.fill);
        canvas.drawCircle(Offset(cx, cy), 4, glow);
        break;

      case 7: // Ankh — üst halka + dikey çizgi + yatay kol
        final ovalR = r * 0.5;
        canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - r * 0.35), width: ovalR * 2, height: ovalR * 1.6), fill);
        canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - r * 0.35), width: ovalR * 2, height: ovalR * 1.6), stroke..color = blended);
        canvas.drawLine(Offset(cx, cy - r * 0.35 + ovalR * 0.8), Offset(cx, cy + r), stroke..color = blended.withValues(alpha: 0.7));
        canvas.drawLine(Offset(cx - r * 0.55, cy + r * 0.15), Offset(cx + r * 0.55, cy + r * 0.15), stroke..color = blended.withValues(alpha: 0.6));
        canvas.drawCircle(Offset(cx, cy - r * 0.35), 1.5, Paint()..color = blended.withValues(alpha: 0.5)..style = PaintingStyle.fill);
        canvas.drawCircle(Offset(cx, cy), 4, glow);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _CardPairSymbolPainter old) =>
      suit1 != old.suit1 || suit2 != old.suit2 || card1Name != old.card1Name || card2Name != old.card2Name;
}

/// Dairesel arc gauge painter
class _ArcGaugePainter extends CustomPainter {
  final double score;
  final Color color;

  _ArcGaugePainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.65;
    final radius = size.width * 0.42;
    const startAngle = pi * 0.8;
    const sweepTotal = pi * 1.4;

    // Arka plan track
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      startAngle, sweepTotal, false,
      Paint()
        ..color = color.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    // Tick işaretleri
    for (var i = 0; i <= 10; i++) {
      final angle = startAngle + (i / 10) * sweepTotal;
      final isMajor = i % 5 == 0;
      final innerR = radius - (isMajor ? 7 : 4);
      final outerR = radius + (isMajor ? 2 : 1);
      canvas.drawLine(
        Offset(cx + innerR * cos(angle), cy + innerR * sin(angle)),
        Offset(cx + outerR * cos(angle), cy + outerR * sin(angle)),
        Paint()
          ..color = color.withValues(alpha: isMajor ? 0.35 : 0.15)
          ..strokeWidth = isMajor ? 1.2 : 0.8
          ..strokeCap = StrokeCap.round,
      );
    }

    // Aktif arc
    final sweepActive = sweepTotal * score;
    if (sweepActive > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        startAngle, sweepActive, false,
        Paint()
          ..color = color.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        startAngle, sweepActive, false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );

      final endAngle = startAngle + sweepActive;
      final mx = cx + radius * cos(endAngle);
      final my = cy + radius * sin(endAngle);
      canvas.drawCircle(Offset(mx, my), 3,
        Paint()..color = color.withValues(alpha: 0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
      canvas.drawCircle(Offset(mx, my), 2.5,
        Paint()..color = color..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(covariant _ArcGaugePainter old) => score != old.score;
}

/// Orbital atom modeli painter
class _OrbitalAtomPainter extends CustomPainter {
  final double score;
  final Color color;

  _OrbitalAtomPainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Çekirdek glow
    canvas.drawCircle(Offset(cx, cy), 10,
      Paint()
        ..color = color.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
        ..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(cx, cy), 5,
      Paint()
        ..color = color.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
        ..style = PaintingStyle.fill);

    // 3 yörünge
    final orbits = [
      [38.0, 14.0, -0.35],
      [32.0, 16.0, 0.7],
      [36.0, 12.0, 1.6],
    ];

    final activeElectrons = (score * 6).round().clamp(0, 6);
    var electronIdx = 0;

    for (var o = 0; o < orbits.length; o++) {
      final rx = orbits[o][0];
      final ry = orbits[o][1];
      final tilt = orbits[o][2];

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(tilt);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2),
        Paint()
          ..color = color.withValues(alpha: 0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
      canvas.restore();

      for (var e = 0; e < 2; e++) {
        final eAngle = (e * pi) + (o * 1.2);
        final ex = rx * cos(eAngle);
        final ey = ry * sin(eAngle);
        final rotX = ex * cos(tilt) - ey * sin(tilt);
        final rotY = ex * sin(tilt) + ey * cos(tilt);
        final isActive = electronIdx < activeElectrons;
        final dotX = cx + rotX;
        final dotY = cy + rotY;

        if (isActive) {
          canvas.drawCircle(Offset(dotX, dotY), 4,
            Paint()..color = color.withValues(alpha: 0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)..style = PaintingStyle.fill);
          canvas.drawCircle(Offset(dotX, dotY), 2.5,
            Paint()..color = color..style = PaintingStyle.fill);
          canvas.drawCircle(Offset(dotX, dotY), 1,
            Paint()..color = Colors.white.withValues(alpha: 0.6)..style = PaintingStyle.fill);
        } else {
          canvas.drawCircle(Offset(dotX, dotY), 2,
            Paint()..color = color.withValues(alpha: 0.15)..style = PaintingStyle.fill);
          canvas.drawCircle(Offset(dotX, dotY), 2,
            Paint()..color = color.withValues(alpha: 0.2)..style = PaintingStyle.stroke..strokeWidth = 0.5);
        }
        electronIdx++;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitalAtomPainter old) => score != old.score;
}

/// Ay fazı painter — fillAmount: 0=yeni ay, 1=dolunay
class _MoonPhasePainter extends CustomPainter {
  final double fillAmount;
  final Color color;

  _MoonPhasePainter({required this.fillAmount, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.42;

    // Arka plan: soluk boş ay
    canvas.drawCircle(Offset(cx, cy), r,
      Paint()..color = color.withValues(alpha: 0.08)..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(cx, cy), r,
      Paint()..color = color.withValues(alpha: 0.2)..style = PaintingStyle.stroke..strokeWidth = 0.8);

    if (fillAmount <= 0) return;

    if (fillAmount >= 1.0) {
      // Dolunay
      canvas.drawCircle(Offset(cx, cy), r,
        Paint()..color = color.withValues(alpha: 0.25)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(cx, cy), r,
        Paint()..color = color.withValues(alpha: 0.85)..style = PaintingStyle.fill);
    } else {
      // Kısmi dolum
      final t = fillAmount * 2 - 1; // -1..1
      final path = Path();
      // Terminatör eğrisi
      path.moveTo(cx, cy - r);
      for (var a = -pi / 2; a <= pi / 2; a += 0.05) {
        path.lineTo(cx + r * t * sin(a), cy - r * cos(a));
      }
      // Sağ yarım daire
      for (var a = pi / 2; a >= -pi / 2; a -= 0.05) {
        path.lineTo(cx + r * sin(a), cy - r * cos(a));
      }
      path.close();

      canvas.save();
      canvas.clipPath(Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r)));
      canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.7)..style = PaintingStyle.fill);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _MoonPhasePainter old) => fillAmount != old.fillAmount;
}

/// Mistik göz painter — openness: 0=kapalı, 1=tamamen açık
class _MysticalEyePainter extends CustomPainter {
  final double openness;
  final Color color;

  _MysticalEyePainter({required this.openness, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final w = size.width * 0.45;
    final h = size.height * 0.4 * openness.clamp(0.05, 1.0);

    // Göz dış glow
    if (openness > 0.3) {
      canvas.drawCircle(Offset(cx, cy), w * 0.5,
        Paint()
          ..color = color.withValues(alpha: 0.08 * openness)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 * openness)
          ..style = PaintingStyle.fill);
    }

    // Üst kapak
    final upperLid = Path()
      ..moveTo(cx - w, cy)
      ..quadraticBezierTo(cx, cy - h, cx + w, cy);

    // Alt kapak
    final lowerLid = Path()
      ..moveTo(cx - w, cy)
      ..quadraticBezierTo(cx, cy + h, cx + w, cy);

    // Göz şekli
    final eyeShape = Path()
      ..addPath(upperLid, Offset.zero)
      ..quadraticBezierTo(cx, cy + h, cx - w, cy)
      ..close();

    canvas.drawPath(eyeShape,
      Paint()..color = color.withValues(alpha: 0.06 + 0.06 * openness)..style = PaintingStyle.fill);
    canvas.drawPath(upperLid,
      Paint()..color = color.withValues(alpha: 0.5 + 0.4 * openness)..style = PaintingStyle.stroke..strokeWidth = 1.2..strokeCap = StrokeCap.round);
    canvas.drawPath(lowerLid,
      Paint()..color = color.withValues(alpha: 0.4 + 0.3 * openness)..style = PaintingStyle.stroke..strokeWidth = 1.0..strokeCap = StrokeCap.round);

    if (openness > 0.15) {
      final irisR = h * 0.65;
      canvas.drawCircle(Offset(cx, cy), irisR,
        Paint()..color = color.withValues(alpha: 0.15 + 0.15 * openness)..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(cx, cy), irisR,
        Paint()..color = color.withValues(alpha: 0.4 + 0.3 * openness)..style = PaintingStyle.stroke..strokeWidth = 0.8);

      if (openness > 0.4) {
        for (var i = 0; i < 8; i++) {
          final angle = i * pi / 4;
          final innerR = irisR * 0.3;
          canvas.drawLine(
            Offset(cx + innerR * cos(angle), cy + innerR * sin(angle)),
            Offset(cx + irisR * 0.9 * cos(angle), cy + irisR * 0.9 * sin(angle)),
            Paint()..color = color.withValues(alpha: 0.15 * openness)..strokeWidth = 0.4,
          );
        }
      }

      final pupilR = irisR * (0.35 + 0.15 * (1 - openness));
      canvas.drawCircle(Offset(cx, cy), pupilR,
        Paint()..color = color.withValues(alpha: 0.7 + 0.3 * openness)..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(cx - pupilR * 0.4, cy - pupilR * 0.4), pupilR * 0.3,
        Paint()..color = Colors.white.withValues(alpha: 0.5 * openness)..style = PaintingStyle.fill);
    }

    if (openness > 0.6) {
      final rayAlpha = (openness - 0.6) * 0.5;
      for (var i = 0; i < 6; i++) {
        final angle = i * pi / 3 + pi / 6;
        final startR = w * 0.85;
        final endR = w * (0.95 + openness * 0.15);
        canvas.drawLine(
          Offset(cx + startR * cos(angle), cy + startR * sin(angle) * 0.5),
          Offset(cx + endR * cos(angle), cy + endR * sin(angle) * 0.5),
          Paint()..color = color.withValues(alpha: rayAlpha)..strokeWidth = 0.8..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MysticalEyePainter old) => openness != old.openness;
}

/// Takımyıldız haritası painter
class _ConstellationPainter extends CustomPainter {
  final double score;
  final Color color;

  _ConstellationPainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 7 yıldız
    final stars = [
      Offset(w * 0.12, h * 0.25),
      Offset(w * 0.30, h * 0.10),
      Offset(w * 0.50, h * 0.30),
      Offset(w * 0.45, h * 0.65),
      Offset(w * 0.70, h * 0.15),
      Offset(w * 0.82, h * 0.50),
      Offset(w * 0.65, h * 0.80),
    ];

    final connections = [
      [0, 1], [1, 2], [2, 3], [2, 4],
      [4, 5], [5, 6], [3, 6],
      [1, 4], [0, 3], [5, 2],
    ];

    final activeConnections = (score * connections.length).round().clamp(0, connections.length);
    final activeStars = <int>{};
    for (var i = 0; i < activeConnections; i++) {
      activeStars.add(connections[i][0]);
      activeStars.add(connections[i][1]);
    }

    for (var i = 0; i < activeConnections; i++) {
      final from = stars[connections[i][0]];
      final to = stars[connections[i][1]];
      canvas.drawLine(from, to,
        Paint()..color = color.withValues(alpha: 0.12)..strokeWidth = 3..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));
      canvas.drawLine(from, to,
        Paint()..color = color.withValues(alpha: 0.25 + 0.15 * score)..strokeWidth = 0.8..strokeCap = StrokeCap.round);
    }

    for (var i = 0; i < stars.length; i++) {
      final isActive = activeStars.contains(i);
      final pos = stars[i];
      if (isActive) {
        canvas.drawCircle(pos, 5,
          Paint()..color = color.withValues(alpha: 0.15)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)..style = PaintingStyle.fill);
        canvas.drawCircle(pos, 2.5,
          Paint()..color = color.withValues(alpha: 0.7 + 0.3 * score)..style = PaintingStyle.fill);
        canvas.drawCircle(pos, 1,
          Paint()..color = Colors.white.withValues(alpha: 0.5 * score)..style = PaintingStyle.fill);
        if (score > 0.5) {
          final rayLen = 2.0 + 2.0 * score;
          final rayPaint = Paint()..color = color.withValues(alpha: 0.2 * score)..strokeWidth = 0.4..strokeCap = StrokeCap.round;
          canvas.drawLine(Offset(pos.dx - rayLen, pos.dy), Offset(pos.dx + rayLen, pos.dy), rayPaint);
          canvas.drawLine(Offset(pos.dx, pos.dy - rayLen), Offset(pos.dx, pos.dy + rayLen), rayPaint);
        }
      } else {
        canvas.drawCircle(pos, 1.5,
          Paint()..color = color.withValues(alpha: 0.12)..style = PaintingStyle.fill);
        canvas.drawCircle(pos, 1.5,
          Paint()..color = color.withValues(alpha: 0.15)..style = PaintingStyle.stroke..strokeWidth = 0.5);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConstellationPainter old) => score != old.score;
}

/// İki dalga rezonansı — uyum göstergesi
class _HarmonyWavesPainter extends CustomPainter {
  final double harmony;
  final Color color;

  _HarmonyWavesPainter({required this.harmony, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cy = h / 2;
    final amplitude = h * 0.3;
    final phaseOffset = pi * (1 - harmony);

    final wave1 = Path();
    final wave2 = Path();
    for (var x = 0.0; x <= w; x += 1) {
      final t = x / w;
      final y1 = cy + amplitude * sin(t * pi * 3);
      final y2 = cy + amplitude * sin(t * pi * 3 + phaseOffset);
      if (x == 0) { wave1.moveTo(x, y1); wave2.moveTo(x, y2); }
      else { wave1.lineTo(x, y1); wave2.lineTo(x, y2); }
    }

    if (harmony > 0.7) {
      canvas.drawPath(wave1, Paint()
        ..color = color.withValues(alpha: 0.2 * (harmony - 0.7) / 0.3)
        ..style = PaintingStyle.stroke..strokeWidth = 6..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    }

    canvas.drawPath(wave2, Paint()
      ..color = color.withValues(alpha: 0.3 + 0.3 * harmony)
      ..style = PaintingStyle.stroke..strokeWidth = 1.5..strokeCap = StrokeCap.round);
    canvas.drawPath(wave1, Paint()
      ..color = color.withValues(alpha: 0.4 + 0.4 * harmony)
      ..style = PaintingStyle.stroke..strokeWidth = 1.8..strokeCap = StrokeCap.round);

    if (harmony > 0.85) {
      final sparkAlpha = (harmony - 0.85) / 0.15;
      for (var i = 0; i < 3; i++) {
        final t = 0.17 + i * 0.33;
        final x = w * t;
        final y = cy + amplitude * sin(t * pi * 3);
        canvas.drawCircle(Offset(x, y), 2.5, Paint()..color = color.withValues(alpha: 0.4 * sparkAlpha)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2)..style = PaintingStyle.fill);
        canvas.drawCircle(Offset(x, y), 1.5, Paint()..color = color.withValues(alpha: 0.7 * sparkAlpha)..style = PaintingStyle.fill);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HarmonyWavesPainter old) => harmony != old.harmony;
}

/// Kenetlenen hilaller — uyum ve tamamlanma sembolü
class _HarmonySymbolPainter extends CustomPainter {
  final double harmony;
  final Color color1; // Sol hilal (altın)
  final Color color2; // Sağ hilal (turkuaz)

  _HarmonySymbolPainter({required this.harmony, required this.color1, required this.color2});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxR = size.width * 0.44;

    final separation = maxR * 0.85 * (1 - harmony);
    final r1 = maxR * (0.62 + 0.12 * harmony);
    final r2 = maxR * (0.50 + 0.14 * harmony);
    final c1 = Offset(cx - separation * 0.5, cy);
    final c2 = Offset(cx + separation * 0.5, cy);

    // Harmanlanmış renk (merkez + orbital için)
    final blended = Color.lerp(color1, color2, 0.5)!;

    // Dış orbital halka (harmanlanmış renk)
    final outerR = maxR + 3;
    canvas.drawCircle(Offset(cx, cy), outerR,
      Paint()..color = blended.withValues(alpha: 0.15 + 0.15 * harmony)..style = PaintingStyle.stroke..strokeWidth = 1.0);

    // Eğik orbital
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(0.35);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: outerR * 2.1, height: outerR * 1.35),
      Paint()..color = blended.withValues(alpha: 0.10 + 0.10 * harmony)..style = PaintingStyle.stroke..strokeWidth = 0.7);
    canvas.restore();

    // Merkez glow (harmanlanmış renk)
    if (harmony > 0.4) {
      final gi = (harmony - 0.4) / 0.6;
      canvas.drawCircle(Offset(cx, cy), maxR * 0.5,
        Paint()..color = blended.withValues(alpha: 0.15 * gi)..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 * gi)..style = PaintingStyle.fill);
    }

    // ▶ Sol hilal dolgusu — color1 (altın)
    canvas.save();
    final clipR = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: c2, radius: r2 * (0.82 + 0.18 * (1 - harmony))));
    canvas.clipPath(clipR, doAntiAlias: true);
    canvas.drawCircle(c1, r1,
      Paint()..color = color1.withValues(alpha: 0.25 + 0.25 * harmony)..style = PaintingStyle.fill);
    canvas.restore();
    canvas.drawCircle(c1, r1,
      Paint()..color = color1.withValues(alpha: 0.55 + 0.35 * harmony)..style = PaintingStyle.stroke..strokeWidth = 1.5 + 0.8 * harmony);

    // ▶ Sağ hilal dolgusu — color2 (turkuaz)
    canvas.save();
    final clipL = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: c1, radius: r1 * (0.78 + 0.22 * (1 - harmony))));
    canvas.clipPath(clipL, doAntiAlias: true);
    canvas.drawCircle(c2, r2,
      Paint()..color = color2.withValues(alpha: 0.20 + 0.30 * harmony)..style = PaintingStyle.fill);
    canvas.restore();
    canvas.drawCircle(c2, r2,
      Paint()..color = color2.withValues(alpha: 0.50 + 0.40 * harmony)..style = PaintingStyle.stroke..strokeWidth = 1.2 + 0.8 * harmony);

    // İç çekirdek daire (color2)
    if (harmony > 0.2) {
      final innerR = r2 * (0.28 + 0.12 * harmony);
      final ia = (harmony - 0.2) / 0.8;
      canvas.drawCircle(c2, innerR,
        Paint()..color = color2.withValues(alpha: 0.18 * ia)..style = PaintingStyle.fill);
      canvas.drawCircle(c2, innerR,
        Paint()..color = color2.withValues(alpha: 0.55 * ia)..style = PaintingStyle.stroke..strokeWidth = 0.9);
    }

    // Merkez buluşma noktası (harmanlanmış renk)
    if (harmony > 0.15) {
      final da = (harmony - 0.15) / 0.85;
      canvas.drawCircle(Offset(cx, cy), 5 * harmony,
        Paint()..color = blended.withValues(alpha: 0.22 * da)..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 * harmony)..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(cx, cy), 2.0 + 1.5 * harmony,
        Paint()..color = blended.withValues(alpha: 0.65 + 0.35 * da)..style = PaintingStyle.fill);
      if (harmony > 0.5) {
        canvas.drawCircle(Offset(cx, cy), 1.0 + 0.5 * harmony,
          Paint()..color = Colors.white.withValues(alpha: 0.35 * ((harmony - 0.5) / 0.5))..style = PaintingStyle.fill);
      }
    }

    // Dış halkada marker noktalar (dönüşümlü renk)
    if (harmony > 0.6) {
      final ma = (harmony - 0.6) / 0.4;
      for (var i = 0; i < 4; i++) {
        final angle = i * pi / 2 + pi / 4;
        final mx = cx + outerR * cos(angle);
        final my = cy + outerR * sin(angle);
        final mc = i.isEven ? color1 : color2;
        canvas.drawCircle(Offset(mx, my), 1.8,
          Paint()..color = mc.withValues(alpha: 0.3 * ma)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5)..style = PaintingStyle.fill);
        canvas.drawCircle(Offset(mx, my), 1.5,
          Paint()..color = mc.withValues(alpha: 0.55 * ma)..style = PaintingStyle.fill);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HarmonySymbolPainter old) => harmony != old.harmony;
}

/// Radyal halka grafik — 7 iç içe yarım daire
class _RadialRingChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  _RadialRingChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.95;
    final maxR = size.width * 0.48;
    final ringWidth = maxR / (values.length + 1.5);
    final gap = ringWidth * 0.15;

    for (var i = 0; i < values.length; i++) {
      final r = maxR - i * (ringWidth + gap);
      if (r < 4) continue;
      final color = colors[i % colors.length];
      final sweep = values[i].clamp(0.0, 1.0);

      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        pi, pi, false,
        Paint()
          ..color = color.withValues(alpha: 0.08)
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringWidth * 0.75
          ..strokeCap = StrokeCap.butt,
      );

      if (sweep > 0) {
        canvas.drawArc(
          Rect.fromCircle(center: Offset(cx, cy), radius: r),
          pi, pi * sweep, false,
          Paint()
            ..color = color.withValues(alpha: 0.55 + 0.35 * sweep)
            ..style = PaintingStyle.stroke
            ..strokeWidth = ringWidth * 0.75
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RadialRingChartPainter old) {
    for (var i = 0; i < values.length; i++) {
      if (values[i] != old.values[i]) return true;
    }
    return false;
  }
}

// ── CUSTOM PAINTER FOR INFOGRAPHIC LINES ──
class _InfographicLinePainter extends CustomPainter {
  final List<Map<String, double>> points;
  final double progress;

  _InfographicLinePainter(this.points, {this.progress = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45 * progress)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final Paint dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85 * progress)
      ..style = PaintingStyle.fill;

    final Paint endDotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.50 * progress)
      ..style = PaintingStyle.fill;

    for (var p in points) {
      final startX = p['startX']!;
      final startY = p['startY']!;
      final elbowX = p['elbowX']!;
      final endX   = p['endX']!;
      final endY   = p['endY']!;

      // Kartın içindeki başlangıç noktasına küçük dot
      canvas.drawCircle(Offset(startX, startY), 2.5 * progress, dotPaint);

      // Tam path
      final fullPath = Path()
        ..moveTo(startX, startY)
        ..lineTo(elbowX, endY)
        ..lineTo(endX, endY);

      // Progress'e göre path'in bir kısmını çiz
      final metrics = fullPath.computeMetrics();
      for (final metric in metrics) {
        final drawLength = metric.length * progress;
        final partialPath = metric.extractPath(0, drawLength);
        canvas.drawPath(partialPath, linePaint);
      }

      // Uç noktada küçük dot (sadece progress tam olduğunda)
      if (progress > 0.8) {
        final endDotOpacity = ((progress - 0.8) / 0.2).clamp(0.0, 1.0);
        final endDot = Paint()
          ..color = Colors.white.withValues(alpha: 0.50 * endDotOpacity)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(endX, endY), 1.5, endDot);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _InfographicLinePainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.progress != progress;
  }
}

// Tutarlı tap efekti — tüm app'te aynı hissiyat
class _TapAnimButton extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget child;
  const _TapAnimButton({required this.onTap, required this.child});

  @override
  State<_TapAnimButton> createState() => _TapAnimButtonState();
}

class _TapAnimButtonState extends State<_TapAnimButton> {
  bool _pressed = false;
  DateTime? _pressTime;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _pressTime = DateTime.now();
        setState(() => _pressed = true);
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) async {
        // Minimum 150ms görsel süre — hızlı tıklamada bile efekt görünsün
        final elapsed = DateTime.now().difference(_pressTime ?? DateTime.now());
        final remaining = const Duration(milliseconds: 150) - elapsed;
        if (remaining > Duration.zero) {
          await Future.delayed(remaining);
        }
        if (mounted) setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.5 : 1.0,
          duration: const Duration(milliseconds: 80),
          child: widget.child,
        ),
      ),
    );
  }
}
