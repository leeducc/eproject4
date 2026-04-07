class QuizOption {
  final String id;    
  final String label; 

  QuizOption({required this.id, required this.label});

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      id: (json['id'] ?? '').toString(),
      label: (json['label'] ?? json['text'] ?? '').toString(),
    );
  }
}