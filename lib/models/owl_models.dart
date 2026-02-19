/// Baykuş Mektup sistemi modelleri

class OwlUser {
  final String id;
  final String name;
  final String emoji;
  final String owlCode; // #OWL-XXXX

  const OwlUser({
    required this.id,
    required this.name,
    required this.emoji,
    required this.owlCode,
  });
}

enum FriendStatus { pending, accepted, rejected }

class FriendRequest {
  final String id;
  final OwlUser from;
  final OwlUser to;
  FriendStatus status;
  final DateTime createdAt;

  FriendRequest({
    required this.id,
    required this.from,
    required this.to,
    this.status = FriendStatus.pending,
    required this.createdAt,
  });
}

class Friend {
  final String id;
  final OwlUser user;
  final DateTime friendsSince;

  const Friend({
    required this.id,
    required this.user,
    required this.friendsSince,
  });
}

class OwlLetter {
  final String id;
  final OwlUser from;
  final OwlUser to;
  final String message;
  final List<List<Map<String, double>>>? drawingStrokes;
  final String? attachedCookieId;
  final String? attachedCookieName;
  final DateTime sentAt;
  final DateTime deliveredAt;
  bool isRead;
  bool cookieClaimed; // alıcı kurabiyeyi aldı mı

  OwlLetter({
    required this.id,
    required this.from,
    required this.to,
    required this.message,
    this.drawingStrokes,
    this.attachedCookieId,
    this.attachedCookieName,
    required this.sentAt,
    required this.deliveredAt,
    this.isRead = false,
    this.cookieClaimed = false,
  });

  /// Mektup teslim edildi mi? (baykuş ulaştı mı)
  bool get isDelivered => DateTime.now().isAfter(deliveredAt);

  /// Teslim için kalan süre
  Duration get timeUntilDelivery => deliveredAt.difference(DateTime.now());
}
