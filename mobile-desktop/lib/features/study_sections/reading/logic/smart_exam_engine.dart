import 'dart:math';
import '../data/question_bank.dart';
import '../models/question_model.dart';
import '../user/user_history.dart';

class SmartExamEngine {

  static List<Question> generateExam({

    required String level,
    required String skill,
    required int totalQuestions,
    required bool smartMode,

  }) {

    // ===== 1. FILTER =====
    List<Question> filtered = QuestionBank.questions.where((q) {

      bool matchLevel = q.level == level;

      bool matchSkill = skill == "Both"
          ? true
          : q.skill.toLowerCase() == skill.toLowerCase();

      return matchLevel && matchSkill;

    }).toList();

    // ===== 2. FALLBACK nếu thiếu =====
    if(filtered.length < totalQuestions){

      List<Question> backup = QuestionBank.questions.where((q) {
        return skill == "Both"
            ? true
            : q.skill.toLowerCase() == skill.toLowerCase();
      }).toList();

      filtered = backup;
    }

    // ===== 3. RANDOM MODE =====
    if(!smartMode){
      return _fillEnough(filtered, totalQuestions);
    }

    // ===== 4. SMART MODE =====
    List<Question> poolA = []; // sai
    List<Question> poolB = []; // mới
    List<Question> poolC = []; // đúng

    for(var q in filtered){

      if(UserHistory.wrongQuestions.contains(q.id)){
        poolA.add(q);
      } else if(UserHistory.correctQuestions.contains(q.id)){
        poolC.add(q);
      } else {
        poolB.add(q);
      }
    }

    int aCount = (totalQuestions * 0.5).round();
    int bCount = (totalQuestions * 0.4).round();
    int cCount = totalQuestions - aCount - bCount;

    List<Question> result = [];

    result.addAll(_pick(poolA, aCount));
    result.addAll(_pick(poolB, bCount));
    result.addAll(_pick(poolC, cCount));

    // ===== 5. FILL CHO ĐỦ =====
    if(result.length < totalQuestions){

      List<Question> remain = filtered.where((q) => !result.contains(q)).toList();

      remain.shuffle();

      result.addAll(remain.take(totalQuestions - result.length));

    }

    // vẫn thiếu → random lại từ đầu
    if(result.length < totalQuestions){
      result = _fillEnough(filtered, totalQuestions);
    }

    result.shuffle();

    return result;
  }

  // ===== HELPER: lấy ngẫu nhiên =====
  static List<Question> _pick(List<Question> list, int count){

    list.shuffle();
    return list.take(count).toList();
  }

  // ===== HELPER: luôn đủ số câu =====
  static List<Question> _fillEnough(List<Question> source, int total){

    List<Question> result = [];
    Random random = Random();

    while(result.length < total){

      source.shuffle();

      for(var q in source){

        if(result.length < total){
          result.add(q);
        } else {
          break;
        }
      }
    }

    return result;
  }
}