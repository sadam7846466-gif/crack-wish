import 'package:flutter/material.dart';
import '../models/mbti_models.dart';

// Renk paleti (MBTI modülü için)
class MBTIColors {
  static const primaryOrange = Color(0xFFF7941D);
  static const secondaryOrange = Color(0xFFFF6B35);
  static const primaryPurple = Color(0xFF8B5CF6);
  static const primaryCyan = Color(0xFF25F4EE);

  static const backgroundDark = Color(0xFF0A1A1F);
  static const cardBackground = Color(0x08FFFFFF); // 3% white
  static const cardBorder = Color(0x14FFFFFF); // 8% white

  static const resultHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x26F7941D), // 15% orange
      Color(0x1AFF6B35), // 10% secondary orange
    ],
  );

  static const progressGradient =
      LinearGradient(colors: [Color(0xFFF7941D), Color(0xFFFF6B35)]);

  static const axisLeftColor = Color(0xFFF7941D);
  static const axisRightColor = Color(0xFF8B5CF6);

  static const strengthBg = Color(0x2610B981);
  static const strengthBorder = Color(0x4D10B981);
  static const strengthText = Color(0xFF10B981);

  static const weaknessBg = Color(0x26EF4444);
  static const weaknessBorder = Color(0x4DEF4444);
  static const weaknessText = Color(0xFFEF4444);
}

// Animasyon süreleri
class MBTIAnimations {
  static const progressFill = Duration(milliseconds: 500);
  static const progressCurve = Curves.easeOut;

  static const questionTransition = Duration(milliseconds: 300);
  static const questionCurve = Curves.easeInOut;

  static const buttonSelect = Duration(milliseconds: 200);
  static const buttonScale = 1.15;

  static const resultBarFill = Duration(milliseconds: 800);
  static const resultBarStagger = Duration(milliseconds: 100);

  static const introPulse = Duration(seconds: 2);
}

// Likert buton boyutları ve renkleri
const Map<int, double> likertButtonSizes = {
  1: 44.0,
  2: 40.0,
  3: 36.0,
  4: 32.0,
  5: 36.0,
  6: 40.0,
  7: 44.0,
};

const Map<int, Color> likertButtonColors = {
  // Tek renk (beyaz); seçim efekti opacity/border ile
  1: Color(0xFFFFFFFF),
  2: Color(0xFFFFFFFF),
  3: Color(0xFFFFFFFF),
  4: Color(0xFFFFFFFF),
  5: Color(0xFFFFFFFF),
  6: Color(0xFFFFFFFF),
  7: Color(0xFFFFFFFF),
};

const axisEmojis = {
  'EI': {'left': '🎉', 'right': '📚'},
  'SN': {'left': '🔍', 'right': '💭'},
  'TF': {'left': '🧠', 'right': '❤️'},
  'JP': {'left': '📋', 'right': '🌊'},
  'AT': {'left': '😎', 'right': '🌀'},
};

const axisDescriptions = {
  'EI': {
    'title': 'Enerji Kaynağı',
    'left': {'letter': 'E', 'name': 'Dışadönük', 'emoji': '🎉', 'color': 0xFFF7941D},
    'right': {'letter': 'I', 'name': 'İçedönük', 'emoji': '📚', 'color': 0xFF8B5CF6},
    'leftDesc': 'Dışadönük bireyler enerjilerini sosyal etkileşimlerden alırlar...',
    'rightDesc': 'İçedönük bireyler enerjilerini yalnız vakit geçirerek yenilerler...',
  },
  'SN': {
    'title': 'Düşünce Tarzı',
    'left': {'letter': 'S', 'name': 'Gerçekçi', 'emoji': '🔍', 'color': 0xFF10B981},
    'right': {'letter': 'N', 'name': 'Sezgisel', 'emoji': '💭', 'color': 0xFF3B82F6},
    'leftDesc': 'Gerçekçi bireyler somut gerçeklere ve detaylara odaklanırlar...',
    'rightDesc': 'Sezgisel bireyler büyük resme ve gelecek olasılıklarına odaklanırlar...',
  },
  'TF': {
    'title': 'Karar Verme',
    'left': {'letter': 'T', 'name': 'Mantıklı', 'emoji': '🧠', 'color': 0xFFEF4444},
    'right': {'letter': 'F', 'name': 'Duygusal', 'emoji': '❤️', 'color': 0xFFEC4899},
    'leftDesc': 'Mantıklı bireyler kararlarını objektif mantık ve analize dayandırırlar...',
    'rightDesc': 'Duygusal bireyler kararlarını değerlere ve insanların duygularına göre alırlar...',
  },
  'JP': {
    'title': 'Yaşam Tarzı',
    'left': {'letter': 'J', 'name': 'Planlı', 'emoji': '📋', 'color': 0xFFF59E0B},
    'right': {'letter': 'P', 'name': 'Esnek', 'emoji': '🌊', 'color': 0xFF8B5CF6},
    'leftDesc': 'Planlı bireyler organize ve yapılandırılmış bir yaşam tarzını tercih ederler...',
    'rightDesc': 'Esnek bireyler spontan ve uyumlu bir yaşam tarzını tercih ederler...',
  },
  'AT': {
    'title': 'Kimlik',
    'left': {'letter': 'A', 'name': 'Özgüvenli', 'emoji': '😎', 'color': 0xFF10B981},
    'right': {'letter': 'T', 'name': 'Çalkantılı', 'emoji': '🌀', 'color': 0xFFF59E0B},
    'leftDesc': 'Özgüvenli bireyler strese karşı dayanıklıdırlar...',
    'rightDesc': 'Çalkantılı bireyler başarı odaklı ve mükemmeliyetçidirler...',
  },
};

// 60 soru
const List<MBTIQuestion> mbtiQuestions = [
  // EI
  MBTIQuestion(text: "Yeni insanlarla tanışmak bana enerji verir.", axis: "EI", reverse: false),
  MBTIQuestion(text: "Kalabalık ortamlarda uzun süre kaldığımda kendimi yorgun hissederim.", axis: "EI", reverse: true),
  MBTIQuestion(text: "Sosyal etkinliklerde genellikle konuşmayı ben başlatırım.", axis: "EI", reverse: false),
  MBTIQuestion(text: "Hafta sonu evde yalnız vakit geçirmek benim için ideal bir dinlenmedir.", axis: "EI", reverse: true),
  MBTIQuestion(text: "Grup çalışmalarında fikirlerimi rahatça paylaşırım.", axis: "EI", reverse: false),
  MBTIQuestion(text: "Düşüncelerimi başkalarıyla paylaşmadan önce kafamda olgunlaştırmayı tercih ederim.", axis: "EI", reverse: true),
  MBTIQuestion(text: "Partilerde ve toplantılarda genellikle enerjik ve aktifimdir.", axis: "EI", reverse: false),
  MBTIQuestion(text: "Yalnız çalışmak, grup halinde çalışmaktan daha verimli olur benim için.", axis: "EI", reverse: true),
  MBTIQuestion(text: "Tanımadığım insanlarla kolayca sohbet başlatabilirim.", axis: "EI", reverse: false),
  MBTIQuestion(text: "Çok fazla sosyalleşme beni bunaltır.", axis: "EI", reverse: true),
  MBTIQuestion(text: "Arkadaş grubum geniştir ve sürekli yeni insanlar eklerim.", axis: "EI", reverse: false),
  MBTIQuestion(text: "Az ama derin arkadaşlıkları, çok sayıda yüzeysel arkadaşlığa tercih ederim.", axis: "EI", reverse: true),
  // SN
  MBTIQuestion(text: "Somut gerçeklere ve detaylara dikkat ederim.", axis: "SN", reverse: false),
  MBTIQuestion(text: "Gelecekteki olasılıkları düşünmek, şimdiki gerçeklerden daha ilgi çekicidir.", axis: "SN", reverse: true),
  MBTIQuestion(text: "Kanıtlanmış ve denenmiş yöntemleri tercih ederim.", axis: "SN", reverse: false),
  MBTIQuestion(text: "Soyut kavramlar ve teoriler beni cezbeder.", axis: "SN", reverse: true),
  MBTIQuestion(text: "Pratik ve uygulanabilir çözümler üretirim.", axis: "SN", reverse: false),
  MBTIQuestion(text: "Hayal kurmak ve farklı senaryolar düşünmek bana keyif verir.", axis: "SN", reverse: true),
  MBTIQuestion(text: "Detayları gözden kaçırmamaya özen gösteririm.", axis: "SN", reverse: false),
  MBTIQuestion(text: "Büyük resmi görmek, detaylarla uğraşmaktan daha önemlidir.", axis: "SN", reverse: true),
  MBTIQuestion(text: "Beş duyumla algılayabildiğim şeylere güvenirim.", axis: "SN", reverse: false),
  MBTIQuestion(text: "Sezgilerime güvenirim, bazen mantıksal bir açıklaması olmasa bile.", axis: "SN", reverse: true),
  MBTIQuestion(text: "Adım adım, sistematik bir şekilde çalışmayı severim.", axis: "SN", reverse: false),
  MBTIQuestion(text: "Rutin işler beni sıkar, yenilik ve değişiklik ararım.", axis: "SN", reverse: true),
  // TF
  MBTIQuestion(text: "Kararlarımı mantık ve objektif analize dayandırırım.", axis: "TF", reverse: false),
  MBTIQuestion(text: "Karar verirken insanların duygularını öncelikle gözetirim.", axis: "TF", reverse: true),
  MBTIQuestion(text: "Eleştiri yaparken dürüst olmak, nazik olmaktan daha önemlidir.", axis: "TF", reverse: false),
  MBTIQuestion(text: "Uyum ve harmoniyi korumak için bazen kendi görüşümden vazgeçerim.", axis: "TF", reverse: true),
  MBTIQuestion(text: "Problemleri duygusal değil, analitik bir şekilde ele alırım.", axis: "TF", reverse: false),
  MBTIQuestion(text: "Empati kurabilmek, analiz yapabilmekten daha değerlidir.", axis: "TF", reverse: true),
  MBTIQuestion(text: "Adalet ve tutarlılık benim için çok önemlidir.", axis: "TF", reverse: false),
  MBTIQuestion(text: "Her durumun kendine özgü koşulları vardır, katı kurallar her zaman işe yaramaz.", axis: "TF", reverse: true),
  MBTIQuestion(text: "Tartışmalarda duygusal argümanlardan çok mantıksal argümanları ciddiye alırım.", axis: "TF", reverse: false),
  MBTIQuestion(text: "İnsanlara yardım etmek ve onları desteklemek beni tatmin eder.", axis: "TF", reverse: true),
  MBTIQuestion(text: "Zayıflıkları tespit edip eleştirmekte iyiyimdir.", axis: "TF", reverse: false),
  MBTIQuestion(text: "Birinin duygularını incitmektense, gerçeği söylemekten kaçınabilirim.", axis: "TF", reverse: true),
  // JP
  MBTIQuestion(text: "İşlerimi önceden planlamayı ve takvime bağlamayı severim.", axis: "JP", reverse: false),
  MBTIQuestion(text: "Son dakikada karar vermek bana esneklik sağlar.", axis: "JP", reverse: true),
  MBTIQuestion(text: "Belirsizlik beni rahatsız eder, net olmayı tercih ederim.", axis: "JP", reverse: false),
  MBTIQuestion(text: "Planlar değiştiğinde kolayca adapte olurum.", axis: "JP", reverse: true),
  MBTIQuestion(text: "Görevlerimi zamanından önce tamamlamaya çalışırım.", axis: "JP", reverse: false),
  MBTIQuestion(text: "Baskı altında ve son dakikada daha iyi çalışırım.", axis: "JP", reverse: true),
  MBTIQuestion(text: "Düzenli ve organize bir çalışma ortamım vardır.", axis: "JP", reverse: false),
  MBTIQuestion(text: "Fazla planlama yaratıcılığımı kısıtlar.", axis: "JP", reverse: true),
  MBTIQuestion(text: "Bir karar verdikten sonra ona bağlı kalmayı tercih ederim.", axis: "JP", reverse: false),
  MBTIQuestion(text: "Seçeneklerimi açık tutmayı, erken karar vermeye tercih ederim.", axis: "JP", reverse: true),
  MBTIQuestion(text: "Listeler yapmak ve işleri takip etmek benim için doğaldır.", axis: "JP", reverse: false),
  MBTIQuestion(text: "Spontan ve anlık kararlar vermekten keyif alırım.", axis: "JP", reverse: true),
  // AT
  MBTIQuestion(text: "Stresli durumlarda sakin kalabilirim.", axis: "AT", reverse: false),
  MBTIQuestion(text: "Başarısızlık ihtimali beni çok endişelendirir.", axis: "AT", reverse: true),
  MBTIQuestion(text: "Eleştirildiğimde kendime olan güvenim sarsılmaz.", axis: "AT", reverse: false),
  MBTIQuestion(text: "Küçük hatalar bile beni uzun süre rahatsız eder.", axis: "AT", reverse: true),
  MBTIQuestion(text: "Kendimle barışığım ve olduğum kişiyi kabul ediyorum.", axis: "AT", reverse: false),
  MBTIQuestion(text: "Sürekli kendimi başkalarıyla karşılaştırırım.", axis: "AT", reverse: true),
  MBTIQuestion(text: "Başkalarının benim hakkımda ne düşündüğü beni çok etkilemez.", axis: "AT", reverse: false),
  MBTIQuestion(text: "Hata yaptığımda kendimi çok sorgularım.", axis: "AT", reverse: true),
  MBTIQuestion(text: "Zorluklarla karşılaştığımda motivasyonum yüksek kalır.", axis: "AT", reverse: false),
  MBTIQuestion(text: "Gelecekle ilgili sık sık endişelenirim.", axis: "AT", reverse: true),
  MBTIQuestion(text: "Yeteneklerime ve becerilerime güvenirim.", axis: "AT", reverse: false),
  MBTIQuestion(text: "Mükemmel olmadığım için kendimi eleştiririm.", axis: "AT", reverse: true),
];

// 16 tip tam veri (dokümandan)
const Map<String, MBTIType> mbtiTypes = {
  // ANALİSTLER
  'INTJ': MBTIType(
    code: 'INTJ',
    name: 'Stratejist',
    nickname: 'Mimar',
    emoji: '🏗️',
    description:
        'Bağımsız, stratejik düşünen ve vizyoner birisin. Karmaşık sistemleri analiz etme ve uzun vadeli planlar yapma konusunda doğal bir yeteneğin var. Bilgiye ve yetkinliğe büyük değer verirsin. İç dünyan zengin ve sürekli yeni fikirler üretirsin. Hedeflerine ulaşmak için azimle çalışır, engelleri aşmak için yaratıcı çözümler bulursun.',
    negatives:
        'Bazen aşırı mükemmeliyetçiliğin seni ve çevrendekileri yorabilir. Duygusal konularda mesafeli kalma eğilimin, yakın ilişkilerinde zorluk yaratabilir. Başkalarının fikirlerini çok çabuk eleştirebilir, bu da iletişimde sorunlara yol açabilir. Sabırsızlığın ve "her şeyi en iyi ben bilirim" tutumun bazen seni yalnızlaştırabilir.',
    relationships:
        'İlişkilerde derin bağlar kurmayı tercih edersin ama bu bağları kurmak zaman alır. Partnerinden zeka ve bağımsızlık beklersin. Duygularını ifade etmekte zorlanabilirsin ama sadık ve güvenilir bir partnersin. Entelektüel uyum senin için romantik uyum kadar önemli.',
    strengths: ['Stratejik düşünce', 'Bağımsızlık', 'Kararlılık', 'Analitik zeka', 'Vizyon sahibi', 'Problem çözme'],
    weaknesses: ['Aşırı eleştirel', 'Duygusal mesafe', 'Mükemmeliyetçi', 'Sabırsız', 'İnatçı', 'Sosyal becerilerde zayıf'],
    careers: ['Bilim insanı', 'Yazılım mimarı', 'Yatırım stratejisti', 'Yönetim danışmanı', 'Hakim', 'Akademisyen'],
    famous: ['Elon Musk', 'Christopher Nolan', 'Michelle Obama', 'Isaac Newton', 'Nikola Tesla', 'Friedrich Nietzsche'],
    compatible: ['ENFP', 'ENTP', 'INTJ', 'ENTJ'],
    tips: [
      '💡 Duygularını ifade etme pratiği yap - yakınlarınla daha derin bağlar kurabilirsin',
      '🤝 Başkalarının bakış açılarına daha açık ol - her zaman tek bir doğru yoktur',
      '⏸️ Mükemmel olmayı beklemeden harekete geç - "yeterince iyi" bazen en iyisidir',
      '😊 Sosyal etkinliklere katılmaya çalış - bağlantılar kariyer için de önemli',
    ],
  ),
  'INTP': MBTIType(
    code: 'INTP',
    name: 'Mantıkçı',
    nickname: 'Düşünür',
    emoji: '🔬',
    description:
        'Meraklı, yaratıcı ve mantıksal bir zekaya sahipsin. Teorik düşünceyi ve soyut kavramları keşfetmeyi seversin. Sürekli "neden" ve "nasıl" sorularıyla dünyayı anlamaya çalışırsın. Bağımsız düşünce senin için çok değerli. Karmaşık problemleri çözmek seni heyecanlandırır ve bu konuda doğal bir yeteneğin var.',
    negatives:
        'Pratik detayları ve günlük sorumlulukları ihmal edebilirsin. Düşüncelerinde kaybolup sosyal ortamlardan kopabilirsin. Duygusal durumları analiz etmeye çalışman, empati eksikliği olarak algılanabilir. Erteleme eğilimin ve kararsızlığın projelerini tamamlamayı zorlaştırabilir.',
    relationships:
        'İlişkilerde entelektüel uyumu ön planda tutarsın. Duygusal ifade konusunda zorlanabilirsin ama derinlemesine bağlar kurduğunda çok sadık olursun. Partnerine alan tanırsın ve aynısını beklersin. Romantik jestlerde doğal olmayabilirsin ama düşünceli ve mantıklı çözümlerle destek olursun.',
    strengths: ['Analitik zeka', 'Yaratıcılık', 'Objektiflik', 'Bağımsız düşünce', 'Merak', 'Problem çözme'],
    weaknesses: ['Sosyal beceri eksikliği', 'Erteleme', 'Pratik konularda zayıf', 'Kararsızlık', 'Duygusal mesafe', 'Dikkatsizlik'],
    careers: ['Bilim insanı', 'Yazılımcı', 'Matematikçi', 'Filozof', 'Ekonomist', 'Mühendis'],
    famous: ['Albert Einstein', 'Bill Gates', 'Marie Curie', 'Charles Darwin', 'Sokrates', 'Abraham Lincoln'],
    compatible: ['ENTJ', 'ESTJ', 'ENFJ', 'INFJ'],
    tips: [
      '📅 Günlük rutinler oluştur - pratik işleri aksatmamana yardımcı olur',
      '💬 Duygularını adlandırma pratiği yap - "hissediyorum" cümleleri kur',
      '✅ Küçük görevleri hemen bitir - erteleme döngüsünü kır',
      '👥 Sosyal becerilerini geliştir - küçük adımlarla başla',
    ],
  ),
  'ENTJ': MBTIType(
    code: 'ENTJ',
    name: 'Komutan',
    nickname: 'Lider',
    emoji: '👑',
    description:
        'Doğal bir lidersin - kararlı, stratejik ve hedef odaklı. İnsanları organize etme ve büyük projeleri yönetme konusunda doğuştan yeteneklisin. Verimliliğe ve başarıya büyük önem verirsin. Zorluklardan kaçmaz, onları fırsata çevirirsin. Vizyonunu gerçeğe dönüştürmek için gerekli iradeye sahipsin.',
    negatives:
        'Dominant yapın başkalarını bunaltabilir. Sabırsızlığın ve yüksek standartların ekip üyelerini strese sokabilir. Duygusal ihtiyaçları göz ardı edebilirsin. "Sonuç odaklı" yaklaşımın bazen ilişkilere zarar verebilir. Eleştiriye karşı savunmacı olabilirsin.',
    relationships:
        'İlişkilerde de liderlik rolü üstlenme eğilimindesin. Güçlü, bağımsız partnerlerle uyum sağlarsın. Duygusal ifade konusunda zorlanabilirsin ama ilişkine yatırım yapar, onu "başarılı" kılmak için çaba gösterirsin. Partnerinin büyümesini desteklersin.',
    strengths: ['Liderlik', 'Verimlilik', 'Özgüven', 'Stratejik düşünce', 'Kararlılık', 'Organize etme'],
    weaknesses: ['Dominant', 'Sabırsız', 'Duygusal körlük', 'İnatçı', 'Hoşgörüsüz', 'İş odaklı'],
    careers: ['CEO', 'Girişimci', 'Avukat', 'Yönetici', 'Politik lider', 'Askeri komutan'],
    famous: ['Steve Jobs', 'Margaret Thatcher', 'Gordon Ramsay', 'Napoleon Bonaparte', 'Franklin D. Roosevelt', 'Whoopi Goldberg'],
    compatible: ['INTP', 'ISTP', 'ENFP', 'INFP'],
    tips: [
      '👂 Aktif dinleme pratiği yap - başkalarının fikirlerine değer ver',
      '❤️ Duygusal zekânı geliştir - ekip motivasyonu için kritik',
      '⏳ Sabırlı ol - herkes senin hızında çalışamaz',
      '🙏 Delegasyon yaparken güven göster - mikro yönetimden kaçın',
    ],
  ),
  'ENTP': MBTIType(
    code: 'ENTP',
    name: 'Tartışmacı',
    nickname: 'Vizyoner',
    emoji: '💡',
    description:
        'Zeki, meraklı ve yaratıcı bir ruhun var. Yeni fikirleri keşfetmek ve tartışmak seni heyecanlandırır. Geleneksel düşünceyi sorgulamaktan ve sınırları zorlamaktan hoşlanırsın. Hızlı düşünür ve fırsatları görürsün. Entelektüel meydan okumaları seversin ve fikirlerini savunmakta çok iyisin.',
    negatives:
        'Tartışma sevgin bazen insanları yıpratabilir. Bir projeden diğerine atlama eğilimin, işleri yarım bırakmana neden olabilir. Rutin ve detaylardan sıkılırsın. Otoriteye karşı gelme eğilimin profesyonel hayatında sorun yaratabilir. Duygusal hassasiyetleri göz ardı edebilirsin.',
    relationships:
        'İlişkilerde uyarıcı ve eğlenceli bir partnersin. Entelektüel tartışmalardan hoşlanırsın ve partnerinin de meydan okumasını beklersin. Rutinden sıkılabilirsin. Duygusal derinlik konusunda zorlanabilirsin ama ilişkiyi canlı ve heyecanlı tutmakta başarılısın.',
    strengths: ['Yaratıcılık', 'Cesaret', 'Bilgi', 'Hızlı düşünme', 'Uyum yeteneği', 'Karizmatik'],
    weaknesses: ['Tartışmacı', 'Sabırsız', 'Dağınık', 'Otoriteye karşı', 'Tamamlamada zayıf', 'Duyarsız'],
    careers: ['Girişimci', 'Avukat', 'Yaratıcı direktör', 'Danışman', 'Mucit', 'Pazarlamacı'],
    famous: ['Leonardo da Vinci', 'Tom Hanks', 'Sokrates', 'Mark Twain', 'Thomas Edison', 'Weird Al Yankovic'],
    compatible: ['INFJ', 'INTJ', 'ENFJ', 'ENTJ'],
    tips: [
      '🎯 Bir projeye odaklan ve bitir - dağılmaktan kaçın',
      '💕 Tartışmayı her zaman kazanmak zorunda değilsin - ilişkiler daha önemli',
      '📋 Detaylara dikkat et - büyük resim kadar önemli',
      '🧘 Dinlemeyi öğren - her şeye cevap vermek zorunda değilsin',
    ],
  ),
  // DİPLOMATLAR
  'INFJ': MBTIType(
    code: 'INFJ',
    name: 'Savunucu',
    nickname: 'İdealist',
    emoji: '🌟',
    description:
        'Derin düşünceli, idealist ve ilkeli birisin. Başkalarının duygularını ve motivasyonlarını sezgisel olarak anlarsın. Dünyayı daha iyi bir yer yapmak için anlamlı katkılar sunmak istersin. İç dünyan zengin ve karmaşık. Az ama derin ilişkiler kurarsın. Vizyonunu gerçekleştirmek için sessizce ama kararlılıkla çalışırsın.',
    negatives:
        'Aşırı idealistliğin hayal kırıklığına yol açabilir. Başkalarının beklentilerini karşılamaya çalışırken kendini ihmal edebilirsin. Eleştiriye karşı hassassın. Çatışmadan kaçınma eğilimin sorunların birikmesine neden olabilir. Mükemmeliyetçiliğin seni yıpratabilir.',
    relationships:
        'İlişkilerde derin, anlamlı bağlar ararsın. Yüzeysel ilişkilerden kaçınırsın. Partnerine derinden bağlanır ve onun büyümesini desteklersin. Uyumsuzluk hissedersen içine kapanabilirsin. Romantik ve düşünceli bir partnersin.',
    strengths: ['Empati', 'İdealizm', 'Kararlılık', 'Sezgi', 'Yaratıcılık', 'Vizyoner'],
    weaknesses: ['Aşırı hassas', 'Mükemmeliyetçi', 'Tükenmişlik riski', 'Çatışmadan kaçınma', 'Kapalı', 'Aşırı fedakar'],
    careers: ['Psikolog', 'Yazar', 'Danışman', 'Öğretmen', 'Sosyal hizmet uzmanı', 'İnsan kaynakları'],
    famous: ['Martin Luther King Jr.', 'Mother Teresa', 'Nelson Mandela', 'Mahatma Gandhi', 'Carl Jung', 'Lady Gaga'],
    compatible: ['ENFP', 'ENTP', 'INFP', 'ENFJ'],
    tips: [
      '🛡️ Sınır koymayı öğren - "hayır" demek bencillik değil',
      '🌍 Gerçekçi beklentiler belirle - dünya bir günde değişmez',
      '💪 Kendi ihtiyaçlarını da önceliklendir - başkalarına yardım için önce kendin güçlü ol',
      '🗣️ Duygularını bastırmak yerine ifade et',
    ],
  ),
  'INFP': MBTIType(
    code: 'INFP',
    name: 'Arabulucu',
    nickname: 'Şifacı',
    emoji: '🦋',
    description:
        'Hayalperest, empatik ve yaratıcı bir ruha sahipsin. Değerlerine derinden bağlısın ve otantiklik senin için çok önemli. İç dünyan zengin ve hayal gücün güçlü. Başkalarının acılarını hisseder, onlara yardım etmek istersin. Sanat, edebiyat ve anlam arayışı hayatının merkezinde.',
    negatives:
        'Gerçeklikten kopuk kalabilirsin. Duygusal dalgalanmalar yaşayabilirsin. Eleştiriye karşı aşırı hassas olabilirsin. Pratik konularda zorlanabilirsin. Karar vermekte güçlük çekebilirsin. Hayal dünyasında kaybolabilirsin.',
    relationships:
        'İlişkilerde derin duygusal bağ ararsın. Romantik ve düşünceli bir partnersin. Partnerinin değerlerini paylaşmasını beklersin. Çatışmadan kaçınır ama gerektiğinde değerlerini savunursun. İdealleştirme eğilimin olabilir.',
    strengths: ['Yaratıcılık', 'Empati', 'Açık fikirlilik', 'Değerlere bağlılık', 'Otantiklik', 'Derinlik'],
    weaknesses: ['Gerçekçilik eksikliği', 'Aşırı hassas', 'Pratik zorluğu', 'Kararsız', 'Çekingen', 'Kendini ifade edememe'],
    careers: ['Yazar', 'Sanatçı', 'Psikolog', 'Müzisyen', 'Sosyal hizmet uzmanı', 'Grafik tasarımcı'],
    famous: ['William Shakespeare', 'J.R.R. Tolkien', 'Princess Diana', 'John Lennon', 'Edgar Allan Poe', 'Van Gogh'],
    compatible: ['ENFJ', 'ENTJ', 'INFJ', 'ENFP'],
    tips: [
      '📝 Duygularını yazıya dök - kendinle bağlantı kur',
      '🎯 Somut hedefler belirle - hayalleri eyleme dönüştür',
      '💪 Eleştiriyi kişisel algılama - gelişim fırsatı olarak gör',
      '⚡ Harekete geç - mükemmel anı beklemek yerine başla',
    ],
  ),
  'ENFJ': MBTIType(
    code: 'ENFJ',
    name: 'Önder',
    nickname: 'Öğretmen',
    emoji: '🦸',
    description:
        'Karizmatik, empatik ve ilham verici bir lidersin. İnsanları motive etme ve onların potansiyelini açığa çıkarma konusunda doğal bir yeteneğin var. Başkalarının mutluluğu ve gelişimi seni derinden tatmin eder. Güçlü iletişim becerilerinle grupları bir araya getirirsin.',
    negatives:
        'Başkalarının onayına çok bağımlı olabilirsin. Kendi ihtiyaçlarını ihmal edebilirsin. Aşırı fedakarlık tükenmişliğe yol açabilir. Eleştiriye karşı hassassın. Çatışmadan kaçınma eğilimin sorunları büyütebilir.',
    relationships:
        'İlişkilerde verici ve destekleyicisin. Partnerinin mutluluğunu kendi mutluluğunun önüne koyabilirsin. Derin, anlamlı bağlar kurarsın. Romantik ve düşünceli jestler yapmayı seversin. Uyum ve harmoni senin için önemli.',
    strengths: ['İletişim', 'Empati', 'Liderlik', 'Karizmatik', 'Fedakar', 'İlham verici'],
    weaknesses: ['Onay bağımlılığı', 'Aşırı fedakar', 'Hassas', 'Çatışmadan kaçınma', 'Manipülatif olabilir', 'Tükenmişlik'],
    careers: ['Öğretmen', 'Koç', 'İnsan kaynakları', 'Politikacı', 'Danışman', 'Psikolog'],
    famous: ['Barack Obama', 'Oprah Winfrey', 'Maya Angelou', 'Martin Luther King Jr.', 'Ben Affleck', 'Jennifer Lawrence'],
    compatible: ['INTP', 'ISTP', 'INFP', 'ISFP'],
    tips: [
      '🧘 Kendine zaman ayır - başkalarına yardım için önce kendi enerjini koru',
      '🚫 "Hayır" demeyi öğren - her şeye "evet" demek zorunda değilsin',
      '🪞 Başkalarının sorunlarını üstlenme - herkes kendi yolculuğunda',
      '💝 Kendi ihtiyaçların da önemli - onları görmezden gelme',
    ],
  ),
  'ENFP': MBTIType(
    code: 'ENFP',
    name: 'Aktivist',
    nickname: 'Şampiyon',
    emoji: '🎭',
    description:
        'Hevesli, yaratıcı ve sosyal bir ruhun var. Yeni deneyimler, insanlar ve fikirler seni heyecanlandırır. Hayata coşkuyla yaklaşırsın. İnsanlarda iyi olanı görür, onları cesaretlendirirsin. Sıcak ve samimi yapın sayesinde kolayca bağlantı kurarsın.',
    negatives:
        'Bir projeden diğerine atlayabilirsin. Odaklanmakta zorlanabilirsin. Aşırı iyimserliğin gerçeklerle yüzleşmeyi zorlaştırabilir. Duygusal dalgalanmalar yaşayabilirsin. Rutin ve detaylarda sıkılabilirsin.',
    relationships:
        'İlişkilerde tutkulu ve romantiksin. Spontan ve eğlenceli bir partnersin. Partnerinle derin duygusal bağ kurarsın. Sıkıcılıktan nefret edersin. İdealleştirme eğilimin olabilir ama gerçeklerle yüzleştiğinde hayal kırıklığına uğrayabilirsin.',
    strengths: ['Enerji', 'Yaratıcılık', 'İletişim', 'Empati', 'Uyum yeteneği', 'İyimserlik'],
    weaknesses: ['Odak eksikliği', 'Aşırı iyimser', 'Duygusal', 'Dağınık', 'Pratik zorluğu', 'Stres altında zayıf'],
    careers: ['Pazarlamacı', 'Aktör', 'Yazar', 'Girişimci', 'Danışman', 'Psikolog'],
    famous: ['Robin Williams', 'Robert Downey Jr.', 'Walt Disney', 'Ellen DeGeneres', 'Oscar Wilde', 'Will Smith'],
    compatible: ['INTJ', 'INFJ', 'ENTJ', 'ENFJ'],
    tips: [
      '🎯 Bir projeye odaklan - tamamlamadan yenisine başlama',
      '📋 Liste yap ve takip et - dağılmayı önle',
      '🌍 Gerçekçi ol - her şey hayal ettiğin gibi olmayabilir',
      '⏰ Zaman yönetimini geliştir - son dakikaya bırakma',
    ],
  ),
  // KORUYUCULAR
  'ISTJ': MBTIType(
    code: 'ISTJ',
    name: 'Denetçi',
    nickname: 'Görev Adamı',
    emoji: '📋',
    description:
        'Sorumlu, güvenilir ve pratik birisin. Geleneklere ve kurallara değer verirsin. Verdiğin sözleri tutarsın ve beklentileri karşılamak için çok çalışırsın. Sistematik ve organize bir yaklaşımın var. Detaylara dikkat eder, işleri doğru yapmaya özen gösterirsin.',
    negatives:
        'Değişime dirençli olabilirsin. Katı kuralcılığın esnekliği engelleyebilir. Duygusal ifadede zorlanabilirsin. Yeni fikirlere kapalı olabilirsin. Aşırı eleştirel olabilirsin.',
    relationships:
        'İlişkilerde sadık ve güvenilirsin. Taahhütlerini ciddiye alırsın. Duygusal ifade konusunda zorlanabilirsin ama eylemlerin sevgini gösterir. Geleneksel rolleri tercih edebilirsin.',
    strengths: ['Güvenilirlik', 'Pratiklik', 'Dürüstlük', 'Kararlılık', 'Sorumluluk', 'Organize'],
    weaknesses: ['Değişime dirençli', 'Katı', 'Duygusal körlük', 'İnatçı', 'Yargılayıcı', 'Duyarsız'],
    careers: ['Muhasebeci', 'Avukat', 'Askeri personel', 'Polis', 'Yönetici', 'Mühendis'],
    famous: ['George Washington', 'Warren Buffett', 'Angela Merkel', 'Jeff Bezos', 'Natalie Portman', 'Denzel Washington'],
    compatible: ['ESFP', 'ESTP', 'ISFJ', 'ESTJ'],
    tips: [
      '🔄 Değişime açık ol - yeni yaklaşımlar dene',
      '❤️ Duygularını ifade etme pratiği yap',
      '🎨 Yaratıcılığa alan aç - her şey kurallara bağlı değil',
      '😊 Esneklik göster - başkalarının yöntemlerini de kabul et',
    ],
  ),
  'ISFJ': MBTIType(
    code: 'ISFJ',
    name: 'Koruyucu',
    nickname: 'Savunucu',
    emoji: '🛡️',
    description:
        'Sıcak, sorumlu ve dikkatli birisin. Başkalarını düşünür, onların ihtiyaçlarını karşılamak için çaba gösterirsin. Geleneklere ve aile değerlerine bağlısın. Güvenilir ve sadıksın. Arkadan destekleyen, görünmez kahramansın.',
    negatives:
        'Kendi ihtiyaçlarını ihmal edebilirsin. Aşırı fedakarlık seni tüketebilir. Değişime dirençli olabilirsin. Eleştiriye karşı hassassın. Çatışmadan kaçınma eğilimin var.',
    relationships:
        'İlişkilerde verici ve destekleyicisin. Partnerinin ihtiyaçlarını önceliklendirir, onu mutlu etmek için çaba gösterirsin. Sadık ve güvenilirsin. Uyum ve harmoni ararsın.',
    strengths: ['Destek verme', 'Güvenilirlik', 'Sabır', 'Detaylara dikkat', 'Sadakat', 'Pratik yardım'],
    weaknesses: ['Aşırı fedakar', 'Değişime kapalı', 'Hassas', 'Çatışmadan kaçınma', 'Küskün', 'Kendi ihtiyaçlarını ihmal'],
    careers: ['Hemşire', 'Öğretmen', 'Sosyal hizmet uzmanı', 'İnsan kaynakları', 'Kütüphaneci', 'Sekreter'],
    famous: ['Beyoncé', 'Kate Middleton', 'Anne Hathaway', 'Vin Diesel', 'Halle Berry', 'Selena Gomez'],
    compatible: ['ESTP', 'ESFP', 'ISTJ', 'ISFJ'],
    tips: [
      '🛡️ Kendi sınırlarını koru - "hayır" demek önemli',
      '💪 Kendi ihtiyaçlarını da önceliklendir',
      '🗣️ Duygularını açıkça ifade et - birikmesine izin verme',
      '🔄 Değişimi fırsat olarak gör - büyüme şansı',
    ],
  ),
  'ESTJ': MBTIType(
    code: 'ESTJ',
    name: 'Yönetici',
    nickname: 'Denetçi',
    emoji: '📊',
    description:
        'Organize, mantıklı ve kararlı birisin. Düzeni ve yapıyı seversin. Liderlik rollerini üstlenmekte doğalsın. Kuralları takip eder, başkalarından da aynısını beklersin. Verimlilik ve sonuç odaklısın.',
    negatives:
        'Esnek olmayabilirsin. Başkalarının duygularını göz ardı edebilirsin. Dominant yapın insanları bunaltabilir. Değişime dirençli olabilirsin. Çok eleştirel olabilirsin.',
    relationships:
        'İlişkilerde sadık ve güvenilirsin. Geleneksel rolleri tercih edebilirsin. Taahhütlerini ciddiye alırsın. Duygusal ifadede zorlanabilirsin ama eylemlerin sevgini gösterir.',
    strengths: ['Organizasyon', 'Kararlılık', 'Sorumluluk', 'Liderlik', 'Verimlilik', 'Güvenilirlik'],
    weaknesses: ['Esnek değil', 'Dominant', 'Duygusal körlük', 'İnatçı', 'Yargılayıcı', 'Stres altında agresif'],
    careers: ['Yönetici', 'Avukat', 'Hakim', 'Askeri komutan', 'Polis şefi', 'Okul müdürü'],
    famous: ['Judge Judy', 'Frank Sinatra', 'Lyndon B. Johnson', 'Uma Thurman', 'Alec Baldwin', 'Sonia Sotomayor'],
    compatible: ['ISTP', 'ISFP', 'INTP', 'INFP'],
    tips: [
      '👂 Başkalarını dinle - her zaman en iyisini sen bilmeyebilirsin',
      '❤️ Duygusal zekânı geliştir - empati kur',
      '🔄 Esneklik göster - kurallar bazen kırılabilir',
      '😊 Eleştiri yerine teşvik et - insanları motive et',
    ],
  ),
  'ESFJ': MBTIType(
    code: 'ESFJ',
    name: 'Ev Sahibi',
    nickname: 'Danışman',
    emoji: '🤗',
    description:
        'Şefkatli, sosyal ve destekleyici birisin. İlişkilere ve topluluk bağlarına büyük değer verirsin. Başkalarına yardım etmek seni tatmin eder. Uyum ve harmoni için çaba gösterirsin. Sıcak ve karşılayıcı yapın sayesinde insanlar yanında rahat hisseder.',
    negatives:
        'Başkalarının onayına çok bağımlı olabilirsin. Kendi ihtiyaçlarını ihmal edebilirsin. Eleştiriye karşı hassassın. Çatışmadan aşırı kaçınabilirsin. Manipüle edilebilirsin.',
    relationships:
        'İlişkilerde verici ve destekleyicisin. Partnerini mutlu etmek için çaba gösterirsin. Geleneksel değerlere bağlısın. Uyum ve harmoni ararsın. Fedakarlık yapma eğilimindesin.',
    strengths: ['Şefkat', 'Sosyallik', 'Sadakat', 'Pratik yardım', 'Organizasyon', 'İşbirliği'],
    weaknesses: ['Onay bağımlılığı', 'Aşırı fedakar', 'Hassas', 'Esnek değil', 'Manipülasyona açık', 'Çatışmadan kaçınma'],
    careers: ['Hemşire', 'Öğretmen', 'Sosyal hizmet uzmanı', 'İnsan kaynakları', 'Etkinlik planlayıcı', 'Satış'],
    famous: ['Taylor Swift', 'Bill Clinton', 'Jennifer Lopez', 'Ed Sheeran', 'Jennifer Garner', 'Danny Glover'],
    compatible: ['ISFP', 'ISTP', 'INFP', 'INTP'],
    tips: [
      '🛡️ Sınır koymayı öğren - her şeye "evet" demek zorunda değilsin',
      '💪 Kendi ihtiyaçlarını da önceliklendir',
      '🧘 Başkalarının onayı olmadan da kendini değerli hisset',
      '🗣️ Kendi görüşlerini savunmayı öğren',
    ],
  ),
  // KAŞIFLER
  'ISTP': MBTIType(
    code: 'ISTP',
    name: 'Usta',
    nickname: 'Zanaatkar',
    emoji: '🔧',
    description:
        'Pratik, gözlemci ve analitik birisin. Ellerin üzerinde çalışmayı, şeylerin nasıl çalıştığını anlamayı seversin. Sakin ve mantıklı bir yaklaşımın var. Bağımsızlık senin için önemli. Kriz anlarında soğukkanlı kalır, etkili çözümler üretirsin.',
    negatives:
        'Duygusal ifadede zorlanabilirsin. Taahhütlerden kaçınabilirsin. Riskli davranışlara eğilimli olabilirsin. Kuralları çiğneyebilirsin. Duyarsız görünebilirsin.',
    relationships:
        'İlişkilerde bağımsızlık ararsın. Duygusal yakınlık konusunda mesafeli olabilirsin ama sadık bir partnersin. Eylemlerin sevgini gösterir. Spontan ve maceracı bir yapın var.',
    strengths: ['Problem çözme', 'Esneklik', 'Pratiklik', 'Soğukkanlılık', 'Bağımsızlık', 'Mantık'],
    weaknesses: ['Duygusal mesafe', 'Taahhütten kaçınma', 'Riskli davranışlar', 'Duyarsız', 'Öngörülmez', 'İnatçı'],
    careers: ['Mühendis', 'Mekanik', 'Pilot', 'Paramedik', 'Sporcu', 'Dedektif'],
    famous: ['Tom Cruise', 'Clint Eastwood', 'Bruce Lee', 'Michael Jordan', 'Scarlett Johansson', 'Daniel Craig'],
    compatible: ['ESTJ', 'ENTJ', 'ESFJ', 'ENFJ'],
    tips: [
      '❤️ Duygularını ifade etme pratiği yap',
      '🤝 Taahhütlerden kaçınma - bağlanmak zayıflık değil',
      '⚠️ Riskli davranışların sonuçlarını düşün',
      '👥 İlişkilere daha fazla yatırım yap',
    ],
  ),
  'ISFP': MBTIType(
    code: 'ISFP',
    name: 'Maceracı',
    nickname: 'Sanatçı',
    emoji: '🎨',
    description:
        'Sanatsal, hassas ve maceracı bir ruha sahipsin. Anı yaşar, güzelliği takdir edersin. Değerlerine derinden bağlısın. Sessiz ama güçlü bir karakterin var. Doğa ve estetik seni besler. Özgür ruhlusun.',
    negatives:
        'Çatışmadan aşırı kaçınabilirsin. Eleştiriye karşı hassassın. Pratik konularda zorlanabilirsin. Kararsız olabilirsin. Uzun vadeli planlama yapmakta zorlanabilirsin.',
    relationships:
        'İlişkilerde nazik ve destekleyicisin. Partnerine sadık ve şefkatlisin. Uyum ararsın. Duygularını sözcüklerle değil, eylemlerle gösterirsin. Spontan ve romantik anlar yaratırsın.',
    strengths: ['Yaratıcılık', 'Hassasiyet', 'Uyum', 'Pratik sanat', 'Empati', 'Anlık çözümler'],
    weaknesses: ['Çatışmadan kaçınma', 'Hassas', 'Kararsız', 'Uzun vadeli planlama zorluğu', 'Kendini ifade edememe', 'Stres altında zayıf'],
    careers: ['Sanatçı', 'Tasarımcı', 'Müzisyen', 'Veteriner', 'Şef', 'Fotoğrafçı'],
    famous: ['Michael Jackson', 'Britney Spears', 'Rihanna', 'David Bowie', 'Frida Kahlo', 'Jimi Hendrix'],
    compatible: ['ESTJ', 'ESFJ', 'ENTJ', 'ENFJ'],
    tips: [
      '🗣️ Duygularını sözlü ifade et - birikmesine izin verme',
      '📅 Uzun vadeli hedefler belirle ve takip et',
      '💪 Çatışmadan kaçma - sorunları çözmek ilişkiyi güçlendirir',
      '✅ Pratik becerileri geliştir - günlük yaşamı kolaylaştırır',
    ],
  ),
  'ESTP': MBTIType(
    code: 'ESTP',
    name: 'Girişimci',
    nickname: 'Aktivist',
    emoji: '🚀',
    description:
        'Enerjik, akıllı ve algılayıcısın. Risk almayı ve heyecan yaşamayı seversin. Anı yaşar, fırsatları değerlendirirsin. Karizmatik ve ikna edicisin. Pratik zekân güçlü. Harekete geçmekte tereddüt etmezsin.',
    negatives:
        'Uzun vadeli düşünemeyebilirsin. Sabırsız olabilirsin. Başkalarının duygularını göz ardı edebilirsin. Riskli davranışlara eğilimlisin. Kuralları çiğneyebilirsin.',
    relationships:
        'İlişkilerde eğlenceli ve spontansın. Macera ve heyecan ararsın. Rutinden sıkılabilirsin. Duygusal derinlik konusunda zorlanabilirsin ama sadık bir partnersin.',
    strengths: ['Enerji', 'Cesaret', 'Pratiklik', 'İkna', 'Esneklik', 'Problem çözme'],
    weaknesses: ['Sabırsız', 'Riskli', 'Kural tanımaz', 'Duygusal körlük', 'Uzun vadeli düşünememe', 'Duyarsız'],
    careers: ['Girişimci', 'Satışçı', 'Sporcu', 'Paramedik', 'Polis', 'Broker'],
    famous: ['Ernest Hemingway', 'Madonna', 'Jack Nicholson', 'Eddie Murphy', 'Milla Jovovich', 'Samuel L. Jackson'],
    compatible: ['ISFJ', 'ISTJ', 'INFJ', 'INTJ'],
    tips: [
      '⏳ Uzun vadeli sonuçları düşün - anlık tatmin her şey değil',
      '❤️ Empati geliştir - başkalarının duygularını anla',
      '📋 Planlama yapmayı öğren - her şey spontan olmak zorunda değil',
      '⚠️ Riskleri hesapla - düşünmeden atılma',
    ],
  ),
  'ESFP': MBTIType(
    code: 'ESFP',
    name: 'Şovmen',
    nickname: 'Eğlendirici',
    emoji: '🎪',
    description:
        'Neşeli, spontan ve enerjiksin. İnsanları eğlendirmeyi ve onlarla bağlantı kurmayı seversin. Hayatın tadını çıkarırsın. Sıcak ve samimi yapın herkesi etkiler. Anı yaşar, her fırsatı değerlendirirsin.',
    negatives:
        'Uzun vadeli planlama yapmakta zorlanabilirsin. Ciddi konularda odaklanmakta güçlük çekebilirsin. Eleştiriye karşı hassassın. Kolay sıkılabilirsin. Sorumluluktan kaçabilirsin.',
    relationships:
        'İlişkilerde eğlenceli, sıcak ve cömertsin. Partnerini özel hissettirir, onunla kaliteli zaman geçirmekten hoşlanırsın. Spontan ve romantik anlar yaratırsın. Uyum ve eğlence ararsın.',
    strengths: ['Enerji', 'Pratiklik', 'Sosyallik', 'İyimserlik', 'Uyum', 'Eğlenceli'],
    weaknesses: ['Planlama zorluğu', 'Odak eksikliği', 'Hassas', 'Sorumluluktan kaçma', 'Kolay sıkılma', 'Ciddi konularda zayıf'],
    careers: ['Aktör', 'Eğlence sektörü', 'Satış', 'Öğretmen', 'Tur rehberi', 'Etkinlik planlayıcı'],
    famous: ['Marilyn Monroe', 'Elvis Presley', 'Jamie Oliver', 'Adele', 'Cameron Diaz', 'Miley Cyrus'],
    compatible: ['ISTJ', 'ISFJ', 'INTJ', 'INFJ'],
    tips: [
      '📅 Uzun vadeli hedefler belirle ve takip et',
      '💰 Finansal planlama yap - geleceği düşün',
      '📚 Ciddi konularda da gelişmeye çalış',
      '✅ Sorumluluk al - kaçmak yerine yüzleş',
    ],
  ),
};
