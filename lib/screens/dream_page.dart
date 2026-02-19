import 'dart:math' as math;
import 'dart:ui';
import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:share_plus/share_plus.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';
import '../constants/colors.dart';
import '../widgets/bottom_nav.dart';
import '../services/storage_service.dart';
import '../services/dream_analysis_service.dart';
import '../models/emotion.dart';
import '../models/dream_analysis.dart';
import '../models/dream_input.dart';
import '../models/clarification_answer.dart';
import '../widgets/stars_background.dart';
import '../widgets/fade_page_route.dart';
import 'home_page.dart';
import 'collection_page.dart';
import 'profile_page.dart';

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

  List<String> _dreamPromptsFor() =>
      _isTr ? _dreamPromptsTr : _dreamPromptsEn;

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
  late final List<Emotion> _emotionOrder;
  late String _currentPrompt;
  late String _currentSubtitle;
  final DreamAnalysisService _analysisService = DreamAnalysisService();
  String? _lastLocaleCode;
  bool _localizedSeedsReady = false;

  // Bilimsel eğitici metinler (loading sırasında gösterilecek)
  static const List<String> _educationalMessagesTr = [
    '🧠 REM uykusunda mantık merkezleri baskılanır, bu yüzden rüyalar mantıksız görünür.',
    '💤 Rüyalar genellikle yakın dönemde yaşanan duygusal deneyimleri işler.',
    '🔬 Beyin, rüya sırasında anıları düzenler ve güçlendirir.',
    '✨ Lucid rüya, rüyada olduğunuzu fark etme ve kontrol edebilme yeteneğidir.',
    '🌙 Ortalama bir insan gecede 4-6 rüya görür, ancak çoğunu hatırlamaz.',
    '💭 Rüya görmek, zihinsel sağlığın bir işaretidir.',
    '🧬 REM uykusu problem çözme ve yaratıcılığı artırır.',
    '⚡ Beyniniz rüya sırasında uyanıkken olduğu kadar aktiftir.',
    '🎭 Tekrarlayan rüyalar, çözülmemiş duygusal sorunlara işaret edebilir.',
    '🌊 Su içeren rüyalar genellikle duygu durumu ile ilişkilidir.',
    '🚀 Uçma rüyaları özgürlük ve kontrol hissi ile bağlantılıdır.',
    '⏰ Sabah saatlerinde gördüğünüz rüyaları daha iyi hatırlarsınız.',
    '📝 Rüya günlüğü tutmak, rüya hatırlama yeteneğinizi geliştirir.',
    '🔄 Rüyalar, beynin "simülasyon" yaparak olası senaryoları çalıştırmasıdır.',
    '💡 Stres azaldığında kabus görme sıklığı da azalır.',
  ];
  static const List<String> _educationalMessagesEn = [
    '🧠 During REM sleep, logic centers are suppressed, so dreams can seem illogical.',
    '💤 Dreams often process recent emotional experiences.',
    '🔬 The brain organizes and strengthens memories during dreaming.',
    '✨ Lucid dreaming is the ability to realize you are dreaming and control it.',
    '🌙 An average person has 4-6 dreams per night, but forgets most of them.',
    '💭 Dreaming is a sign of mental health.',
    '🧬 REM sleep boosts problem solving and creativity.',
    '⚡ Your brain is nearly as active during dreams as when awake.',
    '🎭 Recurring dreams can indicate unresolved emotional issues.',
    '🌊 Water in dreams is often linked to emotional state.',
    '🚀 Flying dreams are linked to freedom and control.',
    '⏰ You remember dreams better in the early morning.',
    '📝 Keeping a dream journal improves recall.',
    '🔄 Dreams are the brain’s simulation of possible scenarios.',
    '💡 As stress decreases, nightmares become less frequent.',
  ];
  static const String _notAnalyzableMessageTr =
      'Yazdığın metinde analiz edilebilir bir rüya sahnesi bulamadım.';
  static const String _notAnalyzableMessageEn =
      'I could not find a dream scene in your text that can be analyzed.';

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

  void _closeWritingModal() {
    setState(() {
      _analysisOverlayVisible = false;
    });

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

  Future<bool> _interpretDream() async {
    final trimmed = _dreamController.text.trim();
    if (trimmed.length < 15) {
      return false;
    }
    if (_selectedEmotion == null) {
      return false;
    }

    final isAnalyzable = _analysisService.hasAnalyzableScene(trimmed);

    // YENİ BİLİMSEL SİSTEM
    final dreamInput = DreamInput(
      text: _dreamController.text,
      emotions: [_selectedEmotion!], // Artık kesinlikle null değil
    );

    DreamAnalysis? analysis;
    final clarificationQuestions = <_ClarificationQuestion>[];
    var questionCount = 0;
    if (isAnalyzable) {
      // Bilişsel analiz (deterministik)
      analysis = _analysisService.analyzeDream(dreamInput.text);

      clarificationQuestions.addAll(
        _buildClarificationQuestions(analysis, _selectedEmotion!),
      );
      questionCount = clarificationQuestions.length;
    }

    // Bilimsel eğitici mesaj göster
    final messages = _educationalMessagesFor();
    final randomMessage =
        messages[math.Random().nextInt(messages.length)];
    final notAnalyzableMessage = _notAnalyzableMessage;

    final answersCompleter = Completer<List<ClarificationAnswer>>();
    final retryCompleter = Completer<void>();
    _answersCompleter = answersCompleter;
    _retryCompleter = retryCompleter;
    setState(() {
      _showAnalysisOverlay = true;
      _analysisOverlayVisible = false;
      _overlayContent = 'analyzing';
      _overlayRandomMessage = randomMessage;
      _overlayNotAnalyzableMessage = notAnalyzableMessage;
      _overlayShowNotAnalyzable = !isAnalyzable;
      _overlayQuestions = List<_ClarificationQuestion>.from(
        clarificationQuestions,
      );
      _overlayAccentColor = _resolveEmotionAccentColor(_selectedEmotion);
    });

    // Yumuşak açılış animasyonu - frame sonrası tetikle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _analysisOverlayVisible = true);
      }
    });

    if (!isAnalyzable) {
      await retryCompleter.future;
      if (mounted) {
        setState(() {
          _analysisOverlayVisible = false;
          _showAnalysisOverlay = false;
        });
        _dreamFocusNode.requestFocus();
      }
      _answersCompleter = null;
      _retryCompleter = null;
      return false;
    }

    List<ClarificationAnswer> clarificationAnswers = [];
    if (clarificationQuestions.isNotEmpty) {
      clarificationAnswers = await answersCompleter.future;
    } else {
      await Future.delayed(const Duration(milliseconds: 1800));
    }

    if (clarificationQuestions.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Bilimsel yorum üret
    final interpretation = _analysisService.interpret(
      input: dreamInput,
      analysis: analysis!,
      answers: clarificationAnswers,
    );

    if (mounted) {
      setState(() {
        _latestAnalysis = analysis;
        _latestClarifications = clarificationAnswers;
      });
    }

    // Eski sistem için backward compatibility
    final dream = _dreamController.text.toLowerCase();
    _detectedSymbols = _localizeSymbols(_detectSymbols(dream));
    _generalAnalysis = interpretation; // Bilimsel yorum
    _psychologyAnalysis = interpretation; // Aynı yorum (tek kaynak)
    _spiritualAnalysis = interpretation;
    _advice = interpretation;

    // Otomatik başlık oluştur
    final autoTitle = _generateTitle(
      _dreamController.text,
      _detectedSymbols,
      _selectedEmotion,
    );

    // Rüyayı kaydet
    final now = DateTime.now().toIso8601String();
    await StorageService.saveDream({
      'title': autoTitle,
      'text': _dreamController.text,
      'mood': _selectedEmotion?.name ?? _selectedMood,
      'emotion': _selectedEmotion?.name,
      'date': now,
      'symbols': _detectedSymbols,
      'general': _generalAnalysis,
      'psychology': _psychologyAnalysis,
      'spiritual': _spiritualAnalysis,
      'advice': _advice,
      'scientificInterpretation': interpretation,
      'questionCount': questionCount,
      if (clarificationAnswers.isNotEmpty)
        'clarification': clarificationAnswers.map((e) => e.toJson()).toList(),
    });

    await StorageService.setDreamDoneToday();

    if (mounted) {
      // Önce analiz içeriğini kapat (boş geçiş), sonra yorum aç
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
    _answersCompleter = null;
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
    final bottomContentPadding = MediaQuery.of(context).padding.bottom + 160;

    return Scaffold(
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
          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.translucent,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(20, 40, 20, bottomContentPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 6, 0, 12),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: AppColors.textWhite,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Text(
                          _l10n.dreamTitle,
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
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
                          onTap: () => setState(() => _currentTab = 0),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _TabButton(
                          label: _l10n.dreamTabHistory,
                          isActive: _currentTab == 1,
                          onTap: () => setState(() => _currentTab = 1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Content
                  _currentTab == 0 ? _buildNewDreamTab() : _buildHistoryTab(),
                ],
              ),
            ),
          ),
          if (_showAnalysisOverlay || _isWriting)
            Positioned.fill(child: _buildUnifiedOverlay()),
          if (_activeMetric != null && _overlayContent == 'results')
            Positioned.fill(child: _buildMetricOverlay()),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (index == _currentNavIndex) return;
          Widget destination;
          switch (index) {
            case 0:
              destination = const HomePage();
              break;
            case 1:
              destination = const CollectionPage();
              break;
            case 2:
              destination = const ProfilePage();
              break;
            default:
              return;
          }
          Navigator.pushReplacement(context, FadePageRoute(page: destination));
        },
      ),
    );
  }

  Widget _buildNewDreamTab() {
    final activeColors = [
      const Color(0xFF9B7FFF),
      const Color(0xFFAA90FF),
      const Color(0xFFB8A8FF),
      const Color(0xFFC0BCFF),
      const Color(0xFFA8C8FF),
      const Color(0xFF8BD5FF),
      const Color(0xFF7DDBFF),
    ];
    final halfColors = activeColors
        .map((color) => color.withOpacity(0.8))
        .toList();
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
                const SizedBox(height: 20),
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
                const SizedBox(height: 36),
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
                    const SizedBox(height: 32),
                    AnimatedScale(
                      scale: _showMoodPulse ? 1.05 : 1.0,
                      duration: const Duration(milliseconds: 110),
                      curve: Curves.easeOut,
                      child: _buildMoodRail(),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                // Submit Button
                ValueListenableBuilder<bool>(
                  valueListenable: _hasDreamTextNotifier,
                  builder: (context, hasDreamText, child) {
                    final hasEmotion = _selectedEmotion != null;
                    final isActive = hasDreamText && hasEmotion;
                    final isHalfActive =
                        (hasDreamText || hasEmotion) && !isActive;
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: GlassButton.custom(
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
                          await _interpretDream();
                        },
                        useOwnLayer: true,
                        quality: GlassQuality.standard,
                        shape: const LiquidRoundedSuperellipse(
                          borderRadius: 30,
                        ),
                        interactionScale: 0.97,
                        stretch: 0.25,
                        resistance: 0.08,
                        glowColor: const Color(0xFF7C6CF3).withOpacity(
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
                          borderRadius: BorderRadius.circular(30),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: isActive
                                          ? activeColors
                                          : (isHalfActive
                                                ? halfColors
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
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _l10n.dreamAnalyzeButton,
                                      style: const TextStyle(
                                        color: AppColors.textWhite,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _l10n.dreamAnalyzeEstimate,
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
                      ),
                    );
                  },
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

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: _analysisOverlayVisible ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 600),
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
                          begin: const Offset(0, 0.05),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _overlayContent == 'analyzing'
                      ? _buildAnalysisContent(key: const ValueKey('analyzing'))
                      : _overlayContent == 'results'
                      ? _buildInterpretationContent(
                          key: const ValueKey('results'),
                          topPadding: topPadding,
                          bottomPadding: bottomPadding,
                        )
                      : const SizedBox.shrink(key: ValueKey('gap')),
                ),
              ),
            ),
          ),
        );
      },
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
              padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 16),
              child: Row(
                children: [
                  const SizedBox(width: 44),
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
                  GlassIconButton(
                    icon: Icons.close,
                    onPressed: _closeWritingModal,
                    size: 44,
                  ),
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

  List<_ClarificationQuestion> _buildClarificationQuestions(
    DreamAnalysis analysis,
    Emotion emotion,
  ) {
    final questions = <_ClarificationQuestion>[];

    if (analysis.hasThreat) {
      questions.add(
        _ClarificationQuestion(
          id: 'threat',
          text: _l10n.dreamClarifyThreat,
        ),
      );
    }

    if (analysis.hasPastReference) {
      questions.add(
        _ClarificationQuestion(
          id: 'past',
          text: _l10n.dreamClarifyFamiliar,
        ),
      );
    }

    if (questions.isEmpty && analysis.hasMovement) {
      questions.add(
        _ClarificationQuestion(
          id: 'movement',
          text: _l10n.dreamClarifyEscape,
        ),
      );
    }

    if (questions.isEmpty &&
        (emotion == Emotion.anxiety || emotion == Emotion.fear)) {
      questions.add(
        _ClarificationQuestion(
          id: 'threat',
          text: _l10n.dreamClarifyAnxious,
        ),
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
              child: _MetricDescriptionCard(
                body: _metricDescription(metric),
              ),
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
          onPanUpdate: (details) => selectByDx(details.localPosition.dx),
          child: Column(
            children: [
              Row(
                children: emotions.map((emotion) {
                  final label = _emotionLabel(emotion);
                  final isSelected = _selectedEmotion == emotion;
                  final baseStyle = TextStyle(
                    color: isSelected
                        ? Colors.white.withOpacity(0.95)
                        : Colors.white.withOpacity(0.6),
                    fontSize: isSelected ? 12.5 : 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
            return GestureDetector(
              onTap: () => _showDreamDetail(dream),
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.textWhite.withOpacity(0.05),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.isNotEmpty ? title : _l10n.dreamDefaultTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatted,
                            style: TextStyle(
                              color: AppColors.textWhite50,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (dream['mood'] != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryPurple.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              (() {
                                final storedMood = dream['mood']?.toString();
                                final moodEmotion =
                                    _emotionFromStored(storedMood);
                                return moodEmotion != null
                                    ? _emotionLabel(moodEmotion)
                                    : (storedMood ?? '');
                              })(),
                              style: const TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else
                          Text(
                            shortDate,
                            style: TextStyle(
                              color: AppColors.textWhite50,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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

  void _showDreamDetail(Map<String, dynamic> dream) {
    final title = (dream['title'] ?? '').toString().trim();
    final text = dream['text']?.toString() ?? '';
    final storedMood = dream['mood']?.toString();
    final moodEmotion = _emotionFromStored(storedMood);
    final moodLabel =
        moodEmotion != null ? _emotionLabel(moodEmotion) : storedMood;
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
      backgroundColor: const Color(0xFF0F1F2A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        String? enrichedText;
        var isEnriching = false;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            final canEnrich = _analysisService.canEnrich;
            final showEnrichButton = canEnrich && baseInterpretation.isNotEmpty;

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (context, scroll) {
                return SingleChildScrollView(
                  controller: scroll,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title.isNotEmpty
                                      ? title
                                      : _l10n.dreamDefaultTitle,
                                  style: const TextStyle(
                                    color: AppColors.textWhite,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  date,
                                  style: TextStyle(
                                    color: AppColors.textWhite50,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (moodLabel != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryPurple.withOpacity(
                                  0.15,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                moodLabel,
                                style: const TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (symbols.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: symbols
                              .map(
                                (s) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryPurple.withOpacity(
                                      0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    s,
                                    style: const TextStyle(
                                      color: AppColors.textWhite,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      const SizedBox(height: 14),
                      Text(
                        text,
                        style: const TextStyle(
                          color: AppColors.textWhite70,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (general != null && general.isNotEmpty)
                        _detailBlock('Genel Analiz', general),
                      if (psychology != null && psychology.isNotEmpty)
                        _detailBlock('Psikolojik', psychology),
                      if (spiritual != null && spiritual.isNotEmpty)
                        _detailBlock(_l10n.dreamSpiritual, spiritual),
                      if (advice != null && advice.isNotEmpty)
                        _detailBlock('Tavsiye', advice),
                      if (enrichedText != null && enrichedText!.isNotEmpty)
                        _detailBlock(_l10n.dreamEnriched, enrichedText!),
                      if (showEnrichButton) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isEnriching
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
                            icon: isEnriching
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.auto_fix_high, size: 18),
                            label: Text(
                              isEnriching
                                  ? _l10n.dreamEnriching
                                  : _l10n.dreamEnrich,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final shareText = _l10n.dreamShareText(
                              title.isNotEmpty ? title : _l10n.dreamDefaultTitle,
                              date,
                              text,
                              general ?? '',
                              psychology ?? '',
                              spiritual ?? '',
                              advice ?? '',
                            );
                            Share.share(shareText);
                          },
                          icon: const Icon(Icons.share, size: 18),
                          label: Text(_l10n.dreamShare),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
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

  Widget _detailBlock(String title, String body) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryPurple.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primaryPurple,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: AppColors.textWhite70,
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

    // Map sections to appropriate card types
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

    // If no sections, show default
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

  IconData _getIconForSection(String title) {
    if (title.contains('🧠') ||
        title.toLowerCase().contains('nöro') ||
        title.toLowerCase().contains('beyin')) {
      return Icons.psychology;
    }
    if (title.contains('🔍') ||
        title.toLowerCase().contains('bilişsel') ||
        title.toLowerCase().contains('okuma')) {
      return Icons.search;
    }
    if (title.contains('👤') ||
        title.toLowerCase().contains('kişisel') ||
        title.toLowerCase().contains('bağ')) {
      return Icons.person_outline;
    }
    if (title.contains('📌') ||
        title.toLowerCase().contains('sonuç') ||
        title.toLowerCase().contains('dengeli')) {
      return Icons.push_pin;
    }
    if (title.toLowerCase().contains('duygu')) {
      return Icons.favorite_outline;
    }
    if (title.toLowerCase().contains('sembol')) {
      return Icons.auto_awesome;
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
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
      glowColor: AppColors.primaryPurple.withOpacity(isActive ? 0.45 : 0.18),
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
                        ? [
                            AppColors.primaryPurple.withOpacity(0.16),
                            AppColors.primaryTeal.withOpacity(0.12),
                          ]
                        : [
                            Colors.white.withOpacity(0.06),
                            Colors.white.withOpacity(0.02),
                          ],
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? AppColors.textWhite : AppColors.textWhite70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
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
                top:
                    centerY -
                    50, // Tam orta (çember + yazı yüksekliği ~100px, yarısı 50)
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
                    Text(
                      AppLocalizations.of(context)!.dreamAnalyzing,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            // Sorular ve butonlar - çemberin altında
            Positioned(
              left: 20,
              right: 20,
              top: centerY + 60, // Çemberin altında
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
      duration: const Duration(seconds: 10),
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
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
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
                          widget.title,
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
                    widget.body,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      height: 1.55,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 6,
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
