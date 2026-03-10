import '../models/vocabulary.dart';

class SrsService {
  static DateTime calculateNextReview(int level) {
    final now = DateTime.now();

    switch (level) {
      case 0:
        return now.add(const Duration(minutes: 10));
      case 1:
        return now.add(const Duration(days: 1));
      case 2:
        return now.add(const Duration(days: 3));
      case 3:
        return now.add(const Duration(days: 7));
      default:
        return now;
    }
  }

  static void markResult(Vocabulary vocab, bool remembered) {
    if (remembered) {
      vocab.level = (vocab.level + 1).clamp(0, 3);
    } else {
      vocab.level = 0;
    }

    vocab.nextReview = calculateNextReview(vocab.level);
  }
}