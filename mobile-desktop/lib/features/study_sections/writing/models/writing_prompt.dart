import 'package:mobile_desktop/core/providers/ielts_level_provider.dart';

class WritingPrompt {
  final String id;
  final int taskType; 
  final String title;
  final String promptText;
  final IeltsBand band;

  const WritingPrompt({
    required this.id,
    required this.taskType,
    required this.title,
    required this.promptText,
    required this.band,
  });

  @override
  String toString() => 'WritingPrompt(title: $title, taskType: Task $taskType, band: $band)';
}