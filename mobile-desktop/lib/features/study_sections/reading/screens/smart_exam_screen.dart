import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/question_model.dart';
import 'reading_result_screen.dart';

class SmartExamScreen extends StatefulWidget {

  final List<Question> questions;
  final int examId;

  const SmartExamScreen({
    super.key,
    required this.questions,
    required this.examId,
  });

  @override
  State<SmartExamScreen> createState() => _SmartExamScreenState();
}

class _SmartExamScreenState extends State<SmartExamScreen> {

  int index = 0;
  int score = 0;
  int? selected;
  late int _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now().millisecondsSinceEpoch;
  }

  Future<void> submitExam() async {

    try {

      final uri = Uri.parse(
        "http://10.0.2.2:8080/api/v1/exams/${widget.examId}",
      );

      await http.put(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "score": score
        }),
      );

    } catch (e) {
      print("Submit lỗi: $e");
    }
  }

  void nextQuestion() {

    Question q = widget.questions[index];

    if (selected == q.correctIndex) {
      score++;
      q.status = 2;
    } else {
      q.status = 1;
    }

    if (index < widget.questions.length - 1) {

      setState(() {
        index++;
        selected = null;
      });

    } else {

      submitExam();

      int totalTime = (DateTime.now().millisecondsSinceEpoch - _startTime) ~/ 1000;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReadingResultScreen(
            score: score,
            total: widget.questions.length,
            time: totalTime,
            image: '',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    Question q = widget.questions[index];

    double progress = (index + 1) / widget.questions.length;

    return Scaffold(

      backgroundColor: const Color(0xfff4f6fa),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Question ${index + 1}/${widget.questions.length}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xff4facfe),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            // PROGRESS BAR
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation(
                  Color(0xff4facfe),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // QUESTION
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                q.question,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // OPTIONS
            Expanded(
              child: ListView.builder(
                itemCount: q.options.length,
                itemBuilder: (_, i){

                  bool isSelected = selected == i;
                  bool isCorrect = i == q.correctIndex;

                  Color bgColor = Colors.white;
                  Color borderColor = Colors.grey.shade300;

                  if (selected != null) {

                    if (isCorrect) {
                      bgColor = Colors.green.withOpacity(0.2);
                      borderColor = Colors.green;
                    }

                    if (isSelected && !isCorrect) {
                      bgColor = Colors.red.withOpacity(0.2);
                      borderColor = Colors.red;
                    }
                  }

                  return GestureDetector(

                    onTap: (){
                      if (selected == null) {
                        setState(() {
                          selected = i;
                        });
                      }
                    },

                    child: Container(

                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),

                      child: Row(
                        children: [

                          Expanded(
                            child: Text(
                              q.options[i],
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
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

            // NEXT BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff4facfe),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: selected == null ? null : nextQuestion,
                child: const Text(
                  "Next Question",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}