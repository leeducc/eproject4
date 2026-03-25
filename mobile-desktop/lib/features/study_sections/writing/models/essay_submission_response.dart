import 'topic_model.dart';
import 'writing_correction.dart';

class EssaySubmissionResponse {
  final int id;
  final Topic topic;
  final String content;
  final String gradingType;
  final String? aiFeedback;
  final double? score;
  final String? status;
  final String? createdAt;

  final double? taskAchievement;
  final double? grammaticalRange;
  final double? lexicalResource;
  final double? cohesionCoherence;
  final String? teacherFeedback;
  final String? taskAchievementReason;
  final String? cohesionCoherenceReason;
  final String? lexicalResourceReason;
  final String? grammaticalRangeReason;
  final List<WritingCorrection> corrections;

  EssaySubmissionResponse({
    required this.id,
    required this.topic,
    required this.content,
    required this.gradingType,
    this.aiFeedback,
    this.score,
    this.status,
    this.createdAt,
    this.taskAchievement,
    this.grammaticalRange,
    this.lexicalResource,
    this.cohesionCoherence,
    this.teacherFeedback,
    this.taskAchievementReason,
    this.cohesionCoherenceReason,
    this.lexicalResourceReason,
    this.grammaticalRangeReason,
    this.corrections = const [],
  });

  factory EssaySubmissionResponse.fromJson(Map<String, dynamic> json) {
    var correctionsList = <WritingCorrection>[];
    if (json['corrections'] != null) {
      correctionsList = (json['corrections'] as List)
          .map((i) => WritingCorrection.fromJson(i))
          .toList();
    }

    return EssaySubmissionResponse(
      id: json['id'],
      topic: Topic.fromJson(json['topic']),
      content: json['content'],
       gradingType: json['gradingType'],
      aiFeedback: json['aiFeedback'],
      score: json['score'] != null ? (json['score'] as num).toDouble() : null,
      status: json['status'],
      createdAt: json['createdAt'],
      taskAchievement: json['taskAchievement'] != null
          ? (json['taskAchievement'] as num).toDouble()
          : null,
      grammaticalRange: json['grammaticalRange'] != null
          ? (json['grammaticalRange'] as num).toDouble()
          : null,
      lexicalResource: json['lexicalResource'] != null
          ? (json['lexicalResource'] as num).toDouble()
          : null,
      cohesionCoherence: json['cohesionCoherence'] != null
          ? (json['cohesionCoherence'] as num).toDouble()
          : null,
      teacherFeedback: json['teacherFeedback'],
      taskAchievementReason: json['taskAchievementReason'],
      cohesionCoherenceReason: json['cohesionCoherenceReason'],
      lexicalResourceReason: json['lexicalResourceReason'],
      grammaticalRangeReason: json['grammaticalRangeReason'],
      corrections: correctionsList,
    );
  }
}
