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
  final Map<String, dynamic>? metadata; // Additional data like streak, badges, etc.
  
  // Additional properties for the leaderboard screen
  final String name;
  final double change;
  final int level;
  final bool isCurrentUser;

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
    required this.name,
    required this.change,
    required this.level,
    required this.isCurrentUser,
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
    String? name,
    double? change,
    int? level,
    bool? isCurrentUser,
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
      name: name ?? this.name,
      change: change ?? this.change,
      level: level ?? this.level,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
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
      'name': name,
      'change': change,
      'level': level,
      'isCurrentUser': isCurrentUser,
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
      name: json['name'] ?? json['username'],
      change: json['change']?.toDouble() ?? json['changePercent']?.toDouble() ?? 0.0,
      level: json['level'] ?? 1,
      isCurrentUser: json['isCurrentUser'] ?? false,
    );
  }
}
