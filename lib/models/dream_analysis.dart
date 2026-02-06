/// Rüya metninin bilişsel analizi
/// Bu sembol yorumu değil, bilişsel sinyal tespiti
class DreamAnalysis {
  final bool hasThreat;
  final bool hasPastReference;
  final bool hasMovement;
  final bool isSingleScene;

  const DreamAnalysis({
    required this.hasThreat,
    required this.hasPastReference,
    required this.hasMovement,
    required this.isSingleScene,
  });

  /// Geriye dönük uyumluluk
  bool get hasPastSetting => hasPastReference;
}
