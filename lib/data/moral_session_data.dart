import 'dart:math';

/// "Bugun Hangi Karakter Modundasin?" seans veri havuzlari
class KarakterModuData {
  static final _rng = Random();

  // --- KART 2: GUC SECENEKLERI (her seansta 3 tanesi) ---
  static const powers = [
    {'emoji': '🧠', 'ad': 'Zihin Susturucu', 'desc': '30 dk sessizlik'},
    {'emoji': '🧲', 'ad': 'Şans Mıknatısı', 'desc': 'Minik şanslar'},
    {'emoji': '🛡️', 'ad': 'Drama Kalkanı', 'desc': 'Saçma şeyleri umursamaz'},
    {'emoji': '⏸️', 'ad': 'Duraklatıcı', 'desc': 'Zamanı yavaşlatır'},
    {'emoji': '🔋', 'ad': 'Sonsuz Enerji', 'desc': 'Yorgunluk nedir bilmez'},
    {'emoji': '🎯', 'ad': 'Odak Lazeri', 'desc': 'Dikkat dağılmaz'},
    {'emoji': '💎', 'ad': 'Özgüven Zırhı', 'desc': 'Herkes seni alkışlar'},
    {'emoji': '🌀', 'ad': 'Sakinlik Girdabı', 'desc': 'Stres yok olur'},
    {'emoji': '🦸', 'ad': 'Görünmezlik Pelerini', 'desc': 'İstediğin zaman kaybol'},
    {'emoji': '🎪', 'ad': 'Eğlence Bombası', 'desc': 'Her an komik olur'},
    {'emoji': '🌟', 'ad': 'Karizma Patlaması', 'desc': 'Herkes etkilenir'},
    {'emoji': '🧘', 'ad': 'İç Huzur Kalkanı', 'desc': 'Hiçbir şey dokunmaz'},
    {'emoji': '🚀', 'ad': 'Motivasyon Roketi', 'desc': 'Hemen harekete geçer'},
    {'emoji': '🎵', 'ad': 'Müzik Alanı', 'desc': 'Her yerde müzik çalar'},
    {'emoji': '🍀', 'ad': 'Mega Şans', 'desc': 'Bugün her şey yolunda'},
    {'emoji': '⚡', 'ad': 'Anlık Çözüm', 'desc': 'Her sorun 5 dk\'da çözülür'},
    {'emoji': '🫂', 'ad': 'Empati Gücü', 'desc': 'Herkesi anlarsın'},
    {'emoji': '🧃', 'ad': 'Çocukluk Enerjisi', 'desc': 'Her şey heyecanlı'},
    {'emoji': '🎭', 'ad': 'Mizah Ustası', 'desc': 'Her cümlen espri'},
    {'emoji': '💤', 'ad': 'Uyku Bankası', 'desc': '10 dk uyusan 8 saat etkisi'},
  ];

  // --- KART 5: ABSURT SECIMLER ---
  static const absurds = [
    {'a': 'Kahveyi soğutup içen sabır ustası ☕', 'b': 'Kahveyi unutup tekrar yapan hafıza sihirbazı 🧠'},
    {'a': 'Asansörde yabancıyla konuşan cesaret abidesi 🗣️', 'b': 'Merdivenlerden çıkan antisoyal kahraman 🏃'},
    {'a': 'Alarmı ilk çalışta kapatan disiplin tanrısı ⏰', 'b': '14 kez erteleten uyku ustası 😴'},
    {'a': 'Her şeyi listeleten organizasyon dehası 📝', 'b': 'Akışına bırakan kaos yöneticisi 🌊'},
    {'a': 'Son lokmasını paylaşan fedakâr savaşçı 🍕', 'b': 'Son lokmaya "benimdir" diyen sahip çıkıcı 🛡️'},
    {'a': 'Yağmurda dans eden romantik ruh 🌧️', 'b': 'Şemsiyesiz çıkmaya ASLA razı olmayan plancı ☂️'},
    {'a': 'Mesajı hemen cevaplayan güvenilir dost 💬', 'b': 'Mesajı görüp "sonra yazarım" diyen gizemli tip 👻'},
    {'a': 'Bulaşıkları hemen yıkayan ninja 🍽️', 'b': 'Lavaboda dağ oluşturan stratejist 🏔️'},
    {'a': 'Fotoğrafı ilk çekimde beğenen özgüvenli 📸', 'b': '47 selfie çekip hepsini silen mükemmeliyetçi 🤳'},
    {'a': 'Spoiler yiyen ve umursamayan zen ustası 🧘', 'b': 'Spoiler duyunca krize giren drama kralı 😱'},
    {'a': 'Listesiyle gidip sadece listedekileri alan robot 🤖', 'b': 'Listeye bakmadan 20 ürün alan maceracı 🛒'},
    {'a': 'Filmi sessizce izleyen saygılı seyirci 🎬', 'b': 'Her sahneye yorum yapan canlı anlatıcı 🎙️'},
    {'a': 'Ayakkabılarını düzgün dizen tertipli ruh 👟', 'b': 'Ayakkabıyı fırlatan özgür ruh 🦶'},
    {'a': 'GPS\'e güvenen modern gezgin 📍', 'b': '"Ben yolu bilirim" diyen kaybolmuş maceracı 🗺️'},
    {'a': 'Şarjı %100\'den çıkaran plancı 🔋', 'b': '%3 ile "yeter" diyen risk uzmanı ⚠️'},
    {'a': 'Yemeği tarifle yapan şef 👨‍🍳', 'b': '"Gözümden" yapan deney uzmanı 🧪'},
    {'a': 'Toplantıda not alan başarılı çalışan 📋', 'b': 'Toplantıda kafa sallayıp hiç dinlemeyen artist 🎭'},
    {'a': 'Tatili 3 ay önceden planlayan stratejist ✈️', 'b': '"Yarın gidelim" diyen spontane ruh 🎒'},
    {'a': 'Ütüsüz çıkmayan şık insan 👔', 'b': '"Üstüme oturunca düzelir" diyen pratik deha 🧠'},
    {'a': 'Kitabı bitirmeden yenisine başlamayan sadık okur 📖', 'b': '5 kitabı aynı anda okuyan multitasker 📚'},
    {'a': 'Erken yatıp erken kalkan sağlıklı birey 🌅', 'b': 'Gece 3\'te TikTok izleyen gece kuşu 🦉'},
    {'a': 'Buzdolabını organize tutan düzenli 🧊', 'b': 'Buzdolabında arkeoloji yapan kaşif 🔍'},
    {'a': 'Kışın kalın giyinen akıllı 🧥', 'b': '"Üşümem ben" diyen ve üşüyen inatçı 🥶'},
    {'a': 'Çayı 3 dakika demleyen sabırlı 🍵', 'b': '"Olmuştur artık" diyen 30 saniyeci ⚡'},
    {'a': 'Parayla plan yapan ekonomist 💰', 'b': '"Para gelir gider" diyen filozof 🧘'},
    {'a': 'Düzenli spor yapan disiplinli 🏋️', 'b': 'Kumandayı almayı spor sayan yaratıcı 📺'},
    {'a': 'Sabah duş alan enerjik 🚿', 'b': 'Akşam duş alan huzurlu 🌙'},
    {'a': 'WiFi şifresini ezbere bilen teknolojik 📶', 'b': '"Şifre ne?" diye her seferinde soran unutkan 🤔'},
    {'a': 'Düğün davetini hemen cevaplayan sorumluluk sahibi 💌', 'b': 'Son gün "gelirim herhalde" diyen spontane 🎉'},
    {'a': 'Navigasyona "sağa dön" denince dönen kurallı 📱', 'b': '"Kestirmeden giderim" diyen kaybolmuş 🤷'},
  ];

  // --- KART 7: KARAKTER SONUCLARI ---
  static const characters = [
    {'ad': 'Tatlı Kaos Yöneticisi', 'emoji': '😄'},
    {'ad': 'Sabır Ninja\'sı', 'emoji': '🥷'},
    {'ad': 'Drama Kalkanlı Kahraman', 'emoji': '🛡️'},
    {'ad': 'Sessiz Fırtına', 'emoji': '🌪️'},
    {'ad': 'Pozitif Enerji Bombası', 'emoji': '💥'},
    {'ad': 'Gizli Deha', 'emoji': '🧠'},
    {'ad': 'Rahat Kaptan', 'emoji': '⛵'},
    {'ad': 'Stratejik Tembel', 'emoji': '🦥'},
    {'ad': 'Duygusal Tank', 'emoji': '🪖'},
    {'ad': 'Güler Yüzlü Savaşçı', 'emoji': '😊'},
    {'ad': 'Kahve Enerjili Robot', 'emoji': '🤖'},
    {'ad': 'Hayalperest Aksiyon Kahramanı', 'emoji': '🦸'},
    {'ad': 'Sakin Kasırga', 'emoji': '🌀'},
    {'ad': 'Mini Mutluluk Avcısı', 'emoji': '🎯'},
    {'ad': 'Spontane Stratejist', 'emoji': '🎲'},
    {'ad': 'Gece Kuşu Savaşçısı', 'emoji': '🦉'},
    {'ad': 'Empati Şampiyonu', 'emoji': '🫂'},
    {'ad': 'Mizah Tankı', 'emoji': '😂'},
    {'ad': 'Pratik Çözüm Makinesi', 'emoji': '⚙️'},
    {'ad': 'Rüzgâr Gibi Geçen', 'emoji': '💨'},
  ];

  // --- KART 3: SONUC CUMLELERI ---
  static const resultMessages = {
    'insanlar': [
      'Bugün sınır koymak = süper güç.',
      'Herkesi mutlu etmek senin işin değil.',
      'Bazen en iyi iletişim, sessizliktir.',
    ],
    'para': [
      'Küçük adımlar, büyük değişimler yaratır.',
      'Bugün endişe yerine 1 aksiyon al.',
      'Para gelir gider, sen kalırsın.',
    ],
    'yorgunluk': [
      'Azıcık toparlan, kalanını yarına bırak.',
      'Dinlenmek de üretkenlik.',
      'Bugün az yap ama kendine iyi bak.',
    ],
    'kafa': [
      'Düşünce spam\'ini kapat: tek adıma dön.',
      'Kafan karışıksa, en basit şeyle başla.',
      'Her şeyi çözmek zorunda değilsin.',
    ],
  };

  // --- KART 4: MIKRO GOREVLER ---
  static const tasks = [
    {'title': 'Gülümseme Hilesi', 'body': '10 saniye sahte gülümse, sonra gerçek gülümse.', 'secs': 10},
    {'title': 'Nefes Sihirbazı', 'body': '4 sn nefes al, 4 sn tut, 4 sn ver.', 'secs': 12},
    {'title': 'Omuz Silkeleme', 'body': 'Omuzlarını kulaklarına çek, 5 sn tut, bırak. 3 kez tekrarla.', 'secs': 15},
    {'title': 'Mini Dans', 'body': 'Yerinde 10 saniye dans et. Kimse görmüyor!', 'secs': 10},
    {'title': 'Güç Pozu', 'body': 'Superman pozu yap, 15 sn tut. Ciddi ciddi.', 'secs': 15},
  ];

  // --- HELPERS ---
  static List<Map<String, dynamic>> getRandomPowers(int count) {
    final copy = List<Map<String, dynamic>>.from(powers);
    copy.shuffle(_rng);
    return copy.take(count).toList();
  }

  static Map<String, dynamic> getRandomAbsurd() {
    return absurds[_rng.nextInt(absurds.length)];
  }

  static Map<String, dynamic> getRandomCharacter() {
    return characters[_rng.nextInt(characters.length)];
  }

  static Map<String, dynamic> getRandomTask() {
    return tasks[_rng.nextInt(tasks.length)];
  }

  static String getResultMessage(String category) {
    final list = resultMessages[category] ?? resultMessages['kafa']!;
    return list[_rng.nextInt(list.length)];
  }
}
