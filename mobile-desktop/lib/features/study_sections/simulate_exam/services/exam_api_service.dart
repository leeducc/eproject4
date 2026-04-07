import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/models/exam_model.dart';
import '../../../../core/models/exam_submission_model.dart';

class ExamApiService {
  static final String baseUrl = '${dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8123/api'}/v1/exams';

  Future<List<ExamModel>> fetchExamsByType(String examType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/type/$examType'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => ExamModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load exams of type $examType: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching exams by type: $e');
      throw Exception('Failed to fetch exams');
    }
  }

  Future<ExamSubmissionModel> submitExam(
      int examId, double? listeningScore, double? readingScore, int? writingSubmissionId, String status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse('$baseUrl/submit'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'examId': examId,
          'listeningScore': listeningScore,
          'readingScore': readingScore,
          'writingSubmissionId': writingSubmissionId,
          'status': status,
        }),
      );

      if (response.statusCode == 200) {
        return ExamSubmissionModel.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception('Failed to submit exam: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error submitting exam: $e');
      throw Exception('Failed to submit exam: $e');
    }
  }

  Future<List<ExamSubmissionModel>> fetchMySubmissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/my-submissions'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => ExamSubmissionModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch exam submissions');
      }
    } catch (e) {
      debugPrint('Error fetching exam submissions: $e');
      throw Exception('Failed to fetch exam submissions: $e');
    }
  }
}