import '../../core/models/quiz_bank_models.dart';
import 'quiz_option.dart';

class QuizQuestion extends Question {
  QuizQuestion({
    required super.id,
    required super.skill,
    required super.type,
    required super.difficultyBand,
    required super.instruction,
    super.explanation,
    required super.mediaUrls,
    required super.data,
  });

  factory QuizQuestion.from(Question q) {
    return QuizQuestion(
      id: q.id,
      skill: q.skill,
      type: q.type,
      difficultyBand: q.difficultyBand,
      instruction: q.instruction,
      explanation: q.explanation,
      mediaUrls: q.mediaUrls,
      data: q.data,
    );
  }

  List<QuizOption> get options {
    if (data['options'] == null) return [];
    return (data['options'] as List<dynamic>)
        .map((o) => QuizOption.fromJson(o as Map<String, dynamic>))
        .toList();
  }

  List<String> get correctIds {
    if (data['correct_ids'] == null) return [];
    return List<String>.from(data['correct_ids']);
  }

  bool get multipleSelect {
    return data['multiple_select'] ?? false;
  }

  bool get isTrueFalse => options.length == 2;

  String? get mediaUrl => data['media_url'] ?? (mediaUrls.isNotEmpty ? mediaUrls.first : null);
  
  String? get mediaType => data['media_type'];

  bool get hasAudio => mediaType == 'audio' && mediaUrl != null;

  bool get hasImage => mediaType == 'image' && mediaUrl != null;
}
