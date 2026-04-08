import 'package:flutter/material.dart';
import '../models/quiz_option.dart';

class MultipleChoiceWidget extends StatelessWidget {
  final String questionText;
  final List<QuizOption> options;
  final List<String> correctIds;
  final String? selectedId;
  final bool isAnswered;
  final bool isMastered;
  final void Function(String? id) onSelect;

  const MultipleChoiceWidget({
    super.key,
    required this.questionText,
    required this.options,
    required this.correctIds,
    this.selectedId,
    required this.isAnswered,
    this.isMastered = false,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isMastered)
                const Padding(
                  padding: EdgeInsets.only(right: 12.0),
                  child: Icon(Icons.check_circle, color: Colors.green, size: 28),
                ),
              Expanded(
                child: Text(
                  questionText,
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    color: theme.textTheme.titleLarge?.color
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isSelected = selectedId == option.id;
          final isCorrect = correctIds.contains(option.id);
          final prefix = String.fromCharCode(65 + index); 

          Color backgroundColor;
          Color textColor;
          Color prefixColor;
          Color borderColor;

          if (isAnswered) {
            if (isSelected) {
              backgroundColor = isCorrect ? Colors.green.withOpacity(0.08) : Colors.red.withOpacity(0.08);
              textColor = isCorrect ? Colors.green : Colors.redAccent;
              prefixColor = Colors.white;
              borderColor = isCorrect ? Colors.green : Colors.redAccent;
            } else {
              backgroundColor = theme.cardColor;
              textColor = theme.textTheme.bodyLarge?.color?.withOpacity(0.6) ?? Colors.grey;
              prefixColor = theme.textTheme.bodyMedium?.color?.withOpacity(0.4) ?? Colors.grey;
              borderColor = theme.dividerColor.withOpacity(0.1);
            }
          } else if (isSelected) {
            backgroundColor = const Color(0xFF42A5F5).withOpacity(0.1);
            textColor = const Color(0xFF42A5F5);
            prefixColor = Colors.white;
            borderColor = const Color(0xFF42A5F5);
          } else {
            backgroundColor = theme.cardColor;
            textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
            prefixColor = theme.textTheme.bodyMedium?.color?.withOpacity(0.5) ?? Colors.grey;
            borderColor = theme.dividerColor.withOpacity(0.15);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: borderColor,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: isAnswered ? null : () => onSelect(option.id),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected 
                                ? (isAnswered ? (isCorrect ? Colors.green : Colors.redAccent) : const Color(0xFF42A5F5))
                                : theme.dividerColor.withOpacity(0.08),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            prefix,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: prefixColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            option.label,
                            style: TextStyle(
                              fontSize: 16,
                              color: textColor,
                              height: 1.4,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (isAnswered && isSelected)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(
                              isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                              color: isCorrect ? Colors.green : Colors.redAccent,
                              size: 24,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}