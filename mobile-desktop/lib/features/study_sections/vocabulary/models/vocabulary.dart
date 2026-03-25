class Vocabulary {
  final int? id;
  final String word;
  final String type; // 'word' or 'phrase'
  final String level; // Original CEFR (A1, A2, B1, B2, C1, C2)
  final String levelGroup; // IELTS-style (0-4, 5-6, 7-8, 9)
  final String pos; // Part of Speech
  final String definitionUrl;
  final String voiceUrl;
  final String definition;
  final List<String> examples;
  final List<String> synonyms;

  Vocabulary({
    this.id,
    required this.word,
    required this.type,
    required this.level,
    required this.levelGroup,
    required this.pos,
    required this.definitionUrl,
    required this.voiceUrl,
    required this.definition,
    required this.examples,
    required this.synonyms,
  });

  factory Vocabulary.fromJson(Map<String, dynamic> json) {
    return Vocabulary(
      id: json['id'] as int?,
      word: json['word'] as String? ?? '',
      type: json['type'] as String? ?? 'word',
      level: json['level'] as String? ?? '',
      levelGroup: json['levelGroup'] as String? ?? '',
      pos: json['pos'] as String? ?? '',
      definitionUrl: json['definitionUrl'] as String? ?? '',
      voiceUrl: json['voiceUrl'] as String? ?? '',
      definition: json['definition'] as String? ?? '',
      examples: (json['examples'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      synonyms: (json['synonyms'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'type': type,
      'level': level,
      'levelGroup': levelGroup,
      'pos': pos,
      'phonetic': '', // Optional: update backend later
      'vi': '', // Optional: update backend later
      'meaning': definition, // Mapped for legacy UI support
      'meaning_vi': '',
      'examples': examples,
      'synonyms': synonyms,
      'definitionUrl': definitionUrl,
      'voiceUrl': voiceUrl,
    };
  }
}
