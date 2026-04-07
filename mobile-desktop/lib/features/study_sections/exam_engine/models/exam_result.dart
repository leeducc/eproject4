class ExamResult {
  final int examId;
  final String examTitle;
  final double listeningScore;
  final double readingScore;
  final String writingGradingType; 
  final double? writingScore; 
  final String writingStatus; 

  ExamResult({
    required this.examId,
    required this.examTitle,
    required this.listeningScore,
    required this.readingScore,
    required this.writingGradingType,
    this.writingScore,
    required this.writingStatus,
  });

  
  
  double get overallBand {
    if (writingScore != null) {
      return ((listeningScore + readingScore + writingScore!) / 3).clamp(0.0, 9.0);
    }
    return ((listeningScore + readingScore) / 2).clamp(0.0, 9.0);
  }

  bool get writingPending => writingStatus == 'PENDING';
}