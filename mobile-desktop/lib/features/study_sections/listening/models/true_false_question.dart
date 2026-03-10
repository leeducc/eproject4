class TrueFalseQuestion {
  final String word;
  final String image;
  final bool answer;

  TrueFalseQuestion({
    required this.word,
    required this.image,
    required this.answer,
  });

  Map<String, dynamic> toMap() => {
    'word': word,
    'image': image,
    'answer': answer,
  };

  factory TrueFalseQuestion.fromMap(Map<String, dynamic> map) => TrueFalseQuestion(
    word: map['word'] ?? '',
    image: map['image'] ?? '',
    answer: map['answer'] ?? false,
  );
}
