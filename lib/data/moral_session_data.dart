import 'dart:math';

/// "Bugün Hangi Karakter Modundasın?" seansı veri havuzları
class KarakterModuData {
  static final _rng = Random();

  // ─── KART 2: GÜÇ SEÇENEKLERİ (her seansta 3 tanesi gösterilir) ───
  static const guçler = [
    {'emoji': '🧠', 'ad': 'Zihin Susturucu', 'açıklama': '30 dk sessizlik'},
    {'emoji': '🧲', 'ad': 'Şans Mıknatısı', 'açıklama': 'Minik şanslar'},
    {'emoji': '🛡️', 'ad': 'Drama Kalkanı', 'açıklama': 'Saçma şeyleri umursamaz'},
    {'emoji': '⏸️', 'ad': 'Duraklatıcı', 'açıklama': 'Zamanı yavaşlatır'},
    {'emoji': '🔋', 'ad': 'Sonsuz Enerji', 'açıklama': 'Yorgunluk nedir bilmez'},
    {'emoji': '🎯', 'ad': 'Odak Lazeri', 'açıklama': 'Dikkat dağılmaz'},
    {'emoji': '💎', 'ad': 'Özgüven Zırhı', 'açıklama': 'Herkes seni alkışlar'},
    {'emoji': '🌀', 'ad': 'Sakinlik Girdabı', 'açıklama': 'Stres yok olur'},
    {'emoji': '🦸', 'ad': 'Görünmezlik Pelerini', 'açıklama': 'İstediğin zaman kaybol'},
    {'emoji': '🎪', 'ad': 'Eğlence Bombası', 'açıklama': 'Her an komik olur'},
    {'emoji': '🌟', 'ad': 'Karizma Patlaması', 'açıklama': 'Herkes etkilenir'},
    {'emoji': '🧘', 'ad': 'İç Huzur Kalkanı', 'açıklama': 'Hiçbir şey dokunmaz'},
    {'emoji': '🚀', 'ad': 'Motivasyon Roketi', 'açıklama': 'Hemen harekete geçer'},
    {'emoji': '🎵', 'ad': 'Müzik Alanı', 'açıklama': 'Her yerde müzik çalar'},
    {'emoji': '🍀', 'ad': 'Mega Şans', 'açıklama': 'Bugün her şey yolunda'},
    {'emoji': '⚡', 'ad': 'Anlık Çözüm', 'açıklama': 'Her sorun 5 dk\'da çözülür'},
    {'emoji': '🫂', 'ad': 'Empati Gücü', 'açıklama': 'Herkesi anlarsın'},
    {'emoji': '🧃', 'ad': 'Çocukluk Enerjisi', 'açıklama': 'Her şey heyecanlı'},
    {'emoji': '🎭', 'ad': 'Mizah Ustası', 'açıklama': 'Her cümlen espri'},
    {'emoji': '💤', 'ad': 'Uyku Bankası', 'açıklama': '10 dk uyusan 8 saat etkisi'},
  ];

  // ─── KART 5: ABSÜRT SEÇİMLER (her seansta 1 tanesi gösterilir) ───
  static const absürtler = [
    {'a': 'Kahveyi soğutup içen sabır ustası ☕', 'b': 'Kahveyi unutup tekrar yapan hafıza sihirbazı 🧠'},
    {'a': 'Asansörde yabancıyla konuşan cesaret abidesi 🗣️', 'b': 'Merdivenlerden çıkan antisoyal kahraman 🏃'},
    {'a': 'Alarmı ilk çalışta kapatan disiplin tanrısı ⏰', 'b': '14 kez erteleten uyku ustası 😴'},
    {'a': 'Her şeyi listeleten organizasyon dehası 📝', 'b': 'Akışına bırakan kaos yöneticisi 🌊'},
    {'a': 'Son lokmasını paylaşan fedakâr savaşçı 🍕', 'b': 'Son lokmaya "benimdir" diyen sahip çıkıcı 🛡️'},
    {'a': 'Yağmurda dans eden romantik ruh 🌧️', 'b': 'Şemsiyesiz çıkmaya ASLA razı olmayan plancı ☂️'},
    {'a': 'Mesajı hemen cevaplayan güvenilir dost 💬', 'b': 'Mesajı görüp "sonra yazarım" diyen gizemli tip 👻'},
    {'a': 'Bulaşıkları hemen yıkayan ninja 🍽️', 'b': 'Lavaboda dağ oluşturan stratejist 🏔️'},
    {'a': 'Fotoğrafı ilk çekimde beğenen özgüvenli 📸', 'b': '47 selfie çekip hepsini silen mükemmeliyetçi 🤳'},
    {'a': 'Spoiler yiyen ve umursamayan zen ustası 🧘', 'b': 'Spoiler duyunca krize giren drama kralı/kraliçesi 😱'},
    {'a': 'Market listesiyle gidip sadece listedekileri alan robot 🤖', 'b': 'Listeye bakmadan 20 ürün alan maceracı 🛒'},
    {'a': 'Filmi sessizce izleyen saygılı seyirci 🎬', 'b': 'Her sahneye yorum yapan canlı anlatıcı 🎙️'},
    {'a': 'Ayakkabılarını düzgün dizen tertipli ruh 👟', 'b': 'Ayakkabıyı fırlatan özgür ruh 🦶'},
    {'a': 'GPS\'e güvenen modern gezgin 📍', 'b': '"Ben yolu bilirim" diyen maceracı kaybolmuş 🗺️'},
    {'a': 'Şarjı %100\'den çıkaran plancı 🔋', 'b': '%3\'le "yeter" diyen risk uzmanı ⚠️'},
    {'a': 'Yemeği tarifle yapan şef 👨‍🍳', 'b': '"Gözümden" yapan deney uzmanı 🧪'},
    {'a': 'Toplantıda not alan başarılı çalışan 📋', 'b': 'Toplantıda kafa sallayıp hiç dinlemeyen artist 🎭'},
    {'a': 'Tatili 3 ay önceden planlayan stratejist ✈️', 'b': '"Yarın gidelim" diyen spontane ruh 🎒'},
    {'a': 'Ütüsüz çıkmayan şık insan 👔', 'b': '"Üstüme oturunca düzelir" diyen pratik deha 🧠'},
    {'a': 'Kitabı bitirmeden yenisine başlamayan sadık okur 📖', 'b': '5 kitabı aynı anda okuyan multitasker 📚'},
    {'a': 'Erken yatıp erken kalkan sağlıklı birey 🌅', 'b': 'Gece 3\'te TikTok izleyen gece kuşu 🦉'},
    {'a': 'Buzdolabını organize tutan düzenli 🧊', 'b': 'Buzdolabında arkeoloji yapan kaşif 🔍'},
    {'a': 'Kışın kalın giyinen akıllı 🧥', 'b': '"Üşümem ben" diyen ve üşüyen inatçı 🥶'},
    {'a': 'Navigasyona "sağa dön" denince dönen kurallı 📱', 'b': '"Kestirmeden giderim" diyen ve kaybolmuş 🤷'},
    {'a': 'Çayı 3 dakika demleyen sabırlı 🍵', 'b': '"Olmuştur artık" diyen 30 saniyeci ⚡'},
    {'a': 'Parayla plan yapan ekonomist 💰', 'b': '"Para gelir gider" diyen filozof 🧘'},
    {'a': 'Düzenli spor yapan disiplinli 🏋️', 'b': 'Uzaktan kumandayı almayı spor sayan yaratıcı 📺'},
    {'a': 'Sabah duş alan enerjik 🚿', 'b': 'Akşam duş alan huzurlu 🌙'},
    {'a': 'WiFi şifresini ezbere bilen teknolojik 📶', 'b': '"Şifre ne?" diye her seferinde soran unutkan 🤔'},
    {'a': 'Düğün davetini hemen cevaplayan sorumluluk sahibi 💌', 'b': 'Son gün "gelirim herhalde" diyen spontane 🎉'},
  ];

  // ─── KART 7: KARAKTER SONUÇLARI ───
  static const karakterler = [
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

  // ─── KART 3 SONUÇ CÜMLELERİ (seçime göre) ───
  static const sonuçCümleleri = {
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

  // ─── KART 4: MİKRO GÖREVLER (her seansta 1 tanesi) ───
  static const görevler = [
    {'başlık': 'Gülümseme Hilesi', 'metin': '10 saniye sahte gülümse, sonra gerçek gülümse.', 'süre': 10},
    {'başlık': 'Nefes Sihirbazı', 'metin': '4 sn nefes al, 4 sn tut, 4 sn ver.', 'süre': 12},
    {'başlık': 'Omuz Silkeleme', 'metin': 'Omuzlarını kulaklarına çek, 5 sn tut, bırak. 3 kez tekrarla.', 'süre': 15},
    {'başlık': 'Mini Dans', 'metin': 'Yerinde 10 saniye dans et. Kimse görmüyor!', 'süre': 10},
    {'başlık': 'Güç Pozu', 'metin': 'Superman pozu yap, 15 sn tut. Ciddi ciddi.', 'süre': 15},
  ];

  // ─── YARDIMCI METODLAR ───
  static List<Map<String, dynamic>> rastgeleGüçler(int adet) {
    final kopya = List<Map<String, dynamic>>.from(guçler);
    kopya.shuffle(_rng);
    return kopya.take(adet).toList();
  }

  static Map<String, dynamic> rastgeleAbsürt() {
    return absürtler[_rng.nextInt(absürtler.length)];
  }

  static Map<String, dynamic> rastgeleKarakter() {
    return karakterler[_rng.nextInt(karakterler.length)];
  }

  static Map<String, dynamic> rastgeleGörev() {
    return görevler[_rng.nextInt(görevler.length)];
  }

  static String rastgeleSonuçCümlesi(String kategori) {
    final liste = sonuçCümleleri[kategori] ?? sonuçCümleleri['kafa']!;
    return liste[_rng.nextInt(liste.length)];
  }
}
