import '../models/writing_prompt.dart';
import '../../../../core/providers/ielts_level_provider.dart';

abstract class WritingRepository {
  Future<List<WritingPrompt>> fetchPrompts(IeltsBand band);
}
