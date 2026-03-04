class Topic {
  final int id;
  final String title;
  final String description;
  final String? hint;
  final String? imageUrl;
  final String? audioUrl;

  Topic({
    required this.id,
    required this.title,
    required this.description,
    this.hint,
    this.imageUrl,
    this.audioUrl,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      hint: json['hint'],
      imageUrl: json['imageUrl'],
      audioUrl: json['audioUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'hint': hint,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
    };
  }
}
