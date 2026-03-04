import 'topic_model.dart';

class EssaySubmissionResponse {
  final int id;
  final Topic topic;
  final String content;
  final String gradingType;
  final String? aiFeedback;
  final double? score;

  EssaySubmissionResponse({
    required this.id,
    required this.topic,
    required this.content,
    required this.gradingType,
    this.aiFeedback,
    this.score,
  });

  factory EssaySubmissionResponse.fromJson(Map<String, dynamic> json) {
    return EssaySubmissionResponse(
      id: json['id'],
      topic: Topic.fromJson(json['topic']),
      content: json['content'],
      gradingType: json['gradingType'],
      aiFeedback: json['aiFeedback'],
      score: json['score'] != null ? (json['score'] as num).toDouble() : null,
    );
  }
}
