class Question {
  final int id;
  final String question;
  final List<String> options;
  final int answer;

  final int level;
  final String skill;

  int status;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.answer,
    required this.level,
    required this.skill,
    this.status = 0,
  });
}