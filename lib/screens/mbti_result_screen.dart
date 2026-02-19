import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../data/mbti_data.dart';
import '../models/mbti_models.dart';
import 'mbti_intro_screen.dart';

class MBTIResultScreen extends StatelessWidget {
  final MBTIResultData result;
  const MBTIResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final typeCode = result.type.split('-').first;
    final identity = result.type.split('-').last;
    final type = mbtiTypes[typeCode]!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF4B3A2A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const SizedBox.shrink(),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/mbti_bg.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.bgGradient,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 72, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: MBTIColors.resultHeaderGradient,
                    border: Border.all(color: const Color(0x33F7941D)),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${type.emoji}  ${type.code}-$identity',
                        style: const TextStyle(
                          color: Color(0xFF4B3A2A),
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${type.name} • ${type.nickname}',
                        style: const TextStyle(
                          color: Color(0xFF6B5A4A),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        type.description,
                        style: const TextStyle(
                          color: Color(0xFF4B3A2A),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _AxisBars(result: result),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'İlişkiler',
                  emoji: '💕',
                  text: type.relationships,
                ),
                _SectionCard(
                  title: 'Zayıf Noktalar',
                  emoji: '⚠️',
                  text: type.negatives,
                ),
                _TagSection(title: 'Güçlü Yönler', emoji: '💪', tags: type.strengths, isStrength: true),
                _TagSection(title: 'Zayıf Yönler', emoji: '⚠️', tags: type.weaknesses, isStrength: false),
                _TagSection(title: 'Kariyer', emoji: '💼', tags: type.careers, isStrength: true),
                _TagSection(title: 'Ünlüler', emoji: '⭐', tags: type.famous, isStrength: true),
                _TagSection(title: 'Uyumlu Tipler', emoji: '💕', tags: type.compatible, isStrength: true),
                _TipsSection(tips: type.tips),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const MBTIIntroScreen()),
                            (route) => route.isFirst,
                          );
                        },
                        child: const Text('Tekrarla'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MBTIColors.primaryOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          // TODO: paylaşım entegrasyonu
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Paylaşım yakında eklenecek'),
                              duration: Duration(milliseconds: 800),
                            ),
                          );
                        },
                        child: const Text('Paylaş'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AxisBars extends StatelessWidget {
  final MBTIResultData result;
  const _AxisBars({required this.result});

  @override
  Widget build(BuildContext context) {
    final scores = result.scores;
    final p = result.percentages;
    final bars = [
      _AxisBarData('EI', 'E', 'I', p['EI']!, scores['EI']!),
      _AxisBarData('SN', 'S', 'N', p['SN']!, scores['SN']!),
      _AxisBarData('TF', 'T', 'F', p['TF']!, scores['TF']!),
      _AxisBarData('JP', 'J', 'P', p['JP']!, scores['JP']!),
      _AxisBarData('AT', 'A', 'T', p['AT']!, scores['AT']!),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Eksenler',
          style: TextStyle(color: Color(0xFF4B3A2A), fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 8.0;
            final rawSize = (constraints.maxWidth - spacing * 4) / 5;
            final clampedSize = rawSize.clamp(56.0, 64.0);
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: bars
                  .map(
                    (b) => _AxisCircle(
                      data: b,
                      size: clampedSize,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _AxisBarData {
  final String axis;
  final String left;
  final String right;
  final int percent;
  final int raw;
  _AxisBarData(this.axis, this.left, this.right, this.percent, this.raw);
}

class _AxisCircle extends StatelessWidget {
  final _AxisBarData data;
  final double size;
  const _AxisCircle({required this.data, required this.size});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> desc = axisDescriptions[data.axis]! as Map<String, dynamic>;
    final left = (desc['left'] as Map)['letter'];
    final right = (desc['right'] as Map)['letter'];
    final percent = data.percent.clamp(0, 100);
    final stroke = (size * 0.07).clamp(3.5, 5.0);
    final fontSize = (size * 0.2).clamp(11.0, 14.0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: percent / 100,
                strokeWidth: stroke,
                backgroundColor: const Color(0xFFEDE5DC),
                valueColor: const AlwaysStoppedAnimation<Color>(MBTIColors.primaryOrange),
              ),
              Text(
                '$percent%',
                style: TextStyle(
                  color: Color(0xFF4B3A2A),
                  fontWeight: FontWeight.w700,
                  fontSize: fontSize,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$left – $right',
          style: const TextStyle(
            color: Color(0xFF4B3A2A),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String emoji;
  final String text;
  const _SectionCard({required this.title, required this.emoji, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MBTIColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MBTIColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$emoji $title',
            style: const TextStyle(
              color: Color(0xFF4B3A2A),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF6B5A4A),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _TagSection extends StatelessWidget {
  final String title;
  final String emoji;
  final List<String> tags;
  final bool isStrength;

  const _TagSection({
    required this.title,
    required this.emoji,
    required this.tags,
    required this.isStrength,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isStrength ? MBTIColors.strengthBg : MBTIColors.weaknessBg;
    final border = isStrength ? MBTIColors.strengthBorder : MBTIColors.weaknessBorder;
    final textColor = isStrength ? MBTIColors.strengthText : MBTIColors.weaknessText;
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MBTIColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MBTIColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$emoji $title',
            style: const TextStyle(
              color: Color(0xFF4B3A2A),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags
                .map(
                  (t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: border),
                    ),
                    child: Text(
                      t,
                      style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _TipsSection extends StatelessWidget {
  final List<String> tips;
  const _TipsSection({required this.tips});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MBTIColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MBTIColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💡 Gelişim Önerileri',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                tip,
                style: const TextStyle(color: Colors.white70, height: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
