import 'package:flutter/material.dart';
import '../services/question_service.dart';
import '../models/question_model.dart';
import 'exam_screen.dart';

class SmartExamSetupScreen extends StatefulWidget {
  const SmartExamSetupScreen({super.key});

  @override
  State<SmartExamSetupScreen> createState() => _SmartExamSetupScreenState();
}

class _SmartExamSetupScreenState extends State<SmartExamSetupScreen> {

  String level = "7-8";
  String skill = "Both";
  String duration = "20";

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [

          /// BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff9fd3c7),
                  Color(0xff89a6f5),
                ],
              ),
            ),

            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [

                    /// BACK
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),

                    const Text(
                      "Ra Đề Thông Minh",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// MAIN BOX
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          sectionTitle("Cấp độ"),
                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              levelButton("0-4"),
                              levelButton("5-6"),
                              levelButton("7-8"),
                              levelButton("9"),
                            ],
                          ),

                          const SizedBox(height: 25),

                          sectionTitle("Kỹ năng"),
                          const SizedBox(height: 10),

                          Row(
                            children: [
                              skillButton("Listening"),
                              const SizedBox(width: 10),
                              skillButton("Reading"),
                              const SizedBox(width: 10),
                              skillButton("Both"),
                            ],
                          ),

                          const SizedBox(height: 25),

                          sectionTitle("Số câu"),
                          const SizedBox(height: 10),

                          Row(
                            children: [
                              durationButton("10"),
                              const SizedBox(width: 10),
                              durationButton("20"),
                              const SizedBox(width: 10),
                              durationButton("40"),
                            ],
                          ),

                          const SizedBox(height: 30),

                          /// BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : generateExam,
                              child: isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text("Tạo đề thi"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= API CALL =================
  void generateExam() async {
    setState(() => isLoading = true);

    try {
      int limit = int.parse(duration);

      String examType;

      if (skill == "Both") {
        examType = "MIXED";
      } else {
        examType = skill.toUpperCase();
      }

      final int examId = await QuestionService.createExam(
        examType: examType,
        totalQuestions: limit,
      );

      final List<Question> questions = await QuestionService.getQuestions(
        skill: skill == "Both" ? null : skill.toLowerCase(),
        difficulty: level,
        limit: limit,
      );

      setState(() => isLoading = false);

      if (questions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Không có câu hỏi"),
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ExamScreen(
            examId: examId,
            questions: questions,
          ),
        ),
      );
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi API: $e"),
        ),
      );
    }
  }

  /// ================= UI =================

  Widget sectionTitle(String text) {
    return Text(text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget levelButton(String text) {
    bool selected = level == text;

    return GestureDetector(
      onTap: () => setState(() => level = text),
      child: Container(
        width: 65,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: selected ? Colors.blue : Colors.grey.shade200,
        ),
        child: Text(text,
            style: TextStyle(
                color: selected ? Colors.white : Colors.black)),
      ),
    );
  }

  Widget skillButton(String text) {
    bool selected = skill == text;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => skill = text),
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.green : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(text,
              style: TextStyle(
                  color: selected ? Colors.white : Colors.black)),
        ),
      ),
    );
  }

  Widget durationButton(String text) {
    bool selected = duration == text;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => duration = text),
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.orange : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text("$text câu",
              style: TextStyle(
                  color: selected ? Colors.white : Colors.black)),
        ),
      ),
    );
  }
}