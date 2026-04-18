import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

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

  /// ----------------------------------------
  /// GOOGLE GİRİŞİ (NATIVE)
  /// ----------------------------------------
  Future<AuthResponse?> signInWithGoogle() async {
    try {
      // 1. Google ile native giriş başlat
      const webClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID', defaultValue: '79501630124-fts9hq66lm9cpbdps3hf9an9vnoje65i.apps.googleusercontent.com');
      const iosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID', defaultValue: '79501630124-peeupkr8v24kkgla408kg741dcd1n2fp.apps.googleusercontent.com');

      if (webClientId.contains('TODO') || (defaultTargetPlatform == TargetPlatform.iOS && iosClientId.contains('TODO'))) {
        throw 'Geliştirici Hatası: Google Client ID ayarlamaları eksik! Uygulamanın çökmesini (crash) iptal ettik. Lütfen Supabase/Firebase Client ID\'lerinizi girin ve Info.plist ayarlarını yapın.';
      }

      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
        clientId: defaultTargetPlatform == TargetPlatform.iOS ? iosClientId : null,
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // Kullanıcı girişi iptal etti
        return null;
      }

      // 2. Google'dan Authentication bilgilerini (Token) al
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'Google ID Token alınamadı.';
      }

      // 3. Supabase'e ID Token ile giriş yap
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      
      debugPrint("Google Girişi Başarılı: ${response.user?.id}");
      return response;
    } catch (e) {
      debugPrint("Google Giriş Hatası: $e");
      rethrow;
    }
  }

  /// ----------------------------------------
  /// APPLE GİRİŞİ (NATIVE)
  /// ----------------------------------------
  Future<AuthResponse?> signInWithApple() async {
    try {
      // Sadece iOS/macOS'te mi çalıştığını kontrol edebilmek için kütüphane kendi içinde handle eder
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw 'Apple ID Token alınamadı.';
      }

      // Supabase'e Apple kimliği ile giriş yap
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
      );

      debugPrint("Apple Girişi Başarılı: ${response.user?.id}");
      return response;
    } catch (e) {
      debugPrint("Apple Giriş Hatası: $e");
      rethrow;
    }
  }
}
