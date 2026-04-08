import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../data/services/auth_api.dart';
import 'package:flutter/foundation.dart';
import '../models/feedback_model.dart';

class FeedbackApi {
  // Use standard emulator IP or load from env.
  // Note: /api/user/feedback is the base for submission and history list.
  static const String _baseUrl = 'http://10.0.2.2:8123/api/user/feedback';

  static Future<bool> submitFeedback({
    required String title,
    required String textContent,
    File? imageFile,
  }) async {
    try {
      final token = await AuthApi.getToken();
      if (token == null) {
        debugPrint('[FeedbackApi] Error: No token found');
        return false;
      }

      var request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['title'] = title;
      request.fields['textContent'] = textContent;

      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('[FeedbackApi] Feedback submitted successfully');
        return true;
      } else {
        debugPrint('[FeedbackApi] Error submitting feedback: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('[FeedbackApi] Exception submitting feedback: $e');
      return false;
    }
  }

  static Future<List<FeedbackModel>> getUserFeedbacks({int page = 0, int size = 10}) async {
    try {
      final token = await AuthApi.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$_baseUrl?page=$page&size=$size'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> content = data['content'];
        return content.map((f) => FeedbackModel.fromJson(f)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('[FeedbackApi] Exception getting user feedbacks: $e');
      return [];
    }
  }

  static Future<FeedbackDetailModel?> getFeedbackDetails(int id) async {
    try {
      final token = await AuthApi.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return FeedbackDetailModel.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('[FeedbackApi] Exception getting feedback details: $e');
      return null;
    }
  }
}
