class Question {
  final int id;
  final String skill;
  final int level;
  final String question;
  final List<String> options;
  final int correctIndex;

  int status; // 0: new, 1: sai, 2: đúng

  Question({
    required this.id,
    required this.skill,
    required this.level,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.status = 0,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? 0,
      skill: json['skill'] ?? "",
      level: _parseLevel(json['difficulty']),
      question: json['question'] ?? json['content'] ?? "",

      options: _parseOptions(json),

      correctIndex: json['correctIndex']
          ?? json['correct_answer']
          ?? 0,

      status: 0,
    );
  }


  static List<String> _parseOptions(Map<String, dynamic> json) {

    // case 1: backend trả list sẵn
    if (json['options'] != null && json['options'] is List) {
      return List<String>.from(json['options']);
    }


    List<String> opts = [];

    if (json['optionA'] != null) opts.add(json['optionA']);
    if (json['optionB'] != null) opts.add(json['optionB']);
    if (json['optionC'] != null) opts.add(json['optionC']);
    if (json['optionD'] != null) opts.add(json['optionD']);

    return opts;
  }

  static int _parseLevel(dynamic difficulty) {

    if (difficulty == null) return 0;

    if (difficulty is int) return difficulty;

    switch (difficulty.toString().toLowerCase()) {
      case "easy":
        return 1;
      case "medium":
        return 2;
      case "hard":
        return 3;
      case "very_hard":
        return 4;
      default:
        return 0;
    }
  }


  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "skill": skill,
      "difficulty": level,
      "question": question,
      "options": options,
      "correctIndex": correctIndex,
    };
  }
}