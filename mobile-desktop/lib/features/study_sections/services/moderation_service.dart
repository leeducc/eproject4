import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../data/services/auth_api.dart';

class ModerationService {
  String get _baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8123/api';

  Future<String?> _getToken() async {
    return await AuthApi.getToken();
  }

  Future<void> submitReport(String itemType, int itemId, String reason) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/v1/moderation/report'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'itemType': itemType,
        'itemId': itemId,
        'reason': reason,
      }),
    );

    if (response.statusCode != 200) {
      String? errorMessage;
      try {
        final error = jsonDecode(response.body);
        errorMessage = error['message'];
      } catch (_) {}
      throw Exception(errorMessage ?? 'Failed to submit report. Status: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> getNotifications() async {
    final token = await _getToken();
    if (token == null) {
      print('[ModerationService] No token found when fetching notifications');
      return [];
    }
    
    final response = await http.get(
      Uri.parse('$_baseUrl/v1/moderation/notifications'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load notifications. Status: ${response.statusCode}');
    }
  }

  Future<void> markRead(int id) async {
    final token = await _getToken();
    await http.post(
      Uri.parse('$_baseUrl/v1/moderation/notifications/$id/read'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }
}