import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/scientific_dream_analysis.dart';

/// Scientific Dream Analysis Service
/// Uses OpenAI API for psychology and neuroscience-based dream interpretation
/// NOT fortune telling - strictly scientific approach
class ScientificDreamService {
  static const String _endpoint = String.fromEnvironment(
    'OPENAI_API_URL',
    defaultValue: 'https://api.openai.com/v1/chat/completions',
  );
  static const String _apiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );
  static const String _model = String.fromEnvironment(
    'OPENAI_MODEL',
    defaultValue: 'gpt-4o-mini',
  );

  final http.Client _client;

  ScientificDreamService({http.Client? client})
      : _client = client ?? http.Client();

  bool get isConfigured => _apiKey.isNotEmpty;

  /// Scientific system prompt for dream analysis
  static const String _systemPrompt = '''
Sen bir bilimsel rüya analisti olarak görev yapıyorsun. Analizlerin tamamen psikoloji ve nörobilime dayanmalıdır.

MUTLAK KURALLAR:
- Gelecek tahmini YAPMA
- Kader, din, mistisizm veya sabit anlamlı semboller kullanma
- Tüm sembolleri ZİHİNSEL TEMSİLLER olarak yorumla
- Şu konulara odaklan: duygular, stres, sorumluluk, kontrol, hafıza işleme
- Olasılık temelli dil kullan ("işaret edebilir", "ile ilişkili olabilir", "düşündürebilir")
- Kesin yargılardan kaçın
- Emoji KULLANMA

ANALİZ ÇIKTISI YAPISI (JSON formatında döndür):
{
  "brain_process": {
    "title": "Beyin Süreci Analizi",
    "content": "REM uykusu sırasında beynin bu rüyayı nasıl işlediğine dair 2-3 cümle"
  },
  "emotional_theme": {
    "title": "Baskın Duygusal Tema",
    "content": "Rüyadaki ana duygusal tema hakkında 2-3 cümle"
  },
  "mental_representation": {
    "title": "Zihinsel Temsil",
    "content": "Rüyadaki sembollerin zihinsel temsiller olarak açıklaması, 2-3 cümle"
  },
  "stress_indicator": {
    "title": "Belirsizlik ve Stres Göstergesi",
    "content": "Stres ve belirsizlik düzeyi hakkında 2-3 cümle"
  },
  "life_connection": {
    "title": "Yakın Dönem Yaşam Bağlantısı",
    "content": "Son dönem yaşantılarla olası bağlantılar hakkında 2-3 cümle"
  },
  "scientific_summary": {
    "title": "Bilimsel Özet",
    "content": "Genel bilimsel değerlendirme, 2-3 cümle"
  }
}

Her bölüm:
- Kısa olmalı (2-3 cümle)
- Net ve anlaşılır olmalı
- İçgörü sağlamalı
- Ciddi ve profesyonel ton kullanmalı
''';

  /// Analyze dream with OpenAI API
  Future<ScientificDreamAnalysis> analyzeDream(
    ScientificDreamInput input,
  ) async {
    if (!isConfigured) {
      return _generateFallbackAnalysis(input);
    }

    final userPrompt = '''
RÜYA METNİ:
${input.dreamText}

UYANDIĞINDA HİSSEDİLEN DUYGU: ${input.emotion.label}

RÜYA NETLİĞİ: ${input.clarity.label}

Lütfen bu rüyayı bilimsel olarak analiz et ve JSON formatında yanıt ver.
''';

    try {
      final response = await _client
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {'role': 'system', 'content': _systemPrompt},
                {'role': 'user', 'content': userPrompt},
              ],
              'temperature': 0.7,
              'max_tokens': 1000,
              'response_format': {'type': 'json_object'},
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return _generateFallbackAnalysis(input);
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = body['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        return _generateFallbackAnalysis(input);
      }

      final message = choices[0]['message'] as Map<String, dynamic>?;
      final content = message?['content']?.toString();
      if (content == null || content.isEmpty) {
        return _generateFallbackAnalysis(input);
      }

      final analysisJson = jsonDecode(content) as Map<String, dynamic>;
      return ScientificDreamAnalysis.fromJson(analysisJson);
    } catch (e) {
      return _generateFallbackAnalysis(input);
    }
  }

  /// Generate fallback analysis when API is not available
  ScientificDreamAnalysis _generateFallbackAnalysis(ScientificDreamInput input) {
    final emotionContext = _getEmotionContext(input.emotion);
    final clarityContext = _getClarityContext(input.clarity);

    return ScientificDreamAnalysis(
      brainProcess: AnalysisSection(
        title: 'Beyin Süreci Analizi',
        content:
            'REM uykusu sırasında beyin, duygusal deneyimleri işler ve hafızayı düzenler. '
            'Bu rüya, beynin $clarityContext bir şekilde duygusal içerikleri işlediğini gösteriyor.',
        icon: 'brain',
      ),
      emotionalTheme: AnalysisSection(
        title: 'Baskın Duygusal Tema',
        content:
            '${input.emotion.label} hissi, rüyanın ana duygusal temasını oluşturuyor. '
            'Bu duygu, $emotionContext ile ilişkili olabilir.',
        icon: 'heart',
      ),
      mentalRepresentation: AnalysisSection(
        title: 'Zihinsel Temsil',
        content:
            'Rüyadaki görüntüler, bilinçaltının sembolik dili olarak değerlendirilebilir. '
            'Bu temsiller, zihnin soyut kavramları somutlaştırma biçimini yansıtıyor olabilir.',
        icon: 'lightbulb',
      ),
      stressIndicator: AnalysisSection(
        title: 'Belirsizlik ve Stres Göstergesi',
        content:
            '${input.clarity == DreamClarity.fragmented ? 'Parçalı rüya yapısı, yüksek stres veya belirsizlik dönemine işaret edebilir.' : 'Net rüya akışı, göreceli olarak dengeli bir zihinsel durumu yansıtıyor olabilir.'} '
            'Uyanış sırasındaki ${input.emotion.label.toLowerCase()} hissi bu değerlendirmeyi destekliyor.',
        icon: 'warning',
      ),
      lifeConnection: AnalysisSection(
        title: 'Yakın Dönem Yaşam Bağlantısı',
        content:
            'Bu rüya, muhtemelen son günlerde yaşanan deneyimler veya düşüncelerle bağlantılı. '
            'Beyin, günlük yaşantıları rüya sırasında işleyerek anlamlandırmaya çalışır.',
        icon: 'link',
      ),
      scientificSummary: AnalysisSection(
        title: 'Bilimsel Özet',
        content:
            'Bu rüya, beynin normal REM döngüsü içinde duygusal ve bilişsel içerikleri işlemesinin bir ürünü olarak değerlendirilebilir. '
            'Kesin bir öngörü içermez; yakın dönem yaşantılarla ilişkili olması muhtemeldir.',
        icon: 'science',
      ),
    );
  }

  String _getEmotionContext(ScientificEmotion emotion) {
    switch (emotion) {
      case ScientificEmotion.fear:
        return 'algılanan tehditler veya endişeler';
      case ScientificEmotion.stress:
        return 'yaşanan baskı veya sorumluluklar';
      case ScientificEmotion.guilt:
        return 'tamamlanmamış görevler veya pişmanlıklar';
      case ScientificEmotion.relief:
        return 'çözülmüş sorunlar veya aşılmış engeller';
      case ScientificEmotion.confusion:
        return 'karar verme süreçleri veya belirsizlikler';
      case ScientificEmotion.sadness:
        return 'kayıp duyguları veya özlem';
      case ScientificEmotion.calm:
        return 'iç huzur ve denge arayışı';
    }
  }

  String _getClarityContext(DreamClarity clarity) {
    switch (clarity) {
      case DreamClarity.clear:
        return 'akıcı ve tutarlı';
      case DreamClarity.fragmented:
        return 'parçalı ve dağınık';
    }
  }
}
