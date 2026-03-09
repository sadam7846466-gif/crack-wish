import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../widgets/glass_back_button.dart';
import '../services/storage_service.dart';

/// Batı Zodyak Sayfası — "Ben nasıl biriyim?"
/// Psikolojik yorum, kişilik analizi, hayat alanları, uyum
class ZodiacPage extends StatefulWidget {
  const ZodiacPage({super.key});
  @override
  State<ZodiacPage> createState() => _ZodiacPageState();
}

class _ZodiacPageState extends State<ZodiacPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  int _selectedIndex = 0; // Varsayılan: Koç
  String? _userName;

  static const Color _gold = Color(0xFFFFD060);
  static const Color _goldL = Color(0xFFFFE8A1);
  static const Color _goldD = Color(0xFFB07020);
  static const Color _bg = Color(0xFF0F1210);

  // ── TAM 12 BURÇ VERİTABANI ──
  static const List<Map<String, dynamic>> _signs = [
    {
      'symbol': '♈', 'name': 'Koç', 'nameEn': 'Aries', 'image': 'assets/images/zodiac_signs/aries.png',
      'dates': '21 Mart - 19 Nisan',
      'element': 'Ateş', 'elementEmoji': '🔥',
      'planet': 'Mars', 'planetEmoji': '♂️',
      'quality': 'Öncü', 'qualityEmoji': '⚡',
      'traits': ['Cesur', 'Enerjik', 'Girişken', 'Tutkulu', 'Kararlı', 'Lider'],
      'strengths': ['Doğal liderlik', 'Cesaret ve atılganlık', 'Girişimci ruh'],
      'weaknesses': ['Sabırsızlık', 'Düşünmeden hareket', 'Hırslı olma'],
      'description': 'Koç burcu, Zodyak\'ın ilk ve en ateşli başlangıcıdır. Mars\'ın yönetimindeki bu burç, liderlik, cesaret ve eyleme geçme gücünü temsil eder. Koç bireyler doğuştan öncüdür; bilinmeyenden korkmazlar, aksine ona doğru koşarlar. Her yeni durumda ilk adımı atan, enerji ve tutku dolu ruhlardır.',
      'love': 'Aşkta tutkulu ve yoğun. Partnerine sadık ama bağımsızlığına düşkün. İlk adımı her zaman kendisi atar.',
      'career': 'Doğal lider. Girişimcilik, yöneticilik ve rekabete dayalı alanlarda parlıyor.',
      'compatibility': {'En Uyumlu': 'Aslan, Yay', 'İyi Uyum': 'İkizler, Kova', 'Zorlayıcı': 'Yengeç, Oğlak'},
      'luckyNumber': '1, 9', 'luckyColor': 'Kırmızı', 'luckyDay': 'Salı',
      'dailyHoroscope': 'Bugün enerjin doruklarda. Ertelediğin o cesur adımı atmak için mükemmel bir gün. Mars sana güç veriyor, harekete geç!',
    },
    {
      'symbol': '♉', 'name': 'Boğa', 'nameEn': 'Taurus', 'image': 'assets/images/zodiac_signs/taurus.png',
      'dates': '20 Nisan - 20 Mayıs',
      'element': 'Toprak', 'elementEmoji': '🌍',
      'planet': 'Venüs', 'planetEmoji': '♀️',
      'quality': 'Sabit', 'qualityEmoji': '⚓',
      'traits': ['Güvenilir', 'Sabırlı', 'Kararlı', 'Sadık', 'Estetik', 'Pratik'],
      'strengths': ['Sarsılmaz irade', 'Maddi güvenlik', 'Sanatsal hassasiyet'],
      'weaknesses': ['İnatçılık', 'Değişime direnç', 'Aşırı sahiplenme'],
      'description': 'Boğa, Zodyak\'ın en kararlı ve güvenilir burcudur. Venüs\'ün zarif dokunuşuyla güzellik, konfor ve maddi güvenliğe değer verir. Sabırla hedeflerine ulaşır, sözünde durur ve sevdiklerine sıkıca bağlanır. Doğanın ve sanatın tadını çıkaran, ayakları yere basan bir ruhtur.',
      'love': 'Aşkta sadık ve romantik. Güven ve istikrar arar. Partnerini şımartmayı sever.',
      'career': 'Finans, sanat, gastronomi ve mimarlıkta başarılı. Uzun vadeli planlar yapar.',
      'compatibility': {'En Uyumlu': 'Başak, Oğlak', 'İyi Uyum': 'Yengeç, Balık', 'Zorlayıcı': 'Aslan, Kova'},
      'luckyNumber': '2, 6', 'luckyColor': 'Yeşil', 'luckyDay': 'Cuma',
      'dailyHoroscope': 'Bugün iç huzurunu bul. Doğada vakit geçirmek ya da sevdiğin bir sanat eserine odaklanmak ruhunu besleyecek.',
    },
    {
      'symbol': '♊', 'name': 'İkizler', 'nameEn': 'Gemini', 'image': 'assets/images/zodiac_signs/gemini.png',
      'dates': '21 Mayıs - 20 Haziran',
      'element': 'Hava', 'elementEmoji': '💨',
      'planet': 'Merkür', 'planetEmoji': '☿',
      'quality': 'Değişken', 'qualityEmoji': '🔄',
      'traits': ['Meraklı', 'Zeki', 'Sosyal', 'Esnek', 'İletişimci', 'Çok Yönlü'],
      'strengths': ['Hızlı öğrenme', 'İletişim becerisi', 'Uyum yeteneği'],
      'weaknesses': ['Kararsızlık', 'Yüzeysellik', 'Çabuk sıkılma'],
      'description': 'İkizler, zihinsel çevikliğin ve iletişimin burcudur. Merkür\'ün hızıyla düşünen bu burç, her konuyla ilgilenir, her ortama uyum sağlar. Sosyal kelebekler olarak tanınırlar; sohbetleri her zaman ilgi çekici ve bilgilendiricidir. İki yüzlü değil, çok yönlüdürler.',
      'love': 'Aşkta eğlenceli ve entelektüel bağ arar. Sıkıcı rutinden kaçınır, zihinsel uyum şarttır.',
      'career': 'Medya, yazarlık, pazarlama ve eğitimde parlıyor. Aynı anda birden fazla projeyi yönetir.',
      'compatibility': {'En Uyumlu': 'Terazi, Kova', 'İyi Uyum': 'Koç, Aslan', 'Zorlayıcı': 'Başak, Balık'},
      'luckyNumber': '5, 7', 'luckyColor': 'Sarı', 'luckyDay': 'Çarşamba',
      'dailyHoroscope': 'Bugün zihnin berrak, fikirlerin parlak. Yeni bağlantılar kurmak ve yaratıcı projeler için ideal bir gün.',
    },
    {
      'symbol': '♋', 'name': 'Yengeç', 'nameEn': 'Cancer', 'image': 'assets/images/zodiac_signs/cancer.png',
      'dates': '21 Haziran - 22 Temmuz',
      'element': 'Su', 'elementEmoji': '💧',
      'planet': 'Ay', 'planetEmoji': '🌙',
      'quality': 'Öncü', 'qualityEmoji': '⚡',
      'traits': ['Duygusal', 'Koruyucu', 'Sezgisel', 'Sadık', 'Şefkatli', 'Empatik'],
      'strengths': ['Derin empati', 'Aile bağları', 'Güçlü sezgiler'],
      'weaknesses': ['Aşırı duygusallık', 'Geçmişe takılma', 'Kabuğuna çekilme'],
      'description': 'Yengeç, Zodyak\'ın en duygusal ve koruyucu burcudur. Ay\'ın etkisiyle duyguları derin, sezgileri güçlüdür. Sevdiklerini kabuğunun altında korur, yuvasını bir sığınak gibi yaratır. Gözyaşlarının altında bir okyanus kadar güç taşır.',
      'love': 'Aşkta derin bağlanır. Güven ve sıcaklık arar. Partneri için her şeyi yapar.',
      'career': 'Sağlık, eğitim, psikoloji ve aşçılıkta başarılı. İnsanlara yardım eden alanlarda parlıyor.',
      'compatibility': {'En Uyumlu': 'Akrep, Balık', 'İyi Uyum': 'Boğa, Başak', 'Zorlayıcı': 'Koç, Terazi'},
      'luckyNumber': '2, 7', 'luckyColor': 'Gümüş', 'luckyDay': 'Pazartesi',
      'dailyHoroscope': 'Bugün iç dünyana dön. Sezgilerin seni doğru yöne çekiyor. Sevdiklerinle vakit geçirmek ruhunu onaracak.',
    },
    {
      'symbol': '♌', 'name': 'Aslan', 'nameEn': 'Leo', 'image': 'assets/images/zodiac_signs/leo.png',
      'dates': '23 Temmuz - 22 Ağustos',
      'element': 'Ateş', 'elementEmoji': '🔥',
      'planet': 'Güneş', 'planetEmoji': '☀️',
      'quality': 'Sabit', 'qualityEmoji': '⚓',
      'traits': ['Özgüvenli', 'Lider Ruhlu', 'Cömert', 'Yaratıcı', 'Tutkulu', 'Sadık'],
      'strengths': ['Doğal karizma', 'Yaratıcı güç', 'Cömertlik'],
      'weaknesses': ['Gurur', 'Dikkat beklentisi', 'Otoriter tavır'],
      'description': 'Aslan, Zodyak\'ın kralıdır. Güneş\'in ışığını taşıyan bu burç, sahneye çıktığı anda tüm dikkatleri üzerine çeker. Cömert, sadık ve yaratıcı bir ruhtur. Etrafındakilere enerji verir, ilham kaynağı olur. Liderliği doğasında vardır.',
      'love': 'Aşkta tutkulu ve romantik. Hayranlık ve sadakat bekler. Partnerini bir kral gibi korur.',
      'career': 'Sanat, sahne, yöneticilik ve girişimcilikte parlıyor. Spot ışığı altında en iyisi.',
      'compatibility': {'En Uyumlu': 'Koç, Yay', 'İyi Uyum': 'İkizler, Terazi', 'Zorlayıcı': 'Boğa, Akrep'},
      'luckyNumber': '1, 4', 'luckyColor': 'Altın', 'luckyDay': 'Pazar',
      'dailyHoroscope': 'Bugün yaratıcılığının zirvesinde olacaksın. İçindeki ateşi hisset ve liderliği ele almaktan çekinme. Güneş senin için parlıyor!',
    },
    {
      'symbol': '♍', 'name': 'Başak', 'nameEn': 'Virgo', 'image': 'assets/images/zodiac_signs/virgo.png',
      'dates': '23 Ağustos - 22 Eylül',
      'element': 'Toprak', 'elementEmoji': '🌍',
      'planet': 'Merkür', 'planetEmoji': '☿',
      'quality': 'Değişken', 'qualityEmoji': '🔄',
      'traits': ['Analitik', 'Düzenli', 'Detaycı', 'Mükemmeliyetçi', 'Yardımsever', 'Pratik'],
      'strengths': ['Analitik zekâ', 'Düzen ve organizasyon', 'Hizmet ruhu'],
      'weaknesses': ['Aşırı eleştirellik', 'Mükemmeliyetçilik', 'Endişe eğilimi'],
      'description': 'Başak, Zodyak\'ın en analitik ve detaycı burcudur. Merkür\'ün pratik yönüyle her detayı görür, düzeni sever ve çevresini sürekli iyileştirmeye çalışır. Alçakgönüllü ama inanılmaz güçlü bir iç dünyaya sahiptir. Hizmet ruhu en belirgin özelliğidir.',
      'love': 'Aşkta düşünceli ve özenli. Küçük detaylarla sevgisini gösterir. Güvenilir ve sadık.',
      'career': 'Sağlık, analiz, yazılım ve düzenleme alanlarında üstün. Mükemmeliyetçiliği başarı getirir.',
      'compatibility': {'En Uyumlu': 'Boğa, Oğlak', 'İyi Uyum': 'Yengeç, Akrep', 'Zorlayıcı': 'İkizler, Yay'},
      'luckyNumber': '5, 3', 'luckyColor': 'Lacivert', 'luckyDay': 'Çarşamba',
      'dailyHoroscope': 'Bugün detaylara odaklan. Gözden kaçan bir ayrıntı büyük fark yaratabilir. Düzenlediğin her şey mükemmelliğe ulaşıyor.',
    },
    {
      'symbol': '♎', 'name': 'Terazi', 'nameEn': 'Libra', 'image': 'assets/images/zodiac_signs/libra.png',
      'dates': '23 Eylül - 22 Ekim',
      'element': 'Hava', 'elementEmoji': '💨',
      'planet': 'Venüs', 'planetEmoji': '♀️',
      'quality': 'Öncü', 'qualityEmoji': '⚡',
      'traits': ['Diplomatik', 'Estetik', 'Adil', 'Uyumlu', 'Zarif', 'Romantik'],
      'strengths': ['Adalet duygusu', 'Estetik anlayış', 'Diplomasi'],
      'weaknesses': ['Kararsızlık', 'Çatışmadan kaçınma', 'Başkalarına bağımlılık'],
      'description': 'Terazi, denge ve uyumun burcudur. Venüs\'ün zarafetiyle güzelliğe, adalete ve ilişkilere büyük önem verir. Her durumda orta yolu bulmaya çalışır. Estetik anlayışı ve diplomatik yetenekleri onu benzersiz kılar.',
      'love': 'Aşkta romantik ve uyumlu. İlişkide denge ve eşitlik arar. Çatışmadan hoşlanmaz.',
      'career': 'Hukuk, sanat, moda ve diplomaside başarılı. Her alanda estetiği ön plana çıkarır.',
      'compatibility': {'En Uyumlu': 'İkizler, Kova', 'İyi Uyum': 'Aslan, Yay', 'Zorlayıcı': 'Yengeç, Oğlak'},
      'luckyNumber': '6, 9', 'luckyColor': 'Pastel Pembe', 'luckyDay': 'Cuma',
      'dailyHoroscope': 'Bugün ilişkilerin ön planda. Bir dengeyi yeniden kurma zamanı. Estetik projeler seni mutlu edecek.',
    },
    {
      'symbol': '♏', 'name': 'Akrep', 'nameEn': 'Scorpio', 'image': 'assets/images/zodiac_signs/scorpio.png',
      'dates': '23 Ekim - 21 Kasım',
      'element': 'Su', 'elementEmoji': '💧',
      'planet': 'Plüton', 'planetEmoji': '♇',
      'quality': 'Sabit', 'qualityEmoji': '⚓',
      'traits': ['Tutkulu', 'Gizemli', 'Kararlı', 'Derin', 'Manyetik', 'Güçlü'],
      'strengths': ['Derin sezgi', 'Yeniden doğuş gücü', 'Sadakat'],
      'weaknesses': ['Kıskançlık', 'İntikamcılık', 'Aşırı kontrol'],
      'description': 'Akrep, Zodyak\'ın en derin ve tutkulu burcudur. Plüton\'un dönüştürücü gücüyle yaşamın en karanlık köşelerine bakmaktan çekinmez. Güçlü sezgileri ve manyetik çekiciliğiyle tanınır. Anka kuşu gibi her krizden daha güçlü doğar.',
      'love': 'Aşkta son derece tutkulu ve yoğun. Tam bağlanır ya da hiç. Güvene büyük önem verir.',
      'career': 'Araştırma, psikoloji, tıp ve dedektiflikte usta. Gizemleri çözmek doğasında var.',
      'compatibility': {'En Uyumlu': 'Yengeç, Balık', 'İyi Uyum': 'Boğa, Başak', 'Zorlayıcı': 'Aslan, Kova'},
      'luckyNumber': '8, 11', 'luckyColor': 'Bordo', 'luckyDay': 'Salı',
      'dailyHoroscope': 'Bugün derin duyguların yüzeye çıkıyor. Dönüşüm zamanı. Eski kalıpları kır, yeni sen doğuyor.',
    },
    {
      'symbol': '♐', 'name': 'Yay', 'nameEn': 'Sagittarius', 'image': 'assets/images/zodiac_signs/sagittarius.png',
      'dates': '22 Kasım - 21 Aralık',
      'element': 'Ateş', 'elementEmoji': '🔥',
      'planet': 'Jüpiter', 'planetEmoji': '♃',
      'quality': 'Değişken', 'qualityEmoji': '🔄',
      'traits': ['Maceracı', 'Özgür', 'Filozof', 'İyimser', 'Dürüst', 'Enerjik'],
      'strengths': ['Vizyon genişliği', 'Macera ruhu', 'Felsefi derinlik'],
      'weaknesses': ['Sorumsuzluk', 'Aşırı dürüstlük', 'Taahhüt korkusu'],
      'description': 'Yay, Zodyak\'ın kaşifi ve filozofudur. Jüpiter\'in genişletici enerjisiyle sınırları zorlar, yeni ufuklara yelken açar. Hayata büyük bir iyimserlikle bakar, bilgelik arayışı hiç bitmez. Okçu gibi hedefine doğru uçar.',
      'love': 'Aşkta özgür ve maceracı. Onu kafesleyemezsin. Entelektüel bağ ve ortak maceralar ister.',
      'career': 'Seyahat, eğitim, felsefe ve hukuk alanlarında başarılı. Dünyayı keşfetmek onun işi.',
      'compatibility': {'En Uyumlu': 'Koç, Aslan', 'İyi Uyum': 'Terazi, Kova', 'Zorlayıcı': 'İkizler, Başak'},
      'luckyNumber': '3, 7', 'luckyColor': 'Mor', 'luckyDay': 'Perşembe',
      'dailyHoroscope': 'Bugün ufkunu genişlet. Yeni bir bilgi, yeni bir yolculuk ya da yeni bir bakış açısı seni bekliyor. Jüpiter şansını destekliyor.',
    },
    {
      'symbol': '♑', 'name': 'Oğlak', 'nameEn': 'Capricorn', 'image': 'assets/images/zodiac_signs/capricorn.png',
      'dates': '22 Aralık - 19 Ocak',
      'element': 'Toprak', 'elementEmoji': '🌍',
      'planet': 'Satürn', 'planetEmoji': '♄',
      'quality': 'Öncü', 'qualityEmoji': '⚡',
      'traits': ['Disiplinli', 'Hırslı', 'Sorumlu', 'Ciddi', 'Geleneksel', 'Dayanıklı'],
      'strengths': ['İrade gücü', 'Uzun vadeli planlama', 'Sorumluluk bilinci'],
      'weaknesses': ['Aşırı ciddiyet', 'Duygularını bastırma', 'İş koliklik'],
      'description': 'Oğlak, Zodyak\'ın en disiplinli ve hırslı burcudur. Satürn\'ün yapıcı etkisiyle hedeflerine adım adım ilerler. Sabırla dağın zirvesine tırmanır. Sözüne güvenilir, sorumluluklarını asla ihmal etmez. Zamanla daha da güçlenir.',
      'love': 'Aşkta ciddi ve sadık. Uzun vadeli ilişkiler ister. Sevgisini eylemlerle gösterir.',
      'career': 'Yöneticilik, finans, mühendislik ve devlet işlerinde güçlü. Kariyer odaklı.',
      'compatibility': {'En Uyumlu': 'Boğa, Başak', 'İyi Uyum': 'Akrep, Balık', 'Zorlayıcı': 'Koç, Terazi'},
      'luckyNumber': '4, 8', 'luckyColor': 'Koyu Kahve', 'luckyDay': 'Cumartesi',
      'dailyHoroscope': 'Bugün disiplinin meyvelerini topluyorsun. Sabırlı çabaların sonuç veriyor. Bir adım daha yüksel, zirve yakın.',
    },
    {
      'symbol': '♒', 'name': 'Kova', 'nameEn': 'Aquarius', 'image': 'assets/images/zodiac_signs/aquarius.png',
      'dates': '20 Ocak - 18 Şubat',
      'element': 'Hava', 'elementEmoji': '💨',
      'planet': 'Uranüs', 'planetEmoji': '♅',
      'quality': 'Sabit', 'qualityEmoji': '⚓',
      'traits': ['Yenilikçi', 'Bağımsız', 'Hümanist', 'Orijinal', 'Vizyoner', 'Asi'],
      'strengths': ['Özgün düşünce', 'İnsancıl bakış', 'Devrimci ruh'],
      'weaknesses': ['Duygusal mesafe', 'İnatçılık', 'Asi tutum'],
      'description': 'Kova, Zodyak\'ın yenilikçisi ve devrimcisidir. Uranüs\'ün sıra dışı enerjisiyle kalıpları kırar, geleceği hayal eder. İnsanlığın iyiliği için çalışır. Bireysel özgürlüğe düşkün, orijinal düşünceli vizyonerlerdir.',
      'love': 'Aşkta bağımsız ve arkadaşça. Entelektüel uyum arar. Klişe romantizmden kaçınır.',
      'career': 'Teknoloji, bilim, sosyal girişimcilik ve inovasyonda öncü. Geleceği inşa eder.',
      'compatibility': {'En Uyumlu': 'İkizler, Terazi', 'İyi Uyum': 'Koç, Yay', 'Zorlayıcı': 'Boğa, Akrep'},
      'luckyNumber': '4, 7', 'luckyColor': 'Elektrik Mavisi', 'luckyDay': 'Cumartesi',
      'dailyHoroscope': 'Bugün orijinal fikirlerin parlıyor. Sıra dışı bir çözüm bulma zamanı. Uranüs seni yaratıcılığa çağırıyor.',
    },
    {
      'symbol': '♓', 'name': 'Balık', 'nameEn': 'Pisces', 'image': 'assets/images/zodiac_signs/pisces.png',
      'dates': '19 Şubat - 20 Mart',
      'element': 'Su', 'elementEmoji': '💧',
      'planet': 'Neptün', 'planetEmoji': '♆',
      'quality': 'Değişken', 'qualityEmoji': '🔄',
      'traits': ['Hayalperest', 'Empati', 'Sanatsal', 'Sezgisel', 'Şefkatli', 'Gizemli'],
      'strengths': ['Sınırsız empati', 'Sanatsal yetenek', 'Ruhani derinlik'],
      'weaknesses': ['Gerçeklikten kaçış', 'Aşırı hassasiyet', 'Sınır koyamama'],
      'description': 'Balık, Zodyak\'ın son ve en ruhani burcudur. Neptün\'ün hayalci dünyasıyla sınırları olmayan bir iç evrene sahiptir. Tüm burçların bilgeliğini taşır. Güçlü empatisi ve sanatsal ruhuyla dokunduğu her şeye anlam katar.',
      'love': 'Aşkta romantik ve fedakâr. Ruh ikizini arar. Derin duygusal bağ kurar.',
      'career': 'Sanat, müzik, sinema, terapi ve spiritüel alanlarda doğal yetenek. Hayal gücü sınırsız.',
      'compatibility': {'En Uyumlu': 'Yengeç, Akrep', 'İyi Uyum': 'Boğa, Oğlak', 'Zorlayıcı': 'İkizler, Yay'},
      'luckyNumber': '3, 9', 'luckyColor': 'Deniz Mavisi', 'luckyDay': 'Perşembe',
      'dailyHoroscope': 'Bugün sezgilerin zirvedekı. Rüyalarına dikkat et, mesajlar taşıyorlar. Sanatsal bir projede kaybolmak ruhuna iyi gelecek.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await StorageService.getUserName();
    final sign = await StorageService.getZodiacSign();
    if (mounted) {
      setState(() {
        _userName = name;
        if (sign != null) {
          final idx = _signs.indexWhere((s) => s['name'] == sign);
          if (idx >= 0) _selectedIndex = idx;
        }
      });
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = _signs[_selectedIndex];
    final greeting = _userName != null ? 'Merhaba $_userName,' : 'Kozmik Yolcu,';
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(children: [
        // Arka plan
        Container(decoration: BoxDecoration(gradient: RadialGradient(
          center: const Alignment(0, -0.5), radius: 1.3,
          colors: [_goldD.withOpacity(0.25), _bg, const Color(0xFF0A0D0A)],
          stops: const [0.0, 0.5, 1.0],
        ))),

        // 🌀 Geometrik mandala arka plan
        Positioned(top: 20, right: -40, child: AnimatedBuilder(
          animation: _pulse,
          builder: (_, __) => Opacity(
            opacity: 0.10 + _pulse.value * 0.05,
            child: Transform.rotate(angle: _pulse.value * 0.1,
              child: SizedBox(width: 320, height: 320,
                child: CustomPaint(painter: _MandalaPainter(color: _gold)),
              ),
            ),
          ),
        )),

        // 🌌 Yıldız parçacıkları
        ...List.generate(25, (i) {
          final rng = math.Random(i * 13 + 7);
          final x = rng.nextDouble() * MediaQuery.of(context).size.width;
          final y = rng.nextDouble() * MediaQuery.of(context).size.height * 0.6;
          final sz = 1.0 + rng.nextDouble() * 2.0;
          final op = 0.06 + rng.nextDouble() * 0.18;
          final bright = i % 6 == 0;
          return Positioned(left: x, top: y, child: AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) => Opacity(
              opacity: bright ? op + _pulse.value * 0.12 : op,
              child: Container(width: sz, height: sz, decoration: BoxDecoration(
                shape: BoxShape.circle, color: _gold,
                boxShadow: bright ? [BoxShadow(color: _gold.withOpacity(0.25), blurRadius: 5)] : null,
              )),
            ),
          ));
        }),

        SafeArea(bottom: false, child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // ── ÜST BAR ──
              Row(children: [
                const GlassBackButton(),
              ]),
              const SizedBox(height: 12),

              // ── 🔶 DÖNEN ELMAS ÇERÇEVESİ ──
              _fadeIn(100, Center(child: SizedBox(
                width: 280, height: 310,
                child: Stack(alignment: Alignment.center, children: [
                  // Dış parıltı
                  Transform.rotate(angle: math.pi / 4,
                    child: Container(width: 190, height: 190, decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [BoxShadow(color: _gold.withOpacity(0.08), blurRadius: 30, spreadRadius: 8)],
                    )),
                  ),
                  // Dış elmas çerçeve
                  Transform.rotate(angle: math.pi / 4,
                    child: Container(width: 185, height: 185, decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _gold.withOpacity(0.15), width: 0.8),
                    )),
                  ),
                  // İç elmas — illüstrasyon
                  Transform.rotate(angle: math.pi / 4,
                    child: Container(width: 168, height: 168, decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _gold.withOpacity(0.35), width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14.5),
                      child: Transform.rotate(angle: -math.pi / 4,
                        child: Transform.scale(scale: 1.45,
                          child: Image.asset(s['image'] as String, fit: BoxFit.cover)),
                      ),
                    )),
                  ),
                  // Köşe parıltı noktaları (4 köşe)
                  ...List.generate(4, (i) {
                    final angle = i * math.pi / 2 - math.pi / 2;
                    const dist = 95.0;
                    return Positioned(
                      left: 140 + math.cos(angle) * dist - 4,
                      top: 130 + math.sin(angle) * dist - 4,
                      child: Container(width: 8, height: 8, decoration: BoxDecoration(
                        shape: BoxShape.circle, color: _gold.withOpacity(0.6),
                        boxShadow: [BoxShadow(color: _gold.withOpacity(0.3), blurRadius: 8)],
                      )),
                    );
                  }),
                  // İsim — altta
                  Positioned(bottom: 0, child: Column(children: [
                    ShaderMask(
                      shaderCallback: (b) => const LinearGradient(colors: [_goldL, _gold]).createShader(b),
                      child: Text(s['name'] as String, style: const TextStyle(
                        color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 3)),
                    ),
                    const SizedBox(height: 3),
                    Text(s['nameEn'] as String, style: TextStyle(
                      color: Colors.white.withOpacity(0.3), fontSize: 12, letterSpacing: 4)),
                    const SizedBox(height: 2),
                    Text(s['dates'] as String, style: TextStyle(
                      color: _gold.withOpacity(0.5), fontSize: 11, letterSpacing: 1)),
                  ])),
                ]),
              ))),

              const SizedBox(height: 30),

              // ── ELEMENT / GEZEGEN / NİTELİK ──
              _fadeIn(400, Row(children: [
                Expanded(child: _infoBadge(s['elementEmoji'] as String, 'Element', s['element'] as String)),
                const SizedBox(width: 10),
                Expanded(child: _infoBadge(s['planetEmoji'] as String, 'Gezegen', s['planet'] as String)),
                const SizedBox(width: 10),
                Expanded(child: _infoBadge(s['qualityEmoji'] as String, 'Nitelik', s['quality'] as String)),
              ])),

              const SizedBox(height: 28),

              // ── GÜNLÜK YORUM ──
              _fadeIn(500, _dailyCard(s)),

              const SizedBox(height: 28),

              // ── KİŞİLİK ANALİZİ ──
              _fadeIn(600, _sectionTitle('🧠', 'Kişilik Analizi')),
              const SizedBox(height: 12),
              _fadeIn(650, _glassCard(child: Text(
                s['description'] as String,
                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 15, height: 1.7),
              ))),

              const SizedBox(height: 24),

              // ── GÜÇLÜ & ZAYIF YANLAR ──
              _fadeIn(700, Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _strengthWeakCard('💪', 'Güçlü Yanlar', (s['strengths'] as List<String>), true)),
                const SizedBox(width: 12),
                Expanded(child: _strengthWeakCard('⚠️', 'Gelişim Alanları', (s['weaknesses'] as List<String>), false)),
              ])),

              const SizedBox(height: 28),

              // ── AŞK & KARİYER ──
              _fadeIn(750, _sectionTitle('💕', 'Aşk & Kariyer')),
              const SizedBox(height: 12),
              _fadeIn(800, _loveCareerCard('💑', 'Aşk Hayatı', s['love'] as String)),
              const SizedBox(height: 12),
              _fadeIn(850, _loveCareerCard('💼', 'Kariyer Yolu', s['career'] as String)),

              const SizedBox(height: 28),

              // ── UYUM TABLOSU ──
              _fadeIn(900, _sectionTitle('🤝', 'Burç Uyumu')),
              const SizedBox(height: 12),
              _fadeIn(950, _compatibilityCard(s['compatibility'] as Map<String, String>)),

              const SizedBox(height: 28),

              // ── ÖNE ÇIKAN ÖZELLİKLER ──
              _fadeIn(1000, _sectionTitle('✨', 'Öne Çıkan Özellikler')),
              const SizedBox(height: 14),
              _fadeIn(1050, Wrap(spacing: 10, runSpacing: 10,
                children: (s['traits'] as List<String>).map((t) => _traitChip(t)).toList(),
              )),

              const SizedBox(height: 28),

              // ── ŞANSLI BİLGİLER ──
              _fadeIn(1100, _luckyCard(s)),

              const SizedBox(height: 100),
            ]),
          ))],
        )),
      ]),
    );
  }

  // ═══════════════════════════════════════════
  // YARDIMCI WİDGETLER
  // ═══════════════════════════════════════════


  Widget _fadeIn(int delayMs, Widget child) => _FadeSlideIn(delay: Duration(milliseconds: delayMs), child: child);

  Widget _topBadge(String symbol, String name) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: _goldD.withOpacity(0.15), borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _gold.withOpacity(0.3)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(symbol, style: TextStyle(color: _gold, fontSize: 16)),
      const SizedBox(width: 8),
      Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
    ]),
  );

  Widget _infoBadge(String emoji, String label, String value) => Container(
    padding: const EdgeInsets.symmetric(vertical: 18),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(24),
      border: Border.all(color: _gold.withOpacity(0.12)),
    ),
    child: Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 24)),
      const SizedBox(height: 8),
      Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.w500)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(color: _gold, fontSize: 15, fontWeight: FontWeight.w700)),
    ]),
  );

  Widget _glassCard({required Widget child}) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(24),
      border: Border.all(color: _gold.withOpacity(0.1)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 6))],
    ),
    child: child,
  );

  Widget _sectionTitle(String emoji, String title) => Row(children: [
    Text(emoji, style: const TextStyle(fontSize: 20)),
    const SizedBox(width: 10),
    Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
  ]);

  Widget _dailyCard(Map<String, dynamic> s) => ClipRRect(
    borderRadius: BorderRadius.circular(28),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _gold.withOpacity(0.15)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(
              color: _goldD.withOpacity(0.2), shape: BoxShape.circle),
              child: Icon(Icons.auto_awesome, color: _gold, size: 22)),
            const SizedBox(width: 14),
            const Text('Günlük Yıldız Falın', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700)),
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text('Bugün', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w600))),
          ]),
          const SizedBox(height: 16),
          Text(s['dailyHoroscope'] as String, style: TextStyle(
            color: Colors.white.withOpacity(0.85), fontSize: 15, height: 1.65)),
        ]),
      ),
    ),
  );

  Widget _strengthWeakCard(String emoji, String title, List<String> items, bool isStrength) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [
        (isStrength ? const Color(0xFF1A3A2A) : const Color(0xFF3A2A1A)).withOpacity(0.3),
        (isStrength ? const Color(0xFF1A3A2A) : const Color(0xFF3A2A1A)).withOpacity(0.1),
      ]),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: (isStrength ? const Color(0xFF4CAF50) : const Color(0xFFFF9800)).withOpacity(0.2)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('$emoji $title', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
      const SizedBox(height: 12),
      ...items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Text(isStrength ? '✦' : '◈', style: TextStyle(
            color: (isStrength ? const Color(0xFF4CAF50) : const Color(0xFFFF9800)).withOpacity(0.7), fontSize: 10)),
          const SizedBox(width: 8),
          Flexible(child: Text(item, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, height: 1.4))),
        ]),
      )),
    ]),
  );

  Widget _loveCareerCard(String emoji, String title, String text) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(22),
      border: Border.all(color: _gold.withOpacity(0.1)),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(emoji, style: const TextStyle(fontSize: 28)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(text, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 14, height: 1.6)),
      ])),
    ]),
  );

  Widget _compatibilityCard(Map<String, String> compat) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(24),
      border: Border.all(color: _gold.withOpacity(0.1)),
    ),
    child: Column(children: compat.entries.map((e) {
      final color = e.key == 'En Uyumlu' ? const Color(0xFF4CAF50) :
                    e.key == 'İyi Uyum' ? _gold : const Color(0xFFFF9800);
      final icon = e.key == 'En Uyumlu' ? '💚' : e.key == 'İyi Uyum' ? '💛' : '🔸';
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(e.key, style: TextStyle(color: color.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 3),
            Text(e.value, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 15, fontWeight: FontWeight.w500)),
          ])),
        ]),
      );
    }).toList()),
  );

  Widget _traitChip(String trait) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      color: _goldD.withOpacity(0.15), borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _gold.withOpacity(0.3))),
    child: Text(trait, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
  );

  Widget _luckyCard(Map<String, dynamic> s) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [_goldD.withOpacity(0.15), _goldD.withOpacity(0.05)]),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: _gold.withOpacity(0.15)),
    ),
    child: Column(children: [
      _sectionTitle('🍀', 'Şans Rehberin'),
      const SizedBox(height: 18),
      Row(children: [
        Expanded(child: _luckyItem('🔢', 'Sayı', s['luckyNumber'] as String)),
        _vDivider(),
        Expanded(child: _luckyItem('🎨', 'Renk', s['luckyColor'] as String)),
        _vDivider(),
        Expanded(child: _luckyItem('📅', 'Gün', s['luckyDay'] as String)),
      ]),
    ]),
  );

  Widget _luckyItem(String emoji, String label, String value) => Column(children: [
    Text(emoji, style: const TextStyle(fontSize: 20)),
    const SizedBox(height: 6),
    Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
    const SizedBox(height: 4),
    Text(value, textAlign: TextAlign.center, style: TextStyle(color: _gold, fontSize: 14, fontWeight: FontWeight.w700)),
  ]);

  Widget _vDivider() => Container(width: 1, height: 50, color: Colors.white.withOpacity(0.08));
}

// ── FADE + SLIDE IN ANİMASYONU ──
class _FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _FadeSlideIn({required this.child, required this.delay});
  @override
  State<_FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<_FadeSlideIn> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _opacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
    _offset = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, () { if (mounted) _c.forward(); });
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _opacity, child: SlideTransition(position: _offset, child: widget.child));
}

// ── Takımyıldızı çizici ──
class _ConstellationPainter extends CustomPainter {
  final int signIndex;
  final Color color;
  _ConstellationPainter({required this.signIndex, required this.color});

  // Her burç için takımyıldızı yıldız koordinatları (0-1 normalize)
  static const List<List<List<double>>> _stars = [
    // 0-Koç: Hamal, Sheratan, Mesarthim, 41 Ari
    [[0.2,0.3],[0.35,0.25],[0.5,0.35],[0.65,0.5],[0.55,0.65]],
    // 1-Boğa: Aldebaran, Elnath, Hyades V-şekli
    [[0.3,0.5],[0.4,0.35],[0.5,0.4],[0.55,0.3],[0.7,0.2],[0.45,0.55],[0.35,0.6]],
    // 2-İkizler: Castor, Pollux, paralel çizgiler
    [[0.3,0.15],[0.35,0.3],[0.3,0.5],[0.25,0.7],[0.55,0.2],[0.6,0.35],[0.55,0.55],[0.5,0.7]],
    // 3-Yengeç: küçük ters Y
    [[0.4,0.3],[0.5,0.45],[0.6,0.3],[0.45,0.6],[0.55,0.6],[0.5,0.75]],
    // 4-Aslan: orak + üçgen
    [[0.2,0.4],[0.3,0.25],[0.45,0.2],[0.55,0.3],[0.5,0.45],[0.65,0.5],[0.75,0.4],[0.8,0.55],[0.7,0.6]],
    // 5-Başak: Y-şekil + uzantı
    [[0.15,0.35],[0.3,0.4],[0.45,0.35],[0.55,0.45],[0.5,0.55],[0.65,0.6],[0.75,0.5],[0.4,0.6],[0.35,0.75]],
    // 6-Terazi: terazi kefeleri
    [[0.3,0.3],[0.5,0.25],[0.7,0.3],[0.5,0.5],[0.35,0.6],[0.65,0.6]],
    // 7-Akrep: S-eğrisi + iğne
    [[0.15,0.3],[0.25,0.35],[0.35,0.4],[0.45,0.5],[0.55,0.55],[0.6,0.65],[0.55,0.75],[0.45,0.8],[0.5,0.9]],
    // 8-Yay: ok + yay
    [[0.2,0.6],[0.35,0.45],[0.5,0.3],[0.65,0.15],[0.4,0.55],[0.55,0.5],[0.6,0.6],[0.5,0.7],[0.45,0.65]],
    // 9-Oğlak: üçgen + kuyruk
    [[0.25,0.3],[0.4,0.25],[0.55,0.35],[0.65,0.45],[0.55,0.55],[0.4,0.6],[0.3,0.5],[0.7,0.6],[0.8,0.7]],
    // 10-Kova: zigzag su
    [[0.2,0.3],[0.3,0.25],[0.35,0.4],[0.45,0.35],[0.5,0.5],[0.6,0.45],[0.65,0.6],[0.75,0.55]],
    // 11-Balık: iki halka + bağ
    [[0.15,0.4],[0.25,0.3],[0.35,0.35],[0.25,0.5],[0.4,0.5],[0.55,0.5],[0.65,0.4],[0.75,0.45],[0.8,0.55],[0.7,0.6]],
  ];

  // Her burç için yıldızlar arası bağlantılar (indeks çiftleri)
  static const List<List<List<int>>> _lines = [
    [[0,1],[1,2],[2,3],[3,4]],
    [[0,1],[1,2],[2,3],[3,4],[1,5],[5,6]],
    [[0,1],[1,2],[2,3],[4,5],[5,6],[6,7]],
    [[0,1],[1,2],[1,3],[1,4],[3,4],[4,5]],
    [[0,1],[1,2],[2,3],[3,4],[4,5],[5,6],[6,7],[7,8]],
    [[0,1],[1,2],[2,3],[3,4],[4,5],[5,6],[1,7],[7,8]],
    [[0,1],[1,2],[1,3],[3,4],[3,5]],
    [[0,1],[1,2],[2,3],[3,4],[4,5],[5,6],[6,7],[7,8]],
    [[0,1],[1,2],[2,3],[1,4],[4,5],[5,6],[6,7],[7,8]],
    [[0,1],[1,2],[2,3],[3,4],[4,5],[5,6],[6,0],[3,7],[7,8]],
    [[0,1],[1,2],[2,3],[3,4],[4,5],[5,6],[6,7]],
    [[0,1],[1,2],[2,3],[3,0],[3,4],[4,5],[5,6],[6,7],[7,8],[8,9]],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final idx = signIndex.clamp(0, 11);
    final stars = _stars[idx];
    final lines = _lines[idx];

    // Bağlantı çizgileri
    final linePaint = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (final line in lines) {
      final a = stars[line[0]], b = stars[line[1]];
      canvas.drawLine(Offset(a[0] * w, a[1] * h), Offset(b[0] * w, b[1] * h), linePaint);
    }

    // Yıldız noktaları
    for (int i = 0; i < stars.length; i++) {
      final s = stars[i];
      final pos = Offset(s[0] * w, s[1] * h);
      final isMajor = i == 0 || i == stars.length - 1;
      // Dış glow
      canvas.drawCircle(pos, isMajor ? 5 : 3, Paint()..color = color.withOpacity(isMajor ? 0.15 : 0.08));
      // İç nokta
      canvas.drawCircle(pos, isMajor ? 2.5 : 1.8, Paint()..color = color.withOpacity(isMajor ? 0.7 : 0.5));
    }
  }

  @override
  bool shouldRepaint(covariant _ConstellationPainter old) => old.signIndex != signIndex;
}

// ── Geometrik Mandala çizici ──
class _MandalaPainter extends CustomPainter {
  final Color color;
  _MandalaPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final maxR = size.width * 0.48;

    // Eşmerkezli daireler
    final circlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    for (int i = 1; i <= 5; i++) {
      final r = maxR * i / 5;
      canvas.drawCircle(Offset(cx, cy), r, circlePaint
        ..color = color.withOpacity(0.15 + (5 - i) * 0.05));
    }

    // 12 radyal çizgi
    final linePaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 0; i < 12; i++) {
      final angle = i * math.pi * 2 / 12;
      canvas.drawLine(
        Offset(cx + math.cos(angle) * maxR * 0.2, cy + math.sin(angle) * maxR * 0.2),
        Offset(cx + math.cos(angle) * maxR, cy + math.sin(angle) * maxR),
        linePaint,
      );
    }

    // İç 6-köşeli yıldız
    final starPaint = Paint()
      ..color = color.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    for (int t = 0; t < 2; t++) {
      final offset = t * math.pi / 6;
      final path = Path();
      for (int i = 0; i < 3; i++) {
        final angle = offset + i * math.pi * 2 / 3 - math.pi / 2;
        final x = cx + math.cos(angle) * maxR * 0.55;
        final y = cy + math.sin(angle) * maxR * 0.55;
        if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, starPaint);
    }

    // Kesişim noktaları
    final dotPaint = Paint()..color = color.withOpacity(0.35);
    for (int i = 0; i < 12; i++) {
      final angle = i * math.pi * 2 / 12;
      canvas.drawCircle(Offset(cx + math.cos(angle) * maxR, cy + math.sin(angle) * maxR), 1.8, dotPaint);
      canvas.drawCircle(Offset(cx + math.cos(angle) * maxR * 0.6, cy + math.sin(angle) * maxR * 0.6), 1.2,
        Paint()..color = color.withOpacity(0.25));
    }

    // Merkez
    canvas.drawCircle(Offset(cx, cy), 3, Paint()..color = color.withOpacity(0.3));
    canvas.drawCircle(Offset(cx, cy), 1.5, Paint()..color = color.withOpacity(0.5));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
