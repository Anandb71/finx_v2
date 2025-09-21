enum LeaderboardType {
  portfolioValue,
  portfolioGrowth,
  tradingSkills,
  xpPoints,
  learning,
  social,
  daily,
  weekly,
  monthly,
}

class LeaderboardEntry {
  final String userId;
  final String username;
  final String? avatarUrl;
  final double value;
  final double? changePercent;
  final int rank;
  final LeaderboardType type;
  final DateTime lastUpdated;
  final Map<String, dynamic>?
  metadata; // Additional data like streak, badges, etc.

  const LeaderboardEntry({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.value,
    this.changePercent,
    required this.rank,
    required this.type,
    required this.lastUpdated,
    this.metadata,
  });

  LeaderboardEntry copyWith({
    String? userId,
    String? username,
    String? avatarUrl,
    double? value,
    double? changePercent,
    int? rank,
    LeaderboardType? type,
    DateTime? lastUpdated,
    Map<String, dynamic>? metadata,
  }) {
    return LeaderboardEntry(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      value: value ?? this.value,
      changePercent: changePercent ?? this.changePercent,
      rank: rank ?? this.rank,
      type: type ?? this.type,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'avatarUrl': avatarUrl,
      'value': value,
      'changePercent': changePercent,
      'rank': rank,
      'type': type.name,
      'lastUpdated': lastUpdated.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'],
      username: json['username'],
      avatarUrl: json['avatarUrl'],
      value: json['value'].toDouble(),
      changePercent: json['changePercent']?.toDouble(),
      rank: json['rank'],
      type: LeaderboardType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => LeaderboardType.portfolioValue,
      ),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
    );
  }
}
