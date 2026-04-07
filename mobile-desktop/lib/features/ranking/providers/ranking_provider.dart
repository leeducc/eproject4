import 'package:flutter/foundation.dart';
import '../models/ranking_models.dart';
import '../services/ranking_api_service.dart';

class RankingProvider extends ChangeNotifier {
  final RankingApiService _api = RankingApiService();

  List<LeaderboardEntry> _entries = [];
  MyRankInfo? _myRankInfo;
  LeaderboardType _currentType = LeaderboardType.ANSWERS;
  bool _isLoading = false;
  String? _error;

  List<LeaderboardEntry> get entries => List.unmodifiable(_entries);
  MyRankInfo? get myRankInfo => _myRankInfo;
  LeaderboardType get currentType => _currentType;
  bool get isLoading => _isLoading;
  String? get error => _error;

  

  Future<void> loadLeaderboard(LeaderboardType type) async {
    debugPrint('[RankingProvider] loadLeaderboard type=$type');
    _currentType = type;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _api.fetchLeaderboard(type),
        _api.fetchMyRank(type),
      ]);

      _entries = results[0] as List<LeaderboardEntry>;
      _myRankInfo = results[1] as MyRankInfo?;
      debugPrint('[RankingProvider] loaded ${_entries.length} entries, myRank=$_myRankInfo');
    } catch (e) {
      _error = e.toString();
      debugPrint('[RankingProvider] load error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  

  void recordAnswers(int count) {
    if (count <= 0) return;
    debugPrint('[RankingProvider] recordAnswers count=$count');
    _api.recordAnswers(count);
  }

  void recordVocab(int count) {
    if (count <= 0) return;
    debugPrint('[RankingProvider] recordVocab count=$count');
    _api.recordVocab(count);
  }

  void recordTime(int seconds) {
    if (seconds <= 0) return;
    debugPrint('[RankingProvider] recordTime seconds=$seconds');
    _api.recordTime(seconds);
  }
}