import 'dart:io';

void main() {
  final files = [
    '/Users/sdmgmz/crack-wish/lib/screens/tarot_meanings.dart',
    '/Users/sdmgmz/crack-wish/lib/screens/tarot_page.dart',
    '/Users/sdmgmz/crack-wish/lib/services/user_stats_service.dart',
  ];

  for (final path in files) {
    final file = File(path);
    if (!file.existsSync()) continue;
    
    var content = file.readAsStringSync();
    
    // Replacements
    content = content.replaceAll('Tılsımlerin', 'Tılsımların');
    content = content.replaceAll('Tılsımler', 'Tılsımlar');
    content = content.replaceAll('Tılsımyi', 'Tılsımı');
    content = content.replaceAll('Tılsımye', 'Tılsıma');
    content = content.replaceAll('tılsımye', 'tılsıma'); // lower case fallback
    content = content.replaceAll('tılsımsi', 'tılsımı');
    
    file.writeAsStringSync(content);
    print('Fixed $path');
  }
}
