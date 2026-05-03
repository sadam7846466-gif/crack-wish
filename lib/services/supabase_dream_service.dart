import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

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
              'userId': Supabase.instance.client.auth.currentUser?.id,
            }),
          )
          .timeout(const Duration(seconds: 45));

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
          .timeout(const Duration(seconds: 30));

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
    required List<dynamic> answers,
  }) async {
    const maxRetries = 2; // 1 asıl + 1 retry
    const timeout = Duration(seconds: 120); // API ~42s sürebilir, ağ yavaşlığına karşı 120s

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final reqBody = jsonEncode({
          'dreamText': dreamText,
          'emotion': emotion,
          'locale': locale,
          'step': 'analyze',
          'answers': answers,
        });
        debugPrint('🔮 [PREMIUM] Attempt $attempt/$maxRetries — Request body: $reqBody');

        final response = await _client
            .post(
              Uri.parse('$_supabaseUrl/functions/v1/analyze-dream-premium'),
              headers: _headers,
              body: reqBody,
            )
            .timeout(timeout);

        final rawText = utf8.decode(response.bodyBytes);
        debugPrint('🔮 [PREMIUM] Status: ${response.statusCode}');
        debugPrint('🔮 [PREMIUM] Raw response (first 500): ${rawText.substring(0, rawText.length > 500 ? 500 : rawText.length)}');

        if (response.statusCode < 200 || response.statusCode >= 300) {
          debugPrint('🔮 [PREMIUM] ERROR: Status ${response.statusCode} — $rawText');
          // Server error — retry if we have attempts left
          if (attempt < maxRetries) {
            debugPrint('🔮 [PREMIUM] Retrying in 2s...');
            await Future.delayed(const Duration(seconds: 2));
            continue;
          }
          return DeepAnalysisResult.error('Sunucu hatası: ${response.statusCode}');
        }

        final body = jsonDecode(rawText) as Map<String, dynamic>;

        if (body.containsKey('error')) {
          debugPrint('🔮 [PREMIUM] API Error: ${body['error']}');
          return DeepAnalysisResult.error(body['error'].toString());
        }

        debugPrint('🔮 [PREMIUM] Keys: ${body.keys.toList()}');
        debugPrint('🔮 [PREMIUM] title: ${body['title']}');
        debugPrint('🔮 [PREMIUM] subconsciousMap null? ${body['subconscious_map'] == null}');
        debugPrint('🔮 [PREMIUM] archetype null? ${body['archetype'] == null}');
        debugPrint('🔮 [PREMIUM] symbols: ${body['symbols']}');
        debugPrint('🔮 [PREMIUM] cosmicClosing: ${body['cosmic_closing']}');

        return DeepAnalysisResult.fromJson(body);
      } catch (e, stack) {
        debugPrint('🔮 [PREMIUM] EXCEPTION (attempt $attempt): $e');
        debugPrint('🔮 [PREMIUM] Stack: $stack');
        // Timeout or connection error — retry if we have attempts left
        if (attempt < maxRetries) {
          debugPrint('🔮 [PREMIUM] Retrying in 2s...');
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }
        return DeepAnalysisResult.error('Bağlantı hatası: $e');
      }
    }
    // Bu noktaya ulaşmamalı ama güvenlik için:
    return DeepAnalysisResult.error('Beklenmeyen hata');
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
  final int emotionalLoad;
  final String emotionalLoadReasoning;
  final int uncertainty;
  final String uncertaintyReasoning;
  final int recentMemoryEffect;
  final String recentMemoryReasoning;
  final int brainActivity;
  final String brainActivityReasoning;

  const DreamDistribution({
    this.emotionalLoad = 0,
    this.emotionalLoadReasoning = '',
    this.uncertainty = 0,
    this.uncertaintyReasoning = '',
    this.recentMemoryEffect = 0,
    this.recentMemoryReasoning = '',
    this.brainActivity = 0,
    this.brainActivityReasoning = '',
  });

  factory DreamDistribution.fromJson(Map<String, dynamic> json) {
    // Helper to extract value and reasoning safely (backward compatibility)
    int parseValue(dynamic field) {
      if (field == null) return 0;
      if (field is int) return field;
      if (field is num) return field.toInt();
      if (field is String) {
        final match = RegExp(r'\d+').firstMatch(field);
        if (match != null) return int.tryParse(match.group(0)!) ?? 0;
      }
      if (field is Map<String, dynamic> && field['value'] != null) {
        final val = field['value'];
        if (val is num) return val.toInt();
        if (val is String) {
          final match = RegExp(r'\d+').firstMatch(val);
          if (match != null) return int.tryParse(match.group(0)!) ?? 0;
        }
      }
      return 0;
    }

    String parseReasoning(dynamic field) {
      if (field is Map<String, dynamic> && field['reasoning'] != null) {
        return field['reasoning'].toString();
      }
      return '';
    }

    return DreamDistribution(
      emotionalLoad: parseValue(json['emotional_load']),
      emotionalLoadReasoning: parseReasoning(json['emotional_load']),
      uncertainty: parseValue(json['uncertainty']),
      uncertaintyReasoning: parseReasoning(json['uncertainty']),
      recentMemoryEffect: parseValue(json['recent_memory_effect']),
      recentMemoryReasoning: parseReasoning(json['recent_memory_effect']),
      brainActivity: parseValue(json['brain_activity']),
      brainActivityReasoning: parseReasoning(json['brain_activity']),
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

/// Derin analiz sonucu — Premium yapı
class DeepAnalysisResult {
  final bool success;
  final String? errorMessage;
  final String title;
  final SubconsciousMap subconsciousMap;
  final ArchetypeMatch archetype;
  final List<DeepSymbol> symbols;
  final List<TimelineScene> timeline;
  final ShadowSelf shadowSelf;
  final EmotionalLayers emotionalLayers;
  final BrainScience brainScience;
  final RecurringPattern recurringPattern;
  final DreamRitual ritual;
  final String cosmicClosing;
  final String reflectionQuestion;
  final Map<String, String> reflectionResponses;
  final DreamDistribution distribution;
  final List<ClarifyingInsight> clarifyingInsights;
  final WakingLifeDeduction wakingLifeDeduction;
  final Map<String, dynamic>? rawJson;

  DeepAnalysisResult({
    required this.success,
    this.errorMessage,
    this.title = '',
    this.subconsciousMap = const SubconsciousMap(),
    this.archetype = const ArchetypeMatch(),
    this.symbols = const [],
    this.timeline = const [],
    this.shadowSelf = const ShadowSelf(),
    this.emotionalLayers = const EmotionalLayers(),
    this.brainScience = const BrainScience(),
    this.recurringPattern = const RecurringPattern(),
    this.ritual = const DreamRitual(),
    this.cosmicClosing = '',
    this.reflectionQuestion = '',
    this.reflectionResponses = const {},
    this.distribution = const DreamDistribution(),
    this.clarifyingInsights = const [],
    this.wakingLifeDeduction = const WakingLifeDeduction(),
    this.rawJson,
  });

  factory DeepAnalysisResult.fromJson(Map<String, dynamic> json) {
    return DeepAnalysisResult(
      success: true,
      title: json['title']?.toString() ?? '',
      subconsciousMap: json['subconscious_map'] != null
          ? SubconsciousMap.fromJson(json['subconscious_map'] as Map<String, dynamic>)
          : const SubconsciousMap(),
      archetype: json['archetype'] != null
          ? ArchetypeMatch.fromJson(json['archetype'] as Map<String, dynamic>)
          : const ArchetypeMatch(),
      symbols: (json['symbols'] as List<dynamic>?)
              ?.map((s) => DeepSymbol.fromJson(s as Map<String, dynamic>))
              .toList() ?? [],
      timeline: (json['timeline'] as List<dynamic>?)
              ?.map((t) => TimelineScene.fromJson(t as Map<String, dynamic>))
              .toList() ?? [],
      shadowSelf: json['shadow_self'] != null
          ? ShadowSelf.fromJson(json['shadow_self'] as Map<String, dynamic>)
          : const ShadowSelf(),
      emotionalLayers: json['emotional_layers'] != null
          ? EmotionalLayers.fromJson(json['emotional_layers'] as Map<String, dynamic>)
          : const EmotionalLayers(),
      brainScience: json['brain_science'] != null
          ? BrainScience.fromJson(json['brain_science'] as Map<String, dynamic>)
          : const BrainScience(),
      recurringPattern: json['recurring_pattern'] != null
          ? RecurringPattern.fromJson(json['recurring_pattern'] as Map<String, dynamic>)
          : const RecurringPattern(),
      ritual: json['ritual'] != null
          ? DreamRitual.fromJson(json['ritual'] as Map<String, dynamic>)
          : const DreamRitual(),
      cosmicClosing: json['cosmic_closing']?.toString() ?? '',
      reflectionQuestion: json['reflection_question']?.toString() ?? '',
      reflectionResponses: json['reflection_responses'] != null 
          ? Map<String, String>.from(json['reflection_responses'] as Map)
          : const {},
      distribution: json['distribution'] != null
          ? DreamDistribution.fromJson(json['distribution'] as Map<String, dynamic>)
          : const DreamDistribution(),
      clarifyingInsights: (json['clarifying_insights'] as List<dynamic>?)
              ?.map((c) => ClarifyingInsight.fromJson(c as Map<String, dynamic>))
              .toList() ?? [],
      wakingLifeDeduction: json['waking_life_deduction'] != null
          ? WakingLifeDeduction.fromJson(json['waking_life_deduction'] as Map<String, dynamic>)
          : const WakingLifeDeduction(),
      // Cyclic (Ouroboros) hatasını önlemek için yepyeni bir clone yapıyoruz VE data kaybını kalıcı engelliyoruz.
      rawJson: Map<String, dynamic>.from(json)..remove('__rawJson__'),
    );
  }

  factory DeepAnalysisResult.error(String message) {
    return DeepAnalysisResult(success: false, errorMessage: message);
  }
}

class ClarifyingInsight {
  final String questionId;
  final String whyAsked;
  final String insight;

  const ClarifyingInsight({
    required this.questionId,
    required this.whyAsked,
    required this.insight,
  });

  factory ClarifyingInsight.fromJson(Map<String, dynamic> json) {
    return ClarifyingInsight(
      questionId: json['question_id']?.toString() ?? '',
      whyAsked: json['why_asked']?.toString() ?? '',
      insight: json['insight']?.toString() ?? '',
    );
  }
}

class WakingLifeDeduction {
  final String suspectedTrigger;
  final String causeAndEffect;

  const WakingLifeDeduction({
    this.suspectedTrigger = '',
    this.causeAndEffect = '',
  });

  factory WakingLifeDeduction.fromJson(Map<String, dynamic> json) {
    return WakingLifeDeduction(
      suspectedTrigger: json['suspected_trigger']?.toString() ?? '',
      causeAndEffect: json['cause_and_effect']?.toString() ?? '',
    );
  }
}

// ── Bilinçaltı Haritası ──
class SubconsciousMap {
  final List<MapZone> zones;
  final String journeyType;
  final String journeyLabel;
  final String summary;

  const SubconsciousMap({
    this.zones = const [],
    this.journeyType = '',
    this.journeyLabel = '',
    this.summary = '',
  });

  factory SubconsciousMap.fromJson(Map<String, dynamic> json) {
    return SubconsciousMap(
      zones: (json['zones'] as List<dynamic>?)
              ?.map((z) => MapZone.fromJson(z as Map<String, dynamic>))
              .toList() ?? [],
      journeyType: json['journey_type']?.toString() ?? '',
      journeyLabel: json['journey_label']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
    );
  }
}

class MapZone {
  final String name;
  final String symbol;
  final String description;

  const MapZone({this.name = '', this.symbol = '', this.description = ''});

  factory MapZone.fromJson(Map<String, dynamic> json) {
    return MapZone(
      name: json['name']?.toString() ?? '',
      symbol: json['symbol']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}

// ── Arketip Eşleşmesi ──
class ArchetypeMatch {
  final String primary;
  final String emoji;
  final String description;
  final String shadowNote;

  const ArchetypeMatch({
    this.primary = '',
    this.emoji = '🎭',
    this.description = '',
    this.shadowNote = '',
  });

  factory ArchetypeMatch.fromJson(Map<String, dynamic> json) {
    return ArchetypeMatch(
      primary: json['primary']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? '🎭',
      description: json['description']?.toString() ?? '',
      shadowNote: json['shadow_note']?.toString() ?? '',
    );
  }
}

// ── Sembol Derinleme ──
class DeepSymbol {
  final String name;
  final String coreMeaning;
  final String culturalContext;
  final String personalReflection;

  const DeepSymbol({
    this.name = '',
    this.coreMeaning = '',
    this.culturalContext = '',
    this.personalReflection = '',
  });

  factory DeepSymbol.fromJson(Map<String, dynamic> json) {
    return DeepSymbol(
      name: json['name']?.toString() ?? '',
      coreMeaning: json['core_meaning']?.toString() ?? '',
      culturalContext: json['cultural_context']?.toString() ?? '',
      personalReflection: json['personal_reflection']?.toString() ?? '',
    );
  }
}

// ── Zaman Çizgisi ──
class TimelineScene {
  final int scene;
  final String title;
  final String description;
  final String psychologicalShift;

  const TimelineScene({
    this.scene = 0,
    this.title = '',
    this.description = '',
    this.psychologicalShift = '',
  });

  factory TimelineScene.fromJson(Map<String, dynamic> json) {
    return TimelineScene(
      scene: (json['scene'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      psychologicalShift: json['psychological_shift']?.toString() ?? '',
    );
  }
}

// ── Gölge Ben ──
class ShadowSelf {
  final String revealed;
  final String answerInsight;
  final String integrationHint;

  const ShadowSelf({
    this.revealed = '',
    this.answerInsight = '',
    this.integrationHint = '',
  });

  factory ShadowSelf.fromJson(Map<String, dynamic> json) {
    return ShadowSelf(
      revealed: json['revealed']?.toString() ?? '',
      answerInsight: json['answer_insight']?.toString() ?? '',
      integrationHint: json['integration_hint']?.toString() ?? '',
    );
  }
}

// ── Duygusal Katmanlar ──
class EmotionalLayer {
  final String emotion;
  final String explanation;

  const EmotionalLayer({this.emotion = '', this.explanation = ''});

  factory EmotionalLayer.fromJson(Map<String, dynamic> json) {
    return EmotionalLayer(
      emotion: json['emotion']?.toString() ?? '',
      explanation: json['explanation']?.toString() ?? '',
    );
  }
}

class EmotionalLayers {
  final EmotionalLayer surface;
  final EmotionalLayer middle;
  final EmotionalLayer deep;
  final String synthesis;

  const EmotionalLayers({
    this.surface = const EmotionalLayer(),
    this.middle = const EmotionalLayer(),
    this.deep = const EmotionalLayer(),
    this.synthesis = '',
  });

  factory EmotionalLayers.fromJson(Map<String, dynamic> json) {
    return EmotionalLayers(
      surface: json['surface'] != null
          ? EmotionalLayer.fromJson(json['surface'] as Map<String, dynamic>)
          : const EmotionalLayer(),
      middle: json['middle'] != null
          ? EmotionalLayer.fromJson(json['middle'] as Map<String, dynamic>)
          : const EmotionalLayer(),
      deep: json['deep'] != null
          ? EmotionalLayer.fromJson(json['deep'] as Map<String, dynamic>)
          : const EmotionalLayer(),
      synthesis: json['synthesis']?.toString() ?? '',
    );
  }
}

// ── Nörobilim ──
class BrainScience {
  final String primaryRegion;
  final String primaryRegionEmoji;
  final String mechanism;
  final String fascinatingFact;

  const BrainScience({
    this.primaryRegion = '',
    this.primaryRegionEmoji = '🧠',
    this.mechanism = '',
    this.fascinatingFact = '',
  });

  factory BrainScience.fromJson(Map<String, dynamic> json) {
    return BrainScience(
      primaryRegion: json['primary_region']?.toString() ?? '',
      primaryRegionEmoji: json['primary_region_emoji']?.toString() ?? '🧠',
      mechanism: json['mechanism']?.toString() ?? '',
      fascinatingFact: json['fascinating_fact']?.toString() ?? '',
    );
  }
}

// ── Tekrar Kalıbı ──
class RecurringPattern {
  final bool detected;
  final String patternName;
  final String description;
  final String resolutionHint;

  const RecurringPattern({
    this.detected = false,
    this.patternName = '',
    this.description = '',
    this.resolutionHint = '',
  });

  factory RecurringPattern.fromJson(Map<String, dynamic> json) {
    return RecurringPattern(
      detected: json['detected'] as bool? ?? false,
      patternName: json['pattern_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      resolutionHint: json['resolution_hint']?.toString() ?? '',
    );
  }
}

// ── Ritüel Önerisi ──
class DreamRitual {
  final String title;
  final String action;
  final String emoji;
  final String scienceNote;

  const DreamRitual({
    this.title = '',
    this.action = '',
    this.emoji = '🕯️',
    this.scienceNote = '',
  });

  factory DreamRitual.fromJson(Map<String, dynamic> json) {
    return DreamRitual(
      title: json['title']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? '🕯️',
      scienceNote: json['science_note']?.toString() ?? '',
    );
  }
}
