import 'dart:math';
import '../models/owl_models.dart';

/// Mock servis — backend gelince bu sınıf swap edilecek
/// Tüm veri local'de tutuluyor, gerçek API çağrısı yok
class MockOwlService {
  static final MockOwlService _instance = MockOwlService._();
  factory MockOwlService() => _instance;
  MockOwlService._();

  // --- Mevcut kullanıcı ---
  final OwlUser currentUser = const OwlUser(
    id: 'user_me',
    name: 'Ben',
    emoji: '🧑',
    owlCode: 'OWL-7284',
  );

  // --- Arkadaşlar ---
  final List<Friend> _friends = [
    Friend(
      id: 'f1',
      user: const OwlUser(id: 'u1', name: 'Elif Yılmaz', emoji: '🧑‍🦰', owlCode: 'OWL-1234'),
      friendsSince: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Friend(
      id: 'f2',
      user: const OwlUser(id: 'u2', name: 'Ahmet Kaya', emoji: '👨', owlCode: 'OWL-5678'),
      friendsSince: DateTime.now().subtract(const Duration(days: 14)),
    ),
    Friend(
      id: 'f3',
      user: const OwlUser(id: 'u3', name: 'Selin Arslan', emoji: '👧', owlCode: 'OWL-9012'),
      friendsSince: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  // --- Arkadaşlık istekleri ---
  final List<FriendRequest> _incomingRequests = [
    FriendRequest(
      id: 'req1',
      from: const OwlUser(id: 'u4', name: 'Zeynep Demir', emoji: '👩', owlCode: 'OWL-3456'),
      to: const OwlUser(id: 'user_me', name: 'Ben', emoji: '🧑', owlCode: 'OWL-7284'),
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  final List<FriendRequest> _outgoingRequests = [
    FriendRequest(
      id: 'req2',
      from: const OwlUser(id: 'user_me', name: 'Ben', emoji: '🧑', owlCode: 'OWL-7284'),
      to: const OwlUser(id: 'u5', name: 'Burak Çelik', emoji: '🧔', owlCode: 'OWL-4321'),
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  // --- Mektuplar (gelen kutusu) ---
  final List<OwlLetter> _inbox = [];

  // --- Gönderilen mektuplar ---
  final List<OwlLetter> _sent = [];

  // Callback'ler — UI güncellemek için
  final List<void Function()> _listeners = [];

  void addListener(void Function() listener) => _listeners.add(listener);
  void removeListener(void Function() listener) => _listeners.remove(listener);
  void _notify() {
    for (final l in _listeners) {
      l();
    }
  }

  // ========================
  // ARKADAŞLAR
  // ========================

  List<Friend> get friends => List.unmodifiable(_friends);

  List<Friend> searchFriends(String query) {
    if (query.isEmpty) return friends;
    return _friends
        .where((f) => f.user.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // ========================
  // ARKADAŞLIK İSTEKLERİ
  // ========================

  List<FriendRequest> get incomingRequests =>
      List.unmodifiable(_incomingRequests.where((r) => r.status == FriendStatus.pending));

  List<FriendRequest> get outgoingRequests =>
      List.unmodifiable(_outgoingRequests.where((r) => r.status == FriendStatus.pending));

  int get pendingRequestCount => incomingRequests.length;

  /// Kod ile arkadaşlık isteği gönder
  /// Returns: true = gönderildi, false = kod bulunamadı
  Future<bool> sendFriendRequest(String owlCode) async {
    // Simüle et: 500ms gecikme
    await Future.delayed(const Duration(milliseconds: 500));

    final code = owlCode.toUpperCase().replaceAll('#', '').trim();

    // Kendine istek gönderemez
    if (code == currentUser.owlCode) return false;

    // Zaten arkadaş mı?
    if (_friends.any((f) => f.user.owlCode == code)) return false;

    // Zaten istek var mı?
    if (_outgoingRequests.any((r) => r.to.owlCode == code && r.status == FriendStatus.pending)) {
      return false;
    }

    // Mock: her kod geçerli, rastgele bir kullanıcı oluştur
    final mockUser = OwlUser(
      id: 'u_${Random().nextInt(9999)}',
      name: 'Kullanıcı $code',
      emoji: ['👤', '🧑', '👩', '👨', '🧔'][Random().nextInt(5)],
      owlCode: code,
    );

    _outgoingRequests.add(FriendRequest(
      id: 'req_${Random().nextInt(9999)}',
      from: currentUser,
      to: mockUser,
      createdAt: DateTime.now(),
    ));

    _notify();
    return true;
  }

  /// Gelen isteği kabul et
  void acceptRequest(String requestId) {
    final req = _incomingRequests.firstWhere((r) => r.id == requestId);
    req.status = FriendStatus.accepted;

    _friends.add(Friend(
      id: 'f_${Random().nextInt(9999)}',
      user: req.from,
      friendsSince: DateTime.now(),
    ));

    _notify();
  }

  /// Gelen isteği reddet
  void rejectRequest(String requestId) {
    final req = _incomingRequests.firstWhere((r) => r.id == requestId);
    req.status = FriendStatus.rejected;
    _notify();
  }

  // ========================
  // MEKTUPLAR
  // ========================

  List<OwlLetter> get inbox => List.unmodifiable(_inbox.where((l) => l.isDelivered));

  List<OwlLetter> get pendingLetters => List.unmodifiable(_inbox.where((l) => !l.isDelivered));

  int get unreadLetterCount => inbox.where((l) => !l.isRead).length;

  List<OwlLetter> get sentLetters => List.unmodifiable(_sent);

  /// Mektup gönder — 1-3 dakika gecikme ile teslim edilir
  void sendLetter({
    required Friend toFriend,
    required String message,
    List<List<Map<String, double>>>? drawingStrokes,
    String? attachedCookieId,
    String? attachedCookieName,
  }) {
    final delay = Duration(seconds: 5 + Random().nextInt(10)); // Demo için kısa: 5-15 sn
    final now = DateTime.now();

    final letter = OwlLetter(
      id: 'letter_${Random().nextInt(99999)}',
      from: currentUser,
      to: toFriend.user,
      message: message,
      drawingStrokes: drawingStrokes,
      attachedCookieId: attachedCookieId,
      attachedCookieName: attachedCookieName,
      sentAt: now,
      deliveredAt: now.add(delay),
    );

    _sent.add(letter);

    // Mock: karşı tarafın inbox'ına da ekle (demo amaçlı kendimize de gönderelim)
    final echoLetter = OwlLetter(
      id: 'letter_echo_${Random().nextInt(99999)}',
      from: toFriend.user,
      to: currentUser,
      message: '↩️ $message',
      sentAt: now.add(delay),
      deliveredAt: now.add(delay + const Duration(seconds: 10)),
    );

    _inbox.add(echoLetter);
    _notify();
  }

  /// Mektubu okundu olarak işaretle
  void markAsRead(String letterId) {
    final letter = _inbox.firstWhere((l) => l.id == letterId);
    letter.isRead = true;
    _notify();
  }

  // ========================
  // MOCK DATA BAŞLAT
  // ========================

  /// Demo verisi: başlangıçta birkaç mektup ekle
  void loadMockData() {
    if (_inbox.isNotEmpty) return;

    _inbox.addAll([
      OwlLetter(
        id: 'letter_mock_1',
        from: _friends[0].user, // Elif
        to: currentUser,
        message: 'Merhaba! Nasılsın? 💛',
        sentAt: DateTime.now().subtract(const Duration(hours: 2)),
        deliveredAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 55)),
      ),
      OwlLetter(
        id: 'letter_mock_2',
        from: _friends[2].user, // Selin
        to: currentUser,
        message: 'Bugün harika bir gün! 🌟\nSana şans diliyorum!',
        sentAt: DateTime.now().subtract(const Duration(days: 1)),
        deliveredAt: DateTime.now().subtract(const Duration(hours: 23, minutes: 57)),
      ),
      OwlLetter(
        id: 'letter_mock_3',
        from: _friends[1].user, // Ahmet
        to: currentUser,
        message: 'Sana bir kurabiye gönderiyorum! 🥠✨',
        attachedCookieId: 'fortune_cat',
        attachedCookieName: 'Şans Kedisi',
        sentAt: DateTime.now().subtract(const Duration(hours: 1)),
        deliveredAt: DateTime.now().subtract(const Duration(minutes: 55)),
      ),
    ]);
  }
}
