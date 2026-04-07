import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/question_service.dart';
import 'smart_exam_screen.dart';
import 'reading_tips_screen.dart';

class ReadingScreen extends StatefulWidget {
  const ReadingScreen({super.key});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  int totalAnswers = 0;
  int correctAnswers = 0;
  int totalTime = 0;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  void loadStats() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      totalAnswers = prefs.getInt("totalAnswers") ?? 0;
      correctAnswers = prefs.getInt("correctAnswers") ?? 0;
      totalTime = prefs.getInt("totalTime") ?? 0;
    });
  }

  String formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }



  Future<void> startExam(BuildContext context) async {
    try {

      final examId = await QuestionService.createExam(
        examType: "reading",
        totalQuestions: 10,
      );

      final questions = await QuestionService.getQuestions(
        skill: "reading",
        difficulty: "easy",
        limit: 10,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SmartExamScreen(
            questions: questions,
            examId: examId,
          ),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("$e")));
    }
  }


  @override
  Widget build(BuildContext context) {
    double mastery =
    totalAnswers == 0 ? 0 : correctAnswers / totalAnswers;

    return Scaffold(
      backgroundColor: const Color(0xFF1E2A38),

      body: Column(
        children: [
          _buildHeader(context, mastery),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 10),

                const SectionTitle(title: "Phần 1"),
                ReadingPartCard(
                  title: "Phán đoán đúng sai",
                  onTap: () => startExam(context),
                ),

                const SizedBox(height: 20),

                const SectionTitle(title: "Phần 2"),
                ReadingPartCard(
                  title: "Chọn hình ảnh tương ứng",
                  onTap: () => startExam(context),
                ),

                const SizedBox(height: 20),

                const SectionTitle(title: "Phần 3"),
                ReadingPartCard(
                  title: "Chọn câu tương ứng",
                  onTap: () => startExam(context),
                ),

                const SizedBox(height: 20),

                const SectionTitle(title: "Phần 4"),
                ReadingPartCard(
                  title: "Điền vào chỗ trống",
                  onTap: () => startExam(context),
                ),
              ],
            ),
          ),
        ],
      ),

      // ===== BUTTONS =====
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ReadingTipsScreen(),
                    ),
                  );
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Center(
                    child: Text(
                      "Bí kíp làm bài",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: GestureDetector(
                onTap: () => startExam(context),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.lightBlueAccent],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Center(
                    child: Text(
                      "Làm bài ngay",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ===== HEADER =====
  Widget _buildHeader(BuildContext context, double mastery) {
    return Container(
      padding: const EdgeInsets.only(
          top: 50, left: 20, right: 20, bottom: 30),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xffffb74d), Color(0xffff9800)],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    "Đọc hiểu",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48)
            ],
          ),

          const SizedBox(height: 25),

          _buildStatRow("Tổng số câu", "$totalAnswers"),
          const SizedBox(height: 10),

          _buildStatRow("Số câu đúng", "$correctAnswers"),
          const SizedBox(height: 10),

          _buildStatRow("Thời gian", formatTime(totalTime)),

          const SizedBox(height: 15),

          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              const Text("Nắm vững",
                  style: TextStyle(color: Colors.white)),
              Text(
                "${(mastery * 100).toStringAsFixed(0)}%",
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),

          const SizedBox(height: 6),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: mastery,
              minHeight: 8,
              backgroundColor: Colors.white30,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String title, String value) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(color: Colors.white)),
        Text(value,
            style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}

// ===== COMPONENT =====

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
      ),
    );
  }
}

class ReadingPartCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const ReadingPartCard({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 16)
          ],
        ),
      ),
    );
  }
}