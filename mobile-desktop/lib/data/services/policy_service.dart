import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/policy_model.dart';

class PolicyService {
  static final String _baseUrl = '${dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8123/api'}/v1/policies';
  static const String _cachePrefix = 'cached_policy_';

  Future<PolicyModel?> getPolicy(String type) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?type=$type'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        final policy = PolicyModel.fromJson(data);
        
        
        await _cachePolicy(type, jsonEncode(data));
        
        return policy;
      } else {
        print('[PolicyService] Failed to fetch policy $type: ${response.statusCode} - ${response.body}');
        return _getCachedPolicy(type);
      }
    } catch (e) {
      print('[PolicyService] Error fetching policy $type: $e');
      return _getCachedPolicy(type);
    }
  }

  Future<void> _cachePolicy(String type, String jsonString) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_cachePrefix$type', jsonString);
  }

  Future<PolicyModel?> _getCachedPolicy(String type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedString = prefs.getString('$_cachePrefix$type');
      if (cachedString != null) {
        final Map<String, dynamic> data = jsonDecode(cachedString);
        return PolicyModel.fromJson(data);
      }
    } catch (e) {
      print('Error reading cached policy $type: $e');
    }
    return null;
  }
}