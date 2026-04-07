import '../models/vocabulary.dart';

abstract class VocabularyRepository {
  Future<List<Vocabulary>> getVocabularyForLevel(String levelGroup);
}