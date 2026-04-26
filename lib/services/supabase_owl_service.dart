import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/owl_models.dart';
import 'storage_service.dart';
import 'sound_service.dart';
import 'analytics_service.dart';

class SupabaseOwlService {
  static final SupabaseOwlService _instance = SupabaseOwlService._();
  factory SupabaseOwlService() => _instance;
  SupabaseOwlService._() {
    _db.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.initialSession) {
        initialize();
      } else if (event == AuthChangeEvent.signedOut) {
        _friends.clear();
        _inbox.clear();
        _sent.clear();
        _incomingRequests.clear();
        _outgoingRequests.clear();
        _currentUser = null;
        _initialized = false;
        _notify();
      }
    });
  }

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
  Timer? _pollingTimer;
  bool _isInitializing = false;

  void addListener(void Function() listener) => _listeners.add(listener);
  void removeListener(void Function() listener) => _listeners.remove(listener);
  void _notify() {
    if (_listeners.isEmpty) return;
    for (final l in _listeners) { l(); }
  }

  OwlUser get currentUser => _currentUser ?? const OwlUser(id: 'me', name: 'Ziyaretçi', emoji: '🧑', owlCode: 'MYS');

  bool _initialized = false;
  String? _initializedUserId;

  Future<void> initialize() async {
    final user = _db.auth.currentUser;
    if (user == null) {
      debugPrint("🔴 [INIT] user is null, will retry on next call");
      return;
    }
    
    // Zaten tamamen yüklüyse atla
    if (_initialized && _initializedUserId == user.id) return;
    
    // Eşzamanlı çağrıları engelle (race condition koruması)
    if (_isInitializing) return;
    _isInitializing = true;
    
    // Eski realtime aboneliklerini ve timer'ı iptal et
    await _friendSub?.cancel();
    await _requestSub?.cancel();
    await _letterSub?.cancel();
    _friendSub = null;
    _requestSub = null;
    _letterSub = null;
    _pollingTimer?.cancel();
    _pollingTimer = null;
    
    _initialized = true;
    _initializedUserId = user.id;
    debugPrint("🟢 [INIT] Initializing SupabaseOwlService for user: ${user.id}");
    
    try {
      await _loadCurrentUser();
      await _loadInitialData();
      await _loadInboxFromSupabase();
      await _loadCosmicLetters();
      
      // Her zaman taze realtime abonelikleri kur
      _setupRealtime();
    } finally {
      _isInitializing = false;
    }
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
      final user = _db.auth.currentUser;
      if (user == null) {
        debugPrint("🔴 [LOAD] user is null, returning");
        return;
      }
      final userId = user.id;
      debugPrint("🟢 [LOAD] Loading data for user: $userId");
      
      // ── YENİ VERİLERİ GEÇİCİ LİSTELERDE TOPLA (eski veriyi SİLME!) ──
      
      // 1. Gelen Bekleyen İstekleri Yükle
      final List<FriendRequest> newRequests = [];
      final List<dynamic> requests = await _db.from('friend_requests')
          .select()
          .eq('to_user', userId)
          .eq('status', 'pending');
      
      debugPrint("🟢 [LOAD] friend_requests query returned ${requests.length} results");
          
      if (requests.isNotEmpty) {
         final senderIds = requests.map((r) => r['from_user']).toSet().toList();
         
         final profiles = await _db.from('profiles')
             .select('id, full_name, handle, avatar_url')
             .inFilter('id', senderIds.map((e) => e.toString()).toList());
             
         final Map<String, dynamic> profileMap = { for (var p in profiles) p['id'].toString(): p };
         
         for (var req in requests) {
            final senderId = req['from_user'].toString();
            final p = profileMap[senderId];
            if (p != null) {
               newRequests.add(FriendRequest(
                  id: req['id'].toString(),
                  from: OwlUser(
                    id: p['id'].toString(),
                    name: p['full_name'] ?? 'Ruhsal Rehber',
                    emoji: '🧑',
                    owlCode: p['handle']?.toString().replaceFirst('@', '') ?? 'MYS',
                    avatarUrl: p['avatar_url']?.toString(),
                  ),
                  to: currentUser,
                  createdAt: DateTime.tryParse(req['created_at'].toString()) ?? DateTime.now(),
               ));
            }
         }
      }
      
      // 2. Kabul Edilen Arkadaşlıkları Yükle (GEÇİCİ LİSTEYE!)
      final List<Friend> newFriends = [];
      
      final List<dynamic> acceptedFrom = await _db.from('friend_requests')
          .select()
          .eq('to_user', userId)
          .eq('status', 'accepted');
      
      final List<dynamic> acceptedTo = await _db.from('friend_requests')
          .select()
          .eq('from_user', userId)
          .eq('status', 'accepted');
      
      // Tüm arkadaş ID'lerini topla
      final Set<String> friendIds = {};
      for (var r in acceptedFrom) { friendIds.add(r['from_user'].toString()); }
      for (var r in acceptedTo) { friendIds.add(r['to_user'].toString()); }
      debugPrint("🟢 [FRIENDS] Friend IDs: $friendIds");
      
      if (friendIds.isNotEmpty) {
        final friendProfiles = await _db.from('profiles')
            .select('id, full_name, handle, avatar_url')
            .inFilter('id', friendIds.map((e) => e.toString()).toList());
        
        for (var p in friendProfiles) {
          final uid = p['id'].toString();
          if (uid == userId) continue; // Kendisini arkadaş listesine eklemesin
          if (newFriends.any((f) => f.user.id == uid)) continue;
          newFriends.add(Friend(
            id: 'friend_$uid',
            user: OwlUser(
              id: uid,
              name: p['full_name'] ?? 'Arkadaş',
              emoji: '🧑',
              owlCode: p['handle']?.toString().replaceFirst('@', '') ?? '',
              avatarUrl: p['avatar_url']?.toString(),
            ),
            friendsSince: DateTime.now(),
          ));
        }
      }
      
      // ── BAŞARILI! Şimdi ATOMİK OLARAK eski listeyi yenisiyle değiştir ──
      _incomingRequests.clear();
      _incomingRequests.addAll(newRequests);
      _friends.clear();
      _friends.addAll(newFriends);
      
      debugPrint("🟢 [LOAD] Final: ${_incomingRequests.length} requests, ${_friends.length} friends");
      _notify();
      
    } catch(e, stack) {
      // ⚠️ HATA OLURSA ESKİ VERİYE DOKUNMA! Kullanıcı mevcut arkadaşlarını görmeye devam etsin.
      debugPrint("🔴 [LOAD] Error (keeping existing data): $e");
      debugPrint("🔴 [LOAD] Stack: $stack");
    }
  }

  void _setupRealtime() {
    if (_db.auth.currentUser == null) return;
    
    // Gelen İstekler ve Kabul Edilen Arkadaşlıklar Bağlantısı
    _requestSub = _db.from('friend_requests')
      .stream(primaryKey: ['id'])
      .listen((data) {
        final userId = _db.auth.currentUser?.id;
        if (userId == null) return;
        
        bool hasRelevantChange = data.any((row) => 
            row['to_user'] == userId || row['from_user'] == userId);
            
         if (hasRelevantChange) {
           _loadInitialData();
        }
      });
    
    // Gelen Mektuplar Bağlantısı
    _letterSub = _db.from('owl_letters')
      .stream(primaryKey: ['id'])
      .eq('to_user', _db.auth.currentUser!.id)
      .listen((data) {
         _loadInboxFromSupabase(playSound: true);
      });

    // Supabase Realtime fallback: 30 saniyede bir senkronize et
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_currentUser == null) {
        timer.cancel();
        _pollingTimer = null;
        return;
      }
      _loadInitialData();
      _loadInboxFromSupabase();
    });
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
    final authUser = _db.auth.currentUser;
    if (authUser == null) {
      debugPrint("🔴 [SEND] Auth user is null, cannot send");
      return false;
    }
    final myId = authUser.id;
    debugPrint("🟡 [SEND] sendFriendRequest called with: '$owlCode'");
    debugPrint("🟡 [SEND] myId: '$myId', owlCode: '${currentUser.owlCode}'");
    
    final code = owlCode.replaceAll('#', '').replaceAll('@', '').trim();
    debugPrint("🟡 [SEND] cleaned code: '$code'");
    
    if (code == currentUser.owlCode.replaceAll('@', '')) {
      debugPrint("🔴 [SEND] Same user, returning false");
      return false;
    }
    
    try {
      // Önce handle ile ara
      debugPrint("🟡 [SEND] Searching profiles for handle='$code'");
      var targetProfile = await _db.from('profiles').select('id, handle, full_name').eq('handle', code).maybeSingle();
      debugPrint("🟡 [SEND] handle='$code' result: $targetProfile");
      
      targetProfile ??= await _db.from('profiles').select('id, handle, full_name').eq('handle', code.toLowerCase()).maybeSingle();
      debugPrint("🟡 [SEND] handle='${code.toLowerCase()}' result: $targetProfile");
      
      // handle @ ile kayıtlı olabilir
      targetProfile ??= await _db.from('profiles').select('id, handle, full_name').eq('handle', '@$code').maybeSingle();
      debugPrint("🟡 [SEND] handle='@$code' result: $targetProfile");
      
      targetProfile ??= await _db.from('profiles').select('id, handle, full_name').eq('handle', '@${code.toLowerCase()}').maybeSingle();
      debugPrint("🟡 [SEND] handle='@${code.toLowerCase()}' result: $targetProfile");
      
      if (targetProfile == null) {
        debugPrint("🔴 [SEND] No profile found for '$code' in any variant!");
        
        // Son çare: tüm profilleri listele debug için
        final allProfiles = await _db.from('profiles').select('id, handle, full_name').limit(20);
        debugPrint("🟡 [SEND] ALL PROFILES (first 20): $allProfiles");
        return false;
      }
      
      debugPrint("🟢 [SEND] Found target: ${targetProfile['id']} (${targetProfile['full_name']})");
      
      final targetId = targetProfile['id'].toString();
      await _db.from('friend_requests').insert({
        'from_user': myId,
        'to_user': targetId,
        'status': 'pending'
      });
      debugPrint("🟢 [SEND] ✅ INSERT SUCCESSFUL! from=$myId to=$targetId");
      AnalyticsService().logFriendRequestSent();
      return true;
    } catch (e, stack) {
      debugPrint("🔴 [SEND] Error: $e");
      debugPrint("🔴 [SEND] Stack: $stack");
      return false;
    }
  }

  /// userId ile doğrudan istek gönder (handle araması yapmadan)
  Future<bool> sendFriendRequestById(String targetUserId) async {
    final authUser = _db.auth.currentUser;
    if (authUser == null) {
      debugPrint("🔴 [SEND_BY_ID] Auth user is null, cannot send");
      return false;
    }
    final myId = authUser.id;
    debugPrint("🟡 [SEND_BY_ID] targetUserId='$targetUserId', myId='$myId'");
    if (targetUserId == myId) {
      debugPrint("🔴 [SEND_BY_ID] Same user!");
      return false;
    }
    try {
      // Aynı istek daha önce gönderilmiş mi kontrol et
      final existing = await _db.from('friend_requests')
          .select('id')
          .eq('from_user', myId)
          .eq('to_user', targetUserId)
          .maybeSingle();
      if (existing != null) {
        debugPrint("🟡 [SEND_BY_ID] Already sent, skipping");
        return true; // Zaten gönderilmiş, başarılı sayalım
      }
      
      await _db.from('friend_requests').insert({
        'from_user': myId,
        'to_user': targetUserId,
        'status': 'pending',
      });
      debugPrint("🟢 [SEND_BY_ID] ✅ INSERT SUCCESSFUL!");
      AnalyticsService().logFriendRequestSent();
      return true;
    } catch (e, stack) {
      debugPrint("🔴 [SEND_BY_ID] Error: $e");
      debugPrint("🔴 [SEND_BY_ID] Stack: $stack");
      return false;
    }
  }

  final Set<String> _processingRequestIds = {};

  Future<void> acceptRequest(String requestId) async {
    // Çift tıklama koruması
    if (_processingRequestIds.contains(requestId)) return;
    _processingRequestIds.add(requestId);
    
    try {
      debugPrint("🟢 [ACCEPT] Accepting request: $requestId");
      
      // 1. İsteği bul
      final reqIndex = _incomingRequests.indexWhere((r) => r.id == requestId);
      FriendRequest? acceptedReq;
      if (reqIndex != -1) {
        acceptedReq = _incomingRequests[reqIndex];
        _incomingRequests.removeAt(reqIndex);
      }
      
      // 2. Supabase'de status'u 'accepted' yap
      await _db.from('friend_requests')
          .update({'status': 'accepted'})
          .eq('id', requestId);
      
      // 3. Duplicate kontrolü — zaten arkadaşsa ekleme
      if (acceptedReq != null && !_friends.any((f) => f.user.id == acceptedReq!.from.id)) {
        _friends.add(Friend(
          id: 'friend_${acceptedReq.from.id}',
          user: acceptedReq.from,
          friendsSince: DateTime.now(),
        ));
      }
      
      debugPrint("🟢 [ACCEPT] ✅ Request accepted! Friends count: ${_friends.length}");
      _notify();
    } catch (e) {
      debugPrint("🔴 [ACCEPT] Error: $e");
    } finally {
      _processingRequestIds.remove(requestId);
    }
  }

  Future<void> rejectRequest(String requestId) async {
    // Çift tıklama koruması
    if (_processingRequestIds.contains(requestId)) return;
    _processingRequestIds.add(requestId);
    
    try {
      debugPrint("🟡 [REJECT] Rejecting request: $requestId");
      
      _incomingRequests.removeWhere((r) => r.id == requestId);
      
      await _db.from('friend_requests')
          .delete()
          .eq('id', requestId);
      
      debugPrint("🟢 [REJECT] ✅ Request rejected and deleted");
      _notify();
    } catch (e) {
      debugPrint("🔴 [REJECT] Error: $e");
    } finally {
      _processingRequestIds.remove(requestId);
    }
  }

  Future<void> unfriend(String friendId) async {
    final user = _db.auth.currentUser;
    if (user == null) return;
    
    try {
      debugPrint("🟡 [UNFRIEND] Unfriending: $friendId");
      
      // Remove from local list
      _friends.removeWhere((f) => f.user.id == friendId);
      
      // Delete from database
      await _db.from('friend_requests')
          .delete()
          .eq('status', 'accepted')
          .or('and(from_user.eq.${user.id},to_user.eq.$friendId),and(from_user.eq.$friendId,to_user.eq.${user.id})');
          
      debugPrint("🟢 [UNFRIEND] ✅ Unfriended successfully");
      _notify(); // UI güncellensin
    } catch (e) {
      debugPrint("🔴 [UNFRIEND] Error: $e");
    }
  }

  // ========================
  // MEKTUPLAR
  // ========================
  List<OwlLetter> get inbox => List.unmodifiable(_inbox.where((l) => l.isDelivered));
  List<OwlLetter> get pendingLetters => List.unmodifiable(_inbox.where((l) => !l.isDelivered));
  int get unreadLetterCount => inbox.where((l) => !l.isRead).length;
  List<OwlLetter> get sentLetters => List.unmodifiable(_sent);

  /// Supabase'den gelen mektupları çek
  Future<void> _loadInboxFromSupabase({bool playSound = false}) async {
    try {
      final prevCount = _inbox.length; // Ses kontrolü için önceki sayı
      final user = _db.auth.currentUser;
      if (user == null) return;
      
      // Bana gelen mektuplar
      final List<dynamic> received = await _db.from('owl_letters')
          .select()
          .eq('to_user', user.id)
          .order('created_at', ascending: false);
      
      debugPrint("📨 [INBOX] Received letters: ${received.length}");
      
      // Benim gönderdiğim mektuplar
      final List<dynamic> sentFromDb = await _db.from('owl_letters')
          .select()
          .eq('from_user', user.id)
          .order('created_at', ascending: false);
      
      debugPrint("📨 [INBOX] Sent letters: ${sentFromDb.length}");
      
      // Tüm kullanıcı ID'lerini topla profil bilgisi için
      final Set<String> userIds = {};
      for (var l in received) { userIds.add(l['from_user'].toString()); }
      for (var l in sentFromDb) { userIds.add(l['to_user'].toString()); }
      
      Map<String, dynamic> profileMap = {};
      if (userIds.isNotEmpty) {
        final profiles = await _db.from('profiles')
            .select('id, full_name, handle, avatar_url')
            .inFilter('id', userIds.map((e) => e.toString()).toList());
        profileMap = { for (var p in profiles) p['id'].toString(): p };
      }
      final prefs = await SharedPreferences.getInstance();
      final claimedList = prefs.getStringList('claimed_letter_cookies') ?? [];

      // Gelen mektupları inbox'a ekle
      for (var l in received) {
        final letterId = l['id'].toString();
        if (_inbox.any((e) => e.id == letterId)) continue; // Duplicate kontrolü
        
        final senderId = l['from_user'].toString();
        if (senderId == user.id) continue; // Kendisinden kendisine gelen mektupları iptal et (önceki test bug'larını temizle)

        final senderProfile = profileMap[senderId];
        
        _inbox.add(OwlLetter(
          id: letterId,
          from: OwlUser(
            id: senderId,
            name: senderProfile?['full_name'] ?? 'Bilinmeyen',
            emoji: '🧑',
            owlCode: senderProfile?['handle']?.toString().replaceFirst('@', '') ?? '',
            avatarUrl: senderProfile?['avatar_url']?.toString(),
          ),
          to: currentUser,
          message: l['content'] ?? '',
          attachedCookieId: l['attached_cookie_id']?.toString(),
          attachedCookieName: l['attached_cookie_name']?.toString(),
          sentAt: DateTime.tryParse(l['created_at'].toString()) ?? DateTime.now(),
          deliveredAt: DateTime.tryParse(l['created_at'].toString()) ?? DateTime.now(),
          cookieClaimed: claimedList.contains(letterId),
          isRead: l['is_read'] == true,
        ));
      }
      
      // Gönderilen mektupları sent'e ekle
      for (var l in sentFromDb) {
        final letterId = l['id'].toString();
        if (_sent.any((e) => e.id == letterId)) continue;
        
        final receiverId = l['to_user'].toString();
        final receiverProfile = profileMap[receiverId];
        
        _sent.add(OwlLetter(
          id: letterId,
          from: currentUser,
          to: OwlUser(
            id: receiverId,
            name: receiverProfile?['full_name'] ?? 'Bilinmeyen',
            emoji: '🧑',
            owlCode: receiverProfile?['handle']?.toString().replaceFirst('@', '') ?? '',
            avatarUrl: receiverProfile?['avatar_url']?.toString(),
          ),
          message: l['content'] ?? '',
          attachedCookieId: l['attached_cookie_id']?.toString(),
          attachedCookieName: l['attached_cookie_name']?.toString(),
          sentAt: DateTime.tryParse(l['created_at'].toString()) ?? DateTime.now(),
          deliveredAt: DateTime.tryParse(l['created_at'].toString()) ?? DateTime.now(),
        ));
      }
      
      _inbox.sort((a, b) => b.sentAt.compareTo(a.sentAt));
      _sent.sort((a, b) => b.sentAt.compareTo(a.sentAt));
      
      // 🔔 Yeni mektup geldiyse baykuş zili çal
      if (playSound && _inbox.length > prevCount) {
        SoundService().playOwlLetter();
      }
      
      _notify();
      
    } catch (e) {
      debugPrint("🔴 [INBOX] Error loading letters: $e");
    }
  }

  Future<void> sendLetter({
    required Friend toFriend,
    required String message,
    List<List<Map<String, double>>>? drawingStrokes,
    String? attachedCookieId,
    String? attachedCookieName,
  }) async {
    // 1. Ekrandaki Giden Kutusuna (UI) hemen ekle (hız hissi vermek için)
    final instantLetter = OwlLetter(
      id: 'local_\${DateTime.now().millisecondsSinceEpoch}',
      from: currentUser,
      to: toFriend.user,
      message: message,
      attachedCookieId: attachedCookieId,
      attachedCookieName: attachedCookieName,
      sentAt: DateTime.now(),
      deliveredAt: DateTime.now().add(const Duration(minutes: 5)), // Baykuş yola çıktı!
    );
    _sent.insert(0, instantLetter);
    _notify(); // UI anında güncellensin

    // 1.5 Eğer mektupla birlikte bir "Kurabiye Gönderildiyse", gönderenin envanterinden 1 tane eksilt.
    // (Böylece oyun ekonomisi kurulmuş olur, başkasına attığın şey senden gider).
    if (attachedCookieId != null && attachedCookieId.isNotEmpty) {
      await StorageService.decrementCookieCard(attachedCookieId);
    }

    // 2. Arka planda gerçek SQL sunucusuna (Supabase) gönder
    if (_db.auth.currentUser != null) {
      try {
        final letterData = {
          'from_user': _db.auth.currentUser!.id,
          'to_user': toFriend.user.id,
          'content': message,
          'attached_cookie_id': attachedCookieId,
          'attached_cookie_name': attachedCookieName,
        };
        await _db.from('owl_letters').insert(letterData);
        debugPrint("🦉 Mektup Supabase'e fırlatıldı!");
        AnalyticsService().logOwlLetterSent();
      } catch (e) {
         debugPrint("🦉 Bağlantı yok ama mektup kasada tutuluyor (CloudSync eşleyene kadar): \$e");
      }
    }
  }

  void markAsRead(String letterId) async {
    try {
      // 1. Lokalde oku olarak işaretle ki ekrandaki kırmızı okubadı (Unread) rozeti kaybolsun
      final index = _inbox.indexWhere((l) => l.id == letterId);
      if (index != -1) {
        _inbox[index].isRead = true; // Modelde zaten 'bool isRead;' şeklinde mutable tanımlanmış
        _notify();
      }

      // 2. Gerçek veritabanında okundu yap
      if (!letterId.startsWith('local_') && !letterId.startsWith('cosmic_')) {
        await _db.from('owl_letters').update({'is_read': true}).eq('id', letterId);
      }
    } catch(e) {
      debugPrint("Mark As Read Error: $e");
    }
  }

  void markCookieClaimed(String letterId) async {
    try {
      final index = _inbox.indexWhere((l) => l.id == letterId);
      if (index != -1) {
        _inbox[index].cookieClaimed = true;
        _notify();
      }

      final prefs = await SharedPreferences.getInstance();
      final claimedList = prefs.getStringList('claimed_letter_cookies') ?? [];
      if (!claimedList.contains(letterId)) {
        claimedList.add(letterId);
        await prefs.setStringList('claimed_letter_cookies', claimedList);
      }
    } catch(e) {
      debugPrint("Mark Cookie Claimed Error: $e");
    }
  }

  void loadMockData() {
    // Empty
  }

  /// İlizyon Motorunun sessizce bıraktığı sistem mektuplarını Posta Kutusuna (Inbox) çeker
  Future<void> _loadCosmicLetters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var lettersVec = prefs.getStringList('cosmic_inbox_letters') ?? [];
      
      for (var stringJson in lettersVec) {
         final data = jsonDecode(stringJson);
         
         // Zarfı mevcut gelen kutumuza (inbox) modelleyip ekliyoruz.
         // Evreni (CosmicOwl) sahte bir arkadaş gibi simüle ediyoruz.
         OwlLetter letter = OwlLetter(
           id: data['id'],
           from: OwlUser(
             id: 'cosmic_owl',
             name: data['senderName'], // "Kozmik Baykuş" veya "Evren"
             emoji: '🌌',
             owlCode: 'COSMIC',
           ),
           to: currentUser,
           message: data['content'],
           sentAt: DateTime.parse(data['date'] ?? DateTime.now().toIso8601String()),
           deliveredAt: DateTime.parse(data['date'] ?? DateTime.now().toIso8601String()),
         );
         
         // Önceden listeye eklenmemişse ekle
         if (!_inbox.any((element) => element.id == letter.id)) {
            _inbox.add(letter);
         }
      }
      _inbox.sort((a,b) => b.sentAt.compareTo(a.sentAt)); // Yeniden eskiye
      _notify(); // Ekranın Posta kutusu kırmızı yansın diye listeyi yenile
    } catch(e) {
      debugPrint("Sistem mektupları çekilemedi: \$e");
    }
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
          if (profile['id'].toString() == _db.auth.currentUser?.id) continue; // Kendini göstermesin
          
          results.add({
            "name": profile['full_name'] ?? 'Bilinmeyen Büyücü',
            "username": profile['handle'] ?? '',
            "userId": profile['id'] ?? '',
            "avatar_url": profile['avatar_url'],
            "isAppUser": true,
          });
        }

        // 2. Uygulamayı kullanmayan E-postalar (Davet Listesi):
        for (var c in rawContacts) {
          final contactEmails = (c['emails'] as List<dynamic>?)?.cast<String>() ?? [];
          final contactPhones = (c['phones'] as List<dynamic>?)?.cast<String>() ?? [];
          final name = c['name'] as String? ?? 'Bilinmeyen Arkadaş';

          if (contactEmails.isEmpty) {
            // E-postası olmayanları da sadece "Davet Et" diyebilmek için listeye ekle
            if (!results.any((r) => r["name"] == name)) {
              results.add({
                "name": name,
                "isAppUser": false,
                "phone": contactPhones.isNotEmpty ? contactPhones.first : null,
              });
            }
            continue;
          }

          final contactEmail = contactEmails.first.toLowerCase().trim();
          
          if (!matchedEmails.contains(contactEmail)) {
            if (!results.any((r) => r["name"] == name)) {
              results.add({
                "name": name,
                "isAppUser": false,
                "email": contactEmail,
                "phone": contactPhones.isNotEmpty ? contactPhones.first : null,
              });
            }
          }
        }
      } catch (e) {
        debugPrint("Supabase Bağlantı Hatası: $e");
        for (var c in rawContacts) {
          final contactPhones = (c['phones'] as List<dynamic>?)?.cast<String>() ?? [];
          results.add({
            "name": c['name'] ?? 'Bilinmeyen Arkadaş',
            "isAppUser": false,
            "phone": contactPhones.isNotEmpty ? contactPhones.first : null,
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
