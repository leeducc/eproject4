import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ICoinService {
  static final String baseUrl = '${dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080/api'}/icoin';

  static Future<int?> getBalance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        print('No auth token found for iCoin balance fetch');
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/balance'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Fetched iCoin balance: ${data['balance']}');
        return data['balance'] as int?;
      } else {
        print('Failed to fetch iCoin balance: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching iCoin balance: $e');
      return null;
    }
  }
}
