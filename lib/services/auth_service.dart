import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;
  AuthService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> signInAnonymously() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        // Oturum yoksa, gizlice hesap oluştur (Anonim)
        await _supabase.auth.signInAnonymously();
        debugPrint("Yeni Bulut Hesabı Oluşturuldu: ${_supabase.auth.currentUser?.id}");
      } else {
        debugPrint("Mevcut Hesaba Giriş Yapıldı: ${_supabase.auth.currentUser?.id}");
      }
    } catch (e) {
      debugPrint("Auth Error: $e");
    }
  }

  String? getCurrentUserId() {
    return _supabase.auth.currentUser?.id;
  }
}
