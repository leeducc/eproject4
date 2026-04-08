import '../../core/models/quiz_bank_models.dart';
import '../../core/utils/url_helper.dart';
import 'quiz_option.dart';

class QuizQuestion extends Question {
  bool isAlreadySolved = false;

  QuizQuestion({
    required super.id,
    required super.skill,
    required super.type,
    required super.difficultyBand,
    required super.instruction,
    super.explanation,
    required super.mediaUrls,
    required super.mediaTypes,
    required super.data,
    this.isAlreadySolved = false,
  });

  factory QuizQuestion.from(Question q, {bool isSolved = false}) {
    return QuizQuestion(
      id: q.id,
      skill: q.skill,
      type: q.type,
      difficultyBand: q.difficultyBand,
      instruction: q.instruction,
      explanation: q.explanation,
      mediaUrls: q.mediaUrls,
      mediaTypes: q.mediaTypes,
      data: q.data,
      isAlreadySolved: isSolved,
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

  
  List<dynamic> get leftItems => data['left_items'] ?? [];
  List<dynamic> get rightItems => data['right_items'] ?? [];
  Map<String, dynamic> get matchingSolution => data['solution'] ?? {};

  
  bool isCorrectChoice(String answerId) {
    if (type == QuestionType.matching) {
      return answerId == "__MATCHING_CORRECT__";
    }
    return correctIds.contains(answerId);
  }


  String? get mediaUrl {
    final rawUrl = data['media_url'] ?? (mediaUrls.isNotEmpty ? mediaUrls.first : null);
    return UrlHelper.fixMediaUrl(rawUrl);
  }
  
  String? get mediaType {
    final fromData = data['media_type']?.toString();
    if (fromData != null) return fromData;

    if (mediaTypes.isNotEmpty) {
      final mt = mediaTypes.first.toLowerCase();
      if (mt.contains('audio')) return 'audio';
      if (mt.contains('image')) return 'image';
      if (mt.contains('video')) return 'video';
    }
    return null;
  }

  bool get hasAudio => mediaType == 'audio' && mediaUrl != null;

  bool get hasImage => mediaType == 'image' && mediaUrl != null;
}