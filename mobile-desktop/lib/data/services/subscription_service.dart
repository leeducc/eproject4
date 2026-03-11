import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionService {
  static final String baseUrl = '${dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080/api'}/subscriptions';

  static Future<bool> purchasePro(int months, int priceICoins) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        print('No auth token found for subscription purchase');
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/purchase'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'months': months,
          'priceICoins': priceICoins,
        }),
      );

      if (response.statusCode == 200) {
        print('Successfully purchased Pro subscription');
        return true;
      } else {
        print('Failed to purchase Pro subscription: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error purchasing Pro subscription: $e');
      return false;
    }
  }
}
