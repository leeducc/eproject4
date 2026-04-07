class Topic {
  final int id;
  final String title;
  final String prompt;
  final String? hint;
  final String? imageUrl;
  final String? audioUrl;
  final String? difficultyBand;
  final bool isProOnly;

  Topic({
    required this.id,
    required this.title,
    required this.prompt,
    this.hint,
    this.imageUrl,
    this.audioUrl,
    this.difficultyBand,
    this.isProOnly = false,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'],
      title: json['title'],
      prompt: json['prompt'] ?? json['description'] ?? '',
      hint: json['hint'],
      imageUrl: json['imageUrl'],
      audioUrl: json['audioUrl'],
      difficultyBand: json['difficultyBand'],
      isProOnly: json['isProOnly'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'prompt': prompt,
      'hint': hint,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'difficultyBand': difficultyBand,
      'isProOnly': isProOnly,
    };
  }
}