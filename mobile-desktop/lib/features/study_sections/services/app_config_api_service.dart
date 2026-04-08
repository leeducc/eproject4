import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../core/models/app_section_model.dart';
import '../../../../data/services/auth_api.dart';

class AppConfigApiService {
  String get _baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8123/api';

  Future<List<AppSectionModel>> getSections(String skill, String difficultyBand) async {
    final token = await AuthApi.getToken();
    
    final uri = Uri.parse('$_baseUrl/v1/app-sections?skill=$skill&difficultyBand=${Uri.encodeComponent(difficultyBand)}');
    debugPrint('[AppConfigApiService] Fetching sections: $uri');
    
    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      debugPrint('[AppConfigApiService] Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        debugPrint('[AppConfigApiService] Data count: ${body.length}');
        return body.map((m) => AppSectionModel.fromJson(m)).toList();
      } else {
        debugPrint('[AppConfigApiService] Error body: ${response.body}');
        throw Exception('Failed to load sections. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[AppConfigApiService] Exception: $e');
      rethrow;
    }
  }

  Future<List<int>> getSolvedQuestionIds() async {
    final token = await AuthApi.getToken();
    
    final uri = Uri.parse('$_baseUrl/v1/section-stats/solved-questions');
    debugPrint('[AppConfigApiService] Fetching solved questions: $uri');
    
    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((id) => id as int).toList();
      } else {
        debugPrint('[AppConfigApiService] Error solved questions: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('[AppConfigApiService] Solved questions exception: $e');
      return [];
    }
  }
}