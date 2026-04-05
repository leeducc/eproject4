import 'dart:convert';
import 'package:http/http.dart' as http;


class ExamService {

  static const String baseUrl = "http://10.0.2.2:8080/api/v1";

  static Future<bool> submitExam({
    required int examId,
    required int readingScore,
    required List<Map<String, dynamic>> answers,
  }) async {

    try {

      final uri = Uri.parse("$baseUrl/exams/$examId/submit");

      print("📤 Submit Exam:");
      print("ExamId: $examId");
      print("Answers: $answers");

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "examId": examId,
          "readingScore": readingScore,
          "listeningScore": 0,
          "status": "COMPLETED",
          "answers": answers,
        }),
      );

      print("📥 Response: ${response.statusCode}");
      print("📥 Body: ${response.body}");

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }

    } catch (e) {
      print("❌ Submit lỗi: $e");
      return false;
    }
  }
}