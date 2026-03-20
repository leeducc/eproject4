import 'package:mobile_desktop/core/providers/ielts_level_provider.dart';
import 'true_false_question.dart';
import 'dialogue_question.dart';
import 'dialogue_true_false_question.dart';

enum ListeningSectionType {
  trueFalse,
  dialogue,
  dialogueTrueFalse,
}

class ListeningSection {
  final String id;
  final String title;
  final ListeningSectionType type;
  final IeltsBand ieltsLevel;
  final List<dynamic> questions;

  ListeningSection({
    required this.id,
    required this.title,
    required this.type,
    required this.ieltsLevel,
    required this.questions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'ieltsLevel': ieltsLevel.name,
      'questions': questions.map((q) => q.toMap()).toList(),
    };
  }

  factory ListeningSection.fromMap(Map<String, dynamic> map) {
    final typeStr = map['type'] as String;
    final type = ListeningSectionType.values.firstWhere((e) => e.name == typeStr);
    
    final levelStr = map['ieltsLevel'] as String;
    final ieltsLevel = IeltsBand.values.firstWhere((e) => e.name == levelStr);

    final questionsRaw = map['questions'] as List<dynamic>;

    List<dynamic> parsedQuestions;
    switch (type) {
      case ListeningSectionType.trueFalse:
        parsedQuestions = questionsRaw.map((q) => TrueFalseQuestion.fromMap(q)).toList();
        break;
      case ListeningSectionType.dialogue:
        parsedQuestions = questionsRaw.map((q) => DialogueQuestion.fromMap(q)).toList();
        break;
      case ListeningSectionType.dialogueTrueFalse:
        parsedQuestions = questionsRaw.map((q) => DialogueTrueFalseQuestion.fromMap(q)).toList();
        break;
    }

    return ListeningSection(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      type: type,
      ieltsLevel: ieltsLevel,
      questions: parsedQuestions,
    );
  }
}
