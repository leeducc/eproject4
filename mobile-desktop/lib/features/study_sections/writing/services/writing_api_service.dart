import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/topic_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/essay_submission_response.dart';

class WritingApiService {
  
  static final String baseUrl = '${dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080/api'}/writing';

  Future<List<Topic>> fetchTopics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        print('No auth token found for fetchTopics');
      } else {
        print('Found auth token for fetchTopics');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/topics'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        print('Successfully fetched topics, count: ${jsonList.length}');
        return jsonList.map((json) => Topic.fromJson(json)).toList();
      } else {
        print('Failed to load topics: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load topics: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching topics: $e');
      throw Exception('Failed to load topics: $e');
    }
  }

  Future<EssaySubmissionResponse> submitEssay(int topicId, String content, String gradingType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      print('Submitting essay for topicId: $topicId, gradingType: $gradingType');

      final response = await http.post(
        Uri.parse('$baseUrl/submit'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'topicId': topicId,
          'content': content,
          'gradingType': gradingType, // "HUMAN" or "AI"
        }),
      );

      if (response.statusCode == 200) {
        print('Successfully submitted essay: ${response.body}');
        return EssaySubmissionResponse.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to submit essay: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to submit essay: ${response.statusCode}');
      }
    } catch (e) {
      print('Error submitting essay: $e');
      throw Exception('Failed to submit essay: $e');
    }
  }
}
