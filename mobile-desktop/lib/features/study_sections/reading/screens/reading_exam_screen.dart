import 'package:flutter/material.dart';
import 'package:mobile_desktop/features/study_sections/reading/screens/reading_question.dart';
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
      question: "What does Xiaoming like to drink?",
      options: ["Milk", "Coffee", "Tea", "Water"],
      correctIndex: 2,
    ),
    ReadingQuestion(
      question: "How is the weather today?",
      options: ["Hot", "Cold", "Rainy", "Sunny"],
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

      // ===== APPBAR (ĐÃ THÊM NÚT QUAY LẠI) =====
      appBar: AppBar(
        backgroundColor: const Color(0xffff9800),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
      ),

      // ===== BODY =====
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // ===== PROGRESS BAR =====
            LinearProgressIndicator(
              value: (currentIndex + 1) / questions.length,
              color: Colors.orange,
            ),

            const SizedBox(height: 30),

            // ===== QUESTION =====
            Text(
              question.question,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 20),

            // ===== OPTIONS =====
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: selectedIndex == index
                          ? Colors.orange
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          question.options[index],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const Spacer(),

            // ===== NEXT BUTTON =====
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: selectedIndex == null ? null : nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Tiếp tục",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}