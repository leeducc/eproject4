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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Kết quả"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$score / $total",
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 10),
            Text(
              "${percent.toStringAsFixed(1)}%",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 30),

            // Nút làm lại
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // quay lại trang exam
              },
              child: const Text("Làm lại"),
            )
          ],
        ),
      ),
    );
  }
}