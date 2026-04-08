import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../data/services/auth_api.dart';
import '../../../core/models/quiz_bank_models.dart';
import '../../../core_quiz/models/quiz_question.dart';

class QuestionBankApiService {
  String get _baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8123/api';

  Future<List<QuizQuestion>> fetchByTags(List<dynamic> tags, {required String skill}) async {
    final token = await AuthApi.getToken();
    
    final uri = Uri.parse('$_baseUrl/v1/questions/filter');
    
    
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

    try {
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
        debugPrint('[QuestionBankApiService] Successfully fetched ${body.length} items (raw)');
        
        final List<QuizQuestion> results = [];
        for (var item in body) {
          final isGroup = item['isGroup'] == true || item['type'] == 'COMPREHENSION';
          
          if (isGroup) {
            final Map<String, dynamic> data = (item['data'] is Map) 
                ? Map<String, dynamic>.from(item['data'] as Map) 
                : {};
            final List<dynamic> children = data['questions'] as List<dynamic>? ?? [];
            final String passage = data['content']?.toString() ?? item['instruction']?.toString() ?? '';
            
            debugPrint('[QuestionBankApiService] Expanding COMPREHENSION group with ${children.length} questions');
            
            for (var childJson in children) {
              if (childJson is Map<String, dynamic>) {
                final baseQ = Question.fromJson(childJson);
                // Inherit passage if not present in child data
                if (baseQ.data['passage'] == null) {
                  baseQ.data['passage'] = passage;
                }
                results.add(QuizQuestion.from(baseQ));
              }
            }
          } else if (item is Map<String, dynamic>) {
            final baseQ = Question.fromJson(item);
            results.add(QuizQuestion.from(baseQ));
          }
        }
        
        debugPrint('[QuestionBankApiService] Total questions after expansion: ${results.length}');
        return results;
      } else {
        debugPrint('[QuestionBankApiService] FAILED: ${response.statusCode}');
        debugPrint('[QuestionBankApiService] RAW body: ${response.body}');
        throw Exception('Failed to load questions by tags. Status: ${response.statusCode}');
      }
    } catch (e, stack) {
      debugPrint('[QuestionBankApiService] EXCEPTION: $e');
      debugPrint(stack.toString());
      rethrow;
    }
  }
}