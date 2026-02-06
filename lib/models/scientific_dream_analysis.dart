/// Scientific Dream Analysis model
/// Based on psychology and neuroscience - NOT fortune telling
class ScientificDreamAnalysis {
  /// Brain Process Analysis - How the brain processed this dream
  final AnalysisSection brainProcess;

  /// Dominant Emotional Theme detected
  final AnalysisSection emotionalTheme;

  /// Mental Representation Explanation - What symbols represent mentally
  final AnalysisSection mentalRepresentation;

  /// Uncertainty & Stress Indicator
  final AnalysisSection stressIndicator;

  /// Recent Life Connection - How this relates to recent experiences
  final AnalysisSection lifeConnection;

  /// Scientific Summary - Overall scientific interpretation
  final AnalysisSection scientificSummary;

  const ScientificDreamAnalysis({
    required this.brainProcess,
    required this.emotionalTheme,
    required this.mentalRepresentation,
    required this.stressIndicator,
    required this.lifeConnection,
    required this.scientificSummary,
  });

  /// Parse from API response JSON
  factory ScientificDreamAnalysis.fromJson(Map<String, dynamic> json) {
    return ScientificDreamAnalysis(
      brainProcess: AnalysisSection.fromJson(
        json['brain_process'] as Map<String, dynamic>? ?? {},
        defaultTitle: 'Beyin Süreci Analizi',
        defaultIcon: 'brain',
      ),
      emotionalTheme: AnalysisSection.fromJson(
        json['emotional_theme'] as Map<String, dynamic>? ?? {},
        defaultTitle: 'Baskın Duygusal Tema',
        defaultIcon: 'heart',
      ),
      mentalRepresentation: AnalysisSection.fromJson(
        json['mental_representation'] as Map<String, dynamic>? ?? {},
        defaultTitle: 'Zihinsel Temsil',
        defaultIcon: 'lightbulb',
      ),
      stressIndicator: AnalysisSection.fromJson(
        json['stress_indicator'] as Map<String, dynamic>? ?? {},
        defaultTitle: 'Belirsizlik ve Stres Göstergesi',
        defaultIcon: 'warning',
      ),
      lifeConnection: AnalysisSection.fromJson(
        json['life_connection'] as Map<String, dynamic>? ?? {},
        defaultTitle: 'Yakın Dönem Yaşam Bağlantısı',
        defaultIcon: 'link',
      ),
      scientificSummary: AnalysisSection.fromJson(
        json['scientific_summary'] as Map<String, dynamic>? ?? {},
        defaultTitle: 'Bilimsel Özet',
        defaultIcon: 'science',
      ),
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
        'brain_process': brainProcess.toJson(),
        'emotional_theme': emotionalTheme.toJson(),
        'mental_representation': mentalRepresentation.toJson(),
        'stress_indicator': stressIndicator.toJson(),
        'life_connection': lifeConnection.toJson(),
        'scientific_summary': scientificSummary.toJson(),
      };

  /// Get all sections as a list for UI rendering
  List<AnalysisSection> get allSections => [
        brainProcess,
        emotionalTheme,
        mentalRepresentation,
        stressIndicator,
        lifeConnection,
        scientificSummary,
      ];

  /// Create a placeholder/loading state
  factory ScientificDreamAnalysis.empty() {
    return ScientificDreamAnalysis(
      brainProcess: AnalysisSection(
        title: 'Beyin Süreci Analizi',
        content: '',
        icon: 'brain',
      ),
      emotionalTheme: AnalysisSection(
        title: 'Baskın Duygusal Tema',
        content: '',
        icon: 'heart',
      ),
      mentalRepresentation: AnalysisSection(
        title: 'Zihinsel Temsil',
        content: '',
        icon: 'lightbulb',
      ),
      stressIndicator: AnalysisSection(
        title: 'Belirsizlik ve Stres Göstergesi',
        content: '',
        icon: 'warning',
      ),
      lifeConnection: AnalysisSection(
        title: 'Yakın Dönem Yaşam Bağlantısı',
        content: '',
        icon: 'link',
      ),
      scientificSummary: AnalysisSection(
        title: 'Bilimsel Özet',
        content: '',
        icon: 'science',
      ),
    );
  }
}

/// A single section of the analysis
class AnalysisSection {
  final String title;
  final String content;
  final String icon;

  const AnalysisSection({
    required this.title,
    required this.content,
    required this.icon,
  });

  factory AnalysisSection.fromJson(
    Map<String, dynamic> json, {
    required String defaultTitle,
    required String defaultIcon,
  }) {
    String clean(String value) => _sanitizeUtf16(value);
    return AnalysisSection(
      title: clean(json['title']?.toString() ?? defaultTitle),
      content: clean(json['content']?.toString() ?? ''),
      icon: clean(json['icon']?.toString() ?? defaultIcon),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'icon': icon,
      };

  bool get isEmpty => content.trim().isEmpty;
  bool get isNotEmpty => content.trim().isNotEmpty;
}

String _sanitizeUtf16(String input) {
  final units = input.codeUnits;
  final buffer = StringBuffer();
  for (int i = 0; i < units.length; i++) {
    final unit = units[i];
    if (unit >= 0xD800 && unit <= 0xDBFF) {
      if (i + 1 < units.length) {
        final next = units[i + 1];
        if (next >= 0xDC00 && next <= 0xDFFF) {
          buffer.writeCharCode(unit);
          buffer.writeCharCode(next);
          i++;
        }
      }
      continue;
    }
    if (unit >= 0xDC00 && unit <= 0xDFFF) {
      continue;
    }
    buffer.writeCharCode(unit);
  }
  return buffer.toString();
}

/// Dream clarity options
enum DreamClarity {
  clear('Net ve akıcı', 'Rüya net, sahneler akıcı'),
  fragmented('Parçalı / karışık', 'Rüya parçalı, sahneler dağınık');

  final String label;
  final String description;

  const DreamClarity(this.label, this.description);
}

/// Scientific emotion options for dream analysis
enum ScientificEmotion {
  fear('Korku', 'Endişe, tehdit algısı'),
  stress('Stres', 'Baskı, gerilim'),
  guilt('Suçluluk', 'Pişmanlık, sorumluluk hissi'),
  relief('Rahatlama', 'Kurtuluş, ferahlık'),
  confusion('Kafa karışıklığı', 'Belirsizlik, şaşkınlık'),
  sadness('Üzüntü', 'Keder, hüzün'),
  calm('Huzur', 'Sakinlik, dinginlik');

  final String label;
  final String description;

  const ScientificEmotion(this.label, this.description);
}

/// Input model for scientific dream analysis
class ScientificDreamInput {
  final String dreamText;
  final ScientificEmotion emotion;
  final DreamClarity clarity;

  const ScientificDreamInput({
    required this.dreamText,
    required this.emotion,
    required this.clarity,
  });

  Map<String, dynamic> toJson() => {
        'dream_text': dreamText,
        'emotion': emotion.name,
        'emotion_label': emotion.label,
        'clarity': clarity.name,
        'clarity_label': clarity.label,
      };
}
