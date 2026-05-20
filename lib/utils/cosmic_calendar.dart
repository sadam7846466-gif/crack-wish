import 'dart:io';
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
    // ==========================================
    // --- MİSTİK & KOZMİK GÜNLER (GLOBAL) ---
    // ==========================================
    "03-20": const CosmicDayEvent(
      emoji: '🌱',
      iconWidget: Icon(Icons.eco_rounded, size: 18, color: Colors.green),
      trTitle: 'Bugün İlkbahar Ekinoksu', enTitle: 'Today is Spring Equinox',
      descTr: 'Gece ve gündüz eşit. Yeniden doğuşun ve doğanın uyanışının enerjisini hisset.',
      descEn: 'Day and night are equal. Feel the energy of rebirth and nature\'s awakening.',
    ),
    "06-21": const CosmicDayEvent(
      emoji: '☀️',
      iconWidget: Icon(Icons.light_mode_rounded, size: 18, color: Colors.yellowAccent),
      trTitle: 'Bugün Yaz Gündönümü', enTitle: 'Today is Summer Solstice',
      descTr: 'Güneşin en güçlü olduğu, günün en uzun olduğu zaman. Işığını dışarıya yansıt.',
      descEn: 'The day the sun is strongest and longest. Reflect your light outwards.',
    ),
    "09-23": const CosmicDayEvent(
      emoji: '🍂',
      iconWidget: Icon(Icons.energy_savings_leaf_rounded, size: 18, color: Colors.orangeAccent),
      trTitle: 'Bugün Sonbahar Ekinoksu', enTitle: 'Today is Autumn Equinox',
      descTr: 'Denge zamanı. Hasatını topla ve içsel huzura odaklan.',
      descEn: 'Time for balance. Gather your harvest and focus on inner peace.',
    ),
    "11-11": const CosmicDayEvent(
      emoji: '✨',
      iconWidget: Icon(Icons.auto_awesome, size: 18, color: Colors.purpleAccent),
      trTitle: '11:11 Kozmik Portalı', enTitle: '11:11 Cosmic Portal',
      descTr: 'Manifest kapıları açık! Bugün ne dilersen evren seni duyacak.',
      descEn: 'Manifestation doors are open! The universe is listening to your wishes today.',
    ),
    "12-21": const CosmicDayEvent(
      emoji: '❄️',
      iconWidget: Icon(Icons.ac_unit_rounded, size: 18, color: Colors.lightBlueAccent),
      trTitle: 'Bugün Kış Gündönümü', enTitle: 'Today is Winter Solstice',
      descTr: 'En uzun gece. İçe dönmek, dinlenmek ve yeni yıla ruhunu hazırlamak için harika.',
      descEn: 'The longest night. Great for turning inward, resting and preparing your soul.',
    ),

    // ==========================================
    // --- EVRENSEL KUTLAMALAR (GLOBAL) ---
    // ==========================================
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
    "04-01": const CosmicDayEvent(
      emoji: '🃏',
      iconWidget: Icon(Icons.sentiment_very_satisfied_rounded, size: 18, color: Colors.orangeAccent),
      trTitle: 'Bugün Şaka Günü', enTitle: 'Today is April Fools\' Day',
      descTr: 'Gülmek ruhun ilacıdır. Bugün eğlenceye ve espriye açık ol.',
      descEn: 'Laughter is the soul\'s medicine. Be open to fun and humor today.',
    ),
    "04-22": const CosmicDayEvent(
      emoji: '🌍',
      iconWidget: Icon(Icons.public_rounded, size: 18, color: Colors.green),
      trTitle: 'Bugün Dünya Günü', enTitle: 'Today is Earth Day',
      descTr: 'Evimiz olan gezegene sevgi gönder. Doğayla bağ kurma zamanı.',
      descEn: 'Send love to our home planet. Time to connect with nature.',
    ),
    "05-01": const CosmicDayEvent(
      emoji: '🛠️',
      iconWidget: Icon(Icons.engineering_rounded, size: 18, color: Colors.blueGrey),
      trTitle: 'Bugün Emek Günü', enTitle: 'Today is Labor Day',
      descTr: 'Emeğin ve alın terinin kıymetini bilme günü. Kendinle gurur duy.',
      descEn: 'A day to value effort and hard work. Be proud of yourself.',
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
    "12-25": const CosmicDayEvent(
      emoji: '🎄',
      iconWidget: Icon(Icons.park_rounded, size: 18, color: Colors.lightGreenAccent),
      trTitle: 'Bugün Noel', enTitle: 'Today is Christmas',
      descTr: 'Sıcaklık ve sevgi dolu bir gün. Mucizelere inanma vakti.',
      descEn: 'A day full of warmth and love. Time to believe in miracles.',
    ),
    "12-31": const CosmicDayEvent(
      emoji: '🥂',
      iconWidget: Icon(Icons.attractions_rounded, size: 18, color: Colors.indigoAccent),
      trTitle: 'Bugün Yılbaşı Gecesi', enTitle: 'Today is New Year\'s Eve',
      descTr: 'Geçmişi geride bırak, yepyeni bir sayfa senin için açılıyor. Kutla!',
      descEn: 'Leave the past behind, a brand new page is opening for you. Celebrate!',
    ),

    // ==========================================
    // --- YEREL MİLLİ BAYRAMLAR (LOKAL) ---
    // ==========================================
    
    // TÜRKİYE (_tr)
    "04-23_tr": const CosmicDayEvent(
      emoji: '🎈',
      iconWidget: Icon(Icons.child_care_rounded, size: 18, color: Colors.lightBlueAccent),
      trTitle: 'Bugün Çocuk Bayramı', enTitle: 'Today is Children\'s Day',
      descTr: 'İçindeki çocuğu serbest bırak! Bugün dünyanın tadını çıkarma vakti.',
      descEn: 'Unleash your inner child! Time to enjoy the world today.',
    ),
    "05-19_tr": const CosmicDayEvent(
      emoji: '🏃',
      iconWidget: Icon(Icons.directions_run_rounded, size: 18, color: Colors.redAccent),
      trTitle: 'Bugün Gençlik Bayramı', enTitle: 'Today is Youth Day',
      descTr: 'Dinamik ve coşkulu bir enerji seninle! Harekete geçme zamanı.',
      descEn: 'A dynamic and enthusiastic energy is with you! Time to take action.',
    ),
    "07-15_tr": const CosmicDayEvent(
      emoji: '🇹🇷',
      iconWidget: Icon(Icons.brightness_3_rounded, size: 18, color: Colors.white),
      trTitle: 'Demokrasi ve Birlik Günü', enTitle: 'Democracy and National Unity Day',
      descTr: 'Birlik ve beraberliğin gücünü hatırla. Şehitlerimizi saygıyla anıyoruz.',
      descEn: 'Remember the power of unity and solidarity. We honor our martyrs.',
    ),
    "08-30_tr": const CosmicDayEvent(
      emoji: '✌️',
      iconWidget: Icon(Icons.emoji_events_rounded, size: 18, color: Colors.amber),
      trTitle: 'Bugün Zafer Bayramı', enTitle: 'Today is Victory Day',
      descTr: 'Azim ve kararlılıkla aşılamayacak engel yoktur. İçindeki gücü kutla.',
      descEn: 'With determination, no obstacle is insurmountable. Celebrate your inner power.',
    ),
    "10-29_tr": const CosmicDayEvent(
      emoji: '🇹🇷',
      iconWidget: Icon(Icons.flag_rounded, size: 18, color: Colors.white),
      trTitle: 'Bugün Cumhuriyet Bayramı', enTitle: 'Today is Republic Day',
      descTr: 'Özgürlüğün ve bağımsızlığın getirdiği o büyük gururu hisset!',
      descEn: 'Feel the great pride of freedom and independence!',
    ),
    "11-10_tr": const CosmicDayEvent(
      emoji: '♾️',
      iconWidget: Icon(Icons.all_inclusive_rounded, size: 18, color: Colors.grey),
      trTitle: 'Atatürk\'ü Anma Günü', enTitle: 'Commemoration of Atatürk',
      descTr: 'Ulu Önder Mustafa Kemal Atatürk\'ü saygı, sevgi ve özlemle anıyoruz.',
      descEn: 'We remember Mustafa Kemal Atatürk with deep respect and gratitude.',
    ),
    "11-24_tr": const CosmicDayEvent(
      emoji: '📚',
      iconWidget: Icon(Icons.school_rounded, size: 18, color: Colors.lightBlue),
      trTitle: 'Bugün Öğretmenler Günü', enTitle: 'Today is Teachers\' Day',
      descTr: 'Bizi aydınlatan tüm öğretmenlerimize minnetle. Bilgi en büyük güçtür.',
      descEn: 'With gratitude to all teachers who enlighten us. Knowledge is power.',
    ),

    // GLOBAL İNGİLİZCE / AMERİKA KÜLTÜRÜ (_en)
    "03-17_en": const CosmicDayEvent(
      emoji: '🍀',
      iconWidget: Icon(Icons.cruelty_free_rounded, size: 18, color: Colors.greenAccent),
      trTitle: 'Bugün Aziz Patrick Günü', enTitle: 'Today is St. Patrick\'s Day',
      descTr: 'Dört yapraklı yoncanın şansı seninle olsun! Şanslı günündesin.',
      descEn: 'May the luck of the four-leaf clover be with you! It\'s your lucky day.',
    ),
    "07-04_en": const CosmicDayEvent(
      emoji: '🎇',
      iconWidget: Icon(Icons.star_rounded, size: 18, color: Colors.blueAccent),
      trTitle: 'Bugün Bağımsızlık Günü', enTitle: 'Today is Independence Day',
      descTr: 'Özgürlüğün tadını çıkar ve havai fişeklerin parlaklığını hisset.',
      descEn: 'Enjoy the freedom and feel the brightness of the fireworks.',
    ),
  };

  /// Bugün için özel bir gün olup olmadığını denetler (Önce Local, Sonra Global).
  /// Yoksa null döndürür.
  static CosmicDayEvent? getEventForDate(DateTime date, String localeCode) {
    String monthPrefix = date.month.toString().padLeft(2, '0');
    String dayPrefix = date.day.toString().padLeft(2, '0');
    
    // Uygulama dili ne olursa olsun, kullanıcının fiziksel bulunduğu ülkeyi bulalım:
    String countryCode = localeCode; // fallback olarak uygulama dilini kullan
    try {
      if (Platform.environment.containsKey('FLUTTER_TEST')) {
         countryCode = localeCode;
      } else {
        String rawLocale = Platform.localeName.replaceAll('-', '_');
        final parts = rawLocale.split('_');
        if (parts.length > 1) {
          countryCode = parts.last.toLowerCase(); // 'tr_TR' -> 'tr'
        } else {
          countryCode = parts.first.toLowerCase();
        }
      }
      
      // Timezone bazlı akıllı konum bulucu:
      // Eğer cihaz (veya simülatör) yanlışlıkla 'um', 'us' gibi farklı bir bölgede kalmışsa,
      // ama cihazın saati fiziksel olarak Türkiye saat diliminde (UTC+3) ise, onu Türkiye kabul et.
      if (DateTime.now().timeZoneOffset.inHours == 3) {
        countryCode = 'tr';
      }
      
    } catch (e) {
      // Platform check fail fallback
    }

    // 1. Önce kullanıcının fiziksel ülkesindeki bir milli/yerel bayrama bak.
    String localKey = "$monthPrefix-${dayPrefix}_$countryCode";
    if (_events.containsKey(localKey)) {
      return _events[localKey];
    }

    // Eğer 'us' ise ama en olarak eklemişsek diye fallback kontrol (Bizim takvimde _en olarak tanımlı)
    if (countryCode == 'us' || countryCode == 'gb' || countryCode == 'au') {
      String enLocalKey = "$monthPrefix-${dayPrefix}_en";
      if (_events.containsKey(enLocalKey)) {
        return _events[enLocalKey];
      }
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
