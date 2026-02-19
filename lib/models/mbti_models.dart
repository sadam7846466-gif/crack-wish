class MBTIQuestion {
  final String text;
  final String axis; // EI, SN, TF, JP, AT
  final bool reverse;

  const MBTIQuestion({
    required this.text,
    required this.axis,
    required this.reverse,
  });
}

class MBTIType {
  final String code;
  final String name;
  final String nickname;
  final String emoji;
  final String description;
  final String negatives;
  final String relationships;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> careers;
  final List<String> famous;
  final List<String> compatible;
  final List<String> tips;

  const MBTIType({
    required this.code,
    required this.name,
    required this.nickname,
    required this.emoji,
    required this.description,
    required this.negatives,
    required this.relationships,
    required this.strengths,
    required this.weaknesses,
    required this.careers,
    required this.famous,
    required this.compatible,
    required this.tips,
  });
}

class MBTIResultData {
  final String type;
  final Map<String, int> scores;
  final Map<String, int> percentages;
  final DateTime date;

  MBTIResultData({
    required this.type,
    required this.scores,
    required this.percentages,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'scores': scores,
        'percentages': percentages,
        'date': date.toIso8601String(),
      };

  factory MBTIResultData.fromJson(Map<String, dynamic> json) {
    return MBTIResultData(
      type: json['type'] as String,
      scores: Map<String, int>.from(json['scores'] as Map),
      percentages: Map<String, int>.from(json['percentages'] as Map),
      date: DateTime.parse(json['date'] as String),
    );
  }
}
