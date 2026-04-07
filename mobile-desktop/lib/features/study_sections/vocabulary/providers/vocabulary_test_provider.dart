import 'package:flutter/material.dart';
import '../services/vocabulary_test_api_service.dart';
import '../../../../features/ranking/services/ranking_api_service.dart';

class VocabularyTestProvider with ChangeNotifier {
  final VocabularyTestApiService _apiService = VocabularyTestApiService();
  final RankingApiService _rankingApiService = RankingApiService();
  
  int _dueCount = 0;
  int get dueCount => _dueCount;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  Map<String, dynamic>? _currentTest;
  Map<String, dynamic>? get currentTest => _currentTest;
  
  List<Map<String, dynamic>> _answers = [];
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  
  int _correctCount = 0;
  int get correctCount => _correctCount;

  Future<void> loadDueCount() async {
    _isLoading = true;
    notifyListeners();
    _dueCount = await _apiService.fetchDueCount();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> startTest() async {
    _isLoading = true;
    notifyListeners();
    _currentTest = await _apiService.generateTest();
    _currentIndex = 0;
    _answers = [];
    _correctCount = 0;
    _isLoading = false;
    notifyListeners();
  }

  void submitAnswer(int vocabularyId, bool isCorrect) {
    _answers.add({
      'vocabularyId': vocabularyId,
      'isCorrect': isCorrect,
    });
    if (isCorrect) _correctCount++;
    _currentIndex++;
    notifyListeners();
  }

  Future<void> finalizeTest() async {
    _isLoading = true;
    notifyListeners();
    await _apiService.submitResults(_answers);

    
    debugPrint('[VocabularyTestProvider] finalizeTest — correctCount=$_correctCount');
    await _rankingApiService.recordVocab(_correctCount);

    await loadDueCount();
    _isLoading = false;
    notifyListeners();
  }
}