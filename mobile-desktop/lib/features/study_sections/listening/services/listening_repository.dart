import '../models/listening_exercise.dart';
import '../../../../core/providers/ielts_level_provider.dart';

abstract class ListeningRepository {
  Future<List<ListeningExercise>> fetchExercises(IeltsBand band);
}
