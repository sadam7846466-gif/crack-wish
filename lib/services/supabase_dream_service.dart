import 'dart:convert';
import 'package:http/http.dart' as http;

/// Supabase Edge Function üzerinden rüya yorumlama servisi
class SupabaseDreamService {
  static const String _supabaseUrl = 'https://zzheonrmioxbiinvomsw.supabase.co';
  static const String _anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp6aGVvbnJtaW94YmlpbnZvbXN3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyMzI3MTAsImV4cCI6MjA4OTgwODcxMH0.ur8u0vCa9x-nRKdKhS_xL6c56jpmXjU9FXa2CCHnaWU';

  final http.Client _client;

  SupabaseDreamService({http.Client? client})
      : _client = client ?? http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $_anonKey',
      };

  // ─── NORMAL RÜYA YORUMLA (FREE) ───
  Future<DreamInterpretationResult> interpretDream({
    required String dreamText,
    required String emotion,
    required String locale,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_supabaseUrl/functions/v1/interpret-dream'),
            headers: _headers,
            body: jsonEncode({
              'dreamText': dreamText,
              'emotion': emotion,
              'locale': locale,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return DreamInterpretationResult.error(
          'Sunucu hatası: ${response.statusCode}',
        );
      }

      final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

      if (body.containsKey('error')) {
        return DreamInterpretationResult.error(body['error'].toString());
      }

      return DreamInterpretationResult.fromJson(body);
    } catch (e) {
      return DreamInterpretationResult.error('Bağlantı hatası: $e');
    }
  }

  // ─── DERİN ANALİZ: SORU ÜRET (PREMIUM) ───
  Future<DeepAnalysisQuestions> generateQuestions({
    required String dreamText,
    required String emotion,
    required String locale,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_supabaseUrl/functions/v1/analyze-dream-premium'),
            headers: _headers,
            body: jsonEncode({
              'dreamText': dreamText,
              'emotion': emotion,
              'locale': locale,
              'step': 'questions',
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return DeepAnalysisQuestions.error('Sunucu hatası');
      }

      final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return DeepAnalysisQuestions.fromJson(body);
    } catch (e) {
      return DeepAnalysisQuestions.error('Bağlantı hatası: $e');
    }
  }

  // ─── DERİN ANALİZ: YORUM ÜRET (PREMIUM) ───
  Future<DeepAnalysisResult> analyzeDeep({
    required String dreamText,
    required String emotion,
    required String locale,
    required List<Map<String, String>> answers,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_supabaseUrl/functions/v1/analyze-dream-premium'),
            headers: _headers,
            body: jsonEncode({
              'dreamText': dreamText,
              'emotion': emotion,
              'locale': locale,
              'step': 'analyze',
              'answers': answers,
            }),
          )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return DeepAnalysisResult.error('Sunucu hatası');
      }

      final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

      if (body.containsKey('error')) {
        return DeepAnalysisResult.error(body['error'].toString());
      }

      return DeepAnalysisResult.fromJson(body);
    } catch (e) {
      return DeepAnalysisResult.error('Bağlantı hatası: $e');
    }
  }
}

// ─────────────────────────────────────────────
// MODELLER
// ─────────────────────────────────────────────

/// FREE yorum sonucu — sabit format
class DreamInterpretationResult {
  final bool success;
  final String? errorMessage;

  // API alanları
  final String category;       // "Kabus", "Duygusal İşleme", vs.
  final DreamDistribution distribution; // Sabit 4 metrik
  final String summary;        // 1 cümle özet
  final List<DreamSection> sections; // Yapılandırılmış bölümler

  DreamInterpretationResult({
    required this.success,
    this.errorMessage,
    this.category = '',
    this.distribution = const DreamDistribution(),
    this.summary = '',
    this.sections = const [],
  });

  factory DreamInterpretationResult.fromJson(Map<String, dynamic> json) {
    final dist = json['distribution'] as Map<String, dynamic>?;

    final sectionsList = (json['sections'] as List<dynamic>?)
            ?.map((s) => DreamSection.fromJson(s as Map<String, dynamic>))
            .toList() ??
        [];

    return DreamInterpretationResult(
      success: true,
      category: json['category']?.toString() ?? '',
      distribution: dist != null
          ? DreamDistribution.fromJson(dist)
          : const DreamDistribution(),
      summary: json['summary']?.toString() ?? '',
      sections: sectionsList,
    );
  }

  factory DreamInterpretationResult.error(String message) {
    return DreamInterpretationResult(
      success: false,
      errorMessage: message,
    );
  }
}

/// Yapılandırılmış yorum bölümü
class DreamSection {
  final String emoji;
  final String title;
  final String content;

  const DreamSection({
    required this.emoji,
    required this.title,
    required this.content,
  });

  factory DreamSection.fromJson(Map<String, dynamic> json) {
    return DreamSection(
      emoji: json['emoji']?.toString() ?? '🧠',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
    );
  }
}

/// Sabit 4 metrik dağılımı
class DreamDistribution {
  final int emotionalLoad;      // Duygusal Yük
  final int uncertainty;         // Belirsizlik
  final int recentMemoryEffect;  // Yakın Geçmiş Etkisi
  final int brainActivity;       // Beyin Aktivitesi

  const DreamDistribution({
    this.emotionalLoad = 0,
    this.uncertainty = 0,
    this.recentMemoryEffect = 0,
    this.brainActivity = 0,
  });

  factory DreamDistribution.fromJson(Map<String, dynamic> json) {
    return DreamDistribution(
      emotionalLoad: (json['emotional_load'] as num?)?.toInt() ?? 0,
      uncertainty: (json['uncertainty'] as num?)?.toInt() ?? 0,
      recentMemoryEffect: (json['recent_memory_effect'] as num?)?.toInt() ?? 0,
      brainActivity: (json['brain_activity'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Derin analiz soruları
class DeepAnalysisQuestions {
  final bool success;
  final String? errorMessage;
  final bool isValidDream;
  final List<DeepQuestion> questions;

  DeepAnalysisQuestions({
    required this.success,
    this.errorMessage,
    this.isValidDream = true,
    this.questions = const [],
  });

  factory DeepAnalysisQuestions.fromJson(Map<String, dynamic> json) {
    final questionsList = (json['questions'] as List<dynamic>?)
            ?.map((q) => DeepQuestion.fromJson(q as Map<String, dynamic>))
            .toList() ??
        [];

    return DeepAnalysisQuestions(
      success: true,
      isValidDream: json['is_valid_dream'] as bool? ?? true,
      questions: questionsList,
    );
  }

  factory DeepAnalysisQuestions.error(String message) {
    return DeepAnalysisQuestions(
        success: false, errorMessage: message, isValidDream: false);
  }
}

class DeepQuestion {
  final String id;
  final String question;
  final List<DeepQuestionOption> options;

  const DeepQuestion({
    required this.id,
    required this.question,
    required this.options,
  });

  factory DeepQuestion.fromJson(Map<String, dynamic> json) {
    final optionsList = (json['options'] as List<dynamic>?)
            ?.map((o) => DeepQuestionOption.fromJson(o as Map<String, dynamic>))
            .toList() ??
        [];

    return DeepQuestion(
      id: json['id']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      options: optionsList,
    );
  }
}

class DeepQuestionOption {
  final String id;
  final String text;

  const DeepQuestionOption({required this.id, required this.text});

  factory DeepQuestionOption.fromJson(Map<String, dynamic> json) {
    return DeepQuestionOption(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
    );
  }
}

/// Derin analiz sonucu
class DeepAnalysisResult {
  final bool success;
  final String? errorMessage;
  final String title;
  final List<AnalysisSection> sections;
  final List<String> symbols;
  final String personalAdvice;

  DeepAnalysisResult({
    required this.success,
    this.errorMessage,
    this.title = '',
    this.sections = const [],
    this.symbols = const [],
    this.personalAdvice = '',
  });

  factory DeepAnalysisResult.fromJson(Map<String, dynamic> json) {
    final sectionsList = (json['sections'] as List<dynamic>?)
            ?.map((s) => AnalysisSection.fromJson(s as Map<String, dynamic>))
            .toList() ??
        [];

    final symbolsList = (json['symbols'] as List<dynamic>?)
            ?.map((s) => s.toString())
            .toList() ??
        [];

    return DeepAnalysisResult(
      success: true,
      title: json['title']?.toString() ?? '',
      sections: sectionsList,
      symbols: symbolsList,
      personalAdvice: json['personalAdvice']?.toString() ?? '',
    );
  }

  factory DeepAnalysisResult.error(String message) {
    return DeepAnalysisResult(success: false, errorMessage: message);
  }
}

class AnalysisSection {
  final String title;
  final String icon;
  final String content;

  const AnalysisSection({
    required this.title,
    required this.icon,
    required this.content,
  });

  factory AnalysisSection.fromJson(Map<String, dynamic> json) {
    return AnalysisSection(
      title: json['title']?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'brain',
      content: json['content']?.toString() ?? '',
    );
  }
}
