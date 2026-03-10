import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/topic_model.dart';
import '../models/essay_submission_response.dart';

class WritingApiService {
  
  static final String baseUrl = '${dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080/api'}/writing';

  Future<List<Topic>> fetchTopics() async {
    final response = await http.get(Uri.parse('$baseUrl/topics'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Topic.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load topics: ${response.statusCode}');
    }
  }

  Future<EssaySubmissionResponse> submitEssay(int topicId, String content, String gradingType) async {
    final response = await http.post(
      Uri.parse('$baseUrl/submit'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'topicId': topicId,
        'content': content,
        'gradingType': gradingType, // "HUMAN" or "AI"
      }),
    );

    if (response.statusCode == 200) {
      return EssaySubmissionResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to submit essay: ${response.statusCode}');
    }
  }
}
