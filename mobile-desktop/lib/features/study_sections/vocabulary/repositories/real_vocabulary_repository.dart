import '../models/vocabulary.dart';
import '../services/vocabulary_api_service.dart';
import 'vocabulary_repository.dart';

class RealVocabularyRepository implements VocabularyRepository {
  final VocabularyApiService apiService;

  RealVocabularyRepository(this.apiService);

  @override
  Future<List<Vocabulary>> getVocabularyForLevel(String levelGroup) async {
    return await apiService.fetchVocabulary(levelGroup);
  }
}
