import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../core/models/quiz_bank_models.dart';
import '../models/quiz_question.dart';
import 'audio_player_widget.dart';
import 'multiple_choice_widget.dart';
import 'fill_blank_widget.dart';
import 'matching_widget.dart';

class DynamicQuestionBuilder extends StatelessWidget {
  final QuizQuestion question;
  final String? selectedId; 
  final bool isAnswered;
  final void Function(String? answerId) onAnswer;

  const DynamicQuestionBuilder({
    super.key,
    required this.question,
    this.selectedId,
    required this.isAnswered,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final String? passage = question.data['passage']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (passage != null && passage.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Html(
              data: passage,
              style: {
                "body": Style(
                  fontSize: FontSize(16),
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              },
            ),
          ),
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
        if (isAnswered && selectedId != null)
          _buildFeedbackBanner(context),
      ],
    );
  }

  Widget _buildFeedbackBanner(BuildContext context) {
    bool isCorrect = question.isCorrectChoice(selectedId!);

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isCorrect ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded, 
               color: isCorrect ? Colors.green : Colors.red,
               size: 24),
          const SizedBox(width: 10),
          Text(
            isCorrect ? "Chính xác!" : "Chưa chính xác", 
            style: TextStyle(
              color: isCorrect ? Colors.green : Colors.red, 
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionBody() {
    switch (question.type) {
      case QuestionType.matching:
        return MatchingWidget(
          question: question,
          isAnswered: isAnswered,
          onAnswer: onAnswer,
        );
      case QuestionType.fillBlank:
        return FillBlankWidget(
          questionText: question.instruction,
          isAnswered: isAnswered,
          onSubmit: onAnswer,
        );
      case QuestionType.multipleChoice:
      default:
        return MultipleChoiceWidget(
          questionText: question.instruction,
          options: question.options,
          correctIds: question.correctIds,
          selectedId: selectedId,
          isAnswered: isAnswered,
          isMastered: question.isAlreadySolved,
          onSelect: onAnswer,
        );
    }
  }
}