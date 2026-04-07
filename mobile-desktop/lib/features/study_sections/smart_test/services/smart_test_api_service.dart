import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/models/quiz_bank_models.dart';
import '../../../../data/services/auth_api.dart';
import '../models/smart_test_models.dart';

class SmartTestApiService {
  String get _baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8123/api';

  Future<List<Question>> generateSmartTest(String skill, String level) async {
    final token = await AuthApi.getToken();
    
    final uri = Uri.parse('$_baseUrl/v1/tests/smart-generate?skill=$skill&level=${Uri.encodeComponent(level)}');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((json) => Question.fromJson(json)).toList();
    } else {
      throw Exception('Failed to generate test. Status: ${response.statusCode}');
    }
  }

  Future<SmartTestSubmitResponse> submitSmartTest(SmartTestSubmitRequest request) async {
    final token = await AuthApi.getToken();
    
    final response = await http.post(
      Uri.parse('$_baseUrl/v1/tests/submit'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return SmartTestSubmitResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to submit test. Status: ${response.statusCode}');
    }
  }
}