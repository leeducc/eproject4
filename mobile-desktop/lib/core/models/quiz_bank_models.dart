import 'package:mobile_desktop/core/utils/url_helper.dart';

enum SkillType { reading, listening, vocabulary, writing }
enum QuestionType { multipleChoice, matching, fillBlank, essay, comprehension }

class Tag {
  final int id;
  final String name;
  final String namespace;
  final String? color;

  Tag({required this.id, required this.name, required this.namespace, this.color});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'],
      name: json['name'],
      namespace: json['namespace'],
      color: json['color'],
    );
  }
}

class QuestionGroup {
  final int id;
  final SkillType skill;
  final String difficultyBand;
  final String title;
  final String content;
  final List<String> mediaUrls;
  final List<String> mediaTypes;
  final List<Question> questions;

  QuestionGroup({
    required this.id,
    required this.skill,
    required this.difficultyBand,
    required this.title,
    required this.content,
    required this.mediaUrls,
    required this.mediaTypes,
    required this.questions,
  });

  String? get mediaUrl => UrlHelper.fixMediaUrl(mediaUrls.isNotEmpty ? mediaUrls.first : null);
  String? get mediaType => mediaTypes.isNotEmpty ? mediaTypes.first : null;

  factory QuestionGroup.fromJson(Map<String, dynamic> json) {
    var rawQuestions = json['questions'] as List<dynamic>?;
    return QuestionGroup(
      id: (json['id'] as num?)?.toInt() ?? 0,
      skill: SkillType.values.firstWhere((e) => e.name.toUpperCase() == (json['skill']?.toString()), orElse: () => SkillType.reading),
      difficultyBand: json['difficultyBand']?.toString() ?? 'BAND_5_6',
      title: json['title']?.toString() ?? json['instruction']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      mediaUrls: (json['mediaUrls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? 
                 (json['mediaUrl'] != null ? [json['mediaUrl'].toString()] : []),
      mediaTypes: (json['mediaTypes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? 
                  (json['mediaType'] != null ? [json['mediaType'].toString()] : []),
      questions: rawQuestions != null ? rawQuestions.map((q) => Question.fromJson(q)).toList() : [],
    );
  }
}

class Question {
  final int id;
  final SkillType skill;
  final QuestionType type;
  final String difficultyBand;
  final String instruction;
  final String? explanation;
  final List<String> mediaUrls;
  final List<String> mediaTypes;
  final Map<String, dynamic> data;

  Question({
    required this.id,
    required this.skill,
    required this.type,
    required this.difficultyBand,
    required this.instruction,
    this.explanation,
    required this.mediaUrls,
    required this.mediaTypes,
    required this.data,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: (json['id'] as num?)?.toInt() ?? 0,
      skill: SkillType.values.firstWhere((e) => e.name.toUpperCase() == (json['skill']?.toString()), orElse: () => SkillType.reading),
      type: QuestionType.values.firstWhere((e) => e.name.toUpperCase() == (json['type']?.toString().replaceAll('_', '')), orElse: () => QuestionType.multipleChoice),
      difficultyBand: json['difficultyBand']?.toString() ?? 'BAND_5_6',
      instruction: json['instruction']?.toString() ?? '',
      explanation: json['explanation']?.toString(),
      mediaUrls: (json['mediaUrls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      mediaTypes: (json['mediaTypes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      data: (json['data'] is Map) ? Map<String, dynamic>.from(json['data'] as Map) : {},
    );
  }
}