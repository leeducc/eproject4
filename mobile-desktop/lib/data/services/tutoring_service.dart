import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_api.dart';
import 'notification_service.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../models/tutoring_models.dart';

class TutoringService {
  static final String apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8123/api';
  static final String wsUrl = apiBaseUrl.replaceFirst('http', 'ws').replaceFirst('/api', '/ws-chat/websocket');
  
  StompClient? _stompClient;
  final StreamController<Map<String, dynamic>> _queueController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _rtcController = StreamController<Map<String, dynamic>>.broadcast();
  
  Stream<Map<String, dynamic>> get queueStream => _queueController.stream;
  Stream<Map<String, dynamic>> get rtcStream => _rtcController.stream;

  Future<void> connect(int userId) async {
    final token = await AuthApi.getToken();

    _stompClient = StompClient(
      config: StompConfig(
        url: wsUrl,
        onConnect: (frame) {
          print('Connected to Tutoring WebSocket');
          _stompClient?.subscribe(
            destination: '/topic/tutoring-queue/student/$userId',
            callback: (frame) {
              if (frame.body != null) {
                _queueController.add(jsonDecode(frame.body!));
              }
            },
          );

          _stompClient?.subscribe(
            destination: '/user/queue/rtc-signal',
            callback: (frame) {
              if (frame.body != null) {
                _rtcController.add(jsonDecode(frame.body!));
              }
            },
          );

          
          _stompClient?.subscribe(
            destination: '/user/topic/notifications',
            callback: (frame) {
              if (frame.body != null) {
                final data = jsonDecode(frame.body!);
                if (data['type'] == 'REMINDER') {
                  NotificationService.showNotification(
                    id: DateTime.now().millisecond,
                    title: 'Nhắc nhở buổi học',
                    body: data['message'],
                  );
                }
              }
            },
          );
        },
        onWebSocketError: (dynamic error) => print('Tutoring WS Error: $error'),
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
      ),
    );

    _stompClient?.activate();
  }

  void joinQueue() {
    _stompClient?.send(
      destination: '/app/tutoring/queue/join',
      body: jsonEncode({}),
    );
  }

  void acceptMatch(int teacherId) {
    _stompClient?.send(
      destination: '/app/tutoring/student/accept',
      body: jsonEncode({'teacherId': teacherId}),
    );
  }

  void sendRtcSignal(Map<String, dynamic> signal) {
    _stompClient?.send(
      destination: '/app/tutoring/rtc/signal',
      body: jsonEncode(signal),
    );
  }

  Future<List<TeacherSchedule>> getAvailableTeachers() async {
    try {
      final token = await AuthApi.getToken();
      final url = '${apiBaseUrl.replaceFirst('/api', '/api/tutoring/slots')}/available-teachers';
      print('[TutoringService] Fetching: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => TeacherSchedule.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch teachers: ${response.statusCode}');
      }
    } catch (e) {
      print('[TutoringService] Error fetching teachers: $e');
      rethrow;
    }
  }

  Future<bool> bookSlot(int slotId) async {
    try {
      final token = await AuthApi.getToken();
      final url = '${apiBaseUrl.replaceFirst('/api', '/api/tutoring/slots')}/student/book/$slotId';
      print('[TutoringService] Booking slot: $url');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('[TutoringService] Error booking slot: $e');
      return false;
    }
  }

  void disconnect() {
    _stompClient?.deactivate();
    _queueController.close();
    _rtcController.close();
  }
}