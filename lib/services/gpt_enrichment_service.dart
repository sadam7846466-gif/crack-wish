import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dream_analysis.dart';
import '../models/emotion.dart';

class GptEnrichmentService {
  static const String _endpoint = String.fromEnvironment(
    'GPT_ENRICH_URL',
    defaultValue: '',
  );
  static const String _apiKey = String.fromEnvironment(
    'GPT_ENRICH_KEY',
    defaultValue: '',
  );
  static const List<String> _defaultConstraints = [
    'no prediction',
    'no symbolism',
    'scientific tone',
  ];

  final http.Client _client;

  GptEnrichmentService({http.Client? client})
    : _client = client ?? http.Client();

  bool get isConfigured => _endpoint.isNotEmpty;

  Future<String> enrich({
    required String baseText,
    required DreamAnalysis analysis,
    required Emotion emotion,
    List<String> constraints = _defaultConstraints,
  }) async {
    if (_endpoint.isEmpty) return baseText;

    final payload = {
      'text': baseText,
      'analysis': {
        'hasThreat': analysis.hasThreat,
        'hasPastReference': analysis.hasPastReference,
        'hasMovement': analysis.hasMovement,
      },
      'emotion': emotion.label,
      'constraints': constraints,
    };

    final headers = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
    };
    if (_apiKey.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_apiKey';
    }

    try {
      final response = await _client
          .post(
            Uri.parse(_endpoint),
            headers: headers,
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return baseText;
      }

      final body = response.body.trim();
      if (body.isEmpty) return baseText;

      try {
        final decoded = jsonDecode(body);
        if (decoded is Map<String, dynamic>) {
          final text = decoded['text']?.toString().trim();
          if (text != null && text.isNotEmpty) return text;
        }
      } catch (_) {
        // JSON değilse body'yi düz metin kabul et.
      }

      return body;
    } catch (_) {
      return baseText;
    }
  }
}
