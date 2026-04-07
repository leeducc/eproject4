import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question_model.dart';

class ExamResult {
  final int examId;
  final List<Question> questions;

  ExamResult({
    required this.examId,
    required this.questions,
  });
}

class SmartExamEngine {

  static const String baseUrl = "http://10.0.2.2:8080/api/v1";


  static Future<ExamResult> generateExam({
    required String level,
    required String skill,
    required int totalQuestions,
    required bool smartMode,
  }) async {

    List<Question> questions = await _getQuestions(
      level: level,
      skill: skill,
      total: totalQuestions,
    );

    int examId = await _createExam(
      questions,
      level,
      skill,
      totalQuestions,
    );

    return ExamResult(
      examId: examId,
      questions: questions,
    );
  }


  static Future<List<dynamic>> getAllExams() async {

    final uri = Uri.parse("$baseUrl/exams");

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception("Lỗi lấy danh sách exam");
    }

    return jsonDecode(response.body);
  }


  static Future<List<Question>> _getQuestions({
    required String level,
    required String skill,
    required int total,
  }) async {

    String difficulty = _mapLevel(level);


    Map<String, String> query = {
      "difficulty": difficulty,
      "limit": total.toString(),
      "type": "mock",
      "search": "",
      "lastSeenId": "0",
    };

    if (skill != "Both") {
      query["skill"] = skill.toLowerCase();
    }

    final uri = Uri.parse("$baseUrl/questions/paginated")
        .replace(queryParameters: query);

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception("Lỗi lấy câu hỏi");
    }

    final data = jsonDecode(response.body);

    List list = data["items"]
        ?? data["content"]
        ?? data["data"]
        ?? [];

    return list.map((e) => Question.fromJson(e)).toList();
  }


  static Future<int> _createExam(
      List<Question> questions,
      String level,
      String skill,
      int total,
      ) async {

    final uri = Uri.parse("$baseUrl/exams");

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "questionIds": questions.map((q) => q.id).toList(),
        "skill": skill == "Both" ? null : skill.toLowerCase(),
        "difficulty": _mapLevel(level),
        "total": total,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Lỗi tạo exam");
    }

    final data = jsonDecode(response.body);

    return data["id"] ?? data["examId"] ?? 0;
  }


  static String _mapLevel(String level) {
    switch (level) {
      case "0-4":
        return "easy";
      case "5-6":
        return "medium";
      case "7-8":
        return "hard";
      case "9":
        return "very_hard";
      default:
        return "medium";
    }
  }
}