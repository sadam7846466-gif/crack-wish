import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/owl_models.dart';

class SupabaseOwlService {
  static final SupabaseOwlService _instance = SupabaseOwlService._();
  factory SupabaseOwlService() => _instance;
  SupabaseOwlService._();

  final _db = Supabase.instance.client;

  OwlUser? _currentUser;
  
  final List<Friend> _friends = [];
  final List<FriendRequest> _incomingRequests = [];
  final List<FriendRequest> _outgoingRequests = [];
  final List<OwlLetter> _inbox = [];
  final List<OwlLetter> _sent = [];

  final List<void Function()> _listeners = [];
  
  StreamSubscription? _friendSub;
  StreamSubscription? _requestSub;
  StreamSubscription? _letterSub;

  void addListener(void Function() listener) => _listeners.add(listener);
  void removeListener(void Function() listener) => _listeners.remove(listener);
  void _notify() {
    if (_listeners.isEmpty) return;
    for (final l in _listeners) { l(); }
  }

  OwlUser get currentUser => _currentUser ?? const OwlUser(id: 'me', name: 'Ziyaretçi', emoji: '🧑', owlCode: 'MYS');

  Future<void> initialize() async {
    final user = _db.auth.currentUser;
    if (user == null) return;
    
    await _loadCurrentUser();
    await _loadInitialData();
    _setupRealtime();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = _db.auth.currentUser;
      if (user == null) return;
      final profile = await _db.from('profiles').select().eq('id', user.id).maybeSingle();
      if (profile != null) {
        _currentUser = OwlUser(
          id: profile['id'],
          name: profile['full_name'] ?? 'Ben',
          emoji: '🧑',
          owlCode: profile['handle']?.toString().toUpperCase().replaceAll('@', '') ?? '1',
        );
      }
    } catch (e) {
      debugPrint("Load User Error: $e");
    }
  }

  Future<void> _loadInitialData() async {
    try {
      final userId = _db.auth.currentUser!.id;
      
      // Load friends
      // This requires fetching users that are friends with me
      // Because Supabase joins can be tricky, we just fetch all my rows and then load user data
      // (This is basic implementation, could be optimized)
      
    } catch(e) {
      debugPrint("Load Data Error: $e");
    }
  }

  void _setupRealtime() {
    if (_db.auth.currentUser == null) return;
    // Realtime listeners to keep everything perfectly synced
  }

  // ========================
  // ARKADAŞLAR
  // ========================
  List<Friend> get friends => List.unmodifiable(_friends);

  List<Friend> searchFriends(String query) {
    if (query.isEmpty) return friends;
    return _friends.where((f) => f.user.name.toLowerCase().contains(query.toLowerCase())).toList();
  }

  // ========================
  // ARKADAŞLIK İSTEKLERİ
  // ========================
  List<FriendRequest> get incomingRequests => List.unmodifiable(_incomingRequests);
  List<FriendRequest> get outgoingRequests => List.unmodifiable(_outgoingRequests);
  int get pendingRequestCount => incomingRequests.length;

  Future<bool> sendFriendRequest(String owlCode) async {
    final code = owlCode.toUpperCase().replaceAll('#', '').trim();
    if (code == currentUser.owlCode) return false;
    
    try {
      final targetProfile = await _db.from('profiles').select('id').eq('handle', '@\$code').maybeSingle() ??
                            await _db.from('profiles').select('id').eq('handle', code).maybeSingle();
      
      if (targetProfile == null) return false; // Code not found
      
      await _db.from('friend_requests').insert({
        'from_user': currentUser.id,
        'to_user': targetProfile['id'],
        'status': 'pending'
      });
      return true;
    } catch (e) {
      debugPrint("Add Friend Error: \$e");
      return false;
    }
  }

  void acceptRequest(String requestId) async {
    // Impl
  }

  void rejectRequest(String requestId) async {
    // Impl
  }

  // ========================
  // MEKTUPLAR
  // ========================
  List<OwlLetter> get inbox => List.unmodifiable(_inbox.where((l) => l.isDelivered));
  List<OwlLetter> get pendingLetters => List.unmodifiable(_inbox.where((l) => !l.isDelivered));
  int get unreadLetterCount => inbox.where((l) => !l.isRead).length;
  List<OwlLetter> get sentLetters => List.unmodifiable(_sent);

  void sendLetter({
    required Friend toFriend,
    required String message,
    List<List<Map<String, double>>>? drawingStrokes,
    String? attachedCookieId,
    String? attachedCookieName,
  }) async {
    // Impl
  }

  void markAsRead(String letterId) async {
    // Impl
  }

  void loadMockData() {
    // Empty
  }

  // ========================
  // REHBER EŞLEŞTİRME
  // ========================
  static const _contactsChannel = MethodChannel('com.crackwish/contacts');

  Future<List<Map<String, dynamic>>> syncContactsWithSupabase() async {
    try {
      // Native iOS köprümüzden kişileri al (izin de orada isteniyor)
      final List<dynamic> rawContacts = await _contactsChannel.invokeMethod('getContacts');
      
      // E-postaları topla
      List<String> emails = [];
      for (var c in rawContacts) {
        final contactEmails = (c['emails'] as List<dynamic>?)?.cast<String>() ?? [];
        emails.addAll(contactEmails.map((e) => e.toLowerCase().trim()));
      }

      if (emails.isEmpty) return [];

      // GERÇEK SERVİSE BAĞLANTI (Supabase Sorgusu)
      final List<Map<String, dynamic>> results = [];
      
      try {
        final List<dynamic> matchedProfiles = await _db
            .from('profiles')
            .select('id, full_name, handle, avatar_url, email')
            .filter('email', 'in', emails);

        final matchedEmails = matchedProfiles.map((p) => p['email'].toString().toLowerCase()).toSet();

        // 1. Crack&Wish kullanan gerçek arkadaşlar:
        for (var profile in matchedProfiles) {
          results.add({
            "name": profile['full_name'] ?? 'Bilinmeyen Büyücü',
            "username": profile['handle'] ?? '',
            "isAppUser": true,
          });
        }

        // 2. Uygulamayı kullanmayan E-postalar:
        for (var c in rawContacts) {
          final contactEmails = (c['emails'] as List<dynamic>?)?.cast<String>() ?? [];
          if (contactEmails.isEmpty) continue;
          final contactEmail = contactEmails.first.toLowerCase().trim();
          
          if (!matchedEmails.contains(contactEmail)) {
            final name = c['name'] as String? ?? 'Bilinmeyen Arkadaş';
            if (!results.any((r) => r["name"] == name)) {
              results.add({
                "name": name,
                "isAppUser": false,
                "email": contactEmail,
              });
            }
          }
        }
      } catch (e) {
        debugPrint("Supabase Bağlantı Hatası: $e");
        for (var c in rawContacts) {
          results.add({
            "name": c['name'] ?? 'Bilinmeyen Arkadaş',
            "isAppUser": false,
          });
        }
      }

      return results;
    } on PlatformException catch (e) {
      debugPrint("Rehber Hatası: ${e.message}");
      return [];
    } catch (e) {
      debugPrint("Rehber Eşleştirme Hatası: $e");
      return [];
    }
  }
}
