import 'dart:math' as math;

/// Deterministic pseudo-ephemeris engine for natal chart calculations.
/// Uses birth date, time & place hash to generate consistent planet positions.
class NatalChartEngine {
  final DateTime birthDate;
  final String birthTime;
  final String birthPlace;
  late final math.Random _rng;
  late final int _hour;
  late final int _minute;

  // Signs
  static const signs = ['Koç','Boğa','İkizler','Yengeç','Aslan','Başak','Terazi','Akrep','Yay','Oğlak','Kova','Balık'];
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
  static const planetSymbols = ['☉','☽','☿','♀','♂','♃','♄','♅','♆','♇'];

  // Results
  late List<PlanetPosition> planets;
  late int ascSignIndex;
  late int mcSignIndex;
  late double ascDegree;
  late double mcDegree;
  late List<List<double>> housesCusps; // 12 house cusp degrees

  NatalChartEngine({required this.birthDate, required this.birthTime, required this.birthPlace}) {
    final parts = birthTime.split(':');
    _hour = int.tryParse(parts[0]) ?? 12;
    _minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    _rng = math.Random((birthDate.millisecondsSinceEpoch + birthPlace.hashCode + _hour * 60 + _minute).abs());
    _calculate();
  }

  int get sunSignIndex {
    final m = birthDate.month, d = birthDate.day;
    const cutoffs = [20,19,20,20,21,21,23,23,23,23,22,22];
    return d < cutoffs[m-1] ? (m-1) : (m % 12);
  }

  void _calculate() {
    // ASC based on birth hour + sun sign
    final timeOffset = (_hour * 60 + _minute) / 1440.0; // fraction of day
    final ascBase = (sunSignIndex * 30 + timeOffset * 360 + birthPlace.hashCode % 30).abs() % 360;
    ascDegree = ascBase;
    ascSignIndex = (ascBase ~/ 30) % 12;
    mcDegree = (ascDegree + 270) % 360; // MC is ~270° from ASC
    mcSignIndex = (mcDegree ~/ 30) % 12;

    // House cusps (Placidus-like approximation)
    housesCusps = [];
    for (int i = 0; i < 12; i++) {
      double cusp = (ascDegree + i * 30 + _rng.nextDouble() * 8 - 4) % 360;
      housesCusps.add([cusp, (cusp ~/ 30) % 12 + 0.0]);
    }
    // Sort cusps by degree to ensure correct circular boundary checking
    housesCusps.sort((a, b) => a[0].compareTo(b[0]));

    // Planet positions deterministic by birth data
    planets = [];
    // Sun is always in sun sign
    double sunDeg = sunSignIndex * 30.0 + birthDate.day.toDouble();
    planets.add(PlanetPosition(0, 'Güneş', '☉', sunDeg, sunSignIndex, _houseForDeg(sunDeg)));

    // Moon moves fast - use hour as major factor
    double moonDeg = (sunDeg + _hour * 13.2 + _minute * 0.22 + birthPlace.hashCode % 60) % 360;
    planets.add(PlanetPosition(1, 'Ay', '☽', moonDeg, (moonDeg ~/ 30) % 12, _houseForDeg(moonDeg)));

    // Mercury close to Sun (±28°)
    double mercDeg = (sunDeg + (_rng.nextInt(56) - 28)) % 360;
    planets.add(PlanetPosition(2, 'Merkür', '☿', mercDeg, (mercDeg ~/ 30) % 12, _houseForDeg(mercDeg)));

    // Venus close to Sun (±46°)
    double venDeg = (sunDeg + (_rng.nextInt(92) - 46)) % 360;
    planets.add(PlanetPosition(3, 'Venüs', '♀', venDeg, (venDeg ~/ 30) % 12, _houseForDeg(venDeg)));

    // Mars 
    double marsDeg = (sunDeg + 30 + _rng.nextInt(300)) % 360;
    planets.add(PlanetPosition(4, 'Mars', '♂', marsDeg, (marsDeg ~/ 30) % 12, _houseForDeg(marsDeg)));

    // Jupiter (slow, ~30° per year)
    double jupDeg = ((birthDate.year - 2000) * 30.0 + birthDate.month * 2.5 + _rng.nextInt(15)) % 360;
    planets.add(PlanetPosition(5, 'Jüpiter', '♃', jupDeg, (jupDeg ~/ 30) % 12, _houseForDeg(jupDeg)));

    // Saturn (~12° per year)
    double satDeg = ((birthDate.year - 2000) * 12.0 + birthDate.month * 1.0 + _rng.nextInt(10)) % 360;
    planets.add(PlanetPosition(6, 'Satürn', '♄', satDeg, (satDeg ~/ 30) % 12, _houseForDeg(satDeg)));

    // Uranus (~4° per year)
    double uraDeg = ((birthDate.year - 1900) * 4.2 + _rng.nextInt(8)) % 360;
    planets.add(PlanetPosition(7, 'Uranüs', '♅', uraDeg, (uraDeg ~/ 30) % 12, _houseForDeg(uraDeg)));

    // Neptune (~2° per year)
    double nepDeg = ((birthDate.year - 1900) * 2.2 + _rng.nextInt(5)) % 360;
    planets.add(PlanetPosition(8, 'Neptün', '♆', nepDeg, (nepDeg ~/ 30) % 12, _houseForDeg(nepDeg)));

    // Pluto (~1.5° per year)
    double pluDeg = ((birthDate.year - 1900) * 1.5 + _rng.nextInt(5)) % 360;
    planets.add(PlanetPosition(9, 'Plüton', '♇', pluDeg, (pluDeg ~/ 30) % 12, _houseForDeg(pluDeg)));
  }

  int _houseForDeg(double deg) {
    for (int i = 0; i < 12; i++) {
      double start = housesCusps[i][0];
      double end = housesCusps[(i + 1) % 12][0];
      
      if (start <= end) {
        if (deg >= start && deg < end) return i + 1;
      } else {
        // Crosses 0° (e.g. start=350, end=20)
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
        final orb = 8.0;
        if ((diff - 0).abs() < orb) aspects.add(Aspect(i, j, 'Kavuşum', 0, diff));
        else if ((diff - 60).abs() < orb) aspects.add(Aspect(i, j, 'Sekstil', 60, diff));
        else if ((diff - 90).abs() < orb) aspects.add(Aspect(i, j, 'Kare', 90, diff));
        else if ((diff - 120).abs() < orb) aspects.add(Aspect(i, j, 'Üçgen', 120, diff));
        else if ((diff - 180).abs() < orb) aspects.add(Aspect(i, j, 'Karşıt', 180, diff));
      }
    }
    return aspects;
  }

  // ── YORUM MOTORU ──

  String getPersonalitySummary() {
    final sun = planets[0]; final moon = planets[1]; final asc = signs[ascSignIndex];
    return '${signs[sun.signIndex]} enerjisiyle parlıyorsun, ${signs[moon.signIndex]} Ay\'ın duygusal derinlik katıyor. $asc yükseleni dış dünyadaki izlenimini şekillendiriyor.';
  }

  String getLoveInterpretation() {
    final venus = planets[3]; final mars = planets[4];
    return '${signs[venus.signIndex]} Venüs\'ün sevgi dilini, ${signs[mars.signIndex]} Mars\'ın tutku tarzını belirliyor. ${_venusHouseInterpretation(venus.house)}';
  }

  String getCareerInterpretation() {
    final mc = signs[mcSignIndex]; final saturn = planets[6];
    return 'MC $mc burcunda — kariyer yönünü bu çiziyor. ${signs[saturn.signIndex]} Satürn disiplin alanını belirliyor. ${_careerHouseInterpretation(planets[0].house)}';
  }

  String getEmotionalInterpretation() {
    final moon = planets[1];
    return '${signs[moon.signIndex]} Ay\'ın iç dünyanı yönetiyor. ${_moonHouseInterpretation(moon.house)}';
  }

  String getStrengthsWeaknesses() {
    final sun = planets[0]; final saturn = planets[6]; final mars = planets[4];
    return '${signs[sun.signIndex]} kararlılığı, ${signs[mars.signIndex]} savaşçı ruhu. ${signs[saturn.signIndex]} Satürn\'ün getirdiği sınırlar denge noktandır.';
  }

  String _venusHouseInterpretation(int house) {
    const m = {
      1:'Çekiciliğin doğal ve göz alıcı.', 2:'Aşkta güvenlik ve konfor arıyorsun.',
      3:'Entelektüel bağ seni cezbediyor.', 4:'Yuva kurmak aşkın temel taşı.',
      5:'Romantizm ve tutku hayatının merkezinde.', 6:'Sevgiyi günlük ilgide buluyorsun.',
      7:'Kalıcı ortaklıklar ve derin bağlar arıyorsun.', 8:'Yoğun ve dönüştürücü aşklar yaşıyorsun.',
      9:'Maceracı ve özgür bir aşk anlayışın var.', 10:'Statü ve saygınlık aşkta önemli.',
      11:'Arkadaşlık temelli ilişkiler tercih ediyorsun.', 12:'Gizli ve ruhsal derin bağlar kuruyorsun.',
    };
    return m[house] ?? '';
  }

  String _careerHouseInterpretation(int house) {
    const m = {
      1:'Kişisel marka ve liderlik öne çıkıyor.', 2:'Finansal güvenlik kariyer motivasyonun.',
      3:'İletişim ve medya alanları parlıyor.', 4:'Ev ve aile odaklı işler uygun.',
      5:'Yaratıcı sektörler ve sanat alanları ideal.', 6:'Hizmet ve sağlık sektörleri güçlü.',
      7:'Ortaklık ve danışmanlık alanları parlak.', 8:'Finans ve araştırma alanları öne çıkıyor.',
      9:'Eğitim ve uluslararası alanlar uygun.', 10:'Yöneticilik ve kamu alanları doğal yeteneklerin.',
      11:'Teknoloji ve sosyal girişimler ideal.', 12:'Ruhsal ve sanatsal alanlar çekiyor.',
    };
    return m[house] ?? '';
  }

  String _moonHouseInterpretation(int house) {
    const m = {
      1:'Duygularını açıkça gösteriyorsun.', 2:'Duygusal güvenlik maddi istikrarla bağlantılı.',
      3:'Duygularını kelimelerle ifade ediyorsun.', 4:'Aile ve yuva duygusal merkezin.',
      5:'Duygularını yaratıcılıkla dışa vuruyorsun.', 6:'Duygusal dengen rutinlerle sağlanıyor.',
      7:'Duygusal tatmini ilişkilerde buluyorsun.', 8:'Derin ve yoğun duygusal deneyimler yaşıyorsun.',
      9:'Keşif ve öğrenme seni duygusal olarak besliyor.', 10:'Başarı duygusal tatminin kaynağı.',
      11:'Topluluk duygusu seni güçlendiriyor.', 12:'İç dünyanda derin bir duygusal okyanus var.',
    };
    return m[house] ?? '';
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
