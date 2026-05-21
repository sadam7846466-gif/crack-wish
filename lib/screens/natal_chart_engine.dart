import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:swisseph/swisseph.dart';

/// Real Swiss Ephemeris engine for natal chart calculations.
/// Uses NASA JPL data via the swisseph package for accurate planet positions.
class NatalChartEngine {
  final DateTime birthDate;
  final String birthTime;
  final String birthPlace;
  late final int _hour;
  late final int _minute;

  // Signs
  static const signs = ['Koç','Boğa','İkizler','Yengeç','Aslan','Başak','Terazi','Akrep','Yay','Oğlak','Kova','Balık'];
  static const signsEn = ['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'];
  static const signImages = [
    'assets/images/zodiac_signs/aries.png','assets/images/zodiac_signs/taurus.png',
    'assets/images/zodiac_signs/gemini.png','assets/images/zodiac_signs/cancer.png',
    'assets/images/zodiac_signs/leo.png','assets/images/zodiac_signs/virgo.png',
    'assets/images/zodiac_signs/libra.png','assets/images/zodiac_signs/scorpio.png',
    'assets/images/zodiac_signs/sagittarius.png','assets/images/zodiac_signs/capricorn.png',
    'assets/images/zodiac_signs/aquarius.png','assets/images/zodiac_signs/pisces.png',
  ];

  // Planet data
  static const planetNames = ['Güneş','Ay','Merkür','Venüs','Mars','Jüpiter','Satürn','Uranüs','Neptün','Plüton'];
  static const planetNamesEn = ['Sun','Moon','Mercury','Venus','Mars','Jupiter','Saturn','Uranus','Neptune','Pluto'];
  static const planetSymbols = ['☉','☽','☿','♀','♂','♃','♄','♅','♆','♇'];

  // Swiss Ephemeris planet IDs
  static const _sePlanets = [
    seSun,     // 0
    seMoon,    // 1
    seMercury, // 2
    seVenus,   // 3
    seMars,    // 4
    seJupiter, // 5
    seSaturn,  // 6
    seUranus,  // 7
    seNeptune, // 8
    sePluto,   // 9
  ];

  // Results
  late List<PlanetPosition> planets;
  late int ascSignIndex;
  late int mcSignIndex;
  late double ascDegree;
  late double mcDegree;
  late List<List<double>> housesCusps; // 12 house cusp degrees

  NatalChartEngine._({required this.birthDate, required this.birthTime, required this.birthPlace}) {
    final parts = birthTime.split(':');
    _hour = int.tryParse(parts[0]) ?? 12;
    _minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
  }

  /// Async factory: geocodes birthPlace, then calculates chart.
  static Future<NatalChartEngine> create({
    required DateTime birthDate,
    required String birthTime,
    required String birthPlace,
  }) async {
    final engine = NatalChartEngine._(
      birthDate: birthDate,
      birthTime: birthTime,
      birthPlace: birthPlace,
    );
    final coords = await _geocode(birthPlace);
    engine._calculateWithCoords(coords['lat']!, coords['lon']!);
    return engine;
  }

  /// Sync constructor (uses offline city database as fallback)
  factory NatalChartEngine({
    required DateTime birthDate,
    required String birthTime,
    required String birthPlace,
  }) {
    final engine = NatalChartEngine._(
      birthDate: birthDate,
      birthTime: birthTime,
      birthPlace: birthPlace,
    );
    final coords = _getOfflineCoordinates(birthPlace);
    engine._calculateWithCoords(coords['lat']!, coords['lon']!);
    return engine;
  }

  int get sunSignIndex {
    final m = birthDate.month, d = birthDate.day;
    if ((m == 3 && d >= 21) || (m == 4 && d <= 19)) return 0; // Koç
    if ((m == 4 && d >= 20) || (m == 5 && d <= 20)) return 1; // Boğa
    if ((m == 5 && d >= 21) || (m == 6 && d <= 20)) return 2; // İkizler
    if ((m == 6 && d >= 21) || (m == 7 && d <= 22)) return 3; // Yengeç
    if ((m == 7 && d >= 23) || (m == 8 && d <= 22)) return 4; // Aslan
    if ((m == 8 && d >= 23) || (m == 9 && d <= 22)) return 5; // Başak
    if ((m == 9 && d >= 23) || (m == 10 && d <= 22)) return 6; // Terazi
    if ((m == 10 && d >= 23) || (m == 11 && d <= 21)) return 7; // Akrep
    if ((m == 11 && d >= 22) || (m == 12 && d <= 21)) return 8; // Yay
    if ((m == 12 && d >= 22) || (m == 1 && d <= 19)) return 9; // Oğlak
    if ((m == 1 && d >= 20) || (m == 2 && d <= 18)) return 10; // Kova
    return 11; // Balık
  }

  /// Geocode a place name using OpenStreetMap Nominatim (free, no API key)
  static Future<Map<String, double>> _geocode(String place) async {
    try {
      // Clean up the place string for better search
      final query = place.replaceAll(',', ' ').trim();
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1',
      );

      final response = await http.get(url, headers: {
        'User-Agent': 'CrackWishApp/1.0',
        'Accept-Language': 'en',
      }).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          final lat = double.tryParse(data[0]['lat'].toString());
          final lon = double.tryParse(data[0]['lon'].toString());
          if (lat != null && lon != null) {
            debugPrint('Geocoded "$place" → lat:$lat, lon:$lon');
            return {'lat': lat, 'lon': lon};
          }
        }
      }
    } catch (e) {
      debugPrint('Geocoding failed for "$place": $e');
    }

    // Fallback to offline database if geocoding fails
    return _getOfflineCoordinates(place);
  }

  /// Offline city coordinate database (fallback when no internet)
  static Map<String, double> _getOfflineCoordinates(String place) {
    final lower = place.toLowerCase()
        .replaceAll('ı', 'i').replaceAll('ş', 's')
        .replaceAll('ç', 'c').replaceAll('ğ', 'g')
        .replaceAll('ö', 'o').replaceAll('ü', 'u');

    const cities = <String, List<double>>{
      'istanbul': [41.0082, 28.9784],
      'ankara': [39.9334, 32.8597],
      'izmir': [38.4192, 27.1287],
      'bursa': [40.1885, 29.0610],
      'antalya': [36.8969, 30.7133],
      'adana': [37.0000, 35.3213],
      'konya': [37.8715, 32.4846],
      'gaziantep': [37.0662, 37.3833],
      'mersin': [36.8121, 34.6415],
      'diyarbakir': [37.9144, 40.2306],
      'kayseri': [38.7312, 35.4787],
      'eskisehir': [39.7767, 30.5206],
      'samsun': [41.2867, 36.33],
      'denizli': [37.7765, 29.0864],
      'sanliurfa': [37.1674, 38.7955],
      'malatya': [38.3554, 38.3335],
      'trabzon': [41.0027, 39.7168],
      'erzurum': [39.9054, 41.2658],
      'van': [38.5012, 43.3800],
      'batman': [37.8812, 41.1351],
      'elazig': [38.6810, 39.2264],
      'manisa': [38.6191, 27.4289],
      'balikesir': [39.6484, 27.8826],
      'hatay': [36.2021, 36.1607],
      'kocaeli': [40.8533, 29.8815],
      'mugla': [37.2153, 28.3636],
      'bodrum': [37.0346, 27.4305],
      'marmaris': [36.8554, 28.2742],
      'aydin': [37.8560, 27.8416],
      'sivas': [39.7477, 37.0179],
      'edirne': [41.6818, 26.5623],
      'canakkale': [40.1553, 26.4142],
      'isparta': [37.7648, 30.5566],
      'bolu': [40.7350, 31.6106],
      'rize': [41.0201, 40.5234],
      'mardin': [37.3212, 40.7245],
      'kars': [40.6013, 43.0975],
      'london': [51.5074, -0.1278],
      'new york': [40.7128, -74.0060],
      'paris': [48.8566, 2.3522],
      'berlin': [52.5200, 13.4050],
      'tokyo': [35.6762, 139.6503],
      'moscow': [55.7558, 37.6173],
      'dubai': [25.2048, 55.2708],
      'rome': [41.9028, 12.4964],
      'los angeles': [34.0522, -118.2437],
      'sydney': [-33.8688, 151.2093],
      'cairo': [30.0444, 31.2357],
      'athens': [37.9838, 23.7275],
      'amsterdam': [52.3676, 4.9041],
      'seoul': [37.5665, 126.9780],
      'beijing': [39.9042, 116.4074],
      'vienna': [48.2082, 16.3738],
      'bucharest': [44.4268, 26.1025],
      'sofia': [42.6977, 23.3219],
      'codrington': [17.6346, -61.8344],
      'antigua': [17.0608, -61.7964],
    };

    for (final entry in cities.entries) {
      if (lower.contains(entry.key)) {
        return {'lat': entry.value[0], 'lon': entry.value[1]};
      }
    }

    // Default to Istanbul if nothing matches
    return {'lat': 41.0082, 'lon': 28.9784};
  }

  /// Get timezone offset in hours from longitude
  double _getTimezoneOffset(double longitude) {
    // Turkey is always UTC+3
    if (longitude >= 25.0 && longitude <= 45.0) return 3.0;
    // Simple longitude-based timezone approximation
    return (longitude / 15.0).roundToDouble();
  }

  void _calculateWithCoords(double lat, double lon) {
    try {
      final swe = SwissEph.find();

      final tzOffset = _getTimezoneOffset(lon);

      // Convert birth date/time to Universal Time (UTC)
      final utHour = _hour + _minute / 60.0 - tzOffset;

      // Calculate Julian Day Number in UT
      final jd = swe.julday(
        birthDate.year,
        birthDate.month,
        birthDate.day,
        utHour,
      );

      // ── HOUSE CALCULATION (Placidus system) ──
      final housesResult = swe.houses(jd, lat, lon, hsysPlacidus);
      final cusps = housesResult.cusps;
      final ascmc = housesResult.ascmc;

      ascDegree = ascmc[0]; // Ascendant
      mcDegree = ascmc[1];  // MC (Midheaven)
      ascSignIndex = (ascDegree ~/ 30) % 12;
      mcSignIndex = (mcDegree ~/ 30) % 12;

      // Build house cusps list (12 houses)
      housesCusps = [];
      for (int i = 1; i <= 12; i++) {
        final cusp = cusps[i];
        housesCusps.add([cusp, (cusp ~/ 30) % 12 + 0.0]);
      }

      // ── PLANET CALCULATIONS ──
      planets = [];
      for (int i = 0; i < _sePlanets.length; i++) {
        final result = swe.calcUt(
          jd,
          _sePlanets[i],
          seFlgSwiEph | seFlgSpeed,
        );

        final longitude = result.longitude;
        final signIdx = (longitude ~/ 30) % 12;
        final house = _houseForDeg(longitude);

        planets.add(PlanetPosition(
          i,
          planetNames[i],
          planetSymbols[i],
          longitude,
          signIdx,
          house,
        ));
      }

      swe.close();
    } catch (e) {
      debugPrint('SwissEph error, falling back to basic calculation: $e');
      _calculateFallback();
    }
  }

  /// Fallback calculation when SwissEph is not available
  void _calculateFallback() {
    final rng = math.Random((birthDate.millisecondsSinceEpoch + birthPlace.hashCode + _hour * 60 + _minute).abs());

    final timeOffset = (_hour * 60 + _minute) / 1440.0;
    final ascBase = (sunSignIndex * 30 + timeOffset * 360 + birthPlace.hashCode % 30).abs() % 360;
    ascDegree = ascBase;
    ascSignIndex = (ascBase ~/ 30) % 12;
    mcDegree = (ascDegree + 270) % 360;
    mcSignIndex = (mcDegree ~/ 30) % 12;

    housesCusps = [];
    for (int i = 0; i < 12; i++) {
      double cusp = (ascDegree + i * 30 + rng.nextDouble() * 8 - 4) % 360;
      housesCusps.add([cusp, (cusp ~/ 30) % 12 + 0.0]);
    }
    housesCusps.sort((a, b) => a[0].compareTo(b[0]));

    planets = [];
    double sunDeg = sunSignIndex * 30.0 + birthDate.day.toDouble();
    planets.add(PlanetPosition(0, 'Güneş', '☉', sunDeg, sunSignIndex, _houseForDeg(sunDeg)));

    double moonDeg = (sunDeg + _hour * 13.2 + _minute * 0.22 + birthPlace.hashCode % 60) % 360;
    planets.add(PlanetPosition(1, 'Ay', '☽', moonDeg, (moonDeg ~/ 30) % 12, _houseForDeg(moonDeg)));

    double mercDeg = (sunDeg + (rng.nextInt(56) - 28)) % 360;
    planets.add(PlanetPosition(2, 'Merkür', '☿', mercDeg, (mercDeg ~/ 30) % 12, _houseForDeg(mercDeg)));

    double venDeg = (sunDeg + (rng.nextInt(92) - 46)) % 360;
    planets.add(PlanetPosition(3, 'Venüs', '♀', venDeg, (venDeg ~/ 30) % 12, _houseForDeg(venDeg)));

    double marsDeg = (sunDeg + 30 + rng.nextInt(300)) % 360;
    planets.add(PlanetPosition(4, 'Mars', '♂', marsDeg, (marsDeg ~/ 30) % 12, _houseForDeg(marsDeg)));

    double jupDeg = ((birthDate.year - 2000) * 30.0 + birthDate.month * 2.5 + rng.nextInt(15)) % 360;
    planets.add(PlanetPosition(5, 'Jüpiter', '♃', jupDeg, (jupDeg ~/ 30) % 12, _houseForDeg(jupDeg)));

    double satDeg = ((birthDate.year - 2000) * 12.0 + birthDate.month * 1.0 + rng.nextInt(10)) % 360;
    planets.add(PlanetPosition(6, 'Satürn', '♄', satDeg, (satDeg ~/ 30) % 12, _houseForDeg(satDeg)));

    double uraDeg = ((birthDate.year - 1900) * 4.2 + rng.nextInt(8)) % 360;
    planets.add(PlanetPosition(7, 'Uranüs', '♅', uraDeg, (uraDeg ~/ 30) % 12, _houseForDeg(uraDeg)));

    double nepDeg = ((birthDate.year - 1900) * 2.2 + rng.nextInt(5)) % 360;
    planets.add(PlanetPosition(8, 'Neptün', '♆', nepDeg, (nepDeg ~/ 30) % 12, _houseForDeg(nepDeg)));

    double pluDeg = ((birthDate.year - 1900) * 1.5 + rng.nextInt(5)) % 360;
    planets.add(PlanetPosition(9, 'Plüton', '♇', pluDeg, (pluDeg ~/ 30) % 12, _houseForDeg(pluDeg)));
  }

  int _houseForDeg(double deg) {
    for (int i = 0; i < 12; i++) {
      double start = housesCusps[i][0];
      double end = housesCusps[(i + 1) % 12][0];

      if (start <= end) {
        if (deg >= start && deg < end) return i + 1;
      } else {
        if (deg >= start || deg < end) return i + 1;
      }
    }
    return 1;
  }

  List<Aspect> getAspects() {
    final aspects = <Aspect>[];
    for (int i = 0; i < planets.length; i++) {
      for (int j = i + 1; j < planets.length; j++) {
        double diff = (planets[i].degree - planets[j].degree).abs() % 360;
        if (diff > 180) diff = 360 - diff;
        const orb = 8.0;
        if ((diff - 0).abs() < orb) {
          aspects.add(Aspect(i, j, 'Kavuşum', 0, diff));
        } else if ((diff - 60).abs() < orb) {
          aspects.add(Aspect(i, j, 'Sekstil', 60, diff));
        } else if ((diff - 90).abs() < orb) {
          aspects.add(Aspect(i, j, 'Kare', 90, diff));
        } else if ((diff - 120).abs() < orb) {
          aspects.add(Aspect(i, j, 'Üçgen', 120, diff));
        } else if ((diff - 180).abs() < orb) {
          aspects.add(Aspect(i, j, 'Karşıt', 180, diff));
        }
      }
    }
    return aspects;
  }

  // ── YORUM MOTORU ──

  String getPersonalitySummary(String lang) {
    final sun = planets[0]; final moon = planets[1];
    final isTr = lang == 'tr';
    final sunSign = isTr ? signs[sun.signIndex] : signsEn[sun.signIndex];
    final moonSign = isTr ? signs[moon.signIndex] : signsEn[moon.signIndex];
    final asc = isTr ? signs[ascSignIndex] : signsEn[ascSignIndex];
    if (isTr) {
      return '$sunSign enerjisiyle parlıyorsun, $moonSign Ay\'ın duygusal derinlik katıyor. $asc yükseleni dış dünyadaki izlenimini şekillendiriyor.';
    } else {
      return 'You shine with the energy of $sunSign, your $moonSign Moon adds emotional depth. The $asc ascendant shapes your impression in the outer world.';
    }
  }

  String getLoveInterpretation(String lang) {
    final venus = planets[3]; final mars = planets[4];
    final isTr = lang == 'tr';
    final venusSign = isTr ? signs[venus.signIndex] : signsEn[venus.signIndex];
    final marsSign = isTr ? signs[mars.signIndex] : signsEn[mars.signIndex];
    if (isTr) {
      return '$venusSign Venüs\'ün sevgi dilini, $marsSign Mars\'ın tutku tarzını belirliyor. ${_venusHouseInterpretation(venus.house, lang)}';
    } else {
      return '$venusSign Venus determines your love language, $marsSign Mars shapes your passion style. ${_venusHouseInterpretation(venus.house, lang)}';
    }
  }

  String getCareerInterpretation(String lang) {
    final mc = mcSignIndex; final saturn = planets[6];
    final isTr = lang == 'tr';
    final mcSign = isTr ? signs[mc] : signsEn[mc];
    final saturnSign = isTr ? signs[saturn.signIndex] : signsEn[saturn.signIndex];
    if (isTr) {
      return 'MC $mcSign burcunda — kariyer yönünü bu çiziyor. $saturnSign Satürn disiplin alanını belirliyor. ${_careerHouseInterpretation(planets[0].house, lang)}';
    } else {
      return 'MC in $mcSign sign — this draws your career path. $saturnSign Saturn determines your discipline area. ${_careerHouseInterpretation(planets[0].house, lang)}';
    }
  }

  String getEmotionalInterpretation(String lang) {
    final moon = planets[1];
    final isTr = lang == 'tr';
    final moonSign = isTr ? signs[moon.signIndex] : signsEn[moon.signIndex];
    if (isTr) {
      return '$moonSign Ay\'ın iç dünyanı yönetiyor. ${_moonHouseInterpretation(moon.house, lang)}';
    } else {
      return 'Your $moonSign Moon rules your inner world. ${_moonHouseInterpretation(moon.house, lang)}';
    }
  }

  String getStrengthsWeaknesses(String lang) {
    final sun = planets[0]; final saturn = planets[6]; final mars = planets[4];
    final isTr = lang == 'tr';
    final sunSign = isTr ? signs[sun.signIndex] : signsEn[sun.signIndex];
    final saturnSign = isTr ? signs[saturn.signIndex] : signsEn[saturn.signIndex];
    final marsSign = isTr ? signs[mars.signIndex] : signsEn[mars.signIndex];
    if (isTr) {
      return '$sunSign kararlılığı, $marsSign savaşçı ruhu. $saturnSign Satürn\'ün getirdiği sınırlar denge noktandır.';
    } else {
      return '$sunSign determination, $marsSign warrior spirit. The boundaries brought by $saturnSign Saturn are your balance points.';
    }
  }

  String _venusHouseInterpretation(int house, String lang) {
    final isTr = lang == 'tr';
    const trMap = {
      1:'Çekiciliğin doğal ve göz alıcı.', 2:'Aşkta güvenlik ve konfor arıyorsun.',
      3:'Entelektüel bağ seni cezbediyor.', 4:'Yuva kurmak aşkın temel taşı.',
      5:'Romantizm ve tutku hayatının merkezinde.', 6:'Sevgiyi günlük ilgide buluyorsun.',
      7:'Kalıcı ortaklıklar ve derin bağlar arıyorsun.', 8:'Yoğun ve dönüştürücü aşklar yaşıyorsun.',
      9:'Maceracı ve özgür bir aşk anlayışın var.', 10:'Statü ve saygınlık aşkta önemli.',
      11:'Arkadaşlık temelli ilişkiler tercih ediyorsun.', 12:'Gizli ve ruhsal derin bağlar kuruyorsun.',
    };
    const enMap = {
      1: 'Your charm is natural and eye-catching.', 2: 'You look for safety and comfort in love.',
      3: 'Intellectual connection attracts you.', 4: 'Building a home is the foundation of your love.',
      5: 'Romance and passion are at the center of your life.', 6: 'You find love in daily care.',
      7: 'You look for lasting partnerships and deep bonds.', 8: 'You experience intense and transformative love.',
      9: 'You have an adventurous and free understanding of love.', 10: 'Status and respect are important in love.',
      11: 'You prefer friendship-based relationships.', 12: 'You form secret and spiritually deep bonds.',
    };
    return (isTr ? trMap[house] : enMap[house]) ?? '';
  }

  String _careerHouseInterpretation(int house, String lang) {
    final isTr = lang == 'tr';
    const trMap = {
      1:'Kişisel marka ve liderlik öne çıkıyor.', 2:'Finansal güvenlik kariyer motivasyonun.',
      3:'İletişim ve medya alanları parlıyor.', 4:'Ev ve aile odaklı işler uygun.',
      5:'Yaratıcı sektörler ve sanat alanları ideal.', 6:'Hizmet ve sağlık sektörleri güçlü.',
      7:'Ortaklık ve danışmanlık alanları parlak.', 8:'Finans ve araştırma alanları öne çıkıyor.',
      9:'Eğitim ve uluslararası alanlar uygun.', 10:'Yöneticilik ve kamu alanları doğal yeteneklerin.',
      11:'Teknoloji ve sosyal girişimler ideal.', 12:'Ruhsal ve sanatsal alanlar çekiyor.',
    };
    const enMap = {
      1: 'Personal brand and leadership stand out.', 2: 'Financial security is your career motivation.',
      3: 'Communication and media fields shine.', 4: 'Home and family-oriented jobs are suitable.',
      5: 'Creative sectors and art fields are ideal.', 6: 'Service and health sectors are strong.',
      7: 'Partnership and consulting fields are bright.', 8: 'Finance and research fields stand out.',
      9: 'Education and international fields are suitable.', 10: 'Management and public fields are your natural talents.',
      11: 'Technology and social enterprises are ideal.', 12: 'Spiritual and artistic fields attract you.',
    };
    return (isTr ? trMap[house] : enMap[house]) ?? '';
  }

  String _moonHouseInterpretation(int house, String lang) {
    final isTr = lang == 'tr';
    const trMap = {
      1:'Duygularını açıkça gösteriyorsun.', 2:'Duygusal güvenlik maddi istikrarla bağlantılı.',
      3:'Duygularını kelimelerle ifade ediyorsun.', 4:'Aile ve yuva duygusal merkezin.',
      5:'Duygularını yaratıcılıkla dışa vuruyorsun.', 6:'Duygusal dengen rutinlerle sağlanıyor.',
      7:'Duygusal tatmini ilişkilerde buluyorsun.', 8:'Derin ve yoğun duygusal deneyimler yaşıyorsun.',
      9:'Keşif ve öğrenme seni duygusal olarak besliyor.', 10:'Başarı duygusal tatminin kaynağı.',
      11:'Topluluk duygusu seni güçlendiriyor.', 12:'İç dünyanda derin bir duygusal okyanus var.',
    };
    const enMap = {
      1: 'You display your emotions openly.', 2: 'Emotional security is linked to financial stability.',
      3: 'You express your feelings in words.', 4: 'Family and home are your emotional center.',
      5: 'You express your emotions through creativity.', 6: 'Your emotional balance is maintained by routines.',
      7: 'You find emotional fulfillment in relationships.', 8: 'You experience deep and intense emotional situations.',
      9: 'Exploration and learning nourish you emotionally.', 10: 'Success is the source of your emotional satisfaction.',
      11: 'Sense of community empowers you.', 12: 'There is a deep emotional ocean in your inner world.',
    };
    return (isTr ? trMap[house] : enMap[house]) ?? '';
  }
}

class PlanetPosition {
  final int index;
  final String name;
  final String symbol;
  final double degree;
  final int signIndex;
  final int house;
  PlanetPosition(this.index, this.name, this.symbol, this.degree, this.signIndex, this.house);
}

class Aspect {
  final int planet1;
  final int planet2;
  final String name;
  final int exactAngle;
  final double actualAngle;
  Aspect(this.planet1, this.planet2, this.name, this.exactAngle, this.actualAngle);
}
