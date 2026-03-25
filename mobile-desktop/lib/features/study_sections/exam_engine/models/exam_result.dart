/// Holds the result of a submitted exam session.
class ExamResult {
  final int examId;
  final String examTitle;
  final double listeningScore;
  final double readingScore;
  final String writingGradingType; // 'AI' or 'HUMAN'
  final double? writingScore; // null if pending human grading
  final String writingStatus; // 'PENDING', 'GRADED', 'AI_GRADED'

  ExamResult({
    required this.examId,
    required this.examTitle,
    required this.listeningScore,
    required this.readingScore,
    required this.writingGradingType,
    this.writingScore,
    required this.writingStatus,
  });

  /// IELTS overall band = average of all 4 skills.
  /// Writing is included only if already graded.
  double get overallBand {
    if (writingScore != null) {
      return ((listeningScore + readingScore + writingScore!) / 3).clamp(0.0, 9.0);
    }
    return ((listeningScore + readingScore) / 2).clamp(0.0, 9.0);
  }

  bool get writingPending => writingStatus == 'PENDING';
}
