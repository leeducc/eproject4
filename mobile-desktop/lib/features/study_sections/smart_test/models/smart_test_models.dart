class SmartTestSubmitRequest {
  final String skill;
  final String difficultyBand;
  final List<QuestionAttemptDTO> attempts;

  SmartTestSubmitRequest({
    required this.skill,
    required this.difficultyBand,
    required this.attempts,
  });

  Map<String, dynamic> toJson() => {
    'skill': skill,
    'difficultyBand': difficultyBand,
    'attempts': attempts.map((a) => a.toJson()).toList(),
  };
}

class QuestionAttemptDTO {
  final int questionId;
  final String userAnswer;
  final bool isCorrect;

  QuestionAttemptDTO({
    required this.questionId,
    required this.userAnswer,
    required this.isCorrect,
  });

  Map<String, dynamic> toJson() => {
    'questionId': questionId,
    'userAnswer': userAnswer,
    'isCorrect': isCorrect,
  };
}

class SmartTestSubmitResponse {
  final int sessionId;
  final double score;
  final int correctCount;
  final int totalCount;

  SmartTestSubmitResponse({
    required this.sessionId,
    required this.score,
    required this.correctCount,
    required this.totalCount,
  });

  factory SmartTestSubmitResponse.fromJson(Map<String, dynamic> json) {
    return SmartTestSubmitResponse(
      sessionId: json['sessionId'],
      score: json['score'].toDouble(),
      correctCount: json['correctCount'],
      totalCount: json['totalCount'],
    );
  }
}
