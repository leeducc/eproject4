import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_api.dart';

class ICoinTransaction {
  final int id;
  final int amount;
  final String transactionType;
  final String description;
  final int balanceAfter;
  final String createdAt;

  ICoinTransaction({
    required this.id,
    required this.amount,
    required this.transactionType,
    required this.description,
    required this.balanceAfter,
    required this.createdAt,
  });

  factory ICoinTransaction.fromJson(Map<String, dynamic> json) {
    return ICoinTransaction(
      id: json['id'],
      amount: json['amount'],
      transactionType: json['transactionType'],
      description: json['description'],
      balanceAfter: json['balanceAfter'],
      createdAt: json['createdAt'],
    );
  }
}

class ICoinService {
  static final String baseUrl = '${dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8123/api'}/icoin';

  static Future<int?> getBalance() async {
    try {
      final token = await AuthApi.getToken();
      
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/balance'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['balance'] as int?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<ICoinTransaction>> getHistory() async {
    try {
      final token = await AuthApi.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/history'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => ICoinTransaction.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}