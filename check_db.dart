import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  final supabaseUrl = Platform.environment['SUPABASE_URL'] ?? 'https://zzheonrmioxbiinvomsw.supabase.co';
  final supabaseKey = Platform.environment['SUPABASE_SERVICE_ROLE_KEY'] ?? 'YOUR_KEY_HERE'; // Need to extract key from lib/main.dart or .env
}
