import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {

  final int score;
  final int total;

  const ResultScreen({
    super.key,
    required this.score,
    required this.total
  });

  @override
  Widget build(BuildContext context) {

    double percent = score / total * 100;

    return Scaffold(

      appBar: AppBar(
        title: const Text("Result"),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(
              "$score / $total",
              style: const TextStyle(fontSize:40),
            ),

            const SizedBox(height:20),

            Text(
              "${percent.toStringAsFixed(1)} %",
              style: const TextStyle(fontSize:24),
            ),

            const SizedBox(height:30),

            ElevatedButton(
              onPressed: (){
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text("Back to Home"),
            )

          ],
        ),
      ),
    );
  }
}