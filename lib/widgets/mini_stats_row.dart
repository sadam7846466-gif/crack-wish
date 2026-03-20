import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';
import '../constants/colors.dart';
import '../services/storage_service.dart';
import '../models/cookie_card.dart';
import '../screens/owl_letter_page.dart';

class MiniStatsRow extends StatefulWidget {
  final VoidCallback? onRefresh;
  final ValueChanged<String>? onCookieSelected;
  final ValueChanged<String>? onCookieNavigate;
  final String? selectedCookieId;

  const MiniStatsRow({super.key, this.onRefresh, this.onCookieSelected, this.onCookieNavigate, this.selectedCookieId});

  @override
  State<MiniStatsRow> createState() => _MiniStatsRowState();
}

class _MiniStatsRowState extends State<MiniStatsRow> {
  int _collectionCount = 0; // Sahip olunan kurabiye çeşit sayısı
  int _totalTypes = 20; // Toplam kurabiye çeşit sayısı
  String _pinnedCookieId = 'spring_wreath'; // StorageService'den yüklenen sabitlenmiş kurabiye
  final GlobalKey _rowKey = GlobalKey();
  final GlobalKey _key0 = GlobalKey();
  final GlobalKey _key1 = GlobalKey();
  final GlobalKey _key2 = GlobalKey();

  // Günün teması
  static const _themes = [
    {'emoji': '💕', 'tr': 'Aşk', 'en': 'Love',
     'descTr': 'Bugün kalbinin sesini dinle. Sevgi enerjin yüksek, yakınlarına vakit ayır.',
     'descEn': 'Listen to your heart today. Your love energy is high, spend time with loved ones.'},
    {'emoji': '💰', 'tr': 'Para', 'en': 'Money',
     'descTr': 'Finansal fırsatlar kapında. Küçük adımlar büyük kazançlar getirebilir.',
     'descEn': 'Financial opportunities await. Small steps can lead to big gains.'},
    {'emoji': '🚀', 'tr': 'Kariyer', 'en': 'Career',
     'descTr': 'Bugün kariyerinde yeni kapılar açılabilir. Cesur ol ve fırsatları değerlendir.',
     'descEn': 'New doors may open in your career today. Be bold and seize opportunities.'},
    {'emoji': '🌿', 'tr': 'Sağlık', 'en': 'Health',
     'descTr': 'Bedenine ve ruhuna iyi bak. Bugün kendine vakit ayırman gereken bir gün.',
     'descEn': 'Take care of your body and soul. Today is a day to focus on yourself.'},
  ];

  // Tılsımlar
  static const _talismans = [
    {'emoji': '🧿', 'image': 'assets/images/talismans/talisman_01.webp', 'tr': 'Nazar Boncuğu', 'en': 'Evil Eye Bead',
     'descTr': 'Negatif enerjilere karşı güçlü bir kalkan. Bugün seni kötü gözlerden koruyacak.',
     'descEn': 'A powerful shield against negative energy. It will protect you from the evil eye today.'},
    {'emoji': '🍀', 'image': 'assets/images/talismans/talisman_02.webp', 'tr': 'Dört Yaprak Yonca', 'en': 'Four Leaf Clover',
     'descTr': 'Nadir bulunan bu şans simgesi bugün seninle. Her adımında şans var.',
     'descEn': 'This rare luck symbol is with you today. Luck is in every step you take.'},
    {'emoji': '🧲', 'image': 'assets/images/talismans/talisman_03.webp', 'tr': 'At Nalı', 'en': 'Horseshoe',
     'descTr': 'Şans kapında! Beklenmedik güzel sürprizlere hazır ol.',
     'descEn': 'Luck is at your door! Be ready for unexpected pleasant surprises.'},
    {'emoji': '🤚', 'image': 'assets/images/talismans/talisman_04.webp', 'tr': 'Hamsa Eli', 'en': 'Hand of Fatima',
     'descTr': 'Koruyucu el bugün üzerinde. Kötülüklerden ve nazardan seni uzak tutacak.',
     'descEn': 'The protective hand watches over you today. It shields you from harm and the evil eye.'},
    {'emoji': '🐱', 'image': 'assets/images/talismans/talisman_05.webp', 'tr': 'Maneki Neko', 'en': 'Lucky Cat',
     'descTr': 'Şans kedisi bolluk ve bereket getiriyor. Bugün maddi şansın yüksek.',
     'descEn': 'The lucky cat brings abundance and prosperity. Your financial luck is high today.'},
    {'emoji': '🪲', 'image': 'assets/images/talismans/talisman_06.webp', 'tr': 'Skarab', 'en': 'Scarab Beetle',
     'descTr': 'Yeniden doğuş ve dönüşüm enerjisi seninle. Bugün yeni başlangıçlar için ideal.',
     'descEn': 'The energy of rebirth and transformation is with you. Today is ideal for new beginnings.'},
    {'emoji': '☯️', 'image': 'assets/images/talismans/talisman_07.webp', 'tr': 'Yin Yang', 'en': 'Yin Yang',
     'descTr': 'Denge ve uyum enerjisi çevreni sarıyor. İç huzuru bugün bulacaksın.',
     'descEn': 'Balance and harmony surround you. You will find inner peace today.'},
    {'emoji': '☥', 'image': 'assets/images/talismans/talisman_08.webp', 'tr': 'Ankh', 'en': 'Ankh',
     'descTr': 'Yaşam enerjisi ve sonsuzluk simgesi. Bugün hayat gücün dorukta.',
     'descEn': 'Symbol of life energy and eternity. Your vitality peaks today.'},
    {'emoji': '👁️', 'image': 'assets/images/talismans/talisman_09.webp', 'tr': 'Horus\'un Gözü', 'en': 'Eye of Horus',
     'descTr': 'Bilgelik ve koruma gözü üzerinde. Gerçekleri bugün daha net göreceksin.',
     'descEn': 'The eye of wisdom and protection watches over you. You will see truths more clearly today.'},
    {'emoji': '🐞', 'image': 'assets/images/talismans/talisman_10.webp', 'tr': 'Uğur Böceği', 'en': 'Ladybug',
     'descTr': 'Küçük mucizeler yakınında. Bugün şans seni beklenmedik yerlerde bulacak.',
     'descEn': 'Small miracles are near. Luck will find you in unexpected places today.'},
    {'emoji': '🪨', 'image': 'assets/images/talismans/talisman_11.webp', 'tr': 'Rün Taşları', 'en': 'Rune Stones',
     'descTr': 'Kadim bilgelik sana yol gösteriyor. Bugün sezgilerine güven, işaretleri oku.',
     'descEn': 'Ancient wisdom guides your path. Trust your intuition and read the signs today.'},
    {'emoji': '🌀', 'image': 'assets/images/talismans/talisman_12.webp', 'tr': 'Triskelion', 'en': 'Triskelion',
     'descTr': 'Üçlü sarmal enerjisi ile ilerleme, dönüşüm ve büyüme seninle.',
     'descEn': 'With triple spiral energy, progress, transformation, and growth are with you.'},
    {'emoji': '🔨', 'image': 'assets/images/talismans/talisman_13.webp', 'tr': 'Mjolnir', 'en': 'Mjolnir',
     'descTr': 'Thor\'un çekici güç ve cesaret veriyor. Bugün hiçbir engel seni durduramaz.',
     'descEn': 'Thor\'s hammer grants strength and courage. No obstacle can stop you today.'},
    {'emoji': '🫐', 'image': 'assets/images/talismans/talisman_14.webp', 'tr': 'Nar', 'en': 'Pomegranate',
     'descTr': 'Bereket ve bolluk simgesi. Bugün hayatına güzellikler akacak.',
     'descEn': 'Symbol of fertility and abundance. Beautiful things will flow into your life today.'},
    {'emoji': '🐟', 'image': 'assets/images/talismans/talisman_15.webp', 'tr': 'Altın Balık', 'en': 'Golden Fish',
     'descTr': 'Bolluk ve özgürlük simgesi. Bugün dileklerin suya yazılıp gerçekleşecek.',
     'descEn': 'Symbol of abundance and freedom. Your wishes will come true like words written on water.'},
    {'emoji': '🪷', 'image': 'assets/images/talismans/talisman_16.webp', 'tr': 'Lotus Çiçeği', 'en': 'Lotus Flower',
     'descTr': 'Aydınlanma ve arınma enerjisi seninle. Bugün ruhun çiçek açacak.',
     'descEn': 'Energy of enlightenment and purification is with you. Your soul will bloom today.'},
    {'emoji': '🔥', 'image': 'assets/images/talismans/talisman_17.webp', 'tr': 'Anka Kuşu', 'en': 'Phoenix',
     'descTr': 'Küllerinden yeniden doğuş zamanı. Bugün her zorluğun üstesinden geleceksin.',
     'descEn': 'Time to rise from the ashes. You will overcome every challenge today.'},
    {'emoji': '🦷', 'image': 'assets/images/talismans/talisman_18.webp', 'tr': 'Kurt Dişi', 'en': 'Wolf Fang',
     'descTr': 'Cesaret ve güç tılsımı. Bugün vahşi doğanın enerjisi seninle.',
     'descEn': 'Talisman of courage and strength. The energy of wild nature is with you today.'},
    {'emoji': '💰', 'image': 'assets/images/talismans/talisman_19.webp', 'tr': 'Ekeko', 'en': 'Ekeko',
     'descTr': 'Bolluk ve zenginlik tanrısı yanında. Bugün maddi fırsatlar kapında.',
     'descEn': 'God of abundance walks with you. Material opportunities await at your door today.'},
    {'emoji': '🪲', 'image': 'assets/images/talismans/talisman_20.webp', 'tr': 'Altın Skarab', 'en': 'Golden Scarab',
     'descTr': 'Güneş tanrısının koruyucu sembolü. Bugün ışık ve güç seninle.',
     'descEn': 'Protective symbol of the sun god. Light and power are with you today.'},
    {'emoji': '✊', 'image': 'assets/images/talismans/talisman_21.webp', 'tr': 'Figa Eli', 'en': 'Figa Hand',
     'descTr': 'Kıskançlık ve kötü niyete karşı güçlü koruma. Bugün enerjin korunuyor.',
     'descEn': 'Powerful protection against jealousy and ill will. Your energy is shielded today.'},
    {'emoji': '👜', 'image': 'assets/images/talismans/talisman_22.webp', 'tr': 'Tılsım Kesesi', 'en': 'Mojo Bag',
     'descTr': 'Büyülü otların ve taşların gücü seninle. Bugün gizli güçler seni destekliyor.',
     'descEn': 'The power of magical herbs and stones is with you. Hidden forces support you today.'},
    {'emoji': '📜', 'image': 'assets/images/talismans/talisman_23.webp', 'tr': 'Muska', 'en': 'Amulet Scroll',
     'descTr': 'Kadim duaların koruması altındasın. Bugün manevi kalkanın çok güçlü.',
     'descEn': 'You are under the protection of ancient prayers. Your spiritual shield is very strong today.'},
    {'emoji': '☀️', 'image': 'assets/images/talismans/talisman_24.webp', 'tr': 'Aztek Güneş Taşı', 'en': 'Aztec Sun Stone',
     'descTr': 'Kozmik güçlerin rehberliğinde yeni bir döngü başlıyor. Büyük değişimler kapıda.',
     'descEn': 'A new cycle begins under cosmic guidance. Great changes are at your doorstep.'},
    {'emoji': '🗿', 'image': 'assets/images/talismans/talisman_25.webp', 'tr': 'Totem Direği', 'en': 'Totem Pole',
     'descTr': 'Atalarının bilgeliği seni yönlendiriyor. Bugün ruh rehberlerin aktif.',
     'descEn': 'The wisdom of your ancestors guides you. Your spirit guides are active today.'},
    {'emoji': '🐈', 'image': 'assets/images/talismans/talisman_26.webp', 'tr': 'Kedi Gözü Taşı', 'en': 'Cat\'s Eye Stone',
     'descTr': 'Sezgi ve öngörü gücü artıyor. Bugün tehlikelerden korunacaksın.',
     'descEn': 'Intuition and foresight are growing stronger. You will be protected from dangers today.'},
    {'emoji': '🪺', 'image': 'assets/images/talismans/talisman_27.webp', 'tr': 'Eriço Gülü', 'en': 'Rose of Jericho',
     'descTr': 'Diriliş ve yenilenme bitkisi seninle. Zor dönemler sona eriyor.',
     'descEn': 'The resurrection plant is with you. Difficult times are coming to an end.'},
    {'emoji': '💎', 'image': 'assets/images/talismans/talisman_28.webp', 'tr': 'Ametist Kristal', 'en': 'Amethyst Crystal',
     'descTr': 'Huzur ve dengeleme kristali. Bugün stresten arınacak, berraklık bulacaksın.',
     'descEn': 'Crystal of peace and balance. You will release stress and find clarity today.'},
    {'emoji': '🌞', 'image': 'assets/images/talismans/talisman_29.webp', 'tr': 'Güneş Çarkı', 'en': 'Sun Cross',
     'descTr': 'Güneşin koruyucu gücü seninle. Bugün yolun aydınlık, enerjin yüksek.',
     'descEn': 'The protective power of the sun is with you. Your path is bright and energy high today.'},
    {'emoji': '🏺', 'image': 'assets/images/talismans/talisman_30.webp', 'tr': 'Bereket Boynuzu', 'en': 'Cornucopia',
     'descTr': 'Bolluk ve bereket boynuzu taşıyor. Bugün hayatın her alanında zenginlik var.',
     'descEn': 'The horn of plenty overflows. There is richness in every area of your life today.'},
    {'emoji': '🦚', 'image': 'assets/images/talismans/talisman_31.webp', 'tr': 'Tavus Kuşu Tüyü', 'en': 'Peacock Feather',
     'descTr': 'Güzellik, koruma ve uyanış tüyü. Bugün göz alıcı bir enerji yayıyorsun.',
     'descEn': 'Feather of beauty, protection, and awakening. You radiate a dazzling energy today.'},
    {'emoji': '☘️', 'image': 'assets/images/talismans/talisman_32.webp', 'tr': 'Kelt Düğümü', 'en': 'Celtic Knot',
     'descTr': 'Sonsuzluk ve bağlılık simgesi. Bugün ilişkilerin ve bağların güçleniyor.',
     'descEn': 'Symbol of eternity and devotion. Your relationships and bonds grow stronger today.'},
    {'emoji': '🐘', 'image': 'assets/images/talismans/talisman_33.webp', 'tr': 'Altın Fil', 'en': 'Golden Elephant',
     'descTr': 'Bilgelik, güç ve şans getiren fil. Bugün engeller önünden kalkacak.',
     'descEn': 'The elephant brings wisdom, strength, and luck. Obstacles will be removed from your path today.'},
    {'emoji': '🐴', 'image': 'assets/images/talismans/talisman_34.webp', 'tr': 'Dala Atı', 'en': 'Dala Horse',
     'descTr': 'İskandinav şans sembolü. Bugün güç, cesaret ve sadakat enerjisi seninle.',
     'descEn': 'Scandinavian luck symbol. Energy of strength, courage, and loyalty is with you today.'},
    {'emoji': '🐉', 'image': 'assets/images/talismans/talisman_35.webp', 'tr': 'Pixiu', 'en': 'Pixiu Dragon',
     'descTr': 'Zenginlik koruyucusu ve servet çeken ejderha. Bugün finansal şansın parlak.',
     'descEn': 'Wealth guardian and fortune-attracting dragon. Your financial luck shines bright today.'},
    {'emoji': '✡️', 'image': 'assets/images/talismans/talisman_36.webp', 'tr': 'Yaşam Çiçeği', 'en': 'Flower of Life',
     'descTr': 'Kutsal geometrinin gücü seninle. Evrenin sırları bugün sana açılıyor.',
     'descEn': 'The power of sacred geometry is with you. The secrets of the universe open to you today.'},
    {'emoji': '🌶️', 'image': 'assets/images/talismans/talisman_37.webp', 'tr': 'Cornicello', 'en': 'Cornicello',
     'descTr': 'İtalyan şans boynuzu kötü gözden koruyor. Bugün negatif enerji sana yaklaşamaz.',
     'descEn': 'Italian lucky horn protects from evil eye. Negative energy cannot reach you today.'},
    {'emoji': '🎀', 'image': 'assets/images/talismans/talisman_38.webp', 'tr': 'Çin Düğümü', 'en': 'Chinese Knot',
     'descTr': 'Şans ve uzun ömür düğümü. Bugün hayatında güzel bağlar kuracaksın.',
     'descEn': 'Knot of luck and longevity. You will form beautiful connections in your life today.'},
    {'emoji': '⛩️', 'image': 'assets/images/talismans/talisman_39.webp', 'tr': 'Omamori', 'en': 'Omamori',
     'descTr': 'Japon koruma muskası. Bugün kutsal enerji seni her yerde koruyacak.',
     'descEn': 'Japanese protection charm. Sacred energy will protect you everywhere today.'},
    {'emoji': '⚕️', 'image': 'assets/images/talismans/talisman_40.webp', 'tr': 'Hermes Asası', 'en': 'Caduceus',
     'descTr': 'Şifa ve denge asası seninle. Bugün sağlık enerjin güçlü, iyileşme hızlı.',
     'descEn': 'The staff of healing and balance is with you. Your health energy is strong today.'},
    {'emoji': '🌰', 'image': 'assets/images/talismans/talisman_41.webp', 'tr': 'Altın Meşe Palamudu', 'en': 'Golden Acorn',
     'descTr': 'Küçük başlangıçlardan büyük başarılar doğacak. Bugün attığın tohumlar meyve verecek.',
     'descEn': 'Great successes will grow from small beginnings. Seeds you plant today will bear fruit.'},
    {'emoji': '🐍', 'image': 'assets/images/talismans/talisman_42.webp', 'tr': 'Ouroboros', 'en': 'Ouroboros',
     'descTr': 'Sonsuz döngü ve yenilenme sembolü. Bugün bir döngü kapanıp yenisi açılıyor.',
     'descEn': 'Symbol of infinite cycle and renewal. One cycle closes and another opens today.'},
    {'emoji': '🦎', 'image': 'assets/images/talismans/talisman_43.webp', 'tr': 'Şans Kertenkelesi', 'en': 'Lucky Lizard',
     'descTr': 'Adaptasyon ve dönüşüm gücü. Bugün her duruma uyum sağlayacaksın.',
     'descEn': 'Power of adaptation and transformation. You will adapt to any situation today.'},
    {'emoji': '🎎', 'image': 'assets/images/talismans/talisman_44.webp', 'tr': 'Daruma', 'en': 'Daruma',
     'descTr': 'Azim ve kararlılık bebeği. Bugün hedeflerine ulaşmak için güçlü bir irade var.',
     'descEn': 'Doll of perseverance and determination. Strong willpower to reach your goals today.'},
    {'emoji': '🧭', 'image': 'assets/images/talismans/talisman_45.webp', 'tr': 'Vegvísir', 'en': 'Vegvísir',
     'descTr': 'Viking pusula tılsımı yolunu aydınlatıyor. Bugün kaybolmayacak, doğru yolu bulacaksın.',
     'descEn': 'Viking compass talisman lights your way. You will not be lost and will find the right path today.'},
    {'emoji': '🕸️', 'image': 'assets/images/talismans/talisman_46.webp', 'tr': 'Düş Kapanı', 'en': 'Dreamcatcher',
     'descTr': 'Kötü rüyaları filtreler, iyi enerjileri toplar. Bugün huzurlu bir gece seni bekliyor.',
     'descEn': 'Filters bad dreams and collects good energy. A peaceful night awaits you today.'},
    {'emoji': '🗡️', 'image': 'assets/images/talismans/talisman_47.webp', 'tr': 'Tumi', 'en': 'Tumi',
     'descTr': 'İnka kutsal bıçağı güç ve koruma sağlıyor. Bugün cesaret ve kararlılık seninle.',
     'descEn': 'Inca sacred blade provides power and protection. Courage and determination are with you today.'},
  ];

  late int _themeIndex;
  late int _talismanIndex;

  @override
  void initState() {
    super.initState();
    _pickDailyValues();
    _loadStats();
    _loadPinnedCookie();
  }

  Future<void> _loadPinnedCookie() async {
    final pinned = await StorageService.getSelectedCookie();
    if (mounted) {
      setState(() => _pinnedCookieId = pinned);
    }
  }

  @override
  void didUpdateWidget(MiniStatsRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onRefresh != null && widget.onRefresh != oldWidget.onRefresh) {
      _loadStats();
    }
  }

  void _pickDailyValues() {
    final now = DateTime.now();
    final daySeed = now.year * 10000 + now.month * 100 + now.day;
    final rng = Random(daySeed);
    _themeIndex = rng.nextInt(_themes.length);
    _talismanIndex = Random().nextInt(_talismans.length);
  }

  Future<void> _loadStats() async {
    final collection = await StorageService.getCookieCollection();
    final owned = collection.where((c) => c.firstObtainedDate != null).length;
    if (mounted) {
      setState(() {
        _collectionCount = owned;
        _totalTypes = collection.length;
      });
    }
  }

  Widget _themeIconWidget(int index) {
    switch (index) {
      case 0:
        return const Icon(Icons.favorite_rounded, size: 16, color: Colors.white);
      case 1:
        return const Icon(Icons.savings_rounded, size: 16, color: Colors.white);
      case 2:
        return const Icon(Icons.rocket_launch_rounded, size: 16, color: Colors.white);
      case 3:
      default:
        return const Icon(Icons.spa_rounded, size: 16, color: Colors.white);
    }
  }

  void _openOverlay(int index) {
    HapticFeedback.lightImpact();

    // Tıklanan kutunun ekran konumunu bul
    final keys = [_key0, _key1, _key2];
    final btnBox = keys[index].currentContext?.findRenderObject() as RenderBox?;
    if (btnBox == null) return;
    final btnPos = btnBox.localToGlobal(Offset.zero);
    final btnSize = btnBox.size;
    // Satırın konumunu da al (panel genişliği için)
    final rowBox = _rowKey.currentContext?.findRenderObject() as RenderBox?;
    if (rowBox == null) return;
    final rowPos = rowBox.localToGlobal(Offset.zero);
    final rowSize = rowBox.size;
    // Panel kutuların hemen altından başlasın
    final topY = rowPos.dy + rowSize.height + 8;
    // Butonun merkez X'i
    final btnCenterX = btnPos.dx + btnSize.width / 2;

    final l10n = AppLocalizations.of(context)!;
    final isTr = l10n.localeName == 'tr';

    String emoji, title, desc;
    String? imagePath;
    if (index == 0) {
      final t = _themes[_themeIndex];
      emoji = t['emoji']!;
      title = isTr ? t['tr']! : t['en']!;
      desc = isTr ? t['descTr']! : t['descEn']!;
    } else if (index == 1) {
      // Koleksiyon overlay'ı — özel kurabiye grid göster
      Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false,
          barrierDismissible: false,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (context, _, __) => _CollectionOverlay(
            topY: topY,
            btnCenterX: btnCenterX,
            selectedCookieId: widget.selectedCookieId,
            onCookieSelected: (cookieId) {
              widget.onCookieSelected?.call(cookieId);
              setState(() => _pinnedCookieId = cookieId);
            },
            onCookieNavigate: widget.onCookieNavigate,
          ),
        ),
      );
      return;
    } else {
      final t = _talismans[_talismanIndex];
      emoji = t['emoji']!;
      imagePath = t['image'];
      title = isTr ? t['tr']! : t['en']!;
      desc = isTr ? t['descTr']! : t['descEn']!;
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, _, __) => _StatOverlay(
          topY: topY,
          btnCenterX: btnCenterX,
          emoji: emoji,
          imagePath: imagePath,
          title: title,
          description: desc,
        ),
      ),
    );
  }

  static const Map<String, String> _cookieImageMap = {
    'spring_wreath': 'assets/images/cookies/spring_wreath.webp',
    'lucky_clover': 'assets/images/cookies/lucky_clover.webp',
    'royal_hearts': 'assets/images/cookies/royal_hearts.webp',
    'evil_eye': 'assets/images/cookies/evil_eye.webp',
    'pizza_party': 'assets/images/cookies/pizza_party.webp',
    'sakura_bloom': 'assets/images/cookies/sakura_bloom.webp',
    'blue_porcelain': 'assets/images/cookies/blue_porcelain.webp',
    'pink_blossom': 'assets/images/cookies/pink_blossom.webp',
    'fortune_cat': 'assets/images/cookies/fortune_cat.webp',
    'wildflower': 'assets/images/cookies/wildflower.webp',
    'cupid_ribbon': 'assets/images/cookies/cupid_ribbon.webp',
    'panda_bamboo': 'assets/images/cookies/panda_bamboo.webp',
    'ramadan_cute': 'assets/images/cookies/ramadan_cute.webp',
    'enchanted_forest': 'assets/images/cookies/enchanted_forest.webp',
    'golden_arabesque': 'assets/images/cookies/golden_arabesque.webp',
    'midnight_mosaic': 'assets/images/cookies/midnight_mosaic.webp',
    'pearl_lace': 'assets/images/cookies/pearl_lace.webp',
    'golden_sakura': 'assets/images/cookies/golden_sakura.webp',
    'dragon_phoenix': 'assets/images/cookies/dragon_phoenix.webp',
    'gold_beasts': 'assets/images/cookies/gold_beasts.webp',
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = _themes[_themeIndex];
    final talisman = _talismans[_talismanIndex];

    // Sabitlenmiş kurabiyenin görseli (swipe ile değişmez)
    final cookieImagePath = _cookieImageMap[_pinnedCookieId];
    Widget? cookieIconWidget;
    if (cookieImagePath != null) {
      cookieIconWidget = Image.asset(
        cookieImagePath,
        width: 22,
        height: 22,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Text('🥠', style: TextStyle(fontSize: 20, fontFamilyFallback: ['Apple Color Emoji'])),
      );
    }

    // Tılsım görseli
    final talismanImagePath = talisman['image'];
    Widget? talismanIconWidget;
    if (talismanImagePath != null) {
      talismanIconWidget = ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          talismanImagePath,
          width: 26,
          height: 26,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Text(talisman['emoji']!, style: const TextStyle(fontSize: 16, fontFamilyFallback: ['Apple Color Emoji'])),
        ),
      );
    }

    return Row(
      key: _rowKey,
      children: [
        Expanded(
          child: _MiniStatCard(
            key: _key0,
            icon: theme['emoji']!,
            iconWidget: _themeIconWidget(_themeIndex),
            label: l10n.statTheme,
            onTap: () => _openOverlay(0),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MiniStatCard(
            key: _key1,
            icon: '🥠',
            iconWidget: cookieIconWidget,
            label: l10n.statCollection,
            onTap: () => _openOverlay(1),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MiniStatCard(
            key: _key2,
            icon: talisman['emoji']!,
            iconWidget: talismanIconWidget,
            label: l10n.statTalisman,
            onTap: () => _openOverlay(2),
          ),
        ),
      ],
    );
  }
}

// ── Overlay sayfası (baykuş butonu gibi) ──
class _StatOverlay extends StatefulWidget {
  final double topY;
  final double btnCenterX;
  final String emoji;
  final String? imagePath;
  final String title;
  final String description;

  const _StatOverlay({
    required this.topY,
    required this.btnCenterX,
    required this.emoji,
    this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  State<_StatOverlay> createState() => _StatOverlayState();
}

class _StatOverlayState extends State<_StatOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool _closing = false;

  void _close() {
    if (_closing) return;
    _closing = true;
    _ctrl.reverse().then((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  void _closeImmediate() {
    if (_closing) return;
    _closing = true;
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {},
      onPointerMove: (_) => _closeImmediate(),
      onPointerUp: (_) => _close(),
      child: Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) {
            final screenW = MediaQuery.of(context).size.width;
            final panelW = screenW - 32;
            final alignX = ((widget.btnCenterX - 16) / panelW) * 2 - 1;
            final clampedAlignX = alignX.clamp(-1.0, 1.0);

            return Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.35 * _fadeAnim.value),
                  ),
                ),
                Positioned(
                  top: widget.topY + 32,
                  left: 16,
                  right: 16,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: ScaleTransition(
                        scale: _scaleAnim,
                        alignment: Alignment(clampedAlignX, -1.0),
                        child: _buildPanel(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPanel() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18), // 40 → 18 (performans)
        child: GlassContainer(
          useOwnLayer: true,
          height: 245,
          settings: const LiquidGlassSettings(
            thickness: 18,
            blur: 2,
            glassColor: Colors.transparent,
            chromaticAberration: 0.1,
            lightIntensity: 0.7,
            ambientStrength: 0.6,
            refractiveIndex: 1.2,
            saturation: 1.0,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(26, 14, 26, 28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.14),
                  Colors.white.withOpacity(0.06),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.35),
                width: 0.8,
              ),
            ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.imagePath != null)
                SizedBox(
                  width: 84,
                  height: 84,
                  child: Image.asset(
                    widget.imagePath!,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Text(widget.emoji, style: const TextStyle(fontSize: 40, fontFamilyFallback: ['Apple Color Emoji'])),
                  ),
                )
              else
                Text(widget.emoji, style: const TextStyle(fontSize: 44, fontFamilyFallback: ['Apple Color Emoji'])),
              const SizedBox(height: 12),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                widget.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

// ── Basit stat kartı ──
class _MiniStatCard extends StatefulWidget {
  final String icon;
  final Widget? iconWidget;
  final String? value;
  final String label;
  final VoidCallback? onTap;

  const _MiniStatCard({
    super.key,
    required this.icon,
    this.iconWidget,
    this.value,
    required this.label,
    this.onTap,
  });

  @override
  State<_MiniStatCard> createState() => _MiniStatCardState();
}

class _MiniStatCardState extends State<_MiniStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 250),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.value != null;

    return GestureDetector(
      onTapDown: (_) => _scaleCtrl.forward(),
      onTapUp: (_) {
        Future.delayed(const Duration(milliseconds: 80), () {
          _scaleCtrl.reverse();
          widget.onTap?.call();
        });
      },
      onTapCancel: () => _scaleCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: GlassContainer(
          useOwnLayer: true,
          height: 42,
          settings: const LiquidGlassSettings(
            thickness: 14,
            blur: 2,
            glassColor: Colors.transparent,
            chromaticAberration: 0.08,
            lightIntensity: 0.6,
            ambientStrength: 0.5,
            refractiveIndex: 1.15,
            saturation: 1.0,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.14),
                  Colors.white.withOpacity(0.06),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.30),
                width: 0.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: hasValue
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Center(
                            child: widget.iconWidget ?? Text(widget.icon, style: const TextStyle(fontSize: 16, fontFamilyFallback: ['Apple Color Emoji'])),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.value!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                widget.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Center(
                            child: widget.iconWidget ?? Text(widget.icon, style: const TextStyle(fontSize: 16, fontFamilyFallback: ['Apple Color Emoji'])),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            widget.label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
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
}

// ── Koleksiyon Overlay — sahip olunan kurabiyeleri gösterir ──
class _CollectionOverlay extends StatefulWidget {
  final double topY;
  final double btnCenterX;
  final String? selectedCookieId;
  final ValueChanged<String>? onCookieSelected;
  final ValueChanged<String>? onCookieNavigate;

  const _CollectionOverlay({
    required this.topY,
    required this.btnCenterX,
    this.selectedCookieId,
    this.onCookieSelected,
    this.onCookieNavigate,
  });

  @override
  State<_CollectionOverlay> createState() => _CollectionOverlayState();
}

class _CollectionOverlayState extends State<_CollectionOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<Offset> _slideAnim;

  List<CookieCard> _ownedCookies = [];
  bool _loading = true;

  static const Map<String, String> _cookieImageMap = {
    'spring_wreath': 'assets/images/cookies/spring_wreath.webp',
    'lucky_clover': 'assets/images/cookies/lucky_clover.webp',
    'royal_hearts': 'assets/images/cookies/royal_hearts.webp',
    'evil_eye': 'assets/images/cookies/evil_eye.webp',
    'pizza_party': 'assets/images/cookies/pizza_party.webp',
    'sakura_bloom': 'assets/images/cookies/sakura_bloom.webp',
    'blue_porcelain': 'assets/images/cookies/blue_porcelain.webp',
    'pink_blossom': 'assets/images/cookies/pink_blossom.webp',
    'fortune_cat': 'assets/images/cookies/fortune_cat.webp',
    'wildflower': 'assets/images/cookies/wildflower.webp',
    'cupid_ribbon': 'assets/images/cookies/cupid_ribbon.webp',
    'panda_bamboo': 'assets/images/cookies/panda_bamboo.webp',
    'ramadan_cute': 'assets/images/cookies/ramadan_cute.webp',
    'enchanted_forest': 'assets/images/cookies/enchanted_forest.webp',
    'golden_arabesque': 'assets/images/cookies/golden_arabesque.webp',
    'midnight_mosaic': 'assets/images/cookies/midnight_mosaic.webp',
    'pearl_lace': 'assets/images/cookies/pearl_lace.webp',
    'golden_sakura': 'assets/images/cookies/golden_sakura.webp',
    'dragon_phoenix': 'assets/images/cookies/dragon_phoenix.webp',
    'gold_beasts': 'assets/images/cookies/gold_beasts.webp',
  };

  static const Set<String> _paidCookieIds = {
    'golden_arabesque',
    'midnight_mosaic',
    'pearl_lace',
    'golden_sakura',
    'dragon_phoenix',
    'gold_beasts',
  };

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero)
        .animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _ctrl.forward();
    _loadOwnedCookies();
  }

  Future<void> _loadOwnedCookies() async {
    final collection = await StorageService.getCookieCollection();
    final owned =
        collection.where((c) => c.firstObtainedDate != null).toList();
    // Çok kırılandan aza doğru sırala
    owned.sort((a, b) => b.countObtained.compareTo(a.countObtained));
    if (mounted) {
      setState(() {
        _ownedCookies = owned;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool _closing = false;
  OverlayEntry? _contextMenuOverlay;
  bool _menuActive = false;
  final ValueNotifier<int> _hoveredIndex = ValueNotifier(-1); // -1: yok, 0: sabitle, 1: gönder
  double _menuLeft = 0;
  double _menuTop = 0;
  static const double _menuW = 150.0;
  static const double _menuH = 36.0;
  String? _contextCookieId;

  void _close() {
    if (_closing) return;
    _closing = true;
    _removeContextMenu();
    _ctrl.reverse().then((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  void _closeImmediate() {
    if (_closing) return;
    _closing = true;
    _removeContextMenu();
    if (mounted) Navigator.pop(context);
  }

  void _removeContextMenu() {
    _contextMenuOverlay?.remove();
    _contextMenuOverlay = null;
    _hoveredIndex.value = -1;
    _contextCookieId = null;
    if (_menuActive) {
      _menuActive = false;
      if (mounted) setState(() {});
    }
  }

  int _hitTestMenu(Offset globalPos) {
    final dx = globalPos.dx;
    final dy = globalPos.dy;
    if (dy < _menuTop || dy > _menuTop + _menuH) return -1;
    if (dx < _menuLeft || dx > _menuLeft + _menuW) return -1;
    // Sol yarı = Sabitle (0), Sağ yarı = Gönder (1)
    if (dx < _menuLeft + _menuW / 2) return 0;
    return 1;
  }

  void _onMenuMoveUpdate(Offset globalPos) {
    _hoveredIndex.value = _hitTestMenu(globalPos);
  }

  void _onMenuRelease(Offset globalPos, String cookieId, bool isTr) {
    final hit = _hitTestMenu(globalPos);
    _removeContextMenu();

    if (hit == 0) {
      // Sabitle
      HapticFeedback.selectionClick();
      widget.onCookieSelected?.call(cookieId);
      _close();
    } else if (hit == 1) {
      // Gönder — koleksiyon panelini kapat, mektup panelini aç
      HapticFeedback.selectionClick();
      final nav = Navigator.of(context);
      final screen = MediaQuery.of(context).size;
      _close();
      Future.delayed(const Duration(milliseconds: 400), () {
        final rect = Rect.fromCenter(
          center: Offset(screen.width / 2, screen.height / 2),
          width: 40,
          height: 40,
        );
        nav.push(
          PageRouteBuilder(
            opaque: false,
            barrierDismissible: false,
            pageBuilder: (context, _, __) => OwlLetterPage(buttonRect: rect),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      });
    }
  }

  void _showCookieContextMenu(
    BuildContext ctx,
    String cookieId,
    String cookieName,
    String? imagePath,
    bool isTr,
    Offset globalPosition,
  ) {
    _removeContextMenu();
    _contextCookieId = cookieId;

    final overlay = Overlay.of(ctx);
    final screenSize = MediaQuery.of(ctx).size;

    _menuLeft = globalPosition.dx - _menuW / 2;
    _menuTop = globalPosition.dy - 56;

    if (_menuLeft < 8) _menuLeft = 8;
    if (_menuLeft + _menuW > screenSize.width - 8) _menuLeft = screenSize.width - _menuW - 8;
    if (_menuTop < 40) _menuTop = globalPosition.dy + 20;

    _contextMenuOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: _menuLeft,
        top: _menuTop,
        child: Material(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18), // 40 → 18 (performans)
              child: Container(
                width: _menuW,
                height: _menuH,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ValueListenableBuilder<int>(
                  valueListenable: _hoveredIndex,
                  builder: (context, hovered, _) {
                    return Row(
                      children: [
                        // Sabitle
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: hovered == 0
                                  ? Colors.white.withOpacity(0.15)
                                  : Colors.transparent,
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(12),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              isTr ? '📌 Sabitle' : '📌 Pin',
                              style: TextStyle(
                                color: Colors.white.withOpacity(hovered == 0 ? 1.0 : 0.9),
                                fontSize: 11,
                                fontWeight: hovered == 0 ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 0.5,
                          height: 20,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        // Gönder
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: hovered == 1
                                  ? Colors.white.withOpacity(0.15)
                                  : Colors.transparent,
                              borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(12),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              isTr ? '✉️ Gönder' : '✉️ Send',
                              style: TextStyle(
                                color: Colors.white.withOpacity(hovered == 1 ? 1.0 : 0.9),
                                fontSize: 11,
                                fontWeight: hovered == 1 ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_contextMenuOverlay!);
    _menuActive = true;
    setState(() {});
  }

  String _cookieNameLocalized(String id, String fallback, String languageCode) {
    const namesTr = {
      'spring_wreath': 'Bahar Çelengi',
      'lucky_clover': 'Şanslı Yonca',
      'royal_hearts': 'Kraliyet Kalpleri',
      'evil_eye': 'Nazar',
      'pizza_party': 'Pizza Partisi',
      'sakura_bloom': 'Sakura',
      'blue_porcelain': 'Mavi Porselen',
      'pink_blossom': 'Pembe Çiçek',
      'fortune_cat': 'Şans Kedisi',
      'wildflower': 'Kır Çiçeği',
      'cupid_ribbon': 'Aşk Kurdelesi',
      'panda_bamboo': 'Panda',
      'ramadan_cute': 'Ramazan',
      'enchanted_forest': 'Büyülü Orman',
      'golden_arabesque': 'Altın Arabesk',
      'midnight_mosaic': 'Gece Mozaiği',
      'pearl_lace': 'İnci Dantel',
      'golden_sakura': 'Altın Sakura',
      'dragon_phoenix': 'Ejderha & Anka',
      'gold_beasts': 'Altın Canavarlar',
    };
    const namesEn = {
      'spring_wreath': 'Spring Wreath',
      'lucky_clover': 'Lucky Clover',
      'royal_hearts': 'Royal Hearts',
      'evil_eye': 'Evil Eye',
      'pizza_party': 'Pizza Party',
      'sakura_bloom': 'Sakura Bloom',
      'blue_porcelain': 'Blue Porcelain',
      'pink_blossom': 'Pink Blossom',
      'fortune_cat': 'Fortune Cat',
      'wildflower': 'Wildflower',
      'cupid_ribbon': 'Cupid Ribbon',
      'panda_bamboo': 'Panda Bamboo',
      'ramadan_cute': 'Ramadan',
      'enchanted_forest': 'Enchanted Forest',
      'golden_arabesque': 'Golden Arabesque',
      'midnight_mosaic': 'Midnight Mosaic',
      'pearl_lace': 'Pearl Lace',
      'golden_sakura': 'Golden Sakura',
      'dragon_phoenix': 'Dragon & Phoenix',
      'gold_beasts': 'Gold Beasts',
    };
    if (languageCode == 'tr') return namesTr[id] ?? fallback;
    return namesEn[id] ?? fallback;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isTr = l10n.localeName == 'tr';
    final languageCode = isTr ? 'tr' : 'en';

    return Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) {
            final screenW = MediaQuery.of(context).size.width;
            final screenH = MediaQuery.of(context).size.height;
            final panelW = screenW - 32;
            final alignX =
                ((widget.btnCenterX - 16) / panelW) * 2 - 1;
            final clampedAlignX = alignX.clamp(-1.0, 1.0);
            final maxPanelH = screenH - widget.topY - 80;

            return Stack(
              children: [
                // Arka plan — dokunulunca kapat
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _close,
                    child: Container(
                      color:
                          Colors.black.withOpacity(0.35 * _fadeAnim.value),
                    ),
                  ),
                ),
                // Panel — scroll ve tap çalışır
                Positioned(
                  top: widget.topY + 32,
                  left: 16,
                  right: 16,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: ScaleTransition(
                        scale: _scaleAnim,
                        alignment: Alignment(clampedAlignX, -1.0),
                        child: _buildPanel(
                          isTr,
                          languageCode,
                          maxPanelH,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
    );
  }

  Widget _buildPanel(bool isTr, String languageCode, double maxH) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18), // 40 → 18 (performans)
        child: GlassContainer(
          useOwnLayer: true,
          height: 245,
          settings: const LiquidGlassSettings(
            thickness: 18,
            blur: 2,
            glassColor: Colors.transparent,
            chromaticAberration: 0.1,
            lightIntensity: 0.7,
            ambientStrength: 0.6,
            refractiveIndex: 1.2,
            saturation: 1.0,
          ),
          child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.14),
                Colors.white.withOpacity(0.06),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.35),
              width: 0.8,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Başlık
              Text(
                _cookieNameLocalized(
                  widget.selectedCookieId ?? '',
                  isTr ? 'Kurabiyelerim' : 'My Cookies',
                  languageCode,
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isTr
                    ? '${_ownedCookies.length} çeşit · dokun → sabitle'
                    : '${_ownedCookies.length} types · tap → pin',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.45),
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              // Kurabiye listesi
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                )
              else if (_ownedCookies.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    isTr
                        ? 'Henüz koleksiyonunda kurabiye yok.\nAna sayfadan kurabiye kırarak başla!'
                        : 'No cookies in your collection yet.\nStart cracking cookies from the home page!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                )
              else
                Expanded(
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.white,
                          Colors.white,
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.14, 0.85, 1.0],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: GridView.builder(
                      physics: _menuActive
                          ? const NeverScrollableScrollPhysics()
                          : null,
                      padding: const EdgeInsets.only(top: 10, bottom: 18),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _ownedCookies.length,
                      itemBuilder: (context, index) {
                        final card = _ownedCookies[index];
                        final imagePath = _cookieImageMap[card.id];
                        final isPaid = _paidCookieIds.contains(card.id);
                        final name = _cookieNameLocalized(
                          card.id,
                          card.name,
                          languageCode,
                        );

                        return _CookieGridItem(
                          cookieId: card.id,
                          name: name,
                          imagePath: imagePath,
                          isPaid: isPaid,
                          count: card.countObtained,
                          isTr: isTr,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            widget.onCookieNavigate?.call(card.id);
                            _close();
                          },
                          onLongPressStart: (details) {
                            HapticFeedback.mediumImpact();
                            _showCookieContextMenu(
                              context,
                              card.id,
                              name,
                              imagePath,
                              isTr,
                              details.globalPosition,
                            );
                          },
                          onLongPressMoveUpdate: (details) {
                            _onMenuMoveUpdate(details.globalPosition);
                          },
                          onLongPressEnd: (details) {
                            _onMenuRelease(details.globalPosition, card.id, isTr);
                          },
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

// ── Kurabiye grid öğesi — basılı tutma scale efektli ──
class _CookieGridItem extends StatefulWidget {
  final String cookieId;
  final String name;
  final String? imagePath;
  final bool isPaid;
  final int count;
  final bool isTr;
  final VoidCallback? onTap;
  final void Function(LongPressStartDetails) onLongPressStart;
  final void Function(LongPressMoveUpdateDetails) onLongPressMoveUpdate;
  final void Function(LongPressEndDetails) onLongPressEnd;

  const _CookieGridItem({
    required this.cookieId,
    required this.name,
    required this.imagePath,
    required this.isPaid,
    required this.count,
    required this.isTr,
    this.onTap,
    required this.onLongPressStart,
    required this.onLongPressMoveUpdate,
    required this.onLongPressEnd,
  });

  @override
  State<_CookieGridItem> createState() => _CookieGridItemState();
}

class _CookieGridItemState extends State<_CookieGridItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  Timer? _longPressTimer;
  Offset? _startPos;
  bool _longPressTriggered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 250),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent e) {
    _ctrl.forward();
    _startPos = e.position;
    _longPressTriggered = false;
    _longPressTimer = Timer(const Duration(milliseconds: 120), () {
      _longPressTriggered = true;
      HapticFeedback.mediumImpact();
      widget.onLongPressStart(
        LongPressStartDetails(globalPosition: _startPos!),
      );
    });
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (_longPressTriggered) {
      widget.onLongPressMoveUpdate(
        LongPressMoveUpdateDetails(
          globalPosition: e.position,
          localPosition: e.localPosition,
        ),
      );
    } else if (_startPos != null) {
      // Parmak hareket ettiyse scroll intent — timer'ı iptal et
      final delta = (e.position - _startPos!).distance;
      if (delta > 8) {
        _longPressTimer?.cancel();
        _ctrl.reverse();
        _startPos = null;
      }
    }
  }

  void _onPointerUp(PointerUpEvent e) {
    _longPressTimer?.cancel();
    _ctrl.reverse();
    if (_longPressTriggered) {
      widget.onLongPressEnd(
        LongPressEndDetails(globalPosition: e.position),
      );
      _longPressTriggered = false;
    } else if (_startPos != null) {
      // Kısa tıklama — yönlendir
      widget.onTap?.call();
    }
    _startPos = null;
  }

  void _onPointerCancel(PointerCancelEvent e) {
    _longPressTimer?.cancel();
    _ctrl.reverse();
    _longPressTriggered = false;
    _startPos = null;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: widget.isPaid
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFFD700).withOpacity(0.7),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.25),
                          blurRadius: 10,
                        ),
                      ],
                    )
                  : null,
              child: Center(
                child: widget.imagePath != null
                    ? Image.asset(
                        widget.imagePath!,
                        width: 36,
                        height: 36,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stack) => const Text(
                          '🥠',
                          style: TextStyle(fontSize: 20, fontFamilyFallback: ['Apple Color Emoji']),
                        ),
                      )
                    : const Text(
                        '🥠',
                        style: TextStyle(fontSize: 20, fontFamilyFallback: ['Apple Color Emoji']),
                      ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              widget.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: widget.isPaid
                    ? const Color(0xFFFFD700).withOpacity(0.9)
                    : Colors.white.withOpacity(0.85),
                fontSize: 8,
                fontWeight: widget.isPaid ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
            Text(
              'x${widget.count}',
              style: TextStyle(
                color: widget.isPaid
                    ? const Color(0xFFFFD700).withOpacity(0.5)
                    : Colors.white.withOpacity(0.4),
                fontSize: 7,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
