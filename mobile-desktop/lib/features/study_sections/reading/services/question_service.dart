import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/question_model.dart';

class QuestionService {

  static const String baseUrl = "http://10.0.2.2:8080/api/v1";

  /// ================= GET QUESTIONS =================
  static Future<List<Question>> getQuestions({
    String? skill,
    String? difficulty,
    String? type,
    String? search,
    int limit = 10,
    int? lastSeenId,
  }) async {
    try {
      final uri = Uri.parse("$baseUrl/questions/paginated").replace(
        queryParameters: {
          if (skill != null) "skill": skill,
          if (difficulty != null) "difficulty": difficulty,
          if (type != null) "type": type,
          if (search != null) "search": search,
          if (lastSeenId != null)
            "lastSeenId": lastSeenId.toString(),
          "limit": limit.toString(),
        },
      );

      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        List list = [];

        if (data is Map) {
          if (data["data"] is List) {
            list = data["data"];
          } else if (data["data"] is Map &&
              data["data"]["content"] != null) {
            list = data["data"]["content"];
          } else if (data["content"] != null) {
            list = data["content"];
          } else if (data["items"] != null) {
            list = data["items"];
          }
        } else if (data is List) {
          list = data;
        }

        return list.map((e) => Question.fromJson(e)).toList();
      } else {
        throw Exception("API lỗi: ${res.statusCode} - ${res.body}");
      }
    } catch (e) {
      throw Exception("Lỗi getQuestions: $e");
    }
  }

  static Future<int> createExam({
    required String examType,
    required int totalQuestions,
  }) async {

    try {

      final uri = Uri.parse("$baseUrl/exams");

      final res = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "examType": examType,
          "totalQuestions": totalQuestions,
        }),
      );

      if (res.statusCode == 200|| res.statusCode == 201) {

        final data = jsonDecode(res.body);


        if (data["data"] != null && data["data"]["id"] != null) {
          return data["data"]["id"];
        }
        if(data["examId"] != null){
          return data["examId"];
        }

        return data["id"] ?? 0;

      } else {
        throw Exception("Create exam lỗi: ${res.body}");
      }

    } catch (e) {
      throw Exception("Lỗi createExam: $e");
    }
  }
  static Future<List<dynamic>> getAllExams() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/exams"));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        if (data is List) return data;
        if (data["data"] is List) return data["data"];
        if (data["content"] is List) return data["content"];
        if (data["items"] is List) return data["items"];
      }

      return [];
    } catch (e) {
      throw Exception("Lỗi getAllExams: $e");
    }
  }

  static Future<Map<String, dynamic>> getExamById(int id) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/exams/$id"),
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }

      throw Exception("Không lấy được exam");
    } catch (e) {
      throw Exception("Lỗi getExamById: $e");
    }
  }

  static Future<List<dynamic>> getExamsByType(String examType) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/exams/type/$examType"),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        if (data is List) return data;
        if (data["data"] is List) return data["data"];
        if (data["content"] is List) return data["content"];
        if (data["items"] is List) return data["items"];
      }

      return [];
    } catch (e) {
      throw Exception("Lỗi getExamsByType: $e");
    }
  }

  static Future<bool> deleteExam(int id) async {
    try {
      final res = await http.delete(
        Uri.parse("$baseUrl/exams/$id"),
      );

      return res.statusCode == 200 || res.statusCode == 204;
    } catch (e) {
      throw Exception("Lỗi deleteExam: $e");
    }
  }

  /// ================= SUBMIT SCORE =================
  static Future<void> submitExam({
    required int examId,
    required int score,
    required List<Map<String, dynamic>> answers,
  }) async {
    try {
      final uri = Uri.parse("$baseUrl/exams/$examId/submit");

      final res = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "examId": examId,
          "score": score,
          "listeningScore": 0,
          "status": "COMPLETED",
          "answers": answers,
        }),
      );

      if (res.statusCode != 200) {
        throw Exception("Submit lỗi: ${res.body}");
      }
    } catch (e) {
      throw Exception("Lỗi submitExam: $e");
    }
  }
}