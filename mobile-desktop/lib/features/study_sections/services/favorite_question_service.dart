import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../data/services/auth_api.dart';

class FavoriteQuestionService {
  String get _baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8123/api';

  Future<String?> _getToken() async {
    return await AuthApi.getToken();
  }

  Future<bool> toggleFavorite(int questionId) async {
    final token = await _getToken();
    final uri = Uri.parse('$_baseUrl/v1/questions/favorite/$questionId');
    
    try {
      debugPrint('[FavoriteQuestionService] Toggling favorite for question: $questionId');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final bool isFavorite = data['isFavorite'] ?? false;
        debugPrint('[FavoriteQuestionService] Success: isFavorite=$isFavorite');
        return isFavorite;
      } else {
        debugPrint('[FavoriteQuestionService] Failed: ${response.statusCode}');
        throw Exception('Failed to toggle favorite. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[FavoriteQuestionService] Exception: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> fetchFavorites() async {
    final token = await _getToken();
    final uri = Uri.parse('$_baseUrl/v1/questions/favorite');
    
    try {
      debugPrint('[FavoriteQuestionService] Fetching all favorites');
      final response = await http.get(
        uri,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data;
      } else {
        throw Exception('Failed to fetch favorites. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[FavoriteQuestionService] Fetch Exception: $e');
      rethrow;
    }
  }

  Future<bool> getFavoriteStatus(int questionId) async {
    final token = await _getToken();
    final uri = Uri.parse('$_baseUrl/v1/questions/favorite/$questionId/status');
    
    try {
      final response = await http.get(
        uri,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['isFavorite'] ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('[FavoriteQuestionService] Status Exception: $e');
      return false;
    }
  }
}
