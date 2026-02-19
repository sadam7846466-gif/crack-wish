import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/motivation_content.dart';

/// Motivasyon Servis - User Analysis Engine & Adaptive Algorithm
class MotivationService {
  static const String _keyCompletedExercises = 'motivation_completed_exercises';
  static const String _keySkippedExercises = 'motivation_skipped_exercises';
  static const String _keyLastSessionDate = 'motivation_last_session';
  static const String _keySessionCount = 'motivation_session_count';
  static const String _keyPreferredCategory = 'motivation_preferred_category';
  static const String _keySessionHistory = 'motivation_session_history';
  
  // ═══════════════════════════════════════════════════════════════
  // USER ANALYSIS ENGINE
  // ═══════════════════════════════════════════════════════════════
  
  /// Tamamlanan egzersiz ID'lerini kaydet
  static Future<void> markExerciseCompleted(String exerciseId) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getStringList(_keyCompletedExercises) ?? [];
    if (!completed.contains(exerciseId)) {
      completed.add(exerciseId);
      await prefs.setStringList(_keyCompletedExercises, completed);
    }
  }
  
  /// Skip edilen egzersiz ID'lerini kaydet
  static Future<void> markExerciseSkipped(String exerciseId) async {
    final prefs = await SharedPreferences.getInstance();
    final skipped = prefs.getStringList(_keySkippedExercises) ?? [];
    if (!skipped.contains(exerciseId)) {
      skipped.add(exerciseId);
      await prefs.setStringList(_keySkippedExercises, skipped);
    }
  }
  
  /// Tamamlanan egzersizleri getir
  static Future<List<String>> getCompletedExercises() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyCompletedExercises) ?? [];
  }
  
  /// Skip edilen egzersizleri getir
  static Future<List<String>> getSkippedExercises() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keySkippedExercises) ?? [];
  }
  
  /// Seans sayısını artır
  static Future<void> incrementSessionCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_keySessionCount) ?? 0;
    await prefs.setInt(_keySessionCount, count + 1);
    await prefs.setString(_keyLastSessionDate, DateTime.now().toIso8601String());
  }
  
  /// Toplam seans sayısını getir
  static Future<int> getSessionCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keySessionCount) ?? 0;
  }
  
  /// Son seans tarihini getir
  static Future<DateTime?> getLastSessionDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString(_keyLastSessionDate);
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr);
  }
  
  /// Tercih edilen kategoriyi kaydet
  static Future<void> setPreferredCategory(String category) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPreferredCategory, category);
  }
  
  /// Tercih edilen kategoriyi getir
  static Future<String?> getPreferredCategory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPreferredCategory);
  }
  
  // ═══════════════════════════════════════════════════════════════
  // ADAPTIVE RECOMMENDATION ALGORITHM
  // ═══════════════════════════════════════════════════════════════
  
  /// Seçime göre otomatik seans oluştur
  /// choice: 'relax', 'energy', 'focus', 'moral'
  static Future<MotivationSession> generateSession(String choice) async {
    final completed = await getCompletedExercises();
    final skipped = await getSkippedExercises();
    final hour = DateTime.now().hour;
    
    // Seçime göre kategorileri belirle
    List<MotivationCategory> stage1Categories;
    List<MotivationCategory> stage2Categories;
    List<MotivationCategory> stage3Categories;
    
    switch (choice) {
      case 'relax':
        stage1Categories = [MotivationCategory.relaxation];
        stage2Categories = [MotivationCategory.thinking, MotivationCategory.awareness];
        stage3Categories = [MotivationCategory.motivation];
        break;
      case 'energy':
        stage1Categories = [MotivationCategory.energy, MotivationCategory.relaxation];
        stage2Categories = [MotivationCategory.motivation];
        stage3Categories = [MotivationCategory.focus];
        break;
      case 'focus':
        stage1Categories = [MotivationCategory.relaxation];
        stage2Categories = [MotivationCategory.thinking];
        stage3Categories = [MotivationCategory.focus, MotivationCategory.motivation];
        break;
      case 'moral':
      default:
        stage1Categories = [MotivationCategory.relaxation, MotivationCategory.awareness];
        stage2Categories = [MotivationCategory.thinking];
        stage3Categories = [MotivationCategory.motivation];
        break;
    }
    
    // Her aşama için egzersiz seç
    final stage1 = _selectExercises(
      categories: stage1Categories,
      count: 2,
      excludeIds: [...completed.take(10), ...skipped],
      preferTypes: [ExerciseType.breathing, ExerciseType.grounding, ExerciseType.meditation],
    );
    
    final stage2 = _selectExercises(
      categories: stage2Categories,
      count: 2,
      excludeIds: [...completed.take(10), ...skipped, ...stage1.map((e) => e.id)],
      preferTypes: [ExerciseType.cbt, ExerciseType.perspective],
    );
    
    final stage3 = _selectExercises(
      categories: stage3Categories,
      count: 2,
      excludeIds: [...completed.take(10), ...skipped, ...stage1.map((e) => e.id), ...stage2.map((e) => e.id)],
      preferTypes: [ExerciseType.microGoal, ExerciseType.timer],
    );
    
    return MotivationSession(
      choice: choice,
      stage1Exercises: stage1,
      stage2Exercises: stage2,
      stage3Exercises: stage3,
      createdAt: DateTime.now(),
    );
  }
  
  /// Kategorilerden egzersiz seç (adaptive)
  static List<MotivationExercise> _selectExercises({
    required List<MotivationCategory> categories,
    required int count,
    List<String> excludeIds = const [],
    List<ExerciseType> preferTypes = const [],
  }) {
    final allExercises = <MotivationExercise>[];
    
    for (final category in categories) {
      allExercises.addAll(MotivationContent.getByCategory(category));
    }
    
    // Exclude IDs
    final filtered = allExercises
        .where((e) => !excludeIds.contains(e.id))
        .toList();
    
    // Tercih edilen tiplere öncelik ver
    final preferred = filtered.where((e) => preferTypes.contains(e.type)).toList();
    final others = filtered.where((e) => !preferTypes.contains(e.type)).toList();
    
    // Karıştır
    preferred.shuffle(Random());
    others.shuffle(Random());
    
    // Birleştir ve limit uygula
    final result = [...preferred, ...others].take(count).toList();
    return result;
  }
  
  /// Gün saatine göre öneri
  static String getTimeBasedSuggestion() {
    final hour = DateTime.now().hour;
    
    if (hour >= 6 && hour < 10) {
      return 'energy'; // Sabah: enerji
    } else if (hour >= 10 && hour < 14) {
      return 'focus'; // Öğle: odak
    } else if (hour >= 14 && hour < 18) {
      return 'moral'; // Öğleden sonra: moral
    } else if (hour >= 18 && hour < 22) {
      return 'relax'; // Akşam: rahatlama
    } else {
      return 'relax'; // Gece: rahatlama
    }
  }
  
  /// Seans verisini kaydet
  static Future<void> saveSessionData({
    required String choice,
    required int completedStages,
    required int closingMood,
    required List<String> completedExerciseIds,
  }) async {
    // Tamamlanan egzersizleri kaydet
    for (final id in completedExerciseIds) {
      await markExerciseCompleted(id);
    }
    
    // Seans sayısını artır
    await incrementSessionCount();
    
    // Tercih edilen kategoriyi güncelle
    await setPreferredCategory(choice);
  }
}

/// Motivasyon Seans Modeli
class MotivationSession {
  final String choice;
  final List<MotivationExercise> stage1Exercises; // Duygu regülasyonu
  final List<MotivationExercise> stage2Exercises; // Zihinsel düzenleme
  final List<MotivationExercise> stage3Exercises; // Davranış aktivasyonu
  final DateTime createdAt;
  
  const MotivationSession({
    required this.choice,
    required this.stage1Exercises,
    required this.stage2Exercises,
    required this.stage3Exercises,
    required this.createdAt,
  });
  
  /// Toplam tahmini süre (saniye)
  int get totalDurationSeconds {
    final all = [...stage1Exercises, ...stage2Exercises, ...stage3Exercises];
    return all.fold(0, (sum, e) => sum + e.durationSeconds);
  }
  
  /// Tahmini süre (dakika)
  int get totalDurationMinutes => (totalDurationSeconds / 60).ceil();
}
