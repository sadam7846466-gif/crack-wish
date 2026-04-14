import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final query = 'Mekit, China';
  final uri = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=jsonv2&addressdetails=1');
  final res = await http.get(uri, headers: {'User-Agent': 'CrackWish/1.0', 'Accept-Language': 'tr,en'});
  if (res.statusCode == 200) {
    final data = json.decode(res.body) as List;
    for (var item in data) {
       print(item['display_name']);
       print(item['name']);
    }
  }
}
