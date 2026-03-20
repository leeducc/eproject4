import 'dart:math';
import '../models/question_model.dart';
import '../data/question_database.dart';

class SmartExamLogic {

  static List<Question> generateExam({
    required int total,
    required String levelRange,
    required String skill,
    required bool smartMode,
  }) {

    List<Question> db = QuestionDatabase.questions;

    int minLevel = 0;
    int maxLevel = 9;

    switch (levelRange) {
      case "0-4":
        minLevel = 0;
        maxLevel = 4;
        break;
      case "5-6":
        minLevel = 5;
        maxLevel = 6;
        break;
      case "7-8":
        minLevel = 7;
        maxLevel = 8;
        break;
      case "9":
        minLevel = 9;
        maxLevel = 9;
        break;
    }

    // ===== FILTER =====
    List<Question> filtered = db.where((q) {

      bool levelMatch = q.level >= minLevel && q.level <= maxLevel;

      bool skillMatch = skill == "Both"
          ? true
          : q.skill.toLowerCase() == skill.toLowerCase();

      return levelMatch && skillMatch;

    }).toList();

    // ===== FALLBACK nếu không có câu =====
    if (filtered.isEmpty) {
      filtered = db;
    }

    filtered.shuffle();

    // ===== RANDOM MODE =====
    if (!smartMode) {
      return _fillEnough(filtered, total);
    }

    // ===== SMART MODE =====
    List<Question> poolA = [];
    List<Question> poolB = [];
    List<Question> poolC = [];

    for (var q in filtered) {

      int status = q.status ?? 0;

      if (status == 1) {
        poolA.add(q); // sai
      } else if (status == 2) {
        poolC.add(q); // đúng
      } else {
        poolB.add(q); // chưa làm
      }
    }

    int a = (total * 0.5).round();
    int b = (total * 0.4).round();
    int c = total - a - b;

    List<Question> result = [];

    result.addAll(_pick(poolA, a));
    result.addAll(_pick(poolB, b));
    result.addAll(_pick(poolC, c));

    // ===== FILL CHO ĐỦ =====
    if (result.length < total) {

      List<Question> remain =
      filtered.where((q) => !result.contains(q)).toList();

      remain.shuffle();

      result.addAll(
        remain.take(total - result.length),
      );
    }

    // vẫn thiếu → random full
    if (result.length < total) {
      result = _fillEnough(filtered, total);
    }

    result.shuffle();

    return result;
  }

  // ===== HELPER =====
  static List<Question> _pick(List<Question> list, int count) {
    if (list.isEmpty) return [];

    list.shuffle();
    return list.take(min(count, list.length)).toList();
  }

  static List<Question> _fillEnough(List<Question> source, int total) {

    if (source.isEmpty) return [];

    List<Question> result = [];

    while (result.length < total) {

      source.shuffle();

      for (var q in source) {

        if (result.length >= total) break;

        result.add(q);
      }
    }

    return result;
  }
}