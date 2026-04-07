import 'package:mobile_desktop/core/models/quiz_bank_models.dart';

class ExamModel {
  final int id;
  final String title;
  final String examType;
  final String? description;
  final String? createdAt;
  final List<Question>? questions;
  final List<QuestionGroup>? groups;
  final List<String>? categories;

  ExamModel({
    required this.id,
    required this.title,
    required this.examType,
    this.description,
    this.createdAt,
    this.questions,
    this.groups,
    this.categories,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id'],
      title: json['title'] ?? '',
      examType: (json['exam_type'] ?? json['examType'] ?? '').toString(),
      description: json['description'],
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString(),
      questions: (json['questions'] as List<dynamic>?)?.map((q) => Question.fromJson(q)).toList(),
      groups: (json['groups'] as List<dynamic>?)?.map((g) => QuestionGroup.fromJson(g)).toList(),
      categories: (json['categories'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }
}