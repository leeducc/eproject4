import 'package:flutter/material.dart';
import '../../core/models/quiz_bank_models.dart';
import '../models/quiz_question.dart';
import 'audio_player_widget.dart';
import 'true_false_widget.dart';
import 'multiple_choice_widget.dart';
import 'fill_blank_widget.dart';

class DynamicQuestionBuilder extends StatelessWidget {
  final QuizQuestion question;
  final String? selectedId; // For MCQ and T/F (as "true"/"false")
  final bool isAnswered;
  final void Function(String answerId) onAnswer;

  const DynamicQuestionBuilder({
    super.key,
    required this.question,
    this.selectedId,
    required this.isAnswered,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (question.hasAudio)
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: AudioPlayerWidget(audioUrl: question.mediaUrl!),
          ),
        if (question.hasImage)
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                question.mediaUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 50),
                    ),
                  );
                },
              ),
            ),
          ),
        _buildQuestionBody(),
      ],
    );
  }

  Widget _buildQuestionBody() {
    if (question.isTrueFalse) {
      return TrueFalseWidget(
        questionText: question.instruction,
        isAnswered: isAnswered,
        result: isAnswered 
            ? (selectedId != null ? (selectedId == question.correctIds.first) : null) 
            : null,
        onAnswer: (choice) => onAnswer(choice.toString()),
      );
    }

    switch (question.type) {
      case QuestionType.FILL_BLANK:
        return FillBlankWidget(
          questionText: question.instruction,
          isAnswered: isAnswered,
          onSubmit: onAnswer,
        );
      case QuestionType.MULTIPLE_CHOICE:
      default:
        return MultipleChoiceWidget(
          questionText: question.instruction,
          options: question.options,
          correctIds: question.correctIds,
          selectedId: selectedId,
          isAnswered: isAnswered,
          onSelect: onAnswer,
        );
    }
  }
}
