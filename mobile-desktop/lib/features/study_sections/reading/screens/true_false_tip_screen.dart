import 'package:flutter/material.dart';

class TrueFalseTipScreen extends StatelessWidget {
  const TrueFalseTipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text("Phán đoán đúng sai"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Text(
            """
Each question contains one picture and one word. The candidate must decide whether the word matches the picture.

In this section, candidates should first pay attention to understanding the differences between words within the same category.

For example:

Means of transportation
“airplane, taxi, bicycle”

Actions
“listen, write, read”

Feelings / temperature
“cold, hot”

Next, candidates should understand the difference between a general category and a specific item within that category.

For example:

“fruit” and “apple”
""",
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}