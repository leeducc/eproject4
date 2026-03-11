import 'package:mobile_desktop/core/providers/ielts_level_provider.dart';

class ListeningExercise {
  final String id;
  final String title;
  final String audioUrl;
  final IeltsBand band;

  const ListeningExercise({
    required this.id,
    required this.title,
    required this.audioUrl,
    required this.band,
  });

  @override
  String toString() => 'ListeningExercise(title: $title, band: $band)';
}
