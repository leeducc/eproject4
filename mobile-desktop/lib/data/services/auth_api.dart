import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthApi {

  static final String baseUrl = '${dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080/api'}/auth';
  
  static final GoogleSignIn _googleSignIn = GoogleSignIn(

    serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'], 
    clientId: dotenv.env['GOOGLE_CLIENT_ID'],
    scopes: ['email'],
  );

  static Future<Map<String, dynamic>?> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // The user canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Failed to get ID token from Google');
      }

      // Send the ID token to our Spring Boot backend
      final response = await http.post(
        Uri.parse('$baseUrl/login/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('token')) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', data['token']);
          if (data.containsKey('isPro')) {
            await prefs.setBool('is_pro', data['isPro'] == true);
          }
          print('Saved token from Google login');
        }
        return data; // contains token, email, role, fullName
      } else {
        throw Exception('Backend authentication failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Google login error: $e');
      return {'error': e.toString()};
    }
  }

  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('token')) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', data['token']);
          if (data.containsKey('isPro')) {
            await prefs.setBool('is_pro', data['isPro'] == true);
          }
          print('Saved token from email login');
        }
        return true;
      }
      print('Login false: ${response.statusCode} - ${response.body}');
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  static Future<bool> register(String email, String code, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code, 'password': password}),
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
}
