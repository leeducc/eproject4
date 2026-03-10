class DialogueTrueFalseQuestion {
  final String audioUrl;
  final String question;
  final bool answer;

  DialogueTrueFalseQuestion({
    required this.audioUrl,
    required this.question,
    required this.answer,
  });

  Map<String, dynamic> toMap() => {
    'audioUrl': audioUrl,
    'question': question,
    'answer': answer,
  };

  factory DialogueTrueFalseQuestion.fromMap(Map<String, dynamic> map) => DialogueTrueFalseQuestion(
    audioUrl: map['audioUrl'] ?? '',
    question: map['question'] ?? '',
    answer: map['answer'] ?? false,
  );
}
