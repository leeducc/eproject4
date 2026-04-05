class Question {
  final int id;
  final String? skill;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? difficulty;
  final String? type;

  int status; // 0: new, 1: sai, 2: đúng

  Question({
    required this.id,
    this.skill,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.difficulty,
    this.type,
    this.status = 0,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? 0,
      skill: json['skill']?.toString(),
      question: json['content']?.toString()
          ?? json['question']?.toString()
          ?? json['title']?.toString() ?? '',

      options: _parseOptions(json),

      correctIndex: _parseCorrectIndex(json),

      difficulty: json['difficulty']?.toString(),
      type: json['type']?.toString(),
    );
  }
  static int _parseCorrectIndex(Map<String, dynamic> json) { final value = json['correctIndex']
      ?? json['correct_answer']
      ?? json['correctAnswer']
      ?? json['answer']
      ?? json['correct'];

    if (value == null) return 0;

    if (value is int) return value;

    String str = value.toString().toUpperCase();
    if (str == "A") return 0;
    if (str == "B") return 1;
    if (str == "C") return 2;
    if (str == "D") return 3;
    return int.tryParse(str) ?? 0; }


  static List<String> _parseOptions(Map<String, dynamic> json) {
    List<dynamic>? rawOptions;

    if (json['options'] != null && json['options'] is List) {
      rawOptions = json['options'];
    } else if (json['choices'] != null && json['choices'] is List) {
      rawOptions = json['choices'];
    } else if (json['answers'] != null && json['answers'] is List) {
      rawOptions = json['answers'];
    }

    if (rawOptions != null) {
      return List<String>.from(
        rawOptions.map((e) {
          if (e is String) {
            return e;
          }

          if (e is Map<String, dynamic>) {
            return e['content']?.toString() ??
                e['text']?.toString() ??
                e['value']?.toString() ??
                e['answer']?.toString() ??
                '';
          }

          return e.toString();
        }),
      );
    }

    List<String> opts = [];

    if (json['optionA'] != null) opts.add(json['optionA'].toString());
    if (json['optionB'] != null) opts.add(json['optionB'].toString());
    if (json['optionC'] != null) opts.add(json['optionC'].toString());
    if (json['optionD'] != null) opts.add(json['optionD'].toString());

    return opts;
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "skill": skill,
      "content": question,
      "options": options,
      "correctIndex": correctIndex,
      "difficulty": difficulty,
      "type": type,
    };
  }
}