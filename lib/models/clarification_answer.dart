/// Netleştirme sorusuna verilen cevap
class ClarificationAnswer {
  final String questionId;
  final String answer; // yes / no / unsure / free-short

  ClarificationAnswer(this.questionId, this.answer);

  /// JSON'dan oluştur
  factory ClarificationAnswer.fromJson(Map<String, dynamic> json) {
    return ClarificationAnswer(
      json['questionId'] as String,
      json['answer'] as String,
    );
  }

  /// JSON'a dönüştür
  Map<String, dynamic> toJson() {
    return {'questionId': questionId, 'answer': answer};
  }
}
