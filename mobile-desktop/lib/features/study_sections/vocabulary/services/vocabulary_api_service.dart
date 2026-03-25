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
        final List<dynamic> items = decoded['content']; // PaginatedResponse structure
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
}
