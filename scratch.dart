import 'package:country_state_city/country_state_city.dart' as csc;
void main() async {
  var cities = await csc.getCountryCities("CN");
  print(cities.length);
}
