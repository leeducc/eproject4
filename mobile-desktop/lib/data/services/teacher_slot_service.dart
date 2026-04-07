import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_api.dart';

class TeacherSlot {
  final int id;
  final int teacherId;
  final String startTime;
  final String endTime;
  final String status;

  TeacherSlot({
    required this.id,
    required this.teacherId,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory TeacherSlot.fromJson(Map<String, dynamic> json) {
    return TeacherSlot(
      id: json['id'],
      teacherId: json['teacherId'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      status: json['status'],
    );
  }
}

class TeacherSlotService {
  static final String baseUrl = '${dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8123/api'}/tutoring/slots';

  Future<List<TeacherSlot>> getAvailableSlots(int teacherId) async {
    final token = await AuthApi.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/student/available/$teacherId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => TeacherSlot.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load slots');
    }
  }

  Future<bool> bookSlot(int slotId) async {
    final token = await AuthApi.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/student/book/$slotId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 200;
  }
}