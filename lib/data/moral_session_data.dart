import 'dart:math';

/// "BugÃ¼n Hangi Karakter ModundasÄ±n?" seansÄ± veri havuzlarÄ±
class KarakterModuData {
  static final _rng = Random();

  // âââ KART 2: GÃÃ SEÃENEKLERÄ° (her seansta 3 tanesi gÃ¶sterilir) âââ
  static const guÃ§ler = [
    {'emoji': 'ðð§ ', 'ad': 'Zihin Susturucu', 'aÃ§Ä±klama': '30 dk sessizlik'},
    {'emoji': 'ðð§²', 'ad': 'Åans MÄ±knatÄ±sÄ±', 'aÃ§Ä±klama': 'Minik Åanslar'},
    {'emoji': 'ðð¡ï¸', 'ad': 'Drama KalkanÄ±', 'aÃ§Ä±klama': 'SaÃ§ma Åeyleri umursamaz'},
    {'emoji': 'â¸ï¸', 'ad': 'DuraklatÄ±cÄ±', 'aÃ§Ä±klama': 'ZamanÄ± yavaÅlatÄ±r'},
    {'emoji': 'ðð', 'ad': 'Sonsuz Enerji', 'aÃ§Ä±klama': 'Yorgunluk nedir bilmez'},
    {'emoji': 'ðð¯', 'ad': 'Odak Lazeri', 'aÃ§Ä±klama': 'Dikkat daÄÄ±lmaz'},
    {'emoji': 'ðð', 'ad': 'ÃzgÃ¼ven ZÄ±rhÄ±', 'aÃ§Ä±klama': 'Herkes seni alkÄ±Ålar'},
    {'emoji': 'ðð', 'ad': 'Sakinlik GirdabÄ±', 'aÃ§Ä±klama': 'Stres yok olur'},
    {'emoji': 'ðð¦¸', 'ad': 'GÃ¶rÃ¼nmezlik Pelerini', 'aÃ§Ä±klama': 'Ä°stediÄin zaman kaybol'},
    {'emoji': 'ððª', 'ad': 'EÄlence BombasÄ±', 'aÃ§Ä±klama': 'Her an komik olur'},
    {'emoji': 'ðð', 'ad': 'Karizma PatlamasÄ±', 'aÃ§Ä±klama': 'Herkes etkilenir'},
    {'emoji': 'ðð§', 'ad': 'Ä°Ã§ Huzur KalkanÄ±', 'aÃ§Ä±klama': 'HiÃ§bir Åey dokunmaz'},
    {'emoji': 'ðð', 'ad': 'Motivasyon Roketi', 'aÃ§Ä±klama': 'Hemen harekete geÃ§er'},
    {'emoji': 'ððµ', 'ad': 'MÃ¼zik AlanÄ±', 'aÃ§Ä±klama': 'Her yerde mÃ¼zik Ã§alar'},
    {'emoji': 'ðð', 'ad': 'Mega Åans', 'aÃ§Ä±klama': 'BugÃ¼n her Åey yolunda'},
    {'emoji': 'â¡', 'ad': 'AnlÄ±k ÃÃ¶zÃ¼m', 'aÃ§Ä±klama': 'Her sorun 5 dk\'da Ã§Ã¶zÃ¼lÃ¼r'},
    {'emoji': 'ðð«', 'ad': 'Empati GÃ¼cÃ¼', 'aÃ§Ä±klama': 'Herkesi anlarsÄ±n'},
    {'emoji': 'ðð§', 'ad': 'Ãocukluk Enerjisi', 'aÃ§Ä±klama': 'Her Åey heyecanlÄ±'},
    {'emoji': 'ðð­', 'ad': 'Mizah UstasÄ±', 'aÃ§Ä±klama': 'Her cÃ¼mlen espri'},
    {'emoji': 'ðð¤', 'ad': 'Uyku BankasÄ±', 'aÃ§Ä±klama': '10 dk uyusan 8 saat etkisi'},
  ];

  // âââ KART 5: ABSÃRT SEÃÄ°MLER (her seansta 1 tanesi gÃ¶sterilir) âââ
  static const absÃ¼rtler = [
    {'a': 'Kahveyi soÄutup iÃ§en sabÄ±r ustasÄ± â', 'b': 'Kahveyi unutup tekrar yapan hafÄ±za sihirbazÄ± ðð§ '},
    {'a': 'AsansÃ¶rde yabancÄ±yla konuÅan cesaret abidesi ðð£ï¸', 'b': 'Merdivenlerden Ã§Ä±kan antisoyal kahraman ðð'},
    {'a': 'AlarmÄ± ilk Ã§alÄ±Åta kapatan disiplin tanrÄ±sÄ± â°', 'b': '14 kez erteleten uyku ustasÄ± ðð´'},
    {'a': 'Her Åeyi listeleten organizasyon dehasÄ± ðð', 'b': 'AkÄ±ÅÄ±na bÄ±rakan kaos yÃ¶neticisi ðð'},
    {'a': 'Son lokmasÄ±nÄ± paylaÅan fedakÃ¢r savaÅÃ§Ä± ðð', 'b': 'Son lokmaya "benimdir" diyen sahip Ã§Ä±kÄ±cÄ± ðð¡ï¸'},
    {'a': 'YaÄmurda dans eden romantik ruh ðð§ï¸', 'b': 'Åemsiyesiz Ã§Ä±kmaya ASLA razÄ± olmayan plancÄ± âï¸'},
    {'a': 'MesajÄ± hemen cevaplayan gÃ¼venilir dost ðð¬', 'b': 'MesajÄ± gÃ¶rÃ¼p "sonra yazarÄ±m" diyen gizemli tip ðð»'},
    {'a': 'BulaÅÄ±klarÄ± hemen yÄ±kayan ninja ðð½ï¸', 'b': 'Lavaboda daÄ oluÅturan stratejist ððï¸'},
    {'a': 'FotoÄrafÄ± ilk Ã§ekimde beÄenen Ã¶zgÃ¼venli ðð¸', 'b': '47 selfie Ã§ekip hepsini silen mÃ¼kemmeliyetÃ§i ðð¤³'},
    {'a': 'Spoiler yiyen ve umursamayan zen ustasÄ± ðð§', 'b': 'Spoiler duyunca krize giren drama kralÄ±/kraliÃ§esi ðð±'},
    {'a': 'Market listesiyle gidip sadece listedekileri alan robot ðð¤', 'b': 'Listeye bakmadan 20 Ã¼rÃ¼n alan maceracÄ± ðð'},
    {'a': 'Filmi sessizce izleyen saygÄ±lÄ± seyirci ðð¬', 'b': 'Her sahneye yorum yapan canlÄ± anlatÄ±cÄ± ððï¸'},
    {'a': 'AyakkabÄ±larÄ±nÄ± dÃ¼zgÃ¼n dizen tertipli ruh ðð', 'b': 'AyakkabÄ±yÄ± fÄ±rlatan Ã¶zgÃ¼r ruh ðð¦¶'},
    {'a': 'GPS\'e gÃ¼venen modern gezgin ðð', 'b': '"Ben yolu bilirim" diyen maceracÄ± kaybolmuÅ ððºï¸'},
    {'a': 'ÅarjÄ± %100\'den Ã§Ä±karan plancÄ± ðð', 'b': '%3\'le "yeter" diyen risk uzmanÄ± â ï¸'},
    {'a': 'YemeÄi tarifle yapan Åef ðð¨âðð³', 'b': '"GÃ¶zÃ¼mden" yapan deney uzmanÄ± ðð§ª'},
    {'a': 'ToplantÄ±da not alan baÅarÄ±lÄ± Ã§alÄ±Åan ðð', 'b': 'ToplantÄ±da kafa sallayÄ±p hiÃ§ dinlemeyen artist ðð­'},
    {'a': 'Tatili 3 ay Ã¶nceden planlayan stratejist âï¸', 'b': '"YarÄ±n gidelim" diyen spontane ruh ðð'},
    {'a': 'ÃtÃ¼sÃ¼z Ã§Ä±kmayan ÅÄ±k insan ðð', 'b': '"ÃstÃ¼me oturunca dÃ¼zelir" diyen pratik deha ðð§ '},
    {'a': 'KitabÄ± bitirmeden yenisine baÅlamayan sadÄ±k okur ðð', 'b': '5 kitabÄ± aynÄ± anda okuyan multitasker ðð'},
    {'a': 'Erken yatÄ±p erken kalkan saÄlÄ±klÄ± birey ðð', 'b': 'Gece 3\'te TikTok izleyen gece kuÅu ðð¦'},
    {'a': 'BuzdolabÄ±nÄ± organize tutan dÃ¼zenli ðð§', 'b': 'BuzdolabÄ±nda arkeoloji yapan kaÅif ðð'},
    {'a': 'KÄ±ÅÄ±n kalÄ±n giyinen akÄ±llÄ± ðð§¥', 'b': '"ÃÅÃ¼mem ben" diyen ve Ã¼ÅÃ¼yen inatÃ§Ä± ðð¥¶'},
    {'a': 'Navigasyona "saÄa dÃ¶n" denince dÃ¶nen kurallÄ± ðð±', 'b': '"Kestirmeden giderim" diyen ve kaybolmuÅ ðð¤·'},
    {'a': 'ÃayÄ± 3 dakika demleyen sabÄ±rlÄ± ððµ', 'b': '"OlmuÅtur artÄ±k" diyen 30 saniyeci â¡'},
    {'a': 'Parayla plan yapan ekonomist ðð°', 'b': '"Para gelir gider" diyen filozof ðð§'},
    {'a': 'DÃ¼zenli spor yapan disiplinli ððï¸', 'b': 'Uzaktan kumandayÄ± almayÄ± spor sayan yaratÄ±cÄ± ððº'},
    {'a': 'Sabah duÅ alan enerjik ðð¿', 'b': 'AkÅam duÅ alan huzurlu ðð'},
    {'a': 'WiFi Åifresini ezbere bilen teknolojik ðð¶', 'b': '"Åifre ne?" diye her seferinde soran unutkan ðð¤'},
    {'a': 'DÃ¼ÄÃ¼n davetini hemen cevaplayan sorumluluk sahibi ðð', 'b': 'Son gÃ¼n "gelirim herhalde" diyen spontane ðð'},
  ];

  // âââ KART 7: KARAKTER SONUÃLARI âââ
  static const karakterler = [
    {'ad': 'TatlÄ± Kaos YÃ¶neticisi', 'emoji': 'ðð'},
    {'ad': 'SabÄ±r Ninja\'sÄ±', 'emoji': 'ðð¥·'},
    {'ad': 'Drama KalkanlÄ± Kahraman', 'emoji': 'ðð¡ï¸'},
    {'ad': 'Sessiz FÄ±rtÄ±na', 'emoji': 'ððªï¸'},
    {'ad': 'Pozitif Enerji BombasÄ±', 'emoji': 'ðð¥'},
    {'ad': 'Gizli Deha', 'emoji': 'ðð§ '},
    {'ad': 'Rahat Kaptan', 'emoji': 'âµ'},
    {'ad': 'Stratejik Tembel', 'emoji': 'ðð¦¥'},
    {'ad': 'Duygusal Tank', 'emoji': 'ððª'},
    {'ad': 'GÃ¼ler YÃ¼zlÃ¼ SavaÅÃ§Ä±', 'emoji': 'ðð'},
    {'ad': 'Kahve Enerjili Robot', 'emoji': 'ðð¤'},
    {'ad': 'Hayalperest Aksiyon KahramanÄ±', 'emoji': 'ðð¦¸'},
    {'ad': 'Sakin KasÄ±rga', 'emoji': 'ðð'},
    {'ad': 'Mini Mutluluk AvcÄ±sÄ±', 'emoji': 'ðð¯'},
    {'ad': 'Spontane Stratejist', 'emoji': 'ðð²'},
    {'ad': 'Gece KuÅu SavaÅÃ§Ä±sÄ±', 'emoji': 'ðð¦'},
    {'ad': 'Empati Åampiyonu', 'emoji': 'ðð«'},
    {'ad': 'Mizah TankÄ±', 'emoji': 'ðð'},
    {'ad': 'Pratik ÃÃ¶zÃ¼m Makinesi', 'emoji': 'âï¸'},
    {'ad': 'RÃ¼zgÃ¢r Gibi GeÃ§en', 'emoji': 'ðð¨'},
  ];

  // âââ KART 3 SONUÃ CÃMLELERÄ° (seÃ§ime gÃ¶re) âââ
  static const sonuÃ§CÃ¼mleleri = {
    'insanlar': [
      'BugÃ¼n sÄ±nÄ±r koymak = sÃ¼per gÃ¼Ã§.',
      'Herkesi mutlu etmek senin iÅin deÄil.',
      'Bazen en iyi iletiÅim, sessizliktir.',
    ],
    'para': [
      'KÃ¼Ã§Ã¼k adÄ±mlar, bÃ¼yÃ¼k deÄiÅimler yaratÄ±r.',
      'BugÃ¼n endiÅe yerine 1 aksiyon al.',
      'Para gelir gider, sen kalÄ±rsÄ±n.',
    ],
    'yorgunluk': [
      'AzÄ±cÄ±k toparlan, kalanÄ±nÄ± yarÄ±na bÄ±rak.',
      'Dinlenmek de Ã¼retkenlik.',
      'BugÃ¼n az yap ama kendine iyi bak.',
    ],
    'kafa': [
      'DÃ¼ÅÃ¼nce spam\'ini kapat: tek adÄ±ma dÃ¶n.',
      'Kafan karÄ±ÅÄ±ksa, en basit Åeyle baÅla.',
      'Her Åeyi Ã§Ã¶zmek zorunda deÄilsin.',
    ],
  };

  // âââ KART 4: MÄ°KRO GÃREVLER (her seansta 1 tanesi) âââ
  static const gÃ¶revler = [
    {'baÅlÄ±k': 'GÃ¼lÃ¼mseme Hilesi', 'metin': '10 saniye sahte gÃ¼lÃ¼mse, sonra gerÃ§ek gÃ¼lÃ¼mse.', 'sÃ¼re': 10},
    {'baÅlÄ±k': 'Nefes SihirbazÄ±', 'metin': '4 sn nefes al, 4 sn tut, 4 sn ver.', 'sÃ¼re': 12},
    {'baÅlÄ±k': 'Omuz Silkeleme', 'metin': 'OmuzlarÄ±nÄ± kulaklarÄ±na Ã§ek, 5 sn tut, bÄ±rak. 3 kez tekrarla.', 'sÃ¼re': 15},
    {'baÅlÄ±k': 'Mini Dans', 'metin': 'Yerinde 10 saniye dans et. Kimse gÃ¶rmÃ¼yor!', 'sÃ¼re': 10},
    {'baÅlÄ±k': 'GÃ¼Ã§ Pozu', 'metin': 'Superman pozu yap, 15 sn tut. Ciddi ciddi.', 'sÃ¼re': 15},
  ];

  // âââ YARDIMCI METODLAR âââ
  static List<Map<String, dynamic>> rastgeleGÃ¼Ã§ler(int adet) {
    final kopya = List<Map<String, dynamic>>.from(guÃ§ler);
    kopya.shuffle(_rng);
    return kopya.take(adet).toList();
  }

  static Map<String, dynamic> rastgeleAbsÃ¼rt() {
    return absÃ¼rtler[_rng.nextInt(absÃ¼rtler.length)];
  }

  static Map<String, dynamic> rastgeleKarakter() {
    return karakterler[_rng.nextInt(karakterler.length)];
  }

  static Map<String, dynamic> rastgeleGÃ¶rev() {
    return gÃ¶revler[_rng.nextInt(gÃ¶revler.length)];
  }

  static String rastgeleSonuÃ§CÃ¼mlesi(String kategori) {
    final liste = sonuÃ§CÃ¼mleleri[kategori] ?? sonuÃ§CÃ¼mleleri['kafa']!;
    return liste[_rng.nextInt(liste.length)];
  }
}
