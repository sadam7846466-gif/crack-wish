/// Günlük yazma soruları — haftanın her günü için farklı
class JournalPrompts {
  /// Bugünün sorusunu getir
  static String getTodayPrompt() {
    final weekday = DateTime.now().weekday; // 1=Pazartesi, 7=Pazar
    return _prompts[weekday - 1];
  }

  static const List<String> _prompts = [
    'Bu hafta neyi başarmak istiyorsun?',           // Pazartesi
    'Bugün seni güldüren bir şey...',                // Salı
    'Kendine teşekkür etmek istediğin bir şey...',   // Çarşamba
    'Bugün öğrendiğin yeni bir şey...',              // Perşembe
    'Bu hafta seni mutlu eden bir an...',             // Cuma
    'Bugün kendin için yaptığın güzel bir şey...',   // Cumartesi
    'Gelecek hafta için bir dilek...',               // Pazar
  ];
}
