import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glass_back_button.dart';
import '../widgets/swipe_back_wrapper.dart';
import '../services/storage_service.dart';
import '../models/owl_models.dart';
import '../services/supabase_owl_service.dart';
import '../services/analytics_service.dart';
import 'compatibility_content.dart';
import 'cosmic_profile_page.dart';
import 'natal_chart_page.dart';

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
  String? _userAvatar;
  DateTime _birthDate = DateTime(1999, 12, 20);
  Map<String, int> _traitBoosts = {};
  String? _birthTime;
  String? _birthPlace;

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
      'allTraits': ['Cesur', 'Enerjik', 'Girişken', 'Tutkulu', 'Kararlı', 'Lider', 'Ateşli', 'Bağımsız', 'Atılgan', 'Güçlü'],
      'strengths': [
        'Doğal liderlik',
        'Cesaret ve atılganlık',
        'Girişimci ruh',
        'Bağımsızlık',
        'Yüksek enerji',
        'Öz güven',
      ],
      'allStrengths': ['Doğal liderlik', 'Cesaret ve atılganlık', 'Girişimci ruh', 'Bağımsızlık', 'Yüksek enerji', 'Öz güven', 'Hızlı karar verme', 'Motivasyon gücü', 'Rekabetçi ruh', 'Savaşçı irade'],
      'weaknesses': [
        'Sabırsızlık',
        'Düşünmeden hareket',
        'Hırslı olma',
        'Çabuk öfkelenme',
        'Bencillik',
        'Acelecilik',
      ],
      'allWeaknesses': ['Sabırsızlık', 'Düşünmeden hareket', 'Hırslı olma', 'Çabuk öfkelenme', 'Bencillik', 'Acelecilik', 'Sert tepki', 'Dinlememe', 'Takım çalışmasında zorlanma', 'Aşırı rekabet'],
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
      'allTraits': ['Güvenilir', 'Sabırlı', 'Kararlı', 'Sadık', 'Estetik', 'Pratik', 'Dayanıklı', 'Huzurlu', 'Duyusal', 'Topraklanmış'],
      'strengths': [
        'Sarsılmaz irade',
        'Maddi güvenlik',
        'Sanatsal hassasiyet',
        'Sadakat',
        'Sabır',
        'Güvenilirlik',
      ],
      'allStrengths': ['Sarsılmaz irade', 'Maddi güvenlik', 'Sanatsal hassasiyet', 'Sadakat', 'Sabır', 'Güvenilirlik', 'Doğa sevgisi', 'Lezzet anlayışı', 'Konfor yaratma', 'Istikrarlı dostluk'],
      'weaknesses': [
        'İnatçılık',
        'Değişime direnç',
        'Aşırı sahiplenme',
        'Maddiyatçılık',
        'Üşengeçlik',
        'Kıskançlık',
      ],
      'allWeaknesses': ['İnatçılık', 'Değişime direnç', 'Aşırı sahiplenme', 'Maddiyatçılık', 'Üşengeçlik', 'Kıskançlık', 'Konfor bağımlılığı', 'Rutine sığınma', 'Risk almama', 'Paylaşmaktan kaçınma'],
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
      'allTraits': ['Meraklı', 'Zeki', 'Sosyal', 'Esnek', 'İletişimci', 'Çok Yönlü', 'Hızlı', 'Uyumlu', 'Espritüel', 'Keşfedici'],
      'strengths': [
        'Hızlı öğrenme',
        'İletişim becerisi',
        'Uyum yeteneği',
        'Meraklı doğa',
        'Çok yönlülük',
        'Esnek düşünce',
      ],
      'allStrengths': ['Hızlı öğrenme', 'İletişim becerisi', 'Uyum yeteneği', 'Meraklı doğa', 'Çok yönlülük', 'Esnek düşünce', 'Espri yeteneği', 'Ağ kurma becerisi', 'Bilgi sentezi', 'Hızlı adaptasyon'],
      'weaknesses': [
        'Kararsızlık',
        'Yüzeysellik',
        'Çabuk sıkılma',
        'Tutarsızlık',
        'Gevşeklik',
        'Odak eksikliği',
      ],
      'allWeaknesses': ['Kararsızlık', 'Yüzeysellik', 'Çabuk sıkılma', 'Tutarsızlık', 'Gevşeklik', 'Odak eksikliği', 'Dedikodu eğilimi', 'Söz tutamama', 'Dağınıklık', 'Coşku kaybı'],
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
      'allTraits': ['Duygusal', 'Koruyucu', 'Sezgisel', 'Sadık', 'Şefkatli', 'Empatik', 'Annesel', 'İçsel', 'Hassas', 'Bağlı'],
      'strengths': [
        'Derin empati',
        'Aile bağları',
        'Güçlü sezgiler',
        'Koruyucu yapı',
        'Şefkat',
        'Sadakat',
      ],
      'allStrengths': ['Derin empati', 'Aile bağları', 'Güçlü sezgiler', 'Koruyucu yapı', 'Şefkat', 'Sadakat', 'Yuva yaratma', 'Duygusal zekâ', 'Besleyici enerji', 'Hafıza gücü'],
      'weaknesses': [
        'Aşırı duygusallık',
        'Geçmişe takılma',
        'Kabuğuna çekilme',
        'Alınganlık',
        'Karamsarlık',
        'Aşırı hassasiyet',
      ],
      'allWeaknesses': ['Aşırı duygusallık', 'Geçmişe takılma', 'Kabuğuna çekilme', 'Alınganlık', 'Karamsarlık', 'Aşırı hassasiyet', 'Edilgen saldırganlık', 'Suçluluk manipülasyonu', 'Kapanma refleksi', 'Aşırı endişe'],
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
      'allTraits': ['Özgüvenli', 'Lider Ruhlu', 'Cömert', 'Yaratıcı', 'Tutkulu', 'Sadık', 'Karizmatik', 'Ateşli', 'Asil', 'Parlak'],
      'strengths': [
        'Doğal karizma',
        'Yaratıcı güç',
        'Cömertlik',
        'Liderlik ruhu',
        'Özgüven',
        'Cesaret',
      ],
      'allStrengths': ['Doğal karizma', 'Yaratıcı güç', 'Cömertlik', 'Liderlik ruhu', 'Özgüven', 'Cesaret', 'Sahne hakimiyeti', 'İlham verme', 'Asalet', 'Koruyucu içgüdü'],
      'weaknesses': [
        'Gurur',
        'Dikkat beklentisi',
        'Otoriter tavır',
        'Kibir',
        'İnatçılık',
        'Egoizm',
      ],
      'allWeaknesses': ['Gurur', 'Dikkat beklentisi', 'Otoriter tavır', 'Kibir', 'İnatçılık', 'Egoizm', 'Kolay kırılma', 'Gösteriş düşkünlüğü', 'Onay bağımlılığı', 'Eleştiriye kapalılık'],
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
      'allTraits': ['Analitik', 'Düzenli', 'Detaycı', 'Mükemmeliyetçi', 'Yardımsever', 'Pratik', 'Özenli', 'Titiz', 'Alçak gönüllü', 'Stratejik'],
      'strengths': [
        'Analitik zekâ',
        'Düzen ve organizasyon',
        'Hizmet ruhu',
        'Detaycılık',
        'Pratiklik',
        'Güvenilirlik',
      ],
      'allStrengths': ['Analitik zekâ', 'Düzen ve organizasyon', 'Hizmet ruhu', 'Detaycılık', 'Pratiklik', 'Güvenilirlik', 'Problem çözme', 'Sağlık bilinci', 'Verimlilik', 'Titiz çalışma'],
      'weaknesses': [
        'Aşırı eleştirellik',
        'Mükemmeliyetçilik',
        'Endişe eğilimi',
        'Evham',
        'Detaylarda boğulma',
        'Soğuk görünüm',
      ],
      'allWeaknesses': ['Aşırı eleştirellik', 'Mükemmeliyetçilik', 'Endişe eğilimi', 'Evham', 'Detaylarda boğulma', 'Soğuk görünüm', 'Kendini yıpratma', 'Kontrolcülük', 'Esneklik eksikliği', 'Duygu bastırma'],
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
      'allTraits': ['Diplomatik', 'Estetik', 'Adil', 'Uyumlu', 'Zarif', 'Romantik', 'Dengeli', 'Nazik', 'Uzlaşmacı', 'Rafine'],
      'strengths': [
        'Adalet duygusu',
        'Estetik anlayış',
        'Diplomasi',
        'Uyum yeteneği',
        'Zarafet',
        'Sosyal beceri',
      ],
      'allStrengths': ['Adalet duygusu', 'Estetik anlayış', 'Diplomasi', 'Uyum yeteneği', 'Zarafet', 'Sosyal beceri', 'Arabuluculuk', 'Stil duygusu', 'Ortam yaratma', 'Nezaket'],
      'weaknesses': [
        'Kararsızlık',
        'Çatışmadan kaçınma',
        'Başkalarına bağımlılık',
        'Yüzeysellik',
        'Hayır diyememe',
        'Kendinden ödün verme',
      ],
      'allWeaknesses': ['Kararsızlık', 'Çatışmadan kaçınma', 'Başkalarına bağımlılık', 'Yüzeysellik', 'Hayır diyememe', 'Kendinden ödün verme', 'Pasif agresiflik', 'Memnun etme takıntısı', 'Kendi sesini kaybetme', 'Yalnızlık korkusu'],
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
      'allTraits': ['Tutkulu', 'Gizemli', 'Kararlı', 'Derin', 'Manyetik', 'Güçlü', 'Sezgisel', 'Stratejik', 'Dayanıklı', 'Dönüştürücü'],
      'strengths': [
        'Derin sezgi',
        'Yeniden doğuş gücü',
        'Sadakat',
        'Tutku',
        'Kararlılık',
        'Stratejik zeka',
      ],
      'allStrengths': ['Derin sezgi', 'Yeniden doğuş gücü', 'Sadakat', 'Tutku', 'Kararlılık', 'Stratejik zeka', 'Psikolojik derinlik', 'Gizem çekiciliği', 'Kriz yönetimi', 'Keşif gücü'],
      'weaknesses': [
        'Kıskançlık',
        'İntikamcılık',
        'Aşırı kontrol',
        'Şüphecilik',
        'Gizemlilik',
        'Sahiplenicilik',
      ],
      'allWeaknesses': ['Kıskançlık', 'İntikamcılık', 'Aşırı kontrol', 'Şüphecilik', 'Gizemlilik', 'Sahiplenicilik', 'Manipülasyon', 'Paranoya', 'Kin tutma', 'Obsesif bağlanma'],
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
      'allTraits': ['Maceracı', 'Özgür', 'Filozof', 'İyimser', 'Dürüst', 'Enerjik', 'Vizyoner', 'Neşeli', 'Kaşif', 'Cömert'],
      'strengths': [
        'Vizyon genişliği',
        'Macera ruhu',
        'Felsefi derinlik',
        'İyimserlik',
        'Özgür düşünce',
        'Dürüstlük',
      ],
      'allStrengths': ['Vizyon genişliği', 'Macera ruhu', 'Felsefi derinlik', 'İyimserlik', 'Özgür düşünce', 'Dürüstlük', 'Kültürel zenginlik', 'Mizah anlayışı', 'İlham verme', 'Ruhani arayış'],
      'weaknesses': [
        'Sorumsuzluk',
        'Aşırı dürüstlük',
        'Taahhüt korkusu',
        'Sabırsızlık',
        'Patavatsızlık',
        'Huzursuzluk',
      ],
      'allWeaknesses': ['Sorumsuzluk', 'Aşırı dürüstlük', 'Taahhüt korkusu', 'Sabırsızlık', 'Patavatsızlık', 'Huzursuzluk', 'Aşırı iyimserlik', 'Detay atlama', 'Kaçış eğilimi', 'Yerleşememe'],
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
      'allTraits': ['Disiplinli', 'Hırslı', 'Sorumlu', 'Ciddi', 'Geleneksel', 'Dayanıklı', 'Sabırlı', 'Stratejik', 'Güvenilir', 'Azimli'],
      'strengths': [
        'İrade gücü',
        'Uzun vadeli planlama',
        'Sorumluluk bilinci',
        'Disiplin',
        'Kararlılık',
        'Güvenilirlik',
      ],
      'allStrengths': ['İrade gücü', 'Uzun vadeli planlama', 'Sorumluluk bilinci', 'Disiplin', 'Kararlılık', 'Güvenilirlik', 'Sabırlı yükseliş', 'Pratik zekâ', 'Otorite', 'Dayanıklılık'],
      'weaknesses': [
        'Aşırı ciddiyet',
        'Duygularını bastırma',
        'İş koliklik',
        'Karamsarlık',
        'Katı kuralcılık',
        'Maddiyatçılık',
      ],
      'allWeaknesses': ['Aşırı ciddiyet', 'Duygularını bastırma', 'İş koliklik', 'Karamsarlık', 'Katı kuralcılık', 'Maddiyatçılık', 'Duygusal soğukluk', 'Eğlenememe', 'Statü takıntısı', 'Aşırı kontrol'],
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
      'allTraits': ['Yenilikçi', 'Bağımsız', 'Hümanist', 'Orijinal', 'Vizyoner', 'Asi', 'Ileriçi', 'Zeki', 'Toplumcu', 'Özgün'],
      'strengths': [
        'Özgün düşünce',
        'İnsancıl bakış',
        'Devrimci ruh',
        'Bağımsızlık',
        'Gelecek vizyonu',
        'Yenilikçilik',
      ],
      'allStrengths': ['Özgün düşünce', 'İnsancıl bakış', 'Devrimci ruh', 'Bağımsızlık', 'Gelecek vizyonu', 'Yenilikçilik', 'Teknoloji sevgisi', 'Toplumsal bilinç', 'Sıra dışı bakış', 'Entelektüel derinlik'],
      'weaknesses': [
        'Duygusal mesafe',
        'İnatçılık',
        'Asi tutum',
        'Bağlanma korkusu',
        'Ukalalık',
        'Aşırı rasyonalite',
      ],
      'allWeaknesses': ['Duygusal mesafe', 'İnatçılık', 'Asi tutum', 'Bağlanma korkusu', 'Ukalalık', 'Aşırı rasyonalite', 'Üstünlük taslama', 'Empati eksikliği', 'Kurallara karşı çıkma', 'Öngörülemezlik'],
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
      'allTraits': ['Hayalperest', 'Empati', 'Sanatsal', 'Sezgisel', 'Şefkatli', 'Gizemli', 'Rühani', 'Fedakar', 'Romantik', 'Hassas'],
      'strengths': [
        'Sınırsız empati',
        'Sanatsal yetenek',
        'Ruhani derinlik',
        'Sezgisel güç',
        'Şefkat',
        'Fedakarlık',
      ],
      'allStrengths': ['Sınırsız empati', 'Sanatsal yetenek', 'Ruhani derinlik', 'Sezgisel güç', 'Şefkat', 'Fedakarlık', 'Hayal gücü', 'Müzik yeteneği', 'Şifa enerjisi', 'Rüya yorumlama'],
      'weaknesses': [
        'Gerçeklikten kaçış',
        'Aşırı hassasiyet',
        'Sınır koyamama',
        'Kurban psikolojisi',
        'Kararsızlık',
        'Aşırı duygusallık',
      ],
      'allWeaknesses': ['Gerçeklikten kaçış', 'Aşırı hassasiyet', 'Sınır koyamama', 'Kurban psikolojisi', 'Kararsızlık', 'Aşırı duygusallık', 'Bağımlılık eğilimi', 'Pasiflik', 'Kolay kandırılma', 'Erteleme'],
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
    final avatar = await StorageService.getAvatar();
    final savedDate = await StorageService.getBirthDate();
    final boosts = await StorageService.getTraitBoosts();
    final bTime = await StorageService.getBirthTime();
    final bPlace = await StorageService.getBirthPlace();
    if (mounted) {
      setState(() {
        _userName = name;
        _userAvatar = avatar ?? 'assets/images/owl.png';
        _traitBoosts = boosts;
        _birthTime = bTime;
        _birthPlace = bPlace;
        if (savedDate != null) {
          _birthDate = savedDate;
          _selectedIndex = _signIndexFromDate(savedDate);
        } else {
          _selectedIndex = _signIndexFromDate(_birthDate);
        }
      });
      AnalyticsService().logZodiacViewed(sign: 'western_${_signs[_selectedIndex]['nameEn']}');
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
          filter: ui.ImageFilter.blur(sigmaX: 25, sigmaY: 25),
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
                          Icon(
                            Icons.star_rounded,
                            color: _gold.withOpacity(0.4),
                            size: 10,
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
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, scrollController) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                border: Border(
                  top: BorderSide(color: _gold.withOpacity(0.25), width: 0.8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 40,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 14),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.74,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
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
                                    userAvatar: _userAvatar,
                                    gold: const Color(
                                      0xFFE5CC75,
                                    ),
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
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _gold.withOpacity(0.12)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                sign['image'] as String,
                                width: 40,
                                height: 40,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                sign['name'].toString().toUpperCase(),
                                style: GoogleFonts.cinzel(
                                  color: _gold,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                sign['dates'] as String,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.35),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom + 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }

  void _showFriendListForCompatibility(Map<String, dynamic> mySign) {
    final mockService = SupabaseOwlService();
    final friends = mockService.friends;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, scrollController) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border(top: BorderSide(color: _gold.withOpacity(0.25), width: 0.8)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 40,
                    offset: const Offset(0, -8),
                  ),
                ],
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
                  const SizedBox(height: 16),
                  Text(
                    'ARKADAŞ SEÇ',
                    style: GoogleFonts.cinzel(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kozmik enerjilerinizi karşılaştırmak için bir dost seç',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: friends.isEmpty
                      ? Center(
                          child: Text(
                            'Henüz arkadaşın yok',
                            style: TextStyle(color: Colors.white.withOpacity(0.5)),
                          ),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          itemCount: friends.length,
                          separatorBuilder: (context, i) => const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final f = friends[i];
                            // Arkadaş için rastgele ama id'ye göre tutarlı bir burç belirle
                            final friendSignIndex = f.user.id.hashCode.abs() % _signs.length;
                            final friendSign = _signs[friendSignIndex];

                            return GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (_, __, ___) => _CompatibilityResultPage(
                                      sign1: mySign,
                                      sign2: friendSign,
                                      friend: f,
                                      gold: const Color(0xFFE5CC75),
                                      userAvatar: _userAvatar,
                                    ),
                                    transitionsBuilder: (_, a, __, child) =>
                                        FadeTransition(opacity: a, child: child),
                                    transitionDuration: const Duration(milliseconds: 400),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.02),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: _gold.withOpacity(0.15)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _gold.withOpacity(0.05),
                                        border: Border.all(color: _gold.withOpacity(0.2)),
                                      ),
                                      child: Center(
                                        child: Text(
                                          f.user.emoji,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontFamilyFallback: ['Apple Color Emoji', 'Segoe UI Emoji', 'Noto Color Emoji'],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            f.user.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              ClipOval(
                                                child: Image.asset(
                                                  friendSign['image'] as String,
                                                  width: 16,
                                                  height: 16,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                friendSign['name'] as String,
                                                style: TextStyle(
                                                  color: _gold.withOpacity(0.6),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _gold.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'SEÇ',
                                        style: TextStyle(
                                          color: _gold,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
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
    final isCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    return SwipeBackWrapper(
      child: TickerMode(
        enabled: isCurrent,
        child: Scaffold(
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
                                          (s['name'] as String).toUpperCase(),
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
                                      Icon(
                                        Icons.star_rounded,
                                        color: _gold.withOpacity(0.3),
                                        size: 9,
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
                                      Icon(
                                        Icons.star_rounded,
                                        color: _gold.withOpacity(0.3),
                                        size: 9,
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
                                  'Ruh Hali',
                                  s['quality'] as String,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ── KOZMİK REHBERİN — Günlük Fal + Kişilik Birleşik Kart ──
                        // ── KOZMİK REHBERİN — Günlük Fal + Kişilik Birleşik Kart ──
                        _fadeIn(
                          500,
                          _CosmicGuideInteractive(
                            s: s,
                            goldColor: _gold,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── ANALİTİK PROFİL — Güçlü Yanlar & Gelişim ──
                        _fadeIn(700, _analyticsCard(s)),

                        const SizedBox(height: 28),

                        // ── DERİN ASTROLOJİ — Doğum Haritası & Yükselen ──
                        _fadeIn(750, _premiumAstrologyCard(s)),

                        const SizedBox(height: 28),

                        // ── KOZMİK BAĞLANTILAR — Burç Uyumu ──
                        _fadeIn(800, _compatibilityCard(s)),

                        SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        ), // Stack
      ), // Scaffold
      ), // TickerMode
    ); // SwipeBackWrapper
  }

  // ═══════════════════════════════════════════
  // YARDIMCI WİDGETLER
  // ═══════════════════════════════════════════

  // ── Analitik Güçlü Yanlar & Gelişim Kartı ──
  Widget _analyticsCard(Map<String, dynamic> s) {
    final strengths = s['strengths'] as List<String>;
    final weaknesses = s['weaknesses'] as List<String>;
    final name = s['name'] as String;

    // 10 günde bir trait rotasyonu
    final activeTraits = _getActiveTraits(s);

    final scoreMap = _computeTraitScores(s, _traitBoosts);
    final values = List.generate(6, (i) {
      return (scoreMap[activeTraits[i]] ?? 75) / 100.0;
    });
    final displayTraits = activeTraits;

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
            width: double.infinity,
            height: 310,
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
                CupertinoPageRoute(
                  builder: (_) => _ZodiacDetailPage(
                    sign: s,
                    gold: _gold,
                    boosts: _traitBoosts,
                    onBoostUpdated: _loadUserData,
                  ),
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
    delay: Duration(milliseconds: delayMs + 1400),
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
            'Yıldızların rehberliğinde ikili enerjini keşfet',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 30),
          _CosmicHarmonyAnimation(
            color: _gold,
            currentSignData: currentSignData,
            onPickFriend: () => _showZodiacPickerForCompatibility(currentSignData),
            userAvatar: _userAvatar,
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => _showFriendListForCompatibility(currentSignData),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _gold.withOpacity(0.3), width: 1),
                gradient: LinearGradient(
                  colors: [
                    _gold.withOpacity(0.02),
                    _gold.withOpacity(0.10),
                    _gold.withOpacity(0.02),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _gold.withOpacity(0.05),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add_alt_1_rounded, color: _gold.withOpacity(0.9), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'ARKADAŞ SEÇ',
                    style: TextStyle(
                      color: _gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
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
  Widget _premiumAstrologyCard(Map<String, dynamic> s) {
    final hasBirthInfo = _birthTime != null && _birthTime!.isNotEmpty && _birthPlace != null && _birthPlace!.isNotEmpty;

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
                  'KOZMİK DOĞUM ÇARKI',
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
            'Doğum saati ve yeriyle hesaplanan derin analizin',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 24),

          if (hasBirthInfo) ...[
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => NatalChartPage(
                      birthTime: _birthTime!,
                      birthPlace: _birthPlace!,
                      sunSignData: s,
                      selectedIndex: _selectedIndex,
                    ),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: _gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _gold.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(color: _gold.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5)),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: 68,
                      height: 68,
                      child: CustomPaint(
                        painter: _MiniNatalChartPainter(color: _gold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'DOĞUM HARİTASI',
                      style: GoogleFonts.cinzel(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ASC, Güneş, Ay ve Gezegen Açıları',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('İNCELE', style: TextStyle(color: _gold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                          const SizedBox(width: 6),
                          Icon(Icons.arrow_forward_ios_rounded, color: _gold, size: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            _buildLockedPremiumInfo(),
          ],
        ],
      ),
    );
  }

  Widget _buildLockedPremiumInfo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
          ),
          child: Column(
            children: [
              // Glowing Lock Icon
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _gold.withOpacity(0.15),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.04),
                      border: Border.all(color: _gold.withOpacity(0.4), width: 1),
                    ),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      color: _gold.withOpacity(0.9),
                      size: 26,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                'DOĞUM HARİTASI KİLİTLİ',
                style: GoogleFonts.cinzel(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Description
              Text(
                'Doğum haritanı oluşturabilmemiz için doğum saatine ve yerine ihtiyacımız var.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                  height: 1.6,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Premium Button
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (ctx) => const CosmicProfilePage()),
                  );
                  _loadUserData();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _gold.withOpacity(0.4), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: _gold.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'KİLİDİ AÇ',
                        style: TextStyle(
                          color: _gold,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: _gold,
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
    final r = (math.min(size.width, size.height) / 2) - 65;
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
// 10 GÜNLÜK ROTASYON SİSTEMİ
// ═══════════════════════════════════════════

/// Genel rotasyon: [allKey] havuzundan her 10 günde bir farklı [take] tanesini seçer.
/// Seçim deterministik: aynı burç + aynı periyotta hep aynı öğeler.
/// [category] parametresi farklı listeler (traits/strengths/weaknesses) için
/// farklı shuffle sonuçları üretir.
List<String> _getActiveList(
  Map<String, dynamic> sign, {
  required String allKey,
  required String defaultKey,
  required String category,
  int take = 6,
}) {
  final allItems = sign[allKey] as List<dynamic>?;
  final defaultItems = sign[defaultKey] as List<dynamic>;

  if (allItems == null || allItems.length <= take) {
    return defaultItems.take(take).cast<String>().toList();
  }

  final now = DateTime.now();
  final daysSinceEpoch = now.difference(DateTime(2025, 1, 1)).inDays;
  final period = daysSinceEpoch ~/ 10;

  final signName = sign['name'] as String;
  final seed = signName.hashCode ^ (period * 31337) ^ category.hashCode;

  final pool = List<String>.from(allItems.cast<String>());
  final rng = math.Random(seed);
  for (int i = pool.length - 1; i > 0; i--) {
    final j = rng.nextInt(i + 1);
    final tmp = pool[i];
    pool[i] = pool[j];
    pool[j] = tmp;
  }

  return pool.take(take).toList();
}

/// Radar chart trait'leri — her 10 günde 6 farklı
List<String> _getActiveTraits(Map<String, dynamic> sign) =>
    _getActiveList(sign, allKey: 'allTraits', defaultKey: 'traits', category: 'traits');

/// Süper Güçlerin — her 10 günde 6 farklı
List<String> _getActiveStrengths(Map<String, dynamic> sign) =>
    _getActiveList(sign, allKey: 'allStrengths', defaultKey: 'strengths', category: 'strengths');

/// Büyüme Alanların — her 10 günde 6 farklı
List<String> _getActiveWeaknesses(Map<String, dynamic> sign) =>
    _getActiveList(sign, allKey: 'allWeaknesses', defaultKey: 'weaknesses', category: 'weaknesses');

// ═══════════════════════════════════════════
// TUTARLI TRAIT SKORU HESAPLAMA
// ═══════════════════════════════════════════

/// Zayıflık adından olumlu karşılığına dönüşüm haritası (rozet adları için)
const _weaknessToPositive = <String, String>{
  'Sabırsızlık': 'Sabır',
  'Düşünmeden hareket': 'Düşünceli Hareket',
  'Hırslı olma': 'Dengeli Hırs',
  'Çabuk öfkelenme': 'Sakinlik',
  'Bencillik': 'Empati',
  'Acelecilik': 'Sabır',
  'İnatçılık': 'Esneklik',
  'Değişime direnç': 'Uyum',
  'Aşırı sahiplenme': 'Güven',
  'Maddiyatçılık': 'Ruhani Zenginlik',
  'Üşengeçlik': 'Motivasyon',
  'Kıskançlık': 'Güven',
  'Kararsızlık': 'Kararlılık',
  'Yüzeysellik': 'Derinlik',
  'Çabuk sıkılma': 'Odaklanma',
  'Tutarsızlık': 'Tutarlılık',
  'Gevşeklik': 'Disiplin',
  'Odak eksikliği': 'Odaklanma',
  'Aşırı duygusallık': 'Duygusal Denge',
  'Geçmişe takılma': 'Şimdi',
  'Kabuğuna çekilme': 'Açılma',
  'Alınganlık': 'Dayanıklılık',
  'Karamsarlık': 'İyimserlik',
  'Aşırı hassasiyet': 'Dayanıklılık',
  'Gurur': 'Alçakgönüllülük',
  'Dikkat beklentisi': 'İç Huzur',
  'Otoriter tavır': 'Şefkatli Liderlik',
  'Kibir': 'Tevazu',
  'Egoizm': 'Paylaşım',
  'Aşırı eleştirellik': 'Anlayış',
  'Mükemmeliyetçilik': 'Kabul',
  'Endişe eğilimi': 'Güven',
  'Evham': 'Huzur',
  'Detaylarda boğulma': 'Büyük Resim',
  'Soğuk görünüm': 'Sıcaklık',
  'Çatışmadan kaçınma': 'Cesaret',
  'Başkalarına bağımlılık': 'Bağımsızlık',
  'Hayır diyememe': 'Sınır Koyma',
  'Kendinden ödün verme': 'Öz Değer',
  'İntikamcılık': 'Affetme',
  'Aşırı kontrol': 'Güven',
  'Şüphecilik': 'Güven',
  'Gizemlilik': 'Açıklık',
  'Sahiplenicilik': 'Bırakma',
  'Sorumsuzluk': 'Sorumluluk',
  'Aşırı dürüstlük': 'İncelik',
  'Taahhüt korkusu': 'Bağlanma',
  'Patavatsızlık': 'Zarafet',
  'Huzursuzluk': 'İç Huzur',
  'Aşırı ciddiyet': 'Neşe',
  'Duygularını bastırma': 'Duygusal Özgürlük',
  'İş koliklik': 'Denge',
  'Katı kuralcılık': 'Esneklik',
  'Duygusal mesafe': 'Yakınlık',
  'Asi tutum': 'Uyum',
  'Bağlanma korkusu': 'Bağlanma',
  'Ukalalık': 'Alçakgönüllülük',
  'Aşırı rasyonalite': 'Sezgisellik',
  'Gerçeklikten kaçış': 'Gerçeklik',
  'Sınır koyamama': 'Sınır Koyma',
  'Kurban psikolojisi': 'Güçlenme',
  // ── Genişletilmiş havuz (allWeaknesses) ──
  'Sert tepki': 'Yumuşak Güç',
  'Dinlememe': 'Aktif Dinleme',
  'Takım çalışmasında zorlanma': 'İş Birliği',
  'Aşırı rekabet': 'Dengeli Rekabet',
  'Konfor bağımlılığı': 'Cesaret',
  'Rutine sığınma': 'Yenilik',
  'Risk almama': 'Cesur Adım',
  'Paylaşmaktan kaçınma': 'Cömertlik',
  'Dedikodu eğilimi': 'Saygı',
  'Söz tutamama': 'Sadakat',
  'Dağınıklık': 'Düzen',
  'Coşku kaybı': 'İlham',
  'Edilgen saldırganlık': 'Doğrudanlık',
  'Suçluluk manipülasyonu': 'Dürüst İfade',
  'Kapanma refleksi': 'Açılma',
  'Aşırı endişe': 'Huzur',
  'Kolay kırılma': 'Dayanıklılık',
  'Gösteriş düşkünlüğü': 'Sadelik',
  'Onay bağımlılığı': 'Öz Değer',
  'Eleştiriye kapalılık': 'Gelişim',
  'Kendini yıpratma': 'Öz Bakım',
  'Kontrolcülük': 'Bırakma',
  'Esneklik eksikliği': 'Esneklik',
  'Duygu bastırma': 'Duygusal Özgürlük',
  'Pasif agresiflik': 'Doğrudanlık',
  'Memnun etme takıntısı': 'Öz Değer',
  'Kendi sesini kaybetme': 'Ses Bulma',
  'Yalnızlık korkusu': 'İç Huzur',
  'Manipülasyon': 'Dürüstlük',
  'Paranoya': 'Güven',
  'Kin tutma': 'Affetme',
  'Obsesif bağlanma': 'Sağlıklı Bağ',
  'Aşırı iyimserlik': 'Gerçekçilik',
  'Detay atlama': 'Dikkat',
  'Kaçış eğilimi': 'Yüzleşme',
  'Yerleşememe': 'Kök Salma',
  'Duygusal soğukluk': 'Sıcaklık',
  'Eğlenememe': 'Neşe',
  'Statü takıntısı': 'İçsel Değer',
  'Üstünlük taslama': 'Eşitlik',
  'Empati eksikliği': 'Empati',
  'Kurallara karşı çıkma': 'Uyum',
  'Öngörülemezlik': 'Tutarlılık',
  'Bağımlılık eğilimi': 'Bağımsızlık',
  'Pasiflik': 'İnisiyatif',
  'Kolay kandırılma': 'Sağduyu',
  'Erteleme': 'Harekete Geçme',
};

/// Bir burcun trait ve strength isimlerini anlam bazında eşleştirerek
/// her iki bölümde de (radar chart + detay sayfası) tutarlı yüzdelik üretir.
/// [boosts] parametresi kalıcı olarak kaydedilmiş trait boost'larını uygular.
Map<String, double> _computeTraitScores(Map<String, dynamic> sign, [Map<String, int>? boosts]) {
  final traits = sign['traits'] as List<dynamic>;
  final strengths = sign['strengths'] as List<dynamic>;
  final weaknesses = sign['weaknesses'] as List<dynamic>;
  final map = <String, double>{};
  final b = boosts ?? {};

  // 1) Tüm trait skorlarını hesapla + boost uygula
  final count = traits.length > 6 ? 6 : traits.length;
  final traitScores = <int, double>{};
  for (int i = 0; i < count; i++) {
    final traitName = traits[i] as String;
    final h = (traitName.hashCode ^ (i * 7919)).abs() % 100;
    final base = 55 + (h % 40).toDouble();
    final boost = b[traitName] ?? 0;
    final score = (base + boost).clamp(0, 99).toDouble();
    traitScores[i] = score;
    map[traitName] = score;
  }

  // 1b) allTraits'teki ekstra trait'ler için de skor hesapla (rotasyon desteği)
  final allTraits = sign['allTraits'] as List<dynamic>?;
  if (allTraits != null) {
    for (int i = 0; i < allTraits.length; i++) {
      final tName = allTraits[i] as String;
      if (!map.containsKey(tName)) {
        final h = (tName.hashCode ^ (i * 7919)).abs() % 100;
        final base = 55 + (h % 40).toDouble();
        final boost = b[tName] ?? 0;
        map[tName] = (base + boost).clamp(0, 99).toDouble();
      }
    }
  }

  // 2) Her strength için en uygun trait'i BUL ve aynı skoru ata
  for (int si = 0; si < strengths.length && si < count; si++) {
    final sName = strengths[si] as String;
    final matchIdx = _findBestTraitMatch(sName, traits, count);
    final baseScore = traitScores[matchIdx >= 0 ? matchIdx : si]!;
    final boost = b[sName] ?? 0;
    map[sName] = (baseScore + boost).clamp(0, 99).toDouble();
  }

  // 2b) allStrengths'teki ekstra öğeler için de skor hesapla (rotasyon desteği)
  final allStrengths = sign['allStrengths'] as List<dynamic>?;
  if (allStrengths != null) {
    for (int i = 0; i < allStrengths.length; i++) {
      final sName = allStrengths[i] as String;
      if (!map.containsKey(sName)) {
        final h = (sName.hashCode ^ (i * 7919)).abs() % 100;
        final base = 55 + (h % 40).toDouble();
        final boost = b[sName] ?? 0;
        map[sName] = (base + boost).clamp(0, 99).toDouble();
      }
    }
  }

  // 3) Weaknesses: kendi formülü (30-65 arası) + boost
  for (int i = 0; i < weaknesses.length && i < 6; i++) {
    final wName = weaknesses[i] as String;
    final h = (wName.hashCode ^ (i * 5147)).abs() % 100;
    final base = 30 + (h % 35).toDouble();
    final boost = b[wName] ?? 0;
    map[wName] = (base + boost).clamp(0, 99).toDouble();
  }

  // 3b) allWeaknesses'teki ekstra öğeler için de skor hesapla (rotasyon desteği)
  final allWeaknesses = sign['allWeaknesses'] as List<dynamic>?;
  if (allWeaknesses != null) {
    for (int i = 0; i < allWeaknesses.length; i++) {
      final wName = allWeaknesses[i] as String;
      if (!map.containsKey(wName)) {
        final h = (wName.hashCode ^ (i * 5147)).abs() % 100;
        final base = 30 + (h % 35).toDouble();
        final boost = b[wName] ?? 0;
        map[wName] = (base + boost).clamp(0, 99).toDouble();
      }
    }
  }

  return map;
}

/// Bir strength adına en iyi eşleşen trait'in index'ini döndürür.
/// Eşleşme bulunamazsa -1 döner (fallback olarak index kullanılır).
int _findBestTraitMatch(String strength, List<dynamic> traits, int count) {
  final sLower = strength.toLowerCase();
  final sWords = sLower.split(' ');

  // Strateji 1: Strength, trait adını içeriyor mu?
  //   Örn: "Dürüstlük" → contains("dürüst") ✓
  //   Örn: "İyimserlik" → contains("iyimser") ✓ (İ→i dönüşümü ile)
  for (int i = 0; i < count; i++) {
    final tLower = (traits[i] as String).toLowerCase();
    if (tLower.length >= 3 && sLower.contains(tLower)) return i;
  }

  // Strateji 2: Trait, strength adını (veya herhangi bir kelimesini) içeriyor mu?
  //   Örn: "Maceracı" → contains("macera") ✓ ("Macera ruhu" kelimesi)
  for (int i = 0; i < count; i++) {
    final tLower = (traits[i] as String).toLowerCase();
    for (final w in sWords) {
      if (w.length >= 4 && tLower.contains(w)) return i;
    }
  }

  // Strateji 3: Strength'in herhangi bir kelimesi, trait ile ortak kök paylaşıyor mu?
  //   En az 4 karakter ortak ön ek kontrolü
  for (int i = 0; i < count; i++) {
    final tLower = (traits[i] as String).toLowerCase();
    for (final w in sWords) {
      if (w.length >= 4 && tLower.length >= 4) {
        int common = 0;
        final minLen = w.length < tLower.length ? w.length : tLower.length;
        for (int j = 0; j < minLen; j++) {
          if (w[j] == tLower[j]) {
            common++;
          } else {
            break;
          }
        }
        if (common >= 4) return i;
      }
    }
  }

  return -1; // Eşleşme bulunamadı, fallback index kullanılacak
}

// ═══════════════════════════════════════════
// KENDİNİ KEŞFET — DETAY SAYFASI (Zigzag Kart Tasarım)
// ═══════════════════════════════════════════
class _ZodiacDetailPage extends StatefulWidget {
  final Map<String, dynamic> sign;
  final Color gold;
  final Map<String, int> boosts;
  final VoidCallback? onBoostUpdated;
  const _ZodiacDetailPage({
    required this.sign,
    required this.gold,
    this.boosts = const {},
    this.onBoostUpdated,
  });

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
    // Rotasyonlu havuzdan al, sonra karıştır ve 3 tanesini göster
    final activeStrengths = _getActiveStrengths(widget.sign);
    final activeWeaknesses = _getActiveWeaknesses(widget.sign);
    shuffledStrengths = (List<String>.from(activeStrengths)..shuffle()).take(3).toList();
    shuffledWeaknesses = (List<String>.from(activeWeaknesses)..shuffle()).take(3).toList();
  }

  // Trait için yüzde hesapla — radar chart ile tutarlı
  Map<String, double> _scoreMap = {};

  void _reloadScores() {
    StorageService.getTraitBoosts().then((boosts) {
      if (mounted) {
        setState(() {
          _scoreMap = _computeTraitScores(widget.sign, boosts);
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scoreMap.isEmpty) {
      _scoreMap = _computeTraitScores(widget.sign, widget.boosts);
    }
  }

  int _getPct(String trait, bool isStrength) {
    return (_scoreMap[trait] ?? (isStrength ? 75 : 45)).round();
  }

  String _getFallback(String trait, bool isStrength) {
    final hints = isStrength
        ? const [
            'Potansiyelini keşfet ve öne çık.',
            'Bu özelliğini günlük hayatta aktif kullan.',
            'Bunu bir avantaja dönüştürebilirsin.',
            'Bu yönde adımlar atarak fark yarat.',
            'Bu eşsiz yeteneğini ön plana çıkar.',
          ]
        : const [
            'Farkındalık geliştirerek dengeyi bul.',
            'Bu özelliği bir gelişim fırsatı olarak gör.',
            'Küçük adımlarla bu yönünü törpüle.',
            'Bilinçli çaba ile bunu dönüştürebilirsin.',
            'Bu zayıflığın üzerine gidip güçlen.',
          ];
    
    // Her gün farklı bir tavsiye gelmesi için zaman bazlı rotasyon (Günlük döngü)
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    
    return hints[(trait.hashCode.abs() + dayOfYear) % hints.length];
  }

  @override
  Widget build(BuildContext context) {
    final sign = widget.sign;
    final strengths = shuffledStrengths;
    final weaknesses = shuffledWeaknesses;
    final nameEn = sign['name'] as String;

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
      // ── Koç ──
      'Bağımsızlık': 'Kendi rotanı çizerek bağımsız karar alma gücünü kullan.',
      'Yüksek enerji': 'Yüksek enerjinle çevreni motive et ve projelere öncülük et.',
      'Öz güven': 'Kendine güvenini ilham kaynağı olarak çevrenle paylaş.',
      'Hızlı karar verme': 'Kritik anlarda hızlı ve doğru kararlar alarak liderlik et.',
      'Motivasyon gücü': 'Enerjinle takımını harekete geçir ve motivasyonu yüksek tut.',
      'Rekabetçi ruh': 'Rekabet gücünü kendini geliştirmek için bir araç olarak kullan.',
      'Savaşçı irade': 'Zorluklara karşı yılmaz duruşunla engelleri aş.',
      // ── Boğa ──
      'Doğa sevgisi': 'Doğa ile kurduğun bağı yaşam tarzına entegre et.',
      'Lezzet anlayışı': 'Damak tadını gastronomi ve sosyal deneyimlerde değerlendir.',
      'Konfor yaratma': 'Yaşam alanlarını herkes için konforlu ve ilham verici kıl.',
      'Istikrarlı dostluk': 'Uzun süreli dostluklarını koruyarak güçlü bir çevre oluştur.',
      // ── İkizler ──
      'Meraklı doğa': 'Sonsuz merakını sürekli öğrenme ve gelişim için kullan.',
      'Çok yönlülük': 'Birçok alanda yetkinlik kazanarak çok yönlü bir profil oluştur.',
      'Esnek düşünce': 'Esnek düşünce yapınla yaratıcı çözümler üret.',
      'Espri yeteneği': 'Mizahınla ortamı yumuşat ve insanları bir araya getir.',
      'Ağ kurma becerisi': 'Sosyal ağını stratejik olarak genişleterek fırsatlar yarat.',
      'Bilgi sentezi': 'Farklı alanlardan edindiğin bilgileri sentezleyerek yenilik üret.',
      'Hızlı adaptasyon': 'Değişen koşullara hızla uyum sağlayarak avantaj kazan.',
      // ── Yengeç ──
      'Koruyucu yapı': 'Sevdiklerini koruma içgüdünle güvenli ortamlar yarat.',
      'Şefkat': 'Şefkatinle çevrendeki insanların hayatına dokunmaya devam et.',
      'Yuva yaratma': 'Sıcak ve huzurlu ortamlar kurarak sevdiklerini destekle.',
      'Besleyici enerji': 'Besleyici enerjinle çevrendeki insanları büyüt ve güçlendir.',
      'Hafıza gücü': 'Güçlü hafızanı öğrenme ve derin bağlar kurmada avantaja çevir.',
      // ── Aslan ──
      'Liderlik ruhu': 'Doğal liderlik karizmanla ekipleri başarıya taşı.',
      'Özgüven': 'Güçlü özgüvenini ilham kaynağına dönüştür.',
      'Cesaret': 'Cesaretinle bilinmeyene adım atarak yeni ufuklar keşfet.',
      'Sahne hakimiyeti': 'Sahne hakimiyetinle fikirlerin etkili bir şekilde ulaştır.',
      'İlham verme': 'İlham verici kişiliğinle çevrendeki insanları motive et.',
      'Asalet': 'Asil duruşunla saygı uyandır ve güvenilir bir figür ol.',
      'Koruyucu içgüdü': 'Sevdiklerini koruma içgüdünle liderlik pozisyonu üstlen.',
      // ── Başak ──
      'Detaycılık': 'Detaylara olan hakimiyetinle projelerde mükemmelliğe ulaş.',
      'Pratiklik': 'Pratik çözümlerin ile karmaşık sorunları basitleştir.',
      'Problem çözme': 'Analitik yeteneğinle en zorlu problemlere çözüm üret.',
      'Sağlık bilinci': 'Sağlık bilincinle hem kendine hem çevrene örnek ol.',
      'Verimlilik': 'Verimli çalışma tarzınla zamandan ve kaynaklardan tasarruf et.',
      'Titiz çalışma': 'Titizliğinle yüksek kaliteli işler ortaya koy.',
      // ── Terazi ──
      'Zarafet': 'Zarif duruşunla her ortamda fark yaratan bir izlenim bırak.',
      'Sosyal beceri': 'Sosyal becerilerinle geniş ve güçlü bir network oluştur.',
      'Arabuluculuk': 'Arabuluculuk yeteneğinle çatışmaları çöz ve uyum sağla.',
      'Stil duygusu': 'Benzersiz stil anlayışınla kendini ifade et ve ilham ver.',
      'Ortam yaratma': 'Estetik anlayışınla herkesin keyif alacağı ortamlar tasarla.',
      'Nezaket': 'Nazik yaklaşımınla derin ve kalıcı ilişkiler kur.',
      // ── Akrep ──
      'Tutku': 'Tutkunu hayatının her alanına yansıtarak fark yarat.',
      'Stratejik zeka': 'Stratejik zekanla uzun vadeli planlar yaparak hedeflerine ulaş.',
      'Psikolojik derinlik': 'İnsanları anlama yeteneğinle derin ve anlamlı bağlar kur.',
      'Gizem çekiciliği': 'Gizemli auranla insanları kendine çekerek etki alanını genişlet.',
      'Kriz yönetimi': 'Kriz anlarındaki soğukkanlılığınla liderlik üstlen.',
      'Keşif gücü': 'Merakını derinlemesine araştırmalarla bilgiye dönüştür.',
      // ── Yay ──
      'İyimserlik': 'İyimser bakış açınla zorlu süreçleri motive edici hale getir.',
      'Özgür düşünce': 'Özgür düşüncenle kalıpların dışına çıkarak yenilikler yarat.',
      'Dürüstlük': 'Dürüstlüğünle güven inşa et ve ilişkilerini sağlam temellere ota.',
      'Kültürel zenginlik': 'Farklı kültürlerden edindiğin bilgiyi çevrene aktararak zenginlik kat.',
      'Mizah anlayışı': 'Mizah gücünle ortamı aydınlat ve insanları bir araya getir.',
      'Ruhani arayış': 'Ruhani derinliğinle hayatına anlam katacak keşifler yap.',
      // ── Oğlak ──
      'Disiplin': 'Disiplininle hedeflerine kararlılıkla ilerleyerek başarıya ulaş.',
      'Sabırlı yükseliş': 'Sabırla attığın her adımın seni zirveye taşıyacağını bil.',
      'Pratik zekâ': 'Pratik zekanla somut çözümler üreterek çevrende fark yarat.',
      'Otorite': 'Doğal otoritenle güvenilir bir lider figürü ol.',
      'Dayanıklılık': 'Sarsılmaz dayanıklılığınla en zorlu süreçlerin üstesinden gel.',
      // ── Kova ──
      'Gelecek vizyonu': 'Geleceğe yönelik vizyonunla yenilikçi projeler başlat.',
      'Yenilikçilik': 'Yenilikçi düşüncenle geleneksel kalıpları kırarak ilerleme sağla.',
      'Teknoloji sevgisi': 'Teknolojiye olan tutkunu geleceği şekillendirmek için kullan.',
      'Toplumsal bilinç': 'Toplumsal duyarlılığınla anlamlı sosyal projeler başlat.',
      'Sıra dışı bakış': 'Sıra dışı bakış açınla yaratıcı çözümler üreterek ilham ver.',
      'Entelektüel derinlik': 'Entelektüel derinliğinle düşünce liderliği üstlen.',
      // ── Balık ──
      'Fedakarlık': 'Fedakar ruhunla çevrendeki insanların hayatına değer kat.',
      'Hayal gücü': 'Sınırsız hayal gücünü yaratıcı projelere dönüştür.',
      'Müzik yeteneği': 'Müzikal yeteneğini sanatsal ifade aracı olarak geliştir.',
      'Şifa enerjisi': 'İyileştirici enerjinle çevrendekilere destek ve huzur sağla.',
      'Rüya yorumlama': 'İç dünyanın mesajlarını keşfederek farkındalığını derinleştir.',
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
      // ── Ek zayıf yönler (allWeaknesses) ──
      'Kibir': 'Alçakgönüllülük pratiği yaparak çevrendeki insanlara yaklaş.',
      'Egoizm': 'Başkalarının ihtiyaçlarına kulak vererek empati kasını çalıştır.',
      'Evham': 'Somut verilerle düşüncelerini test ederek gerçekçi kal.',
      'Detaylarda boğulma': 'Büyük resme odaklanarak önceliklendirme yap.',
      'Soğuk görünüm': 'Samimi küçük jestlerle sıcaklığını göster.',
      'Hayır diyememe': 'Sınırlarını net koyarak enerjini koru.',
      'Kendinden ödün verme': 'Kendi ihtiyaçlarını da önceliklendirmeyi öğren.',
      'Şüphecilik': 'Güven inşa egzersizleri ile insanlara şans ver.',
      'Gizemlilik': 'Açık iletişim pratiği yaparak yakınlarınla bağını güçlendir.',
      'Sahiplenicilik': 'Özgürlük ve güven dengesini kurarak ilişkilerini sağlamlaştır.',
      'Patavatsızlık': 'Düşüncelerini ifade etmeden önce empati filtresinden geçir.',
      'Aşırı iyimserlik': 'Plan B hazırlama alışkanlığı edinerek dengeli kal.',
      'Detay atlama': 'Kontrol listesi kullanarak önemli detayları kaçırma.',
      'Kaçış eğilimi': 'Zorlukların üstüne giderek dayanıklılığını artır.',
      'Yerleşememe': 'Kısa vadeli rutinler oluşturarak istikrar deneyimle.',
      'Katı kuralcılık': 'Esneklik denemeleri yaparak yeni yaklaşımlara açıl.',
      'Duygusal soğukluk': 'Duygularını günlüğe yazarak iç dünyanla bağlan.',
      'Eğlenememe': 'Haftalık eğlence aktiviteleri planlayarak hayattan keyif al.',
      'Statü takıntısı': 'İç değerlerine odaklanarak dış onaydan bağımsızlaş.',
      'Ukalalık': 'Başkalarının bilgisine saygı göstererek dinleme becerisini geliştir.',
      'Aşırı rasyonalite': 'Sezgilerine de güvenerek duygusal zekanı besle.',
      'Bağlanma korkusu': 'Küçük bağlılık adımları atarak güven ortamı yarat.',
      'Üstünlük taslama': 'Alçakgönüllülük pratiği yaparak empatiyi güçlendir.',
      'Empati eksikliği': 'Başkalarının perspektifinden bakmaya çalışarak empati kur.',
      'Kurallara karşı çıkma': 'Yapıcı önerilerle değişim yaratmanın yollarını bul.',
      'Öngörülemezlik': 'Tutarlı davranış kalıpları oluşturarak güvenilirliğini artır.',
      'Kurban psikolojisi': 'Sorumluluk almayı öğrenerek kendi gücünü keşfet.',
      'Bağımlılık eğilimi': 'Bağımsız aktivitelerle öz yeterliliğini güçlendir.',
      'Pasiflik': 'Küçük inisiyatifler alarak aktif katılımı deneyimle.',
      'Kolay kandırılma': 'Eleştirel düşünme becerini geliştirerek sağlıklı sınırlar koy.',
      'Erteleme': 'Pomodoro tekniği ile küçük adımlarla başlama alışkanlığı edin.',
      'Sert tepki': 'Tepki vermeden önce 3 nefes alarak sakinleş.',
      'Dinlememe': 'Aktif dinleme pratiği yaparak ilişkilerini derinleştir.',
      'Takım çalışmasında zorlanma': 'Küçük gruplarla işbirliği yaparak takım ruhunu geliştir.',
      'Aşırı rekabet': 'İşbirliğine dayalı projelerle rekabeti dengeye getir.',
      'Konfor bağımlılığı': 'Konfor alanının dışına çıkarak yeni deneyimler kazan.',
      'Rutine sığınma': 'Haftalık bir yenilik deneyerek rutinden çık.',
      'Risk almama': 'Hesaplanmış küçük risklerle cesaret kasını geliştir.',
      'Paylaşmaktan kaçınma': 'Küçük paylaşım adımları atarak cömertliği deneyimle.',
      'Dedikodu eğilimi': 'Yapıcı konuşma pratiği yaparak pozitif iletişim kur.',
      'Söz tutamama': 'Küçük sözler verip tutarak güvenilirliğini inşa et.',
      'Dağınıklık': 'Günlük düzen rutini oluşturarak odaklanmayı artır.',
      'Coşku kaybı': 'İlham veren aktivitelerle motivasyonunu yeniden keşfet.',
      'Edilgen saldırganlık': 'Duygularını doğrudan ve nazikçe ifade etmeyi öğren.',
      'Suçluluk manipülasyonu': 'Dürüst iletişim kurarak sağlıklı sınırlar belirle.',
      'Kapanma refleksi': 'Güvendiğin birine açılarak bağ kurma pratiği yap.',
      'Aşırı endişe': 'Mindfulness ile şimdiki ana odaklanarak endişeyi azalt.',
      'Kolay kırılma': 'Dayanıklılık egzersizleri ile öz güvenini pekiştir.',
      'Gösteriş düşkünlüğü': 'İç değerlerine odaklanarak dış görünümden bağımsızlaş.',
      'Onay bağımlılığı': 'Kendi başarılarını kutlayarak iç onay mekanizmasını güçlendir.',
      'Eleştiriye kapalılık': 'Yapıcı geri bildirimi büyüme fırsatı olarak değerlendir.',
      'Kendini yıpratma': 'Öz bakım rutini oluşturarak enerjini koru.',
      'Kontrolcülük': 'Akışa bırakma pratiği yaparak esnekliğini geliştir.',
      'Esneklik eksikliği': 'Farklı yaklaşımları deneyerek adaptasyon yeteneğini güçlendir.',
      'Duygu bastırma': 'Duygularını güvenli bir ortamda ifade etme pratiği yap.',
      'Pasif agresiflik': 'Doğrudan ve nazik iletişim kurarak ilişkilerini sağlamlaştır.',
      'Memnun etme takıntısı': 'Kendi ihtiyaçlarını ön plana koyma cesaretini göster.',
      'Kendi sesini kaybetme': 'Kişisel değerlerini tanımla ve savunma pratiği yap.',
      'Yalnızlık korkusu': 'Yalnız kalma pratiği yaparak iç huzurunu keşfet.',
      'Manipülasyon': 'Dürüst ve açık iletişim kurarak güven inşa et.',
      'Paranoya': 'Güven egzersizleri yaparak olumlu niyetleri görmayı öğren.',
      'Kin tutma': 'Affetme pratiği yaparak iç huzurunu bul.',
      'Obsesif bağlanma': 'Sağlıklı bağlanma kalıpları oluşturarak dengeyi bul.',
    };

    return SwipeBackWrapper(
      child: Scaffold(
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // ── Geri butonu ──
                        Row(
                          children: [
                            GlassBackButton(
                              onTap: () => Navigator.pop(context),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CustomPaint(
                                painter: _CosmicStarPainter(color: gold),
                              ),
                            ),
                            const Spacer(),
                            const SizedBox(width: 36),
                          ],
                        ),

                        const SizedBox(height: 16),

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

                        const SizedBox(height: 20),

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
                        const SizedBox(height: 12),

                        // Zigzag layout — güçlü yanlar
                        ...List.generate(strengths.length, (i) {
                          final trait = strengths[i];
                          final pct = _getPct(trait, true);
                          final hint =
                              usageHints[trait] ?? _getFallback(trait, true);
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
                        const SizedBox(height: 12),
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
                        const SizedBox(height: 20), 
                        // ═══════════════════════════
                        // | BÜYÜME ALANLARIN
                        // ═══════════════════════════
                        _sectionHeader('BÜYÜME ALANLARIN', _coolBlue),
                        const SizedBox(height: 12),

                        // Zigzag layout — zayıf yanlar
                        ...List.generate(weaknesses.length, (i) {
                          final trait = weaknesses[i];
                          final pct = _getPct(trait, false);
                          final hint =
                              growthTips[trait] ?? _getFallback(trait, false);
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
                            'Kişisel farkındalığını artırmak için dönüşüm odaklı bir serüven',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildCosmicQuests(weaknesses),

                        SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ));
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
            fontSize: 22, // Küçültüldü
            fontWeight: FontWeight.w700,
            height: 1.0,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '%',
          style: GoogleFonts.cinzel(
            color: color.withOpacity(0.5),
            fontSize: 12, // Küçültüldü
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
          height: 8, // İnceltildi
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        // Dolu Kısım
        FractionallySizedBox(
          widthFactor: pct / 100.0,
          child: Container(
            height: 8, // İnceltildi
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
      padding: const EdgeInsets.only(bottom: 12), // Tek sayfayı aşmadan yaymak için dengeli ayar
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
                        height: 28, // Sıkışmadan dengeli okuma alanı
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                trait,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12, // Denge sağlandı
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            pctWidget,
                          ],
                        ),
                      ),
                      const SizedBox(height: 5), // Barlar azıcık rahatlatıldı
                      barWidget,
                      const SizedBox(height: 5), // Barlar azıcık rahatlatıldı
                      Text(
                        hint,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 10, // Denge sağlandı
                          fontStyle: FontStyle.normal, // Düz normale dönüldü
                          height: 1.25,
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
                        height: 28, // Sıkışmadan dengeli okuma alanı
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
                                  fontSize: 12, // Denge sağlandı
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5), // Barlar azıcık rahatlatıldı
                      barWidget,
                      const SizedBox(height: 5), // Barlar azıcık rahatlatıldı
                      Text(
                        hint,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 10, // Denge sağlandı
                          fontStyle: FontStyle.normal, // Düz normale dönüldü
                          height: 1.25,
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
      onDayCompleted: () async {
        // Her günlük görev tamamlandığında +1 boost
        await StorageService.addTraitBoost(topWeakness, 1);
        widget.onBoostUpdated?.call();
        _reloadScores();
      },
      onJourneyCompleted: () async {
        // Serüven tamamlandığında ekstra +2 bonus
        await StorageService.addTraitBoost(topWeakness, 2);
        widget.onBoostUpdated?.call();
        _reloadScores();
        if (mounted) {
          setState(() {
            final first = shuffledWeaknesses.removeAt(0);
            shuffledWeaknesses.add(first);
          });
        }
      },
    );
  }
}

class _CosmicChallengeCard extends StatefulWidget {
  final String topWeakness;
  final Color baseColor;
  final int initialPct;
  final VoidCallback? onDayCompleted;
  final VoidCallback? onJourneyCompleted;

  const _CosmicChallengeCard({
    super.key,
    required this.topWeakness,
    required this.baseColor,
    required this.initialPct,
    this.onDayCompleted,
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
                      '"${_weaknessToPositive[widget.topWeakness] ?? widget.topWeakness} Ustası"',
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

  /// Zaaf konusuna göre tematik ikon döndürür
  IconData _weaknessIcon(String weakness) {
    final w = weakness.toLowerCase();
    if (w.contains('sabır') || w.contains('acele')) return Icons.hourglass_bottom_rounded;
    if (w.contains('liderlik') || w.contains('pasif') || w.contains('çekingen')) return Icons.local_fire_department_rounded;
    if (w.contains('iletişim') || w.contains('sessiz') || w.contains('içe dönük') || w.contains('içedönük')) return Icons.graphic_eq_rounded;
    if (w.contains('odak') || w.contains('dağınık') || w.contains('dikkat')) return Icons.center_focus_strong_rounded;
    if (w.contains('kontrol') || w.contains('kıskanç') || w.contains('inat')) return Icons.water_drop_rounded;
    if (w.contains('kararsız') || w.contains('hayır') || w.contains('sınır')) return Icons.balance_rounded;
    if (w.contains('mükemmel') || w.contains('eleştirel') || w.contains('detay') || w.contains('mükemmeliyet')) return Icons.diamond_rounded;
    if (w.contains('maddiyat') || w.contains('hırs') || w.contains('açgözlü')) return Icons.monetization_on_rounded;
    if (w.contains('soğuk') || w.contains('mesafe') || w.contains('duygusuz')) return Icons.ac_unit_rounded;
    if (w.contains('sorumsuz') || w.contains('sorumluluk') || w.contains('ertelemek')) return Icons.landscape_rounded;
    if (w.contains('güven') || w.contains('korkak') || w.contains('korku')) return Icons.shield_rounded;
    if (w.contains('öfke') || w.contains('sinir') || w.contains('agresif')) return Icons.whatshot_rounded;
    return Icons.auto_awesome_rounded;
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
                'Kazanılan Rozet:\n"${_weaknessToPositive[widget.topWeakness] ?? widget.topWeakness} Ustası"',
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
                child: Icon(
                  _weaknessIcon(widget.topWeakness),
                  color: Colors.white.withOpacity(0.9),
                  size: 22,
                ),
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
                    'GÜNÜN KEŞFİ',
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

              // Her günlük görev tamamlandığında boost kaydet
              widget.onDayCompleted?.call();

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
        w.contains('detay') || 
        w.contains('mükemmeliyet')) {
      sides = 9;
      outerSides = 9;
      innerRatio = 0.8;
      accentColor = const Color(0xFFFFD740); // Yellow
      centerIcon = Icons.diamond_rounded;
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
  _ArcGaugePainter({
    required this.value,
    required this.color,
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

    // İstenmeyen / çift çizilen "Merkez yüzde yazısı" kısmı kaldırıldı
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

    // Ensure we perfectly distribute dashes around the circle
    // We want a roughly equal dash and gap ratio.
    const approximateDashWidth = 5.0;
    const approximateGapWidth = 4.0;
    final totalSegmentLength = approximateDashWidth + approximateGapWidth;

    final circumference = 2 * math.pi * radius;
    // Calculate how many integer segments we can fit perfectly
    final dashCount = (circumference / totalSegmentLength).round();

    // Now perfectly divide the 2*pi radians by the rounded discrete count
    final totalRadianPerSegment = (2 * math.pi) / dashCount;
    // Keep the dash ratio the same relative to the new exact segment
    final dashRatio = approximateDashWidth / totalSegmentLength;
    final dashRadian = totalRadianPerSegment * dashRatio;

    for (var i = 0; i < dashCount; i++) {
      final startAngle = i * totalRadianPerSegment;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashRadian,
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
  final Friend? friend;
  final String? userAvatar;
  final Color gold;

  const _CompatibilityResultPage({
    required this.sign1,
    required this.sign2,
    this.friend,
    this.userAvatar,
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
    int combinedHash =
        (widget.sign1['name'].hashCode ^ widget.sign2['name'].hashCode).abs();

    if (widget.friend != null) {
      // Eğer bir arkadaş seçildiyse, sadece burçları değil kişinin eşsiz karmasını da hesaba kat (Arkadaş ID'si)
      combinedHash = (combinedHash ^ widget.friend!.user.id.hashCode).abs();
    }

    final lovePct = 50 + (combinedHash % 45); // 50 to 95
    final friendPct = 40 + ((combinedHash ~/ 10) % 55); // 40 to 95
    final commPct = 45 + ((combinedHash ~/ 100) % 50); // 45 to 95
    final workPct = 35 + ((combinedHash ~/ 3) % 60); // 35 to 95
    final funPct = 40 + ((combinedHash ~/ 7) % 55); // 40 to 95

    final avg = (lovePct + friendPct + commPct + workPct + funPct) / 5.0;

    return SwipeBackWrapper(
      child: Scaffold(
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
          // Scrollable Content
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 70,
                bottom: MediaQuery.of(context).padding.bottom + 40,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                        // Title
                        ShaderMask(
                          shaderCallback: (b) => const LinearGradient(
                            colors: [
                              Color(0xFFF1DEB9), // Soft warm gold
                              Color(0xFFF5E296), // Muted center glow
                              Color(0xFFE5CC75), // Deep gold base
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
                            _buildAvatar(widget.sign1, assetImageAvatar: widget.userAvatar),
                            const SizedBox(width: 20),
                            Icon(
                              Icons.all_inclusive,
                              color: widget.gold.withOpacity(0.5),
                              size: 30,
                            ),
                            const SizedBox(width: 20),
                            _buildAvatar(widget.sign2, f: widget.friend),
                          ],
                        ),
                        const SizedBox(height: 30),

                        if (widget.friend != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                            child: _buildDeepSynastryCard(widget.friend!),
                          ),

                        // Percentages
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 30,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (widget.friend == null) ...[
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
                              ] else ...[
                                _ExpandableCategoryCard(
                                  title: 'KARMİK BAĞ & GEÇMİŞ Y.',
                                  categoryValue: 'karmic',
                                  pct: lovePct, // Yeniden rastgele hashlendiği için farklı dağılımlar olacak 
                                  iconObj: Icons.all_inclusive,
                                  c: _c,
                                  isAdvanced: true,
                                ),
                                const SizedBox(height: 20),
                                _ExpandableCategoryCard(
                                  title: 'GİZLİ TELEPATİ',
                                  categoryValue: 'telepathy',
                                  pct: commPct,
                                  iconObj: Icons.wifi_tethering,
                                  c: _c,
                                  isAdvanced: true,
                                ),
                                const SizedBox(height: 20),
                                _ExpandableCategoryCard(
                                  title: 'KRİZ DİNAMİĞİ',
                                  categoryValue: 'crisis',
                                  pct: workPct,
                                  iconObj: Icons.thunderstorm_outlined,
                                  c: _c,
                                  isAdvanced: true,
                                ),
                                const SizedBox(height: 20),
                                _ExpandableCategoryCard(
                                  title: 'TOKSİK ÇARPIŞMA',
                                  categoryValue: 'toxic',
                                  pct: funPct,
                                  iconObj: Icons.warning_amber_rounded,
                                  c: _c,
                                  isAdvanced: true,
                                ),
                              ],

                              const SizedBox(height: 40),

                              // Description based on average
                              _buildAnalysisText(avg),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          
          // Floating Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20,
            child: const GlassBackButton(),
          ),
        ],
      ),
    ));
  }

  Widget _buildDeepSynastryCard(Friend friend) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: widget.gold.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: widget.gold.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, color: widget.gold.withOpacity(0.7), size: 14),
              const SizedBox(width: 8),
              Text(
                'DERİN SİNASTRİ HARİTASI',
                style: GoogleFonts.cinzel(
                  color: widget.gold.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.auto_awesome, color: widget.gold.withOpacity(0.7), size: 14),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${friend.user.name} ile arandaki uyum sadece Güneş burçlarıyla sınırlandırılmadı.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Kozmik algoritma, gizlilik esasına dayanarak her iki tarafın da astrolojik doğum haritalarını, Ay ve Yükselen evrelerini perde arkasında çaprazlayarak bu analizi tamamen size özel hale getirdi.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 11,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Sadece görsel bir ayrıştırıcı
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 30, height: 1, color: widget.gold.withOpacity(0.2)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.lock_person_outlined, size: 16, color: widget.gold.withOpacity(0.4)),
              ),
              Container(width: 30, height: 1, color: widget.gold.withOpacity(0.2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(Map<String, dynamic> s, {Friend? f, String? assetImageAvatar}) {
    // If f != null, it's a friend (Emoji). If assetImageAvatar != null, it's the user's avatar image.
    final bool hasAvatarOverride = f != null || assetImageAvatar != null;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasAvatarOverride ? widget.gold.withOpacity(0.05) : null,
                border: Border.all(color: widget.gold.withOpacity(0.4), width: 2),
                boxShadow: [
                  BoxShadow(color: widget.gold.withOpacity(0.1), blurRadius: 20),
                ],
              ),
              child: f != null
                  ? Center(child: Text(f.user.emoji, style: const TextStyle(
                      fontSize: 40,
                      fontFamilyFallback: ['Apple Color Emoji', 'Segoe UI Emoji', 'Noto Color Emoji'],
                    )))
                  : assetImageAvatar != null
                      ? ClipOval(child: assetImageAvatar.startsWith('http')
                          ? Image.network(assetImageAvatar, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Image.asset(s['image'] as String, fit: BoxFit.cover))
                          : Image.asset(assetImageAvatar, fit: BoxFit.cover))
                      : ClipOval(child: Image.asset(s['image'] as String, fit: BoxFit.cover)),
            ),
            if (hasAvatarOverride)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1210),
                  shape: BoxShape.circle,
                  border: Border.all(color: widget.gold.withOpacity(0.5), width: 1.5),
                ),
                child: ClipOval(
                  child: Image.asset(
                    s['image'] as String,
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          s['name'].toString().toUpperCase(),
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
        filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: widget.gold.withOpacity(0.06),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: widget.gold.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: widget.gold.withOpacity(0.03),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome,
                color: widget.gold.withOpacity(0.5),
                size: 20,
              ),
              const SizedBox(height: 12),
              Container(
                width: 80,
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.gold.withOpacity(0),
                      widget.gold.withOpacity(0.5),
                      widget.gold.withOpacity(0),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: 14,
                  height: 1.6,
                  letterSpacing: 0.5,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 80,
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.gold.withOpacity(0),
                      widget.gold.withOpacity(0.5),
                      widget.gold.withOpacity(0),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Icon(
                Icons.auto_awesome,
                color: widget.gold.withOpacity(0.5),
                size: 20,
              ),
            ],
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
  final bool isAdvanced;

  const _ExpandableCategoryCard({
    required this.title,
    required this.categoryValue,
    required this.pct,
    required this.iconObj,
    required this.c,
    this.isAdvanced = false,
  });

  @override
  State<_ExpandableCategoryCard> createState() =>
      _ExpandableCategoryCardState();
}

class _ExpandableCategoryCardState extends State<_ExpandableCategoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final content = widget.isAdvanced 
        ? CompatibilityContent.getAdvanced(widget.categoryValue, widget.pct)
        : CompatibilityContent.get(widget.categoryValue, widget.pct);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
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
                              Expanded(
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
                              const SizedBox(width: 8),
                              AnimatedRotation(
                                turns: _expanded ? 0.5 : 0.0,
                                duration: const Duration(milliseconds: 300),
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.white.withOpacity(0.5),
                                  size: 20,
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

// ── ── Kozmik Rehber İnteraktif Paneli ── ──
class _CosmicGuideInteractive extends StatefulWidget {
  final Map<String, dynamic> s;
  final Color goldColor;

  const _CosmicGuideInteractive({
    Key? key,
    required this.s,
    required this.goldColor,
  }) : super(key: key);

  @override
  State<_CosmicGuideInteractive> createState() => _CosmicGuideInteractiveState();
}

class _CosmicGuideInteractiveState extends State<_CosmicGuideInteractive>
    with SingleTickerProviderStateMixin {
  bool _isOpened = false;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  String _formatCurrentDate() {
    final d = DateTime.now();
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }

  Widget _buildIntroCard() {
    final _gold = widget.goldColor;
    return GestureDetector(
      key: const ValueKey('intro'),
      onTap: () {
        setState(() => _isOpened = true);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              _gold.withOpacity(0.08),
              _gold.withOpacity(0.02),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: _gold.withOpacity(0.2)),
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
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_pulseCtrl.value * 0.05),
                  child: Opacity(
                    opacity: 0.8 + (_pulseCtrl.value * 0.2),
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CustomPaint(
                        painter: _CosmicStarPainter(color: _gold),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'KOZMİK REHBERİN',
              style: GoogleFonts.cinzel(
                color: _gold,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 12),
            // YENİ: TARİH BADGE'İ BAŞLANGIÇ PANELİNDE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _gold.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _gold.withOpacity(0.25),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today, color: _gold.withOpacity(0.7), size: 12),
                  const SizedBox(width: 6),
                  Text(
                    _formatCurrentDate(),
                    style: TextStyle(
                      color: _gold.withOpacity(0.9),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Bugünün fısıltısını hisset ve\nruhsal portrenin sırlarını çöz.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: _gold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _gold.withOpacity(0.4)),
              ),
              child: const Text(
                'Rehberi Arala',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpanded() {
    final _gold = widget.goldColor;
    final s = widget.s;
    return Container(
      key: const ValueKey('expanded'),
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
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
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
                    painter: _CosmicStarPainter(color: _gold),
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
                          color: Colors.white.withOpacity(0.3),
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
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: _gold.withOpacity(0.04),
                border: Border.all(color: _gold.withOpacity(0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 3,
                        height: 14,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
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
                      const SizedBox(width: 8),
                      // YENİ: TARİH BİLGİSİ EKLENDİ
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _gold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: _gold.withOpacity(0.2),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          _formatCurrentDate(),
                          style: TextStyle(
                            color: _gold.withOpacity(0.9),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    s['dailyHoroscope'] as String,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
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
            padding: const EdgeInsets.symmetric(horizontal: 32),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CustomPaint(
                      painter: _CosmicEyePainter(color: _gold),
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
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: 14,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 850),
      switchInCurve: Curves.easeOutBack, // Hafifçe yayılan açılış
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final rotate = Tween(begin: math.pi / 2, end: 0.0).animate(animation);
        final scale = Tween(begin: 0.85, end: 1.0).animate(animation);
        final fade = Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: const Interval(0.2, 1.0)),
        );
        
        return AnimatedBuilder(
          animation: animation,
          child: child,
          builder: (context, w) {
            return FadeTransition(
              opacity: fade,
              child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0012)
                  ..scale(scale.value)
                  ..rotateX(rotate.value),
                alignment: Alignment.center,
                child: child,
              ),
            );
          },
        );
      },
      child: _isOpened ? _buildExpanded() : _buildIntroCard(),
    );
  }
}

class _CosmicHarmonyAnimation extends StatefulWidget {
  final Color color;
  final Map<String, dynamic> currentSignData;
  final VoidCallback onPickFriend;
  final String? userAvatar;

  const _CosmicHarmonyAnimation({
    required this.color,
    required this.currentSignData,
    required this.onPickFriend,
    this.userAvatar,
  });

  @override
  State<_CosmicHarmonyAnimation> createState() => _CosmicHarmonyAnimationState();
}

class _CosmicHarmonyAnimationState extends State<_CosmicHarmonyAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  bool _isInteracting = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat();
  }

  @override
  void dispose() { 
    _c.dispose(); 
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (_) => setState(() => _isInteracting = true),
      onPanEnd: (_) => setState(() => _isInteracting = false),
      onPanCancel: () => setState(() => _isInteracting = false),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: _isInteracting ? 1.0 : 0.0),
        duration: const Duration(milliseconds: 700),
        curve: Curves.elasticOut,
        builder: (context, interactVal, child) {
          return AnimatedBuilder(
            animation: _c,
            builder: (_, __) {
              final spin = _c.value;
              
              // Daha yavaş ve dingin nabız (40 saniyede aheste dalgalanmalar)
              final magneticPulse = (math.sin(spin * math.pi * 16) + 1.0) / 2.0;

              // Havada çok hafif yavaş yörüngesel süzülme
              final leftFloat = Offset(0, math.cos(spin * math.pi * 8) * 4);
              final rightFloat = Offset(0, math.sin(spin * math.pi * 8 + math.pi) * 4);
              
              // Çekim mesafesi aynı kalabilir ama geçişi daha soft
              final pullDist = (magneticPulse * 16.0) + (interactVal * 20.0);
              final totalIntensity = math.min(1.0, (magneticPulse * 0.3) + interactVal);

              return Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _HarmonyPainter(
                        color: widget.color,
                        spin: spin,
                        interact: interactVal,
                        magneticPulse: magneticPulse,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Transform.translate(
                        offset: leftFloat + Offset(pullDist, 0),
                        child: Transform.scale(
                          scale: 1.0 + (totalIntensity * 0.06),
                          child: _buildLeft(totalIntensity),
                        ),
                      ),
                      const SizedBox(width: 30),
                      Transform.translate(
                        offset: rightFloat + Offset(-pullDist, 0),
                        child: Transform.scale(
                          scale: 1.0 + (totalIntensity * 0.06),
                          child: _buildRight(),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          );
        }
      ),
    );
  }

  Widget _buildLeft(double totalIntensity) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.userAvatar != null ? widget.color.withOpacity(0.05) : null,
                border: Border.all(color: widget.color.withOpacity(0.3 + (totalIntensity * 0.3)), width: 1.5 + (totalIntensity * 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.1 + (totalIntensity * 0.2)),
                    blurRadius: 20 + (totalIntensity * 15),
                  ),
                ],
              ),
              child: widget.userAvatar != null
                  ? ClipOval(
                      child: widget.userAvatar!.startsWith('http')
                          ? Image.network(
                              widget.userAvatar!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Image.asset(
                                widget.currentSignData['image'] as String,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              widget.userAvatar!,
                              fit: BoxFit.cover,
                            ),
                    )
                  : ClipOval(
                      child: Image.asset(
                        widget.currentSignData['image'] as String,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            if (widget.userAvatar != null)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1210),
                  shape: BoxShape.circle,
                  border: Border.all(color: widget.color.withOpacity(0.5), width: 1.5),
                ),
                child: ClipOval(
                  child: Image.asset(
                    widget.currentSignData['image'] as String,
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          widget.currentSignData['name'].toString().toUpperCase(),
          style: GoogleFonts.cinzel(
            color: widget.color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRight() {
    return GestureDetector(
      onTap: widget.onPickFriend,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: CustomPaint(
              painter: _DashedCirclePainter(color: widget.color),
              child: Center(
                child: Text(
                  '?',
                  style: GoogleFonts.cinzel(
                    color: widget.color,
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'BURÇ SEÇ',
            style: GoogleFonts.cinzel(
              color: widget.color.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _HarmonyPainter extends CustomPainter {
  final Color color;
  final double spin; 
  final double interact; 
  final double magneticPulse;

  _HarmonyPainter({
    required this.color, 
    required this.spin, 
    required this.interact,
    required this.magneticPulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cX = size.width / 2;
    final cY = 40.0;
    
    final totalIntensity = math.min(1.0, (magneticPulse * 0.3) + interact);

    canvas.save();
    canvas.translate(cX, cY);

    // Ethereal çok ince yıldız tozu arka planı (Daha dingin)
    final numStars = 12;
    for (int i = 0; i < numStars; i++) {
      final angle = (i * math.pi * 2 / numStars) + (spin * math.pi * 2);
      final radius = 20.0 + math.sin(spin * math.pi * 8 + i) * 8.0;
      final starPos = Offset(math.cos(angle) * radius, math.sin(angle) * radius);
      canvas.drawCircle(starPos, 0.8, Paint()..color = color.withOpacity(0.05 + totalIntensity * 0.15));
    }

    // Avatar Yansıma Ağı (Cosmic Web)
    // Avatarların koordinatları tahmini baseDist - pullDist şeklindedir
    final baseDist = size.width * 0.28;
    final pullDist = (magneticPulse * 16.0) + (interact * 20.0);
    // Y Süzülme miktarları State ile uyumlu
    final leftY = math.cos(spin * math.pi * 8) * 4;
    final rightY = math.sin(spin * math.pi * 8 + math.pi) * 4;
    
    final pL = Offset(-baseDist + pullDist, leftY);
    final pR = Offset(baseDist - pullDist, rightY);

    // Ağ Düğümleri (Cosmic Web Nodes) daha sakin yer değiştirir
    final tVal = spin * math.pi * 2;
    
    Offset makeNode(double baseX, double baseY, double freq1, double freq2, double phase) {
      // Çekim gücüne bağlı merkeze daralma (ağ sıkışır)
      final pullX = -baseX * 0.25 * totalIntensity;
      final pullY = -baseY * 0.25 * totalIntensity;
      return Offset(
        baseX + pullX + math.sin(tVal * freq1 + phase) * 6.0,
        baseY + pullY + math.cos(tVal * freq2 + phase) * 6.0,
      );
    }

    // Modern / mistik takımyıldız dizilimi
    final n1 = makeNode(-30, -20, 2.0, 3.0, 0.0);
    final n2 = makeNode(-20,  22, 3.0, 2.0, 1.0);
    final n3 = makeNode(  0,   0, 1.5, 2.5, 2.0); // Kalp/Çekirdek Düğümü
    final n4 = makeNode( 30, -20, 2.5, 1.5, 3.0);
    final n5 = makeNode( 20,  22, 2.0, 3.0, 4.0);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8 + totalIntensity * 1.2
      ..color = color.withOpacity(0.20 + totalIntensity * 0.40);

    void connect(Offset a, Offset b) {
      canvas.drawLine(a, b, linePaint);
    }

    // Taraf bağları
    connect(pL, n1);
    connect(pL, n2);
    connect(pL, n3); // Ana taşıyıcı hat
    
    connect(pR, n3); // Ana taşıyıcı hat
    connect(pR, n4);
    connect(pR, n5);

    // Kendi içindeki örgü ağı (Geometrik Pleiades ağı)
    connect(n1, n3);
    connect(n2, n3);
    connect(n4, n3);
    connect(n5, n3);
    connect(n1, n2); // Sol kanat dış zar
    connect(n4, n5); // Sağ kanat dış zar

    // Düğümlerdeki ışıltılı kozmik yıldızlar
    void drawNodeStar(Offset pos, double baseR) {
      final pr = baseR + totalIntensity * 1.5;
      canvas.drawCircle(pos, pr, Paint()..color = Color.lerp(color, Colors.white, totalIntensity)!);
      
      final glowR = pr * 3.5 + totalIntensity * 8.0;
      canvas.drawCircle(pos, glowR, Paint()
        ..shader = RadialGradient(
          colors: [color.withOpacity(0.4 + totalIntensity * 0.5), color.withOpacity(0)]
        ).createShader(Rect.fromCircle(center: pos, radius: glowR)));
    }

    drawNodeStar(n1, 1.2);
    drawNodeStar(n2, 1.0);
    drawNodeStar(n3, 2.5); // Merkez en parlaktır
    drawNodeStar(n4, 1.2);
    drawNodeStar(n5, 1.0);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HarmonyPainter old) => 
      old.spin != spin || old.interact != interact || old.magneticPulse != magneticPulse;
}

class _MiniNatalChartPainter extends CustomPainter {
  final Color color;
  _MiniNatalChartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    final pOuter = Paint()..color = color.withOpacity(0.6)..style = PaintingStyle.stroke..strokeWidth = 1.0..isAntiAlias = true..strokeCap = StrokeCap.round;
    final pInner = Paint()..color = color.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 0.7..isAntiAlias = true..strokeCap = StrokeCap.round;
    final pTick = Paint()..color = color.withOpacity(0.2)..style = PaintingStyle.stroke..strokeWidth = 0.5..isAntiAlias = true..strokeCap = StrokeCap.round;

    canvas.drawCircle(c, r * 0.95, pOuter);
    canvas.drawCircle(c, r * 0.72, pInner);
    canvas.drawCircle(c, r * 0.45, pInner);

    for (int i = 0; i < 12; i++) {
      final angle = i * math.pi / 6;
      canvas.drawLine(
        Offset(c.dx, c.dy),
        Offset(c.dx + math.cos(angle) * r * 0.45, c.dy + math.sin(angle) * r * 0.45),
        pTick);
      canvas.drawLine(
        Offset(c.dx + math.cos(angle) * r * 0.72, c.dy + math.sin(angle) * r * 0.72),
        Offset(c.dx + math.cos(angle) * r * 0.95, c.dy + math.sin(angle) * r * 0.95),
        pInner);
    }

    final dotPaint = Paint()..color = color.withOpacity(0.8)..isAntiAlias = true;
    final angles = [0.4, 1.2, 2.1, 3.0, 3.8, 4.9, 5.5];
    final dists = [0.56, 0.40, 0.60, 0.52, 0.36, 0.58, 0.46];
    for (int i = 0; i < angles.length; i++) {
      canvas.drawCircle(Offset(c.dx + math.cos(angles[i]) * r * dists[i], c.dy + math.sin(angles[i]) * r * dists[i]), 1.5, dotPaint);
    }

    final aspPaint = Paint()..color = color.withOpacity(0.12)..strokeWidth = 0.4..isAntiAlias = true;
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(c.dx + math.cos(angles[i]) * r * dists[i], c.dy + math.sin(angles[i]) * r * dists[i]),
        Offset(c.dx + math.cos(angles[i+3]) * r * dists[i+3], c.dy + math.sin(angles[i+3]) * r * dists[i+3]),
        aspPaint);
    }

    canvas.drawCircle(c, 1.5, Paint()..color = color..isAntiAlias = true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
