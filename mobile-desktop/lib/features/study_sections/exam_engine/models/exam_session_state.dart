import '../../../../core/models/exam_model.dart';
import '../../../../core/models/quiz_bank_models.dart';

enum ExamSection { LISTENING, READING, WRITING }

class ExamSessionState {
  final ExamModel exam;
  final ExamSection currentSection;
  final int remainingSeconds;

  
  final Map<int, dynamic> userAnswers;

  
  final Set<int> flaggedQuestions;

  
  final Set<int> audioPlayedGroups;

  
  final int currentQuestionIndex;

  
  final int listeningTotalSecs;
  final int readingTotalSecs;
  final int writingTotalSecs;

  ExamSessionState({
    required this.exam,
    this.currentSection = ExamSection.LISTENING,
    this.remainingSeconds = 40 * 60,
    this.userAnswers = const {},
    this.flaggedQuestions = const {},
    this.audioPlayedGroups = const {},
    this.currentQuestionIndex = 0,
    this.listeningTotalSecs = 40 * 60,
    this.readingTotalSecs = 60 * 60,
    this.writingTotalSecs = 60 * 60,
  });

  ExamSessionState copyWith({
    ExamSection? currentSection,
    int? remainingSeconds,
    Map<int, dynamic>? userAnswers,
    Set<int>? flaggedQuestions,
    Set<int>? audioPlayedGroups,
    int? currentQuestionIndex,
    int? listeningTotalSecs,
    int? readingTotalSecs,
    int? writingTotalSecs,
  }) {
    return ExamSessionState(
      exam: exam,
      currentSection: currentSection ?? this.currentSection,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      userAnswers: userAnswers ?? this.userAnswers,
      flaggedQuestions: flaggedQuestions ?? this.flaggedQuestions,
      audioPlayedGroups: audioPlayedGroups ?? this.audioPlayedGroups,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      listeningTotalSecs: listeningTotalSecs ?? this.listeningTotalSecs,
      readingTotalSecs: readingTotalSecs ?? this.readingTotalSecs,
      writingTotalSecs: writingTotalSecs ?? this.writingTotalSecs,
    );
  }

  double calculateScore(SkillType skill) {
    if (exam.groups == null && exam.questions == null) return 0.0;

    int correctCount = 0;
    int totalCount = 0;

    for (var group in (exam.groups ?? <QuestionGroup>[])) {
      if (group.skill == skill) {
        totalCount += group.questions.length;
        for (var q in group.questions) {
          correctCount += _isCorrect(q.id, q.data) ? 1 : 0;
        }
      }
    }

    for (var q in (exam.questions ?? <Question>[])) {
      if (q.skill == skill && q.type != QuestionType.essay) {
        totalCount++;
        correctCount += _isCorrect(q.id, q.data) ? 1 : 0;
      }
    }

    if (totalCount == 0) return 0.0;
    double percentage = correctCount / totalCount;
    return (percentage * 9.0).clamp(0.0, 9.0);
  }

  bool _isCorrect(int qId, Map<String, dynamic> data) {
    var answer = userAnswers[qId];
    if (answer == null) return false;

    if (data.containsKey('correct_ids')) {
      var correctIds = List<String>.from(data['correct_ids']);
      if (answer is String) return correctIds.contains(answer);
      if (answer is List) {
        if (answer.length != correctIds.length) return false;
        for (var a in answer) {
          if (!correctIds.contains(a)) return false;
        }
        return true;
      }
    }

    if (data.containsKey('blanks')) {
      var blanks = data['blanks'] as Map<String, dynamic>;
      if (answer is Map) {
        bool allCorrect = true;
        blanks.forEach((key, val) {
          List<String> validOptions = List<String>.from(val['correct'] ?? []);
          String userAns = answer[key]?.toString().toLowerCase().trim() ?? '';
          if (!validOptions.map((e) => e.toLowerCase().trim()).contains(userAns)) {
            allCorrect = false;
          }
        });
        return allCorrect;
      }
      return false;
    }

    if (data.containsKey('solution')) {
      var solution = data['solution'] as Map<String, dynamic>;
      if (answer is Map) {
        bool allCorrect = true;
        solution.forEach((key, val) {
          if (answer[key] != val) allCorrect = false;
        });
        return allCorrect;
      }
      return false;
    }

    return false;
  }
}