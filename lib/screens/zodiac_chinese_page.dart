import 'package:flutter/material.dart';
import '../widgets/glass_back_button.dart';

/// Çin/Asya Burç Sayfası - 12 Hayvan Yılı
/// Renk paleti: Altın-amber (panel ile uyumlu)
class ZodiacChinesePage extends StatefulWidget {
  const ZodiacChinesePage({super.key});

  @override
  State<ZodiacChinesePage> createState() => _ZodiacChinesePageState();
}

class _ZodiacChinesePageState extends State<ZodiacChinesePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _selectedAnimalIndex = 6; // Varsayılan: At (2026)

  // Panel ile uyumlu altın renk paleti
  static const Color _goldBright = Color(0xFFFFD060);
  static const Color _goldLight = Color(0xFFFFE8A1);
  static const Color _goldDark = Color(0xFFB07020);
  static const Color _amber = Color(0xFFFFB74D);
  static const Color _bgDark = Color(0xFF0F1210);

  // Çin Burçları - 12 Hayvan
  static const List<Map<String, dynamic>> _animals = [
    {
      'emoji': '🐀',
      'name': 'Sıçan',
      'nameEn': 'Rat',
      'years': '1924, 1936, 1948, 1960, 1972, 1984, 1996, 2008, 2020',
      'element': 'Su',
      'elementEmoji': '💧',
      'yinYang': 'Yang',
      'traits': ['Zeki', 'Çevik', 'Becerikli', 'Çalışkan', 'Kurnaz'],
      'description':
          'Sıçan yılında doğanlar doğal liderlerdir. Zekâları ve çevikliğiyle dikkat çekerler. Her durumda ayakta kalma becerisine sahiplerdir. Sosyal yetenekleri güçlüdür ve çevrelerine ilham verirler.',
      'compatibility': 'Ejderha, Maymun',
      'luckyNumber': '2, 3',
      'luckyColor': 'Mavi, Altın',
    },
    {
      'emoji': '🐂',
      'name': 'Öküz',
      'nameEn': 'Ox',
      'years': '1925, 1937, 1949, 1961, 1973, 1985, 1997, 2009, 2021',
      'element': 'Toprak',
      'elementEmoji': '🌍',
      'yinYang': 'Yin',
      'traits': ['Güvenilir', 'Sabırlı', 'Güçlü', 'Kararlı', 'Sadık'],
      'description':
          'Öküz yılında doğanlar sarsılmaz bir iradeye sahiptir. Güvenilirlikleri ve kararlılıklarıyla tanınırlar. Hedeflerine ulaşmak için azimle çalışırlar ve etraflarına güven verirler.',
      'compatibility': 'Yılan, Horoz',
      'luckyNumber': '1, 4',
      'luckyColor': 'Beyaz, Sarı',
    },
    {
      'emoji': '🐅',
      'name': 'Kaplan',
      'nameEn': 'Tiger',
      'years': '1926, 1938, 1950, 1962, 1974, 1986, 1998, 2010, 2022',
      'element': 'Ağaç',
      'elementEmoji': '🌳',
      'yinYang': 'Yang',
      'traits': ['Cesur', 'Tutkulu', 'Maceracı', 'Bağımsız', 'Karizmatik'],
      'description':
          'Kaplan yılında doğanlar doğuştan cesurdur. Güçlü kişilikleri ve tutkuları onları etkileyici kılar. Liderlik kabiliyetleri yüksektir ve adalet duyguları güçlüdür.',
      'compatibility': 'At, Köpek',
      'luckyNumber': '1, 3, 4',
      'luckyColor': 'Mavi, Gri',
    },
    {
      'emoji': '🐇',
      'name': 'Tavşan',
      'nameEn': 'Rabbit',
      'years': '1927, 1939, 1951, 1963, 1975, 1987, 1999, 2011, 2023',
      'element': 'Ağaç',
      'elementEmoji': '🌳',
      'yinYang': 'Yin',
      'traits': ['Zarif', 'Nazik', 'Barışçıl', 'Duyarlı', 'Sanatsal'],
      'description':
          'Tavşan yılında doğanlar incelik ve zerafet timsalidir. Barışçıl ruhları ve güçlü sezgileriyle çevrelerine huzur getirirler. Sanatsal yetenekleri dikkat çekicidir.',
      'compatibility': 'Keçi, Domuz',
      'luckyNumber': '3, 4, 6',
      'luckyColor': 'Pembe, Mor',
    },
    {
      'emoji': '🐉',
      'name': 'Ejderha',
      'nameEn': 'Dragon',
      'years': '1928, 1940, 1952, 1964, 1976, 1988, 2000, 2012, 2024',
      'element': 'Toprak',
      'elementEmoji': '🌍',
      'yinYang': 'Yang',
      'traits': ['Güçlü', 'Asil', 'Enerjik', 'Karizmatik', 'Şanslı'],
      'description':
          'Ejderha yılında doğanlar en şanslı burç olarak kabul edilir. Güçlü ve karizmatik kişilikleriyle doğal liderlerdir. Büyük hayaller kurar ve onları gerçeğe dönüştürürler.',
      'compatibility': 'Sıçan, Maymun',
      'luckyNumber': '1, 6, 7',
      'luckyColor': 'Altın, Gümüş',
    },
    {
      'emoji': '🐍',
      'name': 'Yılan',
      'nameEn': 'Snake',
      'years': '1929, 1941, 1953, 1965, 1977, 1989, 2001, 2013, 2025',
      'element': 'Ateş',
      'elementEmoji': '🔥',
      'yinYang': 'Yin',
      'traits': ['Bilge', 'Gizemli', 'Sezgisel', 'Zarif', 'Stratejik'],
      'description':
          'Yılan yılında doğanlar derin bilgelik taşır. Güçlü sezgileri ve analitik düşünceleriyle dikkat çekerler. Gizemli bir çekicilikleri vardır ve stratejik düşünürler.',
      'compatibility': 'Öküz, Horoz',
      'luckyNumber': '2, 8, 9',
      'luckyColor': 'Kırmızı, Siyah',
    },
    {
      'emoji': '🐴',
      'name': 'At',
      'nameEn': 'Horse',
      'years': '1930, 1942, 1954, 1966, 1978, 1990, 2002, 2014, 2026',
      'element': 'Ateş',
      'elementEmoji': '🔥',
      'yinYang': 'Yang',
      'traits': ['Enerjik', 'Özgür', 'Neşeli', 'Sosyal', 'Atletik'],
      'description':
          'At yılında doğanlar özgürlük aşığıdır. Sınırsız enerjileri ve neşeli kişilikleriyle her ortamın yıldızı olurlar. Maceraperest ruhları onları sürekli yeni ufuklara taşır.',
      'compatibility': 'Kaplan, Köpek',
      'luckyNumber': '2, 3, 7',
      'luckyColor': 'Sarı, Yeşil',
    },
    {
      'emoji': '🐏',
      'name': 'Keçi',
      'nameEn': 'Goat',
      'years': '1931, 1943, 1955, 1967, 1979, 1991, 2003, 2015, 2027',
      'element': 'Toprak',
      'elementEmoji': '🌍',
      'yinYang': 'Yin',
      'traits': ['Yaratıcı', 'Şefkatli', 'Hassas', 'Sakinleştirici', 'Estetik'],
      'description':
          'Keçi yılında doğanlar sanatsal ruha sahiptir. Yaratıcılıkları ve hassas ruhları onları benzersiz kılar. İçsel huzuru ararlar ve çevrelerinde güzellik yaratırlar.',
      'compatibility': 'Tavşan, Domuz',
      'luckyNumber': '2, 7',
      'luckyColor': 'Yeşil, Kahverengi',
    },
    {
      'emoji': '🐵',
      'name': 'Maymun',
      'nameEn': 'Monkey',
      'years': '1932, 1944, 1956, 1968, 1980, 1992, 2004, 2016, 2028',
      'element': 'Metal',
      'elementEmoji': '⚙️',
      'yinYang': 'Yang',
      'traits': ['Zeki', 'Esprili', 'Yaratıcı', 'Kurnaz', 'Girişimci'],
      'description':
          'Maymun yılında doğanlar parlak zekâları ve esprili kişilikleriyle tanınır. Problem çözme yetenekleri üstündür ve her durumda yaratıcı çözümler bulurlar.',
      'compatibility': 'Sıçan, Ejderha',
      'luckyNumber': '4, 9',
      'luckyColor': 'Beyaz, Mavi',
    },
    {
      'emoji': '🐔',
      'name': 'Horoz',
      'nameEn': 'Rooster',
      'years': '1933, 1945, 1957, 1969, 1981, 1993, 2005, 2017, 2029',
      'element': 'Metal',
      'elementEmoji': '⚙️',
      'yinYang': 'Yin',
      'traits': ['Gözlemci', 'Çalışkan', 'Cesur', 'Pratik', 'Detaycı'],
      'description':
          'Horoz yılında doğanlar mükemmeliyetçi ve detaycıdır. Keskin gözlem yetenekleri ve çalışkanlıklarıyla başarıya ulaşırlar. Dürüst ve pratik yaklaşımlarıyla tanınırlar.',
      'compatibility': 'Öküz, Yılan',
      'luckyNumber': '5, 7, 8',
      'luckyColor': 'Altın, Kahve',
    },
    {
      'emoji': '🐕',
      'name': 'Köpek',
      'nameEn': 'Dog',
      'years': '1934, 1946, 1958, 1970, 1982, 1994, 2006, 2018, 2030',
      'element': 'Toprak',
      'elementEmoji': '🌍',
      'yinYang': 'Yang',
      'traits': ['Sadık', 'Dürüst', 'Koruyucu', 'Cesur', 'Adil'],
      'description':
          'Köpek yılında doğanlar en sadık ve güvenilir ruhlardır. Dürüstlükleri ve adalet duyguları güçlüdür. Sevdiklerini her koşulda korurlar ve verilen sözde dururlar.',
      'compatibility': 'Kaplan, At',
      'luckyNumber': '3, 4, 9',
      'luckyColor': 'Kırmızı, Yeşil',
    },
    {
      'emoji': '🐖',
      'name': 'Domuz',
      'nameEn': 'Pig',
      'years': '1935, 1947, 1959, 1971, 1983, 1995, 2007, 2019, 2031',
      'element': 'Su',
      'elementEmoji': '💧',
      'yinYang': 'Yin',
      'traits': ['Cömert', 'Şefkatli', 'Neşeli', 'Eğlenceli', 'Nazik'],
      'description':
          'Domuz yılında doğanlar cömertlik ve şefkatin simgesidir. Sıcak kişilikleri ve neşeli ruhlarıyla herkesi mutlu ederler. Güçlü bir iç dünyaya ve zengin duygusal hazineye sahiplerdir.',
      'compatibility': 'Tavşan, Keçi',
      'luckyNumber': '2, 5, 8',
      'luckyColor': 'Sarı, Gri',
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
    final animal = _animals[_selectedAnimalIndex];
    return Scaffold(
      backgroundColor: _bgDark,
      body: Stack(
        children: [
          // Altın arka plan
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.5),
                radius: 1.3,
                colors: [
                  _goldDark.withOpacity(0.25),
                  _bgDark,
                  const Color(0xFF0A0D0A),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Büyük bulanık emoji arka plan
          Positioned(
            top: -30,
            right: -40,
            child: Opacity(
              opacity: 0.06,
              child: Text(
                animal['emoji'] as String,
                style: const TextStyle(fontSize: 300),
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
                        // Geri butonu
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
                                  Text(animal['emoji'] as String,
                                      style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Çin Astrolojisi',
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
                        const SizedBox(height: 30),

                        // Hayvan seçici - yatay kaydırmalı
                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _animals.length,
                            itemBuilder: (context, index) {
                              final isSelected = index == _selectedAnimalIndex;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedAnimalIndex = index),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 64,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? _goldDark.withOpacity(0.25)
                                        : Colors.white.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? _goldBright.withOpacity(0.5)
                                          : Colors.white.withOpacity(0.1),
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color:
                                                  _goldBright.withOpacity(0.15),
                                              blurRadius: 12,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _animals[index]['emoji'] as String,
                                        style: TextStyle(
                                          fontSize: isSelected ? 28 : 24,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _animals[index]['name'] as String,
                                        style: TextStyle(
                                          color: isSelected
                                              ? _goldBright
                                              : Colors.white.withOpacity(0.5),
                                          fontSize: 9,
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
                        const SizedBox(height: 30),

                        // Hayvan adı ve büyük emoji
                        Center(
                          child: Text(
                            animal['emoji'] as String,
                            style: const TextStyle(fontSize: 80),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [_goldBright, _goldLight],
                            ).createShader(bounds),
                            child: Text(
                              animal['name'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 42,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Center(
                          child: Text(
                            animal['nameEn'] as String,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            animal['years'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _goldBright.withOpacity(0.6),
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Element, Yin/Yang kartları
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                animal['elementEmoji'] as String,
                                'Element',
                                animal['element'] as String,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoCard(
                                '☯️',
                                'Yin/Yang',
                                animal['yinYang'] as String,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoCard(
                                '💑',
                                'Uyum',
                                animal['compatibility'] as String,
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
                                    'Karakter Analizi',
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
                                animal['description'] as String,
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
                          'Öne Çıkan Özellikler',
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
                          children: (animal['traits'] as List<String>)
                              .map((t) => _buildTraitChip(t))
                              .toList(),
                        ),

                        const SizedBox(height: 24),

                        // Şanslı bilgiler
                        _buildGlassCard(
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildLuckyItem(
                                    '🔢', 'Şanslı Sayı', animal['luckyNumber'] as String),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.white.withOpacity(0.1),
                              ),
                              Expanded(
                                child: _buildLuckyItem(
                                    '🎨', 'Şanslı Renk', animal['luckyColor'] as String),
                              ),
                            ],
                          ),
                        ),

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

  Widget _buildInfoCard(String emoji, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _goldBright.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _amber,
              fontSize: 13,
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
        color: Colors.white.withOpacity(0.06),
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
        color: _goldDark.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _goldBright.withOpacity(0.25)),
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

  Widget _buildLuckyItem(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _goldBright,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
