import 'package:flutter/material.dart';
import '../data/mbti_data.dart';
import '../widgets/mbti/mbti_progress.dart';
import 'mbti_question_screen.dart';

class MBTIIntroScreen extends StatelessWidget {
  const MBTIIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MBTIColors.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🧠', style: TextStyle(fontSize: 26)),
                  const SizedBox(width: 10),
                  const Text(
                    'MBTI Kişilik Testi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '16 kişilik tipinden hangisisin?',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: MBTIColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: MBTIColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Kendini Keşfet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Jung\'un psikolojik tipler teorisine dayanan bu test, kişiliğinin 5 temel boyutunu ölçer ve seni 16 kişilik tipinden birine yerleştirir.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 16),
                    _InfoRow(),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: MBTIColors.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: MBTIColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Eksen Önizlemesi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _AxisPreview(axis: 'EI', left: 'E', right: 'I', title: 'Enerji'),
                      _AxisPreview(axis: 'SN', left: 'S', right: 'N', title: 'Düşünce'),
                      _AxisPreview(axis: 'TF', left: 'T', right: 'F', title: 'Karar'),
                      _AxisPreview(axis: 'JP', left: 'J', right: 'P', title: 'Yaşam Tarzı'),
                      _AxisPreview(axis: 'AT', left: 'A', right: 'T', title: 'Kimlik'),
                      const Spacer(),
                      const Text(
                        'Sonuçlar cihazında saklanır.',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MBTIColors.primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MBTIQuestionScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Teste Başla →',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w800,
    );
    return Row(
      children: const [
        _InfoChip(label: '60 Soru', style: style),
        SizedBox(width: 12),
        _InfoChip(label: '10-15 dk', style: style),
        SizedBox(width: 12),
        _InfoChip(label: '16 Tip', style: style),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final TextStyle style;
  const _InfoChip({required this.label, required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: style),
    );
  }
}

class _AxisPreview extends StatelessWidget {
  final String axis;
  final String left;
  final String right;
  final String title;

  const _AxisPreview({
    required this.axis,
    required this.left,
    required this.right,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> desc = axisDescriptions[axis]! as Map<String, dynamic>;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '${(desc['left'] as Map)['emoji']} $left',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: MBTIProgressBar(
              value: 0.5,
              height: 6,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$right ${(desc['right'] as Map)['emoji']}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
