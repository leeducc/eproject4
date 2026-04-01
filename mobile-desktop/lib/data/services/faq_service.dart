import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/faq_model.dart';

class FAQService {
  static final String _baseUrl = '${dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8123/api'}/v1/faqs';
  static const String _cacheKey = 'cached_faqs';

  Future<List<FAQModel>> getFAQs() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        final faqs = data.map((json) => FAQModel.fromJson(json)).toList();
        
        // Update cache
        _cacheFAQs(response.body);
        
        return faqs;
      } else {
        print('[FAQService] Failed to fetch FAQs: ${response.statusCode} - ${response.body}');
        return _getCachedFAQs();
      }
    } catch (e) {
      print('[FAQService] Error fetching FAQs: $e');
      return _getCachedFAQs();
    }
  }

  Future<void> _cacheFAQs(String jsonString) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonString);
  }

  Future<List<FAQModel>> _getCachedFAQs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedString = prefs.getString(_cacheKey);
      if (cachedString != null) {
        final List<dynamic> data = jsonDecode(cachedString);
        return data.map((json) => FAQModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error reading cached FAQs: $e');
    }
    return [];
  }
}
