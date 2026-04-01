import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exam_provider.dart';
import '../../../../core/models/quiz_bank_models.dart';

/// Bottom sheet that displays a grid of all question numbers for the current section.
/// Shows answered (blue), flagged (flag icon), current (bordered), and unanswered (outline) states.
class QuestionMapSheet extends StatelessWidget {
  final List<Question> questions;
  final int currentIndex;

  const QuestionMapSheet({
    Key? key,
    required this.questions,
    required this.currentIndex,
  }) : super(key: key);

  static void show(BuildContext context, List<Question> questions, int currentIndex) {
    print('[QuestionMapSheet] Showing with ${questions.length} questions, current=$currentIndex');
    // Capture the provider before opening modal (modal creates a new route = new context)
    final provider = Provider.of<ExamProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ChangeNotifierProvider<ExamProvider>.value(
        value: provider,
        child: QuestionMapSheet(
          questions: questions,
          currentIndex: currentIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExamProvider>(
      builder: (context, provider, _) {
        final state = provider.state;
        if (state == null) return const SizedBox.shrink();

        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1E2E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Question Map', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  _LegendDot(color: Colors.blueAccent, label: 'Answered'),
                  const SizedBox(width: 12),
                  _LegendDot(color: Colors.orangeAccent, label: 'Flagged'),
                  const SizedBox(width: 12),
                  _LegendDot(color: Colors.white24, label: 'Empty'),
                ],
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.0,
                ),
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final q = questions[index];
                  final isCurrentQ = index == currentIndex;
                  final isAnswered = state.userAnswers.containsKey(q.id) && state.userAnswers[q.id] != null;
                  final isFlagged = state.flaggedQuestions.contains(q.id);

                  Color bgColor = Colors.transparent;
                  Color borderColor = Colors.white24;
                  Color textColor = Colors.white54;

                  if (isAnswered) {
                    bgColor = Colors.blueAccent;
                    borderColor = Colors.blueAccent;
                    textColor = Colors.white;
                  }
                  if (isFlagged) {
                    bgColor = Colors.orangeAccent.withOpacity(0.3);
                    borderColor = Colors.orangeAccent;
                    textColor = Colors.orangeAccent;
                  }
                  if (isCurrentQ) {
                    borderColor = Colors.white;
                    textColor = Colors.white;
                  }

                  return GestureDetector(
                    onTap: () {
                      print('[QuestionMapSheet] Jump to question index $index (id=${q.id})');
                      provider.jumpToQuestion(index);
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: borderColor,
                          width: isCurrentQ ? 2.0 : 1.0,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: isCurrentQ ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                          if (isFlagged)
                            Positioned(
                              top: 2, right: 2,
                              child: Icon(Icons.flag, size: 8, color: Colors.orangeAccent),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }
}
