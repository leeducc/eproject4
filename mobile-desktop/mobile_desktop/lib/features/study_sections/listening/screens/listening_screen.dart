import 'package:flutter/material.dart';
import 'true_false_screen.dart';

class ListeningScreen extends StatelessWidget {
  const ListeningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    int total = 5;
    int done = 2;
    double progress = done / total;

    return Scaffold(
      appBar: AppBar(title: const Text("Listening")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _section("Section 1"),
            _menuCard(
              context,
              "True / False",
              done,
              total,
              progress,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TrueFalseScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _section("Section 2"),
            _menuCard(context, "Coming Soon", 0, 0, 0, () {}),
          ],
        ),
      ),
    );
  }

  Widget _section(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: const TextStyle(color: Colors.grey, fontSize: 12)),
    ),
  );

  Widget _menuCard(BuildContext context, String title, int done, int total,
      double progress, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18)),
                  Text("$done/$total"),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 6),
              Text("Progress ${(progress * 100).toInt()}%"),
            ],
          ),
        ),
      ),
    );
  }
}