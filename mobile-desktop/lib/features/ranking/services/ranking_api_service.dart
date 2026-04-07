import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ranking_models.dart';

class RankingApiService {
  static String get _base =>
      '${dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8123/api'}/v1/ranking';

  Future<String?> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Map<String, String> _authHeaders(String? token) => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  

  Future<List<LeaderboardEntry>> fetchLeaderboard(LeaderboardType type,
      {int page = 0, int size = 50}) async {
    try {
      final typeStr = type.name.toUpperCase();
      final uri = Uri.parse('$_base/leaderboard?type=$typeStr&page=$page&size=$size');
      print('[RankingApiService] fetchLeaderboard type=$typeStr uri=$uri');

      final response = await http.get(uri,
          headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('[RankingApiService] leaderboard returned ${data.length} entries');
        return data.map((e) => LeaderboardEntry.fromJson(e)).toList();
      } else {
        print('[RankingApiService] leaderboard error ${response.statusCode}: ${response.body}');
        return [];
      }
    } catch (e) {
      print('[RankingApiService] fetchLeaderboard exception: $e');
      return [];
    }
  }

  

  Future<MyRankInfo?> fetchMyRank(LeaderboardType type) async {
    try {
      final token = await _token();
      if (token == null) {
        print('[RankingApiService] fetchMyRank: no auth token');
        return null;
      }
      final typeStr = type.name.toUpperCase();
      final uri = Uri.parse('$_base/my-rank?type=$typeStr');
      print('[RankingApiService] fetchMyRank type=$typeStr');

      final response = await http.get(uri, headers: _authHeaders(token));

      if (response.statusCode == 200) {
        return MyRankInfo.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('[RankingApiService] fetchMyRank exception: $e');
      return null;
    }
  }

  

  Future<void> recordAnswers(int count) async {
    try {
      final token = await _token();
      if (token == null) return;
      print('[RankingApiService] recordAnswers count=$count');
      await http.post(
        Uri.parse('$_base/record-answers'),
        headers: _authHeaders(token),
        body: jsonEncode({'count': count}),
      );
    } catch (e) {
      print('[RankingApiService] recordAnswers exception: $e');
    }
  }

  Future<void> recordVocab(int count) async {
    try {
      final token = await _token();
      if (token == null) return;
      print('[RankingApiService] recordVocab count=$count');
      await http.post(
        Uri.parse('$_base/record-vocab'),
        headers: _authHeaders(token),
        body: jsonEncode({'count': count}),
      );
    } catch (e) {
      print('[RankingApiService] recordVocab exception: $e');
    }
  }

  Future<void> recordTime(int seconds) async {
    try {
      final token = await _token();
      if (token == null) return;
      print('[RankingApiService] recordTime seconds=$seconds');
      await http.post(
        Uri.parse('$_base/record-time'),
        headers: _authHeaders(token),
        body: jsonEncode({'seconds': seconds}),
      );
    } catch (e) {
      print('[RankingApiService] recordTime exception: $e');
    }
  }
}