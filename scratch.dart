import 'dart:math' as math;

class _FastRandom implements math.Random {
  int _state;
  _FastRandom(int seed) : _state = seed;

  @override
  int nextInt(int max) {
    _state = (_state * 1103515245 + 12345) & 0x7fffffff;
    return _state % max;
  }
  @override bool nextBool() => nextInt(2) == 0;
  @override double nextDouble() => nextInt(1000000) / 1000000.0;
}

void main() {
  var list = [
    'fortune_cat', 'spring_wreath', 'lucky_clover', 'royal_hearts', 
    'evil_eye', 'pizza_party', 'sakura_bloom', 'celestial_dream', 
    'starlight_whisper', 'mystic_aura', 'lunar_glow', 'solar_flare', 
    'cosmic_dust', 'nebula_breeze', 'astral_projection', 'quantum_leap', 
    'enchanted_forest', 'ramadan_cute'
  ];
  
  final now = DateTime(2026, 5, 3);
  final weekNumber = now.difference(DateTime(now.year, 1, 1)).inDays ~/ 7;
  print("week: $weekNumber");
  list.shuffle(_FastRandom(weekNumber));
  print(list.take(6).toList());
}
