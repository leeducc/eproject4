import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../services/question_service.dart';

class ExamScreen extends StatefulWidget {
  final int examId;
  final List<Question> questions;

  const ExamScreen({
    super.key,
    required this.questions,
    required this.examId ,
  });


  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen>
    with SingleTickerProviderStateMixin {

  late List<Question> questions;
  List<Map<String, dynamic>> answers = [];

  int current = 0;
  int? selected;
  int score = 0;

  int seconds = 0;
  Timer? timer;


  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    questions = List.from(widget.questions);
    questions.shuffle(Random());

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => seconds++);
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  String formatTime() {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {

    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Không có câu hỏi")),
      );
    }

    Question q = questions[current];
    double progress = (current + 1) / questions.length;

    return Scaffold(
      backgroundColor: const Color(0xfff4f6fa),

      appBar: AppBar(
        title: Text("Câu ${current + 1}/${questions.length}"),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                formatTime(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
              ),
            ),

            const SizedBox(height: 20),

            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  q.question,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: q.options.length,
                itemBuilder: (_, i) {

                  bool isSelected = selected == i;
                  bool isCorrect = i == q.correctIndex;

                  Color bg = Colors.white;
                  Color border = Colors.grey.shade300;

                  if (selected != null) {
                    if (isCorrect) {
                      bg = Colors.green.withOpacity(0.2);
                      border = Colors.green;
                    } else if (isSelected) {
                      bg = Colors.red.withOpacity(0.2);
                      border = Colors.red;
                    }
                  }

                  return GestureDetector(
                    onTap: () {
                      if (selected == null) {
                        setState(() => selected = i);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              q.options[i],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          if (selected != null)
                            if (isCorrect)
                              const Icon(Icons.check, color: Colors.green)
                            else if (isSelected)
                              const Icon(Icons.close, color: Colors.red)
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            /// NEXT BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: selected == null ? null : nextQuestion,
                child: Text(
                  current == questions.length - 1
                      ? "Hoàn thành"
                      : "Câu tiếp",
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void nextQuestion() async {
    answers.removeWhere(
          (e) => e['questionId'] == questions[current].id,
    );

    answers.add({ 'questionId': questions[current].id,
      'selectedAnswer': questions[current].options[selected!],
      'correctAnswer': questions[current].options[questions[current].correctIndex],
      'selectedIndex': selected, 'correctIndex': questions[current].correctIndex,
      'isCorrect': selected == questions[current].correctIndex, });
    int finalScore = answers.where((e) => e['isCorrect'] == true).length;


    if (current < questions.length - 1) {
      _controller.reset();
      _controller.forward();

      setState(() {
        current++;
        selected = null;
      });
    } else {
      timer?.cancel();

      try {
        await QuestionService.submitExam(
          examId: widget.examId,
          score: finalScore,
          answers: answers,
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi submit bài: $e'),
            ),
          );
        }
      }

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Kết quả"),
          content: Text( "Điểm: $finalScore/${questions.length}\n"
              "Thời gian: ${formatTime()}\n"
              "Exam ID: ${widget.examId}", ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("OK"),
            )
          ],
        ),
      );
    }
  }
}