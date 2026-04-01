import 'package:flutter/material.dart';
import '../models/smart_test_models.dart';

class SmartTestSummaryScreen extends StatelessWidget {
  final SmartTestSubmitResponse response;

  const SmartTestSummaryScreen({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test Results"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
           padding: const EdgeInsets.all(32),
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               const Icon(Icons.check_circle, color: Colors.green, size: 100),
               const SizedBox(height: 20),
               const Text("Test Complete!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
               const SizedBox(height: 20),
               Card(
                 elevation: 4,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                 child: Padding(
                   padding: const EdgeInsets.all(24),
                   child: Column(
                     children: [
                       Text("Score: ${response.score.toStringAsFixed(1)} / 10", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                       const SizedBox(height: 10),
                       Text("Correct Answers: ${response.correctCount} / ${response.totalCount}", style: const TextStyle(fontSize: 18)),
                     ],
                   ),
                 ),
               ),
               const SizedBox(height: 40),
               ElevatedButton(
                 style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                 onPressed: () {
                   Navigator.pop(context); // Return to home/study section
                 },
                 child: const Text("Back to Study Menu"),
               )
             ],
           ),
        ),
      )
    );
  }
}
