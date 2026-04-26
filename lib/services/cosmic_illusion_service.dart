import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vlucky_flutter/services/cosmic_engine_service.dart';

/// 0 Maliyetli İlizyon Motoru (Zero-Cost Magic)
/// Kullanıcının kendi cihazından, kullanıcının veritabanı posta kutusuna 
/// yapay zeka tarafından (Evren/Baykuş) gönderilmiş gibi şablon tabanlı
/// edebi ve psikolojik mektuplar yollar. OpenAI veya sunucu maliyeti sıfırdır.
class CosmicIllusionService {
  static final CosmicIllusionService _instance = CosmicIllusionService._internal();
  factory CosmicIllusionService() => _instance;
  CosmicIllusionService._internal();

  // Şablon Veritabanı
  final List<String> _nightmareTemplates = [
    "Gecenin karanlığında, {ZODIAC} burcunun hissettiği o derin ağırlığı izliyorum sevgili {NAME}. Rüyalarındaki koyu gölgeler sadece içsel büyümenin bir sancısıdır. Karanlıktan korkma, bu Ruh Taşı sana ışık olsun.",
    "Ruhunun biraz yorgun olduğunu, rüyalarına yansıyan korkulardan görebiliyorum {NAME}. Evren her zorluğun ardından bir şafak saklar. Derin bir nefes al ve sana gönderdiğim bu enerjiyi hisset."
  ];

  final List<String> _birthdayTemplates = [
    "Bugün, ruhunun bu boyuta indiği o kutsal gün sirkadiyen. Güneşin döngüsü senin için yeniden başlarken, {ZODIAC} enerjisinin en parlak halini yaşamanı diliyorum {NAME}. İyi ki kozmosun bir parçasısın.",
    "Doğum günün kutlu olsun {NAME}! Yıldızların senin için parladığı bugünde, rüyalarının ve dileklerinin yeni yaşınla gerçeğe dönüşmesini dileyerek sana bir armağan bırakıyorum."
  ];

  final List<String> _streakTemplates = [
    "Kozmik bağın giderek güçleniyor {NAME}. Üst üste günlüğüne sadık kalarak kendi bilinçaltının haritasını çiziyorsun. Bu kararlılığın için Evren sana teşekkür ediyor."
  ];

  /// Uygulama açılışında gizlice çalışıp, gerekli senaryoları (Doğum günü, kabus vb)
  /// tarayan ana analitik motor.
  Future<void> runInvisibleProfiler() async {
    if (kIsWeb) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Kullanıcı bilgisini çek (İsim ve Burç)
      String userName = prefs.getString('user_name') ?? "Ruh";
      String zodiac = prefs.getString('zodiac_sign') ?? "Yıldıztozu"; // Zodiac bilgisi (geliştirdiğimiz profile dayalı)

      // 1. Doğum Günü Kontrolü
      await _checkAndTriggerBirthdayMagic(prefs, userName, zodiac);

      // 2. Kabus / Anksiyete Sentezi (Üst üste 3 kötü rüya analizi)
      await _checkAndTriggerAnxietyRelief(prefs, userName, zodiac);

      // 3. Seri (Streak) Ödüllendirmesi
      await _checkAndTriggerStreakReward(prefs, userName, zodiac);

    } catch (e) {
      debugPrint("İlizyon profilleyici hatası: $e");
    }
  }

  /// Kullanıcının doğum gününü lokalde kontrol eder ve gece tam 00:00 iken kendisine "Evrenden" mesaj atar.
  Future<void> _checkAndTriggerBirthdayMagic(SharedPreferences prefs, String name, String zodiac) async {
    // Profil ekranında girilen doğum tarihi bilgisini alıyoruz
    String? dobString = prefs.getString('date_of_birth');
    if (dobString == null) return;

    DateTime dob = DateTime.parse(dobString);
    DateTime today = DateTime.now();

    // Bugün doğum günü ise
    if (dob.month == today.month && dob.day == today.day) {
      String key = 'birthday_gift_received_${today.year}';
      if (!(prefs.getBool(key) ?? false)) {
        // Hediyeyi vermemişiz, hemen İlizyonu başlat.
        String msg = _getRandomTemplate(_birthdayTemplates, name, zodiac);
        
        // Zarfı kullanıcının posta kutusuna "Kozmik Baykuş" adıyla sinsi sinsi bırak.
        await _deliverCosmicLetter("Kozmik Baykuş", msg, giftAmount: 10);
        
        prefs.setBool(key, true);
        debugPrint("🎂 Sıfır Maliyetli Doğum Günü Ritüeli Tetiklendi!");
      }
    }
  }

  /// Kullanıcının son rüyalarını matematiksel tarar
  Future<void> _checkAndTriggerAnxietyRelief(SharedPreferences prefs, String name, String zodiac) async {
    String todayKey = 'nightmare_relief_sent_${DateTime.now().month}_${DateTime.now().day}';
    if (prefs.getBool(todayKey) ?? false) return; // Günde en fazla 1 kez

    // Basit Matematik: StorageService üzerinden kullanıcının son girilen rüya duygularını (Fear, Anxiety, vs) say.
    // Eğer art arda son 2-3 rüya negatif duygudaysa (Veya Puan hesaplanırsa);
    
    // (Simüle edilmiş basit matematiksel kural, veri altyapısına göre StorageService'den çekilebilir): 
    bool hasConsecutiveNightmares = false; // Şimdilik basitçe eklendi.
    
    if (hasConsecutiveNightmares) {
      String msg = _getRandomTemplate(_nightmareTemplates, name, zodiac);
      await _deliverCosmicLetter("Rehber Ruh", msg, giftAmount: 2); // Küçük moral hediyesi
      prefs.setBool(todayKey, true);
      debugPrint("🌑 Negatif Ruh Hali Tespit Edildi, Şifa Mektubu Gönderildi.");
    }
  }

  Future<void> _checkAndTriggerStreakReward(SharedPreferences prefs, String name, String zodiac) async {
     // Örnek: Eğer appOpenCount = 7 olduysa rozet at
    int currentStreak = prefs.getInt('app_open_streak') ?? 0;
    if (currentStreak == 7 && !(prefs.getBool('streak_7_rewarded') ?? false)) {
       String msg = _getRandomTemplate(_streakTemplates, name, zodiac);
       await _deliverCosmicLetter("Zamanın Bekçisi", msg, giftAmount: 5);
       prefs.setBool('streak_7_rewarded', true);
       debugPrint("🔥 7 Günlük Seri Başarısı Evren Tarafından Ödüllendirildi.");
    }
  }

  // --- Yardımcı Metodlar ---

  String _getRandomTemplate(List<String> list, String name, String zodiac) {
    String t = list[Random().nextInt(list.length)];
    t = t.replaceAll("{NAME}", name);
    t = t.replaceAll("{ZODIAC}", zodiac);
    return t;
  }

  /// Kendi kendine mesaj yollama illüzyonu (Kullanıcının veritabanına)
  Future<void> _deliverCosmicLetter(String senderName, String content, {int giftAmount = 0}) async {
    // 1. Mektubu kullanıcının Posta Kutusunda kalıcı görünmesi için Local Storage'a json olarak kaydet
    try {
      final prefs = await SharedPreferences.getInstance();
      final lettersVec = prefs.getStringList('cosmic_inbox_letters') ?? [];
      
      final Map<String, dynamic> newLetter = {
        'id': 'cosmic_\${DateTime.now().millisecondsSinceEpoch}',
        'senderName': senderName,
        'content': content,
        'giftAmount': giftAmount,
        'date': DateTime.now().toIso8601String(),
      };
      
      lettersVec.add(jsonEncode(newLetter));
      await prefs.setStringList('cosmic_inbox_letters', lettersVec);
      
      debugPrint("💌 [İlizyon Motoru] \$senderName posta kutusuna zarfı bıraktı!");
    } catch(e) {
      debugPrint("Mektup bırakılamadı: \$e");
    }

    // 2. Bildirimin doğrudan düşmesi için Local Notification taklit et
    CosmicEngineService().scheduleInstantLocalNotification(
      title: "🔮 \$senderName'den Yeni Bir Mesaj",
      body: "Evrenin sana iletmek istediği bir mesaj var...",
    );
  }
}
