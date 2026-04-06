import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/glass_back_button.dart';
import '../widgets/guidance_booklet.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:share_plus/share_plus.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';
import '../constants/colors.dart';
import '../services/storage_service.dart';
import '../services/dream_analysis_service.dart';
import '../services/supabase_dream_service.dart';
import '../models/emotion.dart';
import '../models/dream_analysis.dart';
import '../models/dream_input.dart';
import 'premium_paywall_page.dart';
import '../models/clarification_answer.dart';
import '../widgets/stars_background.dart';

class DreamPage extends StatefulWidget {
  const DreamPage({super.key});

  @override
  State<DreamPage> createState() => _DreamPageState();
}

class _DreamPageState extends State<DreamPage>
    with SingleTickerProviderStateMixin {
  AppLocalizations get _l10n => AppLocalizations.of(context)!;
  bool get _isTr => Localizations.localeOf(context).languageCode == 'tr';

  String _trEn(String tr, String en) => _isTr ? tr : en;

  String _emotionLabel(Emotion emotion) {
    switch (emotion) {
      case Emotion.anxiety:
        return _l10n.emotionAnxiety;
      case Emotion.fear:
        return _l10n.emotionFear;
      case Emotion.calm:
        return _l10n.emotionCalm;
      case Emotion.happiness:
        return _l10n.emotionHappy;
      case Emotion.sadness:
        return _l10n.emotionSad;
      case Emotion.confusion:
        return _l10n.emotionConfusion;
    }
  }

  List<String> _dreamPromptsFor() => _isTr ? _dreamPromptsTr : _dreamPromptsEn;

  List<String> _dreamQuotesFor() => _isTr ? _dreamQuotesTr : _dreamQuotesEn;

  List<String> _educationalMessagesFor() =>
      _isTr ? _educationalMessagesTr : _educationalMessagesEn;
  static const List<double> _dreamGradientStops = [
    0.0,
    0.2,
    0.42,
    0.62,
    0.82,
    1.0,
  ];
  static const LinearGradient _morningDreamGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0F162B), // gece mavi (daha koyu)
      Color(0xFF20284A), // morumsu mavi (koyu)
      Color(0xFF373B6E), // lavanta (koyu)
      Color(0xFF4F3F86), // yumuşak mor (koyu)
      Color(0xFF765C7B), // bulut pembe (koyu)
      Color(0xFF41436D), // alt mavi (koyu)
    ],
    stops: _dreamGradientStops,
  );
  static const LinearGradient _anxietyDreamGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0B1224),
      Color(0xFF1D2B44),
      Color(0xFF2B3C62),
      Color(0xFF3A4B74),
      Color(0xFF4B5D86),
      Color(0xFF2D3B5F),
    ],
    stops: _dreamGradientStops,
  );
  static const LinearGradient _fearDreamGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0D0F1F),
      Color(0xFF1B1B32),
      Color(0xFF2A263E),
      Color(0xFF3B2B3F),
      Color(0xFF4A2C3D),
      Color(0xFF2A2334),
    ],
    stops: _dreamGradientStops,
  );
  static const LinearGradient _calmDreamGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0B1B2A),
      Color(0xFF123046),
      Color(0xFF1C465E),
      Color(0xFF2A5C6F),
      Color(0xFF3B6A78),
      Color(0xFF1B3446),
    ],
    stops: _dreamGradientStops,
  );
  static const LinearGradient _happinessDreamGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF2A1D3A),
      Color(0xFF3A244F),
      Color(0xFF4A2C64),
      Color(0xFF5A3572),
      Color(0xFF6A3F7A),
      Color(0xFF3C2C58),
    ],
    stops: _dreamGradientStops,
  );
  static const LinearGradient _sadnessDreamGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0B1424),
      Color(0xFF13233A),
      Color(0xFF1C2F4A),
      Color(0xFF243A58),
      Color(0xFF2E4566),
      Color(0xFF1B2B41),
    ],
    stops: _dreamGradientStops,
  );
  static const LinearGradient _uncertainDreamGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF121723),
      Color(0xFF1B2130),
      Color(0xFF242B3E),
      Color(0xFF2C3247),
      Color(0xFF343A50),
      Color(0xFF1F2638),
    ],
    stops: _dreamGradientStops,
  );

  // Rastgele yönlendirici yazılar (20 adet)
  static const List<String> _dreamPromptsTr = [
    'En net hatırladığın sahneyi yaz…',
    'Rüyada gördüğün ilk görüntüyü yaz…',
    'Aklında kalan mekânı veya ortamı yaz…',
    'Rüyada olan biteni kısaca anlat…',
    'Rüyada seni en çok etkileyen an hangisiydi?',
    'Gördüğün kişileri veya varlıkları yaz…',
    'Rüyada olan olayın özünü yaz…',
    'En yoğun geçen sahneyi yaz…',
    'Rüyada tekrar eden bir şey varsa yaz…',
    'Başlangıç, orta veya son fark etmez — yaz…',
    'Rüyada yaşanan ana durumu yaz…',
    'Aklında kalan görüntüleri sırayla yaz…',
    'Rüyadaki hareketi veya değişimi yaz…',
    'Nerede olduğunu hatırlıyorsan yaz…',
    'Rüyada ne olduğunu kısa cümlelerle yaz…',
    'Tam net değilse parçalar hâlinde yaz…',
    'Mantıklı olmasına gerek yok, gördüğünü yaz…',
    'Bir sahneyle başla…',
    'En baskın anı yaz…',
    'Aklında kalan kısmı buraya yaz…',
  ];
  static const List<String> _dreamPromptsEn = [
    'Write the clearest scene you remember…',
    'Write the first image you saw in the dream…',
    'Describe the place or setting you remember…',
    'Briefly describe what happened in the dream…',
    'What was the most striking moment for you?',
    'Write the people or beings you saw…',
    'Summarize the main event of the dream…',
    'Write the most intense scene…',
    'If something repeated, write it…',
    'Start, middle, or end—just write…',
    'Describe the main situation in the dream…',
    'Write the images you remember in order…',
    'Describe the movement or change in the dream…',
    'Write where you were, if you recall…',
    'Write what happened in short sentences…',
    'If it is not clear, write fragments…',
    'It does not have to be logical—write what you saw…',
    'Start with a scene…',
    'Write the most dominant moment…',
    'Write the part you remember here…',
  ];

  // Bilimsel rüya sözleri - her sayfa açılışında rastgele biri gösterilir
  static const List<String> _dreamQuotesTr = [
    'Uyku sırasında beyin, anıları yeniden düzenler.',
    'Beyin, uykuda anlam üretmeye devam eder.',
    'Rüyalar, zihnin iç dengeyi koruma çabasıdır.',
    'Uyku sırasında mantık azalır, duygu artar.',
    'Rüyalar, zihinsel yüklerin boşaltılma alanıdır.',
    'Rüyalar, günlük yaşantının izlerini taşır.',
    'Uyuyan beyin, senaryo üretir.',
    'Rüya, zihnin kendini simüle etmesidir.',
    'Rüyalar, bilinçsiz öğrenmenin parçasıdır.',
    'Beyin, rüyada duygusal önceliklere odaklanır.',
    'Uyku, zihinsel yeniden yapılanma sağlar.',
    'Rüyalar, içsel çatışmaların izlerini taşır.',
    'Beyin, rüyada olasılıkları dener.',
    'Rüyalar, duygusal tepkileri test eder.',
    'Rüyalar, zihnin kendini regüle etme yoludur.',
    'Beyin, rüyada sembollerle çalışır.',
    'Rüya, duygusal yoğunluğun göstergesidir.',
    'Rüyalar, zihinsel stresin işaretlerini taşır.',
    'Uyku, beyin için aktif bir süreçtir.',
    'Rüyalar, geçmişle bugünü bağlar.',
    'Beyin, rüyada nedensellik aramaz.',
    'Rüya, içsel önceliklerin yansımasıdır.',
    'Rüyalar, duygusal öğrenmeyi destekler.',
    'Uyuyan zihin, verileri filtreler.',
    'Rüya, duyguların sahneye taşınmasıdır.',
    'Beyin, rüyada kontrolsüzdür ama aktiftir.',
    'Rüyalar, zihinsel sürekliliğin parçasıdır.',
    'Uyku, zihnin bakım modudur.',
    'Rüya, bastırılan düşüncelerin izidir.',
    'Rüyalar, beynin gece vardiyasıdır.',
    'Rüya, duygusal yüklerin işlenme anıdır.',
    'Beyin, rüyada güvenlik senaryoları üretir.',
    'Rüyalar, zihnin kendini dengeleme yoludur.',
  ];
  static const List<String> _dreamQuotesEn = [
    'During sleep, the brain reorganizes memories.',
    'The brain keeps producing meaning while asleep.',
    'Dreams are the mind’s effort to keep inner balance.',
    'Logic decreases during sleep while emotion rises.',
    'Dreams are a release valve for mental load.',
    'Dreams carry traces of daily life.',
    'The sleeping brain creates scenarios.',
    'A dream is the mind simulating itself.',
    'Dreams are part of unconscious learning.',
    'The brain focuses on emotional priorities in dreams.',
    'Sleep supports mental reconfiguration.',
    'Dreams carry traces of inner conflicts.',
    'The brain tests possibilities in dreams.',
    'Dreams test emotional reactions.',
    'Dreams help the mind self-regulate.',
    'The brain works with symbols in dreams.',
    'Dreams reflect emotional intensity.',
    'Dreams carry signs of mental stress.',
    'Sleep is an active process for the brain.',
    'Dreams connect past and present.',
    'The brain does not seek causality in dreams.',
    'Dreams reflect inner priorities.',
    'Dreams support emotional learning.',
    'The sleeping mind filters data.',
    'Dreams bring emotions to the stage.',
    'The brain is uncontrolled yet active in dreams.',
    'Dreams are part of mental continuity.',
    'Sleep is the mind’s maintenance mode.',
    'Dreams trace suppressed thoughts.',
    'Dreams are the brain’s night shift.',
    'Dreams are moments where emotional load is processed.',
    'The brain runs safety scenarios in dreams.',
    'Dreams help the mind rebalance.',
  ];

  int _currentNavIndex = 0;
  int _currentTab = 0; // 0: Yeni Rüya, 1: Rüyalarım
  late String _currentDreamQuote; // Rastgele bilimsel söz
  final TextEditingController _dreamController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _dreamFocusNode = FocusNode();
  final ValueNotifier<bool> _hasDreamTextNotifier = ValueNotifier(false);
  Emotion? _selectedEmotion; // Yeni bilimsel sistem
  String? _selectedMood; // Eski sistem (backward compatibility)
  DreamAnalysis? _latestAnalysis;
  List<ClarificationAnswer> _latestClarifications = const [];
  _MetricType? _activeMetric;
  Offset? _overlayPointerDown;
  Offset? _metricTapOrigin; // Panel'in çıkış noktası
  final GlobalKey _legendKey = GlobalKey();
  static const Map<_MetricType, String> _metricDescriptionsTr = {
    _MetricType.emotionalLoad:
        'Rüyayı etkileyen baskın ve bastırılmış duyguların yoğunluğu.',
    _MetricType.uncertainty:
        'Zihnin kontrol ve karar süreçlerindeki kararsızlık seviyesi.',
    _MetricType.recentPast:
        'Son günlerde yaşanan olayların rüyaya yansıma payı.',
    _MetricType.brainActivity:
        'REM uykusunda oluşan, anlam taşımayan doğal beyin sinyalleri.',
  };
  static const Map<_MetricType, String> _metricDescriptionsEn = {
    _MetricType.emotionalLoad:
        'The intensity of dominant and suppressed emotions influencing the dream.',
    _MetricType.uncertainty:
        'The level of indecision in control and decision-making processes.',
    _MetricType.recentPast:
        'How much recent events are reflected in the dream.',
    _MetricType.brainActivity:
        'Natural brain signals during REM sleep that carry no inherent meaning.',
  };

  String _metricDescription(_MetricType metric) {
    final map = _isTr ? _metricDescriptionsTr : _metricDescriptionsEn;
    return map[metric] ?? '';
  }

  static const double _metricPanelWidth = 200;
  List<String> _detectedSymbols = [];
  String _generalAnalysis = '';
  String _psychologyAnalysis = '';
  String _spiritualAnalysis = '';
  String _advice = '';
  bool _isWriting = false;
  bool _isTyping = false;
  bool _showDreamInputWarning = false;
  bool _showMoodPulse = false;
  bool _showAnalysisOverlay = false;
  bool _analysisOverlayVisible = false; // Animasyon için
  String _overlayContent = 'analyzing'; // 'analyzing' | 'gap' | 'results'
  String _overlayRandomMessage = '';
  String _overlayNotAnalyzableMessage = '';
  bool _overlayShowNotAnalyzable = false;
  List<_ClarificationQuestion> _overlayQuestions = [];
  Color _overlayAccentColor = AppColors.primaryPurple;
  Completer<List<ClarificationAnswer>>? _answersCompleter;
  Completer<void>? _retryCompleter;
  DeepAnalysisResult? _deepAnalysisResult;
  bool _isPremiumResult = false;
  bool _isFromHistory = false;
  bool _isDreamSaved = false;
  String? _currentDreamId;
  String? _selectedReflectionAction;
  int _historyKeyTracker = 0;
  late final List<Emotion> _emotionOrder;
  late String _currentPrompt;
  late String _currentSubtitle;
  final DreamAnalysisService _analysisService = DreamAnalysisService();
  final SupabaseDreamService _supabaseDreamService = SupabaseDreamService();
  DreamDistribution _apiDistribution =
      const DreamDistribution(); // Sabit 4 metrik
  String _apiCategory = ''; // "Kabus", "Duygusal İşleme", vs.
  List<DreamSection> _apiSections = []; // Yapılandırılmış bölümler
  String _apiSummary = ''; // 1 cümle
  String? _lastLocaleCode;
  bool _localizedSeedsReady = false;
  int _currentTipIndex = 0; // Biliyor muydun? için sabit index
  List<Map<String, dynamic>> _premiumAnswers =
      []; // Kullanıcının verdiği premium cevaplar
  bool _isPremiumUser = false;

  // ── STANDART YORUM EKONOMİSİ (Tarot modeli) ──
  static const _kDreamFreeDate = 'dream_free_date_v1';
  static const _kDreamAdCredits = 'dream_ad_credits_v1';
  static const _kDreamAdWatchCount = 'dream_ad_watch_count_v1';
  static const _kDreamAdWatchDate = 'dream_ad_watch_date_v1';
  static const _kDreamPremiumReadsCount = 'dream_premium_reads_count_v1';
  static const _kDreamPremiumReadsDate = 'dream_premium_reads_date_v1';
  static const _kMaxDailyAds = 2;
  static const _kMaxPremiumReads = 3;
  bool _dreamDailyFreeUsed = false;
  int _dreamAdCredits = 0;
  int _dreamDailyAdWatchCount = 0;
  int _dreamPremiumReadsUsed = 0;
  // Bilimsel eğitici metinler (loading sırasında gösterilecek)
  static const List<String> _educationalMessagesTr = [
    'REM uykusunda mantık merkezleri baskılanır, bu yüzden rüyalar mantıksız görünür.',
    'Rüyalar genellikle yakın dönemde yaşanan duygusal deneyimleri işler.',
    'Beyin, rüya sırasında anıları düzenler ve güçlendirir.',
    'Lucid rüya, rüyada olduğunuzu fark etme ve kontrol edebilme yeteneğidir.',
    'Ortalama bir insan gecede 4-6 rüya görür, ancak çoğunu hatırlamaz.',
    'Rüya görmek, zihinsel sağlığın bir işaretidir.',
    'REM uykusu problem çözme ve yaratıcılığı artırır.',
    'Beyniniz rüya sırasında uyanıkken olduğu kadar aktiftir.',
    'Tekrarlayan rüyalar, çözülmemiş duygusal sorunlara işaret edebilir.',
    'Su içeren rüyalar genellikle duygu durumu ile ilişkilidir.',
    'Uçma rüyaları özgürlük ve kontrol hissi ile bağlantılıdır.',
    'Sabah saatlerinde gördüğünüz rüyaları daha iyi hatırlarsınız.',
    'Rüya günlüğü tutmak, rüya hatırlama yeteneğinizi geliştirir.',
    'Rüyalar, beynin simülasyon yaparak olası senaryoları çalıştırmasıdır.',
    'Stres azaldığında kabus görme sıklığı da azalır.',
  ];
  static const List<String> _educationalMessagesEn = [
    'During REM sleep, logic centers are suppressed, so dreams can seem illogical.',
    'Dreams often process recent emotional experiences.',
    'The brain organizes and strengthens memories during dreaming.',
    'Lucid dreaming is the ability to realize you are dreaming and control it.',
    'An average person has 4-6 dreams per night, but forgets most of them.',
    'Dreaming is a sign of mental health.',
    'REM sleep boosts problem solving and creativity.',
    'Your brain is nearly as active during dreams as when awake.',
    'Recurring dreams can indicate unresolved emotional issues.',
    'Water in dreams is often linked to emotional state.',
    'Flying dreams are linked to freedom and control.',
    'You remember dreams better in the early morning.',
    'Keeping a dream journal improves recall.',
    'Dreams are the brain\'s simulation of possible scenarios.',
    'As stress decreases, nightmares become less frequent.',
  ];
  static const String _notAnalyzableMessageTr =
      'Bunun bir rüyaya ait olduğuna emin misin?\nLütfen uykudayken zihninde canlanan gerçek bir sahneyi anlat.';
  static const String _notAnalyzableMessageEn =
      'Are you sure this was a dream?\nPlease describe a real scene you experienced while sleeping.';

  String get _notAnalyzableMessage =>
      _trEn(_notAnalyzableMessageTr, _notAnalyzableMessageEn);

  @override
  void initState() {
    super.initState();
    // En az 15 karakter kontrolü
    _hasDreamTextNotifier.value = _dreamController.text.trim().length >= 15;
    _dreamController.addListener(_onDreamChanged);
    _dreamFocusNode.addListener(_onFocusChanged);
    _scrollController.addListener(_onScroll);
    _emotionOrder = List<Emotion>.from(Emotion.values);
    _emotionOrder.shuffle(math.Random());
    _currentTipIndex = math.Random().nextInt(50); // Biliyor muydun? sabit tip
    _loadPremiumStatus();
  }

  Future<void> _loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      final today = DateTime.now().toIso8601String().split('T')[0];
      setState(() {
        _isPremiumUser = prefs.getBool('is_premium_test_mode') ?? false;

        // Günlük ücretsiz hak kontrolü
        _dreamDailyFreeUsed = (prefs.getString(_kDreamFreeDate) == today);
        _dreamAdCredits = prefs.getInt(_kDreamAdCredits) ?? 0;

        // Günlük reklam sayacı sıfırlama
        final adDate = prefs.getString(_kDreamAdWatchDate) ?? '';
        if (adDate != today) {
          _dreamDailyAdWatchCount = 0;
          _dreamAdCredits = 0;
          prefs.setInt(_kDreamAdCredits, 0);
          prefs.setInt(_kDreamAdWatchCount, 0);
          prefs.setString(_kDreamAdWatchDate, today);
        } else {
          _dreamDailyAdWatchCount = prefs.getInt(_kDreamAdWatchCount) ?? 0;
        }

        // Elite günlük okuma sayacı
        final premReadsDate = prefs.getString(_kDreamPremiumReadsDate) ?? '';
        if (premReadsDate != today) {
          _dreamPremiumReadsUsed = 0;
          prefs.setInt(_kDreamPremiumReadsCount, 0);
          prefs.setString(_kDreamPremiumReadsDate, today);
        } else {
          _dreamPremiumReadsUsed = prefs.getInt(_kDreamPremiumReadsCount) ?? 0;
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localeCode = Localizations.localeOf(context).languageCode;
    if (_localizedSeedsReady && _lastLocaleCode == localeCode) return;
    _lastLocaleCode = localeCode;
    final prompts = _dreamPromptsFor();
    _currentPrompt = prompts[math.Random().nextInt(prompts.length)];
    _currentSubtitle = prompts[math.Random().nextInt(prompts.length)];
    final quotes = _dreamQuotesFor();
    _currentDreamQuote = quotes[math.Random().nextInt(quotes.length)];
    while (_currentSubtitle == _currentPrompt && prompts.length > 1) {
      _currentSubtitle = prompts[math.Random().nextInt(prompts.length)];
    }
    _localizedSeedsReady = true;
  }

  void _onScroll() {
    if (_activeMetric != null) {
      _dismissMetricOverlay();
    }
  }

  void _closeWritingModal({bool instant = false}) {
    setState(() {
      _analysisOverlayVisible = false;
    });

    if (instant) {
      if (mounted) {
        setState(() {
          _showAnalysisOverlay = false;
          _isWriting = false;
          _overlayContent = 'analyzing';
        });
      }
      return;
    }

    // Kapanma animasyonu bitmesini bekle
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _showAnalysisOverlay = false;
          _isWriting = false;
          _overlayContent = 'analyzing'; // Sonraki açılış için resetle
        });
      }
    });
  }

  void _onFocusChanged() {
    final hasFocus = _dreamFocusNode.hasFocus;
    if (hasFocus != _isTyping) {
      setState(() => _isTyping = hasFocus);
    }
    // Input'a tıklandığında metrik panelini kapat
    if (hasFocus && _activeMetric != null) {
      _dismissMetricOverlay();
    }
  }

  Future<void> _pulseDreamInputWarning() async {
    if (_showDreamInputWarning) return;
    setState(() => _showDreamInputWarning = true);
    await Future.delayed(const Duration(milliseconds: 360));
    if (mounted) {
      setState(() => _showDreamInputWarning = false);
    }
  }

  Future<void> _pulseMoodRail() async {
    if (_showMoodPulse) {
      setState(() => _showMoodPulse = false);
      await Future.delayed(const Duration(milliseconds: 40));
    }
    setState(() => _showMoodPulse = true);
    await Future.delayed(const Duration(milliseconds: 120));
    if (mounted) {
      setState(() => _showMoodPulse = false);
    }
  }

  void _onDreamChanged() {
    // En az 15 karakter yazılınca buton aktif olsun
    final hasEnoughText = _dreamController.text.trim().length >= 15;
    if (hasEnoughText != _hasDreamTextNotifier.value) {
      _hasDreamTextNotifier.value = hasEnoughText;
    }
  }

  @override
  void dispose() {
    _dreamController.removeListener(_onDreamChanged);
    _dreamController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _dreamFocusNode.removeListener(_onFocusChanged);
    _dreamFocusNode.dispose();
    _hasDreamTextNotifier.dispose();
    super.dispose();
  }

  Future<bool> _checkAndDeductPremiumAccess() async {
    // Herkes (Elite dahil) Ruh Taşı harcar
    int soulStones = await StorageService.getSoulStones();

    // Ruh Taşı bittiyse — paywall yönlendir
    if (soulStones <= 0) {
      if (!mounted) return false;
      await showGeneralDialog<void>(
        context: context,
        barrierColor: Colors.black.withOpacity(0.5),
        barrierDismissible: true,
        barrierLabel: 'NoStones',
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, anim1, anim2) {
          return Center(
            child: ScaleTransition(
              scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Material(
                  type: MaterialType.transparency,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.diamond_rounded,
                              color: Colors.white.withOpacity(0.3),
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _isTr
                                  ? 'Ruh Taşı Gerekli'
                                  : 'Soul Stone Required',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isTr
                                  ? 'Derin analiz için Ruh Taşı gereklidir.\n\nRuh Taşlarını Aura puanlarını dönüştürerek veya Elite abonelik ile kazanabilirsin.'
                                  : 'Soul Stones are required for deep analysis.\n\nYou can earn Soul Stones by converting Aura points or with Elite subscription.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(
                                    0xFF22D3EE,
                                  ).withOpacity(0.15),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color: const Color(
                                        0xFF22D3EE,
                                      ).withOpacity(0.4),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const PremiumPaywallPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  _isTr ? 'Elite Abone Ol' : 'Get Elite',
                                  style: const TextStyle(
                                    color: Color(0xFF22D3EE),
                                    fontWeight: FontWeight.bold,
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
          );
        },
      );
      return false;
    }

    // Elite kullanıcı: sessizce harcar (dialog yok)
    if (_isPremiumUser) {
      await StorageService.deductSoulStones(1);
      return true;
    }

    // Ücretsiz kullanıcı: onay dialogu göster
    if (!mounted) return false;
    bool? confirm = await showGeneralDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible: true,
      barrierLabel: 'SpendStone',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Material(
                type: MaterialType.transparency,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.diamond_rounded,
                            color: const Color(0xFFFFD700),
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isTr
                                ? 'Klinik Analiz Kapısı'
                                : 'Clinical Analysis Gate',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isTr
                                ? 'Mevcut Ruh Taşın: $soulStones\n\nBu klinik seviye derin psikolojik analiz için 1 Ruh Taşı harcanır.'
                                : 'Current Soul Stones: $soulStones\n\nThis clinical-level deep psychoanalysis costs 1 Soul Stone.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(
                                      0xFF22D3EE,
                                    ).withOpacity(0.15),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(
                                        color: const Color(
                                          0xFF22D3EE,
                                        ).withOpacity(0.4),
                                      ),
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      _isTr
                                          ? '1 Ruh Taşı Kullan'
                                          : 'Use 1 Stone',
                                      style: const TextStyle(
                                        color: Color(0xFF22D3EE),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(
                                      0xFF22D3EE,
                                    ).withOpacity(0.15),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(
                                        color: const Color(
                                          0xFF22D3EE,
                                        ).withOpacity(0.4),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const PremiumPaywallPage(),
                                      ),
                                    );
                                  },
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      _isTr ? 'Elite Abone Ol' : 'Get Elite',
                                      style: const TextStyle(
                                        color: Color(0xFF22D3EE),
                                        fontWeight: FontWeight.bold,
                                      ),
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
        );
      },
    );

    if (confirm == true) {
      await StorageService.deductSoulStones(1);
      return true;
    }
    return false;
  }

  Future<bool> _interpretDreamPremium() async {
    final trimmed = _dreamController.text.trim();
    if (trimmed.length < 15) return false;
    if (_selectedEmotion == null) return false;

    bool canAccess = await _checkAndDeductPremiumAccess();
    if (!canAccess) return false;

    final messages = _educationalMessagesFor();
    final randomMessage = messages[math.Random().nextInt(messages.length)];

    final retryCompleter = Completer<void>();
    _retryCompleter = retryCompleter;
    setState(() {
      _showAnalysisOverlay = true;
      _analysisOverlayVisible = false;
      _overlayContent = 'analyzing';
      _overlayRandomMessage = randomMessage;
      _overlayNotAnalyzableMessage = '';
      _overlayShowNotAnalyzable = false;
      _overlayQuestions = [];
      _overlayAccentColor = const Color(0xFF7C6CF3); // Premium Kozmik İndigo
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _analysisOverlayVisible = true);
    });

    final locale = _isTr ? 'tr' : 'en';
    final emotionLabel = _selectedEmotion!.label;

    // 1. ADIM: Soruları Getir
    final questionResult = await _supabaseDreamService.generateQuestions(
      dreamText: trimmed,
      emotion: emotionLabel,
      locale: locale,
    );

    if (!questionResult.success || !questionResult.isValidDream) {
      // Hata veya Rüya Algılanamadı
      if (mounted) {
        setState(() {
          _overlayShowNotAnalyzable = true;
          _overlayNotAnalyzableMessage =
              _notAnalyzableMessage; // Standart rüya değil uyarısı
        });
      }
      return true;
    }

    // Soruları ekrana bas ve cevabı bekle
    final uiQuestions = questionResult.questions
        .map((q) => _ClarificationQuestion(id: q.id, text: q.question))
        .toList();

    List<ClarificationAnswer> userAnswers = [];

    if (uiQuestions.isNotEmpty) {
      if (mounted) {
        setState(() {
          _overlayQuestions = uiQuestions;
        });
      }

      final answersCompleter = Completer<List<ClarificationAnswer>>();
      _answersCompleter = answersCompleter;

      // Kullanıcının dönen çember altında evet/hayır cevaplarını vermesini bekle
      userAnswers = await answersCompleter.future;
    }

    // 2. ADIM: Soruları yanıtlandı — spinner kalsın, soruları kaldır
    if (mounted) {
      setState(() {
        _overlayQuestions = [];
      });
    }

    // 3. ADIM: Derin Analiz API çağrısı — cevaplarla birlikte
    // Soruların orijinal metnini kaydetmek için (overlay kaldırıldıktan sonra)
    final questionsBackup = questionResult.questions
        .map((q) => {'questionId': q.id, 'question': q.question})
        .toList();

    // Eğer overlay'daki sorular zaten kaldırıldıysa, backup'tan al
    final finalAnswers = userAnswers.map((a) {
      final qText =
          questionsBackup.firstWhere(
            (q) => q['questionId'] == a.questionId,
            orElse: () => {'question': ''},
          )['question'] ??
          '';
      return {
        'questionId': a.questionId,
        'question': qText,
        'answer': a.answer,
      };
    }).toList();

    final deepResult = await _supabaseDreamService.analyzeDeep(
      dreamText: trimmed,
      emotion: emotionLabel,
      locale: locale,
      answers: finalAnswers,
    );

    print('🔮🔮🔮 deepResult.success = ${deepResult.success}');
    print('🔮🔮🔮 deepResult.title = "${deepResult.title}"');
    print('🔮🔮🔮 deepResult.errorMessage = "${deepResult.errorMessage}"');

    if (!deepResult.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Derin Analiz API Hatası: ${deepResult.errorMessage}\nKlasik yoruma geçiliyor...',
            ),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      print('🔮🔮🔮 FALLING BACK TO STANDARD!');
      return await _interpretDream(skipOverlaySetup: true);
    }

    // Premium sonucu kaydet ve göster
    if (mounted) {
      _deepAnalysisResult = deepResult;
      _premiumAnswers = finalAnswers;
      _isPremiumResult = true;
      _isFromHistory = false;
      _isDreamSaved = false;
      _currentDreamId = null;
      _selectedReflectionAction = null;

      // Durumu hemen results'a geçecek şekilde güncelle ki kayıt işlemi asılı kalırsa UI'yi kilitlemesin
      print(
        '🔮🔮🔮 Setting _isPremiumResult = true, switching to gap then results',
      );
      setState(() {
        _overlayContent = 'gap';
        _isWriting = true;
      });

      // Otomatik Premium Kayıt İptal Edildi - Kullanıcı butona basarak kaydedecek.

      Future.delayed(const Duration(milliseconds: 520), () {
        if (mounted) {
          setState(() => _overlayContent = 'results');
        }
      });
    }
    _retryCompleter = null;
    return true;
  }

  // ── STANDART YORUM GÜNLÜK HAK SİSTEMİ ──
  bool _ensureDreamAllowance() {
    if (_isPremiumUser) {
      return _dreamPremiumReadsUsed < _kMaxPremiumReads;
    }
    if (!_dreamDailyFreeUsed) return true;
    if (_dreamAdCredits > 0) return true;
    return false;
  }

  Future<void> _consumeDreamAllowance() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (_isPremiumUser) {
      _dreamPremiumReadsUsed += 1;
      await prefs.setInt(_kDreamPremiumReadsCount, _dreamPremiumReadsUsed);
      if (mounted) setState(() {});
      return;
    }
    if (!_dreamDailyFreeUsed) {
      _dreamDailyFreeUsed = true;
      await prefs.setString(_kDreamFreeDate, today);
      if (mounted) setState(() {});
    } else if (_dreamAdCredits > 0) {
      _dreamAdCredits -= 1;
      await prefs.setInt(_kDreamAdCredits, _dreamAdCredits);
      if (mounted) setState(() {});
    }
  }

  Widget _dreamCreditInfoRow(IconData icon, String text, bool active) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: active
              ? AppColors.primaryPurple
              : Colors.white.withOpacity(0.3),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: active
                  ? Colors.white.withOpacity(0.9)
                  : Colors.white.withOpacity(0.4),
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showSoulStoneInfoPanel() async {
    final soulStones = await StorageService.getSoulStones();
    if (!mounted) return;
    await showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible: true,
      barrierLabel: 'SoulStoneInfo',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        final panelW = MediaQuery.of(context).size.width * 0.85;
        return Center(
          child: SizedBox(
            width: panelW,
            child: Material(
              type: MaterialType.transparency,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _isPremiumUser
                          ? const Color(0xFF22D3EE).withOpacity(0.08)
                          : Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _isPremiumUser
                            ? const Color(0xFF22D3EE).withOpacity(0.35)
                            : Colors.white.withOpacity(0.25),
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.diamond_rounded,
                          color: soulStones >= 1
                              ? const Color(0xFF22D3EE)
                              : Colors.white.withOpacity(0.3),
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isTr ? "Ruh Taşların" : "Your Soul Stones",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF22D3EE).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF22D3EE).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.diamond_outlined,
                                size: 14,
                                color: Color(0xFF22D3EE),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                soulStones > 0
                                    ? (_isTr
                                          ? "$soulStones Ruh Taşın var"
                                          : "$soulStones Soul Stones remaining")
                                    : (_isTr
                                          ? "Ruh Taşın bitti"
                                          : "Out of Soul Stones"),
                                style: const TextStyle(
                                  color: Color(0xFF22D3EE),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _premiumInfoRow(
                          Icons.auto_awesome,
                          _isTr
                              ? "Derin Analiz için gerekli"
                              : "Required for Deep Analysis",
                          true,
                        ),
                        const SizedBox(height: 10),
                        _premiumInfoRow(
                          Icons.diamond_outlined,
                          _isTr
                              ? "Her analiz 1 Ruh Taşı harcar"
                              : "Each analysis costs 1 Soul Stone",
                          soulStones >= 1,
                        ),
                        const SizedBox(height: 10),
                        _premiumInfoRow(
                          Icons.workspace_premium,
                          _isPremiumUser
                              ? (_isTr
                                    ? "Elite ayrıcalığı: Her gece 5 Ruh Taşı yenilenir"
                                    : "Elite refils 5 Soul Stones nightly")
                              : (_isTr
                                    ? "Elite ile her gece 5 Ruh Taşı kazan"
                                    : "Get 5 daily Soul Stones with Elite"),
                          _isPremiumUser,
                        ),

                        if (!_isPremiumUser) ...[
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFF22D3EE,
                              ).withOpacity(0.15),
                              elevation: 0,
                              minimumSize: const Size(double.infinity, 44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: const Color(
                                    0xFF22D3EE,
                                  ).withOpacity(0.4),
                                ),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PremiumPaywallPage(),
                                ),
                              );
                            },
                            child: Text(
                              _isTr ? "Elite Abone Ol" : "Get Elite",
                              style: const TextStyle(
                                color: Color(0xFF22D3EE),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: const SizedBox.expand(),
            ),
            FadeTransition(
              opacity: anim1,
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: anim1,
                  curve: Curves.easeOutBack,
                ),
                child: child,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _premiumInfoRow(IconData icon, String text, bool isActive) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? const Color(0xFF22D3EE).withOpacity(0.12)
                : Colors.white.withOpacity(0.05),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isActive
                ? const Color(0xFF22D3EE).withOpacity(0.8)
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

  Future<bool> _showDreamCreditPanel() async {
    if (!mounted) return false;

    final hasCredit = _isPremiumUser
        ? (_dreamPremiumReadsUsed < _kMaxPremiumReads)
        : (!_dreamDailyFreeUsed || _dreamAdCredits > 0);

    int creditCount = _isPremiumUser
        ? (_kMaxPremiumReads - _dreamPremiumReadsUsed)
        : (!_dreamDailyFreeUsed ? 1 : _dreamAdCredits);

    final bool? result = await showGeneralDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible: true,
      barrierLabel: 'DreamCredit',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        final panelW = MediaQuery.of(context).size.width * 0.85;
        return Center(
          child: SizedBox(
            width: panelW,
            child: Material(
              type: MaterialType.transparency,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _isPremiumUser
                          ? AppColors.primaryPurple.withOpacity(0.08)
                          : Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _isPremiumUser
                            ? AppColors.primaryPurple.withOpacity(0.35)
                            : Colors.white.withOpacity(0.25),
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.nights_stay_rounded,
                          color: hasCredit
                              ? AppColors.primaryPurple
                              : Colors.white.withOpacity(0.3),
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isTr
                              ? (_isPremiumUser
                                    ? "Elite Okuma Hakların"
                                    : "Okuma Hakların")
                              : (_isPremiumUser
                                    ? "Elite Credits"
                                    : "Your Reading Credits"),
                          style: TextStyle(
                            color: _isPremiumUser
                                ? AppColors.primaryPurple
                                : Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _isPremiumUser
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryPurple.withOpacity(
                                    0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.primaryPurple.withOpacity(
                                      0.3,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.stars,
                                      size: 14,
                                      color: AppColors.primaryPurple,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      creditCount > 0
                                          ? (_isTr
                                                ? "$creditCount okuma hakkın var"
                                                : "$creditCount credits remaining")
                                          : (_isTr
                                                ? "Bugünlük hakkın bitti"
                                                : "Daily limit reached"),
                                      style: TextStyle(
                                        color: AppColors.primaryPurple,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Text(
                                creditCount > 0
                                    ? (_isTr
                                          ? "$creditCount okuma hakkın var"
                                          : "$creditCount credits remaining")
                                    : (_dreamDailyAdWatchCount < _kMaxDailyAds
                                          ? (_isTr
                                                ? "0 okuma hakkın var"
                                                : "0 credits remaining")
                                          : (_isTr
                                                ? "Bugünlük hakkın bitti"
                                                : "Daily limit reached")),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 13,
                                ),
                              ),
                        const SizedBox(height: 16),
                        // Info rows
                        if (_isPremiumUser) ...[
                          _dreamCreditInfoRow(
                            Icons.star_border,
                            _isTr
                                ? "Günlük $_kMaxPremiumReads Rüya Yorumu hakkı"
                                : "$_kMaxPremiumReads daily Dream interpretations",
                            true,
                          ),
                          const SizedBox(height: 10),
                          _dreamCreditInfoRow(
                            Icons.not_interested,
                            _isTr
                                ? "Reklam izleme zorunluluğu yok"
                                : "No need to watch ads",
                            true,
                          ),
                          const SizedBox(height: 10),
                          _dreamCreditInfoRow(
                            Icons.refresh,
                            _isTr
                                ? "Haklar her gece sıfırlanır"
                                : "Credits reset every night",
                            false,
                          ),
                        ] else ...[
                          _dreamCreditInfoRow(
                            Icons.nights_stay_outlined,
                            _isTr
                                ? "Her gün 1 ücretsiz yorum"
                                : "1 free interpretation every day",
                            !_dreamDailyFreeUsed,
                          ),
                          const SizedBox(height: 10),
                          _dreamCreditInfoRow(
                            Icons.play_circle_outline,
                            _isTr
                                ? "Reklam ile ek $_kMaxDailyAds hak (${math.min(_dreamDailyAdWatchCount, _kMaxDailyAds)}/$_kMaxDailyAds)"
                                : "Watch ads for $_kMaxDailyAds extra credits (${math.min(_dreamDailyAdWatchCount, _kMaxDailyAds)}/$_kMaxDailyAds)",
                            _dreamDailyAdWatchCount < _kMaxDailyAds,
                          ),
                          const SizedBox(height: 10),
                          _dreamCreditInfoRow(
                            Icons.refresh,
                            _isTr
                                ? "Haklar her gece sıfırlanır"
                                : "Credits reset every night",
                            false,
                          ),
                        ],
                        if (!_isPremiumUser) ...[
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _dreamDailyAdWatchCount < _kMaxDailyAds
                                    ? AppColors.primaryPurple.withOpacity(0.15)
                                    : Colors.white.withOpacity(0.05),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color:
                                        _dreamDailyAdWatchCount < _kMaxDailyAds
                                        ? AppColors.primaryPurple.withOpacity(
                                            0.4,
                                          )
                                        : Colors.white.withOpacity(0.1),
                                  ),
                                ),
                              ),
                              onPressed: _dreamDailyAdWatchCount < _kMaxDailyAds
                                  ? () {
                                      Navigator.pop(context, true);
                                    }
                                  : null,
                              child: Text(
                                _isTr ? "Reklam İzle" : "Watch Ad",
                                style: TextStyle(
                                  color: _dreamDailyAdWatchCount < _kMaxDailyAds
                                      ? AppColors.primaryPurple
                                      : Colors.white30,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: const SizedBox.expand(),
            ),
            FadeTransition(
              opacity: anim1,
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: anim1,
                  curve: Curves.easeOutBack,
                ),
                child: child,
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      // TODO: Gerçek reklam SDK entegrasyonu buraya gelecek
      // Şimdilik simüle ediyoruz (2 saniye bekleme)
      // await AdManager.showRewardedAd();
      await Future.delayed(const Duration(seconds: 2));

      final prefs = await SharedPreferences.getInstance();
      _dreamAdCredits += 1;
      _dreamDailyAdWatchCount += 1;
      await prefs.setInt(_kDreamAdCredits, _dreamAdCredits);
      await prefs.setInt(_kDreamAdWatchCount, _dreamDailyAdWatchCount);
      if (mounted) setState(() {});
      return true;
    }
    return false;
  }

  Future<bool> _interpretDream({bool skipOverlaySetup = false}) async {
    final trimmed = _dreamController.text.trim();
    if (trimmed.length < 15) {
      return false;
    }
    if (_selectedEmotion == null) {
      return false;
    }

    // ── Günlük hak kontrolü ──
    if (!_ensureDreamAllowance()) {
      final gotCredit = await _showDreamCreditPanel();
      if (!gotCredit || !_ensureDreamAllowance()) return false;
    }

    _isPremiumResult = false; // Reset premium flag for standard interpretation
    _deepAnalysisResult = null; // Clear old premium results

    if (!skipOverlaySetup) {
      // Bilimsel eğitici mesaj göster
      final messages = _educationalMessagesFor();
      final randomMessage = messages[math.Random().nextInt(messages.length)];

      final retryCompleter = Completer<void>();
      _retryCompleter = retryCompleter;
      setState(() {
        _showAnalysisOverlay = true;
        _analysisOverlayVisible = false;
        _overlayContent = 'analyzing';
        _overlayRandomMessage = randomMessage;
        _overlayNotAnalyzableMessage = '';
        _overlayShowNotAnalyzable = false;
        _overlayQuestions = [];
        _overlayAccentColor = _resolveEmotionAccentColor(_selectedEmotion);
      });

      // Yumuşak açılış animasyonu
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _analysisOverlayVisible = true);
        }
      });
    }

    // ─── API ÇAĞRISI ───
    final locale = _isTr ? 'tr' : 'en';
    final emotionLabel = _selectedEmotion!.label;

    final result = await _supabaseDreamService.interpretDream(
      dreamText: trimmed,
      emotion: emotionLabel,
      locale: locale,
    );

    if (!result.success) {
      // API bağlantı hatası → Lokal fallback
      final dreamInput = DreamInput(
        text: _dreamController.text,
        emotions: [_selectedEmotion!],
      );
      final analysis = _analysisService.analyzeDream(dreamInput.text);
      final interpretation = _analysisService.interpret(
        input: dreamInput,
        analysis: analysis,
        answers: [],
      );
      _generalAnalysis = interpretation;
      _apiDistribution = const DreamDistribution();
      _apiCategory = '';
      _apiSections = [];
      _apiSummary = '';
      _latestAnalysis = analysis;
    } else {
      // API başarılı ama içerik bir "Rüya" değilse, direkt hata popup'ını göster
      if (result.category == "Geçersiz Metin" ||
          result.category == "Invalid Content") {
        if (mounted) {
          setState(() {
            _overlayShowNotAnalyzable = true;
            // API'den gelen mesaj yerine doğrudan Flutter içindeki genel/gizemli hata mesajını basıyoruz
            _overlayNotAnalyzableMessage = _notAnalyzableMessage;
            // Animasyon veya ekran değişimi yapma, doğrudan "analyzing" ekranında hata mesajı belirecek.
          });
        }
        // return false demeyip true diyoruz çünkü API bir cevap verdi, ama işlem rüya değil.
        // Dialog içindeki onTap (_handleAnalysisRetry) fonksiyonu modalı kapatıp yeni giriş yapmayı sağlar.
        return true;
      }

      // API başarılı ve gerçek bir rüya → Sonuçları kaydet
      _apiDistribution = result.distribution;
      _apiCategory = result.category;
      _generalAnalysis = result.sections
          .map((s) => '${s.emoji} ${s.title}\n${s.content}')
          .join('\n\n');
      _apiSections = result.sections;
      _apiSummary = result.summary;
      _latestAnalysis = DreamAnalysis(
        hasThreat: false,
        hasPastReference: false,
        hasMovement: false,
        isSingleScene: false,
      );
    }

    _psychologyAnalysis = _generalAnalysis;
    _spiritualAnalysis = _generalAnalysis;
    _advice = _generalAnalysis;

    // Standart Rüyalar artık analiz geçmişine kaydedilmiyor (Sadece Premium kaydedilecek)
    await _consumeDreamAllowance();
    await StorageService.setDreamDoneToday();

    if (mounted) {
      setState(() {
        _overlayContent = 'gap';
        _isWriting = true;
      });
      Future.delayed(const Duration(milliseconds: 520), () {
        if (mounted) {
          setState(() => _overlayContent = 'results');
        }
      });
    }
    _retryCompleter = null;

    return true;
  }

  List<String> _detectSymbols(String dream) {
    final symbols = <String>[];
    final symbolMap = {
      'su': 'Su',
      'deniz': 'Su',
      'göl': 'Su',
      'uçmak': 'Uçmak',
      'uçuyordum': 'Uçmak',
      'düşmek': 'Düşmek',
      'düştüm': 'Düşmek',
      'ev': 'Ev',
      'oda': 'Ev',
      'araba': 'Araba',
      'köpek': 'Köpek',
      'kedi': 'Kedi',
      'yılan': 'Yılan',
      'ölüm': 'Ölüm',
      'öldüm': 'Ölüm',
      'bebek': 'Bebek',
      'çocuk': 'Bebek',
      'anne': 'Anne',
      'baba': 'Baba',
      'para': 'Para',
      'altın': 'Para',
      'ateş': 'Ateş',
      'yangın': 'Ateş',
      'diş': 'Diş',
    };

    symbolMap.forEach((key, value) {
      if (dream.contains(key) && !symbols.contains(value)) {
        symbols.add(value);
      }
    });

    return symbols.isEmpty ? [_l10n.dreamGeneral] : symbols;
  }

  List<String> _localizeSymbols(List<String> symbols) {
    if (_isTr) return symbols;
    const map = {
      'Su': 'Water',
      'Uçmak': 'Flying',
      'Düşmek': 'Falling',
      'Ev': 'Home',
      'Araba': 'Car',
      'Köpek': 'Dog',
      'Kedi': 'Cat',
      'Yılan': 'Snake',
      'Ölüm': 'Death',
      'Bebek': 'Baby',
      'Anne': 'Mother',
      'Baba': 'Father',
      'Para': 'Money',
      'Ateş': 'Fire',
      'Diş': 'Teeth',
    };
    return symbols.map((s) => map[s] ?? s).toList();
  }

  Emotion? _emotionFromStored(String? mood) {
    if (mood == null || mood.isEmpty) return null;
    try {
      return Emotion.values.firstWhere((e) => e.name == mood);
    } catch (_) {
      // Legacy labels (TR)
      switch (mood) {
        case 'Kaygılı':
          return Emotion.anxiety;
        case 'Korkmuş':
          return Emotion.fear;
        case 'Huzurlu':
          return Emotion.calm;
        case 'Mutlu':
          return Emotion.happiness;
        case 'Üzgün':
          return Emotion.sadness;
        case 'Belirsiz':
          return Emotion.confusion;
        default:
          return null;
      }
    }
  }

  // ESKİ SİSTEM METODLARI (Artık kullanılmıyor, bilimsel sistem aktif)
  // Geriye dönük uyumluluk için tutuldu, gerekirse silinebilir

  String _generateTitle(String text, List<String> symbols, Emotion? mood) {
    final lower = text.toLowerCase();
    // Öncelikle sembole göre
    if (symbols.contains('Su')) {
      return _trEn('Dalgalar ve Derinlik', 'Waves and Depth');
    }
    if (symbols.contains('Uçmak')) {
      return _trEn('Gökyüzüne Yolculuk', 'Journey to the Sky');
    }
    if (symbols.contains('Düşmek')) {
      return _trEn('Boşluğa Düşüş', 'Falling into the Void');
    }
    if (symbols.contains('Ev')) {
      return _trEn('Evin İçindeki Sırlar', 'Secrets Inside the Home');
    }
    if (symbols.contains('Yılan')) {
      return _trEn('Gizli Tehlike', 'Hidden Danger');
    }
    if (symbols.contains('Bebek')) {
      return _trEn('Yeni Başlangıç', 'New Beginning');
    }
    if (symbols.contains('Ateş')) {
      return _trEn('Alevlerin Arasında', 'Among the Flames');
    }
    if (symbols.contains('Para')) {
      return _trEn('Gizli Kazanç', 'Hidden Gain');
    }

    // İçerik anahtar kelime
    if (lower.contains('deniz') || lower.contains('okyanus')) {
      return _trEn('Sonsuz Deniz', 'Endless Sea');
    }
    if (lower.contains('uç') || lower.contains('kanat')) {
      return _trEn('Kanatlanan Yolculuk', 'Winged Journey');
    }
    if (lower.contains('karanlık')) {
      return _trEn('Karanlık Koridor', 'Dark Corridor');
    }
    if (lower.contains('ışık')) {
      return _trEn('Işığa Doğru', 'Toward the Light');
    }
    if (lower.contains('koş') || lower.contains('kovala')) {
      return _trEn('Peşindeki Adımlar', 'Footsteps Behind You');
    }

    // Mood'a göre yumuşak başlık
    if (mood == Emotion.calm || mood == Emotion.happiness) {
      return _trEn('Sakin Bir Gece', 'A Calm Night');
    }
    if (mood == Emotion.fear) {
      return _trEn('Gölgeden Gelen', 'From the Shadows');
    }
    if (mood == Emotion.sadness) {
      return _trEn('Sessiz Odalar', 'Silent Rooms');
    }
    if (mood == Emotion.confusion) {
      return _trEn('Tuhaf Sahne', 'Strange Scene');
    }

    // Varsayılan
    return _trEn('Gece Yolculuğu', 'Night Journey');
  }

  @override
  Widget build(BuildContext context) {
    final starsOpacity = _isTyping ? 0.22 : 0.35;
    final noiseOpacity = _isTyping ? 0.03 : 0.08;
    final backgroundGradient = _resolveBackgroundGradient();
    final bottomContentPadding = MediaQuery.of(context).padding.bottom + 24;

    return PopScope(
      canPop: !(_showAnalysisOverlay || _isWriting),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _closeWritingModal();
        }
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: const Color(0xFF0F162B),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(gradient: backgroundGradient),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: Opacity(
                    opacity: starsOpacity,
                    child: const StarsBackground(),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: Opacity(
                    opacity: noiseOpacity,
                    child: const _NoiseOverlay(),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(0.0, 0.45),
                        radius: 1.2,
                        colors: [
                          Color(0x4DF0D1DA),
                          Color(0x24F6E3D9),
                          Color(0x001E2A4D),
                        ],
                        stops: [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Opacity(
              opacity:
                  (_showAnalysisOverlay &&
                      (_overlayContent == 'results' ||
                          _overlayContent == 'analyzing'))
                  ? 0.0
                  : 1.0,
              child: IgnorePointer(
                ignoring:
                    (_showAnalysisOverlay &&
                    (_overlayContent == 'results' ||
                        _overlayContent == 'analyzing')),
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  behavior: HitTestBehavior.translucent,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      20,
                      MediaQuery.of(context).padding.top + 12,
                      20,
                      bottomContentPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                          child: Row(
                            children: [
                              GlassBackButton(),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      _l10n.dreamTitle,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColors.textWhite,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GuidanceBookletButton(
                                    dialogTitleTr: 'Rüya Rehberi',
                                    dialogTitleEn: 'Dream Guide',
                                    items: const [
                                      GuidanceItem(
                                        titleTr: 'Rüya Nedir?',
                                        titleEn: 'What Are Dreams?',
                                        descTr:
                                            'Rüyalar, beynin uyku sırasında anıları düzenlemesi, duyguları işlemesi ve bilinçaltı süreçleri aktif etmesidir. Bilimsel olarak REM uykusu sırasında oluşurlar.',
                                        descEn:
                                            'Dreams are the brain\'s way of organizing memories, processing emotions, and activating subconscious processes during sleep. They form during REM sleep.',
                                        icon: Icons.nights_stay_outlined,
                                      ),
                                      GuidanceItem(
                                        titleTr: 'Neden Rüya Yazmalıyız?',
                                        titleEn: 'Why Write Dreams?',
                                        descTr:
                                            'Rüya günlüğü tutmak, hatırlama yeteneğinizi güçlendirir ve bilinçaltınızdaki kalıpları görmenize yardımcı olur. Düzenli yazım, kendinizi daha iyi tanımanızı sağlar.',
                                        descEn:
                                            'Keeping a dream journal strengthens your recall ability and helps you see patterns in your subconscious. Regular writing helps you know yourself better.',
                                        icon: Icons.edit_note_outlined,
                                      ),
                                      GuidanceItem(
                                        titleTr: 'Duygu Seçimi Neden Önemli?',
                                        titleEn: 'Why Does Emotion Matter?',
                                        descTr:
                                            'Rüya sırasında hissettikleriniz, yorumun yönünü belirler. Aynı rüya farklı duygularla farklı anlamlar taşır. Duygu seçimi, analizi kişiselleştirir.',
                                        descEn:
                                            'What you felt during the dream shapes the interpretation. The same dream carries different meanings with different emotions. Emotion selection personalizes the analysis.',
                                        icon: Icons.psychology_outlined,
                                      ),
                                      GuidanceItem(
                                        titleTr: 'Semboller ve Arketipler',
                                        titleEn: 'Symbols and Archetypes',
                                        descTr:
                                            'Su, uçmak, düşmek, diş — bunlar evrensel rüya sembolleridir. Her biri bilinçaltının farklı mesajlarını taşır. Yorumlar bu sembolleri analiz eder.',
                                        descEn:
                                            'Water, flying, falling, teeth — these are universal dream symbols. Each carries different messages from the subconscious. Interpretations analyze these symbols.',
                                        icon: Icons.auto_stories_outlined,
                                      ),
                                      GuidanceItem(
                                        titleTr: 'Bilimsel Yaklaşım',
                                        titleEn: 'Scientific Approach',
                                        descTr:
                                            'Rüya analizi, psikolojik kuramlar (Freud, Jung) ve modern nörobilim bulgularını harmanlayarak yapılır. Kesin gelecek tahmini değil, zihinsel süreçlerinizi anlamanıza yardımcı olur.',
                                        descEn:
                                            'Dream analysis blends psychological theories (Freud, Jung) with modern neuroscience. It doesn\'t predict the future, but helps you understand your mental processes.',
                                        icon: Icons.science_outlined,
                                      ),
                                      GuidanceItem(
                                        titleTr: 'Tekrarlayan Rüyalar',
                                        titleEn: 'Recurring Dreams',
                                        descTr:
                                            'Aynı rüyayı tekrar görmek, çözülmemiş duygusal konulara işaret eder. Bu rüyaları takip etmek, iç dünyanızdaki kalıpları keşfetmenize yardımcı olur.',
                                        descEn:
                                            'Seeing the same dream repeatedly points to unresolved emotional issues. Tracking these dreams helps you discover patterns in your inner world.',
                                        icon: Icons.replay_outlined,
                                      ),
                                      GuidanceItem(
                                        titleTr: 'Rüya Dağılım Çizelgesi',
                                        titleEn: 'Dream Distribution Chart',
                                        descTr:
                                            'Analiz sonucundaki çizelge, rüyanızın duygusal yük, belirsizlik, yakın geçmiş ve beyin aktivitesi oranlarını gösterir. Bu, rüyanızın hangi kaynaklardan beslendiğini anlatır.',
                                        descEn:
                                            'The chart in the analysis shows emotional load, uncertainty, recent past, and brain activity ratios. This explains what feeds your dream.',
                                        icon: Icons.pie_chart_outline,
                                      ),
                                      GuidanceItem(
                                        titleTr: 'Gece ve Sabah Farkı',
                                        titleEn: 'Night vs Morning',
                                        descTr:
                                            'Sabah uyanır uyanmaz yazılan rüyalar daha detaylı hatırlanır. Gün içinde detaylar hızla kaybolur. En iyi zaman: uyandıktan sonraki ilk 5 dakika.',
                                        descEn:
                                            'Dreams written right after waking are remembered in more detail. Details fade quickly during the day. Best time: the first 5 minutes after waking.',
                                        icon: Icons.wb_sunny_outlined,
                                      ),
                                      GuidanceItem(
                                        titleTr: 'Rüya Güvenliğiniz',
                                        titleEn: 'Your Dream Privacy',
                                        descTr:
                                            'Yazdığınız rüyalar cihazınızda saklanır. Analiz sırasında yapay zeka ile paylaşılan metin, saklanmaz ve üçüncü taraflarla paylaşılmaz.',
                                        descEn:
                                            'Your written dreams are stored on your device. Text shared with AI during analysis is not stored and not shared with third parties.',
                                        icon: Icons.lock_outline,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  _buildTopBarCreditButton(),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Tabs
                        Row(
                          children: [
                            Expanded(
                              child: _TabButton(
                                label: _l10n.dreamTabNew,
                                isActive: _currentTab == 0,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _currentTab = 0);
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _TabButton(
                                label: _l10n.dreamTabHistory,
                                isActive: _currentTab == 1,
                                isPremium: true,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _currentTab = 1);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Content
                        _currentTab == 0
                            ? _buildNewDreamTab()
                            : _buildHistoryTab(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_showAnalysisOverlay || _isWriting)
              Positioned.fill(child: _buildUnifiedOverlay()),
            if (_activeMetric != null && _overlayContent == 'results')
              Positioned.fill(child: _buildMetricOverlay()),
          ],
        ),
      ),
    );
  }

  Widget _buildNewDreamTab() {
    final activeColors = [
      const Color(0xFFBBA8FF),
      const Color(0xFFC4B4FF),
      const Color(0xFFCCC0FF),
      const Color(0xFFD3CBFF),
      const Color(0xFFC5D6FF),
      const Color(0xFFB3E0FF),
      const Color(0xFFAAE5FF),
    ].map((c) => c.withOpacity(0.55)).toList();
    final halfColors = [
      const Color(0xFFCDBEFF),
      const Color(0xFFD4C8FF),
      const Color(0xFFDAD0FF),
      const Color(0xFFDFD9FF),
      const Color(0xFFD5E2FF),
      const Color(0xFFC8EAFF),
      const Color(0xFFC0EDFF),
    ].map((color) => color.withOpacity(0.38)).toList();
    final inactiveBaseColors = [
      const Color(0xFFC9B8FF),
      const Color(0xFFD2C4FF),
      const Color(0xFFDDD1FF),
      const Color(0xFFE7E0FF),
      const Color(0xFFDCE7FF),
      const Color(0xFFCFEFFF),
      const Color(0xFFC5F2FF),
    ];
    final inactiveColors = inactiveBaseColors
        .map((color) => color.withOpacity(0.45))
        .toList();

    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input Section - sade panel
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bilimsel rüya sözü
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      _currentDreamQuote,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textWhite70.withOpacity(0.8),
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AnimatedScale(
                  scale: _showDreamInputWarning ? 1.03 : 1.0,
                  duration: const Duration(milliseconds: 110),
                  curve: Curves.easeOut,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 130),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white.withOpacity(0.25)),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 22,
                    ),
                    child: TextField(
                      focusNode: _dreamFocusNode,
                      controller: _dreamController,
                      onTapOutside: (_) => _dreamFocusNode.unfocus(),
                      minLines: 7,
                      maxLines: 7,
                      style: const TextStyle(
                        color: AppColors.textWhite70,
                        fontSize: 13,
                        height: 1.5,
                      ),
                      decoration: InputDecoration(
                        hintText: _currentPrompt,
                        hintStyle: TextStyle(
                          color: AppColors.textWhite50,
                          fontSize: 13,
                          height: 1.6,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // Mood Section
                Column(
                  children: [
                    Center(
                      child: Text(
                        _l10n.dreamMoodQuestion,
                        style: TextStyle(
                          color: AppColors.textWhite70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedScale(
                      scale: _showMoodPulse ? 1.05 : 1.0,
                      duration: const Duration(milliseconds: 110),
                      curve: Curves.easeOut,
                      child: _buildMoodRail(),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Submit Buttons (Standard & Premium)
                ValueListenableBuilder<bool>(
                  valueListenable: _hasDreamTextNotifier,
                  builder: (context, hasDreamText, child) {
                    final hasEmotion = _selectedEmotion != null;
                    final isActive = hasDreamText && hasEmotion;
                    final isHalfActive =
                        (hasDreamText || hasEmotion) && !isActive;

                    Widget buildActionButton({
                      required String title,
                      required String subtitle,
                      required List<Color> activeGradients,
                      required List<Color> halfGradients,
                      required Color customGlowColor,
                      required VoidCallback onTap,
                      bool isPremium = false,
                      List<Gradient>? extraGradientLayers,
                    }) {
                      return GlassButton.custom(
                        width: double.infinity,
                        height: 56,
                        onTap: () async {
                          if (!hasDreamText) {
                            await _pulseDreamInputWarning();
                            return;
                          }
                          if (_selectedEmotion == null) {
                            await _pulseMoodRail();
                            return;
                          }
                          onTap();
                        },
                        useOwnLayer: true,
                        quality: GlassQuality.standard,
                        shape: const LiquidRoundedSuperellipse(
                          borderRadius: 24,
                        ),
                        interactionScale: 0.97,
                        stretch: 0.25,
                        resistance: 0.08,
                        glowColor: customGlowColor.withOpacity(
                          isActive ? 0.35 : (isHalfActive ? 0.25 : 0.15),
                        ),
                        glowRadius: isActive ? 1.8 : (isHalfActive ? 1.5 : 1.2),
                        settings: const LiquidGlassSettings(
                          thickness: 16,
                          blur: 1.2,
                          glassColor: Color(0x0BFFFFFF),
                          chromaticAberration: 0.08,
                          lightIntensity: 0.4,
                          ambientStrength: 0.5,
                          refractiveIndex: 1.45,
                          saturation: 1.0,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: isActive
                                          ? activeGradients
                                          : (isHalfActive
                                                ? halfGradients
                                                : inactiveColors),
                                      stops: const [
                                        0.0,
                                        0.22,
                                        0.36,
                                        0.5,
                                        0.64,
                                        0.78,
                                        1.0,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Ek gradient katmanları (mücevher efekti)
                              if (extraGradientLayers != null)
                                ...extraGradientLayers.map(
                                  (g) => Positioned.fill(
                                    child: AnimatedOpacity(
                                      opacity: (isActive || isHalfActive)
                                          ? 1.0
                                          : 0.0,
                                      duration: const Duration(
                                        milliseconds: 400,
                                      ),
                                      curve: Curves.easeInOut,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(gradient: g),
                                      ),
                                    ),
                                  ),
                                ),
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.white.withOpacity(0.22),
                                        Colors.white.withOpacity(0.03),
                                        Colors.white.withOpacity(0.0),
                                      ],
                                      stops: const [0.0, 0.4, 1.0],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.12),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      center: const Alignment(-0.85, -0.7),
                                      radius: 1.2,
                                      colors: [
                                        Colors.white.withOpacity(0.28),
                                        Colors.white.withOpacity(0.0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.18),
                                      width: 0.7,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                              ),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          title,
                                          style: const TextStyle(
                                            color: AppColors.textWhite,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        if (isPremium) ...[
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.diamond_outlined,
                                            size: 12,
                                            color: customGlowColor.withOpacity(
                                              0.8,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      subtitle,
                                      style: TextStyle(
                                        color: AppColors.textWhite70,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
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

                    // Kuzey Işıkları (Aurora Borealis)
                    final premiumActiveColors = List.filled(
                      7,
                      const Color(0xFF1A1535).withOpacity(0.25),
                    );
                    final premiumHalfColors = List.filled(
                      7,
                      const Color(0xFF1A1535).withOpacity(0.15),
                    );

                    // Aurora katmanları (yumuşak geçişli)
                    final gemLayers = <Gradient>[
                      // Aurora yeşili — ana dalga
                      RadialGradient(
                        center: const Alignment(-0.3, -0.2),
                        radius: 1.8,
                        colors: [
                          const Color(0xFF00E676).withOpacity(0.28),
                          const Color(0xFF00E676).withOpacity(0.12),
                          const Color(0xFF00E676).withOpacity(0.03),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.25, 0.55, 1.0],
                      ),
                      // Teal dalga — sağ
                      RadialGradient(
                        center: const Alignment(0.5, 0.0),
                        radius: 1.7,
                        colors: [
                          const Color(0xFF22D3EE).withOpacity(0.25),
                          const Color(0xFF22D3EE).withOpacity(0.10),
                          const Color(0xFF22D3EE).withOpacity(0.03),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.25, 0.55, 1.0],
                      ),
                      // Mor parıltı — sağ üst
                      RadialGradient(
                        center: const Alignment(0.6, -0.4),
                        radius: 1.5,
                        colors: [
                          const Color(0xFF7C3AED).withOpacity(0.28),
                          const Color(0xFF7C3AED).withOpacity(0.12),
                          const Color(0xFF7C3AED).withOpacity(0.03),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.25, 0.55, 1.0],
                      ),
                      // Yeşil-teal karışım — alt
                      RadialGradient(
                        center: const Alignment(0.0, 0.5),
                        radius: 1.6,
                        colors: [
                          const Color(0xFF2DD4BF).withOpacity(0.22),
                          const Color(0xFF2DD4BF).withOpacity(0.10),
                          const Color(0xFF2DD4BF).withOpacity(0.03),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.25, 0.55, 1.0],
                      ),
                      // Magenta dokunuş — sol alt
                      RadialGradient(
                        center: const Alignment(-0.5, 0.3),
                        radius: 1.2,
                        colors: [
                          const Color(0xFFD946EF).withOpacity(0.18),
                          const Color(0xFFD946EF).withOpacity(0.07),
                          const Color(0xFFD946EF).withOpacity(0.02),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.25, 0.55, 1.0],
                      ),
                      // İndigo derinlik — geniş
                      RadialGradient(
                        center: const Alignment(-0.6, -0.5),
                        radius: 1.8,
                        colors: [
                          const Color(0xFF4338CA).withOpacity(0.20),
                          const Color(0xFF4338CA).withOpacity(0.08),
                          const Color(0xFF4338CA).withOpacity(0.02),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.3, 0.6, 1.0],
                      ),
                    ];

                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: Row(
                        children: [
                          // Sol: Standart Yorum
                          Expanded(
                            child: buildActionButton(
                              title: _l10n.dreamAnalyzeButton,
                              subtitle: _l10n.dreamAnalyzeEstimate,
                              activeGradients: activeColors,
                              halfGradients: halfColors,
                              customGlowColor: const Color(0xFF7C6CF3),
                              onTap: () async {
                                await _interpretDream(); // normal
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Sağ: Premium Yorum
                          Expanded(
                            child: buildActionButton(
                              title: _isTr ? 'Derin Analiz' : 'Deep Analysis',
                              subtitle: _isTr
                                  ? 'Sırlarını keşfet'
                                  : 'Discover secrets',
                              activeGradients: premiumActiveColors,
                              halfGradients: premiumHalfColors,
                              customGlowColor: const Color(0xFF22D3EE),
                              isPremium: true,
                              extraGradientLayers: gemLayers,
                              onTap: () async {
                                await _interpretDreamPremium();
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 44),
                // ─── BİLGİLENDİRİCİ İPUCU ───
                _buildDreamTipsSection(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBarCreditButton() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primaryPurple.withOpacity(0.3),
              width: 0.6,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // NORMAL CREDIT HALF
              GestureDetector(
                onTap: _showDreamCreditPanel,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Builder(
                    builder: (_) {
                      int count;
                      bool hasCredit;
                      if (_isPremiumUser) {
                        count = _kMaxPremiumReads - _dreamPremiumReadsUsed;
                        hasCredit = count > 0;
                      } else {
                        count = !_dreamDailyFreeUsed ? 1 : _dreamAdCredits;
                        hasCredit = !_dreamDailyFreeUsed || _dreamAdCredits > 0;
                      }
                      return Row(
                        children: [
                          Icon(
                            Icons.nights_stay_rounded,
                            size: 13,
                            color: hasCredit
                                ? AppColors.primaryPurple.withOpacity(0.9)
                                : Colors.white.withOpacity(0.25),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$count',
                            style: TextStyle(
                              color: hasCredit
                                  ? AppColors.primaryPurple.withOpacity(0.9)
                                  : Colors.white.withOpacity(0.3),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // DIVIDER
              Container(
                width: 1,
                height: 20,
                color: Colors.white.withOpacity(0.15),
              ),

              // PREMIUM / SOUL STONE HALF
              GestureDetector(
                onTap: _showSoulStoneInfoPanel,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ValueListenableBuilder<int>(
                    valueListenable: StorageService.soulStonesNotifier,
                    builder: (_, stones, __) {
                      return Row(
                        children: [
                          Icon(
                            Icons.diamond_outlined,
                            size: 13,
                            color: stones > 0
                                ? const Color(0xFF22D3EE).withOpacity(0.9)
                                : Colors.white.withOpacity(0.25),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isPremiumUser ? '∞' : '$stones',
                            style: TextStyle(
                              color: stones > 0 || _isPremiumUser
                                  ? const Color(0xFF22D3EE).withOpacity(0.9)
                                  : Colors.white.withOpacity(0.3),
                              fontSize: _isPremiumUser ? 16 : 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDreamTipsSection() {
    final tips = _isTr
        ? [
            // Temel rüya bilimi
            'Tekrarlayan rüyalar, çözülmemiş duygusal bir konuya işaret edebilir.',
            'Rüya günlüğü tutmak, rüyalarını hatırlama yeteneğini güçlendirir.',
            'Ortalama bir insan ömrü boyunca yaklaşık 6 yılını rüya görerek geçirir.',
            'REM uykusu sırasında beyin, uyanıkken olduğu kadar aktiftir.',
            'Rüyada gördüğün yüzler genellikle hayatında bir noktada karşılaştığın kişilere aittir.',
            'Beyin, rüya sırasında günlük deneyimleri işler ve anıları pekiştirir.',
            'Lucid rüya, rüyada olduğunu fark edip yönlendirebilme durumudur.',
            'Stres ve kaygı düzeyi arttıkça kabus görme olasılığı da artar.',
            'Kör doğan insanlar görsel rüya görmez ama ses, dokunma ve koku ile rüya görür.',
            'Rüyalar genellikle uykunun REM evresinde gerçekleşir ve her biri 5-20 dakika sürer.',
            // Hafıza ve algı
            'Uykudan uyanır uyanmaz rüyanın %90\'ı ilk 10 dakikada unutulur.',
            'Siyah-beyaz rüya görmek, renkli televizyon öncesi nesilde daha yaygındı.',
            'Rüyada zaman algısı farklı çalışır — saatler sürmüş gibi hissedilen rüyalar dakikalar içinde olur.',
            'Dış dünyadan gelen sesler rüyanın içeriğine dahil olabilir.',
            'Hamile kadınlar, hormonal değişimler nedeniyle daha canlı ve yoğun rüyalar görür.',
            'Hayvanlar da rüya görür — köpeklerin REM uykusunda patilerini hareket ettirdiği gözlemlenmiştir.',
            'Rüyalar problem çözme yeteneğini artırabilir — birçok bilimsel keşif rüyada ilham almıştır.',
            'Gece boyunca 4-6 farklı rüya görürsün ama çoğunu hatırlamazsın.',
            'Düşme rüyaları genellikle güvensizlik veya kontrol kaybı hissiyle ilişkilidir.',
            'Beyin rüyada mantık filtrelerini devre dışı bırakır, bu yüzden rüyalar absürt olabilir.',
            // Nörobilim ve psikoloji
            'Rüyalar sırasında amigdala aktifleşir — bu yüzden rüyalarda duygular çok yoğun hissedilir.',
            'Beyin rüyada yeni sinaptik bağlantılar kurabilir, bu da yaratıcılığı destekler.',
            'Kabuslar aslında beynin tehlike simülasyonudur — seni olası tehditlere hazırlar.',
            'Rüyada okuduğun bir metin her baktığında değişir çünkü dil merkezi tam çalışmaz.',
            'Uyku felci, REM atonisi ile bilincin çakışmasından kaynaklanır ve zararsızdır.',
            'Çocuklar yetişkinlere göre daha sık kabus görür çünkü duygusal düzenleme gelişmektedir.',
            'Rüyalar sırasında prefrontal korteks baskılanır — bu yüzden eleştiri ve mantık azalır.',
            'Rüyada koşup da ilerleyememek, gerçek hayattaki çaresizlik hissini yansıtabilir.',
            'Bazı insanlar rüyada tat ve koku alabilir — bu çok nadir ama gerçek bir olgudur.',
            'Gündüz yaşanan yoğun duygular, gece rüyanın temasını belirleyebilir.',
            // İlginç gerçekler
            'Rüya sırasında yeni bir dil öğrenemezsin ama öğrendiğin bilgileri pekiştirebilirsin.',
            'Beynin rüya üretme sistemi tamamen kapatılamaz — uyuyan herkes bir şekilde rüya görür.',
            'Rüyada tanımadığın biri varsa, aslında geçmişte bir yerde gördüğün birinin yüzüdür.',
            'Bilim insanları bazı rüya içeriklerini beyin taramasıyla tahmin edebiliyor.',
            'Antik Mısır\'da rüyalar tanrısal mesajlar olarak kabul edilir ve tapınaklarda yorumlanırdı.',
            'Uykusuzluk arttıkça beyin, telafi için daha yoğun ve canlı rüyalar üretir.',
            'Rüyadaki duygular genellikle içerikten daha doğru hatırlanır.',
            'Uyandıktan sonra gözlerini kapatıp sabit kalmak, rüyayı hatırlama şansını artırır.',
            'Bazı kültürlerde rüyalar kolektif bilinçle bağlantılı kabul edilir.',
            'Yeni doğan bebekler günün %50\'sini REM uykusunda geçirir — muhtemelen rüya görerek.',
            // Uyku fizyolojisi
            'REM uykusunda göz kasları hariç tüm istemli kaslar felç olur — bu seni rüyanı yaşamaktan korur.',
            'Beyin rüya görürken oksijen tüketimini artırır, bu da enerji harcadığını gösterir.',
            'Uykunun ilk saatlerinde derin uyku, son saatlerinde ise daha uzun REM dönemleri baskındır.',
            'Alkol tüketimi REM uykusunu baskılar, bu yüzden alkol sonrası rüya hatırlama azalır.',
            'Kafein rüya kalitesini etkilemez ama uyku süresini kısaltarak REM dönemini azaltabilir.',
            'Melatonin hormonu sadece uykuyu düzenlemez, rüyaların canlılığını da artırabilir.',
            'Uyku apnesi olan kişiler REM döneminde daha sık uyanır ve rüyalarını daha iyi hatırlar.',
            'Vücut sıcaklığı düştükçe uyku derinleşir ve rüya üretimi artar.',
            // Rüya psikolojisi
            'Rüyada birine kızıyorsan, bu genellikle o kişiye değil kendine yönelik bastırılmış bir duyguyu temsil eder.',
            'Sınavda başarısız olma rüyası, gerçek sınavdan çok performans kaygısıyla ilgilidir.',
            'Rüyada kaybolmak, hayatta yön bulmakta zorlanma hissinin bir yansımasıdır.',
            'Rüyada dişlerin dökülmesi birçok kültürde kontrol kaybı ve güvensizlik sembolüdür.',
            'Rüyada çıplak kalmak, savunmasızlık ve yargılanma korkusuyla bağlantılıdır.',
            'Rüyada geç kalmak, fırsatları kaçırma veya hayatın hızına yetişememe kaygısını yansıtır.',
            'Mutlu rüyalar gören insanların gündüz duygusal dayanıklılığı daha yüksektir.',
            'Rüyada tanıdık bir mekânın farklı görünmesi, o yerle ilgili değişen duygularını yansıtabilir.',
            // Kültür ve tarih
            'Eski Yunan\'da Asclepius tapınaklarında hastalar rüya görerek şifa arardı.',
            'Avustralya Aborjinleri rüyaları "Düş Zamanı" olarak adlandırır ve yaradılış hikâyesiyle ilişkilendirir.',
            'Tibet Budizmi\'nde rüya yogası, bilinçli rüya görme pratiği olarak yüzyıllardır uygulanır.',
            'Orta Çağ Avrupa\'sında rüyalar kehanet aracı olarak kabul edilir ve kayıt altına alınırdı.',
            'Japon kültüründe yılbaşı gecesi görülen ilk rüya (hatsuyume) yılın gidişatını belirler.',
            'Freud rüyaları bilinçaltının kraliyet yolu olarak tanımladı.',
            'Jung\'a göre rüyalar, kolektif bilinçaltındaki arketiplerin yansımasıdır.',
            // Modern araştırmalar
            'Araştırmalar, rüya günlüğü tutan kişilerin duygusal farkındalığının arttığını gösteriyor.',
            'Bazı sporcular rüyada antrenman yaparak performanslarını artırabilir.',
            'Rüya sırasında beyin yeni fikirler üretebilir — periyodik tablo Mendeleev\'in rüyasında şekillendi.',
            'Müzisyenler rüyalarında sık sık müzik duyar — Paul McCartney "Yesterday" melodisini rüyada buldu.',
            'Bilim insanları rüya döneminde beynin bilgiyi kategorize ettiğini ve arşivlediğini keşfetti.',
            'Rüya terapisi, travma sonrası stres bozukluğu tedavisinde etkili bir yöntemdir.',
            'Korkutucu rüyalar gören kişilere uygulanan imaj provası terapisi kabusları %70 azaltabilir.',
            'Rüya sırasında beyin, günlük yaşamda fark etmediğin kalıpları ve bağlantıları keşfedebilir.',
            // Fizyolojik ilişkiler
            'Ağır yemek yemek rüya yoğunluğunu artırabilir çünkü metabolizma uykuyu etkiler.',
            'B6 vitamini alan kişilerin rüyalarını daha canlı ve detaylı hatırladığı raporlanmıştır.',
            'Egzersiz yapan kişiler daha kaliteli uyur ve daha düzenli rüya döngüsüne sahip olur.',
            'Rüya sırasında kalp atış hızı ve kan basıncı düzensizleşir, bu da rüyanın yoğunluğunu yansıtır.',
            'Bazı ilaçlar (antidepresanlar gibi) REM uykusunu baskılayarak rüya hatırlamayı azaltabilir.',
            'Nikotin bandı kullanan kişiler daha canlı ve garip rüyalar gördüğünü bildirmiştir.',
            'Yüksek rakımda uyumak oksijen düşüklüğü nedeniyle daha yoğun rüyalara neden olabilir.',
            'Gündüz uyuyanlar REM dönemine daha hızlı girer ve daha canlı rüyalar görebilir.',
          ]
        : [
            // Core dream science
            'Recurring dreams can signal an unresolved emotional issue.',
            'Keeping a dream journal strengthens your ability to recall dreams.',
            'The average person spends about 6 years of their life dreaming.',
            'During REM sleep, the brain is nearly as active as when you are awake.',
            'The faces you see in dreams usually belong to people you have encountered in real life.',
            'The brain processes daily experiences and consolidates memories during dreams.',
            'Lucid dreaming is when you become aware you are dreaming and can influence the dream.',
            'Higher stress and anxiety levels increase the likelihood of nightmares.',
            'People born blind do not have visual dreams but dream with sound, touch and smell.',
            'Dreams mostly occur during REM sleep and each one lasts about 5-20 minutes.',
            // Memory and perception
            'Within 10 minutes of waking, 90% of the dream is typically forgotten.',
            'Black-and-white dreams were more common in generations before color television.',
            'Time perception works differently in dreams — hours can feel like minutes.',
            'Sounds from the outside world can be incorporated into dream content.',
            'Pregnant women tend to have more vivid and intense dreams due to hormonal changes.',
            'Animals dream too — dogs have been observed moving their paws during REM sleep.',
            'Dreams can boost problem-solving — many scientific discoveries were inspired by dreams.',
            'You have 4-6 different dreams each night but rarely remember most of them.',
            'Falling dreams are often linked to feelings of insecurity or loss of control.',
            'The brain disables its logic filters during dreams, which is why they can seem absurd.',
            // Neuroscience and psychology
            'The amygdala is highly active during dreams — that is why emotions feel so intense.',
            'The brain can form new synaptic connections during dreams, fueling creativity.',
            'Nightmares are actually threat simulations — your brain rehearsing for danger.',
            'Text changes every time you look at it in a dream because the language center is suppressed.',
            'Sleep paralysis occurs when REM atonia overlaps with wakefulness and is harmless.',
            'Children have more nightmares than adults because emotional regulation is still developing.',
            'The prefrontal cortex is suppressed during dreaming, reducing logic and self-criticism.',
            'Being unable to run in a dream can reflect real-life feelings of helplessness.',
            'Some people can taste and smell in dreams — rare but a documented phenomenon.',
            'Intense daytime emotions can shape the theme of your dreams at night.',
            // Fascinating facts
            'You cannot learn a new language in a dream, but you can consolidate what you learned.',
            'The brain\'s dream-generation system cannot be fully shut off — everyone dreams.',
            'A stranger in your dream is actually a face your brain stored from a past encounter.',
            'Scientists can predict some dream content using brain scans.',
            'In ancient Egypt, dreams were considered divine messages and interpreted in temples.',
            'Sleep deprivation causes the brain to produce more vivid dreams as compensation.',
            'Dream emotions are usually remembered more accurately than dream content.',
            'Keeping your eyes closed and staying still after waking increases dream recall.',
            'Some cultures view dreams as connected to a collective consciousness.',
            'Newborns spend 50% of their sleep in REM — likely dreaming extensively.',
            // Sleep physiology
            'During REM sleep, all voluntary muscles except the eyes are paralyzed — this keeps you from acting out dreams.',
            'The brain increases oxygen consumption while dreaming, showing it is actively working.',
            'Deep sleep dominates early in the night while longer REM periods occur toward morning.',
            'Alcohol suppresses REM sleep, which is why dream recall drops after drinking.',
            'Caffeine does not affect dream quality but can shorten sleep duration, reducing REM time.',
            'Melatonin not only regulates sleep but can also make dreams more vivid.',
            'People with sleep apnea wake more often during REM and tend to remember dreams better.',
            'As body temperature drops, sleep deepens and dream production increases.',
            // Dream psychology
            'Being angry at someone in a dream often represents a suppressed emotion directed at yourself.',
            'Failing an exam in a dream is usually about performance anxiety, not the actual exam.',
            'Being lost in a dream reflects a feeling of struggling to find direction in life.',
            'Teeth falling out in dreams symbolizes loss of control and insecurity across many cultures.',
            'Being naked in a dream is linked to vulnerability and fear of being judged.',
            'Being late in a dream reflects anxiety about missing opportunities or keeping up with life.',
            'People who have happy dreams tend to show higher emotional resilience during the day.',
            'A familiar place looking different in a dream can reflect your changing feelings about it.',
            // Culture and history
            'In ancient Greece, patients would sleep in Asclepius temples hoping for healing dreams.',
            'Australian Aboriginals call dreams "Dreamtime" and link them to their creation story.',
            'Tibetan Buddhism has practiced dream yoga — conscious dreaming — for centuries.',
            'In medieval Europe, dreams were considered prophecy tools and were officially documented.',
            'In Japanese culture, the first dream of the new year (hatsuyume) foretells the year ahead.',
            'Freud described dreams as the royal road to the unconscious.',
            'Jung believed dreams reflect archetypes from the collective unconscious.',
            // Modern research
            'Studies show that keeping a dream journal increases emotional self-awareness.',
            'Some athletes improve their performance by mentally rehearsing in dreams.',
            'The brain can generate new ideas during dreams — the periodic table came to Mendeleev in a dream.',
            'Musicians often hear music in dreams — Paul McCartney discovered the melody for "Yesterday" in one.',
            'Scientists found that the brain categorizes and archives information during dreams.',
            'Dream therapy is an effective treatment for post-traumatic stress disorder.',
            'Imagery rehearsal therapy can reduce nightmares by up to 70% in people with frightening dreams.',
            'During dreams, the brain can discover patterns and connections you missed while awake.',
            // Physiological connections
            'Eating heavy meals can intensify dreams because metabolism affects sleep quality.',
            'People taking vitamin B6 have reported remembering dreams more vividly and in detail.',
            'Regular exercise leads to better sleep quality and a more consistent dream cycle.',
            'Heart rate and blood pressure become irregular during dreams, reflecting dream intensity.',
            'Some medications like antidepressants can suppress REM sleep and reduce dream recall.',
            'People using nicotine patches have reported more vivid and bizarre dreams.',
            'Sleeping at high altitude can cause more intense dreams due to lower oxygen levels.',
            'Daytime nappers enter REM faster and may experience more vivid dreams.',
          ];

    final tipIndex = _currentTipIndex % tips.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF7C6CF3).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome,
                color: Color(0xFFB8A8FF),
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isTr ? 'Biliyor muydun?' : 'Did you know?',
                  style: TextStyle(
                    color: const Color(0xFFB8A8FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tips[tipIndex],
                  style: TextStyle(
                    color: AppColors.textWhite70.withOpacity(0.85),
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _resolveEmotionAccentColor(Emotion? emotion) {
    switch (emotion) {
      case Emotion.anxiety:
        return AppColors.primaryPurple;
      case Emotion.fear:
        return AppColors.primaryPink;
      case Emotion.calm:
        return AppColors.primaryTeal;
      case Emotion.happiness:
        return AppColors.primaryOrange;
      case Emotion.sadness:
        return const Color(0xFF5C7CFF);
      case Emotion.confusion:
        return AppColors.textGrey;
      default:
        return AppColors.primaryPurple;
    }
  }

  void _completeAnalysisAnswers(List<ClarificationAnswer> answers) {
    final completer = _answersCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(answers);
    }
  }

  void _handleAnalysisRetry() {
    final completer = _retryCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
    if (mounted) {
      setState(() {
        _analysisOverlayVisible = false;
        _showAnalysisOverlay = false;
      });
    }
    _answersCompleter = null;
    _retryCompleter = null;
  }

  Widget _buildUnifiedOverlay() {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Dismissible(
      key: const Key('unified_overlay_dismissible'),
      direction: DismissDirection.startToEnd, // Sadece sağa kaydırarak kapatma
      resizeDuration:
          null, // Önemli: Stack içinde Positioned olduğundan boyutunu küçültmeye çalışmasını engeller
      onDismissed: (_) {
        _closeWritingModal(instant: true);
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: _analysisOverlayVisible ? 1.0 : 0.0),
        duration: const Duration(
          milliseconds: 1000,
        ), // Yumu\u015fak a\u00e7\u0131l\u0131\u015f
        curve: Curves.easeOutCubic,
        builder: (context, animValue, child) {
          return ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 20 * animValue,
                sigmaY: 20 * animValue,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromRGBO(0, 0, 0, 0.2 * animValue),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
                child: Opacity(
                  opacity: animValue,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.15),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _overlayContent == 'analyzing'
                        ? _buildAnalysisContent(
                            key: const ValueKey('analyzing'),
                          )
                        : _overlayContent == 'results'
                        ? (_isPremiumResult && _deepAnalysisResult != null
                              ? _buildPremiumResultContent(
                                  key: const ValueKey('premium_results'),
                                  topPadding: topPadding,
                                  bottomPadding: bottomPadding,
                                )
                              : _buildInterpretationContent(
                                  key: const ValueKey('results'),
                                  topPadding: topPadding,
                                  bottomPadding: bottomPadding,
                                ))
                        : const SizedBox.shrink(key: ValueKey('gap')),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnalysisContent({Key? key}) {
    return Center(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: _AnalysisDialog(
          randomMessage: _overlayRandomMessage,
          questions: _overlayQuestions,
          showNotAnalyzable: _overlayShowNotAnalyzable,
          notAnalyzableMessage: _overlayNotAnalyzableMessage,
          accentColor: _overlayAccentColor,
          onComplete: _completeAnalysisAnswers,
          onRetry: _handleAnalysisRetry,
        ),
      ),
    );
  }

  Widget _buildInterpretationContent({
    Key? key,
    required double topPadding,
    required double bottomPadding,
  }) {
    final interpretation = _generalAnalysis.trim();
    final sections = _parseInterpretationSections(interpretation);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (_activeMetric != null) {
          _dismissMetricOverlay();
        }
        return false; // Don't consume
      },
      child: CustomScrollView(
        key: key,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 16),
              child: Row(
                children: [
                  GlassBackButton(onTap: _closeWritingModal),
                  Expanded(
                    child: Center(
                      child: Text(
                        _l10n.dreamInterpretationTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 38),
                ],
              ),
            ),
          ),
          // Chart
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: _HolographicBrainWidget(metrics: _computeChartMetrics()),
            ),
          ),
          // Legend
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: KeyedSubtree(
                key: _legendKey,
                child: _ChartLegend(
                  selected: _activeMetric,
                  onSelect: _handleMetricSelect,
                ),
              ),
            ),
          ),
          // Cards
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding + 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                _buildInterpretationCards(sections),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // PREMIUM DERİN ANALİZ SONUÇ UI (KLİNİK-LAB TASARIMI KUKLA VERİ)
  // ────────────────────────────────────────────────────────

  Widget _buildPremiumResultContent({
    Key? key,
    required double topPadding,
    required double bottomPadding,
  }) {
    final isTr = _isTr;

    return Stack(
      children: [
        CustomScrollView(
          key: key,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // ── 1) Üst Bar ve Girdi Bağlamı ──
            SliverToBoxAdapter(
              child: _PremiumReveal(
                index: 0,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, topPadding + 40, 20, 16),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          isTr
                              ? 'NÖRO-PSİKOLOJİK ANALİZ'
                              : 'NEURO-PSYCH ANALYSIS',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── 1.5) Yazılan Rüya ve Seçilen Duygu ──
            if (_isFromHistory)
              SliverToBoxAdapter(
                child: _PremiumReveal(
                  index: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                color: Colors.white.withOpacity(0.5),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isTr ? 'RÜYANIZ' : 'YOUR DREAM',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const Spacer(),
                              if (_selectedEmotion != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _resolveEmotionAccentColor(
                                      _selectedEmotion!,
                                    ).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    _selectedEmotion!.label,
                                    style: TextStyle(
                                      color: _resolveEmotionAccentColor(
                                        _selectedEmotion!,
                                      ),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _dreamController.text,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 13,
                              height: 1.7,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // ── 2) Ana Sonuç Kartı (Katman 1) ──
            SliverToBoxAdapter(
              child: _PremiumReveal(
                index: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: _ClinicalMainThemeCard(
                    isTr: isTr,
                    title: _deepAnalysisResult!.title,
                    summary: _deepAnalysisResult!.subconsciousMap.summary,
                    uncertainty: _deepAnalysisResult!.distribution.uncertainty,
                  ),
                ),
              ),
            ),

            // ── 3) Hızlı Bulgular / Ciddi Metrikler ──
            SliverToBoxAdapter(
              child: _PremiumReveal(
                index: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: _ClinicalMetricsPanel(
                    isTr: isTr,
                    distribution: _deepAnalysisResult!.distribution,
                  ),
                ),
              ),
            ),

            // ── 4) Kanıta Dayalı Bulgular "Bu sonuca neden vardık?" (Katman 2) ──
            SliverToBoxAdapter(
              child: _PremiumReveal(
                index: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ), // Yumuşak uçtan uca kaydırma için iç padding kullanıldı
                  child: _ClinicalEvidenceSection(
                    isTr: isTr,
                    analysis: _deepAnalysisResult!,
                  ),
                ),
              ),
            ),

            // ── 4.5) Analizi Netleştiren Yanıtlar (Soru-Cevap) ──
            if (_premiumAnswers.isNotEmpty)
              SliverToBoxAdapter(
                child: _PremiumReveal(
                  index: 4,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: _ClinicalAnswersSection(
                      isTr: isTr,
                      answers: _premiumAnswers,
                      insights: _deepAnalysisResult!.clarifyingInsights,
                      globalInsight:
                          _deepAnalysisResult!.shadowSelf.answerInsight,
                    ),
                  ),
                ),
              ),

            // ── 5) Açılır Detaylar (Akordeon) (Katman 3) ──
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _ClinicalAccordion(
                    title: isTr ? 'Duygusal Profil' : 'Emotional Profile',
                    subtitle: isTr
                        ? 'Rüya sırasındaki psikolojik katmanlarınız'
                        : 'Psychological layers during the dream',
                    icon: Icons.waves,
                    content: _deepAnalysisResult!.emotionalLayers.synthesis,
                  ),
                  if (_deepAnalysisResult!.shadowSelf.revealed.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _ClinicalAccordion(
                      title: isTr ? 'Gölge Benlik' : 'Shadow Self',
                      subtitle: isTr
                          ? 'Bastırdığınız ve yüzleşmekten kaçındığınız yönler'
                          : 'Suppressed and unexamined aspects of the subconscious',
                      icon: Icons.person_off_outlined,
                      content:
                          '${_deepAnalysisResult!.shadowSelf.revealed}\n\n${_deepAnalysisResult!.shadowSelf.answerInsight}',
                    ),
                  ],
                  if (_deepAnalysisResult!
                      .recurringPattern
                      .description
                      .isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _ClinicalAccordion(
                      title: isTr
                          ? 'Kalıplar ve Davranışlar'
                          : 'Recurring Patterns',
                      subtitle: isTr
                          ? 'Hayatınızda sürekli tekrar eden psikolojik döngüler'
                          : 'Recurring loops and psychological blockages',
                      icon: Icons.replay,
                      content:
                          '${_deepAnalysisResult!.recurringPattern.description}\n\n${isTr ? "Öneri:" : "Hint:"} ${_deepAnalysisResult!.recurringPattern.resolutionHint}',
                    ),
                  ],
                  if (_deepAnalysisResult!.ritual.action.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _ClinicalAccordion(
                      title: isTr
                          ? 'Önerilen Ritüel: ${_deepAnalysisResult!.ritual.title}'
                          : 'Suggested Ritual: ${_deepAnalysisResult!.ritual.title}',
                      subtitle: isTr
                          ? 'Bu rüyanın etkisini yönetmek için size özel eylem'
                          : 'A specialized action to manage this dream\'s impact',
                      icon: Icons.self_improvement,
                      content:
                          '${_deepAnalysisResult!.ritual.action}\n\n${isTr ? "Bilimsel Not:" : "Science Note:"} ${_deepAnalysisResult!.ritual.scienceNote}',
                    ),
                  ],
                ]),
              ),
            ),

            // ── 6) Yansıtma Sorusu (Etkileşim) ──
            if (_deepAnalysisResult!.reflectionQuestion.isNotEmpty)
              SliverToBoxAdapter(
                child: _PremiumReveal(
                  index: 6,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: _ClinicalReflectionQuestion(
                      isTr: isTr,
                      questionText: _deepAnalysisResult!.reflectionQuestion,
                      reflectionResponses:
                          _deepAnalysisResult!.reflectionResponses,
                      initialSelectedAction: _selectedReflectionAction,
                      onAnswerSelected: (val) async {
                        if (mounted) {
                          setState(() {
                            _selectedReflectionAction = val;
                          });
                          if (_isDreamSaved && _currentDreamId != null) {
                            try {
                              _historyKeyTracker++;
                              await StorageService.saveDream({
                                'id': _currentDreamId,
                                'isPremium': true,
                                'title': _deepAnalysisResult!.title,
                                'text': _dreamController.text,
                                'emotion': _selectedEmotion?.name,
                                'date': DateTime.now().toIso8601String(),
                                'premiumAnswers': jsonEncode(_premiumAnswers),
                                'premiumData': jsonEncode(
                                  _deepAnalysisResult!.rawJson,
                                ),
                                'reflectionAction': _selectedReflectionAction,
                              });
                            } catch (e) {
                              debugPrint('Upsert error: $e');
                            }
                          }
                        }
                      },
                    ),
                  ),
                ),
              ),

            // ── 6.5) Rüyayı Kaydet Butonu ──
            if (!_isFromHistory && _deepAnalysisResult != null)
              SliverToBoxAdapter(
                child: _PremiumReveal(
                  index: 7,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(40, 24, 40, 0),
                    child: _AnimatedBounceButton(
                      onTap: _isDreamSaved
                          ? null
                          : () async {
                              setState(() {
                                _isDreamSaved = true;
                                _historyKeyTracker++;
                              });
                              try {
                                final now = DateTime.now().toIso8601String();
                                _currentDreamId ??= DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString();
                                await StorageService.saveDream({
                                  'id': _currentDreamId,
                                  'isPremium': true,
                                  'title': _deepAnalysisResult!.title,
                                  'text': _dreamController.text,
                                  'emotion': _selectedEmotion?.name,
                                  'date': now,
                                  'premiumAnswers': jsonEncode(_premiumAnswers),
                                  'premiumData': jsonEncode(
                                    _deepAnalysisResult!.rawJson,
                                  ),
                                  'reflectionAction': _selectedReflectionAction,
                                });
                                await StorageService.setDreamDoneToday();
                              } catch (e) {
                                debugPrint('Error saving dream: $e');
                                if (mounted)
                                  setState(() => _isDreamSaved = false);
                              }
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _isDreamSaved
                                ? Colors.green.withOpacity(0.3)
                                : Colors.white.withOpacity(
                                    0.2,
                                  ), // Mor yerine beyaz
                            width: 1,
                          ),
                          gradient: LinearGradient(
                            colors: [
                              _isDreamSaved
                                  ? Colors.green.withOpacity(0.15)
                                  : Colors.white.withOpacity(
                                      0.08,
                                    ), // Mor yerine beyaz gradyan
                              _isDreamSaved
                                  ? Colors.green.withOpacity(0.02)
                                  : Colors.white.withOpacity(0.01),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isDreamSaved
                                  ? Icons.check_circle
                                  : Icons.bookmark_add_rounded,
                              color: _isDreamSaved
                                  ? Colors.greenAccent
                                  : Colors.white.withOpacity(0.9), // Açık beyaz
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isDreamSaved
                                  ? (isTr ? 'KAYDEDİLDİ' : 'SAVED')
                                  : (isTr ? 'RÜYAYI KAYDET' : 'SAVE DREAM'),
                              style: TextStyle(
                                color: _isDreamSaved
                                    ? Colors.greenAccent
                                    : Colors.white.withOpacity(
                                        0.9,
                                      ), // Açık beyaz
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // ── 7) Yeni Rüya Yaz Butonu (Kapatma) ──
            SliverToBoxAdapter(
              child: _PremiumReveal(
                index: 7,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(40, 8, 40, bottomPadding + 80),
                  child: _AnimatedBounceButton(
                    onTap: () {
                      // Formu sıfırla ve input ekranına dön
                      setState(() {
                        _dreamController.clear();
                        _selectedEmotion = null;
                        _deepAnalysisResult = null;
                        _isPremiumResult = false;
                        _isFromHistory = false;
                        _isDreamSaved = false;
                        _currentDreamId = null;
                        _selectedReflectionAction = null;
                        _premiumAnswers = [];
                        _currentTab =
                            0; // Kullanıcıyı Yeni Rüya Tab'ine atıyoruz
                      });
                      _closeWritingModal(instant: true);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 1,
                        ),
                        color: Colors.white.withOpacity(0.05),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit_note,
                            color: Colors.white.withOpacity(0.6),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isTr ? 'Yeni Bir Rüya Yaz' : 'Write a New Dream',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // Sabit Geri Dönüş Butonu — her zaman üstte
        Positioned(
          top: topPadding + 16,
          left: 16,
          child: GlassBackButton(onTap: _closeWritingModal),
        ),
      ],
    );
  }

  // == İÇ YAPILAR (MOCK) ==

  List<_ClarificationQuestion> _buildClarificationQuestions(
    DreamAnalysis analysis,
    Emotion emotion,
  ) {
    final questions = <_ClarificationQuestion>[];

    if (analysis.hasThreat) {
      questions.add(
        _ClarificationQuestion(id: 'threat', text: _l10n.dreamClarifyThreat),
      );
    }

    if (analysis.hasPastReference) {
      questions.add(
        _ClarificationQuestion(id: 'past', text: _l10n.dreamClarifyFamiliar),
      );
    }

    if (questions.isEmpty && analysis.hasMovement) {
      questions.add(
        _ClarificationQuestion(id: 'movement', text: _l10n.dreamClarifyEscape),
      );
    }

    if (questions.isEmpty &&
        (emotion == Emotion.anxiety || emotion == Emotion.fear)) {
      questions.add(
        _ClarificationQuestion(id: 'threat', text: _l10n.dreamClarifyAnxious),
      );
    }

    return questions.take(2).toList();
  }

  void _handleMetricSelect(_MetricType metric, Offset globalPosition) {
    final box = context.findRenderObject() as RenderBox?;
    setState(() {
      if (_activeMetric == metric) {
        _activeMetric = null;
        _metricTapOrigin = null;
      } else {
        _activeMetric = metric;
        // Tıklanan pozisyonu kaydet (local koordinat)
        _metricTapOrigin = box?.globalToLocal(globalPosition);
      }
    });
  }

  void _dismissMetricOverlay() {
    if (_activeMetric == null) {
      return;
    }
    setState(() {
      _activeMetric = null;
    });
  }

  Widget _buildMetricOverlay() {
    final metric = _activeMetric!;
    final size = MediaQuery.of(context).size;
    const panelHeight = 104.0;

    // Panel her zaman yatayda ortada
    final left = (size.width - _metricPanelWidth) / 2;

    // Legend'ın üstünde sabit bir konum hesapla
    final legendBox =
        _legendKey.currentContext?.findRenderObject() as RenderBox?;
    double top;
    if (legendBox != null) {
      final legendGlobal = legendBox.localToGlobal(Offset.zero);
      // Legend'ın hemen üstünde
      top = legendGlobal.dy - panelHeight + 5;
    } else {
      // Fallback: ekranın üst kısmında
      top = 200.0;
    }
    top = top.clamp(60.0, size.height - panelHeight - 24.0);

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        _overlayPointerDown = event.position;
      },
      onPointerUp: (event) {
        final downPos = _overlayPointerDown;
        _overlayPointerDown = null;
        if (downPos != null) {
          final distance = (event.position - downPos).distance;
          // Eğer çok az hareket ettiyse tap olarak say (scroll değil)
          if (distance < 20) {
            _handleOverlayTap(event.position);
          }
        }
      },
      child: Stack(
        children: [
          // Panel
          TweenAnimationBuilder<double>(
            key: ValueKey(metric),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutQuart,
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, t, child) {
              // Başlangıç pozisyonu (tıklanan yer)
              final origin = _metricTapOrigin ?? Offset(left, top);
              // Hedef pozisyon
              final targetLeft = left;
              final targetTop = top;
              // Daha yumuşak ease curve
              final smoothT = Curves.easeOut.transform(t);
              // Lerp ile ara pozisyon
              final currentLeft =
                  origin.dx + (targetLeft - origin.dx) * smoothT;
              final currentTop = origin.dy + (targetTop - origin.dy) * smoothT;
              // Scale ve opacity - daha yumuşak başlangıç
              final scale = 0.5 + (0.5 * smoothT);
              final opacity = (t * 1.5).clamp(
                0.0,
                1.0,
              ); // Opacity daha hızlı tam oluyor

              return Positioned(
                left: currentLeft - (_metricPanelWidth / 2) * (1 - t),
                top: currentTop - (panelHeight * (1 - t)),
                width: _metricPanelWidth,
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.bottomCenter,
                  child: Opacity(opacity: opacity, child: child),
                ),
              );
            },
            child: GestureDetector(
              onTap: _dismissMetricOverlay,
              child: _MetricDescriptionCard(body: _metricDescription(metric)),
            ),
          ),
        ],
      ),
    );
  }

  void _handleOverlayTap(Offset globalPosition) {
    final rootBox = context.findRenderObject() as RenderBox?;
    final legendBox =
        _legendKey.currentContext?.findRenderObject() as RenderBox?;
    if (rootBox == null || legendBox == null) {
      _dismissMetricOverlay();
      return;
    }
    final legendGlobal = legendBox.localToGlobal(Offset.zero);
    final legendRect = Rect.fromLTWH(
      legendGlobal.dx,
      legendGlobal.dy,
      legendBox.size.width,
      legendBox.size.height,
    );

    if (legendRect.contains(globalPosition)) {
      final tx = (globalPosition.dx - legendGlobal.dx) / legendBox.size.width;
      final ty = (globalPosition.dy - legendGlobal.dy) / legendBox.size.height;
      final metric = _metricForLegendPosition(tx, ty);
      setState(() {
        _activeMetric = metric;
        _metricTapOrigin = rootBox.globalToLocal(globalPosition);
      });
      return;
    }

    _dismissMetricOverlay();
  }

  /// Legend 2 sütun ve 2 satır:
  /// Sol üst: emotionalLoad, Sol alt: uncertainty
  /// Sağ üst: recentPast, Sağ alt: brainActivity
  _MetricType _metricForLegendPosition(double tx, double ty) {
    final isRight = tx > 0.5;
    final isBottom = ty > 0.5;
    if (isRight) {
      return isBottom ? _MetricType.brainActivity : _MetricType.recentPast;
    } else {
      return isBottom ? _MetricType.uncertainty : _MetricType.emotionalLoad;
    }
  }

  _DreamMetrics _computeChartMetrics() {
    // API'den distribution geldiyse kullan
    final d = _apiDistribution;
    if (d.emotionalLoad > 0 ||
        d.uncertainty > 0 ||
        d.recentMemoryEffect > 0 ||
        d.brainActivity > 0) {
      return _DreamMetrics(
        duygusal: d.emotionalLoad.toDouble(),
        belirsizlik: d.uncertainty.toDouble(),
        yakinGecmis: d.recentMemoryEffect.toDouble(),
        beyinAkt: d.brainActivity.toDouble(),
      );
    }

    // Lokal fallback
    final emotion = _selectedEmotion;
    final analysis = _latestAnalysis;
    if (analysis == null || emotion == null) {
      return _fallbackMetrics(emotion);
    }

    final threat = _resolveClarification('threat', analysis.hasThreat);
    final past = _resolveClarification('past', analysis.hasPastReference);
    final movement = _resolveClarification('movement', analysis.hasMovement);

    var duygusal = 20.0 + _emotionLoadBoost(emotion) + (threat ? 10.0 : 0.0);
    var belirsizlik =
        16.0 + (!analysis.isSingleScene ? 8.0 : 0.0) + (movement ? 4.0 : 0.0);
    if (emotion == Emotion.confusion) {
      belirsizlik += 10.0;
    } else if (emotion == Emotion.anxiety) {
      belirsizlik += 6.0;
    }
    var yakinGecmis = 16.0 + (past ? 20.0 : 0.0);
    var beyinAkt =
        18.0 + (movement ? 12.0 : 0.0) + (!analysis.isSingleScene ? 4.0 : 0.0);

    return _normalizeMetrics(
      _DreamMetrics(
        duygusal: duygusal,
        belirsizlik: belirsizlik,
        yakinGecmis: yakinGecmis,
        beyinAkt: beyinAkt,
      ),
    );
  }

  bool _resolveClarification(String id, bool baseValue) {
    for (final answer in _latestClarifications) {
      if (answer.questionId != id) continue;
      if (answer.answer == 'yes') return true;
      if (answer.answer == 'no') return false;
    }
    return baseValue;
  }

  double _emotionLoadBoost(Emotion emotion) {
    switch (emotion) {
      case Emotion.anxiety:
        return 16;
      case Emotion.fear:
        return 18;
      case Emotion.sadness:
        return 14;
      case Emotion.confusion:
        return 10;
      case Emotion.happiness:
        return 8;
      case Emotion.calm:
        return 6;
    }
  }

  _DreamMetrics _normalizeMetrics(_DreamMetrics raw) {
    final total =
        raw.duygusal + raw.belirsizlik + raw.yakinGecmis + raw.beyinAkt;
    if (total <= 0) {
      return raw;
    }
    final scale = 100.0 / total;
    return _DreamMetrics(
      duygusal: raw.duygusal * scale,
      belirsizlik: raw.belirsizlik * scale,
      yakinGecmis: raw.yakinGecmis * scale,
      beyinAkt: raw.beyinAkt * scale,
    );
  }

  _DreamMetrics _fallbackMetrics(Emotion? emotion) {
    switch (emotion) {
      case Emotion.anxiety:
        return const _DreamMetrics(
          duygusal: 35,
          belirsizlik: 20,
          yakinGecmis: 30,
          beyinAkt: 15,
        );
      case Emotion.fear:
        return const _DreamMetrics(
          duygusal: 40,
          belirsizlik: 20,
          yakinGecmis: 25,
          beyinAkt: 15,
        );
      case Emotion.calm:
        return const _DreamMetrics(
          duygusal: 20,
          belirsizlik: 15,
          yakinGecmis: 30,
          beyinAkt: 35,
        );
      case Emotion.happiness:
        return const _DreamMetrics(
          duygusal: 25,
          belirsizlik: 15,
          yakinGecmis: 25,
          beyinAkt: 35,
        );
      case Emotion.sadness:
        return const _DreamMetrics(
          duygusal: 35,
          belirsizlik: 20,
          yakinGecmis: 30,
          beyinAkt: 15,
        );
      case Emotion.confusion:
        return const _DreamMetrics(
          duygusal: 25,
          belirsizlik: 35,
          yakinGecmis: 20,
          beyinAkt: 20,
        );
      default:
        return const _DreamMetrics(
          duygusal: 30,
          belirsizlik: 20,
          yakinGecmis: 25,
          beyinAkt: 25,
        );
    }
  }

  LinearGradient _resolveBackgroundGradient() {
    switch (_selectedEmotion) {
      case Emotion.anxiety:
        return _anxietyDreamGradient;
      case Emotion.fear:
        return _fearDreamGradient;
      case Emotion.calm:
        return _calmDreamGradient;
      case Emotion.happiness:
        return _happinessDreamGradient;
      case Emotion.sadness:
        return _sadnessDreamGradient;
      case Emotion.confusion:
        return _uncertainDreamGradient;
      default:
        return _morningDreamGradient;
    }
  }

  Widget _buildMoodRail() {
    // Emotion enum'dan duygu listesini al
    final emotions = _emotionOrder;

    return LayoutBuilder(
      builder: (context, constraints) {
        void selectByDx(double dx) {
          final itemWidth = constraints.maxWidth / emotions.length;
          final index = (dx / itemWidth).clamp(0, emotions.length - 1).floor();
          final emotion = emotions[index];
          if (_selectedEmotion != emotion) {
            setState(() {
              _selectedEmotion = emotion;
              _selectedMood = emotion.name; // Backward compatibility
            });
          }
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) => selectByDx(details.localPosition.dx),
          onHorizontalDragStart: (details) =>
              selectByDx(details.localPosition.dx),
          onHorizontalDragUpdate: (details) =>
              selectByDx(details.localPosition.dx),
          onHorizontalDragEnd: (_) {},
          child: Column(
            children: [
              SizedBox(
                height: 20,
                child: Row(
                  children: emotions.map((emotion) {
                    final label = _emotionLabel(emotion);
                    final isSelected = _selectedEmotion == emotion;
                    final baseStyle = TextStyle(
                      color: isSelected
                          ? Colors.white.withOpacity(0.95)
                          : Colors.white.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    );
                    final itemWidth = constraints.maxWidth / emotions.length;
                    final painter = TextPainter(
                      text: TextSpan(text: label, style: baseStyle),
                      textDirection: TextDirection.ltr,
                    )..layout();
                    final available = itemWidth - 4;
                    final targetScale = isSelected && painter.width > available
                        ? (available / painter.width).clamp(0.85, 1.0)
                        : 1.0;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      width: itemWidth,
                      child: Center(
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOut,
                          tween: Tween<double>(begin: 1.0, end: targetScale),
                          builder: (context, scaleX, child) {
                            return AnimatedScale(
                              scale: isSelected ? 1.08 : 1.0,
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOut,
                              child: Transform.scale(
                                scaleX: scaleX,
                                scaleY: 1.0,
                                alignment: Alignment.center,
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            label,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.visible,
                            textAlign: TextAlign.center,
                            style: baseStyle,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 18,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Row(
                      children: emotions.map((emotion) {
                        final isSelected = _selectedEmotion == emotion;
                        final size = isSelected ? 10.0 : 6.0;
                        final width = constraints.maxWidth / emotions.length;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOut,
                          width: width,
                          child: Center(
                            child: AnimatedScale(
                              scale: isSelected ? 1.35 : 1.0,
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOut,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.easeOut,
                                width: size,
                                height: size,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.85)
                                      : Colors.white.withOpacity(0.35),
                                  shape: BoxShape.circle,
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(
                                              0.4,
                                            ),
                                            blurRadius: 6,
                                            spreadRadius: 1,
                                          ),
                                          BoxShadow(
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
                                            blurRadius: 12,
                                            spreadRadius: 3,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      key: ValueKey(_historyKeyTracker),
      future: StorageService.getDreams(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryPurple),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  _l10n.dreamNoHistory,
                  style: TextStyle(
                    color: AppColors.textWhite50,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final dream = snapshot.data![index];
            final title = (dream['title'] ?? '').toString().trim();
            final dateStr = dream['date']?.toString() ?? '';
            final formatted = _formatDate(dateStr);
            final shortDate = _formatShortDate(dateStr);
            final isPremium = dream['isPremium'] == true;
            final emotionName =
                dream['emotion']?.toString() ?? dream['mood']?.toString();
            final emotionEnum = _resolveDreamEmotion(dream);
            final emotionColor = _resolveEmotionAccentColor(emotionEnum);

            String emotionLabelValue = shortDate;
            if (emotionName != null) {
              final parsed = _emotionFromStored(emotionName);
              emotionLabelValue = parsed != null
                  ? _emotionLabel(parsed)
                  : emotionName;
            }

            return _AnimatedBounceButton(
              onTap: () => _showDreamDetail(dream),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.01),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.transparent),
                      ),
                      child: Icon(
                        _resolveDreamIcon(title),
                        color: Colors.white.withOpacity(0.7),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.isNotEmpty
                                ? title
                                : (_isTr ? 'Gizemli Rüya' : 'Mysterious Dream'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatted,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (emotionName != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Text(
                          emotionLabelValue,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      )
                    else
                      Text(
                        shortDate,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (!_isPremiumUser) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 14,
                        color: const Color(0xFF22D3EE).withOpacity(0.4),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _resolveDreamIcon(String title) {
    final t = title.toLowerCase();

    // TEMEL KORKULAR & KAÇIŞ
    if (t.contains('karanl') ||
        t.contains('gece') ||
        t.contains('dark') ||
        t.contains('night'))
      return Icons.nights_stay_rounded;
    if (t.contains('kork') ||
        t.contains('kabus') ||
        t.contains('canavar') ||
        t.contains('fear'))
      return Icons.error_outline_rounded;
    if (t.contains('koş') ||
        t.contains('peşin') ||
        t.contains('takip') ||
        t.contains('kaç'))
      return Icons.directions_run_rounded;
    if (t.contains('düş') || t.contains('uçurum') || t.contains('fall'))
      return Icons.transit_enterexit_rounded;
    if (t.contains('kaybol') || t.contains('labirent') || t.contains('bulama'))
      return Icons.help_center_rounded;

    // DOĞA, ELEMENTLER & UZAY
    if (t.contains('su') ||
        t.contains('deniz') ||
        t.contains('okyanus') ||
        t.contains('göl'))
      return Icons.water_drop_rounded;
    if (t.contains('ateş') ||
        t.contains('yangın') ||
        t.contains('alev') ||
        t.contains('fire'))
      return Icons.local_fire_department_rounded;
    if (t.contains('orman') ||
        t.contains('ağaç') ||
        t.contains('doğa') ||
        t.contains('yaprak'))
      return Icons.park_rounded;
    if (t.contains('dağ') ||
        t.contains('tepe') ||
        t.contains('tırman') ||
        t.contains('kaya'))
      return Icons.landscape_rounded;
    if (t.contains('yağmur') ||
        t.contains('fırtına') ||
        t.contains('şimşek') ||
        t.contains('sel'))
      return Icons.thunderstorm_rounded;
    if (t.contains('kar ') ||
        t.contains('kış') ||
        t.contains('soğuk') ||
        t.contains('buz'))
      return Icons.ac_unit_rounded;
    if (t.contains('uzay') ||
        t.contains('gezegen') ||
        t.contains('yıldız') ||
        t.contains('ayı'))
      return Icons.rocket_launch_rounded;
    if (t.contains('ışık') || t.contains('parlak') || t.contains('güneş'))
      return Icons.wb_sunny_rounded;

    // YAŞAM, ÖLÜM, DÖNÜŞÜM
    if (t.contains('ölüm') ||
        t.contains('ölü') ||
        t.contains('mezar') ||
        t.contains('cenaze'))
      return Icons.blur_on_rounded;
    if (t.contains('doğum') || t.contains('bebek') || t.contains('hamile'))
      return Icons.child_care_rounded;
    if (t.contains('hasta') ||
        t.contains('kan ') ||
        t.contains('yaralan') ||
        t.contains('diş'))
      return Icons.local_hospital_rounded;
    if (t.contains('yüzleş') ||
        t.contains('dönüş') ||
        t.contains('ayna') ||
        t.contains('sır'))
      return Icons.all_inclusive_rounded;
    if (t.contains('gizem') ||
        t.contains('büyü') ||
        t.contains('cadı') ||
        t.contains('ruh'))
      return Icons.visibility_outlined;

    // İLİŞKİLER & İNSANLAR
    if (t.contains('eski sev') || t.contains('aldat') || t.contains('ayrıl'))
      return Icons.heart_broken_rounded;
    if (t.contains('aşk') ||
        t.contains('sev') ||
        t.contains('öp') ||
        t.contains('sevgil'))
      return Icons.favorite_border_rounded;
    if (t.contains('aile') ||
        t.contains('anne') ||
        t.contains('baba') ||
        t.contains('kardeş'))
      return Icons.family_restroom_rounded;
    if (t.contains('arkadaş') || t.contains('dost') || t.contains('kalabalık'))
      return Icons.groups_rounded;
    if (t.contains('düğün') ||
        t.contains('parti') ||
        t.contains('kutlama') ||
        t.contains('eğlen'))
      return Icons.celebration_rounded;
    if (t.contains('kavga') ||
        t.contains('savaş') ||
        t.contains('silah') ||
        t.contains('dövüş'))
      return Icons.shield_moon_rounded;

    // NESNELER & YERLER
    if (t.contains('ev') ||
        t.contains('oda') ||
        t.contains('bina') ||
        t.contains('kapı'))
      return Icons.other_houses_rounded;
    if (t.contains('şato') || t.contains('saray') || t.contains('kale'))
      return Icons.castle_rounded;
    if (t.contains('araba') ||
        t.contains('kaza') ||
        t.contains('sür') ||
        t.contains('trafik'))
      return Icons.directions_car_rounded;
    if (t.contains('uçak') ||
        t.contains('havaliman') ||
        t.contains('uç') ||
        t.contains('kanat'))
      return Icons.flight_takeoff_rounded;
    if (t.contains('tren') || t.contains('yol') || t.contains('istasyon'))
      return Icons.moving_rounded;
    if (t.contains('okul') ||
        t.contains('sınav') ||
        t.contains('ders') ||
        t.contains('öğretmen'))
      return Icons.menu_book_rounded;
    if (t.contains('para') ||
        t.contains('zengin') ||
        t.contains('altın') ||
        t.contains('cüzdan'))
      return Icons.attach_money_rounded;
    if (t.contains('yemek') ||
        t.contains('mutfak') ||
        t.contains('aç') ||
        t.contains('restoran'))
      return Icons.restaurant_rounded;
    if (t.contains('saat') ||
        t.contains('zaman') ||
        t.contains('geç kal') ||
        t.contains('bekle'))
      return Icons.schedule_rounded;
    if (t.contains('müzik') ||
        t.contains('şarkı') ||
        t.contains('dans') ||
        t.contains('konser'))
      return Icons.music_note_rounded;

    // CANLILAR
    if (t.contains('hayvan') || t.contains('köpek') || t.contains('kedi'))
      return Icons.pets_rounded;
    if (t.contains('yılan'))
      return Icons.gesture_rounded; // Yılana benzer şekil
    if (t.contains('kuş') || t.contains('karga'))
      return Icons.flutter_dash_rounded;
    if (t.contains('böcek') || t.contains('örümcek'))
      return Icons.bug_report_rounded;

    // HİÇBİRİNE UYMAZSA - Çeşitlilik sağlayan rastgele ama sabit ikonlar
    final fallbacks = [
      Icons.auto_awesome, // Yıldızlar
      Icons.toll_rounded, // Aura/Para
      Icons.fingerprint_rounded, // Kimlik/Gizem
      Icons.hdr_strong_rounded, // Noktalar/Yol
      Icons.blur_circular_rounded, // Duman/Sis
      Icons.lens_blur_rounded, // Karışıklık
      Icons.flare_rounded, // Işık patlaması
      Icons.bubble_chart_rounded, // Baloncuklar
    ];

    // Başlığın uzunluğuna veya içeriğine göre her zaman aynı rüyaya aynı ikonu vermek için
    final hashIndex = title.length % fallbacks.length;
    return fallbacks[hashIndex];
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      String two(int v) => v.toString().padLeft(2, '0');
      return '${two(dt.day)}.${two(dt.month)}.${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
    } catch (_) {
      return iso;
    }
  }

  Future<void> _showDreamDetail(Map<String, dynamic> dream) async {
    // ── Premium Kapısı: Ücretsiz kullanıcılar rüya detaylarını açamaz ──
    if (!_isPremiumUser) {
      final soulStones = await StorageService.getSoulStones();
      if (!mounted) return;

      final bool? confirm = await showGeneralDialog<bool>(
        context: context,
        barrierColor: Colors.black.withOpacity(0.5),
        barrierDismissible: true,
        barrierLabel: 'DreamDetailGate',
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, anim1, anim2) {
          return Center(
            child: ScaleTransition(
              scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Material(
                  type: MaterialType.transparency,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              color: const Color(0xFF22D3EE).withOpacity(0.9),
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _isTr ? 'Rüya Arşivi' : 'Dream Archive',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isTr
                                  ? 'Geçmiş rüya analizlerini görüntülemek için Elite abonelik veya Ruh Taşı gereklidir.\n\nMevcut Ruh Taşın: $soulStones'
                                  : 'Viewing past dream analyses requires Elite subscription or Soul Stones.\n\nCurrent Soul Stones: $soulStones',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: soulStones >= 1
                                          ? const Color(
                                              0xFF22D3EE,
                                            ).withOpacity(0.15)
                                          : Colors.white.withOpacity(0.05),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: BorderSide(
                                          color: soulStones >= 1
                                              ? const Color(
                                                  0xFF22D3EE,
                                                ).withOpacity(0.4)
                                              : Colors.white.withOpacity(0.1),
                                        ),
                                      ),
                                    ),
                                    onPressed: soulStones >= 1
                                        ? () => Navigator.pop(context, true)
                                        : null,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        _isTr
                                            ? '1 Ruh Taşı Kullan'
                                            : 'Use 1 Stone',
                                        style: TextStyle(
                                          color: soulStones >= 1
                                              ? const Color(0xFF22D3EE)
                                              : Colors.white30,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(
                                        0xFF22D3EE,
                                      ).withOpacity(0.15),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: BorderSide(
                                          color: const Color(
                                            0xFF22D3EE,
                                          ).withOpacity(0.4),
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const PremiumPaywallPage(),
                                        ),
                                      );
                                    },
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        _isTr ? 'Elite Abone Ol' : 'Get Elite',
                                        style: const TextStyle(
                                          color: Color(0xFF22D3EE),
                                          fontWeight: FontWeight.bold,
                                        ),
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
          );
        },
      );

      if (confirm == true && soulStones >= 1) {
        await StorageService.deductSoulStones(1);
      } else {
        return; // İptal veya yetersiz taş
      }
    }

    if (dream['isPremium'] == true && dream['premiumData'] != null) {
      // Premium rüya ise doğrudan analiz ekranına atla
      try {
        final pData = dream['premiumData'];

        Map<String, dynamic> rawObj = {};
        if (pData is String) {
          final decoded = jsonDecode(pData);
          if (decoded is Map) rawObj = Map<String, dynamic>.from(decoded);
        } else if (pData is Map) {
          rawObj = Map<String, dynamic>.from(pData);
        }

        final decodedDeepResult = DeepAnalysisResult.fromJson(rawObj);

        final pAns = dream['premiumAnswers'];
        List ansList = [];
        if (pAns is String) {
          try {
            final decodedAns = jsonDecode(pAns);
            if (decodedAns is List) ansList = decodedAns;
          } catch (_) {}
        } else if (pAns is List) {
          ansList = pAns;
        }

        final decodedAnswers = ansList
            .where((e) => e != null && e is Map)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

        setState(() {
          _dreamController.text = dream['text'] ?? '';
          _selectedEmotion = _resolveDreamEmotion(dream);
          _deepAnalysisResult = decodedDeepResult;
          _premiumAnswers = decodedAnswers;
          _isPremiumResult = true;
          _isFromHistory = true; // History'den yüklendiğini işaretle

          _showAnalysisOverlay = true;
          _analysisOverlayVisible = true;

          _isWriting = true;
          _overlayContent = 'results';
          _currentDreamId = dream['id']?.toString();
          _selectedReflectionAction = dream['reflectionAction']?.toString();
          _isDreamSaved = true;
        });
      } catch (e, stack) {
        debugPrint('Parsing error in History Tap: $e\n$stack');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kayıtlı veri hatalı: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }
    final title = (dream['title'] ?? '').toString().trim();
    final text = dream['text']?.toString() ?? '';
    final storedMood = dream['mood']?.toString();
    final moodEmotion = _emotionFromStored(storedMood);
    final moodLabel = moodEmotion != null
        ? _emotionLabel(moodEmotion)
        : storedMood;
    final symbols = (dream['symbols'] as List?)?.cast<String>() ?? [];
    final general = dream['general']?.toString();
    final psychology = dream['psychology']?.toString();
    final spiritual = dream['spiritual']?.toString();
    final advice = dream['advice']?.toString();
    final scientific = dream['scientificInterpretation']?.toString();
    final baseInterpretation = (scientific ?? general ?? '').trim();
    final emotion = _resolveDreamEmotion(dream);
    final date = _formatDate(dream['date']?.toString() ?? '');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors
          .transparent, // Arka planı transparent yapıyoruz Blur ekleyebilmek için
      isScrollControlled: true,
      builder: (_) {
        String? enrichedText;
        var isEnriching = false;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            final canEnrich = _analysisService.canEnrich;
            final showEnrichButton = canEnrich && baseInterpretation.isNotEmpty;

            return BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 20,
                sigmaY: 20,
              ), // Liquid glass efekti eklendi
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF0F141E,
                  ).withOpacity(0.85), // Premium dark tema
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: DraggableScrollableSheet(
                  expand: false,
                  initialChildSize: 0.8,
                  minChildSize: 0.5,
                  maxChildSize: 0.95,
                  builder: (context, scroll) {
                    return SingleChildScrollView(
                      controller: scroll,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  _isTr
                                      ? 'STANDART ANALİZ'
                                      : 'STANDARD ANALYSIS',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2.5,
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                          // ── YAZILAN RÜYA KART (Premium Uyumlu) ──
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.04),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.auto_awesome,
                                      color: Colors.white.withOpacity(0.5),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isTr ? 'RÜYANIZ' : 'YOUR DREAM',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (moodLabel != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _resolveEmotionAccentColor(
                                            emotion,
                                          ).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          moodLabel,
                                          style: TextStyle(
                                            color: _resolveEmotionAccentColor(
                                              emotion,
                                            ),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  text,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 13,
                                    height: 1.7,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    date,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.3),
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (symbols.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: symbols
                                    .map(
                                      (s) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF7C6CF3,
                                          ).withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: const Color(
                                              0xFF7C6CF3,
                                            ).withOpacity(0.3),
                                          ),
                                        ),
                                        child: Text(
                                          s,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          if (general != null && general.isNotEmpty)
                            _detailBlock(
                              _isTr ? 'Genel Analiz' : 'General Analysis',
                              general,
                              icon: Icons.insights,
                            ),
                          if (psychology != null && psychology.isNotEmpty)
                            _detailBlock(
                              _isTr ? 'Psikolojik Örüntü' : 'Psychological',
                              psychology,
                              icon: Icons.psychology,
                            ),
                          if (spiritual != null && spiritual.isNotEmpty)
                            _detailBlock(
                              _isTr ? 'Ruhsal / Sembolik' : 'Spiritual',
                              spiritual,
                              icon: Icons.nights_stay,
                            ),
                          if (advice != null && advice.isNotEmpty)
                            _detailBlock(
                              _isTr ? 'Öneri & Adım' : 'Advice',
                              advice,
                              icon: Icons.wb_incandescent_outlined,
                            ),
                          if (enrichedText != null && enrichedText!.isNotEmpty)
                            _detailBlock(
                              _isTr
                                  ? 'Derinleştirilmiş Analiz'
                                  : 'Deepened Insights',
                              enrichedText!,
                              icon: Icons.auto_awesome,
                            ),
                          if (showEnrichButton) ...[
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: GestureDetector(
                                onTap: isEnriching
                                    ? null
                                    : () async {
                                        setSheetState(() {
                                          isEnriching = true;
                                        });
                                        final analysis = _analysisService
                                            .analyzeDream(text);
                                        final enriched = await _analysisService
                                            .enrichWithGpt(
                                              baseText: baseInterpretation,
                                              analysis: analysis,
                                              emotion: emotion,
                                            );
                                        if (!context.mounted) return;
                                        setSheetState(() {
                                          enrichedText = enriched;
                                          isEnriching = false;
                                        });
                                      },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(
                                          0xFF7C6CF3,
                                        ).withOpacity(isEnriching ? 0.4 : 0.8),
                                        const Color(
                                          0xFFC356FE,
                                        ).withOpacity(isEnriching ? 0.3 : 0.6),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: isEnriching
                                        ? null
                                        : [
                                            BoxShadow(
                                              color: const Color(
                                                0xFF7C6CF3,
                                              ).withOpacity(0.3),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (isEnriching)
                                        const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      else
                                        const Icon(
                                          Icons.auto_fix_high,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isEnriching
                                            ? _l10n.dreamEnriching
                                            : _l10n.dreamEnrich,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: GestureDetector(
                              onTap: () {
                                final shareText = _l10n.dreamShareText(
                                  title.isNotEmpty
                                      ? title
                                      : _l10n.dreamDefaultTitle,
                                  date,
                                  text,
                                  general ?? '',
                                  psychology ?? '',
                                  spiritual ?? '',
                                  advice ?? '',
                                );
                                Share.share(shareText);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.share,
                                      size: 18,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _l10n.dreamShare,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Emotion _resolveDreamEmotion(Map<String, dynamic> dream) {
    final raw = dream['emotion']?.toString();
    if (raw != null && raw.isNotEmpty) {
      return Emotion.values.firstWhere(
        (e) => e.name == raw,
        orElse: () => Emotion.calm,
      );
    }
    final mood = dream['mood']?.toString();
    final legacyEmotion = _emotionFromStored(mood);
    if (legacyEmotion != null) return legacyEmotion;
    return Emotion.calm;
  }

  Widget _detailBlock(String title, String body, {IconData? icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white.withOpacity(0.7), size: 18),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  String _formatShortDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      const monthsTr = [
        'Oca',
        'Şub',
        'Mar',
        'Nis',
        'May',
        'Haz',
        'Tem',
        'Ağu',
        'Eyl',
        'Eki',
        'Kas',
        'Ara',
      ];
      const monthsEn = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final months = _isTr ? monthsTr : monthsEn;
      final d = dt.day.toString().padLeft(2, '0');
      final m = months[dt.month - 1];
      return '$d $m ${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  List<_InterpretationSection> _parseInterpretationSections(String text) {
    final cleaned = text.trim();
    if (cleaned.isEmpty) return [];
    final blocks = cleaned.split(RegExp(r'\n\s*\n'));
    final sections = <_InterpretationSection>[];
    for (final block in blocks) {
      final lines = block
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
      if (lines.isEmpty) continue;
      final title = lines.first;
      final body = lines.skip(1).join('\n').trim();
      sections.add(
        _InterpretationSection(title: title, body: body.isEmpty ? title : body),
      );
    }
    return sections;
  }

  List<Widget> _buildInterpretationCards(
    List<_InterpretationSection> sections,
  ) {
    final cards = <Widget>[];

    // API'den gelen kısa analiz varsa onu göster
    // API'den yapılandırılmış sections geldiyse
    if (_apiSections.isNotEmpty) {
      for (var i = 0; i < _apiSections.length; i++) {
        final section = _apiSections[i];
        final icon = _getIconForEmoji(section.emoji);
        cards.add(
          _InterpretationCardWidget(
            icon: icon,
            title: section
                .title, // [?] hatasını önlemek için emoji'yi string'den çıkardık
            body: section.content,
            index: i,
          ),
        );
      }
      return cards;
    }

    // Fallback: eski parse yöntemi
    for (var i = 0; i < sections.length; i++) {
      final section = sections[i];
      final title = section.title.replaceAll(RegExp(r'^[🧠🔍👤📌✨💭]\s*'), '');
      final icon = _getIconForSection(section.title);

      cards.add(
        _InterpretationCardWidget(
          icon: icon,
          title: title,
          body: section.body,
          index: i,
        ),
      );
    }

    if (cards.isEmpty) {
      cards.add(
        _InterpretationCardWidget(
          icon: Icons.psychology,
          title: 'Yorum',
          body: _generalAnalysis.isNotEmpty
              ? _generalAnalysis
              : _l10n.dreamAnalysisFailed,
          index: 0,
        ),
      );
    }

    return cards;
  }

  IconData _getIconForEmoji(String emoji) {
    switch (emoji) {
      case '🧠':
        return Icons.psychology;
      case '❤️':
        return Icons.favorite;
      case '🧩':
        return Icons.extension;
      case '🌫':
        return Icons.cloud;
      case '🔁':
        return Icons.refresh;
      case '🔬':
        return Icons.science;
      case '🌲':
        return Icons.park;
      case '💭':
        return Icons.chat_bubble_outline;
      case '⚡':
        return Icons.bolt;
      case '🛡':
        return Icons.shield;
      default:
        return Icons.auto_awesome;
    }
  }

  IconData _getIconForSection(String title) {
    if (title.contains('🧠') ||
        title.toLowerCase().contains('nöro') ||
        title.toLowerCase().contains('beyin')) {
      return Icons.psychology;
    }
    if (title.contains('🔍') ||
        title.toLowerCase().contains('bilişsel') ||
        title.toLowerCase().contains('detaylı') ||
        title.toLowerCase().contains('okuma')) {
      return Icons.search;
    }
    if (title.contains('💭') ||
        title.toLowerCase().contains('bilinçaltı') ||
        title.toLowerCase().contains('subconscious')) {
      return Icons.bubble_chart;
    }
    if (title.contains('✨') ||
        title.toLowerCase().contains('sembol') ||
        title.toLowerCase().contains('symbol')) {
      return Icons.auto_awesome;
    }
    if (title.contains('👤') ||
        title.toLowerCase().contains('kişisel') ||
        title.toLowerCase().contains('bağ')) {
      return Icons.person_outline;
    }
    if (title.contains('📌') ||
        title.toLowerCase().contains('sonuç') ||
        title.toLowerCase().contains('tavsiye') ||
        title.toLowerCase().contains('dengeli')) {
      return Icons.push_pin;
    }
    if (title.toLowerCase().contains('duygu')) {
      return Icons.favorite_outline;
    }
    if (title.toLowerCase().contains('geçmiş')) {
      return Icons.history;
    }
    return Icons.circle_outlined;
  }
}

class _InterpretationSection {
  final String title;
  final String body;

  const _InterpretationSection({required this.title, required this.body});
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isPremium;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    this.isPremium = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Premium tab uses cyan accent (same as Full Arcana in Tarot)
    final premiumColor = const Color(0xFF22D3EE);
    final glowCol = isPremium
        ? premiumColor.withOpacity(isActive ? 0.45 : 0.18)
        : AppColors.primaryPurple.withOpacity(isActive ? 0.45 : 0.18);

    return GlassButton.custom(
      width: double.infinity,
      height: 48,
      onTap: onTap,
      useOwnLayer: true,
      quality: GlassQuality.standard,
      shape: const LiquidRoundedSuperellipse(borderRadius: 28),
      interactionScale: 0.98,
      stretch: 0.2,
      resistance: 0.08,
      glowColor: glowCol,
      glowRadius: isActive ? 2.2 : 1.4,
      settings: const LiquidGlassSettings(
        thickness: 18,
        blur: 2,
        glassColor: AppColors.cardBackground,
        chromaticAberration: 0.15,
        lightIntensity: 0.45,
        ambientStrength: 0.6,
        refractiveIndex: 1.4,
        saturation: 0.8,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isActive
                        ? (isPremium
                              ? [
                                  premiumColor.withOpacity(0.18),
                                  premiumColor.withOpacity(0.04),
                                  Colors.white.withOpacity(0.01),
                                  premiumColor.withOpacity(0.10),
                                ]
                              : [
                                  AppColors.primaryPurple.withOpacity(0.16),
                                  AppColors.primaryTeal.withOpacity(0.12),
                                ])
                        : (isPremium
                              ? [
                                  premiumColor.withOpacity(0.08),
                                  premiumColor.withOpacity(0.02),
                                  Colors.white.withOpacity(0.01),
                                  premiumColor.withOpacity(0.04),
                                ]
                              : [
                                  Colors.white.withOpacity(0.06),
                                  Colors.white.withOpacity(0.02),
                                ]),
                  ),
                  border: isPremium
                      ? Border.all(
                          color: isActive
                              ? premiumColor.withOpacity(0.55)
                              : premiumColor.withOpacity(0.15),
                          width: isActive ? 1.2 : 0.8,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
            // Premium: subtle top highlight
            if (isPremium)
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
                        premiumColor.withOpacity(isActive ? 0.12 : 0.05),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isActive
                          ? (isPremium ? Colors.white : AppColors.textWhite)
                          : (isPremium
                                ? premiumColor.withOpacity(0.6)
                                : AppColors.textWhite70),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isPremium) ...[
                    const SizedBox(width: 5),
                    Icon(
                      Icons.diamond_outlined,
                      size: 13,
                      color: isActive
                          ? premiumColor
                          : premiumColor.withOpacity(0.4),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoiseOverlay extends StatelessWidget {
  const _NoiseOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _NoisePainter());
  }
}

class _NoisePainter extends CustomPainter {
  final math.Random _rand = math.Random(7);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.15);

    const count = 240;
    for (var i = 0; i < count; i++) {
      final dx = _rand.nextDouble() * size.width;
      final dy = _rand.nextDouble() * size.height;
      final r = 0.6 + _rand.nextDouble() * 0.8;
      canvas.drawCircle(Offset(dx, dy), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AnalysisDialog extends StatefulWidget {
  final String randomMessage;
  final List<_ClarificationQuestion> questions;
  final ValueChanged<List<ClarificationAnswer>> onComplete;
  final bool showNotAnalyzable;
  final VoidCallback? onRetry;
  final String notAnalyzableMessage;
  final Color accentColor;

  const _AnalysisDialog({
    required this.randomMessage,
    required this.questions,
    required this.onComplete,
    required this.showNotAnalyzable,
    required this.notAnalyzableMessage,
    required this.accentColor,
    this.onRetry,
  });

  @override
  State<_AnalysisDialog> createState() => _AnalysisDialogState();
}

class _AnalysisDialogState extends State<_AnalysisDialog> {
  Timer? _spinnerTimer;
  int _spinnerMsgIndex = 0;
  bool _answered = false;
  bool _showResult = false;
  bool _questionVisible = true; // Soru görünürlüğü için
  int _questionIndex = 0;
  String? _selectedValue;
  final List<ClarificationAnswer> _answers = [];
  late List<_ChoiceOption> _options;
  String? _lastLocaleCode;

  List<_ChoiceOption> _buildShuffledOptions() {
    final l10n = AppLocalizations.of(context)!;

    final options = [
      _ChoiceOption(label: l10n.dreamYes, value: 'yes'),
      _ChoiceOption(label: l10n.dreamNo, value: 'no'),
      _ChoiceOption(label: l10n.dreamUnsure, value: 'unsure'),
    ];
    options.shuffle(math.Random());
    return options;
  }

  @override
  void initState() {
    super.initState();
    _options = [];
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showResult = true);
      }
    });
    _spinnerTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _spinnerMsgIndex++;
      });
    });
  }

  @override
  void dispose() {
    _spinnerTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localeCode = Localizations.localeOf(context).languageCode;
    if (_options.isNotEmpty && _lastLocaleCode == localeCode) return;
    _lastLocaleCode = localeCode;
    _options = _buildShuffledOptions();
  }

  Future<void> _handleAnswer(String answer) async {
    if (_answered) return;
    setState(() {
      _answered = true;
      _selectedValue = answer;
    });
    final question = widget.questions[_questionIndex];
    _answers.add(ClarificationAnswer(question.id, answer));
    final isLast = _questionIndex >= widget.questions.length - 1;

    if (!isLast) {
      // Önce fade out
      await Future.delayed(const Duration(milliseconds: 150));
      setState(() => _questionVisible = false);

      // Fade out tamamlanınca sonraki soruya geç
      await Future.delayed(const Duration(milliseconds: 350));
      setState(() {
        _questionIndex += 1;
        _answered = false;
        _selectedValue = null;
        _options = _buildShuffledOptions();
        _questionVisible = true; // Yeni soru fade in
      });
      return;
    }

    // Son soru - fade out sonra tamamla
    await Future.delayed(const Duration(milliseconds: 150));
    setState(() => _questionVisible = false);
    await Future.delayed(const Duration(milliseconds: 300));
    widget.onComplete(_answers);
  }

  String get _currentDots {
    final dotCount = (_spinnerMsgIndex % 4);
    return '.' * dotCount;
  }

  @override
  Widget build(BuildContext context) {
    final hasQuestion = widget.questions.isNotEmpty;
    final showNotAnalyzable = _showResult && widget.showNotAnalyzable;
    final showQuestion =
        _showResult && hasQuestion && !widget.showNotAnalyzable;
    final showInfo = _showResult && !hasQuestion && !widget.showNotAnalyzable;
    final showAnalyzingHeader = !widget.showNotAnalyzable || !_showResult;
    final currentQuestion = showQuestion
        ? widget.questions[_questionIndex].text
        : '';
    // Çember sabit konumda, sorular altında - Positioned ile
    final content = LayoutBuilder(
      builder: (context, constraints) {
        final centerY = constraints.maxHeight / 2;

        return Stack(
          children: [
            // Çember ve başlık - tam ortada sabit
            if (showAnalyzingHeader)
              Positioned(
                left: 0,
                right: 0,
                top: centerY - 50,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: CircularProgressIndicator(
                        color: widget.accentColor,
                        backgroundColor: AppColors.textWhite30,
                        strokeWidth: 4,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.dreamAnalyzing.replaceAll('.', '').trim(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                            letterSpacing: 0.0,
                          ),
                        ),
                        SizedBox(
                          width:
                              24, // Sabit genişlik, böylece yazı titrekleşmez/oynamaz
                          child: Text(
                            _currentDots,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.none,
                              letterSpacing: 0.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            // Sorular ve butonlar - çemberin altında (Eğer hata mesajıysa tam ortada)
            Positioned(
              left: 20,
              right: 20,
              top: showNotAnalyzable ? centerY - 30 : (centerY + 60),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: AnimatedOpacity(
                    opacity:
                        (showQuestion || showNotAnalyzable || showInfo) &&
                            _questionVisible
                        ? 1.0
                        : 0.0,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    child: AnimatedSlide(
                      offset:
                          (showQuestion || showNotAnalyzable || showInfo) &&
                              _questionVisible
                          ? Offset.zero
                          : const Offset(0, 0.1),
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (showNotAnalyzable)
                            Text(
                              widget.notAnalyzableMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textWhite70,
                                fontSize: 13,
                                height: 1.5,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                              ),
                            )
                          else if (showQuestion)
                            Text(
                              currentQuestion,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textWhite70,
                                fontSize: 13,
                                height: 1.5,
                                decoration: TextDecoration.none,
                              ),
                            )
                          else if (showInfo)
                            Text(
                              widget.randomMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textWhite70,
                                fontSize: 13,
                                height: 1.5,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          if (showQuestion) ...[
                            const SizedBox(height: 14),
                            _ChoiceRail(
                              options: _options,
                              selectedValue: _selectedValue,
                              onSelect: _handleAnswer,
                              isInteractive: !_answered,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    if (!showNotAnalyzable) return content;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onRetry ?? () {},
      child: content,
    );
  }
}

class _ClarificationQuestion {
  final String id;
  final String text;

  const _ClarificationQuestion({required this.id, required this.text});
}

class _ChoiceOption {
  final String label;
  final String value;

  const _ChoiceOption({required this.label, required this.value});
}

class _ChoiceRail extends StatelessWidget {
  final List<_ChoiceOption> options;
  final String? selectedValue;
  final ValueChanged<String> onSelect;
  final bool isInteractive;

  const _ChoiceRail({
    required this.options,
    required this.selectedValue,
    required this.onSelect,
    this.isInteractive = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        void selectByDx(double dx) {
          final itemWidth = constraints.maxWidth / options.length;
          final index = (dx / itemWidth).clamp(0, options.length - 1).floor();
          onSelect(options[index].value);
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: isInteractive
              ? (details) => selectByDx(details.localPosition.dx)
              : null,
          onPanUpdate: isInteractive
              ? (details) => selectByDx(details.localPosition.dx)
              : null,
          child: Column(
            children: [
              Row(
                children: options.map((option) {
                  final isSelected = selectedValue == option.value;
                  final baseStyle = TextStyle(
                    color: isSelected
                        ? Colors.white.withOpacity(0.95)
                        : Colors.white.withOpacity(0.6),
                    fontSize: isSelected ? 12.5 : 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    decoration: TextDecoration.none,
                  );
                  final itemWidth = constraints.maxWidth / options.length;
                  final painter = TextPainter(
                    text: TextSpan(text: option.label, style: baseStyle),
                    textDirection: TextDirection.ltr,
                  )..layout();
                  final available = itemWidth - 4;
                  final targetScale = isSelected && painter.width > available
                      ? (available / painter.width).clamp(0.85, 1.0)
                      : 1.0;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    width: itemWidth,
                    child: Center(
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        tween: Tween<double>(begin: 1.0, end: targetScale),
                        builder: (context, scaleX, child) {
                          return AnimatedScale(
                            scale: isSelected ? 1.08 : 1.0,
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOut,
                            child: Transform.scale(
                              scaleX: scaleX,
                              scaleY: 1.0,
                              alignment: Alignment.center,
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          option.label,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.visible,
                          textAlign: TextAlign.center,
                          style: baseStyle,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 18,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Row(
                      children: options.map((option) {
                        final isSelected = selectedValue == option.value;
                        final size = isSelected ? 10.0 : 6.0;
                        final width = constraints.maxWidth / options.length;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOut,
                          width: width,
                          child: Center(
                            child: AnimatedScale(
                              scale: isSelected ? 1.35 : 1.0,
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOut,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.easeOut,
                                width: size,
                                height: size,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.85)
                                      : Colors.white.withOpacity(0.35),
                                  shape: BoxShape.circle,
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(
                                              0.4,
                                            ),
                                            blurRadius: 6,
                                            spreadRadius: 1,
                                          ),
                                          BoxShadow(
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
                                            blurRadius: 12,
                                            spreadRadius: 3,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Dream Analysis Chart Widget - layered soft waves
class _HolographicBrainWidget extends StatefulWidget {
  final _DreamMetrics metrics;

  const _HolographicBrainWidget({required this.metrics});

  @override
  State<_HolographicBrainWidget> createState() =>
      _HolographicBrainWidgetState();
}

class _HolographicBrainWidgetState extends State<_HolographicBrainWidget>
    with TickerProviderStateMixin {
  // Soft line colors (each category)
  static const Color _duygusalColor = Color(0xFF7EEFE6);
  static const Color _belirsizlikColor = Color(0xFF8FB7FF);
  static const Color _yakinGecmisColor = Color(0xFFB78CFF);
  static const Color _beyinAktColor = Color(0xFF9CE6B5);
  static const double _bubbleOffset = 100;
  static const double _calloutHeight = 40;
  static const double _lineGap = 10;
  static const double _bubbleMinTop = 8;
  static const double _wavePeriodSeconds = 14;

  late final AnimationController _waveController;
  late final AnimationController _drawController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16), // 10s → 16s (performans)
    )..repeat();

    // Çizim animasyonu - soldan sağa çizilme
    _drawController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..forward();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _drawController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final metrics = widget.metrics;
    final chartMetrics = [
      _ChartMetric(
        label: l10n.dreamMetricEmotional,
        value: metrics.duygusal,
        color: _duygusalColor,
        anchorT: 0.18,
        peakT: 0.18,
        startLift: 0.06,
        edgeOffset: 0.06,
      ),
      _ChartMetric(
        label: l10n.dreamMetricUncertainty,
        value: metrics.belirsizlik,
        color: _belirsizlikColor,
        anchorT: 0.41,
        peakT: 0.41,
        startLift: 0.02,
        edgeOffset: 0.02,
      ),
      _ChartMetric(
        label: l10n.dreamMetricRecentPast,
        value: metrics.yakinGecmis,
        color: _yakinGecmisColor,
        anchorT: 0.64,
        peakT: 0.64,
        startLift: 0.04,
        edgeOffset: -0.02,
      ),
      _ChartMetric(
        label: l10n.dreamMetricBrain,
        value: metrics.beyinAkt,
        color: _beyinAktColor,
        anchorT: 0.87,
        peakT: 0.87,
        startLift: 0.015,
        edgeOffset: -0.06,
      ),
    ];

    return SizedBox(
      height: 200,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final chartRect = _DreamWaveChartPainter.chartRectFor(size);
          final anchors = [
            for (final metric in chartMetrics) _anchorOffset(chartRect, metric),
          ];

          return Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _waveController,
                    _drawController,
                  ]),
                  builder: (context, child) {
                    final timeSeconds =
                        (_waveController.lastElapsedDuration?.inMilliseconds ??
                            0) /
                        1000.0;
                    final phase =
                        timeSeconds * 2 * math.pi / _wavePeriodSeconds;
                    // Çizim ilerlemesi - easeOutQuart ile yumuşak
                    final drawT = Curves.easeOutQuart.transform(
                      _drawController.value,
                    );
                    return CustomPaint(
                      painter: _DreamWaveChartPainter(
                        metrics: chartMetrics,
                        bubbleOffset: _bubbleOffset,
                        calloutHeight: _calloutHeight,
                        lineGap: _lineGap,
                        bubbleMinTop: _bubbleMinTop,
                        phase: phase,
                        drawProgress: drawT,
                      ),
                    );
                  },
                ),
              ),
              // Balonlar - sırayla belirme animasyonu
              for (var i = 0; i < chartMetrics.length; i++)
                AnimatedBuilder(
                  animation: _drawController,
                  builder: (context, child) {
                    // Her balon kendi çizgisinden sonra yavaşça gelsin
                    final drawT = Curves.easeOutQuart.transform(
                      _drawController.value,
                    );
                    final bubbleStart = 0.10 + i * 0.15;
                    final bubbleEnd = bubbleStart + 0.45;
                    final bubbleProgress =
                        ((drawT - bubbleStart) / (bubbleEnd - bubbleStart))
                            .clamp(0.0, 1.0);
                    final smoothProgress = Curves.easeOutQuart.transform(
                      bubbleProgress,
                    );

                    return Transform.translate(
                      offset: Offset(
                        anchors[i].dx,
                        _bubbleTopFor(anchors[i].dy),
                      ),
                      child: FractionalTranslation(
                        translation: const Offset(-0.5, 0),
                        child: Transform.scale(
                          scale: smoothProgress,
                          child: Opacity(opacity: bubbleProgress, child: child),
                        ),
                      ),
                    );
                  },
                  child: RepaintBoundary(
                    child: _MetricCallout(
                      value: '${chartMetrics[i].value.toInt()}%',
                      label: chartMetrics[i].label,
                      accentColor: chartMetrics[i].color,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  double _bubbleTopFor(double anchorDy) {
    return math.max(_bubbleMinTop, anchorDy - _bubbleOffset);
  }

  Offset _anchorOffset(Rect rect, _ChartMetric metric) {
    final targetPeak = _DreamWaveChartPainter.targetPeakFor(metric.value);
    final y = rect.bottom - rect.height * targetPeak;
    final x = rect.left + rect.width * metric.anchorT;
    return Offset(x, y);
  }
}

class _DreamMetrics {
  final double duygusal;
  final double belirsizlik;
  final double yakinGecmis;
  final double beyinAkt;

  const _DreamMetrics({
    required this.duygusal,
    required this.belirsizlik,
    required this.yakinGecmis,
    required this.beyinAkt,
  });
}

class _ChartMetric {
  final String label;
  final double value;
  final Color color;
  final double anchorT;
  final double peakT;
  final double startLift;
  final double edgeOffset;

  const _ChartMetric({
    required this.label,
    required this.value,
    required this.color,
    required this.anchorT,
    required this.peakT,
    this.startLift = 0.0,
    this.edgeOffset = 0.0,
  });
}

/// Callout pill + label
class _MetricCallout extends StatelessWidget {
  final String value;
  final String label;
  final Color accentColor;

  const _MetricCallout({
    required this.value,
    required this.label,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 0.6,
                ),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: accentColor.withOpacity(0.75),
            fontSize: 8.5,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DreamWaveChartPainter extends CustomPainter {
  final List<_ChartMetric> metrics;
  final double bubbleOffset;
  final double calloutHeight;
  final double lineGap;
  final double bubbleMinTop;
  final double phase;
  final double drawProgress;

  _DreamWaveChartPainter({
    required this.metrics,
    required this.bubbleOffset,
    required this.calloutHeight,
    required this.lineGap,
    required this.bubbleMinTop,
    required this.phase,
    this.drawProgress = 1.0,
  });

  static const double _chartTopPadding = 46;
  static const double _chartBottomPadding = 22;
  static const double _edgeBaselineFactor = 0.14;
  static const double _edgeBlendWidth = 0.26;
  static const double _lineExtend = 40;

  static Rect chartRectFor(Size size) {
    return Rect.fromLTWH(
      10,
      _chartTopPadding,
      size.width - 20,
      size.height - _chartTopPadding - _chartBottomPadding,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final chartRect = chartRectFor(size);

    final anchors = <Offset>[
      for (final metric in metrics) _anchorPoint(chartRect, metric),
    ];

    // Çizgileri anchorT sırasına göre sırala (soldan sağa)
    final sortedMetrics = List<_ChartMetric>.from(metrics)
      ..sort((a, b) => a.anchorT.compareTo(b.anchorT));

    // Her çizgi için ayrı timing - daha yavaş ve yumuşak
    for (var i = 0; i < sortedMetrics.length; i++) {
      final metric = sortedMetrics[i];
      // Her çizgi için daha uzun aralar
      final lineStart = i * 0.18;
      final lineEnd = lineStart + 0.45;
      final rawProgress = ((drawProgress - lineStart) / (lineEnd - lineStart))
          .clamp(0.0, 1.0);
      // Ekstra yumuşatma
      final lineProgress = Curves.easeOutQuad.transform(rawProgress);

      if (lineProgress > 0) {
        canvas.save();
        final clipWidth = chartRect.width * lineProgress;
        canvas.clipRect(
          Rect.fromLTWH(
            chartRect.left - _lineExtend,
            0,
            clipWidth + _lineExtend * 2,
            size.height,
          ),
        );
        _drawWave(canvas, chartRect, metric);
        canvas.restore();
      }
    }

    // Anchor çizgileri de drawProgress'e göre
    for (var i = 0; i < metrics.length; i++) {
      // Her anchor kendi pozisyonuna göre belirsin
      final anchorT = metrics[i].anchorT;
      if (drawProgress >= anchorT * 0.9) {
        _drawAnchor(
          canvas,
          anchors[i],
          bubbleOffset,
          calloutHeight,
          lineGap,
          bubbleMinTop,
          metrics[i].color,
        );
      }
    }
  }

  int _layerSeed(List<_ChartMetric> metrics) {
    var seed = 7;
    for (final metric in metrics) {
      seed =
          (seed * 37 +
                  metric.value.round() * 13 +
                  (metric.anchorT * 1000).round())
              .clamp(-1 << 30, 1 << 30)
              .toInt();
    }
    return seed.abs();
  }

  void _drawWave(Canvas canvas, Rect rect, _ChartMetric metric) {
    final baseColor = Color.lerp(metric.color, Colors.white, 0.35)!;
    final points = _buildWavePoints(
      rect,
      metric.value,
      metric.peakT,
      metric.startLift,
      metric.edgeOffset,
    );
    final fillPath = _fillPath(points, rect);
    final strokePath = _strokePath(points, extend: _lineExtend);
    final shaderRect = Rect.fromLTRB(
      rect.left - _lineExtend,
      rect.top,
      rect.right + _lineExtend,
      rect.bottom,
    );
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [metric.color.withOpacity(0.22), Colors.transparent],
      ).createShader(rect);

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          Color.lerp(Colors.white, baseColor, 0.35)!.withOpacity(0.75),
          Color.lerp(Colors.white, baseColor, 0.35)!.withOpacity(0.75),
          Colors.transparent,
        ],
        stops: const [0.0, 0.18, 0.82, 1.0],
      ).createShader(shaderRect);

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          baseColor.withOpacity(0.08),
          baseColor.withOpacity(0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.18, 0.82, 1.0],
      ).createShader(shaderRect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawPath(fillPath, fillPaint);
    _drawAuroraBeams(canvas, rect, metric, baseColor, phase);
    canvas.drawPath(strokePath, glowPaint);
    canvas.drawPath(strokePath, strokePaint);
  }

  void _drawAuroraBeams(
    Canvas canvas,
    Rect rect,
    _ChartMetric metric,
    Color baseColor,
    double phase,
  ) {
    final anchorY = _waveY(
      rect,
      metric.value,
      metric.peakT,
      metric.anchorT,
      metric.startLift,
      metric.edgeOffset,
    );
    final anchorX = rect.left + rect.width * metric.anchorT;
    canvas.save();
    canvas.clipRect(rect);

    final beamWidth = rect.width * 0.11;
    final beamRect = Rect.fromLTWH(
      anchorX - beamWidth / 2,
      anchorY + 6,
      beamWidth,
      rect.bottom - (anchorY + 6),
    );

    final pulse = 0.85 + 0.15 * math.sin(phase + metric.anchorT * 4.2);
    final beamPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          metric.color.withOpacity(0.35 * pulse),
          baseColor.withOpacity(0.18 * pulse),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(beamRect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);

    canvas.drawRRect(
      RRect.fromRectAndRadius(beamRect, const Radius.circular(22)),
      beamPaint,
    );

    final corePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = metric.color.withOpacity(0.32 * pulse);
    canvas.drawLine(
      Offset(anchorX, anchorY + 8),
      Offset(anchorX, rect.bottom),
      corePaint,
    );

    canvas.restore();
  }

  void _drawAnchor(
    Canvas canvas,
    Offset anchor,
    double bubbleOffset,
    double calloutHeight,
    double lineGap,
    double bubbleMinTop,
    Color color,
  ) {
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = Colors.white.withOpacity(0.35);

    final bubbleTop = math.max(bubbleMinTop, anchor.dy - bubbleOffset);
    final lineStartY = bubbleTop + calloutHeight + lineGap;
    final clampedStartY = math.min(anchor.dy - 2, lineStartY);
    canvas.drawLine(Offset(anchor.dx, clampedStartY), anchor, linePaint);

    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.9);
    final haloPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withOpacity(0.5);

    canvas.drawCircle(anchor, 4.6, haloPaint);
    canvas.drawCircle(anchor, 3.0, dotPaint);
  }

  Offset _anchorPoint(Rect rect, _ChartMetric metric) {
    final x = rect.left + rect.width * metric.anchorT;
    final y = _waveY(
      rect,
      metric.value,
      metric.peakT,
      metric.anchorT,
      metric.startLift,
      metric.edgeOffset,
    );
    return Offset(x, y);
  }

  List<Offset> _buildWavePoints(
    Rect rect,
    double value,
    double peakT,
    double startLift,
    double edgeOffset,
  ) {
    const sampleCount = 24;
    final tValues = <double>{};
    for (var i = 0; i < sampleCount; i++) {
      tValues.add(i / (sampleCount - 1));
    }
    tValues.add(peakT.clamp(0.0, 1.0));

    final sortedT = tValues.toList()..sort();
    final points = [
      for (final t in sortedT)
        Offset(
          rect.left + rect.width * t,
          _waveY(rect, value, peakT, t, startLift, edgeOffset),
        ),
    ];
    if (points.length <= 2) {
      return points;
    }
    final smoothed = <Offset>[points.first];
    for (var i = 1; i < points.length - 1; i++) {
      final prev = points[i - 1];
      final current = points[i];
      final next = points[i + 1];
      final smoothY = (prev.dy + current.dy * 2 + next.dy) / 4;
      smoothed.add(Offset(current.dx, smoothY));
    }
    smoothed.add(points.last);
    return smoothed;
  }

  Path _strokePath(List<Offset> points, {double extend = 0}) {
    if (points.length < 2) {
      return Path();
    }
    final startX = points.first.dx - extend;
    final endX = points.last.dx + extend;
    final startSlopeDx = (points.length > 1)
        ? (points[1].dx - points.first.dx)
        : 1.0;
    final startSlopeDy = (points.length > 1)
        ? (points[1].dy - points.first.dy)
        : 0.0;
    final endSlopeDx = (points.length > 1)
        ? (points.last.dx - points[points.length - 2].dx)
        : 1.0;
    final endSlopeDy = (points.length > 1)
        ? (points.last.dy - points[points.length - 2].dy)
        : 0.0;
    final startY =
        points.first.dy +
        (startSlopeDx.abs() < 0.001
            ? 0.0
            : (startX - points.first.dx) * (startSlopeDy / startSlopeDx));
    final endY =
        points.last.dy +
        (endSlopeDx.abs() < 0.001
            ? 0.0
            : (endX - points.last.dx) * (endSlopeDy / endSlopeDx));
    final extendedPoints = <Offset>[
      Offset(startX, startY),
      ...points,
      Offset(endX, endY),
    ];
    final path = Path()
      ..moveTo(extendedPoints.first.dx, extendedPoints.first.dy);

    // Catmull-Rom spline için kontrol noktaları hesapla
    const tension = 0.15; // Düşük = daha yumuşak eğriler

    for (var i = 0; i < extendedPoints.length - 1; i++) {
      final p0 = i > 0 ? extendedPoints[i - 1] : extendedPoints[i];
      final p1 = extendedPoints[i];
      final p2 = extendedPoints[i + 1];
      final p3 = i < extendedPoints.length - 2
          ? extendedPoints[i + 2]
          : extendedPoints[i + 1];

      // Catmull-Rom -> Cubic Bezier dönüşümü
      final cp1 = Offset(
        p1.dx + (p2.dx - p0.dx) * tension,
        p1.dy + (p2.dy - p0.dy) * tension,
      );
      final cp2 = Offset(
        p2.dx - (p3.dx - p1.dx) * tension,
        p2.dy - (p3.dy - p1.dy) * tension,
      );

      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  Path _fillPath(List<Offset> points, Rect rect) {
    if (points.length < 2) {
      return Path();
    }
    final path = _strokePath(points);
    path.lineTo(rect.right, rect.bottom);
    path.lineTo(rect.left, rect.bottom);
    path.close();
    return path;
  }

  double _waveY(
    Rect rect,
    double value,
    double peakT,
    double t,
    double startLift,
    double edgeOffset,
  ) {
    final factor = _waveFactor(
      value: value,
      peakT: peakT,
      t: t,
      startLift: startLift,
      edgeOffset: edgeOffset,
      phase: phase,
    );
    return rect.bottom - rect.height * factor;
  }

  static double _edgeWeight(double t) {
    final left = math.exp(-math.pow(t / _edgeBlendWidth, 2));
    final right = math.exp(-math.pow((1 - t) / _edgeBlendWidth, 2));
    return (left + right).clamp(0.0, 1.0).toDouble();
  }

  static double _normalizedValue(double value) {
    final valueNorm = (value / 100).clamp(0.0, 0.95);
    return math.pow(valueNorm, 0.4).toDouble();
  }

  static double targetPeakFor(double value) {
    final normalized = _normalizedValue(value);
    return lerpDouble(0.12, 0.7, normalized)!;
  }

  static double _waveFactor({
    required double value,
    required double peakT,
    required double t,
    required double startLift,
    required double edgeOffset,
    required double phase,
  }) {
    final normalized = _normalizedValue(value);
    final targetPeak = targetPeakFor(value);

    final primary = math.exp(-math.pow((t - peakT) / 0.28, 2));
    final trailing = 0.06 * math.exp(-math.pow((t - (peakT + 0.32)) / 0.24, 2));
    final leading = 0.04 * math.exp(-math.pow((t - (peakT - 0.32)) / 0.24, 2));
    final start = startLift * math.exp(-math.pow((t - 0.1) / 0.14, 2));

    final base = (0.08 + 0.06 * normalized + start)
        .clamp(0.06, 0.32)
        .toDouble();
    final secondary = (trailing + leading) * (1 - primary);
    final flowScale = (1 - primary);
    // Daha belirgin su dalgası efekti
    final wobble = 0.065 * math.sin(phase + t * 3.2 + peakT * 2.4) * flowScale;
    final micro =
        0.028 *
        math.sin(phase * 1.3 + t * 6.0 + peakT) *
        flowScale *
        (1 - _edgeWeight(t));
    final anchorWobble =
        0.018 * math.sin(phase + t * 2.2 + value * 0.1) * primary;
    final rawFactor =
        base +
        (targetPeak - base) * primary +
        secondary +
        wobble +
        micro +
        anchorWobble;

    final edgeWeight = _edgeWeight(t) * (1 - primary);
    final edgeBaseline = _edgeBaselineFactor + edgeOffset;
    return lerpDouble(
      rawFactor,
      edgeBaseline,
      edgeWeight,
    )!.clamp(0.08, 0.9).toDouble();
  }

  @override
  bool shouldRepaint(covariant _DreamWaveChartPainter oldDelegate) {
    if (oldDelegate.metrics.length != metrics.length) {
      return true;
    }
    if (oldDelegate.bubbleOffset != bubbleOffset) {
      return true;
    }
    if (oldDelegate.calloutHeight != calloutHeight ||
        oldDelegate.lineGap != lineGap) {
      return true;
    }
    if (oldDelegate.bubbleMinTop != bubbleMinTop) {
      return true;
    }
    if ((oldDelegate.phase - phase).abs() > 0.0001) {
      return true;
    }
    for (var i = 0; i < metrics.length; i++) {
      final old = oldDelegate.metrics[i];
      final current = metrics[i];
      if (old.value != current.value ||
          old.anchorT != current.anchorT ||
          old.peakT != current.peakT ||
          old.startLift != current.startLift ||
          old.edgeOffset != current.edgeOffset ||
          old.color != current.color) {
        return true;
      }
    }
    return false;
  }
}

/// Chart Legend Widget - 4 categories (2 left, 2 right) - Soft colors
enum _MetricType { emotionalLoad, uncertainty, recentPast, brainActivity }

typedef _MetricTapCallback =
    void Function(_MetricType metric, Offset globalPosition);

class _ChartLegend extends StatelessWidget {
  final _MetricType? selected;
  final _MetricTapCallback onSelect;

  const _ChartLegend({required this.selected, required this.onSelect});

  static const Color _duygusalColor = Color(0xFF7EEFE6);
  static const Color _belirsizlikColor = Color(0xFF8FB7FF);
  static const Color _yakinGecmisColor = Color(0xFFB78CFF);
  static const Color _beyinAktColor = Color(0xFF9CE6B5);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Sol taraf - 2 tane alt üst
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LegendItem(
                selected: selected == _MetricType.emotionalLoad,
                color: _duygusalColor,
                icon: PhosphorIcon(
                  PhosphorIcons.heart(PhosphorIconsStyle.regular),
                  size: 14,
                  color: _duygusalColor.withOpacity(0.85),
                ),
                label: l10n.dreamMetricEmotional,
                onTapDown: (details) =>
                    onSelect(_MetricType.emotionalLoad, details.globalPosition),
              ),
              const SizedBox(height: 8),
              _LegendItem(
                selected: selected == _MetricType.uncertainty,
                color: _belirsizlikColor,
                icon: PhosphorIcon(
                  PhosphorIcons.question(PhosphorIconsStyle.regular),
                  size: 14,
                  color: _belirsizlikColor.withOpacity(0.85),
                ),
                label: l10n.dreamMetricUncertainty,
                onTapDown: (details) =>
                    onSelect(_MetricType.uncertainty, details.globalPosition),
              ),
            ],
          ),
          // Sağ taraf - 2 tane alt üst
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _LegendItem(
                selected: selected == _MetricType.recentPast,
                color: _yakinGecmisColor,
                icon: PhosphorIcon(
                  PhosphorIcons.clockCounterClockwise(
                    PhosphorIconsStyle.regular,
                  ),
                  size: 14,
                  color: _yakinGecmisColor.withOpacity(0.85),
                ),
                label: l10n.dreamMetricRecentPast,
                onTapDown: (details) =>
                    onSelect(_MetricType.recentPast, details.globalPosition),
              ),
              const SizedBox(height: 8),
              _LegendItem(
                selected: selected == _MetricType.brainActivity,
                color: _beyinAktColor,
                icon: PhosphorIcon(
                  PhosphorIcons.brain(PhosphorIconsStyle.regular),
                  size: 14,
                  color: _beyinAktColor.withOpacity(0.85),
                ),
                label: l10n.dreamMetricBrain,
                onTapDown: (details) =>
                    onSelect(_MetricType.brainActivity, details.globalPosition),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final Color color;
  final ValueChanged<TapDownDetails> onTapDown;
  final bool selected;

  const _LegendItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTapDown,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: onTapDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 6),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              shadows: selected
                  ? [
                      Shadow(
                        color: Colors.white.withOpacity(0.4),
                        blurRadius: 6,
                      ),
                    ]
                  : null,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}

class _MetricDescriptionCard extends StatefulWidget {
  final String body;

  const _MetricDescriptionCard({required this.body});

  @override
  State<_MetricDescriptionCard> createState() => _MetricDescriptionCardState();
}

class _MetricDescriptionCardState extends State<_MetricDescriptionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    // Yazı gecikmeli ve yumuşak gelsin
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 1.0, curve: Curves.easeOutQuart),
      ),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _MetricDescriptionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.body != widget.body) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
          ),
          child: FadeTransition(
            opacity: _textOpacity,
            child: Text(
              widget.body,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Interpretation Card Widget - Glass Panel Design
class _InterpretationCardWidget extends StatefulWidget {
  final IconData icon;
  final String title;
  final String body;
  final int index;

  const _InterpretationCardWidget({
    required this.icon,
    required this.title,
    required this.body,
    required this.index,
  });

  @override
  State<_InterpretationCardWidget> createState() =>
      _InterpretationCardWidgetState();
}

class _InterpretationCardWidgetState extends State<_InterpretationCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;
  late Animation<double> _scale;

  static const Color _softMint = Color(0xFF8EDAD3);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Her kart için delay - grafik gibi yavaş yavaş
    final delay = widget.index * 0.15;
    final start = delay.clamp(0.0, 0.6);
    final end = (start + 0.4).clamp(0.0, 1.0);

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOutQuart),
      ),
    );

    _slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(start, end, curve: Curves.easeOutCubic),
          ),
        );

    _scale = Tween<double>(begin: 0.97, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOutQuart),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // [?] Hatası Veren Emojileri Temizle
    String cleanTitle = widget.title
        .replaceAll('🧠', '')
        .replaceAll('❤️', '')
        .replaceAll('🧩', '')
        .replaceAll('🌲', '')
        .replaceAll('🌫️', '')
        .replaceAll('🌫', '')
        .replaceAll('🔁', '')
        .replaceAll('🔬', '')
        .replaceAll('📌', '')
        .replaceAll('👉', '')
        .trim();

    // Body'deki sorunlu parmak emojisini güvenli bir ok işaretiyle değiştir
    String cleanBody = widget.body.replaceAll('👉', '➤');

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slide.value.dy * 30),
          child: Transform.scale(
            scale: _scale.value,
            child: Opacity(opacity: _opacity.value, child: child),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _softMint.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _softMint.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(widget.icon, size: 18, color: _softMint),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          cleanTitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    cleanBody,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95), // Daha net beyaz
                      fontSize: 14, // 13'ten 14'e çıktı (Okunabilirlik)
                      height:
                          1.65, // 1.55'ten 1.65'e (Paragraflar arası boşluk hissi)
                      letterSpacing: 0.2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Gradient dönen spinner (CSS'den uyarlandı)
class _GradientSpinner extends StatefulWidget {
  final double size;
  const _GradientSpinner({this.size = 50});

  @override
  State<_GradientSpinner> createState() => _GradientSpinnerState();
}

class _GradientSpinnerState extends State<_GradientSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
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
      width: widget.size * 2,
      height: widget.size * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow efekti (blur ile) - arkada
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * 2 * math.pi,
                  child: child,
                );
              },
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFBA42FF), Color(0xFF00E1FF)],
                    stops: [0.35, 1.0],
                  ),
                ),
              ),
            ),
          ),
          // Ana gradient çember (hafif blur)
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * 2 * math.pi,
                  child: child,
                );
              },
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFBA42FF), Color(0xFF00E1FF)],
                    stops: [0.35, 1.0],
                  ),
                ),
              ),
            ),
          ),
          // İç koyu daire (blur ile)
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              width: widget.size * 0.7,
              height: widget.size * 0.7,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF242424),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Premium Derin Analiz Kart Widget ──
class _PremiumSectionCard extends StatefulWidget {
  final int index;
  final String emoji;
  final String title;
  final Color accentColor;
  final String? badge;
  final bool isDarker;
  final List<Widget> children;

  const _PremiumSectionCard({
    required this.index,
    required this.emoji,
    required this.title,
    required this.accentColor,
    this.badge,
    this.isDarker = false,
    required this.children,
  });

  @override
  State<_PremiumSectionCard> createState() => _PremiumSectionCardState();
}

class _PremiumSectionCardState extends State<_PremiumSectionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<double> _slideY;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    final delay = (widget.index * 0.1).clamp(0.0, 0.5);
    final end = (delay + 0.5).clamp(0.0, 1.0);

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Interval(delay, end, curve: Curves.easeOutQuart),
      ),
    );
    _slideY = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Interval(delay, end, curve: Curves.easeOutCubic),
      ),
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideY.value),
          child: Opacity(opacity: _opacity.value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.isDarker
                    ? Colors.black.withOpacity(0.5)
                    : const Color(0xFF13111C).withOpacity(0.85),
                borderRadius: BorderRadius.circular(16),
                border: Border(
                  top: BorderSide(
                    color: widget.accentColor.withOpacity(0.4),
                    width: 1.5,
                  ),
                  left: BorderSide(
                    color: widget.accentColor.withOpacity(0.1),
                    width: 1,
                  ),
                  right: BorderSide(
                    color: widget.accentColor.withOpacity(0.1),
                    width: 1,
                  ),
                  bottom: BorderSide(
                    color: widget.accentColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: widget.accentColor.withOpacity(0.05),
                    blurRadius: 20,
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(widget.emoji, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.title.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                color: widget.accentColor.withOpacity(0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.badge != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: widget.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: widget.accentColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        widget.badge!,
                        style: TextStyle(
                          color: widget.accentColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  ...widget.children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Premium Çark Metrikleri (Holographic Brain Yerine) ──
class _PremiumCosmicMetrics extends StatelessWidget {
  final DreamDistribution distribution;
  final bool isTr;

  const _PremiumCosmicMetrics({required this.distribution, required this.isTr});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0910), // Ultra dark
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFB39DDB).withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isTr ? 'BİLİNÇDIŞI FREKANSLAR' : 'UNCONSCIOUS FREQUENCIES',
            style: const TextStyle(
              color: Color(0xFF9FA8DA),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 3.0,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOrb(
                isTr ? 'DUYGU YÜKÜ' : 'EMOTION',
                distribution.emotionalLoad,
                const Color(0xFFE040FB),
              ),
              _buildOrb(
                isTr ? 'BELİRSİZLİK' : 'ENTROPY',
                distribution.uncertainty,
                const Color(0xFF26C6DA),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOrb(
                isTr ? 'BEYİN AKT.' : 'ACTIVITY',
                distribution.brainActivity,
                const Color(0xFFFFCA28),
              ),
              _buildOrb(
                isTr ? 'YAKIN GEÇMİŞ' : 'RESIDUE',
                distribution.recentMemoryEffect,
                const Color(0xFF66BB6A),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrb(String label, int value, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [color.withOpacity(0.15), Colors.transparent],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                value: value / 100,
                strokeWidth: 3,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(
              '$value%',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                shadows: [Shadow(color: color, blurRadius: 6)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.8),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

class _ClinicalMainThemeCard extends StatelessWidget {
  final bool isTr;
  final String title;
  final String summary;
  final int uncertainty;

  const _ClinicalMainThemeCard({
    required this.isTr,
    required this.title,
    required this.summary,
    required this.uncertainty,
  });

  String get _confidenceText {
    if (uncertainty < 30) return isTr ? 'Yüksek Güven' : 'High Confidence';
    if (uncertainty < 70) return isTr ? 'Orta Güven' : 'Moderate Confidence';
    return isTr ? 'Düşük Güven' : 'Low Confidence';
  }

  Color get _confidenceColor {
    if (uncertainty < 30) return const Color(0xFF26A69A); // Yüksek -> Teal
    if (uncertainty < 70) return const Color(0xFFFFA726); // Orta -> Turuncu
    return const Color(0xFFEF5350); // Düşük -> Kırmızı
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isTr ? 'ANA TEMATİK ÖRÜNTÜ' : 'CORE THEMATIC PATTERN',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _confidenceColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _confidenceColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          uncertainty < 30
                              ? Icons.check_circle_outline
                              : (uncertainty < 70
                                    ? Icons.info_outline
                                    : Icons.warning_amber_outlined),
                          color: _confidenceColor,
                          size: 13,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _confidenceText,
                          style: TextStyle(
                            color: _confidenceColor,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                summary,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 14.5,
                  height: 1.6,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClinicalMetricsPanel extends StatefulWidget {
  final bool isTr;
  final DreamDistribution distribution;

  const _ClinicalMetricsPanel({
    Key? key,
    required this.isTr,
    required this.distribution,
  }) : super(key: key);

  @override
  State<_ClinicalMetricsPanel> createState() => _ClinicalMetricsPanelState();
}

class _ClinicalMetricsPanelState extends State<_ClinicalMetricsPanel>
    with SingleTickerProviderStateMixin {
  int? _selectedIndex;
  late AnimationController _ringAnimController;
  late Animation<double> _ringAnim;

  @override
  void initState() {
    super.initState();
    _ringAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _ringAnim = CurvedAnimation(
      parent: _ringAnimController,
      curve: Curves.easeOutCubic,
    );
    // Kısa gecikme ile animasyonu başlat (sayfa açılışından sonra)
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _ringAnimController.forward();
    });
  }

  @override
  void dispose() {
    _ringAnimController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _metrics => [
    {
      'percentage': widget.distribution.emotionalLoad / 100.0,
      'title': widget.isTr ? 'Duygusal\nYoğunluk' : 'Emotional\nLoad',
      'color': const Color(
        0xFFDCA4FF,
      ), // Yumu\u015fat\u0131lm\u0131\u015f lila/pembe
      'reasoning': widget.distribution.emotionalLoadReasoning,
      'description': widget.isTr
          ? 'Rüyan sırasında beyninin duygusal merkezi (amigdala) ne kadar yoğun çalıştı. Yüksekse rüyanda güçlü duygular (huzur, mutluluk, korku, heyecan) yaşandı.'
          : 'How intensely your brain\'s emotional center was activated during this dream.',
    },
    {
      'percentage': widget.distribution.uncertainty / 100.0,
      'title': widget.isTr
          ? 'Anlatısal\nBelirsizlik'
          : 'Narrative\nUncertainty',
      'color': const Color(0xFF9BA6FF), // Yumu\u015fat\u0131lm\u0131\u015f mavi
      'reasoning': widget.distribution.uncertaintyReasoning,
      'description': widget.isTr
          ? 'Rüyanda ne kadar mantıksız veya tutarsız olay yaşandı. Yüksekse mekanlar aniden değişti, olaylar mantığa aykırıydı.'
          : 'How illogical or inconsistent your dream narrative was.',
    },
    {
      'percentage': widget.distribution.recentMemoryEffect / 100.0,
      'title': widget.isTr ? 'Yakın\nGeçmiş' : 'Recent\nConnection',
      'color': const Color(
        0xFF8ADABD,
      ), // Yumu\u015fat\u0131lm\u0131\u015f mint ye\u015fili
      'reasoning': widget.distribution.recentMemoryReasoning,
      'description': widget.isTr
          ? 'Rüyanın ne kadarı son günlerde yaşadığın gerçek olaylardan etkilenmiş. Yüksekse beynin günlük anıları rüyada işliyor.'
          : 'How much of your dream was influenced by recent real-life events.',
    },
    {
      'percentage': widget.distribution.brainActivity / 100.0,
      'title': widget.isTr ? 'Ajans /\nKontrol' : 'Agency /\nControl',
      'color': const Color(
        0xFF86D2E1,
      ), // Yumu\u015fat\u0131lm\u0131\u015f cam g\u00f6be\u011fi
      'reasoning': widget.distribution.brainActivityReasoning,
      'description': widget.isTr
          ? 'Rüyanda olayları ne kadar kontrol edebildin. Düşükse sadece izledin, yüksekse kararlar aldın ve müdahale ettin.'
          : 'How much control you had over events in your dream.',
    },
  ];

  String _severityLabel(double pct) {
    final p = (pct * 100).toInt();
    if (p >= 70) return widget.isTr ? 'Yüksek' : 'High';
    if (p >= 35) return widget.isTr ? 'Normal' : 'Normal';
    return widget.isTr ? 'Düşük' : 'Low';
  }

  Color _severityColor(double pct) {
    final p = (pct * 100).toInt();
    if (p >= 70) return const Color(0xFFFF8A65);
    if (p >= 35) return const Color(0xFF81C784);
    return const Color(0xFF90CAF9);
  }

  @override
  Widget build(BuildContext context) {
    final selectedMetric = _selectedIndex != null
        ? _metrics[_selectedIndex!]
        : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.donut_large,
                    color: Colors.white.withOpacity(0.5),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.isTr ? 'BİLİŞSEL DAĞILIM' : 'COGNITIVE DISTRIBUTION',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AnimatedBuilder(
                animation: _ringAnim,
                builder: (context, _) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(_metrics.length * 2 - 1, (i) {
                      if (i.isOdd) return const SizedBox(width: 8);
                      final index = i ~/ 2;
                      final m = _metrics[index];
                      final isSelected = _selectedIndex == index;
                      final pct = m['percentage'] as double;
                      final animPct = pct * _ringAnim.value;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(
                            () => _selectedIndex = isSelected ? null : index,
                          ),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _selectedIndex == null || isSelected
                                ? 1.0
                                : 0.5,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 72,
                                    height: 72,
                                    child: CustomPaint(
                                      painter: _PremiumRingPainter(
                                        animPct,
                                        m['color'],
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${(animPct * 100).toInt()}%',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 19,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 28,
                                    child: Text(
                                      m['title'],
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9.5,
                                        height: 1.2,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _severityColor(
                                        pct,
                                      ).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      _severityLabel(pct),
                                      style: TextStyle(
                                        color: _severityColor(pct),
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: selectedMetric != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: (selectedMetric['color'] as Color)
                                .withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: (selectedMetric['color'] as Color)
                                  .withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: selectedMetric['color'],
                                    size: 14,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${selectedMetric['title'].toString().replaceAll('\n', ' ').toUpperCase()} — ${_severityLabel(selectedMetric['percentage'])}',
                                      style: TextStyle(
                                        color: selectedMetric['color'],
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                selectedMetric['description'] ?? '',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 11.5,
                                  height: 1.4,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: Container(
                                  height: 1,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        (selectedMetric['color'] as Color)
                                            .withOpacity(0.25),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Icon(
                                      Icons.arrow_forward,
                                      color: selectedMetric['color'],
                                      size: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      (selectedMetric['reasoning'] as String)
                                              .isNotEmpty
                                          ? selectedMetric['reasoning']
                                          : (widget.isTr
                                                ? 'Bu metrik için özel bir açıklama üretilmemiş.'
                                                : 'No reasoning generated.'),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 12.5,
                                        height: 1.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumRingPainter extends CustomPainter {
  final double percentage;
  final Color baseColor;

  _PremiumRingPainter(this.percentage, this.baseColor);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 4; // leave room for stroke

    // Background track
    final trackPaint = Paint()
      ..color = baseColor.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawCircle(center, radius, trackPaint);

    if (percentage > 0) {
      final sweepAngle = 2 * 3.14159265359 * percentage;
      final startAngle = -3.14159265359 / 2; // Start from top

      // Glow effect
      final glowPaint = Paint()
        ..color = baseColor.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0)
        ..strokeCap = StrokeCap.round;

      // Solid inner ring
      final ringPaint = Paint()
        ..color = baseColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        glowPaint,
      );

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        ringPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PremiumRingPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.baseColor != baseColor;
  }
}

class _ClinicalEvidenceSection extends StatelessWidget {
  final bool isTr;
  final DeepAnalysisResult analysis;
  const _ClinicalEvidenceSection({required this.isTr, required this.analysis});

  @override
  Widget build(BuildContext context) {
    // Collect evidences from timeline and symbols
    final evidenceItems = <Map<String, dynamic>>[];

    // Nöro-bilim bulgusu
    if (analysis.brainScience.mechanism.isNotEmpty) {
      evidenceItems.add({
        'icon': Icons.psychology,
        'title': isTr ? 'Nörolojik Taban' : 'Neurological Basis',
        'text': analysis.brainScience.mechanism,
        'color': const Color(0xFFD500F9), // Purple neon
      });
    }

    // Semboller için çok daha parlak (Neon/Vivid) ikon ve renk paletleri
    final List<IconData> symbolIcons = [
      Icons.auto_awesome,
      Icons.scatter_plot,
      Icons.filter_tilt_shift,
      Icons.toll,
      Icons.flare,
    ];
    final List<Color> symbolColors = [
      const Color(0xFF18FFFF), // Ultra Parlak Cyan
      const Color(0xFFFF1744), // Ateşli Kırmızı/Pembe
      const Color(0xFFFFEA00), // Floresan Sarı/Kehribar
      const Color(0xFF00E676), // Fosforlu Yeşil
      const Color(0xFFD500F9), // Elektrik Mor
    ];

    int sIndex = 0;
    for (final sym in analysis.symbols) {
      evidenceItems.add({
        'icon': symbolIcons[sIndex % symbolIcons.length],
        'title': sym.name,
        'text': sym.personalReflection,
        'color':
            symbolColors[sIndex %
                symbolColors.length], // Opacity yok, en parlak hali
      });
      sIndex++;
    }

    // Timeline son sahneyi al (Kırılma noktası)
    if (analysis.timeline.isNotEmpty) {
      final lastScene = analysis.timeline.last;
      evidenceItems.add({
        'icon': Icons.timeline,
        'title': lastScene.title,
        'text': lastScene.psychologicalShift,
        'color': const Color(0xFF536DFE), // Blue neon
      });
    }

    if (evidenceItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 16),
          child: Row(
            children: [
              Icon(Icons.hub, color: Colors.white.withOpacity(0.5), size: 16),
              const SizedBox(width: 8),
              Text(
                isTr ? 'BU SONUCA NEDEN VARDIK?' : 'EVIDENCE BASE',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height:
              145, // Metinler artık çok kısa olacağı için panelleri gereksiz uzatmadık
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            clipBehavior: Clip.none,
            itemCount: evidenceItems.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final item = evidenceItems[index];
              return Container(
                width:
                    215, // Çok uzun ve hantal olmamaları için genişliği azalttık
                margin: EdgeInsets.only(
                  right: index == evidenceItems.length - 1 ? 0 : 12,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                item['icon'],
                                color: item['color'] ?? Colors.white70,
                                size: 18,
                              ), // Matlığı kaldırdık, tam parlaklık (18px)
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item['title'].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Text(
                                item['text'],
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 12,
                                  height: 1.45,
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
          ),
        ),
      ],
    );
  }
}

class _ClinicalAccordion extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final String content;

  const _ClinicalAccordion({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.content,
  });

  @override
  State<_ClinicalAccordion> createState() => _ClinicalAccordionState();
}

class _ClinicalAccordionState extends State<_ClinicalAccordion> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: _isExpanded
                  ? Colors.black.withOpacity(0.4)
                  : Colors.black.withOpacity(0.2),
              border: Border.all(
                color: _isExpanded
                    ? const Color(0xFF7C6CF3).withOpacity(0.3)
                    : Colors.white.withOpacity(0.08),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      widget.icon,
                      color: Colors.white.withOpacity(0.5),
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              color: _isExpanded
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.8),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (widget.subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              widget.subtitle!,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ],
                ),
                if (_isExpanded) ...[
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFF39374C), height: 1),
                  const SizedBox(height: 16),
                  Text(
                    widget.content,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ClinicalReflectionQuestion extends StatefulWidget {
  final bool isTr;
  final String questionText;
  final Map<String, String> reflectionResponses;
  final String? initialSelectedAction;
  final Function(String)? onAnswerSelected;

  const _ClinicalReflectionQuestion({
    required this.isTr,
    required this.questionText,
    required this.reflectionResponses,
    this.initialSelectedAction,
    this.onAnswerSelected,
  });

  @override
  State<_ClinicalReflectionQuestion> createState() =>
      _ClinicalReflectionQuestionState();
}

class _ClinicalReflectionQuestionState
    extends State<_ClinicalReflectionQuestion> {
  String? _selectedAction;
  bool _isAnalyzing = false;
  String _displayedText = '';
  String _fullText = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialSelectedAction != null) {
      _selectedAction = widget.initialSelectedAction;
      _fullText =
          widget.reflectionResponses[_selectedAction!] ??
          (widget.isTr
              ? 'Bu farkındalık yeni bir yolun başlangıcıdır. Şimdi yüzleşme zamanı.'
              : 'This awareness is the start of a new path. It is time to face it.');
      _displayedText = _fullText;
    }
  }

  void _onActionSelected(String actionKey) async {
    if (_selectedAction != null) return; // Sadece bir kere seçime izin ver

    setState(() {
      _selectedAction = actionKey;
      _isAnalyzing = true;
    });

    if (widget.onAnswerSelected != null) {
      widget.onAnswerSelected!(actionKey);
    }

    // Yapay zeka cevap hazırlıyormuş gibi 1.5 saniye bekle
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    setState(() {
      _isAnalyzing = false;
      _fullText =
          widget.reflectionResponses[actionKey] ??
          (widget.isTr
              ? 'Bu farkındalık yeni bir yolun başlangıcıdır. Şimdi yüzleşme zamanı.'
              : 'This awareness is the start of a new path. It is time to face it.');
    });

    // Yazı daktilo (typewriter) efekti
    for (int i = 0; i <= _fullText.length; i++) {
      if (!mounted) return;
      setState(() {
        _displayedText = _fullText.substring(0, i);
      });
      await Future.delayed(const Duration(milliseconds: 30)); // Daktilo hızı
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questionText.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7C6CF3).withOpacity(0.1),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFF7C6CF3).withOpacity(0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.my_location, color: const Color(0xFFB39DDB), size: 28),
          const SizedBox(height: 16),
          Text(
            widget.isTr ? 'Rüyanın Gerçek Sebebi' : 'Root Cause',
            style: const TextStyle(
              color: Color(0xFFB39DDB),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.questionText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildReflectionBtn(
                  widget.isTr ? 'Kesinlikle' : 'Absolutely',
                  'absolutely',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildReflectionBtn(
                  widget.isTr ? 'Olabilir' : 'Maybe',
                  'maybe',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildReflectionBtn(
                  widget.isTr ? 'Emin Değilim' : 'Not Sure',
                  'not_sure',
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.fastOutSlowIn,
            child: _selectedAction != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: _buildResponseArea(),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionBtn(String label, String actionKey) {
    final isSelected = _selectedAction == actionKey;
    final isAnySelected = _selectedAction != null;

    final opacity = isAnySelected ? (isSelected ? 1.0 : 0.3) : 1.0;

    return _AnimatedBounceButton(
      onTap: () => _onActionSelected(actionKey),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: opacity,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withOpacity(0.12)
                : Colors.white.withOpacity(0.04),
            border: Border.all(
              color: isSelected
                  ? Colors.white.withOpacity(0.5)
                  : Colors.white.withOpacity(0.15),
              width: isSelected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(isSelected ? 1.0 : 0.9),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResponseArea() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05), // Frosted glass tint
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C6CF3).withOpacity(0.05),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _isAnalyzing
              ? Column(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFB39DDB),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.isTr
                          ? 'Klinik sonuç derleniyor...'
                          : 'Gathering clinical deduction...',
                      style: const TextStyle(
                        color: Color(0xFFB39DDB),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.psychology_alt,
                          color: Color(0xFFB39DDB),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.isTr ? 'KLİNİK TESPİT' : 'CLINICAL DEDUCTION',
                          style: const TextStyle(
                            color: Color(0xFFB39DDB),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _displayedText +
                          (_displayedText.length < _fullText.length
                              ? '...'
                              : ''),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _DummyError extends StatelessWidget {
  // Sadece hata veya aracı sınıflar varsa engellememek için
  @override
  Widget build(BuildContext context) => const SizedBox();
}

class _ClinicalAnswersSection extends StatelessWidget {
  final bool isTr;
  final List<Map<String, dynamic>> answers;
  final List<ClarifyingInsight> insights;
  final String globalInsight;

  const _ClinicalAnswersSection({
    required this.isTr,
    required this.answers,
    required this.insights,
    required this.globalInsight,
  });

  @override
  Widget build(BuildContext context) {
    if (answers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 20),
          child: Row(
            children: [
              Icon(
                Icons.timeline,
                color: Colors.white.withOpacity(0.5),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                isTr ? 'ANALİZİ NETLEŞTİREN YANITLAR' : 'CLARIFYING RESPONSES',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ...answers.asMap().entries.expand((entry) {
                final int idx = entry.key;
                final qa = entry.value;
                final bool isYes = qa['answer'] == 'yes';
                final bool isNo = qa['answer'] == 'no';
                final String ansText = isYes
                    ? (isTr ? 'EVET' : 'YES')
                    : (isNo ? (isTr ? 'HAYIR' : 'NO') : (isTr ? '?' : '?'));
                final Color ansColor = isYes
                    ? const Color(0xFF69F0AE)
                    : (isNo
                          ? const Color(0xFFFF5252)
                          : const Color(0xFFFFD740));

                final String questionId = qa['questionId']?.toString() ?? '';
                final matchingInsight =
                    insights
                        .where(
                          (i) =>
                              i.questionId == questionId ||
                              i.questionId.contains(questionId),
                        )
                        .firstOrNull
                        ?.insight ??
                    '';

                return [
                  // Soru ve Yanıt (Node Kutusu)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(
                        0.04,
                      ), // Yarı saydam arka plan
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Sol taraftaki renkli bar
                            Container(
                              width: 3.5,
                              height: 18,
                              decoration: BoxDecoration(
                                color: ansColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Soru ve Cevap
                            Expanded(
                              child: Text(
                                qa['question'],
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              ansText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        if (matchingInsight.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 17.5,
                              ), // Renkli bar ve spacing hizalaması
                              Icon(
                                Icons.subdirectory_arrow_right,
                                color: Colors.white.withOpacity(0.3),
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  matchingInsight,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Bağlantı Çizgisi (Ara çizgi veya ok)
                  if (idx < answers.length - 1)
                    Container(
                      height: 24,
                      width: 1.5,
                      color: Colors.white.withOpacity(0.15),
                    )
                  else if (globalInsight.isNotEmpty && globalInsight != 'null')
                    SizedBox(
                      height: 32,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 1.5,
                            height: 12,
                            color: Colors.white.withOpacity(0.15),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white.withOpacity(0.3),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                ];
              }),

              if (globalInsight.isNotEmpty && globalInsight != 'null')
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF7C6CF3,
                    ).withOpacity(0.08), // Morumsu özel vurgu
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF7C6CF3).withOpacity(0.2),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.psychology,
                        color: Color(0xFFB39DDB),
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          globalInsight,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PremiumReveal extends StatefulWidget {
  final Widget child;
  final int index;
  const _PremiumReveal({Key? key, required this.child, this.index = 0})
    : super(key: key);

  @override
  State<_PremiumReveal> createState() => _PremiumRevealState();
}

class _PremiumRevealState extends State<_PremiumReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // Initial load stagger for top items, quick appear for items lazily loaded upon scrolling down
    final delay = widget.index < 4 ? widget.index * 150 : 50;

    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class _AnimatedBounceButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _AnimatedBounceButton({Key? key, required this.child, this.onTap})
    : super(key: key);

  @override
  State<_AnimatedBounceButton> createState() => _AnimatedBounceButtonState();
}

class _AnimatedBounceButtonState extends State<_AnimatedBounceButton> {
  bool _isPressed = false;
  DateTime? _pressedAt;

  void _handleTapDown(TapDownDetails _) {
    _pressedAt = DateTime.now();
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    final elapsed = DateTime.now()
        .difference(_pressedAt ?? DateTime.now())
        .inMilliseconds;
    // Minimum 180ms basılı kalsın ki efekt gözle görülsün
    final remaining = (180 - elapsed).clamp(0, 180);

    Future.delayed(Duration(milliseconds: remaining), () {
      if (!mounted) return;
      setState(() => _isPressed = false);

      // Geri sıçrama animasyonunun bitmesini bekle, sonra aksiyonu çalıştır
      Future.delayed(const Duration(milliseconds: 160), () {
        if (mounted && widget.onTap != null) {
          widget.onTap!();
        }
      });
    });
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _pressedAt = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap != null ? _handleTapDown : null,
      onTapUp: widget.onTap != null ? _handleTapUp : null,
      onTapCancel: widget.onTap != null ? _handleTapCancel : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _isPressed ? 0.5 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: widget.child,
        ),
      ),
    );
  }
}
