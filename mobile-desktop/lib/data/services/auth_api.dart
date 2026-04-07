import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthApi {

  static final String baseUrl = '${dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8123/api'}/auth';
  
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'], 
    clientId: dotenv.env['GOOGLE_CLIENT_ID'],
    scopes: ['email'],
  );

  static final _storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>?> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; 
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Failed to get ID token from Google');
      }

      
      final response = await http.post(
        Uri.parse('$baseUrl/login/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('token')) {
          await _storage.write(key: 'auth_token', value: data['token']);
          final prefs = await SharedPreferences.getInstance();
          if (data.containsKey('isPro')) {
            await prefs.setBool('is_pro', data['isPro'] == true);
          }
          print('Saved token securely from Google login');
        }
        return data; 
      } else {
        throw Exception('Backend authentication failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Google login error: $e');
      return {'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('Attempting login for: $email at ${Uri.parse('$baseUrl/login')}');
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));
      
      final Map<String, dynamic> data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        if (data.containsKey('token')) {
          await _storage.write(key: 'auth_token', value: data['token']);
          final prefs = await SharedPreferences.getInstance();
          if (data.containsKey('isPro')) {
            await prefs.setBool('is_pro', data['isPro'] == true);
          }
          print('Saved token securely from email login');
        }
        return {'success': true, ...data};
      } else {
        print('Login failed: ${response.statusCode} - ${response.body}');
        return {
          'success': false, 
          'error': data['error'] ?? 'Sai email hoặc mật khẩu.'
        };
      }
    } catch (e) {
      print('Login error details: $e');
      String userMessage = 'Lỗi kết nối';
      if (e.toString().contains('TimeoutException')) {
        userMessage = 'Yêu cầu đăng nhập quá hạn. Vui lòng kiểm tra mạng hoặc máy chủ.';
      } else if (e.toString().contains('Connection refused')) {
        userMessage = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra máy chủ backend.';
      }
      return {'success': false, 'error': '$userMessage: ${e.toString()}'};
    }
  }

  static Future<bool> checkEmailAvailable(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/register/check-email?email=$email'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['available'] ?? false;
      }
      return false;
    } catch (e) {
      print('Check email error: $e');
      return false;
    }
  }

  static Future<bool> register(String email, String code, String password, String fullName, String phoneNumber, String address) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code,
          'password': password,
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'address': address,
        }),
      );
      if (response.statusCode != 200) {
        print('Register failed: ${response.statusCode} - ${response.body}');
      }
      return response.statusCode == 200;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }

  static Future<void> sendVerificationCode(String email, String captchaToken) async {
    try {
      final url = '$baseUrl/register/send-otp';
      print('Sending OTP request to: $url');
      print('Request body: ${jsonEncode({'email': email, 'captchaToken': captchaToken})}');
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'captchaToken': captchaToken}),
      );
      print('Send OTP response: ${response.statusCode} - ${response.body}');
      if (response.statusCode != 200) {
         print('Failed to send code: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Send code error: $e');
    }
  }

  static Future<void> sendForgotPasswordOtp(String email, String captchaToken) async {
    try {
      final url = '$baseUrl/forgot-password/send-otp';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'captchaToken': captchaToken}),
      );
      if (response.statusCode != 200) {
        print('Forgot password send OTP failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Forgot password send OTP error: $e');
    }
  }

  static Future<bool> resetPassword(String email, String code, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password/reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code, 'newPassword': newPassword}),
      );
      if (response.statusCode != 200) {
        print('Reset password failed: ${response.statusCode} - ${response.body}');
      }
      return response.statusCode == 200;
    } catch (e) {
      print('Reset password error: $e');
      return false;
    }
  }
  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  static Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _googleSignIn.signOut();
  }
}