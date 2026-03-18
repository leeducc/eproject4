class WritingCorrection {
  final String original;
  final String corrected;
  final String explanation;

  WritingCorrection({
    required this.original,
    required this.corrected,
    required this.explanation,
  });

  factory WritingCorrection.fromJson(Map<String, dynamic> json) {
    return WritingCorrection(
      original: json['original'] ?? '',
      corrected: json['corrected'] ?? '',
      explanation: json['explanation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'original': original,
      'corrected': corrected,
      'explanation': explanation,
    };
  }
}
