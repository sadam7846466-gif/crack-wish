import 'package:country_state_city/country_state_city.dart' as csc;

void main() async {
  final countries = await csc.getAllCountries();
  final china = countries.firstWhere((c) => c.name.toLowerCase().contains('china'), orElse: () => csc.Country(name: 'NotFound', isoCode: '', phoneCode: '', flag: '', currency: '', latitude: '', longitude: ''));
  print('Country: ${china.name} (${china.isoCode})');
  
  if (china.isoCode.isNotEmpty) {
    final states = await csc.getStatesOfCountry(china.isoCode);
    final xinjiang = states.where((s) => s.name.toLowerCase().contains('xinjiang') || s.name.toLowerCase().contains('sinciang')).toList();
    print('Found states matching xinjiang: ${xinjiang.map((e) => e.name).toList()}');
    
    for (var s in states) {
      if (s.name.toLowerCase().contains('xinjiang')) {
         final cities = await csc.getStateCities(china.isoCode, s.isoCode);
         final kashgar = cities.where((c) => c.name.toLowerCase().contains('kashgar') || c.name.toLowerCase().contains('kashi')).toList();
         print('Cities in Xinjiang matching kashgar/kashi: ${kashgar.map((e) => e.name).toList()}');
         
         final mekit = cities.where((c) => c.name.toLowerCase().contains('mekit') || c.name.toLowerCase().contains('maigaiti')).toList();
         print('Cities matching mekit/maigaiti: ${mekit.map((e) => e.name).toList()}');
      }
    }
  }
}
