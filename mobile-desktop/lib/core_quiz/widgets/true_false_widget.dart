import 'package:flutter/material.dart';

class TrueFalseWidget extends StatelessWidget {
  final String questionText;
  final bool isAnswered;
  final bool? result; 
  final void Function(bool choice) onAnswer;

  const TrueFalseWidget({
    super.key,
    required this.questionText,
    required this.isAnswered,
    this.result,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            questionText,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        if (isAnswered && result != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  result! ? Icons.check_circle : Icons.cancel,
                  color: result! ? Colors.green : Colors.red,
                  size: 32,
                ),
                const SizedBox(width: 8),
                Text(
                  result! ? "Correct" : "Incorrect",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: result! ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: !isAnswered ? () => onAnswer(true) : null,
                child: Container(
                  height: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: isAnswered 
                      ? (result != null && result == true ? Colors.green.withOpacity(0.5) : Colors.grey.shade300)
                      : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      "TRUE",
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: !isAnswered ? () => onAnswer(false) : null,
                child: Container(
                  height: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: isAnswered 
                      ? (result != null && result == false ? Colors.red.withOpacity(0.5) : Colors.grey.shade300)
                      : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      "FALSE",
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}