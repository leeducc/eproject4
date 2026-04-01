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
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Text(
            questionText,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        ...options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isSelected = selectedId == option.id;
          final isCorrect = correctIds.contains(option.id);
          final prefix = String.fromCharCode(65 + index); // A, B, C...

          Color backgroundColor = const Color(0xFF2C313D);
          Color textColor = Colors.white;
          Color prefixColor = Colors.grey;

          if (isAnswered) {
            if (isCorrect) {
              backgroundColor = Colors.green.withOpacity(0.2);
              textColor = Colors.greenAccent;
              prefixColor = Colors.greenAccent;
            } else if (isSelected) {
              backgroundColor = Colors.red.withOpacity(0.2);
              textColor = Colors.redAccent;
              prefixColor = Colors.redAccent;
            } else {
              textColor = Colors.white38;
            }
          } else if (isSelected) {
            backgroundColor = const Color(0xFF42A5F5).withOpacity(0.2);
            textColor = const Color(0xFF42A5F5);
            prefixColor = const Color(0xFF42A5F5);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: isAnswered ? null : () => onSelect(option.id),
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isSelected || (isAnswered && isCorrect)
                        ? (isCorrect ? Colors.green : const Color(0xFF42A5F5))
                        : Colors.white10,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      "$prefix ",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: prefixColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option.label,
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
