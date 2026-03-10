import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final int correct;
  final int wrong;
  final int total;

  const ResultScreen({
    super.key,
    required this.correct,
    required this.wrong,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    double percent = (correct / total) * 100;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1A24),

      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Practice Result",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            Text(
              "${percent.toStringAsFixed(0)}%",
              style: const TextStyle(
                fontSize: 60,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            Text(
              "Correct: $correct",
              style: const TextStyle(color: Colors.green, fontSize: 20),
            ),

            Text(
              "Wrong: $wrong",
              style: const TextStyle(color: Colors.red, fontSize: 20),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Back"),
            ),
          ],
        ),
      ),
    );
  }
}
