import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:math';

class AuthService {
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;
  AuthService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Mevcut oturumdaki kullanıcı
  User? get currentUser => _supabase.auth.currentUser;

  /// Kullanıcı giriş yapmış mı?
  bool get isLoggedIn => currentUser != null;

  /// Misafir durumu kurgusu için (Kullanıcı giriş yapmamışsa misafirdir)
  bool get isGuest => currentUser == null;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // --------------------------------------------------------------------------
  // GOOGLE ENTEGRASYONU
  // --------------------------------------------------------------------------
  
  /// Google ile Giriş Yap (iOS ve Android destekli)
  Future<AuthResponse?> signInWithGoogle() async {
    try {
      // NOTE: Buradaki client ID bilgisini Supabase paneli üzerinden ayarlayacağız.
      // Projeye Google Cloud üzerinden alınan Web Client ID yazılacak.
      const String webClientId = 'SENIN_GOOGLE_WEB_CLIENT_ID'; 
      const String iosClientId = 'SENIN_GOOGLE_IOS_CLIENT_ID';

      final googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
        clientId: defaultTargetPlatform == TargetPlatform.iOS ? iosClientId : null,
        scopes: ['email', 'profile'],
      );

      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw 'Google Sign-In cancelled by user.';
      }

      final googleAuth = await googleUser.authentication;

      // idToken — authentication property'den
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'No ID Token found.';
      }

      final accessToken = googleAuth.accessToken;

      // Supabase'e Google Token'ını kullanarak giriş yap
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      
      return response;
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      rethrow;
    }
  }

  // --------------------------------------------------------------------------
  // APPLE ENTEGRASYONU
  // --------------------------------------------------------------------------

  /// Apple ile Giriş Yap (Sadece iOS cihazlar / MacOS)
  Future<AuthResponse?> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw 'No ID Token found.';
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      return response;
    } catch (e) {
      debugPrint('Apple Sign-In Error: $e');
      rethrow;
    }
  }

  // Apple girişi için güvenlik nonce oluşturucu
  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  // --------------------------------------------------------------------------
  // ÇIKIŞ VE PROFİL
  // --------------------------------------------------------------------------

  /// Güvenli Çıkış Yap
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('Sign Out Error: $e');
    }
  }
}
