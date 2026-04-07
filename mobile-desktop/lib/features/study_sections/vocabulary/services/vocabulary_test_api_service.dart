import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/services/auth_api.dart';

class VocabularyTestApiService {
  static final String baseUrl = '${dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8123/api'}/v1/vocabulary/test';

  Future<int> fetchDueCount() async {
    try {
      final token = await AuthApi.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/due-count'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as int;
      }
      return 0;
    } catch (e) {
      debugPrint('Error fetching due count: $e');
      return 0;
    }
  }

  Future<Map<String, dynamic>?> generateTest() async {
    try {
      final token = await AuthApi.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/generate'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error generating test: $e');
      return null;
    }
  }

  Future<void> submitResults(List<Map<String, dynamic>> answers) async {
    try {
      final token = await AuthApi.getToken();

      await http.post(
        Uri.parse('$baseUrl/submit'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'answers': answers,
        }),
      );
    } catch (e) {
      debugPrint('Error submitting test results: $e');
    }
  }

  Future<void> logView(int id) async {
    try {
      final token = await AuthApi.getToken();

      await http.post(
        Uri.parse('$baseUrl/log-view/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      debugPrint('Error logging word view: $e');
    }
  }
}