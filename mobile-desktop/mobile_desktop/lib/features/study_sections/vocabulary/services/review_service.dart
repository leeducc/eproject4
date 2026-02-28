import '../models/vocabulary.dart';

class ReviewService {
  static List<Vocabulary> getDueWords(List<Vocabulary> allWords) {
    final now = DateTime.now();
    return allWords
        .where((v) => v.nextReview.isBefore(now))
        .toList();
  }
}