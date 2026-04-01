enum LeaderboardType { ANSWERS, VOCAB, TIME }

class LeaderboardEntry {
  final int rank;
  final int userId;
  final String displayName;
  final String? avatarUrl;
  final bool isPro;
  final int score;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.isPro,
    required this.score,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: (json['rank'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      displayName: json['displayName'] as String? ?? 'Unknown',
      avatarUrl: json['avatarUrl'] as String?,
      isPro: json['isPro'] as bool? ?? false,
      score: (json['score'] as num).toInt(),
    );
  }
}

class MyRankInfo {
  final int myRank;
  final int myScore;
  final bool ranked;

  const MyRankInfo({
    required this.myRank,
    required this.myScore,
    required this.ranked,
  });

  factory MyRankInfo.fromJson(Map<String, dynamic> json) {
    return MyRankInfo(
      myRank: (json['myRank'] as num?)?.toInt() ?? 0,
      myScore: (json['myScore'] as num?)?.toInt() ?? 0,
      ranked: json['ranked'] as bool? ?? false,
    );
  }
}
