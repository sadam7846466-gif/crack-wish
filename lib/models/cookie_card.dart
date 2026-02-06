class CookieCard {
  final String id;
  final String emoji;
  final String name;
  final String rarity; // common, rare, legendary
  final String? theme;
  final DateTime? firstObtainedDate;
  final int countObtained;
  final bool isFavorite;

  const CookieCard({
    required this.id,
    required this.emoji,
    required this.name,
    required this.rarity,
    this.theme,
    this.firstObtainedDate,
    this.countObtained = 0,
    this.isFavorite = false,
  });

  CookieCard copyWith({
    DateTime? firstObtainedDate,
    int? countObtained,
    bool? isFavorite,
  }) {
    return CookieCard(
      id: id,
      emoji: emoji,
      name: name,
      rarity: rarity,
      theme: theme,
      firstObtainedDate: firstObtainedDate ?? this.firstObtainedDate,
      countObtained: countObtained ?? this.countObtained,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'emoji': emoji,
        'name': name,
        'rarity': rarity,
        'theme': theme,
        'firstObtainedDate': firstObtainedDate?.toIso8601String(),
        'countObtained': countObtained,
        'isFavorite': isFavorite,
      };

  factory CookieCard.fromJson(Map<String, dynamic> json) {
    return CookieCard(
      id: json['id'] as String,
      emoji: json['emoji'] as String,
      name: json['name'] as String,
      rarity: json['rarity'] as String,
      theme: json['theme'] as String?,
      firstObtainedDate: json['firstObtainedDate'] != null
          ? DateTime.tryParse(json['firstObtainedDate'] as String)
          : null,
      countObtained: (json['countObtained'] ?? 0) as int,
      isFavorite: (json['isFavorite'] ?? false) as bool,
    );
  }
}
