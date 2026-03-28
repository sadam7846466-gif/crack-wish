import 'dart:ui' show Color;

/// Asya Astrolojisi - Kapsamlı Veri Modeli
/// 12 Hayvan, 5 Element, Yin-Yang, Kariyer, Evlilik, Feng Shui, İsimlendirme

class ChineseZodiacData {
  // ── 2026 = At Yılı (Ateş) ──
  static const int currentYearAnimalIndex = 6; // At
  static const String currentYearElement = 'Ateş';
  static const String currentYear = '2026';

  /// Doğum yılından burç indeksi hesapla
  static int animalIndexFromYear(int year) {
    // Çin takvimine göre: Sıçan=0, Öküz=1, ... , Domuz=11
    // 2020 Sıçan yılıydı → (year - 2020) % 12
    return ((year - 2020) % 12 + 12) % 12;
  }

  /// Doğum yılından element hesapla (10 yıllık döngü, 2'şerli)
  static String elementFromYear(int year) {
    final idx = ((year - 4) % 10) ~/ 2;
    return ['Ağaç', 'Ateş', 'Toprak', 'Metal', 'Su'][idx];
  }

  /// Yin/Yang hesapla (çift yıl=Yang, tek=Yin)
  static String yinYangFromYear(int year) => year % 2 == 0 ? 'Yang' : 'Yin';

  // ── 12 HAYVAN VERİTABANI ──
  static const List<Map<String, dynamic>> animals = [
    {
      'emoji': '🐀', 'name': 'Sıçan', 'nameEn': 'Rat', 'nameCn': '鼠',
      'years': '1924, 1936, 1948, 1960, 1972, 1984, 1996, 2008, 2020',
      'fixedElement': 'Su', 'fixedYinYang': 'Yang',
      'traits': ['Zeki', 'Çevik', 'Becerikli', 'Çalışkan', 'Kurnaz'],
      'strengths': ['Keskin zekâ', 'Çabuk uyum', 'Stratejik düşünce', 'Sosyal beceri', 'Fırsatçı göz'],
      'weaknesses': ['Aşırı hesapçı', 'Kurnazlık', 'Güvensizlik', 'Stres eğilimi'],
      'personality': 'Sıçan ruhunu taşıyanlar, evrenin en keskin gözlemcileridir. Başkalarının göremediği fırsatları sezinler, karanlıkta bile yolunu bulan bir iç pusulaya sahiptirler. Zekâları yalnızca analitik değil — sezgisel bir derinlik taşır. Bir odaya girdiklerinde enerjiyi okur, insanların söylemediklerini duyar ve zamanın ruhunu yakalarlar. Bu güç onları sessiz ama sarsılmaz liderler yapar.',
      'love': 'Aşkta duygusal ve sadık. Partneri için fedakarlık yapar ama duygularını göstermekte zorlanır.',
      'bestMatch': [4, 8], // Ejderha, Maymun
      'goodMatch': [1, 6], // Öküz, At  
      'conflict': [6, 3], // At, Tavşan
      'careers': ['Finans Uzmanı', 'Girişimci', 'Muhasebeci', 'Avukat', 'Yazar'],
      'careerAdvice': 'Karanlıkta bile yolunu bulan gözleriniz, sayıların arasında altın madeni keşfeder. Sezgilerinizi stratejiye dönüştürdüğünüzde, başkalarının göremediği kapılar size açılır.',
      'luckyNumbers': [2, 3], 'luckyColors': ['Mavi', 'Altın', 'Yeşil'],
      'luckyDirections': ['Güney', 'Güneydoğu'],
      'unluckyNumbers': [5, 9], 'unluckyColors': ['Sarı', 'Kahverengi'],
      'fengShui': {'renk': 'Mavi ve yeşil tonları', 'yön': 'Güney & Güneydoğu', 'malzeme': 'Cam ve su öğeleri', 'tavsiye': 'Evin güney tarafına küçük bir su çeşmesi veya akvaryum koyun. Mavi tonlarda aksesuar kullanın.'},
      'timingAdvice': {'isKurma': 4, 'yatirim': 5, 'evlenme': 3, 'cocuk': 4, 'seyahat': 5, 'tasima': 3},
      'childNames': {'erkek': ['Deniz', 'Baran', 'Doruk', 'Çınar'], 'kiz': ['Su', 'Derya', 'Nehir', 'Damla']},
    },
    {
      'emoji': '🐂', 'name': 'Öküz', 'nameEn': 'Ox', 'nameCn': '牛',
      'years': '1925, 1937, 1949, 1961, 1973, 1985, 1997, 2009, 2021',
      'fixedElement': 'Toprak', 'fixedYinYang': 'Yin',
      'traits': ['Güvenilir', 'Sabırlı', 'Güçlü', 'Kararlı', 'Sadık'],
      'strengths': ['Sarsılmaz irade', 'Dayanıklılık', 'Güvenilirlik', 'Çalışkanlık', 'Pratik zekâ'],
      'weaknesses': ['İnatçılık', 'Değişime direnç', 'Duygusal kapalılık', 'Aşırı geleneksellik'],
      'personality': 'Öküz ruhunu taşıyanlar, zamanın kendisiyle yarışmayan bilge ruhlardır. Onlar için hayat bir sprint değil, bir maratondur — ve her adımı bilinçle atarlar. Toprak gibi sağlam, dağ gibi heybetli duruşları, etraflarındaki insanlara derin bir güven verir. Sözleri azdır ama her biri altın değerindedir. Fırtınalar geçer, modalar değişir — ama Öküz ruhunun inşa ettiği temeller sonsuza kadar ayakta kalır.',
      'love': 'Aşkta sadık ve güvenilir. Uzun vadeli ilişkilere değer verir. Duygularını göstermekte ağır kalır ama sevgisi derindir.',
      'bestMatch': [5, 9], // Yılan, Horoz
      'goodMatch': [0, 3], // Sıçan, Tavşan
      'conflict': [6, 7], // At, Keçi
      'careers': ['Mühendis', 'Çiftçi', 'Bankacı', 'Mimar', 'Cerrah'],
      'careerAdvice': 'Sabırla inşa ettiğiniz her yapı, zamanın testini geçer. Sizin eliniz değdiğinde kaos düzene, hayal gerçeğe dönüşür. Büyük eserler acele etmeyenleri bekler.',
      'luckyNumbers': [1, 4], 'luckyColors': ['Beyaz', 'Sarı', 'Yeşil'],
      'luckyDirections': ['Kuzey', 'Güney'],
      'unluckyNumbers': [5, 6], 'unluckyColors': ['Mavi'],
      'fengShui': {'renk': 'Toprak tonları, bej, krem', 'yön': 'Kuzey & Güney', 'malzeme': 'Doğal taş ve ahşap', 'tavsiye': 'Evinizde doğal malzemeler kullanın. Toprak saksılarda bitkiler yetiştirin. Sıcak tonlarda tekstil tercih edin.'},
      'timingAdvice': {'isKurma': 3, 'yatirim': 4, 'evlenme': 5, 'cocuk': 5, 'seyahat': 3, 'tasima': 4},
      'childNames': {'erkek': ['Kaya', 'Toprak', 'Dağhan', 'Alp'], 'kiz': ['Toprak', 'Yağmur', 'Kayra', 'Ela']},
    },
    {
      'emoji': '🐅', 'name': 'Kaplan', 'nameEn': 'Tiger', 'nameCn': '虎',
      'years': '1926, 1938, 1950, 1962, 1974, 1986, 1998, 2010, 2022',
      'fixedElement': 'Ağaç', 'fixedYinYang': 'Yang',
      'traits': ['Cesur', 'Tutkulu', 'Maceracı', 'Bağımsız', 'Karizmatik'],
      'strengths': ['Cesaret', 'Liderlik', 'Karizma', 'Adalet duygusu', 'Koruyuculuk'],
      'weaknesses': ['Saldırganlık', 'Sabırsızlık', 'Dikbaşlılık', 'Riskli kararlar'],
      'personality': 'Kaplan ruhunu taşıyanlar, içlerinde uykuya dalmış bir volkan barındırır. Sakin görünürler ama gözlerinin ardında fırtınalar kopar. Adalet duyguları pusula gibi nettir — haksızlık gördüklerinde sessiz kalamazlar. Kalabalıklarda bile yalnız durabilecek cesarete sahiptirler. Bir Kaplanın sadakati nadirdir ama kazanıldığında — ölümsüzdür. Onlar doğanın aristokratlarıdır; kükremedikleri zamanlarda bile varlıkları hissedilir.',
      'love': 'Aşkta tutkulu ve koruyucu. Partnerini bir kraliçe/kral gibi korur. Bağımsızlığına düşkündür.',
      'bestMatch': [6, 10], // At, Köpek
      'goodMatch': [4, 8], // Ejderha, Maymun
      'conflict': [8, 5], // Maymun, Yılan
      'careers': ['Asker', 'Komutan', 'CEO', 'Sporcu', 'Gazeteci'],
      'careerAdvice': 'Kükremenize gerek yok — varlığınız yeter. Cesaretiniz sizi tahtlara oturtur, adalet duygunuz ise orada tutar. Liderlik sizin için bir görev değil, doğanızdır.',
      'luckyNumbers': [1, 3, 4], 'luckyColors': ['Mavi', 'Gri', 'Turuncu'],
      'luckyDirections': ['Doğu', 'Kuzey'],
      'unluckyNumbers': [6, 7, 8], 'unluckyColors': ['Kahverengi'],
      'fengShui': {'renk': 'Yeşil ve mavi tonları', 'yön': 'Doğu & Kuzey', 'malzeme': 'Ahşap ve bambu', 'tavsiye': 'Evinize bol yeşil bitki ekleyin. Ahşap mobilyalar ve bambu dekorasyon kullanın. Doğu yönüne çalışma masası koyun.'},
      'timingAdvice': {'isKurma': 5, 'yatirim': 4, 'evlenme': 3, 'cocuk': 4, 'seyahat': 5, 'tasima': 4},
      'childNames': {'erkek': ['Arda', 'Orman', 'Çınar', 'Barış'], 'kiz': ['Yaprak', 'Çiçek', 'Bahar', 'Irmak']},
    },
    {
      'emoji': '🐇', 'name': 'Tavşan', 'nameEn': 'Rabbit', 'nameCn': '兔',
      'years': '1927, 1939, 1951, 1963, 1975, 1987, 1999, 2011, 2023',
      'fixedElement': 'Ağaç', 'fixedYinYang': 'Yin',
      'traits': ['Zarif', 'Nazik', 'Barışçıl', 'Duyarlı', 'Sanatsal'],
      'strengths': ['Zarafet', 'Diplomasi', 'Sezgi gücü', 'Sanatsal yetenek', 'Empati'],
      'weaknesses': ['Aşırı hassasiyet', 'Kaçınmacılık', 'Kararsızlık', 'Çekingenlik'],
      'personality': 'Tavşan ruhunu taşıyanlar, evrenin en hassas antenlerine sahiptir. Bir odanın enerjisini, bir bakışın ardındaki duyguyu, söylenmemiş kelimeleri algılarlar. Zerafetleri yüzeysel değil — ruhlarının derinliklerinden gelen bir uyumdur. Kaosun ortasında bile iç huzurlarını koruyabilirler. Sanatı, güzelliği ve inceliği sadece takdir etmezler — onlar bu kavramları yaşarlar. Sessiz güçleri, fırtınayı bile sakinleştirme yeteneğindedir.',
      'love': 'Aşkta romantik ve zarif. Uyumlu ve huzurlu ilişkiler arar. Çatışmadan kaçınır.',
      'bestMatch': [7, 11], // Keçi, Domuz
      'goodMatch': [1, 10], // Öküz, Köpek
      'conflict': [9, 0], // Horoz, Sıçan
      'careers': ['Sanatçı', 'Diplomat', 'Psikolog', 'Tasarımcı', 'Müzisyen'],
      'careerAdvice': 'Dünyanın gürültüsünde bile şiir duyarsınız. İnceliğiniz bir süper güçtür — insanları, renkleri ve duyguları birbirine bağlayan görünmez ipliği siz dokursunuz.',
      'luckyNumbers': [3, 4, 6], 'luckyColors': ['Pembe', 'Mor', 'Kırmızı'],
      'luckyDirections': ['Doğu', 'Güney'],
      'unluckyNumbers': [1, 7, 8], 'unluckyColors': ['Koyu Kahve'],
      'fengShui': {'renk': 'Pastel yeşil ve pembe', 'yön': 'Doğu & Güney', 'malzeme': 'İpek ve ahşap', 'tavsiye': 'Yumuşak aydınlatma ve zarif tekstiller kullanın. Doğu duvarına sanat eseri asın. Çiçekli desenler tercih edin.'},
      'timingAdvice': {'isKurma': 3, 'yatirim': 3, 'evlenme': 5, 'cocuk': 5, 'seyahat': 4, 'tasima': 4},
      'childNames': {'erkek': ['Barış', 'Ege', 'Poyraz', 'Umut'], 'kiz': ['Çiçek', 'Lale', 'Gül', 'İnci']},
    },
    {
      'emoji': '🐉', 'name': 'Ejderha', 'nameEn': 'Dragon', 'nameCn': '龙',
      'years': '1928, 1940, 1952, 1964, 1976, 1988, 2000, 2012, 2024',
      'fixedElement': 'Toprak', 'fixedYinYang': 'Yang',
      'traits': ['Güçlü', 'Asil', 'Enerjik', 'Karizmatik', 'Şanslı'],
      'strengths': ['Doğal karizma', 'Güç', 'Cesaret', 'Şans', 'Vizyon'],
      'weaknesses': ['Kibir', 'Sabırsızlık', 'Agresiflik', 'Otoriter tavır'],
      'personality': 'Ejderha ruhunu taşıyanlar, kaderin özel olarak işaretlediği ruhlardır. İçlerinde antik bir ateş yanar — hem yaratıcı hem dönüştürücü. Sıradan hayattan tatmin olmazlar çünkü ruhları büyüklük için kodlanmıştır. Bir Ejderhanın varlığı odayı doldurur, enerjisi bulaşıcıdır ve vizyonu çağının ötesindedir. Onlar kral yaratıcıları, imparatorluk kurucuları ve çağ değiştiricileridir.',
      'love': 'Aşkta tutkulu ve dominant. Güçlü bir partner ister. Sevgisini büyük jestlerle gösterir.',
      'bestMatch': [0, 8], // Sıçan, Maymun
      'goodMatch': [2, 9], // Kaplan, Horoz
      'conflict': [10, 1], // Köpek, Öküz
      'careers': ['Politikacı', 'CEO', 'Yatırımcı', 'Sanatçı', 'Lider'],
      'careerAdvice': 'İçinizdeki ateş, sıradan bir kariyer için çok büyük. Siz imparatorluklar kurmak, vizyonları gerçeğe dönüştürmek için varsınız. Büyük düşünün — çünkü evren sizinle aynı dilde konuşuyor.',
      'luckyNumbers': [1, 6, 7], 'luckyColors': ['Altın', 'Gümüş', 'Beyaz'],
      'luckyDirections': ['Doğu', 'Kuzey', 'Güney'],
      'unluckyNumbers': [3, 8], 'unluckyColors': ['Mavi'],
      'fengShui': {'renk': 'Kırmızı ve altın', 'yön': 'Doğu & Güney', 'malzeme': 'Kristal ve metal', 'tavsiye': 'Evinizin giriş kapısını kırmızı aksesuarlarla süsleyin. Kristal avize veya dekor nesneleri kullanın. Güçlü aydınlatma tercih edin.'},
      'timingAdvice': {'isKurma': 5, 'yatirim': 5, 'evlenme': 4, 'cocuk': 5, 'seyahat': 5, 'tasima': 4},
      'childNames': {'erkek': ['Altay', 'Bora', 'Alp', 'Emir'], 'kiz': ['Altın', 'Gökçe', 'Güneş', 'Asya']},
    },
    {
      'emoji': '🐍', 'name': 'Yılan', 'nameEn': 'Snake', 'nameCn': '蛇',
      'years': '1929, 1941, 1953, 1965, 1977, 1989, 2001, 2013, 2025',
      'fixedElement': 'Ateş', 'fixedYinYang': 'Yin',
      'traits': ['Bilge', 'Gizemli', 'Sezgisel', 'Zarif', 'Stratejik'],
      'strengths': ['Derin bilgelik', 'Strateji', 'Sezgi', 'Zarafet', 'Analitik düşünce'],
      'weaknesses': ['Şüphecilik', 'Kıskançlık', 'Gizlilik', 'Soğukluk'],
      'personality': 'Yılan ruhunu taşıyanlar, zamanın ötesinden gelen bir bilgelikle doğarlar. Yüzeyin altını görür, kelimelerin ardındaki niyeti sezerler. Mistik bir çekicilikleri vardır — insanlar onları tam olarak çözemez ama etkilenmekten kendilerini alamaz. Düşünceleri derin, stratejileri çok katmanlı, sezgileri neredeyse doğaüstüdür. Bir Yılan ruhunun sessizliği, bin kelimenin söylediklerinden daha çok şey anlatır.',
      'love': 'Aşkta gizemli ve derin. Tam güvenmedikçe kalbini açmaz. Ama sevince sonsuz sadakatle bağlanır.',
      'bestMatch': [1, 9], // Öküz, Horoz
      'goodMatch': [4, 0], // Ejderha, Sıçan
      'conflict': [2, 11], // Kaplan, Domuz
      'careers': ['Bilim İnsanı', 'Filozof', 'Psikolog', 'Dedektif', 'Danışman'],
      'careerAdvice': 'Yüzeyin altını gören gözleriniz, başkalarının kaçırdığı gerçekleri ortaya çıkarır. Sessiz bilgeliğiniz en karmaşık düğümleri bile çözer — stratejiniz su gibi akıp her engeli aşar.',
      'luckyNumbers': [2, 8, 9], 'luckyColors': ['Kırmızı', 'Siyah', 'Sarı'],
      'luckyDirections': ['Güney', 'Güneybatı'],
      'unluckyNumbers': [1, 6, 7], 'unluckyColors': ['Beyaz'],
      'fengShui': {'renk': 'Kırmızı ve siyah', 'yön': 'Güney & Güneybatı', 'malzeme': 'İpek ve taş', 'tavsiye': 'Minimalist tasarım tercih edin. Kırmızı aksesuarlar ve siyah mobilyalar uyumlu. Güneye bakan bir meditasyon köşesi oluşturun.'},
      'timingAdvice': {'isKurma': 4, 'yatirim': 5, 'evlenme': 3, 'cocuk': 3, 'seyahat': 4, 'tasima': 3},
      'childNames': {'erkek': ['Ateş', 'Volkan', 'Alev', 'Kaan'], 'kiz': ['Ateş', 'Naz', 'Sude', 'Defne']},
    },
    {
      'emoji': '🐴', 'name': 'At', 'nameEn': 'Horse', 'nameCn': '马',
      'years': '1930, 1942, 1954, 1966, 1978, 1990, 2002, 2014, 2026',
      'fixedElement': 'Ateş', 'fixedYinYang': 'Yang',
      'traits': ['Enerjik', 'Özgür', 'Neşeli', 'Sosyal', 'Atletik'],
      'strengths': ['Sınırsız enerji', 'Özgürlük ruhu', 'Sosyal beceri', 'Atletizm', 'Neşe'],
      'weaknesses': ['Sabırsızlık', 'Kararsızlık', 'Bağlanma korkusu', 'Aşırı hareketlilik'],
      'personality': 'At ruhunu taşıyanlar, rüzgârın bedene bürünmüş halidir. Özgürlükleri yalnızca fiziksel değil — ruhsal bir ihtiyaçtır. Duvarlar onları bunaltır, rutinler onları soldurur. Ama koştuklarında — ah, koştuklarında dünya durur ve izler. Enerjileri güneş gibidir: yanlarında olmak insanları canlandırır, ısıtır ve ilham verir. Bir At ruhunun neşesi sahte değildir — yaşamın kendisine duyulan derin bir aşktan doğar.',
      'love': 'Aşkta heyecan ve macera arar. Bağımsızlığına düşkün, ama doğru kişiyi bulunca tam bağlanır.',
      'bestMatch': [2, 10], // Kaplan, Köpek
      'goodMatch': [7, 11], // Keçi, Domuz
      'conflict': [0, 1], // Sıçan, Öküz
      'careers': ['Sporcu', 'Pilot', 'Satıcı', 'Komedyen', 'Rehber'],
      'careerAdvice': 'Rüzgâr gibisiniz — duvarlar arasına sığmazsınız. Enerjiniz sadece size değil, dokunduğunuz herkese hayat verir. Özgürlüğünüzü besleyen bir kariyer, ruhunuzu da besler.',
      'luckyNumbers': [2, 3, 7], 'luckyColors': ['Sarı', 'Yeşil', 'Kırmızı'],
      'luckyDirections': ['Güney', 'Güneybatı'],
      'unluckyNumbers': [1, 5, 6], 'unluckyColors': ['Beyaz', 'Mavi'],
      'fengShui': {'renk': 'Sıcak kırmızı ve turuncu', 'yön': 'Güney', 'malzeme': 'Ahşap ve deri', 'tavsiye': 'Açık ve ferah mekanlar tercih edin. Güneş ışığı alan odalar idealdir. Spor ekipmanları için özel alan oluşturun.'},
      'timingAdvice': {'isKurma': 5, 'yatirim': 4, 'evlenme': 4, 'cocuk': 3, 'seyahat': 5, 'tasima': 5},
      'childNames': {'erkek': ['Güneş', 'Ateş', 'Yiğit', 'Koray'], 'kiz': ['Alev', 'Işıl', 'Sıla', 'Ayla']},
    },
    {
      'emoji': '🐏', 'name': 'Keçi', 'nameEn': 'Goat', 'nameCn': '羊',
      'years': '1931, 1943, 1955, 1967, 1979, 1991, 2003, 2015, 2027',
      'fixedElement': 'Toprak', 'fixedYinYang': 'Yin',
      'traits': ['Yaratıcı', 'Şefkatli', 'Hassas', 'Sakinleştirici', 'Estetik'],
      'strengths': ['Yaratıcılık', 'Sanatsal ruh', 'Şefkat', 'Estetik anlayış', 'Huzur verme'],
      'weaknesses': ['Aşırı hassasiyet', 'Bağımlılık', 'Kararsızlık', 'Endişe eğilimi'],
      'personality': 'Keçi ruhunu taşıyanlar, evrenin şiirini duyan nadir ruhlardır. Bir günbatımında başkalarının göremediği renkleri, bir melodide gizli duyguları fark ederler. Yaratıcılıkları yalnızca bir yetenek değil — dünyayı algılama biçimleridir. Hassasiyetleri zayıflık değil, evrenle kurdukları derin bağın göstergesidir. Bir Keçi ruhunun dokunduğu her şey — bir yemek, bir söz, bir bakış — sanata dönüşür.',
      'love': 'Aşkta romantik ve duygusal. Güven ve sıcaklık arar. Koruma altında hissedildikçe açılır.',
      'bestMatch': [3, 11], // Tavşan, Domuz
      'goodMatch': [6, 2], // At, Kaplan
      'conflict': [1, 10], // Öküz, Köpek
      'careers': ['Ressam', 'Müzisyen', 'Terapi Uzmanı', 'Aşçı', 'Tasarımcı'],
      'careerAdvice': 'Dokunduğunuz her şeyi sanata dönüştüren elleriniz var. Şefkatiniz iyileştirir, yaratıcılığınız ilham verir — sizin işiniz dünyayı güzelleştirmektir, bir fırça darbesiyle ya da bir gülümsemeyle.',
      'luckyNumbers': [2, 7], 'luckyColors': ['Yeşil', 'Kahverengi', 'Kırmızı'],
      'luckyDirections': ['Güney', 'Güneybatı'],
      'unluckyNumbers': [4, 9], 'unluckyColors': ['Siyah'],
      'fengShui': {'renk': 'Toprak ve pastel tonlar', 'yön': 'Güney & Güneybatı', 'malzeme': 'Seramik ve kumaş', 'tavsiye': 'Yumuşak tonlarda boyanan duvarlar ve el yapımı seramikler evinize huzur katar. Sanat köşesi oluşturun.'},
      'timingAdvice': {'isKurma': 3, 'yatirim': 3, 'evlenme': 5, 'cocuk': 5, 'seyahat': 4, 'tasima': 3},
      'childNames': {'erkek': ['Toprak', 'Atlas', 'Eylül', 'Efe'], 'kiz': ['Elif', 'Melis', 'Arya', 'Duru']},
    },
    {
      'emoji': '🐵', 'name': 'Maymun', 'nameEn': 'Monkey', 'nameCn': '猴',
      'years': '1932, 1944, 1956, 1968, 1980, 1992, 2004, 2016, 2028',
      'fixedElement': 'Metal', 'fixedYinYang': 'Yang',
      'traits': ['Zeki', 'Esprili', 'Yaratıcı', 'Kurnaz', 'Girişimci'],
      'strengths': ['Parlak zekâ', 'Espri yeteneği', 'Yaratıcılık', 'Problem çözme', 'Esneklik'],
      'weaknesses': ['Sabırsızlık', 'Kurnazlık', 'Güvenilmezlik', 'Çabuk sıkılma'],
      'personality': 'Maymun ruhunu taşıyanlar, evrenin jokerleridir. Zekâları öyle hızlı çalışır ki, başkaları daha sorunu anlamadan onlar çoktan üç çözüm üretmiştir. Esprileri sadece güldürmez — hakikati maskeler arkasından fısıldar. Sıkılmak onlar için varoluşsal bir tehlikedir; bu yüzden hayatı sürekli yeniden icat ederler. Bir Maymun ruhunun yanında asla sıkılmazsınız — çünkü onlar sihirbaz gibidir: her an bir sonraki numarayı hazırlarlar.',
      'love': 'Aşkta eğlenceli ve heyecanlı. Sıkılmaktan korkar. Zeki ve esprili bir partner arar.',
      'bestMatch': [0, 4], // Sıçan, Ejderha
      'goodMatch': [5, 11], // Yılan, Domuz
      'conflict': [2, 11], // Kaplan, Domuz
      'careers': ['Yazılımcı', 'Stand-up Komedyen', 'Mühendis', 'Mucit', 'Pazarlamacı'],
      'careerAdvice': 'Zihniniz bir sihirbazın eli gibi çalışır — sorunları çözmez, onları yok eder. Sıkıcı olanı büyüleyiciye çeviren zekanız, inovasyonun tam kalbinde atıyor.',
      'luckyNumbers': [4, 9], 'luckyColors': ['Beyaz', 'Mavi', 'Altın'],
      'luckyDirections': ['Batı', 'Kuzeybatı'],
      'unluckyNumbers': [2, 7], 'unluckyColors': ['Kırmızı'],
      'fengShui': {'renk': 'Beyaz ve metalik tonlar', 'yön': 'Batı & Kuzeybatı', 'malzeme': 'Metal ve cam', 'tavsiye': 'Modern ve minimalist tasarım sizin için ideal. Metal aksesuarlar ve aydınlık mekanlar tercih edin.'},
      'timingAdvice': {'isKurma': 5, 'yatirim': 4, 'evlenme': 3, 'cocuk': 4, 'seyahat': 5, 'tasima': 4},
      'childNames': {'erkek': ['Demir', 'Çelik', 'Kaan', 'Mert'], 'kiz': ['Gümüş', 'İnci', 'Nil', 'Selen']},
    },
    {
      'emoji': '🐔', 'name': 'Horoz', 'nameEn': 'Rooster', 'nameCn': '鸡',
      'years': '1933, 1945, 1957, 1969, 1981, 1993, 2005, 2017, 2029',
      'fixedElement': 'Metal', 'fixedYinYang': 'Yin',
      'traits': ['Gözlemci', 'Çalışkan', 'Cesur', 'Pratik', 'Detaycı'],
      'strengths': ['Keskin gözlem', 'Çalışkanlık', 'Dürüstlük', 'Pratiklik', 'Organizasyon'],
      'weaknesses': ['Eleştiricilik', 'Kibirlilik', 'Aşırı titizlik', 'Baskınlık'],
      'personality': 'Horoz ruhunu taşıyanlar, karanlığın içinde ışığı ilk gören ve haber veren ruhlardır. Gözleri bir kartal kadar keskin, standartları bir kuyumcu kadar yüksektir. Mükemmeliyetçilikleri yüzeysel bir titizlik değil — dünyaya sundukları her şeyin onurlarını yansıtması gerektiğine dair derin bir inançtır. Cesurdurlar — doğruyu söylemekten çekinmezler, popüler olmasa bile.',
      'love': 'Aşkta dürüst ve doğrudan. net iletişim kurar ama bazen aşırı eleştirel olabilir.',
      'bestMatch': [1, 5], // Öküz, Yılan
      'goodMatch': [4, 8], // Ejderha, Maymun
      'conflict': [3, 10], // Tavşan, Köpek
      'careers': ['Askeri Komutan', 'Gazeteci', 'Cerrah', 'Kalite Kontrolcü', 'Polis'],
      'careerAdvice': 'Karanlıkta ilk ışığı siz görürsünüz. Mükemmeliyetçiliğiniz bir lüks değil, standart belirleyen bir güçtür — elinizden geçen her iş, onurlu imzanızı taşır.',
      'luckyNumbers': [5, 7, 8], 'luckyColors': ['Altın', 'Kahverengi', 'Sarı'],
      'luckyDirections': ['Batı', 'Güneybatı'],
      'unluckyNumbers': [1, 3, 9], 'unluckyColors': ['Beyaz'],
      'fengShui': {'renk': 'Altın ve toprak tonları', 'yön': 'Batı & Güneybatı', 'malzeme': 'Metal ve seramik', 'tavsiye': 'Düzenli ve organize bir ortam sizi rahatlatır. Metal çerçeveli tablolar ve altın tonlu aksesuarlar kullanın.'},
      'timingAdvice': {'isKurma': 4, 'yatirim': 4, 'evlenme': 4, 'cocuk': 4, 'seyahat': 3, 'tasima': 4},
      'childNames': {'erkek': ['Altın', 'Yüce', 'Polat', 'Tunç'], 'kiz': ['Altın', 'Simge', 'Tuğçe', 'Ezgi']},
    },
    {
      'emoji': '🐕', 'name': 'Köpek', 'nameEn': 'Dog', 'nameCn': '狗',
      'years': '1934, 1946, 1958, 1970, 1982, 1994, 2006, 2018, 2030',
      'fixedElement': 'Toprak', 'fixedYinYang': 'Yang',
      'traits': ['Sadık', 'Dürüst', 'Koruyucu', 'Cesur', 'Adil'],
      'strengths': ['Sadakat', 'Dürüstlük', 'Koruma içgüdüsü', 'Adalet duygusu', 'Cesaret'],
      'weaknesses': ['Endişe eğilimi', 'Karamsar bakış', 'Aşırı korumacılık', 'Güvensizlik'],
      'personality': 'Köpek ruhunu taşıyanlar, evrenin vicdanıdır. İçlerinde taşıdıkları adalet ateşi, haksızlık karşısında asla sönmez. Sadakatleri kör değildir — bilinçli bir seçimdir. Sevdiklerini yalnızca korumakla kalmazlar; onların en iyi versiyonlarını görmelerini sağlarlar. Bir Köpek ruhunun dostluğu, bu dünyadaki en değerli hazinelerden biridir — çünkü koşulsuz, sarsılmaz ve sonsuzdur.',
      'love': 'Aşkta sadık ve koruyucu. Güven en önemli değeridir. Sevdiklerini her koşulda savunur.',
      'bestMatch': [2, 6], // Kaplan, At
      'goodMatch': [3, 11], // Tavşan, Domuz
      'conflict': [4, 9], // Ejderha, Horoz
      'careers': ['Avukat', 'Polis', 'Doktor', 'Öğretmen', 'Sosyal Hizmet Uzmanı'],
      'careerAdvice': 'İçinizdeki pusula her zaman doğruyu gösterir. Adaletiniz sizi yalnızca iyi bir profesyonel değil, insanların güvenle sığındığı bir liman yapar.',
      'luckyNumbers': [3, 4, 9], 'luckyColors': ['Kırmızı', 'Yeşil', 'Mor'],
      'luckyDirections': ['Doğu', 'Güney'],
      'unluckyNumbers': [1, 6, 7], 'unluckyColors': ['Kahverengi'],
      'fengShui': {'renk': 'Sıcak toprak ve yeşil tonlar', 'yön': 'Doğu & Güney', 'malzeme': 'Doğal ahşap ve taş', 'tavsiye': 'Sıcak ve güvenli hissettiren bir ortam yaratın. Doğal malzemeler ve yumuşak aydınlatma kullanın.'},
      'timingAdvice': {'isKurma': 3, 'yatirim': 3, 'evlenme': 5, 'cocuk': 5, 'seyahat': 4, 'tasima': 3},
      'childNames': {'erkek': ['Kaya', 'Yiğit', 'Burak', 'Onur'], 'kiz': ['Toprak', 'Zeynep', 'Eylül', 'Beren']},
    },
    {
      'emoji': '🐖', 'name': 'Domuz', 'nameEn': 'Pig', 'nameCn': '猪',
      'years': '1935, 1947, 1959, 1971, 1983, 1995, 2007, 2019, 2031',
      'fixedElement': 'Su', 'fixedYinYang': 'Yin',
      'traits': ['Cömert', 'Şefkatli', 'Neşeli', 'Eğlenceli', 'Nazik'],
      'strengths': ['Cömertlik', 'Sıcaklık', 'Neşe', 'Güçlü iç dünya', 'Sadakat'],
      'weaknesses': ['Saflık', 'Aşırı güven', 'Tembel eğilim', 'Savurganlık'],
      'personality': 'Domuz ruhunu taşıyanlar, evrenin en saf kalpli varlıklarıdır. Cömertlikleri hesapsız, sevgileri koşulsuzdur. Bir odaya girdiklerinde görünmez bir sıcaklık yayılır — sanki güneş doğmuş gibi. Saflıkları zayıflık değil, dünyaya inatla iyilik sunma cesaretidir. Bir Domuz ruhunun sofrasında herkes yer bulur, kalbinde herkes sığınak bulur. Onlar hayatın tadını en derinden alan ve bunu cömertçe paylaşan ruhlardır.',
      'love': 'Aşkta sıcak ve cömert. Sevgisini bolca gösterir. Güvene çok değer verir.',
      'bestMatch': [3, 7], // Tavşan, Keçi
      'goodMatch': [2, 6], // Kaplan, At
      'conflict': [5, 8], // Yılan, Maymun
      'careers': ['Aşçı', 'Hayırsever', 'Hemşire', 'Veteriner', 'Otelci'],
      'careerAdvice': 'Kalbiniz bir okyanus gibi geniştir — herkes için yer vardır. Cömertliğinizle dokunan elleriniz, ister bir sofrada ister bir hastane koridorunda olsun, her yerde mucize yaratır.',
      'luckyNumbers': [2, 5, 8], 'luckyColors': ['Sarı', 'Gri', 'Kahverengi'],
      'luckyDirections': ['Kuzey', 'Doğu'],
      'unluckyNumbers': [1, 7, 8], 'unluckyColors': ['Kırmızı', 'Mavi'],
      'fengShui': {'renk': 'Mavi ve gri tonları', 'yön': 'Kuzey & Doğu', 'malzeme': 'Cam ve kumaş', 'tavsiye': 'Rahat ve konforlu bir ortam yaratın. Su öğeleri (çeşme, akvaryum) şansınızı artırır. Mavi tonlarda dekorasyon kullanın.'},
      'timingAdvice': {'isKurma': 3, 'yatirim': 3, 'evlenme': 5, 'cocuk': 5, 'seyahat': 4, 'tasima': 4},
      'childNames': {'erkek': ['Deniz', 'Umut', 'Ozan', 'Berk'], 'kiz': ['Su', 'Damla', 'Melisa', 'Ceren']},
    },
  ];

  // ── 5 ELEMENT SİSTEMİ ──
  static const Map<String, Map<String, dynamic>> elements = {
    'Ağaç': {
      'emoji': '🌳', 'color': 0xFF4CAF50, 'season': 'İlkbahar', 'direction': 'Doğu',
      'organ': 'Karaciğer', 'emotion': 'Öfke → Nezaket',
      'generates': 'Ateş', 'controls': 'Toprak', 'weakenedBy': 'Metal',
      'desc': 'Büyüme, esneklik ve yaratıcılığı temsil eder. Ağaç insanları idealist ve cömerttir.',
    },
    'Ateş': {
      'emoji': '🔥', 'color': 0xFFE53935, 'season': 'Yaz', 'direction': 'Güney',
      'organ': 'Kalp', 'emotion': 'Neşe → Heyecan',
      'generates': 'Toprak', 'controls': 'Metal', 'weakenedBy': 'Su',
      'desc': 'Tutku, enerji ve dönüşümü temsil eder. Ateş insanları karizmatik ve motivedir.',
    },
    'Toprak': {
      'emoji': '🌍', 'color': 0xFF8D6E63, 'season': 'Mevsim Geçişleri', 'direction': 'Merkez',
      'organ': 'Dalak', 'emotion': 'Endişe → Güven',
      'generates': 'Metal', 'controls': 'Su', 'weakenedBy': 'Ağaç',
      'desc': 'Denge, istikrar ve beslenmeyi temsil eder. Toprak insanları güvenilir ve şefkatlidir.',
    },
    'Metal': {
      'emoji': '⚙️', 'color': 0xFF78909C, 'season': 'Sonbahar', 'direction': 'Batı',
      'organ': 'Akciğer', 'emotion': 'Üzüntü → Cesaret',
      'generates': 'Su', 'controls': 'Ağaç', 'weakenedBy': 'Ateş',
      'desc': 'Kararlılık, güç ve disiplini temsil eder. Metal insanları organize ve güçlüdür.',
    },
    'Su': {
      'emoji': '💧', 'color': 0xFF1565C0, 'season': 'Kış', 'direction': 'Kuzey',
      'organ': 'Böbrek', 'emotion': 'Korku → Bilgelik',
      'generates': 'Ağaç', 'controls': 'Ateş', 'weakenedBy': 'Toprak',
      'desc': 'Bilgelik, akış ve adaptasyonu temsil eder. Su insanları sezgisel ve uyumludur.',
    },
  };

  // ── YIL ETKİLEŞİM METİNLERİ (Her hayvan için At yılı 2026 etkileşimi) ──
  static const List<String> yearInteractions = [
    // Sıçan
    'Sıçan ve At yılı geleneksel olarak karşıt enerjiler taşır. Bu yıl sabırlı olmak ve büyük kararları ertelemek lehinize olacaktır. Finansal konularda temkinli davranın.',
    // Öküz
    'Öküz için At yılı zorlu ama gelişimsel bir dönemdir. Alışkanlıklarınızı değiştirmeye açık olun. Yeni beceriler edinmek için ideal zaman.',
    // Kaplan
    'Kaplan ve At mükemmel bir üçgen uyumu içindedir! Bu yıl çok şanslısınız. Cesur adımlar atabilir, büyük projelere başlayabilirsiniz.',
    // Tavşan
    'Tavşan için At yılı sosyal açıdan parlak bir dönemdir. Yeni insanlar tanıyacak, ilham verici bağlantılar kuracaksınız.',
    // Ejderha
    'Ejderha için At yılı enerji dolu ve üretken bir zaman. Büyük hedeflerinize ulaşmak için doğru an. Liderlik pozisyonlarına yükselebilirsiniz.',
    // Yılan
    'Yılan için At yılı dikkatli olunması gereken bir dönemdir. İç sesinizi dinleyin ve stratejik düşünün. Aceleci kararlardan kaçının.',
    // At
    'Bu sizin yılınız! "Ben Nian" — kendi yılınız. Kırmızı aksesuar takmak geleneksel olarak şans getirir. Yenilenme ve yeniden doğuş zamanı.',
    // Keçi
    'Keçi için At yılı yaratıcılığın zirvesidir. Sanatsal projeler başlatın, ruhunuzu ifade edin. İlişkilerde güzel gelişmeler var.',
    // Maymun
    'Maymun için At yılı hareketli ve fırsatlarla dolu bir dönemdir. Zekanızı kullanın, ama dürtüsel kararlardan sakının.',
    // Horoz
    'Horoz için At yılı çalışkanlığınızın karşılığını aldığınız bir dönemdir. Kariyer atılımları ve maddi kazançlar mümkün.',
    // Köpek
    'Köpek ve At mükemmel bir uyum içindedir! Bu yıl sadakatiniz ve dürüstlüğünüz ödüllendirilir. İlişkilerde güzel gelişmeler sizi bekliyor.',
    // Domuz
    'Domuz için At yılı sosyal ve eğlenceli bir dönemdir. Cömertliğiniz takdir edilir ama bütçenize dikkat edin.',
  ];

  // ── 2026 MEVSİMSEL TAVSİYELER (Her hayvan için kişiselleştirilmiş) ──
  static const List<List<List<String>>> yearSeasonalAdvice = [
    // 0-Sıçan
    [['🌱', 'İlkbahar', 'Temkinli başlangıçlar yapın. Küçük ama sağlam adımlar atın, finansal planlarınızı gözden geçirin.'],
     ['☀️', 'Yaz', 'Sosyal ağınızı genişletin. Stratejik ortaklıklar kurmak için ideal dönem.'],
     ['🍂', 'Sonbahar', 'Birikiminizi değerlendirin. Yatırımlarınızı analiz edin, gereksiz harcamaları kesin.'],
     ['❄️', 'Kış', 'Geri çekilin ve gözlem yapın. Yeni yıl için güçlü bir strateji oluşturun.']],
    // 1-Öküz
    [['🌱', 'İlkbahar', 'Alışkanlıklarınızı yeniden yapılandırın. Değişime kapınızı aralayın, küçük adımlarla başlayın.'],
     ['☀️', 'Yaz', 'Beceri geliştirmeye odaklanın. Yeni bir kurs veya eğitim programına katılın.'],
     ['🍂', 'Sonbahar', 'Emeğinizin karşılığını almaya başlayacaksınız. Sabrınız ödüllendirilir.'],
     ['❄️', 'Kış', 'Sevdiklerinizle kaliteli vakit geçirin. Sağlığınıza ekstra özen gösterin.']],
    // 2-Kaplan
    [['🌱', 'İlkbahar', 'Büyük projelere cesurca başlayın! At yılı enerjisi sizinle tam uyumlu.'],
     ['☀️', 'Yaz', 'Zirve döneminiz. Kariyerde atılım yapın, risk almaktan korkmayın.'],
     ['🍂', 'Sonbahar', 'Kazanımlarınızı pekiştirin. Ekibinizi güçlendirin ve delegasyon yapın.'],
     ['❄️', 'Kış', 'Enerjinizi koruyun, kendinizi yenileyin. Gelecek yıl için vizyonunuzu netleştirin.']],
    // 3-Tavşan
    [['🌱', 'İlkbahar', 'Yeni sosyal çevreler edinin. Sanatsal projelere başlamak için mükemmel zamanlama.'],
     ['☀️', 'Yaz', 'İlişkileriniz güçleniyor. Romantik dönem — kalbinizin sesini dinleyin.'],
     ['🍂', 'Sonbahar', 'Yaratıcılığınızı maddi değere dönüştürün. Estetik projelerde parlayın.'],
     ['❄️', 'Kış', 'İç dünyanıza çekilin, meditasyon ve sanat ile ruhunuzu besleyin.']],
    // 4-Ejderha
    [['🌱', 'İlkbahar', 'Büyük hedeflerinize koşun. Liderlik fırsatları kendini gösterecek.'],
     ['☀️', 'Yaz', 'En güçlü döneminiz! Büyük yatırımlar ve iş kurmak için altın zaman.'],
     ['🍂', 'Sonbahar', 'İmparatorluğunuzu genişletin. Yeni pazarlara ve alanlara açılın.'],
     ['❄️', 'Kış', 'Stratejik geri çekilme. Acele etmeyin, büyük hamleleri ilkbahara saklayın.']],
    // 5-Yılan
    [['🌱', 'İlkbahar', 'Sezgileriniz güçlü ama acele etmeyin. Araştırma ve analiz döneminiz.'],
     ['☀️', 'Yaz', 'Gizli fırsatları keşfedin. Başkalarının göremediği detaylar avantajınız.'],
     ['🍂', 'Sonbahar', 'Stratejik hamleler için uygun. Uzun vadeli planlarınızı devreye sokun.'],
     ['❄️', 'Kış', 'Bilgeliğinizi derinleştirin. Okuyun, öğrenin, kendinizi geliştirin.']],
    // 6-At
    [['🌱', 'İlkbahar', 'Kendi yılınız başladı! Kırmızı aksesuar ile şansınızı artırın. Yeni sayfa açın.'],
     ['☀️', 'Yaz', 'Enerjiniz zirvede ama Ben Nian dikkat gerektirir — ani kararlardan kaçının.'],
     ['🍂', 'Sonbahar', 'Dengeyi bulun. Özgürlük ve sorumluluk arasındaki ince çizgiyi koruyun.'],
     ['❄️', 'Kış', 'Yılı güçlü kapatın. Tempolu ama bilinçli hareket edin, yeni yıla hazırlanın.']],
    // 7-Keçi
    [['🌱', 'İlkbahar', 'Yaratıcılığınız çiçek açıyor. Sanat, müzik veya tasarım projelerine başlayın.'],
     ['☀️', 'Yaz', 'İlişkilerde güzel gelişmeler. Sevdiklerinizle bağlarınızı güçlendirin.'],
     ['🍂', 'Sonbahar', 'Eserlerinizi dünyayla paylaşın. Sergi veya lansman için ideal dönem.'],
     ['❄️', 'Kış', 'Ruhunuzu dinlendirin. Sıcak bir ortamda yaratıcı ilhamınızı yenileyin.']],
    // 8-Maymun
    [['🌱', 'İlkbahar', 'Zekanızı iş fikirlerine dönüştürün. Girişimcilik ruhunuz ateşleniyor.'],
     ['☀️', 'Yaz', 'Hızlı hareket edin ama dürtüsel olmayın. Fırsatlar bol, seçici olun.'],
     ['🍂', 'Sonbahar', 'Sosyal ağınız genişliyor. Network etkinliklerine katılın ve yeni kapılar açın.'],
     ['❄️', 'Kış', 'Yenilikçi projelerinizi planlayın. Teknolojiyle ilgili yatırımlar şanslı.']],
    // 9-Horoz
    [['🌱', 'İlkbahar', 'Kariyer atılımı için harekete geçin. Disiplininiz ve titizliğiniz ödüllendirilecek.'],
     ['☀️', 'Yaz', 'Maddi kazanç dönemi. Çalışkanlığınızın meyvelerini toplamaya başlayın.'],
     ['🍂', 'Sonbahar', 'Organizasyon yeteneklerinizi kullanarak büyük projeleri tamamlayın.'],
     ['❄️', 'Kış', 'Detaylara odaklanın, eksikleri giderin. Mükemmeliyetçiliğiniz sizi öne taşır.']],
    // 10-Köpek
    [['🌱', 'İlkbahar', 'Sadakatiniz ve dürüstlüğünüz kapılar açıyor. Güvenilir ortaklıklar kurun.'],
     ['☀️', 'Yaz', 'İlişkileriniz derinleşiyor. Romantik dönem — cesur adımlar atın.'],
     ['🍂', 'Sonbahar', 'Topluma katkı sağlayan projelerde yer alın. Vicdanınız sizi doğru yönlendirir.'],
     ['❄️', 'Kış', 'Ailenizle bağlarınızı güçlendirin. Sıcaklık ve huzur arayışı ön planda.']],
    // 11-Domuz
    [['🌱', 'İlkbahar', 'Cömertliğinizi akıllıca yönlendirin. Yardım ederken kendinizi de unutmayın.'],
     ['☀️', 'Yaz', 'Sosyal hayatınız parlak! Eğlence ve kutlamalar sizi bekliyor.'],
     ['🍂', 'Sonbahar', 'Bütçenizi gözden geçirin. Biriktirme zamanı — lüks harcamaları erteleyin.'],
     ['❄️', 'Kış', 'Ev ve aile odaklı bir dönem. Sevdiklerinizle sıcak anlar yaşayın.']],
  ];

  // ── 2026 KİŞİSEL ZAMANLAMA REHBERİ (Her hayvan için özel kategoriler) ──
  // [emoji, label, score(1-5)]
  static const List<List<List<dynamic>>> yearTimingGuide = [
    // 0-Sıçan — Finansal zekâ ve strateji odaklı
    [['💰', 'Finansal Hamle', 4],
     ['🤝', 'Stratejik Ortaklık', 3],
     ['🏠', 'Mülk Yatırımı', 2],
     ['📊', 'Borsa & Kripto', 5],
     ['🎓', 'Eğitim & Sertifika', 4],
     ['🧳', 'İş Seyahati', 3]],
    // 1-Öküz — Dayanıklılık ve uzun vade odaklı
    [['🏗️', 'Uzun Vadeli Yatırım', 4],
     ['📚', 'Beceri Geliştirme', 5],
     ['💒', 'Evlilik & Nişan', 4],
     ['🌾', 'Arazi & Tarla', 3],
     ['🏥', 'Sağlık Check-up', 5],
     ['🔨', 'Ev Tadilatı', 3]],
    // 2-Kaplan — Cesaret ve liderlik odaklı
    [['👑', 'Liderlik Atılımı', 5],
     ['🎲', 'Cesur Risk Alma', 4],
     ['🏆', 'Spor & Yarışma', 5],
     ['🚀', 'Startup Kurma', 4],
     ['🗺️', 'Macera Seyahati', 5],
     ['💕', 'Aşk İlanı', 3]],
    // 3-Tavşan — Estetik ve ilişki odaklı
    [['🎨', 'Sanat Projesi', 5],
     ['💐', 'Romantizm', 5],
     ['🖼️', 'Estetik Yatırım', 4],
     ['🧘', 'Terapi & Şifa', 4],
     ['🎭', 'Sosyal Etkinlik', 4],
     ['🕊️', 'İç Huzur Arayışı', 3]],
    // 4-Ejderha — Büyüklük ve güç odaklı
    [['🏰', 'İmparatorluk Kurma', 5],
     ['💎', 'Lüks Yatırım', 5],
     ['📈', 'Büyük Sermaye', 4],
     ['🎖️', 'Kariyer Zirvesi', 5],
     ['💍', 'Görkemli Düğün', 4],
     ['🌍', 'Uluslararası Açılım', 4]],
    // 5-Yılan — Bilgelik ve strateji odaklı
    [['🔬', 'Araştırma & Analiz', 5],
     ['♟️', 'Stratejik Hamle', 4],
     ['💼', 'Gizli Yatırım', 3],
     ['🔮', 'Ruhsal Gelişim', 5],
     ['🎓', 'Akademik Kariyer', 4],
     ['📦', 'Sessiz Taşınma', 2]],
    // 6-At — Özgürlük ve hareket odaklı
    [['✈️', 'Dünya Turu', 4],
     ['🏃', 'Spor & Fitness', 5],
     ['🎉', 'Sosyal Etkinlik', 5],
     ['🔄', 'Kariyer Değişimi', 3],
     ['🏕️', 'Macera & Keşif', 5],
     ['💪', 'Bağımsız Proje', 4]],
    // 7-Keçi — Yaratıcılık ve sanat odaklı
    [['🎵', 'Müzik & Sanat', 5],
     ['💞', 'Romantik Adım', 5],
     ['🏡', 'Ev Dekorasyonu', 4],
     ['🌿', 'Doğa Terapisi', 4],
     ['✍️', 'Yaratıcı Yazarlık', 5],
     ['👨‍👩‍👧', 'Aile Planı', 4]],
    // 8-Maymun — İnovasyon ve girişimcilik odaklı
    [['💡', 'Girişimcilik', 5],
     ['🖥️', 'Teknoloji Yatırımı', 4],
     ['🌐', 'Network Genişletme', 5],
     ['🧪', 'İnovasyon Projesi', 4],
     ['🎪', 'Eğlence Sektörü', 3],
     ['📱', 'Dijital Dönüşüm', 4]],
    // 9-Horoz — Disiplin ve başarı odaklı
    [['📊', 'Kariyer Atılımı', 5],
     ['📋', 'Organizasyon', 5],
     ['🏦', 'Maddi Birikim', 4],
     ['🔍', 'Detay & Kalite İşi', 5],
     ['👔', 'Profesyonel İmaj', 4],
     ['⏰', 'Rutin Optimizasyonu', 4]],
    // 10-Köpek — Sadakat ve toplum odaklı
    [['🤲', 'Toplumsal Proje', 5],
     ['⚖️', 'Adalet & Hak Arama', 4],
     ['💑', 'İlişki Derinleştirme', 5],
     ['👪', 'Aile Bağları', 5],
     ['🎗️', 'Gönüllü Çalışma', 4],
     ['🛡️', 'Güvenli Yuva Kurma', 4]],
    // 11-Domuz — Keyif ve cömertlik odaklı
    [['🍽️', 'Gastronomi & Lezzet', 5],
     ['🥂', 'Sosyal Kutlama', 5],
     ['💝', 'Hayırseverlik', 4],
     ['🛋️', 'Konfor Yatırımı', 4],
     ['💵', 'Birikim & Tasarruf', 2],
     ['👶', 'Aile Genişletme', 5]],
  ];

  /// Güne göre şans hesapla — Güçlü günlük değişim algoritması
  static Map<String, dynamic> getDayFortune(int animalIndex, DateTime date) {
    // Güçlü seed: her gün + her burç için kesinlikle farklı
    final dayNum = date.year * 10000 + date.month * 100 + date.day;
    // Asal sayı tabanlı hash — ardışık günlerde tamamen farklı sonuçlar
    int _mix(int a, int b) => ((a * 2654435761 + b * 40503) & 0x7FFFFFFF);
    final baseSeed = _mix(dayNum, animalIndex * 7919 + 104729);
    // Her extra için benzersiz, günle doğrudan bağlı hash
    int _h(int extra) => _mix(baseSeed, extra * 15487469 + dayNum * 31);

    // Şans seviyesi — daha düzgün dağılım
    final rng = (_h(0) % 100);

    // Seviye bazlı tutarlı içerik havuzları — GENİŞLETİLMİŞ
    String level; Color color; double eBase;
    List<String> advicePool;
    List<Map<String, String>> moodPool;
    List<String> affPool, whisperPool, challengePool, doPool, dontPool, activityPool;

    if (rng < 15) {
      level = 'Çok Şanslı'; color = const Color(0xFFFFD700); eBase = 0.75;
      advicePool = [
        'Bugün yıldızlar sizden yana! Büyük kararlar almak ve yeni başlangıçlar için ideal bir gün.',
        'Kozmik enerji zirve yapıyor — hayallerinizi gerçeğe dönüştürmek için harika bir fırsat.',
        'Evren bugün size altın kapılar açıyor. Cesaretle ilerleyin, şans yanınızda.',
        'Bugün her dokunduğunuz altına dönüşebilir. Büyük düşünün ve harekete geçin.',
        'Yıldızlar sizin için dans ediyor — bu enerjiyi değerlendirin, yarın çok geç olabilir.',
        'Mucizeler bugün mümkün. Gözlerinizi açın ve evrenden gelen işaretleri takip edin.',
        'Nadiren bu kadar güçlü bir kozmik destek görüyoruz. Bugün imkansız diye bir şey yok.',
        'Şans rüzgarları tam arkanızda. Yelkenlerinizi açın ve en uzak limanlara doğru yol alın.',
      ];
      moodPool = [
        {'mood': 'Enerjik', 'emoji': '⚡', 'desc': 'Yüksek motivasyon ve aksiyon günü'},
        {'mood': 'Yaratıcı', 'emoji': '🎨', 'desc': 'İlham dolu, büyük fikirler doğuyor'},
        {'mood': 'Maceracı', 'emoji': '🌍', 'desc': 'Sınırları zorla, yenilikçi ol'},
        {'mood': 'Kararlı', 'emoji': '💎', 'desc': 'Hedefine kilitlen, hiçbir şey durduramaz'},
        {'mood': 'Güçlü', 'emoji': '🔥', 'desc': 'İçindeki aslan uyanıyor'},
        {'mood': 'Neşeli', 'emoji': '☀️', 'desc': 'Pozitif titreşimler yayıyorsun'},
      ];
      affPool = [
        'Bugün evren seninle aynı yöne akıyor.', 'Cesaretinle ışıyorsun — bırak herkes görsün!',
        'Bugün fark yaratacak güçtesin, durma.', 'Ruhundaki ateş bugün daha parlak yanıyor.',
        'Sen bir yıldızsın ve bugün en çok parlayan sensin.', 'İçindeki güç dağları yerinden oynatabilir.',
        'Bugün attığın her adım seni zirveye taşıyor.', 'Evren bugün senin lehine çalışıyor — hisset.',
      ];
      whisperPool = [
        'Yıldızlar fısıldıyor: "Zamanın geldi."', 'Kozmik enerjiler hizalandı — bugün senin günün.',
        'Evren senin için büyük kapılar açıyor.', 'Yıldız haritanda bugün parlak bir ışık var.',
        'Kaderin bugün sana gülümsüyor — gülümse sen de.', 'Galaksiler senin için hizalandı — fırsatı yakala.',
        'Antik yıldızlar diyor: "Bu ruh büyük işler başaracak."', 'Gökyüzü bugün senin adını fısıldıyor.',
      ];
      challengePool = [
        'Bugün cesur bir adım at — ertelediğin o şeyi yap', 'Bir hayalini birine sesli söyle',
        'Yeni bir şey dene — konfor alanını genişlet', 'Bugünkü en büyük başarını not al ve kutla',
        'Bugün biri için beklenmedik bir güzellik yap', 'En cesur fikrine bugün bir adım at',
        'Kendine lüks bir ödül ver — hak ediyorsun', 'Bugün bir liderin tavrıyla hareket et',
      ];
      doPool = ['Büyük kararlar al', 'Spontane ol ve akışa bırak', 'Yeni projelere başla', 'Cesur adımlar at', 'Liderlik pozisyonu üstlen', 'Risk al ve kazan', 'Hayallerini paylaş', 'Büyük hamleler yap'];
      dontPool = ['Fırsatları kaçırma', 'Küçük düşünme', 'Kendini küçümseme', 'Tereddüt etme', 'Başkalarının seni durdurmasına izin verme', 'Güvenini kaybetme', 'Erteleme tuzağına düşme', 'Mükemmeliyetçiliğe takılma'];
      activityPool = ['Yeni proje', 'Spor', 'Toplantı', 'Keşif', 'Sunum yapma', 'Yatırım araştırma', 'Network etkinliği', 'Yaratıcı çalışma'];
    } else if (rng < 40) {
      level = 'Şanslı'; color = const Color(0xFF4CAF50); eBase = 0.6;
      advicePool = [
        'Pozitif enerji yüksek. Planlarınızı hayata geçirin ve fırsatları değerlendirin.',
        'Güzel bir gün sizi bekliyor. Sevdiklerinizle vakit geçirin ve anın tadını çıkarın.',
        'Bugün küçük detaylarda büyük mutluluklar gizli. Gözlerinizi dört açın.',
        'İç sesiniz bugün doğru yolu gösteriyor — ona güvenin ve adım atın.',
        'Bugün rüzgar arkanızdan esiyor. Planlarınızı hayata geçirmek için ideal zaman.',
        'Evren bugün size küçük hediyeler sunuyor — fark edin ve kabul edin.',
        'Pozitif titreşimler sizi sarıyor. Bu enerjiyi çevrenizle paylaşın.',
        'Güzel sürprizlere açık olun — bugün beklenmedik kapılar açılabilir.',
      ];
      moodPool = [
        {'mood': 'Sosyal', 'emoji': '🤝', 'desc': 'İnsan ilişkileri güçleniyor'},
        {'mood': 'Romantik', 'emoji': '💫', 'desc': 'Duygusal bağlar derinleşiyor'},
        {'mood': 'Enerjik', 'emoji': '⚡', 'desc': 'Pozitif enerji yüksek'},
        {'mood': 'Neşeli', 'emoji': '☀️', 'desc': 'Gülümsemen bulaşıcı bugün'},
        {'mood': 'Yaratıcı', 'emoji': '🎨', 'desc': 'Güzel şeyler üretme zamanı'},
        {'mood': 'Maceracı', 'emoji': '🌍', 'desc': 'Spontane planlar bugün iyi gidecek'},
        {'mood': 'Şefkatli', 'emoji': '🤲', 'desc': 'Sevgini çevrene yay'},
        {'mood': 'Odaklı', 'emoji': '🎯', 'desc': 'Hedeflerine net adımlar at'},
      ];
      affPool = [
        'Her adımın seni doğru yere götürüyor.', 'İçindeki ışık bugün çevreni de aydınlatıyor.',
        'Evren senin için sessizce kapılar açıyor.', 'Bugün küçük mucizeler seni bulacak.',
        'Gülümsemen bugün en güçlü silahın.', 'Kalbindeki sıcaklık çevrene yayılıyor.',
        'Enerjin bulaşıcı — yanındakiler de hissediyor.', 'Bugün her şey yolunda gidecek — güven.',
      ];
      whisperPool = [
        'Ay ışığı yolunu aydınlatıyor — güven ve ilerle.', 'Rüzgâr değişti — güzel şeyler yaklaşıyor.',
        'Geceyi geçiren yıldızlar sana sabahı müjdeliyor.', 'Evrenin ritmiyle uyumlusun — akışa bırak.',
        'Kozmik melodiler bugün senin için çalıyor.', 'Yıldız tozu ruhuna taze enerji saçıyor.',
        'Gece gökyüzü senin için en parlak yıldızı sakladı.', 'Ay ve güneş bugün senin dengende buluşuyor.',
      ];
      challengePool = [
        'Sevdiğin birine teşekkür mesajı gönder', 'Bugün tanımadığın birine gülümse',
        'Bir yabancıya iltifat et', '3 şey yaz: bugün minnettar olduğun',
        'Eski bir arkadaşını ara ve hal hatır sor', 'Bugün birinin gününü güzelleştir',
        'Sevdiğin bir mekâna git ve anın tadını çıkar', 'Bir yakınına el yazısıyla not bırak',
      ];
      doPool = ['Sevdiklerinle vakit geçir', 'Planlarını hayata geçir', 'İçgüdülerine güven', 'Yeni insanlarla tanış', 'Kendine güzel bir şey al', 'Doğada vakit geçir', 'Yaratıcı bir proje başlat', 'Spontane bir plan yap'];
      dontPool = ['Güzel anları kaçırma', 'Olumsuzlara odaklanma', 'Fırsatları erteleme', 'Şüpheye kapılma', 'Enerjini boşa harcama', 'Negatif insanlara zaman ver', 'Kendini kısıtlama', 'Mükemmeliyetçi olma'];
      activityPool = ['Buluşma', 'Yürüyüş', 'Alışveriş', 'Yemek yapma', 'Kahve molası', 'Park gezisi', 'Film izleme', 'Müzik dinleme'];
    } else if (rng < 65) {
      level = 'Normal'; color = const Color(0xFF78909C); eBase = 0.45;
      advicePool = [
        'Dengeli bir gün. Rutininize sadık kalın ve küçük adımlarla ilerleyin.',
        'Bugün sakin ve dengeli kalmak en doğru strateji. Adım adım ilerleyin.',
        'Orta tempolu bir gün — acele etmeyin, ama durmayın da. Denge anahtarınız.',
        'Bugün kendine odaklan. Küçük ama anlamlı adımlar at.',
        'Sakin bir nehir gibi akmaya devam et — hedefe ulaşacaksın.',
        'Bugün büyük sürprizler bekleme, ama küçük güzellikleri fark et.',
        'Dengeni koru ve enerjini akıllıca kullan — yarına güçlü başla.',
        'Bugün altyapı günü. Gözle görülmeyen ama önemli adımlar at.',
      ];
      moodPool = [
        {'mood': 'Huzurlu', 'emoji': '🧘', 'desc': 'İç denge ve sükunet günü'},
        {'mood': 'Düşünceli', 'emoji': '🔮', 'desc': 'Derinlere in, kendini keşfet'},
        {'mood': 'Yaratıcı', 'emoji': '🎨', 'desc': 'Sakin bir ilham dalgası var'},
        {'mood': 'Odaklı', 'emoji': '🎯', 'desc': 'Konsantrasyonun güçlü, detaylara dikkat'},
        {'mood': 'Sosyal', 'emoji': '🤝', 'desc': 'Yakın çevrenle bağları güçlendir'},
        {'mood': 'Şefkatli', 'emoji': '🤲', 'desc': 'Kendine ve çevrene şefkat göster'},
        {'mood': 'Kararlı', 'emoji': '💎', 'desc': 'Küçük hedefler koy ve başar'},
        {'mood': 'Neşeli', 'emoji': '☀️', 'desc': 'Günün güzel yanlarını keşfet'},
      ];
      affPool = [
        'Sabrın en güçlü silahın olacak bugün.', 'Kalbinin sesini dinle, o asla yanılmaz.',
        'İç huzurun, dış başarıyı çekecek.', 'Bugün geçmişi bırak, geleceğe güvenle bak.',
        'Küçük adımlar büyük yolculukların başlangıcıdır.', 'Dengen senin süper gücün — koru onu.',
        'Her nefes alışın seni yeniler — fark et.', 'Bugün olduğun yer tam olman gereken yer.',
      ];
      whisperPool = [
        'Sessiz bir mucize yolda — gözlerini aç.', 'Evrenin fısıltısı bugün sana doğru esiyor.',
        'Kozmik pusulan dengeyi gösteriyor — sabret.', 'Antik bilgelik diyor ki: "Sabır, güçtür."',
        'Yıldızlar sessiz ama seni izliyorlar.', 'Ay ışığında saklı bir mesaj var — dinle.',
        'Evrenin saati senin için doğru çalıyor.', 'Rüzgârın taşıdığı sırları duyabiliyor musun?',
      ];
      challengePool = [
        'Bir fincan çayı mindful şekilde iç', '5 dakika sessizce otur ve nefesine odaklan',
        'Sevdiğin müziği gözlerin kapalı dinle', 'Doğada 10 dakika sessiz yürüyüş yap',
        'Bugün yapacaklar listenden 1 şeyi sil — rahatla', 'Bir sayfaya bugünkü düşüncelerini yaz',
        'Pencereden gökyüzünü 5 dakika izle', 'Sevdiğin bir yemeği yavaşça ve tadını çıkararak ye',
      ];
      doPool = ['Rutinine sadık kal', 'Küçük adımlarla ilerle', 'Kendine zaman ayır', 'Doğayla bağlan', 'Planlama yap', 'Düzenle ve organize et', 'Oku ve öğren', 'Sağlığına dikkat et'];
      dontPool = ['Aşırı düşünmekten kaçın', 'Kendini zorlama', 'Acele etme', 'Kontrolü elden bırakma', 'Başkalarıyla kıyaslama', 'Gereksiz stres yapma', 'Negatif içeriklere maruz kalma', 'Kendini ihmal etme'];
      activityPool = ['Meditasyon', 'Okuma', 'Yazı yazma', 'Yürüyüş', 'Yoga', 'Puzzle çözme', 'Çizim yapma', 'Bahçe işleri'];
    } else if (rng < 85) {
      level = 'Dikkatli Ol'; color = const Color(0xFFFF9800); eBase = 0.3;
      advicePool = [
        'Bugün biraz temkinli olun. Büyük kararları erteleyin ve detaylara dikkat edin.',
        'Dikkatli adımlar atmanız gereken bir gün. Sezgilerinize güvenin ama aceleci olmayın.',
        'Bugün savunma pozisyonunda kalmak akıllıca. Enerjinizi koruyun.',
        'Temkinli olmak zayıflık değil, bilgeliktir. Bugün bu bilgeliği kullanın.',
        'Küçük sorunlar büyümeden çözün — bugün detaylara odaklanın.',
        'İç sesiniz bugün sizi uyarıyor — dinleyin ve ona göre hareket edin.',
        'Bugün büyük adımlar atmak yerine mevcut durumunuzu sağlamlaştırın.',
        'Enerjiniz dalgalı — önemli kararları bir sonraki güne bırakın.',
      ];
      moodPool = [
        {'mood': 'Düşünceli', 'emoji': '🔮', 'desc': 'İç gözlem ve farkındalık zamanı'},
        {'mood': 'Huzurlu', 'emoji': '🧘', 'desc': 'Sakinliğini koru, içine dön'},
        {'mood': 'Odaklı', 'emoji': '🎯', 'desc': 'Detaylara odaklan, yavaş ilerle'},
        {'mood': 'Şefkatli', 'emoji': '🤲', 'desc': 'Bugün anlayışlı ol, kendine de'},
        {'mood': 'Güçlü', 'emoji': '🔥', 'desc': 'Direncin seni ayakta tutuyor'},
        {'mood': 'Kararlı', 'emoji': '💎', 'desc': 'Sağlam dur, bu da geçecek'},
      ];
      affPool = [
        'İçindeki güç, dışındaki her engelden büyük.', 'Her fırtına sonrası güneş doğar — bugün de öyle.',
        'Bugün kendine nazik ol, yarın güçlü olacaksın.', 'Dikkat, bilgeliğin ilk adımıdır.',
        'Bugün yavaşlamak seni güçlendirecek.', 'Köklerini derinleştir — fırtınaları böyle atlatırsın.',
        'Zorluklardan geçen ruhlar daha parlak parlar.', 'Sabrın meyvesi tatlı olacak — güven.',
      ];
      whisperPool = [
        'Yıldızlar diyor ki: "Sabret, zamanın yakın."', 'Görünmez eller seni koruyarak yönlendiriyor.',
        'Bugün durağan gibi görünse de altyapı kuruluyor.', 'Kozmik enerji seni içe dönmeye çağırıyor.',
        'Ay bulutların ardında ama hâlâ parlıyor — sen de öyle.', 'Gece en karanlık olduğunda şafak en yakındır.',
        'Evren seni test ediyor — geçeceksin.', 'Kadim ruhlar fısıldıyor: "Dayanıklılığın seni taşıyacak."',
      ];
      challengePool = [
        'Telefonunu 1 saat kenara koy ve sessizliğin tadını çıkar', '5 dakika derin nefes egzersizi yap',
        'Bugün için 1 şey yaz: bırakman gereken', 'Kendine güzel bir şey söyle — sesli olarak',
        'Bu gece erken yat ve kaliteli uyku al', 'Stres yapan 1 şeyi bugünlük bırak',
        'Sıcak bir duş al ve zihnini temizle', 'Sevdiğin bir anıyı düşün ve gülümse',
      ];
      doPool = ['Detaylara dikkat et', 'Kararları ertele ve düşün', 'İç sesini dinle', 'Sakin kal ve gözlemle', 'Enerjini koru', 'Sınırlarını belirle', 'Güvendiğin birine danış', 'Küçük hedefler koy'];
      dontPool = ['Büyük kararlar alma', 'Tartışmalara girme', 'Risk alma', 'Aceleci olma', 'Kontrolünü kaybetme', 'Gereksiz harcamalar yapma', 'Olumsuz düşüncelere kapılma', 'Kendini zorla'];
      activityPool = ['Meditasyon', 'Günlük yazma', 'Dinlenme', 'Okuma', 'Sıcak çay', 'Hafif yürüyüş', 'Nefes egzersizi', 'Müzik terapi'];
    } else {
      level = 'Riskli'; color = const Color(0xFFE53935); eBase = 0.2;
      advicePool = [
        'Bugün enerjiler karışık. Önemli kararları erteleyin, sakin kalın ve iç sesinizi dinleyin.',
        'Kozmik fırtına etkisi altındasınız. Kendinizi koruyun ve büyük adımlardan kaçının.',
        'Bugün derinden nefes alın ve sığınağınıza çekilin. Yarın güneş yeniden doğacak.',
        'Zorlayıcı bir gün olabilir — ama unutmayın, en güçlü çelik ateşte dövülür.',
        'Bugün düşük profilde kalın. Enerjinizi koruyun — yarın için biriktirin.',
        'Rüzgâr sert esiyor — yelkenlerinizi indirin ve fırtınanın geçmesini bekleyin.',
        'Bugün kendinize şefkat gösterin. Bazı günler sadece dayanmak bile kahramanlıktır.',
        'Kozmik enerjiler çalkantılı — güvenli limanda kalın ve sabırlı olun.',
      ];
      moodPool = [
        {'mood': 'Huzurlu', 'emoji': '🧘', 'desc': 'Sakinliğin en büyük gücün'},
        {'mood': 'Düşünceli', 'emoji': '🔮', 'desc': 'İçe dön, dinlen, hazırlan'},
        {'mood': 'Şefkatli', 'emoji': '🤲', 'desc': 'Kendine sevgi ve şefkat göster'},
        {'mood': 'Güçlü', 'emoji': '🔥', 'desc': 'İçsel gücünle bu günü de atlatacaksın'},
        {'mood': 'Kararlı', 'emoji': '💎', 'desc': 'Dayanıklılığın seni zirveye taşıyacak'},
        {'mood': 'Odaklı', 'emoji': '🎯', 'desc': 'Tek bir şeye odaklan ve hayatta kal'},
      ];
      affPool = [
        'Bu da geçecek — sen bundan da güçlüsün.', 'Fırtınalar en güçlü kökleri büyütür.',
        'Bugün kendini toparla, yarın parlayacaksın.', 'Durağanlık da bir güçtür — sabret.',
        'En karanlık gece bile şafağı getirir.', 'Güçlü insanlar zor günlerde şekillenir.',
        'Kırılganlığını kabul et — bu cesaret ister.', 'Bugün dinlen, yarın savaşırsın.',
      ];
      whisperPool = [
        'Yıldızlar diyor: "Bugün koru, yarın saldır."', 'Kozmik kalkan etrafında — güvendesin.',
        'Karanlık gece, en parlak yıldızları gösterir.', 'Evren sana dinlenme molası veriyor — kabul et.',
        'Ateşin külleri altında hâlâ yanıyor — sabret.', 'Gökyüzü kararsa da yıldızlar kaybolmaz.',
        'Kadim bilgelik: "Çekilmek de bir stratejidir."', 'Fırtına geçecek ve sen hâlâ ayakta olacaksın.',
      ];
      challengePool = [
        'Gün batımını izle ve bir dilek tut', 'Rahatlatıcı bir banyo yap veya sıcak çay iç',
        'Bugün sadece 1 iş yap, ama onu iyi yap', 'Sevdiğin bir anıyı hatırla ve gülümse',
        'Kendine sarıl — bazen en iyi destek sensin', 'Favori battaniyene sarıl ve film izle',
        'Bugün "hayır" deme cesaretini göster', 'Sessizce 3 şey say: hayatında iyi olan',
      ];
      doPool = ['Kendini koru ve dinlen', 'Sınırlarını belirle', 'Sevdiklerinin yanında ol', 'Erken yat', 'Rahatlatıcı aktiviteler yap', 'İçine dön ve meditasyon yap', 'Güvenli alanda kal', 'Enerjini koru'];
      dontPool = ['Büyük harcamalar yapma', 'Kendini aşırı yorma', 'Olumsuz insanlara zaman verme', 'Geçmişe takılma', 'Agresif kararlar alma', 'Tartışmalara girme', 'Sosyal medyada vakit harcama', 'Uykusuz kalma'];
      activityPool = ['Dinlenme', 'Meditasyon', 'Sıcak çay', 'Erken uyku', 'Hafif müzik', 'Sıcak banyo', 'Kitap okuma', 'Doğa sesleri'];
    }

    // Enerji — seviyeye uygun, günlük değişen
    final mE = (eBase + ((_h(1) % 30) / 100.0)).clamp(0.15, 0.98);
    final aE = (eBase + ((_h(2) % 28) / 100.0) - 0.05).clamp(0.15, 0.95);
    final eE = (eBase + ((_h(3) % 26) / 100.0) - 0.1).clamp(0.15, 0.90);

    return {
      'level': level, 'emoji': '', 'color': color,
      'score': (100 - rng).clamp(10, 100),
      'advice': advicePool[_h(12) % advicePool.length],
      'luckyHour': '${(_h(4) % 16 + 6).clamp(6, 21)}:00',
      'luckyActivity': activityPool[_h(5) % activityPool.length],
      'affirmation': affPool[_h(6) % affPool.length],
      'mood': moodPool[_h(7) % moodPool.length],
      'morningEnergy': mE, 'afternoonEnergy': aE, 'eveningEnergy': eE,
      'challenge': challengePool[_h(8) % challengePool.length],
      'whisper': whisperPool[_h(9) % whisperPool.length],
      'doAdvice': doPool[_h(10) % doPool.length],
      'dontAdvice': dontPool[_h(11) % dontPool.length],
    };
  }

  /// Batı burcu index → isim
  static String westernSignName(int monthDay) {
    if (monthDay >= 321 && monthDay <= 419) return 'Koç';
    if (monthDay >= 420 && monthDay <= 520) return 'Boğa';
    if (monthDay >= 521 && monthDay <= 620) return 'İkizler';
    if (monthDay >= 621 && monthDay <= 722) return 'Yengeç';
    if (monthDay >= 723 && monthDay <= 822) return 'Aslan';
    if (monthDay >= 823 && monthDay <= 922) return 'Başak';
    if (monthDay >= 923 && monthDay <= 1022) return 'Terazi';
    if (monthDay >= 1023 && monthDay <= 1121) return 'Akrep';
    if (monthDay >= 1122 && monthDay <= 1221) return 'Yay';
    if (monthDay >= 1222 || monthDay <= 119) return 'Oğlak';
    if (monthDay >= 120 && monthDay <= 218) return 'Kova';
    return 'Balık';
  }

  // ── FENG SHUİ VERİ KATMANI ──

  /// Element bazlı Feng Shui profili
  /// dominant: Bu elementin güçlü tarafı
  /// missing: Dengesi için eksik element / alan tavsiyesi
  /// supportEnergy: Seni destekleyen enerji tanımı
  /// drainEnergy: Seni yoran enerji tanımı
  /// colors: İdeal renkler (liste)
  /// materials: İdeal malzemeler
  /// shapes: Uygun formlar
  /// avoid: Kaçınılacaklar
  static const Map<String, Map<String, dynamic>> fengShuiElementProfile = {
    'Ağaç': {
      'dominant': 'Büyüme enerjisi — yaratıcı, vizyoner, ileri odaklı.',
      'missing': 'Metal dengesi zayıf. Yapı ve sınır eksikliği olabilir.',
      'supportEnergy': 'Açık ve ferah alanlar, doğal ışık, bitki örtüsü seni besler.',
      'drainEnergy': 'Dağınık, karanlık ve sıkışık ortamlar enerjiini yavaşlatır.',
      'miniAction': 'Masanda en az bir canlı bitki bulundur. Doğanın büyüme enerjisi sana güç verir.',
      'colors': ['Yeşil', 'Açık mavi', 'Turkuaz', 'Bej'],
      'materials': ['Ahşap', 'Bambu', 'Keten', 'Bitkisel lifler'],
      'shapes': ['Dikey uzun formlar', 'İnce sütunlar', 'Dal desenleri'],
      'avoid': 'Metal baskın dekor, fazla gri-beyaz, sert köşeli mobilyalar',
      'baguaFocus': 'Güneydoğu (Refah) ve Doğu (Aile & Sağlık) köşelerini aktif tut.',
      'idealSpace': 'Açık plan, yeşil dokunuşlar, pencere önü çalışma masası.',
    },
    'Ateş': {
      'dominant': 'Tutku ve dönüşüm enerjisi — lider, karizmatik, hareketli.',
      'missing': 'Su dengesi zayıf. Sakinleşme ve içe yönelme için alan gerekir.',
      'supportEnergy': 'Güneye bakan alanlar, sıcak tonlar, hareket ve ritim seni güçlendirir.',
      'drainEnergy': 'Kaotik, soğuk ve akışsız ortamlar tüketir. Fazla stimülasyon sinir eder.',
      'miniAction': 'Ortamında bir mum veya sıcak lamba yak; sembolik ateş enerjisi ilham verir.',
      'colors': ['Kırmızı', 'Turuncu', 'Mor', 'Pembe', 'Altın'],
      'materials': ['Deri', 'Yün', 'Kristal', 'Aydınlatma öğeleri'],
      'shapes': ['Yıldız', 'Üçgen', 'Sivri tepe formları'],
      'avoid': 'Çok fazla mavi/siyah, ağır perdeler, ayna karşı ayna',
      'baguaFocus': 'Güney (Şöhret & Tanınma) köşesi senin için en güçlü alan.',
      'idealSpace': 'Sıcak aydınlatma, canlı renk vurguları, sergi alanı.',
    },
    'Toprak': {
      'dominant': 'İstikrar ve besleyicilik enerjisi — güvenilir, dengeli, merkezi.',
      'missing': 'Ağaç enerjisi zayıf. Büyüme ve yenilik için akış gerekir.',
      'supportEnergy': 'Merkezi ve simetrik alanlar, toprak tonları, sağlam zeminler seni destekler.',
      'drainEnergy': 'Sürekli değişen, belirsiz ve kaotik ortamlar güvensizlik hissi yaratır.',
      'miniAction': 'Toprak enerjisini güçlendirmek için kristal veya taş bir nesneyi masanın üzerine ya da merkezi alana koy.',
      'colors': ['Kahve', 'Sarı', 'Bal rengi', 'Açık kiremit', 'Krem'],
      'materials': ['Taş', 'Seramik', 'Toprak kaplar', 'Ağır kumaşlar'],
      'shapes': ['Kare', 'Dikdörtgen', 'Yatay formlar'],
      'avoid': 'Çok fazla su elementi (akvaryum, büyük ayna), sürekli değişen dekor',
      'baguaFocus': 'Merkez (Sağlık) ve Kuzeydoğu (Bilgi) alanları seni besler.',
      'idealSpace': 'Simetrik yerleşim, sıcak zemin, istikrarlı mobilya düzeni.',
    },
    'Metal': {
      'dominant': 'Berraklık ve hassasiyet enerjisi — analitik, organize, net.',
      'missing': 'Ateş enerjisi zayıf. Yaratıcılık ve sıcaklık için renk gerekir.',
      'supportEnergy': 'Temiz, minimal ve düzenli alanlar zihni açar ve odaklar.',
      'drainEnergy': 'Dağınık, kirli ve gürültülü ortamlar kararlarını bulanıklaştırır.',
      'miniAction': 'Çalışma alanını tamamen sadeleştir. Her gereksiz eşyayı kaldır; zihin netliği için boşluk şart.',
      'colors': ['Beyaz', 'Gri', 'Gümüş', 'Krem', 'Açık altın'],
      'materials': ['Metal', 'Paslanmaz çelik', 'Krom', 'Beyaz mermer'],
      'shapes': ['Daire', 'Oval', 'Yuvarlak kenarlar', 'Simetri'],
      'avoid': 'Keskin kırmızı vurgular, kaotik desen, fazla organik form',
      'baguaFocus': 'Batı (Yaratıcılık & Çocuklar) ve Kuzeybatı (Destekçiler) senin güç bölgelerin.',
      'idealSpace': 'Minimalist, beyaz baskın, net çizgiler, az eşya.',
    },
    'Su': {
      'dominant': 'Akış ve bilgelik enerjisi — derin, sezgisel, gizemli.',
      'missing': 'Toprak enerjisi zayıf. İstikrar ve güvenlik hissi eksik olabilir.',
      'supportEnergy': 'Akışkan, esnek ve huzurlu alanlar seni besler. Sessizlik güç kaynağın.',
      'drainEnergy': 'Kalabalık, gürültülü ve sınında koşturanlar enerjiini bitirir.',
      'miniAction': 'Ortamına küçük bir çeşme, akvaryum veya su sesi çıkaran bir nesne ekle.',
      'colors': ['Siyah', 'Lacivert', 'Koyu mor', 'Antrasit', 'Koyu mavi'],
      'materials': ['Cam', 'Ayna', 'Su öğeleri', 'Parlak yüzeyler'],
      'shapes': ['Dalgalı', 'Asimetrik', 'Serbest form', 'Akim formları'],
      'avoid': 'Çok fazla toprak tonu, ağır taş objeler, aşırı düz çizgiler',
      'baguaFocus': 'Kuzey (Kariyer & Yaşam Yolu) köşesi senin için en güçlü alandır.',
      'idealSpace': 'Sakin, karanlık vurgular, yumuşak ışık, akıcı tekstiller.',
    },
  };

  /// Yin/Yang bazlı mekan önerileri
  static const Map<String, Map<String, dynamic>> fengShuiYinYang = {
    'Yin': {
      'state': 'İçe dönük · Sezgisel · Sakin',
      'risk': 'Çok fazla Yin: içe kapanma, aşırı pasiflik, dinginliğin durağanlığa dönüşmesi.',
      'spaceNeed': 'Sessiz köşeler, yumuşak ışık, doğal dokular ve dinlendirici renkler.',
      'activate': 'Dengelenmek için biraz Yang enerjisi ekle: Pencereyi aç, aydınlatmayı artır veya sıcak bir renk vurgusu kullan.',
      'lightTip': 'Sabah gün ışığını içeri al — perde açmak bile enerjiyi canlandırır.',
      'soundTip': 'Hafif müzik veya doğa sesi çal; sessizliği kır ama çok gürültü yaratma.',
      'declutter': 'Yatak odasındaki gereksiz eşyaları kaldır — Yin dinlenme alanı saf kalmalı.',
      'color': 'Pastel tonlar, gümüş, açık mavi, lavanta.',
      'weekly': [
        'Girişinizi temizle ve aydınlat — enerji buradan girer.',
        'Oturma alanına bir sıcak ışık kaynağı ekle.',
        'Çalışma masandaki gereksiz kâğıtları topla.',
        'Kuzey yönündeki köşenizi aktif tut — kariyer enerjisi.',
        'Bir bitki ya da çiçek seç, canlı element ekle.',
        'Eski/kullanılmayan eşyayı çıkar — enerji akışını aç.',
        'Pencereleri temizle — netlik enerjisi gelsin.',
      ],
    },
    'Yang': {
      'state': 'Dışa dönük · Aktif · Enerjik',
      'risk': 'Çok fazla Yang: tükenmişlik, sabırsızlık, kaos ve dağılma riski.',
      'spaceNeed': 'Düzenli, sadeleştirilmiş alanlar; rahatlama köşesi; sessizlik adaları.',
      'activate': 'Biraz Yin enerji eklemek için tonları koyulaştır, ses yalıtımı ekle, akış köşesi yarat.',
      'lightTip': 'Akşam mavi ışıktan kaç; ambar ve sarı tonda ışık sinir sistemini sakinleştirir.',
      'soundTip': 'Gün içinde en az 10 dakika tam sessizlikte otur; zihni yavaşlatır.',
      'declutter': 'Girişini ve çalışma masanı sadeleştir — Yang insanlar bu alanlarda kaotik olur.',
      'color': 'Koyu, toprak tonları, lacivert, derin yeşil.',
      'weekly': [
        'Çalışma masasını komple sadeleştir — sadece bugünün işi kalsın.',
        'Yatak odasına elektronik sokma veya uzak tut.',
        'Batı köşene (Yaratıcılık) küçük bir obje koy.',
        'Zararlı "enerji sızdıran" dağınıklığı temizle.',
        'Bir oturma köşesi belirle ve yalnızca dinlenmeye ayır.',
        'Güney yönünü aktif tut — görünürlük ve başarı.',
        'Akşam ortamını koyulaştır, geçiş ritüeli yarat.',
      ],
    },
  };

  /// Hedef bazlı Bagua önerileri
  /// Kullanıcı hedef seçer → hangi köşe, ne koyulur, ne uzaklaştırılır
  static const Map<String, Map<String, String>> baguaGoals = {
    'Para': {
      'emoji': '💰',
      'bagua': 'Güneydoğu — Zenginlik & Bolluk',
      'activate': 'Canlı bitki, mor veya mor tonlu kristal, akan su sembolü.',
      'remove': 'Bozuk eşya, tıkayan mobilya, boş kaplar.',
      'tip': 'Güneydoğu köşesine sağlıklı bir bitki koy. Büyüyen bitki büyüyen refahı simgeler.',
      'color': 'Mor · Yeşil · Altın',
    },
    'Aşk': {
      'emoji': '💕',
      'bagua': 'Güneybatı — İlişkiler & Aşk',
      'activate': 'Çift objeler (iki mum, iki taş), pembe veya kırmızı kristal, çifti simgeleyen şeyler.',
      'remove': 'Yalnızlık hissettiren objeler, kırık veya tek kalan öğeler.',
      'tip': 'Güneybatı köşesine pembe kuvars kristali koy. Kalp enerjisini çeker.',
      'color': 'Pembe · Kırmızı · Beyaz',
    },
    'Kariyer': {
      'emoji': '💼',
      'bagua': 'Kuzey — Kariyer & Yaşam Yolu',
      'activate': 'Su elementi (küçük çeşme, ayna), siyah veya lacivert vurgular.',
      'remove': 'Durgun su izlenimi, tıkayan mobilya, eski iş eşyaları.',
      'tip': 'Kuzey yönündeki masanda bir ayna veya cam obje bulundur.',
      'color': 'Siyah · Lacivert · Gri',
    },
    'Huzur': {
      'emoji': '☮️',
      'bagua': 'Merkez — Sağlık & Denge',
      'activate': 'Sarı veya bej objeler, kristaller, simetrik yerleşim.',
      'remove': 'Dağınıklık, akımı kesen mobilyalar, karanlık köşeler.',
      'tip': 'Evin merkezini temiz ve açık tut. Gelen enerji oradan tüm odalara dağılır.',
      'color': 'Sarı · Bej · Kahve',
    },
    'Sağlık': {
      'emoji': '🌿',
      'bagua': 'Doğu — Aile & Sağlık',
      'activate': 'Canlı bitkiler, ahşap dokunuşlar, yeşil tonlar.',
      'remove': 'Ölü bitkiler, soluk çiçekler, kırık eşyalar.',
      'tip': 'Doğu köşesine sağlıklı veya taze bir bitki koy. Karaciğer enerjisini destekler.',
      'color': 'Yeşil · Açık mavi · Bej',
    },
  };

  /// Hayvan burç bazlı Feng Shui güç profili
  static const List<Map<String, dynamic>> animalFengShui = [
    // 0 - Sıçan
    {'animalEmoji': '🐀', 'supportEl': 'Su', 'avoidEnergy': 'Aşırı toprak ve ağır kütle',
     'spaceVibe': 'Zeki ve çevik enerjin için esnek, çok fonksiyonlu alanlar idealdir.',
     'workSpace': 'Gizli köşe, araştırma masası, kuzey yönü güçlü.',
     'loveSpace': 'Yumuşak ışık, akıcı tekstil, yakın oturma düzeni.',
     'powerCorner': 'Kuzey', 'powerColor': 'Lacivert · Gri · Gümüş'},
    // 1 - Öküz
    {'animalEmoji': '🐂', 'supportEl': 'Toprak', 'avoidEnergy': 'Kaos ve düzensizlik',
     'spaceVibe': 'İstikrarlı ve sağlam enerji için simetrik, düzenli mekanlar idealdır.',
     'workSpace': 'Sağlam masa, düzenli raf, güneydoğu çalışma açısı.',
     'loveSpace': 'Sıcak, samimi ve konforlu bir köşe. Masif ahşap mobilya.',
     'powerCorner': 'Kuzeydoğu', 'powerColor': 'Kahve · Sarı · Bej'},
    // 2 - Kaplan
    {'animalEmoji': '🐯', 'supportEl': 'Ağaç', 'avoidEnergy': 'Kapalı ve kısıtlayıcı alanlar',
     'spaceVibe': 'Enerjik ve iddialı doğan için açık alan, yüksek tavan, güçlü aydınlatma.',
     'workSpace': 'Büyük masa, doğuya bakan açı, cesur renk vurguları.',
     'loveSpace': 'Sıcak ve çekici, mum ışığı, kahverengi-kırmızı tonlar.',
     'powerCorner': 'Doğu', 'powerColor': 'Yeşil · Siyah · Lacivert'},
    // 3 - Tavşan
    {'animalEmoji': '🐰', 'supportEl': 'Ağaç', 'avoidEnergy': 'Sert, gürültülü ve kaba enerji',
     'spaceVibe': 'Hassas ve estetik ruhun için yumuşak, huzurlu ve güzel bir ortam şart.',
     'workSpace': 'Estetik, düzenli, hafif yeşil dokunuşlu, sessiz köşe.',
     'loveSpace': 'Çiçek, yumuşak tekstil, pastel tonlar, güneybatı köşesi.',
     'powerCorner': 'Doğu', 'powerColor': 'Yeşil · Pembe · Bej'},
    // 4 - Ejderha
    {'animalEmoji': '🐉', 'supportEl': 'Ağaç & Ateş', 'avoidEnergy': 'Küçük ve sıkışık alanlar',
     'spaceVibe': 'Güçlü ve karizmatik enerjin için büyük formlar, lider estetiği.',
     'workSpace': 'İddialı masa, yüksek koltuk, güney yönü, siyah-altın kombinasyonu.',
     'loveSpace': 'Dramatik, koyulaştırılmış tablo, derin renk, güçlü ambiyans.',
     'powerCorner': 'Güneydoğu', 'powerColor': 'Altın · Kırmızı · Yeşil'},
    // 5 - Yılan
    {'animalEmoji': '🐍', 'supportEl': 'Ateş', 'avoidEnergy': 'Dağınık ve gürültülü ortamlar',
     'spaceVibe': 'Derin ve gizemli enerjin için minimal, sofistike, özenle seçilmiş objeler.',
     'workSpace': 'Sezgi masası, özenle seçilmiş obje, güney-batı arası.',
     'loveSpace': 'Aydınlatma sanatı, örtük çekicilik, koyu kırmızı vurgular.',
     'powerCorner': 'Güney', 'powerColor': 'Kırmızı · Turuncu · Sarı'},
    // 6 - At
    {'animalEmoji': '🐴', 'supportEl': 'Ateş', 'avoidEnergy': 'Kısıtlayan ve dar mekanlar',
     'spaceVibe': 'Özgür ve enerjik ruhun için açık, aydınlık, hareket alanı olan mekanlar.',
     'workSpace': 'Ayakta çalışma seçeneği, açık alan, koşu izni olan düzen.',
     'loveSpace': 'Neşeli, sıcak, hareketli bir köşe. Turuncu-pembe dokunuşlar.',
     'powerCorner': 'Güney', 'powerColor': 'Kırmızı · Turuncu · Sarı'},
    // 7 - Keçi
    {'animalEmoji': '🐐', 'supportEl': 'Toprak', 'avoidEnergy': 'Yalnız ve soğuk alanlar',
     'spaceVibe': 'Yaratıcı ve hassas enerjin için estetik, sanatsal ve huzurlu mekanlar.',
     'workSpace': 'Sanat köşesi, yumuşak ışık, toprak tonlu yaratıcı masa.',
     'loveSpace': 'Romantik, çiçekli, yumuşak halı, güneybatı köşe.',
     'powerCorner': 'Güneybatı', 'powerColor': 'Sarı · Kahve · Pembe'},
    // 8 - Maymun
    {'animalEmoji': '🐒', 'supportEl': 'Metal', 'avoidEnergy': 'Monoton ve hareketsiz alanlar',
     'spaceVibe': 'Zeki ve dinamik enerjin için çok katmanlı, ilginç ve çeşitli mekanlar.',
     'workSpace': 'Araçları el altında, beyaz tahta ya da not alanı, batı yönü.',
     'loveSpace': 'Eğlenceli, renkli, sürpriz bir köşe. Oyunbaz ama şık.',
     'powerCorner': 'Batı', 'powerColor': 'Beyaz · Gümüş · Mavi'},
    // 9 - Horoz
    {'animalEmoji': '🐓', 'supportEl': 'Metal', 'avoidEnergy': 'Düzensiz ve dağınık alanlar',
     'spaceVibe': 'Mükemmeliyetçi enerjin için her şeyin yerli yerinde olduğu düzenli mekanlar.',
     'workSpace': 'Simetrik masa, organize raf, batı yönü, gümüş vurgular.',
     'loveSpace': 'Temiz, zarif, sade ama etkileyici köşe.',
     'powerCorner': 'Batı', 'powerColor': 'Beyaz · Altın · Gümüş'},
    // 10 - Köpek
    {'animalEmoji': '🐕', 'supportEl': 'Toprak', 'avoidEnergy': 'Güvensiz ve değişken alanlar',
     'spaceVibe': 'Sadık ve güvenilir enerjin için sıcak, tutarlı ve güvenli mekanlar.',
     'workSpace': 'İstikrarlı, sıcak aydınlatmalı, güvenilir malzeme seçimi.',
     'loveSpace': 'Samimi ve sıcak; köy sadeliği, kahve tonları, birlikte köşesi.',
     'powerCorner': 'Kuzeybatı', 'powerColor': 'Kahve · Toprak · Sarı'},
    // 11 - Domuz
    {'animalEmoji': '🐷', 'supportEl': 'Su', 'avoidEnergy': 'Sert ve agresif objeler',
     'spaceVibe': 'Neşeli ve cömert enerjin için hoş, konforlu ve davetkar mekanlar.',
     'workSpace': 'Konforlu ve iyi aydınlatılmış, sizi mutlu eden obje seçimi.',
     'loveSpace': 'Güzel, romantik, lüks dokunuşlar — pembe veya koyu kırmızı.',
     'powerCorner': 'Kuzey', 'powerColor': 'Lacivert · Gri · Sarı'},
  ];

  /// Haftalık feng shui görevi — element bazlı (7 görev)
  static Map<String, String> weeklyFengShuiTask(String element, String yinYang) {
    final tasks = fengShuiElementProfile[element]!;
    final yyTasks = fengShuiYinYang[yinYang]!;
    final today = DateTime.now();
    final dayIdx = today.weekday - 1; // 0-6
    final allTasks = (yyTasks['weekly'] as List<String>);
    return {
      'task': allTasks[dayIdx % allTasks.length],
      'area': (tasks['baguaFocus'] as String).split(' ')[0],
      'color': (tasks['colors'] as List<String>).first,
    };
  }
}

