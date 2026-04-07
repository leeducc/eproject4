import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../models/chat_message.dart';
import 'dart:async';

class ChatService {
  static final String apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8123/api';
  static final String wsUrl = apiBaseUrl.replaceFirst('http', 'ws').replaceFirst('/api', '/ws-chat/websocket');
  
  StompClient? _stompClient;
  final StreamController<ChatMessage> _messageController = StreamController<ChatMessage>.broadcast();
  Stream<ChatMessage> get messageStream => _messageController.stream;

  Future<void> connect(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    _stompClient = StompClient(
      config: StompConfig(
        url: wsUrl,
        onConnect: (frame) {
          print('Connected to Chat WebSocket');
          _stompClient?.subscribe(
            destination: '/topic/chat/$userId',
            callback: (frame) {
              if (frame.body != null) {
                final message = ChatMessage.fromJson(jsonDecode(frame.body!));
                _messageController.add(message);
              }
            },
          );
        },
        onWebSocketError: (dynamic error) => print('WS Error: $error'),
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
      ),
    );

    _stompClient?.activate();
  }

  void disconnect() {
    _stompClient?.deactivate();
    _messageController.close();
  }

  static Future<List<ChatMessage>> getChatHistory(int adminId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      final response = await http.get(
        Uri.parse('$apiBaseUrl/chat/$adminId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((m) => ChatMessage.fromJson(m)).toList();
      }
      return [];
    } catch (e) {
      print('History error: $e');
      return [];
    }
  }

  static Future<bool> sendMessage(int receiverId, String content, {String? filePath}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      var request = http.MultipartRequest('POST', Uri.parse('$apiBaseUrl/chat/send'));
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['receiverId'] = receiverId.toString();
      request.fields['content'] = content;

      if (filePath != null) {
        request.files.add(await http.MultipartFile.fromPath('file', filePath));
      }

      var response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      print('Send error: $e');
      return false;
    }
  }

  static Future<bool> editMessage(int messageId, String newContent) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.put(
        Uri.parse('$apiBaseUrl/chat/message/$messageId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(newContent),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Edit error: $e');
      return false;
    }
  }

  static Future<List<EditHistory>> getEditHistory(int messageId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$apiBaseUrl/chat/message/$messageId/history'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((h) => EditHistory.fromJson(h)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}