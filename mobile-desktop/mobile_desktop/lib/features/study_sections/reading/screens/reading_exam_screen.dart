import 'package:flutter/material.dart';
import '../models/reading_question_model.dart';
import 'reading_result_screen.dart';

class ReadingExamScreen extends StatefulWidget {
  final String title;
  const ReadingExamScreen({super.key, required this.title});

  @override
  State<ReadingExamScreen> createState() => _ReadingExamScreenState();
}

class _ReadingExamScreenState extends State<ReadingExamScreen> {
  int currentIndex = 0;
  int? selectedIndex;
  int score = 0;

  final List<ReadingQuestion> questions = [
    ReadingQuestion(
      question: "小明喜欢喝什么？",
      options: ["牛奶", "咖啡", "茶", "水"],
      correctIndex: 2,
    ),
    ReadingQuestion(
      question: "今天天气怎么样？",
      options: ["热", "冷", "下雨", "晴天"],
      correctIndex: 3,
    ),
  ];

  void nextQuestion() {
    if (selectedIndex == questions[currentIndex].correctIndex) {
      score++;
    }

    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedIndex = null;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReadingResultScreen(
            score: score,
            total: questions.length,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (currentIndex + 1) / questions.length,
              color: Colors.orange,
            ),
            const SizedBox(height: 30),
            Text(
              question.question,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ...List.generate(question.options.length, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: selectedIndex == index
                          ? Colors.orange
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(question.options[index]),
                ),
              );
            }),
            const Spacer(),
            ElevatedButton(
              onPressed: selectedIndex == null ? null : nextQuestion,
              child: const Text("Tiếp tục"),
            )
          ],
        ),
      ),
    );
  }
}