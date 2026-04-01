import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/quiz_bank_models.dart';
import '../../../core_quiz/models/quiz_question.dart';

class QuestionBankApiService {
  String get _baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8123/api';

  Future<List<QuizQuestion>> fetchByTags(List<dynamic> tags, {required String skill}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    final uri = Uri.parse('$_baseUrl/v1/questions/filter');
    
    // Construct FilterRequest
    final List<String> tagStrings = tags.map((t) {
      if (t is Map) {
        return "${t['namespace']}:${t['name']}";
      }
      return t.toString();
    }).toList();

    final bodyRequest = {
      "logic": "AND",
      "skill": skill,
      "groups": [
        {
          "logic": "OR",
          "tags": tagStrings
        }
      ]
    };

    debugPrint('[QuestionBankApiService] Fetching questions for skill: $skill with tags: $tagStrings');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(bodyRequest),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((json) {
        final baseQ = Question.fromJson(json);
        return QuizQuestion.from(baseQ);
      }).toList();
    } else {
      throw Exception('Failed to load questions by tags. Status: ${response.statusCode}');
    }
  }
}
