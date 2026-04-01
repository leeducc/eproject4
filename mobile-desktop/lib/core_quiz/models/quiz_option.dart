class QuizOption {
  final String id;    // e.g. "a", "b", "c", "d"
  final String label; // e.g. "Option A"

  QuizOption({required this.id, required this.label});

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      id: json['id'] as String,
      label: json['label'] as String,
    );
  }
}
