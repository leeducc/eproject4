class DialogueQuestion {
  final String audioUrl;
  final String question;
  final List<String> options;
  final int correctIndex;

  DialogueQuestion({
    required this.audioUrl,
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  Map<String, dynamic> toMap() => {
    'audioUrl': audioUrl,
    'question': question,
    'options': options,
    'correctIndex': correctIndex,
  };

  factory DialogueQuestion.fromMap(Map<String, dynamic> map) => DialogueQuestion(
    audioUrl: map['audioUrl'] ?? '',
    question: map['question'] ?? '',
    options: List<String>.from(map['options'] ?? []),
    correctIndex: map['correctIndex'] ?? 0,
  );
}
