import 'package:flutter/material.dart';
import '../widgets/glass_back_button.dart';

/// Maya Takvimi Burç Sayfası - 20 Gün İşareti (Nahual)
/// Renk paleti: Altın-amber (panel ile uyumlu)
class ZodiacMayanPage extends StatefulWidget {
  const ZodiacMayanPage({super.key});

  @override
  State<ZodiacMayanPage> createState() => _ZodiacMayanPageState();
}

class _ZodiacMayanPageState extends State<ZodiacMayanPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _selectedSignIndex = 0;

  // Panel ile uyumlu altın renk paleti
  static const Color _goldBright = Color(0xFFFFD060);
  static const Color _goldLight = Color(0xFFFFE8A1);
  static const Color _goldWarm = Color(0xFFE8C860);
  static const Color _goldDark = Color(0xFFB07020);
  static const Color _bgDark = Color(0xFF0F1210);

  // Maya Burçları - 20 Nahual (Gün İşareti)
  static const List<Map<String, dynamic>> _nahuales = [
    {
      'glyph': '🐊',
      'name': 'Imix',
      'meaning': 'Timsah',
      'period': '1 Ocak - 19 Ocak',
      'element': 'Su',
      'elementEmoji': '💧',
      'direction': 'Doğu',
      'color': 'Kırmızı',
      'traits': ['Koruyucu', 'Ana Ruhlu', 'Başlatıcı', 'Sezgisel'],
      'description':
          'Imix, yaratılışın başlangıcıdır. Bu işaret altında doğanlar güçlü koruma içgüdüsüne sahiptir. Yeni başlangıçlar yapma ve başkalarını besleme kapasiteleri yüksektir. Güçlü sezgileriyle bilinirler.',
      'power': 'Yaratıcı Enerji',
      'spirit': 'Timsah Ruhu',
    },
    {
      'glyph': '🌬️',
      'name': 'Ik',
      'meaning': 'Rüzgâr',
      'period': '20 Ocak - 8 Şubat',
      'element': 'Hava',
      'elementEmoji': '🌪️',
      'direction': 'Kuzey',
      'color': 'Beyaz',
      'traits': ['İletişimci', 'Ruhani', 'Yaratıcı', 'Özgür'],
      'description':
          'Ik, ilahi nefesin ve ruhun taşıyıcısıdır. Bu işaret altında doğanlar doğal iletişimcilerdir. Değişimin rüzgârını taşırlar ve manevi dünyanın mesajlarını aktarırlar.',
      'power': 'İlham Verme',
      'spirit': 'Rüzgâr Ruhu',
    },
    {
      'glyph': '🌙',
      'name': 'Akbal',
      'meaning': 'Gece',
      'period': '9 Şubat - 28 Şubat',
      'element': 'Toprak',
      'elementEmoji': '🌍',
      'direction': 'Batı',
      'color': 'Mavi',
      'traits': ['Gizemli', 'Hayalperest', 'Derin', 'İç Gözlemci'],
      'description':
          'Akbal, gecenin ve karanlığın gizemini temsil eder. Bu işaret altında doğanlar derinlerdeki gerçekleri keşfetme yeteneğine sahiptir. Rüya dünyası ve bilinçaltıyla güçlü bağları vardır.',
      'power': 'İç Görü',
      'spirit': 'Gece Jaguar',
    },
    {
      'glyph': '🌾',
      'name': 'Kan',
      'meaning': 'Mısır Tohumu',
      'period': '1 Mart - 20 Mart',
      'element': 'Ateş',
      'elementEmoji': '🔥',
      'direction': 'Güney',
      'color': 'Sarı',
      'traits': ['Bereketli', 'Sabırlı', 'Fırsatçı', 'Büyüyen'],
      'description':
          'Kan, tohumun filizlenmesini ve bolluğu simgeler. Bu işaret altında doğanlar doğal bir büyüme ve gelişme enerjisi taşır. Sabırla ekilen tohumların meyvesini toplama ustasıdırlar.',
      'power': 'Bolluk ve Bereket',
      'spirit': 'Mısır Tanrısı',
    },
    {
      'glyph': '🐍',
      'name': 'Chicchan',
      'meaning': 'Yılan',
      'period': '21 Mart - 9 Nisan',
      'element': 'Su',
      'elementEmoji': '💧',
      'direction': 'Doğu',
      'color': 'Kırmızı',
      'traits': ['Kundalini', 'Güçlü', 'Dönüşümcü', 'Tutkulu'],
      'description':
          'Chicchan, yaşam gücünün ve kundalini enerjisinin simgesidir. Bu işaret altında doğanlar güçlü bir yaşam enerjisi taşır. Deri değiştiren yılan gibi sürekli dönüşüm ve yenilenme kapasitesine sahiplerdir.',
      'power': 'Dönüşüm Gücü',
      'spirit': 'Tüylü Yılan',
    },
    {
      'glyph': '💀',
      'name': 'Cimi',
      'meaning': 'Ölüm & Yeniden Doğuş',
      'period': '10 Nisan - 29 Nisan',
      'element': 'Hava',
      'elementEmoji': '🌪️',
      'direction': 'Kuzey',
      'color': 'Beyaz',
      'traits': ['Yeniden Doğuş', 'Şifacı', 'Bağlantıcı', 'Kadim'],
      'description':
          'Cimi, ölüm ve yeniden doğuşun döngüsünü temsil eder. Bu işaret altında doğanlar ataları ve ruhani dünyayla güçlü bağlar kurar. Doğal şifacılardırlar ve dönüşüm süreçlerinde rehberlik ederler.',
      'power': 'Ruhani Bağlantı',
      'spirit': 'Ata Ruhları',
    },
    {
      'glyph': '🦌',
      'name': 'Manik',
      'meaning': 'Geyik',
      'period': '30 Nisan - 19 Mayıs',
      'element': 'Toprak',
      'elementEmoji': '🌍',
      'direction': 'Batı',
      'color': 'Mavi',
      'traits': ['Özgür', 'Zarif', 'Doğal', 'Şifacı'],
      'description':
          'Manik, geyiğin zarafetini ve doğayla uyumunu simgeler. Bu işaret altında doğanlar dört elementle güçlü bir bağ kurar. Doğal şifacılar ve ormanın bilgeleridir.',
      'power': 'Doğa Şifası',
      'spirit': 'Geyik Rehber',
    },
    {
      'glyph': '⭐',
      'name': 'Lamat',
      'meaning': 'Yıldız / Tavşan',
      'period': '20 Mayıs - 8 Haziran',
      'element': 'Ateş',
      'elementEmoji': '🔥',
      'direction': 'Güney',
      'color': 'Sarı',
      'traits': ['Uyumlu', 'Parlak', 'Bereketli', 'Zarif'],
      'description':
          'Lamat, Venüs yıldızının parlaklığını temsil eder. Bu işaret altında doğanlar doğal güzellik ve uyum taşır. Sanatsal yetenekleri güçlüdür ve etraflarına ışık saçarlar.',
      'power': 'Uyum & Güzellik',
      'spirit': 'Venüs Yıldızı',
    },
    {
      'glyph': '💧',
      'name': 'Muluc',
      'meaning': 'Su',
      'period': '9 Haziran - 28 Haziran',
      'element': 'Su',
      'elementEmoji': '💧',
      'direction': 'Doğu',
      'color': 'Kırmızı',
      'traits': ['Duygusal', 'Sezgisel', 'Akışkan', 'Şefkatli'],
      'description':
          'Muluc, suyun akışkanlığını ve duygusal derinliği simgeler. Bu işaret altında doğanlar güçlü empati ve sezgi sahibidir. Duyguların sonsuz okyanusunda yüzme yeteneğiyle bilinirler.',
      'power': 'Duygusal Zekâ',
      'spirit': 'Ay Tanrıçası',
    },
    {
      'glyph': '🐕',
      'name': 'Oc',
      'meaning': 'Köpek',
      'period': '29 Haziran - 18 Temmuz',
      'element': 'Hava',
      'elementEmoji': '🌪️',
      'direction': 'Kuzey',
      'color': 'Beyaz',
      'traits': ['Sadık', 'Rehber', 'Koruyucu', 'Yoldaş'],
      'description':
          'Oc, sadakatin ve rehberliğin sembolüdür. Bu işaret altında doğanlar hem dünyevi hem ruhani yolculuklarda güvenilir rehberlerdir. Sezgileriyle yolu aydınlatan ışık taşıyıcılarıdır.',
      'power': 'Sadakat & Rehberlik',
      'spirit': 'Ruh Rehberi Köpek',
    },
    {
      'glyph': '🐒',
      'name': 'Chuen',
      'meaning': 'Maymun',
      'period': '19 Temmuz - 7 Ağustos',
      'element': 'Toprak',
      'elementEmoji': '🌍',
      'direction': 'Batı',
      'color': 'Mavi',
      'traits': ['Yaratıcı', 'Eğlenceli', 'Zanaatkar', 'Sanatsal'],
      'description':
          'Chuen, kozmik zanaatkârı ve sanatçıyı temsil eder. Bu işaret altında doğanlar olağanüstü yaratıcılığa sahiptir. Evrenin ipliklerini dokuyarak yeni gerçeklikler yaratırlar.',
      'power': 'Yaratıcılık',
      'spirit': 'Kutsal Maymun',
    },
    {
      'glyph': '🌿',
      'name': 'Eb',
      'meaning': 'Yol / Çimen',
      'period': '8 Ağustos - 27 Ağustos',
      'element': 'Ateş',
      'elementEmoji': '🔥',
      'direction': 'Güney',
      'color': 'Sarı',
      'traits': ['Yolcu', 'Hümanist', 'Keşifçi', 'Bilge'],
      'description':
          'Eb, kutsal yolu ve insani kaderi simgeler. Bu işaret altında doğanlar doğal yol göstericilerdir. Hayatın anlamını arayan gezginler ve toplumun vicdanıdırlar.',
      'power': 'Kaderi Okuma',
      'spirit': 'Yol Ruhu',
    },
    {
      'glyph': '🌽',
      'name': 'Ben',
      'meaning': 'Kamış',
      'period': '28 Ağustos - 16 Eylül',
      'element': 'Su',
      'elementEmoji': '💧',
      'direction': 'Doğu',
      'color': 'Kırmızı',
      'traits': ['Otorite', 'Lider', 'Güçlü', 'Kararlı'],
      'description':
          'Ben, gökyüzü ile yeryüzü arasındaki bağlantıyı sembolize eder. Bu işaret altında doğanlar doğal otoritelere ve güçlü liderlik kapasitesine sahiptir. Toplulukları bir arada tutarlar.',
      'power': 'İlahi Otorite',
      'spirit': 'Kamış Savaşçı',
    },
    {
      'glyph': '🐆',
      'name': 'Ix',
      'meaning': 'Jaguar',
      'period': '17 Eylül - 6 Ekim',
      'element': 'Hava',
      'elementEmoji': '🌪️',
      'direction': 'Kuzey',
      'color': 'Beyaz',
      'traits': ['Mistik', 'Güçlü', 'Büyücü', 'Sezgisel'],
      'description':
          'Ix, jaguarın gücünü ve gizemlerin bekçiliğini temsil eder. Bu işaret altında doğanlar derin mistik güçlere sahiptir. Gece dünyasının ve gizemlerin ustasıdırlar.',
      'power': 'Mistik Güç',
      'spirit': 'Gece Jaguarı',
    },
    {
      'glyph': '🦅',
      'name': 'Men',
      'meaning': 'Kartal',
      'period': '7 Ekim - 26 Ekim',
      'element': 'Toprak',
      'elementEmoji': '🌍',
      'direction': 'Batı',
      'color': 'Mavi',
      'traits': ['Vizyoner', 'Özgür', 'Yüksek Bakış', 'Bilge'],
      'description':
          'Men, kartalın gökyüzünden bakışını ve geniş vizyonunu simgeler. Bu işaret altında doğanlar büyük resmi görme yeteneğine sahiptir. Yükseklerden bakarak gerçeğin peçesini kaldırırlar.',
      'power': 'Kozmik Vizyon',
      'spirit': 'Kartal Ruhu',
    },
    {
      'glyph': '🌋',
      'name': 'Cib',
      'meaning': 'Akbaba / Bilgelik',
      'period': '27 Ekim - 15 Kasım',
      'element': 'Ateş',
      'elementEmoji': '🔥',
      'direction': 'Güney',
      'color': 'Sarı',
      'traits': ['Bilge', 'Arındırıcı', 'Kadim', 'Şifacı'],
      'description':
          'Cib, kadim bilgeliği ve ruhsal arınmayı temsil eder. Bu işaret altında doğanlar derin bir bilgelik taşır. Geçmişin öğretilerini bugüne taşıyan kadim ruhları temsil ederler.',
      'power': 'Kadim Bilgelik',
      'spirit': 'Bilgelik Bekçisi',
    },
    {
      'glyph': '🌎',
      'name': 'Caban',
      'meaning': 'Deprem / Dünya',
      'period': '16 Kasım - 5 Aralık',
      'element': 'Su',
      'elementEmoji': '💧',
      'direction': 'Doğu',
      'color': 'Kırmızı',
      'traits': ['Güçlü', 'Zeki', 'Entelektüel', 'Bağlantıcı'],
      'description':
          'Caban, dünyanın gücünü ve zihinsel kapasiteyi simgeler. Bu işaret altında doğanlar keskin zekâya sahiptir. Doğayla derin bir bağ kurar ve evrenin ritimlerini hissederler.',
      'power': 'Zihinsel Güç',
      'spirit': 'Dünya Ana',
    },
    {
      'glyph': '🗡️',
      'name': 'Etznab',
      'meaning': 'Obsidyen Bıçak',
      'period': '6 Aralık - 25 Aralık',
      'element': 'Hava',
      'elementEmoji': '🌪️',
      'direction': 'Kuzey',
      'color': 'Beyaz',
      'traits': ['Dürüst', 'Adil', 'Keskin', 'Ayna'],
      'description':
          'Etznab, obsidyen bıçağın keskinliğini ve gerçeğin aynasını temsil eder. Bu işaret altında doğanlar acımasız bir dürüstlüğe sahiptir. Gerçeği yansıtan aynalar ve adaleti sağlayan kılıçlardır.',
      'power': 'Gerçeğin Aynası',
      'spirit': 'Obsidyen Ruh',
    },
    {
      'glyph': '🌧️',
      'name': 'Cauac',
      'meaning': 'Fırtına',
      'period': '26 Aralık - 13 Ocak (son)',
      'element': 'Toprak',
      'elementEmoji': '🌍',
      'direction': 'Batı',
      'color': 'Mavi',
      'traits': ['Şifacı', 'Arındırıcı', 'Güçlü', 'Dönüştürücü'],
      'description':
          'Cauac, fırtınanın arındırıcı gücünü temsil eder. Bu işaret altında doğanlar derin bir şifa enerjisi taşır. Fırtına gibi gelir, her şeyi arındırır ve ardında yenilenmiş bir dünya bırakırlar.',
      'power': 'Kozmik Şifa',
      'spirit': 'Fırtına Tanrısı',
    },
    {
      'glyph': '☀️',
      'name': 'Ahau',
      'meaning': 'Güneş Lordu',
      'period': '14 Ocak - 31 Ocak (döngü)',
      'element': 'Ateş',
      'elementEmoji': '🔥',
      'direction': 'Güney',
      'color': 'Sarı',
      'traits': ['Aydınlanmış', 'Lider', 'Sanatçı', 'Parlak'],
      'description':
          'Ahau, güneş lordunun ışığını ve evrensel bilinç seviyesini temsil eder. Bu işaret altında doğanlar doğuştan aydınlanmış ruhlardır. En yüksek bilinç seviyesini sembolize ederler.',
      'power': 'Evrensel Aydınlanma',
      'spirit': 'Güneş Tanrısı Kinich Ahau',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sign = _nahuales[_selectedSignIndex];
    return Scaffold(
      backgroundColor: _bgDark,
      body: Stack(
        children: [
          // Altın-amber arka plan
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.3, -0.6),
                radius: 1.4,
                colors: [
                  _goldDark.withOpacity(0.2),
                  _bgDark,
                  const Color(0xFF0A0D0A),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Büyük bulanık glyph arka plan
          Positioned(
            top: 40,
            right: -20,
            child: Opacity(
              opacity: 0.05,
              child: Text(
                sign['glyph'] as String,
                style: const TextStyle(fontSize: 260),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Üst bar
                        Row(
                          children: [
                            const GlassBackButton(),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: _goldDark.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: _goldBright.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🏛️',
                                      style: TextStyle(fontSize: 14)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Maya Takvimi',
                                    style: TextStyle(
                                      color: _goldLight.withOpacity(0.9),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Nahual seçici
                        _buildSignSelector(),

                        const SizedBox(height: 24),

                        // Ana işaret gösterimi
                        Center(
                          child: Text(
                            sign['glyph'] as String,
                            style: const TextStyle(fontSize: 72),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [_goldBright, _goldLight],
                            ).createShader(bounds),
                            child: Text(
                              sign['name'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: Text(
                            '"${sign['meaning']}"',
                            style: TextStyle(
                              color: _goldWarm.withOpacity(0.8),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: Text(
                            sign['period'] as String,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 13,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Element, Yön, Renk kartları
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                sign['elementEmoji'] as String,
                                'Element',
                                sign['element'] as String,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildInfoCard(
                                '🧭',
                                'Yön',
                                sign['direction'] as String,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildInfoCard(
                                '🎨',
                                'Renk',
                                sign['color'] as String,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Ruhani güç ve ruh hayvanı
                        Row(
                          children: [
                            Expanded(
                              child: _buildMysticCard(
                                '⚡',
                                'Ruhani Güç',
                                sign['power'] as String,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMysticCard(
                                '👻',
                                'Ruh Rehberi',
                                sign['spirit'] as String,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Açıklama kartı
                        _buildGlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: _goldDark.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.auto_awesome,
                                        color: _goldBright, size: 22),
                                  ),
                                  const SizedBox(width: 14),
                                  const Text(
                                    'Nahual Rehberliği',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                sign['description'] as String,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 15,
                                  height: 1.7,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Özellikler
                        const Text(
                          'Nahual Özellikleri',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: (sign['traits'] as List<String>)
                              .map((t) => _buildTraitChip(t))
                              .toList(),
                        ),

                        const SizedBox(height: 24),

                        // Maya bilgelik notu
                        _buildWisdomCard(),

                        const SizedBox(height: 120),
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

  Widget _buildSignSelector() {
    return SizedBox(
      height: 68,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _nahuales.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedSignIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedSignIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 58,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: isSelected
                    ? _goldDark.withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? _goldBright.withOpacity(0.5)
                      : Colors.white.withOpacity(0.08),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: _goldBright.withOpacity(0.12),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _nahuales[index]['glyph'] as String,
                    style: TextStyle(fontSize: isSelected ? 24 : 20),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _nahuales[index]['name'] as String,
                    style: TextStyle(
                      color: isSelected
                          ? _goldBright
                          : Colors.white.withOpacity(0.4),
                      fontSize: 7,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String emoji, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _goldBright.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: _goldWarm,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMysticCard(String emoji, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _goldDark.withOpacity(0.1),
            _goldDark.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _goldBright.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: _goldBright,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _goldBright.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTraitChip(String trait) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: _goldDark.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _goldBright.withOpacity(0.2)),
      ),
      child: Text(
        trait,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildWisdomCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _goldDark.withOpacity(0.15),
            _goldDark.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _goldBright.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌿', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                'Maya Bilgeliği',
                style: TextStyle(
                  color: _goldBright,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '"In Lak\'ech Ala K\'in"\n— Ben başka bir senim. Sen başka bir bensin.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 15,
              height: 1.7,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Maya kozmolojisinde her birey evrenin bir parçasıdır. Nahualler, ruhani rehberlerimizi ve kozmik amacımızı yansıtır.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
