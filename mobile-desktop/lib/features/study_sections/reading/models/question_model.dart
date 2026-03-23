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
}