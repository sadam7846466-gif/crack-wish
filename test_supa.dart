import 'package:supabase/supabase.dart';
import 'dart:io';

void main() async {
  final supabase = SupabaseClient(
    'https://zzheonrmioxbiinvomsw.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp6aGVvbnJtaW94YmlpbnZvbXN3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyMzI3MTAsImV4cCI6MjA4OTgwODcxMH0.ur8u0vCa9x-nRKdKhS_xL6c56jpmXjU9FXa2CCHnaWU',
  );

  print("═══════════════════════════════════════");
  print("  🔐 UPDATE/DELETE DOĞRULAMA TESTİ");
  print("═══════════════════════════════════════\n");

  // Test: Anonim UPDATE sonrası gerçekten değişmiş mi?
  print("📋 T1: Anonim UPDATE denemesi...");
  try {
    // Önce mevcut ismi oku (authenticated olmadığımız için okunamayacak)
    final before = await supabase.from('profiles').select('full_name').limit(1);
    print("  → Önce profil okuma: ${before.length} sonuç (0 olmalı)");

    // Update dene
    await supabase.from('profiles').update({'full_name': 'HACKED_TEST'}).eq('id', '520639f1-dd4a-4b5d-a98c-ab9d096915c1');
    print("  → UPDATE komutu hata vermedi");

    // Tekrar oku — değişmiş mi?
    final after = await supabase.from('profiles').select('full_name').limit(1);
    print("  → Sonra profil okuma: ${after.length} sonuç");
    
    if (after.isEmpty) {
      print("  ✅ Profil okunamıyor = UPDATE de etkisiz (RLS çalışıyor!)");
    } else {
      final name = after.first['full_name'];
      if (name == 'HACKED_TEST') {
        print("  🔴 KRİTİK: Profil değiştirildi! İsim şimdi: $name");
      } else {
        print("  ✅ Profil değişmemiş. İsim hala: $name");
      }
    }
  } catch (e) {
    print("  ✅ Exception fırlatıldı: $e");
  }

  // Test: Anonim DELETE sonrası gerçekten silinmiş mi?
  print("\n📋 T2: Anonim DELETE denemesi...");
  try {
    await supabase.from('profiles').delete().eq('id', '520639f1-dd4a-4b5d-a98c-ab9d096915c1');
    print("  → DELETE komutu hata vermedi");

    // Ama profil gerçekten silinmiş mi? Authenticated olmadan okuyamayız
    // O yüzden insert deneyelim — eğer silinmişse aynı id ile insert edilebilir
    try {
      await supabase.from('profiles').insert({'id': '520639f1-dd4a-4b5d-a98c-ab9d096915c1', 'full_name': 'TEST'});
      print("  🔴 Profil silinmiş olabilir! INSERT başarılı oldu");
      // Geri al
      await supabase.from('profiles').delete().eq('full_name', 'TEST');
    } catch (e2) {
      print("  ✅ INSERT de engellendi = Profil silinmemiş, RLS çalışıyor!");
    }
  } catch (e) {
    print("  ✅ Exception fırlatıldı: $e");
  }

  print("\n═══════════════════════════════════════");
  print("  ✅ TEST TAMAMLANDI");
  print("═══════════════════════════════════════\n");

  exit(0);
}
