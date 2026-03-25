class ExamSubmissionModel {
  final int id;
  final int examId;
  final String examTitle;
  final double? listeningScore;
  final double? readingScore;
  final double? writingScore;
  final String? writingStatus;
  final String status;
  final String createdAt;
  final String? completedAt;

  ExamSubmissionModel({
    required this.id,
    required this.examId,
    required this.examTitle,
    this.listeningScore,
    this.readingScore,
    this.writingScore,
    this.writingStatus,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  factory ExamSubmissionModel.fromJson(Map<String, dynamic> json) {
    return ExamSubmissionModel(
      id: json['id'],
      examId: json['examId'],
      examTitle: json['examTitle'],
      listeningScore: json['listeningScore'] != null ? (json['listeningScore'] as num).toDouble() : null,
      readingScore: json['readingScore'] != null ? (json['readingScore'] as num).toDouble() : null,
      writingScore: json['writingScore'] != null ? (json['writingScore'] as num).toDouble() : null,
      writingStatus: json['writingStatus'],
      status: json['status'],
      createdAt: json['createdAt'],
      completedAt: json['completedAt'],
    );
  }
}
