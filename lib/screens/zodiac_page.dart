import 'package:flutter/material.dart';
import '../widgets/glass_back_button.dart';
import '../constants/colors.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/fade_page_route.dart';
import 'home_page.dart';
import 'collection_page.dart';
import 'profile_page.dart';

class ZodiacPage extends StatefulWidget {
  const ZodiacPage({super.key});

  @override
  State<ZodiacPage> createState() => _ZodiacPageState();
}

class _ZodiacPageState extends State<ZodiacPage> {
  int _currentNavIndex = 0;
  String? _selectedZodiac;

  final List<Map<String, String>> _zodiacs = [
    {'emoji': '♈', 'name': 'Koç'},
    {'emoji': '♉', 'name': 'Boğa'},
    {'emoji': '♊', 'name': 'İkizler'},
    {'emoji': '♋', 'name': 'Yengeç'},
    {'emoji': '♌', 'name': 'Aslan'},
    {'emoji': '♍', 'name': 'Başak'},
    {'emoji': '♎', 'name': 'Terazi'},
    {'emoji': '♏', 'name': 'Akrep'},
    {'emoji': '♐', 'name': 'Yay'},
    {'emoji': '♑', 'name': 'Oğlak'},
    {'emoji': '♒', 'name': 'Kova'},
    {'emoji': '♓', 'name': 'Balık'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 20, 12),
                child: Row(
                  children: [
                    GlassBackButton(),
                    const SizedBox(width: 10),
                    const Text(
                      '⭐ Burç Yorumu',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Zodiac Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.2,
                            ),
                        itemCount: _zodiacs.length,
                        itemBuilder: (context, index) {
                          final zodiac = _zodiacs[index];
                          final isSelected = _selectedZodiac == zodiac['name'];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedZodiac = zodiac['name'];
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppColors.primaryOrange.withOpacity(
                                            0.25,
                                          ),
                                          AppColors.primaryOrangeDark
                                              .withOpacity(0.15),
                                        ],
                                      )
                                    : null,
                                color: isSelected
                                    ? null
                                    : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primaryOrange.withOpacity(0.5)
                                      : Colors.white.withOpacity(0.1),
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primaryOrange
                                              .withOpacity(0.2),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Opacity(
                                      opacity: 0.85,
                                      child: Image.asset(
                                        'assets/images/zodiac.webp',
                                        width: 22,
                                        height: 22,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        zodiac['emoji']!,
                                        style: const TextStyle(fontSize: 40),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        zodiac['name']!,
                                        style: TextStyle(
                                          color: isSelected
                                              ? AppColors.primaryOrange
                                              : AppColors.textWhite,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      // Result
                      if (_selectedZodiac != null) ...[
                        const SizedBox(height: 30),
                        _buildResult(),
                      ],
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

  Widget _buildResult() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryOrange.withOpacity(0.15),
            AppColors.primaryOrangeDark.withOpacity(0.1),
          ],
        ),
        border: Border.all(color: AppColors.primaryOrange.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$_selectedZodiac Burcu - Günlük Yorum',
            style: const TextStyle(
              color: AppColors.primaryOrange,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Bu hafta aşk konusunda şanslısın! Kariyer fırsatları kapında, gözlerini aç. Enerjin yüksek, bunu değerlendir. Yeni projeler için mükemmel bir zaman. İletişim becerilerin zirvede, bunu kullan.',
            style: TextStyle(
              color: AppColors.textWhite70,
              fontSize: 14,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatBox(emoji: '💕', label: 'Aşk', value: 0.85),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBox(emoji: '💼', label: 'Kariyer', value: 0.9),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBox(emoji: '💰', label: 'Para', value: 0.75),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBox(emoji: '🌿', label: 'Sağlık', value: 0.8),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String emoji;
  final String label;
  final double value;

  const _StatBox({
    required this.emoji,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.textWhite.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: AppColors.textWhite50, fontSize: 10),
          ),
          const SizedBox(height: 6),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textWhite.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              widthFactor: value,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.orangeGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
