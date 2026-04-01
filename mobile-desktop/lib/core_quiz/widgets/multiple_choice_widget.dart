import 'package:flutter/material.dart';
import '../models/quiz_option.dart';

class MultipleChoiceWidget extends StatelessWidget {
  final String questionText;
  final List<QuizOption> options;
  final List<String> correctIds;
  final String? selectedId;
  final bool isAnswered;
  final void Function(String id) onSelect;

  const MultipleChoiceWidget({
    super.key,
    required this.questionText,
    required this.options,
    required this.correctIds,
    this.selectedId,
    required this.isAnswered,
    required this.onSelect,
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        ...options.map((option) {
          final isSelected = selectedId == option.id;
          final isCorrect = correctIds.contains(option.id);

          Color? backgroundColor;
          Color textColor = Colors.black87;

          if (isAnswered) {
            if (isCorrect) {
              backgroundColor = Colors.green;
              textColor = Colors.white;
            } else if (isSelected) {
              backgroundColor = Colors.red;
              textColor = Colors.white;
            } else {
              backgroundColor = Colors.grey.withOpacity(0.1);
              textColor = Colors.black38;
            }
          } else if (isSelected) {
            backgroundColor = Colors.blueAccent;
            textColor = Colors.white;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: textColor,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                elevation: isSelected ? 4 : 0,
                side: BorderSide(
                  color: isAnswered && (isCorrect || isSelected)
                      ? Colors.transparent
                      : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: isAnswered ? null : () => onSelect(option.id),
              child: Text(
                option.label,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
