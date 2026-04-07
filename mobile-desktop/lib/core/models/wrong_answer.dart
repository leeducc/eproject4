import 'dart:convert';

class WrongAnswer {
  final int questionId;
  final String skill; // 'LISTENING', 'SPEAKING', etc.
  final String questionTitle;
  final String? instruction;
  final String userAnswer;
  final List<String> correctAnswers;
  final String? explanation;
  final Map<String, dynamic>? originalJson;
  final DateTime timestamp;

  WrongAnswer({
    required this.questionId,
    required this.skill,
    required this.questionTitle,
    this.instruction,
    required this.userAnswer,
    required this.correctAnswers,
    this.explanation,
    this.originalJson,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'skill': skill,
      'questionTitle': questionTitle,
      'instruction': instruction,
      'userAnswer': userAnswer,
      'correctAnswers': correctAnswers,
      'explanation': explanation,
      'originalJson': originalJson,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory WrongAnswer.fromJson(Map<String, dynamic> json) {
    return WrongAnswer(
      questionId: json['questionId'],
      skill: json['skill'],
      questionTitle: json['questionTitle'],
      instruction: json['instruction'],
      userAnswer: json['userAnswer'],
      correctAnswers: List<String>.from(json['correctAnswers']),
      explanation: json['explanation'],
      originalJson: json['originalJson'] != null ? Map<String, dynamic>.from(json['originalJson']) : null,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
