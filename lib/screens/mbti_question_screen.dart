import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors.dart';
import '../data/mbti_data.dart';
import '../models/mbti_models.dart';
import '../services/mbti_calculator.dart';
import '../widgets/mbti/mbti_progress.dart';
import 'mbti_result_screen.dart';

class MBTIQuestionScreen extends StatefulWidget {
  const MBTIQuestionScreen({super.key});

  @override
  State<MBTIQuestionScreen> createState() => _MBTIQuestionScreenState();
}

class _MBTIQuestionScreenState extends State<MBTIQuestionScreen>
    with SingleTickerProviderStateMixin {
  final List<int> _answers = List<int>.filled(mbtiQuestions.length, 0);
  int _current = 0;

  void _selectAnswer(int value) {
    setState(() {
      _answers[_current] = value;
    });
    HapticFeedback.lightImpact();
  }

  void _next() {
    if (_answers[_current] == 0) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir seçim yap.'),
          duration: Duration(milliseconds: 800),
        ),
      );
      return;
    }
    if (_current < mbtiQuestions.length - 1) {
      setState(() {
        _current++;
      });
      HapticFeedback.lightImpact();
    } else {
      _showResult();
    }
  }

  void _prev() {
    if (_current > 0) {
      setState(() => _current--);
    }
  }

  Future<void> _showResult() async {
    final scores = MBTICalculator.calculateScores(_answers);
    final type = MBTICalculator.determineType(scores);
    final perc = MBTICalculator.calculatePercentages(scores);
    final result = MBTIResultData(
      type: type,
      scores: scores,
      percentages: perc,
      date: DateTime.now(),
    );
    await MBTICalculator.saveResult(result);
    HapticFeedback.mediumImpact();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => MBTIResultScreen(result: result)),
    );
  }

  void _debugJumpToResult() {
    final rnd = math.Random();
    final filled = List<int>.generate(
      mbtiQuestions.length,
      (_) => rnd.nextInt(7) + 1,
    );
    setState(() {
      for (var i = 0; i < _answers.length; i++) {
        _answers[i] = filled[i];
      }
    });
    _showResult();
  }

  @override
  Widget build(BuildContext context) {
    final q = mbtiQuestions[_current];
    final progress = (_current + 1) / mbtiQuestions.length;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            if (_current > 0 && _current < mbtiQuestions.length) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: MBTIColors.backgroundDark,
                  title: const Text(
                    'Çıkmak istiyor musun?',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    'Testten çıkarsan ilerlemen kaybolacak.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'İptal',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Çık',
                        style: TextStyle(color: MBTIColors.primaryOrange),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'MBTI Kişilik Testi',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/mbti_bg.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const DecoratedBox(
                decoration: BoxDecoration(gradient: AppColors.bgGradient),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(
                0.08,
              ), // yoğunluğu azalt, okunurluk
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: MBTIProgressBar(value: progress)),
                  const SizedBox(height: 16),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        const Spacer(),
                        Transform.translate(
                          offset: const Offset(0, 20),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                constraints: const BoxConstraints(
                                  minHeight: 200,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.42),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 96, // sabit genişlik
                                      child: Text(
                                        'SORU ${(_current + 1).toString().padLeft(2, '0')}',
                                        style: const TextStyle(
                                          color: MBTIColors.primaryOrange,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    Text(
                                      q.text,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        height: 1.4,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Spacer(),
                        Transform.translate(
                          offset: const Offset(0, -96), // biraz daha aşağı
                          child: Column(
                            children: [
                              Row(
                                children: const [
                                  Text(
                                    'Katılmıyorum',
                                    style: TextStyle(color: Color(0xFF7A5635)),
                                  ),
                                  Spacer(),
                                  Text(
                                    'Kararsızım',
                                    style: TextStyle(color: Color(0xFF7A5635)),
                                  ),
                                  Spacer(),
                                  Text(
                                    'Katılıyorum',
                                    style: TextStyle(color: Color(0xFF7A5635)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Center(
                                child: _LikertRow(
                                  selected: _answers[_current],
                                  onSelect: _selectAnswer,
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -80),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.white,
                              disabledForegroundColor: Colors.black54,
                              disabledBackgroundColor: Colors.white70,
                              side: const BorderSide(
                                color: Colors.white,
                                width: 2,
                              ),
                              disabledMouseCursor: SystemMouseCursors.basic,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _current == 0 ? null : _prev,
                            child: const Text('← Önceki'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE68424),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 2,
                            ),
                            onPressed: _next,
                            child: Text(
                              _current == mbtiQuestions.length - 1
                                  ? 'Sonuçları Gör →'
                                  : 'Sonraki →',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black87,
                        backgroundColor: Colors.white.withOpacity(0.8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _debugJumpToResult,
                      child: const Text('Sunucu Test (Rastgele Sonuç)'),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LikertRow extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  const _LikertRow({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 12,
      children: List.generate(7, (index) {
        final value = index + 1;
        final isSelected = selected == value;
        final size = likertButtonSizes[value]!;
        return AnimatedScale(
          scale: isSelected ? MBTIAnimations.buttonScale : 1.0,
          duration: MBTIAnimations.buttonSelect,
          child: GestureDetector(
            onTap: () => onSelect(value),
            child: AnimatedContainer(
              duration: MBTIAnimations.buttonSelect,
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                      border: Border.all(
                        color: Colors.white,
                        width: isSelected ? 2.6 : 2.2,
                      ),
                    ),
                  ),
                  Container(
                    width: size * 0.8,
                    height: size * 0.8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? MBTIColors.primaryOrange
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
