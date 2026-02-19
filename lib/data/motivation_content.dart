/// Motivasyon İçerik Havuzu - 50+ Deneyim
/// 6 Kategori: Rahatlama, Enerji, Odak, Düşünce, Motivasyon, Farkındalık

enum MotivationCategory {
  relaxation,   // Rahatlama
  energy,       // Enerji
  focus,        // Odak
  thinking,     // Düşünce sorgulama
  motivation,   // Motivasyon
  awareness,    // Duygusal farkındalık
}

enum ExerciseType {
  breathing,      // Nefes egzersizi
  grounding,      // Topraklama
  meditation,     // Mini meditasyon
  movement,       // Hareket
  cbt,            // CBT kart
  perspective,    // Bakış açısı
  microGoal,      // Mikro hedef
  timer,          // Focus timer
  gratitude,      // Minnettarlık
  bodyAwareness,  // Beden farkındalığı
}

class MotivationExercise {
  final String id;
  final String title;
  final String description;
  final MotivationCategory category;
  final ExerciseType type;
  final int durationSeconds;
  final Map<String, dynamic> data;
  
  const MotivationExercise({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.durationSeconds,
    this.data = const {},
  });
}

/// 50+ Deneyim Havuzu
class MotivationContent {
  
  // ═══════════════════════════════════════════════════════════════
  // RAHATLAMA KATEGORİSİ (10 içerik)
  // ═══════════════════════════════════════════════════════════════
  static const List<MotivationExercise> relaxationExercises = [
    MotivationExercise(
      id: 'breath_444',
      title: '4-4-4 Nefes',
      description: '4 saniye nefes al, 4 tut, 4 ver',
      category: MotivationCategory.relaxation,
      type: ExerciseType.breathing,
      durationSeconds: 120,
      data: {'inhale': 4, 'hold': 4, 'exhale': 4, 'cycles': 4},
    ),
    MotivationExercise(
      id: 'breath_478',
      title: '4-7-8 Nefes',
      description: 'Derin rahatlama tekniği',
      category: MotivationCategory.relaxation,
      type: ExerciseType.breathing,
      durationSeconds: 150,
      data: {'inhale': 4, 'hold': 7, 'exhale': 8, 'cycles': 3},
    ),
    MotivationExercise(
      id: 'breath_box',
      title: 'Kutu Nefes',
      description: 'Kare şeklinde nefes döngüsü',
      category: MotivationCategory.relaxation,
      type: ExerciseType.breathing,
      durationSeconds: 120,
      data: {'inhale': 4, 'hold': 4, 'exhale': 4, 'holdEmpty': 4, 'cycles': 4},
    ),
    MotivationExercise(
      id: 'ground_54321',
      title: '5-4-3-2-1 Topraklama',
      description: '5 şey gör, 4 dokun, 3 duy, 2 kokla, 1 tat',
      category: MotivationCategory.relaxation,
      type: ExerciseType.grounding,
      durationSeconds: 180,
      data: {'steps': ['5 şey gör', '4 şey dokun', '3 şey duy', '2 şey kokla', '1 şey tat']},
    ),
    MotivationExercise(
      id: 'ground_feet',
      title: 'Ayaklar Yere',
      description: 'Ayaklarını yere bas, bağlantıyı hisset',
      category: MotivationCategory.relaxation,
      type: ExerciseType.grounding,
      durationSeconds: 60,
      data: {'instruction': 'Ayaklarını yere sıkıca bas. Ağırlığını hisset.'},
    ),
    MotivationExercise(
      id: 'med_body_scan',
      title: 'Beden Taraması',
      description: 'Baştan ayağa vücudunu tara',
      category: MotivationCategory.relaxation,
      type: ExerciseType.meditation,
      durationSeconds: 180,
      data: {'parts': ['Baş', 'Omuzlar', 'Göğüs', 'Karın', 'Bacaklar', 'Ayaklar']},
    ),
    MotivationExercise(
      id: 'med_safe_place',
      title: 'Güvenli Yer',
      description: 'Zihninde güvenli bir yer hayal et',
      category: MotivationCategory.relaxation,
      type: ExerciseType.meditation,
      durationSeconds: 120,
      data: {'prompt': 'Kendini güvende hissettiğin bir yer hayal et...'},
    ),
    MotivationExercise(
      id: 'relax_jaw',
      title: 'Çene Gevşetme',
      description: 'Çene ve yüz kaslarını gevşet',
      category: MotivationCategory.relaxation,
      type: ExerciseType.bodyAwareness,
      durationSeconds: 60,
      data: {'instruction': 'Çeneni hafifçe aç, dişlerin birbirine değmesin.'},
    ),
    MotivationExercise(
      id: 'relax_shoulders',
      title: 'Omuz Bırakma',
      description: 'Omuzlarını kulaktan uzaklaştır',
      category: MotivationCategory.relaxation,
      type: ExerciseType.bodyAwareness,
      durationSeconds: 45,
      data: {'instruction': 'Omuzlarını yukarı kaldır, sonra bırak.'},
    ),
    MotivationExercise(
      id: 'breath_calm',
      title: 'Sakin Nefes',
      description: 'Yavaş ve derin nefes al',
      category: MotivationCategory.relaxation,
      type: ExerciseType.breathing,
      durationSeconds: 90,
      data: {'inhale': 5, 'exhale': 7, 'cycles': 5},
    ),
    // Yeni eklenen egzersizler
    MotivationExercise(
      id: 'relax_pmr',
      title: 'Kas Gevşetme',
      description: 'Progressive muscle relaxation',
      category: MotivationCategory.relaxation,
      type: ExerciseType.bodyAwareness,
      durationSeconds: 180,
      data: {'instruction': 'Sırayla her kas grubunu 5 sn kas, sonra gevşet. El → Kol → Omuz → Yüz → Bacak.'},
    ),
    MotivationExercise(
      id: 'relax_1min_reset',
      title: '1 Dakika Reset',
      description: 'Gözleri kapat, zihni sıfırla',
      category: MotivationCategory.relaxation,
      type: ExerciseType.meditation,
      durationSeconds: 60,
      data: {'instruction': 'Gözlerini kapat. 1 dakika boyunca sadece nefesine odaklan.'},
    ),
    MotivationExercise(
      id: 'breath_heart',
      title: 'Kalp Ritmi Nefes',
      description: 'Kalp atışıyla senkron nefes',
      category: MotivationCategory.relaxation,
      type: ExerciseType.breathing,
      durationSeconds: 120,
      data: {'inhale': 5, 'exhale': 5, 'cycles': 6},
    ),
    MotivationExercise(
      id: 'relax_thought_dump',
      title: 'Düşünce Boşaltma',
      description: 'Zihnindekileri bırak',
      category: MotivationCategory.relaxation,
      type: ExerciseType.meditation,
      durationSeconds: 90,
      data: {'instruction': 'Zihnindeki tüm düşünceleri fark et ve bırak. Tutma.'},
    ),
    MotivationExercise(
      id: 'relax_eyes',
      title: 'Göz Dinlendirme',
      description: '20-20-20 kuralı',
      category: MotivationCategory.relaxation,
      type: ExerciseType.bodyAwareness,
      durationSeconds: 60,
      data: {'instruction': 'Gözlerini kapat veya 6 metre uzağa bak. 20 saniye dinlen.'},
    ),
  ];
  
  // ═══════════════════════════════════════════════════════════════
  // ENERJİ KATEGORİSİ (8 içerik)
  // ═══════════════════════════════════════════════════════════════
  static const List<MotivationExercise> energyExercises = [
    MotivationExercise(
      id: 'move_30sec',
      title: '30 Saniye Hareket',
      description: 'Ayağa kalk, hareket et',
      category: MotivationCategory.energy,
      type: ExerciseType.movement,
      durationSeconds: 30,
      data: {'instruction': 'Ayağa kalk ve 30 saniye boyunca hareket et.'},
    ),
    MotivationExercise(
      id: 'move_stretch',
      title: 'Germe Hareketi',
      description: 'Vücudunu ger ve esnet',
      category: MotivationCategory.energy,
      type: ExerciseType.movement,
      durationSeconds: 60,
      data: {'instruction': 'Kollarını yukarı uzat, gergin kaslarını esnet.'},
    ),
    MotivationExercise(
      id: 'energy_breath',
      title: 'Enerji Nefesi',
      description: 'Hızlı nefes alarak enerji topla',
      category: MotivationCategory.energy,
      type: ExerciseType.breathing,
      durationSeconds: 45,
      data: {'inhale': 2, 'exhale': 2, 'cycles': 10},
    ),
    MotivationExercise(
      id: 'move_walk',
      title: 'Kısa Yürüyüş',
      description: 'Odayı bir tur at',
      category: MotivationCategory.energy,
      type: ExerciseType.movement,
      durationSeconds: 60,
      data: {'instruction': 'Bulunduğun alanda biraz yürü.'},
    ),
    MotivationExercise(
      id: 'move_shake',
      title: 'Silkele',
      description: 'Vücudunu silkele, enerjiyi yay',
      category: MotivationCategory.energy,
      type: ExerciseType.movement,
      durationSeconds: 30,
      data: {'instruction': 'Ellerini, kollarını, bacaklarını silkele.'},
    ),
    MotivationExercise(
      id: 'cold_water',
      title: 'Soğuk Su',
      description: 'Yüzüne soğuk su çarp',
      category: MotivationCategory.energy,
      type: ExerciseType.movement,
      durationSeconds: 30,
      data: {'instruction': 'Yüzüne soğuk su çarparak kendini uyandır.'},
    ),
    MotivationExercise(
      id: 'sunlight',
      title: 'Güneş Işığı',
      description: 'Pencereye git, ışık al',
      category: MotivationCategory.energy,
      type: ExerciseType.movement,
      durationSeconds: 60,
      data: {'instruction': 'Pencereye git ve doğal ışığa bak.'},
    ),
    MotivationExercise(
      id: 'power_pose',
      title: 'Güç Pozu',
      description: 'Güçlü bir duruş al',
      category: MotivationCategory.energy,
      type: ExerciseType.movement,
      durationSeconds: 60,
      data: {'instruction': 'Dik dur, omuzları aç, güçlü hisset.'},
    ),
    // Yeni eklenen egzersizler
    MotivationExercise(
      id: 'posture_fix',
      title: 'Postür Düzeltme',
      description: 'Duruşunu düzelt',
      category: MotivationCategory.energy,
      type: ExerciseType.bodyAwareness,
      durationSeconds: 30,
      data: {'instruction': 'Omuzlarını geri çek, çeneni paralel tut, göğsünü aç.'},
    ),
    MotivationExercise(
      id: 'water_reminder',
      title: 'Su İç',
      description: 'Vücudunu nemledir',
      category: MotivationCategory.energy,
      type: ExerciseType.microGoal,
      durationSeconds: 30,
      data: {'instruction': 'Bir bardak su iç. Dehidrasyon enerjiyi düşürür.'},
    ),
    MotivationExercise(
      id: 'energy_1min',
      title: '1 Dakika Aktivasyon',
      description: 'Hızlı enerji boost',
      category: MotivationCategory.energy,
      type: ExerciseType.movement,
      durationSeconds: 60,
      data: {'instruction': '30 sn yerinde koş + 30 sn jumping jack.'},
    ),
    MotivationExercise(
      id: 'micro_task',
      title: 'Mikro Görev',
      description: 'Küçük bir şey tamamla',
      category: MotivationCategory.energy,
      type: ExerciseType.microGoal,
      durationSeconds: 120,
      data: {'instruction': '2 dakikadan kısa bir iş bul ve hemen tamamla.'},
    ),
  ];
  
  // ═══════════════════════════════════════════════════════════════
  // ODAK KATEGORİSİ (8 içerik)
  // ═══════════════════════════════════════════════════════════════
  static const List<MotivationExercise> focusExercises = [
    MotivationExercise(
      id: 'focus_3min',
      title: '3 Dakika Odak',
      description: 'Tek bir şeye 3 dakika odaklan',
      category: MotivationCategory.focus,
      type: ExerciseType.timer,
      durationSeconds: 180,
      data: {'instruction': 'Tek bir görev seç ve 3 dakika boyunca sadece ona odaklan.'},
    ),
    MotivationExercise(
      id: 'focus_5min',
      title: '5 Dakika Sprint',
      description: 'Kısa ve yoğun odaklanma',
      category: MotivationCategory.focus,
      type: ExerciseType.timer,
      durationSeconds: 300,
      data: {'instruction': '5 dakika boyunca hiçbir şeye bakmadan çalış.'},
    ),
    MotivationExercise(
      id: 'focus_breath',
      title: 'Odak Nefesi',
      description: 'Nefesine odaklanarak başla',
      category: MotivationCategory.focus,
      type: ExerciseType.breathing,
      durationSeconds: 60,
      data: {'instruction': 'Sadece nefesine odaklan, düşünceler gelirse bırak.'},
    ),
    MotivationExercise(
      id: 'focus_one_thing',
      title: 'Tek Şey',
      description: 'Bugün tek önemli şey ne?',
      category: MotivationCategory.focus,
      type: ExerciseType.microGoal,
      durationSeconds: 60,
      data: {'question': 'Bugün tamamlaman gereken EN önemli tek şey ne?'},
    ),
    MotivationExercise(
      id: 'focus_clear_desk',
      title: 'Masa Temizle',
      description: 'Çalışma alanını düzenle',
      category: MotivationCategory.focus,
      type: ExerciseType.microGoal,
      durationSeconds: 120,
      data: {'instruction': 'Masandan gereksiz şeyleri kaldır.'},
    ),
    MotivationExercise(
      id: 'focus_phone_away',
      title: 'Telefonu Uzaklaştır',
      description: 'Telefonu görüş alanından çıkar',
      category: MotivationCategory.focus,
      type: ExerciseType.microGoal,
      durationSeconds: 30,
      data: {'instruction': 'Telefonunu başka odaya veya çantana koy.'},
    ),
    MotivationExercise(
      id: 'focus_intention',
      title: 'Niyet Belirle',
      description: 'Şimdi ne yapmak istiyorsun?',
      category: MotivationCategory.focus,
      type: ExerciseType.microGoal,
      durationSeconds: 45,
      data: {'question': 'Şu an için niyetin ne?'},
    ),
    MotivationExercise(
      id: 'focus_pomodoro',
      title: 'Mini Pomodoro',
      description: '10 dakika çalış, 2 mola',
      category: MotivationCategory.focus,
      type: ExerciseType.timer,
      durationSeconds: 600,
      data: {'work': 600, 'break': 120},
    ),
    // Yeni eklenen egzersizler
    MotivationExercise(
      id: 'focus_reset',
      title: 'Dikkat Reset',
      description: 'Odağını sıfırla',
      category: MotivationCategory.focus,
      type: ExerciseType.meditation,
      durationSeconds: 60,
      data: {'instruction': 'Gözlerini kapat, 3 derin nefes al, yeniden başla.'},
    ),
    MotivationExercise(
      id: 'focus_noise',
      title: 'Gürültü Azalt',
      description: 'Sessiz ortam oluştur',
      category: MotivationCategory.focus,
      type: ExerciseType.microGoal,
      durationSeconds: 30,
      data: {'instruction': 'Bildirimleri kapat, kulaklık tak veya sessiz moduna geç.'},
    ),
    MotivationExercise(
      id: 'focus_distraction',
      title: 'Dikkat Dağıtıcı Farkındalık',
      description: 'Neye takılıyorsun?',
      category: MotivationCategory.focus,
      type: ExerciseType.cbt,
      durationSeconds: 45,
      data: {'question': 'Dikkatini dağıtan şey ne? Onu şimdilik bir kenara koy.'},
    ),
    MotivationExercise(
      id: 'focus_chunk',
      title: 'Hedef Parçalama',
      description: 'Büyük görevi küçük parçalara böl',
      category: MotivationCategory.focus,
      type: ExerciseType.microGoal,
      durationSeconds: 60,
      data: {'question': 'Bu görevi 3 küçük adıma bölersen, ilk adım ne?'},
    ),
  ];
  
  // ═══════════════════════════════════════════════════════════════
  // DÜŞÜNCE SORGULAMA KATEGORİSİ (10 içerik)
  // ═══════════════════════════════════════════════════════════════
  static const List<MotivationExercise> thinkingExercises = [
    MotivationExercise(
      id: 'cbt_challenge',
      title: 'Düşünce Sorgusu',
      description: 'Bu düşünce gerçekten doğru mu?',
      category: MotivationCategory.thinking,
      type: ExerciseType.cbt,
      durationSeconds: 120,
      data: {
        'cards': [
          'Bu düşünce kesin doğru mu?',
          'Bunu kanıtlayan delil ne?',
          'Başka bir ihtimal var mı?',
          'En kötü senaryo gerçekleşse ne olur?',
        ],
      },
    ),
    MotivationExercise(
      id: 'cbt_perspective',
      title: 'Bakış Açısı',
      description: 'Arkadaşın olsan ne derdin?',
      category: MotivationCategory.thinking,
      type: ExerciseType.perspective,
      durationSeconds: 90,
      data: {'question': 'Bir arkadaşın bu durumda olsa ona ne söylerdin?'},
    ),
    MotivationExercise(
      id: 'cbt_worst_case',
      title: 'En Kötü Senaryo',
      description: 'Gerçekleşse başa çıkabilir misin?',
      category: MotivationCategory.thinking,
      type: ExerciseType.cbt,
      durationSeconds: 90,
      data: {'question': 'En kötü senaryo gerçekleşse ne yapardın?'},
    ),
    MotivationExercise(
      id: 'cbt_evidence',
      title: 'Delil Ara',
      description: 'Bu düşünceyi destekleyen kanıt ne?',
      category: MotivationCategory.thinking,
      type: ExerciseType.cbt,
      durationSeconds: 60,
      data: {'question': 'Bu düşüncenin doğru olduğuna dair somut kanıt var mı?'},
    ),
    MotivationExercise(
      id: 'cbt_alternative',
      title: 'Alternatif Düşünce',
      description: 'Başka nasıl bakabilirsin?',
      category: MotivationCategory.thinking,
      type: ExerciseType.perspective,
      durationSeconds: 60,
      data: {'question': 'Bu duruma başka nasıl bakabilirsin?'},
    ),
    MotivationExercise(
      id: 'cbt_future',
      title: 'Gelecek Perspektifi',
      description: '1 yıl sonra önemli olacak mı?',
      category: MotivationCategory.thinking,
      type: ExerciseType.perspective,
      durationSeconds: 45,
      data: {'question': 'Bu konu 1 yıl sonra hala önemli olacak mı?'},
    ),
    MotivationExercise(
      id: 'cbt_control',
      title: 'Kontrol Çemberi',
      description: 'Kontrolünde olan ne?',
      category: MotivationCategory.thinking,
      type: ExerciseType.cbt,
      durationSeconds: 90,
      data: {'question': 'Bu durumda senin kontrolünde olan ne var?'},
    ),
    MotivationExercise(
      id: 'cbt_small_step',
      title: 'En Küçük Adım',
      description: 'Şimdi atabileceğin en küçük adım?',
      category: MotivationCategory.thinking,
      type: ExerciseType.microGoal,
      durationSeconds: 45,
      data: {'question': 'Şu an atabileceğin en küçük adım ne?'},
    ),
    MotivationExercise(
      id: 'cbt_reframe',
      title: 'Yeniden Çerçevele',
      description: 'Fırsat olarak görsen?',
      category: MotivationCategory.thinking,
      type: ExerciseType.perspective,
      durationSeconds: 60,
      data: {'question': 'Bu zorlukta gizli bir fırsat olabilir mi?'},
    ),
    MotivationExercise(
      id: 'cbt_self_compassion',
      title: 'Öz Şefkat',
      description: 'Kendine nazik ol',
      category: MotivationCategory.thinking,
      type: ExerciseType.cbt,
      durationSeconds: 60,
      data: {'question': 'Şu an kendine nazik davranabileceğin bir şey var mı?'},
    ),
  ];
  
  // ═══════════════════════════════════════════════════════════════
  // MOTİVASYON KATEGORİSİ (8 içerik)
  // ═══════════════════════════════════════════════════════════════
  static const List<MotivationExercise> motivationExercises = [
    MotivationExercise(
      id: 'goal_micro',
      title: 'Mikro Hedef',
      description: '5 dakikada tamamlanabilecek bir şey',
      category: MotivationCategory.motivation,
      type: ExerciseType.microGoal,
      durationSeconds: 300,
      data: {'question': '5 dakikada tamamlayabileceğin küçük bir hedef ne?'},
    ),
    MotivationExercise(
      id: 'goal_why',
      title: 'Neden?',
      description: 'Bu görevi neden yapıyorsun?',
      category: MotivationCategory.motivation,
      type: ExerciseType.perspective,
      durationSeconds: 60,
      data: {'question': 'Bu işi neden yapmak istiyorsun?'},
    ),
    MotivationExercise(
      id: 'goal_reward',
      title: 'Küçük Ödül',
      description: 'Tamamladıktan sonra kendine ne vaat ediyorsun?',
      category: MotivationCategory.motivation,
      type: ExerciseType.microGoal,
      durationSeconds: 30,
      data: {'question': 'Bu görevi tamamlayınca kendine ne ödül vereceksin?'},
    ),
    MotivationExercise(
      id: 'goal_2min',
      title: '2 Dakika Kuralı',
      description: '2 dakikadan kısa iş? Hemen yap.',
      category: MotivationCategory.motivation,
      type: ExerciseType.timer,
      durationSeconds: 120,
      data: {'instruction': '2 dakikada bitecek bir iş varsa şimdi yap.'},
    ),
    MotivationExercise(
      id: 'goal_start',
      title: 'Sadece Başla',
      description: 'Mükemmel olmak zorunda değil',
      category: MotivationCategory.motivation,
      type: ExerciseType.microGoal,
      durationSeconds: 60,
      data: {'instruction': 'Sadece ilk adımı at, mükemmel olması gerekmez.'},
    ),
    MotivationExercise(
      id: 'goal_done_list',
      title: 'Yapılanlar Listesi',
      description: 'Bugün ne başardın?',
      category: MotivationCategory.motivation,
      type: ExerciseType.gratitude,
      durationSeconds: 60,
      data: {'question': 'Bugün başardığın 3 şey ne?'},
    ),
    MotivationExercise(
      id: 'goal_next',
      title: 'Sıradaki Adım',
      description: 'Bir sonraki somut adım ne?',
      category: MotivationCategory.motivation,
      type: ExerciseType.microGoal,
      durationSeconds: 45,
      data: {'question': 'Hedefe yaklaşmak için sıradaki somut adım ne?'},
    ),
    MotivationExercise(
      id: 'goal_energy_match',
      title: 'Enerji Eşleştirme',
      description: 'Enerjine uygun iş seç',
      category: MotivationCategory.motivation,
      type: ExerciseType.microGoal,
      durationSeconds: 45,
      data: {'question': 'Şu anki enerjine uygun en iyi görev ne?'},
    ),
    // Yeni eklenen egzersizler
    MotivationExercise(
      id: 'goal_past_success',
      title: 'Geçmiş Başarı',
      description: 'Daha önce başardığın bir şeyi hatırla',
      category: MotivationCategory.motivation,
      type: ExerciseType.perspective,
      durationSeconds: 60,
      data: {'question': 'Zor görünüp de başardığın bir şey ne?'},
    ),
    MotivationExercise(
      id: 'goal_strength',
      title: 'Güçlü Yön',
      description: 'Neyde iyisin?',
      category: MotivationCategory.motivation,
      type: ExerciseType.perspective,
      durationSeconds: 45,
      data: {'question': 'Bugün kullanabileceğin en güçlü yönün ne?'},
    ),
    MotivationExercise(
      id: 'goal_visualize',
      title: 'Hedef Görselleştirme',
      description: 'Başarıyı hayal et',
      category: MotivationCategory.motivation,
      type: ExerciseType.meditation,
      durationSeconds: 60,
      data: {'instruction': 'Hedefine ulaştığında nasıl hissedeceğini hayal et.'},
    ),
    MotivationExercise(
      id: 'goal_24h_plan',
      title: '24 Saatlik Plan',
      description: 'Yarına kadar ne yapacaksın?',
      category: MotivationCategory.motivation,
      type: ExerciseType.microGoal,
      durationSeconds: 90,
      data: {'question': 'Önümüzdeki 24 saat için en önemli 3 şey ne?'},
    ),
    MotivationExercise(
      id: 'goal_self_message',
      title: 'Kendine Mesaj',
      description: 'Gelecekteki sana bir not',
      category: MotivationCategory.motivation,
      type: ExerciseType.perspective,
      durationSeconds: 60,
      data: {'question': 'Yarınki kendine ne söylemek istersin?'},
    ),
  ];
  
  // ═══════════════════════════════════════════════════════════════
  // DUYGUSAL FARKINDALIK KATEGORİSİ (8 içerik)
  // ═══════════════════════════════════════════════════════════════
  static const List<MotivationExercise> awarenessExercises = [
    MotivationExercise(
      id: 'aware_emotion',
      title: 'Duygu Tanıma',
      description: 'Şu an ne hissediyorsun?',
      category: MotivationCategory.awareness,
      type: ExerciseType.meditation,
      durationSeconds: 60,
      data: {'question': 'Şu an hissettiğin duyguya bir isim ver.'},
    ),
    MotivationExercise(
      id: 'aware_body',
      title: 'Bedensel Farkındalık',
      description: 'Vücudunda gerginlik nerede?',
      category: MotivationCategory.awareness,
      type: ExerciseType.bodyAwareness,
      durationSeconds: 60,
      data: {'question': 'Vücudunun hangi bölgesinde gerginlik hissediyorsun?'},
    ),
    MotivationExercise(
      id: 'aware_gratitude',
      title: 'Minnettarlık',
      description: 'Bugün neye minnettarsın?',
      category: MotivationCategory.awareness,
      type: ExerciseType.gratitude,
      durationSeconds: 60,
      data: {'question': 'Bugün minnettar olduğun bir şey ne?'},
    ),
    MotivationExercise(
      id: 'aware_kindness',
      title: 'Küçük İyilik',
      description: 'Bugün kendin için yapabileceğin küçük bir iyilik?',
      category: MotivationCategory.awareness,
      type: ExerciseType.microGoal,
      durationSeconds: 45,
      data: {'question': 'Bugün kendin için yapabileceğin küçük bir iyilik ne?'},
    ),
    MotivationExercise(
      id: 'aware_accept',
      title: 'Kabul Et',
      description: 'Bu duyguyu yargılama, sadece fark et',
      category: MotivationCategory.awareness,
      type: ExerciseType.meditation,
      durationSeconds: 60,
      data: {'instruction': 'Hissettiğin duyguyu yargılama. Sadece var olduğunu kabul et.'},
    ),
    MotivationExercise(
      id: 'aware_needs',
      title: 'İhtiyaç Kontrolü',
      description: 'Şu an neye ihtiyacın var?',
      category: MotivationCategory.awareness,
      type: ExerciseType.meditation,
      durationSeconds: 45,
      data: {'question': 'Şu an en çok neye ihtiyacın var?'},
    ),
    MotivationExercise(
      id: 'aware_present',
      title: 'Şu An',
      description: 'Şu an neredesin, ne yapıyorsun?',
      category: MotivationCategory.awareness,
      type: ExerciseType.grounding,
      durationSeconds: 45,
      data: {'instruction': 'Şu an nerede olduğunu ve ne yaptığını fark et.'},
    ),
    MotivationExercise(
      id: 'aware_breath_check',
      title: 'Nefes Kontrolü',
      description: 'Nefes alışını fark et',
      category: MotivationCategory.awareness,
      type: ExerciseType.breathing,
      durationSeconds: 30,
      data: {'instruction': 'Nefes alışını değiştirme, sadece fark et.'},
    ),
  ];
  
  // Tüm egzersizleri getir
  static List<MotivationExercise> getAllExercises() {
    return [
      ...relaxationExercises,
      ...energyExercises,
      ...focusExercises,
      ...thinkingExercises,
      ...motivationExercises,
      ...awarenessExercises,
    ];
  }
  
  // Kategoriye göre egzersiz getir
  static List<MotivationExercise> getByCategory(MotivationCategory category) {
    switch (category) {
      case MotivationCategory.relaxation:
        return relaxationExercises;
      case MotivationCategory.energy:
        return energyExercises;
      case MotivationCategory.focus:
        return focusExercises;
      case MotivationCategory.thinking:
        return thinkingExercises;
      case MotivationCategory.motivation:
        return motivationExercises;
      case MotivationCategory.awareness:
        return awarenessExercises;
    }
  }
  
  // Tip ve kategoriye göre rastgele egzersiz
  static MotivationExercise? getRandomByType(ExerciseType type, {List<String>? excludeIds}) {
    final allExercises = getAllExercises()
        .where((e) => e.type == type)
        .where((e) => !(excludeIds ?? []).contains(e.id))
        .toList();
    
    if (allExercises.isEmpty) return null;
    allExercises.shuffle();
    return allExercises.first;
  }
}
