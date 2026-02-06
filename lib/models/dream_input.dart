import 'emotion.dart';

/// Kullanıcıdan gelen rüya verisi
class DreamInput {
  final String text;
  final List<Emotion> emotions;

  DreamInput({required this.text, required this.emotions});

  /// JSON'dan oluştur
  factory DreamInput.fromJson(Map<String, dynamic> json) {
    return DreamInput(
      text: json['text'] as String,
      emotions: (json['emotions'] as List<dynamic>)
          .map((e) => Emotion.values.firstWhere((emotion) => emotion.name == e))
          .toList(),
    );
  }

  /// JSON'a dönüştür
  Map<String, dynamic> toJson() {
    return {'text': text, 'emotions': emotions.map((e) => e.name).toList()};
  }
}
