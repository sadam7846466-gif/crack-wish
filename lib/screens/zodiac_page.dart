import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glass_back_button.dart';
import '../services/storage_service.dart';
import 'compatibility_content.dart';

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
  DateTime _birthDate = DateTime(1999, 12, 20);

  static const Color _gold = Color(0xFFFFD060);
  static const Color _goldL = Color(0xFFFFE8A1);
  static const Color _goldD = Color(0xFFB07020);
  static const Color _bg = Color(0xFF0F1210);

  // ── TAM 12 BURÇ VERİTABANI ──
  static const List<Map<String, dynamic>> _signs = [
    {
      'symbol': '♈',
      'name': 'Koç',
      'nameEn': 'Aries',
      'image': 'assets/images/zodiac_signs/aries.png',
      'dates': '21 Mart - 19 Nisan',
      'element': 'Ateş',
      'elementEmoji': '🔥',
      'planet': 'Mars',
      'planetEmoji': '♂️',
      'quality': 'Öncü',
      'qualityEmoji': '⚡',
      'traits': ['Cesur', 'Enerjik', 'Girişken', 'Tutkulu', 'Kararlı', 'Lider'],
      'strengths': [
        'Doğal liderlik',
        'Cesaret ve atılganlık',
        'Girişimci ruh',
        'Bağımsızlık',
        'Yüksek enerji',
        'Öz güven',
      ],
      'weaknesses': [
        'Sabırsızlık',
        'Düşünmeden hareket',
        'Hırslı olma',
        'Çabuk öfkelenme',
        'Bencillik',
        'Acelecilik',
      ],
      'description':
          'Koç burcu, Zodyak\'ın ilk ve en ateşli başlangıcıdır. Mars\'ın yönetimindeki bu burç, liderlik, cesaret ve eyleme geçme gücünü temsil eder. Koç bireyler doğuştan öncüdür; bilinmeyenden korkmazlar, aksine ona doğru koşarlar. Her yeni durumda ilk adımı atan, enerji ve tutku dolu ruhlardır.',
      'love':
          'Aşkta tutkulu ve yoğun. Partnerine sadık ama bağımsızlığına düşkün. İlk adımı her zaman kendisi atar.',
      'career':
          'Doğal lider. Girişimcilik, yöneticilik ve rekabete dayalı alanlarda parlıyor.',
      'compatibility': {
        'En Uyumlu': 'Aslan, Yay',
        'İyi Uyum': 'İkizler, Kova',
        'Zorlayıcı': 'Yengeç, Oğlak',
      },
      'luckyNumber': '1, 9',
      'luckyColor': 'Kırmızı',
      'luckyDay': 'Salı',
      'dailyHoroscope':
          'Bugün enerjin doruklarda. Ertelediğin o cesur adımı atmak için mükemmel bir gün. Mars sana güç veriyor, harekete geç!',
    },
    {
      'symbol': '♉',
      'name': 'Boğa',
      'nameEn': 'Taurus',
      'image': 'assets/images/zodiac_signs/taurus.png',
      'dates': '20 Nisan - 20 Mayıs',
      'element': 'Toprak',
      'elementEmoji': '🌍',
      'planet': 'Venüs',
      'planetEmoji': '♀️',
      'quality': 'Sabit',
      'qualityEmoji': '⚓',
      'traits': [
        'Güvenilir',
        'Sabırlı',
        'Kararlı',
        'Sadık',
        'Estetik',
        'Pratik',
      ],
      'strengths': [
        'Sarsılmaz irade',
        'Maddi güvenlik',
        'Sanatsal hassasiyet',
        'Sadakat',
        'Sabır',
        'Güvenilirlik',
      ],
      'weaknesses': [
        'İnatçılık',
        'Değişime direnç',
        'Aşırı sahiplenme',
        'Maddiyatçılık',
        'Üşengeçlik',
        'Kıskançlık',
      ],
      'description':
          'Boğa, Zodyak\'ın en kararlı ve güvenilir burcudur. Venüs\'ün zarif dokunuşuyla güzellik, konfor ve maddi güvenliğe değer verir. Sabırla hedeflerine ulaşır, sözünde durur ve sevdiklerine sıkıca bağlanır. Doğanın ve sanatın tadını çıkaran, ayakları yere basan bir ruhtur.',
      'love':
          'Aşkta sadık ve romantik. Güven ve istikrar arar. Partnerini şımartmayı sever.',
      'career':
          'Finans, sanat, gastronomi ve mimarlıkta başarılı. Uzun vadeli planlar yapar.',
      'compatibility': {
        'En Uyumlu': 'Başak, Oğlak',
        'İyi Uyum': 'Yengeç, Balık',
        'Zorlayıcı': 'Aslan, Kova',
      },
      'luckyNumber': '2, 6',
      'luckyColor': 'Yeşil',
      'luckyDay': 'Cuma',
      'dailyHoroscope':
          'Bugün iç huzurunu bul. Doğada vakit geçirmek ya da sevdiğin bir sanat eserine odaklanmak ruhunu besleyecek.',
    },
    {
      'symbol': '♊',
      'name': 'İkizler',
      'nameEn': 'Gemini',
      'image': 'assets/images/zodiac_signs/gemini.png',
      'dates': '21 Mayıs - 20 Haziran',
      'element': 'Hava',
      'elementEmoji': '💨',
      'planet': 'Merkür',
      'planetEmoji': '☿',
      'quality': 'Değişken',
      'qualityEmoji': '🔄',
      'traits': [
        'Meraklı',
        'Zeki',
        'Sosyal',
        'Esnek',
        'İletişimci',
        'Çok Yönlü',
      ],
      'strengths': [
        'Hızlı öğrenme',
        'İletişim becerisi',
        'Uyum yeteneği',
        'Meraklı doğa',
        'Çok yönlülük',
        'Esnek düşünce',
      ],
      'weaknesses': [
        'Kararsızlık',
        'Yüzeysellik',
        'Çabuk sıkılma',
        'Tutarsızlık',
        'Gevşeklik',
        'Odak eksikliği',
      ],
      'description':
          'İkizler, zihinsel çevikliğin ve iletişimin burcudur. Merkür\'ün hızıyla düşünen bu burç, her konuyla ilgilenir, her ortama uyum sağlar. Sosyal kelebekler olarak tanınırlar; sohbetleri her zaman ilgi çekici ve bilgilendiricidir. İki yüzlü değil, çok yönlüdürler.',
      'love':
          'Aşkta eğlenceli ve entelektüel bağ arar. Sıkıcı rutinden kaçınır, zihinsel uyum şarttır.',
      'career':
          'Medya, yazarlık, pazarlama ve eğitimde parlıyor. Aynı anda birden fazla projeyi yönetir.',
      'compatibility': {
        'En Uyumlu': 'Terazi, Kova',
        'İyi Uyum': 'Koç, Aslan',
        'Zorlayıcı': 'Başak, Balık',
      },
      'luckyNumber': '5, 7',
      'luckyColor': 'Sarı',
      'luckyDay': 'Çarşamba',
      'dailyHoroscope':
          'Bugün zihnin berrak, fikirlerin parlak. Yeni bağlantılar kurmak ve yaratıcı projeler için ideal bir gün.',
    },
    {
      'symbol': '♋',
      'name': 'Yengeç',
      'nameEn': 'Cancer',
      'image': 'assets/images/zodiac_signs/cancer.png',
      'dates': '21 Haziran - 22 Temmuz',
      'element': 'Su',
      'elementEmoji': '💧',
      'planet': 'Ay',
      'planetEmoji': '🌙',
      'quality': 'Öncü',
      'qualityEmoji': '⚡',
      'traits': [
        'Duygusal',
        'Koruyucu',
        'Sezgisel',
        'Sadık',
        'Şefkatli',
        'Empatik',
      ],
      'strengths': [
        'Derin empati',
        'Aile bağları',
        'Güçlü sezgiler',
        'Koruyucu yapı',
        'Şefkat',
        'Sadakat',
      ],
      'weaknesses': [
        'Aşırı duygusallık',
        'Geçmişe takılma',
        'Kabuğuna çekilme',
        'Alınganlık',
        'Karamsarlık',
        'Aşırı hassasiyet',
      ],
      'description':
          'Yengeç, Zodyak\'ın en duygusal ve koruyucu burcudur. Ay\'ın etkisiyle duyguları derin, sezgileri güçlüdür. Sevdiklerini kabuğunun altında korur, yuvasını bir sığınak gibi yaratır. Gözyaşlarının altında bir okyanus kadar güç taşır.',
      'love':
          'Aşkta derin bağlanır. Güven ve sıcaklık arar. Partneri için her şeyi yapar.',
      'career':
          'Sağlık, eğitim, psikoloji ve aşçılıkta başarılı. İnsanlara yardım eden alanlarda parlıyor.',
      'compatibility': {
        'En Uyumlu': 'Akrep, Balık',
        'İyi Uyum': 'Boğa, Başak',
        'Zorlayıcı': 'Koç, Terazi',
      },
      'luckyNumber': '2, 7',
      'luckyColor': 'Gümüş',
      'luckyDay': 'Pazartesi',
      'dailyHoroscope':
          'Bugün iç dünyana dön. Sezgilerin seni doğru yöne çekiyor. Sevdiklerinle vakit geçirmek ruhunu onaracak.',
    },
    {
      'symbol': '♌',
      'name': 'Aslan',
      'nameEn': 'Leo',
      'image': 'assets/images/zodiac_signs/leo.png',
      'dates': '23 Temmuz - 22 Ağustos',
      'element': 'Ateş',
      'elementEmoji': '🔥',
      'planet': 'Güneş',
      'planetEmoji': '☀️',
      'quality': 'Sabit',
      'qualityEmoji': '⚓',
      'traits': [
        'Özgüvenli',
        'Lider Ruhlu',
        'Cömert',
        'Yaratıcı',
        'Tutkulu',
        'Sadık',
      ],
      'strengths': [
        'Doğal karizma',
        'Yaratıcı güç',
        'Cömertlik',
        'Liderlik ruhu',
        'Özgüven',
        'Cesaret',
      ],
      'weaknesses': [
        'Gurur',
        'Dikkat beklentisi',
        'Otoriter tavır',
        'Kibir',
        'İnatçılık',
        'Egoizm',
      ],
      'description':
          'Aslan, Zodyak\'ın kralıdır. Güneş\'in ışığını taşıyan bu burç, sahneye çıktığı anda tüm dikkatleri üzerine çeker. Cömert, sadık ve yaratıcı bir ruhtur. Etrafındakilere enerji verir, ilham kaynağı olur. Liderliği doğasında vardır.',
      'love':
          'Aşkta tutkulu ve romantik. Hayranlık ve sadakat bekler. Partnerini bir kral gibi korur.',
      'career':
          'Sanat, sahne, yöneticilik ve girişimcilikte parlıyor. Spot ışığı altında en iyisi.',
      'compatibility': {
        'En Uyumlu': 'Koç, Yay',
        'İyi Uyum': 'İkizler, Terazi',
        'Zorlayıcı': 'Boğa, Akrep',
      },
      'luckyNumber': '1, 4',
      'luckyColor': 'Altın',
      'luckyDay': 'Pazar',
      'dailyHoroscope':
          'Bugün yaratıcılığının zirvesinde olacaksın. İçindeki ateşi hisset ve liderliği ele almaktan çekinme. Güneş senin için parlıyor!',
    },
    {
      'symbol': '♍',
      'name': 'Başak',
      'nameEn': 'Virgo',
      'image': 'assets/images/zodiac_signs/virgo.png',
      'dates': '23 Ağustos - 22 Eylül',
      'element': 'Toprak',
      'elementEmoji': '🌍',
      'planet': 'Merkür',
      'planetEmoji': '☿',
      'quality': 'Değişken',
      'qualityEmoji': '🔄',
      'traits': [
        'Analitik',
        'Düzenli',
        'Detaycı',
        'Mükemmeliyetçi',
        'Yardımsever',
        'Pratik',
      ],
      'strengths': [
        'Analitik zekâ',
        'Düzen ve organizasyon',
        'Hizmet ruhu',
        'Detaycılık',
        'Pratiklik',
        'Güvenilirlik',
      ],
      'weaknesses': [
        'Aşırı eleştirellik',
        'Mükemmeliyetçilik',
        'Endişe eğilimi',
        'Evham',
        'Detaylarda boğulma',
        'Soğuk görünüm',
      ],
      'description':
          'Başak, Zodyak\'ın en analitik ve detaycı burcudur. Merkür\'ün pratik yönüyle her detayı görür, düzeni sever ve çevresini sürekli iyileştirmeye çalışır. Alçakgönüllü ama inanılmaz güçlü bir iç dünyaya sahiptir. Hizmet ruhu en belirgin özelliğidir.',
      'love':
          'Aşkta düşünceli ve özenli. Küçük detaylarla sevgisini gösterir. Güvenilir ve sadık.',
      'career':
          'Sağlık, analiz, yazılım ve düzenleme alanlarında üstün. Mükemmeliyetçiliği başarı getirir.',
      'compatibility': {
        'En Uyumlu': 'Boğa, Oğlak',
        'İyi Uyum': 'Yengeç, Akrep',
        'Zorlayıcı': 'İkizler, Yay',
      },
      'luckyNumber': '5, 3',
      'luckyColor': 'Lacivert',
      'luckyDay': 'Çarşamba',
      'dailyHoroscope':
          'Bugün detaylara odaklan. Gözden kaçan bir ayrıntı büyük fark yaratabilir. Düzenlediğin her şey mükemmelliğe ulaşıyor.',
    },
    {
      'symbol': '♎',
      'name': 'Terazi',
      'nameEn': 'Libra',
      'image': 'assets/images/zodiac_signs/libra.png',
      'dates': '23 Eylül - 22 Ekim',
      'element': 'Hava',
      'elementEmoji': '💨',
      'planet': 'Venüs',
      'planetEmoji': '♀️',
      'quality': 'Öncü',
      'qualityEmoji': '⚡',
      'traits': [
        'Diplomatik',
        'Estetik',
        'Adil',
        'Uyumlu',
        'Zarif',
        'Romantik',
      ],
      'strengths': [
        'Adalet duygusu',
        'Estetik anlayış',
        'Diplomasi',
        'Uyum yeteneği',
        'Zarafet',
        'Sosyal beceri',
      ],
      'weaknesses': [
        'Kararsızlık',
        'Çatışmadan kaçınma',
        'Başkalarına bağımlılık',
        'Yüzeysellik',
        'Hayır diyememe',
        'Kendinden ödün verme',
      ],
      'description':
          'Terazi, denge ve uyumun burcudur. Venüs\'ün zarafetiyle güzelliğe, adalete ve ilişkilere büyük önem verir. Her durumda orta yolu bulmaya çalışır. Estetik anlayışı ve diplomatik yetenekleri onu benzersiz kılar.',
      'love':
          'Aşkta romantik ve uyumlu. İlişkide denge ve eşitlik arar. Çatışmadan hoşlanmaz.',
      'career':
          'Hukuk, sanat, moda ve diplomaside başarılı. Her alanda estetiği ön plana çıkarır.',
      'compatibility': {
        'En Uyumlu': 'İkizler, Kova',
        'İyi Uyum': 'Aslan, Yay',
        'Zorlayıcı': 'Yengeç, Oğlak',
      },
      'luckyNumber': '6, 9',
      'luckyColor': 'Pastel Pembe',
      'luckyDay': 'Cuma',
      'dailyHoroscope':
          'Bugün ilişkilerin ön planda. Bir dengeyi yeniden kurma zamanı. Estetik projeler seni mutlu edecek.',
    },
    {
      'symbol': '♏',
      'name': 'Akrep',
      'nameEn': 'Scorpio',
      'image': 'assets/images/zodiac_signs/scorpio.png',
      'dates': '23 Ekim - 21 Kasım',
      'element': 'Su',
      'elementEmoji': '💧',
      'planet': 'Plüton',
      'planetEmoji': '♇',
      'quality': 'Sabit',
      'qualityEmoji': '⚓',
      'traits': ['Tutkulu', 'Gizemli', 'Kararlı', 'Derin', 'Manyetik', 'Güçlü'],
      'strengths': [
        'Derin sezgi',
        'Yeniden doğuş gücü',
        'Sadakat',
        'Tutku',
        'Kararlılık',
        'Stratejik zeka',
      ],
      'weaknesses': [
        'Kıskançlık',
        'İntikamcılık',
        'Aşırı kontrol',
        'Şüphecilik',
        'Gizemlilik',
        'Sahiplenicilik',
      ],
      'description':
          'Akrep, Zodyak\'ın en derin ve tutkulu burcudur. Plüton\'un dönüştürücü gücüyle yaşamın en karanlık köşelerine bakmaktan çekinmez. Güçlü sezgileri ve manyetik çekiciliğiyle tanınır. Anka kuşu gibi her krizden daha güçlü doğar.',
      'love':
          'Aşkta son derece tutkulu ve yoğun. Tam bağlanır ya da hiç. Güvene büyük önem verir.',
      'career':
          'Araştırma, psikoloji, tıp ve dedektiflikte usta. Gizemleri çözmek doğasında var.',
      'compatibility': {
        'En Uyumlu': 'Yengeç, Balık',
        'İyi Uyum': 'Boğa, Başak',
        'Zorlayıcı': 'Aslan, Kova',
      },
      'luckyNumber': '8, 11',
      'luckyColor': 'Bordo',
      'luckyDay': 'Salı',
      'dailyHoroscope':
          'Bugün derin duyguların yüzeye çıkıyor. Dönüşüm zamanı. Eski kalıpları kır, yeni sen doğuyor.',
    },
    {
      'symbol': '♐',
      'name': 'Yay',
      'nameEn': 'Sagittarius',
      'image': 'assets/images/zodiac_signs/sagittarius.png',
      'dates': '22 Kasım - 21 Aralık',
      'element': 'Ateş',
      'elementEmoji': '🔥',
      'planet': 'Jüpiter',
      'planetEmoji': '♃',
      'quality': 'Değişken',
      'qualityEmoji': '🔄',
      'traits': [
        'Maceracı',
        'Özgür',
        'Filozof',
        'İyimser',
        'Dürüst',
        'Enerjik',
      ],
      'strengths': [
        'Vizyon genişliği',
        'Macera ruhu',
        'Felsefi derinlik',
        'İyimserlik',
        'Özgür düşünce',
        'Dürüstlük',
      ],
      'weaknesses': [
        'Sorumsuzluk',
        'Aşırı dürüstlük',
        'Taahhüt korkusu',
        'Sabırsızlık',
        'Patavatsızlık',
        'Huzursuzluk',
      ],
      'description':
          'Yay, Zodyak\'ın kaşifi ve filozofudur. Jüpiter\'in genişletici enerjisiyle sınırları zorlar, yeni ufuklara yelken açar. Hayata büyük bir iyimserlikle bakar, bilgelik arayışı hiç bitmez. Okçu gibi hedefine doğru uçar.',
      'love':
          'Aşkta özgür ve maceracı. Onu kafesleyemezsin. Entelektüel bağ ve ortak maceralar ister.',
      'career':
          'Seyahat, eğitim, felsefe ve hukuk alanlarında başarılı. Dünyayı keşfetmek onun işi.',
      'compatibility': {
        'En Uyumlu': 'Koç, Aslan',
        'İyi Uyum': 'Terazi, Kova',
        'Zorlayıcı': 'İkizler, Başak',
      },
      'luckyNumber': '3, 7',
      'luckyColor': 'Mor',
      'luckyDay': 'Perşembe',
      'dailyHoroscope':
          'Bugün ufkunu genişlet. Yeni bir bilgi, yeni bir yolculuk ya da yeni bir bakış açısı seni bekliyor. Jüpiter şansını destekliyor.',
    },
    {
      'symbol': '♑',
      'name': 'Oğlak',
      'nameEn': 'Capricorn',
      'image': 'assets/images/zodiac_signs/capricorn.png',
      'dates': '22 Aralık - 19 Ocak',
      'element': 'Toprak',
      'elementEmoji': '🌍',
      'planet': 'Satürn',
      'planetEmoji': '♄',
      'quality': 'Öncü',
      'qualityEmoji': '⚡',
      'traits': [
        'Disiplinli',
        'Hırslı',
        'Sorumlu',
        'Ciddi',
        'Geleneksel',
        'Dayanıklı',
      ],
      'strengths': [
        'İrade gücü',
        'Uzun vadeli planlama',
        'Sorumluluk bilinci',
        'Disiplin',
        'Kararlılık',
        'Güvenilirlik',
      ],
      'weaknesses': [
        'Aşırı ciddiyet',
        'Duygularını bastırma',
        'İş koliklik',
        'Karamsarlık',
        'Katı kuralcılık',
        'Maddiyatçılık',
      ],
      'description':
          'Oğlak, Zodyak\'ın en disiplinli ve hırslı burcudur. Satürn\'ün yapıcı etkisiyle hedeflerine adım adım ilerler. Sabırla dağın zirvesine tırmanır. Sözüne güvenilir, sorumluluklarını asla ihmal etmez. Zamanla daha da güçlenir.',
      'love':
          'Aşkta ciddi ve sadık. Uzun vadeli ilişkiler ister. Sevgisini eylemlerle gösterir.',
      'career':
          'Yöneticilik, finans, mühendislik ve devlet işlerinde güçlü. Kariyer odaklı.',
      'compatibility': {
        'En Uyumlu': 'Boğa, Başak',
        'İyi Uyum': 'Akrep, Balık',
        'Zorlayıcı': 'Koç, Terazi',
      },
      'luckyNumber': '4, 8',
      'luckyColor': 'Koyu Kahve',
      'luckyDay': 'Cumartesi',
      'dailyHoroscope':
          'Bugün disiplinin meyvelerini topluyorsun. Sabırlı çabaların sonuç veriyor. Bir adım daha yüksel, zirve yakın.',
    },
    {
      'symbol': '♒',
      'name': 'Kova',
      'nameEn': 'Aquarius',
      'image': 'assets/images/zodiac_signs/aquarius.png',
      'dates': '20 Ocak - 18 Şubat',
      'element': 'Hava',
      'elementEmoji': '💨',
      'planet': 'Uranüs',
      'planetEmoji': '♅',
      'quality': 'Sabit',
      'qualityEmoji': '⚓',
      'traits': [
        'Yenilikçi',
        'Bağımsız',
        'Hümanist',
        'Orijinal',
        'Vizyoner',
        'Asi',
      ],
      'strengths': [
        'Özgün düşünce',
        'İnsancıl bakış',
        'Devrimci ruh',
        'Bağımsızlık',
        'Gelecek vizyonu',
        'Yenilikçilik',
      ],
      'weaknesses': [
        'Duygusal mesafe',
        'İnatçılık',
        'Asi tutum',
        'Bağlanma korkusu',
        'Ukalalık',
        'Aşırı rasyonalite',
      ],
      'description':
          'Kova, Zodyak\'ın yenilikçisi ve devrimcisidir. Uranüs\'ün sıra dışı enerjisiyle kalıpları kırar, geleceği hayal eder. İnsanlığın iyiliği için çalışır. Bireysel özgürlüğe düşkün, orijinal düşünceli vizyonerlerdir.',
      'love':
          'Aşkta bağımsız ve arkadaşça. Entelektüel uyum arar. Klişe romantizmden kaçınır.',
      'career':
          'Teknoloji, bilim, sosyal girişimcilik ve inovasyonda öncü. Geleceği inşa eder.',
      'compatibility': {
        'En Uyumlu': 'İkizler, Terazi',
        'İyi Uyum': 'Koç, Yay',
        'Zorlayıcı': 'Boğa, Akrep',
      },
      'luckyNumber': '4, 7',
      'luckyColor': 'Elektrik Mavisi',
      'luckyDay': 'Cumartesi',
      'dailyHoroscope':
          'Bugün orijinal fikirlerin parlıyor. Sıra dışı bir çözüm bulma zamanı. Uranüs seni yaratıcılığa çağırıyor.',
    },
    {
      'symbol': '♓',
      'name': 'Balık',
      'nameEn': 'Pisces',
      'image': 'assets/images/zodiac_signs/pisces.png',
      'dates': '19 Şubat - 20 Mart',
      'element': 'Su',
      'elementEmoji': '💧',
      'planet': 'Neptün',
      'planetEmoji': '♆',
      'quality': 'Değişken',
      'qualityEmoji': '🔄',
      'traits': [
        'Hayalperest',
        'Empati',
        'Sanatsal',
        'Sezgisel',
        'Şefkatli',
        'Gizemli',
      ],
      'strengths': [
        'Sınırsız empati',
        'Sanatsal yetenek',
        'Ruhani derinlik',
        'Sezgisel güç',
        'Şefkat',
        'Fedakarlık',
      ],
      'weaknesses': [
        'Gerçeklikten kaçış',
        'Aşırı hassasiyet',
        'Sınır koyamama',
        'Kurban psikolojisi',
        'Kararsızlık',
        'Aşırı duygusallık',
      ],
      'description':
          'Balık, Zodyak\'ın son ve en ruhani burcudur. Neptün\'ün hayalci dünyasıyla sınırları olmayan bir iç evrene sahiptir. Tüm burçların bilgeliğini taşır. Güçlü empatisi ve sanatsal ruhuyla dokunduğu her şeye anlam katar.',
      'love':
          'Aşkta romantik ve fedakâr. Ruh ikizini arar. Derin duygusal bağ kurar.',
      'career':
          'Sanat, müzik, sinema, terapi ve spiritüel alanlarda doğal yetenek. Hayal gücü sınırsız.',
      'compatibility': {
        'En Uyumlu': 'Yengeç, Akrep',
        'İyi Uyum': 'Boğa, Oğlak',
        'Zorlayıcı': 'İkizler, Yay',
      },
      'luckyNumber': '3, 9',
      'luckyColor': 'Deniz Mavisi',
      'luckyDay': 'Perşembe',
      'dailyHoroscope':
          'Bugün sezgilerin zirvedekı. Rüyalarına dikkat et, mesajlar taşıyorlar. Sanatsal bir projede kaybolmak ruhuna iyi gelecek.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await StorageService.getUserName();
    final savedDate = await StorageService.getBirthDate();
    if (mounted) {
      setState(() {
        _userName = name;
        if (savedDate != null) {
          _birthDate = savedDate;
          _selectedIndex = _signIndexFromDate(savedDate);
        } else {
          // Varsayılan tarihten burcu hesapla
          _selectedIndex = _signIndexFromDate(_birthDate);
        }
      });
    }
  }

  /// Doğum tarihinden burç indeksini hesapla
  int _signIndexFromDate(DateTime d) {
    final m = d.month, day = d.day;
    if ((m == 3 && day >= 21) || (m == 4 && day <= 19)) return 0; // Koç
    if ((m == 4 && day >= 20) || (m == 5 && day <= 20)) return 1; // Boğa
    if ((m == 5 && day >= 21) || (m == 6 && day <= 20)) return 2; // İkizler
    if ((m == 6 && day >= 21) || (m == 7 && day <= 22)) return 3; // Yengeç
    if ((m == 7 && day >= 23) || (m == 8 && day <= 22)) return 4; // Aslan
    if ((m == 8 && day >= 23) || (m == 9 && day <= 22)) return 5; // Başak
    if ((m == 9 && day >= 23) || (m == 10 && day <= 22)) return 6; // Terazi
    if ((m == 10 && day >= 23) || (m == 11 && day <= 21)) return 7; // Akrep
    if ((m == 11 && day >= 22) || (m == 12 && day <= 21)) return 8; // Yay
    if ((m == 12 && day >= 22) || (m == 1 && day <= 19)) return 9; // Oğlak
    if ((m == 1 && day >= 20) || (m == 2 && day <= 18)) return 10; // Kova
    return 11; // Balık
  }

  void _showDatePicker() {
    DateTime tempDate = _birthDate;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            height: 400,
            decoration: BoxDecoration(
              color: const Color(0xFF0F1210).withOpacity(0.75),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              border: Border(
                top: BorderSide(color: _gold.withOpacity(0.25), width: 1.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: _gold.withOpacity(0.08),
                  blurRadius: 40,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: Column(
              children: [
                // ── Üst tutma çubuğu ──
                const SizedBox(height: 12),
                Container(
                  width: 36,
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      colors: [
                        _gold.withOpacity(0.1),
                        _gold.withOpacity(0.4),
                        _gold.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Başlık bölümü ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Row(
                    children: [
                      // Sol dekoratif çizgi
                      Expanded(
                        child: Container(
                          height: 0.5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                _gold.withOpacity(0.3),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Merkez başlık
                      Column(
                        children: [
                          Text(
                            '✦',
                            style: TextStyle(
                              color: _gold.withOpacity(0.4),
                              fontSize: 8,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ShaderMask(
                            shaderCallback: (b) => const LinearGradient(
                              colors: [
                                Color(0xFFE8D5B7),
                                Color(0xFFFFE8A1),
                                Color(0xFFFFD060),
                              ],
                            ).createShader(b),
                            child: Text(
                              'DOĞUM TARİHİ',
                              style: GoogleFonts.cinzel(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Yıldızların seni tanısın',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.25),
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Sağ dekoratif çizgi
                      Expanded(
                        child: Container(
                          height: 0.5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _gold.withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── İnce ayırıcı ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 0.3,
                          color: _gold.withOpacity(0.1),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _gold.withOpacity(0.2),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 0.3,
                          color: _gold.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Date Picker ──
                Expanded(
                  child: CupertinoTheme(
                    data: const CupertinoThemeData(brightness: Brightness.dark),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: _birthDate,
                      minimumDate: DateTime(1940),
                      maximumDate: DateTime.now(),
                      onDateTimeChanged: (d) => tempDate = d,
                    ),
                  ),
                ),

                // ── Onay butonu ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _birthDate = tempDate;
                        _selectedIndex = _signIndexFromDate(tempDate);
                      });
                      StorageService.setZodiacSign(
                        _signs[_selectedIndex]['name'] as String,
                      );
                      StorageService.setBirthDate(tempDate);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          colors: [
                            _gold.withOpacity(0.12),
                            _gold.withOpacity(0.06),
                            _gold.withOpacity(0.12),
                          ],
                        ),
                        border: Border.all(
                          color: _gold.withOpacity(0.2),
                          width: 0.8,
                        ),
                      ),
                      child: Center(
                        child: ShaderMask(
                          shaderCallback: (b) => const LinearGradient(
                            colors: [
                              Color(0xFFE8D5B7),
                              Color(0xFFFFE8A1),
                              Color(0xFFFFD060),
                            ],
                          ).createShader(b),
                          child: Text(
                            'ONAYLA',
                            style: GoogleFonts.cinzel(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Alt güvenli alan
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showZodiacPickerForCompatibility(Map<String, dynamic> mySign) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.55,
            decoration: BoxDecoration(
              color: const Color(0xFF0F1210).withOpacity(0.85),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              border: Border(
                top: BorderSide(color: _gold.withOpacity(0.3), width: 1.0),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 36,
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      colors: [
                        _gold.withOpacity(0.1),
                        _gold.withOpacity(0.4),
                        _gold.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'BİR BURÇ SEÇİN',
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'Uyum oranınızı görmek için partnerinizi seçin',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: _signs.length,
                    itemBuilder: (context, index) {
                      final sign = _signs[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) =>
                                  _CompatibilityResultPage(
                                    sign1: mySign,
                                    sign2: sign,
                                    gold: _gold,
                                  ),
                              transitionsBuilder: (_, a, __, child) =>
                                  FadeTransition(opacity: a, child: child),
                              transitionDuration: const Duration(
                                milliseconds: 400,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _gold.withOpacity(0.15)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                sign['image'] as String,
                                width: 45,
                                height: 45,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                sign['nameEn'].toString().toUpperCase(),
                                style: GoogleFonts.cinzel(
                                  color: _gold,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = _signs[_selectedIndex];
    final greeting = _userName != null
        ? 'Merhaba $_userName,'
        : 'Kozmik Yolcu,';
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Arka plan
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.5),
                radius: 1.3,
                colors: [
                  _goldD.withOpacity(0.25),
                  _bg,
                  const Color(0xFF0A0D0A),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // 🌀 Geometrik mandala arka plan
          Positioned(
            top: 20,
            right: -40,
            child: AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) => Opacity(
                opacity: 0.10 + _pulse.value * 0.05,
                child: Transform.rotate(
                  angle: _pulse.value * 0.1,
                  child: SizedBox(
                    width: 320,
                    height: 320,
                    child: CustomPaint(painter: _MandalaPainter(color: _gold)),
                  ),
                ),
              ),
            ),
          ),

          // 🌌 Yıldız parçacıkları
          ...List.generate(25, (i) {
            final rng = math.Random(i * 13 + 7);
            final x = rng.nextDouble() * MediaQuery.of(context).size.width;
            final y =
                rng.nextDouble() * MediaQuery.of(context).size.height * 0.6;
            final sz = 1.0 + rng.nextDouble() * 2.0;
            final op = 0.06 + rng.nextDouble() * 0.18;
            final bright = i % 6 == 0;
            return Positioned(
              left: x,
              top: y,
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) => Opacity(
                  opacity: bright ? op + _pulse.value * 0.12 : op,
                  child: Container(
                    width: sz,
                    height: sz,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _gold,
                      boxShadow: bright
                          ? [
                              BoxShadow(
                                color: _gold.withOpacity(0.25),
                                blurRadius: 5,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ),
            );
          }),

          SafeArea(
            top: false,
            bottom: false,
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).padding.top + 8,
                        ),
                        // ── ÜST BAR ──
                        Row(children: [const GlassBackButton()]),

                        // ── 🔶 DÖNEN ELMAS ÇERÇEVESİ ──
                        Transform.translate(
                          offset: const Offset(0, -35),
                          child: _fadeIn(
                            100,
                            Center(
                              child: SizedBox(
                                width: 310,
                                height: 340,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Dış parıltı
                                    Transform.rotate(
                                      angle: math.pi / 4,
                                      child: Container(
                                        width: 220,
                                        height: 220,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: _gold.withOpacity(0.08),
                                              blurRadius: 30,
                                              spreadRadius: 8,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Dış elmas çerçeve
                                    Transform.rotate(
                                      angle: math.pi / 4,
                                      child: Container(
                                        width: 215,
                                        height: 215,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            22,
                                          ),
                                          border: Border.all(
                                            color: _gold.withOpacity(0.15),
                                            width: 0.8,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // İç elmas — illüstrasyon
                                    Transform.rotate(
                                      angle: math.pi / 4,
                                      child: Container(
                                        width: 200,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          border: Border.all(
                                            color: _gold.withOpacity(0.35),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            16.5,
                                          ),
                                          child: Transform.rotate(
                                            angle: -math.pi / 4,
                                            child: Transform.scale(
                                              scale: 1.45,
                                              child: Image.asset(
                                                s['image'] as String,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Köşe parıltı noktaları (4 köşe)
                                    ...List.generate(4, (i) {
                                      final angle =
                                          i * math.pi / 2 - math.pi / 2;
                                      const dist = 112.0;
                                      return Positioned(
                                        left: 155 + math.cos(angle) * dist - 4,
                                        top: 145 + math.sin(angle) * dist - 4,
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: _gold.withOpacity(0.6),
                                            boxShadow: [
                                              BoxShadow(
                                                color: _gold.withOpacity(0.3),
                                                blurRadius: 8,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                    // İsim — altta (Estetik, premium tasarım)
                                    Positioned(
                                      bottom: 2,
                                      child: ShaderMask(
                                        shaderCallback: (b) =>
                                            const LinearGradient(
                                              colors: [
                                                Color(0xFFE8D5B7),
                                                Color(0xFFFFE8A1),
                                                Color(0xFFFFD060),
                                              ],
                                            ).createShader(b),
                                        child: Text(
                                          (s['nameEn'] as String).toUpperCase(),
                                          style: GoogleFonts.cinzel(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: 4,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ── ✨ TARİH SEÇİCİ ──
                        Transform.translate(
                          offset: const Offset(0, -30),
                          child: _fadeIn(
                            250,
                            Center(
                              child: GestureDetector(
                                onTap: _showDatePicker,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      colors: [
                                        _gold.withOpacity(0.03),
                                        _gold.withOpacity(0.06),
                                        _gold.withOpacity(0.03),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: _gold.withOpacity(0.15),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '✦',
                                        style: TextStyle(
                                          color: _gold.withOpacity(0.3),
                                          fontSize: 7,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _dateChip(
                                        _birthDate.day.toString().padLeft(
                                          2,
                                          '0',
                                        ),
                                      ),
                                      _dateSep(),
                                      _dateChip(
                                        _birthDate.month.toString().padLeft(
                                          2,
                                          '0',
                                        ),
                                      ),
                                      _dateSep(),
                                      _dateChip(_birthDate.year.toString()),
                                      const SizedBox(width: 8),
                                      Text(
                                        '✦',
                                        style: TextStyle(
                                          color: _gold.withOpacity(0.3),
                                          fontSize: 7,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ── ELEMENT / GEZEGEN / NİTELİK ──
                        _fadeIn(
                          400,
                          Row(
                            children: [
                              Expanded(
                                child: _cosmicAttribute(
                                  _ElementSymbolPainter(
                                    element: s['element'] as String,
                                    color: _gold,
                                  ),
                                  'Element',
                                  s['element'] as String,
                                ),
                              ),
                              Expanded(
                                child: _cosmicAttribute(
                                  _PlanetSymbolPainter(
                                    planet: s['planet'] as String,
                                    color: _gold,
                                  ),
                                  'Gezegen',
                                  s['planet'] as String,
                                ),
                              ),
                              Expanded(
                                child: _cosmicAttribute(
                                  _QualitySymbolPainter(
                                    quality: s['quality'] as String,
                                    color: _gold,
                                  ),
                                  'Modalite',
                                  s['quality'] as String,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ── KOZMİK REHBERİN — Günlük Fal + Kişilik Birleşik Kart ──
                        _fadeIn(
                          500,
                          Container(
                            padding: const EdgeInsets.all(0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.08),
                                  Colors.white.withOpacity(0.03),
                                ],
                              ),
                              border: Border.all(
                                color: _gold.withOpacity(0.12),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // ── Üst dekoratif şerit ──
                                Container(
                                  padding: const EdgeInsets.fromLTRB(
                                    24,
                                    20,
                                    24,
                                    16,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(28),
                                    ),
                                    gradient: LinearGradient(
                                      colors: [
                                        _gold.withOpacity(0.06),
                                        Colors.transparent,
                                        _gold.withOpacity(0.06),
                                      ],
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Custom yıldız ikonu
                                      SizedBox(
                                        width: 28,
                                        height: 28,
                                        child: CustomPaint(
                                          painter: _CosmicStarPainter(
                                            color: _gold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ShaderMask(
                                              shaderCallback: (b) =>
                                                  const LinearGradient(
                                                    colors: [
                                                      Color(0xFFE8D5B7),
                                                      Color(0xFFFFE8A1),
                                                      Color(0xFFFFD060),
                                                    ],
                                                  ).createShader(b),
                                              child: Text(
                                                'KOZMİK REHBERİN',
                                                style: GoogleFonts.cinzel(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 2,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Bugünün mesajı & ruhsal portre',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.3,
                                                ),
                                                fontSize: 11,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // ── Günlük mesaj bölümü ──
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    0,
                                    20,
                                    20,
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      color: _gold.withOpacity(0.04),
                                      border: Border.all(
                                        color: _gold.withOpacity(0.08),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 3,
                                              height: 14,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    _gold.withOpacity(0.6),
                                                    _gold.withOpacity(0.1),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              'Günün Fısıltısı',
                                              style: GoogleFonts.cinzel(
                                                color: _gold.withOpacity(0.8),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          s['dailyHoroscope'] as String,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.8,
                                            ),
                                            fontSize: 14,
                                            height: 1.7,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // ── İnce dekoratif ayırıcı ──
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 0.3,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.transparent,
                                                _gold.withOpacity(0.2),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        child: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CustomPaint(
                                            painter: _CosmicEyePainter(
                                              color: _gold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 0.3,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                _gold.withOpacity(0.2),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // ── Kişilik portresi bölümü ──
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    24,
                                    16,
                                    24,
                                    24,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 3,
                                            height: 14,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  _gold.withOpacity(0.6),
                                                  _gold.withOpacity(0.1),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Ruhsal Portre',
                                            style: GoogleFonts.cinzel(
                                              color: _gold.withOpacity(0.8),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        s['description'] as String,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.75),
                                          fontSize: 14,
                                          height: 1.75,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── ANALİTİK PROFİL — Güçlü Yanlar & Gelişim ──
                        _fadeIn(700, _analyticsCard(s)),

                        const SizedBox(height: 28),

                        // ── KOZMİK BAĞLANTILAR — Burç Uyumu ──
                        _fadeIn(800, _compatibilityCard(s)),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // YARDIMCI WİDGETLER
  // ═══════════════════════════════════════════

  // ── Analitik Güçlü Yanlar & Gelişim Kartı ──
  Widget _analyticsCard(Map<String, dynamic> s) {
    final strengths = s['strengths'] as List<String>;
    final weaknesses = s['weaknesses'] as List<String>;
    final traits = s['traits'] as List<String>;
    final name = s['name'] as String;

    final values = List.generate(traits.length > 6 ? 6 : traits.length, (i) {
      final h = (traits[i].hashCode ^ (i * 7919)).abs() % 100;
      return 0.55 + (h % 40) / 100.0;
    });
    final displayTraits = traits.take(6).toList();

    const usageHints = <String, String>{
      'Doğal liderlik': 'Takım kurmada kullan',
      'Cesaret ve atılganlık': 'Risk alırken avantajın',
      'Girişimci ruh': 'Yeni projeler başlat',
      'Kararlılık': 'Uzun vadeli hedefler koy',
      'Güvenilirlik': 'Güven inşa et',
      'Sabır': 'Stratejik sabırla büyü',
      'Çift yönlü bakış': 'Arabuluculukta parla',
      'İletişim dehası': 'Fikirlerini yay',
      'Hızlı öğrenme': 'Yeni beceriler edin',
      'Duygusal zekâ': 'İlişkileri derinleştir',
      'Koruyucu doğa': 'Güvenli alan yarat',
      'Sezgisel güç': 'İç sesini dinle',
      'Doğal karizma': 'İlham kaynağı ol',
      'Yaratıcı enerji': 'Sanatla ifade et',
      'Cömertlik': 'Paylaştıkça çoğal',
      'Analitik zekâ': 'Verileri analiz et',
      'Düzen ve organizasyon': 'Sistematik ilerle',
      'Hizmet ruhu': 'Topluma değer kat',
      'Diplomatik yetenek': 'Köprüler kur',
      'Estetik anlayış': 'Güzelliği yarat',
      'Adalet duygusu': 'Dengeyi koru',
      'Derin sezgi': 'Görünmeyeni gör',
      'Yeniden doğuş gücü': 'Krizleri fırsata çevir',
      'Sadakat': 'Derin bağlar kur',
      'Vizyon genişliği': 'Büyük resmi gör',
      'Macera ruhu': 'Keşfetmeye devam et',
      'Felsefi derinlik': 'Bilgeliğini paylaş',
      'İrade gücü': 'Hedefine odaklan',
      'Uzun vadeli planlama': 'Geleceğini inşa et',
      'Sorumluluk bilinci': 'Güvenilir ol',
      'Özgün düşünce': 'Farklılığını kucakla',
      'İnsancıl bakış': 'Empatiyle yaklaş',
      'Devrimci ruh': 'Değişimi başlat',
      'Sınırsız empati': 'Kalbiyle dinle',
      'Sanatsal yetenek': 'Yaratıcılığını keşfet',
      'Ruhani derinlik': 'İçsel yolculuğa çık',
    };

    const growthTips = <String, String>{
      'Sabırsızlık': 'Nefes al, sürece güven',
      'Düşünmeden hareket': 'Dur, düşün, sonra adım at',
      'Hırslı olma': 'Yolculuğun tadını çıkar',
      'İnatçılık': 'Farklı bakış açılarına alan aç',
      'Değişime direnç': 'Küçük değişimlerle başla',
      'Aşırı sahiplenme': 'Güvenerek bırak',
      'Kararsızlık': 'Sezgilerine daha çok güven',
      'Yüzeysellik': 'Bir konuda derinleş',
      'Huzursuzluk': 'Şimdiki anda kal',
      'Aşırı hassasiyet': 'Koruyucu sınırlar belirle',
      'Aşırı korumacılık': 'Güvenmeyi öğren',
      'Geçmişe takılma': 'Bugüne odaklan',
      'Ego': 'Alçakgönüllülüğü keşfet',
      'Diktatörlük': 'Dinleme sanatını geliştir',
      'Beğenilme ihtiyacı': 'Kendi onayın yeter',
      'Aşırı eleştirellik': 'Olduğu gibi kabul et',
      'Mükemmeliyetçilik': 'Yeterli, yeterlidir',
      'Endişe eğilimi': 'Şükranla düşün',
      'Kararsız doğa': 'Önceliklendirmeyi öğren',
      'Başkalarına bağımlılık': 'Kendi gücünü bul',
      'Çatışmadan kaçma': 'Cesaretle yüzleş',
      'Kıskançlık': 'Bolluk zihniyetini benimse',
      'İntikamcılık': 'Bırak gitsin',
      'Aşırı kontrol': 'Akışa güven',
      'Sorumsuzluk': 'Küçük sözler ver ve tut',
      'Aşırı dürüstlük': 'Nazikçe doğruyu söyle',
      'Taahhüt korkusu': 'Adım adım bağlan',
      'Aşırı ciddiyet': 'Oyun oyna, gül',
      'Duygularını bastırma': 'Hissettiklerini yaz',
      'İş koliklik': 'Dengeyi bul',
      'Duygusal mesafe': 'Bir adım yaklaş',
      'Asi tutum': 'Yapıcı isyan öğren',
      'Gerçeklikten kaçış': 'Ayaklarını yere bas',
      'Sınır koyamama': 'Hayır demek de sevgidir',
    };

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.07),
            Colors.white.withOpacity(0.02),
          ],
        ),
        border: Border.all(color: _gold.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Başlık ──
          Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 6),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              gradient: LinearGradient(
                colors: [
                  _gold.withOpacity(0.05),
                  Colors.transparent,
                  _gold.withOpacity(0.05),
                ],
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CustomPaint(
                    painter: _AnalyticsDiamondPainter(color: _gold),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (b) => const LinearGradient(
                          colors: [
                            Color(0xFFE8D5B7),
                            Color(0xFFFFE8A1),
                            Color(0xFFFFD060),
                          ],
                        ).createShader(b),
                        child: Text(
                          'KARAKTERİSTİK ANALİZ',
                          style: GoogleFonts.cinzel(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$name burcunun yetenek haritası',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── RADAR CHART ──
          const SizedBox(height: 8),
          SizedBox(
            width: 310,
            height: 290,
            child: CustomPaint(
              painter: _RadarChartPainter(
                labels: displayTraits,
                values: values,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Keşfet Butonu ──
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 4, 22, 20),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) =>
                      _ZodiacDetailPage(sign: s, gold: _gold),
                  transitionsBuilder: (_, a, __, child) =>
                      FadeTransition(opacity: a, child: child),
                  transitionDuration: const Duration(milliseconds: 400),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      _gold.withOpacity(0.08),
                      _gold.withOpacity(0.03),
                      _gold.withOpacity(0.08),
                    ],
                  ),
                  border: Border.all(color: _gold.withOpacity(0.15)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CustomPaint(
                        painter: _CosmicEyePainter(color: _gold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ShaderMask(
                      shaderCallback: (b) => const LinearGradient(
                        colors: [
                          Color(0xFFE8D5B7),
                          Color(0xFFFFE8A1),
                          Color(0xFFFFD060),
                        ],
                      ).createShader(b),
                      child: Text(
                        'KENDİNİ KEŞFET',
                        style: GoogleFonts.cinzel(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: _gold.withOpacity(0.4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateChip(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6),
      color: _gold.withOpacity(0.03),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: _gold.withOpacity(0.7),
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    ),
  );

  Widget _dateSep() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: Container(
      width: 2.5,
      height: 2.5,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _gold.withOpacity(0.25),
      ),
    ),
  );

  Widget _fadeIn(int delayMs, Widget child) => _FadeSlideIn(
    delay: Duration(milliseconds: delayMs),
    child: child,
  );

  Widget _topBadge(String symbol, String name) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: _goldD.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _gold.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(symbol, style: TextStyle(color: _gold, fontSize: 16)),
        const SizedBox(width: 8),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );

  Widget _cosmicAttribute(CustomPainter painter, String label, String value) =>
      Column(
        children: [
          SizedBox(width: 36, height: 36, child: CustomPaint(painter: painter)),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 10,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: _gold.withOpacity(0.85),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );

  Widget _glassCard({required Widget child}) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.06),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: _gold.withOpacity(0.1)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: child,
  );

  Widget _sectionTitle(String emoji, String title) => Row(
    children: [
      Text(emoji, style: const TextStyle(fontSize: 20)),
      const SizedBox(width: 10),
      Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );

  Widget _compatibilityCard(Map<String, dynamic> currentSignData) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _gold.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CustomPaint(painter: _CosmicEyePainter(color: _gold)),
              ),
              const SizedBox(width: 10),
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [
                    Color(0xFFE8D5B7),
                    Color(0xFFFFE8A1),
                    Color(0xFFFFD060),
                  ],
                ).createShader(b),
                child: Text(
                  'KOZMİK UYUMUNU ÖLÇ',
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Kendi burcunu seç ve yıldızların ne dediğini gör',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _gold.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _gold.withOpacity(0.1),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        currentSignData['image'] as String,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentSignData['nameEn'].toString().toUpperCase(),
                    style: GoogleFonts.cinzel(
                      color: _gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.all_inclusive,
                color: _gold.withOpacity(0.6),
                size: 28,
              ),
              GestureDetector(
                onTap: () => _showZodiacPickerForCompatibility(currentSignData),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: CustomPaint(
                        painter: _DashedCirclePainter(color: _gold),
                        child: Center(
                          child: Text(
                            '?',
                            style: GoogleFonts.cinzel(
                              color: _gold,
                              fontSize: 32,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _gold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _gold.withOpacity(0.3)),
                      ),
                      child: Text(
                        'BURÇ SEÇ',
                        style: TextStyle(
                          color: _gold,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── FADE + SLIDE IN ANİMASYONU ──
class _FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _FadeSlideIn({required this.child, required this.delay});
  @override
  State<_FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<_FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _opacity,
    child: SlideTransition(position: _offset, child: widget.child),
  );
}

// ── Takımyıldızı çizici ──
class _ConstellationPainter extends CustomPainter {
  final int signIndex;
  final Color color;
  _ConstellationPainter({required this.signIndex, required this.color});

  // Her burç için takımyıldızı yıldız koordinatları (0-1 normalize)
  static const List<List<List<double>>> _stars = [
    // 0-Koç: Hamal, Sheratan, Mesarthim, 41 Ari
    [
      [0.2, 0.3],
      [0.35, 0.25],
      [0.5, 0.35],
      [0.65, 0.5],
      [0.55, 0.65],
    ],
    // 1-Boğa: Aldebaran, Elnath, Hyades V-şekli
    [
      [0.3, 0.5],
      [0.4, 0.35],
      [0.5, 0.4],
      [0.55, 0.3],
      [0.7, 0.2],
      [0.45, 0.55],
      [0.35, 0.6],
    ],
    // 2-İkizler: Castor, Pollux, paralel çizgiler
    [
      [0.3, 0.15],
      [0.35, 0.3],
      [0.3, 0.5],
      [0.25, 0.7],
      [0.55, 0.2],
      [0.6, 0.35],
      [0.55, 0.55],
      [0.5, 0.7],
    ],
    // 3-Yengeç: küçük ters Y
    [
      [0.4, 0.3],
      [0.5, 0.45],
      [0.6, 0.3],
      [0.45, 0.6],
      [0.55, 0.6],
      [0.5, 0.75],
    ],
    // 4-Aslan: orak + üçgen
    [
      [0.2, 0.4],
      [0.3, 0.25],
      [0.45, 0.2],
      [0.55, 0.3],
      [0.5, 0.45],
      [0.65, 0.5],
      [0.75, 0.4],
      [0.8, 0.55],
      [0.7, 0.6],
    ],
    // 5-Başak: Y-şekil + uzantı
    [
      [0.15, 0.35],
      [0.3, 0.4],
      [0.45, 0.35],
      [0.55, 0.45],
      [0.5, 0.55],
      [0.65, 0.6],
      [0.75, 0.5],
      [0.4, 0.6],
      [0.35, 0.75],
    ],
    // 6-Terazi: terazi kefeleri
    [
      [0.3, 0.3],
      [0.5, 0.25],
      [0.7, 0.3],
      [0.5, 0.5],
      [0.35, 0.6],
      [0.65, 0.6],
    ],
    // 7-Akrep: S-eğrisi + iğne
    [
      [0.15, 0.3],
      [0.25, 0.35],
      [0.35, 0.4],
      [0.45, 0.5],
      [0.55, 0.55],
      [0.6, 0.65],
      [0.55, 0.75],
      [0.45, 0.8],
      [0.5, 0.9],
    ],
    // 8-Yay: ok + yay
    [
      [0.2, 0.6],
      [0.35, 0.45],
      [0.5, 0.3],
      [0.65, 0.15],
      [0.4, 0.55],
      [0.55, 0.5],
      [0.6, 0.6],
      [0.5, 0.7],
      [0.45, 0.65],
    ],
    // 9-Oğlak: üçgen + kuyruk
    [
      [0.25, 0.3],
      [0.4, 0.25],
      [0.55, 0.35],
      [0.65, 0.45],
      [0.55, 0.55],
      [0.4, 0.6],
      [0.3, 0.5],
      [0.7, 0.6],
      [0.8, 0.7],
    ],
    // 10-Kova: zigzag su
    [
      [0.2, 0.3],
      [0.3, 0.25],
      [0.35, 0.4],
      [0.45, 0.35],
      [0.5, 0.5],
      [0.6, 0.45],
      [0.65, 0.6],
      [0.75, 0.55],
    ],
    // 11-Balık: iki halka + bağ
    [
      [0.15, 0.4],
      [0.25, 0.3],
      [0.35, 0.35],
      [0.25, 0.5],
      [0.4, 0.5],
      [0.55, 0.5],
      [0.65, 0.4],
      [0.75, 0.45],
      [0.8, 0.55],
      [0.7, 0.6],
    ],
  ];

  // Her burç için yıldızlar arası bağlantılar (indeks çiftleri)
  static const List<List<List<int>>> _lines = [
    [
      [0, 1],
      [1, 2],
      [2, 3],
      [3, 4],
    ],
    [
      [0, 1],
      [1, 2],
      [2, 3],
      [3, 4],
      [1, 5],
      [5, 6],
    ],
    [
      [0, 1],
      [1, 2],
      [2, 3],
      [4, 5],
      [5, 6],
      [6, 7],
    ],
    [
      [0, 1],
      [1, 2],
      [1, 3],
      [1, 4],
      [3, 4],
      [4, 5],
    ],
    [
      [0, 1],
      [1, 2],
      [2, 3],
      [3, 4],
      [4, 5],
      [5, 6],
      [6, 7],
      [7, 8],
    ],
    [
      [0, 1],
      [1, 2],
      [2, 3],
      [3, 4],
      [4, 5],
      [5, 6],
      [1, 7],
      [7, 8],
    ],
    [
      [0, 1],
      [1, 2],
      [1, 3],
      [3, 4],
      [3, 5],
    ],
    [
      [0, 1],
      [1, 2],
      [2, 3],
      [3, 4],
      [4, 5],
      [5, 6],
      [6, 7],
      [7, 8],
    ],
    [
      [0, 1],
      [1, 2],
      [2, 3],
      [1, 4],
      [4, 5],
      [5, 6],
      [6, 7],
      [7, 8],
    ],
    [
      [0, 1],
      [1, 2],
      [2, 3],
      [3, 4],
      [4, 5],
      [5, 6],
      [6, 0],
      [3, 7],
      [7, 8],
    ],
    [
      [0, 1],
      [1, 2],
      [2, 3],
      [3, 4],
      [4, 5],
      [5, 6],
      [6, 7],
    ],
    [
      [0, 1],
      [1, 2],
      [2, 3],
      [3, 0],
      [3, 4],
      [4, 5],
      [5, 6],
      [6, 7],
      [7, 8],
      [8, 9],
    ],
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
      canvas.drawLine(
        Offset(a[0] * w, a[1] * h),
        Offset(b[0] * w, b[1] * h),
        linePaint,
      );
    }

    // Yıldız noktaları
    for (int i = 0; i < stars.length; i++) {
      final s = stars[i];
      final pos = Offset(s[0] * w, s[1] * h);
      final isMajor = i == 0 || i == stars.length - 1;
      // Dış glow
      canvas.drawCircle(
        pos,
        isMajor ? 5 : 3,
        Paint()..color = color.withOpacity(isMajor ? 0.15 : 0.08),
      );
      // İç nokta
      canvas.drawCircle(
        pos,
        isMajor ? 2.5 : 1.8,
        Paint()..color = color.withOpacity(isMajor ? 0.7 : 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConstellationPainter old) =>
      old.signIndex != signIndex;
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
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        circlePaint..color = color.withOpacity(0.15 + (5 - i) * 0.05),
      );
    }

    // 12 radyal çizgi
    final linePaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 0; i < 12; i++) {
      final angle = i * math.pi * 2 / 12;
      canvas.drawLine(
        Offset(
          cx + math.cos(angle) * maxR * 0.2,
          cy + math.sin(angle) * maxR * 0.2,
        ),
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
        if (i == 0)
          path.moveTo(x, y);
        else
          path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, starPaint);
    }

    // Kesişim noktaları
    final dotPaint = Paint()..color = color.withOpacity(0.35);
    for (int i = 0; i < 12; i++) {
      final angle = i * math.pi * 2 / 12;
      canvas.drawCircle(
        Offset(cx + math.cos(angle) * maxR, cy + math.sin(angle) * maxR),
        1.8,
        dotPaint,
      );
      canvas.drawCircle(
        Offset(
          cx + math.cos(angle) * maxR * 0.6,
          cy + math.sin(angle) * maxR * 0.6,
        ),
        1.2,
        Paint()..color = color.withOpacity(0.25),
      );
    }

    // Merkez
    canvas.drawCircle(
      Offset(cx, cy),
      3,
      Paint()..color = color.withOpacity(0.3),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      1.5,
      Paint()..color = color.withOpacity(0.5),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Element sembol çizici (Organik) ──
class _ElementSymbolPainter extends CustomPainter {
  final String element;
  final Color color;
  _ElementSymbolPainter({required this.element, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final pen = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    final dotP = Paint()..color = color.withOpacity(0.4);

    switch (element) {
      case 'Ateş':
        // Klasik stilize alev ikonu (referans görseldeki gibi)
        // Ana alev gövdesi (S eğrili, yukarı uzanan)
        final flame = Path();
        flame.moveTo(cx + 2, cy + 14);
        flame.cubicTo(cx - 8, cy + 10, cx - 12, cy + 2, cx - 8, cy - 4);
        flame.cubicTo(cx - 5, cy - 8, cx - 2, cy - 6, cx - 3, cy - 2);
        flame.cubicTo(cx - 5, cy + 2, cx - 4, cy + 4, cx, cy + 2);
        flame.cubicTo(cx + 6, cy - 2, cx + 2, cy - 10, cx, cy - 16);
        flame.cubicTo(cx + 8, cy - 10, cx + 14, cy, cx + 10, cy + 8);
        flame.cubicTo(cx + 8, cy + 12, cx + 6, cy + 14, cx + 2, cy + 14);
        canvas.drawPath(flame, pen);

        // İç alev dili (ters S, daha soluk)
        final inner = Path();
        inner.moveTo(cx + 1, cy + 12);
        inner.cubicTo(cx - 4, cy + 10, cx - 6, cy + 4, cx - 3, cy);
        inner.cubicTo(cx, cy - 4, cx + 2, cy - 2, cx + 1, cy + 2);
        canvas.drawPath(inner, pen..color = color.withOpacity(0.4));

        // Sağ iç alev (küçük ikinci dil)
        final r = Path();
        r.moveTo(cx + 3, cy + 12);
        r.cubicTo(cx + 8, cy + 8, cx + 8, cy + 2, cx + 4, cy - 4);
        r.cubicTo(cx + 6, cy, cx + 6, cy + 4, cx + 4, cy + 8);
        canvas.drawPath(r, pen..color = color.withOpacity(0.35));
        break;
      case 'Toprak':
        // Minimalist ağaç — ince gövde + yuvarlak taç
        // Gövde
        canvas.drawLine(Offset(cx, cy + 14), Offset(cx, cy), pen);
        // Taç (daire)
        canvas.drawCircle(Offset(cx, cy - 6), 10, pen);
        // İç dallanma
        canvas.drawLine(
          Offset(cx, cy),
          Offset(cx - 4, cy - 6),
          pen..color = color.withOpacity(0.3),
        );
        canvas.drawLine(
          Offset(cx, cy),
          Offset(cx + 3, cy - 8),
          pen..color = color.withOpacity(0.3),
        );
        // Kök çizgileri
        canvas.drawLine(
          Offset(cx, cy + 14),
          Offset(cx - 5, cy + 16),
          pen..color = color.withOpacity(0.2),
        );
        canvas.drawLine(
          Offset(cx, cy + 14),
          Offset(cx + 4, cy + 16),
          pen..color = color.withOpacity(0.2),
        );
        // Zemin
        canvas.drawLine(
          Offset(cx - 8, cy + 14),
          Offset(cx + 8, cy + 14),
          pen..color = color.withOpacity(0.15),
        );
        break;
      case 'Hava':
        // Kıvrımlı rüzgar girdapları (Referans görseldeki hava akımları)
        final w1 = Path();
        // Üst uzun rüzgar (spiral dönüşlü)
        w1.moveTo(cx - 14, cy - 4);
        w1.cubicTo(cx - 6, cy - 4, cx - 4, cy - 12, cx + 4, cy - 12);
        w1.cubicTo(cx + 12, cy - 12, cx + 12, cy - 2, cx + 6, cy - 2);
        w1.cubicTo(cx, cy - 2, cx, cy - 8, cx + 5, cy - 8);
        canvas.drawPath(w1, pen);

        final w2 = Path();
        // Alt rüzgar (ikinci kıvrım)
        w2.moveTo(cx - 14, cy + 6);
        w2.cubicTo(cx - 4, cy + 6, cx - 6, cy + 1, cx, cy + 1);
        w2.cubicTo(cx + 8, cy + 1, cx + 8, cy + 11, cx + 2, cy + 11);
        w2.cubicTo(cx - 4, cy + 11, cx - 4, cy + 5, cx + 1, cy + 5);
        canvas.drawPath(w2, pen..color = color.withOpacity(0.6));

        // Rüzgar akımına kapılan birkaç detay noktası
        canvas.drawCircle(Offset(cx - 12, cy + 1), 0.8, dotP);
        canvas.drawCircle(Offset(cx + 10, cy + 4), 1.2, dotP);
        canvas.drawCircle(Offset(cx - 6, cy - 9), 1.0, dotP);
        break;
      case 'Su':
        // Üç su damlası (büyük merkez, sol üst orta, sağ üst küçük)
        final fillP = Paint()
          ..color = color.withOpacity(0.5)
          ..style = PaintingStyle.fill;
        final strokeP = Paint()
          ..color = color.withOpacity(0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        void drawDrop(double x, double y, double s) {
          final d = Path();
          d.moveTo(x, y - 7 * s);
          d.cubicTo(x + 1.5 * s, y - 3 * s, x + 5 * s, y + 2 * s, x, y + 6 * s);
          d.cubicTo(x - 5 * s, y + 2 * s, x - 1.5 * s, y - 3 * s, x, y - 7 * s);
          canvas.drawPath(d, fillP..color = color.withOpacity(0.12 + s * 0.03));
          canvas.drawPath(
            d,
            strokeP..color = color.withOpacity(0.48 + s * 0.06),
          );
        }
        drawDrop(cx, cy + 2, 2.0); // Büyük merkez
        drawDrop(cx - 9, cy - 6, 1.2); // Sol üst orta
        drawDrop(cx + 8, cy - 4, 0.8); // Sağ üst küçük
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _ElementSymbolPainter old) =>
      old.element != element;
}

// ── Gezegen sembol çizici ──
class _PlanetSymbolPainter extends CustomPainter {
  final String planet;
  final Color color;
  _PlanetSymbolPainter({required this.planet, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final pen = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final dotP = Paint()..color = color.withOpacity(0.5);

    switch (planet) {
      case 'Mars':
        // Daire + sağ üst ok
        canvas.drawCircle(Offset(cx - 2, cy + 2), 7, pen);
        canvas.drawLine(Offset(cx + 3, cy - 3), Offset(cx + 11, cy - 11), pen);
        canvas.drawLine(Offset(cx + 6, cy - 11), Offset(cx + 11, cy - 11), pen);
        canvas.drawLine(Offset(cx + 11, cy - 11), Offset(cx + 11, cy - 6), pen);
        break;
      case 'Venüs':
        // Daire + alt haç
        canvas.drawCircle(Offset(cx, cy - 4), 7, pen);
        canvas.drawLine(Offset(cx, cy + 3), Offset(cx, cy + 13), pen);
        canvas.drawLine(Offset(cx - 5, cy + 9), Offset(cx + 5, cy + 9), pen);
        break;
      case 'Merkür':
        // Daire + üst hilal + alt haç
        canvas.drawCircle(Offset(cx, cy), 6, pen);
        canvas.drawArc(
          Rect.fromCircle(center: Offset(cx, cy - 8), radius: 5),
          math.pi * 0.15,
          math.pi * 0.7,
          false,
          pen,
        );
        canvas.drawLine(Offset(cx, cy + 6), Offset(cx, cy + 13), pen);
        canvas.drawLine(Offset(cx - 4, cy + 10), Offset(cx + 4, cy + 10), pen);
        break;
      case 'Ay':
        // Hilal
        final outer = Path()
          ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: 10));
        final inner = Path()
          ..addOval(Rect.fromCircle(center: Offset(cx + 6, cy), radius: 9));
        canvas.drawPath(
          Path.combine(PathOperation.difference, outer, inner),
          pen
            ..style = PaintingStyle.fill
            ..color = color.withOpacity(0.15),
        );
        canvas.drawPath(
          Path.combine(PathOperation.difference, outer, inner),
          pen
            ..style = PaintingStyle.stroke
            ..color = color.withOpacity(0.5),
        );
        break;
      case 'Güneş':
        // Daire + merkez nokta + ışınlar
        canvas.drawCircle(Offset(cx, cy), 7, pen);
        canvas.drawCircle(Offset(cx, cy), 2, dotP);
        for (int i = 0; i < 8; i++) {
          final a = i * math.pi / 4;
          canvas.drawLine(
            Offset(cx + math.cos(a) * 9, cy + math.sin(a) * 9),
            Offset(cx + math.cos(a) * 12, cy + math.sin(a) * 12),
            pen,
          );
        }
        break;
      case 'Jüpiter':
        // 2 harfi: yatay çizgi üst, sol dikey, sağda eğri
        canvas.drawLine(Offset(cx - 4, cy - 6), Offset(cx + 8, cy - 6), pen);
        canvas.drawLine(Offset(cx + 2, cy - 12), Offset(cx + 2, cy + 10), pen);
        final arc = Path();
        arc.moveTo(cx - 8, cy - 2);
        arc.quadraticBezierTo(cx - 12, cy + 8, cx - 4, cy + 10);
        canvas.drawPath(arc, pen);
        break;
      case 'Satürn':
        // h harfi: dikey çizgi + eğri kuyruk
        canvas.drawLine(Offset(cx - 2, cy - 12), Offset(cx - 2, cy + 6), pen);
        canvas.drawLine(Offset(cx - 6, cy - 9), Offset(cx + 2, cy - 9), pen);
        final arc = Path();
        arc.moveTo(cx - 2, cy);
        arc.quadraticBezierTo(cx + 8, cy - 2, cx + 6, cy + 8);
        arc.quadraticBezierTo(cx + 4, cy + 14, cx - 4, cy + 12);
        canvas.drawPath(arc, pen);
        break;
      case 'Plüton':
        // Daire + üst yay + alt haç
        canvas.drawCircle(Offset(cx, cy - 2), 5, pen);
        canvas.drawArc(
          Rect.fromCircle(center: Offset(cx, cy - 8), radius: 7),
          math.pi * 0.15,
          math.pi * 0.7,
          false,
          pen,
        );
        canvas.drawLine(Offset(cx, cy + 3), Offset(cx, cy + 13), pen);
        canvas.drawLine(Offset(cx - 5, cy + 9), Offset(cx + 5, cy + 9), pen);
        break;
      case 'Uranüs':
        // Daire + dikey çizgi + üstte yatay anten
        canvas.drawCircle(Offset(cx, cy + 4), 6, pen);
        canvas.drawCircle(Offset(cx, cy + 4), 1.5, dotP);
        canvas.drawLine(Offset(cx, cy - 2), Offset(cx, cy - 14), pen);
        canvas.drawLine(Offset(cx - 6, cy - 10), Offset(cx + 6, cy - 10), pen);
        canvas.drawCircle(Offset(cx, cy - 14), 1.8, dotP);
        break;
      case 'Neptün':
        // Trident (üç çatallı yaba)
        canvas.drawLine(Offset(cx, cy + 12), Offset(cx, cy - 10), pen);
        canvas.drawLine(Offset(cx - 6, cy + 6), Offset(cx + 6, cy + 6), pen);
        // Üç çatal
        canvas.drawLine(Offset(cx - 8, cy - 6), Offset(cx - 8, cy - 12), pen);
        canvas.drawLine(Offset(cx, cy - 10), Offset(cx, cy - 14), pen);
        canvas.drawLine(Offset(cx + 8, cy - 6), Offset(cx + 8, cy - 12), pen);
        // Yay bağlantısı
        final arc = Path();
        arc.moveTo(cx - 8, cy - 6);
        arc.quadraticBezierTo(cx - 4, cy - 2, cx, cy - 10);
        arc.quadraticBezierTo(cx + 4, cy - 2, cx + 8, cy - 6);
        canvas.drawPath(arc, pen);
        // Uç noktaları
        canvas.drawCircle(Offset(cx - 8, cy - 12), 1.5, dotP);
        canvas.drawCircle(Offset(cx, cy - 14), 1.5, dotP);
        canvas.drawCircle(Offset(cx + 8, cy - 12), 1.5, dotP);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _PlanetSymbolPainter old) =>
      old.planet != planet;
}

// ── Nitelik sembol çizici ──
class _QualitySymbolPainter extends CustomPainter {
  final String quality;
  final Color color;
  _QualitySymbolPainter({required this.quality, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final pen = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    switch (quality) {
      case 'Öncü': // Kare köşeleri açık — hareket, yön
        final p = Path();
        p.moveTo(cx, cy - 12);
        p.lineTo(cx + 10, cy);
        p.lineTo(cx, cy + 12);
        p.lineTo(cx - 10, cy);
        p.close();
        canvas.drawPath(p, pen);
        // İç ok (yukarı)
        canvas.drawLine(
          Offset(cx, cy + 5),
          Offset(cx, cy - 5),
          pen..color = color.withOpacity(0.4),
        );
        canvas.drawLine(Offset(cx - 3, cy - 2), Offset(cx, cy - 5), pen);
        canvas.drawLine(Offset(cx + 3, cy - 2), Offset(cx, cy - 5), pen);
        break;
      case 'Sabit': // Kare — stabilite, sağlamlık
        canvas.drawRect(
          Rect.fromCenter(center: Offset(cx, cy), width: 20, height: 20),
          pen,
        );
        // İç artı
        canvas.drawLine(
          Offset(cx - 5, cy),
          Offset(cx + 5, cy),
          pen..color = color.withOpacity(0.3),
        );
        canvas.drawLine(
          Offset(cx, cy - 5),
          Offset(cx, cy + 5),
          pen..color = color.withOpacity(0.3),
        );
        // Köşe noktaları
        for (final o in [
          Offset(cx - 10, cy - 10),
          Offset(cx + 10, cy - 10),
          Offset(cx + 10, cy + 10),
          Offset(cx - 10, cy + 10),
        ]) {
          canvas.drawCircle(o, 1.5, Paint()..color = color.withOpacity(0.4));
        }
        break;
      case 'Değişken': // Spiral / iki yönlü ok — esneklik
        // İki yönlü yay
        canvas.drawArc(
          Rect.fromCenter(center: Offset(cx, cy - 3), width: 20, height: 16),
          math.pi,
          math.pi,
          false,
          pen,
        );
        canvas.drawArc(
          Rect.fromCenter(center: Offset(cx, cy + 3), width: 20, height: 16),
          0,
          math.pi,
          false,
          pen,
        );
        // Uç noktalarında küçük oklar
        canvas.drawCircle(
          Offset(cx - 10, cy - 3),
          1.5,
          Paint()..color = color.withOpacity(0.5),
        );
        canvas.drawCircle(
          Offset(cx + 10, cy + 3),
          1.5,
          Paint()..color = color.withOpacity(0.5),
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _QualitySymbolPainter old) =>
      old.quality != quality;
}

// ── Kozmik Yıldız İkonu (Custom) ──
class _CosmicStarPainter extends CustomPainter {
  final Color color;
  _CosmicStarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final p = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // 4 ana ışın (uzun, ince)
    for (int i = 0; i < 4; i++) {
      final a = i * math.pi / 2;
      canvas.drawLine(
        c + Offset(math.cos(a) * r * 0.15, math.sin(a) * r * 0.15),
        c + Offset(math.cos(a) * r * 0.9, math.sin(a) * r * 0.9),
        p,
      );
    }
    // 4 çapraz ışın (kısa)
    for (int i = 0; i < 4; i++) {
      final a = i * math.pi / 2 + math.pi / 4;
      canvas.drawLine(
        c + Offset(math.cos(a) * r * 0.1, math.sin(a) * r * 0.1),
        c + Offset(math.cos(a) * r * 0.5, math.sin(a) * r * 0.5),
        p
          ..strokeWidth = 1.0
          ..color = color.withOpacity(0.5),
      );
    }
    // Merkez parıltı
    canvas.drawCircle(
      c,
      r * 0.12,
      Paint()
        ..color = color.withOpacity(0.9)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      c,
      r * 0.25,
      Paint()
        ..shader = RadialGradient(
          colors: [color.withOpacity(0.3), Colors.transparent],
        ).createShader(Rect.fromCircle(center: c, radius: r * 0.25)),
    );
  }

  @override
  bool shouldRepaint(covariant _CosmicStarPainter old) => false;
}

// ── Mistik Göz İkonu (Custom) ──
class _CosmicEyePainter extends CustomPainter {
  final Color color;
  _CosmicEyePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final w = size.width;
    final h = size.height;
    final p = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    // Üst göz kapağı
    final top = Path()
      ..moveTo(0, c.dy)
      ..quadraticBezierTo(w * 0.5, -h * 0.15, w, c.dy);
    canvas.drawPath(top, p);
    // Alt göz kapağı
    final bot = Path()
      ..moveTo(0, c.dy)
      ..quadraticBezierTo(w * 0.5, h * 1.15, w, c.dy);
    canvas.drawPath(bot, p);
    // İris
    canvas.drawCircle(
      c,
      w * 0.18,
      Paint()
        ..color = color.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    // Göz bebeği
    canvas.drawCircle(
      c,
      w * 0.08,
      Paint()
        ..color = color.withOpacity(0.6)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _CosmicEyePainter old) => false;
}

// ── Analitik Elmas İkonu (Custom) ──
class _AnalyticsDiamondPainter extends CustomPainter {
  final Color color;
  _AnalyticsDiamondPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final p = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    // Dış elmas (eğik kare)
    final diamond = Path()
      ..moveTo(c.dx, c.dy - r * 0.85)
      ..lineTo(c.dx + r * 0.85, c.dy)
      ..lineTo(c.dx, c.dy + r * 0.85)
      ..lineTo(c.dx - r * 0.85, c.dy)
      ..close();
    canvas.drawPath(diamond, p);

    // İç çapraz çizgiler
    final inner = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawLine(
      Offset(c.dx, c.dy - r * 0.4),
      Offset(c.dx, c.dy + r * 0.4),
      inner,
    );
    canvas.drawLine(
      Offset(c.dx - r * 0.4, c.dy),
      Offset(c.dx + r * 0.4, c.dy),
      inner,
    );

    // Merkez parlak nokta
    canvas.drawCircle(
      c,
      r * 0.1,
      Paint()
        ..color = color.withOpacity(0.8)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _AnalyticsDiamondPainter old) => false;
}

// ── Radar Chart (Örümcek Ağı) Painter ──
class _RadarChartPainter extends CustomPainter {
  final List<String> labels;
  final List<double> values;
  final Color color;

  _RadarChartPainter({
    required this.labels,
    required this.values,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 46;
    final n = labels.length;
    final angleStep = 2 * math.pi / n;
    final startAngle = -math.pi / 2;

    // ── Web grid çizgileri (4 katman: %25, %50, %75, %100) ──
    const levelLabels = ['25', '50', '75', ''];
    for (var level = 1; level <= 4; level++) {
      final lr = r * level / 4;
      final gridPath = Path();
      for (var i = 0; i <= n; i++) {
        final a = startAngle + (i % n) * angleStep;
        final x = cx + math.cos(a) * lr;
        final y = cy + math.sin(a) * lr;
        if (i == 0)
          gridPath.moveTo(x, y);
        else
          gridPath.lineTo(x, y);
      }
      canvas.drawPath(
        gridPath,
        Paint()
          ..color = color.withOpacity(level == 4 ? 0.18 : 0.06)
          ..style = PaintingStyle.stroke
          ..strokeWidth = level == 4 ? 1.0 : 0.6,
      );

      // Seviye etiketi (sağ eksende)
      if (level < 4) {
        final ly = cy - lr;
        final tp = TextPainter(
          text: TextSpan(
            text: '${levelLabels[level - 1]}%',
            style: TextStyle(color: color.withOpacity(0.25), fontSize: 8),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(cx + 4, ly - tp.height / 2));
      }
    }

    // ── Eksen çizgileri ──
    for (var i = 0; i < n; i++) {
      final a = startAngle + i * angleStep;
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + math.cos(a) * r, cy + math.sin(a) * r),
        Paint()
          ..color = color.withOpacity(0.1)
          ..strokeWidth = 0.6,
      );
    }

    // ── Veri poligonu ──
    final dataPath = Path();
    final dataPoints = <Offset>[];
    for (var i = 0; i < n; i++) {
      final a = startAngle + i * angleStep;
      final v = i < values.length ? values[i] : 0.5;
      final x = cx + math.cos(a) * r * v;
      final y = cy + math.sin(a) * r * v;
      dataPoints.add(Offset(x, y));
      if (i == 0)
        dataPath.moveTo(x, y);
      else
        dataPath.lineTo(x, y);
    }
    dataPath.close();

    // Dolgu
    canvas.drawPath(
      dataPath,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          colors: [color.withOpacity(0.18), color.withOpacity(0.04)],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r))
        ..style = PaintingStyle.fill,
    );

    // Kenar çizgisi
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = color.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeJoin = StrokeJoin.round,
    );

    // Glow
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = color.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // ── Köşe noktaları + Yüzdelik göstergeleri ──
    for (var i = 0; i < dataPoints.length; i++) {
      final p = dataPoints[i];
      final v = i < values.length ? values[i] : 0.5;
      final pct = (v * 100).round();

      // Nokta rengi: Yüksek → parlak altın, düşük → soluk amber
      final brightness = v > 0.75 ? 0.9 : (v > 0.6 ? 0.6 : 0.4);
      canvas.drawCircle(
        p,
        5,
        Paint()..color = color.withOpacity(brightness * 0.3),
      );
      canvas.drawCircle(p, 3, Paint()..color = color.withOpacity(brightness));
      canvas.drawCircle(p, 1.5, Paint()..color = Colors.white.withOpacity(0.9));

      // Yüzdelik etiketi (noktanın yanında)
      final a = startAngle + i * angleStep;
      final pctX = p.dx + math.cos(a) * 14;
      final pctY = p.dy + math.sin(a) * 14;
      final pctTp = TextPainter(
        text: TextSpan(
          text: '$pct%',
          style: TextStyle(
            color: v > 0.75 ? color.withOpacity(0.9) : color.withOpacity(0.5),
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      pctTp.paint(
        canvas,
        Offset(pctX - pctTp.width / 2, pctY - pctTp.height / 2),
      );
    }

    // ── Etiketler (trait isimleri) ──
    const labelGap = 18.0; // Chart kenarından sabit mesafe
    for (var i = 0; i < n; i++) {
      final a = startAngle + i * angleStep;
      final v = i < values.length ? values[i] : 0.5;
      final edgeX = cx + math.cos(a) * r;
      final edgeY = cy + math.sin(a) * r;
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: v > 0.75 ? color.withOpacity(0.85) : color.withOpacity(0.5),
            fontSize: 10,
            fontWeight: v > 0.75 ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      // Açıya göre anchor offset — etiketin en yakın kenarı chart'a eşit mesafede
      final cosA = math.cos(a);
      final sinA = math.sin(a);
      double dx = edgeX + cosA * labelGap;
      double dy = edgeY + sinA * labelGap;

      // Sağ taraftakiler: sol kenardan hizala
      if (cosA > 0.3) {
        dx = edgeX + labelGap;
        dy -= tp.height / 2;
      }
      // Sol taraftakiler: sağ kenardan hizala
      else if (cosA < -0.3) {
        dx = edgeX - labelGap - tp.width;
        dy -= tp.height / 2;
      }
      // Üst/alt: merkezden hizala
      else {
        dx -= tp.width / 2;
        if (sinA < 0)
          dy = edgeY - labelGap - tp.height;
        else
          dy = edgeY + labelGap;
      }

      tp.paint(canvas, Offset(dx, dy));
    }

    // ── Merkez nokta ──
    canvas.drawCircle(
      Offset(cx, cy),
      2,
      Paint()..color = color.withOpacity(0.15),
    );
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter old) => false;
}

// ═══════════════════════════════════════════
// KENDİNİ KEŞFET — DETAY SAYFASI (Zigzag Kart Tasarım)
// ═══════════════════════════════════════════
class _ZodiacDetailPage extends StatefulWidget {
  final Map<String, dynamic> sign;
  final Color gold;
  const _ZodiacDetailPage({required this.sign, required this.gold});

  @override
  State<_ZodiacDetailPage> createState() => _ZodiacDetailPageState();
}

class _ZodiacDetailPageState extends State<_ZodiacDetailPage> {
  Color get gold => widget.gold;
  static const _warmGold = Color(0xFFFFD060);
  static const _coolBlue = Color(0xFF8AAFC8);

  late List<String> shuffledStrengths;
  late List<String> shuffledWeaknesses;

  @override
  void initState() {
    super.initState();
    // Liste her açılışta karıştırılıyor (kullanıcının sıkılmasını ve aynı duty/challenge listesini görmesini engeller)
    shuffledStrengths = (List<String>.from(
      widget.sign['strengths'] as List<dynamic>,
    )..shuffle()).take(3).toList();
    shuffledWeaknesses = (List<String>.from(
      widget.sign['weaknesses'] as List<dynamic>,
    )..shuffle()).take(3).toList();
  }

  // Trait için yüzde hesapla
  int _getPct(String trait, bool isStrength) {
    // Biraz da rastgeleleşmesini sağlayan gün değişkeni ekleyelim ki skorlar da değişsin
    final dayRandom = DateTime.now().day;
    final h = (trait.hashCode.abs() ^ (trait.length * 3571) ^ dayRandom) % 100;
    if (isStrength) return 80 + (h % 16);
    return 40 + (h % 26);
  }

  @override
  Widget build(BuildContext context) {
    final sign = widget.sign;
    final strengths = shuffledStrengths;
    final weaknesses = shuffledWeaknesses;
    final nameEn = sign['nameEn'] as String;

    const usageHints = <String, String>{
      'Doğal liderlik':
          'Takım kuracak projelerde öne geç ve yönlendirici rol üstlen.',
      'Cesaret ve atılganlık':
          'Risk içeren kararlarda diğerlerinin çekineceği adımları at.',
      'Girişimci ruh': 'Yeni iş fikirleri geliştir ve öncü projeler başlat.',
      'Sarsılmaz irade':
          'Uzun vadeli hedefler koyarak kararlılığını avantaja çevir.',
      'Maddi güvenlik': 'Finansal stratejilerle güvenli bir gelecek inşa et.',
      'Sanatsal hassasiyet':
          'Estetik alanlarında kendini ifade et ve fark yarat.',
      'Hızlı öğrenme': 'Yeni alanları hızla öğrenerek rekabet avantajı kazan.',
      'İletişim becerisi': 'Fikirlerini etkili ifade ederek çevreni genişlet.',
      'Uyum yeteneği': 'Farklı ortamlara hızla adapte olarak avantaj yakala.',
      'Derin empati': 'İlişkilerde derinlik kurarak güçlü bağlar oluştur.',
      'Aile bağları': 'Sevdiklerinle güçlü bağlar kurarak destek ağı oluştur.',
      'Güçlü sezgiler':
          'Sezgilerini dinleyerek doğru zamanda doğru kararlar ver.',
      'Doğal karizma':
          'Etrafındakilere ilham vererek liderlik pozisyonları üstlen.',
      'Yaratıcı güç':
          'Sanatsal projeler ve tasarım alanlarında kendini ifade et.',
      'Cömertlik': 'Paylaşımcı yaklaşımınla sosyal çevreni genişlet.',
      'Analitik zekâ': 'Verileri analiz ederek stratejik kararlar al.',
      'Düzen ve organizasyon':
          'Sistematik yaklaşımınla karmaşık süreçleri basitleştir.',
      'Hizmet ruhu': 'Topluma değer katacak projelerde gönüllü rol al.',
      'Adalet duygusu':
          'Etik değerleri ön plana koyarak güvenilir bir figür ol.',
      'Estetik anlayış':
          'Görsel ve tasarım projelerinde fark yaratan işler çıkar.',
      'Diplomasi': 'Farklı tarafları bir araya getirerek köprüler kur.',
      'Derin sezgi':
          'Görünmeyen dinamikleri sezgilerinle fark et ve yönlendir.',
      'Yeniden doğuş gücü': 'Kriz anlarını dönüştürerek fırsata çevir.',
      'Sadakat': 'Uzun vadeli ilişkiler kurarak güçlü bir destek ağı oluştur.',
      'Vizyon genişliği':
          'Büyük fikirler ve uzun vadeli planlarda öne geçersin.',
      'Macera ruhu':
          'Keşfetme tutkunu girişimcilik ve seyahat alanlarında değerlendir.',
      'Felsefi derinlik': 'Derin düşünme yeteneğinle başkalarına ilham ver.',
      'İrade gücü': 'Zorlu hedeflere ulaşmada irade gücün en büyük avantajın.',
      'Uzun vadeli planlama': 'Geleceğe yönelik stratejik planlarınla öne geç.',
      'Sorumluluk bilinci':
          'Güvenilir ve tutarlı duruşunla liderlik konumu kazan.',
      'Özgün düşünce': 'Alışılmışın dışında çözümler üreterek fark yarat.',
      'İnsancıl bakış': 'Empati gücünü sosyal etki alanlarında kullan.',
      'Devrimci ruh': 'Yenilikçi fikirlerin ile çevrendeki değişimi başlat.',
      'Sınırsız empati':
          'Derin empatin ile insanların yaşamlarına dokunmaya devam et.',
      'Sanatsal yetenek':
          'Yaratıcılığını müzik, sinema veya görsel sanatlarda keşfet.',
      'Ruhani derinlik':
          'İçsel yolculuğunla başkalarına rehberlik edebilirsin.',
      'Kararlılık':
          'Uzun vadeli hedefler koyarak kararlılığını avantaja çevir.',
      'Güvenilirlik': 'Güven gerektiren görevlerde referans noktası ol.',
      'Sabır': 'Uzun süreçli projelerde stratejik sabrınla fark yarat.',
      'Çift yönlü bakış':
          'Farklı bakış açılarını harmanlayarak arabuluculuk yap.',
      'İletişim dehası': 'Fikirlerini etkili ifade ederek çevreni genişlet.',
      'Duygusal zekâ': 'İlişkilerde derinlik kurarak güçlü bağlar oluştur.',
      'Koruyucu doğa': 'Çevrendekiler için güvenli bir ortam yarat.',
      'Sezgisel güç':
          'Sezgilerini dinleyerek doğru zamanda doğru kararlar ver.',
      'Yaratıcı enerji':
          'Sanatsal projeler ve tasarım alanlarında kendini ifade et.',
      'Diplomatik yetenek':
          'Farklı tarafları bir araya getirerek köprüler kur.',
    };

    const growthTips = <String, String>{
      'Sabırsızlık': 'Süreç takibi alışkanlığı kazanarak sabrını güçlendir.',
      'Düşünmeden hareket': 'Karar vermeden önce 3 dakika bekle kuralı uygula.',
      'Hırslı olma': 'Küçük başarıları kutlayarak yolculuğun tadını çıkar.',
      'İnatçılık': 'Farklı bakış açılarını dinleyerek esnekliğini geliştir.',
      'Değişime direnç':
          'Haftalık bir yenilik deneyerek adaptasyon kaslarını çalıştır.',
      'Aşırı sahiplenme': 'Kontrolü bırakma pratikleri yaparak güven geliştir.',
      'Kararsızlık':
          'Karar matriksi kullanarak sistemli seçim yapma becerisini kazan.',
      'Yüzeysellik': 'Bir konuda 30 gün derinleşme challenge başlat.',
      'Huzursuzluk':
          'Günlük 10 dakika mindfulness pratiği ile sakinliği keşfet.',
      'Aşırı hassasiyet': 'Duygusal sınırlarını belirleyerek enerjini koru.',
      'Aşırı korumacılık':
          'Güven inşa egzersizleri ile kontrol ihtiyacını azalt.',
      'Geçmişe takılma': 'Günlük şükran listesi tutarak şimdiki ana odaklan.',
      'Ego': 'Başkalarının başarılarını kutlayarak alçakgönüllülüğü geliştir.',
      'Diktatörlük':
          'Aktif dinleme tekniklerini öğrenerek iletişimini güçlendir.',
      'Beğenilme ihtiyacı':
          'İçsel onay mekanizmalarını geliştirerek özgüvenini artır.',
      'Aşırı eleştirellik':
          'Mükemmeliyetten vazgeçip yeterince iyi kavramını benimse.',
      'Mükemmeliyetçilik': '80/20 kuralını uygulayarak verimliliğini artır.',
      'Endişe eğilimi': 'Endişe günlüğü tutarak düşüncelerini somutlaştır.',
      'Kararsız doğa': 'Önceliklendirme matrisi kullanarak net kararlar al.',
      'Başkalarına bağımlılık':
          'Tek başına aktiviteler planlayarak öz yeterliliğini keşfet.',
      'Çatışmadan kaçma':
          'Assertif iletişim teknikleri öğrenerek sesini duyur.',
      'Çatışmadan kaçınma':
          'Assertif iletişim teknikleri öğrenerek sesini duyur.',
      'Kıskançlık': 'Bolluk zihniyetini benimseyerek güven inşa et.',
      'İntikamcılık': 'Affetme pratiği yaparak iç huzurunu bul.',
      'Aşırı kontrol': 'Akışa bırakma egzersizleri ile esnekliğini geliştir.',
      'Sorumsuzluk': 'Küçük taahhütlerle başlayarak güvenilirliğini inşa et.',
      'Aşırı dürüstlük': 'Empati filtresinden geçirerek nazikçe doğruyu söyle.',
      'Taahhüt korkusu': 'Kısa süreli bağlanma adımlarıyla güven oluştur.',
      'Aşırı ciddiyet':
          'Haftalık eğlence rutini oluşturarak hayatın tadını çıkar.',
      'Duygularını bastırma': 'Günlük duygu günlüğü tutarak iç sesini duyur.',
      'İş koliklik': 'İş-yaşam dengesi planı yaparak kaliteli zaman ayır.',
      'Duygusal mesafe': 'Haftalık derin sohbet pratiği ile yakınlık kur.',
      'Asi tutum': 'Yapıcı eleştiri teknikleri öğrenerek enerjini yönlendir.',
      'Gerçeklikten kaçış':
          'Somut ve ölçülebilir hedefler belirleyerek odaklan.',
      'Sınır koyamama': 'Hayır deme pratiği yaparak sınırlarını koru.',
      'Çabuk sıkılma':
          'Bir projeye sabırla bağlan, bitirmekten haz duymayı öğren.',
      'Aşırı duygusallık': 'Duygusal sınırlarını belirleyerek enerjini koru.',
      'Kabuğuna çekilme': 'Güven inşa ederek sosyal bağlarını güçlendir.',
      'Gurur': 'Alçakgönüllülüğü keşfet, başkalarının başarılarını kutla.',
      'Dikkat beklentisi':
          'İçsel onay mekanizmalarını geliştirerek özgüvenini artır.',
      'Otoriter tavır':
          'Aktif dinleme tekniklerini öğrenerek iletişimini güçlendir.',
    };

    return Scaffold(
      backgroundColor: const Color(0xFF0F1210),
      body: Stack(
        children: [
          // Arka plan gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.2,
                  colors: [gold.withOpacity(0.06), Colors.transparent],
                ),
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),

                        // ── Geri butonu ──
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: gold.withOpacity(0.06),
                                  border: Border.all(
                                    color: gold.withOpacity(0.12),
                                  ),
                                ),
                                child: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 16,
                                  color: gold.withOpacity(0.6),
                                ),
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: 28,
                              height: 28,
                              child: CustomPaint(
                                painter: _CosmicStarPainter(color: gold),
                              ),
                            ),
                            const Spacer(),
                            const SizedBox(width: 36),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // ── Başlık ──
                        Center(
                          child: Column(
                            children: [
                              ShaderMask(
                                shaderCallback: (b) => const LinearGradient(
                                  colors: [
                                    Color(0xFFE8D5B7),
                                    Color(0xFFFFE8A1),
                                    Color(0xFFFFD060),
                                  ],
                                ).createShader(b),
                                child: Text(
                                  nameEn.toUpperCase(),
                                  style: GoogleFonts.cinzel(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Kendini Keşfet',
                                style: GoogleFonts.cinzel(
                                  color: gold.withOpacity(0.35),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 3,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ── Dekoratif elmas çizgi ──
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 0.3,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      gold.withOpacity(0.2),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: SizedBox(
                                width: 14,
                                height: 14,
                                child: CustomPaint(
                                  painter: _AnalyticsDiamondPainter(
                                    color: gold,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 0.3,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      gold.withOpacity(0.2),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // ═══════════════════════════
                        // | SÜPER GÜÇLERİN
                        // ═══════════════════════════
                        _sectionHeader('SÜPER GÜÇLERİN', _warmGold),
                        const SizedBox(height: 20),

                        // Zigzag layout — güçlü yanlar
                        ...List.generate(strengths.length, (i) {
                          final trait = strengths[i];
                          final pct = _getPct(trait, true);
                          final hint =
                              usageHints[trait] ?? 'Potansiyelini keşfet.';
                          return _zigzagItem(
                            trait,
                            pct,
                            hint,
                            _warmGold,
                            i,
                            strengths.length,
                          );
                        }),

                        // ── Göz ayırıcı ──
                        const SizedBox(
                          height: 16,
                        ), // Üstteki öğenin 24px kendi boşluğu var, toplam 40px
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 0.8,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withOpacity(0.3),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CustomPaint(
                                  painter: _CosmicEyePainter(color: gold),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 0.8,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.3),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 40,
                        ), // Alttaki başlığa olan mesafe de tam 40px
                        // ═══════════════════════════
                        // | BÜYÜME ALANLARIN
                        // ═══════════════════════════
                        _sectionHeader('BÜYÜME ALANLARIN', _coolBlue),
                        const SizedBox(height: 20),

                        // Zigzag layout — zayıf yanlar
                        ...List.generate(weaknesses.length, (i) {
                          final trait = weaknesses[i];
                          final pct = _getPct(trait, false);
                          final hint =
                              growthTips[trait] ?? 'Farkındalık geliştir.';
                          return _zigzagItem(
                            trait,
                            pct,
                            hint,
                            _coolBlue,
                            i,
                            weaknesses.length,
                          );
                        }),

                        const SizedBox(height: 64),

                        // ═══════════════════════════
                        // | SANA MEYDAN OKUYORUM (GÖREVLER)
                        // ═══════════════════════════
                        _sectionHeader('SANA MEYDAN OKUYORUM !', _warmGold),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 11),
                          child: Text(
                            'Kişisel farkındalığını artırmak için dönüşüm odaklı bir serüven ✨',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildCosmicQuests(weaknesses),

                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Bölüm başlığı ──
  Widget _sectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withOpacity(0.9), color.withOpacity(0.2)],
            ),
          ),
        ),
        const SizedBox(width: 12),
        ShaderMask(
          shaderCallback: (b) => LinearGradient(
            colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
          ).createShader(b),
          child: Text(
            title,
            style: GoogleFonts.cinzel(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
            ),
          ),
        ),
      ],
    );
  }

  // ── Zigzag Progress Bar Öğesi ──
  // ── Orijinal Kopuk (Ayrık) Zigzag Tasarımı (Kullanıcının İstediği) ──
  Widget _zigzagItem(
    String trait,
    int pct,
    String hint,
    Color color,
    int index,
    int totalCount,
  ) {
    final bool isRight = index % 2 == 1;

    // Yüzde Metni (Birleşik)
    final pctWidget = Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$pct',
          style: GoogleFonts.cinzel(
            color: color,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            height: 1.0,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '%',
          style: GoogleFonts.cinzel(
            color: color.withOpacity(0.5),
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.0,
          ),
        ),
      ],
    );

    // İsim Metni için sabit bir widget yapısı kullanmayıp TextAlign'ı duruma göre ayarlayacağız.

    // Progress Bar (Track & Fill)
    final barWidget = Stack(
      alignment: isRight ? Alignment.centerLeft : Alignment.centerRight,
      children: [
        // Track
        Container(
          height: 12, // Daha kalın
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        // Dolu Kısım
        FractionallySizedBox(
          widthFactor: pct / 100.0,
          child: Container(
            height: 12, // Daha kalın
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: LinearGradient(
                // Bar, merkezden (isRight için sol, !isRight için sağ) dışa doğru (uçlara) uzar.
                begin: isRight ? Alignment.centerLeft : Alignment.centerRight,
                end: isRight ? Alignment.centerRight : Alignment.centerLeft,
                colors: [
                  color, // İç kısımdaki yoğun renk
                  color.withOpacity(0.8), // Ortalar
                  Color.lerp(
                    color,
                    Colors.white,
                    0.6,
                  )!, // Uçlarda estetik beyazımsı parlama ve açılma
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.4), blurRadius: 8),
              ],
            ),
          ),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── SOL KISIM ──
          Expanded(
            child: !isRight
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        height:
                            46, // Sabit yükseklik, iki satıra taşan özellik isimleri (örn: "Düzen ve organizasyon") için genişletildi
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                trait,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            pctWidget,
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      barWidget,
                      const SizedBox(height: 10),
                      Text(
                        hint,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 11,
                          fontStyle: FontStyle.normal,
                          height: 1.4,
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
          ),

          // ── MERKEZ İŞARETÇİ ──
          SizedBox(
            width: 24,
            child: CustomPaint(painter: _TimelineMarkerPainter(color: color)),
          ),

          // ── SAĞ KISIM ──
          Expanded(
            child: isRight
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height:
                            46, // Sol taraf ile aynı yükseklik (çok satırlılar için)
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            pctWidget,
                            Expanded(
                              child: Text(
                                trait,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      barWidget,
                      const SizedBox(height: 10),
                      Text(
                        hint,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 11,
                          fontStyle: FontStyle.normal,
                          height: 1.4,
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  // ── Kozmik Görev (Mini Challenge) ──
  Widget _buildCosmicQuests(List<dynamic> weaknesses) {
    if (weaknesses.isEmpty) return const SizedBox();
    final topWeakness = weaknesses.first.toString();
    final pct = _getPct(topWeakness, false);
    return _CosmicChallengeCard(
      key: ValueKey(topWeakness),
      topWeakness: topWeakness,
      baseColor: _warmGold,
      initialPct: pct,
      onJourneyCompleted: () {
        setState(() {
          final first = shuffledWeaknesses.removeAt(0);
          shuffledWeaknesses.add(first);
        });
      },
    );
  }
}

class _CosmicChallengeCard extends StatefulWidget {
  final String topWeakness;
  final Color baseColor;
  final int initialPct;
  final VoidCallback? onJourneyCompleted;

  const _CosmicChallengeCard({
    super.key,
    required this.topWeakness,
    required this.baseColor,
    required this.initialPct,
    this.onJourneyCompleted,
  });

  @override
  State<_CosmicChallengeCard> createState() => _CosmicChallengeCardState();
}

class _CosmicChallengeCardState extends State<_CosmicChallengeCard> {
  int currentDay = 1;
  bool isChallengeFinished = false;
  List<Map<String, dynamic>> days = [];
  int totalDays = 0;
  String currentFocusText = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initChallenges();
  }

  Future<void> _initChallenges() async {
    final w = widget.topWeakness.toLowerCase();

    List<Map<String, dynamic>> pool = [];

    // Zayıflık türüne göre dinamik meydan okumalar ve değişen süreler (3 ile 7 gün arası)
    if (w.contains('sabır') ||
        w.contains('acele') ||
        w.contains('öfke') ||
        w.contains('bencil') ||
        w.contains('düşünmeden') ||
        w.contains('hırs')) {
      currentFocusText =
          'Acelecilik ve tahammülsüzlük dürtülerini kontrol altına almak.';
      pool = [
        {
          "task":
              "Bir konuşmada karşı taraf bitene kadar sözünü kesmeden, sadece dinle.",
          "reward": 5,
        },
        {
          "task":
              "Bugün alacağın bir kararı en az 10 dakika durup düşünerek al.",
          "reward": 5,
        },
        {
          "task":
              "Hızlı yürüdüğünü veya acele iş yaptığını fark ettiğinde dur ve 3 derin nefes al.",
          "reward": 10,
        },
        {
          "task":
              "Sabrını zorlayan birine karşı anlayışla ve ekstra nezaketle yaklaş.",
          "reward": 15,
        },
        {
          "task":
              "Beklemen gereken bir sırada (kasa, trafik) telefonuna bakmadan etrafını gözlemle.",
          "reward": 10,
        },
        {
          "task":
              "Bugün duyduğun ilk olumsuz şeye anında tepki vermek yerine 1 saat bekle.",
          "reward": 15,
        },
        {
          "task":
              "Bir işi normalden iki kat daha yavaş ve hissederek yapmayı dene.",
          "reward": 10,
        },
        {
          "task":
              "Kendine zaman sınırı koymadan, sadece o ana odaklanarak bir yemek ye.",
          "reward": 10,
        },
        {
          "task":
              "Bugün kimseyi hızlandırmaya çalışma, herkesin kendi ritmine saygı duy.",
          "reward": 20,
        },
        {
          "task":
              "Eğer bir şey beklediğin gibi gitmezse, 'zamanlamanın bir bildiği var' de ve rahatla.",
          "reward": 15,
        },
        {
          "task":
              "Haklı olduğun bir konuda tartışmayı kazanmak yerine, anı kurtarmayı seç.",
          "reward": 15,
        },
      ];
    } else if (w.contains('lider') ||
        w.contains('pasif') ||
        w.contains('çekingen') ||
        w.contains('gurur') ||
        w.contains('dikkat') ||
        w.contains('otorite') ||
        w.contains('kibir') ||
        w.contains('ego')) {
      currentFocusText =
          'Sağlam bir özgüven ile kibri ayırmak ve şefkatli liderliği güçlendirmek.';
      pool = [
        {
          "task":
              "Sorumluluk almaktan kaçındığın bir konuda bugün öne çıkarak inisiyatif al.",
          "reward": 10,
        },
        {
          "task":
              "Çevrenizdekileri motive edecek küçük ama etkili bir övgüde bulun.",
          "reward": 15,
        },
        {
          "task":
              "Dışarıdan bir onay veya övgü gelmese dahi başardığın bir şeyle içsel gurur duy.",
          "reward": 15,
        },
        {
          "task":
              "Bugün girdiğin bir tartışmada karşındakine hak verdiğini yüksek sesle söyle.",
          "reward": 20,
        },
        {
          "task":
              "Kendinden emin bir beden dili (dik duruş, göz teması) pratiği yap.",
          "reward": 5,
        },
        {
          "task":
              "Senin için çok basit olan bir işi bugün sessizce, kimseye anlatmadan yap.",
          "reward": 15,
        },
        {
          "task":
              "Kendi konfor alanının dışına çıkacak bir sorumluluğa 'Ben yaparım' de.",
          "reward": 15,
        },
        {
          "task":
              "Pasif kalan bir arkadaşına cesaret vererek onun fikrini öne çıkarmasını sağla.",
          "reward": 10,
        },
        {
          "task":
              "Hatırladığın uzak bir hatanda kendi egonu tespit et ve zihninde bundan özgürleş.",
          "reward": 20,
        },
      ];
    } else if (w.contains('iletişim') ||
        w.contains('sessiz') ||
        w.contains('içe') ||
        w.contains('gerçek') ||
        w.contains('kurban') ||
        w.contains('sınır')) {
      currentFocusText =
          'Kendini cesurca ifade etmek ve sağlıklı sınırlar çizerek kendi gerçekliğini kurmak.';
      pool = [
        {
          "task":
              "İçinde tuttuğun güzel bir hissi sevdiğin birine açıkça mesaj at ve belirt.",
          "reward": 10,
        },
        {
          "task":
              "Seni rahatsız eden bir duruma karşı çok net ve açıklamasız bir şekilde sınır koy.",
          "reward": 20,
        },
        {
          "task":
              "Bugün eleştiriyi savunmaya geçmeden, sadece ne demek istediklerini dinleyerek karşıla.",
          "reward": 15,
        },
        {
          "task":
              "Hayal kurmak veya kaçmak yerine bugün bitmesi gereken çok somut bir görevi tamamla.",
          "reward": 15,
        },
        {
          "task":
              "Asansörde veya markette tanımadığın birine küçük bir iltifat et.",
          "reward": 20,
        },
        {
          "task":
              "Kendinle ilgili eskiden sakladığın masum bir detayı güvendiğin biriyle paylaş.",
          "reward": 15,
        },
        {
          "task":
              "Birisi sınırını aştığında şakaya vurmadan doğrudan rahatsızlığını dile getir.",
          "reward": 20,
        },
        {
          "task":
              "Bugün 'Nasılsın?' diyen birine sadece 'İyiyim' yerine daha detaylı ve dürüst bir cevap ver.",
          "reward": 15,
        },
        {
          "task":
              "Başkalarının dertlerini dinlemek için harcadığın 1 saati bugün kendi ihtiyaçlarına ayır.",
          "reward": 15,
        },
      ];
    } else if (w.contains('karar') ||
        w.contains('yüzey') ||
        w.contains('sıkıl') ||
        w.contains('tutar') ||
        w.contains('gevşek') ||
        w.contains('odak') ||
        w.contains('dağınık')) {
      currentFocusText =
          'Zihnindeki bulanıklığı dağıtıp şimdiki ana çapalanmak ve bir konuda derinleşmek.';
      pool = [
        {
          "task":
              "Bugün hiçbir bildirim sesi olmadan, 30 dakika dış dünyadan soyutlanarak çalış.",
          "reward": 15,
        },
        {
          "task":
              "Yarım bıraktığın ve sürekli aklını kurcalayan çok basit bir okumayı/videoyu bugün kesin bitir.",
          "reward": 10,
        },
        {
          "task":
              "Bir işi yaparken araya giren başka bir görevi, ilkini bitirmeden kesinlikle reddet.",
          "reward": 15,
        },
        {
          "task":
              "Meditatif bir sessizlikte, etrafındaki ortamın detaylarını en az 2 dakika incele.",
          "reward": 10,
        },
        {
          "task":
              "Aynı anda iki iş yaparken kendini yakala ve hemen birini bırak.",
          "reward": 15,
        },
        {
          "task":
              "Masanda veya çalışma alanında duran gereksiz her şeyi kaldırıp minimalist bir alan yarat.",
          "reward": 10,
        },
        {
          "task":
              "Karar veremediğin küçük bir konuda mantık yerine doğrudan ilk hissine güvenerek seç.",
          "reward": 15,
        },
        {
          "task":
              "Telefonun ana ekranından dikkatini dağıtan üç uygulamayı 1 günlüğüne kaldır.",
          "reward": 20,
        },
        {
          "task":
              "Bugün yürüyüş yaparken kulaklık takmak yerine sadece adımlarına ve an'a odaklan.",
          "reward": 20,
        },
      ];
    } else if (w.contains('kıskanç') ||
        w.contains('intikam') ||
        w.contains('kontrol') ||
        w.contains('şüphe') ||
        w.contains('gizem') ||
        w.contains('sahip')) {
      currentFocusText =
          'Korkularından özgürleşerek evrenin akışına teslim olmak ve güven alanını genişletmek.';
      pool = [
        {
          "task":
              "Kontrol edemediğin bir durum çıktığında sadece 'olması gereken buymuş' diyerek es geç.",
          "reward": 10,
        },
        {
          "task":
              "Kaygılandığın birini serbest bırak ve ona olan güvenini açıkça dile getir.",
          "reward": 10,
        },
        {
          "task":
              "Sana yanlış yapan birine duyduğun gizli öfkeyi bugün affetme niyetiyle serbest bırak.",
          "reward": 20,
        },
        {
          "task":
              "Yapılacak küçük bir görevin sorumluluğunu tamamen bir başkasına devret ve sonuca karışma.",
          "reward": 20,
        },
        {
          "task":
              "Bugün sana söylenen güzel bir sözün altında başka bir niyet aramadan safça kabul et.",
          "reward": 15,
        },
        {
          "task":
              "Her şeyi planlama isteğini bugün ufak bir spontane eylemle tamamen boz.",
          "reward": 20,
        },
        {
          "task":
              "Birinin senin yolun dışında farklı bir yolla bir işi çözmesine izin ver.",
          "reward": 10,
        },
        {
          "task":
              "Güçlü bir rekabet veya kıskançlık hissettiğinde içinden o kişiye bolluk ve şans dile.",
          "reward": 20,
        },
        {
          "task":
              "Gizli tuttuğun ve seni yoran küçük bir sırrı/düşünceyi en inandığın dostunla paylaş.",
          "reward": 15,
        },
      ];
    } else if (w.contains('çatışma') ||
        w.contains('bağım') ||
        w.contains('hayır') ||
        w.contains('ödün')) {
      currentFocusText =
          'Dış onaya olan ihtiyacını yıkıp kendi doğrularını seçmek ve uyumu kendi içinde bulmak.';
      pool = [
        {
          "task":
              "Önüne çıkan basit bir seçimi (yemek, mekan vs.) kimseden onay almadan ilk hissinle seç.",
          "reward": 10,
        },
        {
          "task":
              "Kabul etmek istemediğin bir iyilik talebine açık, net ve nezaketli bir 'Hayır' de.",
          "reward": 15,
        },
        {
          "task":
              "Bugün kendinden ödün vermeni gerektiren her durumu bir adım geri çekilerek gözden geçir.",
          "reward": 15,
        },
        {
          "task":
              "Ortamı yumuşatmak için gülümsemek zorunda kaldığın bir anı fark et ve o sahte gülüşü bırak.",
          "reward": 15,
        },
        {
          "task":
              "Başkasının ruh halini düzeltme görevini bir kenara bırakıp kendi enerjine sahip çık.",
          "reward": 20,
        },
        {
          "task":
              "Bugün fikrin sorulduğunda 'Fark etmez' kelimesini lügatından çıkar ve net bir şey seç.",
          "reward": 15,
        },
        {
          "task":
              "Zamanını çalan birine veya bir bildirime karşı çok net, sağlıklı bir mesafe koy.",
          "reward": 20,
        },
        {
          "task":
              "Bugün sadece 'O istiyor diye' yaptığın bir fedakarlığı tespit et ve derhal sonlandır.",
          "reward": 15,
        },
        {
          "task":
              "Bir konuşmayı sırf ayıp olmasın diye uzatmak yerine nezaketle ve cesurca bitir.",
          "reward": 15,
        },
      ];
    } else if (w.contains('eleştiri') ||
        w.contains('mükemmel') ||
        w.contains('endişe') ||
        w.contains('evham') ||
        w.contains('detay') ||
        w.contains('soğuk')) {
      currentFocusText =
          'Kusurların içindeki güzelliği görmek, detaylardan sıyrılıp bütünü kucaklamak.';
      pool = [
        {
          "task":
              "Tam olarak içine sinmese bile bir işi, sırf %100 olmadı diye ertelemeden 'Tamamlandı' işaretle.",
          "reward": 10,
        },
        {
          "task":
              "Karşındakinin canını sıkan ufak bir hatasını bilerek gözardı et ve pozitifine odaklan.",
          "reward": 15,
        },
        {
          "task":
              "Kendi yaptığın veya yapamadığın bir şey için kendine şefkat göster ve bunu normal kabul et.",
          "reward": 20,
        },
        {
          "task":
              "Birisine eleştiri getirmeden önce tam 3 kez yutkun ve o eleştiriyi kendine sakla.",
          "reward": 10,
        },
        {
          "task":
              "Odanı, masanı veya evini bugün bilerek biraz dağınık (kusurlu) bırak ve buna tahammül et.",
          "reward": 15,
        },
        {
          "task":
              "Ortada hiçbir sebep yokken geleceğe dair kurduğun bir felaket senaryosunu zihninde anında iptal et.",
          "reward": 20,
        },
        {
          "task":
              "Dışarıdan ne kadar 'soğuk' veya 'mesafeli' görünürsen görün, bugün birine sıcak bir sarılma ver.",
          "reward": 15,
        },
        {
          "task":
              "Bugün bir şeyin 'mükemmel' olmasını beklemek yerine komik veya salaş bir yönünü kucakla.",
          "reward": 15,
        },
        {
          "task":
              "Aynaya bak ve fiziksel bir 'kusurunu' düzeltmeye çalışmadan, ona sevgiyle gülümse.",
          "reward": 20,
        },
      ];
    } else if (w.contains('sorumsuz') ||
        w.contains('sorumluluk') ||
        w.contains('dağınık') ||
        w.contains('ertelemek') ||
        w.contains('üşengeç')) {
      currentFocusText =
          'Kaçış mekanizmalarını durdurup kendi hayatının direksiyonuna geçmek.';
      pool = [
        {
          "task":
              "Sürekli arkaya attığın, seni zihnen yoran o tek küçük problemi şimdi, şu an, anında çöz.",
          "reward": 10,
        },
        {
          "task":
              "Daha sonra hallederim dediğin 3 parça çöpü veya bulaşığı hiçbir bahane üretmeden şimdi kaldır.",
          "reward": 5,
        },
        {
          "task":
              "Günlük programına uymak için alarm kur ve ilk çaldığında asla ertelemeden işe başla.",
          "reward": 10,
        },
        {
          "task":
              "Bugün başkalarının üstlendiği seninle ilgili ufak bir yükün sorumluluğunu bizzat sen al.",
          "reward": 15,
        },
        {
          "task":
              "Kendine ufak bir 'yapılması zorunlu kural' koy ve bütün gün ona sadık kaldığını kanıtla.",
          "reward": 20,
        },
        {
          "task":
              "Yarın sabah yapman gereken çok ufak bir hazırlığı (kıyafet vb.) daha bu geceden hazırla.",
          "reward": 15,
        },
      ];
    } else if (w.contains('dürüst') || w.contains('patavatsız')) {
      currentFocusText =
          'İçinden geçenleri daha nazik ve yapıcı bir filtreyle ifade etmeyi öğrenmek.';
      pool = [
        {
          "task":
              "Aklına gelen ancak gereksiz derecede 'fazla dürüst' (patavatsız) olabilecek o eleştiriyi bugün yut.",
          "reward": 15,
        },
        {
          "task":
              "Bugün bir şeyin eksikliğini söylemek yerine, iyi olan yönünü bulup onu vurgula.",
          "reward": 10,
        },
        {
          "task":
              "Karşındakine acımasızca dürüst olmadan önce onun duygularını incitip incitmeyeceğini 3 saniye düşün.",
          "reward": 15,
        },
        {
          "task":
              "Sivri dilli eleştiriler yerine bugün sadece 'Seni anlıyorum' demeyi pratik et.",
          "reward": 20,
        },
      ];
    } else if (w.contains('taahhüt') ||
        w.contains('bağlanma') ||
        w.contains('korku')) {
      currentFocusText =
          'Bağlılığın gücünü keşfetmek ve aidiyet duygusuna izin vermek.';
      pool = [
        {
          "task":
              "Bağlanmaktan veya söz vermekten kaçtığın minik bir konuda bugün kesin ve net bir söz ver.",
          "reward": 20,
        },
        {
          "task":
              "Kaçmak istediğin bir buluşmayı iptal etme, sonuna kadar orada kalarak anı yaşa.",
          "reward": 15,
        },
        {
          "task":
              "Kendine uzun vadeli küçük bir hedef koy ve bu hedefe ulaşacağına dair kendine güven ver.",
          "reward": 15,
        },
      ];
    } else if (w.contains('huzur')) {
      currentFocusText =
          'İçsel zihinsel karmaşayı durdurmak ve olduğun yerde yavaşlamak.';
      pool = [
        {
          "task":
              "Bugün hiçbir yere kaçmadan, tamamen sabit kalarak o anki 'sıkıcı' hissi deneyimle ve geçmesini izle.",
          "reward": 15,
        },
        {
          "task":
              "Sürekli bir şey yapma ihtiyacını fark et ve bilerek 5 dakika boş dur.",
          "reward": 20,
        },
        {
          "task":
              "Sabırsızca beklediğin bir şeyi düşünmeyi bırak ve şu an odandaki 3 sese odaklan.",
          "reward": 15,
        },
      ];
    } else if (w.contains('inat') ||
        w.contains('değişim') ||
        w.contains('madde') ||
        w.contains('ciddi') ||
        w.contains('bastır') ||
        w.contains('iş kolik') ||
        w.contains('iş') ||
        w.contains('katı') ||
        w.contains('karamsar')) {
      currentFocusText =
          'Direncini kırmak, bedeni harekete geçirmek ve anın içindeki hafifliği yakalamak.';
      pool = [
        {
          "task":
              "Bugün her zaman gittiğin yolu değiştir veya her zaman yediğin yemeğin dışında yeni bir şey dene.",
          "reward": 10,
        },
        {
          "task":
              "Haklı olsan bile inatlaşmayı bırakıp 'Belki de senin dediğin gibidir' diyerek geri çekil.",
          "reward": 15,
        },
        {
          "task":
              "Bugün maddiyata veya eşyalara olan bağlılığını esnet: Eskimiş veya kullanmadığın 2 eşyayı çöpe/ihtiyacı olana ayır.",
          "reward": 20,
        },
        {
          "task":
              "Ciddiyet maskeni bugün tamamen indir; izlediğin/dinlediğin komik bir şeye sesli bir şekilde kahkaha at.",
          "reward": 10,
        },
        {
          "task":
              "Bugün 'çalışmak' dışında sadece dinlenmek ve hiçbir şey yapmamak için kendine 1 saat ayır.",
          "reward": 20,
        },
        {
          "task":
              "Bastırdığın bir hissi (özlem, üzüntü, coşku) bugün yalnızken sesli bir şekilde dile getir.",
          "reward": 15,
        },
        {
          "task":
              "Kurallarına uymayan bir duruma karşı içinden 'Ne olacaksa olsun' de ve gülümseyip geç.",
          "reward": 15,
        },
        {
          "task":
              "Karamsar bir düşünce zihnini işgal ettiğinde derhal üç tane minnet duyduğun detay bul.",
          "reward": 10,
        },
      ];
    } else if (w.contains('duygu') ||
        w.contains('geçmiş') ||
        w.contains('kabuk') ||
        w.contains('alın') ||
        w.contains('hassas')) {
      currentFocusText =
          'Geçmişin yüklerinden sıyrılmak ve duygusal dalgalanmaların üstünde durabilmek.';
      pool = [
        {
          "task":
              "Geçmişte seni üzen bir olayı bugün sadece bir 'tecrübe hikayesi' gibi hiçbir duygu katmadan anımsa.",
          "reward": 15,
        },
        {
          "task":
              "Alınganlık yaptığın veya kırıldığın ilk cümlede, karşıdakinin niyetinin aslında nötr olduğunu varsay.",
          "reward": 20,
        },
        {
          "task":
              "Kendini geri çekmek (kabuğuna dönmek) istediğin o an, bilerek ortamda kal ve sürece diren.",
          "reward": 15,
        },
        {
          "task":
              "Bugün çok sevdiğin nostaljik bir müzik yerine ruh halini şimdiki ana çekecek yepyeni bir ritim dinle.",
          "reward": 10,
        },
        {
          "task":
              "Aşırı tepki verme ihtiyacı duyduğunda fiziksel olarak ortamdan çık, elini yüzünü yıka ve geri dön.",
          "reward": 10,
        },
        {
          "task":
              "Geçmişe dair zihnini yoran eski fotoğraflara/mesajlara bakma dürtünü yakala ve telefonu derhal bırak.",
          "reward": 20,
        },
        {
          "task":
              "Sana söylenen sıradan bir sözü şahsına bir saldırı olarak algıladığın an beynine 'Bu benimle ilgili değil' komutu ver.",
          "reward": 15,
        },
        {
          "task":
              "Bugün kendi kırılganlığını zırh gibi kuşanıp insanlardan saklanmak yerine, olduğun gibi görünmekten korkma.",
          "reward": 15,
        },
      ];
    } else if (w.contains('mesafe') ||
        w.contains('asi') ||
        w.contains('ukala') ||
        w.contains('rasyonalite')) {
      currentFocusText =
          'Aşırı mantığın duvarlarını yıkıp empatinin ve teslimiyetin gücüyle bağ kurmak.';
      pool = [
        {
          "task":
              "Her şeyi bir formüle veya mantığa oturtmaya çalıştığın an, dur ve sadece 'hissetmeye' odaklan.",
          "reward": 15,
        },
        {
          "task":
              "Duygusal bağ kurmaktan korktuğun için araya çektiğin o mesafeyi bugün birilerine sürpriz bir iltifatla kır.",
          "reward": 20,
        },
        {
          "task":
              "Asi ruhunu dinleyip kurallara karşı çıkmak istediğin anda, 'Sıradan olmanın' da bazen bir güç olduğunu kabul et.",
          "reward": 10,
        },
        {
          "task":
              "Herkesin katıldığı ama senin 'saçma' veya 'mantıksız' bulduğun bir sohbete eleştirmeden dahil ol.",
          "reward": 15,
        },
        {
          "task":
              "Bugün duygularını gösteren birine 'Bu rasyonel değil' demek yerine sadece 'Seni anlıyorum' de.",
          "reward": 20,
        },
        {
          "task":
              "Ukalalık yaparak daha fazlasını bildiğini iddia edeceğin bir ortamda bugün sadece 'Dinleyici' rolüne geç.",
          "reward": 15,
        },
        {
          "task":
              "Bağımsızlık ihtiyacının insanları senden uzaklaştırmasına izin verme; birine açıkça 'Yardımına ihtiyacım var' de.",
          "reward": 20,
        },
        {
          "task":
              "Odağını farklı olmaya değil, 'bütünün bir parçası olmaya' yönlendir; topluluğun enerjisine uyumlan.",
          "reward": 10,
        },
      ];
    } else {
      currentFocusText =
          'Kendi gölgelerinle cesaretle yüzleşmek ve seni kısıtlayan döngüleri farkındalıkla dönüştürmek.';
      pool = [
        {
          "task":
              "Bugün bu zaafını tetikleyen ilk olayı bir izleyici gibi dışarıdan gözlemle.",
          "reward": 10,
        },
        {
          "task":
              "Eski otomatik tepkini vermek yerine, tamamen denemediğin, absürt bile olsa yeni bir yaklaşım seç.",
          "reward": 15,
        },
        {
          "task":
              "Bugün kendine bir mola ver ve neleri aştığını kısa bir an düşünerek kendi sırtını sıvazla.",
          "reward": 20,
        },
        {
          "task":
              "Tepki vermek yerine önce dur, nefes al, ve sonra kendi iç rehberine danışarak konuş.",
          "reward": 15,
        },
        {
          "task":
              "Farkına vardığın bu zaafını, bugün şefkatle kabul et ve onunla savaşmak yerine barış.",
          "reward": 15,
        },
        {
          "task":
              "Negatif bir döngüye girdiğini fark ettiğin an, fiziksel olarak bulunduğun odayı veya mekanı değiştir.",
          "reward": 10,
        },
        {
          "task":
              "Dışarıdan bir onay veya rıza beklemeden kendi kendini motive edecek o tek bilge cümleyi bul.",
          "reward": 15,
        },
        {
          "task":
              "Bu durum tam şu an yeniden yaşanıyor olsaydı, film gibi geri sarıp en doğru tepkiyi zihninde uyarla.",
          "reward": 20,
        },
      ];
    }

    // Listeyi karıştır (shuffle)
    pool.shuffle();

    // Önceden tamamlanan görevleri filtrele
    final completedCache = await StorageService.getCompletedCosmicTasks();
    if (completedCache.isNotEmpty) {
      final filtered = pool
          .where((e) => !completedCache.contains(e['task']))
          .toList();
      // Eğer tamamen tüketirsek, havuzu boşaltmak yerine en az 3 taslaklık yedekle
      if (filtered.length >= 3) {
        pool = filtered;
      }
    }

    int dynamicTotal =
        3 +
        (DateTime.now().millisecond % 3); // 3, 4 veya 5 günlük görevler verir
    if (dynamicTotal > pool.length)
      dynamicTotal = pool.length; // Array'den büyük olmaması için güvenli limit

    if (mounted) {
      setState(() {
        days = pool.sublist(0, dynamicTotal);
        totalDays = days.length;
        _isLoading = false;
      });
    }
  }

  void _showCosmicCelebrationDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Kapat',
      barrierColor: Colors.black.withOpacity(0.8),
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.elasticOut,
              builder: (context, val, child) {
                return Transform.scale(scale: val, child: child);
              },
              child: Container(
                padding: const EdgeInsets.all(32),
                margin: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: const Color(0xFF141A23),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: widget.baseColor.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.baseColor.withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 2 * 3.14159),
                      duration: const Duration(seconds: 15),
                      builder: (context, rotation, child) {
                        return Transform.rotate(
                          angle: rotation,
                          child: _ProceduralBadge(
                            seedText: widget.topWeakness,
                            baseColor: widget.baseColor,
                            size: 140,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'YENİ ROZET\nKAZANILDI',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cinzel(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '"${widget.topWeakness} Ustası"',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cinzel(
                        color: widget.baseColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Evrenin ritmiyle tamamen uyumlandın.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: widget.baseColor.withOpacity(0.9),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: LinearGradient(
                            colors: [
                              widget.baseColor,
                              widget.baseColor.withOpacity(0.7),
                            ],
                          ),
                        ),
                        child: const Text(
                          'HARİKA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _statRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: CircularProgressIndicator(color: widget.baseColor),
        ),
      );
    }

    if (isChallengeFinished) {
      final int increase = 12; // Sabit gelişim oranı
      final int newScore = (widget.initialPct + increase > 100)
          ? 100
          : widget.initialPct + increase;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: widget.baseColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: widget.baseColor.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _ProceduralBadge(
              seedText: widget.topWeakness,
              baseColor: widget.baseColor,
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              'Serüven Tamamlandı',
              style: GoogleFonts.cinzel(
                color: widget.baseColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Etkileyici Yüzde Artış Görseli
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${widget.initialPct}%',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: widget.baseColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  '$newScore%',
                  style: TextStyle(
                    color: const Color(0xFF69F0AE),
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.topWeakness} Gelişimi: +$increase%',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: widget.baseColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: widget.baseColor.withOpacity(0.5)),
              ),
              child: Text(
                'Kazanılan Rozet:\n"${widget.topWeakness} Ustası"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: widget.baseColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                if (widget.onJourneyCompleted != null) {
                  widget.onJourneyCompleted!();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [
                      widget.baseColor,
                      widget.baseColor.withOpacity(0.7),
                    ],
                  ),
                ),
                child: const Text(
                  'YENİ SERÜVENE BAŞLA',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final currentTask = days[currentDay - 1];
    final progressPct =
        (currentDay - 1) / totalDays.toDouble(); // Toplam güne bölüyoruz

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.09),
            Colors.white.withOpacity(0.01),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: widget.baseColor.withOpacity(0.05),
            blurRadius: 40,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık Bölümü
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.25)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Text('✨', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$totalDays GÜNLÜK SERÜVEN',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 10,
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '"${widget.topWeakness}" Zaafını Yık',
                      style: GoogleFonts.cinzel(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Amaç
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.track_changes_rounded,
                  color: widget.baseColor.withOpacity(0.9),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Odak: $currentFocusText',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // İlerleme Alanı
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'GÜN $currentDay / $totalDays',
                style: GoogleFonts.cinzel(
                  color: widget.baseColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '%${(progressPct * 100).toInt()}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                ' TAMAM',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress Bar
          Stack(
            children: [
              Container(
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
              ),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progressPct == 0 ? 0.04 : progressPct,
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: [Colors.white.withOpacity(0.4), Colors.white],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Günün Görevi Kartı
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white.withOpacity(0.03),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '✨ GÜNÜN KEŞFİ ✨',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  currentTask['task'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Aksiyon Butonu
          GestureDetector(
            onTap: () {
              final taskToMark = days[currentDay - 1]['task'] as String;
              StorageService.addCompletedCosmicTask(taskToMark);

              if (currentDay >= totalDays) {
                widget.onJourneyCompleted?.call();
                _showCosmicCelebrationDialog(context);
                setState(() => isChallengeFinished = true);
              } else {
                setState(() => currentDay++);
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: widget.baseColor.withOpacity(0.85),
                boxShadow: [
                  BoxShadow(
                    color: widget.baseColor.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    currentDay >= totalDays
                        ? Icons.auto_awesome_rounded
                        : Icons.check_circle_outline_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    currentDay >= totalDays
                        ? 'SERÜVENİ TAMAMLA'
                        : 'BUGÜNÜ TAMAMLADIM',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Klasik Bağımsız İşaretçi (Dikey Çizgi ve Basit Nokta) ──
class _TimelineMarkerPainter extends CustomPainter {
  final Color color;
  _TimelineMarkerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Barın hizasına ince ayar (TextRow: 46px + SizedBox: 8px => bar center: 46+8+6 = 60px)
    final c = Offset(size.width / 2, 60.0);

    // Rengi bir tık aç (beyaza 40% daha yakın)
    final lightColor = Color.lerp(color, Colors.white, 0.4)!;

    // Dikey kısa çizgi (daha ince, biraz daha uzun ve rengi açık)
    final linePaint = Paint()
      ..color = lightColor.withOpacity(0.8)
      ..strokeWidth = 0.6;
    canvas.drawLine(
      Offset(c.dx, c.dy - 19),
      Offset(c.dx, c.dy + 19),
      linePaint,
    );

    // Ortadaki basit, parlamayan yuvarlak nokta (aynı açık renk)
    canvas.drawCircle(c, 3.5, Paint()..color = lightColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Özgün Geometrik Rozet Tasarımı (Procedural Badge) ──
class _ProceduralBadge extends StatelessWidget {
  final String seedText;
  final Color baseColor;
  final double size;

  const _ProceduralBadge({
    Key? key,
    required this.seedText,
    required this.baseColor,
    this.size = 100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final w = seedText.toLowerCase();
    int sides = 6;
    int outerSides = 8;
    double innerRatio = 0.5;
    Color accentColor = Colors.white;
    IconData centerIcon = Icons.star_rounded;

    if (w.contains('sabır') || w.contains('acele')) {
      sides = 8;
      outerSides = 12;
      innerRatio = 1.0;
      accentColor = const Color(0xFF00E5FF); // Cyans
      centerIcon = Icons.hourglass_bottom_rounded;
    } else if (w.contains('liderlik') ||
        w.contains('pasif') ||
        w.contains('çekingen')) {
      sides = 5;
      outerSides = 10;
      innerRatio = 0.4;
      accentColor = const Color(0xFFFF9100); // Orange/Gold
      centerIcon = Icons.local_fire_department_rounded;
    } else if (w.contains('iletişim') ||
        w.contains('sessiz') ||
        w.contains('içe dönük') ||
        w.contains('içedönük')) {
      sides = 3;
      outerSides = 6;
      innerRatio = 1.0;
      accentColor = const Color(0xFFE040FB); // Magenta/Pink
      centerIcon = Icons.graphic_eq_rounded;
    } else if (w.contains('odak') ||
        w.contains('dağınık') ||
        w.contains('dikkat')) {
      sides = 4;
      outerSides = 8;
      innerRatio = 0.2;
      accentColor = const Color(0xFF69F0AE); // Neon Green
      centerIcon = Icons.center_focus_strong_rounded;
    } else if (w.contains('kontrol') ||
        w.contains('kıskanç') ||
        w.contains('inat')) {
      sides = 7;
      outerSides = 14;
      innerRatio = 0.6;
      accentColor = const Color(0xFF448AFF); // Deep Blue
      centerIcon = Icons.water_drop_rounded;
    } else if (w.contains('kararsız') ||
        w.contains('hayır') ||
        w.contains('sınır')) {
      sides = 6;
      outerSides = 6;
      innerRatio = 0.5;
      accentColor = const Color(0xFFFF5252); // Red
      centerIcon = Icons.balance_rounded;
    } else if (w.contains('mükemmel') ||
        w.contains('eleştirel') ||
        w.contains('detay')) {
      sides = 9;
      outerSides = 9;
      innerRatio = 0.8;
      accentColor = const Color(0xFFFFD740); // Yellow
      centerIcon = Icons.spa_rounded;
    } else if (w.contains('sorumsuz') ||
        w.contains('sorumluluk') ||
        w.contains('ertelemek')) {
      sides = 4;
      outerSides = 4;
      innerRatio = 1.0;
      accentColor = const Color(0xFFD7CCC8); // Earth tone
      centerIcon = Icons.landscape_rounded;
    } else {
      // Default / Generics
      int seed = seedText.codeUnits.fold(0, (p, c) => p + c);
      sides = 4 + (seed % 6);
      outerSides = 6 + (seed % 7);
      innerRatio = 0.3 + ((seed % 5) * 0.1);
      final hues = [
        const Color(0xFFE040FB),
        const Color(0xFF00E5FF),
        const Color(0xFFFF9100),
        const Color(0xFF69F0AE),
        Colors.white,
      ];
      accentColor = hues[seed % hues.length];
      centerIcon = Icons.diamond_rounded;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [baseColor.withOpacity(0.2), baseColor.withOpacity(0.0)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dış Parıltı Gölgeleri (Neon Glow)
          Container(
            width: size * 0.7,
            height: size * 0.7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: baseColor.withOpacity(0.4),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: accentColor.withOpacity(0.2),
                  blurRadius: 50,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          // Dış Çerçeve (Kutsal Geometri / Outer)
          CustomPaint(
            size: Size(size * 0.85, size * 0.85),
            painter: _BadgeGeometryPainter(
              sides: outerSides,
              color: Colors.white.withOpacity(0.2),
              isOutline: true,
              innerRadiusRatio: 1.0,
              strokeWidth: 1.5,
            ),
          ),
          // Orta Çizgiler (Mid Geometry)
          CustomPaint(
            size: Size(size * 0.65, size * 0.65),
            painter: _BadgeGeometryPainter(
              sides: sides,
              color: baseColor.withOpacity(0.5),
              isOutline: true,
              innerRadiusRatio: 1.0,
              strokeWidth: 2.0,
            ),
          ),
          // İç Yıldız/Amblem (Inner Star)
          CustomPaint(
            size: Size(size * 0.5, size * 0.5),
            painter: _BadgeGeometryPainter(
              sides: sides,
              color: baseColor,
              isOutline: false,
              innerRadiusRatio: innerRatio,
              strokeWidth: 0,
              glowColor: accentColor,
            ),
          ),
          // Merkez Çekirdek (Thematic Icon)
          Container(
            padding: EdgeInsets.all(size * 0.08),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(centerIcon, color: Colors.white, size: size * 0.22),
          ),
        ],
      ),
    );
  }
}

class _BadgeGeometryPainter extends CustomPainter {
  final int sides;
  final Color color;
  final bool isOutline;
  final double innerRadiusRatio;
  final double strokeWidth;
  final Color? glowColor;

  _BadgeGeometryPainter({
    required this.sides,
    required this.color,
    required this.isOutline,
    required this.innerRadiusRatio,
    this.strokeWidth = 2.0,
    this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (glowColor != null) {
      Paint glowPaint = Paint()
        ..color = glowColor!.withOpacity(0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      _drawShape(canvas, size, glowPaint);
    }

    Paint paint = Paint()
      ..color = color
      ..style = isOutline ? PaintingStyle.stroke : PaintingStyle.fill
      ..strokeWidth = strokeWidth;

    _drawShape(canvas, size, paint);
  }

  void _drawShape(Canvas canvas, Size size, Paint paint) {
    Path path = Path();
    double cx = size.width / 2;
    double cy = size.height / 2;
    double radius = size.width / 2;
    double angleOffset = -math.pi / 2; // Yukarıdan başla

    // Yıldız (Star) çizimi
    if (innerRadiusRatio < 1.0) {
      double angle = (math.pi * 2) / sides;
      for (int i = 0; i < sides; i++) {
        // Dış nokta (Uç)
        double px = cx + radius * math.cos(angleOffset + (i * angle));
        double py = cy + radius * math.sin(angleOffset + (i * angle));
        if (i == 0)
          path.moveTo(px, py);
        else
          path.lineTo(px, py);

        // İç nokta (Vadi)
        double rInner = radius * innerRadiusRatio;
        double pnx =
            cx + rInner * math.cos(angleOffset + (i * angle) + (angle / 2));
        double pny =
            cy + rInner * math.sin(angleOffset + (i * angle) + (angle / 2));
        path.lineTo(pnx, pny);
      }
    } else {
      // Düz Poligon çizimi
      double angle = (math.pi * 2) / sides;
      for (int i = 0; i < sides; i++) {
        double px = cx + radius * math.cos(angleOffset + (i * angle));
        double py = cy + radius * math.sin(angleOffset + (i * angle));
        if (i == 0)
          path.moveTo(px, py);
        else
          path.lineTo(px, py);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Combined Radar Painter (Kombine Güç Haritası) ──
class _CombinedRadarPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final List<Color> colors;
  final int strengthCount;
  final int? selectedIndex;

  _CombinedRadarPainter({
    required this.values,
    required this.labels,
    required this.colors,
    required this.strengthCount,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    const cy = 155.0;
    const r = 105.0;
    final n = values.length;

    // Grid çizgileri (4 seviye)
    for (var level = 1; level <= 4; level++) {
      final lr = r * level / 4;
      final path = Path();
      for (var i = 0; i <= n; i++) {
        final angle = -math.pi / 2 + (2 * math.pi * (i % n) / n);
        final x = cx + math.cos(angle) * lr;
        final y = cy + math.sin(angle) * lr;
        if (i == 0)
          path.moveTo(x, y);
        else
          path.lineTo(x, y);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withOpacity(level == 4 ? 0.08 : 0.04)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5,
      );
    }

    // Eksen çizgileri
    for (var i = 0; i < n; i++) {
      final angle = -math.pi / 2 + (2 * math.pi * i / n);
      final x = cx + math.cos(angle) * r;
      final y = cy + math.sin(angle) * r;
      canvas.drawLine(
        Offset(cx, cy),
        Offset(x, y),
        Paint()
          ..color = Colors.white.withOpacity(0.05)
          ..strokeWidth = 0.5,
      );
    }

    // Güçlü yanlar polygon (altın)
    _drawPolygon(
      canvas,
      cx,
      cy,
      r,
      n,
      0,
      strengthCount,
      const Color(0xFFFFD060),
    );

    // Zayıf yanlar polygon (buz mavisi)
    _drawPolygon(
      canvas,
      cx,
      cy,
      r,
      n,
      strengthCount,
      n,
      const Color(0xFF8AAFC8),
    );

    // Nokta + etiketler
    for (var i = 0; i < n; i++) {
      final angle = -math.pi / 2 + (2 * math.pi * i / n);
      final vr = r * values[i];
      final px = cx + math.cos(angle) * vr;
      final py = cy + math.sin(angle) * vr;
      final isSelected = i == selectedIndex;
      final c = colors[i];

      // Veri noktası
      canvas.drawCircle(
        Offset(px, py),
        isSelected ? 5 : 3.5,
        Paint()..color = c.withOpacity(isSelected ? 0.9 : 0.6),
      );
      if (isSelected) {
        canvas.drawCircle(
          Offset(px, py),
          8,
          Paint()
            ..color = c.withOpacity(0.15)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }

      // Etiket konumu
      final labelR = r + 28;
      final lx = cx + math.cos(angle) * labelR;
      final ly = cy + math.sin(angle) * labelR;
      final pctText = '${(values[i] * 100).round()}%';
      final labelText = labels[i];

      // Yüzde
      final ptp = TextPainter(
        text: TextSpan(
          text: pctText,
          style: TextStyle(
            color: c.withOpacity(isSelected ? 0.95 : 0.6),
            fontSize: isSelected ? 12 : 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      // İsim
      final ltp = TextPainter(
        text: TextSpan(
          text: labelText,
          style: TextStyle(
            color: Colors.white.withOpacity(isSelected ? 0.9 : 0.5),
            fontSize: isSelected ? 11 : 9,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      // Pozisyon ayarla
      double tx = lx - ltp.width / 2;
      double ty = ly - ltp.height / 2;
      if (angle > math.pi / 4 && angle < 3 * math.pi / 4) ty += 4; // alt
      if (angle < -math.pi / 4 && angle > -3 * math.pi / 4) ty -= 4; // üst

      ltp.paint(canvas, Offset(tx, ty - 7));
      ptp.paint(canvas, Offset(lx - ptp.width / 2, ty + 7));
    }
  }

  void _drawPolygon(
    Canvas canvas,
    double cx,
    double cy,
    double r,
    int n,
    int from,
    int to,
    Color c,
  ) {
    final path = Path();
    for (var i = 0; i < n; i++) {
      final angle = -math.pi / 2 + (2 * math.pi * i / n);
      final v = (i >= from && i < to) ? values[i] : 0.0;
      final x = cx + math.cos(angle) * r * v;
      final y = cy + math.sin(angle) * r * v;
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
    }
    path.close();

    // Fill
    canvas.drawPath(path, Paint()..color = c.withOpacity(0.08));
    // Stroke
    canvas.drawPath(
      path,
      Paint()
        ..color = c.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    // Glow
    canvas.drawPath(
      path,
      Paint()
        ..color = c.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  @override
  bool shouldRepaint(covariant _CombinedRadarPainter old) =>
      old.selectedIndex != selectedIndex || old.values != values;
}

class _ArcGaugePainter extends CustomPainter {
  final double value; // 0.0 – 1.0
  final Color color;
  final Color textColor;

  _ArcGaugePainter({
    required this.value,
    required this.color,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 4;
    const startAngle = -math.pi * 0.75; // -135°
    const sweepTotal = math.pi * 1.5; // 270° toplam yay

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    // Arka plan track
    canvas.drawArc(
      rect,
      startAngle,
      sweepTotal,
      false,
      Paint()
        ..color = color.withOpacity(0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    final sweep = sweepTotal * value;
    canvas.drawArc(
      rect,
      startAngle,
      sweep,
      false,
      Paint()
        ..color = color.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );

    // Glow arc
    canvas.drawArc(
      rect,
      startAngle,
      sweep,
      false,
      Paint()
        ..color = color.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Uç nokta parlak daire
    final endAngle = startAngle + sweep;
    final px = cx + math.cos(endAngle) * r;
    final py = cy + math.sin(endAngle) * r;
    canvas.drawCircle(
      Offset(px, py),
      2.5,
      Paint()..color = color.withOpacity(0.8),
    );

    // Merkez yüzde yazısı
    final pct = (value * 100).round();
    final tp = TextPainter(
      text: TextSpan(
        text: '$pct',
        style: TextStyle(
          color: textColor.withOpacity(0.9),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _ArcGaugePainter old) => old.value != value;
}

// ── Crystal Shard Clipper (Asimetrik Kesim) ──
class _CrystalShardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const cut = 22.0; // sağ üst köşe kesim boyutu
    const r = 16.0; // diğer köşelerin yuvarlatma yarıçapı
    final w = size.width;
    final h = size.height;

    return Path()
      ..moveTo(r, 0) // sol üst — yuvarlak başlangıç
      ..lineTo(w - cut, 0) // üst kenar → sağ üst kesim başlangıcı
      ..lineTo(w, cut) // diagonal kesim aşağı
      ..lineTo(w, h - r) // sağ kenar aşağı
      ..quadraticBezierTo(w, h, w - r, h) // sağ alt yuvarlak
      ..lineTo(r, h) // alt kenar
      ..quadraticBezierTo(0, h, 0, h - r) // sol alt yuvarlak
      ..lineTo(0, r) // sol kenar
      ..quadraticBezierTo(0, 0, r, 0) // sol üst yuvarlak
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ── Kesik Çizgili Yuvarlak İşaret ──
class _DashedCirclePainter extends CustomPainter {
  final Color color;
  _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color.withOpacity(0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);

    const dashWidth = 5.0;
    const dashSpace = 4.0;
    final circumference = 2 * math.pi * radius;
    final dashCount = (circumference / (dashWidth + dashSpace)).floor();

    for (var i = 0; i < dashCount; i++) {
      final startAngle = (i * (dashWidth + dashSpace)) / radius;
      final sweepAngle = dashWidth / radius;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// ── UYUM SONUÇ SAYFASI ──
class _CompatibilityResultPage extends StatefulWidget {
  final Map<String, dynamic> sign1;
  final Map<String, dynamic> sign2;
  final Color gold;

  const _CompatibilityResultPage({
    required this.sign1,
    required this.sign2,
    required this.gold,
  });

  @override
  State<_CompatibilityResultPage> createState() =>
      _CompatibilityResultPageState();
}

class _CompatibilityResultPageState extends State<_CompatibilityResultPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Basic calculation for demo purposes:
    final combinedHash =
        (widget.sign1['name'].hashCode ^ widget.sign2['name'].hashCode).abs();

    final lovePct = 50 + (combinedHash % 45); // 50 to 95
    final friendPct = 40 + ((combinedHash ~/ 10) % 55); // 40 to 95
    final commPct = 45 + ((combinedHash ~/ 100) % 50); // 45 to 95
    final workPct = 35 + ((combinedHash ~/ 3) % 60); // 35 to 95
    final funPct = 40 + ((combinedHash ~/ 7) % 55); // 40 to 95

    final avg = (lovePct + friendPct + commPct + workPct + funPct) / 5.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1210),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.2),
                  radius: 1.2,
                  colors: [
                    widget.gold.withOpacity(0.15),
                    const Color(0xFF0F1210),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 20, top: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GlassBackButton(),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    colors: [
                      Color(0xFFE8D5B7),
                      Color(0xFFFFE8A1),
                      Color(0xFFFFD060),
                    ],
                  ).createShader(b),
                  child: Text(
                    'KOZMİK UYUM',
                    style: GoogleFonts.cinzel(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 50),

                // Avatars
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAvatar(widget.sign1),
                    const SizedBox(width: 20),
                    Icon(
                      Icons.all_inclusive,
                      color: widget.gold.withOpacity(0.5),
                      size: 30,
                    ),
                    const SizedBox(width: 20),
                    _buildAvatar(widget.sign2),
                  ],
                ),
                const SizedBox(height: 60),

                // Percentages
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 30,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ExpandableCategoryCard(
                          title: 'AŞK UYUMU',
                          categoryValue: 'love',
                          pct: lovePct,
                          iconObj: Icons.favorite_border,
                          c: _c,
                        ),
                        const SizedBox(height: 20),
                        _ExpandableCategoryCard(
                          title: 'ARKADAŞLIK',
                          categoryValue: 'friend',
                          pct: friendPct,
                          iconObj: Icons.people_alt_outlined,
                          c: _c,
                        ),
                        const SizedBox(height: 20),
                        _ExpandableCategoryCard(
                          title: 'İLETİŞİM & ZİHİN',
                          categoryValue: 'comm',
                          pct: commPct,
                          iconObj: Icons.chat_bubble_outline,
                          c: _c,
                        ),
                        const SizedBox(height: 20),
                        _ExpandableCategoryCard(
                          title: 'ORTAK ÇALIŞMA',
                          categoryValue: 'work',
                          pct: workPct,
                          iconObj: Icons.work_outline,
                          c: _c,
                        ),
                        const SizedBox(height: 20),
                        _ExpandableCategoryCard(
                          title: 'MACERA & EĞLENCE',
                          categoryValue: 'fun',
                          pct: funPct,
                          iconObj: Icons.explore_outlined,
                          c: _c,
                        ),

                        const SizedBox(height: 40),

                        // Description based on average
                        _buildAnalysisText(avg),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(Map<String, dynamic> s) {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: widget.gold.withOpacity(0.4), width: 2),
            boxShadow: [
              BoxShadow(color: widget.gold.withOpacity(0.1), blurRadius: 20),
            ],
          ),
          child: ClipOval(
            child: Image.asset(s['image'] as String, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          s['nameEn'].toString().toUpperCase(),
          style: GoogleFonts.cinzel(
            color: widget.gold,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisText(double avg) {
    String text;
    if (avg > 80)
      text =
          "Bu iki burç arasında güçlü bir çekim ve uyum var. Kozmik enerjiler bir araya geldiğinde durdurulamaz bir bağ yaratıyor.";
    else if (avg > 60)
      text =
          "Farklılıklar birbirini tamamlıyor. Zaman zaman çatışmalar yaşansa da, üzerinde çalışıldığında sağlam bir temel oluşturabilirler.";
    else
      text =
          "Yıldızlar bu ikili için oldukça farklı diller konuşuyor. Birbirinizi anlamak için ekstra çaba göstermeniz gerekebilir.";

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: widget.gold.withOpacity(0.06),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: widget.gold.withOpacity(0.2)),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
              height: 1.6,
              letterSpacing: 0.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpandableCategoryCard extends StatefulWidget {
  final String title;
  final String categoryValue;
  final int pct;
  final IconData iconObj;
  final AnimationController c;

  const _ExpandableCategoryCard({
    required this.title,
    required this.categoryValue,
    required this.pct,
    required this.iconObj,
    required this.c,
  });

  @override
  State<_ExpandableCategoryCard> createState() =>
      _ExpandableCategoryCardState();
}

class _ExpandableCategoryCardState extends State<_ExpandableCategoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final content = CompatibilityContent.get(widget.categoryValue, widget.pct);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _expanded = !_expanded;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: _expanded
                  ? Colors.white.withOpacity(0.08)
                  : Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _expanded
                    ? Colors.white.withOpacity(0.3)
                    : Colors.white.withOpacity(0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Sol taraf: Yuvarlak gauge
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: widget.c,
                            builder: (context, child) => CustomPaint(
                              size: const Size(70, 70),
                              painter: _ArcGaugePainter(
                                value: (widget.c.value * widget.pct) / 100,
                                color: Colors.white.withOpacity(0.85),
                                textColor: Colors
                                    .transparent, // We use icon instead of text
                              ),
                            ),
                          ),
                          AnimatedBuilder(
                            animation: widget.c,
                            builder: (context, child) => Text(
                              '${(widget.c.value * widget.pct).toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Sağ taraf: Başlık & Özet
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                widget.iconObj,
                                color: Colors.white.withOpacity(0.6),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  widget.title,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.95),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            content.dynamicText,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 11,
                              height: 1.4,
                            ),
                            maxLines: _expanded ? null : 2,
                            overflow: _expanded
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_expanded) ...[
                  const SizedBox(height: 24),
                  Container(height: 1, color: Colors.white.withOpacity(0.1)),
                  const SizedBox(height: 20),
                  _buildDetailRow(
                    'Avantajlar',
                    content.pros,
                    Icons.add_circle_outline,
                    Colors.greenAccent,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    'Zorluklar',
                    content.cons,
                    Icons.remove_circle_outline,
                    Colors.redAccent,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    'Tavsiye',
                    content.advice,
                    Icons.lightbulb_outline,
                    Colors.amberAccent,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String title,
    String text,
    IconData icon,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
