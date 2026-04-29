import 'package:flutter/material.dart';

class CosmicDayEvent {
  final String emoji;
  final Widget iconWidget;
  final String trTitle;
  final String enTitle;
  final String descTr;
  final String descEn;

  const CosmicDayEvent({
    required this.emoji,
    required this.iconWidget,
    required this.trTitle,
    required this.enTitle,
    required this.descTr,
    required this.descEn,
  });
}

class CosmicCalendar {
  // Veritabanı: Ay-Gün_Dil formatı. (Örn: "10-29_tr", "04-01")
  // Format MM-DD_locale veya MM-DD (global)
  static final Map<String, CosmicDayEvent> _events = {
    // --- GLOBAL GÜNLER ---
    "01-01": const CosmicDayEvent(
      emoji: '🎆',
      iconWidget: Icon(Icons.celebration_rounded, size: 18, color: Colors.amberAccent),
      trTitle: 'Bugün Yeni Yıl', enTitle: 'Today is New Year',
      descTr: 'Yepyeni bir başlangıç! Bu yıl hayallerinin vücut bulduğu yıl olacak.',
      descEn: 'A brand new start! This will be the year your dreams come true.',
    ),
    "02-14": const CosmicDayEvent(
      emoji: '💖',
      iconWidget: Icon(Icons.favorite, size: 18, color: Colors.pinkAccent),
      trTitle: 'Bugün Sevgililer Günü', enTitle: 'Today is Valentine\'s Day',
      descTr: 'Aşkı kutlama zamanı! Bugün etrafına sevgi tohumları ek.',
      descEn: 'Time to celebrate love! Plant seeds of love around you today.',
    ),
    "03-08": const CosmicDayEvent(
      emoji: '👩',
      iconWidget: Icon(Icons.face_3_rounded, size: 18, color: Colors.purpleAccent),
      trTitle: 'Bugün Kadınlar Günü', enTitle: 'Today is Women\'s Day',
      descTr: 'Güçlü kadınların dünyayı değiştiren enerjisini hisset.',
      descEn: 'Feel the world-changing energy of strong women.',
    ),
    "04-01": const CosmicDayEvent( // 1 Nisan Şaka Günü (Hemen Hemen Global)
      emoji: '🃏',
      iconWidget: Icon(Icons.sentiment_very_satisfied_rounded, size: 18, color: Colors.orangeAccent),
      trTitle: 'Bugün Şaka Günü', enTitle: 'Today is April Fools\' Day',
      descTr: 'Gülmek ruhun ilacıdır. Bugün eğlenceye ve espriye açık ol.',
      descEn: 'Laughter is the soul\'s medicine. Be open to fun and humor today.',
    ),
    "05-01": const CosmicDayEvent(
      emoji: '🛠️',
      iconWidget: Icon(Icons.engineering_rounded, size: 18, color: Colors.blueGrey),
      trTitle: 'Bugün Emek Günü', enTitle: 'Today is Labor Day',
      descTr: 'Emeğin ve alın terinin kıymetini bilme günü. Kendinle gurur duy.',
      descEn: 'A day to value effort and hard work. Be proud of yourself.',
    ),
    "06-21": const CosmicDayEvent(
      emoji: '☀️',
      iconWidget: Icon(Icons.light_mode_rounded, size: 18, color: Colors.yellowAccent),
      trTitle: 'Bugün Yaz Gündönümü', enTitle: 'Today is Summer Solstice',
      descTr: 'Güneşin en güçlü olduğu gün. Işığını dışarıya yansıt.',
      descEn: 'The day the sun is strongest. Reflect your light outwards.',
    ),
    "07-30": const CosmicDayEvent(
      emoji: '🫂',
      iconWidget: Icon(Icons.hub_rounded, size: 18, color: Colors.greenAccent),
      trTitle: 'Bugün Arkadaşlık Günü', enTitle: 'Today is Friendship Day',
      descTr: 'Gerçek dostlar hazinedir. Bugün onlara ne kadar değerli olduklarını hissettir.',
      descEn: 'True friends are treasures. Make them feel valuable today.',
    ),
    "10-01": const CosmicDayEvent(
      emoji: '☕',
      iconWidget: Icon(Icons.local_cafe_rounded, size: 18, color: Colors.brown),
      trTitle: 'Bugün Kahve Günü', enTitle: 'Today is World Coffee Day',
      descTr: 'Zihnini canlandır. Bugün yaratıcı bir sohbet için harika bir gün.',
      descEn: 'Revitalize your mind. Today is a great day for a creative chat.',
    ),
    "10-31": const CosmicDayEvent(
      emoji: '🎃',
      iconWidget: Icon(Icons.nightlight_round, size: 18, color: Colors.deepOrange),
      trTitle: 'Bugün Cadılar Bayramı', enTitle: 'Today is Halloween',
      descTr: 'Korkularıyla yüzleşenler güçlenir. Bugün içindeki karanlığı kucakla.',
      descEn: 'Those who face their fears grow stronger. Embrace your inner darkness today.',
    ),
    "12-31": const CosmicDayEvent(
      emoji: '🥂',
      iconWidget: Icon(Icons.attractions_rounded, size: 18, color: Colors.indigoAccent),
      trTitle: 'Bugün Yılbaşı Gecesi', enTitle: 'Today is New Year\'s Eve',
      descTr: 'Geçmişi geride bırak, yepyeni bir sayfa senin için açılıyor. Kutla!',
      descEn: 'Leave the past behind, a brand new page is opening for you. Celebrate!',
    ),

    // --- YEREL (LOCAL) GÜNLER ---
    "04-23_tr": const CosmicDayEvent(
      emoji: '🎈',
      iconWidget: Icon(Icons.child_care_rounded, size: 18, color: Colors.lightBlueAccent),
      trTitle: 'Bugün Çocuk Bayramı', enTitle: 'Today is Children\'s Day', // Türkiye için
      descTr: 'İçindeki çocuğu serbest bırak! Bugün dünyanın tadını çıkarma vakti.',
      descEn: 'Unleash your inner child! Time to enjoy the world today.',
    ),
    "05-19_tr": const CosmicDayEvent(
      emoji: '🏃',
      iconWidget: Icon(Icons.directions_run_rounded, size: 18, color: Colors.redAccent),
      trTitle: 'Bugün Gençlik Bayramı', enTitle: 'Today is Youth Day', // Türkiye için
      descTr: 'Dinamik ve coşkulu bir enerji seninle! Harekete geçme zamanı.',
      descEn: 'A dynamic and enthusiastic energy is with you! Time to take action.',
    ),
    "10-29_tr": const CosmicDayEvent(
      emoji: '🇹🇷',
      iconWidget: Icon(Icons.flag_rounded, size: 18, color: Colors.white),
      trTitle: 'Bugün Cumhuriyet Bayramı', enTitle: 'Today is Republic Day', // Türkiye için
      descTr: 'Özgürlüğün ve bağımsızlığın getirdiği o büyük gururu hisset!',
      descEn: 'Feel the great pride of freedom and independence!',
    ),
  };

  /// Bugün için özel bir gün olup olmadığını denetler (Önce Local, Sonra Global).
  /// Yoksa null döndürür.
  static CosmicDayEvent? getEventForDate(DateTime date, String localeCode) {
    String monthPrefix = date.month.toString().padLeft(2, '0');
    String dayPrefix = date.day.toString().padLeft(2, '0');
    
    // 1. Önce kullanıcının bölgesindeki bir milli/yerel bayrama bak.
    String localKey = "$monthPrefix-${dayPrefix}_$localeCode";
    if (_events.containsKey(localKey)) {
      return _events[localKey];
    }

    // 2. Eğer yerel özel gün yoksa, tüm dünyada kutlanan global günleri kontrol et.
    String globalKey = "$monthPrefix-$dayPrefix";
    if (_events.containsKey(globalKey)) {
      return _events[globalKey];
    }

    // 3. Hiçbiri yoksa normal astrolojik temalar çalışacak.
    return null;
  }
}
