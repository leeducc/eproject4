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

    if (levelRange == "0-4") {
      minLevel = 0;
      maxLevel = 4;
    }

    if (levelRange == "5-6") {
      minLevel = 5;
      maxLevel = 6;
    }

    if (levelRange == "7-8") {
      minLevel = 7;
      maxLevel = 8;
    }

    if (levelRange == "9") {
      minLevel = 9;
      maxLevel = 9;
    }

    List<Question> filtered = db.where((q) {

      bool levelMatch = q.level >= minLevel && q.level <= maxLevel;
      bool skillMatch = skill == "Both" || q.skill == skill;

      return levelMatch && skillMatch;

    }).toList();

    filtered.shuffle(Random());

    if (!smartMode) {
      return filtered.take(total).toList();
    }

    List<Question> poolA =
    filtered.where((q) => q.status == 1).toList();

    List<Question> poolB =
    filtered.where((q) => q.status == 0).toList();

    List<Question> poolC =
    filtered.where((q) => q.status == 2).toList();

    int a = (total * 0.5).round();
    int b = (total * 0.4).round();
    int c = total - a - b;

    poolA.shuffle();
    poolB.shuffle();
    poolC.shuffle();

    List<Question> result = [];
    result.addAll(poolA.take(a));
    result.addAll(poolB.take(b));
    result.addAll(poolC.take(c));

    result.shuffle();

    if(result.length < total){

      filtered.shuffle();

      for(var q in filtered){

        if(!result.contains(q)){
          result.add(q);
        }

        if(result.length == total) break;
      }

    }

    return result;

  }
}