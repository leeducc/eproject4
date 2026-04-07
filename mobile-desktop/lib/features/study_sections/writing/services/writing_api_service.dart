import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/topic_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/services/auth_api.dart';
import '../models/essay_submission_response.dart';

class WritingApiService {
  
  static final String baseUrl = '${dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8123/api'}/writing';

  Future<List<Topic>> fetchTopics() async {
    try {
      final token = await AuthApi.getToken();
      
      if (token == null) {
        debugPrint('No auth token found for fetchTopics');
      } else {
        debugPrint('Found auth token for fetchTopics');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/topics'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        debugPrint('[WritingApiService] Raw response: ${response.body}');
        final List<dynamic> jsonList = jsonDecode(response.body);
        debugPrint('Successfully fetched topics, count: ${jsonList.length}');
        return jsonList.map((json) => Topic.fromJson(json)).toList();
      } else {
        debugPrint('Failed to load topics: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load topics: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching topics: $e');
      throw Exception('Failed to load topics: $e');
    }
  }

  Future<EssaySubmissionResponse> submitEssay(int topicId, String content, String gradingType) async {
    try {
      final token = await AuthApi.getToken();
      
      debugPrint('Submitting essay for topicId: $topicId, gradingType: $gradingType');

      final response = await http.post(
        Uri.parse('$baseUrl/submit'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'topicId': topicId,
          'content': content,
          'gradingType': gradingType, 
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Successfully submitted essay: ${response.body}');
        return EssaySubmissionResponse.fromJson(jsonDecode(response.body));
      } else {
        debugPrint('Failed to submit essay: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to submit essay: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error submitting essay: $e');
      throw Exception('Failed to submit essay: $e');
    }
  }

  Future<List<EssaySubmissionResponse>> fetchMySubmissions() async {
    try {
      final token = await AuthApi.getToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/my-submissions'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => EssaySubmissionResponse.fromJson(json)).toList();
      } else {
        debugPrint('Failed to fetch submissions: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to fetch submissions');
      }
    } catch (e) {
      debugPrint('Error fetching submissions: $e');
      throw Exception('Failed to fetch submissions: $e');
    }
  }
}