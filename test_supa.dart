import 'package:supabase/supabase.dart';
import 'dart:io';

void main() async {
  final supabase = SupabaseClient(
    'https://zzheonrmioxbiinvomsw.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp6aGVvbnJtaW94YmlpbnZvbXN3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyMzI3MTAsImV4cCI6MjA4OTgwODcxMH0.ur8u0vCa9x-nRKdKhS_xL6c56jpmXjU9FXa2CCHnaWU',
  );

  print("═══════════════════════════════════════════");
  print("  🔐 SUPABASE GÜVENLİK TARAMASI");
  print("═══════════════════════════════════════════\n");

  // 1. Anonim olarak profillere erişim testi
  print("📋 TEST 1: Anonim (giriş yapmadan) profil okuma...");
  try {
    final profiles = await supabase.from('profiles').select();
    if (profiles.isEmpty) {
      print("  ✅ Profil yok veya RLS engelledi");
    } else {
      print("  ⚠️ UYARI: Anonim ${profiles.length} profil okudu!");
      for (var p in profiles) {
        print("    → ${p['full_name']} (@${p['username']})");
      }
    }
  } catch (e) {
    print("  ✅ Erişim reddedildi: $e");
  }

  // 2. Anonim olarak friend_requests erişimi
  print("\n📋 TEST 2: Anonim friend_requests okuma...");
  try {
    final reqs = await supabase.from('friend_requests').select();
    if (reqs.isEmpty) {
      print("  ✅ İstek yok veya RLS engelledi");
    } else {
      print("  ⚠️ UYARI: Anonim ${reqs.length} istek okudu!");
    }
  } catch (e) {
    print("  ✅ Erişim reddedildi: $e");
  }

  // 3. Anonim olarak owl_letters erişimi
  print("\n📋 TEST 3: Anonim owl_letters okuma...");
  try {
    final letters = await supabase.from('owl_letters').select();
    if (letters.isEmpty) {
      print("  ✅ Mektup yok veya RLS engelledi");
    } else {
      print("  ⚠️ UYARI: Anonim ${letters.length} mektup okudu!");
    }
  } catch (e) {
    print("  ✅ Erişim reddedildi: $e");
  }

  // 4. Anonim olarak connections erişimi
  print("\n📋 TEST 4: Anonim connections okuma...");
  try {
    final conns = await supabase.from('connections').select();
    if (conns.isEmpty) {
      print("  ✅ Bağlantı yok veya RLS engelledi");
    } else {
      print("  ⚠️ UYARI: Anonim ${conns.length} bağlantı okudu!");
    }
  } catch (e) {
    print("  ✅ Erişim reddedildi: $e");
  }

  // 5. Anonim olarak user_cloud_saves erişimi
  print("\n📋 TEST 5: Anonim user_cloud_saves okuma...");
  try {
    final saves = await supabase.from('user_cloud_saves').select();
    if (saves.isEmpty) {
      print("  ✅ Kayıt yok veya RLS engelledi");
    } else {
      print("  ⚠️ UYARI: Anonim ${saves.length} bulut kaydı okudu!");
    }
  } catch (e) {
    print("  ✅ Erişim reddedildi: $e");
  }

  // 6. Anonim olarak cosmic_referrals erişimi
  print("\n📋 TEST 6: Anonim cosmic_referrals okuma...");
  try {
    final refs = await supabase.from('cosmic_referrals').select();
    if (refs.isEmpty) {
      print("  ✅ Referans yok veya RLS engelledi");
    } else {
      print("  ⚠️ UYARI: Anonim ${refs.length} referans okudu!");
    }
  } catch (e) {
    print("  ✅ Erişim reddedildi: $e");
  }

  // 7. Anonim profil oluşturma testi
  print("\n📋 TEST 7: Anonim profil INSERT denemesi...");
  try {
    await supabase.from('profiles').insert({
      'id': '00000000-0000-0000-0000-000000000001',
      'full_name': 'HACKER_TEST',
      'username': '@hacker',
    });
    print("  🔴 KRİTİK: Anonim profil oluşturabildi!");
    // Temizle
    await supabase.from('profiles').delete().eq('id', '00000000-0000-0000-0000-000000000001');
  } catch (e) {
    print("  ✅ Anonim INSERT engellendi");
  }

  // 8. Anonim friend_request gönderme testi
  print("\n📋 TEST 8: Anonim friend_request INSERT denemesi...");
  try {
    await supabase.from('friend_requests').insert({
      'from_user': '00000000-0000-0000-0000-000000000001',
      'to_user': '00000000-0000-0000-0000-000000000002',
      'status': 'pending',
    });
    print("  🔴 KRİTİK: Anonim istek gönderebildi!");
  } catch (e) {
    print("  ✅ Anonim INSERT engellendi");
  }

  print("\n═══════════════════════════════════════════");
  print("  🔐 TARAMA TAMAMLANDI");
  print("═══════════════════════════════════════════\n");

  exit(0);
}
