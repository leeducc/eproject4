import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wrong_answer.dart';

class WrongAnswerProvider with ChangeNotifier {
  List<WrongAnswer> _wrongAnswers = [];
  bool _isLoading = true;

  List<WrongAnswer> get wrongAnswers => _wrongAnswers;
  bool get isLoading => _isLoading;

  WrongAnswerProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    debugPrint('[WrongAnswerProvider] loading from SharedPreferences');
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString('wrong_answers_list');
      if (data != null) {
        final List<dynamic> decoded = jsonDecode(data);
        _wrongAnswers = decoded.map((item) => WrongAnswer.fromJson(item)).toList();
        debugPrint('[WrongAnswerProvider] loaded ${_wrongAnswers.length} items');
      }
    } catch (e) {
      debugPrint('[WrongAnswerProvider] error loading: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_wrongAnswers.map((item) => item.toJson()).toList());
      await prefs.setString('wrong_answers_list', encoded);
      debugPrint('[WrongAnswerProvider] saved ${_wrongAnswers.length} items');
    } catch (e) {
      debugPrint('[WrongAnswerProvider] error saving: $e');
    }
  }

  Future<void> addWrongAnswer(WrongAnswer item) async {
    // Avoid duplicates for the same question on the same day if desired, 
    // or just allow multiple attempts. Let's avoid exact duplicates of (questionId).
    _wrongAnswers.removeWhere((element) => element.questionId == item.questionId);
    _wrongAnswers.insert(0, item);
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> removeWrongAnswer(int questionId) async {
    _wrongAnswers.removeWhere((element) => element.questionId == questionId);
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> removeMultipleWrongAnswers(List<int> questionIds) async {
    _wrongAnswers.removeWhere((element) => questionIds.contains(element.questionId));
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> clearAll() async {
    _wrongAnswers.clear();
    notifyListeners();
    await _saveToPrefs();
  }

  List<WrongAnswer> getBySkill(String skill) {
    return _wrongAnswers.where((element) => element.skill == skill).toList();
  }
}
