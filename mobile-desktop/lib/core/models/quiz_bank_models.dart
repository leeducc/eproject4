enum SkillType { READING, LISTENING, VOCABULARY, WRITING }
enum QuestionType { MULTIPLE_CHOICE, MATCHING, FILL_BLANK, ESSAY, COMPREHENSION }

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
  final String? mediaUrl;
  final String? mediaType;
  final List<Question> questions;

  QuestionGroup({
    required this.id,
    required this.skill,
    required this.difficultyBand,
    required this.title,
    required this.content,
    this.mediaUrl,
    this.mediaType,
    required this.questions,
  });

  factory QuestionGroup.fromJson(Map<String, dynamic> json) {
    var rawQuestions = json['questions'] as List<dynamic>?;
    return QuestionGroup(
      id: json['id'] as int,
      skill: SkillType.values.firstWhere((e) => e.name == (json['skill']?.toString()), orElse: () => SkillType.READING),
      difficultyBand: json['difficultyBand']?.toString() ?? 'BAND_5_6',
      title: json['title']?.toString() ?? json['instruction']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      mediaUrl: json['mediaUrl']?.toString(),
      mediaType: json['mediaType']?.toString(),
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
  final Map<String, dynamic> data;

  Question({
    required this.id,
    required this.skill,
    required this.type,
    required this.difficultyBand,
    required this.instruction,
    this.explanation,
    required this.mediaUrls,
    required this.data,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int,
      skill: SkillType.values.firstWhere((e) => e.name == (json['skill']?.toString()), orElse: () => SkillType.READING),
      type: QuestionType.values.firstWhere((e) => e.name == (json['type']?.toString()), orElse: () => QuestionType.MULTIPLE_CHOICE),
      difficultyBand: json['difficultyBand']?.toString() ?? 'BAND_5_6',
      instruction: json['instruction']?.toString() ?? '',
      explanation: json['explanation']?.toString(),
      mediaUrls: (json['mediaUrls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      data: json['data'] as Map<String, dynamic>? ?? {},
    );
  }
}
