import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/mbti_data.dart';
import '../models/mbti_models.dart';
import '../services/mbti_calculator.dart';

class MBTIScreen extends StatefulWidget {
  const MBTIScreen({super.key});

  @override
  State<MBTIScreen> createState() => _MBTIScreenState();
}

class _MBTIScreenState extends State<MBTIScreen> {
  int _stage = 0; // 0 intro, 1 questions, 2 result
  int _currentQuestion = 0;
  final List<int?> _answers = List<int?>.filled(mbtiQuestions.length, null);
  MBTIResult? _result;

  void _startTest() {
    setState(() {
      _stage = 1;
    });
  }

  void _selectAnswer(int value) {
    HapticFeedback.lightImpact();
    setState(() {
      _answers[_currentQuestion] = value;
      if (_currentQuestion < mbtiQuestions.length - 1) {
        _currentQuestion++;
      } else {
        _calculateResult();
      }
    });
  }

  void _prevQuestion() {
    if (_currentQuestion == 0) return;
    setState(() => _currentQuestion--);
  }

  void _nextQuestion() {
    if (_answers[_currentQuestion] == null) {
      HapticFeedback.heavyImpact();
      return;
    }
    if (_currentQuestion < mbtiQuestions.length - 1) {
      setState(() => _currentQuestion++);
    } else {
      _calculateResult();
    }
  }

  void _calculateResult() {
    final filled = _answers.whereType<int>().toList();
    if (filled.length != mbtiQuestions.length) return;
    _result = MBTICalculator.buildResult(_answers.whereType<int>().toList());
    MBTICalculator.saveResult(_result!);
    HapticFeedback.mediumImpact();
    setState(() {
      _stage = 2;
    });
  }

  void _restart() {
    setState(() {
      _stage = 0;
      _currentQuestion = 0;
      for (var i = 0; i < _answers.length; i++) {
        _answers[i] = null;
      }
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MBTIColors.backgroundDark,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: MBTIAnimations.questionTransition,
          child: _buildStage(),
        ),
      ),
    );
  }

  Widget _buildStage() {
    switch (_stage) {
      case 0:
        return _Intro(onStart: _startTest);
      case 1:
        return _QuestionView(
          current: _currentQuestion,
          answers: _answers,
          onSelect: _selectAnswer,
          onNext: _nextQuestion,
          onPrev: _prevQuestion,
        );
      case 2:
        return _ResultView(result: _result!, onRestart: _restart);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _Intro extends StatelessWidget {
  final VoidCallback onStart;
  const _Intro({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D1B2A), Color(0xFF0A1420)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              const Text('🧠', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 16),
              const Text(
                'Kendini Keşfet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Jung'un psikolojik tipler teorisine dayanan bu test, kişiliğinin 5 temel boyutunu ölçer ve seni 16 kişilik tipinden birine yerleştirir.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  _StatBlock(value: '60', label: 'Soru'),
                  _StatBlock(value: '10-15', label: 'Dakika'),
                  _StatBlock(value: '16', label: 'Tip'),
                ],
              ),
              const SizedBox(height: 24),
              _AxisPreview(),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MBTIColors.primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Teste Başla →',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Soruları içgüdüsel olarak yanıtla, çok düşünme.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String value;
  final String label;
  const _StatBlock({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFFFA733),
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _AxisPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const rows = [
      ('E', 'Dışadönük', 'I', 'İçedönük'),
      ('S', 'Duyusal', 'N', 'Sezgisel'),
      ('T', 'Düşünen', 'F', 'Hisseden'),
      ('J', 'Yargılayan', 'P', 'Algılayan'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Eksenler',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            children: rows
                .map(
                  (r) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        _AxisPill(letter: r.$1),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            r.$2,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const Text(
                          'vs',
                          style: TextStyle(
                            color: Colors.white54,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              r.$4,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _AxisPill(letter: r.$3, isRight: true),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _AxisPill extends StatelessWidget {
  final String letter;
  final bool isRight;
  const _AxisPill({required this.letter, this.isRight = false});

  @override
  Widget build(BuildContext context) {
    final color = isRight ? const Color(0xFF4B5667) : const Color(0xFFFFA733);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _QuestionView extends StatelessWidget {
  final int current;
  final List<int?> answers;
  final void Function(int value) onSelect;
  final VoidCallback onNext;
  final VoidCallback onPrev;

  const _QuestionView({
    required this.current,
    required this.answers,
    required this.onSelect,
    required this.onNext,
    required this.onPrev,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (current + 1) / mbtiQuestions.length;
    final question = mbtiQuestions[current];
    final selected = answers[current];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 6),
              const Text(
                '🧠  MBTI Kişilik Testi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${current + 1} / ${mbtiQuestions.length}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ProgressBar(value: progress),
          const SizedBox(height: 12),
          Expanded(
            child: AnimatedSwitcher(
              duration: MBTIAnimations.questionTransition,
              transitionBuilder: (child, anim) {
                final offsetAnim =
                    Tween<Offset>(
                      begin: const Offset(0.1, 0.0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(parent: anim, curve: Curves.easeInOut),
                    );
                return FadeTransition(
                  opacity: anim,
                  child: SlideTransition(position: offsetAnim, child: child),
                );
              },
              child: _QuestionCard(
                key: ValueKey(current),
                question: question.text,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Katılmıyorum',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
              Text(
                'Katılıyorum',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _LikertRow(selected: selected, onSelect: onSelect),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: current == 0 ? null : onPrev,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('← Önceki'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MBTIColors.primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    current == mbtiQuestions.length - 1
                        ? 'Sonuçları Gör →'
                        : 'Sonraki →',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final String question;
  const _QuestionCard({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: MBTIColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: MBTIColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  const _ProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: MBTIAnimations.progressFill,
            curve: MBTIAnimations.progressCurve,
            width: MediaQuery.of(context).size.width * value,
            decoration: BoxDecoration(
              gradient: MBTIColors.progressGradient,
              borderRadius: BorderRadius.circular(3),
              boxShadow: const [
                BoxShadow(color: Color(0x80F7941D), blurRadius: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LikertRow extends StatelessWidget {
  final int? selected;
  final void Function(int value) onSelect;
  const _LikertRow({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final val = i + 1;
        final size = likertButtonSizes[val]!;
        final color = likertButtonColors[val]!;
        final isSel = selected == val;
        return GestureDetector(
          onTap: () => onSelect(val),
          child: AnimatedScale(
            scale: isSel ? MBTIAnimations.buttonScale : 1.0,
            duration: MBTIAnimations.buttonSelect,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(isSel ? 1.0 : 0.3),
                border: Border.all(
                  color: Colors.white.withOpacity(isSel ? 0.8 : 0.2),
                  width: isSel ? 2 : 1,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ResultView extends StatelessWidget {
  final MBTIResult result;
  final VoidCallback onRestart;
  const _ResultView({required this.result, required this.onRestart});

  @override
  Widget build(BuildContext context) {
    final baseCode = result.type.split('-').first;
    final type = mbtiTypes[baseCode]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 6),
              const Text(
                '🧠 MBTI Sonuç',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ResultHeader(type: type, fullType: result.type),
          const SizedBox(height: 16),
          _AxisBars(result: result),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Genel Açıklama',
            child: Text(
              type.description,
              style: const TextStyle(color: Colors.white70, height: 1.4),
            ),
          ),
          const SizedBox(height: 12),
          _TagSection(
            title: 'Güçlü Yönler',
            emoji: '💪',
            items: type.strengths,
            color: MBTIColors.strengthText,
            bg: MBTIColors.strengthBg,
            border: MBTIColors.strengthBorder,
          ),
          const SizedBox(height: 12),
          _TagSection(
            title: 'Zayıf Yönler',
            emoji: '⚠️',
            items: type.weaknesses,
            color: MBTIColors.weaknessText,
            bg: MBTIColors.weaknessBg,
            border: MBTIColors.weaknessBorder,
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'İlişkiler',
            child: Text(
              type.relationships,
              style: const TextStyle(color: Colors.white70, height: 1.4),
            ),
          ),
          const SizedBox(height: 12),
          _ListSection(title: 'Kariyer', emoji: '💼', items: type.careers),
          const SizedBox(height: 12),
          _ListSection(title: 'Ünlüler', emoji: '⭐', items: type.famous),
          const SizedBox(height: 12),
          _ListSection(
            title: 'Uyumlu Tipler',
            emoji: '💕',
            items: type.compatible,
          ),
          const SizedBox(height: 12),
          _ListSection(
            title: 'Gelişim İpuçları',
            emoji: '💡',
            items: type.tips,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRestart,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Tekrarla'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // share placeholder
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MBTIColors.primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Paylaş'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  final MBTIType type;
  final String fullType;
  const _ResultHeader({required this.type, required this.fullType});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: MBTIColors.resultHeaderGradient,
        border: Border.all(color: const Color(0x33F7941D)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fullType,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(type.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                '${type.name} • ${type.nickname}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AxisBars extends StatelessWidget {
  final MBTIResult result;
  const _AxisBars({required this.result});

  @override
  Widget build(BuildContext context) {
    const axes = ['EI', 'SN', 'TF', 'JP', 'AT'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: axes.map((axis) {
        final desc = axisDescriptions[axis]!;
        final percent = result.percentages[axis]!;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _AxisBar(
            descriptor: desc,
            percentLeft: percent,
            onTap: () => _showAxisInfo(context, desc),
          ),
        );
      }).toList(),
    );
  }

  void _showAxisInfo(BuildContext context, AxisDescriptor desc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A1A1F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  desc.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${desc.left.emoji} ${desc.left.letter} ${desc.left.name}\n${desc.left.description}',
              style: const TextStyle(color: Colors.white70, height: 1.4),
            ),
            const SizedBox(height: 10),
            Text(
              '${desc.right.emoji} ${desc.right.letter} ${desc.right.name}\n${desc.right.description}',
              style: const TextStyle(color: Colors.white70, height: 1.4),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _AxisBar extends StatelessWidget {
  final AxisDescriptor descriptor;
  final int percentLeft; // 0-100
  final VoidCallback onTap;

  const _AxisBar({
    required this.descriptor,
    required this.percentLeft,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percentRight = 100 - percentLeft;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0x0DFFFFFF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _AxisLabel(side: descriptor.left),
                const Spacer(),
                _AxisLabel(side: descriptor.right, alignEnd: true),
              ],
            ),
            const SizedBox(height: 10),
            Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0x14FFFFFF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      flex: percentLeft,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: descriptor.left.color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: percentRight,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: descriptor.right.color.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AxisLabel extends StatelessWidget {
  final AxisSide side;
  final bool alignEnd;
  const _AxisLabel({required this.side, this.alignEnd = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(side.emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: alignEnd
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              side.letter,
              style: TextStyle(
                color: side.color,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            Text(
              side.name,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _TagSection extends StatelessWidget {
  final String title;
  final String emoji;
  final List<String> items;
  final Color color;
  final Color bg;
  final Color border;
  const _TagSection({
    required this.title,
    required this.emoji,
    required this.items,
    required this.color,
    required this.bg,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '$emoji $title',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items
            .map(
              (e) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: bg,
                  border: Border.all(color: border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  e,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ListSection extends StatelessWidget {
  final String title;
  final String emoji;
  final List<String> items;
  const _ListSection({
    required this.title,
    required this.emoji,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '$emoji $title',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '• $e',
                  style: const TextStyle(color: Colors.white70, height: 1.3),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
