import 'package:flutter/material.dart';

class ReadingResultScreen extends StatelessWidget {
  final int score;
  final int total;

  const ReadingResultScreen({
    super.key,
    required this.score,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    double percent = score / total * 100;

    return Scaffold(
      appBar: AppBar(title: const Text("Kết quả")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$score / $total",
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 10),
            Text("${percent.toStringAsFixed(1)}%"),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Làm lại"),
            )
          ],
        ),
      ),
    );
  }
}