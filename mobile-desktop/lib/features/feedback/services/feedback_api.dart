import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../data/services/auth_api.dart';
import 'package:flutter/foundation.dart';

class FeedbackApi {
  static const String _baseUrl = 'http://10.0.2.2:8123/api/user/feedback'; // Use standard emulator IP or load from env

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
}
