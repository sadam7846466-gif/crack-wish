import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/mbti_data.dart';
import '../models/mbti_models.dart';

class MBTICalculator {
  /// Min=12, Max=84 (12 soru * 7), orta=48
  static Map<String, int> calculateScores(List<int> answers) {
    final scores = {'EI': 0, 'SN': 0, 'TF': 0, 'JP': 0, 'AT': 0};
    for (int i = 0; i < mbtiQuestions.length; i++) {
      final question = mbtiQuestions[i];
      int score = answers[i];
      if (question.reverse) {
        score = 8 - score; // 1->7, 2->6 ...
      }
      scores[question.axis] = scores[question.axis]! + score;
    }
    return scores;
  }

  static String determineType(Map<String, int> scores) {
    String type = '';
    type += scores['EI']! >= 48 ? 'E' : 'I';
    type += scores['SN']! >= 48 ? 'S' : 'N';
    type += scores['TF']! >= 48 ? 'T' : 'F';
    type += scores['JP']! >= 48 ? 'J' : 'P';
    final identity = scores['AT']! >= 48 ? 'A' : 'T';
    return '$type-$identity';
  }

  static Map<String, int> calculatePercentages(Map<String, int> scores) {
    final p = <String, int>{};
    scores.forEach((axis, value) {
      p[axis] = ((value - 12) / 72 * 100).round(); // 12->0, 84->100
    });
    return p;
  }

  static Future<void> saveResult(MBTIResultData result) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mbtiResult', jsonEncode(result.toJson()));
  }

  static Future<MBTIResultData?> loadResult() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('mbtiResult');
    if (raw == null) return null;
    try {
      return MBTIResultData.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }
}
