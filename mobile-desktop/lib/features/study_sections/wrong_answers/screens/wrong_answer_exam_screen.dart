import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_desktop/core_quiz/models/quiz_question.dart';
import 'package:mobile_desktop/core_quiz/widgets/dynamic_question_builder.dart';
import 'package:mobile_desktop/core/models/quiz_bank_models.dart';
import 'package:mobile_desktop/core/models/wrong_answer.dart';
import 'package:mobile_desktop/core/providers/wrong_answer_provider.dart';

class WrongAnswerExamScreen extends StatefulWidget {
  final List<WrongAnswer> items;

  const WrongAnswerExamScreen({super.key, required this.items});

  @override
  State<WrongAnswerExamScreen> createState() => _WrongAnswerExamScreenState();
}

class _WrongAnswerExamScreenState extends State<WrongAnswerExamScreen> {
  int currentIndex = 0;
  String? selectedId;
  List<int> resolvedIds = [];
  bool isCompleted = false;

  void _nextQuestion(String answerId) {
    final item = widget.items[currentIndex];
    
    // Check if correct
    final quizQ = QuizQuestion.from(Question.fromJson(item.originalJson!));
    if (quizQ.isCorrectChoice(answerId)) {
      resolvedIds.add(item.questionId);
    }

    if (currentIndex < widget.items.length - 1) {
      setState(() {
        currentIndex++;
        selectedId = null;
      });
    } else {
      _finishExam();
    }
  }

  void _finishExam() {
    setState(() {
      isCompleted = true;
    });
    // Remove resolved items from provider
    if (resolvedIds.isNotEmpty) {
      context.read<WrongAnswerProvider>().removeMultipleWrongAnswers(resolvedIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (isCompleted) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hoàn thành luyện tập')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 80, color: Colors.green),
              const SizedBox(height: 24),
              Text(
                'Bạn đã hoàn thành bài luyện tập!',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Đã xóa ${resolvedIds.length} câu khỏi danh sách câu sai.',
                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      );
    }

    final currentItem = widget.items[currentIndex];
    final questionJson = currentItem.originalJson;
    
    if (questionJson == null) {
      return Scaffold(
        body: Center(
          child: Text('Dữ liệu câu hỏi không hợp lệ cho câu ${currentItem.questionId}'),
        ),
      );
    }

    final quizQuestion = QuizQuestion.from(Question.fromJson(questionJson));

    return Scaffold(
      appBar: AppBar(
        title: Text('Luyện tập câu sai (${currentIndex + 1}/${widget.items.length})'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
             DynamicQuestionBuilder(
                question: quizQuestion,
                selectedId: selectedId,
                isAnswered: selectedId != null,
                onAnswer: (id) {
                  setState(() {
                    selectedId = id;
                  });
                },
              ),
              const SizedBox(height: 40),
              if (selectedId != null)
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () => _nextQuestion(selectedId!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text(
                      currentIndex < widget.items.length - 1 ? 'Tiếp tục' : 'Hoàn thành',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
