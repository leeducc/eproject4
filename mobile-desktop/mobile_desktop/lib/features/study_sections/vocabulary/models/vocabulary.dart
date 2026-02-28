class Vocabulary {
  final String word;
  final String ipa;
  final String meaning;
  final String example;

  int level; // 0: chưa nhớ → 3: rất tốt
  DateTime nextReview;
  bool favorite;

  Vocabulary({
    required this.word,
    required this.ipa,
    required this.meaning,
    required this.example,
    this.level = 0,
    DateTime? nextReview,
    this.favorite = false,
  }) : nextReview = nextReview ?? DateTime.now();
}