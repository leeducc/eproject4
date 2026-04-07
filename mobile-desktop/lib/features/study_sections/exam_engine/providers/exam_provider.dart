import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/models/exam_model.dart';
import '../../../../core/models/quiz_bank_models.dart';
import '../models/exam_session_state.dart';
import '../models/exam_result.dart';
import '../../simulate_exam/services/exam_api_service.dart';

class ExamProvider extends ChangeNotifier {
  ExamSessionState? _state;
  ExamSessionState? get state => _state;

  
  ExamResult? _submittedResult;
  ExamResult? get submittedResult => _submittedResult;

  Timer? _timer;
  final ExamApiService _apiService = ExamApiService();

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  

  void startExam({
    required ExamModel exam,
    required int listeningSecs,
    required int readingSecs,
    required int writingSecs,
  }) {
    print('[ExamProvider] startExam: ${exam.title}');
    _state = ExamSessionState(
      exam: exam,
      currentSection: ExamSection.LISTENING,
      remainingSeconds: listeningSecs,
      listeningTotalSecs: listeningSecs,
      readingTotalSecs: readingSecs,
      writingTotalSecs: writingSecs,
      userAnswers: {},
      flaggedQuestions: {},
      audioPlayedGroups: {},
      currentQuestionIndex: 0,
    );
    notifyListeners();
    _startTimer();
  }

  

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_state == null) { timer.cancel(); return; }
      if (_state!.remainingSeconds > 0) {
        _state = _state!.copyWith(remainingSeconds: _state!.remainingSeconds - 1);
        notifyListeners();
      } else {
        timer.cancel();
        handleTimeUp();
      }
    });
  }

  void pauseTimer() => _timer?.cancel();
  void resumeTimer() => _startTimer();

  void handleTimeUp() {
    print('[ExamProvider] Time up for section: ${_state?.currentSection}');
    notifyListeners();
  }

  

  void recordAnswer(int questionId, dynamic answer) {
    if (_state == null) return;
    final newAnswers = Map<int, dynamic>.from(_state!.userAnswers);
    newAnswers[questionId] = answer;
    _state = _state!.copyWith(userAnswers: newAnswers);
    notifyListeners();
  }

  

  void toggleFlag(int questionId) {
    if (_state == null) return;
    final flags = Set<int>.from(_state!.flaggedQuestions);
    if (flags.contains(questionId)) {
      flags.remove(questionId);
      print('[ExamProvider] Unflagged question $questionId');
    } else {
      flags.add(questionId);
      print('[ExamProvider] Flagged question $questionId');
    }
    _state = _state!.copyWith(flaggedQuestions: flags);
    notifyListeners();
  }

  bool isFlagged(int questionId) => _state?.flaggedQuestions.contains(questionId) ?? false;

  

  void markAudioPlayed(int groupId) {
    if (_state == null) return;
    final played = Set<int>.from(_state!.audioPlayedGroups);
    played.add(groupId);
    print('[ExamProvider] Audio played for group $groupId (play-once locked)');
    _state = _state!.copyWith(audioPlayedGroups: played);
    notifyListeners();
  }

  bool isAudioPlayed(int groupId) => _state?.audioPlayedGroups.contains(groupId) ?? false;

  

  void jumpToQuestion(int index) {
    if (_state == null) return;
    print('[ExamProvider] jumpToQuestion: $index');
    _state = _state!.copyWith(currentQuestionIndex: index);
    notifyListeners();
  }

  void nextQuestion(int total) {
    if (_state == null) return;
    final next = (_state!.currentQuestionIndex + 1).clamp(0, total - 1);
    _state = _state!.copyWith(currentQuestionIndex: next);
    notifyListeners();
  }

  void prevQuestion() {
    if (_state == null) return;
    final prev = (_state!.currentQuestionIndex - 1).clamp(0, 999);
    _state = _state!.copyWith(currentQuestionIndex: prev);
    notifyListeners();
  }

  

  void nextSection() {
    if (_state == null) return;
    _timer?.cancel();
    if (_state!.currentSection == ExamSection.LISTENING) {
      print('[ExamProvider] Moving to READING section');
      _state = _state!.copyWith(
        currentSection: ExamSection.READING,
        remainingSeconds: _state!.readingTotalSecs,
        currentQuestionIndex: 0,
      );
      _startTimer();
    } else if (_state!.currentSection == ExamSection.READING) {
      print('[ExamProvider] Moving to WRITING section');
      _state = _state!.copyWith(
        currentSection: ExamSection.WRITING,
        remainingSeconds: _state!.writingTotalSecs,
        currentQuestionIndex: 0,
      );
      _startTimer();
    }
    notifyListeners();
  }

  

  Future<ExamResult?> submitExam({
    required String gradingType,
    required String writingTask1,
    required String writingTask2,
  }) async {
    if (_state == null) return null;
    _timer?.cancel();
    _isSubmitting = true;
    notifyListeners();

    try {
      double listeningScore = _state!.calculateScore(SkillType.listening);
      double readingScore = _state!.calculateScore(SkillType.reading);

      
      
      double? writingScore = gradingType == 'AI' ? 0.0 : null;
      String writingStatus = gradingType == 'AI' ? 'AI_GRADED' : 'PENDING';
      int? writingSubmissionId = gradingType == 'HUMAN' ? 123 : null;

      await _apiService.submitExam(
        _state!.exam.id,
        listeningScore,
        readingScore,
        writingSubmissionId,
        'COMPLETED',
      );

      final result = ExamResult(
        examId: _state!.exam.id,
        examTitle: _state!.exam.title,
        listeningScore: listeningScore,
        readingScore: readingScore,
        writingGradingType: gradingType,
        writingScore: writingScore,
        writingStatus: writingStatus,
      );

      print('[ExamProvider] Exam submitted. L=${listeningScore.toStringAsFixed(1)} R=${readingScore.toStringAsFixed(1)} W=$writingStatus');
      _isSubmitting = false;
      _submittedResult = result; 
      notifyListeners();
      return result;
    } catch (e) {
      print('[ExamProvider] Submit error: $e');
      _isSubmitting = false;
      notifyListeners();
      return null;
    }
  }

  

  void clearSession() {
    print('[ExamProvider] Clearing session state');
    _state = null;
    _submittedResult = null;
    notifyListeners();
  }

  

  void giveUp() {
    print('[ExamProvider] User gave up');
    _timer?.cancel();
    _state = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}