import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';
import '../models/clarification_answer.dart';
import '../models/dream_analysis.dart';
import '../models/emotion.dart';

class GeminiDreamService {
  static const String _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  GenerativeModel? _model;

  GeminiDreamService() {
    if (hasApiKey) {
      _model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: _apiKey,
      );
    }
  }

  bool get hasApiKey => _apiKey.isNotEmpty;
  bool get isConfigured => hasApiKey && _model != null;

  // ═══════════════════════════════════════════════════════════════════
  // Soru sorma — şimdilik devre dışı, direkt analiz akışı
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, String>>> generateClarificationQuestions({
    required String dreamText,
    required Emotion emotion,
  }) async {
    // Şimdilik soru sorma devre dışı — direkt analiz akışı
    return [];
  }

  // ═══════════════════════════════════════════════════════════════════
  // Rüya Analizi — Bilimsel Psikoloji Tabanlı
  // ═══════════════════════════════════════════════════════════════════

  Future<DreamAnalysis> generateInterpretation({
    required String dreamText,
    required Emotion emotion,
    required List<ClarificationAnswer> answers,
    required List<Map<String, String>> questions,
  }) async {
    final String generatedId = const Uuid().v4();

    print('DEBUG: hasApiKey=$hasApiKey, isConfigured=$isConfigured');

    if (!isConfigured) {
      print('DEBUG: API not configured, returning fallback');
      return _buildFallbackAnalysis(id: generatedId, emotion: emotion);
    }

    final prompt = '''
Analyze the following dream using a scientific psychological perspective.

Rules:
- Do NOT predict the future.
- Do NOT use mystical or fortune-telling language.
- Do NOT use certainty claims. Use probability-based scientific tone.
- Keep analysis clear, realistic and neutral.
- All text output (analysis, card bodies, symbol meanings, summary) must be in Turkish.
- If the dream text is meaningless, too short, or not a dream, return a neutral generic analysis instead of an error.
- The number of cards should match the dream complexity: simple dream = 2 cards, complex dream = up to 6 cards.
- Each card should cover a different psychological angle (e.g. memory processing, emotional regulation, stress response, identity, relationships, control).

Dream text:
"$dreamText"

Emotion after waking:
"${emotion.label} - ${emotion.description}"

Return ONLY valid JSON in this exact format (no markdown, no extra text):

{
  "category": "one of: nightmare, stress, daily_reflection, emotional_processing, fragmented",
  "distribution": {
    "emotionalLoad": 0-100,
    "uncertainty": 0-100,
    "recentPast": 0-100,
    "brainActivity": 0-100
  },
  "emotions": [
    {"key": "emotion_name_in_turkish", "value": 0-100}
  ],
  "symbols": [
    {
      "symbolKey": "short_key",
      "label": "Turkish label",
      "meaning": "Scientific Turkish explanation"
    }
  ],
  "cards": [
    {
      "type": "category_key",
      "title": "Turkish title with emoji",
      "body": "Scientific Turkish explanation paragraph",
      "iconKey": "brain or search or pin or shield or heart or eye"
    }
  ],
  "summary": "One sentence Turkish summary",
  "disclaimer": "Bu analiz bilimsel olasılık yorumudur, kesinlik içermez."
}
''';

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      var text = response.text?.trim() ?? '';

      // Markdown temizliği
      if (text.contains('```json')) {
        text = text.split('```json')[1].split('```')[0].trim();
      } else if (text.contains('```')) {
        text = text.split('```')[1].split('```')[0].trim();
      }

      final jsonMap = jsonDecode(text) as Map<String, dynamic>;
      jsonMap['id'] = generatedId;
      jsonMap['createdAt'] = DateTime.now().toIso8601String();

      return DreamAnalysis.fromJson(jsonMap);
    } catch (e) {
      print('Gemini Interpretation Error: $e');
      return _buildFallbackAnalysis(id: generatedId, emotion: emotion);
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // Fallback: API çalışmazsa veya hata olursa
  // ═══════════════════════════════════════════════════════════════════

  DreamAnalysis _buildFallbackAnalysis({
    required String id,
    required Emotion emotion,
  }) {
    return DreamAnalysis(
      id: id,
      createdAt: DateTime.now(),
      category: DreamCategory.dailyReflection,
      distribution: const MentalDistribution(
        emotionalLoad: 50,
        uncertainty: 50,
        recentPast: 30,
        brainActivity: 60,
      ),
      emotions: [
        EmotionScore(key: emotion.name, value: 70),
      ],
      symbols: const [],
      cards: const [
        InsightCard(
          type: 'info',
          title: '⚠️ Bağlantı Sorunu',
          body: 'Analiz şu an gerçekleştirilemedi. Lütfen internet bağlantınızı kontrol edip tekrar deneyin.',
          iconKey: 'pin',
        ),
      ],
      summary: 'Analiz tamamlanamadı.',
      disclaimer: 'Bu analiz bilimsel olasılık yorumudur, kesinlik içermez.',
    );
  }
}
