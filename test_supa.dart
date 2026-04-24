import 'package:supabase/supabase.dart';
import 'dart:io';

void main() async {
  final client = SupabaseClient(
    'https://zzheonrmioxbiinvomsw.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp6aGVvbnJtaW94YmlpbnZvbXN3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyMzI3MTAsImV4cCI6MjA4OTgwODcxMH0.ur8u0vCa9x-nRKdKhS_xL6c56jpmXjU9FXa2CCHnaWU'
  );

  final res = await client.from('profiles').select('handle, full_name');
  print('Profiles: $res');

  final friends = await client.from('friend_requests').select();
  print('Friend requests: $friends');
  
  exit(0);
}
