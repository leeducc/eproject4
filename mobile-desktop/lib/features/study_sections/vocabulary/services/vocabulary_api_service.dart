import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vocabulary.dart';

class VocabularyApiService {
  static final String baseUrl = '${dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8123/api'}/v1/vocabulary';

  Future<List<Vocabulary>> fetchVocabulary(String levelGroup) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      // The backend uses path /api/v1/vocabulary?levelGroup=0-4&limit=100
      final uri = Uri.parse('$baseUrl?levelGroup=$levelGroup&limit=200');
      print('Fetching vocabulary from: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // The backend PaginatedResponse uses 'items' field, but some models might use 'content'
        final List<dynamic> items = decoded['items'] ?? decoded['content'] ?? [];
        print('Successfully fetched vocabulary: ${items.length} items for level $levelGroup');
        return items.map((json) => Vocabulary.fromJson(json)).toList();
      } else {
        print('Failed to fetch vocabulary: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching vocabulary: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchWordDetails(String word) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final uri = Uri.parse('$baseUrl/${Uri.encodeComponent(word)}/details');
      print('Fetching word details from: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('Failed to fetch word details: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching word details: $e');
      return null;
    }
  }

  Future<bool> toggleFavorite(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final uri = Uri.parse('$baseUrl/$id/favorite');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as bool;
      }
      return false;
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }

  Future<List<Vocabulary>> fetchFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final uri = Uri.parse('$baseUrl/favorites');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> items = jsonDecode(response.body);
        return items.map((json) => Vocabulary.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching favorites: $e');
      return [];
    }
  }
}
