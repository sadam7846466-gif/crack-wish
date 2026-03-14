import 'dart:ui' show Color;

/// Çin Astrolojisi - Kapsamlı Veri Modeli
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
      'personality': 'Sıçan yılında doğanlar doğal liderlerdir. Zekâları ve çevikliğiyle dikkat çekerler. Her durumda ayakta kalma becerisine sahiplerdir.',
      'love': 'Aşkta duygusal ve sadık. Partneri için fedakarlık yapar ama duygularını göstermekte zorlanır.',
      'bestMatch': [4, 8], // Ejderha, Maymun
      'goodMatch': [1, 6], // Öküz, At  
      'conflict': [6, 3], // At, Tavşan
      'careers': ['Finans Uzmanı', 'Girişimci', 'Muhasebeci', 'Avukat', 'Yazar'],
      'careerAdvice': 'Analitik zekanız finansta parlıyor. Girişimcilik ve danışmanlık alanlarında büyük başarı potansiyeli. Risk almayı sevsiniz ama kontrolü elden bırakmayın.',
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
      'personality': 'Öküz yılında doğanlar sarsılmaz bir iradeye sahiptir. Hedeflerine ulaşmak için azimle çalışırlar ve etraflarına güven verirler.',
      'love': 'Aşkta sadık ve güvenilir. Uzun vadeli ilişkilere değer verir. Duygularını göstermekte ağır kalır ama sevgisi derindir.',
      'bestMatch': [5, 9], // Yılan, Horoz
      'goodMatch': [0, 3], // Sıçan, Tavşan
      'conflict': [6, 7], // At, Keçi
      'careers': ['Mühendis', 'Çiftçi', 'Bankacı', 'Mimar', 'Cerrah'],
      'careerAdvice': 'Sabrınız ve detaycılığınız mühendislik ve mimarlıkta sizi öne çıkarır. Uzun vadeli projeler sizin için idealdir.',
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
      'personality': 'Kaplan yılında doğanlar doğuştan cesurdur. Güçlü kişilikleri ve tutkuları onları etkileyici kılar.',
      'love': 'Aşkta tutkulu ve koruyucu. Partnerini bir kraliçe/kral gibi korur. Bağımsızlığına düşkündür.',
      'bestMatch': [6, 10], // At, Köpek
      'goodMatch': [4, 8], // Ejderha, Maymun
      'conflict': [8, 5], // Maymun, Yılan
      'careers': ['Asker', 'Komutan', 'CEO', 'Sporcu', 'Gazeteci'],
      'careerAdvice': 'Liderlik kabiliyetiniz sizi yöneticilik pozisyonlarına taşır. Rekabetçi alanlarda öne çıkarsınız.',
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
      'personality': 'Tavşan yılında doğanlar incelik ve zerafet timsalidir. Barışçıl ruhları ve güçlü sezgileriyle çevrelerine huzur getirirler.',
      'love': 'Aşkta romantik ve zarif. Uyumlu ve huzurlu ilişkiler arar. Çatışmadan kaçınır.',
      'bestMatch': [7, 11], // Keçi, Domuz
      'goodMatch': [1, 10], // Öküz, Köpek
      'conflict': [9, 0], // Horoz, Sıçan
      'careers': ['Sanatçı', 'Diplomat', 'Psikolog', 'Tasarımcı', 'Müzisyen'],
      'careerAdvice': 'Sanatsal yeteneğiniz ve diplomatik beceriniz sizi yaratıcı sektörlerde öne çıkarır.',
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
      'personality': 'Ejderha yılında doğanlar en şanslı burç olarak kabul edilir. Güçlü ve karizmatik kişilikleriyle doğal liderlerdir.',
      'love': 'Aşkta tutkulu ve dominant. Güçlü bir partner ister. Sevgisini büyük jestlerle gösterir.',
      'bestMatch': [0, 8], // Sıçan, Maymun
      'goodMatch': [2, 9], // Kaplan, Horoz
      'conflict': [10, 1], // Köpek, Öküz
      'careers': ['Politikacı', 'CEO', 'Yatırımcı', 'Sanatçı', 'Lider'],
      'careerAdvice': 'Büyük düşünün! Liderlik pozisyonları sizin için biçilmiş kaftan. Girişimcilik ve yatırım alanlarında şansınız yüksek.',
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
      'personality': 'Yılan yılında doğanlar derin bilgelik taşır. Güçlü sezgileri ve analitik düşünceleriyle dikkat çekerler.',
      'love': 'Aşkta gizemli ve derin. Tam güvenmedikçe kalbini açmaz. Ama sevince sonsuz sadakatle bağlanır.',
      'bestMatch': [1, 9], // Öküz, Horoz
      'goodMatch': [4, 0], // Ejderha, Sıçan
      'conflict': [2, 11], // Kaplan, Domuz
      'careers': ['Bilim İnsanı', 'Filozof', 'Psikolog', 'Dedektif', 'Danışman'],
      'careerAdvice': 'Analitik zekânız araştırma ve danışmanlıkta sizi parlak kılar. Stratejik planlama sizin güçlü yanınız.',
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
      'personality': 'At yılında doğanlar özgürlük aşığıdır. Sınırsız enerjileri ve neşeli kişilikleriyle her ortamın yıldızı olurlar.',
      'love': 'Aşkta heyecan ve macera arar. Bağımsızlığına düşkün, ama doğru kişiyi bulunca tam bağlanır.',
      'bestMatch': [2, 10], // Kaplan, Köpek
      'goodMatch': [7, 11], // Keçi, Domuz
      'conflict': [0, 1], // Sıçan, Öküz
      'careers': ['Sporcu', 'Pilot', 'Satıcı', 'Komedyen', 'Rehber'],
      'careerAdvice': 'Enerjiniz ve sosyalliğiniz sizi satış, spor ve eğlence sektöründe parlak kılar. Masabaşı işlerden kaçının.',
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
      'personality': 'Keçi yılında doğanlar sanatsal ruha sahiptir. Yaratıcılıkları ve hassas ruhları onları benzersiz kılar.',
      'love': 'Aşkta romantik ve duygusal. Güven ve sıcaklık arar. Koruma altında hissedildikçe açılır.',
      'bestMatch': [3, 11], // Tavşan, Domuz
      'goodMatch': [6, 2], // At, Kaplan
      'conflict': [1, 10], // Öküz, Köpek
      'careers': ['Ressam', 'Müzisyen', 'Terapi Uzmanı', 'Aşçı', 'Tasarımcı'],
      'careerAdvice': 'Sanatsal yetenekleriniz ve şefkatiniz yaratıcı mesleklerde ve sağlık sektöründe sizi öne çıkarır.',
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
      'personality': 'Maymun yılında doğanlar parlak zekâları ve esprili kişilikleriyle tanınır. Problem çözme yetenekleri üstündür.',
      'love': 'Aşkta eğlenceli ve heyecanlı. Sıkılmaktan korkar. Zeki ve esprili bir partner arar.',
      'bestMatch': [0, 4], // Sıçan, Ejderha
      'goodMatch': [5, 11], // Yılan, Domuz
      'conflict': [2, 11], // Kaplan, Domuz
      'careers': ['Yazılımcı', 'Stand-up Komedyen', 'Mühendis', 'Mucit', 'Pazarlamacı'],
      'careerAdvice': 'Hızlı zekanız teknoloji ve yaratıcı sektörlerde sizi parlak kılar. Sıkıcı rutinlerden kaçının.',
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
      'personality': 'Horoz yılında doğanlar mükemmeliyetçi ve detaycıdır. Keskin gözlem yetenekleri ve çalışkanlıklarıyla başarıya ulaşırlar.',
      'love': 'Aşkta dürüst ve doğrudan. net iletişim kurar ama bazen aşırı eleştirel olabilir.',
      'bestMatch': [1, 5], // Öküz, Yılan
      'goodMatch': [4, 8], // Ejderha, Maymun
      'conflict': [3, 10], // Tavşan, Köpek
      'careers': ['Askeri Komutan', 'Gazeteci', 'Cerrah', 'Kalite Kontrolcü', 'Polis'],
      'careerAdvice': 'Detaycılığınız ve organizasyon beceriniz kalite kontrol ve yönetim alanlarında sizi vazgeçilmez kılar.',
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
      'personality': 'Köpek yılında doğanlar en sadık ve güvenilir ruhlardır. Dürüstlükleri ve adalet duyguları güçlüdür.',
      'love': 'Aşkta sadık ve koruyucu. Güven en önemli değeridir. Sevdiklerini her koşulda savunur.',
      'bestMatch': [2, 6], // Kaplan, At
      'goodMatch': [3, 11], // Tavşan, Domuz
      'conflict': [4, 9], // Ejderha, Horoz
      'careers': ['Avukat', 'Polis', 'Doktor', 'Öğretmen', 'Sosyal Hizmet Uzmanı'],
      'careerAdvice': 'Adalet duygunuz ve sadakatiniz hukuk, güvenlik ve eğitim alanlarında sizi güçlü kılar.',
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
      'personality': 'Domuz yılında doğanlar cömertlik ve şefkatin simgesidir. Sıcak kişilikleri ve neşeli ruhlarıyla herkesi mutlu ederler.',
      'love': 'Aşkta sıcak ve cömert. Sevgisini bolca gösterir. Güvene çok değer verir.',
      'bestMatch': [3, 7], // Tavşan, Keçi
      'goodMatch': [2, 6], // Kaplan, At
      'conflict': [5, 8], // Yılan, Maymun
      'careers': ['Aşçı', 'Hayırsever', 'Hemşire', 'Veteriner', 'Otelci'],
      'careerAdvice': 'Sıcaklığınız ve cömertliğiniz hizmet sektörü ve sağlık alanında sizi sevilen biri yapar.',
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

  /// Güne göre şans hesapla (basit ama etkili algoritma)
  static Map<String, dynamic> getDayFortune(int animalIndex, DateTime date) {
    final seed = date.year * 1000 + date.month * 100 + date.day + animalIndex * 7;
    final rng = seed % 100;
    String level;
    String emoji;
    Color color;
    String advice;

    if (rng < 15) {
      level = 'Çok Şanslı';
      emoji = '🌟';
      color = const Color(0xFFFFD700);
      advice = 'Bugün yıldızlar sizden yana! Büyük kararlar almak ve yeni başlangıçlar için ideal bir gün.';
    } else if (rng < 40) {
      level = 'Şanslı';
      emoji = '✨';
      color = const Color(0xFF4CAF50);
      advice = 'Pozitif enerji yüksek. Planlarınızı hayata geçirin ve fırsatları değerlendirin.';
    } else if (rng < 65) {
      level = 'Normal';
      emoji = '☁️';
      color = const Color(0xFF78909C);
      advice = 'Dengeli bir gün. Rutininize sadık kalın ve küçük adımlarla ilerleyin.';
    } else if (rng < 85) {
      level = 'Dikkatli Ol';
      emoji = '⚠️';
      color = const Color(0xFFFF9800);
      advice = 'Bugün biraz temkinli olun. Büyük kararları erteleyin ve detaylara dikkat edin.';
    } else {
      level = 'Riskli';
      emoji = '🔴';
      color = const Color(0xFFE53935);
      advice = 'Bugün enerjiler karışık. Önemli kararları erteleyin, sakin kalın ve iç sesinizi dinleyin.';
    }

    return {
      'level': level,
      'emoji': emoji,
      'color': color,
      'score': (100 - rng).clamp(10, 100),
      'advice': advice,
      'luckyHour': '${(seed % 12 + 6).clamp(6, 21)}:00',
      'luckyActivity': ['Meditasyon', 'Yürüyüş', 'Toplantı', 'Yazı yazma', 'Spor', 'Alışveriş', 'Yemek yapma'][seed % 7],
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
}
